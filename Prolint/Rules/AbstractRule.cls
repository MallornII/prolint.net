 
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

class Prolint.Rules.AbstractRule implements Prolint.Rules.IRule abstract:
    
    &SCOPED-DEFINE ACCESS_MOD protected
    &SCOPED-DEFINE REF_MOD    reference-only
    
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

    define public abstract property RuleDescription as character no-undo 
        get.     

    define public abstract property RuleId as character no-undo 
        get.        

    define public abstract property Severity as integer no-undo 
        get.
     

    /*------------------------------------------------------------------------------
     Purpose: Basic constructor
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor public AbstractRule ( ):
   	
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Return info about class. Should be overriden in actual class!
     Notes:
    ------------------------------------------------------------------------------*/
    
    method public static void GetInfo
        (
        output oRuleId      as character,
        output oSeverity    as integer,
        output oDescription as character        
        ):
        assign
            oRuleId      = "abstract"
            oSeverity    = -1
            oDescription = "You need to override this method in an actual class".                
    end method.
   

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
		
        PublishRuleResult:Publish(RuleId, iUnit, iFileName, iLine, 0, iComment).
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