public with sharing class FormulaFieldParser {

    // searches for any pattern like 'sometext.somemoretext.somemoretext' <-- that is, any alphanumeric or underscore interspersed with '.'
    private static final string FORMULA_WORD_REGEX = '([a-zA-Z0-9_\\.]+)';
    private static Pattern formulaWordPattern = Pattern.compile(FORMULA_WORD_REGEX);

    private Map<String,Map<String, Schema.SObjectField>> objectFields = new Map<String,Map<String, Schema.SObjectField>>();
    private Map<String,Map<String, String>> objectFieldReferences = new Map<String,Map<String,String>>();
    private Set<String> formulaWords = new Set<String>();
    private Set<String> formulaDependencies = new Set<String>();
    private String calculatedFormula;

    public FormulaFieldParser(String objName, String formulaFieldName) {
        
        updateObjectFields(objName);
                        
        updateObjectFieldReferences(objName);

        this.calculatedFormula = this.objectFields.get(objName).get(formulaFieldName).getDescribe().getCalculatedFormula();
        buildFormulaWords(this.calculatedFormula);

        for (String word: formulaWords) {
            parseFormulaWord(objName, word);
        }
    }

    public String getCalculatedFormula() {
        return this.calculatedFormula;
    }

    public Set<String> getFormulaDependencies() {
        return this.formulaDependencies;
    }

    private void updateObjectFields(String objName) {
        if (!this.objectFields.containsKey(objName)) {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            this.objectFields.put(objName, fieldMap);
        }
    }

    private void updateObjectFieldReferences(String objName) {
        if (!this.objectFieldReferences.containsKey(objName)) {    
            this.objectFieldReferences.put(objName,new Map<String,String>());
        }
        
        List<EntityParticle> refFieldList = [SELECT Id, QualifiedApiName
                                             FROM EntityParticle
                                             WHERE EntityDefinition.QualifiedApiName =: objName
                                               AND DataType = 'reference']; 

        Map<String,String> fieldReferences = objectFieldReferences.get(objName);

        for(EntityParticle refField: refFieldList) {
            String fieldName = refField.QualifiedApiName;
            List<Schema.sObjectType> references = this.objectFields.get(objName).get(fieldName).getDescribe().getReferenceTo();
            //NOTE: assumes that there is only a single refernce
            fieldReferences.put(fieldName,references.get(0).getDescribe().getName());
            // if the field is a standard Id (eg, CreatedById) then map both CreatedById and CreatedBy to User
            fieldReferences.put(fieldName.removeEnd('Id'),references.get(0).getDescribe().getName());
        }
    }

    private void buildFormulaWords(String calculatedFormula) {
        Matcher formulaWordMatcher = formulaWordPattern.matcher(calculatedFormula);
        while (formulaWordMatcher.find()) {
            this.formulaWords.add(formulaWordMatcher.group(1));
            
            // move the start point forward .. after the end of the current group
            formulaWordMatcher.region(formulaWordMatcher.end(1),formulaWordMatcher.regionEnd());    
        }
    }

    //recursive: keeps peeling away the objects until it gets to the final field
    private void parseFormulaWord(String currentObject, String word) {
        // if there's no '.' in the word, we're at the field level, and we're done
        if (isFinalElement(word)) {
            processFinalElement(currentObject, word);
        } else {
            String nextObject = getNextObject(currentObject, word);
            updateObjectFields(nextObject);
            updateObjectFieldReferences(nextObject);
            
            String shorterWord = word.substringAfter('.');
            
            parseFormulaWord(nextObject, shorterWord);
        }
    }

    private Boolean isFinalElement(String word) {
        return !word.contains('.');
    }

    private void processFinalElement(String currentObject, String word) {
        Boolean isValidField = false;
        String fieldName;

        if (isReference(currentObject, word)) {
            currentObject = this.objectFieldReferences.get(currentObject).get(word);
            fieldName = 'Id';
            isValidField = true;    
        } else if (isFieldName(currentObject, word)) {
            fieldName = word;
            isValidField = true;
        }

        if (isValidField) {
            this.formulaDependencies.add(currentObject + '.' + fieldName);
        }
    }

    private Boolean isReference(String currentObject, String fieldName) {
        return this.objectFieldReferences.get(currentObject).containsKey(fieldName);
    }

    private Boolean isFieldName(String objName, String word) {
        return objectFields.get(objName).containsKey(word);
    }

    private String getNextObject(String objName, String word) {

        String nextObject = word.split('\\.')[0];
        if (nextObject.endsWith('__r')) {
            nextObject = nextObject.removeEnd('__r') + '__c'; 
        }
        
        return this.objectFieldReferences.get(objName).get(nextObject);
    }
}
