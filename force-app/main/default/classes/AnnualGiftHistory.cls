/**
* @author TJ Griffin
* @date 2022
* @group Giving Rollups
* @description Annual Gift History wrapper class
*/
public class AnnualGiftHistory implements Comparable {
    /*******************************************************************************************************
    * @description year of the gift total
    */
    @auraEnabled public String year { get; set; }
    
    /*******************************************************************************************************
    * @description total hard credits
    */
    @auraEnabled public Decimal hardCreditAmount { get; set; }
    
    /*******************************************************************************************************
    * @description total soft credits
    */
    @auraEnabled public Decimal softCreditAmount { get; set; }
    
    /*******************************************************************************************************
    * @description total pledged amount still outstanding
    */
    @auraEnabled public Decimal pledgedAmountOutstanding { get; set; }

    /*******************************************************************************************************
    * @description total number of gifts
    */
    @auraEnabled public Integer numGifts { get; set; }

    /*******************************************************************************************************
    * @description hard credit + soft credit - pledged amount outstanding
    */
    @auraEnabled public Decimal totalAmount { get; set; }

    /*******************************************************************************************************
    * @description accountId
    */
    @auraEnabled public Id accountId { get; set; }

    /*******************************************************************************************************
    * @description accountId
    */
    @auraEnabled public String uniqueId { 
        get {
            return this.accountId+''+this.year;
        } 
        set; 
    }

	/*******************************************************************************************************
	* @description constructor
	* @param hardCreditAmount
    * @param softCreditAmount
    * @param pledgedAmountOutstanding
    * @param totalAmount
    * @param accountId
	*/
    public AnnualGiftHistory(String Year, Decimal hardCreditAmount, Decimal softCreditAmount, Decimal pledgedAmountOutstanding, Decimal totalAmount, Id accountId) {
        this.Year = Year;
        this.hardCreditAmount = hardCreditAmount;
        this.softCreditAmount = softCreditAmount;
        this.pledgedAmountOutstanding = pledgedAmountOutstanding;
        this.totalAmount = totalAmount;
        this.accountId = accountId;
    }

	/*******************************************************************************************************
	* @description comparable method for sorting
	* @param compObj the object to sort against
	* @return Integer the sort order
	*/
    public Integer compareTo(Object compObj) {
        AnnualGiftHistory aghComp = (AnnualGiftHistory) compObj;
        if(String.isNotBlank(this.Year) && this.Year.containsIgnoreCase('Total')) {
            return 1;
        } else if(String.isNotBlank(aghComp.Year) && aghComp.Year.containsIgnoreCase('Total')){
            return -1;
        } else {
            return Integer.valueOf(this.Year) <  Integer.valueOf(aghComp.Year) ? 1 : -1;
        }
    }

	/*******************************************************************************************************
	* @description returns an AnnualGiftHistory__c sobject from wrapper
	* @return AnnualGiftHistory__c
	*/
    public AnnualGiftHistory__c getSObject(){
        return new AnnualGiftHistory__c(
            Account__c = this.accountId,
            HardCreditAmount__c = this.hardCreditAmount,
            SoftCreditAmount__c = this.softCreditAmount,
            NumberOfGifts__c = this.numGifts,
            PledgedAmount__c = this.pledgedAmountOutstanding,
            ReceivedAmount__c = this.totalAmount,
            UniqueId__c = this.uniqueId,
            Year__c = this.year
        );
    }
}