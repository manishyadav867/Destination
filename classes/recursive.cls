// **************************************************************************************************************
// Name:                recursive
// Description:         Contains all the String Constants
//
// Created By:
//
// ************************Version Updates***********************************************************************
//
// Updated Date     Updated By      Update Comments             CR No           CR Targeted Release date
// 18-Aug-2010      Ananth Krishna  added string const          0000328         27-Aug-2010
// 20-Oct-2010      Ananth Krishna  added string const          00001834        28-Oct-2010
// 15-Feb-2011      Shubhra Sharma  added Tast recordtype variabel  00000477
// 28/2/2011        Shubhra Sharma   added boolean                 00002843      22/4/2011
// 23 March, 2011   Shubhra Sharma  added boolean      00004014
// 24-Mar-2011      Amar            added boolean const    00003583
// 11-May-2011      Sneha Jain      added boolean               00004875   
// 09-Feb-2012      Shweta Tiwari   added My Vmware Support Record Type  
// 28 Feb-2012      Shweta Tiwari   Added Record Type for         My VMware CMT
// 06 March-2012    Shweta Tiwari   Added Boolean for         My VMware CMT
// 27-Sep-2011      Rakesh Poddar   Added Boolean                 For ETM2
// 12 Jan-2012      Shweta Tiwari   Added Record Type for         Cycle 6
// 12-July-2012     Sneha Jain      Added Opportunity & Account Mapping Reference RecordType   Cycle 8 ($Rev)
// 16-July-2012     Jaypal Singh    Added DealReg RecordType      Cycle 8 (DealReg EPP)
// 31-July-2012     Shweta Tiwari   Added EPP RecordType for Deal Reg    Cycle 8 (DealReg EPP)
// 23/11/2012       Shridhar Patankar(Accenture)  CR-00022674 : Added flag isInactivePartner
// 07-Jan-2013     Smita Erande     Added 'Echo'  RecordType      
// 20-Mar-2013      Dilip Mistry   CR-00035711: Added Quota and Commissions Record Type
// 27-Apr-2013   Archana Mujumdar  Added Boolean for PLM2   CR-00037546
// 29-Jan-2014      Radhika Bahl    Added RecordType for ValueChannel Project (CR-00073860)
// 10-Feb-2014   Archana Mujumdar    Added Boolean for the CR-00077522
// 27-Mar-2014      Kush Dawar    Added boolean for ECMS Phase2
// 05-Aug-2014      Bhavesh Mistry    Added boolean for CR-00087104
//07-08-2014        Sanjib Mahanta    Added boolean variable isEmailNotificationToQualifiedLead for CR-00104200
// 11/20/2014       Hem C Gayal     BUG-00105363/BUG-00105365   101 SOQL Fix
// 24-Dec-2014      Abhishek Shubham  Code added for CR-00121623
//01/12/2014        Radhika Bahl      Declaring two constants for CR-00116223, to capture flags for the same transaction and would be used in RS2_PreventUpdateAndDelete
// 31-3-2015        Abhishek Shubham        //Added code for CR-00129652. 
// 22/04/2015       Vijit Vijay       Added Boolean for CR-00132088
// 1/07/2015        Vijit Vijay        Added Boolean for CR-00130467
// 2-June-2015      Dalia Pan      CR-00124276 : Added Boolean.
// 30-June-2015     Chhedika        Added Boolen for CR-00134168 
// 29-July-2015     Dalia Pan           CR-00135498 : Added Boolean.
// 05-Aug-2015      Sandip          Added boolean for CR-00132447
// 12 Aug 2015      Accenture           CR-00134262      04-Sept-2015   Added updateLeadAccountMatchedFlag Method.
// 18-Aug-2015    Amit Kumar      CR-00135781: Added a Static Variable to Bypass RCM Attachment trigger for Case Update.
// 18-Sep-2015     Chhedika        Added Bollean for CR-00135688 
// 18-Sep-2015     Avaneesh Singh  recursive check for PBP Project
// 20-Oct-2015     Chhedika Deshmukh  recursive check for PBP project
// 20-Nov-2015    Dalia Pan      CR-00135134 : checks for Qman batch
// 8-Dec-2015    Bhavesh Mistry    CR-00135847  PPSP Project
// 27-Dec-2015       Bhavesh Mistry     CR-00137254  PPSP Project
// 23-Mar-2016      Jyolsna             CR-00138303  WorkloadPoint Calculation
// 17-May-2016      Jyolsna             CR-00134744  Severity 1 Assignment
//**************************************************************************************************************/
public class recursive {
    //Added on 1 June 2010 for BChannelsAccountUpdate trigger
    public static boolean KBCheck = false;//CR-00140163
    public static boolean checkInbound = false;
    public static boolean isLeadFirstRun=false;
    public static boolean AccountWorkflow=false;
    public static boolean Upd_Contact = true;
    public static boolean Upd_MDF = true;
    public static boolean Upd_ProgDet = true;
    public static boolean Upd_Acc = true;
    public static boolean Upd_PD = true;
    public static boolean Upd_Region = true;
    public static boolean Upd_ISO = true;
    public static boolean firstRun = true;
    public static boolean isFirstRun = true;//Added for CR-00003090
    public static boolean isBchannelAccTgrContext = false;
    public static boolean ContactCertificationCalculation = true;
    public static boolean UserProfileUpdateOnContacts = true;
    public static boolean AddressUpdateOnContact = true;
   public static boolean ContactEmailUpdonUsr = true;
    public static boolean For_Forms = false;
    public static boolean UpdateGlobalParticipation = true;
    public static boolean Progression = true;
    public static boolean AccountCertCal = true;
    public static boolean UserEmailUpdateOnContact = true;
    public static boolean InactivateAccnt=false;
    public static boolean IsProgressionProfileUpdate=false;
    public static boolean IsCreateEntitlement=true;
    public static Boolean isAtFuture = false;
    public static Boolean isUpdateLocationOnContact  = true;
    public  static Boolean issetAccountShare = true;
    public  static Boolean ispopulateCaseFields = true;
    public static boolean isPBMUpdate = true;
    public static boolean flagtoupdate=true;
    public static boolean revIsUpdate=true;
    public static boolean runOnceTerrLock = true;//added as part of Orion Phase 2
    //CR-00132447: Added by Sandip "checkOpportunityUpdateValidation"
    public static boolean checkOpportunityUpdateValidation=false;
    public static boolean isEmailNotificationToQualifiedLead=false;
       //CR-00110154: Added to stop multiple mails on RS2 Case Closure-start
    public static boolean isRs2CaseClosureFlag=false;
    //CR-00110154: Added to stop multiple mails on RS2 Case Closure-stop 
    public static boolean IsChangedFromCrossSellUpSelltoMSO=false; //Added code for CR-00129652. 

