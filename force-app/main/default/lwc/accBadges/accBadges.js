import { LightningElement, api, wire } from 'lwc';
import wireGetCustomBadges from '@salesforce/apex/CON_Badge_CTRL.getCustomBadges';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import DAF from '@salesforce/schema/Account.cfg_Donor_Advised_Fund__c';
import DAF_NAME from '@salesforce/schema/Account.cfg_Donor_Advised_Fund_Name__c';
import DAF_DONOR_NAME from '@salesforce/schema/Account.cfg_Donor__r.Name';
import DAF_DONOR_ID from '@salesforce/schema/Account.cfg_Donor__c';
import FAMILY_FOUNDATION_NAME from '@salesforce/schema/Account.cfg_Family_Foundation_Name__c';
import TRUST_NAME from '@salesforce/schema/Account.cfg_Trust_Name__c';
import SUSTAINER_STATUS from '@salesforce/schema/Account.cfg_Sustaining_Member_Status__c';
import CHANGE_DONOR from '@salesforce/schema/Account.CHANGE_Donor__c';
import IWHC_DONOR from '@salesforce/schema/Account.IWHC_Donor__c';
import FF_DONOR from '@salesforce/schema/Account.Existing_Fos_Feminista_Donor__c';
import FUNDING_FOCUS from '@salesforce/schema/Account.npsp__Funding_Focus__c';
import LEVEL from '@salesforce/schema/Account.Donor_Segment__c';
import GRANTMAKER from '@salesforce/schema/Account.npsp__Grantmaker__c';
import PRIMARY_CONTACT from '@salesforce/schema/Account.npe01__One2OneContact__c';
import PRIMARY_CONTACT_NAME from '@salesforce/schema/Account.npe01__One2OneContact__r.Name';
import PRIMARY_SOLICITOR from '@salesforce/schema/Account.cfg_Primary_Solicitor__c';
import PRIMARY_SOLICITOR_NAME from '@salesforce/schema/Account.cfg_Primary_Solicitor__r.Name';
import SECONDARY_SOLICITOR from '@salesforce/schema/Account.cfg_Secondary_Solicitor__c';
import SECONDARY_SOLICITOR_NAME from '@salesforce/schema/Account.cfg_Secondary_Solicitor__r.Name';

export default class AccBadges extends LightningElement {
    @api recordId;
    @api labels;

    @wire(
        getRecord, 
        {
            recordId:'$recordId', 
            optionalFields: [
                DAF,
                DAF_NAME,
                DAF_DONOR_NAME,
                DAF_DONOR_ID,
                FAMILY_FOUNDATION_NAME,
                TRUST_NAME,
                SUSTAINER_STATUS,
                CHANGE_DONOR,
                IWHC_DONOR,
                FF_DONOR,
                FUNDING_FOCUS,
                GRANTMAKER,
                LEVEL,
                PRIMARY_CONTACT,
                PRIMARY_CONTACT_NAME,
                PRIMARY_SOLICITOR,
                PRIMARY_SOLICITOR_NAME,
                SECONDARY_SOLICITOR,
                SECONDARY_SOLICITOR_NAME
            ]
        }
    )
    account;

    @wire(wireGetCustomBadges,{recordId:'$recordId'})
    setLabels(result){
        const {data,error} = result;
        if(data){
            console.log(JSON.stringify(data));
            this.labels = data;
        }
    }
   
    get levelName(){
        return getFieldValue(this.account.data,LEVEL);
    }
   
    get sustainerStatus(){
        return getFieldValue(this.account.data,SUSTAINER_STATUS);
    }
    get changeDonor(){
        return getFieldValue(this.account.data,CHANGE_DONOR);
    }
    get iwhcDonor(){
        return getFieldValue(this.account.data,IWHC_DONOR);
    }
    
}