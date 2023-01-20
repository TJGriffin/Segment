import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import wireGetGiftItems from '@salesforce/apex/ACC_Giving_CTRL.getGiftItems';

const COLUMNS = [
    {label: 'Name', fieldName: 'link', type: 'url', typeAttributes: {
            label : {fieldName: 'Name'}
        },initialWidth:200},
    /* {label: 'Campaign', fieldName:'campaignName',type:'text',sortable:'true',initialWidth:50},
     {label: 'Type', fieldName:'recordType',type:'text',sortable:'true',initialWidth:160},*/
    {label: 'Status', fieldName: 'StageName', type: 'text', sortable:'true', initialWidth:120},
    {label: 'First Date', fieldName: 'closeDate', type: 'date-local',typeAttributes:{
        month:"2-digit",
        day: "2-digit"
        },
        sortable:'true', initialWidth:120
    },
    {label: 'Last Date', fieldName: 'lastReceivedDate', type: 'date-local',typeAttributes:{
        month:"2-digit",
        day: "2-digit"
        },
        sortable:'true', initialWidth:120
    },
    {label: 'Received', fieldName: 'totalAmount', type: 'currency',sortable:'true', initialWidth:120},
    {label: 'Pledged', fieldName: 'pledgedAmountOutstanding', type: 'currency',sortable:'true', initialWidth:120},
    {label: 'Written Off', fieldName: 'lostAmount', type: 'currency',sortable:'true', initialWidth:120},
    {label: 'Gift Total', fieldName: 'oppAmount', type: 'currency',sortable:'true', initialWidth:120}
];

export default class AccGiving extends LightningElement {
    @api recordId;
    @track showSpinner = true;
    @track data;
    @api showWon;
    @track sortBy;
    @track sortDirection;
    @track firstGift;
    @track lastGift;

    connectedCallback(){
        this.showWon = typeof this.showWon === undefined || this.showWon == null ? true : this.showWon;
    }

    get countText(){
        return typeof this.data != undefined && this.data != null ? this.data.length + ' items' : '0 items';
    }

    cols = COLUMNS;

    handleCheckbox(event){
        this.showSpinner = true;
        this.showWon = event.target.value;
        refreshApex(this.giftItems);
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        
        let keyValue = (a) => {
            return a[fieldname];  // Return the value stored in the field
        };
        
        let isReverse = direction === 'asc' ? 1: -1; // checking reverse direction
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : ''; // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        this.data = parseData;
    }  

    @wire(wireGetGiftItems,{recordId:'$recordId',showWonOnly:'$showWon'})
    setGiftItems({data,error}) {
        this.showSpinner=false;
        this.data = data;
        console.log('gift items');
        console.log(JSON.stringify(this.data));
        this.parseData();
    }

    parseData(){
        if(typeof this.data === undefined || this.data == null) // only process if we have data
            return;

        if(typeof this.firstGift !== undefined && this.firstGift != null)  // if we have already set the value don't do it again
            return;

        this.data.forEach(gift=>{
            this.firstGift = typeof this.firstGift === undefined || this.firstGift == null || this.firstGift.closeDate > gift.closeDate ? gift : this.firstGift;
            this.lastGift = typeof this.lastGift === undefined || this.lastGift == null ||  this.lastGift.closeDate < gift.closeDate ? gift : this.lastGift;

        });
    }


}