    //SFA PRM ENHANCEMENT SEPT RELEASE
    public static boolean leadAccountMatchFlag = false;
    public static boolean isManualRelevel=false; //Added for CR-00121623
     //Added By AK for CR-00135781 on 08/17/2015 for RCM Attachment Issue***START***
     public static boolean isRCMAttachmentupdate=false;
     //Added By AK fro CR-00135781 on 08/17/2015 for RCM Attachment Issue***END***
    //Fix : 101 SOQL issue - during ModelN Integration (BUG-00105363/BUG-00105365) : 6-Dec-14 Release
    public static boolean isCheckForProductPlatformGroup=false;
    public static boolean  isGSM_ExceptionReporting=false;
    public static boolean  ispopulateISREmail=false;
    
    
    // Start Fix:101 Soql issue in PBP account trigger class PBP_UpdatePartnerBusinessPlan
    public static boolean isremoveAccessOnAccountPBM_PMMchange=false;
      public static boolean isupdateAccountExt=false;
     public static boolean isupdateOwnerPBP=false;
     public static boolean IsAssginPermissionsetInsert=false;
     public static boolean isAssginPermissionsetUpdate=false;
     public static boolean isDeactivateRelatedActiveBusinessPlan=false;
     public static boolean isPopulateBusinessPlanFieldsOnAccountUpdate=false;
    
    // End Fix:101 Soql issue in PBP account trigger class  PBP_UpdatePartnerBusinessPlan
        public static boolean isbsnesPlanBeforeUpdate=false;
        public static boolean isbsnesPlanAfterUpdate=false;
        public static boolean isbsnesPlanAfterDelete=false;
        public static boolean isbsnesPlanBeforeInsert=false;
        public static boolean isbsnesPlanAfterInsert=false;
        public static boolean ischeckUniquePartnerPlan=false;
    //Start by chhedika for PBP project
    
    //End by Chhedika for PBP project
    //START CR-00049829
    public static boolean IsUpdate=false;
    public static boolean IsUpdateClassification=false;
    //END CR-00049829
    
    //Added for CR-00038069
    public static boolean VSPPProgressionFlag=false;
  
