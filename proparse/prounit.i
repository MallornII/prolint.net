
/*------------------------------------------------------------------------
    File        : prounit.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Tue Dec 11 21:13:11 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttProUnit NO-UNDO
    {&REF_MOD}
    FIELD UnitType AS INTEGER
    FIELD UnitName AS CHARACTER
    FIELD SourceFile AS CHARACTER
    FIELD FirstLine AS INTEGER
    FIELD IsForward AS LOGICAL
    FIELD StartNode AS Progress.Lang.Object.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
