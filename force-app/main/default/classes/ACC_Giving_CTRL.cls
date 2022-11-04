/**
* @author TJ Griffin
* @date 2022
* @group Giving Rollups
* @description controller for retrieving giving records
*/
public with sharing class ACC_Giving_CTRL {

	public static String sortOrder {
		get {
			if(sortOrder == null){
				sortOrder = 'DESC';
			}
			return sortOrder;
		}
		set;
	}

    

    

		
	
	/*******************************************************************************************************
	* @description given a contact or account id, return a list of annual gift histories
	* @param recordId  the id of the contact or account
	* @return List<AnnualGiftHistory> the full gift history summarized by year for the account
	*/
	@auraEnabled(cacheable = true)
	public static List<GiftItem> getGiftItems(Id recordId, Boolean showWonOnly) {
        showWonOnly = showWonOnly == null ? true : showWonOnly;
		
		Id accountId = ACC_Giving_SVC.getAccountIdFromRecordId(recordId);

		Map<Id, List<GiftItem>> giftItemMap = ACC_Giving_SVC.getGiftItems(new Set<Id>{accountId},showWonOnly);

		List<GiftItem> giftItems = giftItemMap.containsKey(accountId) ? giftItemMap.get(accountId) : new List<GiftItem>();
		
		return giftItems;

	}
	
	/*******************************************************************************************************
	* @description given a contact or account id, return a list of annual gift histories
	* @param recordId  the id of the contact or account
	* @return List<AnnualGiftHistory> the full gift history summarized by year for the account
	*/
	@auraEnabled(cacheable = true)
	public static List<AnnualGiftHistory> getGiftHistory(Id recordId) {
        return getGiftHistory(recordId,true);
    }
	/*******************************************************************************************************
	* @description given a contact or account id, return a list of annual gift histories
	* @param recordId  the id of the contact or account
	* @return List<AnnualGiftHistory> the full gift history summarized by year for the account
	*/
	@auraEnabled(cacheable = true)
	public static List<AnnualGiftHistory> getGiftHistory(Id recordId, Boolean showWonOnly) {
        showWonOnly = showWonOnly == null ? true : showWonOnly;
		
		Id accountId = ACC_Giving_SVC.getAccountIdFromRecordId(recordId);

		Map<Id, List<AnnualGiftHistory>> giftHistoryMap = ACC_Giving_SVC.getGiftHistory(new Set<Id>{accountId},showWonOnly);

		List<AnnualGiftHistory> giftHistory = giftHistoryMap.containsKey(accountId) ? giftHistoryMap.get(accountId) : new List<AnnualGiftHistory>();
		
		return giftHistory;
	}
}
