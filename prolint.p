
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
session:error-stack-trace = true.
log-manager:logfile-name = "prolint.net.log".
log-manager:clear-log().
log-manager:log-entry-types = "4GLMessages":u.
log-manager:logging-level = 2.

if not connected("bisquit":u) then
    connect value("-db bisquit -H localhost -S 2164 -U bis -P 123":u).

lintForm = new Prolint.Forms.MainForm() no-error.
wait-for System.Windows.Forms.Application:Run(lintForm).
lintForm:Dispose().

catch e as Progress.Lang.Error :    
    log-manager:write-message(e:CallStack).
    log-manager:write-message(e:GetMessage(1)).    
end catch.

finally:
    session:error-stack-trace = false.
    log-manager:close-log().
    quit.    
end finally.