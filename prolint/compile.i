
/*------------------------------------------------------------------------
    File        : compile.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Wed Dec 12 23:50:26 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttCompileMessage NO-UNDO
    {&REF_MOD}
    FIELD SourceFile   AS CHARACTER
    FIELD Severity     AS INTEGER
    FIELD ErrorCode    AS INTEGER
    FIELD ErrorMessage AS CHARACTER
    FIELD ErrorLine    AS INTEGER.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
