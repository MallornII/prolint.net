
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
    XML-NODE-NAME "Profile"
    FIELD ProfileName AS CHARACTER XML-NODE-TYPE "ATTRIBUTE".
    
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttRule NO-UNDO
    XML-NODE-NAME "Rule"
    FIELD ProfileName     AS CHARACTER
    FIELD RuleId          AS CHARACTER XML-NODE-TYPE "ATTRIBUTE"
    FIELD RuleClass       AS CHARACTER
    FIELD Severity        AS INTEGER   XML-NODE-TYPE "ATTRIBUTE"
    FIELD RuleDescription AS CHARACTER
    INDEX iMain IS UNIQUE PRIMARY RuleClass.
    
DEFINE {&ACCESS_MOD} {&STAT_MOD} DATASET dsProfile
    XML-NODE-NAME "LintProfiles"
    FOR ttProfile, ttRule
    DATA-RELATION drRule
    FOR ttProfile, ttRule
    RELATION-FIELDS (ProfileName, ProfileName)
    NESTED FOREIGN-KEY-HIDDEN.     
    

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
