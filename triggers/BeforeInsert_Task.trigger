//****************************************************************************/
// Task - Before Insert Trigger
// Consolidated Before Insert Task Triggers
//
// Last Modified By : Shashvat Mahendru Date : 08/30/2012 Ref : CR-00018323, BUG-00039492
// Modified by : Kush Dawar for ECMS Phase 2 - Dated: 21 July 14 : Added Check To avoid Invokation of code for ECMS Tasks
//Modified by : Inshu Misra for CR-00087409 - Dated: 1 Oct 14 : Added code to make 'send customer email' button on 'KB details' page functional
//08 April 2016 safiya mohammad CR-00136358 "Date" field in the SE SET Activity Form
//Modified By : Pabitra		CR-00140109 - Removed System.debug
//****************************************************************************/

trigger BeforeInsert_Task on Task (before insert) {
if(!GSS_UtilityClass.isTaskTriggerCheck){    //CR-00094677,CR-00110854

    List<Task> GSS_Tasks = new List<Task>();
    List<Task> PRM_Tasks = new List<Task>();
    List<Task> SFA_Tasks = new List<Task>();
    
    /***START CR-00087409: Send Customer Email button added on KB details page***/
    for (Task t: trigger.new) {
	  //CR-00140109 - Removed System.debug
      //System.debug('KB test added start ' + t);
      if((String.valueOf(t.WhatId)!=NULL) && String.valueOf(t.WhatId).startsWith('a31') && (String.valueOf(t.type) == 'Outbound Email')){
        GSS_Case_Knova__c kb = [select Id, GSS_Case_Number__r.Id from GSS_Case_Knova__c where Id=:t.WhatId limit 1];
        t.WhatId = kb.GSS_Case_Number__r.Id;
      }
	  //CR-00140109 - Removed System.debug
      //System.debug('KB test added end' + t.WhatId);
    }
    /***END CR-00087409e***/
   
    Map<String, String> mapGSS = GSS_CaseUtils.getMapGSS();
    Map<String, String> mapPRM = GSS_CaseUtils.getMapPRM();
    Map<String, String> mapSFA = GSS_CaseUtils.getMapSFA();
    //CR-00136358 changes added by safiya mohammad
    Id seSetActivity = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE SET Activity').getRecordTypeId();
     //CR-00136358 changes End by safiya mohammad
    for (Task t: trigger.new) {
        if(( mapGSS.containsKey(t.RecordTypeId) && (String.valueOf(t.WhatId)!=NULL) && !String.valueOf(t.WhatId).startsWith('a7W') ) || ( mapGSS.containsKey(t.RecordTypeId) && String.valueOf(t.WhatId)==NULL)) {
            GSS_Tasks.add(t);
        } else if(( mapPRM.containsKey(t.RecordTypeId) && (String.valueOf(t.WhatId)!=NULL) && !String.valueOf(t.WhatId).startsWith('a7W') ) || ( mapPRM.containsKey(t.RecordTypeId) && String.valueOf(t.WhatId)==NULL)) {
            PRM_Tasks.add(t);
        } else if(( mapSFA.containsKey(t.RecordTypeId) && (String.valueOf(t.WhatId)!=NULL) && !String.valueOf(t.WhatId).startsWith('a7W') ) || ( mapSFA.containsKey(t.RecordTypeId) && String.valueOf(t.WhatId)==NULL)) {
            SFA_Tasks.add(t);
        }
         //CR-00136358 changes added by safiya mohammad
        if(t.RecordTypeId == seSetActivity)
        {
            if(t.ActivityDate == null && t.Start_Date__c != null)
            {
               t.ActivityDate = t.Start_Date__c;
            }
         //CR-00136358 changes End by safiya mohammad
        }
    }
    
   
    // Migrated from TaskBeforeInsert.trigger
    // Added for CR-00002709 (Single ORG CRs) on 20 October 2010     
    Boolean byPass = ByPassTrigger.userCustomMap('TaskBeforeInsert','Task');
    //Added Check To avoid Invokation of below method for ECMS Tasks Start
    if(!byPass && ECMS_Recursive.restrictTaskTriggers == false){
        // instantiate and invoke method to populate user geo
         new PopulateUserGeo().populateGeo();
    }
    //Added Check To avoid Invokation of above method for ECMS Tasks End
    // End of CR-00002709

    
    // Migrated from Task.trigger
    List<Task> tasksList = new List<Task>();
    String userProfileId = userinfo.getProfileId();
    //Added for CR-00002709 (Single ORG CRs) on 20 October 2010     
    byPass = ByPassTrigger.userCustomMap('Task','Task');
    if(!byPass){
        if(userProfileId != null && userProfileId.length() > 0){
            SFA_Activity_Functions__c str = SFA_Activity_Functions__c.getValues(userProfileId);
            if(str != null && str.Internal_User_Task_Check_Trigger__c == true){
                for(Task  tas :Trigger.new){
                    tasksList.add(tas);
                }
            }
             //Added Check To avoid Invokation of below method for ECMS Tasks Start
            if(tasksList.size()>0 && ECMS_Recursive.restrictTaskTriggers == false){
                SFA_InternalUserActivityCheck.internalUserCheckForTask(tasksList);
            }
            //Added Check To avoid Invokation of above method for ECMS Tasks End
        } 
    }
    //End of CR-00002709              

    // Migrated from GSS_BeforeInsertTask.trigger
    // Trigger to update the Task Type to "Inbound Email" is the task is for incoming Email.

    // Get the case Ids
    List<Id> caseIds = new List<Id>();
    List<Task> inboundEmailTasks = new List<Task>();
    for( Task task : GSS_Tasks) {
        
        String subject = task.subject;
        Boolean isEmail = (subject != null && subject.startsWith('Email:') && subject.endsWith('ref ]'));
          
        if( isEmail && ( mapGSS.get(task.RecordTypeId) != null 
                        || mapGSS.get(String.valueof(task.RecordTypeId).substring(0,15))!= null )
                        && !('Outbound Email'.equals(task.type) ) ) {
            
            //caseIds.add(task.whatId);
            //inboundEmailTasks.add(task);
            task.type = 'Inbound Email';
        }
        //Added Executive Summary condition for CR-00025992 by Sanjib Mahanta
        if ( 'Call Manual'.equals(task.type) || 'Outbound Email'.equals(task.type) || 
             'Inbound Email'.equals(task.type) || 'Call'.equals(task.type) || 'Executive Summary'.equals(task.type) ) {
            task.IsVisibleInSelfService = true; 
        }
    }
    
    /*  
     * CR-00018323, BUG-00039492 
     * Author : Shashvat Mahendru 
     * Description : Validates Task Record Type in reference to Case Record Type
     */ 
     //Added Check To avoid Invokation of below method for ECMS Tasks Start
    if(ECMS_Recursive.restrictTaskTriggers == false){
    VCE_UtilityClass.VCERecordTypeCheck(Trigger.new);
    }
    //Added Check To avoid Invokation of below method for ECMS Tasks End
    //if ( caseIds.size() > 0 ) {
    //
    //    Map<Id, Case> cases = new Map<Id, Case>([Select Id, OwnerId from Case where Id in :caseIds ]);
    //         
    //    for(Task task : inboundEmailTasks ) {
    //        task.ownerId = cases.get(task.whatId).ownerId;
    //        task.type = 'Inbound Email';
    //    }
    //}
}    
}