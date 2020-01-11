 
 /*------------------------------------------------------------------------
    File        : IdIsKeyword
    Purpose     : Finds variables,properties e.t.c. name as keywords
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 0.02.2019 17:56:29
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Utils.Strings.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.IdIsKeyword inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public IdIsKeyword (  ):
        super ().
        
        assign
            RuleDescription = "Finds variables,properties e.t.c. name as keywords":t
            RuleId          = "IdIsKeyword":U
            Severity        = 6.
        
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void InspectNode( input parentNum as integer ):
        
        define buffer ttIDNode for ttNode.
        define buffer ttBeforeNode for ttNode.
        
        BLK_NODE:
        for each ttIDNode where ttIDNode.ParentNum = parentNum:
            InspectNode(ttIDNode.NodeNum).
            if ttIDNode.NodeType = ProParserTokenTypes:ID and not Strings:IsEmptyOrNull(keyword-all(ttIDNode.NodeText)) then
            do:
                if ttIDNode.PrevSibling <> 0 then
                    find first ttBeforeNode where ttBeforeNode.NodeNum = ttIDNode.PrevSibling no-error.
                else
                    find first ttBeforeNode where ttBeforeNode.NodeNum = ttIDNode.ParentNum no-error.
                if ttBeforeNode.NodeType = ProParserTokenTypes:ID
                    or ttBeforeNode.NodeType = ProParserTokenTypes:IS
                    or ttBeforeNode.NodeType = ProParserTokenTypes:PRIMARY
                    or ttBeforeNode.NodeType = ProParserTokenTypes:UNIQUE
                    or ttBeforeNode.NodeType = ProParserTokenTypes:ASCENDING
                    or ttBeforeNode.NodeType = ProParserTokenTypes:DESCENDING then
                    next BLK_NODE.
                PublishResult(LintUnit:CompileUnit, ttIDNode.NodeFile, ttIDNode.NodeLine,
                          substitute("name of &1 <&2> is a keyword":t, ttBeforeNode.NodeText, ttIDNode.NodeText)).    
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
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).        
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:DEFINE:
            InspectNode(ttNode.NodeNum).
        end.

    end method.
end class.