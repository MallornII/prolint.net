 
 /*------------------------------------------------------------------------
    File        : IO
    Purpose     : Utilities for working wih filesystem
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 05.01.2019 18:09:05
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using Progress.IO.FileInputStream.

class Utils.IO final: 

    /*------------------------------------------------------------------------------
     Purpose: Gets Directory from FullPath
     Notes:
    ------------------------------------------------------------------------------*/

    method public static character GetDirectory( input sourcePath as character ):
        
        sourcePath = MakePath(sourcePath).
        
        return substring(sourcePath, 1, max(r-index(sourcePath, "/":u) - 1, 0)).

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Gets FileName from FullPath
     Notes:
    ------------------------------------------------------------------------------*/

    method public static character GetFileName( input sourcePath as character ):
        
        sourcePath = MakePath(sourcePath).
        
        return entry(num-entries(sourcePath, "/":u), sourcePath, "/":u).

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Creates FullPath from directory and file. Also changes all "\" to "/"
     Notes: 
     @param sourcePath Directory path. Can end with "/" or not
     @param sourceName Name of the file
     @return full path combined from path and filename
    ------------------------------------------------------------------------------*/

    method public static character MakePath
    (
        input sourcePath as character,
        input sourceName as character
    ):      

        return right-trim(replace(sourcePath, "~\":u, "/":u), "/":u) + "/":u + replace(sourceName, "~\":u, "/":u).

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Changes all "\" to "/"
     Notes:
     @param iPath Directory path. Can end with "/" or not     
    ------------------------------------------------------------------------------*/

    method public static character MakePath
    (
        input sourcePath as character       
    ):      

        return right-trim(replace(sourcePath, "~\":u, "/":u), "/":u).

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Checks if Path provided exists
     Notes:
     @param sourcePath Path to file or directory
    ------------------------------------------------------------------------------*/

    method public static logical PathExists( input sourcePath as character ):
        
        define variable inStream as Progress.IO.FileInputStream no-undo.
        
        inStream = new FileInputStream(sourcePath) no-error.

        return not error-status:error.
        finally:
            if valid-object(inStream) then
                delete object inStream.    
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get file extenstion
     Notes:
     @param fullName Can be just a FileName for FullPath
    ------------------------------------------------------------------------------*/

    method public static character GetFileExt( input fullName as character ):
        
        define variable ext as character no-undo.
        
        ext = entry(num-entries(fullName, "/":U), fullName, "/":U).
        ext = entry(num-entries(ext, ".":U), ext, ".":U).
        return ext.

    end method.

end class.