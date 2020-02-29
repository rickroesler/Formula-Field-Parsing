public with sharing class FieldMetadataServiceMock implements IFieldMetadataService {
    private static List<String> objects = new List<String>{'Object1__c','Object2__c','Object3__c'};
    
    private static Map<String,CustomFieldWrapper> object1Fields
        = new Map<String,CustomFieldWrapper>{'formula1__c' => new CustomFieldWrapper(),
                                             'formula2__c' => new CustomFieldWrapper(),
                                             'Account__c' => new CustomFieldWrapper(),
                                             'points_to_Object2__c' => new CustomFieldWrapper(),
                                             'text1__c' => new CustomFieldWrapper()};
    private static Map<String,CustomFieldWrapper> object2Fields
        = new Map<String,CustomFieldWrapper>{'formula1__c' => new CustomFieldWrapper(),
                                             'Account__c' => new CustomFieldWrapper(),
                                             'points_to_Object3__c' => new CustomFieldWrapper(),
                                             'text1__c' => new CustomFieldWrapper()};
    private static Map<String,CustomFieldWrapper> object3Fields
        = new Map<String,CustomFieldWrapper>{'Account__c' => new CustomFieldWrapper(),
                                             'Opportunity__c' => new CustomFieldWrapper(),
                                             'text1__c' => new CustomFieldWrapper()};
    private static Map<String,CustomFieldWrapper> accountFields
        = new Map<String,CustomFieldWrapper>{'text1__c' => new CustomFieldWrapper(),
                                             'Id' => new CustomFieldWrapper(),
                                             'Name' => new CustomFieldWrapper()};
    private static Map<String,CustomFieldWrapper> opportunityFields
        = new Map<String,CustomFieldWrapper>{'Name' => new CustomFieldWrapper(),
                                             'AccountId' => new CustomFieldWrapper()};                                                                                                                                                                                     

    static {
        CustomFieldWrapper f;

        // object1, formula1
        f = object1Fields.get('formula1__c');
        f.parentObject = 'Object1__c';
        f.name = 'formula1__c';
        f.label = 'Custom Formula 1';
        f.isCalculated = true;
        f.calculatedFormula = 'points_to_Object2__r.text1__c + points_to_Object2__r.points_to_Object3__r.Account__r.Name';
        f.dataType = 'Text';
        f.referenceTo = null;

        // object1, formula2
        f = object1Fields.get('formula2__c');
        f.parentObject = 'Object1__c';
        f.name = 'formula2__c';
        f.label = 'Custom Formula 2';
        f.isCalculated = true;
        f.calculatedFormula = 'TEXT(Account__r.Name) + text1__c + points_to_Object2__r.text1__c';
        f.dataType = 'Text';
        f.referenceTo = null;

        // object1, Account
        f = object1Fields.get('Account__c');
        f.parentObject = 'Object1__c';
        f.name = 'Account__c';
        f.label = 'Account';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Reference';
        f.referenceTo = 'Account';

        // object1, points_to_Object2
        f = object1Fields.get('points_to_Object2__c');
        f.parentObject = 'Object1__c';
        f.name = 'points_to_Object2__c';
        f.label = 'Object 2';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Reference';
        f.referenceTo = 'Object2__c';

        // object1, text1
        f = object1Fields.get('text1__c');
        f.parentObject = 'Object1__c';
        f.name = 'text1__c';
        f.label = 'Text Field';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Text';
        f.referenceTo = null;

        // object2, formula1
        f = object2Fields.get('formula1__c');
        f.parentObject = 'Object2__c';
        f.name = 'formula1__c';
        f.label = 'Custom Formula 1';
        f.isCalculated = true;
        f.calculatedFormula = 'text1__c + points_to_Object3__r.Account__c + points_to_Object3__r.Opportunity__r.Account.text1__c';
        f.dataType = 'Text';
        f.referenceTo = null;

        // object2, Account
        f = object2Fields.get('Account__c');
        f.parentObject = 'Object2__c';
        f.name = 'Account__c';
        f.label = 'Account';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Reference';
        f.referenceTo = 'Account';

        // object2, points_to_Object3
        f = object2Fields.get('points_to_Object3__c');
        f.parentObject = 'Object2__c';
        f.name = 'points_to_Object3__c';
        f.label = 'Object 3';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Reference';
        f.referenceTo = 'Object3__c';

        // object2, text1
        f = object2Fields.get('text1__c');
        f.parentObject = 'Object2__c';
        f.name = 'text1__c';
        f.label = 'Text Field';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Text';
        f.referenceTo = null;

        // object3, Account
        f = object3Fields.get('Account__c');
        f.parentObject = 'Object3__c';
        f.name = 'Account__c';
        f.label = 'Account';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Reference';
        f.referenceTo = 'Account';

        // object3, Opportunity
        f = object3Fields.get('Opportunity__c');
        f.parentObject = 'Object3__c';
        f.name = 'Opportunity__c';
        f.label = 'Opportunity';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Reference';
        f.referenceTo = 'Opportunity';

        // object3, text1
        f = object3Fields.get('text1__c');
        f.parentObject = 'Object3__c';
        f.name = 'text1__c';
        f.label = 'Text Field';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Text';
        f.referenceTo = null;

        // Account, text1
        f = accountFields.get('text1__c');
        f.parentObject = 'Account';
        f.name = 'text1__c';
        f.label = 'Text Field';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Text';
        f.referenceTo = null;

        // Account, Name
        f = accountFields.get('Name');
        f.parentObject = 'Account';
        f.name = 'Name';
        f.label = 'Account Name';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Text';
        f.referenceTo = null;

        // Account, Id
        f = accountFields.get('Id');
        f.parentObject = 'Account';
        f.name = 'Id';
        f.label = 'Account Id';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Text';
        f.referenceTo = null;

        // Opportunity, Name
        f = opportunityFields.get('Name');
        f.parentObject = 'Opportunity';
        f.name = 'Name';
        f.label = 'Opportunity Name';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Text';
        f.referenceTo = null;

        // Opportunity, Account
        f = opportunityFields.get('AccountId');
        f.parentObject = 'Opportunity';
        f.name = 'AccountId';
        f.label = 'Account';
        f.isCalculated = false;
        f.calculatedFormula = null;
        f.dataType = 'Reference';
        f.referenceTo = 'Account';
        
    }

    public static List<String> getObjects(String searchKey) {
        switch on searchKey {
            when 'obj' {
                return objects;
            }	
            when else {
                return new List<String>();
            }
        }
    }

    public static Map<String, CustomFieldWrapper> getAllFields(string objName) {
        switch on objName {
            when 'Object1__c' {
                return object1Fields;
            }	
            when 'Object2__c' {
                return object2Fields;
            }
            when 'Object3__c' {
                return object3Fields;
            }
            when 'Account' {
                return accountFields;
            }
            when 'Opportunity' {
                return opportunityFields;
            }
            when else {
                return new Map<String, CustomFieldWrapper>();
            }
        }
    }
}
