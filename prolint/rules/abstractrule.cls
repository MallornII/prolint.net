 
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
    
    {proparse/jpnodes.i &ACCESS_MOD="PROTECTED" &REF_MOD="REFERENCE-ONLY"}
    
    DEFINE PROTECTED PROPERTY LintInstance AS prolint.linter NO-UNDO 
        GET.
        SET. 

    DEFINE PROTECTED PROPERTY ParseFile AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PUBLIC ABSTRACT PROPERTY RuleId AS CHARACTER NO-UNDO 
        GET.	 

    DEFINE PUBLIC ABSTRACT PROPERTY Severity AS INTEGER NO-UNDO 
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
		
        LintInstance:PublishResult(RuleId, iFileName, iLine, Severity, iComment).
        RETURN.

    END METHOD.	

END CLASS.