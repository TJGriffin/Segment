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
    get iconType(){
        var iconName = 'standard:dataset';
        switch(this.statusLabel){
            case 'Active':
                iconName = 'standard:opportunity';
            break;
            case 'Former':
                iconName = 'standard:empty';
            break;
            case 'Lapsed':
                iconName = 'standard:thanks_loading';
            break;
            case 'Deep Lapsed':
                iconName = 'standard:thanks_loading';
            break;
            case 'Extended Lapsed':
                iconName = 'standard:thanks_loading';
            break;
        }
        return iconName;
    }
}