   //Added for CR-00135847  
   public static boolean IsProgressPrdManually=false;
  //Added for CR-00135847  
  //Added for  CR-00137254  
      public static boolean IsAutoProgression=false;
      public static boolean isContactUpdate=false;
       public static boolean isPCPAlertUpdate=false;
  //End
  //Added for CR-00130467 by Vijit-START
   public static boolean IsRenewProgram=false;
  //Added for CR-00130467 by Vijit-END
    
     //Added for the CR-00077522
     public static boolean RelevelToProgressionFlag=false;
    
    public static boolean assignRegistrationInvoked = false;
    public static boolean dealRegTpsCalloutInvoked = false;
    public static boolean isfirstPartnerAccountOnLead= false;
    public static boolean isLeadFirstRunPartnerIdCheck =false;
    public static boolean isfirstRunProductLeadFilter  =false;
    //Added by Archana forPLM2
     public static boolean HistoryFirstRun=true; //Added for CR - 00037547 
    public static boolean isfirstupdateforLead=false;
    public static boolean isfirstupdateforAccount=false;
     public static boolean isfirstrunPBM=false;
      public static boolean isfirstrunAssignedLead=false;
      public static boolean isfirstrunSLAOverdue=false;
     public static boolean isfirstrunSLADate =false;
     public static boolean isfirstrunLeadOwnerProfile =false;

    //Added by Shweta for $Rev
    public static boolean revmappIsUpdate=true;
    public static boolean isfirstRunforRev=true;
    public static boolean IsRevAfterUpdate=true;
    public static boolean isfirstrunforUpdate=true;
    //End of changes by Shweta for $Rev
    
    //START - CR-00116223 - Declaring two constants for Opportunity and Case objects
    public static boolean oppInsertFlag=false;
    public static boolean caseInsertFlag=false;
    //END - CR-00116223 - Declaring two constants for Opportunity and Case objects
    
    // Rakesh for ETM2
      public static boolean IsDnBUpdated = true;
      public static boolean IsAccDnBUpdated = true;
      //End of Rakesh
    // public static Id PartnerVirtualAccountRecType = null;
    //Added on 6 July 2010 for CR-00000771 (Maintenance Page)
    public static boolean istestRTM = false;
    // Added on August 4, 2010 for CR00001457
    //Added on 30 Aug 2011 for Cycle 5 
    public static boolean isOppPartnerUpdate = true;
    public static boolean isOppPartnerDelete = true;
    
     //Added by Accenture for My VMware Project       
     public static Id MyVmwareSupportCase = null;
     //End of change for My VMware Project
     
    public static boolean isAccountTrigger = true;
    public  static Boolean issetAccountTeam = true;
    public static boolean UserUpdateFromContact = true;
    public static boolean Inactive_User_Check = true;
    public static boolean createEntitlementLines = true;
    public static boolean relevel_error = false;
    public static boolean isAccountApproval = false;
    public static boolean isAccountOwnerShipdone = false;
    public static boolean isOpptyOwnerShipdone = false;
    //Added for My Vmware
    public static boolean isInsertCase = false;
    public static boolean IsFirstUpdate= false;
     //End of change for My Vmware  
    //Added for CR-00020068
    public static boolean emailFlag = false;
    //Added by Chhedika CR-00134168 Start
    public static boolean emailThreshld = false;
    public static boolean emailNotify = false;
    //Added by Chhedika CR-00134168 End
    
    //Added By Chhedika CR-00135688 Start
    public static boolean bsinessPlan = false;
    //Added by Jaypal for CR-00022628 Dated 24 Oct 2012
    public static boolean isrReassignedByButton = false;
    
    //Added by Jaypal for CR-00025413 Dated 5 Dec 2012
    public static boolean allowBackendProcess = false;
    
    //Added by Radhika Bahl (Accenture) Dated 29th Jan, 2014 for ValueChannel (CR-00073860)
    public static Id DistributorAccountSetupForm = null;
    
    //Added by Prudhvi Godthi Dated December 1, 2014
    public static Boolean isPartnerUpdation = false;
    public static Boolean isProgramUpdation = false;
    public static Boolean isInactivePartnerUpdation = false;
    public static Boolean isPreventFutureRecursive = false;
    public static Boolean isPreventRecursiveRecord = false;
    public static Boolean isProgramUpdationNew = true;
    
    //Added by Bhavesh for  CR-00087104
    public static boolean isPBMUpdateFromAccount = false;
    
