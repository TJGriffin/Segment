public with sharing class ACC_Segment_CTRL {
    @auraEnabled
    public static String processSegmentsFromRecordId(String recordId) {
        Id accountId = ACC_Giving_SVC.getAccountIdFromRecordId(recordId);
        String failedId;

        Account account = [SELECT Id, Major_Donor_Downgrade_Date__c, Mid_Level_Donor_Downgrade_Date__c FROM Account WHERE Id =:accountID];
        ACC_Segment_SVC service = new ACC_Segment_SVC(new List<Account>{account});
        if(service.failedIds != null && service.failedIds.size()>0)
            failedId = recordId;
            
        return failedId;
    }
}
