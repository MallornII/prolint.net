
/*------------------------------------------------------------------------
    File        : lint_test.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Wed Dec 05 23:39:19 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/
USING proparse.api.
USING OpenEdge.Core.Collections.List.
USING OpenEdge.Core.Collections.IListIterator.

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.


DEFINE VARIABLE errs AS OpenEdge.Core.Collections.IListIterator NO-UNDO.
DEFINE VARIABLE mylint AS prolint.linter NO-UNDO.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
COMPILE proparse/api.cls SAVE = FALSE LISTING VALUE("C:/temp/api.list") XREF-XML VALUE("C:/temp/api.xref") NO-ERROR.
COMPILE c:/temp/testide.p SAVE = FALSE LISTING VALUE("C:/temp/api2.list") XREF-XML VALUE("C:/temp/api2.xref")  .

mylint = NEW prolint.linter("test"). 

IF NOT mylint:Parse("c:/temp/test.cls") THEN
DO:
    MESSAGE "errs1"
    VIEW-AS ALERT-BOX.
    errs = proparse.api:GetErrors().    
    MESSAGE "ttt"
    VIEW-AS ALERT-BOX.
    DO WHILE errs:HasNext():
        MESSAGE CAST(errs:Next(), "Progress.Lang.Error"):GetMessage(1)
        VIEW-AS ALERT-BOX.
    END.
END.
ELSE 
MESSAGE "parsed ok!"
VIEW-AS ALERT-BOX.