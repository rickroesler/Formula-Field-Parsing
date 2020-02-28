public with sharing class FormulaFieldService {
    
    // dependency injection via setter
    private static IFieldMetadataService fieldMetadataService = (IFieldMetadataService) Type.forName('FieldMetadataService').newInstance();

    //private static Map<String,Map<String, Schema.SObjectField>> allObjectFields = new Map<String,Map<String, Schema.SObjectField>>();
    private static Map<String, Map<String, CustomFieldWrapper>> allObjectFields = new Map<String,Map<String,CustomFieldWrapper>>();
    private static Map<String,Map<String, String>> objectFieldReferences = new Map<String,Map<String,String>>();

    public static void setFieldMetadataService(IFieldMetadataService service) {
        fieldMetadataService = service;
    }

    public static Boolean isValidField(String objName, String fieldName) {
        updateObjectFields(objName);
        return allObjectFields.get(objName).containsKey(fieldName);
    }

    public static Boolean isReferenceField(String objName, String fieldName) {
        updateObjectFieldReferences(objName);
        return objectFieldReferences.get(objName).containsKey(fieldName);
    }
    
    public static String getReferenceTarget(String objName, String referenceFieldName) {
        String targetObject = '';
        if (isReferenceField(objName, referenceFieldName)) {
            targetObject = objectFieldReferences.get(objName).get(referenceFieldName);
        }
        return targetObject;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<CustomFieldWrapper>> getFormulaFields(String searchKey) {
        Map<String,List<CustomFieldWrapper>> formulaFields = new Map<String,List<CustomFieldWrapper>>();

        List<String> objects = fieldMetadataService.getObjects('%' + searchKey + '%');

        for (String objName: objects) {
            updateObjectFields(objName);

            List<CustomFieldWrapper> fields = new List<CustomFieldWrapper>();
            for (CustomFieldWrapper f: allObjectFields.get(objName).values()) {
                if (f.isCalculated) {
                    fields.add(f);
                }
            }

            if (fields.size() > 0) {
                formulaFields.put(objName, fields);
            }
        }

        return formulaFields;
    }

    private static void updateObjectFields(String objName) {
        if (!allObjectFields.containsKey(objName)) {
            Map<String, CustomFieldWrapper> fieldMap = fieldMetadataService.getAllFields(objName);
            allObjectFields.put(objName, fieldMap);
        }
    }

    private static void updateObjectFieldReferences(String objName) {
        
        if (!objectFieldReferences.containsKey(objName)) {    
            updateObjectFields(objName);

            Map<String,String> referenceFields = new Map<String,String>();

            for(CustomFieldWrapper f: allObjectFields.get(objName).values()) {
                if (f.dataType == 'Reference') {
                    referenceFields.put(f.name, f.referenceTo);
                    // if the field is a standard Id (eg, CreatedById) then map both CreatedById and CreatedBy to User
                    referenceFields.put(f.name.removeEnd('Id'), f.referenceTo);
                }
            }

            objectFieldReferences.put(objName, referenceFields);
        }
    }
}
