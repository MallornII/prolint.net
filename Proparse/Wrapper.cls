/*------------------------------------------------------------------------
   File        : Wrapper
   Purpose     : Wrapper over proparse.net dll
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 05.12.2018 21:33:21
   Notes       : Calls org.prorefactor.treeparser.ParseUnit(JavaFile):ParseUnit:treeParser01()
                 from proparse.net.dll, then fills OpenEdge temp-tables with parsed nodes and decorates them  with additional properties.
----------------------------------------------------------------------*/

block-level on error undo, throw.

using com.joanju.proparse.ProToken.
using com.joanju.proparse.ProParserTokenTypes.
using org.prorefactor.core.JPNode.
using org.prorefactor.core.TreeUtils.
using com.joanju.proparse.NodeTypes.
using java.util.ArrayList.
using java.io.File.
using Progress.Lang.Error.
using Progress.Lang.AppError.
using OpenEdge.Core.Collections.List.
using Proparse.UnitType.
using com.joanju.proparse.ProParserTokenTypes.
using Utils.IO.

class Proparse.Wrapper use-widget-pool final:
    
    define private stream sParse.

    define private static property ErrorList as OpenEdge.Core.Collections.List no-undo 
        get.
        set. 

    define private static property JavaFile as java.io.File no-undo 
        get.
        set. 

    define private static property ParserCollection as OpenEdge.Core.Collections.Collection no-undo 
        get.
        set. 

    /* This class will be used to load DB schema */    
    define public static property DbSchema as Proparse.IDbSchema no-undo 
        get.
        set.

    define private static property ParseEnv as com.joanju.proparse.Environment no-undo 
        get.
        set. 

    define private static property ParseSchema as org.prorefactor.core.schema.Schema no-undo 
        get.
        set. 

    define private static property ParseSession as org.prorefactor.refactor.RefactorSession no-undo 
        get.
        set. 

    define private static property ParseUnit as org.prorefactor.treeparser.ParseUnit no-undo 
        get.
        set. 

    define public static property TempDir as character no-undo 
        get.
        set(input iTempDir as character):
            TempDir = iTempDir.        
            ParseSession:setContextDirName(TempDir + "/":U).
        end set. 

    /*------------------------------------------------------------------------------
     Purpose: Sets environment variables for proparse.net.dll
     Notes: 
    ------------------------------------------------------------------------------*/
		
    constructor static Wrapper (  ):
        ErrorList = new OpenEdge.Core.Collections.List().
        parseSchema = org.prorefactor.core.schema.Schema:getInstance().
        ParseEnv = com.joanju.proparse.Environment:instance().
        ParseSession = org.prorefactor.refactor.RefactorSession:getInstance().     
        
        ParseEnv:configSet("batch-mode", string(session:batch-mode, "true/false":U)).
        ParseEnv:configSet("opsys":U, opsys).
        ParseEnv:configSet("propath":U, propath).
        ParseEnv:configSet("proversion":U, proversion).
        ParseEnv:configSet("window-system":U, session:window-system).
        
        ParserCollection = new OpenEdge.Core.Collections.Collection().
        ParserCollection:Add(new Proparse.TreeBuilder()).
        ParserCollection:Add(new Proparse.CodeBlocksParser()).
        ParserCollection:Add(new Proparse.DirectivesParser()).
        ParserCollection:Add(new Proparse.ProUnitsParser()).
        
        ReadDbSchema().
		
    end constructor.   
 
    /*------------------------------------------------------------------------------
     Purpose: Adds new parser. All parsers are called after the org.prorefactor.treeparser.ParseUnit call from Parse method
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void AddParser( input newParser as Proparse.IParser ):
        
        if valid-object(newParser) then
            ParserCollection:Add(newParser).
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Cleans temp-tables, deletes old objects
     Notes:
    ------------------------------------------------------------------------------*/

    method private static void CleanUp(  ):		
		
        ErrorList:Clear().
        if valid-object(ParseUnit) then
            delete object ParseUnit.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Return TRUE if there errors during class' work
     Notes: 
    ------------------------------------------------------------------------------*/

    method public static logical ErrorStatus(  ):
        
        return not ErrorList:IsEmpty().

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Returns IIterator class with errors that were raised during class' work
     Notes: Use ErrorStatus() method to determine whenever there were any errors
    ------------------------------------------------------------------------------*/

    method public static final OpenEdge.Core.Collections.IListIterator GetErrors(  ):

        return ErrorList:ListIterator().

    end method.


    /*------------------------------------------------------------------------------
     Purpose: Parses file, returns temp-tables for Nodes nd ProUnits (methods, functions e.t.c.) 
     Notes:
    ------------------------------------------------------------------------------*/

    method public static logical Parse ( input currentUnit as Prolint.ILintUnit ):        
        
        define variable parserIterator as OpenEdge.Core.Collections.IIterator no-undo.        
     
        CleanUp().

        JavaFile = new java.io.File(currentUnit:CompileUnit).
        ParseUnit = new org.prorefactor.treeparser.ParseUnit(JavaFile).	
        ParseUnit:treeParser01().
        currentUnit:TopNode = cast(ParseUnit:getTopNode(), JPNode).

        parserIterator = ParserCollection:Iterator().
        do while parserIterator:HasNext():                        
            currentUnit:Accept(cast(parserIterator:Next(), Proparse.IParser)).
        end.        
                        
        return true.
		
        catch e as Progress.Lang.Error :            
            ErrorList:Add(e).
            return false.                
        end catch.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Gets DB schema via SchemaLoader class and passes it to proparse.net.dll
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void ReadDbSchema(  ):
        
        define variable vSchemaFile as character no-undo.
	    
        if not valid-object(DbSchema) then
            DbSchema = new Proparse.ProDbSchema().
            
        vSchemaFile = session:temp-directory + "proparse.schema":U.
        DbSchema:ToFile(vSchemaFile).
        ParseSchema:clear().
        ParseSchema:loadSchema(vSchemaFile).
		
        return.
        catch eErr as Progress.Lang.Error :
            ErrorList:Add(eErr).        		
        end catch.

    end method.    

    /*------------------------------------------------------------------------------
     Purpose: Releases recources used by proparse.net.dll (nodes and files)
     Notes: As there is now way to free them directly it's just parses dummy file
    ------------------------------------------------------------------------------*/

    method public static void ReleaseNodes(  ):
        
        define variable dummyFile as character no-undo.
        
        CleanUp().
        dummyFile = IO:MakePath(TempDir, "parse_dummy.p":U).
        output stream sParse to value(dummyFile).
        output stream sParse close.        

        JavaFile = new java.io.File(dummyFile).
        ParseUnit = new org.prorefactor.treeparser.ParseUnit(JavaFile). 
        ParseUnit:treeParser01().
        JavaFile:deleteOnExit().
        ParseUnit = ?.
        JavaFile = ?.        
        
        return.
        
        catch e as Progress.Lang.Error :            
            ErrorList:Add(e).
            return.                
        end catch.
        finally:
            os-delete value(dummyFile).  
        end finally.

    end method.    

    destructor public Wrapper ( ):
       
    end destructor.

end class.