    public static boolean isInsert = true;
    public static Id PartnerAccountRecType =null;
    public static Id ProdGrpAndComMatchRecType = null;
    public static Id PartnerVirtualAccountRecType = null;
    public static Id PartnerLocationRecType =null;
    public static Id CustomerAccountRecType = null;
    public static Id NamedAccountRequestRecType = null;
    public static Id ConsultingAccountRecType = null;
    public static Id PartnerContactRecType =null;
    public static Id CustomerContactRecType =null;
    public static Id ConsultingContactRecType =null;
    public static Id ParentOpportunityRecType = null;
    public static Id ManagedSalesOpportunityRecType = null;
    public static Id TargetedPossibilityRecType = null;
    //Added a new record type for Opportunity & Account Mapping Reference - Cycle 8 ($Rev Project) : Sneha 07/12/2012
    public static Id RenewalOpportunityRecType = null;
    public static Id AccountMappingReferenceRecType = null;
    
    //Added against CR-00004875 : Sneha 05/11/2011
    public static Id VCloudOpportunityRecType = null;
    public static String accountrecordtypes = 'End Customer';//add the additional recordtype to process seperated by comma
    public static Id custReferenceRecType = null;            //Added by Achin - Deloitte
    public static Id genTaskRecType = null;                  //Added by Achin - Deloitte
    public static Id pilotTaskRecType = null;                //Added by Accenture for CR-00001759
    public static Id SEAccountTaskRecType = null;            //Added by Accenture for CR-00001759
    public static Id DTAMRecType = null;
    public static Id STAMRecType = null;
    public static Id TAMRecType = null;
    public static Id hTAMRecType = null;
    public static Id qTAMRecType = null;
    //public static boolean accreditionCountfromContact = false; //Added by Deepesh - Appirio
    //public static boolean accreditionCountfromContact2 = false; //Added by Deepesh - Appirio
   // CR-00003453
    public static boolean isTAPProgressionAfterUpdate = true;

    // Added for CR-00003583, added to check TA is running at the time of insert or update of lead
    public static boolean leadIsInsert = false;


    //Added additional record types for OppReg - Achin (Deloitte)
    public static Id OppRegAdClaimOnlyRecType = null;
    public static Id OppRegELARecType = null;
    public static Id OppRegGoingGreenRecType = null;
    public static Id OppRegGovernmentUSOnlyRecType = null;
    public static Id OppRegAdReadOnlyRecType = null;
    public static Id OppRegAdRegisterRecType = null;
    public static Id OppRegAdRequestClaimRecType = null;
    public static Id OppRegELAReadOnlyRecType = null;
    public static Id OppRegELARegisterRecType = null;
    public static Id OppRegELARequestClaimRecType = null;
    public static Id OppRegGOVReadOnlyRecType = null;
    public static Id OppRegGOVRegisterRecType = null;
    public static Id OppRegAdvantageRecType = null;
    public static Id OppRegSiebelOpportunityRecType = null;
    public static Id OppRegRegistrationLeadRecType = null;

    public static Id DealRegAdClaimOnlyRecType = null;
    public static Id DealRegELARecType = null;
    public static Id DealRegGoingGreenRecType = null;
    public static Id DealRegGovernmentUSOnlyRecType = null;
    public static Id DealRegAdReadOnlyRecType = null;
    public static Id DealRegAdRegisterRecType = null;
    public static Id DealRegAdRequestClaimRecType = null;
    public static Id DealRegELAReadOnlyRecType = null;
    public static Id DealRegELARegisterRecType = null;
    public static Id DealRegELARequestClaimRecType = null;
    public static Id DealRegGOVReadOnlyRecType = null;
    public static Id DealRegGOVRegisterRecType = null;
    public static Id DealRegAdvantageRecType = null;
         
    public static Id DealRegSiebelOpportunityRecType = null;
    public static Id DealRegRegistrationLeadRecType = null;
    public static Id DealRegBasicInfoOnlyRecType = null;
    public static Id DealRegBasicClaimRecType = null;
    public static Id DealRegBasicReadOnlyRecType = null;
    //added for cycle 8
    public static Id DealRegNewAccValidationRecType = null;
    
    //Added by Shweta for Cycle 8-Deal Reg/EPP
    public static Id DealRegEPPRecType = null;
    public static Id DealRegEPPReadOnlyRecType = null;
    //End of changes for Cycle 8-Deal Reg/EPP       
    
