
/*------------------------------------------------------------------------
    File        : compile.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Wed Dec 12 23:50:26 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttCompileMessage no-undo
    {&REF_MOD}
    field SourceFile   as character
    field Severity     as integer
    field ErrorCode    as integer
    field ErrorMessage as character
    field ErrorLine    as integer.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
