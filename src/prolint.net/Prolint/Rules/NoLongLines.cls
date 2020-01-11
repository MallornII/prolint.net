 
 /*------------------------------------------------------------------------
    File        : NoLongLines
    Purpose     : Finds long lines
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 10.02.2019 16:03:44
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.NoLongLines inherits AbstractRule final serializable: 

    define public property MaxLength as integer initial 100 no-undo 
    get.
    set.
    
    define private stream sourceInput. 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public NoLongLines (  ):
        super ().
        
        assign
            RuleDescription = "Finds long lines":t
            RuleId          = "NoLongLines":U
            Severity        = 6.
        
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
            
        define variable lineValue as character no-undo.
        define variable lineNumber as integer no-undo.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        BLK_SRC:
        for each ttSource:
            input stream sourceInput from value(ttSource.SourceFile).        
            BLK_LINE:
            repeat:                
                import stream sourceInput unformatted lineValue.
                lineNumber = lineNumber + 1.
                if length(lineValue) > MaxLength then
                    PublishResult(currentUnit:CompileUnit, ttSource.SourceFile, lineNumber, 
                    substitute("Line <&1> has more than <&2> characters":t, lineNumber, MaxLength)).
            end.
            input stream sourceInput close.
        end.
        
    end method.
end class.