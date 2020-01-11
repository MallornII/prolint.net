 
 /*------------------------------------------------------------------------
    File        : DotComment
    Purpose     : Finds dot comments (<PERIOD> symbol before statement)
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 14.01.2019 22:14:45
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.DotComment inherits AbstractRule serializable final: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public DotComment (  ):
        super ().
        
        assign
            RuleDescription = "Finds dot comments (<PERIOD> symbol before statement)":t
            RuleId          = "DotComment":U
            Severity        = 9.
        
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
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:DOT_COMMENT:
            PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, "<PERIOD> comments a statement":t).                              
        end.

    end method.
end class.