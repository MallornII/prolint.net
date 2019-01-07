 
 /*------------------------------------------------------------------------
    File        : CodeBlocksParser
    Purpose     : Marks every Node inside Code_block with type of Code_block
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 22.12.2018 15:42:43
    Notes       : 
  ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using Proparse.IParser.
using Utils.Strings.

block-level on error undo, throw.

class Proparse.CodeBlocksParser implements IParser final:
    
    &SCOPED-DEFINE ACCESS_MOD private
    &SCOPED-DEFINE REF_MOD    reference-only
    {proparse/parsedata.i}
    
    /*------------------------------------------------------------------------------
     Purpose: Start method for visiting ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/    

    method public void Visit
    (
       input currentUnit as Prolint.ILintUnit,
       input dataset dsProparse              
    ):
        
        define buffer bttNode for ttNode.
        
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:Code_block,
            first bttNode where bttNode.NodeNum = ttNode.ParentNum:
            ttNode.CodeBlock = Strings:AppendEntry(ttNode.CodeBlock, bttNode.NodeText).
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
            ttNode.CodeBlock = Strings:AppendEntry(ttNode.CodeBlock, iBlockText).
            PopulateCodeBlocks(ttNode.NodeNum, iBlockText).
        end.
        return.

    end method.

end class.