define {&ACCESS_MOD} {&STAT_MOD} temp-table ttNode no-undo
    {&REF_MOD}
    field NodeNum      as integer
    field ParentNum    as integer    
    field FirstChild   as integer
    field NextSibling  as integer 
    field PrevSibling  as integer
    field NodeType     as integer
    field NodeFile     as character
    field NodeLine     as integer 
    field NodeText     as character
    field NodeColumn   as integer
    field IngroneRules as character
    field IsStateHead  as logical
    field State2       as integer
    field StoreType    as character
    field CodeBlock    as character    
    index iMain is unique primary NodeNum
    index iParent                 ParentNum NodeType
    index iType                   NodeType.
