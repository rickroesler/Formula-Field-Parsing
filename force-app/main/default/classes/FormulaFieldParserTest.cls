
@isTest
public with sharing class FormulaFieldParserTest {

    @isTest
    public static void buildFormulaWordsTest() {
        Set<List<String>> actual;
        actual = new Set<List<String>>{New List<String>{'Object1__r','Object2__r','Field__c'}};
        System.assertEquals(true,actual.equals(FormulaFieldParser.buildFormulaWords('Object1__r.Object2__r.Field__c')),'Incorrect Set of formulaWords.');

        actual = new Set<List<String>>{New List<String>{'$CustomMetadata','CustomType__mdt','MetadataRecord','Field__c'}};
        System.assertEquals(true,actual.equals(FormulaFieldParser.buildFormulaWords('$CustomMetadata.CustomType__mdt.MetadataRecord.Field__c')),'Did not match initial "$".');
    }

    @isTest
    public static void getFormulaDependenciesTest() {
        List<String> dependencies;

        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        dependencies = FormulaFieldParser.getFormulaDependencies('Object1__c', 'points_to_Object2__r.text1__c + points_to_Object2__r.points_to_Object3__r.Account__r.Name');
        System.assertEquals(5, dependencies.size(), 'Expected exactly 5 dependent fields.');
        System.assertEquals(true, dependencies.contains('Account.Name'), 'Missing dependent field: Account.Name');
        System.assertEquals(true, dependencies.contains('Object1__c.points_to_Object2__c'), 'Missing dependent field: Object1__c.points_to_Object2__c');
        System.assertEquals(true, dependencies.contains('Object2__c.points_to_Object3__c'), 'Missing dependent field: Object2__c.points_to_Object3__c');
        System.assertEquals(true, dependencies.contains('Object3__c.Account__c'), 'Missing dependent field: Object3__c.Account__c');
        System.assertEquals(true, dependencies.contains('Object2__c.text1__c'), 'Missing dependent field: Object2__c.text1__c');
        
        dependencies = FormulaFieldParser.getFormulaDependencies('Object1__c', 'TEXT(Account__r.Name) + text1__c + points_to_Object2__r.text1__c');
        System.assertEquals(5, dependencies.size(), 'Expected exactly 5 dependent fields.');
        System.assertEquals(true, dependencies.contains('Account.Name'), 'Missing dependent field: Account.Name');
        System.assertEquals(true, dependencies.contains('Object1__c.points_to_Object2__c'), 'Missing dependent field: Object1__c.points_to_Object2__c');
        System.assertEquals(true, dependencies.contains('Object2__c.text1__c'), 'Missing dependent field: Object2__c.text1__c');
        System.assertEquals(true, dependencies.contains('Object1__c.Account__c'), 'Missing dependent field: Object1__c.Account__c');
        System.assertEquals(true, dependencies.contains('Object1__c.text1__c'), 'Missing dependent field: Object1__c.text1__c');
        
        dependencies = FormulaFieldParser.getFormulaDependencies('Object2__c', 'text1__c + points_to_Object3__r.Account__c + points_to_Object3__r.Opportunity__r.Account.text1__c'); 
        System.assertEquals(6, dependencies.size(), 'Expected exactly 6 dependent fields.');
        System.assertEquals(true, dependencies.contains('Account.text1__c'), 'Missing dependent field: Account.text1__c');
        System.assertEquals(true, dependencies.contains('Object2__c.points_to_Object3__c'), 'Missing dependent field: Object2__c.points_to_Object3__c');
        System.assertEquals(true, dependencies.contains('Object2__c.text1__c'), 'Missing dependent field: Object2__c.text1__c');
        System.assertEquals(true, dependencies.contains('Object3__c.Account__c'), 'Missing dependent field: Object3__c.Account__c');
        System.assertEquals(true, dependencies.contains('Object3__c.Opportunity__c'), 'Missing dependent field: Object3__c.Opportunity__c');
        System.assertEquals(true, dependencies.contains('Opportunity.AccountId'), 'Missing dependent field: Opportunity.AccountId');
        
    }
}
