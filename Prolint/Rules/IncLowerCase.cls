 
 /*------------------------------------------------------------------------
    File        : IncLowerCase
    Purpose     : Finds includes with upper-case names
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 03.02.2019 18:12:56
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.IncLowerCase inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public IncLowerCase (  ):
        super ().
        
        assign
            RuleDescription = "Finds includes with upper-case names":t
            RuleId          = "IncLowerCase":U
            Severity        = 8.
        
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
            
        define variable includeName as character no-undo case-sensitive.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_XREF:
        for each ttXref where ttXref.ReferenceType = "include":u,
            first ttSource where ttSource.SourceGUID = ttXref.SourceGUID:
            includeName = ttXref.ObjectIdentifier.
            if includeName <> lc(includeName) then
                PublishResult(currentUnit:CompileUnit, ttSource.SourceFile, ttXref.LineNum, 
                    substitute("Compile will fail on Unix, use only lower-case includefiles: &1":t, includeName)).                              
        end.

    end method.
end class.