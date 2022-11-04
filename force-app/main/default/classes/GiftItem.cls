/*******************************************************************************************************
* @description wrapper class to collect annual gift history
*/
public class GiftItem implements Comparable {
		/**
		* @description Id of threcord
		*/
		@auraEnabled public Id recordId {get;set;}

		/**
		* @description Id of threcord
		*/
		@auraEnabled public Id opportunityId {get;set;}				
		/*******************************************************************************************************
		* @description date of the gift
		*/
		@auraEnabled public Date closeDate {get;set;}
		/*******************************************************************************************************
		* @description date of the gift
		*/
		@auraEnabled public Date lastReceivedDate {get;set;}

		/*******************************************************************************************************
		* @description date of the gift
		*/
		@auraEnabled public String link {
			get {
				return '/'+opportunityId;
			}
			set;
		}
		
		/*******************************************************************************************************
		* @description total hard credits
		*/
		@auraEnabled public Decimal hardCreditAmount { get; set; }
		
		/*******************************************************************************************************
		* @description total soft credits
		*/
		@auraEnabled public Decimal softCreditAmount { get; set; }
		
		/*******************************************************************************************************
		* @description total soft credits
		*/
		@auraEnabled public Boolean isSoftCredit { 
				get {
					return softCreditAmount > 0;
				} 
				set; 
			}
				
		/*******************************************************************************************************
		* @description total pledged amount still outstanding
		*/
		@auraEnabled public Decimal pledgedAmountOutstanding { get; set; }
		
		/*******************************************************************************************************
		* @description hard credit + soft credit - pledged amount outstanding
		*/
		@auraEnabled public Decimal totalAmount { get; set; }
		
		/*******************************************************************************************************
		* @description hard credit + soft credit - pledged amount outstanding
		*/
		@auraEnabled public String accountName { get; set; }
		
		/*******************************************************************************************************
		* @description hard credit + soft credit - pledged amount outstanding
		*/
		@auraEnabled public Id accountId { get; set; }
				
		/*******************************************************************************************************
		* @description whether or not the gift is won
		*/
		@auraEnabled public Boolean IsWon { get; set; }
		/*******************************************************************************************************
		* @description whether or not the gift is won
		*/
		@auraEnabled public Boolean IsClosed { get; set; }
				
		/*******************************************************************************************************
		* @description whether or not the gift is won
		*/
		@auraEnabled public Boolean IsRecurring { get; set; }
				
		/*******************************************************************************************************
		* @description whether or not the gift is won
		*/
		@auraEnabled public Boolean IsPmt { get; set; }

		/*******************************************************************************************************
		* @description the Stage of the Gift
		*/
		@auraEnabled public String StageName{ get; set; }

		/*******************************************************************************************************
		* @description the Stage of the Gift
		*/
		@auraEnabled public String campaignName { get; set; }

		/*******************************************************************************************************
		* @description the Stage of the Gift
		*/
		@auraEnabled public String recordType{ get; set; }

		/*******************************************************************************************************
		* @description the Stage of the Gift
		*/
		@auraEnabled public Decimal oppAmount { get; set; }

		/*******************************************************************************************************
		* @description the Name of the Gift
		*/
		@auraEnabled public String Name { get; set; }


        public GiftItem(Opportunity opp, Boolean isRecurring){
            this.isPmt = false;
            this.isRecurring = isRecurring;
            this.StageName = opp.StageName;
            this.recordId = opp.Id;
			this.opportunityId = opp.Id;
            this.oppAmount = opp.Amount;
            this.Name = opp.Name;
            this.closeDate = opp.CloseDate;
            this.hardCreditAmount =  calculateAmount('won', opp.Amount, 0, opp.StageName, opp.IsWon, opp.IsClosed);
            this.softCreditAmount = 0;
            this.pledgedAmountOutstanding = calculateAmount('pledged', opp.Amount, 0, opp.StageName, opp.IsWon, opp.IsClosed); 
            this.TotalAmount = this.HardCreditAmount; 
            this.IsWon = opp.IsWon;
            this.IsClosed = opp.IsClosed;
            this.lastReceivedDate = opp.CloseDate;
            this.campaignName = opp.Campaign.Name;
            this.accountName = opp.Account.Name;
            this.accountId = opp.AccountId;
            this.recordType = isRecurring ? 'Recurring Donation' : opp.RecordType.Name;
        }

