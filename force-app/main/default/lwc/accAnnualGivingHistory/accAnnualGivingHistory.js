import { LightningElement, api, wire, track } from 'lwc';
import wireGetGiftHistory from '@salesforce/apex/ACC_Giving_CTRL.getGiftHistory';

const COLUMNS = [
    {label: 'Year', fieldName: 'year', type: 'text', initialWidth:80},
    {label: 'Committed', fieldName: 'committedAmount', type: 'currency'},
    {label: 'Hard Credit', fieldName: 'hardCreditAmount', type: 'currency'},
    {label: 'Soft Credit', fieldName: 'softCreditAmount', type: 'currency'},
    {label: 'Received', fieldName: 'receivedAmount', type: 'currency'},
    {label: 'Outstanding Pledged', fieldName: 'pledgedAmountOutstanding', type: 'currency'},
    {label: 'Written Off', fieldName: 'writtenOffAmount', type: 'currency'}
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
            var gifts = [];
            data.forEach(row=>{
                if(row.committedAmount > 0 || row.receivedAmount > 0 || row.pledgedAmountOutstanding > 0)
                    gifts.push(row);
            })
            this.giftHistory = gifts;
        }
    }
}