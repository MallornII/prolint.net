
/*------------------------------------------------------------------------
    File        : prolint.p
    Purpose     : Laucnhes main from for prolint.net

    Syntax      :

    Description : 

    Author(s)   : Andrew Ni
    Created     : 18.12.2018 21:25:29
    Notes       :
  ----------------------------------------------------------------------*/
block-level on error undo, throw.
/* ***************************  Definitions  ************************** */
define variable lintForm as Prolint.Forms.MainForm no-undo.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
lintForm = new Prolint.Forms.MainForm().
wait-for System.Windows.Forms.Application:Run(lintForm).
lintForm:Dispose().
