 
/*------------------------------------------------------------------------
   File        : abstractrule
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Sun Dec 09 15:45:47 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS prolint.rules.abstractrule IMPLEMENTS prolint.rules.irule ABSTRACT:
    
    &SCOPED-DEFINE ACCESS_MOD PROTECTED
    &SCOPED-DEFINE REF_MOD    REFERENCE-ONLY
    
    {proparse/jpnodes.i}     
    {prolint/xref.i}
    {prolint/compile.i}

    DEFINE PROTECTED PROPERTY LintInstance AS prolint.linter NO-UNDO 
        GET.
        SET. 

    DEFINE PROTECTED PROPERTY ParseFile AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PROTECTED ABSTRACT PROPERTY RuleId AS CHARACTER NO-UNDO 
        GET.

    /*------------------------------------------------------------------------------
     Purpose:
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
	

    METHOD PUBLIC ABSTRACT VOID ApplyRule( TABLE ttNode BIND  ).

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PROTECTED VOID PublishResult
        (       
        INPUT iFileName AS CHARACTER,
        INPUT iLine AS INTEGER,     
        INPUT iComment AS CHARACTER
        ):
		
        LintInstance:PublishResult(RuleId, iFileName, iLine, 0, iComment).
        RETURN.

    END METHOD.	

END CLASS.