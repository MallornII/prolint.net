
/*------------------------------------------------------------------------
    File        : xref.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Mon Dec 10 22:45:27 ALMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttSource NO-UNDO    
    XML-NODE-NAME "Source"
    {&REF_MOD}
    FIELD SourceFile AS CHARACTER
        XML-NODE-TYPE "ATTRIBUTE"
        XML-NODE-NAME "File-name"
    FIELD SourceGUID AS CHARACTER
        XML-NODE-NAME "Source-guid"
    FIELD FileNum AS INTEGER
        XML-NODE-NAME "File-num".

DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttXRef NO-UNDO
    XML-NODE-NAME "Reference"
    {&REF_MOD}
    FIELD ReferenceType AS CHARACTER
        XML-NODE-TYPE "ATTRIBUTE"
        XML-NODE-NAME "Reference-type"
    FIELD ObjectIdentifier AS CHARACTER
        XML-NODE-TYPE "ATTRIBUTE"
        XML-NODE-NAME "Object-identifier"
    FIELD SourceGUID AS CHARACTER
        XML-NODE-NAME "Source-guid"
    FIELD FileNum AS INTEGER
        XML-NODE-NAME "File-num"
    FIELD RefSeq AS INTEGER
        XML-NODE-NAME "Ref-seq"
    FIELD LineNum AS INTEGER
        XML-NODE-NAME "Line-num"    
    FIELD ObjectContext AS CHARACTER
        XML-NODE-NAME "Object-context"
    FIELD AccessMode AS CHARACTER
        XML-NODE-NAME "Access-mode"
    FIELD DataMemberRef AS CHARACTER
        XML-NODE-NAME "Data-member-ref"
    FIELD TempRef AS CHARACTER
        XML-NODE-NAME "Temp-ref"
    FIELD Detail AS CHARACTER
        XML-NODE-NAME "Detail"
    FIELD IsStatic AS LOGICAL
        XML-NODE-NAME "Is-static"
    FIELD IsAbstract AS LOGICAL
        XML-NODE-NAME "Is-abstract".
    
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttParameterRef NO-UNDO
    XML-NODE-NAME "Parameter-ref"
    {&REF_MOD}
    FIELD Order AS INTEGER
        XML-NODE-TYPE "ATTRIBUTE"
        XML-NODE-NAME "Order"
    FIELD ParameterMode AS CHARACTER
        XML-NODE-TYPE "ATTRIBUTE"
        XML-NODE-NAME "Parameter-mode"
    FIELD ParameterName AS CHARACTER
        XML-NODE-TYPE "ATTRIBUTE"
        XML-NODE-NAME "Parameter-name"
    FIELD ParameterType AS CHARACTER
        XML-NODE-TYPE "ATTRIBUTE"
        XML-NODE-NAME "Parameter-type"
    FIELD SourceGUID AS CHARACTER
        XML-NODE-NAME "Source-guid"   
    FIELD RefSeq AS INTEGER
        XML-NODE-NAME "Ref-seq"
    FIELD Dimension AS INTEGER
        XML-NODE-NAME "Dimension"
    FIELD IsAppend AS LOGICAL
        XML-NODE-NAME "Is-append"
    FIELD DatasetGUID AS CHARACTER
        XML-NODE-NAME "Dataset-guid".
        
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttClassRef NO-UNDO
    XML-NODE-NAME "Class-ref"
    {&REF_MOD}   
    FIELD SourceGUID AS CHARACTER
        XML-NODE-NAME "Source-guid"   
    FIELD RefSeq AS INTEGER
        XML-NODE-NAME "Ref-seq"
    FIELD InheritedList AS CHARACTER
        XML-NODE-NAME "Inherited-list"
    FIELD ImplementsList AS CHARACTER
        XML-NODE-NAME "Implements-lis"
    FIELD HasUsePool AS LOGICAL
        XML-NODE-NAME "Has-use-pool"
    FIELD IsFinal AS LOGICAL
        XML-NODE-NAME "Is-final"
    FIELD IsSerializable AS LOGICAL
        XML-NODE-NAME "Is-serializable".
        
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttStringRef NO-UNDO
    XML-NODE-NAME "String-ref"
    {&REF_MOD}   
    FIELD SourceGUID AS CHARACTER
        XML-NODE-NAME "Source-guid"   
    FIELD RefSeq AS INTEGER
        XML-NODE-NAME "Ref-seq"
    FIELD MaxLength AS INTEGER
        XML-NODE-NAME "Max-length"
    FIELD Justification AS CHARACTER
        XML-NODE-NAME "Justification"
    FIELD Translatable AS LOGICAL
        XML-NODE-NAME "Translatable".
        
DEFINE {&ACCESS_MOD} {&STAT_MOD} TEMP-TABLE ttDatasetRef NO-UNDO
    XML-NODE-NAME "Dataset-ref"
    {&REF_MOD}   
    FIELD SourceGUID AS CHARACTER
        XML-NODE-NAME "Source-guid"   
    FIELD DatasetGUID AS CHARACTER
        XML-NODE-NAME "Dataset-guid"
    FIELD RefSeq AS INTEGER
        XML-NODE-NAME "Ref-seq"
    FIELD NameUri AS CHARACTER
        XML-NODE-NAME "N-uri"
    FIELD NamePrefix AS CHARACTER
        XML-NODE-NAME "N-prefix"
    FIELD IsReference AS LOGICAL
        XML-NODE-NAME "Is-reference"
    FIELD BufferList AS CHARACTER
        XML-NODE-NAME "Buffer-list"
    FIELD DataLinks AS INTEGER
        XML-NODE-NAME "Data-links".
        
DEFINE {&ACCESS_MOD} {&STAT_MOD} DATASET dsXRef
    NAMESPACE-URI "uri:schemas-progress-com:XREFD:0005"
    XML-NODE-NAME "Cross-reference"
    {&REF_MOD}
    FOR ttSource, ttXRef, ttParameterRef, ttClassRef, ttStringRef, ttDatasetRef
    DATA-RELATION drXRef FOR ttSource, ttXRef
    RELATION-FIELDS (SourceGUID, SourceGUID)
    NESTED
    DATA-RELATION drParameterRef FOR ttXRef, ttParameterRef
    RELATION-FIELDS (SourceGUID, SourceGUID, RefSeq, RefSeq)
    NESTED
    DATA-RELATION drClassRef FOR ttXRef, ttClassRef
    RELATION-FIELDS (SourceGUID, SourceGUID, RefSeq, RefSeq)
    NESTED
    DATA-RELATION drStringRef FOR ttXRef, ttStringRef
    RELATION-FIELDS (SourceGUID, SourceGUID, RefSeq, RefSeq)
    NESTED
    DATA-RELATION drDatasetRef FOR ttXRef, ttDatasetRef
    RELATION-FIELDS (SourceGUID, SourceGUID, RefSeq, RefSeq)
    NESTED.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
