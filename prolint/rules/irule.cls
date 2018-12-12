
/*------------------------------------------------------------------------
    File        : irule
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Dec 09 15:33:42 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE prolint.rules.irule:
    {proparse/jpnodes.i &REF_MOD="REFERENCE-ONLY"}
  
	DEFINE PUBLIC PROPERTY RuleId AS CHARACTER NO-UNDO 
	GET.	 

	DEFINE PUBLIC PROPERTY Severity AS INTEGER NO-UNDO 
	GET.
	 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC VOID ApplyRule( TABLE ttNode BIND ).

END INTERFACE.