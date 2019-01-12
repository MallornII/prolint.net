 
/*------------------------------------------------------------------------
   File        : AbbrevTable
   Purpose     : Finds abbreviated table names
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 29.12.2018 22:53:41
   Notes       : 
 ----------------------------------------------------------------------*/
using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.AbbrevTable inherits AbstractRule serializable final:
    
    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public AbbrevTable (  ):
        super ().
        assign
            RuleDescription = "Finds abbreviated table names":T
            RuleId          = "AbbrevTable":U
            Severity        = 7.
    end constructor.

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
        
        define variable tableName    as character no-undo.
        define variable databaseName as character no-undo.
        define variable fullName     as character no-undo.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:RECORD_NAME
            and ttNode.StoreType = "st-dbtable":u:
            if num-entries(ttNode.NodeText, ".":u) = 2 then
                assign
                    databaseName = entry(1, ttNode.NodeText, ".":u)
                    tableName    = entry(2, ttNode.NodeText, ".":u).
            else
                assign
                    databaseName = ?
                    tableName    = ttNode.NodeText.
                
            fullName = Proparse.Wrapper:DbSchema:ResolveTableName(databaseName, tableName).
            if tableName <> fullName then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, substitute("Abbreviated &1 for &2":T, tableName, fullName)).
        
        end.

    end method.

end class.