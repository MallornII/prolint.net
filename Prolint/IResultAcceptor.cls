
/*------------------------------------------------------------------------
    File        : IResultAcceptor
    Purpose     : Interface for classes that accepts Lint results
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 12.01.2019 14:00:21
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface Prolint.IResultAcceptor:  
  
    /*------------------------------------------------------------------------------
     Purpose: Receive results published by ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/

    method public void ReceiveResult
    (
        input ruleId      as character,
        input attrs       as character,
        input compileUnit as character,
        input sourceFile  as character,
        input lineNumber  as integer,
        input severity    as integer,
        input comment     as character
    ).

end interface.