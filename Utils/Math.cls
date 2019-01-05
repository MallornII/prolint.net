 
 /*------------------------------------------------------------------------
    File        : Binary
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Fri Jan 04 21:41:16 ALMT 2019
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

class Utils.Math final: 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer bin_xor( input a as integer, input b as integer ):
        
        define variable pos as integer no-undo.
        define variable c as integer no-undo.
        
        do pos = 1 to 32:
            if get-bits(a, pos, 1) + get-bits(b, pos, 1) = 1 then
                put-bits(c, pos, 1) = 1.                
        end.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static int64 bin_xor( input a as int64, input b as int64 ):
        
        define variable pos as integer no-undo.
        define variable c as int64 no-undo.
        
        do pos = 1 to 64:
            if get-bits(a, pos, 1) + get-bits(b, pos, 1) = 1 then
                put-bits(c, pos, 1) = 1.                
        end.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer bin_or( input a as integer, input b as integer ):
        
        define variable pos as integer no-undo.
        define variable c as integer no-undo.
        
        do pos = 1 to 32:
            if get-bits(a, pos, 1) + get-bits(b, pos, 1) > 0 then
                put-bits(c, pos, 1) = 1.                
        end.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static int64 bin_or( input a as int64, input b as int64 ):
        
        define variable pos as integer no-undo.
        define variable c as int64 no-undo.
        
        do pos = 1 to 64:
            if get-bits(a, pos, 1) + get-bits(b, pos, 1) > 0 then
                put-bits(c, pos, 1) = 1.                
        end.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer bin_and( input a as integer, input b as integer ):
        
        define variable pos as integer no-undo.
        define variable c as integer no-undo.
        
        do pos = 1 to 32:
            if get-bits(a, pos, 1) + get-bits(b, pos, 1) = 2 then
                put-bits(c, pos, 1) = 1.                
        end.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static int64 bin_and( input a as int64, input b as int64 ):
        
        define variable pos as integer no-undo.
        define variable c as int64 no-undo.
        
        do pos = 1 to 64:
            if get-bits(a, pos, 1) + get-bits(b, pos, 1) = 2 then
                put-bits(c, pos, 1) = 1.                
        end.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer bin_lshift( input a as integer, input shift as integer ):        
        
        define variable c as integer no-undo.
        
        if shift > 31 or shift < 1 then
            return 0.
            
        put-bits(c, shift + 1, 32) = get-bits(a, 1, 32 - shift).
        put-bits(c, 1, shift) = 0.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static int64 bin_lshift( input a as int64, input shift as integer ):        
        
        define variable c as int64 no-undo.
        
        if shift > 63 or shift < 1 then
            return 0.
            
        put-bits(c, shift + 1, 64) = get-bits(a, 1, 64 - shift).
        put-bits(c, 1, shift) = 0.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer bin_rshift( input a as integer, input shift as integer ):        
        
        define variable c as integer no-undo.
        
        if shift > 31 or shift < 1 then
            return 0.
            
        put-bits(c, 1, 32 - shift) = get-bits(a, shift + 1, 32 - shift).
        put-bits(c, 33 - shift, shift) = 0.
        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static int64 bin_rshift( input a as int64, input shift as integer ):        
        
        define variable c as integer no-undo.
        
        if shift > 63 or shift < 1 then
            return 0.
            
        put-bits(c, 1, 64 - shift) = get-bits(a, shift + 1, 64 - shift).
        put-bits(c, 65 - shift, shift) = 0.
        return c.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer cast_byte( input a as integer ):
        
        define variable c as integer no-undo.
        
        put-bits(c, 1, 8) = get-bits(a, 1, 8).

        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer cast_byte( input a as int64 ):
        
        define variable c as integer no-undo.
        
        put-bits(c, 1, 8) = get-bits(a, 1, 8).

        return c.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer cast_short( input a as integer ):
        
        define variable c as integer no-undo.
        
        put-bits(c, 1, 16) = get-bits(a, 1, 16).

        return c.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static integer cast_short( input a as int64 ):
        
        define variable c as integer no-undo.
        
        put-bits(c, 1, 16) = get-bits(a, 1, 16).

        return c.

    end method.     
    

end class.