/**
* @author TJ Griffin
* @date 2022
* @group Giving Rollups
* @description service class for handling giving history
*/
public with sharing class ACC_Giving_SVC {

	/*******************************************************************************************************
	* @description gets the account id of a record Id
	* @param recordId
	* @return Id  
	********************************************************************************************************/
    public static Id getAccountIdFromRecordId(Id recordId){
		Id accountId;		
		// determine if current Id is contact
		if(recordId.getSObjectType().getDescribe().getName().equalsIgnoreCase('contact')) {
			Contact con = [SELECT Id, AccountId FROM Contact WHERE Id=:recordId];
			accountId = con.AccountId;
		} else {
			accountId=recordId;
		}
        return accountId;
    }
	/*******************************************************************************************************
	* @description gets contact ids for an account
	* @param recordId
	* @return Set<Id>
	********************************************************************************************************/
    public static Set<Id> getContactIdsForAccount(Id recordId){
		Set<Id> contactIds = new Set<Id>();		

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE AccountId=:recordId]);
        if(contactMap.size()>0)
            contactIds.addAll(contactMap.keyset());

        return contactIds;
    }

	/*******************************************************************************************************
	* @description retrieves a list of opportunity given a specific account id
	* @param accountId
	* @return List<Opportunity>  
	********************************************************************************************************/
    public static List<Opportunity> getOpportunitiesFromAccountId(Id accountId){
        Map<Id, List<Opportunity>> oppMap = getOpportunitiesFromAccountIds(new Set<Id>{accountId});
        return oppMap.get(accountId);
    }

	/*******************************************************************************************************
	* @description retrieves a Map of opportunity keyed by AccountId
	* @param accountId
	* @return Map<Id, List<Opportunity>>
	********************************************************************************************************/
    public static Map<Id, List<Opportunity>> getOpportunitiesFromAccountIds(Set<Id> accountIds){
        Map<Id, List<Opportunity>> oppsByAccount = new Map<Id, List<Opportunity>>();
        String soqlQuery = getOpportunitySoql();
        soqlQuery+=getOpportunityWhereClause(accountIds);
        for(Opportunity opp:(List<Opportunity>) database.query(soqlQuery)){
            if(!oppsByAccount.containsKey(opp.AccountId))
                oppsByAccount.put(opp.AccountId,new List<Opportunity>());
            oppsByAccount.get(opp.AccountId).add(opp);
        }
        for(Id accountId:accountIds){
            if(!oppsByAccount.containsKey(accountId))
                oppsByAccount.put(accountId,new List<Opportunity>());
        }
        return oppsByAccount;
    }

	/*******************************************************************************************************
	* @description retrieves a list of OpportunityContactRole given a specific account id
	* @param accountId
	* @return List<OpportunityContactRole>
	********************************************************************************************************/
    public static List<OpportunityContactRole> getSoftCreditsFromAccountId(Id accountId){
        Map<Id, List<OpportunityContactRole>> roleMap = getSoftCreditsFromAccountIds(new Set<Id>{accountId});
        return roleMap.get(accountId);
    }

	/*******************************************************************************************************
	* @description retrieves a map of OpportunityContactRole keyed by AccountId
	* @param accountId
	* @return Map<Id,List<OpportunityContactRole>>
	********************************************************************************************************/
    public static Map<Id,List<OpportunityContactRole>> getSoftCreditsFromAccountIds(Set<Id> accountIds){
        Map<Id, List<OpportunityContactRole>> rolesByAccount = new Map<Id, List<OpportunityContactRole>>();
        String soqlQuery = getSoftCreditSoql();
        soqlQuery+=getSoftCreditWhereClause(accountIds);
        for(OpportunityContactRole role:(List<OpportunityContactRole>) database.query(soqlQuery)){
            if(!rolesByAccount.containsKey(role.Contact.AccountId))
                rolesByAccount.put(role.Contact.AccountId,new List<OpportunityContactRole>());
            rolesByAccount.get(role.Contact.AccountId).add(role);
        }
        for(Id accountId:accountIds){
            if(!rolesByAccount.containsKey(accountId))
                rolesByAccount.put(accountId,new List<OpportunityContactRole>());
        }
        return rolesByAccount;
    }

	/*******************************************************************************************************
	* @description retrieves a list of npsp__Partial_Soft_Credit__c given an accountId
	* @param accountId
	* @return List<npsp__Partial_Soft_Credit__c>
	********************************************************************************************************/
    public static List<npsp__Partial_Soft_Credit__c> getPartialSoftCreditsFromAccountId(Id accountId){
        Map<Id, List<npsp__Partial_Soft_Credit__c>> pscMap = getPartialSoftCreditsFromAccountIds(new Set<Id>{accountId});
        return pscMap.get(accountId);
    }

	/*******************************************************************************************************
	* @description retrieves a list of npsp__Partial_Soft_Credit__c given an accountId
	* @param accountId
	* @return List<npsp__Partial_Soft_Credit__c>
	********************************************************************************************************/
    public static Map<Id,List<npsp__Partial_Soft_Credit__c>> getPartialSoftCreditsFromAccountIds(Set<Id> accountIds){
        Map<Id, List<npsp__Partial_Soft_Credit__c>> pscByAccount = new Map<Id, List<npsp__Partial_Soft_Credit__c>>();
        String soqlQuery = getPSCSoql();
        soqlQuery+=getPSCWhereClause(accountIds);
        for(npsp__Partial_Soft_Credit__c psc:(List<npsp__Partial_Soft_Credit__c>) database.query(soqlQuery)){
            if(!pscByAccount.containsKey(psc.npsp__Contact__r.AccountId))
                pscByAccount.put(psc.npsp__Contact__r.AccountId,new List<npsp__Partial_Soft_Credit__c>());
            pscByAccount.get(psc.npsp__Contact__r.AccountId).add(psc);
        }
        for(Id accountId:accountIds){
            if(!pscByAccount.containsKey(accountId))
                pscByAccount.put(accountId,new List<npsp__Partial_Soft_Credit__c>());
        }
        return pscByAccount;
    }

	/*******************************************************************************************************
	* @description retrieves a list of npsp__Account_Soft_Credit__c given an accountId
	* @param accountId
	* @return List<npsp__Account_Soft_Credit__c>
	********************************************************************************************************/
    public static List<npsp__Account_Soft_Credit__c> getAccountSoftCreditsFromAccountId(Id accountId){
        Map<Id, List<npsp__Account_Soft_Credit__c>> ascMap = getAccountSoftCreditsFromAccountIds(new Set<Id>{accountId});
        return ascMap.get(accountId);
    }

	/*******************************************************************************************************
	* @description retrieves a list of npsp__Partial_Soft_Credit__c given an accountId
	* @param accountId
	* @return List<npsp__Partial_Soft_Credit__c>
	********************************************************************************************************/
    public static Map<Id,List<npsp__Account_Soft_Credit__c>> getAccountSoftCreditsFromAccountIds(Set<Id> accountIds){
        Map<Id,List<npsp__Account_Soft_Credit__c>> ascByAccount = new Map<Id,List<npsp__Account_Soft_Credit__c>>();
        String soqlQuery = getASCSoql();
        soqlQuery+=getASCWhereClause(accountIds);
        for(npsp__Account_Soft_Credit__c ascr:(List<npsp__Account_Soft_Credit__c>) database.query(soqlQuery)){
            if(!ascByAccount.containsKey(ascr.npsp__Account__c))
                ascByAccount.put(ascr.npsp__Account__c,new List<npsp__Account_Soft_Credit__c>());
            ascByAccount.get(ascr.npsp__Account__c).add(ascr);
        }
        for(Id accountId:accountIds){
            if(!ascByAccount.containsKey(accountId))
                ascByAccount.put(accountId,new List<npsp__Account_Soft_Credit__c>());
        }
        return ascByAccount;
    }
	/*******************************************************************************************************
	* @description retrieves a map of giftitem collections keyed by accountId
	* @param accountId
	* @param showWonOnly
	* @return Map<Id, List<GiftItem>>
	********************************************************************************************************/
    public static Map<Id, List<GiftItem>> getGiftItems(Set<Id> accountIds, Boolean showWonOnly) {


        showWonOnly = showWonOnly == null ? true : showWonOnly;

		/*******************************************************************************************************
		* @description gift history to return
		*/
		Map<Id, List<GiftItem>> giftItemsMap = new Map<Id, List<GiftItem>>();
		

		/*******************************************************************************************************
		* @description List of opportunities based on accountId
		*/		  
		Map<Id, List<Opportunity>> oppListMap = getOpportunitiesFromAccountIds(accountIds);
		
		/*******************************************************************************************************
		* @description List of soft credit roles based on accountid
		*/		  
		Map<Id, List<OpportunityContactRole>> croleListMap = getSoftCreditsFromAccountIds(accountIds);
		
		/*******************************************************************************************************
		* @description List of partial soft credits based on account id
		*/  
		Map<Id, List<npsp__Partial_Soft_Credit__c>> pscListMap = getPartialSoftCreditsFromAccountIds(accountIds);

		/*******************************************************************************************************
		* @description List of account soft credits based on account id
		*/  
		Map<Id, List<npsp__Account_Soft_Credit__c>> ascListMap = getAccountSoftCreditsFromAccountIds(accountIds);

        for(Id accountId:accountIds){
            List<Opportunity> oppList = oppListMap.containsKey(accountId) ? oppListMap.get(accountId) : new List<Opportunity>();
            List<OpportunityContactRole> croleList = croleListMap.containsKey(accountId) ? croleListMap.get(accountId) : new List<OpportunityContactRole>();
            List<npsp__Partial_Soft_Credit__c> pscList = pscListMap.containsKey(accountId) ? pscListMap.get(accountId) : new List<npsp__Partial_Soft_Credit__c>();
            List<npsp__Account_Soft_Credit__c> ascList = pscListMap.containsKey(accountId) ? ascListMap.get(accountId) : new List<npsp__Account_Soft_Credit__c>();
            if(oppList.size() > 0 
                || croleList.size() > 0
                || pscList.size() > 0
                || ascList.size() > 0){
                List<GiftItem> giftItems = getGiftItems(oppList,croleList,pscList,ascList,showWonOnly);
                giftItemsMap.put(accountId,giftItems);
            } else {
                giftItemsMap.put(accountId,new List<giftItem>());
            }
        }

		return giftItemsMap;

	}

	/*******************************************************************************************************
	* @description gets the Opportunity soql
	* @param void
	* @return String
	********************************************************************************************************/
    public static List<GiftItem> getGiftItems(List<Opportunity> oppList, List<OpportunityContactRole> croleList, List<npsp__Partial_Soft_Credit__c> pscList, List<npsp__Account_Soft_Credit__c> ascList, Boolean showWonOnly){
		/*******************************************************************************************************
		* @description count of giftItems
		*/
        Integer giftCount = 0;

		/*******************************************************************************************************
		* @description gift history to return
		*/
		Map<Id, GiftItem> giftHistory = new Map<Id, GiftItem>();

        /*******************************************************************************************************
        * @description map of softcredits keyed by the opportunity id in order to prevent double counting 
        *  hard credits that may be soft credited to a contact within an account
        */ 
        Map<Id, GiftItem> softCreditGiftItems = new Map<Id, GiftItem>();

        /*******************************************************************************************************
        * @description map of hardcredits keyed by the opportunity id in order to prevent double counting 
        *  hard credits that may be soft credited to a contact within an account
        */ 
        Map<Id, GiftItem> hardCreditGiftItems = new Map<Id, GiftItem>();

        /*******************************************************************************************************
        * @description map of outstanding balances keyed by Opportunity Id 
        */ 
        Map<Id, Decimal> oppOutstandingMap = new Map<Id, Decimal>();

        for(Opportunity opp:oppList) {
            Boolean isRecurring = String.isNotBlank(opp.npe03__Recurring_Donation__c);
            Decimal oppOutstanding = opp.npe01__Amount_Outstanding__c == null ? 0 : opp.npe01__Amount_Outstanding__c;
            Boolean hasPayments = !isRecurring && opp.npe01__OppPayment__r != null && opp.npe01__OppPayment__r.size() >0;
            if(hasPayments && !isRecurring) { 
                for(npe01__OppPayment__c pmt:opp.npe01__OppPayment__r) {
                    GiftItem gi = new GiftItem(opp, pmt);

                    if(!oppOutstandingMap.containsKey(opp.Id)) {
                        gi.pledgedAmountOutstanding = oppOutstanding; 
                        oppOutstandingMap.put(opp.Id,oppOutstanding);
                    }
                    giftCount++;

                    if(opp.isWon && showWonOnly){
                        hardCreditGiftItems.put(gi.recordId,gi);
                    } else {
                        hardCreditGiftItems.put(gi.recordId,gi);
                    }
                    
                }
            } else {
                String recurringName = opp.npe03__Recurring_Donation__r.Name;
                String recurringStage = opp.npe03__Recurring_Donation__r.npsp__Status__c;
                String recurringId = opp.npe03__Recurring_Donation__c;
                GiftItem gi = new GiftItem(opp,isRecurring);
                gi.oppAmount = isRecurring ? gi.TotalAmount + gi.pledgedAmountOutstanding : opp.Amount;
                gi.recordId = isRecurring ? recurringId : opp.Id;
                gi.StageName = isRecurring && String.isNotBlank(recurringStage) ? recurringStage : opp.StageName;
                gi.Name = isRecurring ? recurringName : opp.Name;
                gi.oppAmount = opp.Amount;
                gi.TotalAmount = gi.HardCreditAmount;
            
                if(!hardCreditGiftItems.containsKey(gi.recordId)) {
                    hardCreditGiftItems.put(gi.recordId, gi);
                } else {
                    gi.HardCreditAmount = isRecurring ? hardCreditGiftItems.get(gi.recordId).HardCreditAmount + gi.HardCreditAmount : gi.HardCreditAmount;
                    gi.pledgedAmountOutstanding = isRecurring ? hardCreditGiftItems.get(gi.recordId).pledgedAmountOutstanding + gi.pledgedAmountOutstanding : 0;
                    gi.lastReceivedDate = hardCreditGiftItems.get(gi.recordId).lastReceivedDate < gi.lastReceivedDate ? gi.lastReceivedDate : hardCreditGiftItems.get(gi.recordId).lastReceivedDate;
                    gi.TotalAmount = gi.HardCreditAmount;
                    gi.oppAmount = isRecurring ? gi.TotalAmount + gi.pledgedAmountOutstanding : opp.Amount;

                    if(opp.isWon && showWonOnly){
                        hardCreditGiftItems.put(gi.recordId,gi); 
                    } else {
                        hardCreditGiftItems.put(gi.recordId,gi); 
                    }
                
                }
                
                giftCount++;        
            }
        }
        for(OpportunityContactRole crole : crolelist) {
            if(hardCreditGiftItems.containsKey(crole.OpportunityId))
                continue;
            
            GiftItem gi = new GiftItem(crole);
            giftCount++;

            if(crole.Opportunity.IsWon && showWonOnly) {
                softCreditGiftItems.put(gi.recordId, gi);
            } else {
                softCreditGiftItems.put(gi.recordId, gi);
            }
        }
        for(npsp__Partial_Soft_Credit__c psc : pscList) {
            if(hardCreditGiftItems.containsKey(psc.npsp__Opportunity__c))
                continue;
            
            GiftItem gi = new GiftItem(psc);
            giftCount++;

            if(psc.npsp__Opportunity__r.isWon && showWonOnly){
                softCreditGiftItems.put(gi.recordId, gi);
            } else {
                softCreditGiftItems.put(gi.recordId, gi);
            }
        }
        for(npsp__Account_Soft_Credit__c ascr : ascList) {
            if(hardCreditGiftItems.containsKey(ascr.npsp__Opportunity__c))
                continue;
            
            GiftItem gi = new GiftItem(ascr);
            giftCount++;

            if(ascr.npsp__Opportunity__r.isWon && showWonOnly){
                softCreditGiftItems.put(gi.recordId, gi);
            } else {
                softCreditGiftItems.put(gi.recordId, gi);
            }
        }
        giftHistory.putAll(hardCreditGiftItems);
        giftHistory.putAll(softCreditGiftItems);
        List<GiftItem> giftItems = new List<GiftItem>(giftHistory.values());
        giftItems.sort();
        
		return giftItems;        
    }

    /*******************************************************************************************************
	* @description map of Opportunities for recurring gifts by GiftItem Id
    * @param accountId
    * @return Map<Id, List<Opportunity>> a map of opps keyed by recurring donation id
	*/
	public static Map<Id, List<Opportunity>> getRecurringGiftMap(Id accountId) {
        return getRecurringGiftMap(new Set<Id>{accountId});
    }

    /*******************************************************************************************************
	* @descriptiona map of Opportunities for recurring gifts by GiftItem Id
    * @param accountIds
    * @return Map<Id, List<Opportunity>> a map of opps keyed by recurring donation id
	*/
	public static Map<Id, List<Opportunity>> getRecurringGiftMap(Set<Id> accountIds) {

		Map<Id, List<Opportunity>> recurringGiftMap = new Map<Id, List<Opportunity>>();
		List<Opportunity> oppList = new List<Opportunity>([
			SELECT Id, 
			Name,
			CloseDate, 
			Amount,
			StageName,
			Account.Name,
			isWon,
			isClosed,
			npe03__Recurring_Donation__c,
			npe03__Recurring_Donation__r.Name,
			npe03__Recurring_Donation__r.Status__c,
			npe03__Recurring_Donation__r.npsp__Status__c,
			npe01__Amount_Outstanding__c,
			CampaignId,
			Campaign.Name
			FROM Opportunity 
			WHERE 
			AccountId IN:accountIds 
			AND npe03__Recurring_Donation__c != null
			AND IsWon=true
			ORDER BY CloseDate DESC]);
			
		for(Opportunity opp:oppList) {
			if(!recurringGiftMap.containsKey(opp.npe03__Recurring_Donation__c)) {
				recurringGiftMap.put(opp.npe03__Recurring_Donation__c, new List<Opportunity>());
			}
			recurringGiftMap.get(opp.npe03__Recurring_Donation__c).add(opp);
		}
		return recurringGiftMap;
		
	}

    /*******************************************************************************************************
	* @description given a contact or account id, return a list of annual gift histories
	* @param recordId  the id of the contact or account
	* @return Map<Id, List<AnnualGiftHistory>> the full gift history summarized by year for the account
	*/
	public static Map<Id, List<AnnualGiftHistory>> getGiftHistory(Set<Id> accountIds, Boolean showWonOnly) {

        showWonOnly = showWonOnly == null ? true : showWonOnly;

		/*******************************************************************************************************
		* @description gift history to return
		*/
		Map<Id, List<AnnualGiftHistory>> giftHistoryMap = new Map<Id, List<AnnualGiftHistory>>();
		

		/*******************************************************************************************************
		* @description List of opportunities based on accountId
		*/		  
		Map<Id, List<Opportunity>> oppListMap = getOpportunitiesFromAccountIds(accountIds);
		
		/*******************************************************************************************************
		* @description List of soft credit roles based on accountid
		*/		  
		Map<Id, List<OpportunityContactRole>> croleListMap = getSoftCreditsFromAccountIds(accountIds);
		
		/*******************************************************************************************************
		* @description List of partial soft credits based on account id
		*/  
		Map<Id, List<npsp__Partial_Soft_Credit__c>> pscListMap = getPartialSoftCreditsFromAccountIds(accountIds);

		/*******************************************************************************************************
		* @description List of partial soft credits based on account id
		*/  
		Map<Id, List<npsp__Account_Soft_Credit__c>> ascListMap = getAccountSoftCreditsFromAccountIds(accountIds);

        for(Id accountId:accountIds){
            List<Opportunity> oppList = oppListMap.containsKey(accountId) ? oppListMap.get(accountId) : new List<Opportunity>();
            List<OpportunityContactRole> croleList = croleListMap.containsKey(accountId) ? croleListMap.get(accountId) : new List<OpportunityContactRole>();
            List<npsp__Partial_Soft_Credit__c> pscList = pscListMap.containsKey(accountId) ? pscListMap.get(accountId) : new List<npsp__Partial_Soft_Credit__c>();
            List<npsp__Account_Soft_Credit__c> ascList = ascListMap.containsKey(accountId) ? ascListMap.get(accountId) : new List<npsp__Account_Soft_Credit__c>();
            Map<Id, List<Opportunity>> recurringGiftMap = getRecurringGiftMap(accountIds);

            if(oppList.size() > 0 
                || croleList.size() > 0
                || pscList.size() > 0
                || ascList.size() > 0){
                List<AnnualGiftHistory> giftHistory = getGiftHistory(oppList,croleList,pscList,ascList,recurringGiftMap,showWonOnly);
                giftHistoryMap.put(accountId,giftHistory);
            } else {
                giftHistoryMap.put(accountId,new List<AnnualGiftHistory>());
            }
        }
        return giftHistoryMap;

    }

    /*******************************************************************************************************
	* @description given a contact or account id, return a list of annual gift histories
	* @param recordId  the id of the contact or account
	* @return Map<Id, List<AnnualGiftHistory>> the full gift history summarized by year for the account
	*/
    public static Map<Id, List<AnnualGiftHistory>> getGiftHistory(Id recordId, Boolean showWonOnly){
        Id accountId = getAccountIdFromRecordId(recordId);
        return getGiftHistory(new Set<Id>{accountId},showWonOnly);
    }

    /*******************************************************************************************************
	* @description given a contact or account id, return a list of annual gift histories
	* @param oppList list of opps for the account
    * @param crolelist list of contact roles for the account
    * @param psclist list of partial soft credits for the account
    * @param recurringGiftMap a map of recurring donations
    * @param showWonOnly boolean to determine whether or not you only display won records
	* @return List<AnnualGiftHistory> the full gift history summarized by year for the account
	*/
	public static List<AnnualGiftHistory> getGiftHistory(List<Opportunity> oppList, List<OpportunityContactRole> croleList, List<npsp__Partial_Soft_Credit__c> pscList, List<npsp__Account_Soft_Credit__c> ascList, Map<Id, List<Opportunity>> recurringGiftMap, Boolean showWonOnly) {
        Id accountId;
		/*******************************************************************************************************
		* @description gift history to return
		*/
		Map<String, AnnualGiftHistory> giftHistory = new Map<String, AnnualGiftHistory>();	

		Set<Id> softCredited = new Set<Id>();

		//List<GiftItem> gis = new List<GiftItem>(getGiftItems(recordId,showWonOnly));

        Map<Id, Decimal> hardCreditMap = new Map<Id, Decimal>();

		Map<String, Set<Id>> oppsByYear = new Map<String, Set<Id>>();

        //system.debug('asclist size: '+asclist.size());

		for(Opportunity opp : oppList) {
            accountId = opp.AccountId;
            hardCreditMap.put(opp.Id,opp.Amount);
			String giftYear = String.valueOf(opp.CloseDate.Year());
			if(!giftHistory.containsKey(giftYear)) {
				AnnualGiftHistory agh = new AnnualGiftHistory(giftYear, 0.0, 0.0, 0.0, 0.0, accountId);
				oppsByYear.put(giftYear,new Set<Id>());
				giftHistory.put(giftYear, agh);
			}
            Boolean hasPayments = opp.npe01__OppPayment__r != null && opp.npe01__OppPayment__r.size() >0;
            Decimal outstanding = hasPayments ? opp.npe01__Amount_Outstanding__c : GiftItem.calculateAmount('pledged', opp.Amount, 0, opp.StageName, opp.IsWon, opp.IsClosed);
            Decimal hardCredit = hasPayments ? opp.Amount - opp.npe01__Amount_Outstanding__c : GiftItem.calculateAmount('won', opp.Amount, 0, opp.StageName, opp.IsWon, opp.IsClosed);
			Boolean lost = opp.IsClosed && !opp.IsWon;
			if(!lost) {
				AnnualGiftHistory agh = giftHistory.get(giftYear);
				agh.hardCreditAmount += hardCredit;
				agh.pledgedAmountOutstanding += outstanding;
				agh.totalAmount = agh.hardCreditAmount + agh.softCreditAmount;
				giftHistory.put(giftYear, agh);
				oppsByYear.get(giftYear).add(opp.Id);
			}
		}
        for(npsp__Partial_Soft_Credit__c psc:pscList){
            accountId = accountId == null ? psc.npsp__Contact__r.AccountId : accountId;
            if(hardCreditMap.containsKey(psc.npsp__Opportunity__c))
                continue;
                
            String giftYear = String.valueOf(psc.npsp__Opportunity__r.CloseDate.Year());
			if(!giftHistory.containsKey(giftYear)) {
				AnnualGiftHistory agh = new AnnualGiftHistory(giftYear, 0.0, 0.0, 0.0, 0.0, accountId);
				giftHistory.put(giftYear, agh);
				oppsByYear.put(giftYear,new Set<Id>());
			}
            AnnualGiftHistory agh = giftHistory.get(giftYear);
            agh.softCreditAmount += psc.npsp__Amount__c;
            agh.totalAmount = agh.hardCreditAmount + agh.softCreditAmount;
            giftHistory.put(giftYear, agh);
			softCredited.add(psc.npsp__Opportunity__c);
			oppsByYear.get(giftYear).add(psc.npsp__Opportunity__c);
        }

        for(npsp__Account_Soft_Credit__c ascr:ascList){
            accountId = accountId == null ? ascr.npsp__Account__c : accountId;
            if(hardCreditMap.containsKey(ascr.npsp__Opportunity__c))
                continue;
                
            String giftYear = String.valueOf(ascr.npsp__Opportunity__r.CloseDate.Year());
			if(!giftHistory.containsKey(giftYear)) {
				AnnualGiftHistory agh = new AnnualGiftHistory(giftYear, 0.0, 0.0, 0.0, 0.0, accountId);
				giftHistory.put(giftYear, agh);
				oppsByYear.put(giftYear,new Set<Id>());
			}
            AnnualGiftHistory agh = giftHistory.get(giftYear);
            agh.softCreditAmount += ascr.npsp__Amount__c;
            agh.totalAmount = agh.hardCreditAmount + agh.softCreditAmount;
            giftHistory.put(giftYear, agh);
			softCredited.add(ascr.npsp__Opportunity__c);
			oppsByYear.get(giftYear).add(ascr.npsp__Opportunity__c);
        }

        for(OpportunityContactRole crole:croleList){
            accountId = accountId == null ? crole.Contact.AccountId : accountId;
            if(hardCreditMap.containsKey(crole.OpportunityId)
				|| softCredited.contains(crole.OpportunityId))
                continue;

			
            String giftYear = String.valueOf(crole.Opportunity.CloseDate.Year());
			if(!giftHistory.containsKey(giftYear)) {
				AnnualGiftHistory agh = new AnnualGiftHistory(giftYear, 0.0, 0.0, 0.0, 0.0, accountId);
				giftHistory.put(giftYear, agh);
				oppsByYear.put(giftYear,new Set<Id>());
			}
            AnnualGiftHistory agh = giftHistory.get(giftYear);
            agh.softCreditAmount += (crole.Opportunity.Amount - crole.Opportunity.npe01__Amount_Outstanding__c);
			agh.pledgedAmountOutstanding += crole.Opportunity.npe01__Amount_Outstanding__c;
            agh.totalAmount = agh.hardCreditAmount + agh.softCreditAmount;
            giftHistory.put(giftYear, agh);
			softCredited.add(crole.OpportunityId);
			oppsByYear.get(giftYear).add(crole.OpportunityId);
        }

		
		AnnualGiftHistory totalRow = new AnnualGiftHistory('Total', 0.0, 0.0, 0.0, 0.0, accountId);
		totalRow.Year = 'Total';
		totalRow.hardCreditAmount = 0;
		totalRow.softCreditAmount = 0;
		totalRow.pledgedAmountOutstanding = 0;
		totalRow.totalAmount = 0;
		for(AnnualGiftHistory agh:giftHistory.values()) {
			agh.numGifts = oppsByYear.containsKey(agh.Year) ? oppsByYear.get(agh.Year).size() : agh.numGifts;
			totalRow.hardCreditAmount += agh.hardCreditAmount;
			totalRow.softCreditAmount += agh.softCreditAmount;
			totalRow.pledgedAmountOutstanding += agh.pledgedAmountOutstanding;
			totalRow.totalAmount += agh.totalAmount;
		}
		giftHistory.put('Total', totalRow);
		List<AnnualGiftHistory> aghList = new List<AnnualGiftHistory>(giftHistory.values());
		aghList.sort();
		
		return aghList;
	}

	/*******************************************************************************************************
	* @description processes gift histories from the batch
	* @param void
	* @return String
	********************************************************************************************************/
    public static void processHistories(List<SObject> records, Boolean isAccount){
        Set<Id> accountIds = new Set<Id>();
        
        if(isAccount){
            accountIds.addAll(new Map<Id, Account>((List<Account>) records).keyset());
        } else {
            accountIds.addAll(getAccountIdsFromOpps((List<Opportunity>) records));
        }

        Map<Id, List<AnnualGiftHistory>> aghMap = new Map<Id, List<AnnualGiftHistory>>();
        aghMap.putAll(getGiftHistory(accountIds,true));

        List<AnnualGiftHistory__c> aghList = new List<AnnualGiftHistory__c>();
        for(Id accountId:aghMap.keyset()){
           for(AnnualGiftHistory agh:aghMap.get(accountId)){
                if(!agh.year.equalsIgnoreCase('Total'))
                    aghList.add(agh.getSObject());
           }
        }

        if(aghList.size()>0)
            upsert aghList UniqueId__c;

    }

	/*******************************************************************************************************
	* @description retrieves a set of AccountIds from a list of opportunities
	* @param opps opportunities to pull account ids from hard and soft credits
	* @return Set<Id> accountIds
	********************************************************************************************************/
    public static Set<Id> getAccountIdsFromOpps(List<Opportunity> opps){
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp:opps){
            accountIDs.add(opp.AccountId);
            if(opp.OpportunityContactRoles != null && opp.OpportunityContactRoles.size()>0){
                for(OpportunityContactRole ocr:opp.OpportunityContactRoles){
                    accountIds.add(ocr.Contact.AccountId);
                }
            }
        }

        return accountIds;
    }

	/*******************************************************************************************************
	* @description gets the Opportunity soql
	* @param void
	* @return String
	********************************************************************************************************/
    public static String getOpportunitySoql(){
        String soql='SELECT Id,'; 
        soql+=' Name,'; 
        soql+=' CloseDate, '; 
        soql+=' Amount,'; 
        soql+=' StageName,'; 
        soql+=' Account.Name,'; 
        soql+=' isWon,'; 
        soql+=' isClosed,'; 
        soql+=' npe03__Recurring_Donation__c,'; 
        soql+=' npe03__Recurring_Donation__r.Name,'; 
        soql+=' npe03__Recurring_Donation__r.Status__c,'; 
        soql+=' npe03__Recurring_Donation__r.npsp__Status__c,'; 
        soql+=' npe01__Amount_Outstanding__c,'; 
        soql+=' CampaignId,'; 
        soql+=' Campaign.Name, '; 
        soql+=' RecordType.Name,'; 
        soql+=' (SELECT '; 
        soql+='     Id, '; 
        soql+='     npe01__Payment_Amount__c,'; 
        soql+='     npe01__Payment_Date__c,'; 
        soql+='     npe01__Paid__c,'; 
        soql+='     npe01__Scheduled_Date__c'; 
        soql+='     FROM npe01__OppPayment__r'; 
        soql+='     WHERE npe01__Paid__c = true'; 
        soql+='     ORDER BY npe01__Payment_Date__c DESC'; 
        soql+=' )'; 
        soql+=' FROM Opportunity '; 
        return soql;
 
    }

	/*******************************************************************************************************
	* @description gets the ContactRole soql
	* @param void
	* @return String
	********************************************************************************************************/
    public static String getSoftCreditSoql(){
        String soql='SELECT Id,';
        soql+=' ContactId,';
        soql+=' Contact.AccountId,';
        soql+=' Opportunity.AccountId,';
        soql+=' OpportunityId,';
        soql+=' Opportunity.Name,';
        soql+=' Opportunity.IsWon,';
        soql+=' Opportunity.IsClosed,';
        soql+=' Opportunity.Amount,';
        soql+=' Opportunity.CloseDate,';
        soql+=' Opportunity.StageName,';
        soql+=' Opportunity.Account.Name,';
        soql+=' Opportunity.CampaignId,';
        soql+=' Opportunity.Campaign.Name,';
        soql+= 'Opportunity.npe01__Amount_Outstanding__c,';
        soql+=' Opportunity.RecordType.Name';
        soql+=' FROM OpportunityContactRole';
        return soql;

    }

	/*******************************************************************************************************
	* @description gets the Account Soft Credit soql
	* @param void
	* @return String
	********************************************************************************************************/
    public static String getASCSoql(){
        String soql='SELECT Id,';
        soql+=' npsp__Account__c,';
        soql+=' npsp__Amount__c,';
        soql+=' npsp__Opportunity__c,';
        soql+=' npsp__Opportunity__r.AccountId,';
        soql+=' npsp__Opportunity__r.Name,';
        soql+=' npsp__Opportunity__r.CloseDate,';
        soql+=' npsp__Opportunity__r.StageName,';
        soql+=' npsp__Opportunity__r.IsWon,';
        soql+=' npsp__Opportunity__r.IsClosed,';
        soql+=' npsp__Opportunity__r.Amount,';
        soql+=' npsp__Opportunity__r.CampaignId,';
        soql+=' npsp__Opportunity__r.Campaign.Name,';
        soql+=' npsp__Opportunity__r.npe01__Amount_Outstanding__c,';
        soql+=' npsp__Opportunity__r.RecordType.Name,';
        soql+=' npsp__Role__c';
        soql+=' FROM npsp__Account_Soft_Credit__c';
        return soql;
    }

	/*******************************************************************************************************
	* @description gets the PArtialSoftCredit soql
	* @param void
	* @return String
	********************************************************************************************************/
    public static String getPSCSoql(){
        String soql='SELECT Id,';
        soql+=' npsp__Opportunity__c,';
        soql+=' npsp__Opportunity__r.AccountId,';
        soql+=' npsp__Contact__c,';
        soql+=' npsp__Contact__r.AccountId,';
        soql+=' npsp__Opportunity__r.Name,';
        soql+=' npsp__Opportunity__r.CloseDate,';
        soql+=' npsp__Opportunity__r.StageName,';
        soql+=' npsp__Opportunity__r.IsWon,';
        soql+=' npsp__Opportunity__r.IsClosed,';
        soql+=' npsp__Amount__c,';
        soql+=' npsp__Opportunity__r.Amount,';
        soql+=' npsp__Contact__r.Account.Name,';
        soql+=' npsp__Opportunity__r.CampaignId,';
        soql+=' npsp__Opportunity__r.Campaign.Name,';
        soql+=' npsp__Opportunity__r.npe01__Amount_Outstanding__c,';
        soql+=' npsp__Opportunity__r.RecordType.Name';
        soql+=' FROM npsp__Partial_Soft_Credit__c';
        return soql;
    }
	/*******************************************************************************************************
	* @description get ContactRole whereClause
	* @param type
	* @return String
	********************************************************************************************************/
    public static String getSoftCreditWhereClause(Set<Id> accountIds){
        String whereClause =' WHERE ';
        whereClause+=' Contact.AccountId IN:accountIds';
        whereClause+=' AND Role=\'Soft Credit\'';
        whereClause+=' AND Opportunity.Amount != null';
        whereClause+=' AND Opportunity.Amount != 0';
        whereClause+=' AND (';
        whereClause+='     (Opportunity.IsClosed = TRUE AND Opportunity.IsWon = TRUE)';
        whereClause+='     OR Opportunity.IsClosed = FALSE';
        whereClause+=' )';
        whereClause+=' ORDER BY Opportunity.CloseDate DESC';
        return whereClause;
    }

	/*******************************************************************************************************
	* @description get Opportunity whereClause
	* @param type
	* @return String
	********************************************************************************************************/
    public static String getOpportunityWhereClause(Set<Id> accountIds){

        String whereClause =' WHERE ';
        whereClause+=' AccountId IN:accountIds';
        whereClause+=' AND Amount != null';
        whereClause+=' AND Amount != 0';
        whereClause+=' AND RecordType.DeveloperName != \'Planned_Gift\'';
        whereClause+=' AND (';
        whereClause+='     (IsClosed = TRUE AND IsWon = TRUE)';
        whereClause+='     OR IsClosed = FALSE';
        whereClause+=' )';
        whereClause+=' ORDER BY CloseDate DESC'; 
        return whereClause;
    }
	/*******************************************************************************************************
	* @description get Partial Soft Credit whereClause
	* @param accountIds
	* @return String
	********************************************************************************************************/
    public static String getPSCWhereClause(Set<Id> accountIds){
        String whereClause =' WHERE npsp__Contact__r.AccountId IN:accountIds';
        whereClause+=' AND npsp__Opportunity__r.Amount != null';
        whereClause+=' AND npsp__Opportunity__r.Amount != 0';
        whereClause+=' AND (';
        whereClause+='     (npsp__Opportunity__r.IsClosed = TRUE AND npsp__Opportunity__r.IsWon = TRUE)';
        whereClause+='     OR npsp__Opportunity__r.IsClosed = FALSE';
        whereClause+=' )';
        whereClause+='  ORDER BY npsp__Opportunity__r.CloseDate DESC';
        return whereClause;
    }

	/*******************************************************************************************************
	* @description get Partial Soft Credit whereClause
	* @param accountIds
	* @return String
	********************************************************************************************************/
    public static String getASCWhereClause(Set<Id> accountIds){
        String whereClause =' WHERE npsp__Account__c IN:accountIds';
        whereClause+=' AND npsp__Opportunity__r.Amount != null';
        whereClause+=' AND npsp__Opportunity__r.Amount != 0';
        whereClause+=' AND (';
        whereClause+='     (npsp__Opportunity__r.IsClosed = TRUE AND npsp__Opportunity__r.IsWon = TRUE)';
        whereClause+='     OR npsp__Opportunity__r.IsClosed = FALSE';
        whereClause+=' )';
        whereClause+='  ORDER BY npsp__Opportunity__r.CloseDate DESC';
        return whereClause;
    }
	/*******************************************************************************************************
	* @description get batch soql query
	* @param isAccount
	* @return String
	********************************************************************************************************/
    public static String getBatchSoql(Boolean isAccount){
        String soqlQuery = '';
        if(!isAccount){
            soqlQuery+='SELECT Id,';
            soqlQuery+=' AccountId,';
            soqlQuery+=' (SELECT Id,';
            soqlQuery+=' Contact.AccountId';
            soqlQuery+=' FROM OpportunityContactRoles';
            soqlQuery+=' WHERE Role=\'Soft Credit\')';
            soqlQuery+=' FROM Opportunity';
        } else {
           soqlQuery+='SELECT Id';
           soqlQuery+=' FROM Account';
        }
         
        return soqlQuery;
    }
	/*******************************************************************************************************
	* @description get batch where clause
	* @param accountIds
    * @param startDate
	* @return String
	********************************************************************************************************/
    public static String getBatchWhereClause(Date startDate, Set<Id> accountIds){
        String whereClause;
        if(accountIds == null){
            whereClause = ' WHERE LastModifiedDate >=:startDate ORDER BY AccountId';
        } else {
            whereClause = ' WHERE Id IN:accountIds';
        }
        return whereClause;
    }
}
