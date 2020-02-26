public interface IFieldMetadataService {
    
    Boolean isValidField(String objName, String fieldName);
    Boolean isReferenceField(String objName, String fieldName);
    String getReferenceTarget(String objName, String referenceFieldName);
    String getJsonFormulaFields(String searchKey);
}
