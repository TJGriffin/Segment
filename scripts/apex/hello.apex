// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

Id recordId = '0013o00002aYfWNAA0';
Set<Id> accountIds = new Set<Id>{recordId};
List<String> softCreditRoles = ACC_Giving_SVC.softCreditRoles;
system.debug(JSON.serialize(ACC_Giving_CTRL.getGiftItems(recordId,true)));
Map<Id, List<OpportunityContactRole>> croleListMap = ACC_Giving_SVC.getSoftCreditsFromAccountIds(accountIds);
system.debug(croleListMap.size());
        String soqlQuery = ACC_Giving_SVC.getSoftCreditSoql();
        soqlQuery+=ACC_Giving_SVC.getSoftCreditWhereClause(accountIds);

        system.debug(database.query(soqlQuery));