define {&ACCESS_MOD} {&STAT_MOD} temp-table ttProUnit no-undo
    {&REF_MOD}    
    field UnitType   as int64
    field Id         as integer
    field ParentId   as integer
    field UnitName   as character
    field SourceFile as character
    field FirstLine  as integer
    field AccessMode as character
    field Direction  as character
    field ReturnType as character
    field IsNoUndo   as logical
    field IsStatic   as logical
    field IsForward  as logical
    field StartNode  as integer.

