
/*------------------------------------------------------------------------
    File        : ilintunit
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : niand
    Created     : Fri Dec 21 22:45:18 ALMT 2018
    Notes       : 
  ----------------------------------------------------------------------*/
using org.prorefactor.core.JPNode.

interface Prolint.ILintUnit:
        
  
    define public property CompileUnit as character no-undo
    get.
    set.

    define public property IsCompiled as logical no-undo 
    get.
    set. 

    define public property IsDebug as logical no-undo 
    get.
    set. 

    define public property TopNode as org.prorefactor.core.JPNode no-undo 
    get.
    set.      

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Accept( input currentRule as Prolint.Rules.IRule ).
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Accept( input currentParser as Proparse.IParser ).    
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public void Accept( input currentWorker as Prolint.IUnitWorker ).

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetParentNum( input nodeNum as integer ).

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetParentType( input nodeNum as integer ).

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer NextSequenceId(  ).
    
    /*------------------------------------------------------------------------------
     Purpose: Returns JPNode that is a statement head for given node
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetStateHead( input iNodeNum as integer ).
    
    /*------------------------------------------------------------------------------
     Purpose: Returns NodeType for node that is a statement head for given node
     Notes:
    ------------------------------------------------------------------------------*/

    method public integer GetStateHeadType( input iNodeNum as integer ).

end interface.