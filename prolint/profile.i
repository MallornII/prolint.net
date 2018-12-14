
/*------------------------------------------------------------------------
    File        : profile.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Fri Dec 14 14:28:03 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttProfile NO-UNDO
    FIELD ProfileName AS CHARACTER.
    
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttProfileRule NO-UNDO
    FIELD ProfileName     AS CHARACTER
    FIELD RuleId          AS CHARACTER
    FIELD Severity        AS INTEGER
    FIELD IncludeSeverity AS INTEGER.
    
DEFINE DATASET {&ACCESS_MOD} {&STAT_MOD} dsProfile
FOR ttProfile, ttProfileRule
    DATA-RELATION drRule
    FOR ttProfile, ttProfileRule
    RELATION-FIELDS (ProfileName, ProfileName)
    NESTED FOREIGN-KEY-HIDDEN.     
    

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
