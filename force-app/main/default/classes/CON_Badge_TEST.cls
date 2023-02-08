
@isTest
private class CON_Badge_TEST {
    @TestSetup
    static void makeData(){
        Map<Integer, String> countRoles = new Map<Integer, String>{
            0=>'Test'
        };

        Account acc = new Account(
            Name='Foundation'
        );
        insert acc;

        List<Contact> cons = (List<Contact>) TestDataFactory.createSObjectList('Contact', 10, true);
        List<npe5__Affiliation__c> affs = new List<npe5__Affiliation__c>();
        Integer i=0;
        for(Contact con:cons){
            
            affs.add(new npe5__Affiliation__c(
                npe5__Contact__c = con.Id,
                npe5__Organization__c = acc.Id,
                trac_Role__c = 'Board Member',
                npe5__Status__c = 'Current'
            ));
            
            i++;
        }
        insert affs;


    }

    @isTest
    static void testController1() {
        List<Id> contactIds = new List<Id>();
        for(npe5__Affiliation__c aff:[SELECT Id,npe5__Contact__c FROM npe5__Affiliation__c]){
            contactIds.add(aff.npe5__Contact__c);
        }
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id FROM Contact]);
        List<String> badges = CON_Badge_CTRL.getCustomBadges(contactIds[0]);
        Set<String> uniqueBadges = CON_Badge_CTRL.getAffiliationBadges(contactMap.keyset());


    }
}