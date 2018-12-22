
/*------------------------------------------------------------------------
    File        : iparser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Fri Dec 21 23:18:24 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

interface Proparse.IParser:
    
    {proparse/parsedata.i}    
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsProparse              
    ).
  
end interface.