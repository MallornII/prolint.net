 
/*------------------------------------------------------------------------
   File        : viewer
   Purpose     : Main form of profile editor
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 17.12.2018 11:54:42 ALMT
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.

block-level on error undo, throw.

class profiles.viewer inherits Form use-widget-pool final:
    
    {prolint/profile.i &ACCESS_MOD="PRIVATE"} 
    
    define private variable btnSaveProfile                     as System.Windows.Forms.Button                    no-undo.
    define private variable btnRemoveRule                      as System.Windows.Forms.Button                    no-undo.
    define private variable btnRemoveProfile                   as System.Windows.Forms.Button                    no-undo.
    define private variable btnEditRule                        as System.Windows.Forms.Button                    no-undo.
    define private variable btnAddRule                         as System.Windows.Forms.Button                    no-undo.
    define private variable btnAddProfile                      as System.Windows.Forms.Button                    no-undo.
    define private variable BSRules                            as Progress.Data.BindingSource                    no-undo.
    define private variable BSProfiles                         as Progress.Data.BindingSource                    no-undo.
    define private variable comboProfiles                      as System.Windows.Forms.ComboBox                  no-undo.
    define private variable components                         as System.ComponentModel.IContainer               no-undo.
    define private variable groupProfile                       as System.Windows.Forms.GroupBox                  no-undo.
    define private variable profileFileDialog                  as System.Windows.Forms.SaveFileDialog            no-undo.
    define private variable RuleDescription                    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable severityDataGridViewTextBoxColumn  as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable ruleIdDataGridViewTextBoxColumn    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable ruleClassDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable RulesGrid                          as System.Windows.Forms.DataGridView              no-undo.
    define private variable profileFile                        as character                                      no-undo.
    define private variable queryProfiles                      as handle                                         no-undo.
    define private variable queryRules                         as handle                                         no-undo.

        
    constructor public viewer (  ):       
        
        super().
        InitializeComponent().
        this-object:ComponentsCollection:ADD(this-object:components).
        
        profileFile = search("profiles.xml":U).
        if profileFile <> ? then        
            dataset dsProfile:read-xml( "FILE":U, profileFile, "EMPTY":U, ?, false).
        else
            profileFile = "profiles.xml":U.           
           
        assign
            profileFileDialog:FileName         = GetFileName(profileFile)
            profileFileDialog:InitialDirectory = GetFilePath(profileFile).
            
        find first ttProfile where ttProfile.ProfileName = "default":U no-error.
        if not available(ttProfile) then
        do:
            create ttProfile.
            ttProfile.ProfileName = "default":U.
        end.
        
        create query queryProfiles.
        queryProfiles:add-buffer(buffer ttProfile:HANDLE).
        queryProfiles:query-prepare("FOR EACH ttProfile":U).
        queryProfiles:query-open().
        bsProfiles:HANDLE = queryProfiles.
        
        create query queryRules.
        queryRules:add-buffer(buffer ttRule:HANDLE).
        RefreshRules(ttProfile.ProfileName).
        bsRules:HANDLE = queryRules.
        
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.

    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void btnAddProfile_Click( input sender as System.Object, input e as System.EventArgs ):
		
        define variable newProfileName as character  no-undo.
        define variable profileDialog  as profiles.baseform no-undo.
		
        profileDialog = new profiles.baseform().		
        profileDialog:ShowModalDialog().
        if profileDialog:DialogResult = System.Windows.Forms.DialogResult:OK then
        do:
            create ttProfile.
            ttProfile.ProfileName = profileDialog:profileName.
            RefreshProfiles(true).
        end.
        profileDialog:Dispose().
		
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void btnAddRule_Click( input sender as System.Object, input e as System.EventArgs ):
        define variable ruleDialog as profiles.ruleform no-undo.
        
        ruleDialog = new profiles.ruleform().
        ruleDialog:Text = "Add new rule".
        ruleDialog:ShowModalDialog().
        if ruleDialog:DialogResult = System.Windows.Forms.DialogResult:OK then
        do:
            create ttRule.
            assign
                ttRule.ProfileName     = comboProfiles:SelectedValue:ToString()
                ttRule.RuleClass       = ruleDialog:ruleClass
                ttRule.RuleId          = ruleDialog:ruleId
                ttRule.RuleDescription = ruleDialog:RuleDescription
                ttRule.Severity        = ruleDialog:Severity.
            
            RefreshRules(comboProfiles:SelectedValue:ToString()).
        end.
        ruleDialog:Dispose().
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void btnEditRule_Click( input sender as System.Object, input e as System.EventArgs ):
        define variable ruleDialog   as profiles.ruleform  no-undo.
        define variable currentClass as character no-undo.
        
        if valid-object(RulesGrid:CurrentRow) then
        do:
            currentClass = RulesGrid:CurrentRow:Cells:Item[1]:Value:ToString().
            find first ttRule where ttRule.RuleClass = currentClass.
            ruleDialog = new profiles.ruleform().       
            assign     
                ruleDialog:Text            = "Edit rule"            
                ruleDialog:ruleId          = ttRule.RuleId
                ruleDialog:ruleClass       = ttRule.RuleClass
                ruleDialog:ruleDescription = ttRule.RuleDescription
                ruleDialog:Severity        = ttRule.Severity.
            ruleDialog:ShowModalDialog().
            if ruleDialog:DialogResult = System.Windows.Forms.DialogResult:OK then
            do:      
                assign
                    ttRule.ProfileName     = comboProfiles:SelectedValue:ToString()
                    ttRule.RuleClass       = ruleDialog:ruleClass
                    ttRule.RuleId          = ruleDialog:ruleId
                    ttRule.RuleDescription = ruleDialog:RuleDescription
                    ttRule.Severity        = ruleDialog:Severity.                
                RefreshRules(comboProfiles:SelectedValue:ToString()).
            end.
            ruleDialog:Dispose().
        end.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void btnRemoveProfile_Click( input sender as System.Object, input e as System.EventArgs ):
        define variable confirmDelete as logical no-undo.
		
        if comboProfiles:SelectedIndex >= 0 then
        do:
            if comboProfiles:SelectedValue:ToString() <> "default":U then
            do:
                message substitute("Are you sure you want to delete profile <&1> and all it's rules?":T, comboProfiles:SelectedValue:ToString())
                    view-as alert-box question buttons yes-no update confirmDelete.
                if confirmDelete then
                do:
                    find first ttProfile where ttProfile.ProfileName = comboProfiles:SelectedValue:ToString().
                    for each ttRule where ttRule.ProfileName = ttProfile.ProfileName:
                        delete ttRule.
                    end.
                    delete ttProfile.
                    find first ttProfile.               
                    RefreshProfiles(false).
                end.
            end.
            else
                message "You can't delete default profile":T
                    view-as alert-box error.	        
        end.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void btnRemoveRule_Click( input sender as System.Object, input e as System.EventArgs ):
	    
        define variable confirmDelete as logical   no-undo.
        define variable currentClass  as character no-undo.
	    
        if valid-object(RulesGrid:CurrentRow) then
        do:            
            currentClass = RulesGrid:CurrentRow:Cells:Item[1]:Value:ToString().
            message substitute("Are you sure you want to delete rule <&1>?":T, currentClass)
                view-as alert-box question buttons yes-no update confirmDelete.
            if confirmDelete then
            do:
                find first ttRule where ttRule.RuleClass = currentClass.
                delete ttRule.
                RefreshRules(comboProfiles:SelectedValue:ToString()).
            end.
        end.
		
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void btnSaveProfile_Click( input sender as System.Object, input e as System.EventArgs ):
        define variable dialogResult as System.Windows.Forms.DialogResult no-undo.
        wait-for profileFileDialog:ShowDialog() set dialogResult.
        if dialogResult = System.Windows.Forms.DialogResult:OK then        
            dataset dsProfile:write-xml("FILE":U, profileFileDialog:FileName, true, "UTF-8").

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void comboProfiles_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
		
        if comboProfiles:SelectedIndex >= 0 then
            RefreshRules(comboProfiles:SelectedValue:ToString()).		
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private character GetFileName( input iFileName as character ):
        
        define variable localname as character no-undo.
        
        localName = replace(iFileName, "/", "~\").
        if num-entries(localName, "~\") > 1 then
            localName = entry(num-entries(localName, "~\"), localName, "~\").  
        return localname.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private character GetFilePath( input iFileName as character ):
        
        define variable localPath as character no-undo.
        
        localPath = replace(iFileName, "/", "~\"). 
        if index(localPath, "~\") = 0 then
            localPath = "".
        else
            localPath = substring(localPath, 1, r-index(localPath, "~\") - 1).

        return localPath.

    end method.

    method private void InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("ttRule").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc2 as Progress.Data.TableDesc no-undo.
        tableDesc2 = new Progress.Data.TableDesc("ttProfile").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("lintprof").
        this-object:BSRules = new Progress.Data.BindingSource(this-object:components).
        this-object:RulesGrid = new System.Windows.Forms.DataGridView().
        this-object:ruleIdDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:ruleClassDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:severityDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:RuleDescription = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:comboProfiles = new System.Windows.Forms.ComboBox().
        this-object:BSProfiles = new Progress.Data.BindingSource(this-object:components).
        this-object:groupProfile = new System.Windows.Forms.GroupBox().
        this-object:btnSaveProfile = new System.Windows.Forms.Button().
        this-object:btnRemoveProfile = new System.Windows.Forms.Button().
        this-object:btnAddProfile = new System.Windows.Forms.Button().
        this-object:btnAddRule = new System.Windows.Forms.Button().
        this-object:btnEditRule = new System.Windows.Forms.Button().
        this-object:btnRemoveRule = new System.Windows.Forms.Button().
        this-object:profileFileDialog = new System.Windows.Forms.SaveFileDialog().
        cast(this-object:BSRules, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:RulesGrid, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:BSProfiles, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:groupProfile:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* BSRules */
        /*  */
        this-object:BSRules:MaxDataGuess = 0.
        this-object:BSRules:NoLOBs = false.
        this-object:BSRules:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 4 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("RuleId", "Id", Progress.Data.DataType:CHARACTER).
        arrayvar1[2] = new Progress.Data.ColumnPropDesc("RuleClass", "Class", Progress.Data.DataType:CHARACTER).
        arrayvar1[3] = new Progress.Data.ColumnPropDesc("Severity", "Severity", Progress.Data.DataType:INTEGER).
        arrayvar1[4] = new Progress.Data.ColumnPropDesc("RuleDescription", "Description", Progress.Data.DataType:CHARACTER).
        tableDesc1:Columns = arrayvar1.
        this-object:BSRules:TableSchema = tableDesc1.
        /*  */
        /* RulesGrid */
        /*  */
        this-object:RulesGrid:AllowUserToAddRows = false.
        this-object:RulesGrid:AllowUserToDeleteRows = false.
        this-object:RulesGrid:AutoGenerateColumns = false.
        this-object:RulesGrid:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as System.Windows.Forms.DataGridViewColumn extent 4 no-undo.
        arrayvar2[1] = this-object:ruleIdDataGridViewTextBoxColumn.
        arrayvar2[2] = this-object:ruleClassDataGridViewTextBoxColumn.
        arrayvar2[3] = this-object:severityDataGridViewTextBoxColumn.
        arrayvar2[4] = this-object:RuleDescription.
        this-object:RulesGrid:Columns:AddRange(arrayvar2).
        this-object:RulesGrid:DataSource = this-object:BSRules.
        this-object:RulesGrid:Location = new System.Drawing.Point(12, 71).
        this-object:RulesGrid:Name = "RulesGrid".
        this-object:RulesGrid:ReadOnly = true.
        this-object:RulesGrid:Size = new System.Drawing.Size(1147, 486).
        this-object:RulesGrid:TabIndex = 0.
        /*  */
        /* ruleIdDataGridViewTextBoxColumn */
        /*  */
        this-object:ruleIdDataGridViewTextBoxColumn:DataPropertyName = "RuleId".
        this-object:ruleIdDataGridViewTextBoxColumn:HeaderText = "Id".
        this-object:ruleIdDataGridViewTextBoxColumn:Name = "ruleIdDataGridViewTextBoxColumn".
        this-object:ruleIdDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:ruleIdDataGridViewTextBoxColumn:Width = 150.
        /*  */
        /* ruleClassDataGridViewTextBoxColumn */
        /*  */
        this-object:ruleClassDataGridViewTextBoxColumn:DataPropertyName = "RuleClass".
        this-object:ruleClassDataGridViewTextBoxColumn:HeaderText = "Class".
        this-object:ruleClassDataGridViewTextBoxColumn:Name = "ruleClassDataGridViewTextBoxColumn".
        this-object:ruleClassDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:ruleClassDataGridViewTextBoxColumn:Width = 200.
        /*  */
        /* severityDataGridViewTextBoxColumn */
        /*  */
        this-object:severityDataGridViewTextBoxColumn:DataPropertyName = "Severity".
        this-object:severityDataGridViewTextBoxColumn:HeaderText = "Severity".
        this-object:severityDataGridViewTextBoxColumn:Name = "severityDataGridViewTextBoxColumn".
        this-object:severityDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:severityDataGridViewTextBoxColumn:Width = 50.
        /*  */
        /* RuleDescription */
        /*  */
        this-object:RuleDescription:DataPropertyName = "RuleDescription".
        this-object:RuleDescription:HeaderText = "Description".
        this-object:RuleDescription:Name = "RuleDescription".
        this-object:RuleDescription:ReadOnly = true.
        this-object:RuleDescription:Width = 700.
        /*  */
        /* comboProfiles */
        /*  */
        this-object:comboProfiles:DataSource = this-object:BSProfiles.
        this-object:comboProfiles:DisplayMember = "ProfileName".
        this-object:comboProfiles:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
        this-object:comboProfiles:FormattingEnabled = true.
        this-object:comboProfiles:Location = new System.Drawing.Point(6, 19).
        this-object:comboProfiles:Name = "comboProfiles".
        this-object:comboProfiles:Size = new System.Drawing.Size(263, 21).
        this-object:comboProfiles:TabIndex = 1.
        this-object:comboProfiles:ValueMember = "ProfileName".
        this-object:comboProfiles:SelectedIndexChanged:Subscribe(this-object:comboProfiles_SelectedIndexChanged).
        /*  */
        /* BSProfiles */
        /*  */
        this-object:BSProfiles:MaxDataGuess = 0.
        this-object:BSProfiles:NoLOBs = false.
        this-object:BSProfiles:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar3 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar3 = new "Progress.Data.TableDesc[]"(0).
        tableDesc2:ChildTables = arrayvar3.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar4 as Progress.Data.ColumnPropDesc extent 1 no-undo.
        arrayvar4[1] = new Progress.Data.ColumnPropDesc("ProfileName", "Name", Progress.Data.DataType:CHARACTER).
        tableDesc2:Columns = arrayvar4.
        this-object:BSProfiles:TableSchema = tableDesc2.
        /*  */
        /* groupProfile */
        /*  */
        this-object:groupProfile:Controls:Add(this-object:btnSaveProfile).
        this-object:groupProfile:Controls:Add(this-object:btnRemoveProfile).
        this-object:groupProfile:Controls:Add(this-object:btnAddProfile).
        this-object:groupProfile:Controls:Add(this-object:comboProfiles).
        this-object:groupProfile:Location = new System.Drawing.Point(12, 12).
        this-object:groupProfile:Name = "groupProfile".
        this-object:groupProfile:Size = new System.Drawing.Size(407, 53).
        this-object:groupProfile:TabIndex = 2.
        this-object:groupProfile:TabStop = false.
        this-object:groupProfile:Text = "Profile".
        this-object:groupProfile:UseCompatibleTextRendering = true.
        /*  */
        /* btnSaveProfile */
        /*  */
        this-object:btnSaveProfile:Image = cast(resources:GetObject("btnSaveProfile.Image"), System.Drawing.Image).
        this-object:btnSaveProfile:Location = new System.Drawing.Point(363, 9).
        this-object:btnSaveProfile:Name = "btnSaveProfile".
        this-object:btnSaveProfile:Size = new System.Drawing.Size(38, 38).
        this-object:btnSaveProfile:TabIndex = 4.
        this-object:btnSaveProfile:UseCompatibleTextRendering = true.
        this-object:btnSaveProfile:UseVisualStyleBackColor = true.
        this-object:btnSaveProfile:Click:Subscribe(this-object:btnSaveProfile_Click).
        /*  */
        /* btnRemoveProfile */
        /*  */
        this-object:btnRemoveProfile:Image = cast(resources:GetObject("btnRemoveProfile.Image"), System.Drawing.Image).
        this-object:btnRemoveProfile:Location = new System.Drawing.Point(319, 9).
        this-object:btnRemoveProfile:Name = "btnRemoveProfile".
        this-object:btnRemoveProfile:Size = new System.Drawing.Size(38, 38).
        this-object:btnRemoveProfile:TabIndex = 3.
        this-object:btnRemoveProfile:UseCompatibleTextRendering = true.
        this-object:btnRemoveProfile:UseVisualStyleBackColor = true.
        this-object:btnRemoveProfile:Click:Subscribe(this-object:btnRemoveProfile_Click).
        /*  */
        /* btnAddProfile */
        /*  */
        this-object:btnAddProfile:Image = cast(resources:GetObject("btnAddProfile.Image"), System.Drawing.Image).
        this-object:btnAddProfile:Location = new System.Drawing.Point(275, 9).
        this-object:btnAddProfile:Name = "btnAddProfile".
        this-object:btnAddProfile:Size = new System.Drawing.Size(38, 38).
        this-object:btnAddProfile:TabIndex = 2.
        this-object:btnAddProfile:UseCompatibleTextRendering = true.
        this-object:btnAddProfile:UseVisualStyleBackColor = true.
        this-object:btnAddProfile:Click:Subscribe(this-object:btnAddProfile_Click).
        /*  */
        /* btnAddRule */
        /*  */
        this-object:btnAddRule:Image = cast(resources:GetObject("btnAddRule.Image"), System.Drawing.Image).
        this-object:btnAddRule:Location = new System.Drawing.Point(1027, 21).
        this-object:btnAddRule:Name = "btnAddRule".
        this-object:btnAddRule:Size = new System.Drawing.Size(38, 38).
        this-object:btnAddRule:TabIndex = 3.
        this-object:btnAddRule:UseCompatibleTextRendering = true.
        this-object:btnAddRule:UseVisualStyleBackColor = true.
        this-object:btnAddRule:Click:Subscribe(this-object:btnAddRule_Click).
        /*  */
        /* btnEditRule */
        /*  */
        this-object:btnEditRule:Image = cast(resources:GetObject("btnEditRule.Image"), System.Drawing.Image).
        this-object:btnEditRule:Location = new System.Drawing.Point(1071, 21).
        this-object:btnEditRule:Name = "btnEditRule".
        this-object:btnEditRule:Size = new System.Drawing.Size(38, 38).
        this-object:btnEditRule:TabIndex = 4.
        this-object:btnEditRule:UseCompatibleTextRendering = true.
        this-object:btnEditRule:UseVisualStyleBackColor = true.
        this-object:btnEditRule:Click:Subscribe(this-object:btnEditRule_Click).
        /*  */
        /* btnRemoveRule */
        /*  */
        this-object:btnRemoveRule:Image = cast(resources:GetObject("btnRemoveRule.Image"), System.Drawing.Image).
        this-object:btnRemoveRule:Location = new System.Drawing.Point(1115, 21).
        this-object:btnRemoveRule:Name = "btnRemoveRule".
        this-object:btnRemoveRule:Size = new System.Drawing.Size(38, 38).
        this-object:btnRemoveRule:TabIndex = 5.
        this-object:btnRemoveRule:UseCompatibleTextRendering = true.
        this-object:btnRemoveRule:UseVisualStyleBackColor = true.
        this-object:btnRemoveRule:Click:Subscribe(this-object:btnRemoveRule_Click).
        /*  */
        /* profileFileDialog */
        /*  */
        this-object:profileFileDialog:DefaultExt = "xml".
        this-object:profileFileDialog:Filter = "XML Files|*.xml".
        /*  */
        /* lintprof */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(1165, 569).
        this-object:Controls:Add(this-object:btnRemoveRule).
        this-object:Controls:Add(this-object:btnEditRule).
        this-object:Controls:Add(this-object:btnAddRule).
        this-object:Controls:Add(this-object:groupProfile).
        this-object:Controls:Add(this-object:RulesGrid).
        this-object:Name = "lintprof".
        this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterScreen.
        this-object:Text = "prolint.net profile editor".
        cast(this-object:BSRules, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:RulesGrid, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:BSProfiles, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:groupProfile:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void RefreshProfiles( input isNew as logical ):
        
        queryProfiles:query-close().        
        queryProfiles:query-open().
        if isNew then
            comboProfiles:SelectedIndex = comboProfiles:Items:Count - 1.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void RefreshRules( input profileName as character ):
        
        queryRules:query-close().
        queryRules:query-prepare(substitute("FOR EACH ttRule WHERE ttRule.ProfileName = &1":U, quoter(profileName))).
        queryRules:query-open().
        return.

    end method.

    destructor public viewer ( ):

    end destructor.

end class.