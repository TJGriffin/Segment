import { LightningElement, api, wire } from 'lwc';
import wireGetCustomBadges from '@salesforce/apex/CON_Badge_CTRL.getCustomBadges';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import SUSTAINER from '@salesforce/schema/Contact.cfg_Sustaining_Member_Status__c';
import LEVEL from '@salesforce/schema/Contact.Donor_Segment__c';
import DECEASED from '@salesforce/schema/Contact.npsp__Deceased__c';
import DNC from '@salesforce/schema/Contact.npsp__Do_Not_Contact__c';

export default class ConBadges extends LightningElement {
    @api recordId;
    @api labels;

    @wire(
        getRecord, 
        {
            recordId:'$recordId', 
            optionalFields: [
                LEVEL,
                SUSTAINER,
                DECEASED,
                DNC
            ]
        }
    )
    contact; 

    @wire(wireGetCustomBadges,{recordId:'$recordId'})
    setLabels(result){
        const {data,error} = result;
        if(data){
            console.log(JSON.stringify(data));
            this.labels = data;
        }
    }

    
    get levelName(){
        return getFieldValue(this.contact.data,LEVEL);
    }
    get sustainerStatus(){
        return getFieldValue(this.contact.data,SUSTAINER);
    }
    get deceasedStatus(){
        var deceased;
        if(getFieldValue(this.contact.data,DECEASED))
            deceased = 'Deceased';
        return deceased;
    }
    get dncStatus(){
        var dnc;
        if(getFieldValue(this.contact.data,DNC))
            dnc = 'Do Not Contact';
        return dnc;
    }
}