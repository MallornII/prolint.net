 
/*------------------------------------------------------------------------
   File        : OfLink
   Purpose     : Finds <OF> in <FIND>, <FOR>, <OPEN QUERY> and <CAN-FIND> statements
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 16.02.2019 18:24:25
   Notes       : 
 ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.OfLink inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public OfLink (  ):
        super ().
        
        assign
            RuleDescription = "Finds <OF> in <FIND>, <FOR>, <OPEN QUERY> and <CAN-FIND> statements":t
            RuleId          = "OfLink":U
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
        define variable headNum   as integer no-undo.
        define variable parentNum as integer no-undo.
        
        define buffer ttHeadNode   for ttNode.
        define buffer ttParentNode for ttNode.
        define buffer ttChildNode  for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:OF:
            headNum = currentUnit:GetStateHead(ttNode.NodeNum).
            find first ttHeadNode where ttHeadNode.NodeNum = headNum.
            case ttHeadNode.NodeType:
                when ProParserTokenTypes:FOR
                or 
                when ProParserTokenTypes:FIND then
                    PublishResult(currentUnit:CompileUnit, ttHeadNode.NodeFile, ttHeadNode.NodeLine, "<OF> used instead of <WHERE>":t).
                when ProParserTokenTypes:OPEN then
                    do:
                        if can-find(first ttChildNode where ttChildNode.NodeNum = ttHeadNode.FirstChild
                            and ttChildNode.NodeType = ProParserTokenTypes:QUERY) then
                            PublishResult(currentUnit:CompileUnit, ttHeadNode.NodeFile, ttHeadNode.NodeLine, "<OF> used instead of <WHERE>":t).
                    end.
                otherwise
                do:
                    find first ttParentNode where ttParentNode.NodeNum = ttNode.ParentNum no-error.
                    do while available(ttParentNode) 
                        and ttParentNode.NodeType <> ProParserTokenTypes:CANFIND
                        and ttParentNode.IsStateHead = false:
                        parentNum = ttParentNode.ParentNum.
                        find first ttParentNode where ttParentNode.NodeNum = parentNum no-error.
                    end.
                    if available(ttParentNode) and ttParentNode.NodeType = ProParserTokenTypes:CANFIND then
                        PublishResult(currentUnit:CompileUnit, ttHeadNode.NodeFile, ttHeadNode.NodeLine, "<OF> used instead of <WHERE>":t).
                end.
            end case.            
        end.
        
    end method.
end class.