    // Orion Ph-2 Deal Reg RecordTypes - Starts 
    public static Id DealRegOrionAdvantageRecType = null;
    public static Id DealRegOrionAdvReadOnlyRecType = null;
    public static Id DealRegOrionAdvRegisterRecType = null;
    public static Id DealRegOrionAdvRequestClaimRecType = null;
    public static Id DealRegOrionAdvClaimOnlyRecType = null;
    // Orion Ph-2 Deal Reg RecordTypes - Ends    

    // Added by Accenture for CR-00002704
    public static Id ResourceRecordType = null;
    public static Id TeamRecordType = null;
    
    // ECMS Phase 2
    public static boolean onAgmtSaveCheck = false;
    
    // Added by Accenture for CR-0000477
    public static Id SEAccountActivity = null;
    public static Id SEInternalActivity = null;
    public static Id SEMarketingActivity = null;
    public static Id SEOpportunityActivity = null;

    //Added by Accenture for Everest Cycle 6 Project.
     public static Id LAR_AppliedRulesRecordType = null;
     public static Id LAR_AuditTrailRecordType = null;
      public static boolean isBeforeUpdate = false;
    //End of change for Everest Cycle 6 Project.  
    
    //Added for My Vmware     
    public static Id MyVmwareCommonCase = null;
     public static Id MyVmwareItAppsSupport = null;
   //End of changes for MyVmware

    //Added by Accenture for Everest Cycle 5 Project.
     public static Id SEActivity = null;

    //Added additional record type for Entitlement - Amar(Accenture)
    public static Id NFREntitlementRecType = null;
    public static Id TAPEntitlementRecType = null;
    //Added additional record type for Entitlement - CR-00020095
    public static Id TAPNFROrderEntitlementRecType = null;

    //CR-00004014 GSS
    public static Id caseGSSHelpZillaRecType = null;

    //Added additional record type for Partner Specialization
    public static Id SpecializationRecType = null;
    public static String AcademicSpecializationRecType = null;
    public static Id FormSpecializationRecType = null;
    public static Id CompetencyAdminSpecializationRecType = null;


    //Added to prevent UpdateSplitOpportunity class invoking recrusively - Accenture 29 July 10
    public static boolean isCalledfromUpdateOpportunity = false;
    public static Boolean donotfireTRtrigger = false;
    public static Boolean isReRun = false;
    public static Boolean isBatchUpdate = false;

    //Added to reduce too many future call error
    public static Boolean isUserProfileUpdateOnProgDetails = false;
    public static Boolean isRenewalCycledate = false;
    public static boolean accreditionCountfromContact = false; //Added by Deepesh - Appirio
    public static boolean accreditionCountfromContact2 = false; //Added by Deepesh - Appirio

    //Added as part of CR-00000328 - Ananth - August 16, 2010
    public static String TAP         = 'Technology Alliance Partner';
    public static String TAP_ACCESS  = 'TAP Access';
    public static String ACCESS      = 'Access';
    public static String ELITE       = 'Elite';
    public static String PREMIER     = 'Premier';
    //Added as part of CR-000001834 - Ananth - 20 Oct, 2010
    public static boolean isFromOpptyPartnerBatch = false;
    public static boolean isTestOpptyPartnerBatch = false;
// Added as part of CR-00002165 by Accenture - 8 Oct 2010
    public static Boolean isReassignfromLead = False;
    public static Boolean isDealRegistrationBeforeUpdate = False;

    // CR-00002843
    public static Boolean issueSupportCode = true;
    public static Boolean byPassRenewalCycledateTrig = true;

    //Added as part of CR-00004875 - Sneha - May 11, 2011
    public static Boolean isUpdateOpportunity = false;
    
    // Added by Rakesh for L10N on 8-Aug-2012
    
     public static boolean isConLangPref = False;
     public static boolean isUserLangPref = False;
     
    //Added by Sanjib Mahanta for CR-00015605
    public static boolean isCamMemUpdate = False;
    
    // Added by Shridhar for CR-00022674
    public static boolean isInactivePartner = false ; 
    //Added a new record type for ECHO Object - for (ECHO Project) : Smita  01/07/2013
    public static Id EchoAbandonRecType = null;

    //CR-00035711: Added Quota and Commissions Record Type
    public static Id QuotaAndCommissionCaseRT = null;
    
    //CR-00116008
    public static Boolean isUpdateOpportunityProductsList = false;
    
    //CR-00132088 : Added by Vijit
    public static Integer callPSOPracticeAllocOnOpportunityUpdate = 0;
    public static boolean callFromOpptyLineItem = false;
    // End Vijit Vijay
    
