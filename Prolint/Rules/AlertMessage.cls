 
 /*------------------------------------------------------------------------
    File        : AlertMessage
    Purpose     : Finds message without alert-box options
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 30.12.2018 18:50:38
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.AlertMessage inherits AbstractRule final serializable:

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public AlertMessage (  ):
        super ().
        
        assign
            RuleDescription = "Finds message without alert-box options":t
            RuleId          = "AlertMessage":u
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
            
        define buffer bttNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:MESSAGE:
            find first bttNode where bttNode.ParentNum = ttnode.NodeNum
                and bttNode.NodeType = ProParserTokenTypes:VIEWAS no-error.
            if not available(bttNode) then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, "'message' without an 'alert-box' option").
        end.

    end method.

end class.