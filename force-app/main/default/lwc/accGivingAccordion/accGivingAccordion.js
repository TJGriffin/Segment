import { LightningElement, api, track} from 'lwc';

export default class AccGivingAccordion extends LightningElement {
    @api recordId;
    @track availWidth;

    applySize = () => {
        this.availWidth = window.innerWidth;
    };

    get inputVariables(){
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    connectedCallback(){
        this.applySize();
        window.addEventListener('resize', this.applySize);
    }
    disconnectedCallback() {
        window.removeEventListener('resize', this.applySize);
    }
}