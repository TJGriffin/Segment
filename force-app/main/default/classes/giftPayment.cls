/*******************************************************************************************************
* @description wrapper class for payments on a gift item
*   for recurring donations this represents the opportunities
*   for multi-payment opportunities, this is the npe01__OppPayment__c object
*/
public with sharing class giftPayment {
    /**
    * @description Id of threcord
    */
    @auraEnabled public Id recordId {get;set;}
    /**
    * @description the object type
    */
    @auraEnabled public String objectType {
        get {
            if(objectType==null){
                objectType = recordId.getSObjectType().getDescribe().getName();
            }
            return objectType;
        }
        set;
    }

    @auraEnabled public Date paymentDate {get;set;}

    @auraEnabled public Boolean paid {get;set;}

    @auraEnabled public Decimal amount {get;set;}

    @auraEnabled public Boolan writtenOff {get;set;}

    public giftPayment(npe01__OppPayment__c pmt){
        this.recordId = pmt.Id;
        this.paymentDate = pmt.npe01__Payment_Date__c;
        this.paid = pmt.npe01__Paid__c;
        this.amount = pmt.npe01__Payment_Amount__c;
        this.writtenOff = pmt.npe01__Written_Off__c;
    }

    public giftPayment(Opportunity opp){
        this.recordId = opp.Id;
        this.paymentDate = opp.CloseDate;
        this.paid = opp.isWon;
        this.amount = opp.Amount;
        this.writtenOff = false;
    }


}