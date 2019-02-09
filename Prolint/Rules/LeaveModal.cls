 
 /*------------------------------------------------------------------------
    File        : LeaveModal
    Purpose     : Finds <RETURN NO-APPLY> and <MESSAGE> inside <ON LEAVE> statement
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 09.02.2019 15:18:25
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.LeaveModal inherits AbstractRule final serializable: 
/*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public LeaveModal (  ):
        super ().
        
        assign
            RuleDescription = "Finds <RETURN NO-APPLY> and <MESSAGE> inside <ON LEAVE> statement":t
            RuleId          = "LeaveModal":U
            Severity        = 4.
        
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void InspectNode
    (
        input nodeNum as integer,
        input findType as integer,
        input findChildType as integer        
    ):                
        define variable typeString as character no-undo.
        define buffer ttInspectNode for ttNode.
        define buffer ttChildNode for ttNode.
        
        BLK_NODE:
        for each ttInspectNode where ttInspectNode.ParentNum = nodeNum:
            InspectNode(ttInspectNode.NodeNum, findType, findChildType).
            if ttInspectNode.NodeType = findType then
            do:
                typeString = ttInspectNode.NodeText.
                if findChildType <> ? then
                do:
                    find first ttChildNode where ttChildNode.NodeNum = ttInspectNode.FirstChild
                        and ttChildNode.NodeType = findChildType no-error.
                    if not available(ttChildNode)then
                        next BLK_NODE.
                    typeString = typeString + " " + ttChildNode.NodeText.
                end.
                PublishResult(LintUnit:CompileUnit, ttInspectNode.NodeFile, ttInspectNode.NodeLine, 
                    substitute("Modal <LEAVE> Trigger -- has <&1> statement":t, typeString)).
            end.  
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
           
        define buffer ttEventNode for ttNode.
        define buffer ttLeaveNode for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:ON,
            first ttEventNode where ttEventNode.ParentNum = ttNode.NodeNum
            and ttEventNode.NodeType = ProParserTokenTypes:Event_list,
            each ttLeaveNode where ttLeaveNode.ParentNum = ttEventNode.NodeNum
            and (ttLeaveNode.NodeText = "LEAVE":u or ttLeaveNode.NodeText = quoter("LEAVE":u)):              
            InspectNode(ttNode.NodeNum, ProParserTokenTypes:MESSAGE, ?).            
            InspectNode(ttNode.NodeNum, ProParserTokenTypes:RETURN, ProParserTokenTypes:NOAPPLY).
        end.
    end method.
end class.