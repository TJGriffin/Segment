public with sharing class ACC_Segment_CTRL {
    @auraEnabled
    public static String processSegmentsFromRecordId(String recordId) {
        Id accountId = ACC_Giving_SVC.getAccountIdFromRecordId(recordId);
        String failedId;

        Account account = [
            SELECT 
                Id, 
                Major_Donor_Downgrade_Date__c, 
                Mid_Level_Donor_Downgrade_Date__c,
                First_Recurring_Gift_Date__c,
                Last_Recurring_Gift_Date__c
                
            FROM Account 
            WHERE Id =:accountID
        ];
        ACC_Segment_SVC service = new ACC_Segment_SVC(new List<Account>{account});
        if(service.failedIds != null && service.failedIds.size()>0)
            failedId = recordId;
            
        return failedId;
    }

    @auraEnabled
    public static String setProspectStatus(String recordId,String fieldName, String status){
        String message;
        Id accountId = ACC_Giving_SVC.getAccountIdFromRecordId(recordId);
        String failedId;
        Account acc = new Account(Id=accountId);
        acc.put(fieldName,status);

        try {
            update acc;
            message = 'Success';
        } catch(Exception e){
            message = e.getMessage();
        }
        return message;
    }

    @auraEnabled
    public static String downgradeDonor(String recordId,String fieldName, String status){
        String message;
        Id accountId = ACC_Giving_SVC.getAccountIdFromRecordId(recordId);
        String failedId;
        Account acc = new Account(Id=accountId);
        acc.put(fieldName,status);
        if(String.isBlank(status)){
            String dateFieldName = fieldName.replace('Status__c','Downgrade_Date__c');
            acc.put(dateFieldName,null);
            String userField = fieldName.replace('Status__c','Downgrade_By__c');
            acc.put(userField,null);
        }

        try {
            update acc;
            message = 'Success';
        } catch(Exception e){
            message = e.getMessage();
        }
        return message;
    }
}
