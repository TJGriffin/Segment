import { LightningElement, api } from 'lwc';

export default class AccStatusWidget extends LightningElement {
    @api statusField;
    @api statusLabel;
    @api statusDate;
    @api downgradeByName;
    @api downgradeById;
    @api downgradeDate;

    get isDowngrade(){
        return typeof this.downgradeById !== undefined && this.downgradeById != null;
    }
    get displayLabel(){
        return this.statusField+': '+this.statusLabel;
    }
    get downgradeLink(){
        return '/'+this.downgradeById;
    }
}