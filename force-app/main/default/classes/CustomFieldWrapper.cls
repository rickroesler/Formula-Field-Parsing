public with sharing class CustomFieldWrapper {
    @AuraEnabled
    public String parentObject { get; set; }
    
    @AuraEnabled
    public String name { get; set; }
    
    @AuraEnabled
    public String label { get; set; }
    
    @AuraEnabled
    public String calculatedFormula { get; set; }

    public Boolean isCalculated;
    public String dataType;
    public String referenceTo;
}
