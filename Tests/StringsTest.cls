 
 /*------------------------------------------------------------------------
    File        : StringsTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Jan 13 19:33:31 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.Core.Assert.
using Utils.Strings.

block-level on error undo, throw.

class Tests.StringsTest:
      
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testAppendEntry(  ):
        
        Assert:IsEmpty(Strings:AppendEntry("", "")).
        Assert:Equals("a":u, Strings:AppendEntry("", "a":u)).
        Assert:Equals("a,":u, Strings:AppendEntry("a":u, "")).
        Assert:Equals("a,b":u, Strings:AppendEntry("a":u, "b":u)).
        Assert:Equals("a,a":u, Strings:AppendEntry("a":u, "a":u)).
        Assert:Equals("a:b":u, Strings:AppendEntry("a":u, "b":u, ":":u)).
        Assert:Equals("a:a":u, Strings:AppendEntry("a":u, "a":u, ":":u)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testAppendUniqueEntry(  ):
        
        Assert:IsEmpty(Strings:AppendUniqueEntry("", "")).
        Assert:Equals("a":u, Strings:AppendUniqueEntry("", "a":u)).
        Assert:Equals("a,":u, Strings:AppendUniqueEntry("a":u, "")).
        Assert:Equals("a,b":u, Strings:AppendUniqueEntry("a":u, "b":u)).
        Assert:Equals("a":u, Strings:AppendUniqueEntry("a":u, "a":u)).
        Assert:Equals("a:b":u, Strings:AppendUniqueEntry("a":u, "b":u, ":":u)).
        Assert:Equals("a":u, Strings:AppendUniqueEntry("a":u, "a":u, ":":u)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testHasEntry(  ):
        
        Assert:IsFalse(Strings:HasEntry("", "a":u)).
        Assert:IsTrue(Strings:HasEntry("a":u, "a":u)).
        Assert:IsTrue(Strings:HasEntry("a,b":u, "a":u)).
        Assert:IsFalse(Strings:HasEntry("a:c":u, "a":u)).
        Assert:IsTrue(Strings:HasEntry("a:c":u, "a":u, ":":u)).
        
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testIsEmptyOrNull(  ):
        
        Assert:IsTrue(Strings:IsEmptyOrNull("")).
        Assert:IsTrue(Strings:IsEmptyOrNull(" ":u)).
        Assert:IsTrue(Strings:IsEmptyOrNull(?)).
        Assert:IsFalse(Strings:IsEmptyOrNull("a":u)).
        return.

    end method.
    
end class.