 
/*------------------------------------------------------------------------
   File        : ProUnitsParser
   Purpose     : Parses classes, methods, procedures etc
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 22.12.2018 15:59:38
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

    define private property LintUnit as Prolint.ILintUnit no-undo 
        get.
        set. 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private integer GetParentUnit( input nodeNum as integer ):
        
        define variable nextNum as integer no-undo.
        
        define buffer ttNode    for ttNode.
        define buffer ttProUnit for ttProUnit.
        
        find first ttNode where ttNode.NodeNum = nodeNum no-error.
        if available(ttNode) then
        do:
            nextNum = ttNode.ParentNum.
            do while ttNode.NodeNum <> 0:                
                find first ttNode where ttNode.NodeNum = nextNum.
                find first ttProUnit where ttProUnit.StartNode = ttNode.NodeNum no-error.
                if available(ttProUnit) then
                    return ttProUnit.Id.
                nextNum = ttNode.ParentNum.                
            end.
        end.
        
        find first ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_ROOT:GetValue().        
        return ttProUnit.Id.
    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void ParseMain
        (
        input tokenType     as integer,
        input proUnitType   as UnitType
        ):
        
        define buffer ttChildNode for ttNode.
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = tokenType:
            create ttProUnit.
            assign
                ttProUnit.Id         = LintUnit:NextSequenceId()
                ttProUnit.UnitType   = proUnitType:GetValue()
                ttProUnit.StartNode  = ttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.AccessMode = ""
                ttProUnit.IsAbstract = true 
                when tokenType = ProParserTokenTypes:INTERFACE.
            for each ttChildNode where ttChildNode.ParentNum = ttNode.NodeNum:
                case ttChildNode.NodeType:
                    when ProParserTokenTypes:ABSTRACT then
                        ttProUnit.IsAbstract = true.
                    when ProParserTokenTypes:ID then
                        ttProUnit.UnitName = ttChildNode.NodeText. 
                end case.
            end.         
        end.        
        
        return.

    end method.

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
                ttProUnit.Id         = LintUnit:NextSequenceId()
                ttProUnit.ParentId   = GetParentUnit(ttNode.NodeNum)
                ttProUnit.UnitType   = proUnitType:GetValue()
                ttProUnit.StartNode  = bttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.AccessMode = "PUBLIC":u
                when tokenType = ProParserTokenTypes:PROPERTY
                ttProUnit.AccessMode = "PRIVATE":u
                when tokenType = ProParserTokenTypes:VARIABLE.                
                        
            BLK_NEXT:
            for each cttNode where cttNode.ParentNum = bttNode.NodeNum:    
                case cttNode.NodeType:
                    when ProParserTokenTypes:INPUT then
                        ttProUnit.Direction = "INPUT":u.
                    when ProParserTokenTypes:INPUTOUTPUT then
                        ttProUnit.Direction = "INPUT-OUTPUT":u.
                    when ProParserTokenTypes:OUTPUT then
                        ttProUnit.Direction = "OUTPUT":u.
                    when ProParserTokenTypes:ABSTRACT then
                        ttProUnit.IsAbstract = true.
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
                    when ProParserTokenTypes:RECORD_NAME then
                        ttProUnit.DataType = cttNode.NodeText.
                    when ProParserTokenTypes:AS then
                        do:
                            /* In variables definition DataType is child for 'AS'
                               and won't appear as child of 'DEFINE'
                               In properties however DataType is child for 'DEFINE'
                               and next-sibling for 'AS'. More interesting in variables 
                               DataType is also next-sibling for 'AS' 
                               TODO: Correct g4 grammar to make DataType child of 'DEFINE' everywhere */
                            find first dttNode where dttNode.NodeNum = cttNode.NextSibling no-error.
                            if available(dttNode) then
                                ttProUnit.DataType = dttNode.NodeText.
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

    method private void ParseParameterList(  ):
        
        define buffer ttNode          for ttNode.
        define buffer ttParameterNode for ttNode.
        define buffer ttChildNode     for ttNode.
        
        define variable nextNum    as integer no-undo.
        define variable isDataType as logical no-undo.        
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:PARAMETER_LIST,
            each ttParameterNode where ttParameterNode.ParentNum = ttNode.NodeNum and
            (ttParameterNode.NodeType = ProParserTokenTypes:INPUT
            or ttParameterNode.NodeType = ProParserTokenTypes:INPUTOUTPUT
            or ttParameterNode.NodeType = ProParserTokenTypes:OUTPUT
            or ttParameterNode.NodeType = ProParserTokenTypes:BUFFER):
            create ttProUnit.            
            assign
                ttProUnit.Id         = LintUnit:NextSequenceId()
                ttProUnit.ParentId   = GetParentUnit(ttNode.NodeNum)
                ttProUnit.UnitType   = Proparse.UnitType:U_PARAMETER:GetValue()
                ttProUnit.StartNode  = ttParameterNode.NodeNum
                ttProUnit.SourceFile = ttParameterNode.NodeFile
                ttProUnit.FirstLine  = ttParameterNode.NodeLine                
                ttProUnit.Direction  = "INPUT":u
                when ttParameterNode.NodeType = ProParserTokenTypes:INPUT
                ttProUnit.Direction  = "INPUT-OUTPUT":u
                when ttParameterNode.NodeType = ProParserTokenTypes:INPUTOUTPUT
                ttProUnit.Direction  = "OUTPUT":u
                when ttParameterNode.NodeType = ProParserTokenTypes:OUTPUT.
            for each ttChildNode where ttChildNode.ParentNum = ttParameterNode.NodeNum:
                /* If 'input' keyword is virtual it points to line 0 of compiled file */
                if ttProUnit.FirstLine = 0 then
                do:
                    assign
                        ttProUnit.StartNode  = ttChildNode.NodeNum
                        ttProUnit.SourceFile = ttChildNode.NodeFile
                        ttProUnit.FirstLine  = ttChildNode.NodeLine.
                end.
                case ttChildNode.NodeType:                    
                    when ProParserTokenTypes:AS then
                        isDataType = true.
                    when ProParserTokenTypes:ID then
                        ttProUnit.UnitName = ttChildNode.NodeText.
                    when ProParserTokenTypes:DATASET
                    or 
                    when ProParserTokenTypes:DATASETHANDLE
                    or 
                    when ProParserTokenTypes:TABLE
                    or 
                    when ProParserTokenTypes:TABLEHANDLE
                    or 
                    when ProParserTokenTypes:RECORD_NAME then
                        ttProUnit.DataType = ttChildNode.NodeText.
                    otherwise
                    do:
                        if isDataType then
                            ttProUnit.DataType = ttChildNode.NodeText.
                        assign
                            isDataType = false.
                    end.       
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
        
        define buffer ttNode   for ttNode.
        define buffer bttNode  for ttNode.
        define buffer ttIDNode for ttNode.
        
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
                ttProUnit.Id         = LintUnit:NextSequenceId()
                ttProUnit.ParentId   = GetParentUnit(ttNode.NodeNum)
                ttProUnit.UnitType   = Proparse.UnitType:U_TEMPTABLE:GetValue()
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
                        ttProUnit.IsAbstract = true.                    
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
                    when ProParserTokenTypes:BEFORETABLE then
                        do:
                            find first ttIDNode where ttIDNode.NodeNum = bttNode.FirstChild no-error.
                            if available(ttIDNode) then
                                ttProUnit.UnitName = ttIDNode.NodeText.
                        end.
                    when ProParserTokenTypes:FIELD then
                        leave BLK_NEXT.                                        
                end case.
            end.
        end.
        return.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Start method for visiting ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Visit
        (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse              
        ):  
        LintUnit = currentUnit.
        
        create ttProUnit.
        assign
            ttProUnit.Id         = LintUnit:NextSequenceId()
            ttProUnit.UnitType   = Proparse.UnitType:U_ROOT:GetValue()            
            ttProUnit.SourceFile = LintUnit:CompileUnit
            ttProUnit.UnitName   = LintUnit:CompileUnit.
              
        ParseMain(ProParserTokenTypes:CLASS, Proparse.UnitType:U_CLASS).
        ParseMain(ProParserTokenTypes:INTERFACE, Proparse.UnitType:U_INTERFACE).        
        ParseProcedures(ProParserTokenTypes:PROCEDURE, Proparse.UnitType:U_PROCEDURE, ?).        
        ParseProcedures(ProParserTokenTypes:FUNCTION, Proparse.UnitType:U_FUNCTION, ?).        
        ParseProcedures(ProParserTokenTypes:METHOD, Proparse.UnitType:U_METHOD, "Interface":U).        
        ParseProcedures(ProParserTokenTypes:CONSTRUCTOR, Proparse.UnitType:U_CONSTRUCTOR, ?).
        ParseProcedures(ProParserTokenTypes:DESTRUCTOR, Proparse.UnitType:U_DESTRUCTOR, ?).
        ParseDefines(ProParserTokenTypes:PROPERTY, Proparse.UnitType:U_PROPERTY).                
        ParseAccessors(ProParserTokenTypes:Property_getter, Proparse.UnitType:U_GETTER).                
        ParseAccessors(ProParserTokenTypes:Property_setter, Proparse.UnitType:U_SETTER).                
        ParseDefines(ProParserTokenTypes:VARIABLE, Proparse.UnitType:U_VARIABLE).        
        ParseDefines(ProParserTokenTypes:PARAMETER, Proparse.UnitType:U_PARAMETER).        
        ParseParameterList().        
        ParseTempTables().
        ParseDefines(ProParserTokenTypes:BUFFER, Proparse.UnitType:U_BUFFER).                
      
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
        
        define buffer ttNode    for ttNode.
        define buffer bttNode   for ttNode.        
        define buffer ttEndNode for ttNode.
        
        define variable nextNum   as integer   no-undo.
        define variable tempText  as character no-undo.
        define variable isReturns as logical   no-undo.
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = tokenType
            and ttNode.IsStateHead:
            find first bttNode where bttNode.ParentNum = ttNode.NodeNum
                and bttNode.NodeType = ProParserTokenTypes:ID no-error.
            if not available(bttNode) then
                next BLK_NODE.
            create ttProUnit.
            assign
                ttProUnit.Id         = LintUnit:NextSequenceId()
                ttProUnit.ParentId   = GetParentUnit(ttNode.NodeNum)
                ttProUnit.UnitType   = proUnitType:GetValue()
                ttProUnit.StartNode  = ttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.UnitName   = bttNode.NodeText
                ttProUnit.AccessMode = "PUBLIC".
                
            find first ttEndNode where ttEndNode.ParentNum = ttNode.nodeNum
                and ttEndNode.NodeType = ProParserTokenTypes:END no-error.
            if available(ttEndNode) then
                ttProunit.EndNode = ttEndNode.NodeNum.
                
            if abstractBlock <> ? and LOOKUP(abstractBlock, ttNode.CodeBlock) > 0 then            
                ttProUnit.IsAbstract = true.                                          
            
            BLK_NEXT:
            for each bttNode where bttNode.ParentNum = ttNode.NodeNum:                
                case bttNode.NodeType:
                    when ProParserTokenTypes:EXTERNAL
                    or 
                    when ProParserTokenTypes:FORWARDS
                    or 
                    when ProParserTokenTypes:IN_KW
                    or 
                    when ProParserTokenTypes:ABSTRACT then
                        ttProUnit.IsAbstract = true.
                    when ProParserTokenTypes:PUBLIC then
                        ttProUnit.AccessMode = "PUBLIC":U.
                    when ProParserTokenTypes:PROTECTED then
                        ttProUnit.AccessMode = "PROTECTED":U.
                    when ProParserTokenTypes:PRIVATE then
                        ttProUnit.AccessMode = "PRIVATE":U.
                    when ProParserTokenTypes:STATIC then
                        ttProUnit.IsStatic = true.
                    when ProParserTokenTypes:RETURN
                    or 
                    when ProParserTokenTypes:RETURNS then
                        isReturns = true.
                    when ProParserTokenTypes:ID then                    
                        if proUnitType = Proparse.UnitType:U_METHOD then
                            ttProUnit.DataType = tempText.
                    otherwise
                    do:
                        if isReturns then
                            ttProUnit.DataType = bttNode.NodeText.
                        assign
                            isReturns = false
                            tempText  = bttNode.NodeText.
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
         
        define buffer ttNode    for ttNode. /* setter or getter */
        define buffer bttNode   for ttNode. /* ID node with propety name */
        define buffer cttNode   for ttNode. /* define node */
        define buffer dttNode   for ttNode. /* Code_block node of accessor */
        define buffer ttEndNode for ttNode.
        
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
                ttProUnit.Id         = LintUnit:NextSequenceId()
                ttProUnit.ParentId   = GetParentUnit(ttNode.NodeNum)
                ttProUnit.UnitType   = proUnitType:GetValue()
                ttProUnit.StartNode  = ttNode.NodeNum
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.UnitName   = bttNode.NodeText.
                
            find first ttEndNode where ttEndNode.ParentNum = ttNode.nodeNum
                and ttEndNode.NodeType = ProParserTokenTypes:END no-error.
            if available(ttEndNode) then
                ttProunit.EndNode = ttEndNode.NodeNum.
                
            if lookup("Interface":U, ttNode.CodeBlock) > 0 then
            do:
                ttProUnit.IsAbstract = true.
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
                    ttProUnit.IsAbstract = true.
                    leave BLK_NEXT.
                end.
            end.
        end.
        return.

    end method.

end class.