 
 /*------------------------------------------------------------------------
    File        : MathTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Jan 13 17:51:15 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.Core.Assert.
using Utils.Math.

block-level on error undo, throw.

class Tests.MathTest:
      
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testbin_xor(  ):
        
        Assert:Equals(1, Math:bin_xor(0, 1)).
        Assert:Equals(0, Math:bin_xor(1, 1)).
        Assert:Equals(3, Math:bin_xor(1, 2)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testbin_or(  ):
        
        Assert:Equals(1, Math:bin_or(0, 1)).
        Assert:Equals(1, Math:bin_or(1, 1)).
        Assert:Equals(3, Math:bin_or(1, 2)).
        Assert:Equals(3, Math:bin_or(1, 3)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testbin_and(  ):
        
        Assert:Equals(0, Math:bin_and(0, 1)).
        Assert:Equals(1, Math:bin_and(1, 1)).
        Assert:Equals(0, Math:bin_and(1, 2)).
        Assert:Equals(1, Math:bin_and(1, 3)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testbin_lshift(  ):
        
        Assert:Equals(2, Math:bin_lshift(1, 1)).
        Assert:Equals(8, Math:bin_lshift(1, 3)).
        Assert:Equals(20, Math:bin_lshift(5, 2)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testbin_rshift(  ):
        
        Assert:Equals(0, Math:bin_rshift(1, 1)).
        Assert:Equals(1, Math:bin_rshift(8, 3)).
        Assert:Equals(4, Math:bin_rshift(17, 2)).
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testcast_byte(  ):
        
        Assert:Equals(250, Math:cast_byte(250)).
        Assert:Equals(1, Math:cast_byte(257)).
        
        return.

    end method.
    
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @Test. 
    method public void testcast_short(  ):
        
        Assert:Equals(65535, Math:cast_short(65535)).
        Assert:Equals(1, Math:cast_short(65537)).
        return.

    end method.
    
end class.