 
 /*------------------------------------------------------------------------
    File        : NoError
    Purpose     : Finds <FIND> statements without <NO-ERROR>
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 10.02.2019 15:53:06
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.NoError inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public NoError (  ):
        super ().
        
        assign
            RuleDescription = "Finds <FIND> statements without <NO-ERROR>":t
            RuleId          = "NoError":U
            Severity        = 7.
        
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
        
        define buffer ttRecordNode for ttNode.        
        define buffer ttNoErrorNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:FIND,
            first ttRecordNode where ttRecordNode.ParentNum = ttNode.NodeNum
            and ttRecordNode.NodeType = ProParserTokenTypes:RECORD_NAME:
            if not can-find(first ttNoErrorNode where ttNoErrorNode.ParentNum = ttRecordNode.NodeNum
                and ttNoErrorNode.NodeType = ProParserTokenTypes:NOERROR_KW) then                 
            PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine,
                substitute("<FIND &1> statement defined without <NO-ERROR>":t, ttRecordNode.NodeText)).            
        end.
    end method.
end class.