
/*------------------------------------------------------------------------
    File        : ischemaloader
    Purpose     : Interface for loading DB schema
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 06.12.2018 07:31:34
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE proparse.ischemaloader:    

	/*------------------------------------------------------------------------------
	 Purpose: Save current DB schema into file (proparse.net.dll can only get DB schema from file)
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC VOID ToFile( INPUT iFileName AS CHARACTER ).

END INTERFACE.