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
		* @description fiscal year
		*/
		@auraEnabled public Integer fiscalYear {get;set;}

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
		@auraEnabled public Decimal uncommittedAmount { get; set; }

		/*******************************************************************************************************
		* @description hard credit + soft credit - pledged amount outstanding
		*/
		@auraEnabled public Decimal writtenOffAmount { get; set; }

		/*******************************************************************************************************
		* @description hard credit + soft credit - pledged amount outstanding
		*/
		@auraEnabled public Decimal committedAmount { 
			get {
				Decimal totAmt = totalAmount == null ? 0 : totalAmount;
				Decimal writeOff = writtenOffAmount == null ? 0 : writtenOffAmount;
				return totAmt - writeOff;
			}
			set; 
		}
		/*******************************************************************************************************
		* @description hard credit + soft credit - pledged amount outstanding
		*/
		@auraEnabled public Decimal receivedAmount { get; set; }
		/*******************************************************************************************************
		* @description hard credit + soft credit - pledged amount outstanding
		*/
		@auraEnabled public Decimal lostAmount { get; set; }

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

		/*******************************************************************************************************
		* @description the Name of the Gift
		*/
		@auraEnabled public List<giftPayment> payments { get; set; }


        public GiftItem(Opportunity opp, Boolean isRecurring){
            this.isPmt = false;
            this.isRecurring = isRecurring;
            this.StageName = opp.StageName;
            this.recordId = opp.Id;
			this.opportunityId = opp.Id;
            this.oppAmount = opp.Amount;
            this.Name = opp.Name;
            this.closeDate = opp.CloseDate;
			this.fiscalYear = opp.FiscalYear;
            this.hardCreditAmount =  calculateAmount('won', opp);
			this.uncommittedAmount =  calculateAmount('uncommitted', opp);
			this.receivedAmount = calculateAmount('received',opp);
			this.lostAmount =  calculateAmount('lost', opp);
			this.writtenOffAmount = calculateAmount('writtenoff',opp);
            this.softCreditAmount = 0;
            this.pledgedAmountOutstanding = calculateAmount('pledged', opp); 
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
			this.fiscalYear = opp.FiscalYear;
            this.lastReceivedDate = pmt.npe01__Paid__c ? pmt.npe01__Payment_Date__c : null;
            this.HardCreditAmount = calculateAmount('won',opp, pmt);
			this.uncommittedAmount = calculateAmount('uncommitted',opp, pmt);
			this.lostAmount = calculateAmount('lost',opp, pmt);
			this.receivedAmount = calculateAmount('received',opp, pmt);
			this.writtenOffAmount = calculateAmount('writtenoff',opp,pmt);
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
			giftPayment gPayment = new giftPayment(pmt);
			this.payments = new List<giftPayment>{gPayment};
        }

        public GiftItem(OpportunityContactRole cRole){
			this.isPmt = false;
			this.recordId = crole.OpportunityId;
			this.opportunityId = crole.OpportunityId;
			this.isRecurring = false;
			this.closeDate = crole.Opportunity.CloseDate;
			this.fiscalYear = crole.Opportunity.fiscalYear;
            this.lastReceivedDate  = crole.Opportunity.CloseDate;
			this.HardCreditAmount = 0;
			//this.SoftCreditAmount = calculateAmount('won', crole.Opportunity.Amount, crole.Opportunity.npe01__Amount_Outstanding__c, crole.Opportunity.StageName, crole.Opportunity.IsWon, crole.Opportunity.IsClosed);
			//this.pledgedAmountOutstanding = crole.Opportunity.npe01__Amount_Outstanding__c;
            this.oppAmount = crole.Opportunity.Amount;
			this.softCreditAmount = calculateAmount('won',crole);
			this.pledgedAmountOutstanding = calculateAmount('pledged',crole);
			this.uncommittedAmount = calculateAmount('uncommitted',crole);
			this.receivedAmount = calculateAmount('received',crole);
			this.lostAmount = calculateAmount('lost',crole);
			this.writtenOffAmount = calculateAmount('writtenoff',crole);
			this.totalAmount = this.softCreditAmount;
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
			this.fiscalYear = psc.npsp__Opportunity__r.FiscalYear;
            this.lastReceivedDate  = psc.npsp__Opportunity__r.CloseDate;
			this.HardCreditAmount = 0;
			//this.SoftCreditAmount = calculateAmount('won', psc.npsp__Amount__c, psc.npsp__Opportunity__r.npe01__Amount_Outstanding__c, psc.npsp__Opportunity__r.StageName, psc.npsp__Opportunity__r.IsWon, psc.npsp__Opportunity__r.IsClosed);
			this.softCreditAmount = calculateAmount('won',psc);
			this.pledgedAmountOutstanding = calculateAmount('pledged',psc);
			this.uncommittedAmount = calculateAmount('uncommitted',psc);
			this.receivedAmount = calculateAmount('received',psc);
			this.lostAmount = calculateAmount('lost',psc);
			this.writtenOffAmount = calculateAmount('writtenoff',psc);
			//this.pledgedAmountOutstanding = psc.npsp__Opportunity__r.npe01__Amount_Outstanding__c;
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
			this.fiscalYear = ascr.npsp__Opportunity__r.FiscalYear;
            this.lastReceivedDate  = ascr.npsp__Opportunity__r.CloseDate;
			this.HardCreditAmount = 0;
			//this.SoftCreditAmount = calculateAmount('won', ascr.npsp__Amount__c, ascr.npsp__Opportunity__r.npe01__Amount_Outstanding__c, ascr.npsp__Opportunity__r.StageName, ascr.npsp__Opportunity__r.IsWon, ascr.npsp__Opportunity__r.IsClosed);
			//this.pledgedAmountOutstanding = ascr.npsp__Opportunity__r.npe01__Amount_Outstanding__c;
			this.softCreditAmount = calculateAmount('won',ascr);
			this.pledgedAmountOutstanding = calculateAmount('pledged',ascr);
			this.uncommittedAmount = calculateAmount('uncommitted',ascr);
			this.receivedAmount = calculateAmount('received',ascr);
			this.lostAmount = calculateAmount('lost',ascr);
			this.writtenOffAmount = calculateAmount('writtenoff',ascr);
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
		public static Decimal calculateAmount(String calcType, SObject sobj){
			String objType = sobj.getSObjectType().getDescribe().getName();
			String stage;
			Boolean isWon;
			Boolean isClosed;
			Decimal pledgedAmountOutstanding = 0;
			Decimal oppAmount = 0;
			Decimal giftAmount = 0;
			Decimal returnAmount = 0;
			Decimal writtenOff = 0;
			Decimal received = 0;

			switch on objType.toLowerCase() {
				when 'opportunity' {
					pledgedAmountOutstanding = sobj.get('npe01__Amount_Outstanding__c') != null ? (Decimal) sobj.get('npe01__Amount_Outstanding__c') : 0;
					oppAmount = sobj.get('Amount') != null ? (Decimal) sobj.get('Amount') : 0;
					giftAmount = oppAmount;
					stage = (String) sobj.get('StageName');
					isWon = (Boolean) sobj.get('IsWon');
					isClosed = (Boolean) sobj.get('IsClosed');
					writtenOff = sobj.get('npe01__Amount_Written_Off__c') != null ? (Decimal) sobj.get('npe01__Amount_Written_Off__c') : 0;
					received = sobj.get('npe01__Payments_Made__c') != null ? (Decimal) sobj.get('npe01__Payments_Made__c') : 0;
				}
				when 'npsp__account_soft_credit__c','npsp__partial_soft_credit__c' {
					writtenOff = sobj.getSObject('npsp__Opportunity__r').get('npe01__Amount_Written_Off__c') != null ? (Decimal) sobj.getSObject('npsp__Opportunity__r').get('npe01__Amount_Written_Off__c') : 0;
					pledgedAmountOutstanding = sobj.getSObject('npsp__Opportunity__r').get('npe01__Amount_Outstanding__c') != null ? (Decimal) sobj.getSObject('npsp__Opportunity__r').get('npe01__Amount_Outstanding__c') : 0;
					oppAmount = (Decimal) sobj.getSObject('npsp__Opportunity__r').get('Amount');
					giftAmount = (Decimal) sobj.get('npsp__Amount__c');
					stage = (String) sobj.getSObject('npsp__Opportunity__r').get('StageName');
					isWon = (Boolean) sobj.getSObject('npsp__Opportunity__r').get('IsWon');
					isClosed = (Boolean) sobj.getSObject('npsp__Opportunity__r').get('IsClosed');
					received = sobj.getSObject('npsp__Opportunity__r').get('npe01__Payments_Made__c') != null ? (Decimal) sobj.getSObject('npsp__Opportunity__r').get('npe01__Payments_Made__c') : 0;
				}
				when 'opportunitycontactrole' {
					writtenOff = sobj.getSObject('Opportunity').get('npe01__Amount_Written_Off__c') != null ? (Decimal) sobj.getSObject('Opportunity').get('npe01__Amount_Written_Off__c') : 0;
					pledgedAmountOutstanding = sobj.getSObject('Opportunity').get('npe01__Amount_Outstanding__c') != null ? (Decimal) sobj.getSObject('Opportunity').get('npe01__Amount_Outstanding__c') : 0;
					oppAmount = (Decimal) sobj.getSObject('Opportunity').get('Amount');
					giftAmount = oppAmount;
					stage = (String) sobj.getSObject('Opportunity').get('StageName');
					isWon = (Boolean) sobj.getSObject('Opportunity').get('IsWon');
					isClosed = (Boolean) sobj.getSObject('Opportunity').get('IsClosed');
					received = sobj.getSObject('Opportunity').get('npe01__Payments_Made__c') != null ? (Decimal) sobj.getSObject('Opportunity').get('npe01__Payments_Made__c') : 0;
				}
			}


			switch on calcType {
				when 'won' {
					if(isWon || stage.equalsIgnoreCase('pledged'))
						returnAmount = giftAmount;
				}
				when 'pledged' {
					if((isWon && pledgedAmountOutstanding > 0) || stage.equalsIgnoreCase('pledged'))
						returnAmount = pledgedAmountOutstanding > 0 ? pledgedAmountOutstanding : giftAmount; 
				}
				when 'lost' {
					if(isclosed && !isWon) {
						returnAmount = giftAmount;
					} else {
						returnAmount = writtenOff;
					}

				}
				when 'writtenoff'{
					returnAmount = writtenOff;
				}
				when 'uncommitted' {
					if(!isClosed && !isWon && !stage.equalsIgnoreCase('pledged'))
						returnAmount = giftAmount; 
				}
				when 'received' {
					returnAmount = received;
					if(isWon && returnAmount == 0)
						returnAmount = giftAmount;
				}
			}

			return returnAmount;
		}

        
        public static Decimal calculateAmount(String calcType, Opportunity opp, npe01__OppPayment__c pmt) {
            Decimal Amount = 0;
            if(calcType=='won') {
                if(pmt.npe01__Paid__c) {
                    Amount = pmt.npe01__Payment_Amount__c;
                }
            } else if(calcType=='pledged') {
                if(!pmt.npe01__Paid__c && opp.StageName=='Pledged') {
                    Amount = pmt.npe01__Payment_Amount__c;
                }
            } else if(calcType == 'uncommitted') {
                if(!pmt.npe01__Paid__c) {
                    Amount = pmt.npe01__Payment_Amount__c;
                }
            } else if(calcType=='writtenoff' || calcType=='lost'){
				Amount = pmt.npe01__Written_Off__c ? pmt.npe01__Payment_Amount__c : 0;
				if(calcType == 'lost' && opp.isClosed && !opp.IsWon)
					Amount = pmt.npe01__Payment_Amount__c;
			}
            
            return Amount;
        }
	}
