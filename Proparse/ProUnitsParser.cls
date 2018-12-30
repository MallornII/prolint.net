 
 /*------------------------------------------------------------------------
    File        : ProUnitsParser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sat Dec 22 15:59:38 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/
using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Proparse.IParser.

block-level on error undo, throw.

class Proparse.ProUnitsParser implements IParser final:
    
    &SCOPED-DEFINE ACCESS_MOD private
    &SCOPED-DEFINE REF_MOD    reference-only
    {proparse/parsedata.i} 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void ParseDefines
    (
        input tokenType     as integer,
        input proUnitType   as UnitType
    ):
        define buffer ttNode  for ttNode.
        define buffer bttNode for ttNode.
        define buffer cttNode for ttNode.
        define buffer dttNode for ttNode.       
        
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = tokenType
            and ttNode.IsStateHead = false,            
            first bttNode where bttNode.NodeNum = ttNode.ParentNum
            and bttNode.NodeType = ProParserTokenTypes:DEFINE:
                
            create ttProUnit.
            assign
                ttProUnit.UnitType   = proUnitType:GetValue()
                ttProUnit.StartNode  = bttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.AccessMode = "PUBLIC".                
                        
            BLK_NEXT:
            for each cttNode where cttNode.ParentNum = bttNode.NodeNum:    
                case cttNode.NodeType:
                    when ProParserTokenTypes:ABSTRACT then
                        ttProUnit.IsForward = true.
                    when ProParserTokenTypes:PUBLIC then
                        ttProUnit.AccessMode = "PUBLIC":U.
                    when ProParserTokenTypes:PROTECTED then
                        ttProUnit.AccessMode = "PROTECTED":U.
                    when ProParserTokenTypes:PRIVATE then
                        ttProUnit.AccessMode = "PRIVATE":U.
                    when ProParserTokenTypes:STATIC then
                        ttProUnit.IsStatic = true.
                    when ProParserTokenTypes:NOUNDO then
                        ttProUnit.IsNoUndo = true.
                    when ProParserTokenTypes:AS then
                    do:
                        /* In variables definition DataType is child for 'AS'
                           and won't appear as child of 'DEFINE'
                           In properties however DataType is child for 'DEFINE'
                           and next-sibling for 'AS'. Mre interesting in variables 
                           DataType is also next-sibling for 'AS' 
                           TODO: Correct g4 grammar to make DataType child of 'DEFINE' everywhere */
                        find first dttNode where dttNode.NodeNum = cttNode.NextSibling no-error.
                        if available(dttNode) then
                            ttProUnit.ReturnType = dttNode.NodeText.
                    end.
                    when ProParserTokenTypes:ID then
                        ttProUnit.UnitName = cttNode.NodeText.                                            
                end case.
            end.
        end.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void ParseTempTables(  ):
        
        define buffer tNode   for ttNode.
        define buffer bttNode for ttNode.
        
        define variable nextNum as integer no-undo.        
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:TEMPTABLE
            and ttNode.IsStateHead = false.            
            find first bttNode where bttNode.NodeNum = ttNode.ParentNum
            and bttNode.NodeType = ProParserTokenTypes:DEFINE no-error.
            if not available(bttNode) then
                next.
                
            create ttProUnit.
            assign
                ttProUnit.UnitType   = proparse.UnitType:U_TEMPTABLE:GetValue()
                ttProUnit.StartNode  = bttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.AccessMode = "PRIVATE".                
                        
            BLK_NEXT:
            do while bttNode.NextSibling <> 0:
                nextNum = bttNode.NextSibling.
                find first bttNode where bttNode.NodeNum = nextNum.
                case bttNode.NodeType:
                    when ProParserTokenTypes:ABSTRACT then
                        ttProUnit.IsForward = true.                    
                    when ProParserTokenTypes:PROTECTED then
                        ttProUnit.AccessMode = "PROTECTED":U.
                    when ProParserTokenTypes:PRIVATE then
                        ttProUnit.AccessMode = "PRIVATE":U.
                    when ProParserTokenTypes:STATIC then
                        ttProUnit.IsStatic = true.      
                    when ProParserTokenTypes:NOUNDO then
                        ttProUnit.IsNoUndo = true.              
                    when ProParserTokenTypes:ID then
                        ttProUnit.UnitName = bttNode.NodeText.
                    when ProParserTokenTypes:FIELD then
                        leave BLK_NEXT.                                        
                end case.
            end.
        end.
        return.

    end method.

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsProparse              
    ):  
        ParseProcedures(ProParserTokenTypes:PROCEDURE, proparse.UnitType:U_PROCEDURE, ?).
        ParseProcedures(ProParserTokenTypes:FUNCTION, proparse.UnitType:U_FUNCTION, ?).
        ParseProcedures(ProParserTokenTypes:METHOD, proparse.UnitType:U_METHOD, "Interface":U).        
        ParseAccessors(ProParserTokenTypes:Property_getter, proparse.UnitType:U_GETTER).        
        ParseAccessors(ProParserTokenTypes:Property_setter, proparse.UnitType:U_SETTER).
        ParseDefines(ProParserTokenTypes:PROPERTY, proparse.UnitType:U_PROPERTY).
        ParseDefines(ProParserTokenTypes:VARIABLE, proparse.UnitType:U_VARIABLE).
        ParseTempTables().        
      
        return.

    end method.
    
        /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void ParseProcedures
        (
        input tokenType     as integer,
        input proUnitType   as UnitType,
        input abstractBlock as character
        ):
        
        define buffer tNode   for ttNode.
        define buffer bttNode for ttNode.
        
        define variable nextNum as integer no-undo.
        define variable tempText as character no-undo.
        define variable isReturns as logical no-undo.
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = tokenType
            and ttNode.IsStateHead:
            find first bttNode where bttNode.ParentNum = ttNode.NodeNum
                and bttNode.NodeType = ProParserTokenTypes:ID no-error.
            if not available(bttNode) then
                next BLK_NODE.
            create ttProUnit.
            assign
                ttProUnit.UnitType   = proUnitType:GetValue()
                ttProUnit.StartNode  = ttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.UnitName   = bttNode.NodeText
                ttProUnit.AccessMode = "PUBLIC".
                
            if abstractBlock <> ? and LOOKUP(abstractBlock, ttNode.CodeBlock) > 0 then
            do:
                ttProUnit.IsForward = true.
                next BLK_NODE.
            end.
            
            BLK_NEXT:
            do while bttNode.NextSibling <> 0:
                nextNum = bttNode.NextSibling.
                find first bttNode where bttNode.NodeNum = nextNum.
                case bttNode.NodeType:
                    when ProParserTokenTypes:EXTERNAL
                        or when ProParserTokenTypes:FORWARDS
                        or when ProParserTokenTypes:IN_KW
                        or when ProParserTokenTypes:ABSTRACT then
                        ttProUnit.IsForward = true.
                    when ProParserTokenTypes:PUBLIC then
                        ttProUnit.AccessMode = "PUBLIC":U.
                    when ProParserTokenTypes:PROTECTED then
                        ttProUnit.AccessMode = "PROTECTED":U.
                    when ProParserTokenTypes:PRIVATE then
                        ttProUnit.AccessMode = "PRIVATE":U.
                    when ProParserTokenTypes:STATIC then
                        ttProUnit.IsStatic = true.
                    when ProParserTokenTypes:RETURN
                        or when ProParserTokenTypes:RETURNS then
                        isReturns = true.
                    when ProParserTokenTypes:ID then                    
                        if proUnitType = proparse.UnitType:U_METHOD then
                            ttProUnit.ReturnType = tempText.
                    otherwise
                    do:
                        if isReturns then
                            ttProUnit.ReturnType = bttNode.NodeText.
                        assign
                            isReturns = false
                            tempText = bttNode.NodeText.
                    end.                        
                end case.
            end.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: 
     Notes:
    ------------------------------------------------------------------------------*/

    method private void ParseAccessors
        (
        input tokenType   as integer,
        input proUnitType as UnitType
        ):       
         
        define buffer ttNode  for ttNode. /* setter or getter */
        define buffer bttNode for ttNode. /* ID node with propety name */
        define buffer cttNode for ttNode. /* define node */
        define buffer dttNode for ttNode. /* Code_block node of accessor */
        
        define variable nextNum as integer no-undo.
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = tokenType,
            first cttNode where cttNode.NodeNum = ttNode.ParentNum,
            first dttNode where dttNode.ParentNum = ttNode.NodeNum
            and dttNode.NodeType = ProParserTokenTypes:Code_block.            
            find first bttNode where bttNode.ParentNum = cttNode.NodeNum
                and bttNode.NodeType = ProParserTokenTypes:ID no-error.
            if not available(bttNode) then
                next BLK_NODE.
            create ttProUnit.
            assign
                ttProUnit.UnitType   = proUnitType:GetValue()
                ttProUnit.StartNode  = ttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.UnitName   = bttNode.NodeText.
                
            if lookup("Interface":U, ttNode.CodeBlock) > 0 then
            do:
                ttProUnit.IsForward = true.
                next BLK_NODE.
            end.
            
            BLK_NEXT:
            do while bttNode.NextSibling <> 0:
                nextNum = bttNode.NextSibling.
                find first bttNode where bttNode.NodeNum = nextNum.
                if bttNode.NodeType = ProParserTokenTypes:EXTERNAL
                    or bttNode.NodeType = ProParserTokenTypes:FORWARDS
                    or bttNode.NodeType = ProParserTokenTypes:IN_KW
                    or bttNode.NodeType = ProParserTokenTypes:ABSTRACT then
                do:
                    ttProUnit.IsForward = true.
                    leave BLK_NEXT.
                end.
            end.
        end.
        return.

    end method.

end class.