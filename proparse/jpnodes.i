
/*------------------------------------------------------------------------
    File        : jpnodes.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sun Dec 09 15:22:58 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttNode NO-UNDO
    {&REF_MOD}
    FIELD NodeNum      AS INTEGER
    FIELD ParentNum    AS INTEGER    
    FIELD FirstChild   AS INTEGER
    FIELD NextSibling  AS INTEGER 
    FIELD PrevSibling  AS INTEGER
    FIELD NodeType     AS INTEGER
    FIELD NodeFile     AS CHARACTER
    FIELD NodeLine     AS INTEGER 
    FIELD NodeText     AS CHARACTER
    FIELD NodeColumn   AS INTEGER
    FIELD IngroneRules AS CHARACTER
    FIELD IsStateHead  AS LOGICAL
    FIELD StoreType    AS CHARACTER
    FIELD CodeBlock    AS CHARACTER
    FIELD JPNode       AS Progress.Lang.Object SERIALIZE-HIDDEN
    INDEX iMain IS UNIQUE PRIMARY NodeNum
    INDEX iParent                 ParentNum NodeType
    INDEX iType                   NodeType.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
