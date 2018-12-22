 
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

class Proparse.SchemaLoader implements Proparse.ISchemaLoader final: 

    define private stream sSchema.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    -----------------------------------------------------------------------------*/

    method private void ParseDatabase( input dbNum as integer ):
		
        define variable bufferFile  as handle    no-undo.
        define variable bufferField as handle    no-undo.
        define variable queryFile   as handle    no-undo.
        define variable thisDb      as character no-undo.        
        define variable isOk        as logical   no-undo.     
        
        thisDb = ldbname(dbNum).
        put stream sSchema unformatted substitute(":: &1 &2":U, thisDb, dbNum) skip.
        
        create buffer bufferFile for table substitute("&1._file", thisDb).
        create buffer bufferField for table substitute("&1._field", thisDb).
        
        create query queryFile.        
        queryFile:add-buffer (bufferFile).
        isOk = queryFile:query-prepare(substitute("FOR EACH _file WHERE _file._tbl-type = &1":U, quoter("T":U))).
        if not isOk then
            undo, throw new proparse.perror({&LINE-NUMBER}, error-status:get-message(1) , error-status:get-number(1), 1).
        queryFile:query-open().
        queryFile:get-first().
        do while not queryFile:query-off-end:
            put stream sSchema unformatted substitute(": &1 &2":U, bufferFile::_file-name, bufferFile:recid) skip.             
            ParseFile(bufferField, bufferFile:recid).
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

    method private void ParseFile( input iBufferField as handle, iRecID as recid ):
        define variable isOk       as logical no-undo.
        define variable queryField as handle  no-undo.
	    
        create query queryField.
        queryField:add-buffer (iBufferField).  
             
        isOk = queryField:query-prepare(substitute("FOR EACH _field WHERE _field._File-Recid = &1":U, iRecID)).
        if not isOk then
            undo, throw new proparse.perror({&LINE-NUMBER}, error-status:get-message(1) , error-status:get-number(1), 1).
                
        queryField:query-open().
        queryField:get-first().           
        do while not queryField:query-off-end:
            put stream sSchema unformatted substitute("&1 &2 &3 &4":U,
                iBufferField::_field-name,
                iRecID,
                caps(iBufferField::_data-type),
                iBufferField::_extent) skip.             
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
    
    /*------------------------------------------------------------------------------
     Purpose: Save current DB schema into file (proparse.net.dll can only get DB schema from file)
     Notes:
    ------------------------------------------------------------------------------*/

    method public void ToFile( input schemaFile as character ):
		
        define variable dbNum as integer no-undo.

        output stream sSchema TO VALUE(schemaFile).  
        do dbNum = 1 to num-dbs:
            if dbtype(dbNum) <> "PROGRESS":U then next.
            ParseDatabase(dbNum).
        end.
        
        return.
        finally:
            output stream sSchema close. 	
        end finally.

    end method.

end class.