import { LightningElement, api } from 'lwc';

export default class GivingTabTotal extends LightningElement {
    @api header;
    @api amount;
    @api count;
    @api footer;
    @api emphasize;


    get classList(){
        return this.emphasize ? 'slds-box slds-theme_inverse' : 'slds-box slds-theme_default';
    }
    get theme(){
        return this.emphasize ? 'slds-text-title_caps slds-theme_inverse' : 'slds-text-title_caps slds-theme_default';
    }
}