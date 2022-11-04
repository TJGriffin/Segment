import { LightningElement, api, wire, track } from 'lwc';
import wireGetGiftHistory from '@salesforce/apex/ACC_Giving_CTRL.getGiftHistory';

const COLUMNS = [
    {label: 'Year', fieldName: 'year', type: 'text', initialWidth:80},
    {label: 'Hard Credit', fieldName: 'hardCreditAmount', type: 'currency'},
    {label: 'Soft Credit', fieldName: 'softCreditAmount', type: 'currency'},
    {label: 'Pledged', fieldName: 'pledgedAmountOutstanding', type: 'currency'},
    {label: 'Received', fieldName: 'totalAmount', type: 'currency'}
];

export default class AccAnnualGivingHistory extends LightningElement {
    @api recordId;
    @track showSpinner = true;
    @track giftHistory;

    cols = COLUMNS;

    @wire(wireGetGiftHistory,{recordId:'$recordId',showWonOnly:true})
    setSummaries(result) {
        this.showSpinner=false;
        const {data,error} = result;
        if(data){
            console.log(JSON.stringify(data));
            this.giftHistory = data;
        }
    }
}