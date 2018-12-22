 
 /*------------------------------------------------------------------------
    File        : CodeBlocksParser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Sat Dec 22 15:42:43 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.IParser.

block-level on error undo, throw.

class Proparse.CodeBlocksParser implements IParser final:
    
    &SCOPED-DEFINE ACCESS_MOD private
    &SCOPED-DEFINE REF_MOD    reference-only
    {proparse/parsedata.i}    

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsProparse              
    ):
        
        define buffer bttNode for ttNode.
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:Code_block,
            first bttNode where bttNode.NodeNum = ttNode.ParentNum:
            ttNode.CodeBlock = Proparse.Wrapper:AddEntry(ttNode.CodeBlock, bttNode.NodeText).
            PopulateCodeBlocks(ttNode.NodeNum, bttNode.NodeText).                         
        end.
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:FUNCTION:            
            find first bttNode where bttNode.ParentNum = ttNode.NodeNum
                and bttNode.NodeType = ProParserTokenTypes:Parameter_list no-error.
            if available(bttNode) then
                PopulateCodeBlocks(bttNode.NodeNum, ttNode.NodeText).
        end.        
        
        return.
    end method.
    
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void PopulateCodeBlocks
        (
        input iNodeNum as integer,
        input iBlockText as character
        ):
        define buffer tNode for ttNode.
        
        for each ttNode where ttNode.ParentNum = iNodeNum:
            ttNode.CodeBlock = Proparse.Wrapper:AddEntry(ttNode.CodeBlock, iBlockText).
            PopulateCodeBlocks(ttNode.NodeNum, iBlockText).
        end.
        return.

    end method.

end class.