
/*------------------------------------------------------------------------
    File        : ischemaloader
    Purpose     : Interface for loading DB schema
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 06.12.2018 07:31:34
    Notes       : 
  ----------------------------------------------------------------------*/

interface Proparse.IDbSchema:    

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveDatabase( input databaseName as character ).

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input fieldName as character ).
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input tableName as character, input fieldName as character ).
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input databaseName as character, input tableName as character,input fieldName as character ).

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveTableName( input tableName as character ).
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveTableName( input databaseName as character, input tableName as character ).

	/*------------------------------------------------------------------------------
	 Purpose: Save current DB schema into file (proparse.net.dll can only get DB schema from file)
	 Notes:
	------------------------------------------------------------------------------*/

	method public void ToFile( input schemaFile as character ).

end interface.