/*------------------------------------------------------------------------
   File        : editrule
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Mon Dec 17 13:14:28 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/
USING Progress.Windows.Form.
  
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS editrule INHERITS Form  FINAL: 

    DEFINE PRIVATE VARIABLE components         AS System.ComponentModel.IContainer   NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonOk           AS System.Windows.Forms.Button        NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonCancel       AS System.Windows.Forms.Button        NO-UNDO.
    DEFINE PRIVATE VARIABLE lblId              AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE textId             AS System.Windows.Forms.TextBox       NO-UNDO.
    DEFINE PRIVATE VARIABLE textDescription    AS System.Windows.Forms.TextBox       NO-UNDO.
    DEFINE PRIVATE VARIABLE textClass          AS System.Windows.Forms.TextBox       NO-UNDO.
    DEFINE PRIVATE VARIABLE rulesErrorProvider AS System.Windows.Forms.ErrorProvider NO-UNDO.
    DEFINE PRIVATE VARIABLE numericSeverity    AS System.Windows.Forms.NumericUpDown NO-UNDO.
    DEFINE PRIVATE VARIABLE lvlSeverity        AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE lblClass           AS System.Windows.Forms.Label         NO-UNDO.
    
    DEFINE PUBLIC PROPERTY ruleClass AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PUBLIC PROPERTY RuleDescription AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PUBLIC PROPERTY ruleId AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PUBLIC PROPERTY Severity AS INTEGER INITIAL 1 NO-UNDO 
        GET.
        SET. 

    CONSTRUCTOR PUBLIC editrule( ):
    
        SUPER().
        InitializeComponent ( ).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.        

    END CONSTRUCTOR.

    DESTRUCTOR PUBLIC editrule( ):

        IF VALID-OBJECT(components) THEN 
        DO:
            CAST(components, System.IDisposable):Dispose().
        END.

    END DESTRUCTOR.   

	
    METHOD PRIVATE VOID okButton_Click (sender AS System.Object, e AS System.EventArgs):
        IF NOT ValidateForm(FALSE) THEN
            RETURN.
        ASSIGN
            ruleId          = textId:Text
            ruleClass       = textClass:Text
            ruleDescription = textDescription:Text
            Severity        = numericSeverity:Value.            
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
        
        THIS-OBJECT:components = NEW System.ComponentModel.Container().
        THIS-OBJECT:buttonOk = NEW System.Windows.Forms.Button().
        THIS-OBJECT:buttonCancel = NEW System.Windows.Forms.Button().
        THIS-OBJECT:textClass = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:rulesErrorProvider = NEW System.Windows.Forms.ErrorProvider(THIS-OBJECT:components).
        THIS-OBJECT:numericSeverity = NEW System.Windows.Forms.NumericUpDown().
        THIS-OBJECT:textId = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:textDescription = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:lblClass = NEW System.Windows.Forms.Label().
        THIS-OBJECT:lvlSeverity = NEW System.Windows.Forms.Label().
        THIS-OBJECT:lblId = NEW System.Windows.Forms.Label().
        CAST(THIS-OBJECT:rulesErrorProvider, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:numericSeverity, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* buttonOk */
        /*  */
        DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
        THIS-OBJECT:buttonOk:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:buttonOk:Location = NEW System.Drawing.Point(78, 211).
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
        THIS-OBJECT:buttonCancel:Location = NEW System.Drawing.Point(159, 211).
        THIS-OBJECT:buttonCancel:Name = "buttonCancel".
        THIS-OBJECT:buttonCancel:Size = NEW System.Drawing.Size(75, 23).
        THIS-OBJECT:buttonCancel:TabIndex = 1.
        THIS-OBJECT:buttonCancel:Text = "Cancel".
        THIS-OBJECT:buttonCancel:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:buttonCancel:Click:Subscribe(THIS-OBJECT:cancelButton_Click).
        /*  */
        /* textClass */
        /*  */
        THIS-OBJECT:textClass:Location = NEW System.Drawing.Point(69, 12).
        THIS-OBJECT:textClass:Name = "textClass".
        THIS-OBJECT:textClass:Size = NEW System.Drawing.Size(213, 20).
        THIS-OBJECT:textClass:TabIndex = 2.
        THIS-OBJECT:textClass:Leave:Subscribe(THIS-OBJECT:textClass_Leave).
        /*  */
        /* rulesErrorProvider */
        /*  */
        THIS-OBJECT:rulesErrorProvider:ContainerControl = THIS-OBJECT.
        /*  */
        /* numericSeverity */
        /*  */
        THIS-OBJECT:numericSeverity:Location = NEW System.Drawing.Point(69, 38).
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        DEFINE VARIABLE arrayvar0 AS INTEGER EXTENT 4 NO-UNDO.
        arrayvar0[1] = 99.
        arrayvar0[2] = 0.
        arrayvar0[3] = 0.
        arrayvar0[4] = 0.
        THIS-OBJECT:numericSeverity:Maximum = Progress.Util.DecimalHelper:Create(arrayvar0).
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        DEFINE VARIABLE arrayvar1 AS INTEGER EXTENT 4 NO-UNDO.
        arrayvar1[1] = 1.
        arrayvar1[2] = 0.
        arrayvar1[3] = 0.
        arrayvar1[4] = 0.
        THIS-OBJECT:numericSeverity:Minimum = Progress.Util.DecimalHelper:Create(arrayvar1).
        THIS-OBJECT:numericSeverity:Name = "numericSeverity".
        THIS-OBJECT:numericSeverity:Size = NEW System.Drawing.Size(213, 20).
        THIS-OBJECT:numericSeverity:TabIndex = 4.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        DEFINE VARIABLE arrayvar2 AS INTEGER EXTENT 4 NO-UNDO.
        arrayvar2[1] = 1.
        arrayvar2[2] = 0.
        arrayvar2[3] = 0.
        arrayvar2[4] = 0.
        THIS-OBJECT:numericSeverity:Value = Progress.Util.DecimalHelper:Create(arrayvar2).
        /*  */
        /* textId */
        /*  */
        THIS-OBJECT:textId:Location = NEW System.Drawing.Point(69, 64).
        THIS-OBJECT:textId:Name = "textId".
        THIS-OBJECT:textId:ReadOnly = TRUE.
        THIS-OBJECT:textId:Size = NEW System.Drawing.Size(213, 20).
        THIS-OBJECT:textId:TabIndex = 5.
        /*  */
        /* textDescription */
        /*  */
        THIS-OBJECT:textDescription:Location = NEW System.Drawing.Point(12, 90).
        THIS-OBJECT:textDescription:Multiline = TRUE.
        THIS-OBJECT:textDescription:Name = "textDescription".
        THIS-OBJECT:textDescription:ReadOnly = TRUE.
        THIS-OBJECT:textDescription:Size = NEW System.Drawing.Size(270, 109).
        THIS-OBJECT:textDescription:TabIndex = 6.
        /*  */
        /* lblClass */
        /*  */
        THIS-OBJECT:lblClass:Location = NEW System.Drawing.Point(12, 15).
        THIS-OBJECT:lblClass:Name = "lblClass".
        THIS-OBJECT:lblClass:Size = NEW System.Drawing.Size(39, 20).
        THIS-OBJECT:lblClass:TabIndex = 7.
        THIS-OBJECT:lblClass:Text = "Class:".
        THIS-OBJECT:lblClass:UseCompatibleTextRendering = TRUE.
        /*  */
        /* lvlSeverity */
        /*  */
        THIS-OBJECT:lvlSeverity:Location = NEW System.Drawing.Point(12, 40).
        THIS-OBJECT:lvlSeverity:Name = "lvlSeverity".
        THIS-OBJECT:lvlSeverity:Size = NEW System.Drawing.Size(51, 23).
        THIS-OBJECT:lvlSeverity:TabIndex = 8.
        THIS-OBJECT:lvlSeverity:Text = "Severity:".
        THIS-OBJECT:lvlSeverity:UseCompatibleTextRendering = TRUE.
        /*  */
        /* lblId */
        /*  */
        THIS-OBJECT:lblId:Location = NEW System.Drawing.Point(12, 63).
        THIS-OBJECT:lblId:Name = "lblId".
        THIS-OBJECT:lblId:Size = NEW System.Drawing.Size(51, 23).
        THIS-OBJECT:lblId:TabIndex = 9.
        THIS-OBJECT:lblId:Text = "Id:".
        THIS-OBJECT:lblId:UseCompatibleTextRendering = TRUE.
        /*  */
        /* editrule */
        /*  */
        THIS-OBJECT:AcceptButton = THIS-OBJECT:buttonOk.
        THIS-OBJECT:CancelButton = THIS-OBJECT:buttonCancel.
        THIS-OBJECT:ClientSize = NEW System.Drawing.Size(303, 246).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:lblId).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:lvlSeverity).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:lblClass).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:textDescription).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:textId).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:numericSeverity).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:textClass).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonCancel).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonOk).
        THIS-OBJECT:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
        THIS-OBJECT:MaximizeBox = FALSE.
        THIS-OBJECT:MinimizeBox = FALSE.
        THIS-OBJECT:Name = "editrule".
        THIS-OBJECT:ShowInTaskbar = FALSE.
        THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
        THIS-OBJECT:Text = "editrule".
        CAST(THIS-OBJECT:rulesErrorProvider, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:numericSeverity, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:ResumeLayout(FALSE).
        THIS-OBJECT:PerformLayout().
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END METHOD. 
 
    METHOD PUBLIC VOID ShowModalDialog(  ):
        ASSIGN
            textId:Text           = ruleId
            textClass:Text        = ruleClass
            textDescription:Text  = ruleDescription
            numericSeverity:Value = Severity.
        WAIT-FOR THIS-OBJECT:ShowDialog().

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID textClass_Leave( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        ValidateForm(TRUE).
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE LOGICAL ValidateForm( INPUT assignFields AS LOGICAL ):
        
        DEFINE VARIABLE localClass       AS Progress.Lang.Class         NO-UNDO.
        DEFINE VARIABLE localParameters  AS Progress.Lang.ParameterList NO-UNDO.
        DEFINE VARIABLE localId          AS CHARACTER                   NO-UNDO.
        DEFINE VARIABLE localDescription AS CHARACTER                   NO-UNDO.
        DEFINE VARIABLE localSeverity    AS INTEGER                     NO-UNDO.
        
        rulesErrorProvider:Clear().        
        localClass = Progress.Lang.Class:GetClass(textClass:Text) NO-ERROR.
        IF localClass = ? THEN
        DO:
            rulesErrorProvider:SetError(textClass, "Not a valid OE class":T).
            RETURN FALSE.
        END.
        
        IF NOT localClass:IsA("prolint.rules.abstractrule":U) THEN
        DO:
            rulesErrorProvider:SetError(textClass, "Class not inherited from prolint.rules.abtractrule":T).
            RETURN FALSE.
        END.
        
        IF localClass:IsAbstract() THEN
        DO:
            rulesErrorProvider:SetError(textClass, "Class can not be abstract":T).
            RETURN FALSE.
        END.
        
        IF assignFields THEN
        DO:
            localParameters = NEW Progress.Lang.ParameterList(3).
            localParameters:SetParameter(1, "CHARACTER":U, "OUTPUT":U, localId).
            localParameters:SetParameter(2, "INTEGER":U, "OUTPUT":U, localSeverity).
            localParameters:SetParameter(3, "CHARACTER":U, "OUTPUT":U, localDescription).
            localClass:Invoke("GetInfo":U, localParameters).
            textId:Text = localId.
            numericSeverity:Value = localSeverity.   
            textDescription:Text = localDescription.    
        END.
        
        RETURN TRUE.
        
        FINALLY:
            DELETE OBJECT localClass NO-ERROR.
            DELETE OBJECT localParameters NO-ERROR.    
        END FINALLY.
    END METHOD.

 
END CLASS.
