import { LightningElement, wire } from 'lwc';
import getFormulaFields from '@salesforce/apex/FormulaFieldService.getFormulaFields';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class LwcObjectSearch extends LightningElement {
    searchKey = '';
    treeModel;
    objFields;
    displayTree = false;

    @wire(getFormulaFields, { searchKey: '$searchKey' })
    formulaFieldMap({ error, data }) {
        if (data) {
            this.objFields = data;
            this.treeModel = this.buildTreeModel(this.objFields);
        }
    }

    buildTreeModel(objFields) {
        const treeNodes = [];
        
        for (let [objName, fields] of Object.entries(objFields)) {
            treeNodes.push({
                label: objName,
                items: fields.map(field => ({
                    label: field.label,
                    name: objName + '.' + field.name,
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
            if (searchKey.length > 2) {
                this.displayTree = true;
                this.searchKey = searchKey;
                console.log(searchKey);
            }
        }, DELAY);
    }

    handleOnselect(event) {
        console.log(`in handleOnselect: ${event.detail.name}`);
        if (event.detail.name) {
            const apiName = event.detail.name;
            const objName = apiName.split('.')[0];
            const fieldName = apiName.split('.')[1];
            for (const field of this.objFields[objName]) {
                if (field.name == fieldName) {
                    const selectedEvent = new CustomEvent('formulafieldselected', { detail: field});
                    this.dispatchEvent(selectedEvent);    
                    break;
                }
            }
        }
    }

}