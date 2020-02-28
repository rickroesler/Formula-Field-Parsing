public interface IFieldMetadataService {
    List<String> getObjects(String searchKey);
    Map<String, CustomFieldWrapper> getAllFields(string objName);
}
