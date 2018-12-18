 
/*------------------------------------------------------------------------
   File        : abstractrule
   Purpose     : Abstract class from which all actual rules should be derived
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 09.12.2018 15:45:47
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS prolint.rules.abstractrule IMPLEMENTS prolint.rules.irule ABSTRACT:
    
    &SCOPED-DEFINE ACCESS_MOD PROTECTED
    &SCOPED-DEFINE REF_MOD    REFERENCE-ONLY
    
    {proparse/jpnodes.i}     
    {prolint/xref.i}
    {prolint/compile.i}

    DEFINE PUBLIC EVENT PublishRuleResult  SIGNATURE VOID 
    (
        INPUT iRuleId   AS CHARACTER,
        INPUT iFileName AS CHARACTER,
        INPUT iLine     AS INTEGER,
        INPUT iSeverity AS INTEGER,
        INPUT iComment  AS CHARACTER
    ).

    DEFINE PROTECTED PROPERTY LintInstance AS prolint.linter NO-UNDO 
        GET.
        SET. 

    DEFINE PROTECTED PROPERTY ParseFile AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PUBLIC ABSTRACT PROPERTY RuleId AS CHARACTER NO-UNDO 
        GET.        

    /*------------------------------------------------------------------------------
     Purpose: Basic constructor
     Notes:
    ------------------------------------------------------------------------------*/
		
    CONSTRUCTOR PUBLIC abstractrule
        (
        INPUT iFileName AS CHARACTER,
        INPUT iLintInstance AS prolint.linter
        ):
        ASSIGN
            ParseFile    = iFileName
            LintInstance = iLintInstance.		
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Return info about class. Should be overriden in actual class!
     Notes:
    ------------------------------------------------------------------------------*/
    
    METHOD PUBLIC STATIC VOID GetInfo
    (
        OUTPUT oRuleId      AS CHARACTER,
        OUTPUT oSeverity    AS INTEGER,
        OUTPUT oDescription AS CHARACTER        
    ):
        ASSIGN
            oRuleId = "abstract"
            oSeverity = -1
            oDescription = "You need to override this method in an actual class".                
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Runs rule's main code
     Notes:
    ------------------------------------------------------------------------------*/
	

    METHOD PUBLIC ABSTRACT VOID ApplyRule( TABLE ttNode BIND  ).

    /*------------------------------------------------------------------------------
     Purpose: Publish current's rule result
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PROTECTED VOID PublishResult
        (       
        INPUT iFileName AS CHARACTER,
        INPUT iLine AS INTEGER,     
        INPUT iComment AS CHARACTER
        ):
		
        PublishRuleResult:Publish(RuleId, iFileName, iLine, 0, iComment).
        PROCESS EVENTS.
        RETURN.

    END METHOD.	

END CLASS.