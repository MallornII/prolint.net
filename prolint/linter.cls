 
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
    
    DEFINE PUBLIC PROPERTY CurrentProfile AS CHARACTER NO-UNDO 
        GET.
        PRIVATE SET. 

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
		
    CONSTRUCTOR PUBLIC linter ( INPUT iProfile AS CHARACTER ):
		
        CurrentProfile = iProfile.
        ErrorList = NEW OpenEdge.Core.Collections.List().
        LintRules = NEW OpenEdge.Core.Collections.List().
               
        LoadProfiles().     
        FIND FIRST ttProfile WHERE ttProfile.ProfileName = CurrentProfile NO-ERROR.
        IF NOT AVAILABLE(ttProfile) THEN
            UNDO, THROW NEW Progress.Lang.AppError(SUBSTITUTE("Profile <&1> doesn't exist", CurrentProfile)).
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
        
        vExt = ENTRY(NUM-ENTRIES(iFileName, "/"), iFileName).
        vExt = ENTRY(NUM-ENTRIES(vExt, "."), vExt).
        RETURN vExt.

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
	    
        vProfilesPath = SEARCH("profiles.xml").
        IF vProfilesPath = ? THEN
            UNDO, THROW NEW Progress.Lang.AppError("Can't find <profiles.xml>").
	       
        DATASET dsProfile:READ-XML( "FILE", vProfilesPath, "EMPTY", ?, FALSE).        	    
		
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
        DEFINE VARIABLE XrefFile AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cnt      AS INTEGER   NO-UNDO.

        EMPTY TEMP-TABLE ttCompileMessage.
        DATASET dsXref:EMPTY-DATASET().
        
        /* We can't compile it, so return TRUE */
        IF LOOKUP(GetFileExt(CurrentUnit), "p,w,cls":U) = 0 THEN
            RETURN TRUE.
        
        XrefFile = SUBSTITUTE("&1/xref.xml", TempDir).
        COMPILE VALUE(CurrentUnit) OPTIONS "require-full-names,require-field-qualifiers,require-full-keywords"
            SAVE = TRUE INTO TempDir
        XREF-XML XrefFile NO-ERROR.
     
        IF ERROR-STATUS:ERROR THEN       
            UNDO, THROW NEW proparse.perror({&LINE-NUMBER}, ERROR-STATUS:GET-MESSAGE(1), ERROR-STATUS:GET-NUMBER(1)).
      
        IF COMPILER:STOPPED THEN
            RETURN FALSE.   
       
        DO cnt = 1 TO COMPILER:NUM-MESSAGES:
            CREATE ttCompileMessage.
            ASSIGN
                ttCompileMessage.SourceFile   = proparse.api:MakePath(COMPILER:GET-FILE-NAME(cnt), ?)
                ttCompileMessage.Severity     = COMPILER:GET-MESSAGE-TYPE(cnt)
                ttCompileMessage.ErrorLine    = COMPILER:GET-ROW(cnt)
                ttCompileMessage.ErrorCode    = COMPILER:GET-NUMBER(cnt)
                ttCompileMessage.ErrorMessage = COMPILER:GET-MESSAGE(cnt).          
        END.
           
        DATASET dsXRef:READ-XML("FILE", XrefFile, "EMPTY", ?, FALSE).
        FOR EACH ttSource:
            ttSource.SourceFile = proparse.api:MakePath(ttSource.SourceFile, ?).
        END.       
         
        RETURN TRUE.        
  
    END METHOD.
  
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC LOGICAL Parse( INPUT iFileName AS CHARACTER ):
	    
        DEFINE VARIABLE rulesIter   AS OpenEdge.Core.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE curRule     AS prolint.rules.irule                 NO-UNDO.
        DEFINE VARIABLE parseResult AS LOGICAL                             NO-UNDO.
				
        CurrentUnit = proparse.api:MakePath(iFileName, ?).
        IF NOT CompileUnit() THEN
            RETURN FALSE.
                
        parseResult = proparse.api:Parse(iFileName,
            OUTPUT TABLE ttNode BIND,
            OUTPUT TABLE ttProUnit BIND).   
        IF NOT parseResult THEN
            RETURN FALSE.
            
        IF proparse.api:ErrorStatus() THEN
            RETURN FALSE.            
                                             
        rulesIter = LintRules:ListIterator().
        DO WHILE rulesIter:HasNext():		    
            curRule = CAST(rulesIter:Next(), prolint.rules.irule).
            curRule:ApplyRule(INPUT TABLE ttNode BIND).
        END.
        FIND FIRST ttResult NO-ERROR.
        IF AVAILABLE(ttResult) THEN
            TEMP-TABLE ttResult:WRITE-XML("FILE", "c:/temp/results.xml", TRUE, "utf-8") NO-ERROR.
            
        FIND FIRST ttCompileMessage NO-ERROR.
        IF AVAILABLE(ttCompileMessage) THEN
            TEMP-TABLE ttCompileMessage:WRITE-XML("FILE", "c:/temp/cmes.xml", TRUE, "utf-8") NO-ERROR.
        
        proparse.api:ReleaseNodes().
        RETURN TRUE.
		
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
        INPUT iRuleId   AS CHARACTER,
        INPUT iFileName AS CHARACTER,
        INPUT iLine     AS INTEGER,
        INPUT iSeverity AS INTEGER,
        INPUT iComment  AS CHARACTER
        ):
       
        CREATE ttResult.
        ASSIGN
            ttResult.RuleId     = iRuleId
            ttResult.Unit       = CurrentUnit
            ttResult.SourceFile = iFileName
            ttResult.LineNumber = iLine
            ttResult.Severity   = iSeverity
            ttResult.Comment    = iComment. 
		
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID SetDbSchema( INPUT iLoader AS proparse.ischemaloader ):
        
        IF NOT VALID-OBJECT(iLoader) THEN
            UNDO, THROW NEW Progress.Lang.AppError("Invalid schema loader instance").
        proparse.api:SchemaLoader = iLoader.
        proparse.api:ReadDbSchema().
        RETURN.

    END METHOD.

END CLASS.