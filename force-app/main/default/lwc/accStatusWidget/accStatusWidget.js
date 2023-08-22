import { LightningElement, api } from 'lwc';

export default class AccStatusWidget extends LightningElement {
    @api statusLabel;
    @api statusDate;
    @api downgradeByName;
    @api downgradeById;
    @api downgradeDate;

    get downgradeLink(){
        return '/'+this.downgradeById;
    }
}