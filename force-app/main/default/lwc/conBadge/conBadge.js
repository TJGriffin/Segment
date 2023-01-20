import { LightningElement,api } from 'lwc';

export default class ConBadge extends LightningElement {
    @api label;
    @api className;

    get labelText(){
        return typeof this.label !== undefined && this.label != null ? this.label : undefined;
    }
    get labelClass(){
        if(typeof this.className !== undefined && this.className != null){
            return this.className;
        }
    }
}