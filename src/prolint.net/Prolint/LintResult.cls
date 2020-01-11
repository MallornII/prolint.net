
/*------------------------------------------------------------------------
    File        : LintResult
    Purpose     : Enum for resutls of linter:Lint
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 18.12.2018 14:24:42
    Notes       : 
  ----------------------------------------------------------------------*/

enum Prolint.LintResult :  

    define enum 
        LINT_OK        = 0
        COMPILE_ERROR  = 1
        PARSE_ERROR    = 2
        PROPARSE_ERROR = 3
        UNKNOWN_ERROR  = 4
        LINT_NONE      = 5. 

end enum.