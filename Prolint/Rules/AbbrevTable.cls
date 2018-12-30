 
/*------------------------------------------------------------------------
   File        : AbbrevTable
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Sat Dec 29 22:53:41 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/
using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.AbbrevTable inherits AbstractRule serializable final: 
        
    constructor public AbbrevTable (  ):
        super ().
        assign
            RuleDescription = "Finds abbreviated table names":T
            RuleId          = "AbbrevTable":U
            Severity        = 7.
    end constructor.


    method override public void Visit
        (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
        ):
        
        define variable tableName    as character no-undo.
        define variable databaseName as character no-undo.
        define variable fullName     as character no-undo.
        
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