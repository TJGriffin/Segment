
@isTest
private class ACC_Segment_TEST {
    @TestSetup
    static void makeData(){
        Account acc = new Account(
            Name='Foundation'
        );
        insert acc;

        List<Contact> cons = (List<Contact>) TestDataFactory.createSObjectList('Contact', 10, true);

        // add recurring donations
        List<npe03__Recurring_Donation__c> rds = new List<npe03__Recurring_Donation__c>();
        rds.add(new npe03__Recurring_Donation__c(
            npe03__Contact__c = cons[6].Id,
            npe03__Amount__c = 10,
            npe03__Date_Established__c = Date.Today().addYears(-1),
            npe03__Open_Ended_Status__c = 'Closed',
            npe03__Installments__c = 24,
            Status__c = 'active'
        ));
        rds.add(new npe03__Recurring_Donation__c(
            npe03__Contact__c = cons[7].Id,
            npe03__Amount__c = 10,
            npe03__Date_Established__c = Date.Today().addYears(-4),
            npe03__Open_Ended_Status__c = 'Closed',
            npe03__Installments__c = 24,
            Status__c = 'canceled'
        ));

        insert rds;

        List<Opportunity> opps = (List<Opportunity>) TestDataFactory.createSObjectList('Opportunity',new Map<String, Object>{
            'npsp__Primary_Contact__r'=>cons
        },10);
        cons = [
            SELECT 
            Id,
            FirstName,
            LastName,
            (
                SELECT
                Id,
                CloseDate,
                Amount,
                StageName
                FROM 
                npsp__Opportunities__r
            )
            FROM Contact
        ];

        // add soft credits
        Opportunity pscOpp = new Opportunity(
            Amount = 100000,
            CloseDate = Date.today().addMonths(-10),
            AccountId = acc.Id,
            StageName = 'Closed Won',
            Name='Partial Soft Credit Opp'
        );
        insert pscOpp;

        // add soft credits
        Opportunity scOpp = new Opportunity(
            Amount = 25000,
            CloseDate = Date.today().addMonths(-10),
            AccountId = acc.Id,
            StageName = 'Closed Won',
            Name='Full Soft Credit Opp'
        );
        insert scOpp;

        Opportunity ascOpp = new Opportunity(
            Amount = 100,
            CloseDate = Date.today().addMonths(-10),
            AccountId = acc.Id,
            StageName = 'Posted',
            Name='Account Soft Credit Opp'
        );
        insert ascOpp;

        List<npsp__partial_Soft_credit__c> pscs = new List<npsp__Partial_Soft_Credit__c>();
        List<OpportunityContactRole> scs = new List<OpportunityContactRole>();
        List<npsp__Account_Soft_Credit__c> ascs = new List<npsp__Account_Soft_Credit__c>();

        ascs.add(new npsp__Account_Soft_Credit__c(
            npsp__Account__c = acc.Id,
            npsp__Amount__c = 500,
            npsp__Opportunity__c = ascOpp.Id,
            npsp__Role__c = 'Donation Source'
        ));

        opps.clear();
        Integer i=0;
        for(Contact con:cons){
            
            String type = UTIL_TestDataFactory_SVC.countType.containsKey(i) ? UTIL_TestDataFactory_SVC.countType.get(i) : 'na';
            con.FirstName = con.FirstName + ' | '+i;
            con.LastName = type;
            Boolean isActive = type.contains('Active');
            Boolean isLapsed = type.contains('Lapsed');
            Boolean isMajor = type.contains('Major');
            Boolean isMid = type.contains('Mid');
            Boolean isSustainer = type.contains('Sustainer');
            Boolean isDonor = !isMajor && !isMid && !isSustainer && type != 'na';
            Integer multiplier = isActive ? (i + 1) * -2 : (i + 10) * -2;
            multiplier = !isActive && !isLapsed ? (i + 20) * -3 : multiplier;
            for(Opportunity opp:con.npsp__Opportunities__r){
                opp.StageName = type == 'na' ? 'Closed Lost' : 'Closed Won';
                opp.CloseDate = Date.today().addMonths(multiplier);
                if(isDonor) {
                    opp.Amount = .10;
                } else if(isMid) {
                    opp.Amount = 250;
                } else if(isMajor) {
                    opp.Amount = 1000;
                } else if(isSustainer) {
                    opp.npe03__Recurring_Donation__c = i==6 ? rds[0].Id : rds[1].Id;
                    opp.Amount = 10;
                    opp.CloseDate = i==6 ? Date.today().addMonths(-i) : opp.CloseDate;
                }
                
            }
            if(isActive && isMid){
                pscs.add(new npsp__Partial_Soft_credit__c(
                    npsp__Contact__c = con.Id,
                    npsp__Opportunity__c = scOpp.Id,
                    npsp__Amount__c = 25,
                    npsp__Role_Name__c = 'Soft Credit'
                ));
            } else if(isActive && isMajor){
                scs.add(new OpportunityContactRole(
                    ContactId=con.Id,
                    OpportunityId = scOpp.Id,
                    Role = 'Soft Credit'
                ));
            }
            i++;
        }
        update cons;
        update opps;
        insert pscs;
        insert scs;
        insert ascs;

        


    }
    @isTest
    static void testController() {
        System.assertEquals(ACC_Segment_UTIL.manualOverride,true);
        List<Account> accounts = [SELECT Id FROM Account];
        test.startTest();
        ACC_Segment_CTRL.processSegmentsFromRecordId(accounts[0].Id);
        test.stopTest();
    }

