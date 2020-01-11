 
/*------------------------------------------------------------------------
   File        : MainForm
   Purpose     : Main form for prolint
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 18.12.2018 15:10:41
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Windows.Form.
using Prolint.IResultAcceptor.

block-level on error undo, throw.

class Prolint.Forms.MainForm inherits Form implements IResultAcceptor final: 
    &SCOPED-DEFINE ACCESS_MOD PRIVATE
    
    {prolint/profile.i}
    {prolint/results.i}
    
    define private variable bsProfiles                          as Progress.Data.BindingSource                    no-undo.
    define private variable bsResults                           as Progress.Data.BindingSource                    no-undo.
    define private variable btnProfiles as System.Windows.Forms.Button no-undo.
    define private variable comboProfile                        as System.Windows.Forms.ComboBox                  no-undo.
    define private variable checkDebug                          as System.Windows.Forms.CheckBox                  no-undo.
    define private variable btnLint                             as System.Windows.Forms.Button                    no-undo.
    define private variable commentDataGridViewTextBoxColumn    as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable components                          as System.ComponentModel.IContainer               no-undo.
    define private variable resultsView                         as System.Windows.Forms.DataGridView              no-undo.
    define private variable severityDataGridViewTextBoxColumn   as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable ruleIdDataGridViewTextBoxColumn     as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable lineNumberDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable sourceFileDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable statusLint                          as System.Windows.Forms.StatusStrip               no-undo.
    define private variable statusLabelFile                     as System.Windows.Forms.ToolStripStatusLabel      no-undo.
    define private variable statusLabelAction                   as System.Windows.Forms.ToolStripStatusLabel      no-undo.
    define private variable lintDialog                          as System.Windows.Forms.OpenFileDialog            no-undo.
    define private variable profileFile                         as character                                      no-undo.
    define private variable sortOrder                           as character                                      no-undo.
    define private variable sortColumn                          as character                                      no-undo.
    define private variable queryProfiles                       as handle                                         no-undo.  
    define private variable queryResults                        as handle                                         no-undo.
    define private variable unitDataGridViewTextBoxColumn       as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.

        
    constructor public MainForm (  ):
        
        
        super().
        InitializeComponent().
        this-object:ComponentsCollection:ADD(this-object:components).
        
        profileFile = search("profiles.xml":U).
        if profileFile <> ? then        
            dataset dsProfile:read-xml( "FILE":U, profileFile, "EMPTY":U, ?, false).
        else
            undo, throw new Progress.Lang.AppError("<profiles.xml> not found":T, 1).    
                
        find first ttProfile no-error.
        if not available(ttProfile) then
            undo, throw new Progress.Lang.AppError("No profiles found":T, 1).
        
        create query queryProfiles.
        queryProfiles:add-buffer(buffer ttProfile:HANDLE).
        queryProfiles:query-prepare("FOR EACH ttProfile":U).
        queryProfiles:query-open().
        bsProfiles:HANDLE = queryProfiles.
        
        assign
            sortOrder  = " DESCENDING":U
            sortColumn = "Severity":U.
        create query queryResults.
        queryResults:add-buffer(buffer ttResult:HANDLE).
        RefreshResults().        
        bsResults:HANDLE = queryResults.        
       
        catch e as Progress.Lang.Error:
            message e:GetMessage(1)
            view-as alert-box error.
            log-manager:write-message(e:CallStack).
            log-manager:write-message(e:GetMessage(1)).
            undo, throw e.
        end catch.

    end constructor.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void btnLint_Click( input sender as System.Object, input e as System.EventArgs ):
        define variable dialogResult  as System.Windows.Forms.DialogResult   no-undo.
        define variable lintInstance  as prolint.linter                      no-undo.        
        define variable errorIterator as OpenEdge.Core.Collections.IIterator no-undo.
        define variable lintError     as Progress.Lang.Error                 no-undo.
        
        wait-for lintDialog:ShowDialog() set dialogResult.
        if dialogResult = System.Windows.Forms.DialogResult:OK then
        do:            
            empty temp-table ttResult.            
            lintInstance = new prolint.linter(comboProfile:SelectedValue:ToString(), this-object) no-error.
            if error-status:error then
            do:
                UpdateStatus("Create linter":T, error-status:get-message(1)).
                return.
            end.
            lintInstance:IsDebug = checkDebug:Checked.
            lintInstance:PublishStatus:Subscribe(UpdateStatus).                                    
            if lintInstance:Lint(lintDialog:FileName) <> Prolint.LintResult:LINT_OK 
                or lintInstance:ErrorStatus() then
            do:
                errorIterator = lintInstance:GetErrors().
                do while errorIterator:HasNext():
                    lintError = cast(errorIterator:Next(), Progress.Lang.Error).
                    if type-of(lintError, Proparse.PError) then
                        ReceiveResult("system", "", lintDialog:FileName, lintError:CallStack,
                                    cast(lintError, Proparse.PError):LineNumber, 9, lintError:GetMessage(1)).                    
                    else
                        ReceiveResult("system", "", lintDialog:FileName, lintError:CallStack, 0, 9, lintError:GetMessage(1)).
                end.
            end.                        
            RefreshResults().        
        end.
        return.
        
        finally:
            delete object lintInstance no-error.                
        end finally.

    end method.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnProfiles_Click( input sender as System.Object, input e as System.EventArgs ):
		define variable profileEditorDialog as Prolint.Forms.ProfileEditor no-undo.
		
		profileEditorDialog = new Prolint.Forms.ProfileEditor().
	    profileEditorDialog:ShowModalDialog().
	    queryProfiles:query-close().
	    queryProfiles:query-open().
		return.

	end method.

    method private void InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true":U).
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("ttResult":U).
        @VisualDesigner.FormMember (NeedsInitialize="true":U).
        define variable tableDesc2 as Progress.Data.TableDesc no-undo.
        tableDesc2 = new Progress.Data.TableDesc("ttProfile":U).
        @VisualDesigner.FormMember (NeedsInitialize="true":U).
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("Prolint.Forms.MainForm":U).
        this-object:bsResults = new Progress.Data.BindingSource(this-object:components).
        this-object:lintDialog = new System.Windows.Forms.OpenFileDialog().
        this-object:bsProfiles = new Progress.Data.BindingSource(this-object:components).
        this-object:resultsView = new System.Windows.Forms.DataGridView().
        this-object:ruleIdDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:severityDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:sourceFileDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:lineNumberDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:unitDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:commentDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:btnLint = new System.Windows.Forms.Button().
        this-object:comboProfile = new System.Windows.Forms.ComboBox().
        this-object:checkDebug = new System.Windows.Forms.CheckBox().
        this-object:statusLint = new System.Windows.Forms.StatusStrip().
        this-object:statusLabelAction = new System.Windows.Forms.ToolStripStatusLabel().
        this-object:statusLabelFile = new System.Windows.Forms.ToolStripStatusLabel().
        this-object:btnProfiles = new System.Windows.Forms.Button().
        cast(this-object:bsResults, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bsProfiles, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:resultsView, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:statusLint:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* bsResults */
        /*  */
        this-object:bsResults:MaxDataGuess = 0.
        this-object:bsResults:NoLOBs = false.
        this-object:bsResults:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 6 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("RuleId":U, "RuleId":U, Progress.Data.DataType:CHARACTER).
        arrayvar1[2] = new Progress.Data.ColumnPropDesc("Unit":U, "Unit":U, Progress.Data.DataType:CHARACTER).
        arrayvar1[3] = new Progress.Data.ColumnPropDesc("SourceFile":U, "Source file":U, Progress.Data.DataType:CHARACTER).
        arrayvar1[4] = new Progress.Data.ColumnPropDesc("Severity":U, "Severity":U, Progress.Data.DataType:INTEGER).
        arrayvar1[5] = new Progress.Data.ColumnPropDesc("Comment":U, "Comment":U, Progress.Data.DataType:CHARACTER).
        arrayvar1[6] = new Progress.Data.ColumnPropDesc("LineNumber":U, "Line number":U, Progress.Data.DataType:INTEGER).
        tableDesc1:Columns = arrayvar1.
        this-object:bsResults:TableSchema = tableDesc1.
        /*  */
        /* lintDialog */
        /*  */
        this-object:lintDialog:Filter = "OpenEdge executables|*.p;*.w;*.cls|All Files|*.*":U.
        /*  */
        /* bsProfiles */
        /*  */
        this-object:bsProfiles:MaxDataGuess = 0.
        this-object:bsProfiles:NoLOBs = false.
        this-object:bsProfiles:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar2 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar2 = new "Progress.Data.TableDesc[]"(0).
        tableDesc2:ChildTables = arrayvar2.
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar3 as Progress.Data.ColumnPropDesc extent 1 no-undo.
        arrayvar3[1] = new Progress.Data.ColumnPropDesc("ProfileName":U, "ProfileName":U, Progress.Data.DataType:CHARACTER).
        tableDesc2:Columns = arrayvar3.
        this-object:bsProfiles:TableSchema = tableDesc2.
        /*  */
        /* resultsView */
        /*  */
        this-object:resultsView:AllowUserToAddRows = false.
        this-object:resultsView:AllowUserToDeleteRows = false.
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        this-object:resultsView:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:resultsView:AutoGenerateColumns = false.
        this-object:resultsView:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
        this-object:resultsView:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar4 as System.Windows.Forms.DataGridViewColumn extent 6 no-undo.
        arrayvar4[1] = this-object:ruleIdDataGridViewTextBoxColumn.
        arrayvar4[2] = this-object:severityDataGridViewTextBoxColumn.
        arrayvar4[3] = this-object:sourceFileDataGridViewTextBoxColumn.
        arrayvar4[4] = this-object:lineNumberDataGridViewTextBoxColumn.
        arrayvar4[5] = this-object:unitDataGridViewTextBoxColumn.
        arrayvar4[6] = this-object:commentDataGridViewTextBoxColumn.
        this-object:resultsView:Columns:AddRange(arrayvar4).
        this-object:resultsView:DataSource = this-object:bsResults.
        this-object:resultsView:Location = new System.Drawing.Point(0, 48).
        this-object:resultsView:Name = "resultsView":U.
        this-object:resultsView:ReadOnly = true.
        this-object:resultsView:ScrollBars = System.Windows.Forms.ScrollBars:Vertical.
        this-object:resultsView:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
        this-object:resultsView:Size = new System.Drawing.Size(1389, 457).
        this-object:resultsView:TabIndex = 0.
        this-object:resultsView:Sorted:Subscribe(this-object:resultsView_Sorted).
        /*  */
        /* ruleIdDataGridViewTextBoxColumn */
        /*  */
        this-object:ruleIdDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
        this-object:ruleIdDataGridViewTextBoxColumn:DataPropertyName = "RuleId":U.
        this-object:ruleIdDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(152.2842712).
        this-object:ruleIdDataGridViewTextBoxColumn:HeaderText = "RuleId":U.
        this-object:ruleIdDataGridViewTextBoxColumn:Name = "ruleIdDataGridViewTextBoxColumn":U.
        this-object:ruleIdDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:ruleIdDataGridViewTextBoxColumn:Resizable = System.Windows.Forms.DataGridViewTriState:True.
        /*  */
        /* severityDataGridViewTextBoxColumn */
        /*  */
        this-object:severityDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
        this-object:severityDataGridViewTextBoxColumn:DataPropertyName = "Severity":U.
        this-object:severityDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(152.2842712).
        this-object:severityDataGridViewTextBoxColumn:HeaderText = "Severity":U.
        this-object:severityDataGridViewTextBoxColumn:Name = "severityDataGridViewTextBoxColumn":U.
        this-object:severityDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:severityDataGridViewTextBoxColumn:Width = 50.
        /*  */
        /* sourceFileDataGridViewTextBoxColumn */
        /*  */
        this-object:sourceFileDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
        this-object:sourceFileDataGridViewTextBoxColumn:DataPropertyName = "SourceFile":U.
        this-object:sourceFileDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(73.857872).
        this-object:sourceFileDataGridViewTextBoxColumn:HeaderText = "Source file":U.
        this-object:sourceFileDataGridViewTextBoxColumn:Name = "sourceFileDataGridViewTextBoxColumn":U.
        this-object:sourceFileDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:sourceFileDataGridViewTextBoxColumn:Width = 200.
        /*  */
        /* lineNumberDataGridViewTextBoxColumn */
        /*  */
        this-object:lineNumberDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
        this-object:lineNumberDataGridViewTextBoxColumn:DataPropertyName = "LineNumber":U.
        this-object:lineNumberDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(73.857872).
        this-object:lineNumberDataGridViewTextBoxColumn:HeaderText = "Line number":U.
        this-object:lineNumberDataGridViewTextBoxColumn:Name = "lineNumberDataGridViewTextBoxColumn":U.
        this-object:lineNumberDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:lineNumberDataGridViewTextBoxColumn:Width = 50.
        /*  */
        /* unitDataGridViewTextBoxColumn */
        /*  */
        this-object:unitDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
        this-object:unitDataGridViewTextBoxColumn:DataPropertyName = "Unit":U.
        this-object:unitDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(73.857872).
        this-object:unitDataGridViewTextBoxColumn:HeaderText = "Unit":U.
        this-object:unitDataGridViewTextBoxColumn:Name = "unitDataGridViewTextBoxColumn":U.
        this-object:unitDataGridViewTextBoxColumn:ReadOnly = true.
        this-object:unitDataGridViewTextBoxColumn:Width = 200.
        /*  */
        /* commentDataGridViewTextBoxColumn */
        /*  */
        this-object:commentDataGridViewTextBoxColumn:DataPropertyName = "Comment":U.
        this-object:commentDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(73.857872).
        this-object:commentDataGridViewTextBoxColumn:HeaderText = "Comment":U.
        this-object:commentDataGridViewTextBoxColumn:Name = "commentDataGridViewTextBoxColumn":U.
        this-object:commentDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* btnLint */
        /*  */
        this-object:btnLint:Image = cast(resources:GetObject("btnLint.Image":U), System.Drawing.Image).
        this-object:btnLint:Location = new System.Drawing.Point(0, 4).
        this-object:btnLint:Name = "btnLint":U.
        this-object:btnLint:Size = new System.Drawing.Size(38, 38).
        this-object:btnLint:TabIndex = 1.
        this-object:btnLint:UseCompatibleTextRendering = true.
        this-object:btnLint:UseVisualStyleBackColor = true.
        this-object:btnLint:Click:Subscribe(this-object:btnLint_Click).
        /*  */
        /* comboProfile */
        /*  */
        this-object:comboProfile:DataSource = this-object:bsProfiles.
        this-object:comboProfile:DisplayMember = "ProfileName":U.
        this-object:comboProfile:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
        this-object:comboProfile:FormattingEnabled = true.
        this-object:comboProfile:Location = new System.Drawing.Point(110, 12).
        this-object:comboProfile:Name = "comboProfile":U.
        this-object:comboProfile:Size = new System.Drawing.Size(142, 21).
        this-object:comboProfile:TabIndex = 2.
        this-object:comboProfile:ValueMember = "ProfileName":U.
        /*  */
        /* checkDebug */
        /*  */
        this-object:checkDebug:Location = new System.Drawing.Point(44, 14).
        this-object:checkDebug:Name = "checkDebug":U.
        this-object:checkDebug:Size = new System.Drawing.Size(60, 21).
        this-object:checkDebug:TabIndex = 3.
        this-object:checkDebug:Text = "Debug":U.
        this-object:checkDebug:UseCompatibleTextRendering = true.
        this-object:checkDebug:UseVisualStyleBackColor = true.
        /*  */
        /* statusLint */
        /*  */
        @VisualDesigner.FormMember (NeedsInitialize="false":U, InitializeArray="true":U).
        define variable arrayvar5 as System.Windows.Forms.ToolStripItem extent 2 no-undo.
        arrayvar5[1] = this-object:statusLabelAction.
        arrayvar5[2] = this-object:statusLabelFile.
        this-object:statusLint:Items:AddRange(arrayvar5).
        this-object:statusLint:Location = new System.Drawing.Point(0, 518).
        this-object:statusLint:Name = "statusLint":U.
        this-object:statusLint:Size = new System.Drawing.Size(1389, 22).
        this-object:statusLint:TabIndex = 4.
        this-object:statusLint:Text = "statusStrip1":U.
        /*  */
        /* statusLabelAction */
        /*  */
        this-object:statusLabelAction:AutoSize = false.
        this-object:statusLabelAction:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Text.
        this-object:statusLabelAction:Name = "statusLabelAction":U.
        this-object:statusLabelAction:Overflow = System.Windows.Forms.ToolStripItemOverflow:Never.
        this-object:statusLabelAction:Size = new System.Drawing.Size(200, 17).
        this-object:statusLabelAction:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        /*  */
        /* statusLabelFile */
        /*  */
        this-object:statusLabelFile:Name = "statusLabelFile":U.
        this-object:statusLabelFile:Size = new System.Drawing.Size(1174, 17).
        this-object:statusLabelFile:Spring = true.
        this-object:statusLabelFile:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
        /*  */
        /* btnProfiles */
        /*  */
        this-object:btnProfiles:Image = cast(resources:GetObject("btnProfiles.Image":U), System.Drawing.Image).
        this-object:btnProfiles:Location = new System.Drawing.Point(258, 4).
        this-object:btnProfiles:Name = "btnProfiles":U.
        this-object:btnProfiles:Size = new System.Drawing.Size(38, 38).
        this-object:btnProfiles:TabIndex = 5.
        this-object:btnProfiles:UseCompatibleTextRendering = true.
        this-object:btnProfiles:UseVisualStyleBackColor = true.
        this-object:btnProfiles:Click:Subscribe(this-object:btnProfiles_Click).
        /*  */
        /* MainForm */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(1389, 540).
        this-object:Controls:Add(this-object:btnProfiles).
        this-object:Controls:Add(this-object:statusLint).
        this-object:Controls:Add(this-object:checkDebug).
        this-object:Controls:Add(this-object:comboProfile).
        this-object:Controls:Add(this-object:btnLint).
        this-object:Controls:Add(this-object:resultsView).
        this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedSingle.
        this-object:Name = "MainForm":U.
        this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterScreen.
        this-object:Text = "Prolint.Net GUI":U.
        cast(this-object:bsResults, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bsProfiles, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:resultsView, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:statusLint:ResumeLayout(false).
        this-object:statusLint:PerformLayout().
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            message e:GetMessage(1)
            view-as alert-box error.
            log-manager:write-message(e:CallStack).
            log-manager:write-message(e:GetMessage(1)).
            undo, throw e.
        end catch.
    end method.

    /*------------------------------------------------------------------------------
     Purpose: Receive results published by ILintUnit
     Notes:
    ------------------------------------------------------------------------------*/
    method public void ReceiveResult
    (
        input ruleId as character,
        input attrs as character,
        input compileUnit as character,
        input sourceFile as character,
        input lineNumber as integer,
        input severity as integer,
        input comment as character
    ):
        
        create ttResult.
        assign
            ttResult.RuleId     = ruleId
            ttResult.Unit       = compileUnit
            ttResult.SourceFile = sourceFile
            ttResult.LineNumber = lineNumber
            ttResult.Severity   = severity
            ttResult.Comment    = comment.
              
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void RefreshResults(  ):
                
        queryResults:query-close().
        queryResults:query-prepare(substitute("FOR EACH ttResult BY &1&2":U, sortColumn, sortOrder)).
        queryResults:query-open().
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void resultsView_Sorted( input sender as System.Object, input e as System.EventArgs ):
        if resultsView:SortOrder = System.Windows.Forms.SortOrder:Ascending then
            sortOrder = "".
        else
            sortOrder = " DESCENDING":U.
        SortColumn = resultsView:SortedColumn:DataPropertyName.
        RefreshResults().        
        return.

    end method.
 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private void UpdateStatus
        (
        input iStatus as character,
        input iUnit as character 
        ):
        
        assign
            statusLabelAction:Text = iStatus
            statusLabelFile:Text   = iUnit. 
        return.

    end method.

    destructor public MainForm ( ):

    end destructor.

end class.