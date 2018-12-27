 
 /*------------------------------------------------------------------------
    File        : UnitType
    Purpose     : Enum for unit types in temp-table ttProUnit
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 11.12.2018 21:13:45 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

enum proparse.UnitType: 
    define enum
        U_PROCEDURE
        U_FUNCTION
        U_METHOD
        U_GETTER
        U_SETTER
        U_PROPERTY
        U_VARIABLE
        U_TEMPTABLE.
end enum.