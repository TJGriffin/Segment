import { LightningElement, api, wire } from 'lwc';
import wireGetCustomBadges from '@salesforce/apex/CON_Badge_CTRL.getCustomBadges';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import LEVEL from '@salesforce/schema/Account.Donor_Segment__c';
import GRANTMAKER from '@salesforce/schema/Account.npsp__Grantmaker__c';
import PRIMARY_CONTACT from '@salesforce/schema/Account.npe01__One2OneContact__c';
import PRIMARY_CONTACT_NAME from '@salesforce/schema/Account.npe01__One2OneContact__r.Name';

export default class AccBadges extends LightningElement {
    @api recordId;
    @api labels;

    @wire(
        getRecord, 
        {
            recordId:'$recordId', 
            optionalFields: [
                GRANTMAKER,
                LEVEL,
                PRIMARY_CONTACT,
                PRIMARY_CONTACT_NAME
            ]
        }
    )
    account;

    get className(){
        if(typeof this.levelName === undefined || this.levelName == null)
            return 'tangerine';
        
        if(this.levelName.includes('Lapse')){
            return 'cobalt';
        } else if(this.levelName.includes('Beacon')){
            return 'violet';
        } else if(this.levelName.includes('North')){
            return 'teal';
        } else if(this.levelName.includes('Active Luminary')){
            return 'canary';
        } else {
            return 'tangerine';
        }
    }

    @wire(wireGetCustomBadges,{recordId:'$recordId'})
    setLabels(result){
        const {data,error} = result;
        if(data){
            this.labels = data;
        }
    }
   
    get levelName(){
        var lvl = getFieldValue(this.account.data,LEVEL);
        if(typeof lvl === undefined || lvl == null)
            return null;

        lvl = lvl.replace('Mid Level Donor','Beacon').replace('Major Donor','North Star').replace('Sustainer','Luminary');
        
        return lvl;
    }
    
}