
/*------------------------------------------------------------------------
    File        : results.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Tue Dec 18 15:13:13 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE {&ACCESS_MOD} TEMP-TABLE ttResult NO-UNDO
        FIELD RuleId     AS CHARACTER
        FIELD Unit       AS CHARACTER
        FIELD SourceFile AS CHARACTER
        FIELD LineNumber AS INTEGER
        FIELD Severity   AS INTEGER
        FIELD Comment    AS CHARACTER.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
