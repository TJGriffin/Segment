import { LightningElement, api } from 'lwc';

export default class GivingTabTotal extends LightningElement {
    @api header;
    @api amount;
    @api count;
    @api footer;
    @api emphasize;
    @api shade;


    get classList(){
       var classNames = this.emphasize ? 'slds-box slds-theme_inverse' : 'slds-box slds-theme_default';
       if(this.shade){
         classNames = this.emphasize ? 'slds-box slds-theme_alt-inverse' : 'slds-box slds-theme_shade';
       }
       return classNames;
    }
    get theme(){
        var classNames = this.emphasize ? 'slds-text-title_caps slds-theme_inverse' : 'slds-text-title_caps slds-theme_default';
        if(this.shade){
            classNames = this.emphasize ? 'slds-text-title_caps slds-theme_alt-inverse' : 'slds-text-title_caps slds-theme_shade';
        }
        return classNames;
    }
}