import { LightningElement, api, wire } from 'lwc';
import setProspect from '@salesforce/apex/ACC_Segment_CTRL.setProspectStatus';
import setDowngrade from '@salesforce/apex/ACC_Segment_CTRL.downgradeDonor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import ACCOUNT_SEGMENT from '@salesforce/schema/Account.Donor_Segment__c';
import ACCOUNT_SEGMENT_APPLIED_DATE from '@salesforce/schema/Account.Donor_Segment_Applied_Date__c';
import ACCOUNT_DONOR_STATUS from '@salesforce/schema/Account.Donor_Status__c';
import ACCOUNT_DONOR_STATUS_APPLIED_DATE from '@salesforce/schema/Account.Donor_Status_Applied_Date__c';
import ACCOUNT_MAJOR_DONOR_STATUS from '@salesforce/schema/Account.Major_Donor_Status__c';
import ACCOUNT_MAJOR_DONOR_STATUS_APPLIED_DATE from '@salesforce/schema/Account.Major_Donor_Status_Applied_Date__c';
import ACCOUNT_MID_DONOR_STATUS from '@salesforce/schema/Account.Mid_Level_Donor_Status_Applied_Date__c';
import ACCOUNT_MID_DONOR_STATUS_APPLIED_DATE from '@salesforce/schema/Account.Mid_Level_Donor_Status_Applied_Date__c';
import ACCOUNT_SUSTAINER_STATUS from '@salesforce/schema/Account.Sustainer_Status__c';
import ACCOUNT_SUSTAINER_STATUS_APPLIED_DATE from '@salesforce/schema/Account.Sustainer_Status_Applied_Date__c';
import ACCOUNT_MAJOR_DONOR_DOWNGRADE_DATE from '@salesforce/schema/Account.Major_Donor_Downgrade_Date__c';
import ACCOUNT_MAJOR_DONOR_DOWNGRADE_BY from '@salesforce/schema/Account.Major_Donor_Downgrade_By__c';
import ACCOUNT_MID_DONOR_DOWNGRADe_DATE from '@salesforce/schema/Account.Mid_Level_Donor_Downgrade_Date__c';
import ACCOUNT_MID_DONOR_DOWNGRADE_BY  from '@salesforce/schema/Account.Mid_Level_Donor_Downgrade_By__c';
import CONTACT_SEGMENT from '@salesforce/schema/Contact.Donor_Segment__c';
import CONTACT_SEGMENT_APPLIED_DATE from '@salesforce/schema/Contact.Donor_Segment_Applied_Date__c';
import CONTACT_DONOR_STATUS from '@salesforce/schema/Contact.Donor_Status__c';
import CONTACT_DONOR_STATUS_APPLIED_DATE from '@salesforce/schema/Contact.Donor_Status_Applied_Date__c';
import CONTACT_MAJOR_DONOR_STATUS from '@salesforce/schema/Contact.Major_Donor_Status__c';
import CONTACT_MAJOR_DONOR_STATUS_APPLIED_DATE from '@salesforce/schema/Contact.Major_Donor_Status_Applied_Date__c';
import CONTACT_MID_DONOR_STATUS from '@salesforce/schema/Contact.Mid_Level_Donor_Status_Applied_Date__c';
import CONTACT_MID_DONOR_STATUS_APPLIED_DATE from '@salesforce/schema/Contact.Mid_Level_Donor_Status_Applied_Date__c';
import CONTACT_SUSTAINER_STATUS from '@salesforce/schema/Contact.Sustainer_Status__c';
import CONTACT_SUSTAINER_STATUS_APPLIED_DATE from '@salesforce/schema/Contact.Sustainer_Status_Applied_Date__c';
import CONTACT_MAJOR_DONOR_DOWNGRADE_DATE from '@salesforce/schema/Contact.Major_Donor_Downgrade_Date__c';
import CONTACT_MAJOR_DONOR_DOWNGRADE_BY from '@salesforce/schema/Contact.Major_Donor_Downgrade_By__c';
import CONTACT_MID_DONOR_DOWNGRADe_DATE from '@salesforce/schema/Contact.Mid_Level_Donor_Downgrade_Date__c';
import CONTACT_MID_DONOR_DOWNGRADE_BY  from '@salesforce/schema/Contact.Mid_Level_Donor_Downgrade_By__c';

const ACCOUNT_FIELDS = [
	ACCOUNT_SEGMENT,
	ACCOUNT_SEGMENT_APPLIED_DATE,
	ACCOUNT_DONOR_STATUS,
	ACCOUNT_DONOR_STATUS_APPLIED_DATE,
	ACCOUNT_MAJOR_DONOR_STATUS,
	ACCOUNT_MAJOR_DONOR_STATUS_APPLIED_DATE,
	ACCOUNT_MID_DONOR_STATUS,
	ACCOUNT_MID_DONOR_STATUS_APPLIED_DATE,
	ACCOUNT_SUSTAINER_STATUS,
	ACCOUNT_SUSTAINER_STATUS_APPLIED_DATE,
	ACCOUNT_MAJOR_DONOR_DOWNGRADE_DATE,
	ACCOUNT_MAJOR_DONOR_DOWNGRADE_BY,
	ACCOUNT_MID_DONOR_DOWNGRADe_DATE,
	ACCOUNT_MID_DONOR_DOWNGRADE_BY
];
const CONTACT_FIELDS = [    
	CONTACT_SEGMENT,
	CONTACT_SEGMENT_APPLIED_DATE,
	CONTACT_DONOR_STATUS,
	CONTACT_DONOR_STATUS_APPLIED_DATE,
	CONTACT_MAJOR_DONOR_STATUS,
	CONTACT_MAJOR_DONOR_STATUS_APPLIED_DATE,
	CONTACT_MID_DONOR_STATUS,
	CONTACT_MID_DONOR_STATUS_APPLIED_DATE,
	CONTACT_SUSTAINER_STATUS,
	CONTACT_SUSTAINER_STATUS_APPLIED_DATE,
	CONTACT_MAJOR_DONOR_DOWNGRADE_DATE,
	CONTACT_MAJOR_DONOR_DOWNGRADE_BY,
	CONTACT_MID_DONOR_DOWNGRADe_DATE,
	CONTACT_MID_DONOR_DOWNGRADE_BY

];

