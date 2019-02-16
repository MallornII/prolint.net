 
/*------------------------------------------------------------------------
   File        : NoUndo
   Purpose     : Finds variables, properties, parameters and temp-tables without <NO-UNDO> option
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 16.02.2019 14:39:06
   Notes       : 
 ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.NoUndo inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public NoUndo (  ):
        super ().
        
        assign
            RuleDescription = "Finds variables, properties, parameters and temp-tables without <NO-UNDO> option":t
            RuleId          = "NoUndo":U
            Severity        = 8.
        
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void FindUndoUnits( input unitType as int64 ):
        
        define buffer ttProUnit    for ttProUnit.
        define buffer ttParentUnit for ttProUnit.
        
        BLK_UNIT:
        for each ttProUnit where ttProUnit.UnitType = unitType
            and ttProUnit.IsNoUndo = false,
            first ttParentUnit where ttParentUnit.Id = ttProunit.ParentId:
            if ttProUnit.UnitType = ProParse.UnitType:U_PARAMETER:GetValue() and 
                (ttParentUnit.UnitType = ProParse.UnitType:U_FUNCTION:GetValue() 
                or ttParentUnit.UnitType = ProParse.UnitType:U_METHOD:GetValue()) then
                next.
            PublishResult(LintUnit:CompileUnit, ttProUnit.SourceFile, ttProUnit.FirstLine, 
                substitute("&1 <&2> defined without <NO-UNDO> option":T, ProParse.UnitType:GetEnum(unitType):ToString(), ttProUnit.UnitName)).
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

        FindUndoUnits(ProParse.UnitType:U_VARIABLE:GetValue()).       
        FindUndoUnits(ProParse.UnitType:U_PROPERTY:GetValue()).
        FindUndoUnits(ProParse.UnitType:U_PARAMETER:GetValue()).
        FindUndoUnits(ProParse.UnitType:U_TEMPTABLE:GetValue()).
        
    end method.
end class.