    @isTest
    static void testService() {

        String soql = ACC_Segment_SVC.getSegmentFieldSoql('Account');
        List<Account> accounts =  (List<Account>) Database.query(soql);

        test.startTest();
        ACC_Segment_SVC segmentService = new ACC_Segment_SVC(accounts);
        test.stopTest();

        system.assert(ACC_Segment_SVC.firstDate != null);
        system.assert(ACC_Segment_SVC.formerDate != null);
        system.assert(ACC_Segment_SVC.lapsedDate != null);
        system.assert(ACC_Segment_SVC.lapsedSustainer != null);

    }
    @isTest
    static void testBatch() {
        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH());
        test.stopTest();
    }
    @isTest
    static void testBatch1() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.ACCOUNT;
        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(mode));
        test.stopTest();
    }
    @isTest
    static void testBatch2() {
        
        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(true));
        test.stopTest();
    }
    @isTest
    static void testBatch3() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.ACCOUNT;
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id FROM Account]);
        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(accounts.keyset(), 0, mode));
        test.stopTest();
    }
    @isTest
    static void testBatch4() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.ACCOUNT;
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id FROM Account]);
        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(accounts.keyset(), 0, true, mode));
        test.stopTest();
    }
    @isTest
    static void testBatch5() {
        
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id FROM Account]);
        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(accounts.keyset(), 0));
        test.stopTest();
    }
    @isTest
    static void testBatch6() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.CONTACT_SC;


        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(mode));
        test.stopTest();
    }
    @isTest
    static void testBatch7() {
        
        String soql = ACC_Segment_SVC.getSegmentFieldSoql('Account');
        List<Account> accounts =  (List<Account>) Database.query(soql);
        for(Account account:accounts){
            for(String segmentField:ACC_Segment_SVC.segmentFields){
                if(segmentField.containsIgnoreCase('Status')){
                    account.put(segmentField,'Active');
                } else {
                    account.put(segmentField,'Active Donor');
                }
            }
        }
        update accounts;    
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(accountMap.keyset(), 0));
        test.stopTest();
    }
    @isTest
    static void testBatch8() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.CONTACT_PSC;


        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(mode));
        test.stopTest();
    }
    @isTest
    static void testBatch9() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.ACCOUNT_ANNIV;


        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(mode));
        test.stopTest();
    }
    @isTest
    static void testBatch10() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.ACCOUNT_ALL;


        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(mode));
        test.stopTest();
    }
    @isTest
    static void testBatch11() {
        ACC_Segment_BATCH.modeType mode = ACC_Segment_BATCH.modeType.ACCOUNT_SC;


        test.startTest();
        Database.executeBatch(new ACC_Segment_BATCH(mode));
        test.stopTest();
    }
    @isTest
    static void testTrigger() {
    	List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
    	npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
    	th.Name = 'ACC_Segment_TDTM';
		th.npsp__Class__c = 'ACC_Segment_TDTM';
		th.npsp__Object__c = 'Account';
		th.npsp__Trigger_Action__c = 'BeforeInsert;AfterInsert;AfterUpdate;BeforeUpdate;';
		th.npsp__Active__c = true;
		th.npsp__Asynchronous__c = false;
		th.npsp__Load_Order__c = 1;
		triggerHandlers.add(th);

        String soql = ACC_Segment_SVC.getSegmentFieldSoql('Account');
        List<Account> accounts =  (List<Account>) Database.query(soql);
        test.startTest();
        update accounts;
        test.stopTest();
    }
    @isTest
    static void testTrigger2() {
    	List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
    	npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
    	th.Name = 'ACC_Segment_TDTM';
		th.npsp__Class__c = 'ACC_Segment_TDTM';
		th.npsp__Object__c = 'Account';
		th.npsp__Trigger_Action__c = 'BeforeInsert;AfterInsert;AfterUpdate;BeforeUpdate;';
		th.npsp__Active__c = true;
		th.npsp__Asynchronous__c = false;
		th.npsp__Load_Order__c = 1;
		triggerHandlers.add(th);
        
        ACC_Segment_UTIL.manualOverride = true;

        String soql = ACC_Segment_SVC.getSegmentFieldSoql('Account');
        List<Account> accounts =  (List<Account>) Database.query(soql);
        for(Account account:accounts){
           account.Mid_Level_Donor_Status__c = 'Former'; 
        }
        test.startTest();
        update accounts;
        test.stopTest();
    }

}
