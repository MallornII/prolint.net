 /*------------------------------------------------------------------------
    File        : PropathEditor
    Purpose     : Form of Propath editor
    Syntax      : 
    Description : 
    Author(s)   : Andrew Ni
    Created     : 21.01.2019 21:46:37
    Notes       : 
  ----------------------------------------------------------------------*/
using Progress.Windows.Form.
using Utils.Strings.
using Utils.IO.
  
block-level on error undo, throw.
class Prolint.Forms.PropathEditor inherits Form  final: 

    define private variable bindingPropath as Progress.Data.BindingSource no-undo.
    define private variable btnUp as System.Windows.Forms.Button no-undo.
    define private variable btnRemove as System.Windows.Forms.Button no-undo.
    define private variable btnDown as System.Windows.Forms.Button no-undo.
    define private variable btnAdd as System.Windows.Forms.Button no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
    define private variable folderBrowserPath as System.Windows.Forms.FolderBrowserDialog no-undo.
    define private variable listPath as System.Windows.Forms.ListBox no-undo.
    define private variable queryPropath as handle no-undo.
    
    define temp-table ttPropath no-undo
        field order as integer 
        field PathValue as character.
    
    define public property LocalPropath as character no-undo 
    get.
    set. 

    constructor public PropathEditor( ):
    
        super().
        InitializeComponent ( ).
      
        create query queryPropath.
        queryPropath:add-buffer(buffer ttPropath:handle).       
        queryPropath:query-prepare("for each ttPropath by ttPropath.order":u).
        queryPropath:query-open().
        bindingPropath:handle = queryPropath.
              
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.        

    end constructor.

    destructor public PropathEditor( ):

        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.  

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnAdd_Click( input sender as System.Object, input e as System.EventArgs ):
		
		define variable dialogResult as System.Windows.Forms.DialogResult no-undo.
		define variable lastValue as integer no-undo.
		
		define buffer ttPropath for ttPropath.        
        
        wait-for folderBrowserPath:ShowDialog() set dialogResult.
        if dialogResult = System.Windows.Forms.DialogResult:OK then        
        do:
            find last ttPropath no-error.
            if available(ttPropath) then
                lastValue = ttPropath.order.
            else
                lastValue = 1.
            create ttPropath.
            assign
                ttPropath.PathValue = IO:MakePath(folderBrowserPath:SelectedPath)
                ttPropath.order = lastValue + 1.   
            RefreshPropath().
            listPath:SelectedIndex = lastValue.
        end.
        

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnDown_Click( input sender as System.Object, input e as System.EventArgs ):
	    
	    define variable oldIndex as integer no-undo.
		
		define buffer ttPropath for ttPropath.
		define buffer bttPropath for ttPropath.
        
        if listPath:SelectedIndex >= 2 then
        do:
            oldIndex = listPath:SelectedIndex.               
            find first ttPropath where ttPropath.PathValue = listPath:SelectedValue:ToString().
            find first bttPropath where bttPropath.order = ttPropath.order + 1 no-error.
            if available(bttPropath) then
            do:                
                assign 
                    ttPropath.order = ttPropath.order + 1
                    bttPropath.order = bttPropath.order - 1.
                RefreshPropath().                
                listPath:SelectedIndex = oldIndex + 1.                
            end.
        end.
        return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnRemove_Click( input sender as System.Object, input e as System.EventArgs ):
	    
	    define variable oldIndex as integer no-undo.
	    
	    define buffer ttPropath for ttPropath.		
		        
        if listPath:SelectedIndex >= 0 then
        do:
            oldIndex = listPath:SelectedIndex.
            if listPath:SelectedValue:ToString() <> ".":u
                and listPath:SelectedValue:ToString() <> "Prolint.pl" then
            do:                
                find first ttPropath where ttPropath.PathValue = listPath:SelectedValue:ToString().                
                delete ttPropath.
                find first ttPropath.               
                RefreshPropath().   
                listPath:SelectedIndex = min(oldIndex, listPath:TopIndex).             
            end.
            else
                message "You can't delete default path values":T
                    view-as alert-box error.            
        end.
        return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnUp_Click( input sender as System.Object, input e as System.EventArgs ):
	    
	    define variable oldIndex as integer no-undo.
	    
	    define buffer ttPropath for ttPropath.
	    define buffer bttPropath for ttPropath.
		
		if listPath:SelectedIndex >= 3 then
        do:
            oldIndex = listPath:SelectedIndex.               
            find first ttPropath where ttPropath.PathValue = listPath:SelectedValue:ToString().
            find first bttPropath where bttPropath.order = ttPropath.order - 1 no-error.
            if available(bttPropath) then
            do:                
                assign 
                    ttPropath.order = ttPropath.order - 1
                    bttPropath.order = bttPropath.order + 1.
                RefreshPropath().
                listPath:SelectedIndex = oldIndex - 1.
            end.
        end.
        return.

	end method.

    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
        define buffer ttPropath for ttPropath.
        
        LocalPropath = "".
        
        for each ttPropath by ttPropath.order:
            LocalPropath = Strings:AppendEntry(LocalPropath, ttPropath.PathValue).
        end.
        
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
        @VisualDesigner.FormMember (NeedsInitialize="true":U).
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("ttPropath":U).
        @VisualDesigner.FormMember (NeedsInitialize="true":U).
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("Prolint.Forms.PropathEditor":U).
        this-object:buttonOk = new System.Windows.Forms.Button().
        this-object:buttonCancel = new System.Windows.Forms.Button().
        this-object:folderBrowserPath = new System.Windows.Forms.FolderBrowserDialog().
        this-object:bindingPropath = new Progress.Data.BindingSource(this-object:components).
        this-object:btnAdd = new System.Windows.Forms.Button().
        this-object:btnRemove = new System.Windows.Forms.Button().
        this-object:btnUp = new System.Windows.Forms.Button().
        this-object:btnDown = new System.Windows.Forms.Button().
        this-object:listPath = new System.Windows.Forms.ListBox().
        cast(this-object:bindingPropath, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* buttonOk */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
        this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:buttonOk:Location = new System.Drawing.Point(206, 418).
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
        this-object:buttonCancel:Location = new System.Drawing.Point(287, 418).
        this-object:buttonCancel:Name = "buttonCancel":U.
        this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
        this-object:buttonCancel:TabIndex = 1.
        this-object:buttonCancel:Text = "Cancel":U.
        this-object:buttonCancel:UseCompatibleTextRendering = true.
        this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
        /*  */
        /* bindingPropath */
        /*  */
        this-object:bindingPropath:MaxDataGuess = 0.
        this-object:bindingPropath:NoLOBs = false.
        this-object:bindingPropath:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 1 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("PathValue":U, "Path":U, Progress.Data.DataType:CHARACTER).
        tableDesc1:Columns = arrayvar1.
        this-object:bindingPropath:TableSchema = tableDesc1.
        /*  */
        /* btnAdd */
        /*  */
        this-object:btnAdd:Image = cast(resources:GetObject("btnAdd.Image":U), System.Drawing.Image).
        this-object:btnAdd:Location = new System.Drawing.Point(520, 12).
        this-object:btnAdd:Name = "btnAdd":U.
        this-object:btnAdd:Size = new System.Drawing.Size(32, 32).
        this-object:btnAdd:TabIndex = 3.
        this-object:btnAdd:UseCompatibleTextRendering = true.
        this-object:btnAdd:UseVisualStyleBackColor = true.
        this-object:btnAdd:Click:Subscribe(this-object:btnAdd_Click).
        /*  */
        /* btnRemove */
        /*  */
        this-object:btnRemove:Image = cast(resources:GetObject("btnRemove.Image":U), System.Drawing.Image).
        this-object:btnRemove:Location = new System.Drawing.Point(520, 50).
        this-object:btnRemove:Name = "btnRemove":U.
        this-object:btnRemove:Size = new System.Drawing.Size(32, 32).
        this-object:btnRemove:TabIndex = 4.
        this-object:btnRemove:UseCompatibleTextRendering = true.
        this-object:btnRemove:UseVisualStyleBackColor = true.
        this-object:btnRemove:Click:Subscribe(this-object:btnRemove_Click).
        /*  */
        /* btnUp */
        /*  */
        this-object:btnUp:Image = cast(resources:GetObject("btnUp.Image":U), System.Drawing.Image).
        this-object:btnUp:Location = new System.Drawing.Point(520, 88).
        this-object:btnUp:Name = "btnUp":U.
        this-object:btnUp:Size = new System.Drawing.Size(32, 32).
        this-object:btnUp:TabIndex = 5.
        this-object:btnUp:UseCompatibleTextRendering = true.
        this-object:btnUp:UseVisualStyleBackColor = true.
        this-object:btnUp:Click:Subscribe(this-object:btnUp_Click).
        /*  */
        /* btnDown */
        /*  */
        this-object:btnDown:Image = cast(resources:GetObject("btnDown.Image":U), System.Drawing.Image).
        this-object:btnDown:Location = new System.Drawing.Point(520, 126).
        this-object:btnDown:Name = "btnDown":U.
        this-object:btnDown:Size = new System.Drawing.Size(32, 32).
        this-object:btnDown:TabIndex = 6.
        this-object:btnDown:UseCompatibleTextRendering = true.
        this-object:btnDown:UseVisualStyleBackColor = true.
        this-object:btnDown:Click:Subscribe(this-object:btnDown_Click).
        /*  */
        /* listPath */
        /*  */
        this-object:listPath:DataSource = this-object:bindingPropath.
        this-object:listPath:DisplayMember = "PathValue":U.
        this-object:listPath:FormattingEnabled = true.
        this-object:listPath:Location = new System.Drawing.Point(12, 12).
        this-object:listPath:Name = "listPath":U.
        this-object:listPath:Size = new System.Drawing.Size(502, 394).
        this-object:listPath:TabIndex = 7.
        this-object:listPath:ValueMember = "PathValue":U.
        /*  */
        /* PropathEditor */
        /*  */
        this-object:AcceptButton = this-object:buttonOk.
        this-object:CancelButton = this-object:buttonCancel.
        this-object:ClientSize = new System.Drawing.Size(561, 455).
        this-object:Controls:Add(this-object:listPath).
        this-object:Controls:Add(this-object:btnDown).
        this-object:Controls:Add(this-object:btnUp).
        this-object:Controls:Add(this-object:btnRemove).
        this-object:Controls:Add(this-object:btnAdd).
        this-object:Controls:Add(this-object:buttonCancel).
        this-object:Controls:Add(this-object:buttonOk).
        this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
        this-object:MaximizeBox = false.
        this-object:MinimizeBox = false.
        this-object:Name = "PropathEditor":U.
        this-object:ShowInTaskbar = false.
        this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
        this-object:Text = "PropathEditor":U.
        cast(this-object:bindingPropath, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method. 
 
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void RefreshPropath(  ):
        
        queryPropath:query-close().        
        queryPropath:query-open().
        return.        

    end method.

    method public void ShowModalDialog( ):
        
        define variable cnt as integer no-undo.
        
        do cnt = 1 to num-entries(LocalPropath):
            create ttPropath.
            assign
                ttPropath.order = cnt
                ttPropath.PathValue = entry(cnt, localPropath).            
        end.        
        RefreshPropath().
        
        wait-for this-object:ShowDialog().

    end method.


 
end class.
