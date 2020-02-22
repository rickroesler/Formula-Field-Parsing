public with sharing class FormulaFieldParser {

    private IFieldMetadataService fieldMetadataService;
    
    // searches for any pattern like 'sometext.somemoretext.somemoretext' <-- that is, any alphanumeric or underscore interspersed with '.'
    private static final string FORMULA_WORD_REGEX = '([a-zA-Z0-9_\\.]+)';
    private static Pattern formulaWordPattern = Pattern.compile(FORMULA_WORD_REGEX);
    
    private static final string PERIOD = '\\.';

    // we call an api name pattern like 'sometext.somemoretext.somemoretext' a "word"
    // each word is comprised of a list of period-delimited "token"s
    // in this case {'sometext','somemoretext','somemoretext'}
    private Set<List<String>> formulaWords = new Set<List<String>>();

    private Set<String> formulaDependencies = new Set<String>();
    private String calculatedFormula;

    public FormulaFieldParser(IFieldMetadataService fieldMetadataService) {
        this.fieldMetadataService = fieldMetadataService;
    }

    public Set<String> getFormulaDependencies(String objName, String calculatedFormula) {
        buildFormulaWords(calculatedFormula);

        for (List<String> tokens: this.formulaWords) {
            recurseTokens(objName, tokens);
        }

        return this.formulaDependencies;
    }


    private void buildFormulaWords(String calculatedFormula) {
        Matcher formulaWordMatcher = formulaWordPattern.matcher(calculatedFormula);
        while (formulaWordMatcher.find()) {
            String word = formulaWordMatcher.group(1);
            List<String> tokens = word.split(PERIOD);
            this.formulaWords.add(tokens);
            
            // move the start point forward .. after the end of the current group
            formulaWordMatcher.region(formulaWordMatcher.end(1),formulaWordMatcher.regionEnd());    
        }
    }

    // recursive: keeps peeling away the objects until it gets to the final field
    // remember: the "word" is a List of tokens, each of which will represent an object reference or a field
    private void recurseTokens(String currentObject, List<String> tokens) {
        // if there's only one token left, then we're at the field level, and we're done
        if (tokens.size() == 1) {
            processFinalToken(currentObject, tokens[0]);
        } else {
            processNextIntermediateField(currentObject, tokens[0]);

            String nextObject = getNextObject(currentObject, tokens.remove(0));
            recurseTokens(nextObject, tokens);
        }
    }

    private void processFinalToken(String currentObject, String token) {
        Boolean isValidField = false;
        String fieldName;

        if (this.fieldMetadataService.isReferenceField(currentObject, token)) {
            currentObject = fieldMetadataService.getReferenceTarget(currentObject, token);
            fieldName = 'Id';
            isValidField = true;    
        } else if (this.fieldMetadataService.isValidField(currentObject, token)) {
            fieldName = token;
            isValidField = true;
        }

        if (isValidField) {
            this.formulaDependencies.add(currentObject + '.' + fieldName);
        }
    }

    private void processNextIntermediateField(String currentObject, String token) {
        // if not the final token, then it should be a reference
        // if a reference it will be something like 'object__r' or 'Account'
        //      object__r => object__c
        //      Account => AccountId
        String referenceField = '';
        if (token.endsWith('__r')) {
            referenceField = token.removeEnd('__r') + '__c';
        } else {
            referenceField = token + 'Id';
        }

        if (this.fieldMetadataService.isReferenceField(currentObject, referenceField)) {
            this.formulaDependencies.add(currentObject + '.' + referenceField);
        } else {
            system.debug(currentObject + ':' + token + ' -- ' + referenceField + ' is not a reference field');
        }
    }

    private String getNextObject(String currentObject, String nextObject) {

        if (nextObject.endsWith('__r')) {
            nextObject = nextObject.removeEnd('__r') + '__c'; 
        }
        
        return this.fieldMetadataService.getReferenceTarget(currentObject, nextObject);
    }
}
