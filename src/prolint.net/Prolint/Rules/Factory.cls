 
/*------------------------------------------------------------------------
   File        : Factory
   Purpose     : Factory that creates or loades rule's instances
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 21.12.2019 22:04:16 
   Notes       : 
 ----------------------------------------------------------------------*/

block-level on error undo, throw.

class Prolint.Rules.Factory:
    
    define private static variable currentRule    as Prolint.Rules.IRule                      no-undo.  
    
    define private static variable currentClass   as Progress.Lang.Class                      no-undo.

    define private static variable rulesCache     as OpenEdge.Core.Collections.StringKeyedMap no-undo. 

    define private static variable ruleSerializer as Progress.IO.BinarySerializer             no-undo. 
     

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor static Factory (  ):
        rulesCache = new OpenEdge.Core.Collections.StringKeyedMap().
        ruleSerializer = new Progress.IO.BinarySerializer(). 		
    end constructor.

    /*------------------------------------------------------------------------------
     Purpose: Removes instance from cache and file system
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void DropInstance
    (
        input profileName as character,
        input ruleClass as character,
        input isPermanent as logical
    ):
        
        if rulesCache:ContainsKey(substitute("&1:&2":U, profileName, ruleClass)) then
            rulesCache:Remove(substitute("&1:&2":U, profileName, ruleClass)).
        if isPermanent then
            os-delete value(substitute("Profiles/&1/&2.bin", profileName, ruleClass)).
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Gets rule's severity, ID and description
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void GetInfo
        (
        input  profileName     as character,
        input  ruleClass       as character,
        output ruleId          as character,
        output severity        as integer,
        output ruleDescription as character
        ):
        
        currentRule = GetInstance(profileName, ruleClass).       
        
        assign
            ruleId          = currentRule:RuleId
            severity        = currentRule:Severity
            ruleDescription = currentRule:RuleDescription.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Gets instance from cache, file system or createa new one (in that specific order)
     Notes:
    ------------------------------------------------------------------------------*/

    method public static Prolint.Rules.IRule GetInstance
    (
        input profileName as character,
        input ruleClass as character
    ):       
        
        define variable inputStream as Progress.IO.FileInputStream no-undo.        
        
        currentRule = cast(rulesCache:Get(substitute("&1:&2":U, profileName, ruleClass)), Prolint.Rules.IRule).
        if valid-object(currentRule) then
            return currentRule.        
              
        file-info:file-name = substitute("Profiles/&1/&2.bin", profileName, ruleClass).
        if file-info:file-size <> ? then
        do:
            inputStream = new Progress.IO.FileInputStream(file-info:file-name).
            currentRule = cast(ruleSerializer:Deserialize(inputStream), Prolint.Rules.IRule) no-error.            
            inputStream:Close().     
            if valid-object(currentRule) then
            do:
                rulesCache:Put(substitute("&1:&2":U, profileName, ruleClass), currentRule).
                return currentRule.
            end.
        end.
        
        currentClass = Progress.Lang.Class:GetClass(ruleClass) no-error.
        if currentClass = ? then
            undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> cannot be found within PROPATH":T, ruleClass), 0).
        if not currentClass:IsA("Prolint.Rules.IRule":U) then            
            undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> is not implementing of Prolint.Rules.IRule":T, ruleClass), 0).        
        if currentClass:IsAbstract() then            
            undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> is abstract class":T, ruleClass), 0).
        if not currentClass:IsSerializable() then            
            undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> is not serializable class":T, ruleClass), 0). 
        currentRule = cast(currentClass:new(), Prolint.Rules.IRule) no-error.
        if error-status:error then            
            undo, throw new proparse.perror({&LINE-NUMBER}, error-status:get-message(1), error-status:get-number(1), 1).
        rulesCache:Put(substitute("&1:&2":U, profileName, ruleClass), currentRule). 

        return currentRule.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Saves all rules from cache to file system
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void SaveAllRules(  ):
        
        define variable outputStream as Progress.IO.FileOutputStream        no-undo.
        define variable keysIterator as OpenEdge.Core.Collections.IIterator no-undo.
        define variable classKey     as OpenEdge.Core.String                no-undo.
        define variable profileName  as character                           no-undo.
        define variable className    as character                           no-undo.
        
        keysIterator = rulesCache:KeySet:Iterator().
        do while keysIterator:HasNext():
            classKey = cast(keysIterator:Next(), OpenEdge.Core.String).
            assign
                profileName = entry(1, classKey:Value, ":")
                className   = entry(2, classKey:Value, ":").
            outputStream = new Progress.IO.FileOutputStream(substitute("Profiles/&1/&2.bin", profileName, className)).
            ruleSerializer:Serialize(rulesCache:Get(classKey), outputStream).
            outputStream:Close().
            delete object outputStream.
        end.
        
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Saves specific ruile to file system
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void SaveRule
    (
        input profileName as character,
        input ruleClass as character
    ):
        define variable classKey     as OpenEdge.Core.String                no-undo.
        define variable outputStream as Progress.IO.FileOutputStream        no-undo.        
        
        classKey = new OpenEdge.Core.String(substitute("&1:&2":U, profileName, ruleClass)).
        currentRule = cast(rulesCache:Get(classKey), Prolint.Rules.IRule).
        if not valid-object(currentRule) then
            return.
        
        outputStream = new Progress.IO.FileOutputStream(substitute("Profiles/&1/&2.bin", profileName, ruleClass)).
        ruleSerializer:Serialize(rulesCache:Get(classKey), outputStream).
        outputStream:Close().
        delete object outputStream.
        
        return.

    end method.

end class.