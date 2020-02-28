public with sharing class FieldMetadataServiceMock {
    private Set<String> invalidFields = new Set<String>{'TEXT'};
    private Map<String,Map<String, String>> objectFieldReferences 
        = new Map<String,Map<String,String>> {
            'object1__c' => new Map<String,String>{'points_to_object2__c' => 'object2__c',
                                                   'points_to_object3__c' => 'object3__c',
                                                   'LastModifiedBy' => 'User'},
            'object2__c' => new Map<String,String>{'points_to_object3__c' => 'object3__c',
                                                   'CreatedBy' => 'User',
                                                   'Account__c' => 'Account'}
            };

    public Boolean isValidField(String objName, String fieldName) {
        if (invalidFields.contains(fieldName)) {
            return false;
        }
        return true;
    }

    public Boolean isReferenceField(String objName, String fieldName){
        if (objectFieldReferences.containsKey(objName)) {
            if (objectFieldReferences.get(objName).containsKey(fieldName)) {
                return true;
            }
        }
        return false;
    }
    
    public String getReferenceTarget(String objName, String referenceFieldName){
        return null;
    }

    public String getJsonFormulaFields(String searchKey){
        return null;
    }
}
