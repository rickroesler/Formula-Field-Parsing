import { LightningElement, wire } from 'lwc';
import getJsonFormulaFields from '@salesforce/apex/FieldMetadataService.getJsonFormulaFields';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class LwcObjectSearch extends LightningElement {
    searchKey = '';
    treeModel;
    objFields;

    @wire(getJsonFormulaFields, { searchKey: '$searchKey' })
    formulaFieldMap({ error, data }) {
        if (data) {
            this.objFields = JSON.parse(data);
            this.treeModel = this.buildTreeModel(this.objFields);
            console.log(this.objFields);
            console.log(this.treeModel);
        }
    }

    buildTreeModel(objFields) {
        const treeNodes = [];
        
        for (let [objName, fields] of Object.entries(objFields)) {
            fields.map(field => console.log(field));
            treeNodes.push({
                label: objName,
                items: fields.map(field => ({
                    label: field.label,
                    name: objName + '.' + field.apiName,
                }))
            });
        }

        return treeNodes;
    }

    // copied from LWC recipes
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }

    handleOnselect(event) {
        console.log(`selected: ${event.detail.name}`);
    }
}