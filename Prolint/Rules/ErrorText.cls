 
 /*------------------------------------------------------------------------
    File        : ErrorText
    Purpose     : Finds <RETURN ERROR> without argument
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 26.01.2019 20:42:52
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.ErrorText inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public ErrorText (  ):
        super ().
        
        assign
            RuleDescription = "Finds <RETURN ERROR> without argument":t
            RuleId          = "ErrorText":U
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
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:ERROR,
            first ttParentNode where ttParentNode.NodeNum = ttNode.ParentNum
            and ttParentNode.NodeType = ProParserTokenTypes:RETURN:              
            if not can-find(first ttChildNode where ttChildNode.ParentNum = ttParentNode.NodeNum
                and ttChildNode.NodeNum > ttNode.NodeNum
                and ttChildNode.NodeType <> ProParserTokenTypes:PERIOD) then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, "<RETURN ERROR> should have a string argument":t).            
        end.
    end method.
end class.