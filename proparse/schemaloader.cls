 
/*------------------------------------------------------------------------
   File        : schemaloader
   Purpose     : Reads schemas of all currently connected DB's
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 06.12.2018 07:34:09
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS proparse.schemaloader IMPLEMENTS proparse.ischemaloader FINAL: 

    DEFINE PRIVATE STREAM sSchema.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    -----------------------------------------------------------------------------*/

    METHOD PRIVATE VOID ParseDatabase( INPUT iDbNum AS INTEGER ):
		
        DEFINE VARIABLE bufferFile  AS HANDLE    NO-UNDO.
        DEFINE VARIABLE bufferField AS HANDLE    NO-UNDO.
        DEFINE VARIABLE queryFile   AS HANDLE    NO-UNDO.
        DEFINE VARIABLE vName       AS CHARACTER NO-UNDO.        
        DEFINE VARIABLE isOk        AS LOGICAL   NO-UNDO.     
        
        vName = LDBNAME(iDbNum).
        PUT STREAM sSchema UNFORMATTED SUBSTITUTE(":: &1 &2":U, vName, iDbNum) SKIP.
        
        CREATE BUFFER bufferFile FOR TABLE SUBSTITUTE("&1._file", vName).
        CREATE BUFFER bufferField FOR TABLE SUBSTITUTE("&1._field", vName).
        
        CREATE QUERY queryFile.        
        queryFile:ADD-BUFFER (bufferFile).
        isOk = queryFile:QUERY-PREPARE(SUBSTITUTE("FOR EACH _file WHERE _file._tbl-type = &1":U, QUOTER("T":U))).
        IF NOT isOk THEN
            UNDO, THROW NEW proparse.perror({&LINE-NUMBER}, ERROR-STATUS:GET-MESSAGE(1) , ERROR-STATUS:GET-NUMBER(1), 1).
        queryFile:QUERY-OPEN().
        queryFile:GET-FIRST().
        DO WHILE NOT queryFile:QUERY-OFF-END:
            PUT STREAM sSchema UNFORMATTED SUBSTITUTE(": &1 &2":U, bufferFile::_file-name, bufferFile:RECID) SKIP.             
            ParseFile(bufferField, bufferFile:RECID).
            queryFile:GET-NEXT().
        END.
        queryFile:QUERY-CLOSE().

        RETURN.
        
        FINALLY:          
            IF VALID-HANDLE(queryFile) THEN
            DO:
                queryFile:QUERY-CLOSE().
                DELETE OBJECT queryFile.
            END.
            IF VALID-HANDLE(bufferField) THEN
                DELETE OBJECT bufferField.
            IF VALID-HANDLE(bufferFile) THEN
                DELETE OBJECT bufferFile. 
        END FINALLY.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE VOID ParseFile( INPUT iBufferField AS HANDLE, iRecID AS RECID ):
        DEFINE VARIABLE isOk       AS LOGICAL NO-UNDO.
        DEFINE VARIABLE queryField AS HANDLE  NO-UNDO.
	    
        CREATE QUERY queryField.
        queryField:ADD-BUFFER (iBufferField).  
             
        isOk = queryField:QUERY-PREPARE(SUBSTITUTE("FOR EACH _field WHERE _field._File-Recid = &1":U, iRecID)).
        IF NOT isOk THEN
            UNDO, THROW NEW proparse.perror({&LINE-NUMBER}, ERROR-STATUS:GET-MESSAGE(1) , ERROR-STATUS:GET-NUMBER(1), 1).
                
        queryField:QUERY-OPEN().
        queryField:GET-FIRST().           
        DO WHILE NOT queryField:QUERY-OFF-END:
            PUT STREAM sSchema UNFORMATTED SUBSTITUTE("&1 &2 &3 &4":U,
                iBufferField::_field-name,
                iRecID,
                CAPS(iBufferField::_data-type),
                iBufferField::_extent) SKIP.             
            queryField:GET-NEXT().
        END.
        queryField:QUERY-CLOSE().
		
        RETURN.

        FINALLY:
            IF VALID-HANDLE(queryField) THEN
            DO:
                queryField:QUERY-CLOSE().
                DELETE OBJECT queryField.
            END.         
        END FINALLY.

    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Save current DB schema into file (proparse.net.dll can only get DB schema from file)
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID ToFile( INPUT iFileName AS CHARACTER ):
		
        DEFINE VARIABLE dbNum AS INTEGER NO-UNDO.

        OUTPUT STREAM sSchema TO VALUE(iFileName).  
        DO dbNum = 1 TO NUM-DBS:
            IF DBTYPE(dbNum) <> "PROGRESS":U THEN NEXT.
            ParseDatabase(dbNum).
        END.
        
        RETURN.
        FINALLY:
            OUTPUT STREAM sSchema CLOSE. 	
        END FINALLY.

    END METHOD.

END CLASS.