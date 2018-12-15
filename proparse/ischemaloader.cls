
/*------------------------------------------------------------------------
    File        : idbschema
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Thu Dec 06 07:31:34 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE proparse.ischemaloader:    

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC VOID ToFile( INPUT iFileName AS CHARACTER ).

END INTERFACE.