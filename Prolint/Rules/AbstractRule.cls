 
/*------------------------------------------------------------------------
   File        : abstractrule
   Purpose     : Abstract class from which all actual rules should be derived
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 09.12.2018 15:45:47
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Prolint.Rules.AbstractRule  implements Prolint.Rules.IRule serializable abstract:
    
    &scoped-define ACCESS_MOD   protected
    &scoped-define REF_MOD      reference-only
    &scoped-define MIN_SEVERITY 1
    &scoped-define MAX_SEVERITY 99 
    
    
    {proparse/parsedata.i}
    {prolint/lintdata.i}    

    define public event PublishRuleResult  signature void 
        (
        input iRuleId   as character,
        input iUnit     as character,
        input iFileName as character,
        input iLine     as integer,
        input iSeverity as integer,
        input iComment  as character
        ).   

    define public property RuleDescription as character no-undo 
        get.
        protected set (input newValue as character):
            if newValue <> ? and newValue <> "" then
                RuleDescription = newValue.
        end set.  
     

    define public property RuleId as character no-undo 
        get.
        protected set (input newValue as character):
            if newValue <> ? and length(newValue) > 3 then
                RuleId = newValue.
        end set.

    define public property Severity as integer no-undo 
        get.
        set (input newValue as integer):
            if newValue >= {&MIN_SEVERITY} and newValue <= {&MAX_SEVERITY} then
                Severity = newValue.                
        end set.
          

    /*------------------------------------------------------------------------------
     Purpose: Basic constructor
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor public AbstractRule ( ):
        assign
            RuleDescription = "Auto generated description. Set value in child class!":T
            RuleId          = this-object:GetClass():TypeName
            Severity        = {&MIN_SEVERITY}.
    end constructor.
   
    /*------------------------------------------------------------------------------
     Purpose: Publish current's rule result
     Notes:
    ------------------------------------------------------------------------------*/

    method protected void PublishResult
        (
        input iUnit    as character,       
        input iFileName as character,
        input iLine as integer,     
        input iComment as character
        ):
		
        PublishRuleResult:Publish(RuleId, iUnit, iFileName, iLine, Severity, iComment).
        process events.
        return.

    end method.	
 
    method public abstract void Visit
        (
        input unitInst as Prolint.ILintUnit,
        input dataset dsProparse,       
        input dataset dsXref
        ).

end class.