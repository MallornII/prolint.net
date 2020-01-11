
/*------------------------------------------------------------------------
    File        : IParser
    Purpose     : Interface for classes that parse ILintUnit
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 21.12.2018 23:18:24
    Notes       : 
  ----------------------------------------------------------------------*/

interface Proparse.IParser:
    
    {proparse/parsedata.i}    
    
    /*------------------------------------------------------------------------------
     Purpose: Start method for visiting ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsProparse              
    ).
  
end interface.