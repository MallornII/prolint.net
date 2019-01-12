 
 /*------------------------------------------------------------------------
    File        : UnitCompiler
    Purpose     : Class for cimpiling procedures and classes
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 22.12.2018 21:22:44
    Notes       : 
  ----------------------------------------------------------------------*/

using Prolint.IUnitWorker.
using Utils.IO.

block-level on error undo, throw.

class Prolint.UnitCompiler implements IUnitWorker:
    
    &SCOPED-DEFINE ACCESS_MOD private
    &SCOPED-DEFINE REF_MOD    reference-only
    
    {proparse/parsedata.i}
    {prolint/lintdata.i}
    
    /*------------------------------------------------------------------------------
     Purpose: Publishes result of compiling
     Notes:
    ------------------------------------------------------------------------------*/
    
    define public event PublishRuleResult  signature void
    (   
        input iRuleId   as character,
        input iUnit     as character,
        input iFileName as character,
        input iLine     as integer,
        input iSeverity as integer,
        input iComment  as character
    ).  

    define private variable compilerOptions as character no-undo.

    define public property TempDir as character no-undo 
    get.
    set. 
    
    define public property CompileWarningSeverity as integer initial 3 no-undo 
        get.
        set.
        
    define public property CompileErrorSeverity as integer initial 9 no-undo 
        get.
        set.  

    define public property UseStrictOptions as logical no-undo 
    get.
    set(input strictOptions as logical):
        UseStrictOptions = strictOptions.
        if strictOptions then
            compilerOptions = "require-full-names,require-field-qualifiers,require-full-keywords":U.
        else
            compilerOptions = "".
    end set. 
    
    /*------------------------------------------------------------------------------
     Purpose: Start method for visiting ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsProparse,
       input dataset dsXref
    ):
        
        define variable XrefFile        as character no-undo.
        define variable cnt             as integer   no-undo.
        define variable messageSeverity as integer   no-undo.       
        define variable hasErrors       as logical   no-undo.                 

        /* We can't compile it, so return TRUE */
        if lookup(Utils.IO:GetFileExt(CurrentUnit:CompileUnit), "p,w,cls":U) = 0 then
        do:
            currentUnit:IsCompiled = true.
            return.
        end.
        
        XrefFile = substitute("&1/xref.xml":U, TempDir).

        compile value(CurrentUnit:CompileUnit) options compilerOptions
            save into value(TempDir)
        xref-xml value(XrefFile) no-error.         
     
        do cnt = 1 to compiler:num-messages:
            assign
                messageSeverity = GetMessageSeverity(compiler:get-number(cnt))
                hasErrors = hasErrors or (messageSeverity = CompileErrorSeverity).            
            currentUnit:AddResult("Compile":U, compiler:get-file-name(cnt), compiler:get-row(cnt), messageSeverity, compiler:get-message(cnt)).                      
        end.
        
        if hasErrors then
            return.
        
        if search(XrefFile) <> ? then
        do:
            dataset dsXRef:read-xml("FILE":U, XrefFile, "EMPTY":U, ?, false).
            for each ttSource:
                ttSource.SourceFile = IO:MakePath(ttSource.SourceFile).
            end.
        end.       
         
        currentUnit:IsCompiled = true.
        return.  

    end method.    
    
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private integer GetMessageSeverity( input messageCode as integer ):
        define variable warnings as integer extent 7 no-undo.
        define variable cnt      as integer no-undo.
        
        assign
            warnings[1] = 468 /* r-code exists but SAVE was not specified */
            warnings[2] = 4345 /* &MESSAGE output */
            warnings[3] = 6430 /* r-code exists but SAVE was not specified */
            warnings[4] = 14786 /* require-full-name */
            warnings[5] = 14789 /* require-field-qualifiers */
            warnings[6] = 18494 /* require-full-keywords */
            warnings[7] = 198. /* Could not understand line */
        
        do cnt = 1 to extent(warnings):
            if messageCode = warnings[cnt] then
                return CompileWarningSeverity.
        end.

        return CompileErrorSeverity.

    end method.

end class.