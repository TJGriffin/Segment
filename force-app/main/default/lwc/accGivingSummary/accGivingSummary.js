import { LightningElement, api, wire } from 'lwc';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import TOTAL_AMOUNT from '@salesforce/schema/Account.Total_Combined_Credits__c';
import LAST_YEAR_AMOUNT from '@salesforce/schema/Account.Combined_Credits_Last_Year__c';
import THIS_YEAR_AMOUNT from '@salesforce/schema/Account.Combined_Credits_This_Year__c';
import TWO_YEAR_AMOUNT from '@salesforce/schema/Account.Combined_Credits_2_Years_Ago__c';
import TOTAL_COUNT from '@salesforce/schema/Account.Number_Combined_Credits__c';
import LAST_YEAR_COUNT from '@salesforce/schema/Account.Number_Combined_Credits_Last_Year__c';
import THIS_YEAR_COUNT from '@salesforce/schema/Account.Number_Combined_Credits_This_Year__c';
import TWO_YEAR_COUNT from '@salesforce/schema/Account.Number_Combined_Credits_2_Years_Ago__c';
import ONEK_THIS_YEAR from '@salesforce/schema/Account.cfg_Num_1K_Gifts_This_Year__c';
import ONEK_LAST_YEAR from '@salesforce/schema/Account.cfg_Num_1K_Gifts_Last_Year__c';
import ONEK_TWO_YEAR from '@salesforce/schema/Account.cfg_Num_1K_Gifts_Last_2_Yrs__c';


export default class AccGivingSummary extends LightningElement {
    @api recordId;

    @wire(
        getRecord, 
        {
            recordId:'$recordId', 
            optionalFields: [
                TOTAL_AMOUNT,
                LAST_YEAR_AMOUNT,
                THIS_YEAR_AMOUNT,
                TWO_YEAR_AMOUNT,
                TOTAL_COUNT,
                LAST_YEAR_COUNT,
                THIS_YEAR_COUNT,
                TWO_YEAR_COUNT,
                ONEK_THIS_YEAR,
                ONEK_LAST_YEAR,
                ONEK_TWO_YEAR
            ]
        }
    )
    account;

    get totalAmount(){
        return getFieldValue(this.account.data,TOTAL_AMOUNT);
    }
    get lastYearAmount(){
        return getFieldValue(this.account.data,LAST_YEAR_AMOUNT);
    }
    get thisYearAmount(){
        return getFieldValue(this.account.data,THIS_YEAR_AMOUNT);
    }
    get twoYearAmount(){
        return getFieldValue(this.account.data,TWO_YEAR_AMOUNT);
    }
    get totalCount(){
        var count = getFieldValue(this.account.data,TOTAL_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts'; 
        return txt;
    }
    get lastYearCount(){
        var count = getFieldValue(this.account.data,LAST_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts';  
        return txt;
    }
    get thisYearCount(){
        var count = getFieldValue(this.account.data,THIS_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts';  
        return txt;
    }
    get twoYearCount(){
        var count = getFieldValue(this.account.data,TWO_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts' : '0 gifts';  
        return txt;
    }
    get lastYear1K(){
        var count = getFieldValue(this.account.data,LAST_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts over $1k' : null;  
        return txt;
    }
    get thisYear1K(){
        var count = getFieldValue(this.account.data,THIS_YEAR_COUNT);
        var txt = count != null && count > 0 ? count+' gifts over $1k' : null;  
        return txt;
    }
    /*
                TOTAL_AMOUNT,
                LAST_YEAR_AMOUNT,
                THIS_YEAR_AMOUNT,
                TWO_YEAR_AMOUNT,
                TOTAL_COUNT,
                LAST_YEAR_COUNT,
                THIS_YEAR_COUNT,
                TWO_YEAR_COUNT,
                ONEK_THIS_YEAR,
                ONEK_LAST_YEAR,
                ONEK_TWO_YEAR

    */
}