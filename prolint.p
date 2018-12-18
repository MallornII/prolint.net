
/*------------------------------------------------------------------------
    File        : prolint.p
    Purpose     : Laucnhes main from for prolint.net

    Syntax      :

    Description : 

    Author(s)   : Andrew Ni
    Created     : 18.12.2018 21:25:29
    Notes       :
  ----------------------------------------------------------------------*/
BLOCK-LEVEL ON ERROR UNDO, THROW.
/* ***************************  Definitions  ************************** */
DEFINE VARIABLE lingGUI AS prolint.lintgui NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
lingGUI = NEW prolint.lintgui().
WAIT-FOR System.Windows.Forms.Application:Run(lingGUI).
lingGUI:Dispose().