        public GiftItem(Opportunity opp, npe01__OppPayment__c pmt){
            this.isPmt = true;
            this.isRecurring = false;
            this.closeDate = opp.CloseDate;
            this.lastReceivedDate = pmt.npe01__Paid__c ? pmt.npe01__Payment_Date__c : null;
            this.HardCreditAmount = calculateAmount('won',pmt);
            this.SoftCreditAmount = 0;
            this.pledgedAmountOutstanding = 0;
            this.campaignName = opp.Campaign.Name;
            this.TotalAmount = this.HardCreditAmount;
            this.IsWon = pmt.npe01__Paid__c;
            this.IsClosed = opp.IsClosed;
            this.oppAmount = opp.Amount;
            this.Name = opp.Name;
            this.recordType = opp.RecordType.Name;
            this.recordId= pmt.Id;
			this.opportunityId = opp.Id;
            this.StageName = opp.StageName;
        }

        public GiftItem(OpportunityContactRole cRole){
			this.isPmt = false;
			this.recordId = crole.OpportunityId;
			this.opportunityId = crole.OpportunityId;
			this.isRecurring = false;
			this.closeDate = crole.Opportunity.CloseDate;
            this.lastReceivedDate  = crole.Opportunity.CloseDate;
			this.HardCreditAmount = 0;
			this.SoftCreditAmount = calculateAmount('won', crole.Opportunity.Amount, crole.Opportunity.npe01__Amount_Outstanding__c, crole.Opportunity.StageName, crole.Opportunity.IsWon, crole.Opportunity.IsClosed);
			this.pledgedAmountOutstanding = crole.Opportunity.npe01__Amount_Outstanding__c;
			this.TotalAmount = this.SoftCreditAmount;
            this.oppAmount = crole.Opportunity.Amount;
			this.IsWon = crole.Opportunity.IsWon;
            this.campaignName = crole.Opportunity.Campaign.Name;
			this.IsClosed = crole.Opportunity.IsClosed;
			this.Name = crole.Opportunity.Name;
			this.StageName = crole.Opportunity.StageName;
            this.recordType = crole.Opportunity.RecordType.Name;
        }

        public GiftItem(npsp__Partial_Soft_Credit__c psc){
			this.isPmt = false;
			this.recordId = psc.npsp__Opportunity__c;
			this.opportunityId = psc.npsp__Opportunity__c;
			this.isRecurring = false;
			this.closeDate = psc.npsp__Opportunity__r.CloseDate;
            this.lastReceivedDate  = psc.npsp__Opportunity__r.CloseDate;
			this.HardCreditAmount = 0;
			this.SoftCreditAmount = calculateAmount('won', psc.npsp__Amount__c, psc.npsp__Opportunity__r.npe01__Amount_Outstanding__c, psc.npsp__Opportunity__r.StageName, psc.npsp__Opportunity__r.IsWon, psc.npsp__Opportunity__r.IsClosed);
			this.pledgedAmountOutstanding = psc.npsp__Opportunity__r.npe01__Amount_Outstanding__c;
			this.TotalAmount = this.SoftCreditAmount;
            this.oppAmount = psc.npsp__Opportunity__r.Amount;
			this.IsWon = psc.npsp__Opportunity__r.IsWon;
			this.IsClosed = psc.npsp__Opportunity__r.IsClosed;
			this.Name = psc.npsp__Opportunity__r.Name;
            this.campaignName = psc.npsp__Opportunity__r.Campaign.Name;
			this.StageName = psc.npsp__Opportunity__r.StageName;
            this.recordType = psc.npsp__Opportunity__r.RecordType.Name;
        }

