 
 /*------------------------------------------------------------------------
    File        : AlertMessage
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Dec 30 18:50:38 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.AlertMessage inherits AbstractRule final serializable: 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public AlertMessage (  ):
        super ().
        
        assign
            RuleDescription = "Finds message without alert-box options":T
            RuleId          = "AlertMessage":U
            Severity        = 5.
        
    end constructor.


    method override public void Visit
    (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
    ):
            
        define buffer bttNode for ttNode.
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:MESSAGE:
            find first bttNode where bttNode.ParentNum = ttnode.NodeNum
                and bttNode.NodeType = ProParserTokenTypes:VIEWAS no-error.
            if not available(bttNode) then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, "'message' without an 'alert-box' option").
        end.

    end method.

end class.