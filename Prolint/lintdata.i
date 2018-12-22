{prolint/compile.i}    
{prolint/xref.i}

define {&ACCESS_MOD} {&STAT_MOD} dataset dsXRef
    namespace-uri "uri:schemas-progress-com:XREFD:0005"
    xml-node-name "Cross-reference"
    {&REF_MOD}
    for ttCompileMessage, ttSource, ttXRef, ttParameterRef, ttClassRef, ttStringRef, ttDatasetRef
    data-relation drXRef for ttSource, ttXRef
    relation-fields (SourceGUID, SourceGUID)
    nested
    data-relation drParameterRef for ttXRef, ttParameterRef
    relation-fields (SourceGUID, SourceGUID, RefSeq, RefSeq)
    nested
    data-relation drClassRef for ttXRef, ttClassRef
    relation-fields (SourceGUID, SourceGUID, RefSeq, RefSeq)
    nested
    data-relation drStringRef for ttXRef, ttStringRef
    relation-fields (SourceGUID, SourceGUID, RefSeq, RefSeq)
    nested
    data-relation drDatasetRef for ttXRef, ttDatasetRef
    relation-fields (SourceGUID, SourceGUID, RefSeq, RefSeq)
    nested.
