 
 /*------------------------------------------------------------------------
    File        : BackSlash
    Purpose     : Finds use of backslah in strings
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 02.01.2019 13:39:03
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.BackSlash inherits AbstractRule final serializable: 

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public BackSlash (  ):
        super ().
        assign
            RuleDescription = "Finds use of backslah in strings":t
            RuleId          = "BackSlash":u
            Severity        = 5.
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
            
        define variable tempString as character no-undo.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:QSTRING:
            tempString = replace(ttNode.NodeText, "~~~\":u, "").
            tempString = replace(tempString, "~\~\":u, "").
            if index(tempString, "~\") > 0 then
                PublishResult(currentUnit:CompileUnit, 
                              ttNode.NodeFile,
                              ttNode.NodeLine,
                              substitute("backslash in string <&1> is not unix-compatible":t, ttNode.NodeText)).
        end.
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:FILENAME:
            tempString = replace(ttNode.NodeText, "~~~\":u, "").            
            if index(tempString, "~\") > 0 then
                PublishResult(currentUnit:CompileUnit, 
                              ttNode.NodeFile,
                              ttNode.NodeLine,
                              substitute("backslash in filename <&1> is not unix-compatible":t, ttNode.NodeText)).
        end.

    end method.

end class.