
/*------------------------------------------------------------------------
    File        : IDbSchema
    Purpose     : Interface for loading DB schema
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 06.12.2018 07:31:34
    Notes       : 
  ----------------------------------------------------------------------*/

interface Proparse.IDbSchema:    

    /*------------------------------------------------------------------------------
     Purpose: Returns full DB name by it's name or alias
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveDatabase( input databaseName as character ).

    /*------------------------------------------------------------------------------
     Purpose: Resolves full field name from a field_ref qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input fieldName as character ).
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full field name from a table name and a field name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input tableName as character, input fieldName as character ).
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full field name from a database name, a table name and a field name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input databaseName as character, input tableName as character,input fieldName as character ).

    /*------------------------------------------------------------------------------
     Purpose: Resolves full table name from a table name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveTableName( input tableName as character ).
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full table name from a database name and a table name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveTableName( input databaseName as character, input tableName as character ).

	/*------------------------------------------------------------------------------
	 Purpose: Save current DB schema into file (proparse.net.dll can only get DB schema from file)
	 Notes:
	------------------------------------------------------------------------------*/

	method public void ToFile( input schemaFile as character ).

end interface.