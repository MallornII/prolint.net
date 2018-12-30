define {&ACCESS_MOD} {&STAT_MOD} temp-table ttProDb no-undo
    {&REF_MOD}
    field id           as int64
    field DatabaseName as character.
    
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttProAlias no-undo
    {&REF_MOD}
    field DatabaseName as character
    field AliasName    as character.    
    
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttProTable no-undo
    {&REF_MOD}
    field id           as int64
    field DatabaseName as character
    field TableName    as character
    index Main is primary TableName
    index DataTable       DatabaseName TableName.
    
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttProField no-undo
    {&REF_MOD}
    field id           as int64
    field DatabaseName as character
    field TableName    as character
    field FieldName    as character
    field DataType     as character
    field Ext          as integer 
    index Main is primary FieldName
    index TableField      TableName    FieldName
    index DataTableField  DatabaseName TableName FieldName.
    
define {&ACCESS_MOD} {&STAT_MOD} dataset dsSchema
    {&REF_MOD}
    for ttProDb, ttProAlias, ttProTable, ttProField
    data-relation drAlias for ttProDb, ttProAlias
    relation-fields (DatabaseName, DatabaseName) nested foreign-key-hidden
    data-relation drTable for ttProDb, ttProTable
    relation-fields (DatabaseName, DatabaseName) nested foreign-key-hidden
    data-relation drField for ttProTable, ttProField
    relation-fields (DatabaseName, DatabaseName, TableName, TableName) nested foreign-key-hidden.