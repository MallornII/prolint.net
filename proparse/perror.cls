 
/*------------------------------------------------------------------------
   File        : perror
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Wed Dec 05 22:29:20 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Lang.AppError.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS proparse.perror INHERITS AppError FINAL: 

    DEFINE PUBLIC PROPERTY LineNumber AS INTEGER NO-UNDO 
        GET.
        PRIVATE SET.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
		
    CONSTRUCTOR PUBLIC perror
        (
        INPUT iLine AS INTEGER,
        INPUT iMessage AS CHARACTER,
        INPUT iCode AS INTEGER
        ):
        SUPER (iMessage, iCode).
        LineNumber = iLine.
    END CONSTRUCTOR.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
		
    CONSTRUCTOR PUBLIC perror 
        (
        INPUT iLine AS INTEGER,
        INPUT iMessage AS CHARACTER,
        INPUT iCode AS INTEGER,
        INPUT iSeverity AS INTEGER
        ):
        SUPER (iMessage, iCode).
        Severity = iSeverity.
        LineNumber = iLine.
    END CONSTRUCTOR.


END CLASS.