 
 /*------------------------------------------------------------------------
    File        : AndOrParens
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Wed Jan 02 13:31:01 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.AndOrParens inherits AbstractRule final serializable: 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public AndOrParens (  ):
        super ().
        assign
            RuleDescription = "Finds use 'or' and 'and' without parens":t
            RuleId          = "AndOrParens":u
            Severity        = 7.
    end constructor.


    method override public void Visit
        (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
        ):
            
        define variable needParens as logical no-undo.
        
        define buffer ttChildNode for ttNode.
        
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