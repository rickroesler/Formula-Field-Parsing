public with sharing class FieldMetadataService implements IFieldMetadataService {
    
    public static List<String> getObjects(String searchKey) {

        String key = '%' + searchKey + '%';
        List<String> objects = new List<String>();

        List<EntityDefinition> entities = new List<EntityDefinition>([SELECT QualifiedApiName 
                                                                     FROM EntityDefinition 
                                                                     WHERE QualifiedApiName LIKE :key 
                                                                     ORDER BY QualifiedApiName ASC
                                                                     LIMIT 10]);

        for (EntityDefinition e: entities) {
            objects.add(e.QualifiedApiName);
        }

        return objects;
    }
    
    public static Map<String, CustomFieldWrapper> getAllFields(String objName) {
        
        Map<String, CustomFieldWrapper> allFields = new Map<String, CustomFieldWrapper>();

        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        for (Schema.SObjectField f: fieldMap.values()) {
            CustomFieldWrapper formulaField = new CustomFieldWrapper();
            formulaField.parentObject = objName;
            formulaField.name = f.getDescribe().getName();
            formulaField.label = f.getDescribe().getLabel();
            formulaField.isCalculated = f.getDescribe().isCalculated();
            formulaField.calculatedFormula = f.getDescribe().getCalculatedFormula();
            formulaField.dataType = f.getDescribe().getType().name();
            
            List<Schema.SObjectType> referenceTargets = f.getDescribe().getReferenceTo();
            if (formulaField.dataType == 'Reference' && referenceTargets != null) {
                formulaField.referenceTo = referenceTargets.get(0).getDescribe().getName();
            }
            
            allFields.put(formulaField.name, formulaField);
        }
    
        return allFields;
    }

}
