 
 /*------------------------------------------------------------------------
    File        : linter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Dec 09 16:03:54 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS prolint.linter USE-WIDGET-POOL FINAL:
    
    {proparse/jpnodes.i &ACCESS_MOD="PRIVATE" &REF_MOD="REFERENCE-ONLY"}
    
    DEFINE PRIVATE TEMP-TABLE ttResult NO-UNDO
        FIELD RuleId AS CHARACTER
        FIELD Unit AS CHARACTER
        FIELD SourceFile AS CHARACTER
        FIELD LineNumber AS INTEGER
        FIELD Severity AS INTEGER
        FIELD Comment AS CHARACTER. 
    
    DEFINE PRIVATE STREAM sRules.
    
	DEFINE PRIVATE PROPERTY CurrentUnit AS CHARACTER NO-UNDO 
	GET.
	SET. 

    DEFINE PRIVATE PROPERTY ErrorList AS OpenEdge.Core.Collections.List NO-UNDO 
        GET.
        SET. 
    
	DEFINE PRIVATE PROPERTY LintRules AS OpenEdge.Core.Collections.List NO-UNDO 
	GET.
	SET.

    DEFINE PRIVATE PROPERTY TempDir AS CHARACTER NO-UNDO 
    GET.
    SET. 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	CONSTRUCTOR PUBLIC linter (  ):
		
		ErrorList = NEW OpenEdge.Core.Collections.List().
		LintRules = NEW OpenEdge.Core.Collections.List().
		LoadRules().
		
	END CONSTRUCTOR.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC VOID LoadRules(  ):
	    
	    DEFINE VARIABLE ruleName AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE curRule AS prolint.rules.irule NO-UNDO.
	    
	    INPUT STREAM sRules FROM VALUE("rules.d").
	    RULE_BLK:
	    REPEAT:
            IMPORT STREAM sRules ruleName.            
            curRule = DYNAMIC-NEW ruleName(CurrentUnit, THIS-OBJECT) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN
            DO:
                ErrorList:Add(NEW proparse.perror({&LINE-NUMBER}, ERROR-STATUS:GET-MESSAGE(1), ERROR-STATUS:GET-NUMBER(1), 1)).
                NEXT RULE_BLK. 
            END. 
            ELSE
                LintRules:Add(curRule).            
	    END.
	    INPUT STREAM sRules CLOSE.	    
		
		RETURN.

	END METHOD.	

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC LOGICAL Parse( INPUT iFileName AS CHARACTER ):
	    
	    DEFINE VARIABLE rulesIter AS OpenEdge.Core.Collections.IIterator NO-UNDO.
	    DEFINE VARIABLE curRule AS prolint.rules.irule NO-UNDO.
	    DEFINE VARIABLE parseResult AS LOGICAL NO-UNDO.
				
		CurrentUnit = iFileName.
		parseResult = proparse.api:Parse(iFileName, OUTPUT TABLE ttNode BIND ).
		rulesIter = LintRules:ListIterator().
		DO WHILE rulesIter:HasNext():		    
		    curRule = CAST(rulesIter:Next(), prolint.rules.irule).
		    curRule:ApplyRule(INPUT TABLE ttNode BIND).
	    END.
		
		TEMP-TABLE ttResult:WRITE-XML("FILE", "c:/temp/results.xml", TRUE,  "utf-8").
		RETURN parseResult.
		
		CATCH eErr AS Progress.Lang.Error :
            ErrorList:Add(eErr).
            RETURN FALSE.                
        END CATCH.

	END METHOD.	 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC VOID PublishResult
	(
	   INPUT iRuleId AS CHARACTER,
	   INPUT iFileName AS CHARACTER,
	   INPUT iLine AS INTEGER,
	   INPUT iSeverity AS INTEGER,
	   INPUT iComment AS CHARACTER
    ):
       
        CREATE ttResult.
        ASSIGN
            ttResult.RuleId = iRuleId
            ttResult.Unit = CurrentUnit
            ttResult.SourceFile = iFileName
            ttResult.LineNumber = iLine
            ttResult.Severity = iSeverity
            ttResult.Comment = iComment. 
		
        RETURN.

	END METHOD.

END CLASS.