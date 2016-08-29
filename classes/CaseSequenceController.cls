//*************************************************************************************
    // Name             : CaseSequenceController.cls
    // Description      : Class to Maintain the Sequence of trigger operations for Case
    // Created By       : Accenture
    // Created Date     : 06/20/2013
    // ************************************************************************************
    // ************************Version Updates************************************************************************
    //19th July 2013       Smita Erande            CR-00043484:-Formatting,Bulkification of After Update Trigger.
    //14th Jan 2014       Vijaykumar Pendem       CR-00067087: Adding Country field to the History 
    // 06-Apr-14          Nierrbhayy           Added code for GSS AGENT Console Project. Technical contact tracker   
    //22nd Mar 2014       Amit Kumar                RS2: Case assingment for Renewal Project  
    //24th Jul 2014       Ravi Kiran D            CR-00087919: Added Class calls for Populating Case Values based on Opportunity and Account
    //5th Jan, 2015      RaviKiran D            RS2_Quoting | Case Cancellation Notification Scenarios
    //29th Jan 2015     Adya Tripathi           Added logic to call the method of 'RS2_CaseAssignmentClass'
    //20th Mar 2015     Ravi Arrabelli          CR-00129659: Added logic to call method of 'RS2_StatusUpdateToOnHold'
    //26 Mar 2015       Inshu Misra             Added a call to AI_createEmailTask against CR-00006501 after insertion/updation of Case
    //30 Mar 2015       M.S.J Ramarao           Addded a call to SendEmailOnCaseUpdate for CR-00044919 
    //11 May 2015        Accenture              CR-00134177 For ECMS PSO 
    //24 July 2015      safiya mohammad         CR-00132655 Enhancement for Deal Operations EMEA Case record type
    //18-Aug-15         Amit Kumar              CR-00135781 : Bypassed the Case methods for RCM Attahcment Insert/Update
    //25-Aug-15         Ashwin Dash             CR-00121549  Correct commit time should be sent as per the severity
    //12-oct-2015       MSJ                     CR-00136106 : Added method calls for sending remainder notifications to Customer
    //22-Sep-2015       Jyolsna Raghavan    RS2 H2 Project - CR-00135349 - added code to call methods to populate values in case and case extension object
    //30-Sep-2015       Varsha              RS2 H2 Project - CR-00135349  
    //7th-Jan-2016      Sakshi Suri         CR-00039831 - GSS
    //23-Feb-2016       Varsha              RS2 Stabilization - CR-00135665 - Added method call in After Insert
    //22-Mar-2016       Varsha              RS2 Stabilization - CR-00138229 - Added method call in before Insert and after Update
    //26-Apr-2016       Sakshi Suri         GSS - CR-00138107 - Added method in After Insert
    //26-Feb-2016       Sandip wankhede     BB-8 Project 
    //29-Feb-2016       Smitarani Sahoo     BB-8 Project    
    //01-Mar-2016       DeepakKumar              BB-8:JIRA:BB-13 - Populate Opco records.
    //21-apr-2016       Kirti Sinha            CR-00138593-Added as a part of QnC - Enhancement
    //22-Apr-2016       Pallavi LV          BB-8 Project:BB-37 CGS Case Notifications 
  //2-Jun-2016        Sakshi Suri         Changes for Optimization CR-00139133  
  //08-June-2016          Safiya                  CR-00138486:Reset logic for calculating "Aging Days" and adding new fields to calculate SLAs for Sales Ops Cases
  //24-June-2016    Suresh        //CR-00139127 -- Update case status,sub-status and resolution code on inbound message received.
  //24-June-2016        Veera                     CR-00138934: Implemented for GTMOps Web-to-Case functionality.
  //12-08-2016          Nilanjana                   RS2- IBS 73 - Added method Call in After Insert
  //12-08-2016          Nilanjana                   RS2- IBS 73 && IBS-367  - Added method Call in After Update
  //*****************************************************************************************************************/
    public class CaseSequenceController {
        
        //Method to perform operation Sequentially
        /*
        * NAME : BEFOREINSERT
        * DESC : INVOKES ALL THE METHODS IN SEQUENCE BEFORE INSERTING AN CASE.
        * 07/19/2012        CR-00013847     KBHOWMICK  ADDED CODE TO CALL VCE_UTILITYCLASS METHOD SETCASEOWNFIELD TO POPULATE THE VCE ENGINEER AND OTHER DETAILS FOR VCE PARTNER INBOUND CASES.   
        * 08/09/2012                    KBHOWMICK  CHANGED THE CODE TO POPULATE VCE ENGINEER FOR VCE OUTBOUND CASES.
        * 05-FEB-13                     NITIN BHALLA(ACCENTURE IDC) : ADDED CODE FOR CR-00028703
        * 08-MAR-13                     TEJA SANE (ACCENTURE IDC)   : ADDED CODE FOR CR-00026556
        * 20-MAR-2013                   DILIP MISTRY   CR-00035711: INVOKED METHOD TO POPULATE SUBJECT/DESCRIPTION FIELDS FOR QUOTA AND COMMISSION CASES
        * 08-NOV-2013       CR-00052004 INCREASE SIZE OF ADDITIONAL EMAIL(S) FIELD
        * 24-MAR-2014                   RS2 PROJECT CASE ASSINGMENT.
        * 24-JUL-2014       CR-00087919 RS2 PROJECT: POPULATING CASE VALUES BASED ON OPPORTUNITY AND ACCOUNT
        * 05-SEPT-2014                  MAYUR SRIVASTAVA     SDP 6.0 CARPATHIA | CR-00102154
        * 02-MARCH-2015     CR-00128726 BHUMIKA UDANI   RS2 CASE WORKFLOW CONDITIONS FOR EMAIL TEMPLATES
        * 13-AUG-2015       CR-00135328 Added triggerNew as parameter in function call for Business unit CR.
        * 09-OCT-2015       CR-00136106 Added flag to Stop unnecessary trigger calls
        * 22-SEP-2015       CR-00135349 Jyolsna Raghavan    RS2 H2 PROJECT: populate case values based on case owner
        *26-Feb-2016       Smitarani Sahoo    BB-8 Project
        *29-June-2016      Smita/Soumya RS2 Renewal Workload Allocation
        */
        public static void beforeInsert(List<Case> triggerNew,List<Case> triggerOld, Map<ID,Case> oldMap){ 
            
            // CR-00043484 - Added Static Variable to restrict unnecessary execution of trigger in test classes. 
            if(!GSS_UtilityClass.isBeforeInsert_Case){
                GSS_VariableUtilityClass.caseExtensionInsert = True; //CR-00136106
                GSS_EmailToCaseUtility.checkEmail(triggerNew);//CR- 00018373 : Email Validation
                CaseProcessing.BI_ClassifyCasesByRecordType(triggerNew);
                VCE_UtilityClass.BI_VCECaseUpdates(triggerNew,oldMap ); //CR-00013381 and CR-00016269 - Start   
                CaseProcessing.BI_UpdateGSS_OwnerEmail(triggerNew);// CR-00005591 : Polulate the GSS_Owner_Email__c field before insert the case //CR-00135328 added triggerNew as parameter                    
                RS2_Autopopulatevaluesoncase.populatevaluesfromopp(triggerNew); // Added for CR-00087919   
                //Start - Soumya - RS2 Workload Allocation 29th June 2016
                RS2_Autopopulatevaluesoncase.updateRenewalCaseOwner(triggerNew);
               //End- Soumya - RS2 Workload Allocation 29th June 2016
                Boolean flag=ByPassTrigger.userCustomMap('BeforeInsert_Case','Case');
                if(flag==false){ 
                
                  QnC_CaseTriggerController.populateCaseDetails(triggerNew);// CR-00035711 Change
                  CaseProcessing.BI_CaseRegion();
                  CaseProcessing.BI_CaseCentre();
                  CaseProcessing.BI_CaseBusinessHour();  
                  CaseProcessing.BI_CommitDefaulter();
                  CaseProcessing.BI_CaseMgrEmail();  
                  CaseProcessing.BI_CaseWorkLoadPoint();  
                  CaseProcessing.BI_CaseOwnerQueue();
                 
                  CaseProcessing.BI_MyVmwareCMT();
                  CaseProcessing.BI_CaseWorkFlow();
                  CaseProcessing.updateCaseAdditionalEmails(triggerNew); //Added for CR-00052004
                  CaseProcessing.BI_PopulateTechnicalContact(triggerNew);//CR-00122294
                  CaseProcessing.BI_Populate_CustomerContact(triggerNew);//CR-00039831
                  RS2_RCMCommonUtility.populateCaseDetailsBasedOnCaseOwner(triggerNew,oldMap); // Added for CR-00135349 
                  
                  //CR-00134177 - STart: ECMS
                  CaseProcessing.ECMS_caseCreationFromAPJ();                    
                  Deal_EMEArecordTypeNewReq.CaseReasonMapping(triggerNew,null);
                  //CR-00134177 - End: ECMS
                   RS2_StabilizationUtility.updateQuoteRequestToWorking(triggerNew); //CR-00138229 - 22nd Mar 2016 - Varsha
                   CaseProcessing.UpdatereportedbyWeb2Case(triggernew);//Added for CR-00138934 - Veera
                  
                   
                }
                
            }
        }
     
        
        /*
         * Name : beforeUpdate
         * Desc : Invokes all the methods in sequence before updating an Case.
         *  06/20/2013          Accenture                Before Update trigger handles all the update events on Case.
         * 19th July 2013       Smita Erande            CR-00008869:-Formatting,Bulkification of Before Update Trigger.
         * 08-Nov-2013          Hemangini                CR-00052004: Increase size of Additional Email(s) field
         * 24-Jul-2014          Ravi Kiran D            CR-00087919    RS2 Project: Populating Case values based on Opportunity and Account
         * 13-AUG-2015          MSJ                     CR-00135328 Added triggerNew as parameter for Business unit CR.
   * 17-Aug-2015      Amit Kumar              CR-00135781: Bypass all t
         * 22-SEP-2015    Jyolsna Raghavan    CR-00135349 RS2 H2 PROJECT: populate case values based on case owner,setting local time when case is closed and populate values in Case extension object
         * 26-Feb-2016       Sandeep Wankhede      BB-8 Project
   */   
        public static void beforeUpdate(List<Case> triggerNew, List<Case> triggerOld,Map<Id,Case>triggerNewMap,Map<Id,Case>triggerOldMap)    {
               //CR-00135781 -Added as part of RCM Attachemnt issue
            if(!recursive.isRCMAttachmentupdate){
              // CR-00008869 - Added Static Variable to restrict unnecessary execution of trigger. 
              if(!GSS_UtilityClass.isBeforeUpdate_Case){  
                    //GSS_UpdateWPTriggerHelper updateWPhelper = new GSS_UpdateWPTriggerHelper();
                  Boolean flag=ByPassTrigger.userCustomMap('BeforeUpdate_Case','Case');
                  CaseProcessing caseProcessingObj=new CaseProcessing();
                  caseProcessingObj.beforeUpdateCaseInitialization(triggerNew,triggerOldMap,flag);
                  CaseProcessing.ExecuteWorkflows(triggerNew,triggerOld,triggerNewMap,false);//CR-00094677
                  GSS_EmailToCaseUtility.checkEmail(triggerNew); //CR- 00018373 : Email Validation
                  if(flag) return; //CR-00037368
                  /** code changes start BB-8 Project Sandip wankhede **/
                  caseProcessingObj.pauseResumeSLAClock(triggerNew,triggerOldMap);
                  CaseProcessing.validateSLACompletionBeforeCaseClosure(triggerNewMap,triggerOldMap);
       /** code changes end BB-8 Project Sandip wankhed **/
                  VCE_UtilityClass.BU_VCECaseUpdates(triggerNew , triggerOldMap ); // Added Code for CR-00013381 , CR-00016269 
                  GSS_CaseOwnerManager.updateGSS_owner_email(triggerNew);
                  caseProcessingObj.IVRCaseUpdate(triggerOldMap);
                  caseProcessingObj.updateCaseCustomerFR(); //CR-00012844 :: Starts
                  QnC_CaseTriggerController.validateParentCaseClosure(triggerNew);//CR-00035711 Change Starts:
                  QnC_CaseTriggerController.extractCaseShareRec(triggerNew);//CR-00138593-Added as a part of QnC - Enhancement-Kirti
                  caseProcessingObj.updateCaseOnOwnerChange(triggerOldMap,triggerNew); //CR-00135328 Added triggerNew as parameter
                   
                  caseProcessingObj.BU_WrkFlw(triggerOldMap);
                  caseProcessingObj.BU_CommitDefaulter();//CR : 00028703
                  caseProcessingObj.myVmWareCaseUpdate(triggerNew,triggerOldMap,flag);
                  caseProcessingObj.processCaseAndEntitlementIPack();   
                  caseProcessingObj.checkCaseIssueTypeSubStatus(triggerOldMap);
                  caseProcessingObj.processTSEAndCSRCases(triggerOldMap); 
                  caseProcessingObj.servicenowfuncupdate(triggerNewMap,triggerOldMap); //Service-Now
                  CaseProcessing.updateCaseAdditionalEmails(triggerNew); //Added for CR-00052004
                  RS2_Autopopulatevaluesoncase.updateValuesFromOpp(triggerNew,triggerOldMap);// Added for CR-00087919              
                  RS2_Autopopulatevaluesoncase.updateSupportQueue(triggerNew,triggerOldMap);// Added for CR-00087919
          //START - CR-00135349 - 22-SEP-2015 - Jyolsna - Added for RS2 H2 Project
                  RS2_RCMCommonUtility.populateCaseDetailsBasedOnCaseOwner(triggerNew,triggerOldMap);
                  RS2_RCMCommonUtility.populateLocalTimeBasedOnCaseClose(triggerNew,triggerOldMap);
                  RS2_RCMCommonUtility.createCaseExtensionWithOnHoldDetails(triggerNew,triggerOldMap);
          //END - CR-00135349 - Jyolsna - Added for RS2 H2 Project
                  //Start - Smita - RS2 Workload Allocation 29th June 2016
                      RS2_CaseAssignmentUtility.calWorkloadPoint(triggerNew,triggerOldMap);
                  //End- Smita - RS2 Workload Allocation 29th June 2016
                  //Added By Safiya for CR-00132655                   
                  Deal_EMEArecordTypeNewReq.CaseReasonMapping(triggerNew,triggerOldMap);
                  //End By safiya for CR-00132655
                  caseProcessingObj.BU_Populate_CustomerContact(triggerNew,triggerOldMap);//CR-00039831
          GSS_WebformEmailUtility.updateCaseOnInboundMessageReceived(triggerNew);//Suresh CR-00139127
              }    
        }
     
     } 
        
        
        /*
         * Name : afterInsert
         * Desc : Invokes all the methods in sequence after inserting an Case.
         * 03/17/2011           Shweta Tiwari           Added code for CR-00003984
         * 28/02/2012           Shweta Tiwari           Added code for MyVmware   
         * 22/02/2012           Sneha Jain              Added for  CR-00008897 : Bypass trigger functionality for Data Migration user.
         * 31-July-12           Deepak Kumar            Added code for CR-00013381
         * 8- August-12         Kishaloy Bhowmick       Added code for CR-00013385,CR-00013384,CR-00013391 to auto send the Case to S2S Partner Network Connection
         * 4/10/2012            Teja Sane               Added code for CR-5302
         * 20-Mar-2013          Dilip Mistry            CR-00035711: invoked method to share QnC cases with thier requester 
         * 29-Jan-2015          Adya Tripathi           Added logic to trigger the assignment rule on after case insertion
         * 10-feb-2015          Dalia Pan               CR-00110790 : To call class 'caseSharingToReportedUser' for sharing case record with Reported By user. 
         * 26 Mar 2015          Inshu Misra             Added a call to AI_createEmailTask against CR-00006501 after insertion/updation of Case
         * 25-Aug-15            Ashwin Dash             START - CR-00121549  Correct commit time should be sent as per the severity
     * 22-SEP-2015          Jyolsna Raghavan        CR-00135349 RS2 H2 PROJECT: populate values in Case extension object
         *26-Feb-2016       Deepak Kumar        BB-8 Project
   */
        public static void afterInsert(List<Case> triggerNew,List<Case> triggerOld,Map<ID,Case> oldMap,Map<ID,Case> newMap) {
            // CR-00043484 - Added Static Variable to restrict unnecessary execution of trigger in test classes. 
            if(!GSS_UtilityClass.isAfterInsert_Case){
                
                Boolean flag=ByPassTrigger.userCustomMap('AfterInsert_Case','Case'); 
                if(flag) return;

                CaseProcessing caseProcessingObj=new CaseProcessing();
                CaseProcessing.ExecuteWorkflows(triggerNew,triggerOld,newMap,true);//CR-00094677
                // Functionality of SetCaseAssignmentOptions trigger
                CaseProcessing.AI_SetCaseAssignmentOptions(triggerNew);

                CaseProcessing.AI_ClassifyCasesByRecordType(triggerNew);
                CaseProcessing.AI_DCASyncMatch_Engine();
                caseProcessingObj.AI_createEmailTask(newMap, null);//CR-00006501
                VCE_UtilityClass.AI_VCECaseUpdates(triggerNew, oldMap);//CR-00013385,CR-00013384,CR-00013391 ,CR-00013381

                QnC_CaseTriggerController.shareCaseWithRequester(triggerNew); //CR-00035711
                QnC_CaseSharingCalculations sharingUtil = new QnC_CaseSharingCalculations();
                sharingUtil.recalculateVMOperationsAdminSharingRule(newMap, oldMap);

                //GSS AGENT CODE
                caseProcessingObj.AI_TechnicalContactTracker(triggerNew);
    caseProcessingObj.AI_CaseExtensionCreation(triggerNew);//CR-00138107
                CaseProcessing.AI_UpdateCaseFirstResponse();
                CaseProcessing.AI_AcctConSyncAndAvayaFuture();
                caseProcessingObj.AI_SFA_CommontriggerUtility();
                GSS_Caseaccount_notified.processCasesToSendEmailAM(triggerNew); // CR-00006251
                CaseProcessing.AI_MyVmware(oldMap,newMap);  

                CaseProcessing.servicenowfunc();    //Service-Now
                CaseProcessing.InsertDataInCaseHistory(oldMap,newMap,'IsInsert'); //CR-00067087
                CaseProcessing.rS2_CaseClosure(triggerNew,oldMap); //Added for RS2
                CaseProcessing.AI_CarpethiaAccountAccess(triggerNew); //05-Sept-2014      Mayur Srivastava     SDP 6.0 Carpathia | CR-00102154
                //Changes for Optimizaton - 6/2/2016 Starts CR-00139133
                Map<String, Record_Type_Settings__c> recordTypeSettingsMap = Record_Type_Settings__c.getAll();
                Map<Id,Case> SDPcseMap = new Map<Id,Case>();
                for(Case caseNew : triggerNew){
                    if(String.valueOf(caseNew.recordtypeId) == recordTypeSettingsMap.get('GSS_CASE_SDP_FED').Record_Type_ID__c){
                    SDPcseMap.put(CaseNew.Id,caseNew);
                    }
                if(!SDPcseMap.isEmpty()){
                CaseProcessing.sendingAckEmailSDP(SDPcseMap.keySet());}
                // 25-Aug-15    Ashwin Dash  START - CR-00121549  Correct commit time should be sent as per the severity
                }
                //Changes for Optimizaton - 6/2/2016 CR-00139133 Ends
                
                // 29th Jan 2015 Adya Tripathi : Added method to trigger the assignment rule after case insertion 
                RS2_CaseAssignmentClass.triggerAssignementRule(triggerNew);
                
        //Start - CR-00110790 changes
        caseSharingToReportedUser.caseSharing(triggerNew,null);
        //End - CR-00110790 changes
                // 02 MARCH 2015       BHUMIKA UDANI   CR-00128726
                map<id, case>caseMap = new map<id, case>();
                RS2_E2CUtilityClass.sendEmailUpdateCheck(triggerNew, caseMap, false);
                
                /*Added By Safiya for CR-00132655 
                  * calling  methods from Deal_EMEArecordTypeNewReq
                */
                Deal_EMEArecordTypeNewReq.CaseAutoNotification(triggerNew);  
                Deal_EMEArecordTypeNewReq.caseDiffStatuschanges(triggerNew,new map<Id,Case>(),false);
                
                //End by Safiya
// Added for CR-00136106 Start
        GSS_Agent_Variables__c obj = GSS_Agent_Variables__c.getOrgDefaults();
        if(obj!=null && obj.Automation_of_Notifications__c)
          CaseProcessing.AI_SendRemainder(triggerNew); // Added for CR-00136106
        // Added for CR-00136106 End
                RS2_RCMCommonUtility.createCaseExtensionWithOnHoldDetails(triggerNew,oldMap);//Added for CR-00135349
            
                RS2_RCMCommonUtility.createCaseStatusHistory(triggerNew); //CR-00135349 - 30th Sep 2015 - Varsha
                RS2_StabilizationUtility.processQuoteRequest(triggerNew); //CR-00135665 - 23rd Feb 2016 - Varsha
                /**START - User Story IBS-73 -Nilanjana - 8th Aug 2016**/
                //System.debug('*********User Story IBS-73*********');
                RS2_QuoteEndDateCalculation.quoteEndDateVmstarAfterInsert(triggerNew);
                /**END - User Story IBS-73 -Nilanjana - 8th Aug 2016**/
                /** Start - RS2 WorkloadAllocation - Smita - 7th Jul 2016**/ 
                RS2_CaseAssignmentUtility.populateCaseFlagForNoEligibleFound(triggerNew);
                /** End- RS2 WorkloadAllocation - Smita - 7th Jul 2016**/ 
                // BB-8:JIRA:BB-13 - Populate Opco records.
                GSS_PremierEntitlement_Utility.processOpcoDocumentsFuture(triggerNew,null);
            }
            CaseProcessing.shareGTMCaseWithRequester(triggernew,oldMap);//Added for CR-00138934 - Veera
        }

      
        /*
         * Name : afterUpdate
         * Desc : Invokes all the methods in sequence afterupdating an Case.
         * 06/20/2013           Accenture               After Update trigger handles all the update events on Case 
         * 19th July 2013       Smita Erande            CR-00043484:-Formatting,Bulkification of After Update Trigger.
         * 24th Jan 2014        Hemangini               Modified for CR-00037368 (checkbox on Service Description field)
         * 10-feb-2015          Dalia Pan               CR-00110790 : To call class 'caseSharingToReportedUser' for sharing case record with Reported By user. 
         * 26 Mar 2015          Inshu Misra             Added a call to AI_createEmailTask against CR-00006501 after insertion/updation of Case
         * 17-Aug-2015          Amit Kumar              CR-00135781: Bypass all the case processing methods for RCM Attachment Trigger update.
         *26-Mar-2016           Smitarani Sahoo         BB-8 Project
   */
        public static void afterUpdate(List<Case> triggerNew, List<Case> triggerOld,Map<Id,Case>triggerNewMap,Map<Id,Case>triggerOldMap)  { 
             //Added for  CR-00008897 : Bypass trigger functionality for Data Migration user.
                Boolean flag=ByPassTrigger.userCustomMap('AfterUpdate_Case','Case');
                if(flag) return;
                RS2_RCMCommonUtility.updateCaseStatusHistory(triggerNew, triggerOldMap); //CR-00135349 - 30th Sep 2015 - Varsha
            //CR-00135781 -Added as part of RCM Attachemnt issue
            if(!recursive.isRCMAttachmentupdate){
            // CR-00043484 - Added Static Variable to restrict unnecessary execution of trigger in test classes. 
            if(!GSS_UtilityClass.isAfterUpdate_Case){
                
                CaseProcessing caseProcessingObj=new CaseProcessing();
                /** Code change start for BB-8 Project Jira:BB-77 - Smita **/
                caseProcessingObj.syncFirstResponseDate(triggerNew,triggerOldMap);
                 caseProcessingObj.toggleWorkaroundBasedCaseStatus(triggerNew,triggerOldMap);
                /** Code change end for BB-8 Project - Smita **/
                caseProcessingObj.afterUpdateCaseInitialization(triggerNew,triggerOld,triggerOldMap);
                
                //CR-28669 start
                if(GSS_UtilityClass.isCountOnCaseUpdated ==false && GSS_UtilityClass.isManualCase()){
                    UpdateTheRelatedCaseCountOnParent.updateRelatedListCount(triggerNew,triggerOldMap);
                }
                
                //CR-00035711 STARTS
                QnC_CaseTriggerController.shareCaseWithRequester(triggerNew);
                QnC_CaseTriggerController.shareCaseWithPreviousOwner(triggerNew);//CR-00138593-Added as a part of QnC - Enhancement-Kirti
                QnC_CaseSharingCalculations sharingUtil = new QnC_CaseSharingCalculations();
                sharingUtil.recalculateVMOperationsAdminSharingRule(triggerNewMap, triggerOldMap);
                //CR-00035711 ENDS   
                caseProcessingObj.AI_createEmailTask(triggerNewMap, triggerOldMap);//CR-00006501
                caseProcessingObj.VCECaseHandling(triggerNew,triggerOld,triggerOldMap);
                caseProcessingObj.processCaseEmailAndFR(triggerNew,triggerOld,triggerOldMap);
                // Start safiya changes -- CR-00138486
              caseProcessingObj.calculateCaseStatusTime(triggerNewMap,triggerOldMap);
                
                // End safiya changes -- CR-00138486
                caseProcessingObj.calculateCasePhoneQ(triggerOldMap);
                caseProcessingObj.autoCloseAssistRequestOnCaseClosure();
                 
                caseProcessingObj.SFACommonTriggerUtility(triggerNew,triggerOld,triggerNewMap,triggerOldMap);
                caseProcessingObj.myVmWareCaseUpdate();
                caseProcessingObj.VCETaskOwnerUpdate();
                //GSS AGENT CODE
                caseProcessingObj.AU_TechnicalContactTracker(triggerOldMap,triggerNew);
                CaseProcessing.AU_CarpethiaAccountAccess(triggerNew,triggerOld,triggerNewMap,triggerOldMap); //05-Sept-2014     Mayur Srivastava     SDP 6.0 Carpathia | CR-00102154
                 
                // CR-00037368 STARTS
                if(!triggerNew.isEmpty()){
                    caseProcessingObj.filterCaseswithServiceDesc(triggerOldMap);
                }
                // CR-00037368 ENDS
                CaseProcessing.InsertDataInCaseHistory(triggerOldMap,triggerNewMap,'IsUpdate'); //CR-00067087
                CaseProcessing.rS2_CaseClosure(triggerNew,triggerOldMap);//Added for RS2
                RS2_PDSAssignmentruleclass.PDSAPI(triggerNew,triggerOld);
                            
                // 02 MARCH 2015       BHUMIKA UDANI   CR-00128726
                RS2_E2CUtilityClass.sendEmailUpdateCheck(triggerNew,triggerOldMap, true);
                //RS2_StatusUpdateToOnHold.statusUpdate(triggerNew,triggerOld); // Added as part of CR-00129659
                
          //Start - CR-00110790 changes
          List<Case> triNewList = new List<Case>();
          List<Case> triOldList = new List<Case>();

          if(!triggerNew.isEmpty()){
            for(Case caseNew : triggerNew){
              Case caseOld = (Case)Trigger.oldMap.get(caseNew.ID);
              if(caseNew.Reported_By__c!= caseOld.Reported_By__c || caseNew.OwnerID != caseOld.OwnerID){
                  triNewList.add(caseNew);
                  triOldList.add(caseOld);
              }
            }
            caseSharingToReportedUser.caseSharing(triNewList,triOldList);
          }
          //End - CR-00110790 changes
          //Starts CR-00044919-- method to send email on case update for Helpzilla and BI cases
          if(!GSS_VariableUtilityClass.IsCaseCommentMailSent){
            GSS_VariableUtilityClass.IsCaseCommentMailSent= true; 
            caseprocessing.SendEmailOnCaseUpdate(triggerNew);
          }
          //ends CR-00044919
          
              /*Added By Safiya for CR-00132655 
              * calling  methods from Deal_EMEArecordTypeNewReq
              */
                Deal_EMEArecordTypeNewReq.caseDiffStatuschanges(triggerNew,triggerOldMap,true);
              //End by safiya for CR-00132655 
// Added for CR-00136106 Start
      GSS_Agent_Variables__c obj = GSS_Agent_Variables__c.getOrgDefaults();
      if(obj!=null && obj.Automation_of_Notifications__c)
        CaseProcessing.AU_SendRemainder(triggerNew,triggerOldMap); //Added for CR-00136106
            // BB-8:JIRA:BB-13 - Populate Opco records. - Deepak
            GSS_PremierEntitlement_Utility.processOpcoDocumentsFuture(triggerNew,triggerOldMap);
      
      //BB-8 Project:BB-37 - CGS Case Notifications - Pallavi
            CaseProcessing.updateCaseSLAMilestoneDLEmail(triggerNew,triggerOldMap);
           }    
            // Added for CR-00136106 End      
            RS2_StabilizationUtility.updateQuoteRequestToOpen(triggerNew, triggerOldMap); 
            //CR-00138229 - 22nd Mar 2016 - Varsha
            /**START - User Story IBS-367 -Nilanjana - 4th Aug 2016**/
            System.debug('*********User Story IBS-367*********');
            RS2_StabilizationUtility.UpdateSourceToOpen(triggerNew,triggerOldMap);
            /**END - IBS User Story IBS-367 -Nilanjana - 4th Aug 2016**/
            
            /**START - User Story IBS-73 -Nilanjana - 8th Aug 2016**/           
            System.debug('*********User Story IBS-73*********');
            RS2_QuoteEndDateCalculation.quoteEndDateAfterUpdate(triggerNew,triggerOldMap);
            /**END - IBS User Story IBS-73 -Nilanjana - 8th Aug 2016**/
            
            /** Start - RS2 WorkloadAllocation - Smita - 7th Jul 2016**/ 
           // RS2_CaseAssignmentUtility.populateCaseFlagForNoEligibleFound(triggerNew);
            /** End- RS2 WorkloadAllocation - Smita - 7th Jul 2016**/ 
        }        
        //RS2_RCMCommonUtility.updateCaseStatusHistory(triggerNew, triggerOldMap); //CR-00135349 - 30th Sep 2015 - Varsha
        CaseProcessing.shareGTMCaseWithRequester(triggernew,triggerOldMap);//Added for CR-00138934 - Veera
        }
        /*
        * Name : beforeDelete
        * Desc : Invokes all the methods in sequence before deleting an Case.
        */
       
        public static void beforeDelete(List<Case> triggerNew, List<Case> triggerOld){
            
            CaseProcessing caseProcessingObj=new CaseProcessing(); 
            caseProcessingObj.updateRelatedListCount(triggerNew,triggerOld);
        }
        
    }