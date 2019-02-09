 
/*------------------------------------------------------------------------
   File        : FindState
   Purpose     : Finds <FIND> statements without <FIRST,LAST,NEXT,RPEV> modifiers
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 26.01.2018 18:03:26
   Notes       : 
 ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.FindState inherits AbstractRule serializable abstract:
    
    define protected temp-table ttIndex no-undo
        field IndexName as character.
    
    define protected temp-table ttIndexField no-undo
        field IndexName as character
        field FieldName as character.
        
    define protected temp-table ttBufferField no-undo
        field FieldName as character.
    
    define protected property TableType as character no-undo 
    get.
    set. 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public FindState (  ):
        super ().
        
        assign
            RuleDescription = "Finds <FIND> statements without <FIRST,LAST,NEXT,RPEV> modifiers":t
            RuleId          = "FindState":U
            Severity        = 6.
        
    end constructor. 
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method protected void ExtractBufferFields( input bufferName as character ):
        
        define variable bufferHandle as handle  no-undo.
        define variable cnt          as integer no-undo.
        
        empty temp-table ttBufferField.
        
        find first ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_BUFFER:GetValue()
            and ttProUnit.UnitName = bufferName no-error.
        if available(ttProUnit) then
            bufferName = ttProUnit.DataType.
            
        create buffer bufferHandle for table bufferName no-error.
        if valid-handle(bufferHandle) then
        do:
            do cnt = 1 to bufferHandle:num-fields:
                create ttBufferField.
                ttBufferField.FieldName = bufferHandle:buffer-field(cnt):name.
            end.
        end.
        
        return.
        finally:
            if valid-handle(bufferHandle) then
                delete object bufferHandle.    
        end finally.
    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method protected void ExtractIndexes( input bufferName as character ):
        
        define variable bufferHandle as handle    no-undo.
        define variable cnt          as integer   no-undo.
        define variable fieldNum     as integer   no-undo.
        define variable indexInfo    as character no-undo.
        
        empty temp-table ttIndex.
        empty temp-table ttIndexField.
        
        find first ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_BUFFER:GetValue()
            and ttProUnit.UnitName = bufferName no-error.
        if available(ttProUnit) then
            bufferName = ttProUnit.DataType.
            
        create buffer bufferHandle for table bufferName no-error.
        if valid-handle(bufferHandle) then
        do:
            BLK_IDX:            
            do while true:
                assign
                    cnt       = cnt + 1
                    indexInfo = bufferHandle:index-information(cnt).                
                if indexInfo = ? then
                    leave BLK_IDX.
                if entry(2, indexInfo) = "1":u then
                do:
                    create ttIndex.
                    ttIndex.IndexName = entry(1, indexInfo).
                    do fieldNum = 5 to num-entries(indexInfo) by 2:
                        create ttIndexField.
                        assign
                            ttIndexField.IndexName = ttIndex.IndexName
                            ttIndexField.FieldName = entry(fieldNum, indexInfo).                        
                    end.                    
                end.                
            end.
        end.
        
        return.
        finally:
            if valid-handle(bufferHandle) then
                delete object bufferHandle.    
        end finally.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method protected logical IsUniqueClause( input findNodeNum as integer ):
        
        define variable isUnique as logical no-undo.        
        
        define buffer ttOfNode       for ttNode.
        define buffer ttWhereNode    for ttNode.
        define buffer ttRecordNode   for ttNode.
        define buffer ttOfRecordNode for ttNode.
        define buffer ttBadNode      for ttNode.
        define buffer ttEqNode       for ttNode.
        define buffer ttFieldRefNode for ttNode.
        define buffer ttIDNode       for ttNode.                

        find first ttRecordNode where ttRecordNode.ParentNum = findNodeNum
            and ttRecordNode.NodeType = ProParserTokenTypes:RECORD_NAME.
        ExtractIndexes(ttRecordNode.NodeText).
                
        find first ttOfNode where ttOfNode.ParentNum = ttRecordNode.NodeNum
            and ttOfNode.NodeType = ProParserTokenTypes:OF no-error.
        if available(ttOfNode) then
        do:                        
            find first ttOfRecordNode where ttOfRecordNode.ParentNum = ttOfNode.NodeNum
                and ttOfRecordNode.NodeType = ProParserTokenTypes:RECORD_NAME no-error.            
            if available(ttOfRecordNode) then
            do:            
                ExtractBufferFields(ttOfRecordNode.NodeText).                
                for each ttIndex:
                    isUnique = true.
                    for each ttIndexField where ttIndexField.IndexName = ttIndex.IndexName:
                        find first ttBufferField where ttBufferField.FieldName = ttIndexField.FieldName no-error.
                        if not available(ttBufferField) then
                            isUnique = false.
                    end.
                    if isUnique then
                        return true.
                end.                
            end.
        end.        
        
        find first ttWhereNode where ttWhereNode.ParentNum = ttRecordNode.NodeNum
            and ttWhereNode.NodeType = ProParserTokenTypes:WHERE.
        if can-find(first ttBadNode where ttbadNode.ParentNum = ttWhereNode.NodeNum
            and (ttBadNode.NodeType = ProParserTokenTypes:NOT or ttBadNode.NodeType = ProParserTokenTypes:OR)) then
            return false.
                            
        empty temp-table ttBufferField.        
        for each ttEqNode where ttEqNode.ParentNum = ttWhereNode.NodeNum
            and ttEqNode.NodeType = ProParserTokenTypes:EQ,
            each ttFieldRefNode where ttFieldRefNode.ParentNum = ttEqNode.NodeNum
            and ttFieldRefNode.NodeType = ProParserTokenTypes:Field_ref,            
            first ttIDNode where ttIDNode.ParentNum = ttFieldRefNode.NodeNum
            and ttIDNode.NodeType = ProParserTokenTypes:ID
            and ttIDNode.NodeText begins ttRecordNode.NodeText + ".":u:
            create ttBufferField.
            ttBufferField.FieldName = substring(ttIDNode.NodeText, length(ttRecordNode.NodeText, "character":u) + 2).
        end.
        
        for each ttIndex:
            isUnique = true.
            for each ttIndexField where ttIndexField.IndexName = ttIndex.IndexName:
                find first ttBufferField where ttBufferField.FieldName = ttIndexField.FieldName no-error.
                if not available(ttBufferField) then
                    isUnique = false.
            end.
            if isUnique then
                return true.
        end. 
        
        return false.
        catch e as Progress.Lang.Error :
            return false. 
        end catch.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Start method for visiting ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/

    method override public void Visit
        (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
        ):
        define buffer ttDirNode    for ttNode.
        define buffer ttWhereNode  for ttNode.
        define buffer ttRecordNode for ttNode.
        define buffer ttEqNode     for ttNode.
        define buffer ttRowIdNode  for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:FIND,
            first ttRecordNode where ttRecordNode.ParentNum = ttNode.NodeNum
            and ttRecordNode.StoreType = TableType
            and ttRecordNode.NodeType = ProParserTokenTypes:RECORD_NAME,
            first ttDirNode where ttDirNode.NodeNum = ttNode.FirstChild:
                            
            if ttDirNode.NodeType = ProParserTokenTypes:FIRST
                or ttDirNode.NodeType = ProParserTokenTypes:LAST
                or ttDirNode.NodeType = ProParserTokenTypes:PREV
                or ttDirNode.NodeType = ProParserTokenTypes:NEXT
                or ttDirNode.NodeType = ProParserTokenTypes:CURRENT then
                next BLK_NODE.
                    
            for each ttWhereNode where ttWhereNode.ParentNum = ttRecordNode.NodeNum
                and ttWhereNode.NodeType = ProParserTokenTypes:WHERE,
                each ttEqNode where ttEqNode.ParentNum = ttWhereNode.NodeNum
                and ttEqNode.NodeType = ProParserTokenTypes:EQ,
                first ttRowIdNode where ttRowIdNode.ParentNum = ttEqnode.NodeNum
                and (ttRowIdNode.NodeType = ProParserTokenTypes:ROWID
                or ttRowIdNode.NodeType = ProParserTokenTypes:RECID):
                next BLK_NODE.
            end.
                        
            if TableType = "st-dbtable":u and IsUniqueClause(ttNode.NodeNum) then
                next BLK_NODE.
              
            PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, 
                          substitute("FIND <&1> statement defined without [FIRST|LAST|NEXT|PREV|CURRENT] qualifer":t, ttRecordNode.NodeText)).
                
            catch e as Progress.Lang.Error :
                undo, next BLK_NODE.
            end catch.
        end.
        
    end method.
end class.