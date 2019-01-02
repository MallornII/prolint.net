 
 /*------------------------------------------------------------------------
    File        : simplelintunit
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Fri Dec 21 23:13:48 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Prolint.ILintUnit.
using com.joanju.proparse.ProParserTokenTypes.

block-level on error undo, throw.

class Prolint.SimpleLintUnit implements Prolint.ILintUnit:
    
    &SCOPED-DEFINE ACCESS_MOD PROTECTED
    
    {proparse/parsedata.i}
    {prolint/lintdata.i}
    
    define protected variable sequenceId as integer no-undo. 

    define public property CompileUnit as character no-undo 
    get.
    set. 

    define public property IsCompiled as logical no-undo 
    get.
    set.     

    define public property IsDebug as logical no-undo 
    get.
    set.     

    define public property topNode as org.prorefactor.core.JPNode no-undo 
    get.
    set.     

    method public void Accept( input currentRule as Prolint.Rules.IRule ):
        
        currentRule:Visit(this-object, dataset dsProparse by-reference, dataset dsXref by-reference ).

    end method.

    method public void Accept( input currentParser as Proparse.IParser ):
        
        currentParser:Visit(this-object, dataset dsProparse by-reference ).

    end method.
    
    method public void Accept( input currentWorker as Prolint.IUnitWorker ):
        
        currentWorker:Visit(this-object, dataset dsProparse by-reference, dataset dsXref by-reference ).

    end method.

    method public integer GetParentNum( input nodeNum as integer ):
        
        define buffer ttNode for ttNode.
        find first ttNode where ttNode.NodeNum = nodeNum no-error.
        if available(ttNode) then        
            return ttNode.ParentNum.
        else
            return 0.

    end method.

    method public integer GetParentType( input nodeNum as integer ):
        
        define buffer ttNode for ttNode.
        find first ttNode where ttNode.NodeNum = GetParentNum(nodeNum) no-error.
        if available(ttNode) then        
            return ttNode.NodeType.
        else
            return 0.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Returns JPNode that is a statement head for given node
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
        
        catch eErr as Progress.Lang.Error :            
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
        
        catch eErr as Progress.Lang.Error :            
            return ProParserTokenTypes:Program_root.                
        end catch. 

    end method.

    method public integer NextSequenceId(  ):
        
        sequenceId = sequenceId + 1.
        return sequenceId.

    end method.

end class.