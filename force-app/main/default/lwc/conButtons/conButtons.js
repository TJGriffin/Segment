import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';


export default class ConButtons extends NavigationMixin(LightningElement) {
    @api recordId;



    handleClick(event){
    }
}