@isTest
public with sharing class FormulaFieldServiceTest {

    @TestSetup
    static void makeData(){
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
    }

    @isTest
    public static void isValidFieldTest() {
        Boolean valid = FormulaFieldService.isValidField('Object1__c', 'text1__c');
        System.assertEquals(true, valid, 'Expected Object1__c.text1__c to be valid.');

        valid = FormulaFieldService.isValidField('Object2__c', 'not_a_field');
        System.assertEquals(false, valid, 'Expected Object2__c.not_a_field to be invalid.');
    }

    @isTest
    public static void isReferenceFieldTest() {
        Boolean valid = FormulaFieldService.isReferenceField('Object1__c', 'points_to_Object2__c');
        System.assertEquals(true, valid, 'Expected Object1__c.points_to_Object2__c to be valid.');

        valid = FormulaFieldService.isReferenceField('Object2__c', 'text1__c');
        System.assertEquals(false, valid, 'Expected Object2__c.text1__c to not be a valid reference field.');
    }
    
    @isTest
    public static void getReferenceTargetTest() {
        String referenceTarget;

        referenceTarget = FormulaFieldService.getReferenceTarget('Object1__c', 'points_to_Object2__c');
        System.assertEquals('Object2__c', referenceTarget, 'Expected Object1__c.points_to_Object2__c to point to Object2__c.');

        referenceTarget = FormulaFieldService.getReferenceTarget('Object1__c', 'Account__c');
        System.assertEquals('Account', referenceTarget, 'Expected Object1__c.points_to_Object2__c to point to Object2__c.');

        referenceTarget = FormulaFieldService.getReferenceTarget('Opportunity', 'Account');
        System.assertEquals('Account', referenceTarget, 'Expected Object1__c.points_to_Object2__c to point to Object2__c.');

        referenceTarget = FormulaFieldService.getReferenceTarget('Opportunity', 'AccountId');
        System.assertEquals('Account', referenceTarget, 'Expected Object1__c.points_to_Object2__c to point to Object2__c.');
    }

    @isTest
    public static void getFormulaFieldsTest() {
        Map<String, List<CustomFieldWrapper>> fields;

        fields = FormulaFieldService.getFormulaFields('obj');
        System.assertEquals(2, fields.keySet().size(), 'Expected 2 objects with formula fields');
        System.assertEquals(true, fields.keySet().contains('Object1__c'), 'Expected Object1__c to have formula fields');
        System.assertEquals(true, fields.keySet().contains('Object2__c'), 'Expected Object2__c to have formula fields');
        System.assertEquals(2, fields.get('Object1__c').size(), 'Expected Object1__c to have 2 formula fields');
        System.assertEquals(1, fields.get('Object2__c').size(), 'Expected Object2__c to have 1 formula fields');

        fields = FormulaFieldService.getFormulaFields('not_obj');
        System.assertEquals(0, fields.keySet().size(), 'Expected no formula fields');
    }

}
