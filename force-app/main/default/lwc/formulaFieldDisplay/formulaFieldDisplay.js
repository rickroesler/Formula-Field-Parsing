import { LightningElement, wire } from 'lwc';
import getFormulaDependencies from '@salesforce/apex/FormulaFieldParser.getFormulaDependencies';

export default class FormulaFieldDisplay extends LightningElement {
    field='';
    objName;
    calculatedFormula;
    dependencies=[''];

    @wire(getFormulaDependencies, { objName: '$objName', calculatedFormula: '$calculatedFormula' })
    getDependencies( { error, data }) {
        if (data) {
            this.dependencies = data;
        }
    }

    handleFormulaFieldSelected(event) {
        this.field = event.detail;
        this.objName = this.field.parentObject;
        this.calculatedFormula = this.field.calculatedFormula;
    }
}