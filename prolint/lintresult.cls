
/*------------------------------------------------------------------------
    File        : lintresult
    Purpose     : Enum for resutls of linter:Lint
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 18.12.2018 14:24:42 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

ENUM prolint.lintresult :  

    DEFINE ENUM 
        LINT_OK        = 0
        COMPILE_ERROR  = 1
        PARSE_ERROR    = 2
        PROPARSE_ERROR = 3
        UNKNOWN_ERROR  = 4. 

END ENUM.