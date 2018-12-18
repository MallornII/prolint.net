 
/*------------------------------------------------------------------------
   File        : perror
   Purpose     : Error class that provides actual line in file where error occured
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 05.12.2018 22:29:20
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.AppError.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS proparse.perror INHERITS AppError FINAL: 

    DEFINE PUBLIC PROPERTY LineNumber AS INTEGER NO-UNDO 
        GET.
        PRIVATE SET.

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
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
     Purpose: Constructor with error severity
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