 
 /*------------------------------------------------------------------------
    File        : LintTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Fri Dec 28 22:02:22 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.Core.Assert.

block-level on error undo, throw.

class Tests.LintTest:
    
    define private variable lintInstance as Prolint.Linter.
    
       /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/

    @Before.
    method public void setUpBeforeClass(  ):
        
        return.

    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
   
    @Setup.
    method public void setUp(  ):        
        
        return.

    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/

    @TearDown.
    method public void tearDown(  ):
        
        return.

    end method.
     
       /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
   
    @After.
    method public void tearDownAfterClass(  ):
        
        return.

    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testLoadProfiles(  ):
        
        lintInstance = new Prolint.Linter("asdfasd":u) no-error.
        Assert:IsTrue(error-status:error).
        lintInstance = new Prolint.Linter("default":u) no-error.
        Assert:NotNull(lintInstance).
        return.

    end method.  
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testLint(  ):
        
        Assert:Equals("default":u, lintInstance:CurrentProfile).
        Assert:Equals(Prolint.LintResult:LINT_OK, lintInstance:Lint("LintDummy.p":u)).
        return.

    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testGetErrors(  ):
        
        Assert:IsFalse(lintInstance:ErrorStatus()).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testLintCollection(  ):
        
        return.

    end method.
    
    

    
end class.