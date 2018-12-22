
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
define variable lingGUI as prolint.lintgui no-undo.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
lingGUI = new prolint.lintgui().
wait-for System.Windows.Forms.Application:Run(lingGUI).
lingGUI:Dispose().
