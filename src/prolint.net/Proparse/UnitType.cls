 
 /*------------------------------------------------------------------------
    File        : UnitType
    Purpose     : Enum for unit types in temp-table ttProUnit
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 11.12.2018 21:13:45
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

enum proparse.UnitType: 
    define enum
        U_ROOT = 0        
        U_CLASS
        U_INTERFACE        
        U_PROCEDURE
        U_FUNCTION
        U_CONSTRUCTOR
        U_DESTRUCTOR
        U_METHOD
        U_GETTER
        U_SETTER
        U_PROPERTY
        U_VARIABLE
        U_WIDGET        
        U_PARAMETER
        U_TEMPTABLE
        U_BUFFER.
end enum.