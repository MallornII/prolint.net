 
 /*------------------------------------------------------------------------
    File        : EmptyBlock
    Purpose     : Finds empty blocks
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 26.01.2019 18:31:04 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.EmptyBlock inherits AbstractRule serializable final: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public EmptyBlock (  ):
        super ().
        
        assign
            RuleDescription = "Finds empty blocks":t
            RuleId          = "EmptyBlock":U
            Severity        = 4.
        
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
           
        define buffer ttChildNode for ttNode.
        define buffer ttParentNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
         
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:Code_block,
            first ttParentNode where ttParentNode.NodeNum = ttNode.ParentNum:
            if can-find(first ttChildNode where ttChildNode.ParentNum = ttNode.NodeNum) then
                next BLK_NODE.
            if can-find(first ttProUnit where ttProUnit.StartNode = ttNode.ParentNum
                and ttProUnit.IsAbstract) then
                next BLK_NODE.
            PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, 
                                  substitute("Empty &1 block":t, ttParentNode.NodeText)).
        end.
    end method.
end class.