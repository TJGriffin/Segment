import { LightningElement,api } from 'lwc';

export default class ConBadge extends LightningElement {
    @api label;
    get labelText(){
        return typeof this.label !== undefined && this.label != null ? this.label : undefined;
    }
    get labelClass(){
        if(typeof this.label !== undefined && this.label != null){
            if(!this.label.includes('Former') && this.label.includes('Board') ){
                return 'slds-theme_error';
            } else {
                return 'slds-theme_warning';
            }
        }
    }
}