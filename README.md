# Salesforce Formula Field Dependency Analysis

This package allows you to 
1. select (up to 10) Objects,
2. view all the formula fields for those Objects, and
3. for each formula field, view the formula and all the dependent fields. 

In addition, I wanted to  use this project to 
1. experiment with Dependency Injection, and
2. start working with Lightning Web Components (LWC)

## Requirements
1. The User can select a list of Objects by entering part of the Object API name.
2. For each matching Object that has at least one formula field, display the list of formula fields.
3. The User can select one of the formula fields and view
    - the CustomField API name
    - the formula
    - the list of fields that the formula is dependent on
4. If the formula field is on Object1__c and refers to the field `Object2__r.Object3__r.Field__c`, we must show not only the final field dependency, `Object3__c.Field__c`, but also all intermediate dependencies: `Object1__c.Object2__c` and `Object2__c.Object3__c`.

## Installation

tbd

## Architecture - 1 - IFieldMetadataService: Getting Object and CustomField Metadata

A class with the `IFieldMetadataService` interface is responsible for providing
1. a list of Object API names that match a given search key, and 
2. a map of CustomField API names to a `CustomFieldWrapper`

```java
public interface IFieldMetadataService {
    List<String> getObjects(String searchKey);
    Map<String, CustomFieldWrapper> getAllFields(string objName);
}
```

As the name suggests, the `CustomFieldWrapper` wraps information about each CustomField so that the other classes don't need to know the details of how Salesforce stores all this information. This is important for Dependency Injection of the interface; you can't create an instance of Schema.SObjectField, for example, so the interface shouldn't be dependent on it.
 
## Architecture - 2 - FormulaFieldService: Getting Information Specific to Formula Fields

The `FormulaFieldService` exposes one @AuraEnabled method to the LWC UI: the `getFormulaFields()` method searches Objects (based on the Object API name `searchKey`) and returns a map of Object API names to a list of formula fields for that Object. We only create a map entry if there are formula fields on the Object.

```Java
@AuraEnabled(cacheable=true)
public static Map<String, List<CustomFieldWrapper>> getFormulaFields(String searchKey)
```

The service also exposes three methods for querying information about a specific field:
```Java
public static Boolean isValidField(String objName, String fieldName) 
public static Boolean isReferenceField(String objName, String fieldName) 
public static String getReferenceTarget(String objName, String referenceFieldName) 
```

## Architecture - 3 - FormulaFieldParser: Doing the Work

The `FormulaFieldParser` exposes one @AuraEnabled method to the LWC UI: the `getFormulaDependencies()` method takes a formula string and the base object for the formula field and returns a list of CustomField API names that the formula refers to.

```java
@AuraEnabled(cacheable=true)
public static List<String> getFormulaDependencies(String objName, String calculatedFormula) {
```

The parser loops through the string using this Regex matching pattern: `([a-zA-Z0-9_\\.]+)`.
- The pattern will pick up any CustomField API names like `Object1__r.Object2__r.Field__c`.
- The pattern will also pick up any formula functions like 'TEXT' and 'ISPICKVAL'. That's why we need the `isValidField` method (above); so that we can throw away these keyworks as we traverse the formula.

Each matched pattern (eg, `Object1__r.Object2__r.Field__c`) we call a 'word'. We split each word on '.' to create a list of tokens that represent the word. In our example, the list of tokens would be {'Object1__r','Object2__c','Field__c'}.

We recursively traverse the list of tokens:
- If there is only one token, then it's either a field or a formula keyword, and we're done.
- If there is more than one token, then the first token is a reference to another object. We get the object using the `getReferenceTarget()` method (above) and continue traversing the list.

## Architecture - 4 - Event Model

## Architecture - 5 - Dependency Injection

