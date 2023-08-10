/**
* @author tj@tjgriffin.com
* @date 2022
* @group Rollups
* @description batch class that powers rollups
*/
public with sharing class OPP_Segment_BATCH implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	/**
	* @description a collection of Ids to run the rollup for
	*/  
	public List<String> suppressAccountNames {
		get {
			return ACC_Giving_SVC.supppressAccountNames;
		}
		set;
	}
	/**
	* @description a collection of Ids to run the rollup for
	*/  
    private Set<Id> failedIds;

	/**
	* @description a collection of Ids to run the rollup for
	*/  
    private Set<Id> accountIds;

	/**
	* @description only process missing segments
	*/  
    private Boolean isMissing;

	/*******************************************************************************************************
	* @description constructor
	* @param void
	* @return void
	*/ 
    public OPP_Segment_BATCH(){
		this.isMissing = false;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param void
	* @return void
	*/ 
    public OPP_Segment_BATCH(Boolean isMissing){
		this.isMissing = isMissing;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param accountIds the set of accountIds
	* @return void
	*/
    public OPP_Segment_BATCH(Set<Id> accountIds){
        this.accountIds = accountIds;
		this.isMissing = false;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param accountIds the set of accountIds
	* @return void
	*/
    public OPP_Segment_BATCH(Set<Id> accountIds, Boolean isMissing){
        this.accountIds = accountIds;
		this.isMissing = isMissing;
    }


	/*******************************************************************************************************
	* @description batch start method
	* @param BC batchable context
	* @return Querylocator the scope of the batch
	*/  	 
	public Database.QueryLocator start(Database.BatchableContext BC) {
        accountIds = accountIds == null ? new Set<Id>() : accountIds;
		failedIds = failedIds == null ? new Set<Id>() : failedIds;
		String soqlQuery = getSOQL();
		soqlQuery = getWhereClause(soqlQuery, isMissing, accountIds);

		
		return Database.getQueryLocator(soqlQuery);
    }

	/*******************************************************************************************************
	* @description batch execute method
	* @param BC batchable context
	* @param scope list of records to process
	*/ 
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
        failedIds.addAll(OPP_Segment_SVC.processOpportunities((List<Opportunity>) scope));
    }

	/*******************************************************************************************************
	* @description batch finish method, writes out logs and kicks off next process in the chain
	* @param BC batchable context
	*/ 
	public void finish(Database.BatchableContext BC) {
		if(Test.isRunningTest())
			return;

        if(failedIds.size()>0)
            Database.executeBatch(new OPP_Segment_BATCH(failedIds),10);
    }

    /*******************************************************************************************************
	* @description batch finish method, writes out logs and kicks off next process in the chain
	* @param SC schedulable context
	*/ 
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new OPP_Segment_BATCH(),50);
    }

    /*******************************************************************************************************
	* @description get soql string
	*/
    public static String getSoql(){
        String soql = 'SELECT Id,';
        soql+=' CloseDate,';
        soql+=' Amount,';
        soql+=' StageName,';
        soql+=' AccountId,';
        soql+=' npsp__Primary_Contact__r.AccountId';
        soql+=' FROM Opportunity';
        return soql;
    }

    /*******************************************************************************************************
	* @description get soql string
	*/
    public static String getWhereClause(String soqlQuery, Boolean isMissing, Set<Id> accountIds){
	   
       soqlQuery+=' WHERE ';
       if(accountIds.size() > 0){
            soqlQuery+='AccountId IN:accountIds AND ';
       }
       if(isMissing)
            soqlQuery+='Donor_Segment__c = null AND ';

        soqlQuery+=' IsWon=TRUE';
		soqlQuery+=' AND Amount > 0';
        soqlQuery+=' AND AccountId != null';
		soqlQuery+=' AND Account.Name NOT IN:supppressAccountNames';
        soqlQuery+=' ORDER BY AccountId ASC,CloseDate ASC';

        return soqlQuery;
        
    }
}
