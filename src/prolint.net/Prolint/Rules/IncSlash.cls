 
 /*------------------------------------------------------------------------
    File        : IncSlash
    Purpose     : Finds incorrect slashes in includes
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 03.02.2019 18:20:49
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.IncSlash inherits AbstractRule final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public IncSlash (  ):
        super ().
        
        assign
            RuleDescription = "Finds incorrect slashes in includes":t
            RuleId          = "IncSlash":U
            Severity        = 9.
        
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
        
        BLK_XREF:
        for each ttXref where ttXref.ReferenceType = "include":u,
            first ttSource where ttSource.SourceGUID = ttXref.SourceGUID:            
            if ttXref.ObjectIdentifier matches "*~\*" then
                PublishResult(currentUnit:CompileUnit, ttSource.SourceFile, ttXref.LineNum, 
                    substitute("Compile will fail on Unix, don't use backslash in includefiles: &1":t, ttXref.ObjectIdentifier)).                              
        end.

    end method.
end class.