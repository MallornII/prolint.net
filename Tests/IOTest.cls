 
 /*------------------------------------------------------------------------
    File        : IOTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Jan 13 17:31:29 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.Core.Assert.
using Utils.IO.

block-level on error undo, throw.

class Tests.IOTest:
      
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testGetDirectory(  ):
        
        Assert:Equals("c:/mydir":u, IO:GetDirectory("c:\mydir\":u)).
        Assert:Equals("c:":u, IO:GetDirectory("c:\some_string":u)).
        Assert:Equals("c:/mydir":u, IO:GetDirectory("c:\mydir\test.exe":u)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testGetFileName(  ):
        
        Assert:Equals("test.exe":u, IO:GetFileName("c:\mydir\test.exe":u)).
        Assert:Equals("test.exe":u, IO:GetFileName("test.exe":u)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testMakePath(  ):
        
        Assert:Equals("c:/mydir":u, IO:MakePath("c:\mydir\":u)).
        Assert:Equals("c:/mydir":u, IO:MakePath("c:\mydir/":u)).
        Assert:Equals("c:/mydir/test.exe":u, IO:MakePath("c:/mydir/":u, "test.exe":u)).
        Assert:Equals("c:/mydir/test.exe":u, IO:MakePath("c:\mydir\":u, "test.exe":u)).
        Assert:Equals("c:/mydir/test.exe":u, IO:MakePath("c:/mydir":u, "test.exe":u)).
        Assert:Equals("c:/mydir/test.exe":u, IO:MakePath("c:\mydir":u, "test.exe":u)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testPathExists(  ):        
       
        file-info:file-name = ".":u.        
        Assert:IsTrue(IO:PathExists(file-info:full-pathname)).
        Assert:IsFalse(IO:PathExists("no_real_path&//":u)).
        
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testGetFileExt(  ):
        
        Assert:Equals("exe":u, IO:GetFileExt("c:/mydir/test.exe":u)).
        Assert:Equals("exe":u, IO:GetFileExt("test.exe":u)).
        return.

    end method.
    
end class.