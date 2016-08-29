//*************************************************************************************
// Description      : Class is called from CaseSequenceController to invoke the respective trigger methods.
// Created By       : Accenture
// Created Date     : 06/20/2013
// ************************************************************************************
// ************************Version Updates************************************************************************
// Updated Date         Updated By              Update Comments td
// 04/05/2012           Vivekanand Deshmane     Added code for CR-00009560
// 31-July-12           Deepak Kumar            Added code for CR-00013381
// 29-Aug-12            Shashvat Mahendru       Added code for BUG-00039937
// 4/10/2012            Teja Sane               Added code for CR-5302
// 20-Mar-2013          Dilip Mistry            CR-00035711: invoked method to share QnC cases with thier requester 
// 1-April-2013         Harish Patkar           Added code for service now
// 19-April-2013        Mayur Srivastava        Added code for service now
// 13-May-2013          Shashvat Mahendru       Added code for CR-00039339
// 13-July-2013         Pradnya Nigade          CR-00023662:to Auto close Assist Request on case closure 
// 19th July 2013       Smita Erande            CR-00043484:-Formatting,Bulkification of After Update Trigger.
// 24-June-2013         Mayur Srivastava        CR-00044548
// 26-06-2013           Mrutyunjay              commented calling of "GSS_SyncAccountContactRelation" class.
// 13-SEP-13            Nierrbhayy              CR-00052144 Bypassing DCA for vi-hotline E2C sceanrios
// 18-OCT-13            Nierrbhayy              CR-00052138 GSS Support Level Custom Setting - Tech Support only
// 08-Nov-13            Hemangini               CR-00052004 Increase the size of the case "Additional Email(s)" field for SFDC cases
// 06-DEC-13            Nierrbhayy              CR-00055569  Issue with SFDC service call(Long country name)
// 08-Nov-13        Mayur Srivastava    CR-00066003 [SDP 3.5]
// 26-Nov-13        Mayur Srivastava    Added code for Service-Now ITBM Integration [SDP 3.5] - CR 00072107
// 24-Jan-14        Hemangini       Added code for CR-00037368 (check box on Service Description field)
// 14-Jan-14            Vijaykumar              CR-00067087: Adding Country field to the History
// 03-mar-14            MSJ Ramarao             CR-00076418:-populating First Response Due Date field after update
// 06-Apr-14            Nierrbhayy              Added code for GSS AGENT Console Project. Technical contact tracker
// 14-July-14          Surbhi Tiwari            Added for RS2:Distributor contact email notification when case is closed.
// 05-Sep-14            Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Added Account access and associated cases with dummy Contact/ Account for Carpathia Users
// 26-May-14            Vijaykumar Pendem       CR-00094677,CR-00110854  : Case object: Workflows migration to Trigger
// 17-Sep-14            Nierrbhayy              CR-00107561 : history Limit 31,000 characters
// 19-Nov-14            Manu                    CR-00110154-changed to stop multiple mail triggering
//29-dec-14             MSJ Ramarao             CR-00122294- Agent console :populate Technical Contact details with primary contact details 
//Jan 8-15              Manu Sharma             BUG-00109732-Change in the condition to trigger emails to disributor contact on case closure(Renewal Operations).   
// 19-Jan-15            MSJ Ramarao             CR-00110179-Added method to change sub status on owner change
// 26-Mar-15            Inshu Misra             CR-00006501-Added method to create/update sendAlertTask if the status of Partner Network is/changes to 'New', 'Assigned', 'Triaged', 'In-Progress' or 'Re-Opened'
// 30/3/2015            M.S.J Ramarao           CR-00044919-Added class to send emails to case team members and additional email field 
// 01/4/2015            Nierrbhayy              CR-00130456-Updated conditions for technical contact details population 
// 05-Jun-15            Mayur Srivastava        SDP Phase 9.0 | CR-00132194 | VMStar-ServiceNow FRD
// 11-Jun-15            Accenture               CR-00134177 : ECMS PSO | Call a method to remove Junk Link from PSO Case Description field
// 25-Jun-15            MSJ Ramarao             CR-00131921 : populate case owner's business unit on case.
// 13-Aug-15            MSJ Ramarao             CR-00135328 : Added triggerNew as parameter in function call to check for all case recordtypes.
// 25-Aug-15            Ashwin Dash             CR-00121549  Correct commit time should be sent as per the severity for GSS Subscriptions and GSS SDP FEDERAL Cases
// 12-Oct-15            MSJ Ramarao             CR-00136106  Added method for Sending remainders to customer.
// 06-Jan-16            MSJ Ramarao             CR-00136984 - Added a flag to populate Business unit field on case. 
// 07-Jan-16            Sakshi Suri             CR-00039831 Populate Customer Contact Languages.
// 11-Feb-16            Pabitra Pramanick       CR-00137607 Automate Phone Queue for all the GSS profile and for fields specified in a custom setting
// 23-Feb-16            MSJ                     CR-00137623 By pass Increment/decrement functionlity on workloads points on case owner change for Vi-hotline cases.
// 11-Mar-16            Pabitra Pramanick       CR-00137607 Hotfix:Automate Phone Queue for some specific GSS profile
// 23-Mar-2016          Jyolsna                 CR-00138303  WorkloadPoint Calculation put recursive check
//24-Mar-2016           Sakshi Suri             CR-00138072  VI-Hotline Optimization - Implement the user data flag Phase 2
//7-Apr-2016            Sakshi Suri             CR-00138257 Add ability to add multiple partner contact information
//26-Apr-2016        Sakshi Suri                CR-00138107 Case Extension Creation after Case insert
// 26- feb-16           Sandip Wankhede         BB-20 Pause/Resume the SLA Clock depends on  sub status of case
// 29- feb-16           Smitarani Sahoo         BB-8 project - Rounting country must be updated only for premier entitlements
// 22-Apr-16            Pallavi LV              BB-8 project - BB-37 CGS Case Notifications
//16-May-2016           Jyolsna                 CR-00134744 : GSS - Severity 1 Assignment.
//31-May-2016       Jyolsna         CR-00138381 : GSS Business Unit does not update on some occasions
//2-Jun-2016        Sakshi Suri            Changes for Optimization  CR-00139133
//08-June-2016          Safiya                  CR-00138486:Reset logic for calculating "Aging Days" and adding new fields to calculate SLAs for Sales Ops Cases
//24-June-2016        Veera                     CR-00138934: Implemented for GTMOps Web-to-Case functionality.
//15-Jun-2016           Jyolsna                 CR-00138097: For vce cases,Update technical contact with VCE Prime Engineer
//16-Jun-2016            Pallavi LV             BB-8 project : Email notifications changes
//28-Jul-2016           Jyolsna                 CR-00139057 : Added blank check before creating GSS_Technical_Contact__c record
//04-Aug-2016      Pabitra          CR-00140109 : Removed System.debug.
/*****************************************************************************************************************/
public class CaseProcessing {

   public static Id myVmwareRTITSup = Id.valueOf(Record_Type_Settings__c.getInstance('ITAppsSupport').Record_Type_ID__c);
   public static Id myVmwareRTCommon = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_MyVmwareCommonCase').Record_Type_ID__c);
   public static Id techSupport = Id.valueOf(Record_Type_Settings__c.getValues('GSS_CASE_TS').Record_Type_ID__c);
   public static Id licCaseRT = Id.valueOf(Record_Type_Settings__c.getValues('GSS_CASE_LIC').Record_Type_ID__c); //CR-00052144
   public static String Ivradmin =GSS_Configuration_Properties_list__c.getInstance('IVR_ADMIN').setting_value__c ;
   public Static Id caseAdminId = Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('CaseAdmin').setting_value__c); //CR-00052144
   public Static Id SiteUser = Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('SiteUser').setting_value__c);//CR-00094677
   public static datetime dt = datetime.now();
   public static datetime newdate =dt.addSeconds(-5);
   public static String rct =Record_Type_Settings__c.getValues('RCM_Case_Renewal_Operations').Record_Type_ID__c;
   public static Id portalUserId = GSS_Configuration_Properties_list__c.getInstance('GSS-Portal Integration User') !=null ? Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('GSS-Portal Integration User').setting_value__c) : null; // CR-00137623
   public static Id qmanUserId = GSS_Configuration_Properties_list__c.getInstance('Qman User') !=null ? Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('Qman User').setting_value__c) :null; // CR-00137623    
   public GSS_Agent_Variables__c prfID=GSS_Agent_Variables__c.getOrgDefaults();//CR-00138257
   public static Id GTMOpsRT = Record_Type_Settings__c.getInstance('GTMOpsCoE') !=null ? Id.valueOf(Record_Type_Settings__c.getValues('GTMOpsCoE').Record_Type_ID__c) : NULL;//CR-00138934
   public static Id CaseAdminUserId = GSS_Configuration_Properties_list__c.getInstance('CaseAdmin') !=null ? Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('CaseAdmin').setting_value__c) : null;//CR-00138934
     //Start - 15-Jun-2016    Jyolsna     CR-00138097-getting the id of vce case recordtypes
   public static Id partnerVceCase = Id.valueof(Record_Type_Settings__c.getInstance('GSS_Partner_VCE').Record_Type_ID__c);
   public static Id vmwareVceCase = Id.valueof(Record_Type_Settings__c.getInstance('GSS_CASE_VCE').Record_Type_ID__c);
   //End - 15-Jun-2016  Jyolsna     CR-00138097-getting the id of vce case recordtypes
    
    
  /**********Variable Declairation - Before Insert Case -START*****/
  Public Static List<Case> BI_GSS_Cases = new List<Case>();
  Public Static List<Case> BI_PRM_Cases = new List<Case>();
  Public Static List<Case> BI_SFA_Cases = new List<Case>();
  

  //CR-00134177 - Start : Create a list which captures all PSO Case Records
  Public Static List<Case> ECMS_APJ_PSO_Cases_List = new List<Case>();

  //CR-00134177 - End
  
  //SWALEH - Adding below code for MyVMWARE CMT changes - START
  Public Static List<Case> BI_myVmwareCasesSupGrp = new List<Case>();
  Public Static List<Id> BI_myVmwareCasesVIP = new List<Id>();
  Public Static List<Case> BI_myVmwareCasesSLA = new List<Case>();
  /**********Variable Declairation - Before Insert Case -END*****/


         /**********Variable Declairation - After Insert Case -START*****/
  Public Static List<Case> AI_GSS_Cases = new List<Case>();
    Public Static List<Case> AI_PRM_Cases = new List<Case>();
    Public Static List<Case> AI_SFA_Cases = new List<Case>();
  Public Static Set<Id> AI_ContactSet=new Set<Id>();
  
  public static List<Case> AI_ITAppsSupport_Cases = new List<Case>();     // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
  public static List<Case> AI_GlobalOrderMgmt_Cases = new List<Case>();     // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548
    public static Map<String, String> AI_mapITAppsSupport = GSS_CaseUtils.getMapITAppsSupport();    // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
    public static Map<String, String> AI_mapGlobalOrderMgmt = GSS_CaseUtils.getmapGlobalOrderMgmt();  // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548
  
  Public Static List<Id> AI_myVmwareCasesSLA = new List<Id>();
  /**********Variable Declairation - After Insert Case -END*****/

public static String OWNERID = 'OwnerId';// Added variable declaration by Jyolsna 23-Mar-2016 CR-00138303

  /**********Method Declairation - Before Insert Case -START*****/
  /*
     * Name : updateCaseAdditionalEmails
     * Desc : Method for adding spaces between two adjacent email entries in the case field GSS_Additional_Emails__c
     * Added for CR-00052004
     */
  public static void updateCaseAdditionalEmails(List<Case> triggerNew){ 
    try{
        for (Case c : triggerNew) 
        {
            String resultStr='';
            if(c.GSS_Additional_Emails__c!=null && c.GSS_Additional_Emails__c!=''){
                resultStr = GSS_SendCustomerEmail.getUniqueEmails(c.GSS_Additional_Emails__c);
            }
            if(resultStr !=null && resultStr !=''){
                c.GSS_Additional_Emails__c = resultStr ;
            }
        }
    }
    catch(Exception e){
        system.debug('Error while adding spaces to the "Additional Email(s)" field on case');
    }
    }
  
  
  /*
     * Name : BI_ClassifyCasesByRecordType
     * Desc : Create Seperate Map for GSS , PLM and SFA cases.
     */
  public static void BI_ClassifyCasesByRecordType(List<Case> triggerNew){    
    
    Map<String, String> mapGSS = GSS_CaseUtils.getMapGSS();
     List<Case> SDP_SBScases = new List<Case>(); // Added By Nilanka for SDP 3.0
    
    Map<String, String> mapPRM = GSS_CaseUtils.getMapPRM();
    Map<String, String> mapSFA = GSS_CaseUtils.getMapSFA();
    Record_Type_Settings__c recType = Record_Type_Settings__c.getInstance('SubscriptionServices');  
    // 05-Sep-14            Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Associated cases with dummy contact/ account for Carpathia Users - Starts
    Record_Type_Settings__c carpathiaRecType = Record_Type_Settings__c.getInstance('GSS_CASE_SDP_FED'); 
    Profile_Name_Mapping__c profilerec = Profile_Name_Mapping__c.getinstance('Profile - 210 - Carpathia');
    Carpathia_Variables__c  carpathiaAccRec = Carpathia_Variables__c.getInstance('Carpathia Account');      
    Carpathia_Variables__c  carpathiaConRec = Carpathia_Variables__c.getInstance('Carpathia Contact');          
    String profileid = Userinfo.getProfileid().substring(0,15);
    // 05-Sep-14            Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Associated cases with dummy contact/ account for Carpathia Users - Ends
    String RecTypeID = recType.Record_Type_ID__c; 
    //CR-00055569 create a map of country and support level
    Map<String, String> GSS_SupportLevelMap = new Map<String, String>();
      for(GSSSupportLevel__c support : GSSSupportLevel__c.getall().values()){
          GSS_SupportLevelMap.put(support.Country__c,support.Support_Level__c);
      }

    
    
    for (Case c : triggerNew) {
    
      system.debug('case record type Id BEFORE ================'+c.RecordTypeId);
      
      if(mapGSS.containsKey(c.RecordTypeId)) {
        BI_GSS_Cases.add(c);
      } else if(mapPRM.containsKey(c.RecordTypeId)) {
        BI_PRM_Cases.add(c);
      } else if(mapSFA.containsKey(c.RecordTypeId)) {
        BI_SFA_Cases.add(c);
      }
       
    /*********** 24-Sep-2013 Added By Nilanka for SDP 3.0 First Response Due Date::::::: Starts ****************/
        
        if(RecTypeID== c.RecordTypeId && c.Region_First_Response__c!=NULL && c.Status != 'Pending Provisioning'){
            SDP_SBScases.add(c);
        } 

        //CR-00134177 - Start
        if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('PSO').getRecordTypeId()){
            ECMS_APJ_PSO_Cases_List.add(c);
        }

        //CR-00134177 - End

        /*********** 24-Sep-2013 Added By Nilanka for SDP 3.0 First Response Due Date::::::: Starts ****************/

        // 05-Sep-14            Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Associated cases with dummy contact/ account for Carpathia Users - Starts
        //system.debug('Record Type Ids are'+carpathiaRecType.Record_Type_ID__c+'%%^^'+c.RecordTypeId);
        //system.debug('Profile Id is'+profileid+'%%^^'+profilerec.Profile_Id__c);
        if(carpathiaRecType.Record_Type_ID__c==c.RecordTypeId && profileid.equals(profilerec.Profile_Id__c))
        {
            c.ContactID = carpathiaConRec.ID__c;   //Associating Carpathia cases to dummy contact and account created by Carpathia users
            c.AccountId = carpathiaAccRec.ID__c;

        }
        // 05-Sep-14            Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Associated cases with dummy contact/ account for Carpathia Users - Ends
        
        // 05-Jun-15            Mayur Srivastava        SDP Phase 9.0 | CR-00132194 | VMStar-ServiceNow FRD - Starts
        GSS_ServiceNow_Parameters__c  gssSNParameter = GSS_ServiceNow_Parameters__c.getOrgDefaults();
        if(c.Generate_ServiceNow_Inc__c == gssSNParameter.vCHS_NonSFDC__c)
        {
            c.Generate_ServiceNow_Inc__c = gssSNParameter.vCHS_SFDC__c;
        }
        if(c.Generate_ServiceNow_Inc__c == gssSNParameter.ITBM_NonSFDC__c)
        {
            c.Generate_ServiceNow_Inc__c = gssSNParameter.ITBM_SFDC__c;
        }
        // 05-Jun-15            Mayur Srivastava        SDP Phase 9.0 | CR-00132194 | VMStar-ServiceNow FRD - Ends
       // Added for My VMware 
        
       if(c.RecordTypeId==myVmwareRTITSup || c.RecordTypeId==myVmwareRTCommon) {
        BI_myVmwareCasesSupGrp.add(c);
       }
       if(c.RecordTypeId == myVmwareRTITSup) {
        BI_myVmwareCasesVIP.add(c.Id);            
        BI_myVmwareCasesSLA.add(c);            
       }          
      //End of changes for My VMware
    
      // CR-00026556 Start
      // CR-00052138 Added Tech support record type check.
      // CR-00055569 Using map instead of custom setting
      if(c.RecordTypeId==techSupport && c.GSS_Country__c !=null && GSS_SupportLevelMap.get(c.GSS_Country__c)!=null){
          c.GSS_Support_Level__c = GSS_SupportLevelMap.get(c.GSS_Country__c);
      } 
      //CR-00026556 End
              
       }

/********************************* 09-Sept-2013      Nilanka Kundu   SDP 3.0 First Response Due Date - Start ******************/
    if(!SDP_SBScases.IsEmpty())
    {
        GSS_SDPFirstResponseDueDate.calcFirstResponseDueDate(SDP_SBScases);
    }
