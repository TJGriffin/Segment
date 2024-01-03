
@isTest
private class CON_Badge_TEST {
    @TestSetup
    static void makeData(){
        Map<Integer, String> countRoles = new Map<Integer, String>{
            0=>'Test'
        };

        Account acc = new Account(
            Name='The Trevor Project'
        );
        insert acc;

        Account conAcc = new Account(
            Name='contact household'
        );
        insert conAcc;

        List<Contact> cons = (List<Contact>) TestDataFactory.createSObjectList('Contact', 10, true);

        List<npe5__Affiliation__c> affs = new List<npe5__Affiliation__c>();
        Integer i=0;
        for(Contact con:cons){
            String status = i == 0 ? 'Former' : 'Current';
            affs.add(new npe5__Affiliation__c(
                npe5__Contact__c = con.Id,
                npe5__Organization__c = acc.Id,
                npe5__Role__c = 'Board Member',
                Type__c = 'Board Member',
                npe5__Status__c = status
            ));

            
            i++;
        }
        insert affs;


    }

    @isTest
    static void testController1() {
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id FROM Contact]);        

        List<npe5__Affiliation__c> formerAffs = [SELECT npe5__contact__c FROM npe5__Affiliation__c WHERE npe5__Status__c = 'Former'];
        List<String> badges = CON_Badge_CTRL.getCustomBadges(formerAffs[0].npe5__Contact__c);
        String badge = badges[0];
        system.assert(badge.contains('Former'));
        Set<String> uniqueBadges = CON_Badge_CTRL.getAffiliationBadges(contactMap.keyset());
        system.assert(uniqueBadges.size()>0);

    }
}