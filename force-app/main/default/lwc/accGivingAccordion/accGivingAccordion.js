import { LightningElement, api, track} from 'lwc';

export default class AccGivingAccordion extends LightningElement {
    @api recordId;
    @track availWidth;

    applySize = () => {
        this.availWidth = window.innerWidth;
    };


    connectedCallback(){
        this.applySize();
        window.addEventListener('resize', this.applySize);
    }
    disconnectedCallback() {
        window.removeEventListener('resize', this.applySize);
    }
}