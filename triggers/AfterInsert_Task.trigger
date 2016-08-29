//****************************************************************************/
// Task - After Insert Trigger
// Consolidated After Insert Task Triggers
//
//
/*Modified By : Onkar Kumar (Vmware)
Modified By : Kamaljit Singh(Accenture)
Modified By : Jaypal Singh for CR-7076 - Dated: 12/6
Modified By : Rajib Saha for CR - 7104 - Dated: 04/09
Modified by : Rajib  Saha for CR-00012992 - It is used to update the task type with "Webex Session", when an activity is created through webex button and commit the case. In case a task is created manually, it should be
              committed if the task type is Webex Session.
Modified Date : 15 June 2012
Modified by : Teja Sane for CSR DB - Dated: 3/1/2013
Modified by : Sanjib Mahanta for ECMS Project - Dated 04-April-13
Description   : when user will send mail from Activity track attachment.

Modified By :       Tarun Khandelwal        CR-00028656         Dated: 11 March 2013
Modified by : Hemangini Vashishtha for CR-00045177 - Dated: 18 Oct 13
Modified by : Vijaykumar Pendem for CR-00073834 - Dated: 27 Jan 14
Modified by : Vijaykumar Pendem for CR-00073834 Hotfix - Dated: 25th Feb 14
Modified by : Kush Dawar for ECMS Phase 2 - Dated: 19th Feb 2014 ECMS Phase 2
Modified by : Manu Sharma for SDP 6.0    Date:7/14/2014
Modified by : Kush Dawar for ECMS Phase 2 : Date:1st Aug 2014 : Added Check To avoid Invokation of code for ECMS Tasks
Modified by : Sakshi Suri for GSS CR-00121545 : Date: 24th Mar 2015 :Email Alert to be send to vmwarefedcloud@carpathia.com when task is created by Carpathia User.
Modified by  :M.S.J Ramarao   CR-00044919 - Send a email if task is added on Help zilla cases and BI cases.
Modified by : Ashwin Dash   CR-00135394  Created for reducing the no. of SOQL
Modified by : MSJ           CR-00137728 - Added Check on subject field As a part of reducing SOQL Count.
Modified By : Pabitra		CR-00140109 - Removed System.debug
//****************************************************************************/
trigger AfterInsert_Task on Task (after insert, before insert) {

    if(!GSS_UtilityClass.isTaskTriggerCheck){    //CR-00094677

      Boolean flag = ByPassTrigger.userCustomMap('AfterInsert_Task','Task');
        if(flag) return;             
                
        //system.debug('Size------'+Trigger.new.size());
        List<Task> GSS_Tasks = new List<Task>();
        List<Task> PRM_Tasks = new List<Task>();
        List<Task> SFA_Tasks = new List<Task>();
        
        List<Case> FinalListofCasetoUpdate = new List<Case>(); //CR-00073834
        Map<Id,Case> NewCaseMap = new Map<Id,Case>(); //Fix for 2/21 - Hotfx Release
        Set<Id> taskSet = new Set<Id>(); //CR-00135394  Created for reducing the no. of SOQL 
        Map<String, String> mapGSS = GSS_CaseUtils.getMapGSS();
        Map<String, String> mapPRM = GSS_CaseUtils.getMapPRM();
        Map<String, String> mapSFA = GSS_CaseUtils.getMapSFA();     
        
       //  List<Attachment> Alist = new List<Attachment>([Select a.Id, a.ParentId from Attachment a where ParentId =: Trigger.New[0].Id]);
       //  Trigger.New[0].addError('>>>'+Trigger.New);
       // Start :: CR-00044919
        if (trigger.isAfter & trigger.isInsert){
            if(!GSS_VariableUtilityClass.IsTaskUpdateMailsent){
                GSS_VariableUtilityClass.IsTaskUpdateMailsent = true ;
                GSS_NotifyCaseTeam_AdditionalEmail obj= new GSS_NotifyCaseTeam_AdditionalEmail();
                obj.SendEmailForCasecomment(null,null,null,trigger.new);
            }
        }
        // End :: CR-00044919
        
        for (Task t: trigger.new) {
            //system.debug('+++rrrrrrr++++++' + t.status);
            //system.debug('+++rrrrrrr++++++' + t.subject);
            //system.debug('+++type++++++' + t.type);
            if(( mapGSS.containsKey(t.RecordTypeId) && (String.valueOf(t.WhatId)!=NULL) && !String.valueOf(t.WhatId).startsWith('a7W')) || ( mapGSS.containsKey(t.RecordTypeId) && String.valueOf(t.WhatId)==NULL)) {
               GSS_Tasks.add(t);
            } else if(( mapPRM.containsKey(t.RecordTypeId) && (String.valueOf(t.WhatId)!=NULL) && !String.valueOf(t.WhatId).startsWith('a7W')) || ( mapPRM.containsKey(t.RecordTypeId) && String.valueOf(t.WhatId)==NULL)) {
                PRM_Tasks.add(t);
            } else if(( mapSFA.containsKey(t.RecordTypeId) && (String.valueOf(t.WhatId)!=NULL) && !String.valueOf(t.WhatId).startsWith('a7W')) || ( mapSFA.containsKey(t.RecordTypeId) && String.valueOf(t.WhatId)==NULL)) {
                SFA_Tasks.add(t);
            }
        }
        
        // VCE-Start
        //Added Check To avoid Invokation of below method for ECMS Tasks Start
        if(ECMS_Recursive.restrictTaskTriggers == false){
            VCE_UtilityClass.AI_TaskEmailAlert(Trigger.new);
        }
        //Added Check To avoid Invokation of below method for ECMS Tasks End
        // VCE-End
        
        //ECMS Start
         ApttusSendEmailCount.ApttusEmailCount(Trigger.new);
        //ECMS End
        
        //Q&C Start
         FinalListofCasetoUpdate = QnC_CaseTriggerController.updateFirstResponseDate(Trigger.new); //CR-00073834
         //Q&C End 
        
        // Migrated from TaskAfterInsert.trigger
        // Added for CR-00002709 (Single ORG CRs) on 20 October 2010     
        Boolean byPass = ByPassTrigger.userCustomMap('TaskAfterInsert','Task');
        
        //Added Check To avoid Invokation of below method for ECMS Tasks Start
        if(!byPass && ECMS_Recursive.restrictTaskTriggers == false){
            //CR-00001759
            new EmailController().EmailValuesForTaskUserMangrFields();
        }//End of CR-00002709
        //Added Check To avoid Invokation of below method for ECMS Tasks End
    
        // Migrated from GSS_AfterInsertTask.trigger
        byPass = ByPassTrigger.userCustomMap('GSS_AfterInsertTask','Task');   
        if(!byPass && GSS_Tasks.size() > 0){
            if(trigger.isBefore){
                //******CR-7076 kamal******
                GSS_TaskUtility.populateOwners(Trigger.new);
                 //******CR-7076 kamal******
            }else{              
                GSS_LastTouch objUpdateLastTouchTime = new GSS_LastTouch();
                objUpdateLastTouchTime.AI_UpdateLastTouch(GSS_Tasks);
                
                //******CR-4778 Anoop******
                List<Id> tskIds = new List<Id>();
                //system.debug('GSS_TasksGSS_Tasks -----' + GSS_Tasks);
                for(Task t : GSS_Tasks)
                {
                    //system.debug('+++++++++' + t.status);
                    //Added If condition as per CR-7076 - Jaypal Singh : Dated: 12/6
                    if(t.Is_CSR_Alert_Related__c){
                    tskIds.add(t.id);
                    }
                }                
                GSS_TaskUtility.createTask(tskIds);
                //******CR-4778 Anoop*****  
            }
            //CR-7104 - Update the first response date of the tasks with the current date - Begin 
            // CR - 00012992 Begin
            
            //CSR DB code start
            if(trigger.isAfter){            
             
            List<Task> deltaskList=new List<Task>();            
            //START CR-00135394
            for(Task tsk1 : trigger.new){
                // Start CR-00137728 - Added Check on subject field As a part of reducing SOQL Count. 
                if(tsk1.subject.toUpperCase().contains('SERVICE FIRST')){
                    taskSet.add(tsk1.id);
                }
                // End CR-00137728 - Added Check on subject field As a part of reducing SOQL Count. 

            }
            if(taskSet != null && taskSet.size() > 0){
                deltaskList = [SELECT Id from Task where id IN :taskSet and subject like '%Service First%'];
            }
            /*for(Task tsk1:  trigger.new){
                     deltaskList = [Select Id from Task where id=:tsk1.id and subject like '%Service First%' ];      //Commented out SELECT QUERY inside FOR loop       
                }*/                         
            //END CR-00135394
                
            if(!deltaskList.isEmpty())    
             delete deltaskList;
            
             //CSR DB code end
             
             // CR-00045177 Start
             GSS_TaskUtility.populateCaseComments(GSS_Tasks);  
             // CR-00045177 End
             
             }
            
            if(trigger.isBefore){
            // CR - 00012992 End
                   //CR-00073834
                    List<Case> GSSWebExUtilityList = new List<Case>();
                    GSSWebExUtilityList = GSS_WebExUtility.updateFirstResponse(GSS_Tasks);
                    if(GSSWebExUtilityList !=null){
                        for(Case c : GSSWebExUtilityList){
                            FinalListofCasetoUpdate.add(c);
                        }
                    }       
                //CR-00073834                        
            } 
            //CR-7104 - End               
        } //if(!byPass)
        
         //ECMS Phase 2 - Send For Legal Review Start
        
        if(Trigger.isInsert && Trigger.isAfter){
            String parentagreement = '';
            parentagreement = String.valueOf(Trigger.new[0].WhatId);
            /*SDP 6.0 :
            Purpose: Added condition to avoid null exception when case task does not have any WhatId and it is null-ends
            */  
            if(parentagreement!=null)
            {
            /*SDP 6.0:
            Added condition to avoid null exception when case task does not have any WhatId and it is null-ends
            */           
                if(parentagreement.startswith('a7W') && (Trigger.new[0].Subject!=Null && (Trigger.new[0].Subject.equals('Saved redlined version') || Trigger.new[0].Subject.equals('Saved final version') || Trigger.new[0].Subject.equals('Saved clean version')))){
                ApttusSendEmailCount aptsSendEmail = new ApttusSendEmailCount();
                aptsSendEmail.sendStatusToLegal(Trigger.new[0]);
                }
            }
/*             if(parentagreement.startswith('a7W') && (Trigger.new[0].Subject.equals('Sent For Review'))){
                ApttusSendEmailCount aptsSendEmail = new ApttusSendEmailCount();
                aptsSendEmail.sendStatusToCustomer(Trigger.new[0]);
            } */
        }
        //ECMS Phase 2 - Send For Legal Review END
        //ECMS Phase 2 - Customer Offline Document
            String parentagreement = '';
            List<Id> AgmtIDs = new List<Id>();
            for(Task tsk1 : trigger.new)   
            { 
            if(Trigger.isInsert && Trigger.isAfter){
                parentagreement = String.valueOf(Trigger.new[0].WhatId);
                 /*SDP 6.0 :
                   Purpose: Added condition to avoid null exception when case task does not have any WhatId and it is null-starts
                 */  
                if(parentagreement!=null)
                {
                 /*SDP 6.0 :
                   Purpose: Added condition to avoid null exception when case task does not have any WhatId and it is null-ends
                 */
                if(parentagreement.startswith('a7W') && tsk1.Subject != Null && tsk1.Subject.equals('Imported Offline Document')){
                        AgmtIDs.add(parentagreement);
                }
                }
            if(!AgmtIDs.isEmpty())
                AptsUtil.agmtStatusAfterOfflineAgmt(AgmtIDs); 
            }
            }
        //ECMS Phase 2 - Customer Offline Document End
     //Start  - Added for CR-00028656 (Update First Response on Cases) on 11 March 2013     
        byPass = ByPassTrigger.userCustomMap('TaskAfterInsert','Task');
        if(!byPass  && (trigger.isAfter && trigger.isInsert)){
             //CR-00073834     
                List<Case> updateCasesList = new List<Case>();
                updateCasesList = updateCases.updateFirstResponseDate();
                if(updateCasesList!=null && updateCasesList.size()>0){ //Fix for 2/21 - Hotfx Release
                    for(Case ca : updateCasesList){
                        FinalListofCasetoUpdate.add(ca);
                    }
                }               
            //CR-00073834
        }
        // End - Added for CR-00028656 (Update First Response on Cases) on 11 March 2013 
        
        //CR-00073834 - Moved the code from VCEUpdateCaseRecType trigger to Task AfterInsert  
        if(trigger.isAfter){
		//CR-00140109 - Removed System.debug
        //system.debug('VCE #1');
            List<Case> VCECaseList = new List<Case>();
            Set<Id> VCECaseIds = new Set<Id>();
            for(Task t : Trigger.new){
                if(t.VCE_Assigned_to__c=='VMware'){
                    VCECaseIds.add(t.WhatId);
                }
            }
            
            if(VCECaseIds.size()>0){
			//CR-00140109 - Removed System.debug
            //system.debug('VCE #2');
                VCECaseList = [Select Id ,caseNumber ,Vmware_SR_Number__c  From Case where Id in :VCECaseIds];
            }
            
            if(VCECaseList.size()>0){
			//CR-00140109 - Removed System.debug
            //system.debug('VCE #3');
                Case c = VCE_UtilityClass.SetCaseRecordType(VCECaseList);
                FinalListofCasetoUpdate.add(c);
            }
        }
        //CR-00073834
        
        //CR-00073834
         if(FinalListofCasetoUpdate.size()>0){
             try{
             system.debug('VCE #4');
               //Fix for 2/21 - Hotfx Release
                 for(Case cs : FinalListofCasetoUpdate){
                     NewCaseMap.put(cs.id,cs);
                 }                 
                 Database.SaveResult[] results = Database.Update(NewCaseMap.values(), false);
                 //update FinalListofCasetoUpdate;  
               //End of Hotfx  
              }catch(Exception e){
                 CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexTrigger', 'Task', 'AfterInsert_Task');              
             }
        }
        //End of CR-00073834
    String parentAgmtId = '';
    List<Id> updateAgmtIDs = new List<Id>();
    String taskSubject = '';
    for(Task tsk : trigger.new)    
    {   
        if (trigger.isAfter & trigger.isInsert){
            system.debug('TaskSubjectCheck#####'+tsk.Subject);
            
            parentAgmtId  = String.valueOf(Trigger.new[0].WhatId);
            /*SDP 6.0 :
             Purpose: Added condition to avoid null exception when case task does not have any WhatId and it is null-starts
            */
            if(parentAgmtId!=null)
            {
            /*SDP 6.0 :
             Purpose: Added condition to avoid null exception when case task does not have any WhatId and it is null-ends
            */
                if(parentAgmtId.startswith('a7W') && (tsk.Subject != Null && (tsk.Subject.equals('Sent For Signatures') || tsk.Subject.containsIgnoreCase('Agreement sent out for eSignature to')
                || tsk.Subject.containsIgnoreCase('Agreement eSigned by')))) {
                    updateAgmtIDs.add(parentAgmtId);
                    taskSubject = tsk.Subject;
                } 
            }
        }
    }
    if(!updateAgmtIDs.isEmpty())
    AptsUtil.SignatureStatusChange(updateAgmtIDs,taskSubject); 
}
//CR-00121545 starts
if (trigger.isAfter & trigger.isInsert){
    String userProfileId = userinfo.getProfileId();
    String UserName=userinfo.getName();
    String recType = Record_Type_Settings__c.getInstance('GSS_TASK_GT').Record_Type_ID__c; 
    String carpathiaMail= GSS_Configuration_Properties_list__c.getInstance('CarpathiaEmail').Setting_value__c;
    Id profileId=Profile_Name_Mapping__c.getInstance('Profile - 210 - Carpathia').Profile_Id__c;  
    String exactURL = URL.getSalesforceBaseUrl().toExternalForm();
    GSS_Config_Properties__c gcp=GSS_Config_Properties__c.getOrgDefaults();
    String SFDCURL = gcp.GSS_SFDC_URL__c;
    
    if(userProfileId!= null && userProfileId.length()>0 && profileId.equals(String.valueOf(userProfileId))){  
     
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();      
        for (Task tsk: trigger.new) {  
            if(recType.equalsIgnoreCase(String.valueOf(tsk.RecordTypeId))){   
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                String[] toAddresses = new String[] {carpathiaMail}; 
                mail.setToAddresses(toAddresses);
                mail.setSubject(tsk.Subject);           
                mail.setPlainTextBody('<h3>NEW TASK </h3> <br>' +UserName +' has assigned a new task.');
                mail.setHtmlBody('<h1>NEW TASK </h1> <br>' + UserName +' </b>has assigned the following new task<br> Subject : '+tsk.subject+' <br> Activity Date : '+String.valueOf(tsk.ActivityDate).substring(0,10) +'<br> Priority : '+tsk.Priority+'<br> Notes : '+tsk.Description+ '<br><br>for More Details ,Click the following links<br>Carpathia URL: '
                +exactURL+'/Carpathia/'+tsk.id +'<br>Standard URL: '+SFDCURL+'/'+tsk.id);
                mails.add(mail);
            } 
        }        
        Messaging.sendEmail(mails);                       
    }
}
//CR-00121545 ends
}