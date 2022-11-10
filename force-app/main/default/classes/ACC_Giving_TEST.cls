
@isTest
private class ACC_Giving_TEST {
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
            npsp__Status__c = 'Active'
        ));
        rds.add(new npe03__Recurring_Donation__c(
            npe03__Contact__c = cons[7].Id,
            npe03__Amount__c = 10,
            npe03__Date_Established__c = Date.Today().addYears(-4),
            npe03__Open_Ended_Status__c = 'Closed',
            npe03__Installments__c = 24,
            npsp__Status__c = 'Lapsed'
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
            StageName = 'Posted',
            Name='Partial Soft Credit Opp'
        );
        insert pscOpp;

        // add soft credits
        Opportunity scOpp = new Opportunity(
            Amount = 25,
            CloseDate = Date.today().addMonths(-10),
            AccountId = acc.Id,
            StageName = 'Posted',
            Name='Full Soft Credit Opp'
        );
        insert scOpp;

        // add soft credits
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
        Map<Integer, String> types = UTIL_TestDataFactory_SVC.countType;

        ascs.add(new npsp__Account_Soft_Credit__c(
            npsp__Account__c = acc.Id,
            npsp__Amount__c = 500,
            npsp__Opportunity__c = ascOpp.Id,
            npsp__Role__c = 'Donation Source'
        ));
        
        opps.clear();

        Integer i=0;
        for(Contact con:cons){
            String type = types.containsKey(i) ? types.get(i) : 'na';
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
                opp.StageName = 'Posted';
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
            if(type.containsIgnoreCase('Active')){
                pscs.add(new npsp__Partial_Soft_credit__c(
                    npsp__Contact__c = con.Id,
                    npsp__Opportunity__c = pscOpp.Id,
                    npsp__Amount__c = 25,
                    npsp__Role_Name__c = 'Soft Credit'
                ));
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
    static void testService() {
        List<npe03__Recurring_Donation__c> rds = [SELECT npe03__Contact__c, npe03__Contact__r.AccountId FROM npe03__Recurring_Donation__c];

        Id accId = ACC_Giving_SVC.getAccountIdFromRecordId(rds[0].npe03__Contact__c);
        system.assertEquals(accId,rds[0].npe03__Contact__r.AccountId);

        Set<Id> contactIds = ACC_Giving_SVC.getContactIdsForAccount(accId);
        system.assert(contactIds.size()>0);


    }
    @isTest
    static void testRecurringGiftItem() {
        String soql = ACC_Giving_SVC.getOpportunitySoql();

        List<GiftItem> gis = new List<GiftItem>();
        test.startTest();
        for(Opportunity opp:(List<Opportunity>)database.query(soql)){
            Boolean isRecurring = String.isNotBlank(opp.npe03__Recurring_Donation__c);
            gis.add(new GiftItem(opp,isRecurring));
        
        }
        test.stopTest();


    }
    @isTest
    static void testController() {

        List<GiftItem> gis = new List<GiftItem>();
        List<AnnualGiftHistory> agh = new List<AnnualGiftHistory>();
        test.startTest();
        for(Contact con:[SELECT Id FROM Contact LIMIT 5]){
            gis.clear();
            agh.clear();
            gis = ACC_Giving_CTRL.getGiftItems(con.Id,true);
            agh = ACC_Giving_CTRL.getGiftHistory(con.Id);
        }
        test.stopTest();
    }
    @isTest
    static void testController2() {

        List<GiftItem> gis = new List<GiftItem>();
        List<AnnualGiftHistory> agh = new List<AnnualGiftHistory>();
        test.startTest();
        for(Contact con:[SELECT Id FROM Contact WHERE LastName LIKE '%Sustainer%']){
            gis.clear();
            agh.clear();
            gis = ACC_Giving_CTRL.getGiftItems(con.Id,true);
            agh = ACC_Giving_CTRL.getGiftHistory(con.Id);
        }
        test.stopTest();
    }
    @isTest
    static void testController3() {

        List<GiftItem> gis = new List<GiftItem>();
        List<AnnualGiftHistory> agh = new List<AnnualGiftHistory>();
        test.startTest();
        for(Account acc:[SELECT Id FROM Account]){
            gis.clear();
            agh.clear();
            gis = ACC_Giving_CTRL.getGiftItems(acc.Id,true);
            agh = ACC_Giving_CTRL.getGiftHistory(acc.Id,false);
        }
        test.stopTest();
    }
    @isTest
    static void testController4() {

        List<GiftItem> gis = new List<GiftItem>();
        List<AnnualGiftHistory> agh = new List<AnnualGiftHistory>();
        test.startTest();
        for(Contact con:[SELECT Id FROM Contact LIMIT 5]){
            gis.clear();
            agh.clear();
            gis = ACC_Giving_CTRL.getGiftItems(con.Id,false);
            agh = ACC_Giving_CTRL.getGiftHistory(con.Id);
        }
        test.stopTest();
    }
    @isTest
    static void testBatch1() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id FROM Account]);
        test.startTest();
        database.executeBatch(new ACC_Giving_BATCH(accountMap.keyset()));
        test.stopTest();

        List<AnnualGiftHistory__c> agh = [SELECT Id FROM AnnualGiftHistory__c];
        system.assert(agh.size()>0);

    }
    @isTest
    static void testBatch2() {

        Date startDate = Date.today().addDays(-20);
        test.startTest();
        database.executeBatch(new ACC_Giving_BATCH(startDate));
        test.stopTest();

        List<AnnualGiftHistory__c> agh = [SELECT Id FROM AnnualGiftHistory__c];
        system.assert(agh.size()>0);
    }
    @isTest
    static void testBatch3() {

        test.startTest();
        database.executeBatch(new ACC_Giving_BATCH());
        test.stopTest();

        List<AnnualGiftHistory__c> agh = [SELECT Id FROM AnnualGiftHistory__c];
        system.assert(agh.size()>0);
    }
}