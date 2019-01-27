 
 /*------------------------------------------------------------------------
    File        : EndType
    Purpose     : Finds <END> without qualifying statement
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 26.01.2019 19:11:23
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.EndType inherits AbstractRule final serializable:
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public EndType (  ):
        super ().
        
        assign
            RuleDescription = "Finds <END> without qualifying statement":t
            RuleId          = "EndType":U
            Severity        = 6.
        
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
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:END,
            first ttParentNode where ttParentNode.NodeNum = ttNode.ParentNum
            and (ttParentNode.NodeType = ProParserTokenTypes:PROCEDURE
            or ttParentNode.NodeType = ProParserTokenTypes:FUNCTION
            or ttParentNode.NodeType = ProParserTokenTypes:CASE
            or ttParentNode.NodeType = ProParserTokenTypes:METHOD
            or ttParentNode.NodeType = ProParserTokenTypes:CLASS
            or ttParentNode.NodeType = ProParserTokenTypes:CONSTRUCTOR
            or ttParentNode.NodeType = ProParserTokenTypes:DESTRUCTOR
            or ttParentNode.NodeType = ProParserTokenTypes:GET
            or ttParentNode.NodeType = ProParserTokenTypes:SET
            or ttParentNode.NodeType = ProParserTokenTypes:CATCH
            or ttParentNode.NodeType = ProParserTokenTypes:FINALLY):
            
            find first ttChildNode where ttChildNode.ParentNum = ttNode.NodeNum
                and ttChildNode.NodeType = ttParentNode.NodeType no-error.
            if not available(ttChildNode) then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, 
                                  substitute("Use <END &1> to terminate a <&2> block":t, ttParentNode.NodeText, ttParentNode.NodeText)).
            
        end. 
    end method.
end class.