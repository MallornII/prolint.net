 
 /*------------------------------------------------------------------------
    File        : BlockLabel
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Wed Jan 02 13:48:51 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.BlockLabel inherits AbstractRule final serializable: 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public BlockLabel (  ):
        super ().
        assign
            RuleDescription = "Finds use leave, next without corresponding labels":t
            RuleId          = "BlockLabel":u
            Severity        = 8.
    end constructor.


    method override public void Visit
        (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
        ):
        
        define buffer ttChildNode for ttNode.
        
        for each ttNode where 
            (ttNode.NodeType = ProParserTokenTypes:LEAVE
            and ttNode.IsStateHead) or
            (ttNode.NodeType = ProParserTokenTypes:NEXT
            and ttNode.IsStateHead):
            find first ttChildNode where ttChildNode.NodeNum = ttNode.FirstChild
                and ttChildNode.NodeType = ProParserTokenTypes:BLOCK_LABEL no-error.
            if not available(ttChildNode) then
                PublishResult(currentUnit:CompileUnit, 
                              ttNode.NodeFile,
                              ttNode.NodeLine,
                              "next/leave should specify a blocklabel":t).         
        end.

    end method.

end class.