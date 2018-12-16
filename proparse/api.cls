 
/*------------------------------------------------------------------------
   File        : api
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Wed Dec 05 21:33:21 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING com.joanju.proparse.ProToken.
USING com.joanju.proparse.ProParserTokenTypes.
USING org.prorefactor.core.JPNode.
USING org.prorefactor.core.TreeUtils.
USING com.joanju.proparse.NodeTypes.
USING java.util.ArrayList.
USING java.io.File.
USING Progress.Lang.Error.
USING Progress.Lang.AppError.
USING OpenEdge.Core.Collections.List.
USING proparse.UnitType.
USING com.joanju.proparse.ProParserTokenTypes.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS proparse.api USE-WIDGET-POOL FINAL: 
    &SCOPED-DEFINE ACCESS_MODE PRIVATE
    &SCOPED-DEFINE STAT_MOD    STATIC
    
    {proparse/jpnodes.i}            
    {proparse/prounit.i}    
    
    DEFINE PRIVATE STREAM sParse.

    DEFINE PRIVATE STATIC PROPERTY CurrentFile AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY ErrorList AS OpenEdge.Core.Collections.List NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY JavaFile AS java.io.File NO-UNDO 
        GET.
        SET. 

    DEFINE PUBLIC STATIC PROPERTY SchemaLoader AS proparse.ischemaloader NO-UNDO 
        PRIVATE GET.
        SET.

    DEFINE PRIVATE STATIC PROPERTY NodeArray AS java.util.ArrayList NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY ParseEnv AS com.joanju.proparse.Environment NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY ParseSchema AS org.prorefactor.core.schema.Schema NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY ParseSession AS org.prorefactor.refactor.RefactorSession NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY ParseUnit AS org.prorefactor.treeparser.ParseUnit NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY TempDir AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE STATIC PROPERTY TopNode AS org.prorefactor.core.JPNode NO-UNDO 
        GET.
        SET. 

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
		
    CONSTRUCTOR STATIC api (  ):
        ErrorList = NEW OpenEdge.Core.Collections.List().
        parseSchema = org.prorefactor.core.schema.Schema:getInstance().
        ParseEnv = com.joanju.proparse.Environment:instance().
        ParseSession = org.prorefactor.refactor.RefactorSession:getInstance().     
        TempDir = MakePath(SESSION:TEMP-DIRECTORY, GUID(GENERATE-UUID)).        
        OS-CREATE-DIR VALUE(TempDir).
        IF OS-ERROR <> 0 THEN
            UNDO, THROW NEW proparse.perror({&LINE-NUMBER}, SUBSTITUTE("Can't create temp directory. OS error [&1]", OS-ERROR), OS-ERROR).   
        
        ParseSession:setContextDirName(TempDir + "/").
        ParseEnv:configSet("batch-mode", STRING(SESSION:BATCH-MODE, "true/false")).
        ParseEnv:configSet("opsys", OPSYS).
        ParseEnv:configSet("propath", PROPATH).
        ParseEnv:configSet("proversion", PROVERSION).
        ParseEnv:configSet("window-system", SESSION:WINDOW-SYSTEM).
        
        ReadDbSchema().
		
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC CHARACTER AddEntry
        (
        INPUT iFirst  AS CHARACTER,
        INPUT iSecond AS CHARACTER
        ):		
        RETURN iFirst + (IF iFirst = "" THEN  "" ELSE ",") + iSecond.
    END METHOD.   
 
    

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID BuildTree(  ):
        DEFINE VARIABLE cnt        AS INTEGER NO-UNDO.
        DEFINE VARIABLE curNode    AS JPNode  NO-UNDO.
        DEFINE VARIABLE parentNode AS JPNode  NO-UNDO.
        DEFINE VARIABLE childNode  AS JPNode  NO-UNDO.
        DEFINE VARIABLE nextNode   AS JPNode  NO-UNDO.
        DEFINE VARIABLE prevNode   AS JPNode  NO-UNDO.
        
        DEFINE BUFFER tNode FOR ttNode.
		
        DO cnt = 0 TO NodeArray:size() - 1:
            CREATE ttNode.
            ASSIGN
                curNode         = CAST(NodeArray:get(cnt), JPNode)
                parentNode      = curNode:parent()
                childNode       = curNode:firstChild()
                nextNode        = curNode:nextNode()
                prevNode        = curNode:prevNode()
                ttNode.JPNode   = curNode
                ttNode.NodeType = curNode:getType().
            
            ASSIGN                
                ttNode.NodeNum     = curNode:getNodeNum()
                ttNode.NodeFile    = curNode:getFilename()
                ttNode.NodeLine    = curNode:getLine()
                ttNode.NodeColumn  = curNode:getColumn()
                ttNode.NodeText    = curNode:getText()
                WHEN ttNode.NodeType <> ProParserTokenTypes:PROPARSEDIRECTIVE
                ttNode.NodeText    = curNode:attrGetS("proparsedirective")
                WHEN ttNode.NodeType = ProParserTokenTypes:PROPARSEDIRECTIVE                
                ttNode.IsStateHead = curNode:isStateHead()
                ttNode.StoreType   = curNode:attrGetS("storetype")                        
                ttNode.ParentNum   = parentNode:getNodeNum()                 
                WHEN VALID-OBJECT(parentNode)
                ttNode.FirstChild  = childNode:getNodeNum()                 
                WHEN VALID-OBJECT(childNode)
                ttNode.NextSibling = nextNode:getNodeNum()                 
                WHEN VALID-OBJECT(nextNode)
                ttNode.PrevSibling = prevNode:getNodeNum()                 
                WHEN VALID-OBJECT(prevNode).
        END.        
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID CleanUp(  ):
		
        IF VALID-OBJECT(ParseUnit) THEN
            DELETE OBJECT ParseUnit.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID DecorateAccessors
        (
        INPUT iTokenType   AS INTEGER,
        INPUT iProUnitType AS UnitType
        ):       
         
        DEFINE BUFFER tNode   FOR ttNode. /* setter or getter */
        DEFINE BUFFER bttNode FOR ttNode. /* ID node with propety name */
        DEFINE BUFFER cttNode FOR ttNode. /* define node */
        DEFINE BUFFER dttNode FOR ttNode. /* Code_block node of accessor */
        
        DEFINE VARIABLE nextNum AS INTEGER NO-UNDO.
        
        BLK_NODE:
        FOR EACH ttNode WHERE ttNode.NodeType = iTokenType,
            FIRST cttNode WHERE cttNode.NodeNum = ttNode.ParentNum,
            FIRST dttNode WHERE dttNode.ParentNum = ttNode.NodeNum
            AND dttNode.NodeType = ProParserTokenTypes:Code_block.            
            FIND FIRST bttNode WHERE bttNode.ParentNum = cttNode.NodeNum
                AND bttNode.NodeType = ProParserTokenTypes:ID NO-ERROR.
            IF NOT AVAILABLE(bttNode) THEN
                NEXT BLK_NODE.
            CREATE ttProUnit.
            ASSIGN
                ttProUnit.UnitType   = iProUnitType:GetValue()
                ttProUnit.StartNode  = ttNode.JPNode
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.UnitName   = ttNode.NodeText.
                
            IF LOOKUP("Interface", ttNode.CodeBlock) > 0 THEN
            DO:
                ttProUnit.IsForward = TRUE.
                NEXT BLK_NODE.
            END.
            
            BLK_NEXT:
            DO WHILE bttNode.NextSibling <> 0:
                nextNum = bttNode.NextSibling.
                FIND FIRST bttNode WHERE bttNode.NodeNum = nextNum.
                IF bttNode.NodeType = ProParserTokenTypes:EXTERNAL
                    OR bttNode.NodeType = ProParserTokenTypes:FORWARDS
                    OR bttNode.NodeType = ProParserTokenTypes:IN_KW
                    OR bttNode.NodeType = ProParserTokenTypes:ABSTRACT THEN
                DO:
                    ttProUnit.IsForward = TRUE.
                    LEAVE BLK_NEXT.
                END.
            END.
        END.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID DecorateCodeBlocks(  ):
        DEFINE BUFFER tNode   FOR ttNode.
        DEFINE BUFFER bttNode FOR ttNode.        
		
        FOR EACH ttNode WHERE ttNode.NodeType = ProParserTokenTypes:Code_block,
            FIRST bttNode WHERE bttNode.NodeNum = ttNode.ParentNum:
            ttNode.CodeBlock = AddEntry(ttNode.CodeBlock, bttNode.NodeText).
            PopulateCodeBlocks(ttNode.NodeNum, bttNode.NodeText).            		      
        END.
        
        FOR EACH ttNode WHERE ttNode.NodeType = ProParserTokenTypes:FUNCTION:            
            FIND FIRST bttNode WHERE bttNode.ParentNum = ttNode.NodeNum
                AND bttNode.NodeType = ProParserTokenTypes:Parameter_list NO-ERROR.
            IF AVAILABLE(bttNode) THEN
                PopulateCodeBlocks(bttNode.NodeNum, ttNode.NodeText).
        END.	    
        
        RETURN.
        
        CATCH eErr AS Progress.Lang.Error :
            ErrorList:Add(eErr).                        
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID DecorateDirectives(  ):
		
        DEFINE BUFFER tNode   FOR ttNode.
        DEFINE BUFFER bttNode FOR ttNode.
        
        DEFINE VARIABLE rulesList AS CHARACTER NO-UNDO.
        DEFINE VARIABLE labelNum  AS INTEGER   NO-UNDO.
        
        BLK_NODE:
        FOR EACH ttNode WHERE ttNode.NodeType = ProParserTokenTypes:PROPARSEDIRECTIVE:
            FIND FIRST bttNode WHERE bttNode.NodeNum = ttNode.NextSibling.
            IF NOT AVAILABLE(bttNode) THEN
                RETURN.
            IF bttNode.NodeType = ProParserTokenTypes:BLOCK_LABEL THEN
            DO:
                labelNum = bttNode.NodeNum.
                FIND FIRST bttNode WHERE bttNode.ParentNum = labelNum
                    AND bttNode.IsStateHead.    
            END.
            rulesList = ParseDirective(ttNode.NodeText).       
            bttNode.IngroneRules = rulesList. 
            PopulateDirectives(bttNode.NodeNum, rulesList).             
        END. 
            
        RETURN.
    
        CATCH eErr AS Progress.Lang.Error :
            ErrorList:Add(eErr).                        
        END CATCH.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID DecorateTree(  ):
		
        DecorateCodeBlocks().
        DecorateDirectives().
        DecorateUnits().
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID DecorateProcedures
        (
        INPUT iTokenType     AS INTEGER,
        INPUT iProUnitType   AS UnitType,
        INPUT iAbstractBlock AS CHARACTER
        ):
	    
        DEFINE BUFFER tNode   FOR ttNode.
        DEFINE BUFFER bttNode FOR ttNode.
        
        DEFINE VARIABLE nextNum AS INTEGER NO-UNDO.
        
        BLK_NODE:
        FOR EACH ttNode WHERE ttNode.NodeType = iTokenType
            AND ttNode.IsStateHead:
            FIND FIRST bttNode WHERE bttNode.ParentNum = ttNode.NodeNum
                AND bttNode.NodeType = ProParserTokenTypes:ID NO-ERROR.
            IF NOT AVAILABLE(bttNode) THEN
                NEXT BLK_NODE.
            CREATE ttProUnit.
            ASSIGN
                ttProUnit.UnitType   = iProUnitType:GetValue()
                ttProUnit.StartNode  = ttNode.JPNode
                ttProUnit.SourceFile = ttNode.NodeFile
                ttProUnit.FirstLine  = ttNode.NodeLine
                ttProUnit.UnitName   = ttNode.NodeText.
                
            IF iAbstractBlock <> ? AND LOOKUP(iAbstractBlock, ttNode.CodeBlock) > 0 THEN
            DO:
                ttProUnit.IsForward = TRUE.
                NEXT BLK_NODE.
            END.
            
            BLK_NEXT:
            DO WHILE bttNode.NextSibling <> 0:
                nextNum = bttNode.NextSibling.
                FIND FIRST bttNode WHERE bttNode.NodeNum = nextNum.
                IF bttNode.NodeType = ProParserTokenTypes:EXTERNAL
                    OR bttNode.NodeType = ProParserTokenTypes:FORWARDS
                    OR bttNode.NodeType = ProParserTokenTypes:IN_KW
                    OR bttNode.NodeType = ProParserTokenTypes:ABSTRACT THEN
                DO:
                    ttProUnit.IsForward = TRUE.
                    LEAVE BLK_NEXT.
                END.
            END.
        END.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID DecorateUnits(  ):
		
        DecorateProcedures(ProParserTokenTypes:PROCEDURE, proparse.UnitType:U_PROCEDURE, ?).
        DecorateProcedures(ProParserTokenTypes:FUNCTION, proparse.UnitType:U_FUNCTION, ?).
        DecorateProcedures(ProParserTokenTypes:METHOD, proparse.UnitType:U_METHOD, "Interface").        
        DecorateAccessors(ProParserTokenTypes:Property_getter, proparse.UnitType:U_GETTER).        
        DecorateAccessors(ProParserTokenTypes:Property_setter, proparse.UnitType:U_SETTER).
      
        RETURN.
        
        CATCH eErr AS Progress.Lang.Error :
            ErrorList:Add(eErr).                        
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC LOGICAL ErrorStatus(  ):
        
        RETURN NOT ErrorList:IsEmpty().

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC FINAL OpenEdge.Core.Collections.IListIterator GetErrors(  ):

        RETURN ErrorList:ListIterator().

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC JPNode GetStateHead( INPUT iNodeNum AS INTEGER ):
	    
        DEFINE BUFFER ttNode FOR ttNode.
        FIND FIRST ttNode WHERE ttNode.NodeNum = iNodeNum.
        DO WHILE ttNode.IsStateHead = FALSE:
            iNodeNum = ttNode.ParentNum.
            FIND FIRST ttNode WHERE ttNode.NodeNum = iNodeNum.
        END.
	    
        RETURN CAST(ttNode.JPNode, JPNode).
	    
        CATCH eErr AS Progress.Lang.Error :
            ErrorList:Add(eErr).
            RETURN ?.                
        END CATCH.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC INTEGER GetStateHeadType( INPUT iNodeNum AS INTEGER ):
		
        DEFINE VARIABLE localNode AS JPNode NO-UNDO.
		
        localNode = GetStateHead(iNodeNum).
        IF localNode = ? THEN
            RETURN ProParserTokenTypes:Program_root.
        ELSE
            RETURN localNode:getType().	

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC CHARACTER MakePath
        (
        INPUT iPath AS CHARACTER,
        INPUT iFileName AS CHARACTER
        ):
        
        iPath = RIGHT-TRIM(REPLACE(iPath, "~\", "/"), "/").
        iFileName = REPLACE(iFileName, "~\", "/").
        IF iFileName <> ? AND iFileName <> "" THEN
            iPath = iPath + "/" + iFileName.         

        RETURN iPath.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC LOGICAL Parse
        (
        INPUT iFileName AS CHARACTER,
        OUTPUT TABLE FOR ttNode BIND,
        OUTPUT TABLE FOR ttProUnit BIND
        ):
     
        ErrorList:Clear().
        CurrentFile = iFileName.        

        JavaFile = NEW java.io.File(iFileName).
        ParseUnit = NEW org.prorefactor.treeparser.ParseUnit(JavaFile).	
        ParseUnit:treeParser01().
        TopNode = CAST(ParseUnit:getTopNode(), JPNode).        
        NodeArray = org.prorefactor.core.TreeUtils:flatList(TopNode).       
        BuildTree().
        /* implicit delete */
        NodeArray = ?.
        DecorateTree().
        TEMP-TABLE ttNode:WRITE-XML("FILE", "c:/temp/nodes.xml", TRUE,  "utf-8").                
        RETURN TRUE.
		
        CATCH eErr AS Progress.Lang.Error :            
            ErrorList:Add(eErr).
            RETURN FALSE.                
        END CATCH.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC CHARACTER ParseDirective( INPUT iDirective AS CHARACTER ):
	    
        DEFINE VARIABLE leftParen  AS INTEGER NO-UNDO.
        DEFINE VARIABLE rightParen AS INTEGER NO-UNDO.
		
        iDirective = SUBSTITUTE(iDirective, " ":U, "").
        IF NOT iDirective BEGINS "prolint-nowarn":U THEN
            RETURN "".
        ASSIGN
            leftParen  = INDEX(iDirective, "(":U)
            rightParen = INDEX(iDirective, ")":U).
        IF leftParen = 0 OR rightParen = 0 THEN
            RETURN "".
        iDirective = TRIM(SUBSTRING(iDirective, leftParen + 1, rightParen - leftParen - 1), ",":U).

        RETURN iDirective.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID PopulateCodeBlocks
        (
        INPUT iNodeNum AS INTEGER,
        INPUT iBlockText AS CHARACTER
        ):
        DEFINE BUFFER tNode FOR ttNode.
        
        FOR EACH ttNode WHERE ttNode.ParentNum = iNodeNum:
            ttNode.CodeBlock = AddEntry(ttNode.CodeBlock, iBlockText).
            PopulateCodeBlocks(ttNode.NodeNum, iBlockText).
        END.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PRIVATE STATIC VOID PopulateDirectives		
        (
        INPUT iNodeNum AS INTEGER,
        INPUT iRulesList AS CHARACTER
        ):
        
        DEFINE BUFFER tNode FOR ttNode.
            
        FOR EACH ttNode WHERE ttNode.ParentNum = iNodeNum:
            ttNode.IngroneRules = iRulesList.
            PopulateDirectives(ttNode.NodeNum, iRulesList).
        END.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC VOID ReadDbSchema(  ):
        
        DEFINE VARIABLE vSchemaFile AS CHARACTER NO-UNDO.
	    
        IF NOT VALID-OBJECT(SchemaLoader) THEN
            SchemaLoader = NEW proparse.schemaloader().
            
        vSchemaFile = SESSION:TEMP-DIRECTORY + "proparse.schema".
        SchemaLoader:ToFile(vSchemaFile).
        ParseSchema:clear().
        ParseSchema:loadSchema(vSchemaFile).
		
        RETURN.
        CATCH eErr AS Progress.Lang.Error :
            ErrorList:Add(eErr).        		
        END CATCH.

    END METHOD.    

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC STATIC VOID ReleaseNodes(  ):
        
        ErrorList:Clear().
        CurrentFile = MakePath(TempDir, "parse_dummy.p":U).
        OUTPUT STREAM sParse TO VALUE(CurrentFile).
        OUTPUT STREAM sParse CLOSE.        

        JavaFile = NEW java.io.File(CurrentFile).
        ParseUnit = NEW org.prorefactor.treeparser.ParseUnit(JavaFile). 
        ParseUnit:treeParser01().
        TopNode = CAST(ParseUnit:getTopNode(), JPNode).        
        NodeArray = org.prorefactor.core.TreeUtils:flatList(TopNode).       
        
        /* implicit delete */
        NodeArray = ?.                        
        RETURN.
        
        CATCH eErr AS Progress.Lang.Error :            
            ErrorList:Add(eErr).
            RETURN.                
        END CATCH.

    END METHOD.    

    DESTRUCTOR PUBLIC api ( ):
        OS-DELETE VALUE(TempDir) RECURSIVE.
    END DESTRUCTOR.

END CLASS.