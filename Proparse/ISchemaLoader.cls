
/*------------------------------------------------------------------------
    File        : ischemaloader
    Purpose     : Interface for loading DB schema
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 06.12.2018 07:31:34
    Notes       : 
  ----------------------------------------------------------------------*/

interface Proparse.ISchemaLoader:    

	/*------------------------------------------------------------------------------
	 Purpose: Save current DB schema into file (proparse.net.dll can only get DB schema from file)
	 Notes:
	------------------------------------------------------------------------------*/

	method public void ToFile( input schemaFile as character ).

end interface.