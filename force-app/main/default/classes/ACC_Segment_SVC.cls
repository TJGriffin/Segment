/**
* @author TJ Griffin
* @date 2022
* @group Segment
* @description service for managing segments
*/
public with sharing class ACC_Segment_SVC {

    public Date processDate {
        get;
        set {
            processDate = value;
            effectiveDate = processDate;
            firstDate = Date.newInstance(1950,1,1);
            extendedLapsedDate = value.addMonths(-24);
            lapsedDate = value.addMonths(-12);
            deepLapsedDate = value.addMonths(-60);
            lapsedSustainer = value.addDays(-60);
            deepLapsedSustainer = value.addDays(-365);
        }
    }

    /****
     * @description the effective date to run the segment process on
     */
    @TestVisible
    private Date effectiveDate;

    /****
     * @description the first date
     */
    @TestVisible
    private Date firstDate;

    /****
     * @description the extended lapsed date for the given effective date
     */
    @TestVisible
    private Date extendedLapsedDate;

    /****
     * @description the deep lasped date for the given effective date
     */
    @TestVisible
    private Date deepLapsedDate;

    /****
     * @description the lapsed date for the given effective date
     */
    @TestVisible
    private Date lapsedDate;

    /****
     * @description the sustainer lapsed date for the given effective date
     */
    @TestVisible
    private Date lapsedSustainer;

    /****
     * @description the deep sustainer lapsed date for the given effective date
     */
    @TestVisible
    private Date deepLapsedSustainer;

    /****
     * @description a collection of account ids to segment
     */
    public Map<Id, Account> accountMap {get;set;}

    /****
     * @description a collection of failed account ids
     */
    public Set<Id> failedIds;

    /****
     * @description map of a collection of GiftItems keyed by account id
     */
    Map<Id,List<GiftItem>> giftItemsByAccount {get;set;}

    public ACC_Segment_SVC(){
        this.processDate = Date.Today();
    }
	/*******************************************************************************************************
	* @description constructor
	* @param accounts
	********************************************************************************************************/
    public ACC_Segment_SVC(List<Account> accounts){
        this.processDate = Date.Today();
        ACC_Segment_UTIL.manualOverride = false;
        this.accountMap = new Map<Id, Account>(accounts);
        this.giftItemsByAccount = ACC_Giving_SVC.getGiftItems(this.accountMap.keyset(),true);
        
        this.processSegments();
        this.updateAccounts();
    }

	/*******************************************************************************************************
	* @description constructor
    *       This constructor is used when you want to calculate segments based on a date other than today
    *       for instance: when looking back at old opportunities
	* @param accounts
    * @param effectiveDate
	********************************************************************************************************/
    public ACC_Segment_SVC(List<Account> accounts, Date effectiveDate){
        this.processDate = effectiveDate;
        ACC_Segment_UTIL.manualOverride = false;
        this.accountMap = new Map<Id, Account>(accounts);
        this.giftItemsByAccount = ACC_Giving_SVC.getGiftItems(this.accountMap.keyset(),true, effectiveDate);
        
        this.processSegments();
    }
    /*******************************************************************************************************
	* @description processes accounts and contacts on before to set the Donor Segment
	* @param objs
    * @return void
	********************************************************************************************************/
    public void updateAccounts(){

        Set<Id> failures = new Set<Id>();

        try {
           List<Database.SaveResult> saveResults =  Database.update(this.accountMap.values(),false);
           for(Database.SaveResult saveResult:saveResults){
                if(!saveResult.isSuccess())
                    failures.add(saveResult.getId());
           }
        } catch(Exception e){
            system.debug(e.getMessage());
            failures.addAll(this.accountMap.keyset());
        }

        if(failures.size() > 0){
            this.failedIds = failures;
        }
    }	
    /*******************************************************************************************************
	* @description processes accounts and contacts on before to set the Donor Segment
	* @param objs
    * @return void
	********************************************************************************************************/
    public static List<SObject> processBefore(List<SObject> objs, List<SObject> oldObjs){
        Boolean isUpdate = oldObjs != null && oldObjs.size() > 0;
        Integer i=0;
        for(SObject obj:objs){
            String donorSegment = calculateDonorSegment(obj);
            obj.put('Donor_Segment__c',donorSegment);
            if(isUpdate){
                SObject oldObj = oldObjs[i];
                for(String fld:segmentFieldDates.keyset()){
                    String val = (String) obj.get(fld);
                    if(String.isNotBlank(val)){
                        String oldVal = (String) oldObj.get(fld);
                        if(oldVal == null || val != oldVal){
                            String dateField = segmentFieldDates.get(fld);
                            obj.put(dateField,Date.Today());
                            if(ACC_Segment_UTIL.manualOverride 
                                && val.containsIgnoreCase('Former') 
                                && downgradeFields.containsKey(fld)){
                                for(String downgradeFld:downgradeFields.get(fld)){
                                    if(downgradeFld.containsIgnoreCase('Date')){
                                        obj.put(downgradeFld,Date.Today());
                                    } else {
                                        obj.put(downgradeFld,UserInfo.getUserId());
                                    }
                                }
                            }
                        }
                    }
                }
            }
            i++;
        }
        return objs;
    }
    /*******************************************************************************************************
	* @description processes the heirarchy 
	* @param obj
    * @return String
	********************************************************************************************************/
    public static String calculateDonorSegment(SObject obj){
        String donorSegment;
        String majStatus = obj.isSet('Major_Donor_Status__c') ? (String) obj.get('Major_Donor_Status__c') : null;
        String midStatus = obj.isSet('Mid_Level_Donor_Status__c') ? (String) obj.get('Mid_Level_Donor_Status__c') : null;
        String susStatus = obj.isSet('Sustainer_Status__c') ? (String) obj.get('Sustainer_Status__c') : null;
        String donStatus = obj.isSet('Donor_Status__c') ? (String) obj.get('Donor_Status__c') : null;
        if(String.isBlank(majStatus) && String.isBlank(midStatus) && String.isBlank(susStatus) && String.isBlank(donStatus))
            return donorSegment;
        // build donor segment by evaluating up the heirarchy

        donorSegment = getDonorSegmentFromFieldValue('Donor_Status__c',donStatus);

        if(getLowerLevelStatusIsGreater(donStatus,susStatus)){
            if(getLowerLevelStatusIsGreater(donStatus,midStatus)){
                if(getLowerLevelStatusIsGreater(donStatus,majStatus)){
                    donorSegment =getDonorSegmentFromFieldValue('Donor_Status__c',donStatus);
                } else {
                    donorSegment = getDonorSegmentFromFieldValue('Major_Donor_Status__c',majStatus);
                }
            } else {
                donorSegment = getLowerLevelStatusIsGreater(midStatus,majStatus) ? getDonorSegmentFromFieldValue('Mid_Level_Donor_Status__c',midStatus) : getDonorSegmentFromFieldValue('Major_Donor_Status__c',majStatus);
            }

        } else if(getLowerLevelStatusIsGreater(susStatus,midStatus)){
            donorSegment = getLowerLevelStatusIsGreater(susStatus,majStatus) ? getDonorSegmentFromFieldValue('Sustainer_Status__c',susStatus) : getDonorSegmentFromFieldValue('Major_Donor_Status__c',majStatus);
        } else {
            donorSegment = getLowerLevelStatusIsGreater(midStatus,majStatus) ? getDonorSegmentFromFieldValue('Mid_Level_Donor_Status__c',midStatus) : getDonorSegmentFromFieldValue('Major_Donor_Status__c',majStatus);
        }
        return donorSegment;
    }

    /*******************************************************************************************************
	* @description processes accounts and contacts on before to set the Donor Segment
	* @param objs
    * @return void
	********************************************************************************************************/
    public static Boolean getLowerLevelStatusIsGreater(String lowerLevelStatus, String higherLevelStatus){
        Boolean lowerLevelStatusIsGreater = false;
        if(higherLevelStatus == null)
            return true;
        
        if(lowerLevelStatus == null)
            return false;

        if(higherLevelStatus == 'Active' || higherLevelStatus == 'Prospect')
            return false;
        
        if(lowerLevelStatus == 'Active' || lowerLevelStatus == 'Prospect')
            return true;
        
        if(lowerLevelStatus == 'Lapsed' && higherLevelStatus == 'Extended Lapsed')
            return true;

        if(lowerLevelStatus == 'Lapsed' && higherLevelStatus == 'Deep Lapsed')
            return true;

        if(lowerLevelStatus == 'Extended Lapsed' && higherLevelStatus == 'Deep Lapsed')
            return true;
        
        return lowerLevelStatusIsGreater;
    }
    /*******************************************************************************************************
	* @description sets segment values on the opportunity before insert
	* @param opps the opportunities to set the values for
    * @return List<Opportunity> the opps to set the values for
	********************************************************************************************************/
    public static List<Opportunity> processOpportunitiesBefore(List<Opportunity> opps){
        
        Set<Id> accountIds = new Set<Id>();

        for(Opportunity opp:opps){
            if(String.isNotBlank(opp.AccountId))
                accountIds.add(opp.AccountId);
        }
        String objectType = 'Account';
        String soql = getSegmentFieldSoql(objectType);
        soql+=' WHERE Id IN:accountIds';

        Map<Id,Account> accountMap = new Map<Id,Account>((List<Account>) database.query(soql));

        
        for(Opportunity opp:opps){

            if(String.isBlank(opp.AccountId))
                continue;

            Account acc = accountMap.get(opp.AccountId);

            // loop through the segment fields and set the values from the Account on the Opportunity
            for(String fld:segmentFields){
                String value = (String) acc.get(fld);
                opp.put(fld,value);
            }

        }

        return opps;
    }

    /*******************************************************************************************************
	* @description processes account segments in after update
	* @param accounts the list of accounts to object
    * @return contacts the list of contacts to update based on the account
	********************************************************************************************************/
    public static List<Contact> processAccountsAfter(List<Account> accounts){
        Map<Id,Account> accountMap = new Map<Id,Account>(accounts);
        Set<Id> accountIds = accountMap.keyset();
        String objectType = 'Contact';
        String soql = getSegmentFieldSoql(objectType);
        soql+=' WHERE AccountId IN:accountIds';

        List<Contact> contacts = new List<Contact>((List<Contact>) database.query(soql));
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact con:contacts){
            Account acc = accountMap.get(con.AccountId);
            Boolean isChange = false;
            for(String fld:segmentFields){
                String value = (String) acc.get(fld);
                String existingValue = (String) con.get(fld);
                if(value != existingValue)
                    isChange = true;
                con.put(fld,value);
            }
            for(String fld:segmentFieldDates.values()){
                Date value = acc.get(fld) != null ? (Date) acc.get(fld) : null;
                Date existingValue = con.get(fld) != null ? (Date) con.get(fld) : null;
                if(value != existingValue)
                    isChange = true;
                con.put(fld,acc.get(fld));
            }
            if(isChange)
                contactsToUpdate.add(con);
        }
        return contactsToUpdate;
    }

	/*******************************************************************************************************
	* @description determines segments for a given set of accounts
	* @param void
	* @return void
	********************************************************************************************************/
    public void processSegments(){
        ACC_Giving_CTRL.sortOrder = 'ASC';
        Map<Id,Account> updatedAccounts = new Map<Id, Account>();
        system.debug(this.giftItemsByAccount.keyset());
        for(Id accountId:this.accountMap.keyset()){
            
            Boolean isSustainer = false;
            Boolean isActiveSustainer = false;
            if(!this.giftItemsByAccount.containsKey(accountId))
                continue;

            List<giftItem> giftItems = this.giftItemsByAccount.get(accountId);
            giftItems.sort();
            Map<Date, Decimal> thresholdAmounts = getThresholdAmounts(giftItems);
            
            Map<String, GivingLevel> givingLevels = getGivingLevelFromThresholds(thresholdAmounts);

            if(givingLevels.size()>0){
                Account account = this.accountMap.get(accountId);
                account = calculateSoftCreditRollups(account,giftItems);
                for(String fieldName:givingLevels.keyset()){
                    // if there is a downgraded major or mid level status
                    // then we should not automatically set the status
                    if((fieldName.equalsIgnoreCase('Major_Donor_Status__c') 
                        && account.Major_Donor_Downgrade_Date__c != null)
                        ||
                        (fieldName.equalsIgnoreCase('Mid_Level_Donor_Status__c') 
                        && account.Mid_Level_Donor_Downgrade_Date__c != null))
                        continue;

                    GivingLevel lvl = givingLevels.get(fieldName);
                    account.put(fieldName,lvl.status);
                }
                if(account.First_Recurring_Gift_Date__c != null){
                    if((Date) account.Last_Recurring_Gift_Date__c > lapsedSustainer){
                        account.put('Sustainer_Status__c' ,'Active');
                        account.put('Sustainer_Status_Applied_Date__c',account.First_Recurring_Gift_Date__c);
                    } else if((Date)account.Last_Recurring_Gift_Date__c > deepLapsedSustainer){
                        account.put('Sustainer_Status__c' ,'Lapsed');
                        account.put('Sustainer_Status_Applied_Date__c',account.Last_Recurring_Gift_Date__c.addDays(60));
                    } else {
                        account.put('Sustainer_Status__c' ,'Deep Lapsed');
                        account.put('Sustainer_Status_Applied_Date__c',account.Last_Recurring_Gift_Date__c.addDays(90));
                    }
                }
                updatedAccounts.put(accountId,account);
            }

        }
        this.accountMap.putAll(updatedAccounts);
    }
	/*******************************************************************************************************
	* @description calculates rollup values for soft credits
	* @param account the account to calculate rollup values for 
    * @param giftItems the gift items to rollup
	* @return account
	********************************************************************************************************/
    public static Account calculateSoftCreditRollups(Account account,List<giftItem> giftItems){
        Date firstSoftCreditDate;
        Decimal firstSoftCreditAmount;
        Date lastSoftCreditDate;
        Decimal lastSoftCreditAmount;
        Integer numSoftCredits;
        Integer numSoftCreditsTY;
        Integer numSoftCreditsLY;
        Integer numSoftCredits2Y;
        Decimal softCredits;
        Decimal softCreditsTY;
        Decimal softCreditsLY;
        Decimal softCredits2Y;
        Boolean hasSoftCredits = false;
        Integer currentFY = ACC_Giving_SVC.currentFiscalYear;

        for(giftItem gi:giftItems){  
            Decimal amount = gi.softCreditAmount;
            Boolean isSoft = gi.isSoftCredit == null ? false : gi.isSoftCredit;
            isSoft = isSoft && amount > 0;
            Integer closeYear = gi.FiscalYear;
            if(closeYear==null)
                continue;
            if(isSoft){
                hasSoftCredits = true;
                numSoftCredits = numSoftCredits == null ? 0 : numSoftCredits;
                numSoftCredits++; 
                numSoftCreditsTY = numSoftCreditsTY == null ? 0 : numSoftCreditsTY;
                numSoftCreditsLY = numSoftCreditsLY == null ? 0 : numSoftCreditsLY;
                numSoftCredits2Y = numSoftCredits2Y == null ? 0 : numSoftCredits2Y;
                softCredits = softCredits == null ? 0 : softCredits;
                softCredits+=amount;

                lastSoftCreditDate = gi.closeDate;
                lastSoftCreditAmount = amount;

                if(firstsoftCreditAmount == null){
                    firstSoftCreditAmount = amount;
                    firstSoftCreditDate = gi.closeDate;
                }
                if(closeYear  == currentFY){
                    numSoftCreditsTY++;
                    softCreditsTY = softCreditsTY == null ? amount : softCreditsTY + amount;
                } else if(closeYear == (currentFY - 1)){
                    numSoftCreditsLY++;
                    softCreditsLY = softCreditsLY == null ? amount : softCreditsLY + amount;
                } else if(closeYear  == (currentFy - 2)){
                    numSoftCredits2Y++;
                    softCredits2Y = softCredits2Y == null ? amount : softCredits2Y + amount;
                }
            }
        }
        if(hasSoftCredits){
            account.first_Soft_Credit_Date__c = firstSoftCreditDate;
            account.First_Soft_Credit_Amount__c = firstSoftCreditAmount;
            account.Last_Soft_Credit_Date__c = lastSoftCreditDate;
            account.Last_Soft_Credit_Amount__c = lastSoftCreditAmount;
            account.Number_of_Soft_Credits__c = numSoftCredits;
            account.Total_Soft_Credits__c = softCredits;
            account.Number_of_Soft_Credits_This_Year__c = numSoftCreditsTY;
            account.Number_of_Soft_Credits_Last_Year__c = numSoftCreditsLY;
            account.Number_of_Soft_Credits_2_Years_Ago__c = numSoftCredits2y;
            account.Total_Soft_Credits_This_Year__c = softCreditsTY;
            account.Total_Soft_Credits_Last_Year__c = softCreditsLY;
            account.Total_Soft_Credits_2_Years_Ago__c = softCredits2Y;
        }

        return account;
    }


	/*******************************************************************************************************
	* @description gets a set of giving levels based on the threshold dates and amounts provided
    *   the giving levels are keyed by the fields that they are associated with
    *   -  Major_Donor_Status__c, Mid_LeveL_Donor_Status__c, Donor_Status__c and Sustainer_Status__c
    *   if the record's threshold date and amount data doesn't meet the thresholds for a specific status
    *   the field key that the status applies to won't be in the map
	* @param thresholdAmounts
	* @return Map<String, GivingLevel>
	********************************************************************************************************/
    public Map<String, GivingLevel> getGivingLevelFromThresholds(Map<Date, Decimal> thresholdAmounts){
        Map<String, GivingLevel> givingLevels = new Map<String, GivingLevel>();
        List<Date> dates = new List<Date>();
        Map<Date, Map<Decimal, givingLevel>> givingLevelByDateAndAmount =  getGivingLevelByDateAndAmount(firstDate,effectiveDate);
        dates.addAll(givingLevelByDateAndAmount.keyset());
        dates.sort();
        for(Date dt:dates){
            Decimal donorAmount = thresholdAmounts.containsKey(dt) ? thresholdAmounts.get(dt) : 0;
            for(Decimal minAmount:givingLevelByDateAndAmount.get(dt).keyset()){
                if(donorAmount >= minAmount){
                    GivingLevel lvl = givingLevelByDateAndAmount.get(dt).get(minAmount);
                    if(lvl.maxAmount == 0 || donorAmount <= lvl.maxAmount)
                        givingLevels.put(lvl.fieldName, lvl);
                }
            }
        }
        return givingLevels;
    }

	/*******************************************************************************************************
	* @description given a collection of GiftItems for a specific record, get the threshold amounts
    *   based on the cutoff dates of each threshold and the provided list of giftLevels
	* @param giftItems
	* @return Map<Date, Decimal>
	********************************************************************************************************/
    public Map<Date, Decimal> getThresholdAmounts(List<GiftItem> giftItems){
        Map<Date, Decimal> amountByDate = new Map<Date, Decimal>();
        amountByDate.put(firstDate,0);
        amountByDate.put(deepLapsedDate,0);
        amountByDate.put(extendedLapsedDate,0);
        amountByDate.put(lapsedDate,0);
        for(GiftItem giftItem:giftItems){
            if(giftItem.payments == null){
                Date giftDate = giftItem.lastReceivedDate == null ? giftItem.closeDate : giftItem.lastReceivedDate;
                Decimal giftAmount = giftItem.committedAmount;
                if(giftAmount == 0 || giftAmount == null || giftDate == null)
                    continue;

                if(giftDate >= firstDate && giftDate <deepLapsedDate){
                    amountByDate.put(firstDate,amountByDate.get(firstDate)+giftAmount);
                } else if(giftDate >= deepLapsedDate && giftDate < extendedLapsedDate){
                    amountByDate.put(deepLapsedDate,amountByDate.get(deepLapsedDate)+giftAmount);
                } else if(giftDate >= extendedLapsedDate && giftDate < lapsedDate){
                    amountByDate.put(extendedLapsedDate,amountByDate.get(extendedLapsedDate)+giftAmount);
                } else if(giftDate >= lapsedDate){
                    amountByDate.put(lapsedDate,amountByDate.get(lapsedDate)+giftAmount);
                }
            } else {
                for(giftPayment pmt:giftItem.payments){
                    if(pmt.paid){
                        Date giftDate = pmt.paymentDate;
                        Decimal giftAmount = pmt.amount;
                        if(giftAmount == 0 || giftAmount == null || giftDate == null){
                            continue;
                        }
                        if(giftDate >= firstDate && giftDate < deepLapsedDate){
                            amountByDate.put(firstDate,amountByDate.get(firstDate)+giftAmount);
                        } else if(giftDate >= deepLapsedDate && giftDate < extendedLapsedDate){
                            amountByDate.put(deepLapsedDate,amountByDate.get(deepLapsedDate)+giftAmount);
                        } else if(giftDate >= extendedLapsedDate && giftDate < lapsedDate){
                            amountByDate.put(extendedLapsedDate,amountByDate.get(extendedLapsedDate)+giftAmount);
                        } else if(giftDate >= lapsedDate){
                            amountByDate.put(lapsedDate,amountByDate.get(lapsedDate)+giftAmount);
                        }
                    }
                }
                
            }
        }

        return amountByDate;
    }

	/*******************************************************************************************************
	* @description a map for evaluating a collection of giftitems against the date and amount thresholds
    *   for the giving levels.  keyed by date, followed by amount and the associated givinglevel object
    *   TODO:  this should ultimately be backed by custom metadata
	* @param firstDate the first date 
    * @param effectiveDate the effective date to evaluate the giving levels by
	* @return Map<Date, Map<Decimal, givingLevel>>
	********************************************************************************************************/
    public static Map<Date, Map<Decimal, givingLevel>> getGivingLevelByDateAndAmount(Date firstDate, Date effectiveDate) {
        
        Map<Date, Map<Decimal, givingLevel>> givingLevelByDateAndAmount = new Map<Date, Map<Decimal, givingLevel>>();
        for(String levelName:statusRules.keyset()){
            Integer timeAgo;
            for(Integer times:statusRules.get(levelName).keyset()){
                timeAgo = times;
            }
            Decimal amountThreshold = statusRules.get(levelName).get(timeAgo);
            Decimal maxAmount = 0;
            if(levelName.contains('Mid')){
                maxAmount = 24999.99;
            } else {
                maxAmount = 0;
            }
            Integer daysAgo = levelName.contains('Sustainer') ? timeAgo : null;
            Integer monthsAgo = levelName.contains('Sustainer') ? null : timeAgo;
            givingLevel gl = new givingLevel(levelName,daysAgo,monthsAgo,amountThreshold,maxAmount,firstDate,effectiveDate);
            if(!givingLevelByDateAndAmount.containsKey(gl.dateThreshold))
                givingLevelByDateAndAmount.put(gl.dateThreshold, new Map<Decimal, givingLevel>());
            givingLevelByDateAndAmount.get(gl.dateThreshold).put(gl.amountThreshold,gl);
        }
        return givingLevelByDateAndAmount;
        
    }  

	/*******************************************************************************************************
	* @description givinglevel object
    *   TODO:  this should ultimately be backed by custom metadata
	********************************************************************************************************/
    public class givingLevel {
        public String levelName;
        public String status;
        public String fieldName;
        public String dateFieldName;
        public Date dateThreshold;
        public Decimal amountThreshold;
        public Decimal maxAmount;
        public Integer daysAgo;
        public Integer monthsAgo;

        public givingLevel(String levelName, Integer daysAgo, Integer monthsAgo, Decimal amtThreshold, Decimal maxAmount, Date firstDate, Date effectiveDate){
            this.levelName = levelName;
            this.amountThreshold = amtThreshold;
            this.maxAmount = maxAmount;
            this.status  = parseTypeAndStatusFromLevel(levelName,'status');
            String type = parseTypeAndStatusFromLevel(levelName,'type');

            switch on type {
                when 'Major Donor' {
                    this.fieldName = 'Major_Donor_Status__c';
                    this.dateFieldName = 'Major_Donor_Status_Applied_Date__c';
                    this.dateThreshold = monthsAgo == 0 ? firstDate : effectiveDate.addMonths(-(monthsAgo));
                }
                when 'Mid Level Donor' {
                    this.fieldName = 'Mid_Level_Donor_Status__c';
                    this.dateFieldName = 'Mid_Level_Donor_Status_Applied_Date__c';
                    this.dateThreshold = monthsAgo == 0 ? firstDate : effectiveDate.addMonths(-(monthsAgo));
                }
                when 'Donor' {
                    this.fieldName = 'Donor_Status__c';
                    this.dateFieldName = 'Donor_Status_Applied_Date__c';
                    this.dateThreshold = monthsAgo == 0 ? firstDate : effectiveDate.addMonths(-(monthsAgo));
                }
                when 'Sustainer' {
                    this.fieldName = 'Sustainer_Status__c';
                    this.dateThreshold = daysAgo == 0 ? firstDate : effectiveDate.addDays(-(daysAgo));
                }
            }
        }
    }
	/*******************************************************************************************************
	* @description the list of segment fields
    *   TODO:  this should ultimately be backed by custom metadata
	********************************************************************************************************/
    public static Map<String, String> segmentFieldDates {
        get {
            return new Map<String, String>{
                'Donor_Segment__c'=>'Donor_Segment_Applied_Date__c',
                'Major_Donor_Status__c'=>'Major_Donor_Status_Applied_Date__c',
                'Mid_Level_Donor_Status__c'=>'Mid_Level_Donor_Status_Applied_Date__c',
                'Donor_Status__c'=>'Donor_Status_Applied_Date__c',
                'Sustainer_Status__c'=>'Sustainer_Status_Applied_Date__c'
            };
        }
        set;
    }

	/*******************************************************************************************************
	* @description the list of segment fields
    *   TODO:  this should ultimately be backed by custom metadata
	********************************************************************************************************/
    public static List<String> segmentFields {
        get {
            return new List<String>{
                'Donor_Segment__c',
                'Major_Donor_Status__c',
                'Mid_Level_Donor_Status__c',
                'Sustainer_Status__c',
                'Donor_Status__c'
            };
        }
        set;
    }
	/********************************************************************************************************
	* @description status rules
    *   TODO:  this should ultimately be backed by custom metadata
	********************************************************************************************************/
    public static String getSegmentFieldSoql(String objectType){
        String soql = 'SELECT';
        soql+=' Id, ';
        if(objectType == 'Contact' || objectType == 'Opportunity')
            soql+=' AccountId, ';

        soql += String.join(segmentFields, ', ');
        
        if(objectType == 'Contact')
            soql += ', '+String.join(segmentFieldDates.values(), ', ');

        if(objectType == 'Contact' || objectType == 'Account')
            soql += ', Major_Donor_Downgrade_Date__c, Mid_Level_Donor_Downgrade_Date__c, First_Recurring_Gift_Date__c, Last_Recurring_Gift_Date__c';
            
        soql+=' FROM '+objectType;
        return soql;
    }

	/*******************************************************************************************************
	* @description gets the donor segment given a field name and a status from that field
    * @param fieldName the field name to evaluate
    * @param status the value of that field
    * @return String the corresponding donor segment
    *   TODO:  this should ultimately be backed by custom metadata
	********************************************************************************************************/
    public static String getDonorSegmentFromFieldValue(String fieldName, String status){
        if(String.isBlank(status))
            return null;

        String donorType;
        switch on fieldName {
            when 'Major_Donor_Status__c' {
                donorType = 'Major Donor';
            }
            when 'Mid_Level_Donor_Status__c' {
                donorType = 'Mid Level Donor';
            }
            when 'Sustainer_Status__c' {
                donorType = 'Sustainer';
            }
            when 'Donor_Status__c' {
                donorType = 'Donor';
            }
        }
        return status.contains('Prospect') ? donorType + ' '+ status.trim() : status.trim()+' '+donorType;
    }
	/*******************************************************************************************************
	* @description status rules
    *   TODO:  this should ultimately be backed by custom metadata
	********************************************************************************************************/
    public static Map<String, List<String>> downgradeFields {
        get {
            return new Map<String, List<String>>{
                'Major_Donor_Status__c' => new List<String>{
                    'Major_Donor_Downgrade_Date__c',
                    'Major_Donor_Downgrade_By__c'
                },
                'Mid_Level_Donor_Status__c' => new List<String>{
                    'Mid_Level_Donor_Downgrade_Date__c',
                    'Mid_Level_Donor_Downgrade_By__c'
                }
            };
        }
        set;
    }
	/*******************************************************************************************************
	* @description status rules
    *   TODO:  this should ultimately be backed by custom metadata
	********************************************************************************************************/
    public static Map<String, Map<Integer, Decimal>> statusRules {
        get {
            return new Map<String, Map<Integer, Decimal>>{
                'Active Major Donor' => new Map<Integer, Decimal>{
                    12 => 25000.0
                },
                'Active Mid Level Donor' => new Map<Integer, Decimal>{
                    12 => 1000.0
                },
                'Active Donor' => new Map<Integer, Decimal>{
                    12 => .01
                },
                'Lapsed Major Donor' => new Map<Integer, Decimal>{
                    24 => 25000.0
                },
                'Lapsed Mid Level Donor' => new Map<Integer, Decimal>{
                    24 => 1000.0
                },
                'Lapsed Donor' => new Map<Integer, Decimal>{
                    24 => .01
                },
                'Extended Lapsed Major Donor' => new Map<Integer, Decimal>{
                    60 => 25000.0
                },
                'Extended Lapsed Mid Level Donor' => new Map<Integer, Decimal>{
                    60 => 1000.0
                },
                'Extended Lapsed Donor' => new Map<Integer, Decimal>{
                    60 => .01
                },
                'Deep Lapsed Major Donor' => new Map<Integer, Decimal>{
                    0 => 25000.0
                },
                'Deep Lapsed Mid Level Donor' => new Map<Integer, Decimal>{
                    0 => 1000.0
                },
                'Deep Lapsed Donor' => new Map<Integer, Decimal>{
                    0 => .01
                }
            };
        }
        set;
    }

	/*******************************************************************************************************
	* @description get type and status from level name
    *  
	********************************************************************************************************/
    public static String parseTypeAndStatusFromLevel(String levelName, String type){
        List<String> statuses = new List<String>();

        Schema.DescribeFieldResult fieldResult = Account.Donor_Status__c.getDescribe();
        for(Schema.PicklistEntry ple:fieldResult.getPicklistValues()){
            statuses.add(ple.getValue());
        }
        String returnValue;
        for(String status:statuses){
            if(levelName.contains(status)){
                String level = levelName.contains('Prospect') ? levelName.split(status)[0].trim() : levelName.split(status)[1].trim();
                returnValue = type == 'status' ? status : level;
            }
        }
        return returnValue;

    }
}
