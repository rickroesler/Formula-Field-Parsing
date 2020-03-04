// MUST inject fieldMetadataService using setFieldMetadataService() prior to calling
public with sharing class FormulaFieldParser {

    // initialize to the default service; can override with the setFieldMetadataService() method
    //private static IFieldMetadataService fieldMetadataService = new FieldMetadataService();
    
    // searches for any pattern like 'sometext.somemoretext.somemoretext' <-- that is, any alphanumeric or underscore interspersed with '.'
    private static final string FORMULA_WORD_REGEX = '([a-zA-Z0-9_\\.]+)';
    private static Pattern formulaWordPattern = Pattern.compile(FORMULA_WORD_REGEX);
    
    private static final string PERIOD = '\\.';

    // we call an api name pattern like 'sometext.somemoretext.somemoretext' a "word"
    // each word is comprised of a list of period-delimited "token"s
    // in this case {'sometext','somemoretext','somemoretext'}
    private static Set<List<String>> formulaWords = new Set<List<String>>();

    private static Set<String> formulaDependencies;

    @AuraEnabled(cacheable=true)
    public static List<String> getFormulaDependencies(String objName, String calculatedFormula) {
        formulaDependencies = new Set<String>();
        
        buildFormulaWords(calculatedFormula);

        for (List<String> tokens: formulaWords) {
            recurseTokens(objName, tokens);
        }

        List<String> dependencies = new List<String>(formulaDependencies);
        dependencies.sort();
        return dependencies; 
    }

    @TestVisible
    private static void buildFormulaWords(String calculatedFormula) {
        Matcher formulaWordMatcher = formulaWordPattern.matcher(calculatedFormula);
        while (formulaWordMatcher.find()) {
            String word = formulaWordMatcher.group(1);
            List<String> tokens = word.split(PERIOD);
            formulaWords.add(tokens);
            
            // move the start point forward .. after the end of the current group
            formulaWordMatcher.region(formulaWordMatcher.end(1),formulaWordMatcher.regionEnd());    
        }
    }

    // recursive: keeps peeling away the objects until it gets to the final field
    // remember: the "word" is a List of tokens, each of which will represent an object reference or a field
    @TestVisible
    private static void recurseTokens(String currentObject, List<String> tokens) {
        // if there's only one token left, then we're at the field level, and we're done
        if (tokens.size() == 1) {
            if (FormulaFieldService.isValidField(currentObject, tokens[0])) {
                formulaDependencies.add(currentObject + '.' + tokens[0]);
            }
        } else {
            processNextIntermediateField(currentObject, tokens[0]);

            String nextObject = getNextObject(currentObject, tokens.remove(0));
            recurseTokens(nextObject, tokens);
        }
    }

    @TestVisible
    private static void processNextIntermediateField(String currentObject, String token) {
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

        if (FormulaFieldService.isReferenceField(currentObject, referenceField)) {
            formulaDependencies.add(currentObject + '.' + referenceField);
        } else {
            system.debug(currentObject + ':' + token + ' -- ' + referenceField + ' is not a reference field');
        }
    }

    @TestVisible
    private static String getNextObject(String currentObject, String nextObject) {

        if (nextObject.endsWith('__r')) {
            nextObject = nextObject.removeEnd('__r') + '__c'; 
        }
        
        return FormulaFieldService.getReferenceTarget(currentObject, nextObject);
    }
}
