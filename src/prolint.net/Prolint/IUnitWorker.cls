
/*------------------------------------------------------------------------
    File        : IUnitWorker
    Purpose     : Interface for various classes performing actions on ILintUnit
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 22.12.2018 21:02:16
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface Prolint.IUnitWorker:  

    {proparse/parsedata.i}
    {prolint/lintdata.i}
    
    define public property TempDir as character no-undo
    get.
    set.
    
    /*------------------------------------------------------------------------------
     Purpose: Start method for visiting ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/    

    method public void Visit
    (
       input unitInst as Prolint.ILintUnit,
       input dataset dsProparse,
       input dataset dsXref
    ).
        
end interface.