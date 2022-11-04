import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processSegments from '@salesforce/apex/ACC_Segment_CTRL.processSegmentsFromRecordId';

export default class AccProcessSegments extends LightningElement {
    @api recordId;
    isExecuting = false;
    _title = 'Success';
    _message = 'Segments have been processed';
    _variant = 'success';

    @api invoke() {
        if(this.isExecuting){
            return;
        }
        this.isExecuting = true;
        processSegments({recordId:this.recordId})
            .then((result)=>{
                this.showNotification();
            })
            .catch((error)=>{
                this._title = 'Error';
                this._title = 'An unknown error has occurred';
                this._variant = 'error';
                this.showNotification();
            })

    }

    showNotification(){
        const evt = new ShowToastEvent({
            title:this._title,
            message:this._message,
            variant:this._variant,
        });
        this.dispatchEvent(evt);
    }


}