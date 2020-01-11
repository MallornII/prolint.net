
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
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttSource no-undo    
    xml-node-name "Source"
    {&REF_MOD}
    field SourceFile as character
        xml-node-type "ATTRIBUTE"
        xml-node-name "File-name"
    field SourceGUID as character
        xml-node-name "Source-guid"
    field FileNum as integer
        xml-node-name "File-num".

define {&ACCESS_MOD} {&STAT_MOD} temp-table ttXRef no-undo
    xml-node-name "Reference"
    {&REF_MOD}
    field ReferenceType as character
        xml-node-type "ATTRIBUTE"
        xml-node-name "Reference-type"
    field ObjectIdentifier as character
        xml-node-type "ATTRIBUTE"
        xml-node-name "Object-identifier"
    field SourceGUID as character
        xml-node-name "Source-guid"
    field FileNum as integer
        xml-node-name "File-num"
    field RefSeq as integer
        xml-node-name "Ref-seq"
    field LineNum as integer
        xml-node-name "Line-num"    
    field ObjectContext as character
        xml-node-name "Object-context"
    field AccessMode as character
        xml-node-name "Access-mode"
    field DataMemberRef as character
        xml-node-name "Data-member-ref"
    field TempRef as character
        xml-node-name "Temp-ref"
    field Detail as character
        xml-node-name "Detail"
    field IsStatic as logical
        xml-node-name "Is-static"
    field IsAbstract as logical
        xml-node-name "Is-abstract".
    
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttParameterRef no-undo
    xml-node-name "Parameter-ref"
    {&REF_MOD}
    field Order as integer
        xml-node-type "ATTRIBUTE"
        xml-node-name "Order"
    field ParameterMode as character
        xml-node-type "ATTRIBUTE"
        xml-node-name "Parameter-mode"
    field ParameterName as character
        xml-node-type "ATTRIBUTE"
        xml-node-name "Parameter-name"
    field ParameterType as character
        xml-node-type "ATTRIBUTE"
        xml-node-name "Parameter-type"
    field SourceGUID as character
        xml-node-name "Source-guid"   
    field RefSeq as integer
        xml-node-name "Ref-seq"
    field Dimension as integer
        xml-node-name "Dimension"
    field IsAppend as logical
        xml-node-name "Is-append"
    field DatasetGUID as character
        xml-node-name "Dataset-guid".
        
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttClassRef no-undo
    xml-node-name "Class-ref"
    {&REF_MOD}   
    field SourceGUID as character
        xml-node-name "Source-guid"   
    field RefSeq as integer
        xml-node-name "Ref-seq"
    field InheritedList as character
        xml-node-name "Inherited-list"
    field ImplementsList as character
        xml-node-name "Implements-lis"
    field HasUsePool as logical
        xml-node-name "Has-use-pool"
    field IsFinal as logical
        xml-node-name "Is-final"
    field IsSerializable as logical
        xml-node-name "Is-serializable".
        
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttStringRef no-undo
    xml-node-name "String-ref"
    {&REF_MOD}   
    field SourceGUID as character
        xml-node-name "Source-guid"   
    field RefSeq as integer
        xml-node-name "Ref-seq"
    field MaxLength as integer
        xml-node-name "Max-length"
    field Justification as character
        xml-node-name "Justification"
    field Translatable as logical
        xml-node-name "Translatable".
        
define {&ACCESS_MOD} {&STAT_MOD} temp-table ttDatasetRef no-undo
    xml-node-name "Dataset-ref"
    {&REF_MOD}   
    field SourceGUID as character
        xml-node-name "Source-guid"   
    field DatasetGUID as character
        xml-node-name "Dataset-guid"
    field RefSeq as integer
        xml-node-name "Ref-seq"
    field NameUri as character
        xml-node-name "N-uri"
    field NamePrefix as character
        xml-node-name "N-prefix"
    field IsReference as logical
        xml-node-name "Is-reference"
    field BufferList as character
        xml-node-name "Buffer-list"
    field DataLinks as integer
        xml-node-name "Data-links".

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
