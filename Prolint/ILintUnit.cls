
/*------------------------------------------------------------------------
    File        : ILintUnit
    Purpose     : Interface for Units that hold information about current Lint process
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 21.12.2018 22:45:18
    Notes       : 
  ----------------------------------------------------------------------*/
using org.prorefactor.core.JPNode.
using Prolint.LintResult.

interface Prolint.ILintUnit:
        
  
    define public event PublishResult  signature void
    (
        input ruleId      as character,
        input attrs       as character,
        input compileUnit as character,
        input sourceFile  as character,
        input lineNumber  as integer,
        input severity    as integer,
        input comment     as character
    ).

    define public property CompileUnit as character no-undo
    get.
    set.

    define public property IsCompiled as logical no-undo 
    get.
    set. 

    define public property IsDebug as logical no-undo 
    get.
    set. 

    define public property isResultsPublished as logical no-undo 
    get.     

    define public property LintStatus as LintResult no-undo 
    get.
    set.     

    define public property TopNode as org.prorefactor.core.JPNode no-undo 
    get.
    set.      

    /*------------------------------------------------------------------------------
     Purpose: Accepts IRule visitor
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Accept( input currentRule as Prolint.Rules.IRule ).
    
    /*------------------------------------------------------------------------------
     Purpose: Accepts IParser visitor
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Accept( input currentParser as Proparse.IParser ).    
    
    /*------------------------------------------------------------------------------
     Purpose: Accepts IUnitWorker visitor
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Accept( input currentWorker as Prolint.IUnitWorker ).

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public void AddResult
    (
        input ruleId      as character,        
        input sourceFile  as character,
        input lineNumber  as integer,
        input severity    as integer,
        input comment     as character
    ).

    /*------------------------------------------------------------------------------
     Purpose: Return node's parent num
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetParentNum( input nodeNum as integer ).

    /*------------------------------------------------------------------------------
     Purpose: Return node's parent type
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetParentType( input nodeNum as integer ).

    /*------------------------------------------------------------------------------
     Purpose: Return next sequence ID. Acts like NEXT-VALUE function
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer NextSequenceId(  ).
    
    /*------------------------------------------------------------------------------
     Purpose: Returns NodeNum that is a statement head for given node
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetStateHead( input iNodeNum as integer ).
    
    /*------------------------------------------------------------------------------
     Purpose: Returns NodeType for node that is a statement head for given node
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetStateHeadType( input iNodeNum as integer ).

end interface.