 
 /*------------------------------------------------------------------------
    File        : testrule
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sun Dec 09 15:46:45 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING com.joanju.proparse.ProParserTokenTypes.
USING com.joanju.proparse.NodeTypes.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS prolint.rules.testrule INHERITS prolint.rules.abstractrule: 
    
    DEFINE PRIVATE STATIC VARIABLE localId AS CHARACTER INITIAL "test" NO-UNDO. 
    
    DEFINE TEMP-TABLE ttSkipNodes NO-UNDO
        FIELD  NodeType AS INTEGER.
        
    DEFINE TEMP-TABLE ttAbbrev NO-UNDO
        FIELD AbbrevName AS CHARACTER
        FIELD FullName AS CHARACTER.

    DEFINE OVERRIDE PUBLIC PROPERTY RuleId AS CHARACTER NO-UNDO 
    GET():
        RETURN localId.
    END GET.
     

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	CONSTRUCTOR PUBLIC testrule
    (
        INPUT iFileName AS CHARACTER,
        INPUT iLintInstance AS prolint.linter
    ):        
		SUPER (iFileName, iLintInstance).
		AddSkipType(ProParserTokenTypes:Program_root).
		AddSkipType(ProParserTokenTypes:QSTRING).
		AddSkipType(ProParserTokenTypes:NUMBER).
		AddSkipType(ProParserTokenTypes:PERIOD).
		AddSkipType(ProParserTokenTypes:COMMA).
		AddSkipType(ProParserTokenTypes:LEXCOLON).
		AddSkipType(ProParserTokenTypes:OBJCOLON).
		AddSkipType(ProParserTokenTypes:LEFTPAREN).
		AddSkipType(ProParserTokenTypes:RIGHTPAREN).
		
		AddAbbrev("FILE-INFO", "FILE-INFO").
		AddAbbrev("COL", "COLUMNS").
	END CONSTRUCTOR.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PRIVATE VOID AddAbbrev
	(
	   INPUT iAbbrevName AS CHARACTER,
	   INPUT iFullName AS CHARACTER
   ):
		
		CREATE ttAbbrev.
		ASSIGN
            ttAbbrev.AbbrevName = iAbbrevName
            ttAbbrev.FullName = iFullName.
		RETURN.

	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PRIVATE VOID AddSkipType( INPUT iNodeType AS INTEGER ):
		
		CREATE ttSkipNodes.
		ttSkipNodes.NodeType = iNodeType.
		RETURN.

	END METHOD.

	METHOD OVERRIDE PUBLIC VOID ApplyRule( INPUT TABLE FOR ttNode BIND ):
		DEFINE VARIABLE unAbbrevName AS CHARACTER NO-UNDO.
		
		BLK_NODE:
		FOR EACH ttNode WHERE ttNode.NodeText <> "":
		    IF ttNode.NodeText = NodeTypes:getTypeName(ttNode.NodeType) THEN
		      NEXT.
		    IF CAN-FIND(FIRST ttSkipNodes WHERE ttSkipNodes.NodeType = ttNode.NodeType) THEN
                NEXT BLK_NODE.
            unAbbrevName = unAbbrev(ttNode.NodeText).
            IF unAbbrevName <> ? AND unAbbrevname <> ttNode.NodeText THEN
                PublishResult(ttNode.NodeFile, ttNode.NodeLine, SUBSTITUTE("Abbreviated &1 for &2":T, ttNode.NodeText, unAbbrevName)).
	    END.

	END METHOD.

    METHOD OVERRIDE PUBLIC STATIC VOID GetInfo        
    (
        OUTPUT oRuleId AS CHARACTER,
        OUTPUT oSeverity AS INTEGER,
        OUTPUT oDescription AS CHARACTER        
    ):
        ASSIGN
            oRuleId = localId
            oSeverity = 7
            oDescription = "Just a test rule".

    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PRIVATE CHARACTER UnAbbrev( INPUT iAbbrevName AS CHARACTER ):
		
        FIND FIRST ttAbbrev WHERE ttAbbrev.AbbrevName = iAbbrevName NO-ERROR.
        IF AVAILABLE(ttAbbrev) THEN
            RETURN ttAbbrev.FullName.
        ELSE  
            RETURN KEYWORD-ALL(iAbbrevName).

	END METHOD.

END CLASS.