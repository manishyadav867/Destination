/** Trigger Name      : GSS_AfterInsertRequestUpdateCaseStatus
  * Author            : Accenture - IDC (Harish Patkar)
  * JIRA #            : PP-17997
  * JIRA Description  : Create custom trigger to set Case De-escalated to True on Case 
  * Detail Description: This trigger execute when a Request is inserted and update the Case Status.
  *                             
  **/
  // ************************Version Updates********************************************
//
// Updated Date     Updated By          Update Comments 
//
// 27-Feb-2012      Rakesh Poddar       Added Error handling code in catch block for CR-00008898 
// 14-SEP-2013      Nierrbhayy          Added record type for Licensing Escalataions CR-00052193
// 03-AUG-2016      Sneha Rathi         CR-00138663 : Added default contacts for escalation request
// ************************************************************************************

trigger GSS_AfterInsertRequestUpdateCaseStatus on GSS_Request__c (after insert) {
    Boolean flag=ByPassTrigger.userCustomMap('GSS_AfterInsertRequestUpdateCaseStatus','GSS_Request__c');
    system.debug('Checking Request Insert Trigger Flag = ' +flag);
    if(flag==false){
    try{
        Record_Type_Settings__c oRTSReqER = Record_Type_Settings__c.getInstance('GSS_REQ_ER');
        Record_Type_Settings__c oRTSReqLER = Record_Type_Settings__c.getInstance('GSS_REQ_LER'); //CR-00052193
        // List of Request Object with Escalation Request RecordType
        List<GSS_Request__c> listWRRequest = new List<GSS_Request__c>();
        
        //CR-00138663 - Start : Fetch the recordtype id for escalation request.
        List<GSS_Request__c> lstEscalationRequests = new List<GSS_Request__c>();
        Map<Id, String> mapRequestRecordTypes = GSS_CaseUtils.GetRecordType('GSS_Request__c');
        Id escReqRecordTypeId;
        for(String recTypeId : mapRequestRecordTypes.keySet())
        {
            if(mapRequestRecordTypes.get(recTypeId) == 'Escalation Request')
            {
                escReqRecordTypeId = recTypeId;
            }
        }
        //CR-00138663 - End : Fetch the recordtype id for escalation request. 
        
        
        for(GSS_Request__c oRequest :Trigger.new){
            // Added condition for Licensing escalation record type for CR-00052193
            if(oRequest.RecordTypeId == oRTSReqER.Record_Type_ID__c || oRequest.RecordTypeId == oRTSReqLER.Record_Type_ID__c){
                listWRRequest.add(oRequest);
            }
            //CR-00138663 - Start - Create a list of all the escalation request
            if(oRequest.RecordTypeId == escReqRecordTypeId)
            {
                lstEscalationRequests.add(oRequest);
            }
            //CR-00138663 - End - Create a list of all the escalation request
        }
        system.debug('Request List Size = '+listWRRequest.size());
        GSS_CaseRequestClass.updateCaseStatusForRequest(listWRRequest);  
        //CR-00138663 - Start - Call the function to insert the default Request Contacts
        if(lstEscalationRequests.size() > 0)
        {
            GSS_CaseRequestClass.insertDefaultRequestContacts(lstEscalationRequests);
        }
        //CR-00138663 - End - Call the function to insert the default Request Contacts
    }
    catch(Exception ex){
        CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexTrigger', 'GSS_Request__c', 'GSS_AfterInsertRequestUpdateCaseStatus');
        GSS_UtilityClass.errorObjectInsertionMethod('GSS_Request__c', 'High', 'Unable to update the Case Status for GSS_Request__c', 'GSS_UpdateCaseEscalationStatus.Trigger', 'Pending', 'Trigger');    
    }
    }//if(flag==false)
}