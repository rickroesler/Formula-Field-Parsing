@isTest
public with sharing class FieldMetadataServiceTest {
    
    @isTest
    public static void getObjectsTest() {
        List<String> objects = FieldMetadataService.getObjects('acc');
        System.assertEquals(true, objects.contains('Account'), 'Should have retrieved the Account object.');

        objects = FieldMetadataService.getObjects('abcdefghijklmnop');
        System.assertEquals(0, objects.size(), 'Should have received no objects.');
    }
 
    @isTest
    public static void getAllFieldsTest() {
        Map<String, CustomFieldWrapper> fields = FieldMetadataService.getAllFields('Account');
        System.assertEquals(true, fields.keySet().contains('Name'), 'Should have retrieved the Account.Name field.');
     }
}
