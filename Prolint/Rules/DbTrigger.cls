 
/*------------------------------------------------------------------------
   File        : DbTrigger
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Mon Jan 14 21:34:41 ALMT 2019
   Notes       : 
 ----------------------------------------------------------------------*/

using Prolint.Rules.AbstractRule.
using com.joanju.proparse.ProParserTokenTypes.

block-level on error undo, throw.

class Prolint.Rules.DbTrigger inherits AbstractRule serializable final: 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public DbTrigger (  ):
        super ().
        
        assign
            RuleDescription = "Finds disable triggers statements":t
            RuleId          = "DbTrigger":U
            Severity        = 3.
        
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
            
        define variable nextNode     as integer   no-undo.
        define variable triggerType  as character no-undo.
        define variable triggerTable as character no-undo.
        
        define buffer ttChildNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:DISABLE:
            find first ttChildNode where ttChildNode.NodeNum = ttNode.FirstChild
                and ttChildNode.NodeType = ProParserTokenTypes:TRIGGERS no-error.
            if not available(ttChildNode) then
                next BLK_NODE.
                
            assign
                triggerType  = ""
                triggerTable = "".
            
            do while ttChildNode.NextSibling <> 0:
                nextNode = ttChildNode.NextSibling.
                find first ttChildNode where ttChildNode.NodeNum = nextNode.
                case ttChildNode.NodeType:
                    when ProParserTokenTypes:LOAD
                    or 
                    when ProParserTokenTypes:DUMP then
                        triggerType = ttChildNode.NodeText.
                    when ProParserTokenTypes:RECORD_NAME then
                        triggerTable = ttChildNode.NodeText.                    
                end case.
            end.
            PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, 
                          substitute("&1 TRIGGERS disabled on table &2":t, triggerType, triggerTable)).
        end.

    end method.
end class.