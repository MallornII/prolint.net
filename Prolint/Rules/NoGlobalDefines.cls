 
 /*------------------------------------------------------------------------
    File        : NoGlobalDefines
    Purpose     : Finds <&GLOBAL-DEFINE> statements
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 10.02.2019 15:59:55
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.UnitType.
using Prolint.Rules.AbstractRule.

block-level on error undo, throw.

class Prolint.Rules.NoGlobalDefines inherits AbstractRule final serializable: 
    
    define private stream sourceInput. 
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public NoGlobalDefines (  ):
        super ().
        
        assign
            RuleDescription = "Finds <&GLOBAL-DEFINE> statements":t
            RuleId          = "NoGlobalDefines":U
            Severity        = 4.
        
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private final void RemoveComment
    (
        input-output lineString as character,
        input-output commentLevel as integer
    ):
        
        define variable commentStart as integer no-undo.
        define variable commentEnd as integer no-undo.
        define variable cnt as integer no-undo.
        define variable initString as character no-undo.
        define variable checkString as character no-undo.
        
        initString = lineString.
        
        if left-trim(lineString) begins "~/~/" then        
            lineString = "".        
        else if commentLevel = 0 or index(lineString, "*~/":u) <> 0 then
        do:
            do cnt = 1 to commentLevel:
                if index(lineString, "*~/":u) > 0 then
                    lineString = substring(lineString, index(lineString, "*~/":u) + 2).
            end.
            
            assign
                commentStart = r-index(lineString, "~/*":u)
                commentEnd = index(lineString, "*~/":u).
            repeat while commentStart > 0 or commentEnd > 0:
                if commentStart <> 0 then do:
                    if commentEnd = 0 or commentEnd < commentStart then
                        lineString = trim(substring(lineString, 1, commentStart - 1 )).
                    else
                        lineString = trim(substring(lineString, 1 , commentStart - 1)) + " " +
                                     trim(substring(lineString, commentEnd + 2)).

                end.
                else
                    lineString = trim(substring(lineString, commentEnd + 2)). 

                assign
                    commentStart = r-index(lineString, "~/*":u)
                    commentEnd   = index(lineString, "*~/":u).
            end.
        end.
        else
            lineString = "".

        do cnt = 1 to length(initString) - 1:

            checkString = substring(initString, cnt, 2).
            if checkString = "~/*":u then
                commentLevel = commentLevel + 1.
            else if checkString = "*~/":u then
                commentLevel = commentLevel - 1.
        end.

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

        define variable lineValue as character no-undo.
        define variable lineNumber as integer no-undo.
        define variable commentLevel as integer no-undo.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).

        BLK_SRC:
        for each ttSource:
            input stream sourceInput from value(ttSource.SourceFile).
            commentLevel = 0.        
            BLK_LINE:
            repeat:                
                import stream sourceInput unformatted lineValue.
                lineNumber = lineNumber + 1.
                
                RemoveComment(input-output lineValue, input-output commentLevel).
                if index(lineValue, "&GLOB") > 0 then
                    PublishResult(currentUnit:CompileUnit, ttSource.SourceFile, lineNumber, 
                    substitute("Statement <&1> should not use <&2>":t, lineValue, "&GLOBAL-DEFINE")).
            end.
            input stream sourceInput close.
        end.
    end method.
end class.