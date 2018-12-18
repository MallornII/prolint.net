 
 /*------------------------------------------------------------------------
    File        : UnitType
    Purpose     : Enum for unit types in temp-table ttProUnit
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 11.12.2018 21:13:45 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

ENUM proparse.UnitType: 
    DEFINE ENUM
        U_PROCEDURE
        U_FUNCTION
        U_METHOD
        U_GETTER
        U_SETTER.
END ENUM.