@isTest
public with sharing class FieldMetadataServiceMockTest {

   @isTest
   public static void getObjectsTest() {
       List<String> objects = FieldMetadataServiceMock.getObjects('obj');
       System.assertEquals(3, objects.size(), 'Should have received a list of 3 objects.');

       objects = FieldMetadataServiceMock.getObjects('NOTobj');
       System.assertEquals(0, objects.size(), 'Should have received no objects.');
   }

   @isTest
   public static void getAllFieldsTest() {
       Map<String, CustomFieldWrapper> fields = FieldMetadataServiceMock.getAllFields('Object1__c');
       System.assertEquals(5, fields.keySet().size(), 'Expected 5 fields.');
       
       fields = FieldMetadataServiceMock.getAllFields('Object2__c');
       System.assertEquals(4, fields.keySet().size(), 'Expected 4 fields.');
       
       fields = FieldMetadataServiceMock.getAllFields('Object3__c');
       System.assertEquals(3, fields.keySet().size(), 'Expected 3 fields.');
       
       fields = FieldMetadataServiceMock.getAllFields('Account');
       System.assertEquals(3, fields.keySet().size(), 'Expected 3 fields.');
       
       fields = FieldMetadataServiceMock.getAllFields('Opportunity');
       System.assertEquals(2, fields.keySet().size(), 'Expected 2 fields.');

       fields = FieldMetadataServiceMock.getAllFields('not_an_object');
       System.assertEquals(0, fields.keySet().size(), 'Expected 0 fields.');

    }
}
