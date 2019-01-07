/*------------------------------------------------------------------------
   File        : Linter
   Purpose     : Main class for linting files
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 09.12.2018 16:03:54
   Notes       : 
 ----------------------------------------------------------------------*/

block-level on error undo, throw.

using Utils.IO.

class Prolint.Linter use-widget-pool final implements Prolint.IDisposable:
    
    &SCOPED-DEFINE ACCESS_MOD PRIVATE
    &SCOPED-DEFINE REF_MOD    REFERENCE-ONLY
    {prolint/compile.i}    
    {prolint/xref.i}
    {proparse/jpnodes.i}
    {proparse/prounit.i}
    
    &UNDEFINE REF_MOD
    {prolint/profile.i}
    {prolint/results.i}
    
    /*------------------------------------------------------------------------------
     Purpose: Publishes result of linting
     Notes:
    ------------------------------------------------------------------------------*/  
    
    define public event PublishResult  signature void 
        (
        input iRuleId   as character,
        input iUnit     as character,
        input iFileName as character,
        input iLine     as integer,
        input iSeverity as integer,
        input iComment  as character
        ).

    /*------------------------------------------------------------------------------
     Purpose: Publishes current job status
     Notes:
    ------------------------------------------------------------------------------*/
    
    define public event PublishStatus  signature void
        (
        input iUnit as character,
        input iStatus as character
        ).

    define public property CurrentProfile as character no-undo 
        get.
        private set. 

    define private property CurrentUnit as Prolint.ILintUnit no-undo 
        get.
        set. 

    define private property ErrorList as OpenEdge.Core.Collections.List no-undo 
        get.
        set. 
        
    /* If set true will save temp-tables into TempDir in XML format and will not delete TempDir */ 
    define public property IsDebug as logical no-undo 
        get.
        set. 

    define private property LintCompiler as Prolint.UnitCompiler no-undo 
        get.
        set. 

    define private property LintDataDebugger as Prolint.UnitDebugData no-undo 
        get.
        set. 

    define private property LintRules as OpenEdge.Core.Collections.List no-undo 
        get.
        set.

    define private property TempDir as character no-undo 
        get.
        set. 



    define public property UnitClass as Progress.Lang.Class no-undo 
        get.
        set (input newClass as Progress.Lang.Class):
            if newClass:IsA("Prolint.ILintUnit":u) and not newClass:IsAbstract() then
                UnitClass = newClass.
        end set. 

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor public linter ( input profileName as character ):
		
        assign
            CurrentProfile   = profileName
            ErrorList        = new OpenEdge.Core.Collections.List()
            LintRules        = new OpenEdge.Core.Collections.List()
            UnitClass        = Progress.Lang.Class:GetClass("Prolint.SimpleLintUnit":u)
            LintDataDebugger = new Prolint.UnitDebugData()
            LintCompiler     = new Prolint.UnitCompiler()        
            TempDir          = IO:MakePath(session:temp-directory, guid(generate-uuid)).
        
        LintCompiler:PublishRuleResult:Subscribe(PublishRuleResult).
        os-create-dir value(TempDir).
        if os-error <> 0 then
            undo, throw new proparse.perror({&LINE-NUMBER}, substitute("Can't create temp directory. OS error [&1]":t, os-error), os-error).
        
        assign
            Proparse.Wrapper:TempDir = TempDir
            LintDataDebugger:TempDir = TempDir
            LintCompiler:TempDir     = TempDir.
        LoadProfiles().     
        find first ttProfile where ttProfile.ProfileName = CurrentProfile no-error.
        if not available(ttProfile) then
            undo, throw new Progress.Lang.AppError(substitute("Profile <&1> doesn't exist":t, CurrentProfile), 0).
        LoadRules().     
		
    end constructor.

    /*------------------------------------------------------------------------------
     Purpose: Release Java resources
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Dispose(  ):
        
        Proparse.Wrapper:ReleaseNodes().
        delete object this-object no-error.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Returns IIterator class with errors that were raised during class' work
     Notes: Use ErrorStatus() method to determine whenever there were any errors
    ------------------------------------------------------------------------------*/

    method public final OpenEdge.Core.Collections.IListIterator GetErrors(  ):

        return ErrorList:ListIterator().

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Return TRUE if there errors during class' work
     Notes: 
    ------------------------------------------------------------------------------*/

    method public logical ErrorStatus(  ):
        
        return not ErrorList:IsEmpty().

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void LoadProfiles(  ):
	    
        define variable profilesPath as character no-undo.
	    
        profilesPath = search("profiles.xml":u).
        if profilesPath = ? then
            undo, throw new Progress.Lang.AppError("Can't find <profiles.xml>":t).
	       
        dataset dsProfile:read-xml("FILE":U, profilesPath, "EMPTY":u, ?, false).        	    
		
        return.

    end method.	

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    method private void LoadRules(  ):
                
        define variable currentRule as prolint.rules.abstractrule no-undo.        
       
        RULE_BLK:
        for each ttRule where ttRule.ProfileName = CurrentProfile:          
            LintRules:Add(Prolint.Rules.Factory:GetInstance(CurrentProfile, ttRule.RuleClass)).
          
            catch e as Progress.Lang.Error:                
                ErrorList:Add(e). 
            end catch.                                    
        end.              
        
        return.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Lints all files in collection
     Notes:
    ------------------------------------------------------------------------------*/

    method public Prolint.LintResult extent Lint( input fileList as OpenEdge.Core.Collections.StringCollection ):
        define variable fileIterator as OpenEdge.Core.Collections.IIterator no-undo.
        define variable resultSet    as prolint.lintresult                  extent no-undo.
        define variable cnt          as integer                             no-undo.
        
        extent(resultSet) = fileList:Size.
        fileIterator = fileList:Iterator().
        
        do while fileIterator:HasNext():
            cnt = cnt + 1.
            resultSet[cnt] = Lint(fileIterator:Next():ToString()).
        end.
        
        return resultSet.
    end method.
  
    /*------------------------------------------------------------------------------
     Purpose: Lints one file
     Notes:
    ------------------------------------------------------------------------------*/

    method public Prolint.LintResult Lint( input lintFile as character ):
	    
        define variable rulesIteartor as OpenEdge.Core.Collections.IIterator no-undo.
        define variable currentRule   as prolint.rules.irule                 no-undo.        
        define variable parseResult   as logical                             no-undo.
        
        CurrentUnit = cast(UnitClass:New(), Prolint.ILintUnit).
        assign                    
            CurrentUnit:CompileUnit = IO:MakePath(lintFile)
            CurrentUnit:IsDebug = IsDebug.            
        
        PublishStatus:Publish("Linting...":t, CurrentUnit:CompileUnit).        
        process events.
        
        CurrentUnit:Accept(LintCompiler).        
        if not currentUnit:IsCompiled then
            return prolint.lintresult:COMPILE_ERROR.
        
        PublishStatus:Publish("Parsing":t, CurrentUnit:CompileUnit).
        process events.
       
        if not Proparse.Wrapper:Parse(CurrentUnit) then
        do:
            PullErrors().
            return Prolint.LintResult:PARSE_ERROR.
        end.
        
        CurrentUnit:Accept(LintDataDebugger).    
            
        if Proparse.Wrapper:ErrorStatus() then
            return Prolint.LintResult:PROPARSE_ERROR.
                                             
        rulesIteartor = LintRules:ListIterator().
        do while rulesIteartor:HasNext():            	    
            currentRule = cast(rulesIteartor:Next(), Prolint.Rules.IRule).                      
            PublishStatus:Publish(substitute("Applying rule &1":t, currentRule:RuleId), CurrentUnit:CompileUnit).
            process events.
            currentRule:PublishRuleResult:Subscribe(PublishRuleResult).
            CurrentUnit:Accept(currentRule).            
        end.
        
        return Prolint.LintResult:LINT_OK.
		
        catch e as Progress.Lang.Error :            
            ErrorList:Add(e).
            return Prolint.LintResult:UNKNOWN_ERROR.               
        end catch.
        
        finally:
            PublishStatus:Publish("Finished":t, CurrentUnit:CompileUnit).
            Proparse.Wrapper:ReleaseNodes().
            if valid-object(CurrentUnit) then
                delete object CurrentUnit.
        end finally.

    end method.	 

    /*------------------------------------------------------------------------------
     Purpose: 
     Notes:
    ------------------------------------------------------------------------------*/

    method private void PublishRuleResult
        (
        input ruleId     as character,
        input unit       as character,
        input sourceFile as character,
        input lineNumber as integer,
        input severity   as integer,
        input comment    as character
        ):
            
        find first ttRule where ttRule.RuleId = ruleId no-error.
        if available(ttRule) then
            severity = MIN(99, MAX(1, ttRule.Severity + severity)).
       
        create ttResult.
        assign
            ttResult.RuleId     = ruleId
            ttResult.Unit       = CurrentUnit:CompileUnit
            ttResult.SourceFile = sourceFile
            ttResult.LineNumber = lineNumber
            ttResult.Severity   = severity
            ttResult.Comment    = comment.        
            
        PublishResult:Publish(ruleId, CurrentUnit:CompileUnit, sourceFile, lineNumber, severity, comment).
        process events.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void PullErrors(  ):
        
        define variable errorIterator as OpenEdge.Core.Collections.IIterator no-undo.
        
        if Proparse.Wrapper:ErrorStatus() then
        do:
            errorIterator = Proparse.Wrapper:GetErrors().
            do while errorIterator:HasNext():
                ErrorList:Add(errorIterator:Next()).
            end.
        end.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Set's class for reading Db schema
     Notes:
    ------------------------------------------------------------------------------*/

    method public void SetDbSchema( input dbSchema as Proparse.IDbSchema ):
        
        if not valid-object(dbSchema) then
            undo, throw new Progress.Lang.AppError("Invalid IDBSchema instance":t).
        Proparse.Wrapper:DbSchema = dbSchema.
        Proparse.Wrapper:ReadDbSchema().
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    destructor public Linter ( ):
        if not IsDebug then 
            os-delete value(TempDir) recursive.
    end destructor.

end class.