 
 /*------------------------------------------------------------------------
    File        : DirectivesParser
    Purpose     : Parses ProParseDirectives
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 22.12.2018 15:53:27
    Notes       : 
  ----------------------------------------------------------------------*/
using com.joanju.proparse.ProParserTokenTypes.
using Proparse.IParser.
using Utils.Strings.

block-level on error undo, throw.

class Proparse.DirectivesParser implements IParser final:
    
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
        
        define variable rulesList as character no-undo.
        define variable labelNum  as integer   no-undo.
        
        BLK_NODE:
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:ANNOTATION
            and ttNode.NodeText = "@ProparseIgnore":               
            find first bttNode where bttNode.ParentNum = ttNode.ParentNum
                and bttNode.PrevSibling = ttNode.NodeNum no-error.            
            if not available(bttNode) then
                next BLK_NODE.            
            if bttNode.NodeType = ProParserTokenTypes:BLOCK_LABEL then
            do:
                labelNum = bttNode.NodeNum.
                find first bttNode where bttNode.ParentNum = labelNum
                    and bttNode.IsStateHead.    
            end.
            rulesList = ParseDirective(ttNode.NodeNum).                   
            bttNode.IngroneRules = rulesList. 
            PopulateDirectives(bttNode.NodeNum, rulesList).             
        end. 
            
        return.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    
    method private void PopulateDirectives       
        (
        input nodeNum as integer,
        input rulesList as character
        ):
        
        define buffer bttNode for ttNode.
            
        for each bttNode where bttNode.ParentNum = nodeNum:
            bttNode.IngroneRules = rulesList.
            PopulateDirectives(bttNode.NodeNum, rulesList).
        end.
        return.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    
    method private character ParseDirective( input parentNum as integer ):
        
        define variable rulesList as character no-undo.
        
        define buffer ttEqNode for ttNode.
        define buffer ttLeftNode for ttNode.
        define buffer ttRightNode for ttNode.
        
        for each ttEqNode where ttEqNode.ParentNum = parentNum
            and ttEqNode.NodeType = ProParserTokenTypes:EQUAL,
            first ttLeftNode where ttLeftNode.NodeNum = ttEqNode.PrevSibling
            and ttLeftNode.NodeText = "ruleId",
            first ttRightNode where ttRightNode.NodeNum = ttEqNode.NextSibling:        
            rulesList = Strings:AppendUniqueEntry(rulesList, trim(ttRightNode.NodeText, chr(34))).            
        end.
        
        return rulesList.

    end method.
   

end class.