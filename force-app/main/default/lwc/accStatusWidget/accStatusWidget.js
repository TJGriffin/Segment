import { LightningElement, api, wire } from 'lwc';
import USER_NAME from '@salesforce/schema/User.Name';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';

const USERFIELDS = [USER_NAME];

export default class AccStatusWidget extends LightningElement {
    @api statusField;
    @api statusLabel;
    @api statusDate;
    
    @api downgradeById;
    @api downgradeDate;

    get fields(){
        return USERFIELDS;
    }


    @wire(getRecord,{recordId:'$downgradeById',fields:'$fields'})
    userData;

    get isDowngrade(){
        return typeof this.downgradeById !== undefined && this.downgradeById != null;
    }
    get downgradeByName(){
        return this.isDowngrade ? getFieldValue(this.userData.data,USER_NAME) : undefined;
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