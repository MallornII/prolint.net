 
 /*------------------------------------------------------------------------
    File        : DefaultName
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Mon Jan 14 21:49:34 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.DefaultName inherits AbstractRule serializable final: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public DefaultName (  ):
        super ().
        
        assign
            RuleDescription = "Finds widgets with default names":t
            RuleId          = "DefaultName":U
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
            
        define variable defaultPrefix as character no-undo.
        define variable testInt as integer no-undo.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_NODE:
        for each ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_VARIABLE:GetValue()
            and ttProUnit.ViewAs <> "",
            first ttNode where ttNode.nodeNum = ttProUnit.StartNode:
            case ttProUnit.ViewAs:
                when "SELECTION-LIST":u then
                    defaultPrefix = "SELECT-":u.
                when "TOGGLE-BOX":u then
                    defaultPrefix = "TOGGLE-":u.
                otherwise
                    defaultPrefix = substitute("&1-", ttProUnit.ViewAs).
            end case.
            if ttProUnit.UnitName begins defaultPrefix then
            do:
                testInt = ?.
                testInt = integer(substring(ttProUnit.UnitName, length(defaultPrefix) + 1)) no-error.
                if testInt <> ? then
                    PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, 
                                  substitute("&1 is not a meaningful widget name":t, ttProUnit.UnitName)).
            end.
        end.
        
        
        for each ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_WIDGET:GetValue(),
            first ttNode where ttNode.nodeNum = ttProUnit.StartNode:
            defaultPrefix = substitute("&1-", ttProUnit.DataType).
            if ttProUnit.UnitName begins defaultPrefix then
            do:  
                testInt = ?.
                testInt = integer(substring(ttProUnit.UnitName, length(defaultPrefix) + 1)) no-error.
                if testInt <> ? then
                    PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, 
                                  substitute("&1 is not a meaningful widget name":t, ttProUnit.UnitName)).
            end.            
        end.        
        

    end method.
end class.