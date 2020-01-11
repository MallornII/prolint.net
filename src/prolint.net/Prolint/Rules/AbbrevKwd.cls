 
/*------------------------------------------------------------------------
   File        : AbbrevKwd
   Purpose     : Finds abbreviated keywords
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 09.12.2018 15:46:45
   Notes       : 
 ----------------------------------------------------------------------*/

using com.joanju.proparse.ProParserTokenTypes.
using com.joanju.proparse.NodeTypes.

block-level on error undo, throw.

class Prolint.Rules.AbbrevKwd inherits Prolint.Rules.AbstractRule serializable final:   
    
    define private temp-table ttSkipNodes no-undo
        field NodeType as integer.
        
    define private temp-table ttAbbrev no-undo
        field AbbrevName as character
        field FullName   as character.

    /*------------------------------------------------------------------------------
     Purpose: Default constructor
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor public AbbrevKwd ():        
        super ().
		
        assign
            RuleDescription = "Finds abbreviated keywords":t
            RuleId          = "AbbrevKwd":U
            Severity        = 7.
		
        AddSkipType(ProParserTokenTypes:Program_root).
        AddSkipType(ProParserTokenTypes:QSTRING).
        AddSkipType(ProParserTokenTypes:NUMBER).
        AddSkipType(ProParserTokenTypes:PERIOD).
        AddSkipType(ProParserTokenTypes:COMMA).
        AddSkipType(ProParserTokenTypes:LEXCOLON).
        AddSkipType(ProParserTokenTypes:OBJCOLON).
        AddSkipType(ProParserTokenTypes:LEFTPAREN).
        AddSkipType(ProParserTokenTypes:RIGHTPAREN).
		
        AddAbbrev("FILE-INFO", "FILE-INFO").
        AddAbbrev("COL", "COLUMNS").
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose: Start method for visiting ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/

    method private void AddAbbrev
        (
        input abbrevName as character,
        input fullName as character
        ):
		
        create ttAbbrev.
        assign
            ttAbbrev.AbbrevName = abbrevName
            ttAbbrev.FullName   = fullName.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void AddSkipType( input nodeType as integer ):
		
        create ttSkipNodes.
        ttSkipNodes.NodeType = nodeType.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private character UnAbbrev( input abbrevName as character ):
		
        find first ttAbbrev where ttAbbrev.AbbrevName = abbrevName no-error.
        if available(ttAbbrev) then
            return ttAbbrev.FullName.
        else  
            return keyword-all(abbrevName).

    end method.   

    method override public void Visit
        (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
        ):
        
        define variable unAbbrevName as character no-undo.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
        
        BLK_NODE:
        for each ttNode where ttNode.NodeText <> "":
            if ttNode.NodeText = NodeTypes:getTypeName(ttNode.NodeType) then
                next.
            if can-find(first ttSkipNodes where ttSkipNodes.NodeType = ttNode.NodeType) then
                next BLK_NODE.
            unAbbrevName = unAbbrev(ttNode.NodeText).
            if unAbbrevName <> ? and unAbbrevname <> ttNode.NodeText then
                PublishResult(currentUnit:CompileUnit, ttNode.NodeFile, ttNode.NodeLine, substitute("Abbreviated &1 for &2":T, ttNode.NodeText, unAbbrevName)).
        end.

    end method.

end class.