  //START - CR-00124276 - 2June2015 - Dalia Pan 
  public static boolean callFromOpportunityLineItemInsert = false;
  public static boolean callFromOpportunityLineItemUpdate = false;
  public static boolean callFromFlatRebateAdmin = false;
  public static boolean callFromOpportunityAfterUpdate = false;
  public static boolean RebateApplied = false;
  public static boolean callFromOpportunityLineItemDelete = false;
  public static boolean callFromOpportunityLineItemUpdate_future = false;
  public static boolean callFromOpportunityRTMchange = false;
  public static boolean isOpportunityBeforeRebate = false;
  //End - CR-00124276 - 2June2015 - Dalia Pan 
  public static boolean isoptyteaminsert=false;
  public static boolean isaccountupdteonopty=false;
  public static boolean isterritoryupdate=false;
    //START - CR-00135498 - 29July2015 - Dalia Pan 
    public static boolean callFromAddOpportunityProductController = false;
     public static boolean callFromAddOpportunityProductController_Insert = false;
    //End - CR-00135498 - 29July2015 - Dalia Pan 
  
  //START - CR-00135349 - 13Nov2015 - Hemangini
  public static boolean updateCaseStatusHistoryExecuted = false;
  //END - CR-00135349 - 13Nov2015 - Hemangini
  
