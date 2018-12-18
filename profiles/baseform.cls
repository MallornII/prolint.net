 /*------------------------------------------------------------------------
    File        : baseform
    Purpose     : Add profile form
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 17.12.2018 12:59:29
    Notes       : 
  ----------------------------------------------------------------------*/
USING Progress.Windows.Form.
  
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS profiles.baseform INHERITS Form  FINAL: 

    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonOk AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonCancel AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE lblName AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE textProfile AS System.Windows.Forms.TextBox NO-UNDO.
    
    DEFINE PUBLIC PROPERTY profileName AS CHARACTER NO-UNDO 
    GET.
    PRIVATE SET. 

    CONSTRUCTOR PUBLIC baseform( ):
    
        SUPER().
        InitializeComponent ( ).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.        

    END CONSTRUCTOR.

    DESTRUCTOR PUBLIC baseform( ):

        IF VALID-OBJECT(components) THEN DO:
            CAST(components, System.IDisposable):Dispose().
        END.

    END DESTRUCTOR.    

    METHOD PRIVATE VOID okButton_Click (sender AS System.Object, e AS System.EventArgs):
        profileName = textProfile:TEXT.
        THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Ok.        
        THIS-OBJECT:Close ( ). 
    END METHOD.

    METHOD PRIVATE VOID cancelButton_Click (sender AS System.Object, e AS System.EventArgs):
        THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        THIS-OBJECT:Close ( ).
    END METHOD.
    
    METHOD PRIVATE VOID InitializeComponent ( ):

        /* NOTE: The following method is automatically generated.
           
           We strongly suggest that the contents of this method only be modified using the 
           Visual Designer to avoid any incompatible modifications.
           
           Modifying the contents of this method using a code editor will invalidate any support for this file. */
        
        THIS-OBJECT:buttonOk = NEW System.Windows.Forms.Button().
        THIS-OBJECT:buttonCancel = NEW System.Windows.Forms.Button().
        THIS-OBJECT:textProfile = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:lblName = NEW System.Windows.Forms.Label().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* buttonOk */
        /*  */
        DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
        THIS-OBJECT:buttonOk:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:buttonOk:Location = NEW System.Drawing.Point(89, 35).
        THIS-OBJECT:buttonOk:Name = "buttonOk".
        THIS-OBJECT:buttonOk:Size = NEW System.Drawing.Size(75, 23).
        THIS-OBJECT:buttonOk:TabIndex = 0.
        THIS-OBJECT:buttonOk:Text = "OK".
        THIS-OBJECT:buttonOk:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:buttonOk:Click:Subscribe(THIS-OBJECT:okButton_Click).
        /*  */
        /* buttonCancel */
        /*  */
        DEFINE VARIABLE nestedvar1 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
        THIS-OBJECT:buttonCancel:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        THIS-OBJECT:buttonCancel:Location = NEW System.Drawing.Point(170, 35).
        THIS-OBJECT:buttonCancel:Name = "buttonCancel".
        THIS-OBJECT:buttonCancel:Size = NEW System.Drawing.Size(75, 23).
        THIS-OBJECT:buttonCancel:TabIndex = 1.
        THIS-OBJECT:buttonCancel:Text = "Cancel".
        THIS-OBJECT:buttonCancel:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:buttonCancel:Click:Subscribe(THIS-OBJECT:cancelButton_Click).
        /*  */
        /* textProfile */
        /*  */
        THIS-OBJECT:textProfile:Location = NEW System.Drawing.Point(63, 6).
        THIS-OBJECT:textProfile:MaxLength = 30.
        THIS-OBJECT:textProfile:Name = "textProfile".
        THIS-OBJECT:textProfile:Size = NEW System.Drawing.Size(219, 20).
        THIS-OBJECT:textProfile:TabIndex = 2.
        /*  */
        /* lblName */
        /*  */
        THIS-OBJECT:lblName:Location = NEW System.Drawing.Point(12, 9).
        THIS-OBJECT:lblName:Name = "lblName".
        THIS-OBJECT:lblName:Size = NEW System.Drawing.Size(45, 16).
        THIS-OBJECT:lblName:TabIndex = 3.
        THIS-OBJECT:lblName:Text = "Name:".
        THIS-OBJECT:lblName:UseCompatibleTextRendering = TRUE.
        /*  */
        /* newprofile */
        /*  */
        THIS-OBJECT:AcceptButton = THIS-OBJECT:buttonOk.
        THIS-OBJECT:CancelButton = THIS-OBJECT:buttonCancel.
        THIS-OBJECT:ClientSize = NEW System.Drawing.Size(294, 70).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:lblName).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:textProfile).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonCancel).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonOk).
        THIS-OBJECT:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
        THIS-OBJECT:MaximizeBox = FALSE.
        THIS-OBJECT:MinimizeBox = FALSE.
        THIS-OBJECT:Name = "newprofile".
        THIS-OBJECT:ShowInTaskbar = FALSE.
        THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
        THIS-OBJECT:Text = "New profile name".
        THIS-OBJECT:ResumeLayout(FALSE).
        THIS-OBJECT:PerformLayout().
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END METHOD. 
 
    METHOD PUBLIC VOID ShowModalDialog( ):
        
        WAIT-FOR THIS-OBJECT:ShowDialog().        
    END METHOD.


 
END CLASS.
