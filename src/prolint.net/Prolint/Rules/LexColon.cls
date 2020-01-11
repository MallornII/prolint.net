 
 /*------------------------------------------------------------------------
    File        : LexColon
    Purpose     : Finds block headers terminated by a <PERIOD>
    Syntax      : 
    Description : 
    Author(s)   : Andrew No
    Created     : 09.02.2019 15:39:22
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.LexColon inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public LexColon (  ):
        super ().
        
        assign
            RuleDescription = "Finds block headers terminated by a <PERIOD>":t
            RuleId          = "LexColon":U
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
        
        define buffer ttPrevNode for ttNode.
        define buffer ttParentNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:Code_block,
            first ttPrevNode where ttPrevNode.NodeNum = ttNode.PrevSibling
            and ttPrevNode.NodeType <> ProParserTokenTypes:LEXCOLON,
            first ttParentNode where ttParentNode.NodeNum = ttNode.ParentNum:
            PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine,
                substitute("<&1> block header should terminate with a <COLON>":t, ttParentNode.NodeText)).            
        end.
    end method.
end class.