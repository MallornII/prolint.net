/*------------------------------------------------------------------------
   File        : Rule
   Purpose     : Add/Edit rule form
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 17.12.2018 13:14:28
   Notes       : 
 ----------------------------------------------------------------------*/
using Progress.Windows.Form.
  
block-level on error undo, throw.
class Prolint.Forms.Rule inherits Form  final: 

    define private variable components           as System.ComponentModel.IContainer   no-undo.
    define private variable buttonOk             as System.Windows.Forms.Button        no-undo.
    define private variable buttonCancel         as System.Windows.Forms.Button        no-undo.
    define private variable rulePropertyGrid     as PropertyGridEx.PropertyGridEx      no-undo.
    define private variable textClass            as System.Windows.Forms.TextBox       no-undo.
    define private variable rulesErrorProvider   as System.Windows.Forms.ErrorProvider no-undo.
    define private variable lblClass             as System.Windows.Forms.Label         no-undo.
    define private variable ruleInstance         as Prolint.Rules.IRule                no-undo.
    define private variable classInstance        as Progress.Lang.Class                no-undo.
    define private variable ruleProperties       as Progress.Reflect.Property          extent no-undo.
    
    /* as ABl does not support IConvertible the only way to make sure property values
       are properly converted to and from .Net is to declare static type variables */
    define         variable stringIConvertible   as character                          no-undo.
    define         variable int32IConvertible    as integer                            no-undo.
    define         variable int64IConvertible    as int64                              no-undo.
    define         variable boolIConvertible     as logical                            no-undo.
    define         variable doubleIConvertible   as decimal                            no-undo.
    define         variable dateIConvertible     as date                               no-undo.
    define         variable datetimeIConvertible as datetime                           no-undo.
    
    define public property ruleClass as character no-undo 
        get.
        set.
        
    define public property profileName as character no-undo 
        get.
        set.

    constructor public Rule( ):
    
        super().
        InitializeComponent ( ).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.        

    end constructor.

    destructor public Rule( ):

        if valid-object(components) then 
        do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.   

	
    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
        if not valid-object(ruleInstance) then
            return.
            
        SaveProperties().       
        ruleClass = textClass:Text.            
        this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
        this-object:Close ( ). 
    end method.

    method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
        if ruleClass = "" and valid-object(ruleInstance) then
            Prolint.Rules.Factory:DropInstance(profileName, textClass:Text, false).
        this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        this-object:Close ( ).
    end method.
    
    method private void InitializeComponent ( ):

        /* NOTE: The following method is automatically generated.
           
           We strongly suggest that the contents of this method only be modified using the 
           Visual Designer to avoid any incompatible modifications.
           
           Modifying the contents of this method using a code editor will invalidate any support for this file. */
        
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true":U).
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("Prolint.Forms.Rule":U).
        this-object:buttonOk = new System.Windows.Forms.Button().
        this-object:buttonCancel = new System.Windows.Forms.Button().
        this-object:textClass = new System.Windows.Forms.TextBox().
        this-object:rulesErrorProvider = new System.Windows.Forms.ErrorProvider(this-object:components).
        this-object:lblClass = new System.Windows.Forms.Label().
        this-object:rulePropertyGrid = new PropertyGridEx.PropertyGridEx().
        cast(this-object:rulesErrorProvider, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* buttonOk */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
        this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:buttonOk:Location = new System.Drawing.Point(184, 350).
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
        this-object:buttonCancel:Location = new System.Drawing.Point(265, 350).
        this-object:buttonCancel:Name = "buttonCancel":U.
        this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
        this-object:buttonCancel:TabIndex = 1.
        this-object:buttonCancel:Text = "Cancel":U.
        this-object:buttonCancel:UseCompatibleTextRendering = true.
        this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
        /*  */
        /* textClass */
        /*  */
        this-object:textClass:Location = new System.Drawing.Point(69, 12).
        this-object:textClass:Name = "textClass":U.
        this-object:textClass:Size = new System.Drawing.Size(453, 20).
        this-object:textClass:TabIndex = 2.
        this-object:textClass:Leave:Subscribe(this-object:textClass_Leave).
        /*  */
        /* rulesErrorProvider */
        /*  */
        this-object:rulesErrorProvider:ContainerControl = this-object.
        /*  */
        /* lblClass */
        /*  */
        this-object:lblClass:Location = new System.Drawing.Point(12, 15).
        this-object:lblClass:Name = "lblClass":U.
        this-object:lblClass:Size = new System.Drawing.Size(39, 20).
        this-object:lblClass:TabIndex = 7.
        this-object:lblClass:Text = "Class:":U.
        this-object:lblClass:UseCompatibleTextRendering = true.
        /*  */
        /* rulePropertyGrid */
        /*  */
        /*  */
        /*  */
        /*  */
        this-object:rulePropertyGrid:DocCommentDescription:AccessibleName = "":U.
        this-object:rulePropertyGrid:DocCommentDescription:AutoEllipsis = true.
        this-object:rulePropertyGrid:DocCommentDescription:Cursor = System.Windows.Forms.Cursors:Default.
        this-object:rulePropertyGrid:DocCommentDescription:Location = new System.Drawing.Point(3, 18).
        this-object:rulePropertyGrid:DocCommentDescription:Name = "":U.
        this-object:rulePropertyGrid:DocCommentDescription:Size = new System.Drawing.Size(0, 52).
        this-object:rulePropertyGrid:DocCommentDescription:TabIndex = 1.
        this-object:rulePropertyGrid:DocCommentDescription:UseCompatibleTextRendering = true.
        this-object:rulePropertyGrid:DocCommentImage = ?.
        /*  */
        /*  */
        /*  */
        this-object:rulePropertyGrid:DocCommentTitle:Cursor = System.Windows.Forms.Cursors:Default.
        this-object:rulePropertyGrid:DocCommentTitle:Font = new System.Drawing.Font("Microsoft Sans Serif":U, Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold).
        this-object:rulePropertyGrid:DocCommentTitle:Location = new System.Drawing.Point(3, 3).
        this-object:rulePropertyGrid:DocCommentTitle:Name = "":U.
        this-object:rulePropertyGrid:DocCommentTitle:Size = new System.Drawing.Size(0, 0).
        this-object:rulePropertyGrid:DocCommentTitle:TabIndex = 0.
        this-object:rulePropertyGrid:DocCommentTitle:UseCompatibleTextRendering = true.
        this-object:rulePropertyGrid:DocCommentTitle:UseMnemonic = false.
        this-object:rulePropertyGrid:Enabled = false.
        this-object:rulePropertyGrid:HelpVisible = false.
        this-object:rulePropertyGrid:Location = new System.Drawing.Point(12, 38).
        this-object:rulePropertyGrid:Name = "rulePropertyGrid":U.
        this-object:rulePropertyGrid:SelectedObject = cast(resources:GetObject("rulePropertyGrid.SelectedObject":U), System.Object).
        this-object:rulePropertyGrid:ShowCustomProperties = true.
        this-object:rulePropertyGrid:Size = new System.Drawing.Size(510, 306).
        this-object:rulePropertyGrid:TabIndex = 9.
        /*  */
        /*  */
        /*  */
        this-object:rulePropertyGrid:ToolStrip:AccessibleName = "ToolBar":U.
        this-object:rulePropertyGrid:ToolStrip:AccessibleRole = System.Windows.Forms.AccessibleRole:ToolBar.
        this-object:rulePropertyGrid:ToolStrip:AllowMerge = false.
        this-object:rulePropertyGrid:ToolStrip:AutoSize = false.
        this-object:rulePropertyGrid:ToolStrip:CanOverflow = false.
        this-object:rulePropertyGrid:ToolStrip:Dock = System.Windows.Forms.DockStyle:None.
        this-object:rulePropertyGrid:ToolStrip:GripStyle = System.Windows.Forms.ToolStripGripStyle:Hidden.
        this-object:rulePropertyGrid:ToolStrip:Location = new System.Drawing.Point(0, 1).
        this-object:rulePropertyGrid:ToolStrip:Name = "":U.
        this-object:rulePropertyGrid:ToolStrip:Padding = new System.Windows.Forms.Padding(2, 0, 1, 0).
        this-object:rulePropertyGrid:ToolStrip:Size = new System.Drawing.Size(510, 25).
        this-object:rulePropertyGrid:ToolStrip:TabIndex = 1.
        this-object:rulePropertyGrid:ToolStrip:TabStop = true.
        this-object:rulePropertyGrid:ToolStrip:Text = "PropertyGridToolBar":U.
        this-object:rulePropertyGrid:UseCompatibleTextRendering = true.
        /*  */
        /* Rule */
        /*  */
        this-object:AcceptButton = this-object:buttonOk.
        this-object:CancelButton = this-object:buttonCancel.
        this-object:ClientSize = new System.Drawing.Size(534, 385).
        this-object:Controls:Add(this-object:rulePropertyGrid).
        this-object:Controls:Add(this-object:lblClass).
        this-object:Controls:Add(this-object:textClass).
        this-object:Controls:Add(this-object:buttonCancel).
        this-object:Controls:Add(this-object:buttonOk).
        this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
        this-object:MaximizeBox = false.
        this-object:MinimizeBox = false.
        this-object:Name = "Rule":U.
        this-object:ShowInTaskbar = false.
        this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
        this-object:Text = "ruleInstance":U.
        cast(this-object:rulesErrorProvider, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method. 
 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void SaveProperties(  ):
        
        define variable cnt as integer no-undo.
        
        do cnt = 0 to rulePropertyGrid:Item:Count - 1:
            if rulePropertyGrid:Item:Item[cnt]:IsReadOnly then
                next.
            
            case rulePropertyGrid:Item:Item[cnt]:Type:FullName:
                when "System.String":U then
                    do:
                        stringIConvertible = rulePropertyGrid:Item:Item[cnt]:Value.
                        classInstance:SetPropertyValue(ruleInstance, rulePropertyGrid:Item:Item[cnt]:Name, stringIConvertible).                    
                    end.
                when "System.Int32":U then
                    do:                    
                        int32IConvertible = rulePropertyGrid:Item:Item[cnt]:Value.                    
                        classInstance:SetPropertyValue(ruleInstance, rulePropertyGrid:Item:Item[cnt]:Name, int32IConvertible).
                    end.
                when "System.Int64":U then
                    do:
                        int64IConvertible = rulePropertyGrid:Item:Item[cnt]:Value.
                        classInstance:SetPropertyValue(ruleInstance, rulePropertyGrid:Item:Item[cnt]:Name, int64IConvertible).
                    end.
                when "System.Double":U
                or 
                when "System.Single":U
                or 
                when "System.Decimal":U then
                    do:
                        doubleIConvertible = rulePropertyGrid:Item:Item[cnt]:Value.
                        classInstance:SetPropertyValue(ruleInstance, rulePropertyGrid:Item:Item[cnt]:Name, doubleIConvertible).
                    end.
                when "System.Boolean":U then
                    do:
                        boolIConvertible = rulePropertyGrid:Item:Item[cnt]:Value.
                        classInstance:SetPropertyValue(ruleInstance, rulePropertyGrid:Item:Item[cnt]:Name, boolIConvertible).
                    end.
                when "System.Date":U then
                    do:
                        dateIConvertible = rulePropertyGrid:Item:Item[cnt]:Value.
                        classInstance:SetPropertyValue(ruleInstance, rulePropertyGrid:Item:Item[cnt]:Name, dateIConvertible).
                    end.
                when "System.DateTime":U then
                    do:
                        datetimeIConvertible = rulePropertyGrid:Item:Item[cnt]:Value.
                        classInstance:SetPropertyValue(ruleInstance, rulePropertyGrid:Item:Item[cnt]:Name, datetimeIConvertible).
                    end.            
            end case.
        end.
        
        return.

    end method.

    method public void ShowModalDialog(  ):
               
        textClass:Text = ruleClass.
        if ruleClass <> "" then        
            ValidateForm().
              
        wait-for this-object:ShowDialog().

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void ShowProperties(  ):
        
        define variable cnt         as integer   no-undo.
        define variable readOnly    as logical   no-undo.
        define variable ruleSection as character no-undo.
           
        rulePropertyGrid:Enabled = true. 
        ruleProperties = ruleInstance:GetClass():GetProperties().        
        do cnt = 1 to extent(ruleProperties):          
            if ruleProperties[cnt]:DeclaringClass:TypeName = "Progress.Lang.Object":U then
                next.
               
            if ruleProperties[cnt]:DeclaringClass:TypeName = "Prolint.Rules.AbstractRule":U then
                ruleSection = "Core":T.
            else
                ruleSection = "Misc":T.
            readOnly = (ruleProperties[cnt]:SetterAccessMode <> Progress.Reflect.AccessMode:Public).
            case ruleProperties[cnt]:DataType:
                when Progress.Reflect.DataType:Character
                or 
                when Progress.Reflect.DataType:Longchar then
                    do:
                        stringIConvertible = ruleProperties[cnt]:Get(ruleInstance).
                        rulePropertyGrid:Item:Add(ruleProperties[cnt]:name, stringIConvertible, readOnly, ruleSection, "", true).
                    end.
                when Progress.Reflect.DataType:Integer then
                    do:
                        int32IConvertible = ruleProperties[cnt]:Get(ruleInstance).
                        rulePropertyGrid:Item:Add(ruleProperties[cnt]:name, int32IConvertible, readOnly, ruleSection, "", true).
                    end.
                when Progress.Reflect.DataType:Int64 then
                    do:
                        int64IConvertible = ruleProperties[cnt]:Get(ruleInstance).
                        rulePropertyGrid:Item:Add(ruleProperties[cnt]:name, int64IConvertible, readOnly, ruleSection, "", true).
                    end.
                when Progress.Reflect.DataType:Decimal then
                    do:
                        doubleIConvertible = ruleProperties[cnt]:Get(ruleInstance).
                        rulePropertyGrid:Item:Add(ruleProperties[cnt]:name, doubleIConvertible, readOnly, ruleSection, "", true).
                    end.
                when Progress.Reflect.DataType:Logical then
                    do:
                        boolIConvertible = ruleProperties[cnt]:Get(ruleInstance).
                        rulePropertyGrid:Item:Add(ruleProperties[cnt]:name, boolIConvertible, readOnly, ruleSection, "", true).
                    end.
                when Progress.Reflect.DataType:Date then
                    do:
                        dateIConvertible = ruleProperties[cnt]:Get(ruleInstance).
                        rulePropertyGrid:Item:Add(ruleProperties[cnt]:name, dateIConvertible, readOnly, ruleSection, "", true).
                    end.
                when Progress.Reflect.DataType:DateTime then
                    do:
                        datetimeIConvertible = ruleProperties[cnt]:Get(ruleInstance).
                        rulePropertyGrid:Item:Add(ruleProperties[cnt]:name, datetimeIConvertible, readOnly, ruleSection, "", true).
                    end.
            end case.                              
                        
        end.
        rulePropertyGrid:Refresh().
        
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void textClass_Leave( input sender as System.Object, input e as System.EventArgs ):
        ValidateForm().
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private logical ValidateForm(  ):
        
        rulesErrorProvider:Clear().                
        ruleInstance = Prolint.Rules.Factory:GetInstance(profileName, textClass:Text).
        classInstance = ruleInstance:GetClass().
        ShowProperties().
        textClass:ReadOnly = true.   
             
        return true.
        
        catch e as Progress.Lang.Error :
            rulesErrorProvider:SetError(textClass, e:GetMessage(1)).
            return false.        
        end catch.
       
    end method.

 
end class.
