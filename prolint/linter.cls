/*------------------------------------------------------------------------
   File        : linter
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Sun Dec 09 16:03:54 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS prolint.linter USE-WIDGET-POOL FINAL:
    
    &SCOPED-DEFINE ACCESS_MOD PRIVATE
    &SCOPED-DEFINE REF_MOD    REFERENCE-ONLY
    {proparse/jpnodes.i}
    {proparse/prounit.i}
    
    &UNDEFINE REF_MOD
    {prolint/compile.i}    
    {prolint/xref.i}
    {prolint/profile.i}
    
    DEFINE PRIVATE TEMP-TABLE ttResult NO-UNDO
        FIELD RuleId     AS CHARACTER
        FIELD Unit       AS CHARACTER
        FIELD SourceFile AS CHARACTER
        FIELD LineNumber AS INTEGER
        FIELD Severity   AS INTEGER
        FIELD Comment    AS CHARACTER.
    
    DEFINE PUBLIC EVENT PublishResult  SIGNATURE VOID 
        (
        INPUT iRuleId   AS CHARACTER,
        INPUT iFileName AS CHARACTER,
        INPUT iLine     AS INTEGER,
        INPUT iSeverity AS INTEGER,
        INPUT iComment  AS CHARACTER
        ).

    DEFINE PUBLIC EVENT PublishStatus  SIGNATURE VOID (INPUT iStatus AS CHARACTER).

    DEFINE PUBLIC PROPERTY CurrentProfile AS CHARACTER NO-UNDO 
        GET.
        PRIVATE SET. 

    DEFINE PRIVATE PROPERTY CurrentUnit AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE PROPERTY ErrorList AS OpenEdge.Core.Collections.List NO-UNDO 
        GET.
        SET. 
    
    DEFINE PUBLIC PROPERTY IsDebug AS LOGICAL NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE PROPERTY LintRules AS OpenEdge.Core.Collections.List NO-UNDO 
        GET.
        SET.

    DEFINE PRIVATE PROPERTY TempDir AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PUBLIC PROPERTY CompileWarningSeverity AS INTEGER INITIAL 3 NO-UNDO 
        GET.
        SET.
        
    DEFINE PUBLIC PROPERTY CompileErrorSeverity AS INTEGER INITIAL 9 NO-UNDO 
        GET.
        SET.  

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
		
    CONSTRUCTOR PUBLIC linter ( INPUT iProfile AS CHARACTER ):
		
        CurrentProfile = iProfile.
        ErrorList = NEW OpenEdge.Core.Collections.List().
        LintRules = NEW OpenEdge.Core.Collections.List().
        
        TempDir = proparse.api:MakePath(SESSION:TEMP-DIRECTORY, GUID(GENERATE-UUID)).        
        OS-CREATE-DIR VALUE(TempDir).
        IF OS-ERROR <> 0 THEN
            UNDO, THROW NEW proparse.perror({&LINE-NUMBER}, SUBSTITUTE("Can't create temp directory. OS error [&1]":T, OS-ERROR), OS-ERROR).
        proparse.api:TempDir = TempDir.        
               
        LoadProfiles().     
        FIND FIRST ttProfile WHERE ttProfile.ProfileName = CurrentProfile NO-ERROR.
        IF NOT AVAILABLE(ttProfile) THEN
            UNDO, THROW NEW Progress.Lang.AppError(SUBSTITUTE("Profile <&1> doesn't exist":T, CurrentProfile)).
        LoadRules().     
		
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID GetCompileMessages( OUTPUT TABLE ttCompileMessage BIND ):
        
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE CHARACTER GetFileExt( INPUT iFileName AS CHARACTER ):
        
        DEFINE VARIABLE vExt AS CHARACTER NO-UNDO.
        
        vExt = ENTRY(NUM-ENTRIES(iFileName, "/":U), iFileName, "/":U).
        vExt = ENTRY(NUM-ENTRIES(vExt, ".":U), vExt, ".":U).
        RETURN vExt.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE INTEGER GetMessageSeverity( INPUT iCode AS INTEGER ):
        DEFINE VARIABLE warnings AS INTEGER EXTENT 7 NO-UNDO.
        DEFINE VARIABLE cnt      AS INTEGER NO-UNDO.
        
        ASSIGN
            warnings[1] = 468 /* r-code exists but SAVE was not specified */
            warnings[2] = 4345 /* &MESSAGE output */
            warnings[3] = 6430 /* r-code exists but SAVE was not specified */
            warnings[4] = 14786 /* require-full-name */
            warnings[5] = 14789 /* require-field-qualifiers */
            warnings[6] = 18494 /* require-full-keywords */
            warnings[7] = 198. /* Could not understand line */
        
        DO cnt = 1 TO EXTENT(warnings):
            IF iCode = warnings[cnt] THEN
                RETURN 0.
        END.

        RETURN 1.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID GetProUnits( OUTPUT TABLE ttProUnit BIND ):
        
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID GetXref( OUTPUT DATASET dsXref BIND ):
        
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE VOID LoadProfiles(  ):
	    
        DEFINE VARIABLE vProfilesPath AS CHARACTER NO-UNDO.
	    
        vProfilesPath = SEARCH("profiles.xml":U).
        IF vProfilesPath = ? THEN
            UNDO, THROW NEW Progress.Lang.AppError("Can't find <profiles.xml>":T).
	       
        DATASET dsProfile:READ-XML("FILE":U, vProfilesPath, "EMPTY":U, ?, FALSE).        	    
		
        RETURN.

    END METHOD.	

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID LoadRules(  ):
        
        DEFINE VARIABLE curRule AS prolint.rules.irule NO-UNDO.
        
        RULE_BLK:
        FOR EACH ttRule WHERE ttRule.ProfileName = CurrentProfile:            
            curRule = DYNAMIC-NEW ttRule.RuleClass(CurrentUnit, THIS-OBJECT) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN
            DO:
                ErrorList:Add(NEW proparse.perror({&LINE-NUMBER}, ERROR-STATUS:GET-MESSAGE(1), ERROR-STATUS:GET-NUMBER(1), 1)).
                NEXT RULE_BLK. 
            END. 
            ELSE            
                LintRules:Add(curRule).                        
        END.              
        
        RETURN.

    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE LOGICAL CompileUnit(  ):
        DEFINE VARIABLE XrefFile        AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cnt             AS INTEGER   NO-UNDO.
        DEFINE VARIABLE messageSeverity AS INTEGER   NO-UNDO.

        EMPTY TEMP-TABLE ttCompileMessage.
        DATASET dsXref:EMPTY-DATASET().

        /* We can't compile it, so return TRUE */
        IF LOOKUP(GetFileExt(CurrentUnit), "p,w,cls":U) = 0 THEN
            RETURN TRUE.

        XrefFile = SUBSTITUTE("&1/xref.xml":U, TempDir).

        COMPILE VALUE(CurrentUnit) OPTIONS "require-full-names,require-field-qualifiers,require-full-keywords":U
            SAVE = TRUE INTO VALUE(TempDir)
        XREF-XML VALUE(XrefFile) NO-ERROR.         
       
        DO cnt = 1 TO COMPILER:NUM-MESSAGES:
            CREATE ttCompileMessage.
            ASSIGN
                ttCompileMessage.SourceFile   = proparse.api:MakePath(COMPILER:GET-FILE-NAME(cnt), ?)                
                ttCompileMessage.ErrorLine    = COMPILER:GET-ROW(cnt)
                ttCompileMessage.ErrorCode    = COMPILER:GET-NUMBER(cnt)
                ttCompileMessage.Severity     = GetMessageSeverity(ttCompileMessage.ErrorCode)
                ttCompileMessage.ErrorMessage = COMPILER:GET-MESSAGE(cnt).          
        END.
        
        FOR EACH ttCompileMessage:
            messageSeverity = (IF ttCompileMessage.Severity = 0 THEN CompileWarningSeverity ELSE CompileErrorSeverity).
            PublishResult("Compile":U, ttCompileMessage.SourceFile, ttCompileMessage.ErrorLine, messageSeverity, ttCompileMessage.ErrorMessage).
        END.
        
        IF IsDebug THEN
        DO:
            FIND FIRST ttCompileMessage NO-ERROR.
            IF AVAILABLE(ttCompileMessage) THEN
                TEMP-TABLE ttCompileMessage:WRITE-XML("FILE":U, SUBSTITUTE("&1./messages.xml":U, TempDir), TRUE, "utf-8":U) NO-ERROR.
        END.
        
        FIND FIRST ttCompileMessage WHERE ttCompileMessage.Severity > 0 NO-ERROR.
        IF AVAILABLE(ttCompileMessage) THEN
            RETURN FALSE.  
        
        IF SEARCH(XrefFile) <> ? THEN
        DO:
            DATASET dsXRef:READ-XML("FILE":U, XrefFile, "EMPTY":U, ?, FALSE).
            FOR EACH ttSource:
                ttSource.SourceFile = proparse.api:MakePath(ttSource.SourceFile, ?).
            END.
        END.       
         
        RETURN TRUE.        
  
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC prolint.lintresult EXTENT Lint( INPUT iFileList AS OpenEdge.Core.Collections.StringCollection ):
        DEFINE VARIABLE fileIterator AS OpenEdge.Core.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE resultSet    AS prolint.lintresult                  EXTENT NO-UNDO.
        DEFINE VARIABLE cnt          AS INTEGER                             NO-UNDO.
        
        EXTENT(resultSet) = iFileList:Size.
        fileIterator = iFileList:Iterator().
        
        DO WHILE fileIterator:HasNext():
            cnt = cnt + 1.
            resultSet[cnt] = Lint(fileIterator:Next():ToString()).
        END.
        
        RETURN resultSet.
    END METHOD.
  
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC prolint.lintresult Lint( INPUT iFileName AS CHARACTER ):
	    
        DEFINE VARIABLE rulesIter   AS OpenEdge.Core.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE curRule     AS prolint.rules.abstractrule          NO-UNDO.
        DEFINE VARIABLE parseResult AS LOGICAL                             NO-UNDO.        
        
        CurrentUnit = proparse.api:MakePath(iFileName, ?).
        PublishStatus:Publish(SUBSTITUTE("Linting &1":T, CurrentUnit)).
        IF NOT CompileUnit() THEN
            RETURN prolint.lintresult:COMPILE_ERROR.
        
        PublishStatus:Publish(SUBSTITUTE("Parsing &1":T, CurrentUnit)).
        parseResult = proparse.api:Parse(iFileName,
            OUTPUT TABLE ttNode BIND,
            OUTPUT TABLE ttProUnit BIND).   
        IF NOT parseResult THEN
            RETURN prolint.lintresult:PARSE_ERROR.
            
        IF proparse.api:ErrorStatus() THEN
            RETURN prolint.lintresult:PROPARSE_ERROR.            
                                             
        rulesIter = LintRules:ListIterator().
        DO WHILE rulesIter:HasNext():	    
            curRule = CAST(rulesIter:Next(), prolint.rules.abstractrule).
            PublishStatus:Publish(SUBSTITUTE("Applying rule &1":T, curRule:RuleId)).
            curRule:ApplyRule(INPUT TABLE ttNode BIND).
        END.
        
        IF IsDebug THEN
        DO:
            FIND FIRST ttResult NO-ERROR.
            IF AVAILABLE(ttResult) THEN
                TEMP-TABLE ttResult:WRITE-XML("FILE":U, SUBSTITUTE("&1./results.xml":U, TempDir), TRUE, "utf-8":U) NO-ERROR.
        END.        
        
        RETURN prolint.lintresult:LINT_OK.
		
        CATCH eErr AS Progress.Lang.Error :            
            ErrorList:Add(eErr).
            RETURN prolint.lintresult:UNKNOWN_ERROR.               
        END CATCH.
        
        FINALLY:
            PublishStatus:Publish(SUBSTITUTE("Finished &1":T, CurrentUnit)).
            proparse.api:ReleaseNodes().
        END FINALLY.

    END METHOD.	 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID PublishResult
        (
        INPUT iRuleId   AS CHARACTER,
        INPUT iFileName AS CHARACTER,
        INPUT iLine     AS INTEGER,
        INPUT iSeverity AS INTEGER,
        INPUT iComment  AS CHARACTER
        ):
            
        FIND FIRST ttRule WHERE ttRule.RuleId = iRuleId NO-ERROR.
        IF AVAILABLE(ttRule) THEN
            iSeverity = MIN(99, MAX(1, ttRule.Severity + iSeverity)).
       
        CREATE ttResult.
        ASSIGN
            ttResult.RuleId     = iRuleId
            ttResult.Unit       = CurrentUnit
            ttResult.SourceFile = iFileName
            ttResult.LineNumber = iLine
            ttResult.Severity   = iSeverity
            ttResult.Comment    = iComment.        
            
        PublishResult:Publish(iRuleId, iFileName, iLine, iSeverity, iComment).
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID SetDbSchema( INPUT iLoader AS proparse.ischemaloader ):
        
        IF NOT VALID-OBJECT(iLoader) THEN
            UNDO, THROW NEW Progress.Lang.AppError("Invalid schema loader instance":T).
        proparse.api:SchemaLoader = iLoader.
        proparse.api:ReadDbSchema().
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    DESTRUCTOR PUBLIC linter ( ):
        IF NOT IsDebug THEN 
            OS-DELETE VALUE(TempDir) RECURSIVE.
    END DESTRUCTOR.

END CLASS.