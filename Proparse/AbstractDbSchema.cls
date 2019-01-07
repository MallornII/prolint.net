 
/*------------------------------------------------------------------------
   File        : AbstractDbSchema
   Purpose     : Abstract class for working with Progress databases
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 29.12.2018 22:03:02
   Notes       : 
 ----------------------------------------------------------------------*/

using Proparse.IDbSchema.

block-level on error undo, throw.

class Proparse.AbstractDbSchema implements Proparse.IDbSchema abstract:
    
    define private stream sSchema. 
    
    {proparse/prodb.i &ACCESS_MOD=PROTECTED}
    
    /*------------------------------------------------------------------------------
     Purpose: Returns full DB name by it's name or alias
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveDatabase( input databaseName as character ):
        
        find first ttProDb where ttProDb.DatabaseName = databaseName no-error.
        if available(ttProDb) then
            return ttProDb.DatabaseName.
        
        find first ttProAlias where ttProAlias.AliasName = databaseName no-error.
        if available(ttProAlias) then
            return ttProAlias.DatabaseName.
        else        
            return ?.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full field name from a field_ref qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input fieldName as character ):
        
        if num-entries(fieldName, ".":u) = 3 then
            return ResolveFieldName(entry(1, fieldName, ".":u), entry(2, fieldName, ".":u), entry(3, fieldName, ".":u)).
        else if num-entries(fieldName, ".":u) = 2 then
                return ResolveFieldName(entry(1, fieldName, ".":u), entry(2, fieldName, ".":u)).
        
        find first ttProField where ttProField.FieldName begins fieldName no-error.
        if available(ttProField) then
            return ttProField.FieldName.
        else
            return ?.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full field name from a table name and a field name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input tableName as character, input fieldName as character ):
        
        if tableName = ? then
            return ResolveFieldName(fieldName).
        
        tableName = ResolveTableName(tableName).
        if tableName = ? then
            return ?.
            
        find first ttProField where ttProField.TableName = tableName
            and ttProField.FieldName begins fieldName no-error.
        if available(ttProField) then
            return ttProField.FieldName.
        else
            return ?.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full field name from a database name, a table name and a field name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveFieldName( input databaseName as character, input tableName as character, input fieldName as character ):
        
        if databaseName = ? then
            return ResolveFieldName(tableName, fieldName).
            
        databaseName = ResolveDatabase(databaseName).
        if databaseName = ? then
            return ?.
            
        tableName = ResolveTableName(databaseName, tableName).
        if tableName = ? then
            return ?.
        
        find first ttProField where ttProField.DatabaseName = databaseName
            and ttProField.TableName = tableName
            and ttProField.FieldName begins fieldName no-error.
        if available(ttProField) then
            return ttProField.FieldName.
        else
            return ?.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full table name from a table name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveTableName( input tableName as character ):
        
        if num-entries(tableName, ".":u) = 2 then
            return ResolveTableName(entry(1, tableName, ".":u), entry(1, tableName, ".":u)).
            
        find first ttProTable where ttProTable.TableName begins tableName no-error.
        if available(ttProTable) then
            return ttProTable.TableName.
        else
            return ?.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Resolves full table name from a database name and a table name qualifier.
     Notes:
    ------------------------------------------------------------------------------*/

    method public character ResolveTableName( input databaseName as character, input tableName as character ):
        
        if databaseName = ? then
            return ResolveTableName(tableName).
        
        databaseName = ResolveDatabase(databaseName).
        if databaseName = ? then
            return ?.
        
        find first ttProTable where ttProTable.DatabaseName = databaseName
            and ttProTable.TableName begins tableName no-error.
        if available(ttProTable) then
            return ttProTable.TableName.
        else
            return ?.        

    end method.

    /*------------------------------------------------------------------------------
    Purpose: Save current DB schema into file (proparse.net.dll can only get DB schema from file)
    Notes:
    ------------------------------------------------------------------------------*/

    method public final void ToFile( input schemaFile as character ):

        output stream sSchema to value(schemaFile).  
        for each ttProDb:
            put stream sSchema unformatted substitute(":: &1 &2":U, ttProDb.DatabaseName, ttProDb.id) skip.
            for each ttProTable where ttProTable.DatabaseName = ttProDb.DatabaseName:
                put stream sSchema unformatted substitute(": &1 &2":U, ttProTable.TableName, ttProTable.id) skip.
                for each ttProField where ttProField.DatabaseName = ttProDb.DatabaseName
                    and ttProField.TableName = ttProTable.TableName:
                    put stream sSchema unformatted substitute("&1 &2 &3 &4":U,
                        ttProField.FieldName,
                        ttProField.id,
                        ttProField.DataType,
                        ttProField.Ext) skip.   
                end.
            end.
        end. 
        
        return.
        finally:
            output stream sSchema close.    
        end finally.

    end method.

end class.