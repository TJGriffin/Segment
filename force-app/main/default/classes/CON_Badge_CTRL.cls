/**
* @author TJ Griffin
* @date 2022
* @group Giving Rollups
* @description controller for retrieving custom contact badge data
*/
public with sharing class CON_Badge_CTRL {

    /*******************************************************************************************************
    * @description retrieves a collection of strings to display as a badges
    * @param recordId  the id of the contact or account
    * @return List<String>
    */
    @AuraEnabled(cacheable=true)
    public static List<String> getCustomBadges(Id recordId) {

        List<String> badgeLabels = new List<String>();

        Id accountId = ACC_Giving_SVC.getAccountIdFromRecordId(recordId);

        Boolean isAccount = accountId == recordId;

        Set<Id> contactIds = isAccount ? ACC_Giving_SVC.getContactIdsForAccount(accountId) : new Set<Id>{recordId};

        badgeLabels.addAll(getAffiliationBadges(contactIds));

        return badgeLabels;

    }

    /**
    * @description affiliation roles that should be displayed as badges
    */
    public static List<String> roles {
        get { if(roles == null)
           {
                // add the roles that should display as badges here
                roles = new List<String>{'Board Member'};
            }
            return roles;
        }       
        set;
    }

    /*******************************************************************************************************
    * @description retrieves a unique collection of badge labels from affiliation records
    * @param Set<Id> contactIds
    * @return Set<String>
    */
    public static Set<String> getAffiliationBadges(Set<Id> contactIds){
        
        Map<String, String> labelStatus = new Map<String, String>();
        for(npe5__Affiliation__c aff:[
            SELECT 
                Id,
                npe5__Role__c,
            	Type__c,
                npe5__Status__c
            FROM npe5__Affiliation__c 
            WHERE npe5__Contact__c IN:contactIds 
            AND Account_Name__c = 'The Trevor Project'
            AND Type__c IN:roles]){
                if(aff.npe5__Status__c == 'Former'
                    && !labelStatus.containsKey(aff.Type__c)) {
                        labelStatus.put(aff.Type__c, aff.npe5__Status__c);
                    } else {
                        labelStatus.put(aff.Type__c, aff.npe5__Status__c);
                    }
            }
        Set<String> labels = new Set<String>();
        for(String label:labelStatus.keyset()){
            String status = labelStatus.get(label);
            label = status == 'Former' ? 'Former '+label : label;
            labels.add(label);
        }
        return labels;
    }
}