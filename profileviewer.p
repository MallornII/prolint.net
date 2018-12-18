
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
DEFINE VARIABLE profileViewer AS profiles.viewer NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
profileViewer = NEW profiles.viewer().
WAIT-FOR System.Windows.Forms.Application:Run(profileViewer).
profileViewer:Dispose().