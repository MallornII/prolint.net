 
 /*------------------------------------------------------------------------
    File        : AndOrParens
    Purpose     : Finds use 'or' and 'and' without parens
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 02.01.2019 13:31:01
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.AndOrParens inherits AbstractRule final serializable: 

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public AndOrParens (  ):
        super ().
        assign
            RuleDescription = "Finds use 'or' and 'and' without parens":t
            RuleId          = "AndOrParens":u
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
            
        define variable needParens as logical no-undo.
        
        define buffer ttChildNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:OR:
            needParens = false.
            if currentUnit:GetParentType(ttNode.NodeNum) = ProParserTokenTypes:AND then
                needParens = true.
            for first ttChildNode where ttChildNode.ParentNum = ttNode.ParentNum
                and ttChildNode.NodeType = ProParserTokenTypes:AND:
                needParens = true.
            end.
            for first ttChildNode where ttChildNode.ParentNum = ttNode.NodeNum
                and ttChildNode.NodeType = ProParserTokenTypes:AND:
                needParens = true.
            end. 
            if needParens then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, "mixed AND and OR - please use parentheses":t).
        end.

    end method.

end class.