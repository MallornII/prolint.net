 
 /*------------------------------------------------------------------------
    File        : NestedFunc
    Purpose     : Finds functions nested inside code blocks
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 09.02.2019 15:58:17
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.NestedFunc inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public NestedFunc (  ):
        super ().
        
        assign
            RuleDescription = "Finds functions nested inside code blocks":t
            RuleId          = "NestedFunc":U
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
        
        define buffer ttParentNode for ttNode.        
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        BLK_UNIT:
        for each ttProUnit where ttProUnit.UnitType = proparse.UnitType:U_PROCEDURE:GetValue()
            or ttProUnit.UnitType = proparse.UnitType:U_FUNCTION:GetValue(),
            first ttNode where ttNode.NodeNum = ttProUnit.StartNode,
            first ttParentNode where ttParentNode.NodeNum = ttNode.ParentNum
            and ttParentNode.NodeType = ProParserTokenTypes:Code_block:            
            PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine,
                substitute("<&1 &2> is defined inside a code block":t, ttNode.NodeText, ttProUnit.UnitName)).            
        end.
    end method.
end class.