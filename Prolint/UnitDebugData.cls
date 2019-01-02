 
 /*------------------------------------------------------------------------
    File        : UnitDebugData
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sat Dec 22 21:03:23 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Prolint.IUnitWorker.

block-level on error undo, throw.

class Prolint.UnitDebugData implements IUnitWorker final:
    
    &SCOPED-DEFINE ACCESS_MOD private
    &SCOPED-DEFINE REF_MOD    reference-only
    
    {proparse/parsedata.i}
    {prolint/lintdata.i} 

    define public property TempDir as character no-undo
    get.
    set.     

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsProparse,
       input dataset dsXref
    ):
        if not currentUnit:IsDebug then
            return.
        
        if temp-table ttNode:has-records then            
            temp-table ttNode:write-xml("FILE":U, substitute("&1/nodes.xml":U, TempDir), true, "utf-8":U) no-error.
            
        if temp-table ttProUnit:has-records then            
            temp-table ttProUnit:write-xml("FILE":U, substitute("&1/units.xml":U, TempDir), true, "utf-8":U) no-error.
            
        return.

    end method.

end class.