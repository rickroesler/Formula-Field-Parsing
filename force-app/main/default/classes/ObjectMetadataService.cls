public with sharing class ObjectMetadataService {

    @AuraEnabled(cacheable=true)
    public static List<EntityDefinition> findObjects(String searchKey) {
        String key = '%' + searchKey + '%';
        return [SELECT DeveloperName 
                FROM EntityDefinition 
                WHERE DeveloperName LIKE :key 
                ORDER BY DeveloperName ASC
                LIMIT 20];
    }

}
