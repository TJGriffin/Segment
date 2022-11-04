/**
* @author tj@tjgriffin.com
* @date 2022
* @group Rollups
* @description batch class that powers rollups
*/
public with sharing class ACC_Giving_BATCH implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	/**
	* @description a collection of Ids to run the rollup for
	*/  
    private Set<Id> accountIds;

	/**
	* @description start date to run the rollup for
	*/  
    private Date startDate;

	/**
	* @description start date to run the rollup for
	*/  
    private Boolean isAccount {
        get{
            return this.accountIds != null;
        }
        set;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param void
	* @return void
	*/ 
    public ACC_Giving_BATCH() {
        this.startDate = Date.today().addDays(-1);
    }

	/*******************************************************************************************************
	* @description constructor
	* @param startDate
	* @return void
	*/ 
    public ACC_Giving_BATCH(Date startDate) {
        this.startDate = startDate;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param startDate
	* @return void
	*/ 
    public ACC_Giving_BATCH(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }
	/*******************************************************************************************************
	* @description batch start method
	* @param BC batchable context
	* @return Querylocator the scope of the batch
	*/  	 
	public Database.QueryLocator start(Database.BatchableContext BC) {
        
		String soqlQuery = ACC_Giving_SVC.getBatchSoql(isAccount);
        String whereClause = ACC_Giving_SVC.getBatchWhereClause(startDate,accountIds);
		soqlQuery+=whereClause;
		
		return Database.getQueryLocator(soqlQuery);
    }

	/*******************************************************************************************************
	* @description batch execute method
	* @param BC batchable context
	* @param scope list of records to process
	*/ 
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
        ACC_Giving_SVC.processHistories(scope,isAccount);
    }

	/*******************************************************************************************************
	* @description batch finish method, writes out logs and kicks off next process in the chain
	* @param BC batchable context
	*/ 
	public void finish(Database.BatchableContext BC) {

    }

    /*******************************************************************************************************
	* @description batch finish method, writes out logs and kicks off next process in the chain
	* @param SC schedulable context
	*/ 
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new ACC_Segment_BATCH(),50);
    }
}
