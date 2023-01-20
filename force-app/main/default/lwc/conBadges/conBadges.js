import { LightningElement, api, wire } from 'lwc';
import wireGetCustomBadges from '@salesforce/apex/CON_Badge_CTRL.getCustomBadges';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
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

    get className(){
        if(typeof this.levelName === undefined || this.levelName == null)
            return 'tangerine';
        
        if(this.levelName.includes('Lapse')){
            return 'cobalt';
        } else if(this.levelName.includes('Beacon')){
            return 'violet';
        } else if(this.levelName.includes('North')){
            return 'teal';
        } else if(this.levelName.includes('Active') && this.levelName.includes('Luminary')){
            return 'canary';
        } else {
            return 'tangerine';
        }
    }
    
    get levelName(){
        var lvl = getFieldValue(this.contact.data,LEVEL);
        if(typeof lvl === undefined || lvl == null)
            return null;
        lvl = lvl.replace('Mid Level Donor','Beacon').replace('Major Donor','North Star').replace('Sustainer','Luminary');
        
        return lvl;
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