
/*------------------------------------------------------------------------
    File        : launcher.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Mon Dec 17 15:08:20 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.
/* ***************************  Definitions  ************************** */
DEFINE VARIABLE profileEditor AS lintprof NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
profileEditor = NEW lintprof().
WAIT-FOR System.Windows.Forms.Application:Run(profileEditor).
profileEditor:Dispose().