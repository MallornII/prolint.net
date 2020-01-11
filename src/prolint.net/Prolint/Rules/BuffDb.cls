 
/*------------------------------------------------------------------------
   File        : BuffDb
   Purpose     : Finds use of default buffers inside procedure, functions etc
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 02.01.2019 14:58:08
   Notes       : 
 ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.BuffDb inherits AbstractRule final serializable: 
    
    define private temp-table ttInspectUnit no-undo
        field UnitType as integer.

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public BuffDb (  ):
        super ().
        assign
            RuleDescription = "Finds use of default buffers inside procedure, functions etc":t
            RuleId          = "BuffDb":u
            Severity        = 6.
            
        AddInspectUnit(Proparse.UnitType:U_PROCEDURE).
        AddInspectUnit(Proparse.UnitType:U_FUNCTION).
        AddInspectUnit(Proparse.UnitType:U_METHOD).
        AddInspectUnit(Proparse.UnitType:U_CONSTRUCTOR).
        AddInspectUnit(Proparse.UnitType:U_DESTRUCTOR).
        AddInspectUnit(Proparse.UnitType:U_GETTER).
        AddInspectUnit(Proparse.UnitType:U_SETTER).
    end constructor.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void AddInspectUnit( input unitType as Proparse.UnitType ):
        
        create ttInspectUnit.
        ttInspectUnit.UnitType = unitType:GetValue().
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void InspectFieldRefs
        (
        input proUnitId as integer,
        input startNode as integer,
        input endNode as integer
        ):
        define buffer ttProUnit for ttProUnit.
        define buffer ttNode    for ttNode.
        define buffer ttIDNode  for ttNode.
        define variable tableName as character no-undo.
        
        BLK_RECORD:
        for each ttNode where ttNode.NodeNum > startNode
            and ttNode.nodeNum < endNode
            and ttNode.StoreType = "st-dbtable":u
            and ttNode.NodeType = ProParserTokenTypes:Field_ref:
                
            find first ttIDNode where ttIDNode.ParentNum = ttNode.NodeNum
                and ttIDNode.NodeType = ProParserTokenTypes:ID no-error.
            if not available(ttIDNode) then
                next BLK_RECORD.
            if num-entries(ttIDNode.NodeText, ".":u) = 3 then
                tableName = entry(1, ttIDNode.NodeText, ".":u) + ".":u + entry(2, ttIDNode.NodeText, ".":u).
            else
                tableName = entry(1, ttIDNode.NodeText, ".":u).
            find first ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_TEMPTABLE:GetValue()
                and ttProUnit.UnitName = tableName no-error.
            if available(ttProUnit) then
                next BLK_RECORD.
            find first ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_BUFFER:GetValue()
                and ttProUnit.parentId = proUnitId
                and ttProUnit.UnitName = tableName no-error.
            if available(ttProUnit) then
                next BLK_RECORD.
            PublishResult(LintUnit:CompileUnit, 
                ttNode.NodeFile,
                ttNode.NodeLine,
                substitute("no buffer defined for table &1":t, tableName)).
        end.    
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void InspectRecords
        (
        input proUnitId as integer,
        input startNode as integer,
        input endNode as integer
        ):
        define buffer bttProUnit for ttProUnit.        
        define buffer ttNode    for ttNode.
        
        BLK_RECORD:
        for each ttNode where ttNode.NodeNum > startNode
            and ttNode.nodeNum < endNode
            and ttNode.StoreType = "st-dbtable":u
            and ttNode.NodeType = ProParserTokenTypes:RECORD_NAME:
            find first bttProUnit where bttProUnit.UnitType = Proparse.UnitType:U_TEMPTABLE:GetValue()
                and bttProUnit.UnitName = ttNode.NodeText no-error.
            if available(bttProUnit) then
                next BLK_RECORD.
            find first bttProUnit where bttProUnit.UnitType = Proparse.UnitType:U_BUFFER:GetValue()
                and bttProUnit.parentId = proUnitId
                and bttProUnit.UnitName = ttNode.NodeText no-error.
            if available(bttProUnit) then
                next BLK_RECORD.
            PublishResult(LintUnit:CompileUnit, 
                ttNode.NodeFile,
                ttNode.NodeLine,
                substitute("no buffer defined for table &1":t, ttNode.NodeText)).
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
        
        for each ttInspectUnit,            
            each ttProUnit where ttProUnit.UnitType = ttInspectUnit.UnitType
            and ttProUnit.IsAbstract = false:
            InspectRecords(ttProUnit.Id, ttProUnit.StartNode, ttProUnit.EndNode).    
            InspectFieldRefs(ttProUnit.Id, ttProUnit.StartNode, ttProUnit.EndNode).
        end.

    end method.

end class.