  //START - CR-00135134 - 20Nov2015 - Dalia
    public static boolean  callFromGSSReassignPage = false;
    //END - CR-00135134 - 20Nov2015 - Dalia
    //START - CR-00138303   - 23Mar2016 - Jyolsna
    public static boolean caseOwnerChange = false;
    //END - CR-00138303   - 23Mar2016 - Jyolsna
    //START - CR-00134744 - 17May2016 - Jyolsna
    public static boolean userDataUpdate = false;
    //END - CR-00134744- 17May2016 - Jyolsna
    public static boolean optyteaminsert=false;
    // START - RS2 RoadMap 14th July-2016 - Nilanjana
    public static boolean RS2RenewalQuoteFlag=false;
    // END - RS2 RoadMap 14th July-2016 - Nilanjana
	// START - RS2 23rd Aug-2016 - Nilanjana IBS-73
    public static boolean caseUpdate=false;
	// END - RS2 23rd Aug-2016 - Nilanjana IBS-73
    static {
        RTFinder rtf=RTFinder.getRTFinder();
        //Added by Radhika Bahl (Accenture) Dated 29th Jan, 2014 for ValueChannel project (CR-00073860)
        DistributorAccountSetupForm = rtf.getRT('Form__c' , 'DistributorAccountSetupForm');
        
        PartnerAccountRecType = rtf.getRT('Account' , 'Master Account Layout');     
        PartnerVirtualAccountRecType = rtf.getRT('Account' , 'Virtual Partner Account');
        PartnerLocationRecType = rtf.getRT('Account' , 'Partner Location');
        CustomerAccountRecType = rtf.getRT('Account','End Customer');
        NamedAccountRequestRecType = rtf.getRT('Account','Named Account Request');
        ConsultingAccountRecType = rtf.getRT('Account','Consulting Account');

        PartnerContactRecType = rtf.getRT('Contact' , 'Partner Contact');
        CustomerContactRecType = rtf.getRT('Contact','Customer Contact');
        ConsultingContactRecType = rtf.getRT('Contact','Consulting Contact');

        ParentOpportunityRecType = rtf.getRT('Opportunity','Parent Opportunity');
        ManagedSalesOpportunityRecType = rtf.getRT('Opportunity','Managed Sales Opportunity');
        TargetedPossibilityRecType  = rtf.getRT('Opportunity','Targeted Possibility');
        //Added a new record type for Opportunity & Account Mapping Reference- Cycle 8 ($Rev Project) : Sneha 07/12/2012
        RenewalOpportunityRecType = rtf.getRT('Opportunity','Renewal Opportunity');
        AccountMappingReferenceRecType = rtf.getRT('Account_Mapping_Reference__c','Create Account Mapping Reference');
        
        //Added against CR-00004875 : Sneha 05/11/2011
        VCloudOpportunityRecType = rtf.getRT('Opportunity','Customer Renting VSPP from Service Provider');
            
        //Fetching Entitlement RT - Added by Amar(Accenture)
        NFREntitlementRecType = rtf.getRT('Entitlement__c','NFR');
        //Added for Digital River
        TAPEntitlementRecType = rtf.getRT('Entitlement__c','TAP Store Order');
        
        //Added for CR-00020095
        TAPNFROrderEntitlementRecType = rtf.getRT('Entitlement__c','TAP NFR Order');

        //Getting Specialization RecType
        SpecializationRecType = rtf.getRT('Competency__c','Specialization');
        AcademicSpecializationRecType='Academic';
        FormSpecializationRecType = rtf.getRT('Form__c','Specialization');
        CompetencyAdminSpecializationRecType = rtf.getRT('Competency_Admin__c', 'Specialization');
        //CompetencyAdminCompetencyRecType = rtf.getRT('Competency_Admin__c', 'Competency');

        //Fetching OppReg RT - Added by Achin (Deloitte)
        OppRegAdClaimOnlyRecType = rtf.getRT('Opportunity','OppReg - Ad+ - Claim Only');
        OppRegELARecType = rtf.getRT('Opportunity','ELA');
        OppRegGoingGreenRecType = rtf.getRT('Opportunity','Going Green');
        OppRegGovernmentUSOnlyRecType = rtf.getRT('Opportunity','Government (US Only)');
        OppRegAdReadOnlyRecType = rtf.getRT('Opportunity','OppReg - Ad+ - Read Only');
        OppRegAdRegisterRecType = rtf.getRT('Opportunity','OppReg - Ad+ - Register');
        OppRegAdRequestClaimRecType = rtf.getRT('Opportunity','OppReg - Ad+ - Request Claim');
        OppRegELAReadOnlyRecType = rtf.getRT('Opportunity','OppReg - ELA - Read Only');
        OppRegELARegisterRecType = rtf.getRT('Opportunity','OppReg - ELA - Register');
        OppRegELARequestClaimRecType = rtf.getRT('Opportunity','OppReg - ELA - Request Claim');
        OppRegGOVReadOnlyRecType = rtf.getRT('Opportunity','OppReg - Gov - Read Only');
        OppRegGOVRegisterRecType = rtf.getRT('Opportunity','OppReg - Gov - Register');
        OppRegAdvantageRecType = rtf.getRT('Opportunity','advantage+');
        OppRegSiebelOpportunityRecType = rtf.getRT('Opportunity','Siebel Opportunity');
        OppRegRegistrationLeadRecType = rtf.getRT('Opportunity','Registration - Lead');

        DealRegAdClaimOnlyRecType = rtf.getRT('Deal_Registration__c','DealReg - Ad+ - Claim Only');
        DealRegELARecType = rtf.getRT('Deal_Registration__c','ELA');
        DealRegGoingGreenRecType = rtf.getRT('Deal_Registration__c','Going Green');
        DealRegGovernmentUSOnlyRecType = rtf.getRT('Deal_Registration__c','Government (US Only)');
        DealRegAdReadOnlyRecType = rtf.getRT('Deal_Registration__c','DealReg - Ad+ - Read Only');
        DealRegAdRegisterRecType = rtf.getRT('Deal_Registration__c','DealReg - Ad+ - Register');
        DealRegAdRequestClaimRecType = rtf.getRT('Deal_Registration__c','DealReg - Ad+ - Request Claim');
        DealRegELAReadOnlyRecType = rtf.getRT('Deal_Registration__c','DealReg - ELA - Read Only');
        DealRegELARegisterRecType = rtf.getRT('Deal_Registration__c','DealReg - ELA - Register');
        DealRegELARequestClaimRecType = rtf.getRT('Deal_Registration__c','DealReg - ELA - Request Claim');
        DealRegGOVReadOnlyRecType = rtf.getRT('Deal_Registration__c','DealReg - Gov - Read Only');
        DealRegGOVRegisterRecType = rtf.getRT('Deal_Registration__c','DealReg - Gov - Register');
        DealRegAdvantageRecType = rtf.getRT('Deal_Registration__c','advantage+');
        
        // Orion Ph-2 DealReg Record Types - Starts        
        DealRegOrionAdvantageRecType = rtf.getRT('Deal_Registration__c','DealRegistration - Advantage+');
        DealRegOrionAdvReadOnlyRecType = rtf.getRT('Deal_Registration__c','DealRegistration - Ad+ - Read Only');
        DealRegOrionAdvRegisterRecType = rtf.getRT('Deal_Registration__c','DealRegistration - Ad+ - Register');
        DealRegOrionAdvRequestClaimRecType = rtf.getRT('Deal_Registration__c','DealRegistration - Ad+-ReqClaim');
        DealRegOrionAdvClaimOnlyRecType  =  rtf.getRT('Deal_Registration__c','DealRegistration - Ad+ - Claim Only');
        // Orion Ph-2 DealReg Record Types - Ends        
        
        DealRegSiebelOpportunityRecType = rtf.getRT('Deal_Registration__c','Siebel Opportunity');
        DealRegRegistrationLeadRecType = rtf.getRT('Deal_Registration__c','Registration - Lead');
        DealRegBasicInfoOnlyRecType = rtf.getRT('Deal_Registration__c','DealReg - Basic Info Only');
        DealRegBasicClaimRecType = rtf.getRT('Deal_Registration__c','DealReg - Basic Request Claim');
        DealRegBasicReadOnlyRecType = rtf.getRT('Deal_Registration__c','DealReg - Basic Read Only');
        //added for cycle 8
        DealRegNewAccValidationRecType = rtf.getRT('Deal_Registration__c','Deal Reg - New Account Validate');
        //Added by Shweta for Cycle 8-Deal Reg/EPP
        DealRegEPPRecType=rtf.getRT('Deal_Registration__c','DealReg - EPP Burn Down');
        DealRegEPPReadOnlyRecType=rtf.getRT('Deal_Registration__c','DealReg - EPP - Read Only');
        
        //End of changes for Cycle 8-Deal Reg/EPP

        //Fetching Customer Reference/Task RT - Added by Achin (Deloitte)
        custReferenceRecType = rtf.getRT('Customer_Reference__c','Customer Reference');
        genTaskRecType = rtf.getRT('Task','General Task');
        pilotTaskRecType = rtf.getRT('Task','Pilot Program Activities');  //Added by Accenture for CR-00001759
        SEAccountTaskRecType = rtf.getRT('Task','SE Account Activity');   //Added by Accenture for CR-00001759

        //Fetching Task-Tam Record types
        DTAMRecType = rtf.getRT('Task','DTAM Activity');
        STAMRecType = rtf.getRT('Task','STAM Activity');
        TAMRecType = rtf.getRT('Task','TAM Activity');
        hTAMRecType = rtf.getRT('Task','h - TAM Activity');
        qTAMRecType = rtf.getRT('Task','q - TAM Activity');
        //Added by Accenture for CR-00002704
        ResourceRecordType = rtf.getRT('VMW_Team_Resource__c','Resource');
        TeamRecordType = rtf.getRT('VMW_Team_Resource__c','Team');

    //CR-00004014 GSS
       caseGSSHelpZillaRecType = rtf.getRT('Case','Help-SFDC-Zilla for GSS');

        // Added by Accenture for CR-00000477
       SEAccountActivity = rtf.getRT('Task','SE Account Activity');
       SEInternalActivity = rtf.getRT('Task','SE Internal Activity');
       SEMarketingActivity = rtf.getRT('Task','SE Marketing Activity');
       SEOpportunityActivity  = rtf.getRT('Task','SE Opportunity Activity');
       //Added by Accenture for Evesrest Cycle 5 Project
       SEActivity=rtf.getRT('Task','SE Activity');
       
       //Added for My Vmware CMT 2
       MyVmwareCommonCase=rtf.getRT('Case','Common Record Type');
       MyVmwareItAppsSupport=rtf.getRT('Case','IT Apps Support');
       //End of changes for MyVmware
       
        //Added by Accenture for My VMware Project
       MyVmwareSupportCase=rtf.getRT('VMW_Change_Request__c','My Vmware Support');
       //End of change for My VMware Project
       
       // Added by Accenture for Cycle 6
       LAR_AppliedRulesRecordType = rtf.getRT('Lead_Assignment_Rules__c','Applied Rules');
       LAR_AuditTrailRecordType = rtf.getRT('Lead_Assignment_Rules__c','Audit Trail');  
       //End of change for Cycle 6  
      //Added a new record type for ECHO Object - for (ECHO Project) : Smita  01/07/2013
       EchoAbandonRecType = rtf.getRT('Echo__c','ABANDON');
          
        //CR-00035711: Added Quota and Commissions Record Type
       QuotaAndCommissionCaseRT = rtf.getRT('Case','Quota and Commissions');
       //Added a new record type for Product Group and Competency Matching: sanjib 30-May-2013
       ProdGrpAndComMatchRecType = rtf.getRT('Product_Group_and_Competency_Map__c', 'Product Group and Competency Match');
     
   }
}