/** Trigger Name      : GSS_AfterUpdateRequestUpdateCaseStatus
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
// 4-May-2012        Accenture            Updated code for CR-00011784.
// 14-SEP-2013      Nierrbhayy          Added record type for Licensing Escalataions CR-00052193
// 2-Aug-2016       Jyolsna             CR-00140215: For tracking Current Status field
// ************************************************************************************
trigger GSS_AfterUpdateRequestUpdateCaseStatus on GSS_Request__c (after update)  {
    Boolean flag=ByPassTrigger.userCustomMap('GSS_AfterUpdateRequestUpdateCaseStatus','GSS_Request__c');
    if(flag==false){
    try{
         Record_Type_Settings__c oRTSReqER = Record_Type_Settings__c.getInstance('GSS_REQ_ER');
         Record_Type_Settings__c oRTSReqLER = Record_Type_Settings__c.getInstance('GSS_REQ_LER'); //CR-00052193
        // List of Request Object with Escalation Request RecordType
        List<GSS_Request__c> listWRRequest = new List<GSS_Request__c>();
        List<GSS_Request__c> listCurrentStatusHist = new List<GSS_Request__c>();//Added for CR-00140215

        for(GSS_Request__c oRequest :Trigger.new){
        //Added one more condition for Alert Level check in 'IF' for CR-00011784. 
        // Added condition for Licensing escalation record type for CR-00052193      
            if((oRequest.RecordTypeId==oRTSReqER.Record_Type_ID__c  || oRequest.RecordTypeId == oRTSReqLER.Record_Type_ID__c) 
            && ((oRequest.GSS_Status__c != Trigger.oldMap.get(oRequest.id).GSS_Status__c) 
            || (oRequest.GSS_Alert_Level__c != Trigger.oldMap.get(oRequest.id).GSS_Alert_Level__c) )){
                if(oRequest.GSS_Status__c != null)
                    listWRRequest.add(oRequest);
            }
            //Start - 2-Aug-2016 - Jyolsna - CR-00140215 - checking current status field is changed in escalation/ licensing request
            if((oRequest.RecordTypeId == oRTSReqER.Record_Type_ID__c || oRequest.RecordTypeId == oRTSReqLER.Record_Type_ID__c) ){
               listCurrentStatusHist.add(oRequest);
            }
            //End - 2-Aug-2016 - Jyolsna - CR-00140215 - checking current status field is changed in escalation/ licensing request
        }
        system.debug('Request List Size = '+listWRRequest.size());
        if(listWRRequest.size()>0 && listWRRequest !=null){
            GSS_CaseRequestClass.updateCaseStatusForRequest(listWRRequest);       
        }
        //Start - 2-Aug-2016 - Jyolsna - CR-00140215 - save the change in objecttrackhistory object 
        if(listCurrentStatusHist != null && !listCurrentStatusHist.isEmpty()){
            GSS_CaseRequestClass.createCurrentStatusHist(listCurrentStatusHist,Trigger.oldMap);
        }
        //End - 2-Aug-2016 - Jyolsna - CR-00140215 - save the change in objecttrackhistory object 
    }
    catch(Exception ex){
        CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexTrigger', 'GSS_Request__c', 'GSS_AfterUpdateRequestUpdateCaseStatus');
        GSS_UtilityClass.errorObjectInsertionMethod('GSS_Request__c', 'High', 'Unable to update the Case Status for GSS_Request__c', 'GSS_UpdateCaseEscalationStatus.Trigger', 'Pending', 'Trigger');    
    }
    }//if(flag==false)
}