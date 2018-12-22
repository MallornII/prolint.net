
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
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttProfile no-undo
    xml-node-name "Profile"
    field ProfileName as character xml-node-type "ATTRIBUTE".
    
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttRule no-undo
    xml-node-name "Rule"
    field ProfileName     as character
    field RuleId          as character xml-node-type "ATTRIBUTE"
    field RuleClass       as character
    field Severity        as integer   xml-node-type "ATTRIBUTE"
    field RuleDescription as character
    index iMain is unique primary RuleClass.
    
define {&ACCESS_MOD} {&STAT_MOD} dataset dsProfile
    xml-node-name "LintProfiles"
    for ttProfile, ttRule
    data-relation drRule
    for ttProfile, ttRule
    relation-fields (ProfileName, ProfileName)
    nested foreign-key-hidden.     
    

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