export default class AccSegmentStatus extends LightningElement {
    @api recordId;
    @api objectApiName;

    get isAccount(){
        return (this.objectApiName === 'Account');
    }

    get fields(){
        if(this.objectApiName === 'Account'){
            return ACCOUNT_FIELDS;
        } else {
            return CONTACT_FIELDS;
        }
    }

    get isMajorDonorProspect(){
        return this.majorDonorStatus != null && this.majorDonorStatus == 'Prospect';
    }

    get canUpOrDowngrade(){
        return this.canUpgradeMajor || this.canDowngradeMajor || this.canUpgradeMid || this.canDowngradeMid;
    }

    get canUpgradeMajor(){
        return this.majorDonorStatus == null || this.majorDonorStatus != 'Active';
    }

    get canUpgradeMid(){
        return this.midDonorStatus == null || this.midDonorStatus != 'Active';
    }

    get canDowngradeMajor(){
        return this.majorDonorStatus != null && this.majorDonorStatus != 'Former' && this.majorDonorStatus != 'Prospect';
    }

    get canDowngradeMid(){
        return this.midDonorStatus != null && this.midDonorStatus != 'Former' && this.midDonorStatus != 'Prospect';
    }

    @wire(
        getRecord, 
        {
            recordId:'$recordId', 
            optionalFields: '$fields'
        }
    )
    account;

    get donorSegment(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_SEGMENT) : getFieldValue(this.account.data,CONTACT_SEGMENT);
    }
    get donorSegmentAppliedDate(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_SEGMENT_APPLIED_DATE) : getFieldValue(this.account.data,CONTACT_SEGMENT_APPLIED_DATE);
    }
    get donorStatus(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_DONOR_STATUS) : getFieldValue(this.account.data,CONTACT_DONOR_STATUS);
    }
    get majorDonorStatus(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MAJOR_DONOR_STATUS) : getFieldValue(this.account.data,CONTACT_MAJOR_DONOR_STATUS);
    }
    get midDonorStatus(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MID_DONOR_STATUS) : getFieldValue(this.account.data,CONTACT_MID_DONOR_STATUS);
    }
    get sustainerStatus(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_SUSTAINER_STATUS) : getFieldValue(this.account.data,CONTACT_SUSTAINER_STATUS);
    }
    get donorStatusAppliedDate(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_DONOR_STATUS_APPLIED_DATE) : getFieldValue(this.account.data,CONTACT_DONOR_STATUS_APPLIED_DATE);
    }
    get majorDonorStatusAppliedDate(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MAJOR_DONOR_STATUS_APPLIED_DATE) : getFieldValue(this.account.data,CONTACT_MAJOR_DONOR_STATUS_APPLIED_DATE);
    }
    get midDonorStatusAppliedDate(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MID_DONOR_STATUS_APPLIED_DATE) : getFieldValue(this.account.data,CONTACT_MID_DONOR_STATUS_APPLIED_DATE);
    }
    get sustainerStatusAppliedDate(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_SUSTAINER_STATUS_APPLIED_DATE) : getFieldValue(this.account.data,CONTACT_SUSTAINER_STATUS_APPLIED_DATE);
    }
    get majorDonorDowngradeDate(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MAJOR_DONOR_DOWNGRADE_DATE) : getFieldValue(this.account.data,CONTACT_MAJOR_DONOR_DOWNGRADE_DATE);
    }
    get midDonorDowngradeDate(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MID_DONOR_DOWNGRADE_DATE) : getFieldValue(this.account.data,CONTACT_MID_DONOR_DOWNGRADE_DATE);
    }
    get majorDonorDowngradeBy(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MAJOR_DONOR_DOWNGRADE_BY) : getFieldValue(this.account.data,CONTACT_MAJOR_DONOR_DOWNGRADE_BY);
    }
    get midDonorDowngradeBy(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_MID_DONOR_DOWNGRADE_BY) : getFieldValue(this.account.data,CONTACT_MID_DONOR_DOWNGRADE_BY);
    }

    handleProspect(event){
        var fieldToSet = event.target.name == 'major' ? 'Major_Donor_Status__c' : 'Mid_Level_Donor_Status__c';
        setProspect({recordId:this.recordId,fieldName:fieldToSet})
        .then((result)=>{
            this.showToast();
        })
        .catch((error)=>{
            console.log(JSON.stringify(error));
        });
    }

    handleDowngrade(event){
        var fieldToSet = event.target.name == 'major' ? 'Major_Donor_Status__c' : 'Mid_Level_Donor_Status__c';
        setDowngrade({recordId:this.recordId,fieldName:fieldToSet})
        .then((result)=>{
            this.showToast();
        })
        .catch((error)=>{
            console.log(JSON.stringify(error));
        });
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            variant:'success',
            message:
                'Record updated',
        });
        this.dispatchEvent(event);
    }
}