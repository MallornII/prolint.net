 
 /*------------------------------------------------------------------------
    File        : FindStateDb
    Purpose     : Finds <FIND DBTABLE> statements without <FIRST,LAST,NEXT,RPEV> modifiers
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 27.01.2019 18:25:29
    Notes       : 
  ----------------------------------------------------------------------*/

using Prolint.Rules.FindState.

block-level on error undo, throw.

class Prolint.Rules.FindStateDb inherits FindState final serializable: 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public FindStateDb (  ):
        super ().
        
        TableType = "st-dbtable":u.        
    end constructor. 
    
    method override public void Visit
        (
        input currentUnit as Prolint.ILintUnit,
        input dataset dsProparse,
        input dataset dsXref
        ):
        define buffer ttDirNode    for ttNode.
        define buffer ttWhereNode  for ttNode.
        define buffer ttRecordNode for ttNode.
        define buffer ttEqNode     for ttNode.
        define buffer ttRowIdNode  for ttNode.
        
        super:Visit(currentUnit, input dataset dsProparse, input dataset dsXref).
    end method.
end class.