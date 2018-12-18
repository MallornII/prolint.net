
/*------------------------------------------------------------------------
    File        : irule
    Purpose     : Basic interface for rules
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 09.12.2018 15:33:42
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE prolint.rules.irule:
    {proparse/jpnodes.i &REF_MOD="REFERENCE-ONLY"}
    
    /*------------------------------------------------------------------------------
     Purpose: Publish current's rule result
     Notes:
    ------------------------------------------------------------------------------*/     

    DEFINE PUBLIC EVENT PublishRuleResult  SIGNATURE VOID
    (   
        INPUT iRuleId   AS CHARACTER,
        INPUT iFileName AS CHARACTER,
        INPUT iLine     AS INTEGER,
        INPUT iSeverity AS INTEGER,
        INPUT iComment  AS CHARACTER
    ).

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	METHOD PUBLIC VOID ApplyRule( TABLE ttNode BIND ).

END INTERFACE.