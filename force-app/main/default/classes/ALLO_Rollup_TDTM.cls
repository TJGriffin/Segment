/**
* @author TJ Griffin
* @date 2022
* @group Contact
* @description table driven trigger on contact to handle sustainer status processing
*/
global without sharing class ALLO_Rollup_TDTM  extends npsp.TDTM_Runnable  {

	/*******************************************************************************************************
	* @description Trigger Handler 
	* 	Rules:
	* 		before insert/update - change record type to membership based on GL Code
	* 		after insert/update - create new membership for membership record types
	* 		before insert/update - apply appropriate allocation based on GL Code
	* @param listNew the list of Opportunities from trigger new. 
	* @param listOld the list of Opportunities from trigger old. 
	* @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
	* @param objResult the describe for Opportunities
	* @return dmlWrapper.  
	********************************************************************************************************/
	global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        /*******************************************************************************************************
        * @description DML Wrapper
        */
        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert 
         || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate)
            dmlWrapper.objectsToUpdate.addAll(OPP_Allocation_RLUP.processRollups((List<npsp__Allocation__c>)newlist));

        return dmlWrapper;
    }
}
