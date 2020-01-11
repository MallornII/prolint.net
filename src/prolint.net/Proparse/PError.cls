 
/*------------------------------------------------------------------------
   File        : PError
   Purpose     : Error class that provides actual line in file where error occured
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 05.12.2018 22:29:20
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.AppError.

block-level on error undo, throw.

class Proparse.PError inherits AppError final: 

    define public property LineNumber as integer no-undo 
        get.
        private set.

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor public PError
        (
        input errLine as integer,
        input errMessage as character,
        input errCode as integer
        ):
        super (errMessage, errCode).
        LineNumber = errLine.
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose: Constructor with error severity
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor public perror 
        (
        input iLine as integer,
        input iMessage as character,
        input iCode as integer,
        input iSeverity as integer
        ):
        super (iMessage, iCode).
        Severity = iSeverity.
        LineNumber = iLine.
    end constructor.


end class.