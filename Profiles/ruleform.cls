/*------------------------------------------------------------------------
   File        : ruleform
   Purpose     : Add/Edit rule form
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 17.12.2018 13:14:28
   Notes       : 
 ----------------------------------------------------------------------*/
using Progress.Windows.Form.
  
block-level on error undo, throw.
class profiles.ruleform inherits Form  final: 

    define private variable components         as System.ComponentModel.IContainer   no-undo.
    define private variable buttonOk           as System.Windows.Forms.Button        no-undo.
    define private variable buttonCancel       as System.Windows.Forms.Button        no-undo.
    define private variable lblId              as System.Windows.Forms.Label         no-undo.
    define private variable textId             as System.Windows.Forms.TextBox       no-undo.
    define private variable textDescription    as System.Windows.Forms.TextBox       no-undo.
    define private variable textClass          as System.Windows.Forms.TextBox       no-undo.
    define private variable rulesErrorProvider as System.Windows.Forms.ErrorProvider no-undo.
    define private variable numericSeverity    as System.Windows.Forms.NumericUpDown no-undo.
    define private variable lvlSeverity        as System.Windows.Forms.Label         no-undo.
    define private variable lblClass           as System.Windows.Forms.Label         no-undo.
    
    define public property ruleClass as character no-undo 
        get.
        set. 

    define public property RuleDescription as character no-undo 
        get.
        set. 

    define public property ruleId as character no-undo 
        get.
        set. 

    define public property Severity as integer initial 1 no-undo 
        get.
        set. 

    constructor public ruleform( ):
    
        super().
        InitializeComponent ( ).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.        

    end constructor.

    destructor public ruleform( ):

        if valid-object(components) then 
        do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.   

	
    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
        if not ValidateForm(false) then
            return.
        assign
            ruleId          = textId:Text
            ruleClass       = textClass:Text
            ruleDescription = textDescription:Text
            Severity        = numericSeverity:Value.            
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
        
        this-object:components = new System.ComponentModel.Container().
        this-object:buttonOk = new System.Windows.Forms.Button().
        this-object:buttonCancel = new System.Windows.Forms.Button().
        this-object:textClass = new System.Windows.Forms.TextBox().
        this-object:rulesErrorProvider = new System.Windows.Forms.ErrorProvider(this-object:components).
        this-object:numericSeverity = new System.Windows.Forms.NumericUpDown().
        this-object:textId = new System.Windows.Forms.TextBox().
        this-object:textDescription = new System.Windows.Forms.TextBox().
        this-object:lblClass = new System.Windows.Forms.Label().
        this-object:lvlSeverity = new System.Windows.Forms.Label().
        this-object:lblId = new System.Windows.Forms.Label().
        cast(this-object:rulesErrorProvider, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:numericSeverity, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* buttonOk */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
        this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:buttonOk:Location = new System.Drawing.Point(78, 211).
        this-object:buttonOk:Name = "buttonOk".
        this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
        this-object:buttonOk:TabIndex = 0.
        this-object:buttonOk:Text = "OK".
        this-object:buttonOk:UseCompatibleTextRendering = true.
        this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
        /*  */
        /* buttonCancel */
        /*  */
        define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
        this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        this-object:buttonCancel:Location = new System.Drawing.Point(159, 211).
        this-object:buttonCancel:Name = "buttonCancel".
        this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
        this-object:buttonCancel:TabIndex = 1.
        this-object:buttonCancel:Text = "Cancel".
        this-object:buttonCancel:UseCompatibleTextRendering = true.
        this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
        /*  */
        /* textClass */
        /*  */
        this-object:textClass:Location = new System.Drawing.Point(69, 12).
        this-object:textClass:Name = "textClass".
        this-object:textClass:Size = new System.Drawing.Size(213, 20).
        this-object:textClass:TabIndex = 2.
        this-object:textClass:Leave:Subscribe(this-object:textClass_Leave).
        /*  */
        /* rulesErrorProvider */
        /*  */
        this-object:rulesErrorProvider:ContainerControl = this-object.
        /*  */
        /* numericSeverity */
        /*  */
        this-object:numericSeverity:Location = new System.Drawing.Point(69, 38).
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        define variable arrayvar0 as integer extent 4 no-undo.
        arrayvar0[1] = 99.
        arrayvar0[2] = 0.
        arrayvar0[3] = 0.
        arrayvar0[4] = 0.
        this-object:numericSeverity:Maximum = Progress.Util.DecimalHelper:Create(arrayvar0).
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        define variable arrayvar1 as integer extent 4 no-undo.
        arrayvar1[1] = 1.
        arrayvar1[2] = 0.
        arrayvar1[3] = 0.
        arrayvar1[4] = 0.
        this-object:numericSeverity:Minimum = Progress.Util.DecimalHelper:Create(arrayvar1).
        this-object:numericSeverity:Name = "numericSeverity".
        this-object:numericSeverity:Size = new System.Drawing.Size(213, 20).
        this-object:numericSeverity:TabIndex = 4.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        define variable arrayvar2 as integer extent 4 no-undo.
        arrayvar2[1] = 1.
        arrayvar2[2] = 0.
        arrayvar2[3] = 0.
        arrayvar2[4] = 0.
        this-object:numericSeverity:Value = Progress.Util.DecimalHelper:Create(arrayvar2).
        /*  */
        /* textId */
        /*  */
        this-object:textId:Location = new System.Drawing.Point(69, 64).
        this-object:textId:Name = "textId".
        this-object:textId:ReadOnly = true.
        this-object:textId:Size = new System.Drawing.Size(213, 20).
        this-object:textId:TabIndex = 5.
        /*  */
        /* textDescription */
        /*  */
        this-object:textDescription:Location = new System.Drawing.Point(12, 90).
        this-object:textDescription:Multiline = true.
        this-object:textDescription:Name = "textDescription".
        this-object:textDescription:ReadOnly = true.
        this-object:textDescription:Size = new System.Drawing.Size(270, 109).
        this-object:textDescription:TabIndex = 6.
        /*  */
        /* lblClass */
        /*  */
        this-object:lblClass:Location = new System.Drawing.Point(12, 15).
        this-object:lblClass:Name = "lblClass".
        this-object:lblClass:Size = new System.Drawing.Size(39, 20).
        this-object:lblClass:TabIndex = 7.
        this-object:lblClass:Text = "Class:".
        this-object:lblClass:UseCompatibleTextRendering = true.
        /*  */
        /* lvlSeverity */
        /*  */
        this-object:lvlSeverity:Location = new System.Drawing.Point(12, 40).
        this-object:lvlSeverity:Name = "lvlSeverity".
        this-object:lvlSeverity:Size = new System.Drawing.Size(51, 23).
        this-object:lvlSeverity:TabIndex = 8.
        this-object:lvlSeverity:Text = "Severity:".
        this-object:lvlSeverity:UseCompatibleTextRendering = true.
        /*  */
        /* lblId */
        /*  */
        this-object:lblId:Location = new System.Drawing.Point(12, 63).
        this-object:lblId:Name = "lblId".
        this-object:lblId:Size = new System.Drawing.Size(51, 23).
        this-object:lblId:TabIndex = 9.
        this-object:lblId:Text = "Id:".
        this-object:lblId:UseCompatibleTextRendering = true.
        /*  */
        /* editrule */
        /*  */
        this-object:AcceptButton = this-object:buttonOk.
        this-object:CancelButton = this-object:buttonCancel.
        this-object:ClientSize = new System.Drawing.Size(303, 246).
        this-object:Controls:Add(this-object:lblId).
        this-object:Controls:Add(this-object:lvlSeverity).
        this-object:Controls:Add(this-object:lblClass).
        this-object:Controls:Add(this-object:textDescription).
        this-object:Controls:Add(this-object:textId).
        this-object:Controls:Add(this-object:numericSeverity).
        this-object:Controls:Add(this-object:textClass).
        this-object:Controls:Add(this-object:buttonCancel).
        this-object:Controls:Add(this-object:buttonOk).
        this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
        this-object:MaximizeBox = false.
        this-object:MinimizeBox = false.
        this-object:Name = "editrule".
        this-object:ShowInTaskbar = false.
        this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
        this-object:Text = "editrule".
        cast(this-object:rulesErrorProvider, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:numericSeverity, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method. 
 
    method public void ShowModalDialog(  ):
        assign
            textId:Text           = ruleId
            textClass:Text        = ruleClass
            textDescription:Text  = ruleDescription
            numericSeverity:Value = Severity.
        wait-for this-object:ShowDialog().

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void textClass_Leave( input sender as System.Object, input e as System.EventArgs ):
        ValidateForm(true).
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private logical ValidateForm( input assignFields as logical ):
        
        define variable localClass       as Progress.Lang.Class         no-undo.
        define variable localParameters  as Progress.Lang.ParameterList no-undo.
        define variable localId          as character                   no-undo.
        define variable localDescription as character                   no-undo.
        define variable localSeverity    as integer                     no-undo.
        
        rulesErrorProvider:Clear().        
        localClass = Progress.Lang.Class:GetClass(textClass:Text) no-error.
        if localClass = ? then
        do:
            rulesErrorProvider:SetError(textClass, "Not a valid OE class":T).
            return false.
        end.
        
        if not localClass:IsA("prolint.rules.abstractrule":U) then
        do:
            rulesErrorProvider:SetError(textClass, "Class not inherited from prolint.rules.abtractrule":T).
            return false.
        end.
        
        if localClass:IsAbstract() then
        do:
            rulesErrorProvider:SetError(textClass, "Class can not be abstract":T).
            return false.
        end.
        
        if assignFields then
        do:
            localParameters = new Progress.Lang.ParameterList(3).
            localParameters:SetParameter(1, "CHARACTER":U, "OUTPUT":U, localId).
            localParameters:SetParameter(2, "INTEGER":U, "OUTPUT":U, localSeverity).
            localParameters:SetParameter(3, "CHARACTER":U, "OUTPUT":U, localDescription).
            localClass:Invoke("GetInfo":U, localParameters).
            textId:Text = localId.
            numericSeverity:Value = localSeverity.   
            textDescription:Text = localDescription.    
        end.
        
        return true.
        
        finally:
            delete object localClass no-error.
            delete object localParameters no-error.    
        end finally.
    end method.

 
end class.
