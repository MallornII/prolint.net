 
/*------------------------------------------------------------------------
   File        : NoWait
   Purpose     : Finds <FIND> and <GET> with <EXCLUSIVE-LOCK> but without <NO-WAIT>
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 16.02.2019 18:03:41
   Notes       : 
 ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.NoWait inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public NoWait (  ):
        super ().
        
        assign
            RuleDescription = "Finds <FIND> and <GET> with <EXCLUSIVE-LOCK> but without <NO-WAIT>":t
            RuleId          = "NoWait":U
            Severity        = 9.
        
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void FindExclusive
        (
        input parentType as integer,
        input childType as integer
        ):
        define variable parentNum   as integer no-undo.
        define variable isExclusive as logical no-undo.
        define variable hasNoWait   as logical no-undo.
        
        define buffer ttParentNode for ttNode.
        define buffer ttChildNode  for ttNode.
        define buffer ttTargetNode for ttNode.
        
        BLK_NODE:
        for each ttParentNode where ttParentNode.NodeType = parentType,
            first ttChildNode where ttChildNode.ParentNum = ttParentNode.NodeNum
            and ttChildNode.NodeType = childType:
            assign            
                parentNum   = (if parentType = ProParserTokenTypes:FIND then ttChildNode.NodeNum else ttParentNode.NodeNum)
                isExclusive = false
                hasNoWait   = false.
            for each ttTargetNode where ttTargetNode.ParentNum = parentNum:
                if ttTargetNode.NodeType = ProParserTokenTypes:EXCLUSIVELOCK then
                    isExclusive = true.
                if ttTargetNode.NodeType = ProParserTokenTypes:NOWAIT then
                    hasNoWait = true.
            end.
            if isExclusive and not hasNoWait then
                PublishResult(LintUnit:CompileUnit, ttParentNode.NodeFile, ttParentNode.NodeLine, 
                    substitute("<&1> &2 exclusive statement defined without no-wait":t, ttParentNode.NodeText, ttChildNode.NodeText)).
        end.
        return.

    end method.

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
            
        define variable lineValue  as character no-undo.
        define variable lineNumber as integer   no-undo.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        FindExclusive(ProParserTokenTypes:FIND, ProParserTokenTypes:RECORD_NAME).
        FindExclusive(ProParserTokenTypes:GET, ProParserTokenTypes:ID).        
        
    end method.
end class.