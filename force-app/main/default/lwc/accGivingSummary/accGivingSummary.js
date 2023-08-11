import { LightningElement, api, wire } from 'lwc';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import ACCOUNT_TOTAL_AMOUNT from '@salesforce/schema/Account.Total_Combined_Credits__c';
import ACCOUNT_LAST_YEAR_AMOUNT from '@salesforce/schema/Account.Combined_Credits_Last_Year__c';
import ACCOUNT_THIS_YEAR_AMOUNT from '@salesforce/schema/Account.Combined_Credits_This_Year__c';
import ACCOUNT_TWO_YEAR_AMOUNT from '@salesforce/schema/Account.Combined_Credits_2_Years_Ago__c';
import ACCOUNT_TOTAL_COUNT from '@salesforce/schema/Account.Number_Combined_Credits__c';
import ACCOUNT_LAST_YEAR_COUNT from '@salesforce/schema/Account.Number_Combined_Credits_Last_Year__c';
import ACCOUNT_THIS_YEAR_COUNT from '@salesforce/schema/Account.Number_Combined_Credits_This_Year__c';
import ACCOUNT_TWO_YEAR_COUNT from '@salesforce/schema/Account.Number_Combined_Credits_2_Years_Ago__c';
import CONTACT_TOTAL_AMOUNT from '@salesforce/schema/Contact.Account.Total_Combined_Credits__c';
import CONTACT_LAST_YEAR_AMOUNT from '@salesforce/schema/Contact.Account.Combined_Credits_Last_Year__c';
import CONTACT_THIS_YEAR_AMOUNT from '@salesforce/schema/Contact.Account.Combined_Credits_This_Year__c';
import CONTACT_TWO_YEAR_AMOUNT from '@salesforce/schema/Contact.Account.Combined_Credits_2_Years_Ago__c';
import CONTACT_TOTAL_COUNT from '@salesforce/schema/Contact.Account.Number_Combined_Credits__c';
import CONTACT_LAST_YEAR_COUNT from '@salesforce/schema/Contact.Account.Number_Combined_Credits_Last_Year__c';
import CONTACT_THIS_YEAR_COUNT from '@salesforce/schema/Contact.Account.Number_Combined_Credits_This_Year__c';
import CONTACT_TWO_YEAR_COUNT from '@salesforce/schema/Contact.Account.Number_Combined_Credits_2_Years_Ago__c';


const ACCOUNT_FIELDS = [ACCOUNT_TOTAL_AMOUNT,ACCOUNT_LAST_YEAR_AMOUNT,ACCOUNT_THIS_YEAR_AMOUNT,ACCOUNT_TWO_YEAR_AMOUNT,ACCOUNT_TOTAL_COUNT,ACCOUNT_LAST_YEAR_COUNT,ACCOUNT_THIS_YEAR_COUNT,ACCOUNT_TWO_YEAR_COUNT];
const CONTACT_FIELDS = [CONTACT_TOTAL_AMOUNT,CONTACT_LAST_YEAR_AMOUNT,CONTACT_THIS_YEAR_AMOUNT,CONTACT_TWO_YEAR_AMOUNT,CONTACT_TOTAL_COUNT,CONTACT_LAST_YEAR_COUNT,CONTACT_THIS_YEAR_COUNT,CONTACT_TWO_YEAR_COUNT];

export default class AccGivingSummary extends LightningElement {
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

    @wire(
        getRecord, 
        {
            recordId:'$recordId', 
            optionalFields: '$fields'
        }
    )
    account;

    get totalAmount(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_TOTAL_AMOUNT) : getFieldValue(this.account.data,CONTACT_TOTAL_AMOUNT);
    }
    get lastYearAmount(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_LAST_YEAR_AMOUNT) : getFieldValue(this.account.data,CONTACT_LAST_YEAR_AMOUNT);
    }
    get thisYearAmount(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_THIS_YEAR_AMOUNT) : getFieldValue(this.account.data,CONTACT_THIS_YEAR_AMOUNT);
    }
    get twoYearAmount(){
        return this.isAccount ? getFieldValue(this.account.data,ACCOUNT_TWO_YEAR_AMOUNT) : getFieldValue(this.account.data,CONTACT_TWO_YEAR_AMOUNT) ;
    }
    get totalCount(){
        var count = this.isAccount ? getFieldValue(this.account.data,ACCOUNT_TOTAL_COUNT) : getFieldValue(this.account.data,CONTACT_TOTAL_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts'; 
        return txt;
    }
    get lastYearCount(){
        var count = this.isAccount ? getFieldValue(this.account.data,ACCOUNT_LAST_YEAR_COUNT) : getFieldValue(this.account.data,CONTACT_LAST_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts';  
        return txt;
    }
    get thisYearCount(){
        var count = this.isAccount ? getFieldValue(this.account.data,ACCOUNT_THIS_YEAR_COUNT) : getFieldValue(this.account.data,CONTACT_THIS_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts';  
        return txt;
    }
    get twoYearCount(){
        var count = this.isAccount ? getFieldValue(this.account.data,ACCOUNT_TWO_YEAR_COUNT) : getFieldValue(this.account.data,CONTACT_TWO_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts';  
        return txt;
    }

}