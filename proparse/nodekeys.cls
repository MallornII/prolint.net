 
/*------------------------------------------------------------------------
   File        : nodekeys
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : niand
   Created     : Fri Dec 07 22:08:40 ALMT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ENUM proparse.nodekeys: 
    DEFINE ENUM
        STATE2               = 1300
        CONTEXT_QUALIFIER    = 10160
        SYMBOL               = -210
        TETNode              = -211
        BUFFERSCOPE          = -212
        E_BLOCK              = -214
        COMMENTS             = -215
        ORIGINAL             = -216
        FIELD_CONTAINER      = -217
        E_CALL               = -218
        SUPER_CLASS_TREE     = -219
        FILE_NAME_ARRAY      = -220
        AK_STORETYPE         = 1100
        AK_OPERATOR          = 1200
        AK_STATE2            = 1300
        AK_STATEHEAD         = 1400
        AK_PROPARSEDIRECTIVE = 1500
        AK_KEYWORD           = 1600
        AK_ABBREVIATED       = 1700
        AK_FULLTEXT          = 1800
        AK_FROMUSERDICT      = 1900
        AK_INLINEVARDEF      = 2000
        AK_SOURCENUM         = 2300
        AK_QUALIFIEDCLASS    = 2400
        AV_FALSE             = 0
        AV_TRUE              = 1
        AV_ST_VARIABLE       = 1101
        AV_ST_DBTABLE        = 1102
        AV_ST_TTABLE         = 1103
        AV_ST_WTABLE         = 1104.
END ENUM.