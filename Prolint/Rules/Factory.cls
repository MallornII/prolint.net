 
/*------------------------------------------------------------------------
   File        : factory
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Fri Dec 21 22:04:16 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

block-level on error undo, throw.

class Prolint.Rules.Factory:
    
    define private static variable currentRule   as Prolint.Rules.IRule                      no-undo.  
    
    define private static variable currentClass  as Progress.Lang.Class                      no-undo.

    define private static variable rulesCache as OpenEdge.Core.Collections.StringKeyedMap no-undo. 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor static factory (  ):
        rulesCache = new OpenEdge.Core.Collections.StringKeyedMap().		
    end constructor.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void GetInfo
        (
        input  ruleClass       as character,
        output ruleId          as character,
        output severity        as integer,
        output ruleDescription as character
        ):
        
        currentRule = cast(rulesCache:Get(ruleClass), Prolint.Rules.IRule ).
        if not valid-object(currentRule) then        
        do:
            currentClass = Progress.Lang.Class:GetClass(ruleClass).
            if currentClass = ? then
                undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> cannot be found within PROPATH":T, ruleClass), 0).
            if not currentClass:IsA("Prolint.Rules.IRule":U) then            
                undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> is noy implementing of Prolint.Rules.IRule":T, ruleClass), 0).
            currentRule = cast(currentClass:new(), Prolint.Rules.IRule) no-error.
            if error-status:error then            
                undo, throw new proparse.perror({&LINE-NUMBER}, error-status:get-message(1), error-status:get-number(1), 1).
            rulesCache:Put(ruleClass, currentRule).                 
        end.
        
        assign
            ruleId          = currentRule:RuleId
            severity        = currentRule:Severity
            ruleDescription = currentRule:RuleDescription.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static Prolint.Rules.IRule GetInstance( input ruleClass as character ):
        
        currentRule = cast(rulesCache:Get(ruleClass), Prolint.Rules.IRule).
        if not valid-object(currentRule) then        
        do:
            currentClass = Progress.Lang.Class:GetClass(ruleClass).
            if currentClass = ? then
                undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> cannot be found within PROPATH":T, ruleClass), 0).
            if not currentClass:IsA("Prolint.Rules.IRule":U) then            
                undo, throw new proparse.perror({&LINE-NUMBER}, substitute("<&1> is noy implementing of Prolint.Rules.IRule":T, ruleClass), 0).
            currentRule = cast(currentClass:new(), Prolint.Rules.IRule) no-error.
            if error-status:error then            
                undo, throw new proparse.perror({&LINE-NUMBER}, error-status:get-message(1), error-status:get-number(1), 1).
            rulesCache:Put(ruleClass, currentRule).                 
        end.

        return currentRule.

    end method.

end class.