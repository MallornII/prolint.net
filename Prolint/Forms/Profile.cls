 /*------------------------------------------------------------------------
    File        : Profile
    Purpose     : Add profile form
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 17.12.2018 12:59:29
    Notes       : 
  ----------------------------------------------------------------------*/
using Progress.Windows.Form.
  
block-level on error undo, throw.
class Prolint.Forms.Profile inherits Form  final: 

    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
    define private variable lblName as System.Windows.Forms.Label no-undo.
    define private variable textProfile as System.Windows.Forms.TextBox no-undo.
    
    define public property profileName as character no-undo 
    get.
    private set. 

    constructor public Profile( ):
    
        super().
        InitializeComponent ( ).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.        

    end constructor.

    destructor public Profile( ):

        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.    

    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
        profileName = textProfile:TEXT.
        this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.        
        this-object:Close ( ). 
    end method.

    method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
        this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        this-object:Close ( ).
    end method.
    
    method private void InitializeComponent ( ):

        /* NOTE: The following method is automatically generated.
           
           We strongly suggest that the contents of this method only be modified using the 
           Visual Designer to avoid any incompatible modifications.
           
           Modifying the contents of this method using a code editor will invalidate any support for this file. */
        
        this-object:buttonOk = new System.Windows.Forms.Button().
        this-object:buttonCancel = new System.Windows.Forms.Button().
        this-object:textProfile = new System.Windows.Forms.TextBox().
        this-object:lblName = new System.Windows.Forms.Label().
        this-object:SuspendLayout().
        /*  */
        /* buttonOk */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
        this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:buttonOk:Location = new System.Drawing.Point(78, 35).
        this-object:buttonOk:Name = "buttonOk":U.
        this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
        this-object:buttonOk:TabIndex = 0.
        this-object:buttonOk:Text = "OK":U.
        this-object:buttonOk:UseCompatibleTextRendering = true.
        this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
        /*  */
        /* buttonCancel */
        /*  */
        define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
        this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        this-object:buttonCancel:Location = new System.Drawing.Point(159, 35).
        this-object:buttonCancel:Name = "buttonCancel":U.
        this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
        this-object:buttonCancel:TabIndex = 1.
        this-object:buttonCancel:Text = "Cancel":U.
        this-object:buttonCancel:UseCompatibleTextRendering = true.
        this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
        /*  */
        /* textProfile */
        /*  */
        this-object:textProfile:Location = new System.Drawing.Point(63, 6).
        this-object:textProfile:MaxLength = 30.
        this-object:textProfile:Name = "textProfile":U.
        this-object:textProfile:Size = new System.Drawing.Size(219, 20).
        this-object:textProfile:TabIndex = 2.
        /*  */
        /* lblName */
        /*  */
        this-object:lblName:Location = new System.Drawing.Point(12, 9).
        this-object:lblName:Name = "lblName":U.
        this-object:lblName:Size = new System.Drawing.Size(45, 16).
        this-object:lblName:TabIndex = 3.
        this-object:lblName:Text = "Name:":U.
        this-object:lblName:UseCompatibleTextRendering = true.
        /*  */
        /* Profile */
        /*  */
        this-object:AcceptButton = this-object:buttonOk.
        this-object:CancelButton = this-object:buttonCancel.
        this-object:ClientSize = new System.Drawing.Size(294, 70).
        this-object:Controls:Add(this-object:lblName).
        this-object:Controls:Add(this-object:textProfile).
        this-object:Controls:Add(this-object:buttonCancel).
        this-object:Controls:Add(this-object:buttonOk).
        this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
        this-object:MaximizeBox = false.
        this-object:MinimizeBox = false.
        this-object:Name = "Profile":U.
        this-object:ShowInTaskbar = false.
        this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
        this-object:Text = "New profile name":U.
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method. 
 
    method public void ShowModalDialog( ):
        
        wait-for this-object:ShowDialog().        
    end method.


 
end class.
