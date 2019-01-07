 
 /*------------------------------------------------------------------------
    File        : BlockLabel
    Purpose     : Finds use leave, next without corresponding labels
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 02.01.2019 13:48:51
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.BlockLabel inherits AbstractRule final serializable: 

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public BlockLabel (  ):
        super ().
        assign
            RuleDescription = "Finds use leave, next without corresponding labels":t
            RuleId          = "BlockLabel":u
            Severity        = 8.
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