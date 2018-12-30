 
 /*------------------------------------------------------------------------
    File        : ViewAsType
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Dec 30 19:23:45 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.AlertType inherits AbstractRule final serializable: 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public AlertType (  ):
        super ().
        
        assign
            RuleDescription = "Finds alert-boxes without AlertType option":T
            RuleId          = "AlertType":U
            Severity        = 2.
        
    end constructor.


    method override public void Visit
    (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
    ):  
        define variable hasAlertType as logical no-undo.          
        define buffer ttChildNode for ttNode.
        
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:VIEWAS:
            hasAlertType = false.
            for each ttChildNode where ttChildNode.Parent = ttnode.NodeNum:
                if ttChildNode.NodeType = ProParserTokenTypes:MESSAGE
                or ttChildNode.NodeType = ProParserTokenTypes:QUESTION
                or ttChildNode.NodeType = ProParserTokenTypes:INFORMATION
                or ttChildNode.NodeType = ProParserTokenTypes:ERROR
                or ttChildNode.NodeType = ProParserTokenTypes:WARNING then
                    hasAlertType = true.                
            end.
            if not hasAlertType then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, "'alert-box' without 'alert-type' option").
        end.        
    

    end method.

end class.