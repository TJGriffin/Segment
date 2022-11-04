import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import AF_FIELD from '@salesforce/schema/Contact.Query_String_Encrypted__c';
import SBID_FIELD from '@salesforce/schema/Contact.Drupal_User_ID__c';


export default class ConButtons extends NavigationMixin(LightningElement) {
    @api recordId;

    get formId(){
        return '435';
    }

    get baseUrl(){
        return 'https://donate.fosfeminista.org';
    }
    
    get fullUrl(){
        return this.baseUrl+'/node/'+this.formId+'?offline=true&af='+this.afString;
    }
    @wire(getRecord, { recordId: '$recordId', fields: [AF_FIELD , SBID_FIELD]})
    contact;

    get hasAFString(){
        return typeof this.afString !== undefined && this.afString != null;
    }
    get afString(){
        return getFieldValue(this.contact.data,AF_FIELD);
    }
    get sbId(){
        return getFieldValue(this.contact.data,SBID_FIELD);
    }

    handleClick(event){
        event.stopPropagation();
        console.log('clicked');
        console.log('baseurl: '+this.fullUrl);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes:{
                url: this.fullUrl
            }
        })
    }
}