        public GiftItem(npsp__Account_Soft_Credit__c ascr){
			this.isPmt = false;
			this.recordId = ascr.npsp__Opportunity__c;
			this.opportunityId = ascr.npsp__Opportunity__c; 
			this.isRecurring = false;
			this.closeDate = ascr.npsp__Opportunity__r.CloseDate;
            this.lastReceivedDate  = ascr.npsp__Opportunity__r.CloseDate;
			this.HardCreditAmount = 0;
			this.SoftCreditAmount = calculateAmount('won', ascr.npsp__Amount__c, ascr.npsp__Opportunity__r.npe01__Amount_Outstanding__c, ascr.npsp__Opportunity__r.StageName, ascr.npsp__Opportunity__r.IsWon, ascr.npsp__Opportunity__r.IsClosed);
			this.pledgedAmountOutstanding = ascr.npsp__Opportunity__r.npe01__Amount_Outstanding__c;
			this.TotalAmount = this.SoftCreditAmount;
            this.oppAmount = ascr.npsp__Opportunity__r.Amount;
			this.IsWon = ascr.npsp__Opportunity__r.IsWon;
			this.IsClosed = ascr.npsp__Opportunity__r.IsClosed;
			this.Name = ascr.npsp__Opportunity__r.Name;
            this.campaignName = ascr.npsp__Opportunity__r.Campaign.Name;
			this.StageName = ascr.npsp__Opportunity__r.StageName;
            this.recordType = ascr.npsp__Opportunity__r.RecordType.Name;
        }

		
		public Integer compareTo(Object compObj) {
			String sortOrder = ACC_Giving_CTRL.sortOrder;
			GiftItem giComp = (GiftItem) compObj;
			if(sortOrder == 'DESC'){
				return this.closeDate < giComp.closeDate ? 1 : -1; 
			} else {
				return this.closeDate > giComp.closeDate ? 1 : -1; 
			}
		}

        public static Decimal calculateAmount(String calcType, Decimal CloseAmount, Decimal Outstanding, String Stage, Boolean isWon, Boolean isClosed) {
            Decimal Amount = 0;
            if(calcType=='won') {
                if(isWon && isClosed) {
                    if(Outstanding==null || Outstanding==0) {
                        Amount = CloseAmount;
                    } else {
                        Amount = CloseAmount - Outstanding;
                    }
                } else {
                    if(Outstanding==null || Outstanding==0) {
                        Amount = 0;
                    } else {
                        Amount = CloseAmount - Outstanding;
                    }
                }
            } else if(calcType=='pledged') {
                if(isWon && isClosed) {
                    if(Outstanding==null || Outstanding==0) {
                        Amount = 0;
                    } else {
                        Amount = Outstanding;
                    }
                } else {
                    if(Outstanding==null || Outstanding==0) {
                        Amount = CloseAmount;
                    } else {
                        Amount = Outstanding;
                    }
                }
            } else if(calcType=='lost') {
                if(isClosed && !isWon) {
                    Amount = CloseAmount;
                }
            }
            
            return Amount;
        }
        public static Decimal calculateAmount(String calcType, npe01__OppPayment__c pmt) {
            Decimal Amount = 0;
            if(calcType=='won') {
                if(pmt.npe01__Paid__c) {
                    Amount = pmt.npe01__Payment_Amount__c;
                }
            } else if(calcType=='pledged') {
                if(!pmt.npe01__Paid__c) {
                    Amount = pmt.npe01__Payment_Amount__c;
                }
            } else if(calcType=='lost') {
                if(!pmt.npe01__Paid__c) {
                    Amount = pmt.npe01__Payment_Amount__c;
                }
            }
            
            return Amount;
        }
	}
