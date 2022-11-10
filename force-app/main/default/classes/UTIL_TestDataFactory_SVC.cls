public with sharing class UTIL_TestDataFactory_SVC {
    public static Map<Integer, String> countType {
        get{
            return new Map<Integer, String>{
                0 => 'Lapsed Major Donor',
                1 => 'Active Major Donor',
                2 => 'Lapsed Mid Level Donor',
                3 => 'Active Mid Level Donor',
                4 => 'Lapsed Donor',
                5 => 'Active Donor',
                6 => 'Lapsed Sustainer',
                7 => 'Active Sustainer',
                8 => 'Former Major Donor',
                9 => 'na',
                10 => 'na'
            };
        }
        set;
    }

    public static npe03__Recurring_Donation__c createNPSPRd(Id conId){
        return new npe03__Recurring_Donation__c(
            Name = conId,
            npe03__Contact__c = conId,
            npsp__Status__c = 'active',
            npe03__Date_Established__c = Date.today().addMonths(-12),
            npe03__Next_Payment_Date__c = Date.today().addDays(30),
            npe03__Amount__c = 100
        );
    }

}

