 
 /*------------------------------------------------------------------------
    File        : FnUsage
    Purpose     : Finds private functions that is never used
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 02.02.2019 15:03:39
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.FnUsage inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public FnUsage (  ):
        super ().
        
        assign
            RuleDescription = "Finds private functions that is never used":t
            RuleId          = "FnUsage":U
            Severity        = 4.
        
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
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_UNIT:
        for each ttProUnit where ttProUnit.UnitType = Proparse.UnitType:U_FUNCTION:GetValue()
            and ttProUnit.AccessMode = "PRIVATE":u
            and ttProUnit.IsAbstract = false:
            if not can-find(first ttNode where ttnode.NodeType = ProParserTokenTypes:USER_FUNC
                and ttNode.NodeText = ttProUnit.UnitName) then
            PublishResult(currentUnit:CompileUnit, ttProUnit.SourceFile, ttProUnit.FirstLine,
                          substitute("Private function <&1> is not called in current program":t, ttProUnit.UnitName)).                              
        end.

    end method.
end class.