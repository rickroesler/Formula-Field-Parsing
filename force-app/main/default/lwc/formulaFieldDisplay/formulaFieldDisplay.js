import { LightningElement, wire } from 'lwc';

export default class FormulaFieldDisplay extends LightningElement {
    field='';
    dependencies='';

    handleFormulaFieldSelected(event) {
        this.field = event.detail;
    }
}