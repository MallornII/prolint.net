
/*------------------------------------------------------------------------
    File        : results.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Tue Dec 18 15:13:13 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define {&ACCESS_MOD} temp-table ttResult no-undo
        field RuleId     as character
        field Unit       as character
        field SourceFile as character
        field LineNumber as integer
        field Severity   as integer
        field Comment    as character.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
