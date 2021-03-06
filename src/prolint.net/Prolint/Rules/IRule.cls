
/*------------------------------------------------------------------------
    File        : IRule
    Purpose     : Basic interface for rules
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 09.12.2018 15:33:42
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface Prolint.Rules.IRule:
    
    {proparse/parsedata.i}
    {prolint/lintdata.i}

    define public property RuleDescription as character no-undo 
    get.

    define public property RuleId as character no-undo 
    get.

    define public property Severity as integer no-undo 
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