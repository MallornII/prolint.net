
/*------------------------------------------------------------------------
    File        : IUnitWorker
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sat Dec 22 21:02:16 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface Prolint.IUnitWorker:  

    {proparse/parsedata.i}
    {prolint/lintdata.i}
    
    define public property TempDir as character no-undo 
    get.
    set. 

    method public void Visit
    (
       input unitInst as Prolint.ILintUnit,
       input dataset dsProparse,
       input dataset dsXref
    ).
        
end interface.