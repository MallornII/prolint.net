 
/*------------------------------------------------------------------------
   File        : schemaloader
   Purpose     : Reads schemas of all currently connected DB's
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 06.12.2018 07:34:09
   Notes       : 
 ----------------------------------------------------------------------*/

block-level on error undo, throw.

class Proparse.ProDbSchema inherits Proparse.AbstractDbSchema final: 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public ProDbSchema (  ):
        define variable dbNum as integer no-undo.
        
        super ().
        do dbNum = 1 to num-dbs:
            if dbtype(dbNum) <> "PROGRESS":U then next.
            ParseDatabase(dbNum).
        end.        
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    -----------------------------------------------------------------------------*/

    method private void ParseDatabase( input dbNum as integer ):
		
        define variable bufferFile  as handle  no-undo.
        define variable bufferField as handle  no-undo.
        define variable queryFile   as handle  no-undo.                
        define variable isOk        as logical no-undo.
        
        create ttProDb.
        assign
            ttProDb.id           = dbNum
            ttProDb.DatabaseName = ldbname(dbNum).
        
        create buffer bufferFile for table substitute("&1._file", ttProDb.DatabaseName).
        create buffer bufferField for table substitute("&1._field", ttProDb.DatabaseName).
            
        create query queryFile.  
        queryFile:add-buffer (bufferFile).
        isOk = queryFile:query-prepare("FOR EACH _file":U).
        if not isOk then
            undo, throw new proparse.perror({&LINE-NUMBER}, error-status:get-message(1) , error-status:get-number(1), 1).
        queryFile:query-open().
        queryFile:get-first().
        do while not queryFile:query-off-end:
            create ttProTable.
            assign
                ttProTable.id           = int64(bufferFile:recid)
                ttProTable.DatabaseName = ttProDb.DatabaseName
                ttProTable.TableName    = bufferFile::_file-name.            
                         
            ParseFile(bufferField, bufferFile:recid, ttProDb.DatabaseName, ttProTable.TableName).
            queryFile:get-next().
        end.
        queryFile:query-close().

        return.
        
        finally:          
            if valid-handle(queryFile) then
            do:
                queryFile:query-close().
                delete object queryFile.
            end.
            if valid-handle(bufferField) then
                delete object bufferField.
            if valid-handle(bufferFile) then
                delete object bufferFile. 
        end finally.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void ParseFile
        (
        input bufferField as handle,
        input fileRecID as recid,
        input databaseName as character,
        input tableName as character
        ):
        define variable isOk       as logical no-undo.
        define variable queryField as handle  no-undo.
	    
        create query queryField.
        queryField:add-buffer (bufferField).  
             
        isOk = queryField:query-prepare(substitute("FOR EACH _field WHERE _field._File-Recid = &1":U, fileRecID)).
        if not isOk then
            undo, throw new proparse.perror({&LINE-NUMBER}, error-status:get-message(1) , error-status:get-number(1), 1).
                
        queryField:query-open().
        queryField:get-first().           
        do while not queryField:query-off-end:
            create ttProField.
            assign
                ttProField.id           = int64(bufferField:recid)
                ttProField.DatabaseName = databaseName
                ttProField.TableName    = tableName
                ttProField.FieldName    = bufferField::_field-name
                ttProField.DataType     = caps(bufferField::_data-type)
                ttproField.Ext          = bufferField::_extent.                
                      
            queryField:get-next().
        end.
        queryField:query-close().
		
        return.

        finally:
            if valid-handle(queryField) then
            do:
                queryField:query-close().
                delete object queryField.
            end.         
        end finally.

    end method.    


end class.