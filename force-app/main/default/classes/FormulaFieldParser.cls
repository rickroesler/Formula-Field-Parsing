public with sharing class FormulaFieldParser {

    private IFieldMetadataService fieldMetadataService;
    
    // searches for any pattern like 'sometext.somemoretext.somemoretext' <-- that is, any alphanumeric or underscore interspersed with '.'
    private static final string FORMULA_WORD_REGEX = '([a-zA-Z0-9_\\.]+)';
    private static Pattern formulaWordPattern = Pattern.compile(FORMULA_WORD_REGEX);
    
    private Set<String> formulaWords = new Set<String>();
    private Set<String> formulaDependencies = new Set<String>();
    private String calculatedFormula;

    public FormulaFieldParser(IFieldMetadataService fieldMetadataService) {
        this.fieldMetadataService = fieldMetadataService;
    }

    public Set<String> getFormulaDependencies(String objName, String calculatedFormula) {
        buildFormulaWords(calculatedFormula);

        for (String word: this.formulaWords) {
            parseFormulaWord(objName, word);
        }

        return this.formulaDependencies;
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

        if (this.fieldMetadataService.isReferenceField(currentObject, word)) {
            currentObject = fieldMetadataService.getReferenceTarget(currentObject, word);
            fieldName = 'Id';
            isValidField = true;    
        } else if (this.fieldMetadataService.isValidField(currentObject, word)) {
            fieldName = word;
            isValidField = true;
        }

        if (isValidField) {
            this.formulaDependencies.add(currentObject + '.' + fieldName);
        }
    }

    private String getNextObject(String currentObject, String word) {

        String nextObject = word.split('\\.')[0];
        if (nextObject.endsWith('__r')) {
            nextObject = nextObject.removeEnd('__r') + '__c'; 
        }
        
        return this.fieldMetadataService.getReferenceTarget(currentObject, nextObject);
    }
}
