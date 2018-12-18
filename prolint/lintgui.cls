 
/*------------------------------------------------------------------------
   File        : prolint.lintgui
   Purpose     : Main form for prolint
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 18.12.2018 15:10:41
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Windows.Form.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS prolint.lintgui INHERITS Form FINAL: 
    &SCOPED-DEFINE ACCESS_MOD PRIVATE
    
    {prolint/profile.i}
    {prolint/results.i}
    
    DEFINE PRIVATE VARIABLE bsProfiles                          AS Progress.Data.BindingSource                    NO-UNDO.
    DEFINE PRIVATE VARIABLE bsResults                           AS Progress.Data.BindingSource                    NO-UNDO.
    DEFINE PRIVATE VARIABLE comboProfile                        AS System.Windows.Forms.ComboBox                  NO-UNDO.
    DEFINE PRIVATE VARIABLE checkDebug                          AS System.Windows.Forms.CheckBox                  NO-UNDO.
    DEFINE PRIVATE VARIABLE btnLint                             AS System.Windows.Forms.Button                    NO-UNDO.
    DEFINE PRIVATE VARIABLE commentDataGridViewTextBoxColumn    AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE components                          AS System.ComponentModel.IContainer               NO-UNDO.
    DEFINE PRIVATE VARIABLE resultsView                         AS System.Windows.Forms.DataGridView              NO-UNDO.
    DEFINE PRIVATE VARIABLE severityDataGridViewTextBoxColumn   AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE ruleIdDataGridViewTextBoxColumn     AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE lineNumberDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE sourceFileDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
    DEFINE PRIVATE VARIABLE statusLint                          AS System.Windows.Forms.StatusStrip               NO-UNDO.
    DEFINE PRIVATE VARIABLE statusLabelFile                     AS System.Windows.Forms.ToolStripStatusLabel      NO-UNDO.
    DEFINE PRIVATE VARIABLE statusLabelAction                   AS System.Windows.Forms.ToolStripStatusLabel      NO-UNDO.
    DEFINE PRIVATE VARIABLE lintDialog                          AS System.Windows.Forms.OpenFileDialog            NO-UNDO.
    DEFINE PRIVATE VARIABLE profileFile                         AS CHARACTER                                      NO-UNDO.
    DEFINE PRIVATE VARIABLE sortOrder                           AS CHARACTER                                      NO-UNDO.
    DEFINE PRIVATE VARIABLE sortColumn                          AS CHARACTER                                      NO-UNDO.
    DEFINE PRIVATE VARIABLE queryProfiles                       AS HANDLE                                         NO-UNDO.  
    DEFINE PRIVATE VARIABLE queryResults                        AS HANDLE                                         NO-UNDO.
    DEFINE PRIVATE VARIABLE unitDataGridViewTextBoxColumn       AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.

        
    CONSTRUCTOR PUBLIC lintgui (  ):
        
        
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        
        profileFile = SEARCH("profiles.xml":U).
        IF profileFile <> ? THEN        
            DATASET dsProfile:READ-XML( "FILE":U, profileFile, "EMPTY":U, ?, FALSE).
        ELSE
            UNDO, THROW NEW Progress.Lang.AppError("<profiles.xml> not found":T).    
                
        FIND FIRST ttProfile NO-ERROR.
        IF NOT AVAILABLE(ttProfile) THEN
            UNDO, THROW NEW Progress.Lang.AppError("No profiles found":T).
        
        CREATE QUERY queryProfiles.
        queryProfiles:ADD-BUFFER(BUFFER ttProfile:HANDLE).
        queryProfiles:QUERY-PREPARE("FOR EACH ttProfile":U).
        queryProfiles:QUERY-OPEN().
        bsProfiles:HANDLE = queryProfiles.
        
        ASSIGN
            sortOrder  = " DESCENDING":U
            sortColumn = "Severity":U.
        CREATE QUERY queryResults.
        queryResults:ADD-BUFFER(BUFFER ttResult:HANDLE).
        RefreshResults().        
        bsResults:HANDLE = queryResults.
        
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.

    END CONSTRUCTOR.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID btnLint_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        DEFINE VARIABLE dialogResult AS System.Windows.Forms.DialogResult NO-UNDO.
        DEFINE VARIABLE lintInstance AS prolint.linter                    NO-UNDO.
        
        WAIT-FOR lintDialog:ShowDialog() SET dialogResult.
        IF dialogResult = System.Windows.Forms.DialogResult:OK THEN
        DO:
            lintInstance = NEW prolint.linter(comboProfile:SelectedValue:ToString()) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN
            DO:
                UpdateStatus("Create linter":T, ERROR-STATUS:GET-MESSAGE(1)).
                RETURN.
            END.
            lintInstance:IsDebug = checkDebug:Checked.
            lintInstance:PublishStatus:Subscribe(UpdateStatus).
            lintInstance:PublishResult:Subscribe(UpdateResult).
            lintInstance:Lint(lintDialog:FileName).
            RefreshResults().        
        END.
        RETURN.
        
        FINALLY:
            DELETE OBJECT lintInstance NO-ERROR.    
        END FINALLY.

    END METHOD.


    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        THIS-OBJECT:components = NEW System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE tableDesc1 AS Progress.Data.TableDesc NO-UNDO.
        tableDesc1 = NEW Progress.Data.TableDesc("ttResult").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE tableDesc2 AS Progress.Data.TableDesc NO-UNDO.
        tableDesc2 = NEW Progress.Data.TableDesc("ttProfile").
        THIS-OBJECT:bsResults = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
        THIS-OBJECT:lintDialog = NEW System.Windows.Forms.OpenFileDialog().
        THIS-OBJECT:bsProfiles = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
        THIS-OBJECT:resultsView = NEW System.Windows.Forms.DataGridView().
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:severityDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:sourceFileDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:lineNumberDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:unitDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:commentDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
        THIS-OBJECT:btnLint = NEW System.Windows.Forms.Button().
        THIS-OBJECT:comboProfile = NEW System.Windows.Forms.ComboBox().
        THIS-OBJECT:checkDebug = NEW System.Windows.Forms.CheckBox().
        THIS-OBJECT:statusLint = NEW System.Windows.Forms.StatusStrip().
        THIS-OBJECT:statusLabelAction = NEW System.Windows.Forms.ToolStripStatusLabel().
        THIS-OBJECT:statusLabelFile = NEW System.Windows.Forms.ToolStripStatusLabel().
        CAST(THIS-OBJECT:bsResults, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:bsProfiles, System.ComponentModel.ISupportInitialize):BeginInit().
        CAST(THIS-OBJECT:resultsView, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:statusLint:SuspendLayout().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* bsResults */
        /*  */
        THIS-OBJECT:bsResults:MaxDataGuess = 0.
        THIS-OBJECT:bsResults:NoLOBs = FALSE.
        THIS-OBJECT:bsResults:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar0 AS "Progress.Data.TableDesc[]" NO-UNDO.
        arrayvar0 = NEW "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar1 AS Progress.Data.ColumnPropDesc EXTENT 6 NO-UNDO.
        arrayvar1[1] = NEW Progress.Data.ColumnPropDesc("RuleId", "RuleId", Progress.Data.DataType:CHARACTER).
        arrayvar1[2] = NEW Progress.Data.ColumnPropDesc("Unit", "Unit", Progress.Data.DataType:CHARACTER).
        arrayvar1[3] = NEW Progress.Data.ColumnPropDesc("SourceFile", "Source file", Progress.Data.DataType:CHARACTER).
        arrayvar1[4] = NEW Progress.Data.ColumnPropDesc("Severity", "Severity", Progress.Data.DataType:INTEGER).
        arrayvar1[5] = NEW Progress.Data.ColumnPropDesc("Comment", "Comment", Progress.Data.DataType:CHARACTER).
        arrayvar1[6] = NEW Progress.Data.ColumnPropDesc("LineNumber", "Line number", Progress.Data.DataType:INTEGER).
        tableDesc1:Columns = arrayvar1.
        THIS-OBJECT:bsResults:TableSchema = tableDesc1.
        /*  */
        /* lintDialog */
        /*  */
        THIS-OBJECT:lintDialog:Filter = "OpenEdge executables|*.p;*.w;*.cls|All Files|*.*".
        /*  */
        /* bsProfiles */
        /*  */
        THIS-OBJECT:bsProfiles:MaxDataGuess = 0.
        THIS-OBJECT:bsProfiles:NoLOBs = FALSE.
        THIS-OBJECT:bsProfiles:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar2 AS "Progress.Data.TableDesc[]" NO-UNDO.
        arrayvar2 = NEW "Progress.Data.TableDesc[]"(0).
        tableDesc2:ChildTables = arrayvar2.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar3 AS Progress.Data.ColumnPropDesc EXTENT 1 NO-UNDO.
        arrayvar3[1] = NEW Progress.Data.ColumnPropDesc("ProfileName", "ProfileName", Progress.Data.DataType:CHARACTER).
        tableDesc2:Columns = arrayvar3.
        THIS-OBJECT:bsProfiles:TableSchema = tableDesc2.
        /*  */
        /* resultsView */
        /*  */
        THIS-OBJECT:resultsView:AllowUserToAddRows = FALSE.
        THIS-OBJECT:resultsView:AllowUserToDeleteRows = FALSE.
        THIS-OBJECT:resultsView:AutoGenerateColumns = FALSE.
        THIS-OBJECT:resultsView:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar4 AS System.Windows.Forms.DataGridViewColumn EXTENT 6 NO-UNDO.
        arrayvar4[1] = THIS-OBJECT:ruleIdDataGridViewTextBoxColumn.
        arrayvar4[2] = THIS-OBJECT:severityDataGridViewTextBoxColumn.
        arrayvar4[3] = THIS-OBJECT:sourceFileDataGridViewTextBoxColumn.
        arrayvar4[4] = THIS-OBJECT:lineNumberDataGridViewTextBoxColumn.
        arrayvar4[5] = THIS-OBJECT:unitDataGridViewTextBoxColumn.
        arrayvar4[6] = THIS-OBJECT:commentDataGridViewTextBoxColumn.
        THIS-OBJECT:resultsView:Columns:AddRange(arrayvar4).
        THIS-OBJECT:resultsView:DataSource = THIS-OBJECT:bsResults.
        THIS-OBJECT:resultsView:Location = NEW System.Drawing.Point(12, 45).
        THIS-OBJECT:resultsView:Name = "resultsView".
        THIS-OBJECT:resultsView:ReadOnly = TRUE.
        THIS-OBJECT:resultsView:Size = NEW System.Drawing.Size(1365, 460).
        THIS-OBJECT:resultsView:TabIndex = 0.
        THIS-OBJECT:resultsView:Sorted:Subscribe(THIS-OBJECT:resultsView_Sorted).
        /*  */
        /* ruleIdDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:DataPropertyName = "RuleId".
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:HeaderText = "RuleId".
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:Name = "ruleIdDataGridViewTextBoxColumn".
        THIS-OBJECT:ruleIdDataGridViewTextBoxColumn:ReadOnly = TRUE.
        /*  */
        /* severityDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:severityDataGridViewTextBoxColumn:DataPropertyName = "Severity".
        THIS-OBJECT:severityDataGridViewTextBoxColumn:HeaderText = "Severity".
        THIS-OBJECT:severityDataGridViewTextBoxColumn:Name = "severityDataGridViewTextBoxColumn".
        THIS-OBJECT:severityDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:severityDataGridViewTextBoxColumn:Width = 50.
        /*  */
        /* sourceFileDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:sourceFileDataGridViewTextBoxColumn:DataPropertyName = "SourceFile".
        THIS-OBJECT:sourceFileDataGridViewTextBoxColumn:HeaderText = "Source file".
        THIS-OBJECT:sourceFileDataGridViewTextBoxColumn:Name = "sourceFileDataGridViewTextBoxColumn".
        THIS-OBJECT:sourceFileDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:sourceFileDataGridViewTextBoxColumn:Width = 300.
        /*  */
        /* lineNumberDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:lineNumberDataGridViewTextBoxColumn:DataPropertyName = "LineNumber".
        THIS-OBJECT:lineNumberDataGridViewTextBoxColumn:HeaderText = "Line number".
        THIS-OBJECT:lineNumberDataGridViewTextBoxColumn:Name = "lineNumberDataGridViewTextBoxColumn".
        THIS-OBJECT:lineNumberDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:lineNumberDataGridViewTextBoxColumn:Width = 50.
        /*  */
        /* unitDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:unitDataGridViewTextBoxColumn:DataPropertyName = "Unit".
        THIS-OBJECT:unitDataGridViewTextBoxColumn:HeaderText = "Unit".
        THIS-OBJECT:unitDataGridViewTextBoxColumn:Name = "unitDataGridViewTextBoxColumn".
        THIS-OBJECT:unitDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:unitDataGridViewTextBoxColumn:Width = 300.
        /*  */
        /* commentDataGridViewTextBoxColumn */
        /*  */
        THIS-OBJECT:commentDataGridViewTextBoxColumn:DataPropertyName = "Comment".
        THIS-OBJECT:commentDataGridViewTextBoxColumn:HeaderText = "Comment".
        THIS-OBJECT:commentDataGridViewTextBoxColumn:Name = "commentDataGridViewTextBoxColumn".
        THIS-OBJECT:commentDataGridViewTextBoxColumn:ReadOnly = TRUE.
        THIS-OBJECT:commentDataGridViewTextBoxColumn:Width = 500.
        /*  */
        /* btnLint */
        /*  */
        THIS-OBJECT:btnLint:Location = NEW System.Drawing.Point(12, 12).
        THIS-OBJECT:btnLint:Name = "btnLint".
        THIS-OBJECT:btnLint:Size = NEW System.Drawing.Size(131, 27).
        THIS-OBJECT:btnLint:TabIndex = 1.
        THIS-OBJECT:btnLint:Text = "Lint...".
        THIS-OBJECT:btnLint:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnLint:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:btnLint:Click:Subscribe(THIS-OBJECT:btnLint_Click).
        /*  */
        /* comboProfile */
        /*  */
        THIS-OBJECT:comboProfile:DataSource = THIS-OBJECT:bsProfiles.
        THIS-OBJECT:comboProfile:DisplayMember = "ProfileName".
        THIS-OBJECT:comboProfile:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
        THIS-OBJECT:comboProfile:FormattingEnabled = TRUE.
        THIS-OBJECT:comboProfile:Location = NEW System.Drawing.Point(149, 14).
        THIS-OBJECT:comboProfile:Name = "comboProfile".
        THIS-OBJECT:comboProfile:Size = NEW System.Drawing.Size(142, 21).
        THIS-OBJECT:comboProfile:TabIndex = 2.
        THIS-OBJECT:comboProfile:ValueMember = "ProfileName".
        /*  */
        /* checkDebug */
        /*  */
        THIS-OBJECT:checkDebug:Location = NEW System.Drawing.Point(297, 11).
        THIS-OBJECT:checkDebug:Name = "checkDebug".
        THIS-OBJECT:checkDebug:Size = NEW System.Drawing.Size(104, 24).
        THIS-OBJECT:checkDebug:TabIndex = 3.
        THIS-OBJECT:checkDebug:Text = "Debug".
        THIS-OBJECT:checkDebug:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:checkDebug:UseVisualStyleBackColor = TRUE.
        /*  */
        /* statusLint */
        /*  */
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        DEFINE VARIABLE arrayvar5 AS System.Windows.Forms.ToolStripItem EXTENT 2 NO-UNDO.
        arrayvar5[1] = THIS-OBJECT:statusLabelAction.
        arrayvar5[2] = THIS-OBJECT:statusLabelFile.
        THIS-OBJECT:statusLint:Items:AddRange(arrayvar5).
        THIS-OBJECT:statusLint:Location = NEW System.Drawing.Point(0, 518).
        THIS-OBJECT:statusLint:Name = "statusLint".
        THIS-OBJECT:statusLint:Size = NEW System.Drawing.Size(1389, 22).
        THIS-OBJECT:statusLint:TabIndex = 4.
        THIS-OBJECT:statusLint:Text = "statusStrip1".
        /*  */
        /* statusLabelAction */
        /*  */
        THIS-OBJECT:statusLabelAction:AutoSize = FALSE.
        THIS-OBJECT:statusLabelAction:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Text.
        THIS-OBJECT:statusLabelAction:Name = "statusLabelAction".
        THIS-OBJECT:statusLabelAction:Overflow = System.Windows.Forms.ToolStripItemOverflow:Never.
        THIS-OBJECT:statusLabelAction:Size = NEW System.Drawing.Size(200, 17).
        THIS-OBJECT:statusLabelAction:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        /*  */
        /* statusLabelFile */
        /*  */
        THIS-OBJECT:statusLabelFile:Name = "statusLabelFile".
        THIS-OBJECT:statusLabelFile:Size = NEW System.Drawing.Size(1174, 17).
        THIS-OBJECT:statusLabelFile:Spring = TRUE.
        THIS-OBJECT:statusLabelFile:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        /*  */
        /* lintgui */
        /*  */
        THIS-OBJECT:ClientSize = NEW System.Drawing.Size(1389, 540).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:statusLint).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:checkDebug).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:comboProfile).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:btnLint).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:resultsView).
        THIS-OBJECT:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedSingle.
        THIS-OBJECT:Name = "lintgui".
        THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterScreen.
        THIS-OBJECT:Text = "lintgui".
        CAST(THIS-OBJECT:bsResults, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:bsProfiles, System.ComponentModel.ISupportInitialize):EndInit().
        CAST(THIS-OBJECT:resultsView, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:statusLint:ResumeLayout(FALSE).
        THIS-OBJECT:statusLint:PerformLayout().
        THIS-OBJECT:ResumeLayout(FALSE).
        THIS-OBJECT:PerformLayout().
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE VOID RefreshResults(  ):
                
        queryResults:QUERY-CLOSE().
        queryResults:QUERY-PREPARE(SUBSTITUTE("FOR EACH ttResult BY &1&2":U, sortColumn, sortOrder)).
        queryResults:QUERY-OPEN().
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID resultsView_Sorted( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        IF resultsView:SortOrder = System.Windows.Forms.SortOrder:Ascending THEN
            sortOrder = "".
        ELSE
            sortOrder = " DESCENDING":U.
        SortColumn = resultsView:SortedColumn:DataPropertyName.
        RefreshResults().        
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE VOID UpdateResult
        (
        INPUT iRuleId   AS CHARACTER,
        INPUT iUnit     AS CHARACTER,
        INPUT iFileName AS CHARACTER,
        INPUT iLine     AS INTEGER,
        INPUT iSeverity AS INTEGER,
        INPUT iComment  AS CHARACTER
        ):
      
        CREATE ttResult.
        ASSIGN
            ttResult.RuleId     = iRuleId
            ttResult.Unit       = iUnit
            ttResult.SourceFile = iFileName
            ttResult.LineNumber = iLine
            ttResult.Severity   = iSeverity
            ttResult.Comment    = iComment. 
              
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE VOID UpdateStatus
        (
        INPUT iStatus AS CHARACTER,
        INPUT iUnit AS CHARACTER 
        ):
        
        ASSIGN
            statusLabelAction:Text = iStatus
            statusLabelFile:Text   = iUnit. 
        RETURN.

    END METHOD.

    DESTRUCTOR PUBLIC lintgui ( ):

    END DESTRUCTOR.

END CLASS.