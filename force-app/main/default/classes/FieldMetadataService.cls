public with sharing class FieldMetadataService implements IFieldMetadataService {
    
    private Map<String,Map<String, Schema.SObjectField>> objectFields = new Map<String,Map<String, Schema.SObjectField>>();
    private Map<String,Map<String, String>> objectFieldReferences = new Map<String,Map<String,String>>();

    public Boolean isValidField(String objName, String fieldName) {
        updateObjectFields(objName);
        return this.objectFields.get(objName).containsKey(fieldName);
    }

    public String getCalculatedFormula(String objName, String formulaFieldName){
        updateObjectFields(objName);
        return this.objectFields.get(objName).get(formulaFieldName).getDescribe().getCalculatedFormula();
    }
 
    public Boolean isReferenceField(String objName, String fieldName) {
        updateObjectFieldReferences(objName);
        return this.objectFieldReferences.get(objName).containsKey(fieldName);
    }
    
    public String getReferenceTarget(String objName, String referenceFieldName) {
        String targetObject = '';
        if (isReferenceField(objName, referenceFieldName)) {
            targetObject = this.objectFieldReferences.get(objName).get(referenceFieldName);
        }
        return targetObject;
    }

    @AuraEnabled(cacheable=true)
    public static String getJsonFormulaFields(String searchKey) {
        Map<String,List<FieldMetadataService.FormulaField>> formulaFields = new Map<String,List<FieldMetadataService.FormulaField>>();

        String key = '%' + searchKey + '%';
        List<EntityDefinition> entities = new List<EntityDefinition>([SELECT QualifiedApiName 
                                                                     FROM EntityDefinition 
                                                                     WHERE QualifiedApiName LIKE :key 
                                                                     ORDER BY QualifiedApiName ASC
                                                                     LIMIT 10]);

        Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
        for (EntityDefinition entity: entities) {
            String objName = entity.QualifiedApiName;
            Map<String, SObjectField> allFields = allObjects.get(objName).getDescribe().fields.getMap();
            
            for (SObjectField f: allFields.values()) {
                if (f.getDescribe().isCalculated()) {
                    FieldMetadataService.FormulaField formulaField = new FieldMetadataService.FormulaField();
                    formulaField.apiName = f.getDescribe().getName();
                    formulaField.calculatedFormula = f.getDescribe().getCalculatedFormula();
                    formulaField.label = f.getDescribe().getLabel();
                    formulaField.parentObject = objName;
                    if (formulaFields.containsKey(objName)) {
                        formulaFields.get(objName).add(formulaField);
                    } else {
                        formulaFields.put(objName, new List<FieldMetadataService.FormulaField>{formulaField});
                    }
                }
            }
        }

        return Json.serialize(formulaFields);
    }

    private void updateObjectFields(String objName) {
        if (!this.objectFields.containsKey(objName)) {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            this.objectFields.put(objName, fieldMap);
        }
    }

    private void updateObjectFieldReferences(String objName) {
        updateObjectFields(objName);
        if (!this.objectFieldReferences.containsKey(objName)) {    
            this.objectFieldReferences.put(objName,new Map<String,String>());
        }
        
        List<EntityParticle> refFieldList = [SELECT Id, QualifiedApiName
                                             FROM EntityParticle
                                             WHERE EntityDefinition.QualifiedApiName =: objName
                                               AND DataType = 'reference']; 

        Map<String,String> fieldReferences = objectFieldReferences.get(objName);

        for(EntityParticle refField: refFieldList) {
            String fieldName = refField.QualifiedApiName;
            List<Schema.sObjectType> references = this.objectFields.get(objName).get(fieldName).getDescribe().getReferenceTo();
            //NOTE: assumes that there is only a single refernce
            fieldReferences.put(fieldName,references.get(0).getDescribe().getName());
            // if the field is a standard Id (eg, CreatedById) then map both CreatedById and CreatedBy to User
            fieldReferences.put(fieldName.removeEnd('Id'),references.get(0).getDescribe().getName());
        }
    }

    class FormulaField {
        String parentObject;
        protected String apiName;
        String label;
        String calculatedFormula;
    }
}
