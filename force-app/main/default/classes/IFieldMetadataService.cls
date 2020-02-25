public interface IFieldMetadataService {
    
    Boolean isValidField(String objName, String fieldName);
    Boolean isReferenceField(String objName, String fieldName);
    String getCalculatedFormula(String objName, String formulaFieldName);
    String getReferenceTarget(String objName, String referenceFieldName);
    String getJsonFormulaFields(String searchKey);
}
