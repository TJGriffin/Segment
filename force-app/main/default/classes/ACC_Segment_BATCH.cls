/**
* @author tj@tjgriffin.com
* @date 2022
* @group Rollups
* @description batch class that powers rollups
*/
public without sharing class ACC_Segment_BATCH implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	/**
	* @description the types of batches that can be run
	*/ 
	public Enum modeType {
		CONTACT_SC,  // daily run for contact soft credits
		CONTACT_PSC, // daily run for contact partial soft credits
		ACCOUNT_SC, // daily run for contact partial soft credits
		ACCOUNT_ALL, // run for all accounts
		ACCOUNT_ANNIV, // run for accounts on their anniversary dates
		ACCOUNT, // daily run for accounts
		ACCOUNT_PSC
	}

	/**
	* @description the mode to run the batch 
	*/ 
	public modeType mode;

	/**
	* @description count of failed records
	*/ 
	Integer failedCount;

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
    public ACC_Segment_BATCH(){
		this.isMissing = false;
		this.mode = modeType.ACCOUNT;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param void
	* @return void
	*/ 
    public ACC_Segment_BATCH(modeType mode){
		this.isMissing = false;
		this.mode = mode;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param void
	* @return void
	*/ 
    public ACC_Segment_BATCH(Boolean isMissing){
		this.isMissing = isMissing;
		this.mode = isMissing ? modeType.ACCOUNT_ALL : modeType.ACCOUNT;
    }
	/*******************************************************************************************************
	* @description constructor
	* @param accountIds the set of accountIds
	* @return void
	*/
    public ACC_Segment_BATCH(Set<Id> accountIds, modeType mode){
        this.accountIds = accountIds;
		this.isMissing = false;
		this.mode = mode;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param accountIds the set of accountIds
	* @return void
	*/
    public ACC_Segment_BATCH(Set<Id> accountIds, Integer failedCount, modeType mode){
        this.accountIds = accountIds;
		this.failedCount = failedCount;
		this.isMissing = false;
		this.mode = mode;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param accountIds the set of accountIds
	* @return void
	*/
    public ACC_Segment_BATCH(Set<Id> accountIds, Integer failedCount, Boolean isMissing, modeType mode){
        this.accountIds = accountIds;
		this.failedCount = failedCount;
		this.isMissing = isMissing;
		this.mode = mode;
    }

	/*******************************************************************************************************
	* @description constructor
	* @param accountIds the set of accountIds
	* @return void
	*/
    public ACC_Segment_BATCH(Set<Id> accountIds, Integer failedCount){
        this.accountIds = accountIds;
		this.failedCount = failedCount;
		this.isMissing = false;
		this.mode = modeType.ACCOUNT;
    }

	/*******************************************************************************************************
	* @description batch start method
	* @param BC batchable context
	* @return Querylocator the scope of the batch
	*/  	 
	public Database.QueryLocator start(Database.BatchableContext BC) {
		failedCount = failedCount == null ? 0 : failedCount;
		failedIds = new Set<Id>();
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
		Map<Id, Account> accounts = new Map<Id, Account>();
		switch on mode {
			when CONTACT_SC {
				for(OpportunityContactRole role:(List<OpportunityContactRole>) scope){
					Id accountId = role.Contact.AccountId;
					if(accountId != null)
						accounts.put(accountId, new Account(Id=accountId));
				}
			}
			when CONTACT_PSC,ACCOUNT_PSC {
				for(npsp__Partial_Soft_Credit__c psc:(List<npsp__Partial_Soft_Credit__c>) scope){
					Id accountId = psc.npsp__Contact__r.AccountId;
					if(accountId != null)
						accounts.put(accountId, new Account(Id=accountId));
				}
			}
			when ACCOUNT_SC {
				for(npsp__Account_Soft_Credit__c ascr:(List<npsp__Account_Soft_Credit__c>) scope){
					Id accountId = ascr.npsp__Account__c;
					if(accountId != null)
						accounts.put(accountId,new Account(Id=accountId));
				}
			}
			when else {
				accounts = new Map<Id, Account>((List<Account>) scope);
			}
		}
		
		ACC_Segment_SVC service = new ACC_Segment_SVC(accounts.values());

		if(service.failedIds != null)
			failedIds.addAll(service.failedIds);

    }
	/*******************************************************************************************************
	* @description batch finish method, writes out logs and kicks off next process in the chain
	* @param BC batchable context
	*/ 
	public void finish(Database.BatchableContext BC) {
		if(Test.isRunningTest())
			return;

		if(accountIds != null && accountIds.size()>0)
			return;
			
		switch on mode {
			when ACCOUNT {
				Database.executeBatch(new ACC_Segment_BATCH(modeType.ACCOUNT_ANNIV),50);
			}
			when ACCOUNT_ANNIV {
				Database.executeBatch(new ACC_Segment_BATCH(modeType.CONTACT_SC),50);
			}
			when CONTACT_SC {
				Database.executeBatch(new ACC_Segment_BATCH(modeType.CONTACT_PSC),50);
			}
			when CONTACT_PSC {
				Database.executeBatch(new ACC_Segment_BATCH(modeType.ACCOUNT_SC),50);
			}
			when else {
				failedCount++;
				if(failedIds.size()>0 && failedCount < 2)
					Database.executeBatch(new ACC_Segment_BATCH(failedIds,failedCount,mode),5);
			}
		}
    }
	
    /*******************************************************************************************************
	* @description batch finish method, writes out logs and kicks off next process in the chain
	* @param SC schedulable context
	*/ 
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new ACC_Segment_BATCH(),50);
    }

    /*******************************************************************************************************
	* @description gets the initial soql query based on the mode
	* @param SC schedulable context
	*/ 
	private String getSOQL() {
		String soql;
		switch on mode {
			when ACCOUNT, ACCOUNT_ALL, ACCOUNT_ANNIV, null {
				soql = 'SELECT Id, Major_Donor_Downgrade_Date__c, Mid_Level_Donor_Downgrade_Date__c, First_Recurring_Gift_Date__c, Last_Recurring_Gift_Date__c FROM Account';
			}
			when ACCOUNT_SC {
				soql = 'SELECT Id, npsp__Opportunity__c, npsp__Account__c FROM npsp__Account_Soft_Credit__c';
			}
			when CONTACT_SC {
				soql = 'SELECT ContactId, Contact.AccountId, Contact.Account.Major_Donor_Downgrade_Date__c, Contact.Account.Mid_Level_Donor_Downgrade_Date__c, Contact.Account.First_Recurring_Gift_Date__c, Contact.Account.Last_Recurring_Gift_Date__c FROM OpportunityContactRole';
			}
			when CONTACT_PSC,ACCOUNT_PSC {
				soql = 'SELECT npsp__Contact__c, npsp__Contact__r.AccountId, npsp__Contact__r.Account.Major_Donor_Downgrade_Date__c, npsp__Contact__r.Account.Mid_Level_Donor_Downgrade_Date__c FROM npsp__Partial_Soft_Credit__c';
			}

		}
		return soql;
    }

    /*******************************************************************************************************
	* @description gets the where caluse
	* @param soqlQuery
	* @param isMissing
	* @param accountIds
	* @return STRING
	*/ 
	private String getWhereClause(String soqlQuery, Boolean isMissing, Set<Id> accountIds) {
		switch on mode {
			when ACCOUNT,null {
				soqlQuery += soqlQuery.containsIgnoreCase('WHERE') ? ' AND ' : ' WHERE ';
				soqlQuery += 'ID IN (SELECT AccountId FROM Opportunity WHERE LastModifiedDate >= LAST_N_DAYS:2)';
			}
			when ACCOUNT_ALL {
				if(isMissing){
					soqlQuery += soqlQuery.containsIgnoreCase('WHERE') ? ' AND ' : ' WHERE ';
					soqlQuery += 'Donor_Segment__c = null';
				}
				if(accountIds != null && accountIds.size()>0){
					soqlQuery += soqlQuery.containsIgnoreCase('WHERE') ? ' AND ' : ' WHERE ';
					soqlQuery += 'Id IN:accountIds';
				}
			}
			when ACCOUNT_ANNIV {
				soqlQuery += soqlQuery.containsIgnoreCase('WHERE') ? ' AND ' : ' WHERE ';
				soqlQuery += 'Status_Anniversary__c = true';
			}
			when ACCOUNT_SC {
				soqlQuery += soqlQuery.containsIgnoreCase('WHERE') ? ' AND ' : ' WHERE ';
				soqlQuery +='LastModifiedDate >= Last_N_Days:2';
			}
			when CONTACT_SC,CONTACT_PSC{
				soqlQuery += soqlQuery.containsIgnoreCase('WHERE') ? ' AND ' : ' WHERE ';
				soqlQuery +='LastModifiedDate >= Last_N_Days:2';
			}
		}	
		return soqlQuery;
    }

}

