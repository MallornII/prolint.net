 
 /*------------------------------------------------------------------------
    File        : SimpleLintUnit
    Purpose     : Simle class that hold information about current Lint process
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 21.12.2018 23:13:48
    Notes       : 
  ----------------------------------------------------------------------*/

using Prolint.ILintUnit.
using Prolint.LintResult.
using Utils.IO.
using com.joanju.proparse.ProParserTokenTypes.

block-level on error undo, throw.

class Prolint.SimpleLintUnit implements Prolint.ILintUnit:
    
    &SCOPED-DEFINE ACCESS_MOD PROTECTED
    
    {proparse/parsedata.i}
    {prolint/lintdata.i}    
    
    define protected variable sequenceId as integer no-undo. 

    define public event PublishResult  signature void (input ruleId as character, input attrs as character, input compileUnit as character, input sourceFile as character, input lineNumber as integer, input severity as integer, input comment as character).

    define public property CompileUnit as character no-undo 
    get.
    set. 

    define public property IsCompiled as logical no-undo 
    get.
    set.     

    define public property IsDebug as logical no-undo 
    get.
    set.     

    define public property isResultsPublished as logical initial true no-undo 
    get.

    define public property LintStatus as LintResult no-undo 
    get.
    set.     

    define public property topNode as org.prorefactor.core.JPNode no-undo 
    get.
    set.

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public SimpleLintUnit (  ):
        super ().
        LintStatus = LintResult:LINT_NONE.
        
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Accepts IRule visitor
     Notes:
    ------------------------------------------------------------------------------*/     

    method public void Accept( input currentRule as Prolint.Rules.IRule ):
        
        currentRule:Visit(this-object, dataset dsProparse by-reference, dataset dsXref by-reference ).

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Accepts IParser visitor
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Accept( input currentParser as Proparse.IParser ):
        
        currentParser:Visit(this-object, dataset dsProparse by-reference ).

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Accepts IUnitWorker visitor
     Notes:
    ------------------------------------------------------------------------------*/
    
    method public void Accept( input currentWorker as Prolint.IUnitWorker ):
        
        currentWorker:Visit(this-object, dataset dsProparse by-reference, dataset dsXref by-reference ).

    end method.
    
    method public void AddResult
    (
        input ruleId as character,
        input sourceFile as character,
        input lineNumber as integer,
        input severity as integer,
        input comment as character
    ):
        
        create ttResult.       
        assign
            ttResult.RuleId     = ruleId
            ttResult.Unit       = CompileUnit
            ttResult.SourceFile = IO:MakePath(sourceFile)
            ttResult.LineNumber = lineNumber
            ttResult.Severity   = min(99, max(1, severity)).
            ttResult.Comment    = comment.
            
        PublishResult:publish(ruleId, ttResult.Attrs, CompileUnit, ttResult.SourceFile, lineNumber, severity, comment).
        process events. 

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Return node's parent num
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetParentNum( input nodeNum as integer ):
        
        define buffer ttNode for ttNode.
        find first ttNode where ttNode.NodeNum = nodeNum no-error.
        if available(ttNode) then        
            return ttNode.ParentNum.
        else
            return 0.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Return node's parent type
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetParentType( input nodeNum as integer ):
        
        define buffer ttNode for ttNode.
        find first ttNode where ttNode.NodeNum = GetParentNum(nodeNum) no-error.
        if available(ttNode) then        
            return ttNode.NodeType.
        else
            return 0.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Returns NodeNum that is a statement head for given node
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetStateHead( input iNodeNum as integer ):
        
        define buffer ttNode for ttNode.
        find first ttNode where ttNode.NodeNum = iNodeNum.        
        do while ttNode.IsStateHead = false:
            iNodeNum = ttNode.ParentNum.
            find first ttNode where ttNode.NodeNum = iNodeNum.
        end.
        
        return ttNode.NodeNum.
        
        catch e as Progress.Lang.Error:
            log-manager:write-message(e:CallStack).
            log-manager:write-message(e:GetMessage(1)).            
            return ?.                
        end catch.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Returns NodeType for node that is a statement head for given node
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetStateHeadType( input iNodeNum as integer ):
        
        define buffer ttNode for ttNode.
        define variable headNode as integer no-undo.
        
        headNode = GetStateHead(iNodeNum).
        if headNode = ? then
            return ProParserTokenTypes:Program_root.
        else
        do:
            find first ttNode where ttNode.NodeNum = headNode.
            return ttNode.NodeType.
        end.
        
        catch e as Progress.Lang.Error :
            log-manager:write-message(e:CallStack).
            log-manager:write-message(e:GetMessage(1)).            
            return ProParserTokenTypes:Program_root.                
        end catch. 

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Return next sequence ID. Acts like NEXT-VALUE function
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer NextSequenceId(  ):
        
        sequenceId = sequenceId + 1.
        return sequenceId.

    end method.

end class.