/****************** 09-Sept-2013      Nilanka Kundu   SDP 3.0 First Response Due Date - End   *******************************/
   
  }
  
  /*
     * Name : BI_UpdateGSS_OwnerEmail
     * Desc : Method updates case owner email on GSS cases.
     */
  public static void BI_UpdateGSS_OwnerEmail(List<case> triggerNew){ //CR-00135328 added triggerNew as parameter
    GSS_CaseOwnerManager.BI_UpdateBusinessUnit(triggerNew);//CR-00131921 //CR-00135328 added triggerNew as parameter
    GSS_CaseOwnerManager.updateGSS_owner_email(BI_GSS_Cases);
  }
    /*
  * CR-00134177 - Start
  * Name : ECMS_caseCreationFromAPJ
  * Desc : Updates PSO Cases Description Field
  */
  public static void ECMS_caseCreationFromAPJ(){
  
         
      if(ECMS_APJ_PSO_Cases_List != NUll && !ECMS_APJ_PSO_Cases_List.isEmpty()){
        ECMS_ApprovalRequestUtil ecmsAppReqUtil = new ECMS_ApprovalRequestUtil();
        ecmsAppReqUtil.removeEmailTrackingLink(ECMS_APJ_PSO_Cases_List);
      }

  }
  //CR-00134177 - End
  /*
     * Name : BI_CaseRegion
     * Desc : Method updates region info. on GSS Cases.
     */
  public static void BI_CaseRegion(){
  
     GSS_CaseBusinessHours.BI_Region(BI_GSS_Cases);
  }
  
  
  /*
     * Name : BI_CaseCentre
     * Desc : Method updates Support Centre info. on GSS Cases.
     */
  public static void BI_CaseCentre(){
    
    GSS_CaseBusinessHours.BI_Center(BI_GSS_Cases);
  }
  
  /*
     * Name : BI_CaseCentre
     * Desc : Method updates Bussiness Hours info. on GSS Cases.
     */
  public static void BI_CaseBusinessHour(){
  
    GSS_CaseBusinessHours.BI_BusinessHours(BI_GSS_Cases);
  }
  
  /*
     * Name : BI_CommitDefaulter
     * Desc : Method updates commit defaulter on GSS Cases.
   * CR : 00028703
     */
  public static void BI_CommitDefaulter(){
  
    if (!BI_GSS_Cases.isEmpty() ){
      GSS_CaseOwnerManager.updateCommitDefaulter(BI_GSS_Cases);//CR-00028703 Starts
        }

  }  
  
  /*
     * Name : BI_CaseMgrEmail
     * Desc : Method updates case Owner email on GSS Cases.
   * CR : 4812
     */
  public static void BI_CaseMgrEmail(){
  
    List<Case> nonEmailToCase_GSS_Cases = new List<Case>();
    
    for(Case objCase : BI_GSS_Cases){
            if((objCase.SuppliedEmail == null || objCase.SuppliedEmail == '' )&& (objCase.SuppliedName== null || objCase.SuppliedName == '')){
                nonEmailToCase_GSS_Cases.add(objCase);
            }
        }
    
    GSS_CaseOwnerManager.BI_MgrEmail(nonEmailToCase_GSS_Cases);//Code : 4812
    
  }
  
  /*
     * Name : BI_CaseWorkLoadPoint
     * Desc : Method updates workload point on UserDate when cases assigned to a user for GSS Cases.
   * CR : 4812
     */
  public static void BI_CaseWorkLoadPoint(){
    //Start - 16-May-2016 - Jyolsna - Commented and added code for CR-00134744
    // To pass all the GSS cases to BI_WorkPoints() 
     /*List<Case> nonEmail_GSS_Cases = new List<Case>();
     //code :4812 _2 start
     for(Case objCase : BI_GSS_Cases){
            if(objCase.Origin != 'Email'){
                nonEmail_GSS_Cases.add(objCase);
            }
         }
     //code : 4812 _2 end
     if(nonEmail_GSS_Cases != null && nonEmail_GSS_Cases.size() >0) {
            
            System.debug('GSS_UpdateWPTriggerHelper.BI_WorkPoints is called..');
            GSS_UpdateWPTriggerHelper.BI_WorkPoints(nonEmail_GSS_Cases);//4812 code
         }*/
         
    GSS_UpdateWPTriggerHelper.BI_WorkPoints(BI_GSS_Cases);
     //End - 16-May-2016 - Jyolsna - Commented and added code for CR-00134744
  }
  
  
  /*
     * Name : BI_CaseOwnerQueue
     * Desc : Method - TODO .
   */
  public static void BI_CaseOwnerQueue(){
    
    GSS_CaseUtils.resetCaseOwnertoQueue(BI_GSS_Cases); 
  }
  
  /*
     * Name : BI_MyVmwareCMT
     * Desc : Method to populate support group , SLA and resolution time as part of MyVMWARE .
   */
  public static void BI_MyVmwareCMT(){
    
    //SWALEH - Adding below code for MyVMWARE CMT changes - START
    if(!BI_myVmwareCasesSupGrp.isEmpty() && BI_myVmwareCasesSupGrp.size() > 0) {
            MyVmwareHelper.populateSupportGroup(BI_myVmwareCasesSupGrp);
        }
        
        if(!BI_myVmwareCasesVIP.isEmpty() && BI_myVmwareCasesVIP.size() > 0) {
            MyVmwareHelper.markVIPCase(BI_myVmwareCasesVIP);
        }
        
        if(!BI_myVmwareCasesSLA.isEmpty() && BI_myVmwareCasesSLA.size() > 0){
             MyVMwareSLAController.populateSLA(BI_myVmwareCasesSLA);
             MyVMwareSLAController.populateResolutionTime(BI_myVmwareCasesSLA);
        }
    //SWALEH - Adding code for MyVMWARE CMT changes - END
  }
  
  /*
     * Name : BI_CaseWorkFlow
     * Desc : Case Workflow .
   */
  public static void BI_CaseWorkFlow(){
    
    GSS_WorkflowUtils.BI_CaseWorkflowRules(BI_GSS_Cases);  
  }
  
    /* Start Agent console code to update technical contact fields-CR-00122294 */
    public static void BI_PopulateTechnicalContact(List<Case> triggerNew){
  
        Map<Id,Id> CaseContactMap = new Map<Id,Id>();
        Map<Id,contact> ContactDetailMap = new Map<Id,contact>();
        Set<Id> ContactIds = new set<Id>();

        For(case c : triggerNew){
            //CR-00130456 : removing  GSS_Alternate_Contact__c,GSS_Alternate_Contact_Info__c,GSS_Preferred_Phone_Number__c,Alternate_Contact_Email__c
            if(c.ContactId!=null && c.RecordTypeId==techSupport && c.Technical_Contact_Name__c == null && c.Technical_Contact_Phone__c==null && c.Technical_Contact_Email__c == null){
                ContactIds.add(c.contactId);
                CaseContactMap.put(c.Id,c.contactId);
            }
        }
        if(ContactIDs!=null && ContactIDs.Size()>0){
            List<contact> conRec=[select Name,Phone,Email,AccountId from contact where id in :ContactIDs];
            if(conRec!= null){
                for(contact con:conRec){
                    ContactDetailMap.put(con.Id,con);
                }
            }
        }
        
        for (Case c : triggerNew){
            //CR-00130456 : removing  c.GSS_Alternate_Contact__c == null && c.GSS_Alternate_Contact_Info__c == null && c.GSS_Preferred_Phone_Number__c == null && c.Alternate_Contact_Email__c == null
            if(c.RecordTypeId==techSupport && c.Technical_Contact_Name__c == null && c.Technical_Contact_Phone__c==null && c.Technical_Contact_Email__c == null && c.ContactId != null){            
                Contact conDetails = ContactDetailMap.get(CaseContactMap.get(c.id));            
                if(conDetails!=null){        
                    c.Technical_Contact_Name__c = conDetails.name;
                    c.Technical_Contact_Phone__c = conDetails.Phone;
                    c.Technical_Contact_Email__c = conDetails.Email;
                }
                //CR-00130456 : Update technical contact phone to preferred phone number if available
                if(c.GSS_Preferred_Phone_Number__c != null){
                    c.Technical_Contact_Phone__c=c.GSS_Preferred_Phone_Number__c;                
                }                            
            }
            /***********CR-00138097 starts*******************/
            else if((c.RecordTypeId == partnerVceCase || c.RecordTypeId == vmwareVceCase)&& (c.Technical_Contact_Name__c == null && c.Technical_Contact_Phone__c == null && c.Technical_Contact_Email__c == null )){  
                    String vceEngfirstName,vceEnglastName,custFirstNAme,custLastName;
                    if(c.VCE_Prime_Engineer_First_Name__c == null){
                        vceEngfirstName = '';
                    }
                    else{
                        vceEngfirstName = c.VCE_Prime_Engineer_First_Name__c;
                    }
                    if(c.VCE_Prime_Engineer_Last_Name__c == null){
                        vceEnglastName = '';
                    }
                    else{
                        vceEnglastName = c.VCE_Prime_Engineer_Last_Name__c;
                    }
                    if(c.Customer_Contact_First_Name__c == null){
                        custFirstNAme = '';
                    }
                    else{
                        custFirstNAme = c.Customer_Contact_First_Name__c;
                    }
                    if(c.Customer_Contact_Last_Name__c == null){
                        custLastName = '';
                    }
                    else{
                        custLastName = c.Customer_Contact_Last_Name__c;
                    }
                    c.Technical_Contact_Name__c = vceEngfirstName + ' ' + vceEnglastName;
                    c.Technical_Contact_Phone__c = c.VCE_Prime_Engineer_Phone_Number__c;
                    c.Technical_Contact_Email__c = c.VCE_Prime_Engineer_Email__c;
                    
                    c.GSS_Alternate_Contact_Info__c = custFirstNAme+' '+custLastName;
                    c.GSS_Preferred_Phone_Number__c = c.Customer_Contact_Phone__c;
                    c.Alternate_Contact_Email__c = c.Customer_Contact_Email__c;
                
            }
            /***********CR-00138097 Ends*******************/
        }
    }
    /* End -CR-00122294*/ 
    /* Start CR-00039831 */
     /*
     * Name     : BI_Populate_CustomerContact
     * Desc     : Method updates Customer Contact fields for GS-SS Customer Support Cases.
     * Author   : Sakshi Suri
     */
  public static void BI_Populate_CustomerContact(List<Case> triggerNew){
        Map<Id,Id> CaseCusContactMap = new Map<Id,Id>();
        Map<Id,contact> CusContactDetailMap = new Map<Id,contact>();
        Set<Id> CusContactIds = new set<Id>();
    
    for (Case c : triggerNew){
        if(c.RecordTypeId==licCaseRT && c.Customer_Contact_Name__c!=null){
            CusContactIds.add(c.Customer_Contact_Name__c);
            CaseCusContactMap.put(c.Id,c.Customer_Contact_Name__c);
        }
    }
    if(CusContactIds!=null && CusContactIds.Size()>0){
            List<contact> conRec=[select Name,Phone,Email,AccountId from contact where Id in :CusContactIds];
            if(conRec!= null){
                for(contact con:conRec){
                    CusContactDetailMap.put(con.Id,con);
                }
            }
        }
    for (Case c : triggerNew){
            if(c.RecordTypeId==licCaseRT && c.Customer_Contact_Name__c != null && CaseCusContactMap!=null){            
                Contact conDetails = CusContactDetailMap.get(CaseCusContactMap.get(c.id));            
                if(conDetails!=null){        
                    c.Customer_Contact_Email__c = conDetails.Email;
                    c.Customer_Contact_Phone__c = conDetails.Phone;
                }                           
            }
        }
    
  }
   /* End CR-00039831 */
    
  /**********Method Declairation - Before Insert Case -END*****/

  /**********Method Declairation - After Insert Case -START*****/
  
  public static void AI_ClassifyCasesByRecordType(List<Case> triggerNew){
  
    Map<String, String> mapGSS = GSS_CaseUtils.getMapGSS();
    Map<String, String> mapPRM = GSS_CaseUtils.getMapPRM();
    Map<String, String> mapSFA = GSS_CaseUtils.getMapSFA();
     
    

    for (Case c : triggerNew) {
      system.debug('case record type Id AFTER ================'+c.RecordTypeId);
      if(mapGSS.containsKey(c.RecordTypeId)) 
      {
        AI_GSS_Cases.add(c);
        // CR-00052144 Checking if case is created by vi-hotline. Not adding to list for DCA process if it is a vi-hotline case
        if(!(c.CreatedById==caseAdminId && c.RecordTypeId==licCaseRT ))
            AI_ContactSet.add(c.ContactId);
        
      }
    if(AI_mapITAppsSupport.containsKey(c.RecordTypeId)) {  // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
                AI_ITAppsSupport_Cases.add(c);
            }
 if(AI_mapGlobalOrderMgmt.containsKey(c.RecordTypeId)) {  // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548
            AI_GlobalOrderMgmt_Cases.add(c);
        }           
      else if(mapPRM.containsKey(c.RecordTypeId)) {
        AI_SFA_Cases.add(c); //Combine SFA and PRM cases
      } else if(mapSFA.containsKey(c.RecordTypeId)) {
        AI_SFA_Cases.add(c);
      }
            
      if(c.RecordTypeId==myVmwareRTCommon){
         
        MyVMwareUpdateCaseController.UpdateCaseField(triggerNew);
        recursive.isInsertCase=true;   
        MyVMwareCaseAssignment.assignToMyVMwareQueue(triggerNew[0].id);
      
      } 
      
      if(c.RecordTypeId ==myVmwareRTITSup) {            
        AI_myVmwareCasesSLA.add(c.Id);         
      } 
          
    }       
  }
  
  //BB-8 Proj Added to avoid 101 in new contact flow - Smita
  public static void AI_DCASyncMatch_Engine(){
      if(GSS_UtilityClass.isPremierCaseCheck){
        System.debug('Calling future****AI_ContactSet***'+AI_ContactSet);
        DCASyncMatchEngine.ReprocessAccountSync_future(AI_ContactSet);
      }else{
        //For Account maping update
        DCASyncMatchEngine.ReprocessAccountSync(AI_ContactSet);
      }
  }
  
  
  public static void AI_UpdateCaseFirstResponse(){
    
    GSS_UpdateCaseFirstResponse.AI_FirstResponse(AI_GSS_Cases);    
  }
  
  public static void AI_AcctConSyncAndAvayaFuture(){
    
    if(AI_GSS_Cases != null && AI_GSS_Cases.size() > 0){
            //system.debug('GSS_Cases :: '+GSS_Cases);
            //Commented for Account management new process
           // GSS_SyncAccountContactRelation.processCaseInfo(AI_GSS_Cases);
            //CR-5302 - start
            
            
            for(Case oCase : AI_GSS_Cases){
      
        Id gssTechSupport = (Id)(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        Id CSR = (Id)(Profile_Name_Mapping__c.getInstance('Profile - 150').Profile_Id__c);
        
        if (oCase.RecordTypeId == gssTechSupport && CSR==userinfo.getProfileId()){
          GSS_Avaya_IVR.QueryPhQueue(oCase.CaseNumber);
        }
        //CR-5302 - end
      }
        }
  }
  
  public void AI_SFA_CommontriggerUtility(){
  
    List<Case> saveableCases = new List<Case>();
    List<Case> saveableCasesReportedBy = new List<Case>();
    Set<Case> caseSet = new Set<Case>();
    List<Case> tempList = new List<Case>();
    saveableCases=(CommonTriggerUtility.AI_PopFields(AI_SFA_Cases));
  update saveableCases; 
  
    //tempList.addAll(saveableCases);
  
    saveableCasesReportedBy=(CommonTriggerUtility.AI_ReportedBy(AI_SFA_Cases));//Added code for CR-00003984 
    //tempList.addAll(saveableCasesReportedBy);  
    update saveableCasesReportedBy;
    
      //Database.Saveresult[] lsr  = database.update(tempList,false);
    //CreateApexErrorLog.insertHandledExceptions(null, lsr, null, null, 'ApexClass', 'Case', 'AI_SFA_CommontriggerUtility');
 
  }
  
  public static void AI_MyVmware(Map<ID,Case> oldMap,Map<ID,Case> newMap){
    
    if(!AI_myVmwareCasesSLA.isEmpty() && AI_myVmwareCasesSLA.size() > 0){     
            // Commented By Dilip Mistry            
            CaseCalculateTimeSpentOnStatusChange.calculateTimeSpentInStatus(newMap,oldMap);         
             
        }//End of change for My Vmware  
    
  }
  
  
  public static void AI_SetCaseAssignmentOptions(List<Case> triggerNew){
    
    Boolean isUpdate = false;   // update only if SFA/PRM case  
    Util.appRecordTypeMap('Case');//Added for CR-00002432 (Single ORG CRs) on 20 October 2010
    List<Case> updateCaseList = new List<Case>();
    for (Integer i=0; i<triggerNew.size(); i++){
            //Added for CR-00002432 (Single ORG CRs) on 20 October 2010
            if( (Util.mapPRM.get(triggerNew[i].RecordTypeId) != null && Util.mapPRM.get(triggerNew[i].RecordTypeId) == 'PRM') || 
                (Util.mapSFA.get(triggerNew[i].RecordTypeId) != null && Util.mapSFA.get(triggerNew[i].RecordTypeId) == 'SFA')) {
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                triggerNew[i].setOptions(dmo);
                updateCaseList.add((Case)triggerNew[i]);
                if ( !isUpdate )
                    isUpdate = true;
            }
        }
        if (isUpdate){
            //database.update(updateCaseList);     
        }
  }
       
    /*  @description RS2_CaseClosure is method for renewal operations cases, if case is closed then send an email to distributor contact.
        @author Surbhi Tiwari
        @date 14th July, 2014
        */
       public static void rS2_CaseClosure(List<Case> triggerNew,Map<ID,Case> oldMap){
      try { 
       List<String> RS2_Cases = new List<String>();
              for (Case c : triggerNew) {
       
         Case pOld = oldMap.get(c.Id);
    
              //Modified by manu-BUG-00109732-start
              if((string.valueOf(c.RecordTypeId).substring(0,15)).equalsIgnoreCase(rct) && c.status!= pOld.status &&c.status.equalsIgnoreCase('Closed') && c.status.equalsIgnoreCase('Closed') && !(c.Sub_Status__c.equalsIgnoreCase('Customer Requested Cancellation') || c.Sub_Status__c.equalsIgnoreCase('Quote Not Created')) ){
                                   RS2_Cases.add(c.id);
                            } 
              //Modified by manu-BUG-00109732-start               
                    }
     
                      if(!RS2_Cases.IsEmpty() && !recursive.isRs2CaseClosureFlag)
                        {
                         
                         RS2_RCMCommonUtility.sendClosureEmailDistContact(RS2_Cases);
                         //CR-00110154-changed to stop multiple mail triggering-start
                         recursive.isRs2CaseClosureFlag=true;
                         //CR-00110154-changed to stop multiple mail triggering-stop           
                         
                          }
  }
  catch(Exception e){}
  }
      //End of change for RS2
    public static void servicenowfunc()
    {
        // ServiceNow Code Starts

        if(GSS_Service_Now_Configuration__c.getInstance('EnableForInsert') != null  &&
        GSS_Service_Now_Configuration__c.getInstance('EnableForInsert').Is_Active__c ){       

            List<Case> serviceNowCases = new List<Case>();
            List<Case> serviceNowITBMCases = new List<Case>();  // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5
            List<Case> SNCasesInit = new List<Case>();       // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
            SNCasesInit.addAll(AI_GSS_Cases);                   // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
            SNCasesInit.addAll(AI_ITAppsSupport_Cases);         // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
            SNCasesInit.addAll(AI_GlobalOrderMgmt_Cases);  // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548
            SNCasesInit.addAll(AI_SFA_Cases);     // Added by : Mayur Srivastava  Dated : 11/08/2013  For : CR-00066003 [SDP 3.5]              
            for(Case c : SNCasesInit){//AI_GSS_Cases){          // Modified by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
                // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   Start
                // 05-Jun-15            Mayur Srivastava        SDP Phase 9.0 | CR-00132194 | VMStar-ServiceNow FRD - Modified If and Else if condition to make it dynamic
                GSS_ServiceNow_Parameters__c  gssSNParameter = GSS_ServiceNow_Parameters__c.getOrgDefaults();
                if(c.Generate_ServiceNow_Inc__c == gssSNParameter.vCHS_SFDC__c){    
                    serviceNowCases.add(c);
                }
                else if(c.Generate_ServiceNow_Inc__c == gssSNParameter.ITBM_SFDC__c){
                    serviceNowITBMCases.add(c);
                }
                // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   End
            }

            if(!serviceNowCases.IsEmpty()){
                GSS_ServiceNowClass.processServiceCases(serviceNowCases);
            }
            // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   Start
            if(!serviceNowITBMCases.IsEmpty()){
                GSS_ServiceNowITBMClass.processServiceCases(serviceNowITBMCases);
            }
            // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   End              
        }
        // ServiceNow Code Ends  
    }
  
  // CR-00094677,CR-00110854  : Case object: Workflows migration to Trigger
    public static void ExecuteWorkflows(List<Case> triggerNew,List<Case> triggerOld,Map<ID,Case> newMap,boolean Operation){        
       Gss_WorkflowToTrigger.ExecuteWorkflows(triggerNew,triggerOld,newMap,Operation);}
    // 12-Oct-15            MSJ Ramarao             CR-00136106  Added method for Sending remainders to customer.
    public static void AI_SendRemainder(list<case> triggerNew){
        GSS_updatecaseExtension.caseExtensionInsert(triggerNew);
    }
    public static void AU_SendRemainder(list<case> triggerNew,Map<id,case> OldMap){
        GSS_updatecaseExtension.caseExtensionUpdate(triggerNew,OldMap);
    }
    // 12-Oct-15            MSJ Ramarao             CR-00136106  Added method for Sending remainders to customer.
    // 05-Sep-14           Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Added Account access for Carpathia Users - Starts
    public static void AI_CarpethiaAccountAccess(List<Case> triggerNew){
        Record_Type_Settings__c carpathiaRecType = Record_Type_Settings__c.getInstance('GSS_CASE_SDP_FED'); 
        Carpathia_Variables__c  carpathiaVar = Carpathia_Variables__c.getInstance('Carpathia Group');   
        List<Case> carpathiaCases = new List<Case>();
        List<AccountShare> accShareList = new List<AccountShare>();
        for (Case c : triggerNew) 
        {
            if(c.RecordTypeId==carpathiaRecType.Record_Type_ID__c && c.AccountId!=NULL)
            {
                //system.debug('####'+c.RecordTypeId+';;;;;'+carpathiaRecType.Record_Type_ID__c);
                carpathiaCases.add(c);
            }
        }   
        for(Case carpathiarec : carpathiaCases)
        {
            AccountShare accShare = new AccountShare();
            accShare.AccountId = carpathiarec.AccountId;
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.UserOrGroupId = carpathiaVar.ID__c;
            accShareList.add(accShare);
        }
        if(accShareList!=NULL && !accShareList.IsEmpty())
        {
            try
            {
                insert accShareList;
            }
            catch(Exception ex)
            {
                CreateGSSApexErrorLog.insertGSSErrorLogs(ex, null,null,null,'ApexClass','GSS',null,'CaseProcessing','AI_CarpethiaAccountAccess');
            }
        }
    }
    
    // 05-Sep-14           Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Added Account access for Carpathia Users - Ends
    
    // 25-Aug-15            Ashwin Dash            START - CR-00121549  Correct commit time should be sent as per the severity
    
    @future
    public static void sendingAckEmailSDP(Set<Id> newCaseSet){
    if(!newCaseSet.isEmpty()){//Changes for Optimizaton  CR-00139133 6-jun-2016 sakshi 
        List<Case> newCaseList = [SELECT id, CaseNumber, recordtypeId, ContactId, Priority, GSS_Ack_Additional_Email__c, Contact.FirstName, Contact.LastName, Account.Name, Contact.Email FROM Case WHERE Id IN : newCaseSet];
        GSS_ServiceNow_Parameters__c  gssSDPchecks = GSS_ServiceNow_Parameters__c.getOrgDefaults();
        Map<String, Carpathia_Variables__c> carpathiaVarMap = Carpathia_Variables__c.getAll();
        List<String> orgWideEmailIdTemp = System.Label.VMW_SubServSupportEmail_SDP.split(';');
        List<Messaging.SingleEmailMessage> mailbag = new List<Messaging.SingleEmailMessage>();
        Map<String, Record_Type_Settings__c> recordTypeSettingsMap = Record_Type_Settings__c.getAll();
        List<Messaging.SendEmailResult> resultMail = new List<Messaging.SendEmailResult>();
        String sendToAddresses = '';
        String body = '';
        String subject = '';
        String targetResponseHrs = '';
        String threadId = '';
        
        Map<Id,CaseMilestone> mileStoneMap = new Map<Id,CaseMilestone>();
        String Query = '';
        try{
            //List<CaseMilestone> mileStoneList = [SELECT id, CaseId, TargetResponseInHrs FROM CaseMilestone WHERE CaseId IN :newCaseSet ORDER BY CreatedDate DESC];
            if(Test.IsRunningTest()){
                Query = 'SELECT Id, completionDate, TargetResponseInHrs, CaseId, MilestoneType.Name FROM CaseMilestone WHERE MilestoneType.Name = \'First Response\'LIMIT 1';
            }else{
                Query = 'SELECT id, CaseId, TargetResponseInHrs FROM CaseMilestone WHERE CaseId IN :newCaseSet ORDER BY CreatedDate DESC';
            }
            List<CaseMilestone> mileStoneList = Database.query(Query);
            if(Test.IsRunningTest()){
                mileStoneMap.put(newCaseList[0].id, mileStoneList[0]);
            }else{
                for(CaseMilestone cm : mileStoneList){
                    mileStoneMap.put(cm.caseId, cm);
                }     
            }                    
            if(orgWideEmailIdTemp != null && !orgWideEmailIdTemp.isEmpty() && recordTypeSettingsMap != null && !recordTypeSettingsMap.isEmpty() && recordTypeSettingsMap.containsKey('GSS_CASE_SDP_FED')){            
                Map<Id,EmailTemplate> TemplateMap  = new Map<Id,EmailTemplate>([SELECT e.Body,e.Description,e.Id, e.FolderId, e.HtmlValue,e.Name, e.Subject, e.TemplateType FROM EmailTemplate e where e.Id = :orgWideEmailIdTemp[1]]);
                //System.debug('***********EMail Template Map*********** '+TemplateMap);
                if(TemplateMap!=null && !TemplateMap.isEmpty()){
                    if(Test.IsRunningTest()){
                        body = '** Please do not change the subject line of this email if you wish to respond ** \n Dear {!Contact.FirstName} {!Contact.LastName}, \n Thank you for requesting support from VMware Subscription Services Team. Your Support Request Number is {!Case.CaseNumber}. \n A VMware Subscription Services Representative will respond to your query within {!Milestone__c.Milestone__c} business hours. \n A copy of your Support Request is included at the end of this message. You may review the status of your Support Request at any time by accessing: https://my.vmware.com/group/vmware/support-requests \n My VMware dramatically improves and transforms the way you manage your VMware product licenses, support and subscription services. \n Please click on the link for more information on your subscription service: \n https://my.vmware.com/group/vmware/subscription-services \n Thank you for using VMware services. \n Sincerely, \n VMware Subscription Services Support';
                        subject = 'VMware acknowledges your Support Request #{!Case.CaseNumber} {!Case.Thread_Id}';      
                    }else{
                        body = TemplateMap.get(orgWideEmailIdTemp[1]).HtmlValue;
                        subject = TemplateMap.get(orgWideEmailIdTemp[1]).Subject;     
                    }              
                    //System.debug('***********Body*********** '+body);
                    //System.debug('***********Subject*********** '+subject);
                    if(mileStoneMap!=null && !mileStoneMap.isEmpty() && !newCaseList.isEmpty()){
                        for(Case cc : newCaseList){
                            sendToAddresses = '';
                            if(String.valueOf(cc.recordtypeId) == recordTypeSettingsMap.get('GSS_CASE_SDP_FED').Record_Type_ID__c && cc.ContactId != null && String.valueOf(cc.ContactId) != ''){           
                                if(gssSDPchecks.Is_Production__c){
                                    //system.debug('-- THIS IS PRODUCTION ENVIRONMENT --');  
                                    if(cc.Contact.Email != null && cc.Contact.Email != ''){
                                        sendToAddresses = sendToAddresses+cc.Contact.Email+';';
                                    }
                                    if(cc.GSS_Ack_Additional_Email__c != null && cc.GSS_Ack_Additional_Email__c != ''){
                                        sendToAddresses = sendToAddresses+cc.GSS_Ack_Additional_Email__c+';';
                                    }
                                }else{
                                    //system.debug('-- THIS IS SANDBOX ENVIRONMENT --');
                                    sendToAddresses = sendToAddresses + gssSDPchecks.Email_Address_1__c + ';' + gssSDPchecks.Email_Address_2__c;
                                }
                                //System.debug('*******SendToAddresses********** '+sendToAddresses);
                                if(sendToAddresses != null && sendToAddresses != ''){
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    String[] toAdd = sendToAddresses.split(';');
                                    threadId = GSS_EmailToCaseUtility.generateRefId(String.valueOf(cc.id));
                                    subject = subject.replace('{!Case.CaseNumber}',String.valueOf(cc.CaseNumber));
                                    subject = subject.replace('{!Case.Thread_Id}',threadId);
                                    if(carpathiaVarMap.get('Carpathia Contact').ID__c == String.valueOf(cc.ContactId).subString(0,15)){
                                        body = body.replace('{!Contact.FirstName}',' ');
                                    }else{
                                        body = body.replace('{!Contact.FirstName}',cc.Contact.FirstName);
                                    }                                   
                                    body = body.replace('{!Contact.LastName}',cc.Contact.LastName);
                                    body = body.replace('{!Case.CaseNumber}',cc.CaseNumber);
                                    body = body.replace('{!Milestone__c.Milestone__c}',String.valueOf(mileStoneMap.get(cc.id).TargetResponseInHrs));
                                    mail.setSubject(subject);
                                    mail.setToAddresses(toAdd);
                                    //System.debug('$$$$$$$$$TargetObjectID$$$$$$$$$$$$$$$'+cc.contactId);
                                    mail.setTargetObjectId(cc.contactId);                    
                                    mail.setWhatId(cc.id);
                                    mail.setorgWideEmailAddressId(orgWideEmailIdTemp[0]);
                                    mail.setHtmlBody(body);
                                    mail.setSaveAsActivity(false);
                                    mailbag.add(mail);  
                                    //System.debug('**************To address******** '+toAdd);
                                    //System.debug('**************Mail As is********** '+mail);
                                }
                            }
                        }
                        System.debug('**************Mail Bag********** '+mailbag);
                        if(!mailbag.isEmpty()){
                            resultMail = Messaging.sendEmail( mailbag, false );
                            String response = '';
                            if(resultMail[0].isSuccess()) {
                            response = 'ok sent!';
                            }
                            else{
                            response = resultMail[0].getErrors().get(0).getMessage();
                            }
                            //System.debug('------------resultMail---------'+resultMail);
                            //System.debug('************response************'+response);
                        }
                    }
                }
            }
        }Catch(System.EmailException emEx){
          System.debug('*****Error Caught*****'+emEx);
          CreateApexErrorLog.insertHandledExceptions(emEx, null, null, resultMail, 'ApexClass', 'Case', 'caseProcessing');
        }
        Catch(Exception e){
          System.debug('*****Error Caught*****'+e);
          CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Case', 'caseProcessing');
        }
     }//Changes for Optimizaton  CR-00139133 6-jun-2016 sakshi   
    }
      /*
     * Name     : AI_CaseExtensionCreation
     * Desc     : Method Case Extension once the case is created
     * Author   : Sakshi Suri
     * CR#      : CR-00138107
     */
    public void AI_CaseExtensionCreation(List<Case> triggerNew)
    {
    List<Case_Extension__c> caseExtList=new List<Case_Extension__c>();
    //Id Owner_Id=(GSS_Configuration_Properties_list__c.getInstance('GSS_Portal_Intergartion_User') !=null) ? Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('GSS_Portal_Intergartion_User').setting_value__c) : '00580000003lPxz';
    Id Owner_Id;
    if(GSS_Configuration_Properties_list__c.getInstance('GSS_Portal_Intergartion_User')!=null && GSS_Configuration_Properties_list__c.getInstance('GSS_Portal_Intergartion_User').setting_value__c != null){
        Owner_Id = GSS_Configuration_Properties_list__c.getInstance('GSS_Portal_Intergartion_User').setting_value__c;
    }else{
        Owner_Id = [Select Id from User where Name='GSS-Portal Integration User'].Id;
    }
        for(Case cse:triggerNew){
        if(cse.OwnerId!=Owner_Id){
        Case_Extension__c caseExtension= new Case_Extension__c();
        caseExtension.Case__C=cse.id;
        caseExtList.add(caseExtension);
        }
        }
        insert caseExtList;
    }
    
    // 25-Aug-15            Ashwin Dash             END - CR-00121549  Correct commit time should be sent as per the severity
  /**********Method Declairation - After Insert Case -END*******/
 
  
  /***********************************Start:-After Update Methods*************************************************************/
  
     public  List<Case> AU_GSS_Cases = new List<Case>();
     public  List<Case> AU_PRM_Cases = new List<Case>();
     public  List<Case> AU_SFA_Cases = new List<Case>();
     public  List<Case> AU_ITApps_Cases = new List<Case>();
     public  Boolean PopUpCase = false;
     public  List<Id> myVmwareCasesSLA = new List<Id>();
     public  set<Id> caseIdSet = new set<Id>(); // for CR 23662
   /*Start:-CR-00043484-Optimization: Bulkification of MyVmware Case Variables added*/
     public  List<Case> lsMyVmwareCases= new List<Case>(); 
     public  Map<Id,Case> mapNewCases=new Map<Id,Case>();
     public  Map<Id,Case> mapOldCases=new Map<Id,Case>();
     /*END:-CR-00043484-Optimization: */
     public  List<Case> CaseWithUpdatedOwner = new List<Case>();
     public  Id rtGSSPartnerVCECase = (Id)(VCEStatic__c.getInstance('VCECaseRecordType').value__c);
   public  void afterUpdateCaseInitialization(List<Case> triggerNew, List<Case> triggerOld,Map<Id,Case>triggerOldMap)
   {
    
        for (Case c : triggerNew)
        {
          
          if(c.GSS_ScreenPopTime__c!=null && newdate < c.GSS_ScreenPopTime__c) {
            PopUpCase = true;
            AU_GSS_Cases.add(c);
            }
            else{
            Map<String, String> mapGSS = GSS_CaseUtils.getMapGSS();
            Map<String, String> mapPRM = GSS_CaseUtils.getMapPRM();
            Map<String, String> mapSFA = GSS_CaseUtils.getMapSFA();
    
                if(mapGSS.containsKey(c.RecordTypeId)) {
                  AU_GSS_Cases.add(c);
                } else if(mapPRM.containsKey(c.RecordTypeId)) {
                  AU_PRM_Cases.add(c);
                } else if(mapSFA.containsKey(c.RecordTypeId)) {
                  AU_SFA_Cases.add(c);
                }else if(c.recordTypeId==myVmwareRTITSup) {
                  AU_ITApps_Cases.add(c);
                }
            
            
            }
            
                 /*Start:-CR-00043484-Optimization: Bulkification of MyVmware Case */
               if(c.recordTypeId==myVmwareRTITSup  ){
              if(c.Count_Comments__c>triggerOldMap.get(c.id).Count_Comments__c)
              {
              lsMyVmwareCases.add(c);
              }
              myVmwareCasesSLA.add(c.Id); 
              mapNewCases.put(c.Id,c);
              mapOldCases.put(c.Id,triggerOldMap.get(c.id));
              }
                           /*End:-CR-00043484-Optimization: Bulkification of MyVmware Case */   
                
                           /*Start:-CR-00043484-Optimization:Added Code in Existing For Loop.*/    
               string txtcID = c.ownerId;
               Case oldCase = triggerOldMap.get(c.ID);
               if (c.OwnerId != oldCase.OwnerId && c.RecordTypeId==rtGSSPartnerVCECase && (!txtcID.startsWith('OOG')) ) {
               CaseWithUpdatedOwner.add(c); }
                             /*End:-CR-00043484-Optimization: :Added Code in Existing For Loop.*/   
              
              
              
            
          }
    
    
    
  }

   
   public  void VCECaseHandling(List<Case> triggerNew, List<Case> triggerOld,Map<Id,Case>triggerOldMap)
   {
    if(!PopUpCase)
     {
       // Added code for CR-00013381 and BUG-00039937 - Start   
          VCE_UtilityClass.AU_VCECaseUpdates(triggerNew,triggerOldMap);    
        // Added code for CR-00013381 and BUG-00039937 - End
     }
   
   }
   
   public void processCaseEmailAndFR(List<Case> triggerNew,List<Case> triggerOld,Map<Id,Case>triggerOldMap)
   {
    
    if(!PopUpCase)
     {
       //  CR-00006251 Starts: this method need to be called before future call so dont move this to anywhere else.  
        if(GSS_UtilityClass.IsTAMMailSent){
        GSS_Caseaccount_notified.processCasesToSendEmailAM(triggerNew);   
        }
         //  CR-00006251 Ends
   
          GSS_UpdateCaseFirstResponse.AU_FirstResponse(AU_GSS_Cases,triggerOldMap);
     }
   
   }
   
  //START : By Pabitra CR-00137607
  public void calculateCasePhoneQ(Map<Id,Case>triggerOldMap){
     String isNewRunCheck='';
      if( GSS_Configuration_Properties_list__c.getInstance('isNewRunCheck') != null){
          isNewRunCheck = GSS_Configuration_Properties_list__c.getInstance('isNewRunCheck').Setting_value__c.toLowercase();
      }
    //CR-00140109 : Removed System.debug.
      //System.debug('isNewRunCheck:'+isNewRunCheck);
      //Running the previous code if isNewRunCheck not = true else new one
      if(isNewRunCheck != 'true'){
        System.debug('Running Previous Code');
      if(!PopUpCase){
        //CR-5302 start
        for(Case oCase : AU_GSS_Cases){
      
        Id gssTechSupport = (Id)(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        Id CSR = (Id)(Profile_Name_Mapping__c.getInstance('Profile - 150').Profile_Id__c);
          
        if (oCase.RecordTypeId == gssTechSupport && CSR==userinfo.getProfileId()){
          if(
            (oCase.priority!=triggerOldMap.get(oCase.id).priority)
            ||(oCase.GSS_Product_Name__c!=triggerOldMap.get(oCase.id).GSS_Product_Name__c)
            ||(oCase.GSS_Entitlement_Code__c!=triggerOldMap.get(oCase.id).GSS_Entitlement_Code__c)
            ||(oCase.GSS_Problem_Category__c!=triggerOldMap.get(oCase.id).GSS_Problem_Category__c)
            ||(ocase.GSS_Support_Customer_Region__c!=triggerOldMap.get(oCase.id).GSS_Support_Customer_Region__c)
            ||(ocase.GSS_Center__c!=triggerOldMap.get(oCase.id).GSS_Center__c)){
            GSS_Avaya_IVR.QueryPhQueue(oCase.CaseNumber);
                    }            
        }
        }
        //CR-5302 end
      
       }
    
     }   

else {
    //CR-00140109 : Removed System.debug.
        //System.debug('Running New Code');
        if(!PopUpCase){
            //Fetching all the case fields from custom setting
            List<GSS_PhoneQ_Calculating_Fields__c> caseFieldList = GSS_PhoneQ_Calculating_Fields__c.getall().values();
            
            //Fetching the recordtypeid of technical support record type.
            Id gssTechSupport = (Id)(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
            
            //Start : Creating a set containing all the GSS Profileid.
            Set<ID> profileIdSet = new Set<ID>();
            List<GSS_PhoneQ_Calculating_Profiles__c> allProfileList = GSS_PhoneQ_Calculating_Profiles__c.getall().values();         
            if(allProfileList != null && allProfileList.size() >0){
                for(GSS_PhoneQ_Calculating_Profiles__c prof : allProfileList){
                        profileIdSet.add(ID.valueof(prof.Profile_Id__c));
                }
            }
            //End : Creating a set containing all the GSS Profileid.
            
            //Start: Processing for each case having technical support record typeid and user
            //profile is one of the GSS profile.
            String fieldName;
            for(Case oCase : AU_GSS_Cases){
                if (gssTechSupport != null && oCase.RecordTypeId == gssTechSupport && profileIdSet.size() > 0 && profileIdSet.contains(userinfo.getProfileId())){
                    if(caseFieldList != null && caseFieldList.size() > 0 ){
                        for(GSS_PhoneQ_Calculating_Fields__c caseField : caseFieldList){
                            fieldName = String.valueof(caseField.field_api_name__c);
                            if((oCase.get(fieldName)!=triggerOldMap.get(oCase.id).get(fieldName))){
                                GSS_Avaya_IVR.QueryPhQueue(oCase.CaseNumber);
                                break;
                            }
                        }
                    }
                }
            }
            //End: Processing for each case having technical support record typeid and user
            //profile is one of the GSS profile.
       }  
      }
    }
    //END : By Pabitra CR-00137607
  
  public  void autoCloseAssistRequestOnCaseClosure()
   {
      if(!PopUpCase)
        {
         //************************CR 23662 -- START -- To Auto Close Assist Requests on case closure ************************
         for(case cObj : AU_GSS_Cases ){
          if((cObj.status!= null && cObj.status!='')&&(cObj.status.equalsIgnoreCase('Closed') || cObj.isClosed == true)){
            caseIdSet.add(cObj.id); 
           }           
        }
        //Call a method to retrieve all the open with status as Delivered Auto Assist Requests to close.
        if(!caseIdSet.isEmpty()){
           GSS_UtilityClass.assistRequestStatusChange(caseIdSet);
        }        
        //*************************************** CR 23662 STOP *********************************************************  
        }
     }
   
   
   public  void SFACommonTriggerUtility(List<Case> triggerNew,List<Case> triggerOld,Map<Id,Case>triggerNewMap,Map<Id,Case>triggerOldMap)
   {
    //combine SFA & PRM cases
    AU_SFA_Cases.addAll(AU_PRM_cases);

    //objects to save
    List<Case> saveableCases1 = new List<Case>();
    List<Case> saveableCases2 = new List<Case>();
    List<Case> saveableCases3 = new List<Case>();
    Set<Id> SFA_caseIdSet = new Set<Id>();
    List<Case> tempList = new List<Case>();
    //List<Case> lsFinalsaveableCases3 = new List<Case>();
     if(!PopUpCase )
        {
        
          
          
          saveableCases1.addAll(CommonTriggerUtility.AU_PopFields(AU_SFA_Cases, triggerOldMap));
          saveableCases2.addAll(CommonTriggerUtility.AU_ReportedBy(AU_SFA_Cases, triggerOldMap));
          
          if(AU_ITApps_Cases.size()>0 && AU_ITApps_Cases!=null){
                saveableCases3.addAll(CommonTriggerUtility.AU_PopFields(AU_ITApps_Cases, triggerOldMap));
          }
          recursive.ispopulateCaseFields = false;
          update saveableCases3;

            //tempList.addAll(saveableCases3);
            //CR-00006745 - start    
            GSS_AutoAvailable.autoAvailable(AU_GSS_Cases,triggerOldMap);    
            //for CR-00006745 - end
            update saveableCases1;
           // tempList.addAll(saveableCases1);
       //CR-00140109 : Removed System.debug.
           //System.debug('Amar:AfterUpdate_Case--end');
            update saveableCases2;
           //tempList.addAll(saveableCases2);

           //Database.Saveresult[] lsr  = database.update(tempList,false);
           //CreateApexErrorLog.insertHandledExceptions(null, lsr, null, null, 'ApexClass', 'Case', 'SFACommonTriggerUtility');

        
      
      }
   }
  
  public void myVmWareCaseUpdate()
   {
             //Added code for MY VMware           
        MyVMwareUpdateCaseController.UpdateCase(lsMyVmwareCases);
              if(!mapNewCases.isEmpty() && !mapOldCases.isEmpty() ){
              CaseCalculateTimeSpentOnStatusChange.calculateTimeSpentInStatus(mapNewCases, mapOldCases);
        //End code for MY VMware
        }
   }
  
  /* BUG-00039937
    * Author : Shashvat Mahendru 
    * Description : Updates Task owner From Case Owner
   */ 
  public void VCETaskOwnerUpdate()
   {
   
     if(!CaseWithUpdatedOwner.isEmpty() && CaseWithUpdatedOwner.size()>0){ // Added by :Shashvat Mahendru Dated : 10/1/2012 BUG-00042810
     VCE_UtilityClass.VCEUpdateTaskOwnerFromCaseOwner(CaseWithUpdatedOwner);
   }
}

 /* Name: filterCaseswithServiceDesc
  * Desc: filters cases which need to be processed for copying the Service Description feild to Case Comment, and sends them to the method GSS_CaseUtils.insertCaseCommentsforServiceDesc
  * Author: Hemangini   Created for CR-00037368
  */ 
  public void filterCaseswithServiceDesc(Map<Id,Case> triggerOldMap){
        
    GSS_CaseUtils.insertCaseCommentsforServiceDesc(triggerOldMap, AU_GSS_Cases);
    }
 
    // 05-Sep-14           Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Added Account access for Carpathia Users - Starts
    public static void AU_CarpethiaAccountAccess(List<Case> triggerNew, List<Case> triggerOld,Map<Id,Case>triggerNewMap,Map<Id,Case>triggerOldMap){
        Record_Type_Settings__c carpathiaRecType = Record_Type_Settings__c.getInstance('GSS_CASE_SDP_FED'); 
        Carpathia_Variables__c  carpathiaVar = Carpathia_Variables__c.getInstance('Carpathia Group');   
        List<Case> carpathiaCases = new List<Case>();       
        List<AccountShare> accShareList = new List<AccountShare>();
        Set<Id> carpathiaAccId = new Set<Id>();
        for (Case c : triggerNew) 
        {
            if(c.RecordTypeId==carpathiaRecType.Record_Type_ID__c && c.AccountId!=NULL && triggerOldMap.get(c.id).AccountId!=triggerNewMap.get(c.id).AccountId)
            {
                //system.debug('####'+c.RecordTypeId+';;;;;'+carpathiaRecType.Record_Type_ID__c);
                carpathiaCases.add(c);
                carpathiaAccId.add(triggerOldMap.get(c.id).AccountId);
            }
        }   
        for(Case carpathiarec : carpathiaCases)
        {
            AccountShare accShare = new AccountShare();
            accShare.AccountId = carpathiarec.AccountId;
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.UserOrGroupId = carpathiaVar.ID__c;
            accShareList.add(accShare);                                 
        }
        List<AccountShare> accShareRec = new List<AccountShare>();
        if(carpathiaAccId!=NULL && !carpathiaAccId.IsEmpty())
            accShareRec = [Select Id, AccountId, UserOrGroupId from AccountShare where AccountId IN:carpathiaAccId and UserOrGroupId=:carpathiaVar.ID__c and RowCause='Manual'];
        
        try
        {
            if(accShareList!=NULL && !accShareList.IsEmpty())
                insert accShareList;
            if(accShareRec!=NULL && !accShareRec.IsEmpty())
                delete accShareRec;         
        }
        catch(Exception ex)
        {
            CreateGSSApexErrorLog.insertGSSErrorLogs(ex, null,null,null,'ApexClass','GSS',null,'CaseProcessing','AU_CarpethiaAccountAccess');
        }
    }
    // 05-Sep-14           Mayur Srivastava        SDP 6.0 Carpathia | CR-00102154 | Added Account access for Carpathia Users - Ends
 
   //CR-00067087 - Adding fields to be tracked to the new object
  public static void InsertDataInCaseHistory(Map<ID,Case> oldMap,Map<ID,Case> newMap,String Operation){
      try{
            //Declaring local variables to be used
            List<ObjectHistoryTracker__c> HistoryTrackerList = new List<ObjectHistoryTracker__c>();     
            List<HistoryTrackingSetting__c> FieldTrackingList = HistoryTrackingSetting__c.getall().values();
            Map<String,HistoryTrackingSetting__c> FieldTrackingMap = new Map<String,HistoryTrackingSetting__c>();
            
            //Iterating all the CustomSettings for Case object and populating FieldTrackingMap
            if(FieldTrackingList!=null && FieldTrackingList.size()>0){ 
                for(HistoryTrackingSetting__c ht : FieldTrackingList){
                    if(ht.Object__c=='Case'){
                    //0th value contains the Api name of the field and 1st has the field label
                        FieldTrackingMap.put(ht.ApiFieldName__c,ht);
                    }
                }                
            }
            
            //Block for Insert Operation
            if(Operation == 'IsInsert' && newMap!=null && FieldTrackingMap.size()>0){
                for(Case c : newMap.values()){
                    sObject csnew = c; //Casting the newMap Case record to SObject     
                    
                    //Iterate over the FieldTrackingMap(i.e list of api fields)                          
                    for(String s : FieldTrackingMap.keyset()){
            //Modified below condition by Jyolsna 23-Mar-2016  CR-00138303
                        if(csnew.get(s)!=null && s.equalsIgnoreCase(OWNERID) && recursive.caseOwnerChange == false ){ //if the tracking field is not null call CreateCaseHistoryTracker method
                            ObjectHistoryTracker__c ht = CreateCaseHistoryTracker(csnew,null,s,Operation,FieldTrackingMap);      
                            HistoryTrackerList.add(ht);
                        }
                    }
                }
            //Block for Update Operation    
            }else if(Operation == 'IsUpdate' && newMap!=null && oldMap!=null && FieldTrackingMap.size()>0){
                for(Case c : newMap.values()){
                    sObject csnew = c; //Casting the newMap Case record to SObject
                    
                    Case cOld = oldMap.get(c.Id);
                    sObject csold = cOld; //Casting the oldMap Case record to SObject
                    
                    //Iterate over the FieldTrackingMap(i.e list of api fields)
                    for(String s : FieldTrackingMap.keyset()){                        
             //Modified below condition by Jyolsna 23-Mar-2016  CR-00138303                        
                        if(csnew.get(s)!=csold.get(s) && s.equalsIgnoreCase(OWNERID) && recursive.caseOwnerChange == false){ //if the tracking field value is not equals to previous value call CreateCaseHistoryTracker method
                            ObjectHistoryTracker__c ht = CreateCaseHistoryTracker(csnew,csold,s,Operation,FieldTrackingMap);
                            System.Debug('*********ht**********'+ht);
                            HistoryTrackerList.add(ht);  
                            System.Debug('*********HistoryTrackerList**********'+HistoryTrackerList);                           
                        }
                    }
                }   
            }
            //insert HistoryTrackerList list
            if(HistoryTrackerList.size()>0){
                Database.SaveResult[] sr = Database.insert(HistoryTrackerList,false);
        recursive.caseOwnerChange = true;//Added by Jyolsna 23-Mar-2016  CR-00138303
            }
        }catch(Exception e){}
  }
  
  //This method creates and returns the instance of ObjectHistoryTracker__c for field histroy tracking using new and old map values
  public static ObjectHistoryTracker__c CreateCaseHistoryTracker(SObject csnew,SObject csold,String Field,String Operation,Map<String,HistoryTrackingSetting__c> FieldTrackingMap){
        
        ObjectHistoryTracker__c ht = new ObjectHistoryTracker__c();      
            String NewVal ='';
            String OldVal ='';
            String DataType = FieldTrackingMap.get(Field).DataType__c;
            ht.Object__c = 'Case';
            ht.ObjectId__c = csnew.Id;
            ht.CreatedBy__c = Userinfo.getUserId();
            ht.CreatedDate__c = system.now();
            ht.Field__c = FieldTrackingMap.get(Field).FieldLabel__c;
            
            //CR-00107561: Populating NewValueLong field in each scenario
            if(DataType.equalsIgnoreCase('Boolean')){
                ht.NewValue__c = String.Valueof((boolean)csnew.get(Field));
                ht.NewValueLong__c = String.Valueof((boolean)csnew.get(Field));
            }else if(DataType.equalsIgnoreCase('Number')){
                ht.NewValue__c = String.Valueof((Decimal)csnew.get(Field));
                ht.NewValueLong__c = String.Valueof((Decimal)csnew.get(Field));
            }else if(DataType.equalsIgnoreCase('DateTime')){
                ht.NewValue__c = String.Valueof((DateTime)csnew.get(Field));
                ht.NewValueLong__c = String.Valueof((DateTime)csnew.get(Field));
            }else{
                NewVal=(String)csnew.get(Field);
                if(NewVal.length() < 256){
                    ht.NewValue__c = NewVal;
                    ht.NewValueLong__c = NewVal;
                }else{
                    ht.NewValue__c = NewVal.substring(0,244)+'..[trimmed]';
                    ht.NewValueLong__c = NewVal;
                }
            }
            
            
            //Value of field for insert is null for oldvalue field
            //CR-00107561: Populating NewValueLong field in each scenario
            if(Operation=='IsInsert'){
                ht.OldValue__c = '';
                ht.OldValueLong__c = '';
            }else{//Value of field for insert is based on oldmap for oldvalue field
                if(csold==null || csold.get(Field)==null){
                    ht.OldValue__c = '';
                    ht.OldValueLong__c= '';
                }else{
                    if(DataType.equalsIgnoreCase('Boolean')){
                        ht.OldValue__c = String.Valueof((boolean)csold.get(Field));
                        ht.OldValueLong__c = String.Valueof((boolean)csold.get(Field));
                    }else if(DataType.equalsIgnoreCase('Number')){
                        ht.OldValue__c = String.Valueof((Decimal)csold.get(Field));
                        ht.OldValueLong__c = String.Valueof((Decimal)csold.get(Field));
                    }else if(DataType.equalsIgnoreCase('DateTime')){
                        ht.OldValue__c = String.Valueof((DateTime)csold.get(Field));
                        ht.OldValueLong__c = String.Valueof((DateTime)csold.get(Field));
                    }else{
                        OldVal=(String)csold.get(Field);
                        if(OldVal.length() < 256){
                            ht.OldValue__c = OldVal;
                            ht.OldValueLong__c = OldVal;
                        }else{
                            ht.OldValue__c = OldVal.substring(0,244)+'..[trimmed]';
                            ht.OldValueLong__c = OldVal;
                        }
                    }
                }
            }
        
        return ht; //return the ObjectHistoryTracker instance
  }
  //CR-00067087 - End of CR 
  
  
    //GSS AGENT CODE START
    public void AU_TechnicalContactTracker(Map<ID,Case> oldMap, List<Case> triggerNew){
        try{
            List<GSS_Technical_Contact__c> techConList = new List<GSS_Technical_Contact__c>();
            for (Case c : triggerNew){
                Case oldCase = oldMap.get(c.ID);
                //15-Jun-2016 - Jyolsna - CR-00138097 - Create addtional technical contact history for Vce case
                if((c.RecordTypeId==techSupport || c.RecordTypeId == partnerVceCase || c.RecordTypeId == vmwareVceCase) && (c.Technical_Contact_Name__c != oldCase.Technical_Contact_Name__c || c.Technical_Contact_Email__c!= oldCase.Technical_Contact_Email__c||c.Technical_Contact_Phone__c!= oldCase.Technical_Contact_Phone__c)){
                        GSS_Technical_Contact__c gts = new GSS_Technical_Contact__c();
                        gts.Case__c=c.id;
                        gts.Additional_Technical_Contact_Email__c=c.Technical_Contact_Email__c;
                        gts.Additional_Technical_Contact_Name__c=c.Technical_Contact_Name__c;
                        gts.Additional_Technical_Contact_Phone__c=c.Technical_Contact_Phone__c;
                        techConList.add(gts);
                }       
                 //Starts Sakshi
                if(UserInfo.getProfileId()==prfID.PremeirProfileId__c){
                    //CR-00139057 - Jyolsna -  Added blank check so that it wont create GSS_Technical_Contact__c record with blank values
                    if(!String.isBlank(c.GSS_Third_Party_Contact_Name__c) || !String.isBlank(c.GSS_Third_Party_Email_Phone__c)|| !String.isBlank(c.GSS_Third_Party_Ticket__c)){
                        if(c.RecordTypeId==techSupport && (c.GSS_Third_Party_Contact_Name__c != oldCase.GSS_Third_Party_Contact_Name__c || c.GSS_Third_Party_Email_Phone__c!= oldCase.GSS_Third_Party_Email_Phone__c||c.GSS_Third_Party_Ticket__c!= oldCase.GSS_Third_Party_Ticket__c)){
                        System.debug('Entered Partner contact block');
                                GSS_Technical_Contact__c gts = new GSS_Technical_Contact__c();
                                gts.Case__c=c.id;
                                gts.GSS_Third_Party_Email_Phone__c=c.GSS_Third_Party_Email_Phone__c;
                                gts.Additional_Technical_Contact_Name__c=c.GSS_Third_Party_Contact_Name__c;
                                gts.GSS_Third_Party_Ticket__c=c.GSS_Third_Party_Ticket__c;
                                gts.IsPartnerContact__c=true;
                                techConList.add(gts);
                        }
                    }
                }
                //Ends Sakshi
            }
            database.insert(techConList,false);
        }catch (exception e){
            
        }
    }
    
    public void AI_TechnicalContactTracker(List<Case> triggerNew){
        try{
            List<GSS_Technical_Contact__c> techConList = new List<GSS_Technical_Contact__c>();
            for (Case c : triggerNew){  
                //15-Jun-2016 - Jyolsna - CR-00138097 - Create addtional technical contact history for Vce case         
                if((c.RecordTypeId==techSupport || c.RecordTypeId == partnerVceCase || c.RecordTypeId == vmwareVceCase) && ((c.Technical_Contact_Name__c != '' && c.Technical_Contact_Name__c != null) || (c.Technical_Contact_Email__c!= '' && c.Technical_Contact_Email__c!= null) || (c.Technical_Contact_Phone__c!= '' && c.Technical_Contact_Phone__c!= null))){
                        GSS_Technical_Contact__c gts = new GSS_Technical_Contact__c();
                        gts.Case__c=c.id;
                        gts.Additional_Technical_Contact_Email__c=c.Technical_Contact_Email__c;
                        gts.Additional_Technical_Contact_Name__c=c.Technical_Contact_Name__c;
                        gts.Additional_Technical_Contact_Phone__c=c.Technical_Contact_Phone__c;
                        techConList.add(gts);
                }       
                //CR-00138257 Starts Sakshi
                 if(UserInfo.getProfileId()==prfID.PremeirProfileId__c){
                    if(c.RecordTypeId==techSupport && ((c.GSS_Third_Party_Contact_Name__c != '' && c.GSS_Third_Party_Contact_Name__c != null) || (c.GSS_Third_Party_Ticket__c!= '' && c.GSS_Third_Party_Ticket__c!= null) || (c.GSS_Third_Party_Email_Phone__c!= '' && c.GSS_Third_Party_Email_Phone__c!= null))){
                        GSS_Technical_Contact__c gts = new GSS_Technical_Contact__c();
                        gts.Case__c=c.id;
                        gts.GSS_Third_Party_Email_Phone__c=c.GSS_Third_Party_Email_Phone__c;
                        gts.Additional_Technical_Contact_Name__c=c.GSS_Third_Party_Contact_Name__c;
                        gts.GSS_Third_Party_Ticket__c=c.GSS_Third_Party_Ticket__c;
                        gts.IsPartnerContact__c=true;
                        techConList.add(gts);
                } 
              }  //CR-00138257 Ends Sakshi   
            }
            database.insert(techConList,false);
        }catch (exception e){
            
        }
    }
    
      /**
      * @param Map<Id, Case> triggerNewMap
      * @param Map<Id, Case> triggerOldMap 
      * @return void
      * @CR CR-00006501
      * @Author Inshu Misra
      * This method is used to create/update send_alert_task if the status of Partner Network Cases changes to 'New', 'Re-Opened', 'In-Progress', 'Triaged' or 'Assigned'
      **/
    
    public void AI_createEmailTask(Map<Id, Case> triggerNewMap, Map<Id, Case> triggerOldMap){
        List<Task> taskListInsertion = new List<Task>();
        Map<Id, Task> taskListUpdation = new Map<Id, Task>();
        String Case_PN_RecordType = Record_Type_Settings__c.getInstance('SFA_Case_PN').Record_Type_ID__c;
        String Task_sendAlert_RecordType = Record_Type_Settings__c.getInstance('SFA_Task_SendAlert').Record_Type_ID__c;
        String name = SFA_Send_Alert_Task_Properties__c.getInstance('UserName').value__c;
        Set<Id> caseIdLists = new Set<Id>();
        
        if(triggerNewMap != null && triggerNewMap.values() != null && triggerNewMap.values().size() > 0){
            for(Case caseId: triggerNewMap.values()){
                if(Case_PN_RecordType != null && caseId.RecordTypeId == Case_PN_RecordType){
                    caseIdLists.add(caseId.Id);
                }
            }
        }
        Map<Id, Task> taskMap = null;
        Map<Id, CaseComment> ccMap = null;
        Map<Id, EmailMessage> emMap = null;
        if (Trigger.isInsert){
            for(Case newCase:triggerNewMap.values()){
                if(newCase.RecordTypeId == Case_PN_RecordType && (newCase.Status == 'New' || newCase.Status == 'In Progress' || newCase.Status == 'Triaged' || newCase.Status == 'Assigned' || newCase.Status == 'Re-opened')){
                    Task newTask = CaseProcessing.createTask(newCase, Task_sendAlert_RecordType);
                    taskListInsertion.add(newTask);
                }
            }
        }
        if (Trigger.isUpdate && GSS_CaseUpdateUtilityClass.caseUpdatedOnce == false){
            if(caseIdLists != null && caseIdLists.size()>0){
                taskMap = new Map<Id, Task>([select Id, RecordTypeId, Summary__c, Status, CreatedDate, WhatId from Task where WhatId in: caseIdLists and Status = 'New' and RecordTypeId =: Task_sendAlert_RecordType]);
                ccMap = new Map<Id, CaseComment>([select Id, LastModifiedDate, CreatedById, ParentId from CaseComment where ParentId in: caseIdLists]);
                emMap = new Map<Id, EmailMessage>([select Id, MessageDate, ParentId, Incoming, FromName from EmailMessage where ParentId in: caseIdLists and Incoming = false]);
            }
            for(Case newCase : triggerNewMap.values()){
                if(newCase.RecordTypeId == Case_PN_RecordType && triggerOldMap.get(newCase.Id) != null){
                    
                    if(!(triggerOldMap.get(newCase.Id).Status == 'New' || triggerOldMap.get(newCase.Id).Status == 'In Progress' || triggerOldMap.get(newCase.Id).Status == 'Triaged' || triggerOldMap.get(newCase.Id).Status == 'Assigned' || triggerOldMap.get(newCase.Id).Status == 'Re-opened')){
                         if((newCase.Status == 'New' || newCase.Status == 'In Progress' || newCase.Status == 'Triaged' || newCase.Status == 'Assigned' || newCase.Status == 'Re-opened') && newCase.IsEscalated == false){
                            Task newTask = CaseProcessing.createTask(newCase, Task_sendAlert_RecordType);
                            taskListInsertion.add(newTask);
                         }
                    } else if ((triggerOldMap.get(newCase.Id).Status == 'New' || triggerOldMap.get(newCase.Id).Status == 'In Progress' || triggerOldMap.get(newCase.Id).Status == 'Triaged' || triggerOldMap.get(newCase.Id).Status == 'Assigned' || triggerOldMap.get(newCase.Id).Status == 'Re-opened')){
                        if((triggerOldMap.get(newCase.Id).Status != newCase.Status)){
                            if(newCase.IsEscalated == false){
                                if(!(newCase.Status == 'New' || newCase.Status == 'In Progress' || newCase.Status == 'Triaged' || newCase.Status == 'Assigned' || newCase.Status == 'Re-opened')){
                                    for(Task oldTask : taskMap.values()){
                                        if(oldTask.WhatId == newCase.Id && oldTask.RecordTypeId == Task_sendAlert_RecordType){
                                            oldTask.Status = 'Completed';
                                            oldTask.Summary__c = 'Case status was changed';
                                            taskListUpdation.put(oldTask.Id, oldTask);
                                            break;
                                        }
                                    }
                                } else if(newCase.Status == 'New' || newCase.Status == 'In Progress' || newCase.Status == 'Triaged' || newCase.Status == 'Assigned' || newCase.Status == 'Re-opened'){
                                    for(Task oldTask : taskMap.values()){
                                        if(oldTask.WhatId == newCase.Id && oldTask.RecordTypeId == Task_sendAlert_RecordType){
                                            oldTask.Status = 'Completed';
                                            oldTask.Summary__c = 'Case status was changed';                                        
                                            taskListUpdation.put(oldTask.Id, oldTask);
                                            break;
                                        }
                                    }
                                    Task newTask = CaseProcessing.createTask(newCase, Task_sendAlert_RecordType);
                                    taskListInsertion.add(newTask);
                                }
                            }else if(triggerOldMap.get(newCase.Id).IsEscalated == false){
                                for(Task oldTask : taskMap.values()){
                                    if(oldTask.WhatId == newCase.Id && oldTask.RecordTypeId == Task_sendAlert_RecordType){
                                        oldTask.Status = 'Completed';
                                        oldTask.Summary__c = 'Case was escalated for different reasons';
                                        taskListUpdation.put(oldTask.Id, oldTask);
                                        break;
                                    }
                                }
                            }
                        }else{
                            if(triggerOldMap.get(newCase.Id).IsEscalated == true && newCase.IsEscalated == false){
                                Task newTask = CaseProcessing.createTask(newCase, Task_sendAlert_RecordType);
                                taskListInsertion.add(newTask);
                            } 
                            for(Task oldTask : taskMap.values()){
                                Boolean caseCommentUpdated = false;
                                Boolean emailMessageSent = false;
                                if(oldTask.WhatId == newCase.Id && oldTask.RecordTypeId == Task_sendAlert_RecordType){
                                    Decimal taskCreatedTime = Decimal.valueof((oldTask.CreatedDate.getTime())/(60*60))/1000;
                                    for(CaseComment cc : ccMap.values()){
                                        Decimal ccCreatedTime = Decimal.valueof((cc.LastModifiedDate.getTime())/(60*60))/1000;
                                        if(newCase.Id == cc.ParentId && cc.CreatedById == newCase.OwnerId && ccCreatedTime >= taskCreatedTime){
                                            caseCommentUpdated = true;
                                            break;
                                        }
                                    }
                                    for (EmailMessage em : emMap.values()){
                                        Decimal emCreatedTime = Decimal.valueof((em.MessageDate.getTime())/(60*60))/1000;
                                        if(newCase.Id == em.ParentId && emCreatedTime >= taskCreatedTime && em.fromName != name){
                                            emailMessageSent = true;
                                            break;
                                        }
                                    }
                                    if(caseCommentUpdated == true || emailMessageSent == true || (triggerOldMap.get(newCase.Id).IsEscalated == false && newCase.IsEscalated == true && newCase.Escalation_Reason__c != 'Case was inactive for more than 96 hours')){
                                        oldTask.Status = 'Completed';
                                        if(newCase.IsEscalated == false){
                                            if(caseCommentUpdated == true){
                                                oldTask.Summary__c = 'Case comment was added to the Case by Case Owner or Email was sent from the Case';                                        
                                                taskListUpdation.put(oldTask.Id, oldTask);
                                                Task newTask = CaseProcessing.createTask(newCase, Task_sendAlert_RecordType);
                                                taskListInsertion.add(newTask);
                                                break;
                                            }
                                            else if(emailMessageSent == true){
                                                oldTask.Summary__c = 'Case comment was added to the Case by Case Owner or Email was sent from the Case';                                        
                                                taskListUpdation.put(oldTask.Id, oldTask);
                                                Task newTask = CaseProcessing.createTask(newCase, Task_sendAlert_RecordType);
                                                taskListInsertion.add(newTask);
                                                break;
                                            }
                                        }else {
                                            oldTask.Summary__c = 'Case was escalated for different reasons';                                        
                                            taskListUpdation.put(oldTask.Id, oldTask);
                                            break;
                                        }
                                    }
                                }
                            }                            
                        }
                    }
                    //GSS_CaseUpdateUtilityClass.caseUpdatedOnce = true;
                }
            }
            
        }
        if(taskListInsertion != null && !taskListInsertion.isEmpty()){
            GSS_CaseUpdateUtilityClass.caseUpdatedOnce = true;
            Database.SaveResult[] taskSaveList= Database.insert(taskListInsertion, false);
            CreateApexErrorLog.insertHandledExceptions(null, taskSaveList, null, null, 'ApexClass', 'task', 'SFA_sendAlertForCaseInactivityBatch');
        }
        if(taskListUpdation != null && taskListUpdation.values() !=null && taskListUpdation.values().size() > 0){
             
      GSS_CaseUpdateUtilityClass.caseUpdatedOnce = true;
            Database.SaveResult[] taskSaveList= Database.update(taskListUpdation.values(), false);
            CreateApexErrorLog.insertHandledExceptions(null, taskSaveList, null, null, 'ApexClass', 'task', 'SFA_sendAlertForCaseInactivityBatch');
        }
        
    }
    
    /**
      * @param Case newCase
      * @param String Task_sendAlert_RecordType
      * @return Task
      * @CR CR-00006501
      * @Author Inshu Misra
      * This method is used to create New Task from AI_createEmailTask method
      **/
   private static Task createTask(Case newCase, String Task_sendAlert_RecordType){
        Task newTask = new Task();
        if(Task_sendAlert_RecordType != null){
            newTask.RecordTypeId = Task_sendAlert_RecordType;
        }
        if(newCase.ContactId!=null){
            newTask.WhoId = newCase.ContactId;
        }
        if(newCase.OwnerId!=null){
            if(!string.valueOf(newCase.OwnerId).startsWith('00G'))
            {
                newTask.OwnerId=newCase.OwnerId;
            }
                     
        }
        newTask.WhatId = newCase.Id;
        newTask.Status = 'New';
        newTask.Subject = 'Send Email Alert for Case # '+newCase.CaseNumber+' with Status \''+newCase.Status+'\'';
        newTask.IsReminderSet = true;
        newTask.ActivityDate = System.Today();
        return newTask;
    }
    //GSS AGENT CODE END
    
    //Start CR-00044919- added method call to send emails to case team members and additional email field 
    public static void SendEmailOnCaseUpdate(List<Case> triggerNew){
        GSS_NotifyCaseTeam_AdditionalEmail obj =new GSS_NotifyCaseTeam_AdditionalEmail();
        obj.SendEmailForCasecomment(null,triggerNew,null,null);       
    }   
    //End CR-00044919
  
  /*************************************End:-After Update Methods*****************************************************************************************/
  
  
  /*************************************Start:-Before Update Methods*****************************************************************************************/
  
    public  List<Case> BU_GSS_Cases = new List<Case>();
    public  List<Case> BU_PRM_Cases = new List<Case>();
    public  List<Case> BU_SFA_Cases = new List<Case>();
    public  List<Case> BU_myVmwareCases = new List<Case>();
    public  List<Case> BU_myVmwareCasesSupGrp = new List<Case>();
    public  List<Id>   BU_myVmwareCasesVIP = new List<Id>();
    public  List<Case> BU_myVmwareCasesSLA = new List<Case>();    
    public  List<Case> BU_myVmwareCasesSLAforSev = new List<Case>();
    public  List<Case> BU_myVmwareCasesDefect = new List<Case>();
    public  boolean BU_isSubType = false;    //CR-00003564
    public  Boolean BU_PopUpCase = false;
    public  List<Case> CsrTseCase = new List<Case>();
    public  List<Case>lsCaseToUpdateRepsponseTime=new List<Case>();
    public  List<Case>lsCaseToUpdateResolutionTime=new List<Case>();
    public static List<Case> BU_ITAppsSupport_Cases = new List<Case>();     // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
    public static List<Case> BU_GlobalOrderMgmt_Cases = new List<Case>();     // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548
    public static Map<String, String> BU_mapITAppsSupport = GSS_CaseUtils.getMapITAppsSupport();    // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
    public static Map<String, String> BU_mapGlobalOrderMgmt = GSS_CaseUtils.getmapGlobalOrderMgmt();  // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548 
    // Added By Nilanka for SDP 3.0 First Response Due Date//
    List<Case> SDP_SBScases = new List<Case>(); 
    Record_Type_Settings__c recType = Record_Type_Settings__c.getInstance('SubscriptionServices');
    String RecTypeID = recType.Record_Type_ID__c;
    // Added By Nilanka for SDP 3.0 First Response Due Date//





  
  
  public  void beforeUpdateCaseInitialization(List<Case> triggerNew,Map<Id,Case>triggerOldMap,Boolean flag)
  {
    SDP_SBScases.clear();
        //CR-00055569 create a map of country and support level
        Map<String, String> GSS_SupportLevelMap = new Map<String, String>();
        for(GSSSupportLevel__c support : GSSSupportLevel__c.getall().values()){
            GSS_SupportLevelMap.put(support.Country__c,support.Support_Level__c);
        }
  
        for (Case c : triggerNew) 
        {
          System.debug('ScreenPop - c.GSS_ScreenPopTime='+c.GSS_ScreenPopTime__c + ' dt='+dt);
          if(c.GSS_ScreenPopTime__c!=null && newdate < c.GSS_ScreenPopTime__c) {
          BU_PopUpCase = true;
          BU_GSS_Cases.add(c);
           }else{
            Map<String, String> mapGSS = GSS_CaseUtils.getMapGSS();
            Map<String, String> mapPRM = GSS_CaseUtils.getMapPRM();
            Map<String, String> mapSFA = GSS_CaseUtils.getMapSFA();

            
              if(mapGSS.containsKey(c.RecordTypeId)) {
                BU_GSS_Cases.add(c);
              } 
                if(BU_mapITAppsSupport.containsKey(c.RecordTypeId)) {  // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
                BU_ITAppsSupport_Cases.add(c);
            }
             if(BU_mapGlobalOrderMgmt.containsKey(c.RecordTypeId)) {  // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548
            BU_GlobalOrderMgmt_Cases.add(c);
            }
              else if(mapPRM.containsKey(c.RecordTypeId)) {
                BU_PRM_Cases.add(c);
              } else if(mapSFA.containsKey(c.RecordTypeId)) {
                BU_SFA_Cases.add(c);
              }

              //Adding below code for MyVMWARE CMT changes - START
              if(c.RecordTypeId == myVmwareRTITSup) {
                if(c.Status == 'Closed - Resolved' && triggerOldMap.get(c.Id).Status != 'Closed - Resolved')BU_myVmwareCases.add(c);
                else if(c.Status == 'Closed' && c.CAD_number__c != null)c.Sub_Status__c = 'Ordered';
                
                BU_myVmwareCasesVIP.add(c.Id);
              } 
              if(c.RecordTypeId == myVmwareRTITSup || c.RecordTypeId == myVmwareRTCommon) {
                BU_myVmwareCasesSupGrp.add(c);
              }
              //Adding code for MyVMWARE CMT changes - END
              // Added for SDP 3.0 By Nilanka -- Starts
              if(RecTypeID== c.RecordTypeId && c.Region_First_Response__c != NULL && c.Status != 'Pending Provisioning') //  CR-00076418 -Removed status='Active' check
              {
                SDP_SBScases.add(c);
               }
               // Added for SDP 3.0 By Nilanka -- Ends






            
              
                if(flag==false){
                /**For escalated Request****/
                if(c.Status != triggerOldMap.get(c.Id).Status && triggerOldMap.get(c.Id).Status == 'Escalated'){
                  if(GSS_CaseRequestClass.isUserFromEscalatedProfiles(UserInfo.getProfileId())){
                    try{
                      GSS_CaseRequestClass.validateEscalatedCaseRequest(c);
                    }catch(Exception e){
                      c.addError(e.getMessage()); 
                    }
                  }
                  else{
                     c.addError(' Your Profile is not allow to update Case Status of an Escalated Case.');
                  }
                   }  
                   /***For escalated Request**/
                  }
                   
                 /*******************Start: // Added Code for MY VMware***************/
                 
            
                    if (c.Status=='In Progress' && c.Status!= triggerOldMap.get(c.id).Status && c.recordTypeId==myVmwareRTITSup && triggerOldMap.get(c.id).Status=='New')
                    {
                      lsCaseToUpdateRepsponseTime.add(c);
                      }

                    if (c.Status=='Closed - Resolved' && c.Status!= triggerOldMap.get(c.id).Status && c.recordTypeId==myVmwareRTITSup)
                    {
                       lsCaseToUpdateResolutionTime.add(c);
                    }
                    //When Record Type change from Common Record Type to IT Apps
                    if(c.recordTypeId==myVmwareRTITSup && c.recordTypeId!= triggerOldMap.get(c.id).recordTypeId && triggerOldMap.get(c.id).recordTypeId==myVmwareRTCommon){

                      BU_myVmwareCasesSLA.add(c);
                    }
                    //If Severity gets changed
                      if(c.Severity__c!= triggerOldMap.get(c.id).Severity__c && c.recordTypeId == myVmwareRTITSup && c.Response_SLA_Met_Formula__c == null && c.Resolution_SLA_Met_Formula__c == null) {
                      BU_myVmwareCasesSLAforSev.add(c);
                    }

                    if(c.Defect__c!= triggerOldMap.get(c.id).Defect__c && c.recordTypeId == myVmwareRTITSup && c.Defect__c != null ) {
                      BU_myVmwareCasesDefect.add(c);
                    }

                    

                    if (c.Status != 'In Progress' && c.Status != triggerOldMap.get(c.id).Status && c.RecordTypeId ==myVmwareRTITSup && triggerOldMap.get(c.id).Status == 'New')
                    {
                      c.addError('New Status can only be changed to In Progress');
                    }
             
                 /************************END: // Added Code for MY VMware**********/  
                   
                   
                   
                   
                 }
              
                
                // 05-Jun-15            Mayur Srivastava        SDP Phase 9.0 | CR-00132194 | VMStar-ServiceNow FRD - Starts        
                GSS_ServiceNow_Parameters__c  gssSNParameter = GSS_ServiceNow_Parameters__c.getOrgDefaults();
                if(c.Generate_ServiceNow_Inc__c == gssSNParameter.vCHS_NonSFDC__c)
                {
                    c.Generate_ServiceNow_Inc__c = gssSNParameter.vCHS_SFDC__c;
                }
                if(c.Generate_ServiceNow_Inc__c == gssSNParameter.ITBM_NonSFDC__c)
                {
                    c.Generate_ServiceNow_Inc__c = gssSNParameter.ITBM_SFDC__c;
                }
                // 05-Jun-15            Mayur Srivastava        SDP Phase 9.0 | CR-00132194 | VMStar-ServiceNow FRD - Ends
                        
              if(c.status.contains('closed'))// defect 00035051
              {
                c.GSS_Call_Dropped__c= false;
              }
               if(triggerOldMap.get(c.id).GSS_Support_Level__c==c.GSS_Support_Level__c)// CR-00026556 Start
               {
               //CR-00052138 Added tech support record type check
               //CR-00055569 using map instead of custom setting
               if(c.RecordTypeId==techSupport && c.GSS_Country__c !=null && GSS_SupportLevelMap.get(c.GSS_Country__c)!=null)
              {
                c.GSS_Support_Level__c = GSS_SupportLevelMap.get(c.GSS_Country__c);
              } // CR-00026556 End
              }  
           }

// Added By Nilanka for SDP 3.0 Starts//    
                if(!SDP_SBScases.IsEmpty()){
                    GSS_SDPFirstResponseDueDate.calcFirstResponseDueDate(SDP_SBScases);
                    }
           // Added By Nilanka for SDP 3.0 Ends//  




      
          
          
          
        
          
          
    }
    
    
    
    
  
  
  public  void IVRCaseUpdate(Map<Id,Case>triggerOldMap)
  {
      if(BU_PopUpCase){
    GSS_CaseBusinessHours.BU_Center(BU_GSS_Cases);
        GSS_CaseBusinessHours.BU_BusinessHours(BU_GSS_Cases, triggerOldMap);
        if( GSS_UtilityClass.isManagerEmailUpdate == false){
            GSS_CaseOwnerManager.BU_MgrEmail(BU_GSS_Cases);
            GSS_UtilityClass.isManagerEmailUpdate = true ;
        }
        //CR-00006927 Starts here (We have added only check al all places)
        if(GSS_UtilityClass.isWorkLoadIncrease == false){   
          GSS_UpdateWPTriggerHelper.BU_WorkPoints(BU_GSS_Cases,triggerOldMap);//sud code : 3 dec
          GSS_UtilityClass.isWorkLoadIncrease = true;
        }
        if ( BU_GSS_Cases.size() > 0 ) GSS_CaseUtils.resetCaseOwnertoQueue(BU_GSS_Cases); 
        GSS_WorkflowUtils.BU_CaseWorkflowRules(BU_GSS_Cases, triggerOldMap); 
      }
  }
  
  public void updateCaseCustomerFR()
  {
        if(!BU_PopUpCase){
      //CR-00012844 :: Starts
      GSS_UpdateCaseFirstResponse.updateCustomerFR(BU_GSS_Cases);
      //CR-00012844 :: Ends
          }      
    
  }
  
  public void updateCaseOnOwnerChange(Map<Id,Case>triggerOldMap,List<case> triggerNew) //CR-00135328 Added triggerNew as parameter
  {
    //Start - 31-May-2016 - CR-00138381 - Jyolsna - Added below code before BU_PopUpCase check. BU update needs to be done for all cases.
    if(!GSS_UtilityClass.isBusinessUnitUpdate){
        List<Case> buCases = GSS_UpdateWPTriggerHelper.ownerChange(triggerNew,triggerOldMap);
        if(buCases != null && buCases.size() >0){
            GSS_CaseOwnerManager.BU_UpdateBusinessUnit(buCases,triggerOldMap); //CR-00131921 GSS - July Release
            GSS_UtilityClass.isBusinessUnitUpdate = true;
        }
    }
    //End - 31-May-2016 - CR-00138381 - Jyolsna - Added below code before BU_PopUpCase check. BU update needs to be done for all cases.
        if(!BU_PopUpCase)
    {      
      List<Case> GSS_OwnerCases = GSS_UpdateWPTriggerHelper.ownerChange(BU_GSS_Cases,triggerOldMap);     
      GSS_CaseBusinessHours.BU_Center(GSS_OwnerCases);
      GSS_UpdateWPTriggerHelper.updateUserData(BU_GSS_Cases,triggerOldMap);//Added by Jyolsna - 16-May-2016 - CR-00134744
      GSS_UpdateWPTriggerHelper.Change_SubStatus(GSS_OwnerCases); //CR-00110179
      //GSS_UpdateWPTriggerHelper.update_BussinessUnit(GSS_OwnerCases);//CR-00131921 16-june'15  Added to populate Business unit field
      GSS_CaseBusinessHours.BU_BusinessHours(BU_GSS_Cases, triggerOldMap);
       //CR-00136984 - Start Added a separate flag for populating Business unit field 
       //Start - 31-May-2016 - CR-00138381 - Jyolsna - Commented below code and added this code above the BU_PopUpCase check.
       /*List<Case> buCases = GSS_UpdateWPTriggerHelper.ownerChange(triggerNew,triggerOldMap);
        if(!GSS_UtilityClass.isBusinessUnitUpdate){
            if(buCases != null && buCases.size() >0){
                GSS_CaseOwnerManager.BU_UpdateBusinessUnit(buCases,triggerOldMap); //CR-00131921 GSS - July Release
                GSS_UtilityClass.isBusinessUnitUpdate = true;
            }
        }*/
    //End - 31-May-2016 - CR-00138381 - Jyolsna - Commented below code and added this code above the BU_PopUpCase check.
      //CR-00136984 - End
       //fix : BUG-00004812 - start
      if( GSS_UtilityClass.isManagerEmailUpdate == false){
        //CR-00135328--Start
       //CR-00136984 - commented code and added it in above if loop
       /* List<Case> buCases = GSS_UpdateWPTriggerHelper.ownerChange(triggerNew,triggerOldMap);
        if(buCases != null && buCases.size() >0)
            GSS_CaseOwnerManager.BU_UpdateBusinessUnit(buCases,triggerOldMap); //CR-00131921 GSS - July Release
        */
    //CR-00135328--End
    //CR-00136984 - commented the code and added it in above if loop
    
        GSS_CaseOwnerManager.BU_MgrEmail(GSS_OwnerCases);
        GSS_UtilityClass.isManagerEmailUpdate = true ;
      }
      //fix : BUG-00004812 - end
       
// CR-00137623 - Start -- added code to bypass workload points
    Boolean bypassWorkload = GSS_Config_Properties__c.getOrgDefaults().GSS_WorkLoad_points_for_Licensing_cases__c;
    if(bypassWorkload){
        if(userInfo.getuserId() != caseAdminId && userInfo.getuserId() != qmanUserId && userInfo.getUserId() != portalUserId && !GSS_VariableUtilityClass.reassignButton){
            list<case> licCases = new List<case>();
            List<case> nonLicCases = new List<Case>();
            if(GSS_OwnerCases != null && GSS_OwnerCases.size()>0){
                for(case cRec : GSS_OwnerCases){
                    if(cRec.recordtypeId == licCaseRT){
                        licCases.add(cRec);                     
                    }else{
                        nonLicCases.add(cRec);
                    }
                }
            }
            if(nonLicCases != null && nonLicCases.size()>0){
                if(GSS_UtilityClass.isWorkLoadIncrease == false){
                  GSS_UpdateWPTriggerHelper.BU_WorkPoints(nonLicCases,triggerOldMap);//sud code : 3 dec
                  GSS_UtilityClass.isWorkLoadIncrease = true;
                }
            } 
             //CR-00138072 Starts
            if(licCases != null && licCases.size()>0){
                if(GSS_UtilityClass.isWorkLoadIncrease == false){
                  GSS_UpdateWPTriggerHelper.BU_WorkPoints_Lic(licCases,triggerOldMap);
                  GSS_UtilityClass.isWorkLoadIncrease = true;
                }
            }
            //CR-00138072 Ends
        }else{
            if(GSS_OwnerCases != null && GSS_OwnerCases.size()>0){
                if(GSS_UtilityClass.isWorkLoadIncrease == false){
                  GSS_UpdateWPTriggerHelper.BU_WorkPoints(GSS_OwnerCases,triggerOldMap);//sud code : 3 dec
                  GSS_UtilityClass.isWorkLoadIncrease = true;
                }
            }
    
        }
    }
 // Existing code for work load points
    else{
        if(GSS_OwnerCases != null && GSS_OwnerCases.size()>0){
            if(GSS_UtilityClass.isWorkLoadIncrease == false){
              GSS_UpdateWPTriggerHelper.BU_WorkPoints(GSS_OwnerCases,triggerOldMap);//sud code : 3 dec
              GSS_UtilityClass.isWorkLoadIncrease = true;
            }
        }
    }
    // CR-00137623 - End 
    
      /*  commented for CR-00137623 - Start - Commented code is moved to above else block.    
      //CR-00006927 Starts here
      if(GSS_OwnerCases != null && GSS_OwnerCases.size()>0){
        if(GSS_UtilityClass.isWorkLoadIncrease == false){
          GSS_UpdateWPTriggerHelper.BU_WorkPoints(GSS_OwnerCases,triggerOldMap);//sud code : 3 dec
          GSS_UtilityClass.isWorkLoadIncrease = true;
        }
      }
      //CR-00006927 Ends here
     CR-00137623 - Ended */
       if ( GSS_OwnerCases.size() > 0 )//fix: BUG-00005626
          GSS_CaseUtils.resetCaseOwnertoQueue(GSS_OwnerCases);    
        
    
    }
    
  }
  /*
     * Name : BI_CommitDefaulter
     * Desc : Method updates commit defaulter on GSS Cases.
   * CR : 00028703
     */
  public void BU_CommitDefaulter(){
  
     //CR-00028703 Starts
    
    if (  ( !Test.IsrunningTest()  )   && ( !BU_GSS_Cases.isEmpty() ) && !GSS_UtilityClass.isCommitDefaulter  ){
        GSS_UtilityClass.isCommitDefaulter = true;
        GSS_CaseOwnerManager.updateCommitDefaulter(BU_GSS_Cases ,'upd' );
    }
    
    //CR-00028703 Ends

  }  
  
  public void myVmWareCaseUpdate(List<Case> triggerNew,Map<Id,Case>triggerOldMap,Boolean flag)
  {  
      
      if(!BU_PopUpCase)
    {  
          if(flag==false)
          {
          if(!BU_myVmwareCases.isEmpty() && BU_myVmwareCases.size() > 0)MyVmwareHelper.populateBizHrDiff(BU_myVmwareCases);
          if(!BU_myVmwareCasesSupGrp.isEmpty() && BU_myVmwareCasesSupGrp.size() > 0)MyVmwareHelper.populateSupportGroup(BU_myVmwareCasesSupGrp);
          if(!BU_myVmwareCasesVIP.isEmpty() && BU_myVmwareCasesVIP.size() > 0)MyVmwareHelper.markVIPCase(BU_myVmwareCasesVIP); 
          }
          
           // Added Code for MY VMware
                          
            if(!lsCaseToUpdateRepsponseTime.isEmpty() && lsCaseToUpdateRepsponseTime.size() > 0){
            MyVMwareSLAController.populateActualResponseTime(lsCaseToUpdateRepsponseTime);
            }
            if(!lsCaseToUpdateResolutionTime.isEmpty() && lsCaseToUpdateResolutionTime.size() > 0){          
            MyVMwareSLAController.populateActualResolutionTime(lsCaseToUpdateResolutionTime);
             }
            if(!BU_myVmwareCasesDefect.isEmpty() && BU_myVmwareCasesDefect.size() > 0){
               MyVMwareUpdateCaseController.UpdateDefectLink(BU_myVmwareCasesDefect);
            }


           if(!BU_myVmwareCasesSLAforSev.isEmpty() && BU_myVmwareCasesSLAforSev.size() > 0){
               MyVMwareSLAController.populateSLA(BU_myVmwareCasesSLAforSev);
               MyVMwareSLAController.populateResolutionTime(BU_myVmwareCasesSLAforSev);
            }

           if(!BU_myVmwareCasesSLA.isEmpty() && BU_myVmwareCasesSLA.size() > 0){
               MyVMwareSLAController.populateSLA(BU_myVmwareCasesSLA);
               MyVMwareSLAController.populateResolutionTime(BU_myVmwareCasesSLA);
            }//End of changes for MY VMware
          
          
    }
  }
  
  
    public void BU_WrkFlw(Map<Id,Case>triggerOldMap)
  {
    if(!BU_PopUpCase)
    { 
      GSS_WorkflowUtils.BU_CaseWorkflowRules(BU_GSS_Cases,triggerOldMap);  
    }
  }
  
  
  public void processCaseAndEntitlementIPack()
  {
  //CR-00008077 :: Starts
    
    // Check whether manual Incident Pack is enabled
      GSS_Config_Properties__c incPack = GSS_Config_Properties__c.getOrgDefaults();
      
      if(incPack.Enable_Manual_IPack__c){
         if(GSS_UtilityClass.isManualCase() && !GSS_UtilityClass.isPopulateEntitlement)
        {
                //CR-00043483 : START
          Set<string> incidentlist = new Set<string>();
          List<Case> entCaseList = new List<Case>();
          
          for(GSSIncidentPack__c incidentpack : GSSIncidentPack__c.getAll().values()){
              incidentlist.add(incidentpack.Entitlement_Code__c);
          }
          
          for(Case cs : BU_GSS_Cases){
            if(!incidentlist.isEmpty() && cs!=null && cs.GSS_Entitlement_Code__c!=null &&
            cs.GSS_Entitlement_Code__c!='' && incidentlist.contains(cs.GSS_Entitlement_Code__c)){
              entCaseList.add(cs);
            }
          }
          if(!entCaseList.isEmpty()){
            GSS_CaseUtils.populateEntitlementForIPack(entCaseList);
          }
            //CR-00043483 : END
          // Added flag for CR-00036203
          GSS_UtilityClass.isPopulateEntitlement = true ;
        }else if(!GSS_UtilityClass.isPopulateEntitlement){
          GSS_CaseUtils.populateIncidentPackOnCase(BU_GSS_Cases);
          // Added flag for CR-00036203
          GSS_UtilityClass.isPopulateEntitlement = true ;
        }                    
      }
    //CR-00008077 :: End
  }
  
  public  void checkCaseIssueTypeSubStatus(Map<Id,Case>triggerOldMap)
  {
    GSS_CaseUtils.isIssueSubtypeActive(BU_GSS_Cases,triggerOldMap);//CR-00003564 :
  }
  
  public  void processTSEAndCSRCases(Map<Id,Case>triggerOldMap)
  {
          // CR-00023611 BEGIN
     
       for (Case c : BU_GSS_Cases)
       {   
        if(c.RecordTypeId==techSupport && ((''+c.createdById)==Ivradmin) && ((triggerOldMap.get(c.id).GSS_CSR_TSE__c =='') || (triggerOldMap.get(c.id).GSS_CSR_TSE__c ==null) ) && ((''+triggerOldMap.get(c.id).LastModifiedById) ==Ivradmin) && (UserInfo.getUserId()!=Ivradmin))
        {
         CsrTseCase.add(c);
        }
       }
       if(!CsrTseCase.isEmpty() && CsrTseCase.size() > 0)
         GSS_TSE_CSR_update.caseupdate(CsrTseCase);
  
            // CR-00023611 END
  
  }
  
    public void servicenowfuncupdate(Map<Id,Case>triggerNewMap, Map<Id,Case>triggerOldMap)
    {
        // ServiceNow Code Starts

        if(GSS_Service_Now_Configuration__c.getInstance('EnableForUpdate') != null  &&
        GSS_Service_Now_Configuration__c.getInstance('EnableForUpdate').Is_Active__c ){       

            List<Case> serviceNowCases = new List<Case>();
            List<Case> serviceNowITBMCases = new List<Case>();  // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5
            List<Case> SNCasesInit = new List<Case>();       // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
            SNCasesInit.addAll(BU_GSS_Cases);                   // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
            SNCasesInit.addAll(BU_ITAppsSupport_Cases);         // Added by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
            SNCasesInit.addAll(BU_GlobalOrderMgmt_Cases);  // Added by : Mayur Srivastava  Dated : 6/24/2013 For : CR-00044548
            SNCasesInit.addAll(BU_SFA_Cases);                 // Added by : Mayur Srivastava  Dated : 11/08/2013  For : CR-00066003 [SDP 3.5] 
            for(Case c : SNCasesInit){     //BU_GSS_Cases){          // Modified by : Shashvat Mahendru  Dated : 5/13/2013 For : CR-00039339
                
                // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   Start
                
                List<GSS_ServiceNow_API_Users__c> snuserlist = GSS_ServiceNow_API_Users__c.getall().values();  
                
                Boolean found=false;
                
                if (triggerNewMap.get(c.id) != null) {
                
                    String lastmodify= triggerNewMap.get(c.id).LastModifiedById;
                
                    for(GSS_ServiceNow_API_Users__c snuserrec : snuserlist)
                    {                    
                        if(lastmodify.substring(0,15)==snuserrec.ID__c)
                        {
                            found=true;
                            break;
                        }
                    }
                }
                // 05-Jun-15            Mayur Srivastava        SDP Phase 9.0 | CR-00132194 | VMStar-ServiceNow FRD - Modified both If conditions to make it dynamic
                GSS_ServiceNow_Parameters__c  gssSNParameter = GSS_ServiceNow_Parameters__c.getOrgDefaults();
                if((triggerOldMap.get(c.id)!=null) && (triggerOldMap.get(c.id).Generate_ServiceNow_Inc__c==NULL) && (triggerNewMap.get(c.id).Generate_ServiceNow_Inc__c == gssSNParameter.vCHS_SFDC__c) && !found){
                    serviceNowCases.add(c);
                }
                if((triggerOldMap.get(c.id)!=null) && (triggerOldMap.get(c.id).Generate_ServiceNow_Inc__c==NULL) && (triggerNewMap.get(c.id).Generate_ServiceNow_Inc__c == gssSNParameter.ITBM_SFDC__c) && !found){
                    serviceNowITBMCases.add(c);
                }
                // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   End
            }

            if(!serviceNowCases.IsEmpty()){
                GSS_ServiceNowClass.processServiceCases(serviceNowCases);
            } 
            // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   Start
            if(!serviceNowITBMCases.IsEmpty()){
                GSS_ServiceNowITBMClass.processServiceCases(serviceNowITBMCases);
            }   
            // Added by : Mayur Srivastava  Dated : 11/26/2013 For : SDP 3.5   End          
        }
        // ServiceNow Code Ends 
    }
       /* Start CR-00039831 */
     /*
     * Name     : BU_Populate_CustomerContact
     * Desc     : Method updates Customer Contact fields for GS-SS Customer Support Cases.
     * Author   : Sakshi Suri
     */
  public void BU_Populate_CustomerContact(List<Case> triggerNew , Map<Id,Case>triggerOldMap){
        Map<Id,Id> CaseCusContactMap = new Map<Id,Id>();
        Map<Id,contact> CusContactDetailMap = new Map<Id,contact>();
        Set<Id> CusContactIds = new set<Id>();
    
    for (Case c : triggerNew){
        if(c.RecordTypeId==licCaseRT && c.Customer_Contact_Name__c!=null && (triggerOldMap.get(c.id).Customer_Contact_Name__c==null || triggerOldMap.get(c.id).Customer_Contact_Name__c!= c.Customer_Contact_Name__c)){
            CusContactIds.add(c.Customer_Contact_Name__c);
            CaseCusContactMap.put(c.Id,c.Customer_Contact_Name__c);
        }
    }
    if(CusContactIds!=null && CusContactIds.Size()>0){
            List<contact> conRec=[select Name,Phone,Email,AccountId from contact where Id in :CusContactIds];
            if(conRec!= null){
                for(contact con:conRec){
                    CusContactDetailMap.put(con.Id,con);
                }
            }
        }
    for (Case c : triggerNew){
            if(c.RecordTypeId==licCaseRT && c.Customer_Contact_Name__c != null && CaseCusContactMap!=null){            
                Contact conDetails = CusContactDetailMap.get(CaseCusContactMap.get(c.id));            
                if(conDetails!=null){        
                    c.Customer_Contact_Email__c = conDetails.Email;
                    c.Customer_Contact_Phone__c = conDetails.Phone;
                }                           
            }
        }
    
  }
   /* End CR-00039831 */
   
   /***********  
   * @Purpose : BB-8 project (JIRA - BB-77) - Method used to pause/resume SLA clock depends on sub status field of case object   
   * @Param : triggerNew,triggerOldMap - new and old value of the cases modified
   * @Return : null
   ********************/            
   
   
   public  void pauseResumeSLAClock(List<Case> triggerNew , Map<Id,Case>triggerOldMap){
      Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
      Set<String> entCodeSet = new Set<String>();
      Set<String> caseEntitlementCodeSet = new Set<String>();
      Set<String> stoppedClockCases = new Set<String>();
      Set<String> resumedClockCases = new Set<String>();
      List<BB_8_SLA_integration_fields__c> newSLAFields = BB_8_SLA_integration_fields__c.getall().values();
      List<BB_8_SLA_integration_fields__c> caseSlaTargetFields = new List<BB_8_SLA_integration_fields__c>();
      Map<String,Case_SLA__c> caseSLAMap = new Map<String,Case_SLA__c>();
      String SOQL_SLA = '';
      String SOQL = '';
      
       for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
                // Pick all active premier entitlements
                if(entObj.isActive__c  ){
                    entCodeSet.add(entObj.code__c);
                    
                }
        }
        
        for(case ca :triggerNew){
            system.debug('Entilement Code is '+ca.GSS_Entitlement_Code__c);
            if(ca.sub_status__c != null && ca.sub_status__c != triggerOldMap.get(ca.ID).sub_status__c && entCodeSet.contains(ca.GSS_Entitlement_Code__c)
                && (ca.sub_status__c == 'Customer To Confirm Fix') && (GSS_UtilityClass.isSystemUpdatedCaseSubStatusCheck == true)){
                ca.IsStopped = true;
                stoppedClockCases.add(ca.id);
            }else if(ca.sub_status__c != null && ca.sub_status__c != triggerOldMap.get(ca.ID).sub_status__c && entCodeSet.contains(ca.GSS_Entitlement_Code__c)
                && (ca.sub_status__c == 'Fix Succeeded' || ca.sub_status__c == 'Fix Failed')){
                    ca.IsStopped = false;
                    resumedClockCases.add(ca.id);
            }else if(ca.sub_status__c != null && ca.sub_status__c != triggerOldMap.get(ca.ID).sub_status__c && entCodeSet.contains(ca.GSS_Entitlement_Code__c)
                && (ca.sub_status__c == 'Customer To Confirm Fix') && (GSS_UtilityClass.isSystemUpdatedCaseSubStatusCheck == false)){
                    ca.addError(Label.BB_8_Case_Sub_Status_Manual_Change_Error_Msg);
            }
            caseEntitlementCodeSet.add(ca.GSS_Entitlement_Code__c);
        }
        
        System.debug('stoppedClockCases***'+stoppedClockCases);
        System.debug('resumedClockCases***'+resumedClockCases);
        if((stoppedClockCases!= null && stoppedClockCases.size()>0) || (resumedClockCases!=null && resumedClockCases.size()>0)){
           //Get all the target fields to update
           for( BB_8_SLA_integration_fields__c integrationfield : newSLAFields ) { 
                if(integrationfield.Is_Active__c && entCodeSet.contains(integrationfield.Entitlement_Code__c) && caseEntitlementCodeSet.contains(integrationfield.Entitlement_Code__c) && integrationfield.Object_API_Name__c != '' && integrationfield.Object_API_Name__c != null && integrationfield.Object_API_Name__c.equalsIgnoreCase('Case_SLA__c') && integrationfield.Is_Target_Date__c){
                    caseSlaTargetFields.add(integrationfield);
                }
                           
            }
                
                for( BB_8_SLA_integration_fields__c integrationfield : caseSlaTargetFields ) { 
                        if(!String.isBlank(integrationfield.Field_API_Name__c)&& !String.isBlank(integrationfield.MetFieldAPIName__c)){
                            SOQL_SLA += '' + integrationfield.Field_API_Name__c + ', '+integrationfield.MetFieldAPIName__c+ ', ';
                        }
                }
                
                if(SOQL_SLA != '') { //Adding check for non CGS entitlement
                    
                    SOQL += 'Select '+SOQL_SLA+'id,name,case__c,case__r.GSS_Entitlement_Code__c,Last_Stopped_Time__c from Case_SLA__c where Case__c IN : resumedClockCases OR Case__c IN : stoppedClockCases';
                }   
                
                System.debug('SOQL_SLA BB8****'+SOQL);
                List<Case_SLA__c> caseSlAList = database.query(SOQL);
                
                //Update the target date manually
                for(Case_SLA__c caseSla: caseSLAList){
                    if(stoppedClockCases.contains(caseSLA.case__c)){
                        //stamp system.now in the sla record
                        caseSla.Last_Stopped_Time__c = System.now();
                    }       
                    else if(resumedClockCases.contains(caseSLA.case__c)){
                        //stamp the elapsed time between stopped and resume to all the target dates
                         if(caseSla.Last_Stopped_Time__c != null){
                             Long minutesToAdd =  ((System.now().getTime() - caseSla.Last_Stopped_Time__c.getTime())/1000)/60 ;
                             System.debug('minutesToAdd**'+minutesToAdd);
                             for( BB_8_SLA_integration_fields__c integrationfield : caseSlaTargetFields ) { 
                                //Check entitlement fields
                                if(caseSla.case__r.GSS_Entitlement_Code__c!= null && caseSla.case__r.GSS_Entitlement_Code__c.equalsIgnoreCase(integrationfield.Entitlement_Code__c) && caseSla.get(integrationfield.Field_API_Name__c)!= null && caseSla.get(integrationfield.MetFieldAPIName__c)!= null && !String.valueOf(caseSla.get(integrationfield.MetFieldAPIName__c)).equalsIgnoreCase('Yes')) {
                                    caseSla.put(integrationfield.Field_API_Name__c,datetime.valueOf(caseSla.get(integrationfield.Field_API_Name__c)).addMinutes(Integer.valueOf(minutesToAdd)));
                                 }
                             }
                             caseSla.Last_Stopped_Time__c = null;
                         }
                    }
                }
                
                database.update(caseSLAList,false);
        }
        
  } 
  
    /***********  
   * @Purpose : BB-8 project (JIRA - BB-40) - Method used to validate if the milestone are completed before case closure  
   * @Param : triggerNewMap,triggerOldMap - new and old value of the cases modified
   * @Return : null
   ********************/            
   public  static void validateSLACompletionBeforeCaseClosure( Map<Id,Case>triggerNewMap , Map<Id,Case>triggerOldMap){
        
        Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
        Set<String> entCodeSet = new Set<String>();
        
        for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
                // Pick all active premier entitlements
                if(entObj.isActive__c  && entObj.code__c!=null){
                    entCodeSet.add(entObj.code__c);
                }
        }
        List<String> closedCasesIds = new List<String>();
        Set<String> caseEntitlementCodeSet = new Set<String>();
        List<Case_SLA__c> caseSlAList = new List<Case_SLA__c>();
        if(triggerNewMap.values().size()>0){
            for(Case caseRec : triggerNewMap.values()){
                //pick up the cases which are chosen to get closed
                if(caseRec.Status != null && caseRec.Status != triggerOldMap.get(caseRec.ID).Status && !entCodeSet.isEmpty() && entCodeSet.contains(caseRec.GSS_Entitlement_Code__c)
                 && (caseRec.Status.equalsIgnoreCase('Closed')) && (!caseRec.Sub_Status__c.equalsIgnoreCase('Duplicate'))){
                    closedCasesIds.add(caseRec.id);
                    if(caseRec.GSS_Entitlement_Code__c !=null){
                        caseEntitlementCodeSet.add(caseRec.GSS_Entitlement_Code__c);
                    }
                }
            }
        
            if(!closedCasesIds.isEmpty()){
                //Query the child sla records
                List<BB_8_SLA_integration_fields__c> newSLAFields = BB_8_SLA_integration_fields__c.getall().values();
                List<BB_8_SLA_integration_fields__c> caseActualSlaFields = new List<BB_8_SLA_integration_fields__c>();
                Map<String,Case_SLA__c> caseSLAMap = new Map<String,Case_SLA__c>();
                String SOQL_SLA = '';
                String SOQL = '';
                
                for( BB_8_SLA_integration_fields__c integrationfield : newSLAFields ) { 
                    if(integrationfield.Is_Active__c && entCodeSet.contains(integrationfield.Entitlement_Code__c) && caseEntitlementCodeSet.contains(integrationfield.Entitlement_Code__c) && !String.isBlank(integrationfield.Object_API_Name__c) && integrationfield.Object_API_Name__c.equalsIgnoreCase('Case_SLA__c') && !integrationfield.Is_Target_Date__c && integrationfield.Eligible_For_Case_Closure_Validation__c){
                        caseActualSlaFields.add(integrationfield);
                    }
                           
                }
                
                for( BB_8_SLA_integration_fields__c integrationfield : caseActualSlaFields ) { 
                        if(!String.isBlank(integrationfield.Field_API_Name__c)){
                            SOQL_SLA += '' + integrationfield.Field_API_Name__c+',';
                        }
                }
                
                if(SOQL_SLA != '') { //Adding check for non CGS entitlement
                    
                    SOQL += 'Select '+SOQL_SLA+'id,name,case__c,case__r.GSS_Entitlement_Code__c,case__r.priority,Last_Stopped_Time__c from Case_SLA__c where Case__c IN : closedCasesIds';
                }   
                
                System.debug('SOQL_SLA BB8****validateSLACompletionBeforeCaseClosure****'+SOQL);
                if(SOQL!=''){
                    caseSlAList = database.query(SOQL);
                }
                
                Set<String> invalidCases = new Set<String>();
                if(!caseSlAList.isEmpty()){
                    for(Case_SLA__c caseSla : caseSlAList){
                         for( BB_8_SLA_integration_fields__c integrationfield : caseActualSlaFields ) { 
                            if(caseSla.case__r.priority != null && integrationfield.Case_Priorities__c != null && integrationfield.Case_Priorities__c.containsIgnoreCase(caseSla.case__r.priority) && caseSla.get(integrationfield.Field_API_Name__c)==null){
                                invalidCases.add(caseSla.case__c);
                                break;
                            }
                         }
                    }
                        
                 System.debug('invalidCases***validateSLACompletionBeforeCaseClosure****'+invalidCases);
                    if(invalidCases != null){
                        for(String caseId : invalidCases){
                            if(triggerNewMap.get(caseId) != null){
                                triggerNewMap.get(caseId).addError(Label.BB8_case_closure_error_msg);
                            }
                        }
                    }   
                }
                
                
            }
        }
        
   }
    
  /*************************************End:-Before Update Methods*****************************************************************************************/
  
 /******************Before Delete Methods : START ********************/ 
 
 
     /**********Variable Declairation - Before Delete Case -START*****/
      public  List<ID> caseIDList = new List<ID>();
      public  List<Case> childCaseIDList=new List<Case>();
      public  List<Case> updCaseList =new List<Case>();
    /**********Variable Declairation - Before Delete Case -END*****/
   
   public  void updateRelatedListCount(List<Case> triggerNew , List<Case> triggerOld){
   
    for(integer i=0;i<triggerOld.size();i++){
      // updCaseList.add(trigger.old[i]);
      if(triggerOld[i].ParentId!=null){
         caseIDList.add([Select Id From Case Where Id =: triggerOld[i].ParentId ].Id);
         childCaseIDList.add([Select Id From Case Where Id =: triggerOld[i].id]);
      }
  
    }
    
    if(caseIDList.size()>0 && caseIDList!=null){
      updCaseList = UpdateTheRelatedCaseCountOnParent.updateRelatedListCountParent(caseIDList,childCaseIDList);
      GSS_UtilityClass.isCountOnCaseUpdated =true;
      update updCaseList ;
     }
  }
  
    
  
   
   /******************Before Delete Methods : END **********************/ 
   
   
   
   /******************After Update Methods : START For BB-8 Project ********************/ 
 
 
     
    /***********  
   * @Purpose : BB-8 project - Method used to keep first response field on case and case sla in sync  
   * @Param : triggerNew,triggerOldMap - new and old value of the cases modified
   * @Return : null
   ********************/     
   public  void syncFirstResponseDate(List<Case> triggerNew , Map<Id,Case>triggerOldMap){
   
    Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
    Set<String> entNameSet = new Set<String>();
    List<Case_SLA__c> cSLA = new List<Case_SLA__c>();
        for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
                    // Pick all active premier entitlements
                    if(entObj.isActive__c  ){
                        
                        entNameSet.add(entObj.Code__c);
                    }
        }
        Map<Id,DateTime> needToSync = new Map<Id,DateTime>();
        for(case ca :triggerNew){
            system.debug('Entilement Code is '+ca.GSS_Entitlement_Code__c);
            system.debug('Entilement Code is '+entNameSet);
            if(ca.First_Response_Date__c != triggerOldMap.get(ca.ID).First_Response_Date__c && entNameSet.contains(ca.GSS_Entitlement_Code__c)){
                needToSync.put(ca.id,ca.First_Response_Date__c);  
                system.debug('Inside For loop ');  
                    
            }
            
        }
        if(needToSync.size()>0){
          for(Case_SLA__c caseMilestone:[SELECT id,Case__c,First_Response_Due_In__c FROM Case_SLA__c where Case__c IN:needToSync.keyset()]){
              caseMilestone.First_Response_Due_In__c = needToSync.get(caseMilestone.Case__c);
              cSLA.add(caseMilestone);
          }
          database.update(cSLA,false);
        }  
  }
  
    /*********** 
   * @Purpose : BB-8 project - Method used to flip the workaround field of case sla based on case sub status.
                If the sub status in changed to fix succeeded or fix failed then uncheck workaround field.
                It should be done only for premier entitlements
   * @Param : triggerNew,triggerOldMap - new and old value of the cases modified
   * @Return : null     
   ********************/     
  public void toggleWorkaroundBasedCaseStatus(List<Case> triggerNew , Map<Id,Case>triggerOldMap){
        Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
        Set<String> entNameSet = new Set<String>();
        List<Case_SLA__c> cSLA = new List<Case_SLA__c>();
        Set<String> eligibleCaseIds = new Set<String>();
        List<case_sla__c> caseSlatoUpdate = new List<case_sla__c>();
        for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
            // Pick all active premier entitlements
            if(entObj.isActive__c  ){
                entNameSet.add(entObj.Code__c);
            }
        }
        
        for(case ca :triggerNew){
            system.debug('Entilement Code is '+ca.GSS_Entitlement_Code__c);
            system.debug('Entilement Code set is '+entNameSet);
            if(ca.sub_status__c != triggerOldMap.get(ca.ID).sub_status__c && (ca.sub_status__c != null) && (ca.sub_status__c.equalsIgnoreCase('Fix Succeeded') || ca.sub_status__c.equalsIgnoreCase('Fix Failed')) && entNameSet.contains(ca.GSS_Entitlement_Code__c)){
                eligibleCaseIds.add(ca.id);  
            }
        }
        System.debug('toggleWorkaroundBasedCaseStatus***eligibleCaseIds'+eligibleCaseIds);
        if(!eligibleCaseIds.isEmpty()){
            for(case_sla__c caseSla : [select id,name,Workaround_Sent__c from case_sla__c where case__c IN:eligibleCaseIds]){
                if(caseSla.Workaround_Sent__c){
                    caseSla.Workaround_Sent__c = false;
                    caseSlatoUpdate.add(caseSla);
                }
            } 
            database.update(caseSlatoUpdate,false);
        }
  }

     /***********  
    * @Purpose : BB-8 project (JIRA - BB-37) - Method used to update DL email, TSM Mail fields and also Old and New Case Owner fields, Old and New Severity fields in Case SLA Milestone 
    * @Param : triggerNewMap,triggerOldMap - new and old value of the cases modified
    * @Return : null
    ********************/
    public static void updateCaseSLAMilestoneDLEmail(List<Case>triggerNew , Map<Id,Case>triggerOldMap){ 
        try{ 
            Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
            Set<String> entNameSet = new Set<String>();
            Set<Id> eligibleCaseIds = new Set<Id>();

            for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
                // Pick all active premier entitlements
                if(entObj.isActive__c && entObj.isWFNotifsActive__c){ //isWFNotifsActive__c will ensure that only CGS is selected
                    entNameSet.add(entObj.Code__c);
                }
            }
            for(Case cs :triggerNew){
                if(entNameSet.contains(cs.GSS_Entitlement_Code__c)){
                    //Adding owenr and priority check first as part of optimization - Smita
                    Case oldCase = triggerOldMap.get(cs.Id); //get old case - Smita
                    if((oldCase!= null && cs.Priority!=null && oldCase.Priority!=null && cs.Priority != oldCase.Priority) || (oldCase!= null && cs.OwnerId != oldCase.OwnerId)){
                        eligibleCaseIds.add(cs.id);
                    }
                }
            }
            Case oldRec = new Case();
            List<Case> newCases = new List<Case>();
            //Smita- Removing CGS hardcoding from the query
            if(eligibleCaseIds != null && eligibleCaseIds.size()>0){
                newCases = [select id, OwnerId, Priority, Managers_Email__c, Entitlement.Name, GSS_Entitlement_Code__c, (select id, DLEmail__c, New_Case_Priority__c, Old_Case_Priority__c, New_Case_Owner_Id__c, Old_Case_Owner_Id__c, TSM_Email__c from Case_SLA_Milestone__r order by CreatedDate desc) from Case where Id IN :eligibleCaseIds and GSS_Entitlement_Code__c IN: entNameSet];
            }
            List<Case_SLA__c> updateList = new List<Case_SLA__c>();
            Case_SLA__c csSLA = new Case_SLA__c ();           
                
            for(Case csRec : newCases){
                oldRec=triggerOldMap.get(csRec.Id);
                if(csRec.Case_SLA_Milestone__r != null && csRec.Case_SLA_Milestone__r.size() > 0){
                    csSLA = csRec.Case_SLA_Milestone__r[0]; //considering only the latest Case SLA Milestone
                    
                    //Populating the Workflow_Check__c with either the priority or Case owner based on the latest change made on the case : 16-Jun change
                    if(csRec.Priority != oldRec.Priority){                   
                        csSLA.New_Case_Priority__c=csRec.Priority;
                        csSLA.Old_Case_Priority__c=oldRec.Priority;
                        csSLA.Workflow_Check__c = csRec.Priority;
                        updateList.add(csSLA);
                    }  
                    
                    if(csRec.OwnerId != oldRec.OwnerId && csSLA.New_Case_Owner_Id__c !=csRec.OwnerId && csSLA.Old_Case_Owner_Id__c!=oldRec.OwnerId){ 
                        //Populating the new case owner and old case owner ids, to use these fields in workflows to send email notifications
                        csSLA.New_Case_Owner_Id__c=csRec.OwnerId;
                        csSLA.Old_Case_Owner_Id__c=oldRec.OwnerId;
                        csSLA.Workflow_Check__c = csRec.OwnerId;
                        
                        if(String.valueOf(csRec.OwnerId).startsWith('00G')){                                                                                              
                            csSLA.TSM_Email__c='';
                            csSLA.DLEmail__c=System.Label.CGS_Case_Notification_DL;
                            updateList.add(csSLA);                        
                        }
                        else{ 
                            csSLA.DLEmail__c='';
                            csSLA.TSM_Email__c=csRec.Managers_Email__c;
                            updateList.add(csSLA);                        
                        }
                    } 
                }
            }
            Set<Case_SLA__c> updateSet = new Set<Case_SLA__c>(updateList);
            List<Case_SLA__c> SLARecsToUpdate = new List<Case_SLA__c>();
            SLARecsToUpdate.addAll(updateSet);
            
            if(SLARecsToUpdate.size() > 0 && SLARecsToUpdate!= null){
                //By pass sla update trigger - Smita
                CaseSLASequenceController.isCaseSLAMilestoneAfterUpdate = true;
                Database.update(SLARecsToUpdate,false);
            }   
        }
        catch(Exception e){
             CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'Apex class', 'CaseProcessing', 'updateCaseSLAMilestoneDLEmail');   
        }
    }
  /******************After Update Methods : END For BB-8 Project**********************/ 
  //CR-00138486 changes start by safiya mohammad
   public static void updateReOpendays(Map<Id,Case>triggerNewMap){
        set<Id> setOfCaseId = new set<Id>();
        List<Case_Extension__c> casExtListReOpenUpdated = new List<Case_Extension__c>();
        Id SalesOpsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Ops').getRecordTypeId();
        set<String> setofCaseCLosedStaus = new set<String>{'Closed','Closed - Invalid','Closed - Duplicate','Closed - No Response','Closed - No Action','Closed - Not Reproducible','Closed - First Call','Closed - Resolved'};
        List<Case_Extension__c> casExtList;
        for(Case newCase:triggerNewMap.values()){
            
            if(newCase.recordtypeid == SalesOpsRecordTypeId && setofCaseCLosedStaus.contains(String.valueOf(newCase.Status))){
                
                    setOfCaseId.add(newCase.Id);
            }
        }
        if(!setOfCaseId.isEmpty()){
                    casExtList = [select id,Case__c,Time_in_New__c,Case__r.status,Time_in_In_Progress__c,Time_in_On_Hold_hours__c,Time_in_Waiting_on_Customer__c,Time_in_Re_Opened__c,Re_OpenDays_Temp__c,ReOpen_Days__c from Case_Extension__c where Case__c IN :setOfCaseId];
                    
                    for(Case_Extension__c newcaseExt : casExtList){
                
                    // updating case extenstion repondays formula to a temp field 
                        
                        if(triggerNewMap.containskey(newcaseExt.Case__c)){
                             newcaseExt.Re_OpenDays_Temp__c = newcaseExt.ReOpen_Days__c;                             
                             casExtListReOpenUpdated.add(newcaseExt);
                                                
                        }
            }
            if(!casExtListReOpenUpdated.IsEmpty()){
                try{
                    Update casExtListReOpenUpdated;
                }Catch(Exception ex){
                    
                }
                 
            }
        }
        
        
                        
   }
  //CR-00138486 changes end by safiya mohammad
   public void calculateCaseStatusTime(Map<Id,Case>triggerNewMap, Map<Id,Case>triggerOldMap){
        set<Id> setOfCaseId = new set<Id>();
            List<CaseHistory> casHistoryList;
            set<String> setofCaseCLosedStaus = new set<String>{'Closed','Closed - Invalid','Closed - Duplicate','Closed - No Response','Closed - No Action','Closed - Not Reproducible','Closed - First Call','Closed - Resolved'};
            List<Case_Extension__c> casExtList;
            List<Case_Extension__c> casExtListUpdated = new List<Case_Extension__c>();
            List<Case_Extension__c> casExtListReOpenUpdated = new List<Case_Extension__c>();
           
            DateTime currentTime = DateTime.now();
            Double timeSpent = 0;
            //map<id,Case_Extension__c> caseId_Extension = new map<id,Case_Extension__c> ();
            Id SalesOpsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Ops').getRecordTypeId();
        for(Case newCase:triggerNewMap.values()){
            
            if(newCase.recordtypeid == SalesOpsRecordTypeId && newCase.status != triggerOldMap.get(newCase.id).status){
                    setOfCaseId.add(newCase.Id);
            }
        }  
            if(!setOfCaseId.isEmpty()){
                    casExtList = [select id,Case__c,Time_in_New__c,Case__r.status,Time_in_In_Progress__c,Time_in_On_Hold_hours__c,Time_in_Waiting_on_Customer__c,Time_in_Re_Opened__c,Re_OpenDays_Temp__c,ReOpen_Days__c from Case_Extension__c where Case__c IN :setOfCaseId];
                    
                    
                    /*for(Case_Extension__c caseExt :casExtList){
                        
                        caseId_Extension.put(caseExt.Case__c,caseExt);                      
                        
                    }*/
                    casHistoryList = [Select CaseId, Case.Status, Field, OldValue, NewValue, CreatedDate 
                                      From CaseHistory 
                                      Where CaseId IN :triggerNewMap.keySet() AND Field IN ('Status','created') Order by CreatedDate DESC Limit 1 ];
                                    
                    for(Case_Extension__c newcaseExt : casExtList){
                        
                        
                        for(CaseHistory history :casHistoryList){
                                
                                //if(triggerOldMap.containskey(newcaseExt.Case__c) && triggerOldMap.get(newcaseExt.Case__c).status == history.NewValue){
                                       if(history.NewValue == null){
                                            
                                            //timeSpent = ((history.CreatedDate.getTime()-currentTime.getTime())/60000);
                                            timeSpent = ((currentTime.getTime()-history.CreatedDate.getTime())/60000);
                                            timeSpent = timeSpent/60; 
                                            newcaseExt.Time_in_New__c = timeSpent;
                                            casExtListUpdated.add(newcaseExt);
                                            break;
                                        }
                                        if(triggerOldMap.containskey(newcaseExt.Case__c) && triggerOldMap.get(newcaseExt.Case__c).status == history.NewValue){                                            
                                            if(history.NewValue == 'New'){
                                            
                                            //timeSpent = ((history.CreatedDate.getTime()-currentTime.getTime())/60000);
                                            timeSpent = ((currentTime.getTime()-history.CreatedDate.getTime())/60000);
                                            timeSpent = timeSpent/60; 
                                            newcaseExt.Time_in_New__c = timeSpent;
                                            casExtListUpdated.add(newcaseExt);
                                            break;
                                            }
                                        
                                            else if(history.NewValue == 'In Progress'){
                                            //timeSpent = ((history.CreatedDate.getTime()-currentTime.getTime())/60000);
                                            timeSpent = ((currentTime.getTime()-history.CreatedDate.getTime())/60000);
                                            timeSpent = timeSpent/60; 
                                            newcaseExt.Time_in_In_Progress__c = timeSpent;
                                            casExtListUpdated.add(newcaseExt);
                                            break;
                                            
                                        }
                                        else if(history.NewValue == 'Waiting on Customer'){
                                            //timeSpent = ((history.CreatedDate.getTime()-currentTime.getTime())/60000);
                                            timeSpent = ((currentTime.getTime()-history.CreatedDate.getTime())/60000);
                                            timeSpent = timeSpent/60;
                                            newcaseExt.Time_in_Waiting_on_Customer__c = timeSpent;
                                            casExtListUpdated.add(newcaseExt);
                                            break;
                                            
                                        }
                                        else if(history.NewValue == 'On Hold'){
                                            //timeSpent = ((history.CreatedDate.getTime()-currentTime.getTime())/60000);
                                            timeSpent = ((currentTime.getTime()-history.CreatedDate.getTime())/60000);
                                            timeSpent = timeSpent/60;
                                            newcaseExt.Time_in_On_Hold_hours__c = timeSpent;
                                            casExtListUpdated.add(newcaseExt);
                                            break;
                                            
                                        }
                                        else if(setofCaseCLosedStaus.contains(String.valueOf(history.NewValue)) && triggerNewMap.containskey(newcaseExt.Case__c) && triggerNewMap.get(newcaseExt.Case__c).status == 'Re-opened'){
                                            
                                            newcaseExt.Time_in_Re_Opened__c = currentTime;
                                                casExtListUpdated.add(newcaseExt);
                                                break;
                                            
                                        }
                                        /*else if(history.NewValue == 'Re-opened'){
                                                //timeSpent = ((history.CreatedDate.getTime()-currentTime.getTime())/(60000*24));
                                                 timeSpent = ((currentTime.getTime()-history.CreatedDate.getTime())/60000);
                                                 timeSpent = timeSpent/60;
                                                 //timeSpent = timeSpent/24;
                                                System.debug('Printing--timeSpente -'+timeSpent ); 
                                                //newcaseExt.Time_in_Re_Opened__c = timeSpent;
                                                //System.debug('newcaseExt.Time_in_Re_Opened__c---'+newcaseExt.Time_in_Re_Opened__c);
                                                casExtListUpdated.add(newcaseExt);
                                                break;
                                        }*/
                                          
                                        
                                            
                                        }
                                        
                                //}
                        }
                    }
                    
                    
            }
            if(!casExtListUpdated.IsEmpty()){
                try{
                    Update casExtListUpdated;
                }Catch(Exception ex){
                }
                 
            }
            
            
        
    }
    //CR-00138486 changes end by safiya mohammad
    
    
    
   // Method to populate Reportedby User for Web2Case  -- CR-00138934 -- Changes by Veera
    Public Static void UpdatereportedbyWeb2Case(List<Case> newCases)
    {
        Boolean Check = OnOffSwitch__c.getValues('GTMOpsCoE') !=null ? OnOffSwitch__c.getValues('GTMOpsCoE').Active__c: False;
        if(!Check)
        {
            return;
        }
        Set<String> ReportedbyList = new Set<String>();
        Map<String,User> UserMap = new Map<String,User>();
        For (Case c:newCases)
        {
            If(c.RecordTypeId == GTMOpsRT && c.createdbyId==CaseAdminUserId && c.Origin=='WEB')
            {
                ReportedbyList.add(c.SuppliedEmail);
            }
        }
        System.debug('ReportedbyList'+ReportedbyList);
        If(ReportedbyList.size()>0)
        {
            For(User u:[Select Id,email from User where email in :ReportedbyList])
            {
                UserMap.put(u.email,u);
            }
        }
        System.debug('UserMap'+UserMap);
        If(UserMap.size()>0)
        {
            For(Case cas:newCases)
            {
                If(UserMap.containsKey(cas.SuppliedEmail))
                {
                Cas.Reported_By__c=UserMap.get(cas.SuppliedEmail).Id;
                }
            }
        }
    }
    
        public static void shareGTMCaseWithRequester(List<Case> newCaseList, Map<id,Case> CaseOldMap) {
    
        Boolean Check = OnOffSwitch__c.getValues('GTMOpsCoE') !=null ? OnOffSwitch__c.getValues('GTMOpsCoE').Active__c: False;
     
       if(!Check)
        {
            return;
        }
        List<CaseShare> caseSharingRecords = new List<CaseShare>();
         
        for(Case newCase : newCaseList) {
            
            if(newCase.Reported_By__c != null && newCase.RecordTypeId == GTMOpsRT
                && (trigger.isInsert || 
                (trigger.isUpdate && newCase.Reported_By__c != (CaseOldMap.get(newCase.Id).Reported_By__c)))) {
                
                CaseShare caseShareRec = new CaseShare(CaseId=newCase.Id, UserOrGroupId= newCase.Reported_By__c, CaseAccessLevel = 'Edit');
                caseSharingRecords.add(caseShareRec);
            }   
        }
        
        if(!caseSharingRecords.isEmpty()) {
            Database.insert(caseSharingRecords, false);
        }
    }
//End -- CR-00138934 -- Changes by Veera   
}