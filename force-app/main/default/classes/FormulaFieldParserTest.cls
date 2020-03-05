
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
    public static void recurseTokensTest() {
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        List<String> tokens = new List<String>{'points_to_Object2__r','points_to_Object3__r','Account__r','Name'};
        FormulaFieldParser.recurseTokens('Object1__c', tokens);
        Set<String> dependencies = FormulaFieldParser.formulaDependencies;
        System.assertEquals(4, dependencies.size(), 'Expected exactly 4 dependent fields.');
        System.assertEquals(true, dependencies.contains('Account.Name'), 'Missing dependent field: Account.Name');
        System.assertEquals(true, dependencies.contains('Object1__c.points_to_Object2__c'), 'Missing dependent field: Object1__c.points_to_Object2__c');
        System.assertEquals(true, dependencies.contains('Object2__c.points_to_Object3__c'), 'Missing dependent field: Object2__c.points_to_Object3__c');
        System.assertEquals(true, dependencies.contains('Object3__c.Account__c'), 'Missing dependent field: Object3__c.Account__c');      
    }

    @isTest
    public static void processPlatformKeywordsCustomMetadataTest() {
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        List<String> tokens = new List<String>{'$CustomMetadata','CustomType__mdt','MetadataRecord','Field__c'};
        FormulaFieldParser.processPlatformKeyword(tokens);
        Set<String> dependencies = FormulaFieldParser.formulaDependencies;
        System.assertEquals(2, dependencies.size(), 'Expected exactly 2 dependencies.');
        System.assertEquals(true, dependencies.contains('CustomType.MetadataRecord'), 'Missing metadata record: CustomType.MetadataRecord.');
        System.assertEquals(true, dependencies.contains('CustomType__mdt.Field__c'), 'Missing dependent field: CustomType__mdt.Field__c');
    }

    @isTest
    public static void processPlatformKeywordsCustomLabelTest() {
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        List<String> tokens = new List<String>{'$Label','LabelApiName'};
        FormulaFieldParser.processPlatformKeyword(tokens);
        Set<String> dependencies = FormulaFieldParser.formulaDependencies;
        System.assertEquals(1, dependencies.size(), 'Expected exactly 1 dependency.');
        System.assertEquals(true, dependencies.contains('LabelApiName'), 'Missing metadata record: LabelApiName.');
    }

    @isTest
    public static void processPlatformKeywordsCustomSettingTest() {
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        List<String> tokens = new List<String>{'$Setup','CustomSetting__c','Field__c'};
        FormulaFieldParser.processPlatformKeyword(tokens);
        Set<String> dependencies = FormulaFieldParser.formulaDependencies;
        System.assertEquals(1, dependencies.size(), 'Expected exactly 1 dependency.');
        System.assertEquals(true, dependencies.contains('CustomSetting__c.Field__c'), 'Missing custom field: CustomSetting__c.Field__c.');
    }

    @isTest
    public static void processPlatformKeywordsCustomPermissionTest() {
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        List<String> tokens = new List<String>{'$Permission','PermissionName'};
        FormulaFieldParser.processPlatformKeyword(tokens);
        Set<String> dependencies = FormulaFieldParser.formulaDependencies;
        System.assertEquals(1, dependencies.size(), 'Expected exactly 1 dependency.');
        System.assertEquals(true, dependencies.contains('PermissionName'), 'Missing metadata record: PermissionName.');
    }

    @isTest
    public static void processPlatformKeywordsUserTest() {
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        List<String> tokens = new List<String>{'$User','Field__c'};
        FormulaFieldParser.processPlatformKeyword(tokens);
        Set<String> dependencies = FormulaFieldParser.formulaDependencies;
        System.assertEquals(1, dependencies.size(), 'Expected exactly 1 dependency.');
        System.assertEquals(true, dependencies.contains('User.Field__c'), 'Missing field: User.Field__c.');
    }

    @isTest
    public static void processPlatformKeywordsOtherTest() {
        FormulaFieldService.fieldMetadataServiceOverride(new FieldMetadataServiceMock());
        List<String> tokens = new List<String>{'$SomeOtherKeyword','Blah', 'Blah'};
        FormulaFieldParser.processPlatformKeyword(tokens);
        Set<String> dependencies = FormulaFieldParser.formulaDependencies;
        System.assertEquals(0, dependencies.size(), 'Expected no dependencies');
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
