import { LightningElement, api } from 'lwc';

export default class AccSingleGift extends LightningElement {
    @api gift;
    @api emphasize;
    @api type;

    connectedCallback(){
       //this.emphasize = typeof this.emphasize === undefined || this.emphasize == null ? true : this.emphasize;
    }
    get typeLabel(){
        return this.type == 'first' ? 'Initial Gift' : 'Most Recent Gift';
    }
    get header(){
        return this.type == 'first' ? 'First Gift: '+this.gift.Name : 'Last Gift: '+this.gift.Name;
    }

    get amountDifference(){
        this.gift.totalAmount != this.gift.oppAmount;
    }

    get classList(){
        return this.emphasize ? 'slds-box slds-theme_inverse' : 'slds-box slds-theme_default';
    }
    get theme(){
        return this.emphasize ? 'slds-theme_inverse' : 'slds-theme_default';
    }
    get titleTheme(){
        return this.emphasize ? 'slds-text-title_caps slds-theme_inverse' :  'slds-text-title_caps slds-theme_default';
    }
    get hasDifference(){
        return typeof this.gift !== undefined && this.gift != null && (this.gift.oppAmount - this.gift.TotalAmount != 0);
    }
    get showType(){
        return true;
    }
    get badgeClass(){
        return this.emphasize ? 'slds-badge_lightest' : 'slds-badge_inverse';
    }
    g
}