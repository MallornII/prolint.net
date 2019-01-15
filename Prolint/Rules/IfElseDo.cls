 
 /*------------------------------------------------------------------------
    File        : IfElseDo
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Mon Jan 14 21:58:47 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.IfElseDo inherits AbstractRule serializable final: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public IfElseDo (  ):
        super ().
        
        assign
            RuleDescription = "Finds if...do else...do block with 1 line inside":t
            RuleId          = "IfElseDo":U
            Severity        = 3.
        
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
            
        define variable childCount as integer no-undo.
        
        define buffer ttDoNode for ttNode.
        define buffer ttLexColonNode for ttNode.
        define buffer ttCodeBlockNode for ttNode.
        define buffer ttChildNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:THEN
            or ttNode.NodeType = ProParserTokenTypes:ELSE,
            first ttDoNode where ttDoNode.NodeNum = ttNode.FirstChild
            and ttDoNode.NodeType  = ProParserTokenTypes:DO,
            first ttLexColonNode where ttLexColonNode.NodeNum = ttDoNode.FirstChild
            and ttLexColonNode.NodeType = ProParserTokenTypes:LEXCOLON,
            first ttCodeBlockNode where ttCodeBlockNode.NodeNum = ttLexColonNode.NextSibling
            and ttCodeBlockNode.NodeType = ProParserTokenTypes:Code_block:
                
            childCount = 0.
            
            for each ttChildNode where ttChildNode.ParentNum = ttCodeBlockNode.NodeNum
                and ttChildNode.IsStateHead:
                childCount = childCount + 1.
            end.
            if childCount < 2 then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, "<DO:> block contains less than two statements":t).
                              
        end.

    end method.
end class.