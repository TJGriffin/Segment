
@isTest
private class UTIL_TestDataFactory_TEST {

    @isTest
    static void testUtil() {

        Contact con = new Contact(
            FirstName='TEst',
            LastName = 'test'
        );
        insert con;
        
        test.startTest();
        Map<Integer, String> countType = UTIL_TestDataFactory_SVC.countType;

        npe03__Recurring_Donation__c rd  = UTIL_TestDataFactory_SVC.createNPSPRd(con.Id);

        test.stopTest();
        // TO DO: implement unit test
    }
}