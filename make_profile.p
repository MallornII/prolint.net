
/*------------------------------------------------------------------------
    File        : make_profile.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Wed Jan 02 21:18:53 ALMT 2019
    Notes       :
  ----------------------------------------------------------------------*/
block-level on error undo, throw.
/* ***************************  Definitions  ************************** */
define stream sRules.

define variable ruleName     as character           no-undo.
define variable rulePath     as character           no-undo.
define variable currentClass as Progress.Lang.Class no-undo.

{prolint\profile.i}

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
create ttProfile.
assign
    ttProfile.ProfileName  = "default":u
    ttProfile.ParsePropath = ".,Prolint.net":u.
    
input stream sRules from os-dir("Prolint/Rules":u) no-attr-list.
BLK_RULE:
repeat:
    import stream sRules ruleName rulePath.
    if not ruleName matches "*.cls":u then
        next BLK_RULE.
        
    currentClass = Progress.Lang.Class:GetClass(substitute("Prolint.Rules.&1", entry(1, ruleName, "."))) no-error.
    if not valid-object(currentClass) then
        next BLK_RULE.
    if currentClass:HasStatics() then
        next BLK_RULE.
    if currentClass:IsInterface() then
        next BLK_RULE.
    if currentClass:IsAbstract() then
        next BLK_RULE.
    if not currentClass:IsSerializable() then
        next BLK_RULE.
    
    /*if ruleName = "IRule.cls" then
        next BLK_RULE.
    if ruleName = "AbstractRule.cls" then
        next BLK_RULE.
    if ruleName = "Factory.cls" then
        next BLK_RULE.*/
    create ttRule.
    assign
        ttRule.ProfileName = ttProfile.ProfileName.
    ttRule.RuleClass = substitute("Prolint.Rules.&1", entry(1, ruleName, ".":u)).
end.
input stream sRules close.

dataset dsProfile:write-xml("file", "profiles.xml", true, "utf-8":u).

return "0":u.