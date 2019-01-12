 
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
        for each ttNode where ttNode.NodeType = ProParserTokenTypes:PROPARSEDIRECTIVE:
            find first bttNode where bttNode.NodeNum = ttNode.NextSibling no-error.
            if not available(bttNode) then
                next BLK_NODE.
            if bttNode.NodeType = ProParserTokenTypes:BLOCK_LABEL then
            do:
                labelNum = bttNode.NodeNum.
                find first bttNode where bttNode.ParentNum = labelNum
                    and bttNode.IsStateHead.    
            end.
            rulesList = ParseDirective(ttNode.NodeText).       
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
        input iNodeNum as integer,
        input iRulesList as character
        ):
        
        define buffer bttNode for ttNode.
            
        for each bttNode where bttNode.ParentNum = iNodeNum:
            bttNode.IngroneRules = iRulesList.
            PopulateDirectives(bttNode.NodeNum, iRulesList).
        end.
        return.

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    
    method private character ParseDirective( input iDirective as character ):
        
        define variable leftParen  as integer no-undo.
        define variable rightParen as integer no-undo.
        
        iDirective = substitute(iDirective, " ":U, "").
        if not iDirective begins "prolint-nowarn":U then
            return "".
        assign
            leftParen  = index(iDirective, "(":U)
            rightParen = index(iDirective, ")":U).
        if leftParen = 0 or rightParen = 0 then
            return "".
        iDirective = trim(substring(iDirective, leftParen + 1, rightParen - leftParen - 1), ",":U).

        return iDirective.

    end method.
   

end class.