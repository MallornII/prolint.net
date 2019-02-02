 
 /*------------------------------------------------------------------------
    File        : GroupAssign
    Purpose     : Find consecutive <ASSIGN> statements
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 02.02.2019 15:15:08
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.GroupAssign inherits AbstractRule final serializable: 
/*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public GroupAssign (  ):
        super ().
        
        assign
            RuleDescription = "Find consecutive <ASSIGN> statements":t
            RuleId          = "GroupAssign":U
            Severity        = 4.
        
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void InspectBlock( input nodeType as integer ):
        
        define variable currentNodeLine as integer no-undo.
        
        define buffer ttBlockNode for ttNode.
        define buffer ttAssignNode for ttNode.
        define buffer ttPrevNode for ttNode.
        define buffer ttEqualNode for ttNode.
        
        BLK_NODE:
        for each ttBlockNode where ttBlockNode.NodeType = nodeType,
            each ttAssignNode where ttAssignNode.NodeType = ProParserTokenTypes:ASSIGN
            and ttAssignNode.ParentNum = ttBlockNode.NodeNum:
            if ttAssignNode.NodeLine = 0 then
            do:
                find first ttEqualNode where ttEqualNode.NodeNum = ttAssignNode.FirstChild
                    and ttEqualNode.NodeType = ProParserTokenTypes:EQUAL no-error.
                if not available(ttEqualNode) then
                    next BLK_NODE.
                currentNodeLine = ttEqualNode.NodeLine.
            end.
            else
                currentNodeLine = ttAssignNode.NodeLine.
                 
            find first ttPrevNode where ttPrevNode.ParentNum = ttBlockNode.NodeNum
                and ttPrevNode.NodeNum = ttAssignNode.PrevSibling
                and ttPrevNode.NodeFile = ttAssignNode.NodeFile
                and ttPrevNode.NodeType = ProParserTokenTypes:ASSIGN no-error.
            if available(ttPrevNode) then
                PublishResult(LintUnit:CompileUnit, ttAssignNode.NodeFile, currentNodeLine,
                              substitute("Possibly group <ASSIGN> with line &1":t, ttPrevNode.NodeLine)).
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
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        InspectBlock(ProParserTokenTypes:Program_root).
        InspectBlock(ProParserTokenTypes:Code_block).

    end method.
end class.