 
/*------------------------------------------------------------------------
   File        : treebuilder
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Fri Dec 21 23:21:12 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

using proparse.iparser.
using com.joanju.proparse.ProParserTokenTypes.
using org.prorefactor.core.JPNode.

block-level on error undo, throw.

class Proparse.TreeBuilder implements Proparse.IParser final: 
    
    &SCOPED-DEFINE ACCESS_MOD private
    &SCOPED-DEFINE REF_MOD    reference-only
    {proparse/parsedata.i}
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public treebuilder ( ):
        super ().
        
    end constructor.

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsproparse              
    ):
        
        define variable cnt        as integer                     no-undo.
        define variable curNode    as org.prorefactor.core.JPNode no-undo.
        define variable parentNode as org.prorefactor.core.JPNode no-undo.
        define variable childNode  as org.prorefactor.core.JPNode no-undo.
        define variable nextNode   as org.prorefactor.core.JPNode no-undo.
        define variable prevNode   as org.prorefactor.core.JPNode no-undo.
        define variable nodeArray  as java.util.ArrayList         no-undo.        
       
        nodeArray = org.prorefactor.core.TreeUtils:flatList(currentUnit:topNode).        
        
        do cnt = 0 to nodeArray:size() - 1:
            create ttNode.
            assign
                curNode         = cast(nodeArray:get(cnt), JPNode)
                parentNode      = curNode:parent()
                childNode       = curNode:firstChild()
                nextNode        = curNode:nextNode()
                prevNode        = curNode:prevNode()                
                ttNode.NodeType = curNode:getType().
            
            assign                
                ttNode.NodeNum     = curNode:getNodeNum()
                ttNode.NodeFile    = Proparse.Wrapper:MakePath(curNode:getFilename(), ?)
                ttNode.NodeLine    = curNode:getLine()
                ttNode.NodeColumn  = curNode:getColumn()
                ttNode.NodeText    = curNode:getText()
                when ttNode.NodeType <> ProParserTokenTypes:PROPARSEDIRECTIVE
                ttNode.NodeText    = curNode:attrGetS("proparsedirective":U)
                when ttNode.NodeType = ProParserTokenTypes:PROPARSEDIRECTIVE                
                ttNode.IsStateHead = curNode:isStateHead()
                ttNode.StoreType   = curNode:attrGetS("storetype":U)                        
                ttNode.ParentNum   = parentNode:getNodeNum()                 
                when valid-object(parentNode)
                ttNode.FirstChild  = childNode:getNodeNum()                 
                when valid-object(childNode)
                ttNode.NextSibling = nextNode:getNodeNum()                 
                when valid-object(nextNode)
                ttNode.PrevSibling = prevNode:getNodeNum()                 
                when valid-object(prevNode).
        end.
        /* implicit delete */
        nodeArray = ?.
        currentUnit:TopNode = ?.        
        return.

    end method.

end class.