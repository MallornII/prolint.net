 
/*------------------------------------------------------------------------
   File        : lintprof
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Mon Dec 17 11:54:42 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Windows.Form.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS lintprof INHERITS Form USE-WIDGET-POOL FINAL:
    
    {prolint/profile.i &ACCESS_MOD="PRIVATE"} 
    
    DEFINE PRIVATE VARIABLE btnSaveProfile                     AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE btnRemoveRule                      AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE btnRemoveProfile                   AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE btnEditRule                        AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE btnAddRule                         AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE btnAddProfile                      AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE BSRules                            AS Progress.Data.BindingSource                    NO-UNDO.
    DEFINE PRIVATE VARIABLE BSProfiles                         AS Progress.Data.BindingSource                    NO-UNDO.
    DEFINE PRIVATE VARIABLE comboProfiles                      AS System.Windows.Forms.ComboBox                  NO-UNDO.
    DEFINE PRIVATE VARIABLE components                         AS System.ComponentModel.IContainer               NO-UNDO.
    DEFINE PRIVATE VARIABLE groupProfile                       AS System.Windows.Forms.GroupBox                  NO-UNDO.
    DEFINE PRIVATE VARIABLE profileFileDialog                  AS System.Windows.Forms.SaveFileDialog            NO-UNDO.
    DEFINE PRIVATE VARIABLE RuleDescription                    AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE severityDataGridViewTextBoxColumn  AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE ruleIdDataGridViewTextBoxColumn    AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE ruleClassDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE RulesGrid                          AS System.Windows.Forms.DataGridView              NO-UNDO.
    DEFINE PRIVATE VARIABLE profileFile                        AS CHARACTER                                      NO-UNDO.
    DEFINE PRIVATE VARIABLE queryProfiles                      AS HANDLE                                         NO-UNDO.
    DEFINE PRIVATE VARIABLE queryRules                         AS HANDLE                                         NO-UNDO.

        
    CONSTRUCTOR PUBLIC lintprof (  ):       
        
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        
        profileFile = SEARCH("profiles.xml":U).
        IF profileFile <> ? THEN        
            DATASET dsProfile:READ-XML( "FILE":U, profileFile, "EMPTY":U, ?, FALSE).
        ELSE
            profileFile = "profiles.xml":U.           
           
        ASSIGN
            profileFileDialog:FileName         = GetFileName(profileFile)
            profileFileDialog:InitialDirectory = GetFilePath(profileFile).
            
        FIND FIRST ttProfile WHERE ttProfile.ProfileName = "default":U NO-ERROR.
        IF NOT AVAILABLE(ttProfile) THEN
        DO:
            CREATE ttProfile.
            ttProfile.ProfileName = "default":U.
        END.
        
        CREATE QUERY queryProfiles.
        queryProfiles:ADD-BUFFER(BUFFER ttProfile:HANDLE).
        queryProfiles:QUERY-PREPARE("FOR EACH ttProfile":U).
        queryProfiles:QUERY-OPEN().
        bsProfiles:HANDLE = queryProfiles.
        
        CREATE QUERY queryRules.
        queryRules:ADD-BUFFER(BUFFER ttRule:HANDLE).
        RefreshRules(ttProfile.ProfileName).
        bsRules:HANDLE = queryRules.
        
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.

    END CONSTRUCTOR.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID btnAddProfile_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
        DEFINE VARIABLE newProfileName AS CHARACTER  NO-UNDO.
        DEFINE VARIABLE profileDialog  AS newprofile NO-UNDO.
		
        profileDialog = NEW newprofile().		
        profileDialog:ShowModalDialog().
        IF profileDialog:DialogResult = System.Windows.Forms.DialogResult:OK THEN
        DO:
            CREATE ttProfile.
            ttProfile.ProfileName = profileDialog:profileName.
            RefreshProfiles(TRUE).
        END.
        profileDialog:Dispose().
		
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID btnAddRule_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        DEFINE VARIABLE ruleDialog AS editrule NO-UNDO.
        
        ruleDialog = NEW editrule().
        ruleDialog:Text = "Add new rule".
        ruleDialog:ShowModalDialog().
        IF ruleDialog:DialogResult = System.Windows.Forms.DialogResult:OK THEN
        DO:
            CREATE ttRule.
            ASSIGN
                ttRule.ProfileName     = comboProfiles:SelectedValue:ToString()
                ttRule.RuleClass       = ruleDialog:ruleClass
                ttRule.RuleId          = ruleDialog:ruleId
                ttRule.RuleDescription = ruleDialog:RuleDescription
                ttRule.Severity        = ruleDialog:Severity.
            
            RefreshRules(comboProfiles:SelectedValue:ToString()).
        END.
        ruleDialog:Dispose().
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID btnEditRule_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        DEFINE VARIABLE ruleDialog   AS editrule  NO-UNDO.
        DEFINE VARIABLE currentClass AS CHARACTER NO-UNDO.
        
        IF VALID-OBJECT(RulesGrid:CurrentRow) THEN
        DO:
            currentClass = RulesGrid:CurrentRow:Cells:Item[1]:Value:ToString().
            FIND FIRST ttRule WHERE ttRule.RuleClass = currentClass.
            ruleDialog = NEW editrule().       
            ASSIGN     
                ruleDialog:Text            = "Edit rule"            
                ruleDialog:ruleId          = ttRule.RuleId
                ruleDialog:ruleClass       = ttRule.RuleClass
                ruleDialog:ruleDescription = ttRule.RuleDescription
                ruleDialog:Severity        = ttRule.Severity.
            ruleDialog:ShowModalDialog().
            IF ruleDialog:DialogResult = System.Windows.Forms.DialogResult:OK THEN
            DO:      
                ASSIGN
                    ttRule.ProfileName     = comboProfiles:SelectedValue:ToString()
                    ttRule.RuleClass       = ruleDialog:ruleClass
                    ttRule.RuleId          = ruleDialog:ruleId
                    ttRule.RuleDescription = ruleDialog:RuleDescription
                    ttRule.Severity        = ruleDialog:Severity.                
                RefreshRules(comboProfiles:SelectedValue:ToString()).
            END.
            ruleDialog:Dispose().
        END.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID btnRemoveProfile_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        DEFINE VARIABLE confirmDelete AS LOGICAL NO-UNDO.
		
        IF comboProfiles:SelectedIndex >= 0 THEN
        DO:
            IF comboProfiles:SelectedValue:ToString() <> "default":U THEN
            DO:
                MESSAGE SUBSTITUTE("Are you sure you want to delete profile <&1> and all it's rules?":T, comboProfiles:SelectedValue:ToString())
                    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE confirmDelete.
                IF confirmDelete THEN
                DO:
                    FIND FIRST ttProfile WHERE ttProfile.ProfileName = comboProfiles:SelectedValue:ToString().
                    FOR EACH ttRule WHERE ttRule.ProfileName = ttProfile.ProfileName:
                        DELETE ttRule.
                    END.
                    DELETE ttProfile.
                    FIND FIRST ttProfile.               
                    RefreshProfiles(FALSE).
                END.
            END.
            ELSE
                MESSAGE "You can't delete default profile":T
                    VIEW-AS ALERT-BOX ERROR.	        
        END.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID btnRemoveRule_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
	    
        DEFINE VARIABLE confirmDelete AS LOGICAL   NO-UNDO.
        DEFINE VARIABLE currentClass  AS CHARACTER NO-UNDO.
	    
        IF VALID-OBJECT(RulesGrid:CurrentRow) THEN
        DO:            
            currentClass = RulesGrid:CurrentRow:Cells:Item[1]:Value:ToString().
            MESSAGE SUBSTITUTE("Are you sure you want to delete rule <&1>?":T, currentClass)
                VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE confirmDelete.
            IF confirmDelete THEN
            DO:
                FIND FIRST ttRule WHERE ttRule.RuleClass = currentClass.
                DELETE ttRule.
                RefreshRules(comboProfiles:SelectedValue:ToString()).
            END.
        END.
		
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID btnSaveProfile_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        DEFINE VARIABLE dialogResult AS System.Windows.Forms.DialogResult NO-UNDO.
        WAIT-FOR profileFileDialog:ShowDialog() SET dialogResult.
        IF dialogResult = System.Windows.Forms.DialogResult:OK THEN        
            DATASET dsProfile:WRITE-XML("FILE":U, profileFileDialog:FileName, TRUE, "UTF-8").

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID comboProfiles_SelectedIndexChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
        IF comboProfiles:SelectedIndex >= 0 THEN
            RefreshRules(comboProfiles:SelectedValue:ToString()).		
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE CHARACTER GetFileName( INPUT iFileName AS CHARACTER ):
        
        DEFINE VARIABLE localname AS CHARACTER NO-UNDO.
        
        localName = REPLACE(iFileName, "/", "~\").
        IF NUM-ENTRIES(localName, "~\") > 1 THEN
            localName = ENTRY(NUM-ENTRIES(localName, "~\"), localName, "~\").  
        RETURN localname.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE CHARACTER GetFilePath( INPUT iFileName AS CHARACTER ):
        
        DEFINE VARIABLE localPath AS CHARACTER NO-UNDO.
        
        localPath = REPLACE(iFileName, "/", "~\"). 
        IF INDEX(localPath, "~\") = 0 THEN
            localPath = "".
        ELSE
            localPath = SUBSTRING(localPath, 1, R-INDEX(localPath, "~\") - 1).

        RETURN localPath.

    END METHOD.

    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        THIS-OBJECT:components = NEW System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE tableDesc1 AS Progress.Data.TableDesc NO-UNDO.
        tableDesc1 = NEW Progress.Data.TableDesc("ttRule").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE tableDesc2 AS Progress.Data.TableDesc NO-UNDO.
        tableDesc2 = NEW Progress.Data.TableDesc("ttProfile").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE resources AS Progress.Util.ResourceManager NO-UNDO.
        resources = NEW Progress.Util.ResourceManager("lintprof").
        THIS-OBJECT:BSRules = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
        THIS-OBJECT:RulesGrid = NEW System.Windows.Forms.DataGridView().
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:ruleClassDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:severityDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:RuleDescription = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:comboProfiles = NEW System.Windows.Forms.ComboBox().
        THIS-OBJECT:BSProfiles = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
        THIS-OBJECT:groupProfile = NEW System.Windows.Forms.GroupBox().
        THIS-OBJECT:btnSaveProfile = NEW System.Windows.Forms.Button().
        THIS-OBJECT:btnRemoveProfile = NEW System.Windows.Forms.Button().
        THIS-OBJECT:btnAddProfile = NEW System.Windows.Forms.Button().
        THIS-OBJECT:btnAddRule = NEW System.Windows.Forms.Button().
        THIS-OBJECT:btnEditRule = NEW System.Windows.Forms.Button().
        THIS-OBJECT:btnRemoveRule = NEW System.Windows.Forms.Button().
        THIS-OBJECT:profileFileDialog = NEW System.Windows.Forms.SaveFileDialog().
        CAST(THIS-OBJECT:BSRules, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:RulesGrid, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:BSProfiles, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:groupProfile:SuspendLayout().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* BSRules */
        /*  */
        THIS-OBJECT:BSRules:MaxDataGuess = 0.
        THIS-OBJECT:BSRules:NoLOBs = FALSE.
        THIS-OBJECT:BSRules:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar0 AS "Progress.Data.TableDesc[]" NO-UNDO.
        arrayvar0 = NEW "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar1 AS Progress.Data.ColumnPropDesc EXTENT 4 NO-UNDO.
        arrayvar1[1] = NEW Progress.Data.ColumnPropDesc("RuleId", "Id", Progress.Data.DataType:CHARACTER).
        arrayvar1[2] = NEW Progress.Data.ColumnPropDesc("RuleClass", "Class", Progress.Data.DataType:CHARACTER).
        arrayvar1[3] = NEW Progress.Data.ColumnPropDesc("Severity", "Severity", Progress.Data.DataType:INTEGER).
        arrayvar1[4] = NEW Progress.Data.ColumnPropDesc("RuleDescription", "Description", Progress.Data.DataType:CHARACTER).
        tableDesc1:Columns = arrayvar1.
        THIS-OBJECT:BSRules:TableSchema = tableDesc1.
        /*  */
        /* RulesGrid */
        /*  */
        THIS-OBJECT:RulesGrid:AllowUserToAddRows = FALSE.
        THIS-OBJECT:RulesGrid:AllowUserToDeleteRows = FALSE.
        THIS-OBJECT:RulesGrid:AutoGenerateColumns = FALSE.
        THIS-OBJECT:RulesGrid:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar2 AS System.Windows.Forms.DataGridViewColumn EXTENT 4 NO-UNDO.
        arrayvar2[1] = THIS-OBJECT:ruleIdDataGridViewTextBoxColumn.
        arrayvar2[2] = THIS-OBJECT:ruleClassDataGridViewTextBoxColumn.
        arrayvar2[3] = THIS-OBJECT:severityDataGridViewTextBoxColumn.
        arrayvar2[4] = THIS-OBJECT:RuleDescription.
        THIS-OBJECT:RulesGrid:Columns:AddRange(arrayvar2).
        THIS-OBJECT:RulesGrid:DataSource = THIS-OBJECT:BSRules.
        THIS-OBJECT:RulesGrid:Location = NEW System.Drawing.Point(12, 71).
        THIS-OBJECT:RulesGrid:Name = "RulesGrid".
        THIS-OBJECT:RulesGrid:ReadOnly = TRUE.
        THIS-OBJECT:RulesGrid:Size = NEW System.Drawing.Size(1147, 486).
        THIS-OBJECT:RulesGrid:TabIndex = 0.
        /*  */
        /* ruleIdDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:DataPropertyName = "RuleId".
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:HeaderText = "Id".
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:Name = "ruleIdDataGridViewTextBoxColumn".
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:Width = 150.
        /*  */
        /* ruleClassDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:ruleClassDataGridViewTextBoxColumn:DataPropertyName = "RuleClass".
        THIS-OBJECT:ruleClassDataGridViewTextBoxColumn:HeaderText = "Class".
        THIS-OBJECT:ruleClassDataGridViewTextBoxColumn:Name = "ruleClassDataGridViewTextBoxColumn".
        THIS-OBJECT:ruleClassDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:ruleClassDataGridViewTextBoxColumn:Width = 200.
        /*  */
        /* severityDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:severityDataGridViewTextBoxColumn:DataPropertyName = "Severity".
        THIS-OBJECT:severityDataGridViewTextBoxColumn:HeaderText = "Severity".
        THIS-OBJECT:severityDataGridViewTextBoxColumn:Name = "severityDataGridViewTextBoxColumn".
        THIS-OBJECT:severityDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:severityDataGridViewTextBoxColumn:Width = 50.
        /*  */
        /* RuleDescription */
        /*  */
        THIS-OBJECT:RuleDescription:DataPropertyName = "RuleDescription".
        THIS-OBJECT:RuleDescription:HeaderText = "Description".
        THIS-OBJECT:RuleDescription:Name = "RuleDescription".
        THIS-OBJECT:RuleDescription:ReadOnly = TRUE.
        THIS-OBJECT:RuleDescription:Width = 700.
        /*  */
        /* comboProfiles */
        /*  */
        THIS-OBJECT:comboProfiles:DataSource = THIS-OBJECT:BSProfiles.
        THIS-OBJECT:comboProfiles:DisplayMember = "ProfileName".
        THIS-OBJECT:comboProfiles:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
        THIS-OBJECT:comboProfiles:FormattingEnabled = TRUE.
        THIS-OBJECT:comboProfiles:Location = NEW System.Drawing.Point(6, 19).
        THIS-OBJECT:comboProfiles:Name = "comboProfiles".
        THIS-OBJECT:comboProfiles:Size = NEW System.Drawing.Size(263, 21).
        THIS-OBJECT:comboProfiles:TabIndex = 1.
        THIS-OBJECT:comboProfiles:ValueMember = "ProfileName".
        THIS-OBJECT:comboProfiles:SelectedIndexChanged:Subscribe(THIS-OBJECT:comboProfiles_SelectedIndexChanged).
        /*  */
        /* BSProfiles */
        /*  */
        THIS-OBJECT:BSProfiles:MaxDataGuess = 0.
        THIS-OBJECT:BSProfiles:NoLOBs = FALSE.
        THIS-OBJECT:BSProfiles:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar3 AS "Progress.Data.TableDesc[]" NO-UNDO.
        arrayvar3 = NEW "Progress.Data.TableDesc[]"(0).
        tableDesc2:ChildTables = arrayvar3.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar4 AS Progress.Data.ColumnPropDesc EXTENT 1 NO-UNDO.
        arrayvar4[1] = NEW Progress.Data.ColumnPropDesc("ProfileName", "Name", Progress.Data.DataType:CHARACTER).
        tableDesc2:Columns = arrayvar4.
        THIS-OBJECT:BSProfiles:TableSchema = tableDesc2.
        /*  */
        /* groupProfile */
        /*  */
        THIS-OBJECT:groupProfile:Controls:Add(THIS-OBJECT:btnSaveProfile).
        THIS-OBJECT:groupProfile:Controls:Add(THIS-OBJECT:btnRemoveProfile).
        THIS-OBJECT:groupProfile:Controls:Add(THIS-OBJECT:btnAddProfile).
        THIS-OBJECT:groupProfile:Controls:Add(THIS-OBJECT:comboProfiles).
        THIS-OBJECT:groupProfile:Location = NEW System.Drawing.Point(12, 12).
        THIS-OBJECT:groupProfile:Name = "groupProfile".
        THIS-OBJECT:groupProfile:Size = NEW System.Drawing.Size(407, 53).
        THIS-OBJECT:groupProfile:TabIndex = 2.
        THIS-OBJECT:groupProfile:TabStop = FALSE.
        THIS-OBJECT:groupProfile:Text = "Profile".
        THIS-OBJECT:groupProfile:UseCompatibleTextRendering = TRUE.
        /*  */
        /* btnSaveProfile */
        /*  */
        THIS-OBJECT:btnSaveProfile:Image = CAST(resources:GetObject("btnSaveProfile.Image"), System.Drawing.Image).
        THIS-OBJECT:btnSaveProfile:Location = NEW System.Drawing.Point(363, 9).
        THIS-OBJECT:btnSaveProfile:Name = "btnSaveProfile".
        THIS-OBJECT:btnSaveProfile:Size = NEW System.Drawing.Size(38, 38).
        THIS-OBJECT:btnSaveProfile:TabIndex = 4.
        THIS-OBJECT:btnSaveProfile:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnSaveProfile:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:btnSaveProfile:Click:Subscribe(THIS-OBJECT:btnSaveProfile_Click).
        /*  */
        /* btnRemoveProfile */
        /*  */
        THIS-OBJECT:btnRemoveProfile:Image = CAST(resources:GetObject("btnRemoveProfile.Image"), System.Drawing.Image).
        THIS-OBJECT:btnRemoveProfile:Location = NEW System.Drawing.Point(319, 9).
        THIS-OBJECT:btnRemoveProfile:Name = "btnRemoveProfile".
        THIS-OBJECT:btnRemoveProfile:Size = NEW System.Drawing.Size(38, 38).
        THIS-OBJECT:btnRemoveProfile:TabIndex = 3.
        THIS-OBJECT:btnRemoveProfile:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnRemoveProfile:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:btnRemoveProfile:Click:Subscribe(THIS-OBJECT:btnRemoveProfile_Click).
        /*  */
        /* btnAddProfile */
        /*  */
        THIS-OBJECT:btnAddProfile:Image = CAST(resources:GetObject("btnAddProfile.Image"), System.Drawing.Image).
        THIS-OBJECT:btnAddProfile:Location = NEW System.Drawing.Point(275, 9).
        THIS-OBJECT:btnAddProfile:Name = "btnAddProfile".
        THIS-OBJECT:btnAddProfile:Size = NEW System.Drawing.Size(38, 38).
        THIS-OBJECT:btnAddProfile:TabIndex = 2.
        THIS-OBJECT:btnAddProfile:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnAddProfile:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:btnAddProfile:Click:Subscribe(THIS-OBJECT:btnAddProfile_Click).
        /*  */
        /* btnAddRule */
        /*  */
        THIS-OBJECT:btnAddRule:Image = CAST(resources:GetObject("btnAddRule.Image"), System.Drawing.Image).
        THIS-OBJECT:btnAddRule:Location = NEW System.Drawing.Point(1027, 21).
        THIS-OBJECT:btnAddRule:Name = "btnAddRule".
        THIS-OBJECT:btnAddRule:Size = NEW System.Drawing.Size(38, 38).
        THIS-OBJECT:btnAddRule:TabIndex = 3.
        THIS-OBJECT:btnAddRule:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnAddRule:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:btnAddRule:Click:Subscribe(THIS-OBJECT:btnAddRule_Click).
        /*  */
        /* btnEditRule */
        /*  */
        THIS-OBJECT:btnEditRule:Image = CAST(resources:GetObject("btnEditRule.Image"), System.Drawing.Image).
        THIS-OBJECT:btnEditRule:Location = NEW System.Drawing.Point(1071, 21).
        THIS-OBJECT:btnEditRule:Name = "btnEditRule".
        THIS-OBJECT:btnEditRule:Size = NEW System.Drawing.Size(38, 38).
        THIS-OBJECT:btnEditRule:TabIndex = 4.
        THIS-OBJECT:btnEditRule:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnEditRule:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:btnEditRule:Click:Subscribe(THIS-OBJECT:btnEditRule_Click).
        /*  */
        /* btnRemoveRule */
        /*  */
        THIS-OBJECT:btnRemoveRule:Image = CAST(resources:GetObject("btnRemoveRule.Image"), System.Drawing.Image).
        THIS-OBJECT:btnRemoveRule:Location = NEW System.Drawing.Point(1115, 21).
        THIS-OBJECT:btnRemoveRule:Name = "btnRemoveRule".
        THIS-OBJECT:btnRemoveRule:Size = NEW System.Drawing.Size(38, 38).
        THIS-OBJECT:btnRemoveRule:TabIndex = 5.
        THIS-OBJECT:btnRemoveRule:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnRemoveRule:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:btnRemoveRule:Click:Subscribe(THIS-OBJECT:btnRemoveRule_Click).
        /*  */
        /* profileFileDialog */
        /*  */
        THIS-OBJECT:profileFileDialog:DefaultExt = "xml".
        THIS-OBJECT:profileFileDialog:Filter = "XML Files|*.xml".
        /*  */
        /* lintprof */
        /*  */
        THIS-OBJECT:ClientSize = NEW System.Drawing.Size(1165, 569).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:btnRemoveRule).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:btnEditRule).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:btnAddRule).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:groupProfile).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:RulesGrid).
        THIS-OBJECT:Name = "lintprof".
        THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterScreen.
        THIS-OBJECT:Text = "prolint.net profile editor".
        CAST(THIS-OBJECT:BSRules, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:RulesGrid, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:BSProfiles, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:groupProfile:ResumeLayout(FALSE).
        THIS-OBJECT:ResumeLayout(FALSE).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE VOID RefreshProfiles( INPUT isNew AS LOGICAL ):
        
        queryProfiles:QUERY-CLOSE().        
        queryProfiles:QUERY-OPEN().
        IF isNew THEN
            comboProfiles:SelectedIndex = comboProfiles:Items:Count - 1.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE VOID RefreshRules( INPUT profileName AS CHARACTER ):
        
        queryRules:QUERY-CLOSE().
        queryRules:QUERY-PREPARE(SUBSTITUTE("FOR EACH ttRule WHERE ttRule.ProfileName = &1":U, QUOTER(profileName))).
        queryRules:QUERY-OPEN().
        RETURN.

    END METHOD.

    DESTRUCTOR PUBLIC lintprof ( ):

    END DESTRUCTOR.

END CLASS.