/**
* @author TJ Griffin
* @date 2022
* @group Segment
* @description service for managing segments on Opportunities
*/
public with sharing class OPP_Segment_SVC {
	/*******************************************************************************************************
	* @description processes opportunities from the batch class
	* @param opps
    * @return Set<Id> a set of failed Ids
	********************************************************************************************************/
    public static Set<Id> processOpportunities(List<Opportunity> opps) {
        Set<Id> failedIds = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(opps);
        Map<Date, Set<Account>> accsByCloseDate = getAccountsByCloseDate(opps);
        Map<Date, Set<Id>> oppsByCloseDate = getOppIdsByCloseDate(opps);

        for(Date closeDate:accsByCloseDate.keyset()){
            Date effectiveDate = closeDate.addDays(-1);
            Set<Account> accs = accsByCloseDate.get(closeDate);
            List<Account> accList = new List<Account>();
            accList.addAll(accs);
            ACC_Segment_SVC svc = new ACC_Segment_SVC(accList,closeDate);
            Map<Id, Account> accountMap = svc.accountMap;
            for(Id oppId:oppsByCloseDate.get(closeDate)){
                Opportunity opp = oppMap.get(oppId);

                if(String.isBlank(opp.AccountId))
                    continue;
    
                Account acc = accountMap.get(opp.AccountId);
                acc.Donor_Segment__c = ACC_Segment_SVC.calculateDonorSegment((SObject) acc);
                // loop through the segment fields and set the values from the Account on the Opportunity
                for(String fld:ACC_Segment_SVC.segmentFields){
                    if(acc.isSet(fld)){
                        String value = (String) acc.get(fld);
                        opp.put(fld,value);
                    }
                }
                oppMap.put(opp.Id,opp);
            }
            svc.accountMap.clear();

        }
        update oppMap.values();
        return failedIds;
    }

	/*******************************************************************************************************
	* @description gets a list of accounts keyed by Opp close date
	* @param opps
    * @return Map<Date, List<Account>>
	********************************************************************************************************/
    public static Map<Date, Set<Account>> getAccountsByCloseDate(List<Opportunity> opps){
        Set<Id> accountIds = new Set<Id>();
        
        for(Opportunity opp:opps){
            if(String.isNotBlank(opp.AccountId))
                accountIds.add(opp.AccountId);
        }

        Map<Id, Account> accounts = new Map<Id, Account>([
            SELECT Id,
            Major_Donor_Downgrade_Date__c,
            Mid_Level_Donor_Downgrade_Date__c,
            First_Recurring_Gift_Date__c, 
            Last_Recurring_Gift_Date__c
            FROM Account
            WHERE Id IN:accountIds
        ]);
        Map<Date,Set<Account>> accountsByCloseDate = new Map<Date,Set<Account>>();
    
        for(opportunity opp:opps){
            if(String.isBlank(opp.AccountId) || opp.CloseDate == null)
                continue;

            Date closeDate = opp.CloseDate;
            Account acc = accounts.get(opp.AccountId);
            if(!accountsByCloseDate.containsKey(closeDate))
                accountsByCloseDate.put(closeDate,new Set<Account>());

            accountsByCloseDate.get(closeDate).add(acc);

        }

        return accountsByCloseDate;
    }

	/*******************************************************************************************************
	* @description gets a set of Opportunity Ids keyed by Opp CloseDate
	* @param opps
    * @return Map<Date, Set<Id>>
	********************************************************************************************************/
    public static Map<Date, Set<Id>> getOppIdsByCloseDate(List<Opportunity> opps){
        Map<Date, Set<Id>> oppIdsByCloseDate = new Map<Date, Set<Id>>();
        for(Opportunity opp:opps){
            Date closeDate = opp.CloseDate;
            if(closeDate == null)
                continue;

            if(!oppIdsByCloseDate.containsKey(closeDate))
                oppIdsByCloseDate.put(closeDate, new Set<Id>());
            oppIdsByCloseDate.get(closeDate).add(opp.Id);
        }

        return oppIdsByCloseDate;
    }
}
