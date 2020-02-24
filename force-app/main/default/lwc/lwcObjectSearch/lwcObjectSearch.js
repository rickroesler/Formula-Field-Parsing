import { LightningElement, wire } from 'lwc';
import getFormulaFields from '@salesforce/apex/FieldMetadataService.getFormulaFields';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class LwcObjectSearch extends LightningElement {
    searchKey = '';
    treeModel;

    @wire(getFormulaFields, { searchKey: '$searchKey' })
    formulaFieldMap({ error, data }) {
        if (data) {
            this.treeModel = this.buildTreeModel(data);
            console.log(this.treeModel);
            
        }
    }

    buildTreeModel(objFields) {
        const treeNodes = [];
        
        for (let [objName, fields] of Object.entries(objFields)) {
            //fields.map(field => console.log(field));
            treeNodes.push({
                label: objName,
                items: fields.map(field => ({
                    label: field,
                    name: field
                }))
            });
        }

        return treeNodes;
    }

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
}