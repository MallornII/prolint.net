 
 /*------------------------------------------------------------------------
    File        : Strings
    Purpose     : Additional method for strings
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 05.01.2019 18:15:35
    Notes       : 
  ----------------------------------------------------------------------*/


block-level on error undo, throw.

class Utils.Strings final: 
     /*------------------------------------------------------------------------------
     Purpose: Adds entry to the list (empty or not)
     Notes: 
    ------------------------------------------------------------------------------*/

    method public static character AppendEntry
        (
        input firstString  as character,
        input secondString as character,
        input delimString as character
        ):      
        return firstString + (if firstString = "" then "" else delimString) + secondString.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Adds entry to the list (empty or not)
     Notes: 
    ------------------------------------------------------------------------------*/

    method public static character AppendEntry
        (
        input firstString  as character,
        input secondString as character
        ):      
        return AppendEntry(firstString, secondString, ",":u).
    end method.

    /*------------------------------------------------------------------------------
     Purpose: Adds entry to the list (empty or not) if it is not already in the list
     Notes:
    ------------------------------------------------------------------------------*/

    method public static character AppendUniqueEntry
    (
        input firstString  as character,
        input secondString as character,
        input delimString as character
    ):  
        if HasEntry(firstString, SecondString, delimString) then
            return firstString.
        else
            return AppendEntry(firstString, SecondString, delimString).
            
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Adds entry to the list (empty or not) if it is not already in the list
     Notes:
    ------------------------------------------------------------------------------*/

    method public static character AppendUniqueEntry
    (
        input firstString  as character,
        input secondString as character
    ):       
        return AppendUniqueEntry(firstString, SecondString, ",":u).       
    end method.

    /*------------------------------------------------------------------------------
     Purpose: Checks if the list contains specific entry
     Notes:
    ------------------------------------------------------------------------------*/

    method public static logical HasEntry
    (
        input sourceString as character,
        input targetString as character
    ):
        return (lookup(targetString, SourceString) > 0).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Adds entry to the list (empty or not) if it is not already in the list
     Notes:
    ------------------------------------------------------------------------------*/

    method public static logical HasEntry
    (
        input sourceString as character,
        input targetString as character,
        input delimString as character        
    ):
        return (lookup(targetString, sourceString, delimString) > 0).
    end method.    

    /*------------------------------------------------------------------------------
     Purpose: Checks if string is empty or of unknown value
     Notes:
    ------------------------------------------------------------------------------*/

    method public static logical IsEmptyOrNull( input checkString as character ):
        return (trim(checkString) = "" or checkString = ?).
    end method.
    
end class.