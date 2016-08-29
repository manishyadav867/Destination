//****************************************************************************************************
// Name             : Orion_DealReg_FormController.cls
// Description      : Controller class for Deal Registration Forms
// Created By       : Accenture
// Created Date     : 07/11/2012
// *******************************************************************************************************
//Modification Log :
//-----------------------
//* Developer                   Date                   Description
//* ----------                  -----                  ------------------------
//* Accenture                 30 Oct 2012            Updated as a part of CR-00020258
//* Bhawani Sharma            02/06/2013             Replaced Campaign_Name__c with Lead_Campaign_Name__c for CR-00024618
//* Accenture                 06 Mar 2013            Updated as a part of CR-00020284
//* Accenture                 08-Jun-2013            Modified for PLM Phase-2
//* Accenture                 24-Dec-2013            Added more value for Preferred Distributor as part of CR-00072075(Added variable Distributer)
//* Kunal                     24-Feb-2014            CR-00022627 - Replaced Inactive with Re-Registered.
//* Vijit Vijay               29-Sep-2014            CR-00104637 - Making Postal code a compulsory field
//* Sandip                    20-Octo-2014           CR-00113657 - Registrations Missing Preferred Distributor
//* Sandip                    09-Dec-2014           CR-00122078 - Preferred Channel is empty remaining empty for few registration.
//* Manik                     02/01/2015             CR-00121519 - Added Logic for limiting Preferred Distributor when Customer Market Segment - US Federal
//* Yoganand                  11-Dec-2014            Renaisance Phase 2 Requirement to pass Product data from lead to deal reg
//* Pallavi Jha(Accenture)    05- May -2015          CR-00128939 Added Conditions.
//*Safiya                   19-June-2015            CR-00110180 Customized list of distributors for partners in French Caribbean
//*Manu                       15-May-2015            CR-00134260- Partner Opportunity Registration-Added new field mappings for CrossFire.      
//*Manu                       15-May-2015            BUG-00122848- Display Opportunity Source for Dea Reg Created from XSEll Leads
//* Swati             09-July-2015       CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor'
//*Uma                        04-Nov-2015            CR-00136738 Totally Remove the $6k Validation 
// yoganand                   10/03/2016               Modified as part of Orion Phase 2             
// Manu                       5/12/2016                Change for BUG-00146507  
// Vijit Vijay        		  10/8/2016               Change for CR-00140707
// Archana                    10/8/2016               Changed for CR-00140701
// Vijit Vijay                26/8/2016 			  Changed for CR-00140564 and CR-00140795
//************************************************************************************************************/
public class Orion_DealReg_FormController {
    
    string dealDenailReason;//added as part of Orion Phase 2 Yoganand
    public Deal_Registration__c dealReg{get;set;}
    public String reregisterdeal {get;set;}
    public String sharedDataPrefDisti{get;set;}
    public Boolean readyforAppcheck{get;set;}
    Public Set<Id> deleteProduct = new Set<Id>();
    Public String nameValue {get;set;}
    Public String quantityValue{get;set;}
    public Boolean recApproved{get;set;}
    public Boolean submitButtonRender {get;set;}
    public String dealStatus{get; set;}
    public List<SelectOption> ProductListItem{get;set;}
    public Map<String,Product2> ProdNewMap;
    public String rowToRemove{get; set;}
    public String prodRec {get;set;} 
    public String SourcedAcc {get;set;}//added as part of orion Phase 2 Yoganand
    public Integer Index {get;set;}
    public Boolean regProgstamp {get;set;}
    public string programType = '';
    public prodwrapper te {get;set;}
    public string marketSegement = '';
    public string stageOptions = '';
    public Set<String> eligibleProgramSet = new Set<String>();
    public String productSelected {get;set;} 
    public String Domain{get;set;} 
    public String productSelected2 {get;set;} 
    public boolean elaSectionRen;
    public boolean eppSectionRen;
    public String nextStageSelection{get;set;}
    public String leadServiceValue {get; set;}
    public boolean showMsg;
    public boolean progTypeText;
    public boolean prefChannelRen;
    Boolean leadToDealConvert = false;  
    public List<Orion_Subscription_Service_Detail__c> subservicesList {get;set;}
    public static String progType = ApexPages.currentPage().getParameters().get('programType');
    public static String RegId = ApexPages.currentPage().getParameters().get('id');    
    public String pType = ApexPages.currentPage().getParameters().get('type');
    public Boolean recLocked{get;set;}
  public Boolean showLeadServices {get;set;}
  //Added below line for CR-00140701
  public Boolean professionalPartnerCheck {get; set;}
    
    public String disclaimer='';
    public String disclaimerforFullReg='';
    public Deal_Registration__c newDealReg;
    //Changes End for CR-00072075
    public String distributer {get ; set;}
    public List<prodwrapper> productListAdd {get;set;}
       
  //  public List<prodwrapper> productList{get; set;}
    //Added by manu-BUG-00122848-Start
    public String campaignName{get;set;}
    public String OranId {get;set;}
    //Added by manu-BUG-00122848-Start
   public List<ProcessInstance> existingApprovals = new List<ProcessInstance>();
    public Boolean isEdit = false;
    /* 11th March 2016 by Vijit Vijay - Added as a part of Orion Ph2 Project. START */
    ID conRecordTypeID = Record_Type_Settings__c.getall().get('SFA_Con_Cust').Record_Type_ID__c;  
    ID partnerContRecordTypeID = Record_Type_Settings__c.getall().get('PRM_Con_PC').Record_Type_ID__c; 
    ID partnerAccRecordTypeID = Record_Type_Settings__c.getall().get('PRM_Acc_MAL').Record_Type_ID__c; 
    String expirationDays = (Orion_Phase_II_Configurations__c.getInstance('ExpirationDays')!=null && Orion_Phase_II_Configurations__c.getInstance('ExpirationDays').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('ExpirationDays').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('ExpirationDays').value__c:'90';
    
    String dealregBasicURL1 = (Orion_OppRegURL__c.getInstance('DealRegBasicURL1')!=null && Orion_OppRegURL__c.getInstance('DealRegBasicURL1').URL__c!=null && Orion_OppRegURL__c.getInstance('DealRegBasicURL1').URL__c!='')?Orion_OppRegURL__c.getInstance('DealRegBasicURL1').URL__c:'/apex/page?name=incentives.Advantage&sfdc.tabName=';   // Changes to fix Prod Issue - 12/08/2016 - Vijit     
    
    Integer extendedExpirationDays = Integer.ValueOf(expirationDays);
    public string countrySelected{get;set;} 
    public string emailSelected{get;set;}
    public string address1Selected{get;set;} 
    public string address2Selected{get;set;} 
    public string address3Selected{get;set;} 
    public string address4Selected{get;set;} 
    public string citySelected{get;set;} 
    public string zipSelected{get;set;} 
    public string stateSelected{get;set;} 
    public string contactCountry{get; set;}  
    public string contactDomain{get; set;}
    public string contactAccountName{get; set;}
    public string contactState{get; set;}  
    public string contactCity{get; set;}
    public string contactAccountGeo{get; set;}
    public string contactZipCode{get; set;}
    public string contactId{get; set;} 
    Id contactAccount{get;set;} 
    public String pdisti{get;set;}
    public Integer countAirwatchProduct = 0;
    public Integer extendedExpirationDaysRegProgram = 0;
    public String dealCountry{get;set;}
    /* 11th March 2016 by Vijit Vijay - Added as a part of Orion Ph2 Project. END */
    //End of change for CR-00020258
    //Added as a part of L10N - CR-00013048
    String userPreferredLanguage = 'en';
    public Set<Id> accIdSET{get;set;}  //Added as part of CR-00140795 on 23/Aug/2016 - Vijit
    public boolean multiAccountFound{get; set;} //Added as part of CR-00140795 on 23/Aug/2016 - Vijit
    
    Map<String, String> userLangRegProgConfig = new Map<String, String>();
    Map<String,RegistrationProgramConfig__c> regProgramConfigEnglishMap = new Map<String, RegistrationProgramConfig__c>();    
    Map<String, String> lead_And_Oppty_Fields = new Map<String, String>();
    Map<String, String> lead_And_Oppty_Fields1 = new Map<String, String>();
    // Added below by Manik CR-00121519 
    public User loggedinUser = new user();
    
    List<String> Leadfields = new List<String>();
    List<String> Leadfields1 = new List<String>();
    String leadID {get;set;} 
//    public string prefDist{get;set;}
    public List<SelectOption> PrefDistItems{get;set;}
    public boolean preDistBool{get;set;}
    // Added below by Manik CR-00121519 
    public Boolean PerfDistiCustomBool{get;set;}
    
    Deal_Registration__c tmpDealReg  {get;set;}
    Map<String,Boolean> allowLeadServicesProduct {get; set;}
    
    public static final String LEADOBJECTNAME ='Lead';
    public static final String DEALREGOBJECTNAME='Deal_Registration__c';
    //public static final String LEAD_XSELL_RECORDTYPE='XSUS Cross-Sell/Up-Sell -Renewals';
    public static final String LEAD_XSELL_RECORDTYPE='XSUS Cross-Sell/Up-Sell - Renewals';    
    
    //Partner User Check
    public boolean isPartnerEliglible{get;set;}
    public Id thisDealid {get;set;}  // Prasad : 22nd March 2016 - Test Code To Be Deleted
    
    /* Prasad - 10-Apr-2016 - Orion Ph-2 - Discount Matrix Layout Declarations - Starts */
        public List<Orion_Discount_Matrix_Discount__c> lstDisMatDiscounts {get;set;}
        public Map<String, Decimal> mapUniqueProdPlatToDiscount {get;set;}
        public Id discountMatrixHeaderId {get;set;}
        public Map<String,List<String>> mapPlafGrpToPrdPlaf {get;set;}
        public Set<String> setProductPlatforms {get;set;}
        public List<String> lstProductPlatforms {get;set;}
        public Set<String> setPlatformGroups {get;set;}
        public Set<String> setDealBands {get;set;}
        //List<String> lstPlatformGroups = new List<String>();
        public String customUniqueKey = '';
        public Integer platformcount {get;set;} 
        //public Map<String,Map<String,Decimal>> mapBandToPlafGrpDiscounts {get;set;} 
        public Map<String,Map<String,String>> mapBandToPlafGrpDiscounts {get;set;} 
        //public Map<String,Decimal> mapPlafGrpToDiscount {get;set;}
        //public Map<String,Decimal> mapPlafGrpToDiscountTemp {get;set;}
        public Map<String,String> mapPlafGrpToDiscount {get;set;}
        public Map<String,String> mapPlafGrpToDiscountTemp {get;set;}
        public List<String> lstDealBands {get;set;}
        public String plafgroupname; 
        public Decimal tempDiscount; 
        public String strProdPlfVariableDiscount {get;set;}    // Prasad : 29-May-2016
    /* Prasad - 10-Apr-2016 - Orion Ph-2 - Discount Matrix Layout Declarations - Ends*/ 
    
    /* Prasad - 30-Apr-2016 - Orion Ph-2 - Products Control - Starts */
        
        public String strSelProductName {get;set;}
    
    /* Prasad - 30-Apr-2016 - Orion Ph-2 - Products Control - Ends */
    
    //added by yoganand - Orion Phase 2 - start
    Public boolean stopActionPoller{get;set;}
    Public integer pollerCount{get;set;}
    //added by yoganand - Orion Phase 2 - end
    
    public Orion_DealReg_FormController(ApexPages.StandardController controller)
    {
        //Added as part of CR-00140795 on 23/Aug/2016 - Vijit - START
        accIdSet= new Set<Id>();
        multiAccountFound=false;
        //Added as part of CR-00140795 on 23/Aug/2016 - Vijit - END
        
  //Added below line for CR-00140701
    professionalPartnerCheck = false;
    //added by yoganand - Orion Phase 2 - start
    stopActionPoller = true;
    pollerCount = 0;
    //added by yoganand - Orion Phase 2 - end
    
  //  controller.addFields(new List<String>{'Preferred_Channel__c '});
    Index = -1;
    //Index = 0;
    dealReg = new Deal_Registration__c();
       // code changes for CR-00122078 started by sandip
      productListAdd= new List<prodwrapper>();
           
     //  controller.addFields(new String[]{'Reject_Date__c','Id','Orion_Close_Probability__c','Final_Approval_Date__c','Preferred_Channel__c','Customer_Market_Segment__c','Address_1__c','Previous_Registration__c','Manual_Review__c', 'Preferred_Distributor__c'});
     if(!Test.isRunningTest()){
        controller.addFields(new String[]{'Id','Is_Orion_DealReg__c','Are_You_the_Primary_Sales_Contact__c','Incentive_Program__c','Primary_Sales_Contact_Email__c','Orion_Primary_Sales_Contact_Name__c','Primary_Sales_Contact_Phone__c','Orion_Additional_Contact_Name__c','Additional_Contact_Email__c','Email__c','Job_Role__c','Country__c','Customer_Market_Segment__c','Company__c','Department__c','Orion_Customer_Domain__c','Orion_Authority_to_Purchase__c','First_Name__c','EA_Number__c','Last_Name__c','Phone__c','Address_1__c','State_Province__c','Address_2__c','City__c','Address_3__c','Zip_Postal_Code__c','Address_4__c','Project_Name__c','VMware_Sales_Engaged__c','VMware_List_License_Value__c','VMware_Sales_Contact_Name__c','Orion_Development_Fund_Utilized__c','Order_Number__c','Primary_Involvement_in_the_Deal__c','Campaign_Name__c','Project_Focus__c','CloseDate__c','of_Servers__c','Total_Project_Value__c','of_Desktops__c','Does_the_Customer_have_budget__c','Does_the_Customer_have_a_SAN__c','SAN_Vendor__c','Offering_Type__c','StageName__c','Orion_CIO_Sponsorship__c','Orion_Close_Probability__c','What_is_your_customer_trying_to_solve_fo__c','Name','Registration_Status__c','ORAN__c','Orion_Eligible_for_Benefits_Date__c','Value_Selling_Activities_Provided__c','First_Activity_for_this_Deal__c','Next_Steps__c','SnS_Type__c','Sns_Term__c','Preferred_Channel__c','Preferred_Distributor__c','Joint_Selling_Opt_in__c','Final_Approver_in_Customer_Organization__c','Final_Approver_Title__c','Customer_Decision_Maker__c','Customer_Decision_Maker_Title__c','Initial_EPP_Order_Number__c','Additional_Opportunity_Information__c','Disclaimer_del__c','Form_Navigation__c','Orion_Need_To_Update_Management_Form__c','Reject_Date__c','Final_Approval_Date__c','Previous_Registration__c','Manual_Review__c','Orion_AirwatchByPass__c','Do_You_Plan_To_Lead_Services__c'});
     }
     
     // Prasad : 15-Jul-2016 - For ActionPoller Init 
    String dealRegRecId  = ApexPages.currentPage().getParameters().get('Id');
    if(dealRegRecId != null && dealRegRecId != ''){
        if(((Deal_Registration__c)controller.getRecord()).Incentive_Program__c == null){
            //added by yoganand - Orion Phase 2 - start
            stopActionPoller = false;
            //pollerCount = 0;
            //added by yoganand - Orion Phase 2 - end
        }else{
            stopActionPoller = true;
        }
    }       
        Deal_Registration__c prefChannelvalueCompare = (Deal_Registration__c)controller.getRecord();
        
       // recApproved = true;
       
          reregisterdeal=  ApexPages.currentPage().getParameters().get('reRegister');
       
        /* Prasad : 22nd March 2016 - Test Code To Be Deleted From Page - Starts
        thisDealId = ApexPages.currentPage().getParameters().get('dealid');
       
           Prasad : 22nd March 2016 - Test Code To Be Deleted From Page - Ends
        */ 
       // code changes for CR-00122078 end by sandip
       PrefDistItems = new List<SelectOption>();
       //Added as a part of L10N - CR-00013048  
        // Modified below by Manik CR-00121519 - removed initialization in constructor 
        //Added Sub_Region__c field in quesry for CR-00110180
       loggedinUser = [Select Id, ContactId,Contact.Account.Sub_Region__c,contact.Language_Preference__c, contact.Prefered_Language_Formula__c, contact.Account.Geo__c,Contact.RecordType.Name,IsActive,IsPortalEnabled,Profile.UserLicense.Name, Contact.Account.Preferred_Distributor__c,Contact.Phone,Contact.Email, Contact.Account.Country__c, Contact.Account.Partner_ID__c from User where Id =: UserInfo.getUserId()];
       
       if(loggedinUser.ContactId != NULL){
            userPreferredLanguage = loggedinUser.contact.Prefered_Language_Formula__c;
       }
       
       //Partner User Check
       isPartnerEliglible = false;
       if(loggedinUser.Contact.RecordType.Name=='Partner Contact' && loggedinUser.IsPortalEnabled && loggedinUser.Profile.UserLicense.Name=='Gold Partner'){
           isPartnerEliglible = true;    
       }
     showLeadServices = false;
       // if condition added for CR-00122078 started by sandip
     // CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
     ProdNewMap = new Map<String,Product2>();
     // Prasad : 24-Apr-2016 - Removed Transfer_To_Opportunity = true check - Temporary change 
     allowLeadServicesProduct = new Map<String,Boolean>();
     for(Product2 prrec:[Select Id,Division__c,Product_Platform__c,Product_Group__c,Platform_Group__c,Allow_entry_of_Lead_Services_field__c,Registration_Product_Name__c,IsSFA_PRM_Product__c from Product2 where Registration_Product_Name__c!=null and isActive= true and Transfer_to_Opportunity__c=true]){
         ProdNewMap.put(prrec.Registration_Product_Name__c,prrec);
         allowLeadServicesProduct.put(prrec.Registration_Product_Name__c,prrec.Allow_entry_of_Lead_Services_field__c);
     }
     
       if(prefChannelvalueCompare!=null && prefChannelvalueCompare.Preferred_Channel__c != 'VMware Distributor'){
           preDistBool = true;
       }    
       PrefDistItems.add(new SelectOption('','--None--'));
       List<Geo_Preferred_Distributor_Mapping__c> geoPrefDist = Geo_Preferred_Distributor_Mapping__c.getall().values();
       list<string> geoPrefTempList = new List<string>();
       map<String,String> mapPrfList = new map<String,String>();
          if(geoPrefDist != null && !geoPrefDist.isEmpty()){
            //geoPrefList.sort(); //commented by Safiya
            //Added by safiya for the CR-00110180
            for(Geo_Preferred_Distributor_Mapping__c geoPer: geoPrefDist){
                if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Sub_Region__c != null && loggedinUser.Contact.Account.Sub_Region__c == 'French Caribbean'){
                    if(userPreferredLanguage != null && userPreferredLanguage != '' && geoPer.Sub_Region__c != null && geoPer.Sub_Region__c == 'French Caribbean' && geoPer.Language__c != null && geoPer.Language__c != '' && userPreferredLanguage.trim().ToUpperCase() == geoPer.Language__c.trim().ToUpperCase() && geoPer.Value__c != Null && geoPer.Value__c != ''){
                        //PrefDistItems.add(new SelectOption(geoPer.Value__c,geoPer.Value__c));
                        geoPrefTempList.add(geoPer.Value__c);
                        mapPrfList.put(geoPer.Value__c,geoPer.Value__c);
                    }
                }else if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && geoPer.Geo__c == loggedinUser.Contact.Account.Geo__c && userPreferredLanguage == geoPer.Language__c && geoPer.Value__c != Null && geoPer.Value__c != '' && geoPer.Translated_Value__c != null){ //&& geoPer.Value__c != '' && geoPer.Value__c != Null && str == geoPer.Value__c
                    //PrefDistItems.add(new SelectOption(geoPer.Translated_Value__c, geoPer.Value__c));
                    geoPrefTempList.add(geoPer.Value__c);
                    mapPrfList.put(geoPer.Value__c,geoPer.Translated_Value__c);
                }                   
            }
            if(!geoPrefTempList.isEmpty())
            geoPrefTempList.sort();
            for(String strVal : geoPrefTempList){
                if(strVal  != '' && mapPrfList != null && mapPrfList.get(strVal) != null && mapPrfList.get(strVal) != ''){
                    //PrefDistItems.add(new SelectOption(mapPrfList.get(strVal),strVal));
                }
            }
            //doSort(PrefDistItems, FieldToSort.Value); Commented By Safiya
            //Ended by safiya for the CR-00110180
       }
       
       Map<String,RegistrationProgramConfig__c> regprogConfigMap = RegistrationProgramConfig__c.getall();
        for(RegistrationProgramConfig__c getProgConfig: regprogConfigMap.values()){
            if(userPreferredLanguage == getProgConfig.language__c){
                userLangRegProgConfig.put(getProgConfig.ProgramType__c,getProgConfig.Translated_Value__c);
            }
            if(getProgConfig.language__c == 'en'){
                regProgramConfigEnglishMap.put(getProgConfig.Name__c,getProgConfig);
            }       
        }      
      
       Id LeadId=(System.currentPageReference().getParameters().get('leadid'));
        if(LeadId!=null){
                   /*
                   Lead tempLead=[Select id, OwnerId,of_Servers__c,of_Desktops__c,Virtualization_Project__c,Territory__c,Sub_Region__c,Storage_Used__c,State_Province__c,Siebel_Account_ID__c,Screening_Status__c,Screening_Results__c,LDR__c,Refresh_Server__c,Refresh_Desktop__c,Preferred_Reseller__c,Preferred_HW_Vendor__c,Postal_Code__c,Partner_Account__c,Original_Marketing_Source__c,Original_Lead_Source__c,lead_ID__c,Last_Campaign_Response__c,Job_Role__c,GULT__c,GEO__c,Department__c,Decision_Making_Role__c,DUNS__c,Country__c,City__c,Campaign__c,Campaign_Id__c,Budgeted_Project_Within_3_Months__c,Address_2__c,Address_1__c,Relationship_With_VMware__c,Region__c,Employees_in_Country__c,Employees_Worldwide__c,Contact_me__c,State,Street,Rating,PostalCode,Phone,LeadSource,LastName,FirstName,Email,Company,Website,Title,Description,DULT__c,Industry,Products__c,Respondent_s_Comments__c,Pass_to_Sales_Date__c,Channel_Overlay_Territory__c,Global_overlay_territory__c,Primary_Channel_Sales_Territory__c,Primary_Field_Sales_Territory__c from Lead WHERE Id = :LeadId ];
                   */
                   //Modified by Manu - CR-00134260-XFire-Start
                   //Id xSellUpSellRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(LEAD_XSELL_RECORDTYPE).getRecordTypeId();
                   Id xSellUpSellRecordTypeId=(Record_Type_Settings__c.getInstance('Lead_XSUS')!=null && Record_Type_Settings__c.getInstance('Lead_XSUS').Record_Type_ID__c!=null) ? Record_Type_Settings__c.getInstance('Lead_XSUS').Record_Type_ID__c:Lead.sObjectType.getDescribe().getRecordTypeInfosByName().get(LEAD_XSELL_RECORDTYPE).getRecordTypeId();
                   String Query='Select id,recordtypeid, OwnerId,of_Servers__c,of_Desktops__c,Virtualization_Project__c,Territory__c,Sub_Region__c,Storage_Used__c,State_Province__c,Siebel_Account_ID__c,Screening_Status__c,Screening_Results__c,LDR__c,Refresh_Server__c,Refresh_Desktop__c,Preferred_Reseller__c,Preferred_HW_Vendor__c,Postal_Code__c,Partner_Account__c,Original_Marketing_Source__c,Original_Lead_Source__c,lead_ID__c,Last_Campaign_Response__c,Job_Role__c,GULT__c,GEO__c,Department__c,Decision_Making_Role__c,DUNS__c,Country__c,City__c,Campaign__c,Campaign_Id__c,Budgeted_Project_Within_3_Months__c,Address_2__c,Address_1__c,Relationship_With_VMware__c,Region__c,Employees_in_Country__c,Employees_Worldwide__c,Contact_me__c,State,Street,Rating,PostalCode,Phone,LeadSource,LastName,FirstName,Email,Company,Website,Title,Description,DULT__c,Industry,Products__c,Respondent_s_Comments__c,Pass_to_Sales_Date__c,Channel_Overlay_Territory__c,Global_overlay_territory__c,Primary_Channel_Sales_Territory__c,Primary_Field_Sales_Territory__c';
                   List<XFIRE_Enrichment_Field_Mapping__c> leadOppRegFieldMapping=new List<XFIRE_Enrichment_Field_Mapping__c>();
                   //leadOppRegFieldMapping=[Select Source_API_Name__c,Source_Object_API_Name__c,Target_API_Name__c from XFIRE_Enrichment_Field_Mapping__c where Source_Object_API_Name__c='Lead' and IsActive__c=true and Target_API_Name__c='Deal_Registration__c'];
                   Map<String,String> leadOppRegFieldsMap=new Map<String,String>();
                   /*for(XFIRE_Enrichment_Field_Mapping__c obj:leadOppRegFieldMapping)
                   {
                        if(!Query.containsIgnoreCase(obj.Source_API_Name__c))
                        {
                            Query+=','+obj.Source_API_Name__c;
                        }
                        leadOppRegFieldsMap.put(obj.Source_API_Name__c,obj.Target_API_Name__c);
                   }*/
                    List<String> QueryFieldsList=Query.Split(',');
                   for(XFIRE_Enrichment_Field_Mapping__c obj: XFIRE_Enrichment_Field_Mapping__c.getAll().values()){
                    //add to query only the Opportunity object fields
                        if(obj!=null && obj.IsActive__c && obj.IsActive__c && obj.Source_Object_API_Name__c!=null && obj.Source_Object_API_Name__c.equalsIgnoreCase(LEADOBJECTNAME) && obj.Target_Object_API_Name__c!=null && obj.Target_Object_API_Name__c.containsIgnoreCase(DEALREGOBJECTNAME))
                        {
                              //if(!Query.containsIgnoreCase(obj.Source_API_Name__c))
                              Boolean dupFlag=false;
                              for(String str:QueryFieldsList)
                              {
                                if(str.equalsignorecase(obj.Source_API_Name__c))
                                {
                                    dupFlag=true;
                                    break;
                                }
                              }
                              if(!dupFlag)
                              {
                                  Query+=','+obj.Source_API_Name__c;
                                  leadOppRegFieldsMap.put(obj.Source_API_Name__c,obj.Target_API_Name__c);
                              }
                        }
                    } 
                   Query+=' from Lead WHERE Id =\''+LeadId+'\'';
                 
                   Lead tempLead=Database.Query(Query);
                   
                   tmpDealReg= (Deal_Registration__c)controller.getRecord();
                   
                   //Modified by Manu for-CR-00134260-XFire-Ends
                   //Added By Bhawani - CR-00024618
                   //Added/Modified by manu-BUG-00122848-Start
                   campaignName=XFIRE_Config_Settings__c.getInstance('Deal Reg Opportunity Source')!=null?XFIRE_Config_Settings__c.getInstance('Deal Reg Opportunity Source').Value__c:'Cross Sell Opportunity' ;
                   if(tempLead.recordtypeId==xSellUpSellRecordTypeId)
                   {
                       tmpDealReg.Campaign_Name__c = campaignName;    
                   }
                   else
                   {
                   tmpDealReg.Campaign_Name__c = 'VMware Generated Lead';
                   }
                   //Added/Modified by manu-BUG-00122848-Ends
                   
                   LeadToDealRegistration(tempLead.id);

                       for(Integer i = 0;i<Leadfields.size();i++){
                        
                        //if(tempLead.recordtypeId==xSellUpSellRecordTypeId && leadOppRegFieldsMap.get(Leadfields[i])!=null || tempLead.recordtypeId!=xSellUpSellRecordTypeId && leadOppRegFieldsMap.get(Leadfields[i])==null)
                          if(leadOppRegFieldsMap.get(Leadfields[i])!=null && tempLead.recordtypeId!=xSellUpSellRecordTypeId)
                          continue;
                        if(tempLead.get(Leadfields[i]) == false || tempLead.get(Leadfields[i]) == true ){
                            tmpDealReg.put(lead_And_Oppty_Fields.get((String)Leadfields[i]),(Boolean)tempLead.get(Leadfields[i]));
                        }
                        else{
                            if(lead_And_Oppty_Fields.get((String)Leadfields[i])!= null){
                                    //tmpDealReg.put(lead_And_Oppty_Fields.get((String)Leadfields[i]),(String)tempLead.get(Leadfields[i]));
                                    tmpDealReg.put(lead_And_Oppty_Fields.get((String)Leadfields[i]),tempLead.get(Leadfields[i]));
                            }
                        }
                     }  
                     
                      for(Integer j = 0;j<Leadfields1.size();j++){
                        
                        //if(tempLead.recordtypeId==xSellUpSellRecordTypeId && leadOppRegFieldsMap.get(Leadfields[j])!=null || tempLead.recordtypeId!=xSellUpSellRecordTypeId && leadOppRegFieldsMap.get(Leadfields[j])==null)
                        if(leadOppRegFieldsMap.get(Leadfields1[j])!=null && tempLead.recordtypeId!=xSellUpSellRecordTypeId)
                          continue;
                        if(tempLead.get(Leadfields1[j]) == false || tempLead.get(Leadfields1[j]) == true ){
                            tmpDealReg.put(lead_And_Oppty_Fields1.get((String)Leadfields1[j]),(Boolean)tempLead.get(Leadfields1[j]));
                        }
                        else{
                            if(lead_And_Oppty_Fields1.get((String)Leadfields1[j])!= null){
                                    //tmpDealReg.put(lead_And_Oppty_Fields1.get((String)Leadfields1[j]),(String)tempLead.get(Leadfields1[j]));
                                    tmpDealReg.put(lead_And_Oppty_Fields1.get((String)Leadfields1[j]),tempLead.get(Leadfields1[j]));
                            }
                        }
                     }                  

         }  
       dealReg = (Deal_Registration__c)controller.getRecord();
      subservicesList = new List<Orion_Subscription_Service_Detail__c>();
       Map<String,Orion_Subscription_Service_Detail__c> sIDMap = new Map<String,Orion_Subscription_Service_Detail__c>();
      
       if(dealReg.Id!=null){
           for(Orion_Subscription_Service_Detail__c sIdrec: [Select Id,Service_ID__c ,Current_Term_End_Date__c,Current_Term_Start_Date__c,Product_Name__c,Sid_Status__c,SDP_Discount__c,SKU__c from Orion_Subscription_Service_Detail__c where Registration__c=:dealReg.Id order by CreatedDate desc] ){
               if(sIDMap!=null && !sIDMap.containsKey(sIdrec.Service_ID__c)){
                   sIDMap.put(sIdrec.Service_ID__c,sIdrec);
               }
               if(sIDMap==null){
                    sIDMap.put(sIdrec.Service_ID__c,sIdrec);
               }
           }
          
       }
       if(sIDMap!=null && sIDMap.size()>0){
          subservicesList= sIDMap.values();
       }
       dealReg.Orion_AirwatchByPass__c=false;
      
       if(dealReg.Id==null){
                recApproved = true;
            }
           else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c==null && dealReg.Reject_Date__c==null){
                recApproved = true;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c!=null && dealReg.Reject_Date__c==null){
                recApproved = false;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c==null && dealReg.Reject_Date__c!=null){
                recApproved = true;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c!=null && dealReg.Reject_Date__c!=null && dealReg.Final_Approval_Date__c.date()>dealReg.Reject_Date__c){
                recApproved = true;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c!=null && dealReg.Reject_Date__c!=null && dealReg.Final_Approval_Date__c.date()<dealReg.Reject_Date__c){
                recApproved = false;
            }
       //Added the below code for defect --Orion phase 2 --Start
       if(dealReg.Customer_Market_Segment__c!=null){
           marketSegement = dealReg.Customer_Market_Segment__c;
       }
        //Added the below code for defect --Orion phase 2 --END
       //Added as a part of CR-00020258 
       if(ApexPages.currentPage().getParameters().get('edit') == 'true' || ApexPages.currentPage().getParameters().get('reRegister') == 'true'){
         isEdit=true;

        /* if(DealRegEPP_Constants.PARAM_VAL_EPP.equalsIgnoreCase(pType)){
            programType = DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP;
         }
         if(DealRegEPP_Constants.PARAM_VAL_GOV.equalsIgnoreCase(pType)){
            programType = DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS;
           // programType = DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT;
         }
         if(DealRegEPP_Constants.PARAM_VAL_ADPLUS.equalsIgnoreCase(pType)){*/
            programType = DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS;
       /*  }
         if(DealRegEPP_Constants.PARAM_VAL_ELA.equalsIgnoreCase(pType)){
            programType = DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA;
         }
         */
         stageOptions=ApexPages.currentPage().getParameters().get('stagename');
         marketSegement=ApexPages.currentPage().getParameters().get('marketsegment');       
            
       } 
       //End of change for CR-00020258
       disclaimer = System.Label.DealReg_EPP_Disclaimer;
       dealReg.Disclaimer__c=disclaimer;        

       //For full Reg Disclaimer    
        disclaimerforFullReg=System.Label.DealReg_EPP_Disclaimer_for_FullReg;
        dealReg.Disclaimer_del__c=disclaimerforFullReg;   

        dealReg.RecordTypeId = recursive.DealRegBasicInfoOnlyRecType;        
        eligibleProgramSet = partnerEligiblePrograms();
      
       if(progType != null && progType != 'na'){
            programTypeText();
       }
       // Added below by Manik CR-00121519  
      if(dealReg.Preferred_Distributor__c != null && dealReg.Preferred_Distributor__c != '--None--'){
           PerfDistiCustomBool=false;
           distributer= dealReg.Preferred_Distributor__c;
         }
         else
         { PerfDistiCustomBool=true;
           distributer=null;
           }
      // Change for CR-00121519 end
      //Added by Vijit for Pref Distributor Logic for Orion Phase2
      if(dealReg.Country__c != null && dealReg.Country__c != ''){

            getPrefDistItems();
        }
        if(RegId!=null){
        renderproductListAdd();
        }
        
       
       //Added this code to pass OranID when redirecting to estimator
       if(RegId!=null){
            List<Deal_Registration__c> regOranID = new List<Deal_Registration__c>();
            regOranID = [Select ORAN__c from Deal_Registration__c where ID =:RegId]; 
           
            OranId = regOranID[0].ORAN__c;
        }
        //Added the below code for BUG OR-778
        if(dealReg.StageName__c!=null){
            stageOptions=dealReg.StageName__c;
        }
                 existingApprovals = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =:RegId AND Status = 'Pending'];
            if(!existingApprovals.isEmpty() ){   recLocked=true;
            }
            else{  recLocked=false;
            }
      
            
        /* Prasad : 10-Apr-2016 - Discount Matrix Layout - Starts */
        // 1. Add code to check whether parameter Id exists on the page 
        // 2. Add code to redirect to the appropriate page based on created date of the deal reg record 
        // 3. Add check for deal reg status ( if apb only then run below code )
        // 4. Below should NOT run when EditMode = true - add the check for the same
        //discountMatrixHeaderId = 'aFw19000000000z';    // Currently Hardcoded - To Be Retrieved from Reg.Program
        
        thisDealId = ApexPages.currentPage().getParameters().get('id');
        
        if(thisDealId != null ){
            discountMatrixHeaderId = [Select Id, Incentive_Program__r.Orion_Discount_Matrix_Header__c from Deal_Registration__c where Id = :dealReg.Id ].Incentive_Program__r.Orion_Discount_Matrix_Header__c;
            setProductPlatforms = new Set<String>();
            mapUniqueProdPlatToDiscount = new Map<String,Decimal>();
            mapPlafGrpToPrdPlaf = new Map<String, List<String>>();
            setDealBands = new Set<String>();
            mapBandToPlafGrpDiscounts = new Map<String,Map<String,String>>();
            mapPlafGrpToDiscount = new Map<String,String>();
            mapPlafGrpToDiscountTemp = new Map<String,String>();
            
            lstDisMatDiscounts = [ Select Id,Discount_ExternalId__c ,Deal_Band_Start__c, Deal_Band_End__c, 
                                    Platform_Group__c, Product_Platform__c, Product2_Platform_Group__c, Discount__c 
                                    from Orion_Discount_Matrix_Discount__c 
                                    where Discount_Matrix_Product__r.Discount_Matrix_Band__r.Discount_Matrix_Header__c = :discountMatrixHeaderId 
                                    order by Deal_Band_Start__c, Deal_Band_End__c, Platform_Group__c,Product_Platform__c ];
    
            if(!lstDisMatDiscounts.isEmpty()){
                strProdPlfVariableDiscount = '';
                for(Orion_Discount_Matrix_Discount__c disc : lstDisMatDiscounts){                
                    //setDealBands.add('$' + disc.Deal_Band_Start__c + '-' + '$' + disc.Deal_Band_End__c);
                    setDealBands.add(disc.Deal_Band_Start__c + '-' + disc.Deal_Band_End__c);
                    //customUniqueKey = '$' + disc.Deal_Band_Start__c + '-' + '$' + disc.Deal_Band_End__c + ':' + disc.Product_Platform__c; 
                    customUniqueKey = disc.Deal_Band_Start__c + '-' + disc.Deal_Band_End__c + ':' + disc.Product_Platform__c; 
                    if(!mapUniqueProdPlatToDiscount.containsKey(customUniqueKey)){
                        mapUniqueProdPlatToDiscount.put(customUniqueKey, disc.Discount__c);
                    }
                    
                    
                    //if(disc.Platform_Group__c!= null && disc.Platform_Group__c!= '' && disc.Platform_Group__c.equalsIgnoreCase('platform group')){
                        setProductPlatforms.add(disc.Product2_Platform_Group__c);
                        //mapPlafGrpToDiscount.put(disc.Product_Platform__c,-1.0);                    
                        mapPlafGrpToDiscount.put(disc.Product2_Platform_Group__c,'NA');                    
                    //}
                    
                    if(!mapPlafGrpToPrdPlaf.containsKey(disc.Platform_Group__c)){
                        mapPlafGrpToPrdPlaf.put(disc.Platform_Group__c, new List<String>{disc.Product2_Platform_Group__c + '%'});
                    }else{
                        mapPlafGrpToPrdPlaf.get(disc.Platform_Group__c).add(disc.Product2_Platform_Group__c + '%');
                    }
                    if(disc.Platform_Group__c != null && disc.Platform_Group__c != '' && disc.Platform_Group__c.equalsIgnoreCase('Product Platform')){
                        //setProdPlfVariableDiscount.add(disc.Product2_Platform_Group__c);
                        strProdPlfVariableDiscount += ',' + disc.Product2_Platform_Group__c;
                    }                 
                }
                
                for(Orion_Discount_Matrix_Discount__c disc : lstDisMatDiscounts){
                    //if(disc.Platform_Group__c!= null && disc.Platform_Group__c!= '' && disc.Platform_Group__c.equalsIgnoreCase('platform group')){
                        if(!mapBandToPlafGrpDiscounts.containsKey( disc.Deal_Band_Start__c + '-' + disc.Deal_Band_End__c)){
                            mapPlafGrpToDiscountTemp = new Map<String,String>(mapPlafGrpToDiscount);
                            //mapPlafGrpToDiscountTemp = mapPlafGrpToDiscount;
                            mapPlafGrpToDiscountTemp.put(disc.Product2_Platform_Group__c,String.valueOf(disc.Discount__c));    // add the current record's plafgroup value and its discount
                            mapBandToPlafGrpDiscounts.put((disc.Deal_Band_Start__c + '-' + disc.Deal_Band_End__c),mapPlafGrpToDiscountTemp);
                        }else{                      
                            mapPlafGrpToDiscountTemp = mapBandToPlafGrpDiscounts.get(disc.Deal_Band_Start__c + '-' + disc.Deal_Band_End__c);
                            mapPlafGrpToDiscountTemp.put(disc.Product2_Platform_Group__c,String.valueOf(disc.Discount__c));
                            mapBandToPlafGrpDiscounts.put(( disc.Deal_Band_Start__c + '-' +  disc.Deal_Band_End__c),mapPlafGrpToDiscountTemp);
                        }
                    //}       

                }
                
                platformcount  = setProductPlatforms.size();
                
                lstProductPlatforms = new List<String>(setProductPlatforms);
                lstProductPlatforms.sort();
                lstDealBands = new List<String>(setDealBands);
            }

        }
        
        /* Prasad : 10-Apr-2016 - Discount Matrix Layout - Ends */ 

  /* Swasti : 18-Apr-2016 - Page field value will be populate when "Create Advanateg+" gets click on SIT page layout */
    
          Id SIRId=(System.currentPageReference().getParameters().get('sirid'));
          if(SIRId != null)
          {
                     Deal_Registration__c objSIRRg = [Select id,Name,Phone__c,Project_Name__c,Country__c,First_Name__c,CloseDate__c ,Last_Name__c,Email__c,Total_Project_Value__c,VMware_Sales_Contact_Name__c,Project_Focus__c,SIRTN__c,Are_You_the_Primary_Sales_Contact__c,Orion_Primary_Sales_Contact_Name__c,Orion_CIO_Sponsorship__c,Primary_Sales_Contact_Phone__c,Orion_Additional_Contact_Name__c,Next_Steps__c,Orion_Customer_Domain__c,Orion_Authority_to_Purchase__c,VMware_List_License_Value__c,Additional_Contact_Email__c,Primary_Sales_Contact_Email__c,Department__c,EA_Number__c,Does_the_Customer_have_a_SAN__c,Primary_Involvement_in_the_Deal__c,VMware_Sales_Engaged__c,Orion_Development_Fund_Utilized__c,City__c,Does_the_Customer_have_budget__c,Campaign_Name__c,What_is_your_customer_trying_to_solve_fo__c,StageName__c,Company__c,Orion_Close_Probability__c,of_Desktops__c,of_Servers__c,Address_1__c,Job_Role__c,Customer_Market_Segment__c,State_Province__c,Zip_Postal_Code__c from Deal_Registration__c where id =: ApexPages.currentPage().getParameters().get('SIRId') limit 1];
                    dealReg.Country__c                  =  objSIRRg.Country__c ;
                    dealReg.State_Province__c           = objSIRRg.State_Province__c;
                    dealReg.Zip_Postal_Code__c          = objSIRRg.Zip_Postal_Code__c;
                    dealReg.First_Name__c               = objSIRRg.First_Name__c;
                    dealReg.CloseDate__c                = objSIRRg.CloseDate__c ;
                    dealReg.Last_Name__c                = objSIRRg.Last_Name__c;
                    dealReg.Email__c                    = objSIRRg.Email__c;
                    dealReg.Total_Project_Value__c      = objSIRRg.Total_Project_Value__c;
                    dealReg.VMware_Sales_Contact_Name__c = objSIRRg.VMware_Sales_Contact_Name__c;
                    dealReg.Project_Focus__c            = objSIRRg.Project_Focus__c;
                    dealReg.Address_1__c                = objSIRRg.Address_1__c;
                    dealReg.Orion_Customer_Domain__c    =   objSIRRg.Orion_Customer_Domain__c;
                    dealReg.Orion_Authority_to_Purchase__c=objSIRRg.Orion_Authority_to_Purchase__c;
                    dealReg.Orion_CIO_Sponsorship__c=objSIRRg.Orion_CIO_Sponsorship__c;
                    dealReg.Next_Steps__c=objSIRRg.Next_Steps__c;

                    dealReg.Job_Role__c            = objSIRRg.Job_Role__c;
                    dealReg.Customer_Market_Segment__c                = objSIRRg.Customer_Market_Segment__c;
                    dealReg.Department__c   =   objSIRRg.Department__c;
                    dealReg.EA_Number__c                            =      objSIRRg.EA_Number__c;
                    dealReg.City__c                                 =      objSIRRg.City__c;
                    dealReg.Company__c                              =      objSIRRg.Company__c;
                    
                    
                    /*Below Information for partner information*/
                    
                    dealReg.Are_You_the_Primary_Sales_Contact__c    =       objSIRRg.Are_You_the_Primary_Sales_Contact__c;
                    dealReg.Orion_Primary_Sales_Contact_Name__c     =       objSIRRg.Orion_Primary_Sales_Contact_Name__c;
                    dealReg.Primary_Sales_Contact_Phone__c          =       objSIRRg.Primary_Sales_Contact_Phone__c;
                    dealReg.Orion_Additional_Contact_Name__c        =       objSIRRg.Orion_Additional_Contact_Name__c;
                    dealReg.Primary_Sales_Contact_Email__c          =       objSIRRg.Primary_Sales_Contact_Email__c;
                    dealReg.Additional_Contact_Email__c             =       objSIRRg.Additional_Contact_Email__c;
                    
                    dealReg.Source_SIRTN__c                         =       objSIRRg.SIRTN__c;
                    dealReg.Source_SIR_DealReg__c                   =       true;
                    
                    dealReg.Phone__c =       objSIRRg.Phone__c;
                    dealReg.EA_Number__c =       objSIRRg.EA_Number__c;
                    dealReg.Project_Name__c =       objSIRRg.Project_Name__c;
                    dealReg.VMware_List_License_Value__c =       objSIRRg.VMware_List_License_Value__c;
                    dealReg.Orion_Development_Fund_Utilized__c =       objSIRRg.Orion_Development_Fund_Utilized__c;
                    dealReg.VMware_Sales_Engaged__c =       objSIRRg.VMware_Sales_Engaged__c;
                    dealReg.Primary_Involvement_in_the_Deal__c =       objSIRRg.Primary_Involvement_in_the_Deal__c;
                    dealReg.of_Servers__c =       objSIRRg.of_Servers__c;
                    dealReg.of_Desktops__c   =       objSIRRg.of_Desktops__c;
                    dealReg.Campaign_Name__c     =       objSIRRg.Campaign_Name__c;
                    dealReg.What_is_your_customer_trying_to_solve_fo__c = objSIRRg.What_is_your_customer_trying_to_solve_fo__c;
                    dealReg.Does_the_Customer_have_budget__c = objSIRRg.Does_the_Customer_have_budget__c;
                    dealReg.Does_the_Customer_have_a_SAN__c = objSIRRg.Does_the_Customer_have_a_SAN__c;
                    
              
          }
          //Added for CR-00140701 - START
    String showPartnerErrorMsg = (Orion_Phase_II_Configurations__c.getInstance('Show Professional Partner Error Msg')!=null && Orion_Phase_II_Configurations__c.getInstance('Show Professional Partner Error Msg').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('Show Professional Partner Error Msg').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('Show Professional Partner Error Msg').value__c:'YES';
     if(showPartnerErrorMsg == 'YES'){
        professionalPartnerCheck = DealRegEPP_Utilities.checkProfessionalPartner(UserInfo.getUserId());
        } 
         //Added for CR-00140701 - END
    }
    
    //Added by Ibrahim 
    //modified for stage picklist values and corresponding close probablity values 
    Map<String,Integer> stageOptionsMap = new Map<String,Integer>{'02 - Qualified' => 25, '03 - Validate' => 35, '04 - Design' => 45, '05 - Prove' => 60, '06 - Negotiate' => 80, '07 - Agreement to Purchase' => 90, '09 - Closed Lost' => 0, '08 - Closed Won' => 100 };  
    public void onStageNameChange(){
        
                /*if(dealReg.Orion_Close_Probability__c!=null ){
                        
                }
                else{*/
        dealReg.Orion_Close_Probability__c = stageOptionsMap.get(stageOptions);
                //}
                
        
        /*if(stageOptions=='Qualified'){        
            dealReg.Orion_Close_Probability__c = 25;
        }if(stageOptions=='Prospect'){
            dealReg.Orion_Close_Probability__c = 35;
        }if(stageOptions=='Suspect'){
            dealReg.Orion_Close_Probability__c =45;
        }if(stageOptions=='Qualified'){
            dealReg.Orion_Close_Probability__c =60;
        }if(stageOptions=='Technical Validation'){
            dealReg.Orion_Close_Probability__c =80;
        }if(stageOptions=='Business Validation/Pre-Agreement'){
            dealReg.Orion_Close_Probability__c =90;
        }if(stageOptions=='Agreement to Purchase'){
            dealReg.Orion_Close_Probability__c =100;
        }*/
       
     }
    //Ended changes by ibrahim
    
    public boolean getLeadToDealConvert(){

        Id LeadId=(System.currentPageReference().getParameters().get('leadid'));
        if(LeadId!=null)
            return true;
        else
            return false;   
    }
    
    public boolean getProgTypeText(){
        
        return progTypeText;
    }
    
    public boolean getPrefChannelRen(){
        
        if(!((DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT.equalsIgnoreCase(programType))||(DealRegEPP_Constants.PARAM_VAL_GOV.equalsIgnoreCase(progType)))){
            prefChannelRen = false;
        }
        return prefChannelRen;
    }
    
    public boolean getElaSectionRen(){
        if ((DealRegEPP_Constants.PARAM_VAL_ELA.equalsIgnoreCase(progType))||(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA.equalsIgnoreCase(programType))){
            elaSectionRen = true;
            
        }
        else{
            elaSectionRen = false;
        }
        return elaSectionRen;
    }
    
    public boolean getEppSectionRen(){
        if ((DealRegEPP_Constants.PARAM_VAL_EPP.equalsIgnoreCase(progType))||(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType))){
           eppSectionRen = true;
        }
        else{
           eppSectionRen = false;
        }
        return eppSectionRen;
    }
    
    public string getProgramType(){
       return programType;
    }
    
    public void setProgramType(string programType){
       
       this.programType = programType;
    }
    
    public string getMarketSegement(){
       return marketSegement;
    }
    
    public void setMarketSegement(string marketSegement){
       
       this.marketSegement = marketSegement;
    }
    
    public string getStageOptions(){
       return stageOptions;
    }
    
    public void setStageOptions(string stageOptions){
       
       this.stageOptions = stageOptions;
    }
    
    public List<SelectOption> getstageList() {
    if(DealReg.StageName__c!=null){
    stageOptions=DealReg.StageName__c;
    }
    
        List<SelectOption> options = new List<SelectOption>();
         /*Below Variable will populate when a DealReg get created from Approved SIR*/
    Id SIRId=(System.currentPageReference().getParameters().get('sirid'));
        if((DealReg.id == null  && SIRId == null) || DealReg.Registration_Status__c == 'Draft' || DealReg.Registration_Status__c == 'Entered'){
        options.add(new SelectOption('01-Prospect',System.Label.L10N_DealReg_Prospect));
    }else{
        //Modified for Orion Phase 2 by Ibrahim.
        /*options.add(new SelectOption('--None--','--'+System.Label.PC_None_option+'--'));
        options.add(new SelectOption('Prospect',System.Label.L10N_DealReg_Prospect));
        options.add(new SelectOption('Suspect',System.Label.L10N_DealReg_Suspect));
        options.add(new SelectOption('Qualified',System.Label.L10N_DealReg_Qualified));
        options.add(new SelectOption('Technical Validation',System.Label.L10N_DealReg_TechValid));
        options.add(new SelectOption('Business Validation/Pre-Agreement',System.Label.L10N_DealReg_BusinessOrPre));
        options.add(new SelectOption('Agreement to Purchase',System.Label.L10N_DealReg_Agreement));*/
        
        
        options.add(new SelectOption('--None--','--'+System.Label.PC_None_option+'--'));
    options.add(new SelectOption('01-Prospect',System.Label.L10N_DealReg_Prospect));
        options.add(new SelectOption('02 - Qualified',System.Label.L10N_DealReg_02Qualified));
        options.add(new SelectOption('03 - Validate',System.Label.L10N_DealReg_Validate));
        options.add(new SelectOption('04 - Design',System.Label.L10N_DealReg_Design));
        options.add(new SelectOption('05 - Prove',System.Label.L10N_DealReg_Prove));
        options.add(new SelectOption('06 - Negotiate',System.Label.L10N_DealReg_Negotiate));
        options.add(new SelectOption('07 - Agreement to Purchase',System.Label.L10N_DealReg_Agreement_to_Purchase));
        options.add(new SelectOption('09 - Closed Lost',System.Label.L10N_DealReg_Closed_Lost));
        //options.add(new SelectOption('08 - Closed Won',System.Label.L10N_DealReg_ClosedWon));
        //Ended modifications for Orion phase 2
        }
        return options;
    }
    
    public List<SelectOption> getprogramList() {

        getcustMarketSegementList();
        getprimInvolvmntList();
        List<SelectOption> options = new List<SelectOption>();
        //Added as a part of CR-00020258    
        if(DealRegEPP_Constants.PARAM_VAL_EPP.equalsIgnoreCase(progType) && isEdit==false) {
            
            options.add(new SelectOption((DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP),(System.Label.L10N_DealReg_EPP_Post_Sale_Burn_Down)));
        }
        else if(DealRegEPP_Constants.PARAM_VAL_ADPLUS.equalsIgnoreCase(progType) && isEdit==false){            
            
            options.add(new SelectOption((DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS),(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS)));
        }
        else if(DealRegEPP_Constants.PARAM_VAL_GOV.equalsIgnoreCase(progType) && isEdit==false){
            
            options.add(new SelectOption((DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT),(System.Label.L10N_DealReg_Government)));
        }
        else if(DealRegEPP_Constants.PARAM_VAL_ELA.equalsIgnoreCase(progType) && isEdit==false) {
            
            options.add(new SelectOption((DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA),(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA)));
         //End of change for CR-00020258    
        }else {          
            options.add(new SelectOption('--None--','--'+System.Label.PC_None_option+'--'));
            
            // ****************** Code Added for CR-00020284 Starts ******************
            
            List<String> listEligibleProgram = new List<String>();
            List<String> listSortedEligibleProgram = new List<String>();
            
            for(String eligbleProgram : eligibleProgramSet) {
                listEligibleProgram.add(eligbleProgram);
            }
        
            for(integer i=0;i<listEligibleProgram.size();i++) {
                listEligibleProgram[i]=listEligibleProgram[i].substring(0,1).toUpperCase()+listEligibleProgram[i].substring(1,listEligibleProgram[i].length());
            }
            listEligibleProgram.sort();
                       
            for(String sortedList : listEligibleProgram ) {
                for(String setVar : eligibleProgramSet ) {
                    if(sortedList.equalsIgnoreCase(setVar)) {
                        listSortedEligibleProgram.add(setVar);  
                    }   
                }   
            }
            
            // ****************** Code End for CR-00020284 ******************
            
            // Code commented as a part of CR - 00020284 
            //for(String finalProg : eligibleProgramSet){
            for(String finalProg : listSortedEligibleProgram){
            
                //if (finalProg != 'Opportunity Identification') {
                
                    if(userPreferredLanguage != 'en' && userLangRegProgConfig.get(finalProg) != null){
                            options.add(new SelectOption(finalProg, userLangRegProgConfig.get(finalProg)));                             
                    }else{                 
                        options.add(new SelectOption(finalProg, finalProg));
                    }
                //}
            }
        }
        return options;
    }
    
            
    public List<SelectOption> getprimInvolvmntList() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--'+System.Label.PC_None_option+'--'));
        Schema.DescribeFieldResult primInvolvmnt = Deal_Registration__c.Primary_Involvement_in_the_Deal__c.getDescribe();
        
        if ((progType != null && DealRegEPP_Constants.PARAM_VAL_EPP.equalsIgnoreCase(progType))||(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType))) {
                
                for(Schema.Picklistentry picklistEntry : primInvolvmnt.getPicklistValues()) {
                if(picklistEntry.getValue() != (DealRegEPP_Constants.Deal_PickList.PRIM_INVOLV_IN_DEAL_RESELLER)){
                    
                    options.add(new Selectoption(pickListEntry.getValue(),pickListEntry.getLabel()));
                }                
            }
        }
        else {
        
            for(Schema.Picklistentry picklistEntry : primInvolvmnt.getPicklistValues()) {
                                    
                options.add(new Selectoption(pickListEntry.getValue(),pickListEntry.getLabel()));            
            }
        }    
        return options;
    }
    
    public List<SelectOption> getcustMarketSegementList() {
        
        List<SelectOption> options = new List<SelectOption>();
     //Added the below code for defect --Orion phase 2 --Start
        if(dealReg.Customer_Market_Segment__c!=null){
            marketSegement = dealReg.Customer_Market_Segment__c;
        }
     //Added the below code for defect --Orion phase 2 --End
        if(!(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT.equalsIgnoreCase(programType) || 
            DealRegEPP_Constants.PARAM_VAL_GOV.equalsIgnoreCase(progType))){
            options.add(new SelectOption('--None--','-'+System.Label.PC_None_option+'-'));
        }
        
        Schema.DescribeFieldResult marketSeg = Deal_Registration__c.Customer_Market_Segment__c.getDescribe();
       
        if((DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS.equalsIgnoreCase(programType))||(DealRegEPP_Constants.PARAM_VAL_ADPLUS.equalsIgnoreCase(progType))||(DealRegEPP_Constants.PARAM_VAL_EPP.equalsIgnoreCase(progType))||(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType))){
            
            for(Schema.Picklistentry picklistEntry : marketSeg.getPicklistValues()) {
                
                //if(picklistEntry.getValue() != (DealRegEPP_Constants.Deal_PickList.CUST_MKT_SEG_USFED)){                    
                    options.add(new Selectoption(pickListEntry.getValue(),pickListEntry.getLabel()));
                //}                
            }
            
        }else if((DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT.equalsIgnoreCase(programType))||(DealRegEPP_Constants.PARAM_VAL_GOV.equalsIgnoreCase(progType))){
         
           for(Schema.Picklistentry picklistEntry : marketSeg.getPicklistValues()) {
                if(picklistEntry.getValue() == (DealRegEPP_Constants.Deal_PickList.CUST_MKT_SEG_USFED)){                    
                    options.add(new Selectoption(pickListEntry.getValue(),pickListEntry.getLabel()));
                }                
            }
        }       
        else {            
            for(Schema.Picklistentry picklistEntry : marketSeg.getPicklistValues()) {                    
                    options.add(new Selectoption(pickListEntry.getValue(),pickListEntry.getLabel()));            
            }
        }
        
        return options;
    }
    
    public Set<String> partnerEligiblePrograms(){
       
       Set<Id> groupIdSet = new Set<Id>();
        
        List<GroupMember> gpMemberList = [Select Id, GroupId from GroupMember where UserOrGroupId =: UserInfo.getUserId()];
        
        for(GroupMember gpm : gpMemberList){
            
            groupIdSet.add(gpm.GroupId);
        }
        
        Map<Id, Landing_Page_Widget__c> lpWidgetmap = new Map<Id, Landing_Page_Widget__c>([Select l.Widget_Title__c, l.Type__c, l.Name__c, l.Name, l.Id 
                                                          From Landing_Page_Widget__c l where l.Widget_Title__c IN: regProgramConfigEnglishMap.keySet()]);

        
        List<String> sharedWidgetList = new List<String>();
        
        List<Landing_Page_Widget__Share> lpwShareList = [Select l.UserOrGroupId, l.RowCause, l.ParentId, l.Id From Landing_Page_Widget__Share l where 
                                                          l.ParentId IN: lpWidgetmap.keySet() AND l.UserOrGroupId IN: groupIdSet];
        
        for(Landing_Page_Widget__Share lpws : lpwShareList ){
            
            if(lpWidgetmap.containsKey(lpws.ParentId)){
                
                sharedWidgetList.add(lpWidgetmap.get(lpws.ParentId).Widget_Title__c);
                
            }
        }
        
        Set<String> partnerProgramsSet = new Set<String>();
        
        for(String wgtName : sharedWidgetList){
            
            RegistrationProgramConfig__c regProg = regProgramConfigEnglishMap.get(wgtName);
            if(regProg != null){
                partnerProgramsSet.add(regProg.ProgramType__c);              
            }
        }
         //Added as a part of CR-00020258
        if ((progType != null && progType != 'na')&& isEdit==false) {
        //End of change for CR-00020258             
            progTypeText = true ;   
       }
       else {        
            progTypeText = false ;
       }  
        
        return partnerProgramsSet;
    }
    
    public Boolean programTypeText(){

            if(DealRegEPP_Constants.PARAM_VAL_EPP.equalsIgnoreCase(progType)){
                
                programType = (DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP);               
            }
            else if(DealRegEPP_Constants.PARAM_VAL_ADPLUS.equalsIgnoreCase(progType)) {
                
                    programType = (DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS);               
            }
            else if(DealRegEPP_Constants.PARAM_VAL_GOV.equalsIgnoreCase(progType)) {
                
                programType = (DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT);
                prefChannelRen = true;
            }
            else if(DealRegEPP_Constants.PARAM_VAL_ELA.equalsIgnoreCase(progType)){
               
                programType = (DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA);                
            }            
            return true;
    }
    
    public PageReference registerBasic(){
        if(dealReg.Id != null){
          String booleanWindow  = DealRegEPP_Utilities.validateEditAccess(UserInfo.getUserId(),dealReg.Id);
                   if(booleanWindow  != 'yes'){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Orion_Access_to_Deal)); 
                    return null;
         
       }
       } 
     //Added the below code for defect --Orion phase 2 --Start
        if(dealReg.Customer_Market_Segment__c!=null){
       marketSegement = dealReg.Customer_Market_Segment__c ;
        }
     //Added the below code for defect --Orion phase 2 --END
         
        // REQ-REG-059 - 21st April 2016 by Vijit Vijay - Calling the method- START
	//Commented as part of CR-00140564 on 26/Aug/2016 - Vijit - START
       /* if(checkEmailDomain()){
             return null;
         }*/// REQ-REG-059 - 21st April 2016 by Vijit Vijay - Calling the method- END
         //Commented as part of CR-00140564 on 26/Aug/2016 - Vijit - START
        //Added by Vijit below - Calling a method.
        if(prefDistributorCountryCheck()){
            return null; 
        }
         
         if(dealReg.CloseDate__c < System.today()){
          ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_EXP_CLOSE_DATE));
            return null;
        }
        
        if((dealReg.Are_You_the_Primary_Sales_Contact__c != null && dealReg.Are_You_the_Primary_Sales_Contact__c != '' && dealReg.Are_You_the_Primary_Sales_Contact__c == 'No') && dealReg.Orion_Primary_Sales_Contact_Name__c !=null){
            dealReg.Primary_Sales_Contact_Name__c=PrimaryContactName(dealReg.Orion_Primary_Sales_Contact_Name__c);
        }
            
        if((dealReg.Are_You_the_Primary_Sales_Contact__c != null && dealReg.Are_You_the_Primary_Sales_Contact__c != '' && dealReg.Are_You_the_Primary_Sales_Contact__c == 'No') && (dealReg.Primary_Sales_Contact_Email__c == null || dealReg.Orion_Primary_Sales_Contact_Name__c == null || dealReg.Primary_Sales_Contact_Phone__c == null)){
             ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_PRIMARY_SALES_VALIDATION));
            return null;
        }
    if(dealReg.Orion_Development_Fund_Utilized__c != null && dealReg.Orion_Development_Fund_Utilized__c != '--None--' && (dealReg.Campaign_Name__c ==null || dealReg.Campaign_Name__c == '' || dealReg.Campaign_Name__c=='--None--')){
          ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Opportunity_Source_not_blank));
            return null;
        }
        //Added by Manu-CR-00138671-Start   
        If(dealReg.VMware_List_License_Value__c<10000 && !isAirwatchOnly()){
            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_The_list_license_less));
            return null;
        }
        //Added by Manu-CR-00138671-Ends
         
        if(!checkDealForm(dealReg)){
            return null;
        }
        
        
        PageReference pageRefer = new PageReference('/apex/Orion_DealReg_FullRegPage?programType=na'); 
        return pageRefer;
    }   
    public PageReference saveDraftPage1(){
        //Added Contact Validattion by Ibrahim
        if(ValidateContact()){
            return null;
        }
        
        //Added below by Vijit
        if(primarySalesEmailCheck()){
            return null;
        }
        
        // REQ-REG-059 - 21st April 2016 by Vijit Vijay - Calling the method- START
	//Commented as part of CR-00140564 on 26/Aug/2016 - Vijit - START
        /*if(checkEmailDomain()){
             return null;
        }*/// REQ-REG-059 - 21st April 2016 by Vijit Vijay - Calling the method- END
	//Commented as part of CR-00140564 on 26/Aug/2016 - Vijit - END
    /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. START */
    if(dealReg.Preferred_Distributor__c != null && dealReg.Preferred_Distributor__c != ''){
        
        list<Account> accList= new list<Account>();
        accList = [select id, Name, Partner_ID__c  from Account where Name = :dealReg.Preferred_Distributor__c and RecordType.id = :partnerAccRecordTypeID and Account_Status_Formula__c = 'Active'];
        
        if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Preferred_Distributor__c != null && loggedinUser.Contact.Account.Preferred_Distributor__c != '' && loggedinUser.Contact.Account.Preferred_Distributor__c == dealReg.Preferred_Distributor__c && accList.isEmpty()){
                dealReg.Orion_Preferred_Disti_ID__c = loggedinUser.Contact.Account.Partner_ID__c;
        }
        
        if(!accList.isEmpty()){
            for(Account acc : accList){
                dealReg.Orion_Preferred_Disti_ID__c = acc.Partner_ID__c;
               
            }           
        }        
    }
    /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. END */ 
        //Added by Vijit below - Calling a method.
        if(prefDistributorCountryCheck()){
            return null; 
        }       
         if((dealReg.Are_You_the_Primary_Sales_Contact__c != null && dealReg.Are_You_the_Primary_Sales_Contact__c != '' && dealReg.Are_You_the_Primary_Sales_Contact__c == 'No') && dealReg.Orion_Primary_Sales_Contact_Name__c !=null){
            dealReg.Primary_Sales_Contact_Name__c=PrimaryContactName(dealReg.Orion_Primary_Sales_Contact_Name__c);
        }
if(dealReg.Orion_Development_Fund_Utilized__c != null && dealReg.Orion_Development_Fund_Utilized__c != '--None--' && (dealReg.Campaign_Name__c ==null || dealReg.Campaign_Name__c == '' || dealReg.Campaign_Name__c=='--None--')){
          ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Opportunity_Source_not_blank));
            return null;
        }
         // Added below by Manik CR-00121519 
   
    if((prefChannelRen==true || programType == 'Government') || (marketSegement=='US Federal' && (programType=='advantage+' || programType=='ELA'))){
    if(!String.isBlank(distributer) && distributer!=null && distributer!='' && distributer!='--None--')
                dealReg.Preferred_Distributor__c = distributer;
                else
                dealReg.Preferred_Distributor__c='';
     }   
      dealReg.Form_Navigation__c = 1;
      /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Starts */
          dealReg.Is_Orion_DealReg__c = true;   
      /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Ends*/
      //Added by Manu for BUG-00146507-Starts
       dealReg.Orion_Need_To_Update_Management_Form__c=1;
      //Added by Manu for BUG-00146507-Ends
     // Change for CR-00121519 end
        //Added null check to throw error
        programType='advantage+';
       /* if(programType.equals('--None--')){
            
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_PROG_TYPE_BLANK));
            return null;   )         
        }*/
        
        if((programType.equals('advantage+') || programType.equals('ELA')) && dealReg.Zip_Postal_Code__c == null)
        {
        
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_POSTAL_CODE_BLANK));
            return null;
        } //Change End  
        //Added null check to throw error
        else if(stageOptions.equals('--None--')){
            
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_STAGE_BLANK));
            return null;            
        }
        // Added below by Manik CR-00121519 
        else if((!dealReg.Country__c.equalsIgnoreCase('United States')) && marketSegement.equalsIgnoreCase('US Federal'))
        {
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_WRONG_MARKET_SEGMENT));
            return null; 
        }
        //CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
     else if(dealreg.Preferred_Channel__c=='VMware Distributor' && (dealReg.Preferred_Distributor__c=='--None--' || dealReg.Preferred_Distributor__c==null  || dealReg.Preferred_Distributor__c==''))
        {
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_BLANK_PREF_DISTRIBUTOR));
            return null; 
        }  
        //Added by Manu-CR-00138671-Start   
        else If(dealReg.VMware_List_License_Value__c<10000 && !isAirwatchOnly()){
            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_The_list_license_less));
            return null;
        }
        //Added by Manu-CR-00138671-Ends
    // Change CR-00121519 end               
        else {      
            dealReg.Program_Type__c = programType;
            dealReg.StageName__c = stageOptions;        
            
            showMsg = validateListLicenseValue(programType);
            
          /*  if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType)){
                
                String eppOrderNumber = dealReg.Initial_EPP_Order_Number__c;
                List<String> orderList = new List<String>();
    
                for(Order__c ord: [Select Order_Number__c from Order__c where Order_Number__c=: eppOrderNumber limit 1]){
    
                    orderList.add(ord.Order_Number__c);
                }    
                if(orderList.size()==0){
                     ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_INITIAL_EPP_VALID));
                     return null;
                }
            }*/
            //Modified condition for BUG-00040231. By - Jaypal Singh. Dated: 09/03/2012
            if(marketSegement.equals('--None--')){              
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_MKT_SEG_BLANK));
                return null;            
            }
            if(productListAdd==null || productListAdd.size()<=0 || productListAdd.isEmpty()){
                ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Products_Required));
                return null;  
           }
            //code start for CR-00113657 by sandip
        // if condition added by sandip  for CR-00122078 
 /* if(programType != 'EPP Post-Sale Burn-Down'){
             if(dealReg.Preferred_Channel__c == null){
                
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PRECH));
                return null;            
            }else if(dealReg.Preferred_Channel__c.equals('--None--')){
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PRECH));
                return null;  
            }
      //CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
      else if(dealReg.Preferred_Channel__c.equals('VMware Distributor')){
                if(dealReg.Preferred_Distributor__c == null){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PREDIST));
                    return null; 
                }
            }
   }      */  
            //code end for CR-00113657 by sandip
            dealReg.Customer_Market_Segment__c = marketSegement;
                        
            if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS.equalsIgnoreCase(programType)){
                
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ADPLUS));
                    return null;
                }
               // dealReg.RecordTypeId = recursive.DealRegAdvantageRecType;
                dealReg.RecordTypeId = recursive.DealRegOrionAdvantageRecType ;
            }
          /*  else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA.equalsIgnoreCase(programType)){
                
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ELA));
                    return null;
                }
                dealReg.RecordTypeId = recursive.DealRegELARecType;
            }
            else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT.equalsIgnoreCase(programType)){
            
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_GOV));
                    return null;
                }
                dealReg.RecordTypeId = recursive.DealRegGovernmentUSOnlyRecType;
                dealReg.Preferred_Distributor__c = distributer;
            }
            else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType)){
            
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ELA));
                    return null;
                }
                dealReg.RecordTypeId = recursive.DealRegEPPRecType;
            }  */
            
            //Changes made for CR-00020258 : Dated 10/27/2012 Jaypal Singh
            dealReg.Registration_status__c='Draft';
            if(ApexPages.currentPage().getParameters().get('reRegister') == 'true'){
                newDealReg = dealReg.clone(false,true);
                
                newDealReg = nullifyNewDealRegFields(newDealReg);

                newDealReg = nullifyFieldsProgramChange(newDealReg);
                
                newDealReg.Previous_Registration__c = dealReg.id;
                
                newDealReg.Registration_Status__c = 'Draft';

                try{
                    Deal_Registration__c oldDeal = [Select Id, Registration_Status__c, Reregistered_Date__c, Registrations__c from Deal_Registration__c where Id =: dealReg.Id];
                    newDealReg.Registrations__c = oldDeal.Registrations__c;
                    insert newDealReg;

                    oldDeal = updateOldDealRegFields(oldDeal);
                    update oldDeal;
                }               
                catch(Exception ex){
                    
                    //Displaying Error Message on page
                    ApexPages.addMessages(ex);           
                    return null;             
                }
                PageReference dealPage = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+newDealReg.id);
                //PageReference dealPage = new ApexPages.StandardController(newDealReg).view();
                dealPage.setRedirect(true);
                return dealPage;
            }
            //Changes End for CR-00020258 
             Id finaldealId;
                try{
                    if(isEdit==true){
                        
                        dealReg = nullifyFieldsProgramChange(dealReg);                      
                    }
                    List<Deal_Registration__c> dealList = new List<Deal_Registration__c>();
                    dealList.add(dealReg);
          
          Set<String> uniqueProductName = new Set<String>();
      //Modified by Vijit for Duplicate Product Highlight Defect Fix - Start
          Boolean containsDuplicate = false;
          countAirwatchProduct = 0;
                   for(prodwrapper wrap:productListAdd){
                       if(uniqueProductName.add(wrap.name)==false)
                       {    
                            wrap.isDuplicate = true;
                            containsDuplicate = true;                                                 
                       }
                   // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- START
                       for(Orion_Airwatch_Product__c obj: Orion_Airwatch_Product__c.getAll().values()){
                           if(obj.ProductName__c.equalsIgnoreCase(wrap.name)){
                               countAirwatchProduct = countAirwatchProduct + 1;
                           }                           
                        }
                    }
                    if(countAirwatchProduct == productListAdd.size()){                  
                        dealReg.Orion_AirwatchByPass__c = true; 
                        if(dealReg.Incentive_Program__c != null && dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){
                            extendedExpirationDaysRegProgram = Integer.ValueOf(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c);
                        } 
                        if(dealReg.Orion_Deal_Registration_Expiration_Date__c == null){
                            if(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){           
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDaysRegProgram;  
                            }else{
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDays; 
                            } 
                        }
                        if(dealReg.Orion_Eligible_for_Benefits_Date__c == null){
                            dealReg.Orion_Eligible_for_Benefits_Date__c = System.Now();
                        } 
                        
                    }
                    // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- END
                   if(containsDuplicate){
                       ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Duplicate_Products_Found));
                       return null;
                   } //Modified by Vijit for Duplicate Product Highlight Defect Fix - END
                   //Added for Product Name to be shown on Deal by Archana- Start
                   String temp ='';
                   for(prodwrapper wrap:productListAdd){
                      temp = temp+wrap.name+',';
                  }
                    temp= temp.substring(0,temp.length()-1);
                    if(temp!=null &&   temp!=''){
                        dealReg.All_Vmware_Products__c=temp;
                    }
                     //Added for Product Name to be shown on Deal by Archana- Start
                    
                    upsert dealReg;
                   Map<Id, Deal_Registration__c> DealMap = new Map<Id, Deal_Registration__c>(dealList);
                   upsert dealList; 
                   //List<Database.upsertResult> uResults = Database.upsert(dealList,false);
                     List<Partner_Select_Product__c> pSPList = new List<Partner_Select_Product__c>();
                  
                  finaldealId=dealList[0].Id;
                   // List<Partner_Select_Product__c> pSPList = new List<Partner_Select_Product__c>();
                   
                  if(finaldealId!=null){
                  for(prodwrapper wrap:productListAdd){
                      if(wrap.productId==null){
                      pSPList.add(new Partner_Select_Product__c(Name = wrap.name,ORTN_Number__c =DealMap.get(finaldealId).Name,Quantity__c=Integer.valueOf(wrap.Quantity), Product__c = ProdNewMap.get(wrap.name).Id, Division__c=ProdNewMap.get(wrap.name).Division__c, Platform_Group__c=ProdNewMap.get(wrap.name).Platform_Group__c, Product_Group__c=ProdNewMap.get(wrap.name).Product_Group__c,Product_Name__c= ProdNewMap.get(wrap.name).Registration_Product_Name__c, Product_Platform__c=ProdNewMap.get(wrap.name).Product_Platform__c, Registration__c=finaldealId,Willing_to_Lead_Services_Flag__c = wrap.willingLeadServices));
                  }
                   else{
                       if(wrap.Quantity!=null){
                      Partner_Select_Product__c psprecord = new Partner_Select_Product__c(Id=wrap.productId,Quantity__c=Integer.valueOf(wrap.Quantity),Willing_to_Lead_Services_Flag__c=wrap.willingLeadServices);
                      pSPList.add(psprecord);
                       }
                       
                       
                      
                      
                      
                  }
                  }
                  if(productListAdd!=null && productListAdd.size()>0){
                  insert pSPList;
                  }
                }
                }               
                catch(Exception ex){
                    
                    //Displaying Error Message on page
                    ApexPages.addMessages(ex);           
                    return null;             
                }
               retreiveDealRecords(finaldealId);
               
               
               // PageReference dealPage = new ApexPages.StandardController(dealReg).view();
                PageReference pageRefer = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+finaldealId);
                                pageRefer.setredirect(true);
        return pageRefer;
              //  PageReference dealPage =new PageReference('/apex/Orion_DealReg_FullRegPage');
              //  dealPage.setRedirect(true);
              //  return dealPage;

        } 
        
    }
    public void retreiveDealRecords(Id finaldealId){
         productListAdd.clear();
           Deal_Registration__c deal = [Select Id,Registration_Status__c,Final_Approval_Date__c,ORAN_External_ID__c,( Select Name,Quantity__c,Eligible_for_Benifits__c,Approved__c,Eligible_to_Lead_Services__c,Id,Rejected__c,Willing_to_Lead_Services_Flag__c, Discount__c from PartnerSelects__r),Project_Name__c from Deal_Registration__c where Id=: finaldealId];
           Integer Index1 ;
           List<Partner_Select_Product__c> pspFinalList = new List<Partner_Select_Product__c> ([Select Id,Registration__c,Approved__c,Registration__r.Final_Approval_Date__c,Registration__r.Registration_Status__c,Rejected__c,Discount__c,Willing_to_Lead_Services_Flag__c from Partner_Select_Product__c where Registration__c=:finaldealId]);
         
           Boolean RecnotApproved;
           
             if(dealReg.Id==null){
                recApproved = true;
            }
           else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c==null && dealReg.Reject_Date__c==null){
                recApproved = true;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c!=null && dealReg.Reject_Date__c==null){
                recApproved = false;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c==null && dealReg.Reject_Date__c!=null){
                recApproved = true;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c!=null && dealReg.Reject_Date__c!=null && dealReg.Final_Approval_Date__c.date()>dealReg.Reject_Date__c){
                recApproved = true;
            }
            else if(dealReg.Id!=null && dealReg.Final_Approval_Date__c!=null && dealReg.Reject_Date__c!=null && dealReg.Final_Approval_Date__c.date()<dealReg.Reject_Date__c){
                recApproved = false;
            }
            
            
            for(Partner_Select_Product__c pspFinalrec: pspFinalList ){
               if(pspFinalrec.Approved__c==false && pspFinalrec.Rejected__c==false){
                   RecnotApproved = true;
                   break;
               }
               else{
                   RecnotApproved = true;
               }
            }
            if(dealReg.Id == null){
                readyforAppcheck = true;
            }
            else if(dealReg.Registration_Status__c == 'Draft' ||dealReg.Registration_Status__c == 'Returned'  ){
                readyforAppcheck = true;
            }
            else if(dealReg.Registration_Status__c=='Pending Administrative Review'){
                readyforAppcheck = false;
            }
            else if(RecnotApproved==true && (dealReg.Final_Approval_Date__c!=null || dealReg.Reject_Date__c!=null )){
                readyforAppcheck = true;
            }
            else if(RecnotApproved==false && (dealReg.Final_Approval_Date__c!=null || dealReg.Reject_Date__c!=null )){
                readyforAppcheck = false;
            }
            
            
    Index1 =-1;
    dealStatus = deal.Registration_Status__c;
    
    if(deal!=null && deal.PartnerSelects__r!=null && deal.PartnerSelects__r.size()>0){
        for(Partner_Select_Product__c psprec:deal.PartnerSelects__r){
            Index1=Index1+1;
          
        productListAdd.add(new prodwrapper(psprec.Name,String.valueOf(psprec.Quantity__c),psprec.Eligible_for_Benifits__c,psprec.Approved__c,psprec.Eligible_to_Lead_Services__c,psprec.Id,Index1,psprec.Rejected__c,false,psprec.Discount__c,psprec.Willing_to_Lead_Services_Flag__c,allowLeadServicesProduct.get(psprec.Name)));
        }  
        Index = Index1;
        
    } 
        
        
    }
    public PageReference savefullDraft(){
    // Added below by Manik CR-00121519 
  
   /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. START */
    if(dealReg.Preferred_Distributor__c != null && dealReg.Preferred_Distributor__c != ''){
       
        list<Account> accList= new list<Account>();
        accList = [select id, Name, Preferred_Distributor__c, Partner_ID__c  from Account where Name = :dealReg.Preferred_Distributor__c and RecordType.id = :partnerAccRecordTypeID and Account_Status_Formula__c = 'Active'];
        
        if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Preferred_Distributor__c != null && loggedinUser.Contact.Account.Preferred_Distributor__c != '' && loggedinUser.Contact.Account.Preferred_Distributor__c == dealReg.Preferred_Distributor__c && accList.isEmpty()){
                dealReg.Orion_Preferred_Disti_ID__c = loggedinUser.Contact.Account.Partner_ID__c;
        }
        
        if(!accList.isEmpty()){
            for(Account acc : accList){
                dealReg.Orion_Preferred_Disti_ID__c = acc.Partner_ID__c;
               
            }           
        }        
    }
    /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. END */ 
    
    //Added by Vijit below - Calling a method.
     if(prefDistributorCountryCheck()){
        return null; 
     }
    if((dealReg.Are_You_the_Primary_Sales_Contact__c != null && dealReg.Are_You_the_Primary_Sales_Contact__c != '' && dealReg.Are_You_the_Primary_Sales_Contact__c == 'No') && dealReg.Orion_Primary_Sales_Contact_Name__c !=null){
            dealReg.Primary_Sales_Contact_Name__c=PrimaryContactName(dealReg.Orion_Primary_Sales_Contact_Name__c);
        }
    if(dealReg.Orion_Development_Fund_Utilized__c != null && dealReg.Orion_Development_Fund_Utilized__c != '--None--' && (dealReg.Campaign_Name__c ==null || dealReg.Campaign_Name__c == '' || dealReg.Campaign_Name__c=='--None--')){
          ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Opportunity_Source_not_blank));
            return null;
        }
    if((prefChannelRen==true || programType == 'Government') || (marketSegement=='US Federal' && (programType=='advantage+' || programType=='ELA'))){
    if(!String.isBlank(distributer) && distributer!=null && distributer!='' && distributer!='--None--')
                dealReg.Preferred_Distributor__c = distributer;
                else
                dealReg.Preferred_Distributor__c='';
     }   
     dealReg.Form_Navigation__c = 2;
     
     if(productListAdd==null || productListAdd.size()<=0 || productListAdd.isEmpty()){
                ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Products_Required));
                return null;  
           }
     
     /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Starts */
          dealReg.Is_Orion_DealReg__c = true;   
     /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Ends*/
     //Added by Manu for BUG-00146507-Starts
     dealReg.Orion_Need_To_Update_Management_Form__c=2;
     //Added by Manu for BUG-00146507-Ends
     if(dealReg.Registration_status__c==null){
     dealReg.Registration_status__c='Draft';
     }
      dealReg.StageName__c = stageOptions;
     // Change for CR-00121519 end
        //Added null check to throw error
        programType='advantage+';
       /* if(programType.equals('--None--')){
            
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_PROG_TYPE_BLANK));
            return null;   )         
        }*/
        
        if((programType.equals('advantage+') || programType.equals('ELA')) && dealReg.Zip_Postal_Code__c == null)
        {
        
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_POSTAL_CODE_BLANK));
            return null;
        } //Change End  
        //Added null check to throw error
        else if(stageOptions.equals('--None--')){
            
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_STAGE_BLANK));
            return null;            
        }
        // Added below by Manik CR-00121519 
        else if((!dealReg.Country__c.equalsIgnoreCase('United States')) && marketSegement.equalsIgnoreCase('US Federal'))
        {
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_WRONG_MARKET_SEGMENT));
            return null; 
        }
        //CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
     else if(dealreg.Preferred_Channel__c=='VMware Distributor' && (dealReg.Preferred_Distributor__c=='--None--' || dealReg.Preferred_Distributor__c==null  || dealReg.Preferred_Distributor__c==''))
        {
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_BLANK_PREF_DISTRIBUTOR));
            return null; 
        }  
         //Added by Manu-CR-00138671-Start   
        else If(dealReg.VMware_List_License_Value__c<10000 && !isAirwatchOnly()){
            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_The_list_license_less));
            return null;
        }
         //Added by Manu-CR-00138671-Ends
        else if(dealReg.StageName__c=='08 - Closed Won'){
            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_The_Opportunity_Stage_update));
            return null;
        }
    // Change CR-00121519 end               
        else {      
            dealReg.Program_Type__c = programType;
            dealReg.StageName__c = stageOptions;        
            
            showMsg = validateListLicenseValue(programType);
            
          /*  if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType)){
                
                String eppOrderNumber = dealReg.Initial_EPP_Order_Number__c;
                List<String> orderList = new List<String>();
    
                for(Order__c ord: [Select Order_Number__c from Order__c where Order_Number__c=: eppOrderNumber limit 1]){
    
                    orderList.add(ord.Order_Number__c);
                }    
                if(orderList.size()==0){
                     ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_INITIAL_EPP_VALID));
                     return null;
                }
            }*/
            //Modified condition for BUG-00040231. By - Jaypal Singh. Dated: 09/03/2012
            if(marketSegement.equals('--None--')){              
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_MKT_SEG_BLANK));
                return null;            
            }
            //code start for CR-00113657 by sandip
        // if condition added by sandip  for CR-00122078 
  if(programType != 'EPP Post-Sale Burn-Down'){
             if(dealReg.Preferred_Channel__c == null){
                
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PRECH));
                return null;            
            }else if(dealReg.Preferred_Channel__c.equals('--None--')){
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PRECH));
                return null;  
            }
      //CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
      else if(dealReg.Preferred_Channel__c.equals('VMware Distributor')){
                if(dealReg.Preferred_Distributor__c == null){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PREDIST));
                    return null; 
                }
            }
   }        
            //code end for CR-00113657 by sandip
            dealReg.Customer_Market_Segment__c = marketSegement;
            
            if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS.equalsIgnoreCase(programType)){
                
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ADPLUS));
                    return null;
                }
                //dealReg.RecordTypeId = recursive.DealRegAdvantageRecType;
                dealReg.RecordTypeId = recursive.DealRegOrionAdvantageRecType ;
            }
          
            
            //Changes made for CR-00020258 : Dated 10/27/2012 Jaypal Singh
            //Commented below by Vijit for Sprint-3
           /* if(ApexPages.currentPage().getParameters().get('reRegister') == 'true'){
                newDealReg = dealReg.clone(false,true);
                
                newDealReg = nullifyNewDealRegFields(newDealReg);

                newDealReg = nullifyFieldsProgramChange(newDealReg);
                
                newDealReg.Previous_Registration__c = dealReg.id;
                
                newDealReg.Registration_Status__c = 'Draft';

                try{
                    system.debug('newDealReg ' + newDealReg);                    

                    Deal_Registration__c oldDeal = [Select Id, Registration_Status__c, Reregistered_Date__c, Registrations__c from Deal_Registration__c where Id =: dealReg.Id];
                    system.debug('dealReg.Registrations__c = ' +oldDeal.Registrations__c);
                    newDealReg.Registrations__c = oldDeal.Registrations__c;
                    insert newDealReg;

                    oldDeal = updateOldDealRegFields(oldDeal);

                    update oldDeal;
                }               
                catch(Exception ex){
                    
                    //Displaying Error Message on page
                    ApexPages.addMessages(ex);           
                    return null;             
                }
                PageReference dealPage = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+newDealReg.id);
                //PageReference dealPage = new ApexPages.StandardController(newDealReg).view();
                dealPage.setRedirect(true);
                return dealPage;
            }*/
            //Changes End for CR-00020258 
             Id finaldealId;
                try{
                    if(isEdit==true){
                        
                        dealReg = nullifyFieldsProgramChange(dealReg);                      
                    }
                    List<Deal_Registration__c> dealList = new List<Deal_Registration__c>();
                    dealList.add(dealReg);
                    
                    Set<String> uniqueProductName = new Set<String>();
            //Modified by Vijit for Duplicate Product Highlight Defect Fix - Start
                    Boolean containsDuplicate = false;
                    countAirwatchProduct = 0;
                    for(prodwrapper wrap:productListAdd){
                        if(uniqueProductName.add(wrap.name)==false)
                        {
                            wrap.isDuplicate = true;
                            containsDuplicate = true;                         
                        }
                         // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- START
                        for(Orion_Airwatch_Product__c obj: Orion_Airwatch_Product__c.getAll().values()){
                            if(obj.ProductName__c.equalsIgnoreCase(wrap.name)){
                               countAirwatchProduct = countAirwatchProduct + 1;
                            }                          
                        }
                    }
                    if(countAirwatchProduct == productListAdd.size()){
                        dealReg.Orion_AirwatchByPass__c = true; // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added.
                        if(dealReg.Incentive_Program__c != null && dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){
                            extendedExpirationDaysRegProgram = Integer.ValueOf(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c);
                        } 
                        if(dealReg.Orion_Deal_Registration_Expiration_Date__c == null){
                            if(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){           
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDaysRegProgram;  
                            }else{
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDays; 
                            } 
                        }
                        if(dealReg.Orion_Eligible_for_Benefits_Date__c == null){
                            dealReg.Orion_Eligible_for_Benefits_Date__c = System.Now();
                        }   
                    }
                     // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- END
                   if(containsDuplicate){
                       ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Duplicate_Products_Found));
                       return null;
                   } //Modified by Vijit for Duplicate Product Highlight Defect Fix - END
                    //Added to check if Product's Quantity is required-Start
                   for(prodwrapper wrap:productListAdd){
                       if(wrap.Quantity==null || wrap.Quantity=='')
                       {
                            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Quantity_required));
                            return null;
                       }
                   }
             //Added to check if Product's Quantity is required-End
              //Added for Product Name to be shown on Deal by Archana- Start
              String temp='';
                   for(prodwrapper wrap:productListAdd){
                      temp = temp+wrap.name+',';
                  }
                    temp= temp.substring(0,temp.length()-1);
                    if(temp!=null &&   temp!=''){
                        dealReg.All_Vmware_Products__c=temp;
                    }
                     //Added for Product Name to be shown on Deal by Archana- Start
             
                    upsert dealReg;
                     
                  
                   finaldealId = dealList[0].Id;
                   // List<Database.upsertResult> uResults = Database.upsert(dealList,false);
                      Map<Id, Deal_Registration__c> DealMap = new Map<Id, Deal_Registration__c>(dealList);
                     List<Partner_Select_Product__c> pSPList = new List<Partner_Select_Product__c>();
                   /*   for(Database.upsertResult result:uResults) {
                     if (result.isSuccess() && result.isCreated()){
                     finaldealId=result.getId();
                     }
                      else{
                          for(Database.Error err : result.getErrors()) {
                           

                            }

                     }
                          
                        
                  }*/
                  
                 
                  if(deleteProduct!=null && deleteProduct.size()>0){
                    List<Partner_Select_Product__c> deleteProductList = new List<Partner_Select_Product__c>();
                      for(Id ProdId:deleteProduct){
                           deleteProductList.add(new Partner_Select_Product__c(Id =ProdId ));
                      }
                     delete deleteProductList;
                  }
                   
                  if(finaldealId!=null){
                  for(prodwrapper wrap:productListAdd){
                       if(wrap.productId==null){
                      pSPList.add(new Partner_Select_Product__c(Name = wrap.name,ORTN_Number__c =DealMap.get(finaldealId).Name,Quantity__c=Integer.valueOf(wrap.Quantity), Product__c = ProdNewMap.get(wrap.name).Id, Division__c=ProdNewMap.get(wrap.name).Division__c, Platform_Group__c=ProdNewMap.get(wrap.name).Platform_Group__c, Product_Group__c=ProdNewMap.get(wrap.name).Product_Group__c,Product_Name__c= ProdNewMap.get(wrap.name).Registration_Product_Name__c, Product_Platform__c=ProdNewMap.get(wrap.name).Product_Platform__c, Registration__c=finaldealId,Willing_to_Lead_Services_Flag__c = wrap.willingLeadServices));
                  }
                  else{
                      if(wrap.Quantity!=null){
                      Partner_Select_Product__c psprecord = new Partner_Select_Product__c(Id=wrap.productId,Quantity__c=Integer.valueOf(wrap.Quantity),Willing_to_Lead_Services_Flag__c=wrap.willingLeadServices);
                      pSPList.add(psprecord);
                      }
                       
                      
                      
                  }
                  }
                  if(productListAdd!=null && productListAdd.size()>0){
                  upsert pSPList;
                  }
                  }
                }               
                catch(Exception ex){
                    
                    //Displaying Error Message on page
                    ApexPages.addMessages(ex);           
                    return null;             
                }
                if(finaldealId!=null){
                retreiveDealRecords(finaldealId);
                }
                 PageReference pageRefer = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+finaldealId);
                 pageRefer.setRedirect(true);
                 return pageRefer;
             //   PageReference dealPage = new ApexPages.StandardController(dealReg).view();
               // dealPage.setRedirect(true);
               // return dealPage;

        } 
    }
  //Commented the below code/method for SDD changes-Archana
    /* public PageReference submitForApprovalPage1(){
        if(dealReg.Id!=null){
          String booleanWindow  = DealRegEPP_Utilities.validateEditAccess(UserInfo.getUserId(),dealReg.Id);
                   if(booleanWindow  != 'yes'){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Orion_Access_to_Deal)); 
                    return null;
         }
       }       
       
       //Added as part of Orion Phase 2 - Yoganand start
        if(SourcedAcc != null && SourcedAcc != '')
            contactAccount = SourcedAcc;
        //Added as part of Orion Phase 2 - Yoganand End
        
         if(dealReg.Orion_Development_Fund_Utilized__c != null && dealReg.Orion_Development_Fund_Utilized__c != '--None--' && (dealReg.Campaign_Name__c ==null || dealReg.Campaign_Name__c == '' || dealReg.Campaign_Name__c=='--None--')){
          ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Opportunity_Source_not_blank));
            return null;
        }
     
      
     //Added Contact Validation By Ibrahim.
     if(ValidateContact()){
         return null;
     }   
     // REQ-REG-058 - 15th March 2016 by Vijit Vijay - Calling the method.
     if(primarySalesEmailCheck()){
         return null;
     }
     // REQ-REG-059 - 21st April 2016 by Vijit Vijay - Calling the method.
     if(checkEmailDomain()){
         return null;
     } 
     /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. START */
   //Commented the below code for SDD changes-Archana
   /* if(dealReg.Preferred_Distributor__c != null && dealReg.Preferred_Distributor__c != ''){
       
        list<Account> accList= new list<Account>();
        accList = [select id, Name, Partner_ID__c  from Account where Name = :dealReg.Preferred_Distributor__c and RecordType.id = :partnerAccRecordTypeID and Account_Status_Formula__c = 'Active'];
        
        if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Preferred_Distributor__c != null && loggedinUser.Contact.Account.Preferred_Distributor__c != '' && loggedinUser.Contact.Account.Preferred_Distributor__c == dealReg.Preferred_Distributor__c && accList.isEmpty()){
                dealReg.Orion_Preferred_Disti_ID__c = loggedinUser.Contact.Account.Partner_ID__c;
        }
        
        if(!accList.isEmpty()){
            for(Account acc : accList){
                dealReg.Orion_Preferred_Disti_ID__c = acc.Partner_ID__c;
              
            }           
        }        
    }
    /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. END */ 
  //Commented the below code for SDD changes-Archana
     //Added by Vijit below - Calling a method.
   /*  if(prefDistributorCountryCheck()){
        return null; 
     }
    
      if((dealReg.Are_You_the_Primary_Sales_Contact__c != null && dealReg.Are_You_the_Primary_Sales_Contact__c != '' && dealReg.Are_You_the_Primary_Sales_Contact__c == 'No') && dealReg.Orion_Primary_Sales_Contact_Name__c !=null){
            dealReg.Primary_Sales_Contact_Name__c=PrimaryContactName(dealReg.Orion_Primary_Sales_Contact_Name__c);
        }
    /* REQ-REG-057 - 18th March 2016 by Vijit Vijay - Send to Manual Review if Country and State is changed. START */   
  //Commented the below code for SDD changes-Archana
    /* if((contactCountry != null && dealReg.Country__c != contactCountry) || (dealReg.State_Province__c != contactState && contactState != null && contactState != 'null' && contactState != '' && contactState != ' ' && contactState != '__' && contactState != '_' && contactState != '--' && dealReg.State_Province__c != null && dealReg.State_Province__c != 'null' && dealReg.State_Province__c != '' && dealReg.State_Province__c != ' ' && dealReg.State_Province__c != '__' && dealReg.State_Province__c != '_' && dealReg.State_Province__c != '--')){
          //dealReg.Manual_Review__c = true;
          //dealDenailReason = Orion_Phase_II_Configurations__c.getValues('countrystatechanged').value__c;
         
      Orion_OppManagementSequenceController.paramChangedOnForm = true;
     }
     /* REQ-REG-057 - 18th March 2016 by Vijit Vijay - Send to Manual Review if Country and State is changed. END */
    
     //Added as part of Orion phase 2 Yoganand - start
   //Commented the below code for SDD changes-Archana
   /*
    if((dealReg.Zip_Postal_Code__c != contactZipCode && contactZipCode != null) || (dealReg.City__c != contactCity && contactCity!=null) || (dealReg.Company__c != contactAccountName && contactAccountName != null) || (dealReg.Orion_Customer_Domain__c != contactDomain && contactDomain!=null)){
       //flag deal reg for manual review if address changed by user and macthing account found is different then already sourced
       //dealReg.Manual_Review__c = Orion_OppManagementUtility.ValidateDealForManualApproval(dealReg,contactAccount);
       //dealDenailReason = Orion_Phase_II_Configurations__c.getValues('adddressondealchanged').value__c;
     Orion_OppManagementSequenceController.paramChangedOnForm = true;
    }
    
    //Added as part of Orion phase 2 Yoganand - end
    
     dealReg.Form_Navigation__c=2;
     /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Starts */
   //Commented the below code for SDD changes-Archana
   /*
          dealReg.Is_Orion_DealReg__c = true;   
     /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Ends*/
     //Added by Manu for BUG-00146507-Starts
   //Commented the below code for SDD changes-Archana
    /* dealReg.Orion_Need_To_Update_Management_Form__c=1;
     //Added by Manu for BUG-00146507-Ends
      if(dealReg.Registration_status__c==null){
      dealReg.Registration_status__c='Draft';
      }
     
     
     if((prefChannelRen==true || programType == 'Government') || (marketSegement=='US Federal' && (programType=='advantage+' || programType=='ELA'))){
     if(!String.isBlank(distributer) && distributer!=null && distributer!='' && distributer!='--None--')
                dealReg.Preferred_Distributor__c = distributer;
                else
                dealReg.Preferred_Distributor__c='';
    }       
   
    // Change for CR-00121519 End 
        //Added null check to throw error
        programType = 'advantage+';
        
        
        if(programType.equals('advantage+')  && dealReg.Zip_Postal_Code__c == null)
        {
        
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_POSTAL_CODE_BLANK));
            return null;
        } //Change End  
        
        //Added null check to throw error
        else if(stageOptions.equals('--None--')){
            
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_STAGE_BLANK));
            return null;            
        }
        // Added below by Manik CR-00121519 
         //Added by Manu-CR-00138671-Start   
        else If(dealReg.VMware_List_License_Value__c<10000 && !isAirwatchOnly()){
            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_The_list_license_less));
            return null;
        }
         //Added by Manu-CR-00138671-Ends
        else if((!dealReg.Country__c.equalsIgnoreCase('United States')) && marketSegement.equalsIgnoreCase('US Federal'))
        {
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_WRONG_MARKET_SEGMENT));
            return null; 
        }
      else{     
            dealReg.Program_Type__c = programType;    
            dealReg.StageName__c = stageOptions;
            showMsg = validateListLicenseValue(programType);
            if(marketSegement.equals('--None--')){
                
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_MKT_SEG_BLANK));
                return null;            
            }
           if(productListAdd==null || productListAdd.size()<=0 || productListAdd.isEmpty()){
                ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Products_Required));
                return null;  
           }
            //need to add the condition for page 2-- Archana 
            //code end for CR-00113657 by sandip
            dealReg.Customer_Market_Segment__c = marketSegement;
            if(dealReg.Registration_Status__c==null){
                dealReg.Registration_Status__c = 'Draft';
            }
                        
            if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS.equalsIgnoreCase(programType)){
                
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ADPLUS));
                    return null;
                }
               // dealReg.RecordTypeId = recursive.DealRegAdReadOnlyRecType;
                dealReg.RecordTypeId = recursive.DealRegOrionAdvReadOnlyRecType ; 
            }
             //Changes made for CR-00020258 : Dated 10/27/2012 Jaypal Singh
            if(ApexPages.currentPage().getParameters().get('reRegister') == 'true'){
                newDealReg = dealReg.clone(false,true);
                
                newDealReg = nullifyNewDealRegFields(newDealReg);

                newDealReg = nullifyFieldsProgramChange(newDealReg);
                
                newDealReg.Previous_Registration__c = dealReg.id;
                
                newDealReg.Registration_Status__c = 'Draft';
                newDealReg.RecordTypeId = recursive.DealRegOrionAdvReadOnlyRecType ;

                try{
                    
                    Deal_Registration__c oldDeal = [Select Id, Registration_Status__c, Reregistered_Date__c, Registrations__c from Deal_Registration__c where Id =: dealReg.Id];
                    newDealReg.Registrations__c = oldDeal.Registrations__c;
                    insert newDealReg;

                    //Setting values to Submit request in Approval process
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(newDealReg.Id);
                      
                    // Submit the request for Approval
                    // 18th March 2016 by Vijit Vijay - Added Manual Review check below for Orion Ph2.
                    /*if(dealReg.Manual_Review__c == true){
                     Orion_OppManagementSequenceController.updateDenialReasonOnDeal(newDealReg.Id,dealDenailReason);
                    Approval.ProcessResult result = Approval.process(req); 
                    
                    }else{*/
                        //added below line as part of Orion Phase 2 [Yoganand]
          /*              Orion_OppManagementSequenceController.searchEndCustomerAccount(newDealReg.Id,contactAccount);
                     // }
                        
                        oldDeal = updateOldDealRegFields(oldDeal);
                        update oldDeal;
                       
                }               
                catch(Exception ex){
                    
                    //Displaying Error Message on page
                    ApexPages.addMessages(ex);           
                    return null;             
                }
                PageReference dealPage = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+newDealReg.id);
                //PageReference dealPage = new ApexPages.StandardController(newDealReg).view();
                dealPage.setRedirect(true);
                return dealPage;
            }
            //Changes End for CR-00020258
       Id finaldealId;
           try{
                Set<String> uniqueProductName = new Set<String>();
        //Modified by Vijit for Duplicate Product Highlight Defect Fix - Start
                Boolean containsDuplicate = false;
                countAirwatchProduct = 0;
                    for(prodwrapper wrap:productListAdd){
                       if(uniqueProductName.add(wrap.name)==false)
                        {
                            wrap.isDuplicate = true;
                            containsDuplicate = true;                           
                        }
                         // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- START
                        for(Orion_Airwatch_Product__c obj: Orion_Airwatch_Product__c.getAll().values()){
                            if(obj.ProductName__c.equalsIgnoreCase(wrap.name)){
                               countAirwatchProduct = countAirwatchProduct + 1;
                            }                          
                        }
                    }
                    if(countAirwatchProduct == productListAdd.size()){
                        dealReg.Orion_AirwatchByPass__c = true; // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added.
                        if(dealReg.Incentive_Program__c != null && dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){
                            extendedExpirationDaysRegProgram = Integer.ValueOf(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c);
                        } 
                        if(dealReg.Orion_Deal_Registration_Expiration_Date__c == null){
                            if(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){           
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDaysRegProgram;  
                            }else{
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDays; 
                            } 
                        }
                        if(dealReg.Orion_Eligible_for_Benefits_Date__c == null){
                            dealReg.Orion_Eligible_for_Benefits_Date__c = System.Now();
                        }   
                    }
                     // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- END
                if(containsDuplicate){
                    ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Duplicate_Products_Found));
                    return null;
                }  //Modified by Vijit for Duplicate Product Highlight Defect Fix - END 
            //Added for Product Name to be shown on Deal by Archana- Start
            String temp='';
                   for(prodwrapper wrap:productListAdd){
                      temp = temp+wrap.name+',';
                  }
                    temp= temp.substring(0,temp.length()-1);
                    if(temp!=null &&   temp!=''){
                        dealReg.All_Vmware_Products__c=temp;
                    }
                     //Added for Product Name to be shown on Deal by Archana- Start
                upsert dealReg;
               finaldealId = dealReg.Id;
                 List<Partner_Select_Product__c> pSPList = new List<Partner_Select_Product__c>();
                 List<Deal_Registration__c> dealList = new List<Deal_Registration__c>();
                 dealList.add(dealReg);
                   Map<Id, Deal_Registration__c> DealMap = new Map<Id, Deal_Registration__c>(dealList);
                   if(deleteProduct!=null && deleteProduct.size()>0){
                    List<Partner_Select_Product__c> deleteProductList = new List<Partner_Select_Product__c>();
                      for(Id ProdId:deleteProduct){
                           deleteProductList.add(new Partner_Select_Product__c(Id =ProdId ));
                      }
                     delete deleteProductList;
                  }
                if(finaldealId!=null){
                  for(prodwrapper wrap:productListAdd){
                       if(wrap.productId==null){
                      pSPList.add(new Partner_Select_Product__c(Name = wrap.name,ORTN_Number__c =DealMap.get(finaldealId).Name,Product__c = ProdNewMap.get(wrap.name).Id, Division__c=ProdNewMap.get(wrap.name).Division__c, Platform_Group__c=ProdNewMap.get(wrap.name).Platform_Group__c, Product_Group__c=ProdNewMap.get(wrap.name).Product_Group__c,Product_Name__c= ProdNewMap.get(wrap.name).Registration_Product_Name__c, Product_Platform__c=ProdNewMap.get(wrap.name).Product_Platform__c, Registration__c=finaldealId));
                  }
                   else{
                       if(wrap.Quantity!=null){
                      Partner_Select_Product__c psprecord = new Partner_Select_Product__c(Id=wrap.productId,Quantity__c=Integer.valueOf(wrap.Quantity));
                      pSPList.add(psprecord);
                       }
                      
                      
                      
                  }
                  }
                  if(productListAdd!=null && !productListAdd.isEmpty()){
                  insert pSPList;
                  }
                  }
                //modified as part of Orion phase 2 Yoganand - start
                /*if(dealReg.Manual_Review__c == true){
                Orion_OppManagementSequenceController.updateDenialReasonOnDeal(dealReg.Id,dealDenailReason);
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(dealReg.Id);
                Approval.ProcessResult result = Approval.process(req);
                }
                else {*/
           /*     Orion_OppManagementSequenceController.searchEndCustomerAccount(dealReg.Id,contactAccount);
                //}
                //modified as part of Orion phase 2 Yoganand - end
            }
            catch(Exception ex){
                
                ApexPages.addMessages(ex);           
                return null;
            }       
            if(finaldealId!=null){
                retreiveDealRecords(finaldealId);
                }
                 PageReference pageRefer = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+finaldealId);
                                  pageRefer.setRedirect(true);
        return pageRefer;
         /*   PageReference dealPage = new ApexPages.StandardController(dealReg).view();
            dealPage.setRedirect(true);*/
            
           // return dealPage;
    /*    }
    }
    */
  //Commented the code/method for SDD changes-Archana
    public PageReference submitForApproval(){
     if(dealReg.Id!=null){
         String booleanWindow  = DealRegEPP_Utilities.validateEditAccess(UserInfo.getUserId(),dealReg.Id);
         if(booleanWindow  != 'yes'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Orion_Access_to_Deal)); 
            return null;
         }
       }    
        
     //Added Cotact Validation By Ibrahim.
     if(ValidateContact()){
         return null;
     }
     // REQ-REG-058 - 15th March 2016 by Vijit Vijay - Calling the method.
     if(primarySalesEmailCheck()){
         return null;
     }
     if(dealReg.Orion_Development_Fund_Utilized__c != null && dealReg.Orion_Development_Fund_Utilized__c != '--None--' && (dealReg.Campaign_Name__c ==null || dealReg.Campaign_Name__c == '' || dealReg.Campaign_Name__c=='--None--')){
          ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Opportunity_Source_not_blank));
            return null;
        }
        //Added as part of CR-00140795 on 23/Aug/2016 - Vijit - START
        

            multiAccountFound = checkMultiAcc();
            if(multiAccountFound){
               Orion_OppManagementUtility.multipleAccountFlag = true;
            }
            else{
              Orion_OppManagementUtility.multipleAccountFlag = false;
            }       
        //Added as part of CR-00140795 on 23/Aug/2016 - Vijit - END
        
        //Added as part of Orion Phase 2 - Yoganand start
        if(SourcedAcc != null && SourcedAcc != '')
            contactAccount = SourcedAcc;
         
         Orion_OppManagementUtility.sourcedConId = contactId;    
        //Added as part of Orion Phase 2 - Yoganand End
     
      if((dealReg.Are_You_the_Primary_Sales_Contact__c != null && dealReg.Are_You_the_Primary_Sales_Contact__c != '' && dealReg.Are_You_the_Primary_Sales_Contact__c == 'No') && dealReg.Orion_Primary_Sales_Contact_Name__c !=null){
            dealReg.Primary_Sales_Contact_Name__c=PrimaryContactName(dealReg.Orion_Primary_Sales_Contact_Name__c);
        }
    /* REQ-REG-057 - 18th March 2016 by Vijit Vijay - Send to Manual Review if Country and State is changed. START */   
     if((contactCountry != null && dealReg.Country__c != contactCountry) || (dealReg.State_Province__c != contactState && contactState != null && contactState != 'null' && contactState != '' && contactState != ' ' && contactState != '__' && contactState != '_' && contactState != '--' && dealReg.State_Province__c != null && dealReg.State_Province__c != 'null' && dealReg.State_Province__c != '' && dealReg.State_Province__c != ' ' && dealReg.State_Province__c != '__' && dealReg.State_Province__c != '_' && dealReg.State_Province__c != '--')){
          //dealReg.Manual_Review__c = true;
          //dealDenailReason = Orion_Phase_II_Configurations__c.getValues('countrystatechanged').value__c;
      Orion_OppManagementSequenceController.paramChangedOnForm = true;
    dealreg.Account_Populated__c = null;//added as part of Orion HotFix
          
     }
    /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. START */
    if(dealReg.Preferred_Distributor__c != null && dealReg.Preferred_Distributor__c != ''){
        
        list<Account> accList= new list<Account>();
        accList = [select id, Name, Partner_ID__c  from Account where Name = :dealReg.Preferred_Distributor__c and RecordType.id = :partnerAccRecordTypeID and Account_Status_Formula__c = 'Active'];
        
        if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Preferred_Distributor__c != null && loggedinUser.Contact.Account.Preferred_Distributor__c != '' && loggedinUser.Contact.Account.Preferred_Distributor__c == dealReg.Preferred_Distributor__c && accList.isEmpty()){
                dealReg.Orion_Preferred_Disti_ID__c = loggedinUser.Contact.Account.Partner_ID__c;
        }
        
        if(!accList.isEmpty()){
            for(Account acc : accList){
                dealReg.Orion_Preferred_Disti_ID__c = acc.Partner_ID__c;
               
            }           
        }        
    }
    /* REQ-40 - 23rd March 2016 by Vijit Vijay - To populate Preferred Disti ID on the registration record based on Preferred Distributor selected. END */ 
    
    //Added by Vijit below - Calling a method.
     if(prefDistributorCountryCheck()){
        return null; 
     }
    
     //Added as part of Orion phase 2 Yoganand - start
    /*if((dealReg.Zip_Postal_Code__c != contactZipCode && contactZipCode != null) || (dealReg.City__c != contactCity && contactCity!=null) || (dealReg.Company__c != contactAccountName && contactAccountName != null) || (dealReg.Orion_Customer_Domain__c != contactDomain && contactDomain!=null)){*/
  if( (dealReg.City__c != contactCity) || (dealReg.Company__c != contactAccountName) || (dealReg.Orion_Customer_Domain__c != contactDomain)){
       //flag deal reg for manual review if address changed by user and macthing account found is different then already sourced
       //dealReg.Manual_Review__c = Orion_OppManagementUtility.ValidateDealForManualApproval(dealReg,contactAccount);
       //dealDenailReason = Orion_Phase_II_Configurations__c.getValues('adddressondealchanged').value__c;
     Orion_OppManagementSequenceController.paramChangedOnForm = true;
   dealreg.Account_Populated__c = null;//added as part of Orion HotFix
    }
    
    //Added as part of Orion phase 2 Yoganand - end

    /* REQ-REG-057 - 18th March 2016 by Vijit Vijay - Send to Manual Review if Country and State is changed. END */
     if((prefChannelRen==true || programType == 'Government') || (marketSegement=='US Federal' && (programType=='advantage+' || programType=='ELA'))){
     if(!String.isBlank(distributer) && distributer!=null && distributer!='' && distributer!='--None--')
                dealReg.Preferred_Distributor__c = distributer;
                else
                dealReg.Preferred_Distributor__c='';
    }       
    dealReg.Form_Navigation__c=2;
    /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Starts */
          dealReg.Is_Orion_DealReg__c = true;   
    /* Prasad : 23-May-2016 - Mark Orion Deal Reg - Ends*/
    //Added by Manu for BUG-00146507-Starts
     dealReg.Orion_Need_To_Update_Management_Form__c=2;
     //Added by Manu for BUG-00146507-Ends
     if(dealReg.Registration_status__c==null){
      dealReg.Registration_status__c='Draft';
     }
     dealReg.StageName__c = stageOptions;
    // Change for CR-00121519 End 
        //Added null check to throw error
        programType = 'advantage+';
        if(programType.equals('--None--')){
            
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_PROG_TYPE_BLANK));
            return null;            
        }
        
        else if((programType.equals('advantage+') || programType.equals('ELA')) && dealReg.Zip_Postal_Code__c == null)
        {
        
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_POSTAL_CODE_BLANK));
            return null;
        } //Change End  
         //Added by Manu-CR-00138671-Start   
        else If(dealReg.VMware_List_License_Value__c<10000 && !isAirwatchOnly()){
            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_The_list_license_less));
            return null;
        }
         //Added by Manu-CR-00138671-Ends
        else if(dealReg.StageName__c=='08 - Closed Won'){
         ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_The_Opportunity_Stage_update));
                    return null;
        }
        //Added null check to throw error
        else if(stageOptions.equals('--None--')){
            
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_STAGE_BLANK));
            return null;            
        }
        // Added below by Manik CR-00121519 
        else if((!dealReg.Country__c.equalsIgnoreCase('United States')) && marketSegement.equalsIgnoreCase('US Federal'))
        {
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_WRONG_MARKET_SEGMENT));
            return null; 
        }
  //CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
        else if(dealreg.Preferred_Channel__c=='VMware Distributor' && (dealReg.Preferred_Distributor__c=='--None--' || dealReg.Preferred_Distributor__c=='' || dealReg.Preferred_Distributor__c==null || String.IsBlank(dealReg.Preferred_Distributor__c) || String.IsEmpty(dealReg.Preferred_Distributor__c)))
        { // Added By Pallavi Jha CR-00128939 || String.IsBlank(dealReg.Preferred_Distributor__c) || String.IsEmpty(dealReg.Preferred_Distributor__c) 
            ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_BLANK_PREF_DISTRIBUTOR));
            return null; 
        }      
    // Change for CR-00121519 End         
        else{     
            dealReg.Program_Type__c = programType;    
            dealReg.StageName__c = stageOptions;
            showMsg = validateListLicenseValue(programType);
              dealReg.RecordTypeId = recursive.DealRegOrionAdvantageRecType ;
            
          /*  if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType)){
                
                String eppOrderNumber = dealReg.Initial_EPP_Order_Number__c;
                List<String> orderList = new List<String>();
    
                for(Order__c ord: [Select Order_Number__c from Order__c where Order_Number__c=: eppOrderNumber limit 1]){    
                    orderList.add(ord.Order_Number__c);
                }
                
                if(orderList.size()==0){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_INITIAL_EPP_VALID));
                    return null;
                }
            }*/
            //Modified condition for BUG-00040231. By - Jaypal Singh. Dated: 09/03/2012    
            if(marketSegement.equals('--None--')){
                
                ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_MKT_SEG_BLANK));
                return null;            
            }
            if(productListAdd==null || productListAdd.size()<=0 || productListAdd.isEmpty()){
                ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Products_Required));
                return null;  
           }
            //code start for CR-00113657 by sandip
         // if condition added by sandip  for CR-00122078 
         //need to add the condition for page 2-- Archana 
         
            if(programType != 'EPP Post-Sale Burn-Down'){
                if(dealReg.Preferred_Channel__c == null){
                    
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PRECH));
                    return null;            
                }else if(dealReg.Preferred_Channel__c.equals('--None--')){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PRECH));
                    return null;  
            //CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
                }else if(dealReg.Preferred_Channel__c.equals('VMware Distributor')){
                    if(dealReg.Preferred_Distributor__c == null || String.IsBlank(dealReg.Preferred_Distributor__c) || String.IsEmpty(dealReg.Preferred_Distributor__c)){
                        // Addeb by Pallavi jha CR- 00128939 || String.IsBlank(dealReg.Preferred_Distributor__c) || String.IsEmpty(dealReg.Preferred_Distributor__c) 
                        ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.DEAL_REG_LIST_LABEL_PREDIST));
                        return null; 
                    }
                }
            }
            
            //need to add the condition for page 2-- Archana 
            //code end for CR-00113657 by sandip
            dealReg.Customer_Market_Segment__c = marketSegement;
                        
            if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS.equalsIgnoreCase(programType)){
                
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ADPLUS));
                    return null;
                }
                //dealReg.RecordTypeId = recursive.DealRegAdReadOnlyRecType;
                  dealReg.RecordTypeId = recursive.DealRegOrionAdvReadOnlyRecType ;
            }
            else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA.equalsIgnoreCase(programType)){
                
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ELA));
                    return null;
                }
                dealReg.RecordTypeId = recursive.DealRegELAReadOnlyRecType;
            }
            else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT.equalsIgnoreCase(programType)){
                
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_GOV));
                    return null;
                }
                dealReg.RecordTypeId = recursive.DealRegGOVReadOnlyRecType;
                dealReg.Preferred_Distributor__c = distributer;
            }
            else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(programType)){
                    
                if(showMsg){
                    ApexPages.addMessages(new DealReg_EPP_Exception(DealRegEPP_Constants.ERROR_LIST_LICENSE_VALUE_ELA));
                    return null;
                }
                dealReg.RecordTypeId = recursive.DealRegEPPRecType;
            }

            //Changes made for CR-00020258 : Dated 10/27/2012 Jaypal Singh
            //Commented below by Vijit Sprint-3
           /* if(ApexPages.currentPage().getParameters().get('reRegister') == 'true'){
                newDealReg = dealReg.clone(false,true);
                
                newDealReg = nullifyNewDealRegFields(newDealReg);

                newDealReg = nullifyFieldsProgramChange(newDealReg);
                
                newDealReg.Previous_Registration__c = dealReg.id;
                
                newDealReg.Registration_Status__c = 'Draft';

                try{
                    system.debug('newDealReg ' + newDealReg);
                    Deal_Registration__c oldDeal = [Select Id, Registration_Status__c, Reregistered_Date__c,Registrations__c from Deal_Registration__c where Id =: dealReg.Id];
                    system.debug('dealReg.Registrations__c = ' +oldDeal.Registrations__c);
                    newDealReg.Registrations__c = oldDeal.Registrations__c;
                    insert newDealReg;
                     
                    //Setting values to Submit request in Approval process
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(newDealReg.Id);
                      
                    // Submit the request for Approval
                    // 18th March 2016 by Vijit Vijay - Added Manual Review check below for Orion Ph2.
                    if(dealReg.Manual_Review__c == true){
                    Orion_OppManagementSequenceController.updateDenialReasonOnDeal(newDealReg.Id,dealDenailReason);
                    Approval.ProcessResult result = Approval.process(req); //commented as part of Orion Phase 2 [Yoganand]
                    //added below line as part of Orion Phase 2 [Yoganand]
                    }else{
                        Orion_OppManagementSequenceController.searchEndCustomerAccount(newDealReg.Id,contactAccount);
                    }
                        
                        oldDeal = updateOldDealRegFields(oldDeal);
                        update oldDeal;
                       
                }               
                catch(Exception ex){
                    
                    //Displaying Error Message on page
                    ApexPages.addMessages(ex);           
                    return null;             
                }
                PageReference dealPage = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+newDealReg.id);
                //PageReference dealPage = new ApexPages.StandardController(newDealReg).view();
                dealPage.setRedirect(true);
                return dealPage;
            }*/
            //Changes End for CR-00020258        
       Id finaldealId;
           try{
                Set<String> uniqueProductName = new Set<String>();
        //Modified by Vijit for Duplicate Product Highlight Defect Fix - Start
                Boolean containsDuplicate = false;
                countAirwatchProduct = 0;
                    for(prodwrapper wrap:productListAdd){
                        if(uniqueProductName.add(wrap.name)==false)
                        {
                            wrap.isDuplicate = true;
                            containsDuplicate = true;                        
                        }
                         // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- START
                        for(Orion_Airwatch_Product__c obj: Orion_Airwatch_Product__c.getAll().values()){
                            if(obj.ProductName__c.equalsIgnoreCase(wrap.name)){
                               countAirwatchProduct = countAirwatchProduct + 1;
                            }                          
                        }
                    }
                   
                    if(countAirwatchProduct == productListAdd.size()){
                        dealReg.Orion_AirwatchByPass__c = true; // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added.
                        if(dealReg.Incentive_Program__c != null && dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){
                            extendedExpirationDaysRegProgram = Integer.ValueOf(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c);
                        } 
                        if(dealReg.Orion_Deal_Registration_Expiration_Date__c == null){
                            if(dealReg.Incentive_Program__r.Orion_Days_to_Extend__c != null){           
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDaysRegProgram;  
                            }else{
                                dealReg.Orion_Deal_Registration_Expiration_Date__c = System.Today() + extendedExpirationDays; 
                            } 
                        }
                        if(dealReg.Orion_Eligible_for_Benefits_Date__c == null){
                            dealReg.Orion_Eligible_for_Benefits_Date__c = System.Now();
                        }   
                    }
                 // Added by Vijit to Bypass 45 Day Rule when Airwatch Product is added- END    
                if(containsDuplicate){
                    ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Duplicate_Products_Found));
                    return null;
                } 
         //Modified by Vijit for Duplicate Product Highlight Defect Fix - END      
            //Added to check if Product's Quantity is required-Start
                    for(prodwrapper wrap:productListAdd){
                       if(wrap.Quantity==null || wrap.Quantity=='')
                       {
                            ApexPages.addMessages(new DealReg_EPP_Exception(System.Label.Orion_Quantity_required));
                            return null;
                       }
                   }
            //Added to check if Product's Quantity is required-End
            if(dealReg.Registration_Status__c==null){
                dealReg.Registration_Status__c = 'Draft';
            }
             //Added for Product Name to be shown on Deal by Archana- Start
             String temp ='';
                   for(prodwrapper wrap:productListAdd){
                      temp = temp+wrap.name+',';
                  }
                    temp= temp.substring(0,temp.length()-1);
                    if(temp!=null &&   temp!=''){
                        dealReg.All_Vmware_Products__c=temp;
                    }
                     //Added for Product Name to be shown on Deal by Archana- Start
                upsert dealReg;
                finaldealId = dealReg.Id;
                  List<Partner_Select_Product__c> pSPList = new List<Partner_Select_Product__c>();
                    List<Deal_Registration__c> dealList = new List<Deal_Registration__c>();
                 dealList.add(dealReg);
                    Map<Id, Deal_Registration__c> DealMap = new Map<Id, Deal_Registration__c>(dealList);
                
                if(deleteProduct!=null && deleteProduct.size()>0){
                    List<Partner_Select_Product__c> deleteProductList = new List<Partner_Select_Product__c>();
                      for(Id ProdId:deleteProduct){
                           deleteProductList.add(new Partner_Select_Product__c(Id =ProdId ));
                      }
                     delete deleteProductList;
                  }
                if(finaldealId!=null){
                  for(prodwrapper wrap:productListAdd){
                       if(wrap.productId==null){
                      pSPList.add(new Partner_Select_Product__c(Name = wrap.name,ORTN_Number__c =DealMap.get(finaldealId).Name,Quantity__c=Integer.valueOf(wrap.Quantity), Product__c = ProdNewMap.get(wrap.name).Id, Division__c=ProdNewMap.get(wrap.name).Division__c, Platform_Group__c=ProdNewMap.get(wrap.name).Platform_Group__c, Product_Group__c=ProdNewMap.get(wrap.name).Product_Group__c,Product_Name__c= ProdNewMap.get(wrap.name).Registration_Product_Name__c, Product_Platform__c=ProdNewMap.get(wrap.name).Product_Platform__c, Registration__c=finaldealId,Willing_to_Lead_Services_Flag__c=wrap.willingLeadServices));
                  }else{
                      if(wrap.Quantity!=null){
                      Partner_Select_Product__c psprecord = new Partner_Select_Product__c(Id=wrap.productId,Quantity__c=Integer.valueOf(wrap.Quantity),Willing_to_Lead_Services_Flag__c=wrap.willingLeadServices);
                      pSPList.add(psprecord);
                      }
                      
                      
                      
                  }
                  }
                  if(productListAdd!=null && !productListAdd.isEmpty()){
                  upsert pSPList;
                  }
                  }

                //Setting values to Submit request in Approval process
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(dealReg.Id);
                  
                // Submit the request for Approval
                // 18th March 2016 by Vijit Vijay - Added Manual Review check below for Orion Ph2.
               
                /*if(dealReg.Manual_Review__c == true){
                Orion_OppManagementSequenceController.updateDenialReasonOnDeal(dealReg.Id,dealDenailReason);
                Approval.ProcessResult result = Approval.process(req); //commented as part of Orion Phase 2                
                }else*/ if(dealReg.Previous_Registration__c != null){    //Added else-if by Vijit for ReRegister scenario for Sprint-3                    
                    List<Partner_Select_Product__c> reregisterPSPList = new List<Partner_Select_Product__c>();
                    reregisterPSPList = [select id from Partner_Select_Product__c where Registration__c =:dealReg.id];
                   
                    if(!reregisterPSPList.isEmpty()){
                        Orion_OppManagementUtility.approveDealRegForReRegister(reregisterPSPList,dealReg.id);
                    }
                }else{                            //added line as part of Orion Phase 2 [Yoganand]
                    Orion_OppManagementSequenceController.searchEndCustomerAccount(dealReg.Id,contactAccount);
                }   
            }
            catch(Exception ex){
                
                //Displaying Error Message on page
                ApexPages.addMessages(ex);           
                return null;
            }       
            if(finaldealId!=null){
                retreiveDealRecords(finaldealId);
            }
             PageReference pageRefer = new PageReference('/apex/Orion_DealReg_OutputPage?Id='+finaldealId);
                          pageRefer.setRedirect(true);
        return pageRefer;
            /*
            PageReference dealPage = new ApexPages.StandardController(dealReg).view();
            dealPage.setRedirect(true);*/
            
          //  return dealPage;
        }
    }
    
      public Boolean validateListLicenseValue(String selectedProg){
        
        boolean returnVal = false;
        
        if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_GOVT.equalsIgnoreCase(selectedProg) && dealReg.VMware_List_License_Value__c < 10000){
            
            returnVal = true;           
        }
        //Changes made by Jaypal Singh for CR-00019601 Dated: 09/26/2012
        //Uma changes CR-00136738 11/4/2015
        //else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS.equalsIgnoreCase(selectedProg)  && dealReg.VMware_List_License_Value__c < 6000 && dealReg.VMware_Products__c != 'Airwatch'){
        
       //     returnVal = true;           
       // }
        else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA.equalsIgnoreCase(selectedProg) && dealReg.VMware_List_License_Value__c <= 10000){

            returnVal = true;                       
        }
        else if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(selectedProg) && dealReg.VMware_List_License_Value__c <= 10000){
                
            returnVal = true;           
        }
        return returnVal;
    }

    public PageReference registerLeadToDeal(){

        Id LeadId=(System.currentPageReference().getParameters().get('leadid'));

        LeadToDealRegistration(LeadId);

        PageReference pageRefer = new PageReference('/apex/Orion_DealReg_FullRegPage?programType=na');
        return pageRefer;
    }
    
    public PageReference saveLeadToDeal(){
  

    Id LeadId=(System.currentPageReference().getParameters().get('leadid'));

    //LeadToDealRegistration(LeadId);

    //LeadConvert(LeadId);
        
    List<Attachment> tempAttachmentList = [Select Id,Name,Body,ContentType From Attachment WHERE ParentId = :leadid];

        List<Event> tempEventList = [Select e.WhoId, e.WhatId, e.SystemModstamp, e.Subject, e.StartDateTime, e.ShowAs, e.ReminderDateTime, e.RecurrenceType, e.RecurrenceTimeZoneSidKey, e.RecurrenceStartDateTime, e.RecurrenceMonthOfYear, e.RecurrenceInterval, e.RecurrenceInstance, e.RecurrenceEndDateOnly, e.RecurrenceDayOfWeekMask, e.RecurrenceDayOfMonth, e.RecurrenceActivityId, e.PRC_Activity_Type__c, e.PRC_Activity_Category__c, e.OwnerId, e.Outbound__c, e.Location, e.LastModifiedDate, e.LastModifiedById, e.IsReminderSet, e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.IsDeleted, e.IsChild, e.IsArchived, e.IsAllDayEvent, e.Inbound__c, e.Id, e.EndDateTime, e.DurationInMinutes, e.Description, e.CurrencyIsoCode, e.CreatedDate, e.CreatedById, e.ActivityDateTime, e.ActivityDate, e.AccountId From Event e where e.WhoId=:leadID];
        
        List<Task> tempTaskList = [Select t.WhoId, t.WhatId, t.SystemModstamp, t.Subject, t.Status, t.ReminderDateTime, t.Priority, t.PRC_Activity_Type__c, t.PRC_Activity_Category__c, t.OwnerId, t.Outbound__c, t.LastModifiedDate, t.LastModifiedById, t.IsReminderSet, t.IsDeleted, t.IsClosed, t.IsArchived, t.Inbound__c, t.Id, t.Description, t.CurrencyIsoCode, t.CreatedDate, t.CreatedById, t.ConnectionSentId, t.ConnectionReceivedId, t.CallType, t.CallObject, t.CallDurationInSeconds, t.CallDisposition, t.ActivityDate, t.AccountId From Task t where t.WhoId=:leadID];
        //Added fields in below Query as part of Renaisance Phase 2
        //Modified by manu-CR-00134260-XFire-Start
        /*
        Lead tempLead = [select Primary_Product_Group_Interest__c,Product_Group_Interest__c,OwnerId,of_Servers__c,of_Desktops__c,Virtualization_Project__c,Territory__c,Sub_Region__c,Storage_Used__c,State_Province__c,Siebel_Account_ID__c,Screening_Status__c,Screening_Results__c,LDR__c,Refresh_Server__c,Refresh_Desktop__c,Preferred_Reseller__c,Preferred_HW_Vendor__c,Postal_Code__c,Partner_Account__c,Original_Marketing_Source__c,Original_Lead_Source__c,lead_ID__c,Last_Campaign_Response__c,Job_Role__c,GULT__c,GEO__c,Department__c,Decision_Making_Role__c,DUNS__c,Country__c,City__c,Campaign__c,Campaign_Id__c,Budgeted_Project_Within_3_Months__c,Address_2__c,Address_1__c,Relationship_With_VMware__c,Region__c,Employees_in_Country__c,Employees_Worldwide__c,Contact_me__c,State,Street,Rating,PostalCode,Phone,LeadSource,LastName,FirstName,Email,Company,Website,Title,Description,DULT__c,Industry,Products__c,Respondent_s_Comments__c,Pass_to_Sales_Date__c from Lead WHERE Id = :leadID];
        */
        String Query='select Primary_Product_Group_Interest__c,Product_Group_Interest__c,OwnerId,of_Servers__c,of_Desktops__c,Virtualization_Project__c,Territory__c,Sub_Region__c,Storage_Used__c,State_Province__c,Siebel_Account_ID__c,Screening_Status__c,Screening_Results__c,LDR__c,Refresh_Server__c,Refresh_Desktop__c,Preferred_Reseller__c,Preferred_HW_Vendor__c,Postal_Code__c,Partner_Account__c,Original_Marketing_Source__c,Original_Lead_Source__c,lead_ID__c,Last_Campaign_Response__c,Job_Role__c,GULT__c,GEO__c,Department__c,Decision_Making_Role__c,DUNS__c,Country__c,City__c,Campaign__c,Campaign_Id__c,Budgeted_Project_Within_3_Months__c,Address_2__c,Address_1__c,Relationship_With_VMware__c,Region__c,Employees_in_Country__c,Employees_Worldwide__c,Contact_me__c,State,Street,Rating,PostalCode,Phone,LeadSource,LastName,FirstName,Email,Company,Website,Title,Description,DULT__c,Industry,Products__c,Respondent_s_Comments__c,Pass_to_Sales_Date__c,recordtypeid';
        //Id xSellUpSellRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(LEAD_XSELL_RECORDTYPE).getRecordTypeId(); 
        Id xSellUpSellRecordTypeId=(Record_Type_Settings__c.getInstance('Lead_XSUS')!=null && Record_Type_Settings__c.getInstance('Lead_XSUS').Record_Type_ID__c!=null) ? Record_Type_Settings__c.getInstance('Lead_XSUS').Record_Type_ID__c:Lead.sObjectType.getDescribe().getRecordTypeInfosByName().get(LEAD_XSELL_RECORDTYPE).getRecordTypeId();
        //List<XFIRE_Enrichment_Field_Mapping__c> leadOppRegFieldMapping=new List<XFIRE_Enrichment_Field_Mapping__c>();
        //leadOppRegFieldMapping=[Select Source_API_Name__c,Source_Object_API_Name__c,Target_API_Name__c from XFIRE_Enrichment_Field_Mapping__c where Source_Object_API_Name__c='Lead' and IsActive__c=true and Target_API_Name__c='Deal_Registration__c'];
                   /*for(XFIRE_Enrichment_Field_Mapping__c obj:leadOppRegFieldMapping)
                   {
                        if(!Query.containsIgnoreCase(obj.Source_API_Name__c))
                        {
                            Query+=','+obj.Source_API_Name__c;
                        }
                   } */
                   List<String> QueryFieldsList=Query.Split(',');
                   for(XFIRE_Enrichment_Field_Mapping__c obj: XFIRE_Enrichment_Field_Mapping__c.getAll().values())
                   {
                        //add to query only the Opportunity object fields
                        if(obj!=null && obj.IsActive__c && obj.IsActive__c && obj.Source_Object_API_Name__c!=null && obj.Source_Object_API_Name__c.equalsIgnoreCase(LEADOBJECTNAME) && obj.Target_Object_API_Name__c!=null && obj.Target_Object_API_Name__c.containsIgnoreCase(DEALREGOBJECTNAME))
                        {
                              //if(!Query.containsIgnoreCase(obj.Source_API_Name__c))
                              Boolean dupFlag=false;
                              for(String str:QueryFieldsList)
                              {
                                if(str.equalsignorecase(obj.Source_API_Name__c))
                                {
                                    dupFlag=true;
                                    break;
                                }
                              }
                              if(!dupFlag)
                              {
                                    Query+=','+obj.Source_API_Name__c;
                              }
                        }
                    }
        Query+=' from Lead WHERE Id = \''+leadID+'\'';
        Lead tempLead=Database.Query(Query);
            if(tempLead.recordtypeid==xSellUpSellRecordTypeId)
                {
                   /*for(XFIRE_Enrichment_Field_Mapping__c obj:leadOppRegFieldMapping)
                   {
                        if(tempLead.get(obj.Source_API_Name__c) == false || tempLead.get(obj.Source_API_Name__c) == true )
                        {
                            tmpDealReg.put((obj.Target_API_Name__c),(Boolean)tempLead.get(obj.Source_API_Name__c));
                        }
                        else
                        {
                            tmpDealReg.put((obj.Target_API_Name__c),tempLead.get(obj.Source_API_Name__c));
                        }
                   } */
                    for(XFIRE_Enrichment_Field_Mapping__c obj: XFIRE_Enrichment_Field_Mapping__c.getAll().values())
                    {
                        //add to query only the Opportunity object fields
                        if(obj!=null && obj.IsActive__c && obj.IsActive__c && obj.Source_Object_API_Name__c!=null && obj.Source_Object_API_Name__c.equalsIgnoreCase(LEADOBJECTNAME) && obj.Target_Object_API_Name__c!=null && obj.Target_Object_API_Name__c.containsIgnoreCase(DEALREGOBJECTNAME))
                        {
                             if(tempLead.get(obj.Source_API_Name__c) == false || tempLead.get(obj.Source_API_Name__c) == true )
                             {
                                    tmpDealReg.put((obj.Target_API_Name__c),(Boolean)tempLead.get(obj.Source_API_Name__c));
                             }
                            else
                            {
                                tmpDealReg.put((obj.Target_API_Name__c),tempLead.get(obj.Source_API_Name__c));
                            }  
                        }                       
                    }
                }
        //Modified by manu-CR-00134260-XFire-End
        //tempLead.Status = '4 Partner Registered';
        List<Group> grup = [Select g.Type, g.SystemModstamp, g.RelatedId, g.OwnerId, g.Name, g.LastModifiedDate, g.LastModifiedById, g.Id, g.Email, g.DoesSendEmailToMembers, g.CreatedDate, g.CreatedById From Group g where g.Name like: 'Converted to Registration%'];
        
        if(grup.size()>0){
        tempLead.OwnerId = grup[0].Id;        }

      
        //tmpDealReg.Project_Name__c = tempLead.Company;
        tmpDealReg.CloseDate__c = Date.today();
        tmpDealReg.StageName__c = 'Prospecting';
                       
        tmpDealReg.RecordTypeId = recursive.DealRegBasicInfoOnlyRecType;
        //added null check as part of Renaisance phase 2
        if(tempLead != null){ 
        tmpDealReg.Screening_Pass_Date__c = tempLead.Pass_to_Sales_Date__c;
        //Fields mapping as part of Renaisance Phase 2 -start
        tmpDealReg.Product_Interest__c = tempLead.Products__c;
        tmpDealReg.Primary_Product_Group_Interest__c = tempLead.Primary_Product_Group_Interest__c; 
        tmpDealReg.Secondary_Product_Group_Interest__c = tempLead.Product_Group_Interest__c;
        }
        //Fields mapping as part of Renaisance Phase 2 -start
        try{
            insert tmpDealReg;
        }
        catch(Exception e){
            //Added Error handling code in catch block for CR-00008898
            
        //Added for PLM Phase-2:Displaying Error Message on page
            ApexPages.addMessages(e);
            CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Deal_Registration__c', 'DealReg_DealRegistration');
            // End of code for CR-00008898 
            return null;
            
        }

        List<Attachment> tempAttachOpptyList = new List<Attachment>(); 
        for(Integer i =0; i<tempAttachmentList.size();i++)
        {
            Attachment tempAttach = new Attachment(ParentId = tmpDealReg.Id);
            tempAttach.Body = tempAttachmentList[i].Body;
            tempAttach.ContentType = tempAttachmentList[i].ContentType;
            tempAttach.Name = tempAttachmentList[i].Name;
            tempAttachOpptyList.add(tempAttach);
        }
        
        List<Event> oppEventList = tempEventList.deepClone(false);
        for(Integer i =0; i<oppEventList.size();i++)
        {
            oppEventList[i].WhatId = tmpDealReg.Id;
            oppEventList[i].WhoId = null;                       
        }     
         
        try{            
                insert tempAttachOpptyList;
                insert oppEventList;              
                update tempLead;                
                update tmpDealReg;

          
        }
        catch(Exception e){
            //Added Error handling code in catch block for CR-00008898
            CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Deal_Registration__c', 'DealReg_DealRegistration');
            // End of code for CR-00008898 
        }
        
        PageReference dealPage = new ApexPages.StandardController(tmpDealReg).view();
        dealPage.setRedirect(true);
        return dealPage;
    }


     public void LeadToDealRegistration(Id leadid){
        //Intializing lead fields and oppty fiels into a map.
        String lead_fields = 'of_Servers__c,of_Desktops__c,Virtualization_Project__c,Territory__c,Sub_Region__c,Storage_Used__c,State_Province__c,Siebel_Account_ID__c,Screening_Status__c,Screening_Results__c,LDR__c,Refresh_Server__c,Refresh_Desktop__c,Preferred_Reseller__c,Preferred_HW_Vendor__c,Postal_Code__c,Partner_Account__c,Original_Marketing_Source__c,Original_Lead_Source__c,lead_ID__c,Last_Campaign_Response__c,Job_Role__c,GULT__c,GEO__c,Department__c,Decision_Making_Role__c,DUNS__c,Country__c,City__c,Campaign__c,Campaign_Id__c,Budgeted_Project_Within_3_Months__c,Address_2__c,Address_1__c,Relationship_With_VMware__c,Region__c,Employees_in_Country__c,Employees_Worldwide__c,Contact_me__c,Rating,Phone,LeadSource,LastName,FirstName,Email,Company,Website,Title,Description,DULT__c,Industry,Products__c,id,Respondent_s_Comments__c,Channel_Overlay_Territory__c,Global_overlay_territory__c,Primary_Channel_Sales_Territory__c,Primary_Field_Sales_Territory__c';
        //Added by Manu for-CR-00134260-Xfire-Start
        //List<XFIRE_Enrichment_Field_Mapping__c> leadOppRegFieldMapping=new List<XFIRE_Enrichment_Field_Mapping__c>();
        //leadOppRegFieldMapping=[Select Source_API_Name__c,Source_Object_API_Name__c,Target_API_Name__c from XFIRE_Enrichment_Field_Mapping__c where Source_Object_API_Name__c='Lead' and IsActive__c=true and Target_API_Name__c='Deal_Registration__c'];

        List<String> QueryFieldsList=lead_fields.Split(',');
        for(XFIRE_Enrichment_Field_Mapping__c obj: XFIRE_Enrichment_Field_Mapping__c.getAll().values()){
                    //add to query only the Opportunity object fields
                        if(obj!=null && obj.IsActive__c && obj.IsActive__c && obj.Source_Object_API_Name__c!=null && obj.Source_Object_API_Name__c.equalsIgnoreCase(LEADOBJECTNAME) && obj.Target_Object_API_Name__c!=null && obj.Target_Object_API_Name__c.containsIgnoreCase(DEALREGOBJECTNAME))
                        {
                              Boolean dupFlag=false;
                              for(String str:QueryFieldsList)
                              {
                                if(str.equalsignorecase(obj.Source_API_Name__c))
                                {
                                    dupFlag=true;
                                    break;
                                }
                              }
                              //if(!lead_fields.contains(obj.Source_API_Name__c))
                              if(!dupFlag)
                              {
                                lead_fields+=','+obj.Source_API_Name__c;
                              }
                        }
                    } 
        /*for(XFIRE_Enrichment_Field_Mapping__c obj:leadOppRegFieldMapping)
        {
             if(!lead_fields.contains(obj.Source_API_Name__c))
             {
                 lead_fields+=','+obj.Source_API_Name__c;
             }
        }*/
        //Added by Manu for-CR-00134260-Xfire-Ends
        String lead_fields1 ='Company,Pass_to_Sales_Date__c';

        Leadfields = lead_fields.split(',');
        Leadfields1 = lead_fields1.split(',');

        //Commented and Added By Bhawani - CR-00024618
        //String lead_opty_map = 'of_Servers__c-of_Servers__c,of_Desktops__c-of_Desktops__c,Virtualization_Project__c-Virtualization_Project__c,Territory__c-VMware_Territory__c,Sub_Region__c-Subregion__c,Storage_Used__c-Storage_Used__c,State_Province__c-State_Province__c,Screening_Status__c-Screening_Status__c,Screening_Results__c-Screening_Results__c,LDR__c-Screened_By__c,Refresh_Server__c-Refresh_Server__c,Refresh_Desktop__c-Refresh_Desktop__c,Preferred_Reseller__c-Preferred_Reseller__c,Preferred_HW_Vendor__c-Preferred_Server_Vendor__c,Postal_Code__c-Zip_Postal_Code__c,Partner_Account__c-Active_Partner_Account__c,Original_Marketing_Source__c-Original_Marketing_Source__c,Original_Lead_Source__c-Original_Lead_Source__c,lead_ID__c-Lead_ID__c,Last_Campaign_Response__c-Last_Campaign_Response__c,Job_Role__c-Job_Role__c,GULT__c-GULT__c,GEO__c-GEO__c,Department__c-Department__c,Decision_Making_Role__c-Decision_Maker__c,DUNS__c-DUNS__c,Country__c-Country__c,City__c-City__c,Campaign__c-Campaign_Name__c,Campaign_Id__c-Campaign_ID__c,Budgeted_Project_Within_3_Months__c-Budgeted_Project_Within_3_Months__c,Address_2__c-Address_2__c,Address_1__c-Address_1__c,Relationship_With_VMware__c-Relationship_With_VMware__c,Region__c-Region__c,Employees_in_Country__c-of_Employees_in_Country__c,Employees_Worldwide__c-of_Employees_Worldwide__c,Contact_me__c-Contact_Me__c,Rating-Rating__c,Phone-Phone__c,MobilePhone-Mobile__c,LeadSource-LeadSource__c,LastName-Last_Name__c,FirstName-First_Name__c,Email-Email__c,Company-Company__c,Website-Website__c,Title-Title__c,Description-Description__c,DULT__c-DULT__c,Industry-Industry__c,Products__c-VMware_Products__c,Respondent_s_Comments__c-Respondent_s_Comments__c,id-Lead_Record_s_SFDC_ID__c,        Channel_Overlay_Territory__c-Channel_Overlay_Territory_Lookup__c,Primary_Channel_Sales_Territory__c-Primary_Channel_Sales_Territory_Lookup__c,Primary_Field_Sales_Territory__c-Primary_Field_Sales_Territory_Lookup__c';
        String lead_opty_map = 'of_Servers__c-of_Servers__c,of_Desktops__c-of_Desktops__c,Virtualization_Project__c-Virtualization_Project__c,Territory__c-VMware_Territory__c,Sub_Region__c-Subregion__c,Storage_Used__c-Storage_Used__c,State_Province__c-State_Province__c,Screening_Status__c-Screening_Status__c,Screening_Results__c-Screening_Results__c,LDR__c-Screened_By__c,Refresh_Server__c-Refresh_Server__c,Refresh_Desktop__c-Refresh_Desktop__c,Preferred_Reseller__c-Preferred_Reseller__c,Preferred_HW_Vendor__c-Preferred_Server_Vendor__c,Postal_Code__c-Zip_Postal_Code__c,Partner_Account__c-Active_Partner_Account__c,Original_Marketing_Source__c-Original_Marketing_Source__c,Original_Lead_Source__c-Original_Lead_Source__c,lead_ID__c-Lead_ID__c,Last_Campaign_Response__c-Last_Campaign_Response__c,Job_Role__c-Job_Role__c,GULT__c-GULT__c,GEO__c-GEO__c,Department__c-Department__c,Decision_Making_Role__c-Decision_Maker__c,DUNS__c-DUNS__c,Country__c-Country__c,City__c-City__c,Campaign__c-Lead_Campaign_Name__c,Campaign_Id__c-Campaign_ID__c,Budgeted_Project_Within_3_Months__c-Budgeted_Project_Within_3_Months__c,Address_2__c-Address_2__c,Address_1__c-Address_1__c,Relationship_With_VMware__c-Relationship_With_VMware__c,Region__c-Region__c,Employees_in_Country__c-of_Employees_in_Country__c,Employees_Worldwide__c-of_Employees_Worldwide__c,Contact_me__c-Contact_Me__c,Rating-Rating__c,Phone-Phone__c,MobilePhone-Mobile__c,LeadSource-LeadSource__c,LastName-Last_Name__c,FirstName-First_Name__c,Email-Email__c,Company-Company__c,Website-Website__c,Title-Title__c,Description-Description__c,DULT__c-DULT__c,Industry-Industry__c,Products__c-VMware_Products__c,Respondent_s_Comments__c-Respondent_s_Comments__c,id-Lead_Record_s_SFDC_ID__c,        Channel_Overlay_Territory__c-Channel_Overlay_Territory_Lookup__c,Primary_Channel_Sales_Territory__c-Primary_Channel_Sales_Territory_Lookup__c,Primary_Field_Sales_Territory__c-Primary_Field_Sales_Territory_Lookup__c';

        String lead_opty_map1 ='Company-Project_Name__c';

        List<String> lead_opty_map_fields = lead_opty_map.split(',');
        List<String> lead_opty_map_fields1 = lead_opty_map1.split(',');
        for(Integer i =0 ;i<lead_opty_map_fields.size();i++)
        {
            List <String> tempdata = lead_opty_map_fields.get(i).split('-');
            lead_And_Oppty_Fields.put(tempdata[0],tempdata[1]);
            
        }
        for(Integer j =0 ;j<lead_opty_map_fields1.size();j++)
        {
            List <String> tempdata1 = lead_opty_map_fields1.get(j).split('-');
            lead_And_Oppty_Fields1.put(tempdata1[0],tempdata1[1]);
            
        }
        //Added by Manu for-CR-00134260-XFire-Start
        /*for(XFIRE_Enrichment_Field_Mapping__c obj:leadOppRegFieldMapping)
        {
             if(lead_And_Oppty_Fields!=null && lead_And_Oppty_Fields.get(obj.Source_API_Name__c)==null)
             {
                 lead_And_Oppty_Fields.put(obj.Source_API_Name__c,obj.Target_API_Name__c);
             }
        }*/
        for(XFIRE_Enrichment_Field_Mapping__c obj: XFIRE_Enrichment_Field_Mapping__c.getAll().values()){
                    //add to query only the Opportunity object fields
                        if(obj!=null && obj.IsActive__c && obj.IsActive__c && obj.Source_Object_API_Name__c!=null && obj.Source_Object_API_Name__c.equalsIgnoreCase(LEADOBJECTNAME) && obj.Target_Object_API_Name__c!=null && obj.Target_Object_API_Name__c.containsIgnoreCase(DEALREGOBJECTNAME))
                        {
                              if(lead_And_Oppty_Fields!=null && lead_And_Oppty_Fields.get(obj.Source_API_Name__c)==null)
                              {
                                    lead_And_Oppty_Fields.put(obj.Source_API_Name__c,obj.Target_API_Name__c);
                              }
                        }
                    } 
        //Added by Manu for-CR-00134260-XFire-End
        leadID = System.currentPageReference().getParameters().get('leadid');
        //this.leadID = leadid;
        System.currentPageReference().getParameters().put('leadID',leadID);
        //tmpDealReg.Project_Name__c = tempLead.Company;
    }

    
     public PageReference cancelNavToOppReg(){

         Boolean leadToDealFlag = getLeadToDealConvert();
         If(leadToDealFlag){
                
                LeadId=(System.currentPageReference().getParameters().get('leadid'));
                PageReference leadPage=new PageReference('/'+LeadId);
                leadPage.setRedirect(true);
                return leadPage;

         }else{
            String oppRegUrl='';
            Boolean basicAccessFlag = isEligibleForBasicSubmission();

            String dealId = ApexPages.currentPage().getParameters().get('Id');

            if(dealId != null || dealReg.Id!=null/*&& (isEdit || (progType != null && progType == 'na'))*/){
                
                oppRegUrl='/apex/Orion_DealReg_OutputPage?Id='+ dealId;
            }
            else if(basicAccessFlag){
                   
                //oppRegUrl='/apex/page?name=DealRegBasic&sfdc.tabName='; 
                oppRegUrl = dealregBasicURL1; // Changes to fix Prod Issue - 12/08/2016 - Vijit
                    
            }else{             
                   
                //oppRegUrl='/apex/page?name=DealReg&sfdc.tabName=';
                oppRegUrl = dealregBasicURL1; // Changes to fix Prod Issue - 12/08/2016 - Vijit
            }
            
            PageReference oppRegPage=new PageReference(oppRegUrl);
            oppRegPage.setRedirect(true);
            return oppRegPage;
         }
     }

    
    public static Boolean isEligibleForBasicSubmission() {     

        User usr = [select id, contactid, Contact.AccountId from user where id=:UserInfo.getUserId()];
        Id acctId = usr.Contact.AccountId;
        List<String> lpNameList = new List<String>();
        List<Account> accIdList = [Select Id, Name, Override_Basic_Access__c from Account where Id =: acctId and Override_Basic_Access__c=False];

        Map<String, Landing_Page_Widget_Details__c> LandingPageVal = Landing_Page_Widget_Details__c.getAll();
        for(Landing_Page_Widget_Details__c getLandingPage: LandingPageVal.values()){
            
            if(getLandingPage.Name == 'Basic Registration-New DealReg'){
                lpNameList.add(getLandingPage.Landing_Page_Widget_Name__c);
            }       
        }  


          // get ids for groups in Basic Reg widgets 
          List<Landing_Page_Widget__Share> groupsList = new List<Landing_Page_Widget__Share>
                                  ([Select l.Id, l.UserOrGroupId 
                                    From   Landing_Page_Widget__Share l 
                                    where l.Parent.Name IN :lpNameList]);
                        
      List<String> groupIds = new List<ID>();
      for (Landing_Page_Widget__Share lpws : groupsList) {
        
        groupIds.add(lpws.UserOrGroupId);
      }
      
      // does this user belong to any of these groups?
      List<GroupMember> grpMembers = [Select g.UserOrGroupId, g.SystemModstamp, g.Id, g.GroupId 
                                      From   GroupMember g 
                                      where  g.UserOrGroupId =: UserInfo.getUserId() and g.GroupId IN :groupIds];
      
    
      if (grpMembers.size() > 0 && accIdList.size()>0) // yes, at least one
        return true;
      else
        return false; // no, none
    }  
    
//Added to check the Double byte character - L10N Porject - Accenture
    public static final String ERROR_ENTER_NONENGLISH_CHARACTER = System.Label.L10N_DealReg_English_Value_Error_msg;

    public static boolean checkDealForm(Deal_Registration__c deal){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Deal_Registration__c');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        if(deal.Company__c != null && deal.Company__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Company__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Company__c').getDescribe().getLabel() + ': ' +ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
       /* if(deal.First_Name__c != null && deal.First_Name__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.First_Name__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('First_Name__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Last_Name__c != null && deal.Last_Name__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Last_Name__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Last_Name__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }*/
        if(deal.Address_1__c != null && deal.Address_1__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Address_1__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Address_1__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Address_2__c != null && deal.Address_2__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Address_2__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Address_2__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Address_3__c != null && deal.Address_3__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Address_3__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Address_3__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Address_4__c != null && deal.Address_4__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Address_4__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Address_4__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.City__c != null && deal.City__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.City__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('City__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Project_Name__c != null && deal.Project_Name__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Project_Name__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Project_Name__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Email__c != null && deal.Email__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Email__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Email__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Phone__c != null && deal.Phone__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Phone__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Phone__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        if(deal.Zip_Postal_Code__c != null && deal.Zip_Postal_Code__c != '' && Pattern.matches( '[\\x00-\\x7f]*',deal.Zip_Postal_Code__c) == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fieldMap.get('Zip_Postal_Code__c').getDescribe().getLabel() + ': ' + ERROR_ENTER_NONENGLISH_CHARACTER)); 
            return false;
        }
        
    return true;
    }

    public static String PrimaryContactName(Id ContId){
    List<User> Users = New List<User>();
        Users = [Select Id,FirstName,LastName from User where ContactId=:ContId];
    if(Users != null && Users.Size() > 0){
            return Users[0].FirstName +Users[0].LastName;
            }
            else{
            return null;
            }
            return null;
        
    }
   //Changes made for CR-00020258 : Dated 10/27/2012 Jaypal Singh
    public Deal_Registration__c nullifyNewDealRegFields(Deal_Registration__c newDealReg) {
        newDealReg.Audit_Failed_Reason__c = null;
        newDealReg.Audit_Failed_Code__c = null;
        newDealReg.Approver3__c = null;
        newDealReg.Approver2__c = null;
        newDealReg.Approver1__c = null;
        newDealReg.Approved_Date__c = null;
        newDealReg.Approval_Date_2__c = null;
        newDealReg.Approval_Date_1__c = null;
        newDealReg.Booking_Date__c = null;
        newDealReg.CCI_Integration_Status__c = null;
        newDealReg.Final_Approver__c = null;
        newDealReg.GSI_Influence_Status__c = null;
        newDealReg.Influence_Reviewer__c = null;
        newDealReg.Incentive_Program__c = null;
        newDealReg.ISR_Approver__c = null;
        newDealReg.New_Account_Status__c = null;
        newDealReg.Order_Number__c = null;
        newDealReg.Registration_Date__c = null;
        newDealReg.Rebate_Payment_Status__c = null;
        newDealReg.RebatePayment__c = null;
        newDealReg.Reason_for_Reject__c = null;
        newDealReg.Reason_Audit_Failed__c = null;
        newDealReg.Reason_Account_Denied__c = null;
        newDealReg.Review_Status__c = null;
        newDealReg.New_Account__c=null;
        Set<String> prjtFocus=new Set<String>();
        prjtFocus.add('Business Continuity');
        prjtFocus.add('Desktop Management');
        prjtFocus.add('Other');
        prjtFocus.add('Server Consolidation');
        prjtFocus.add('Software Lifecycle Management');
        if(!prjtFocus.contains(newDealReg.Project_Focus__c)) {
            newDealReg.Project_Focus__c=null; 
        }
        return newDealReg;
    }
    
     public Deal_Registration__c nullifyFieldsProgramChange(Deal_Registration__c newDealReg){
        
        if(!DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(newDealReg.Program_Type__c)){
            
            newDealReg.Initial_EPP_Order_Number__c = null;
        }

        if(DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_EPP.equalsIgnoreCase(newDealReg.Program_Type__c)){
            
            newDealReg.StageName__c = null;
            newDealReg.CloseDate__c = null;
            newDealReg.Sns_Term__c = null;
            newDealReg.SnS_Type__c = null;
        }

        if(!DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ELA.equalsIgnoreCase(newDealReg.Program_Type__c)){
            
            newDealReg.Final_Approver_Title__c = null;
            newDealReg.Final_Approver_in_Customer_Organization__c = null;
            newDealReg.Customer_Decision_Maker__c = null;
            newDealReg.Customer_Decision_Maker_Title__c = null;
        }
        
        if(!DealRegEPP_Constants.Deal_PickList.PROGRAM_TYPE_ADPLUS.equalsIgnoreCase(newDealReg.Program_Type__c)){
            
            // Commented this line for CR-00122078 by sandip
            //newDealReg.Preferred_Channel__c = null;
        }

        return newDealReg;
    }

    public Deal_Registration__c updateOldDealRegFields ( Deal_Registration__c oldDealReg ) {
        //Modified ase part of CR-00022627.
        oldDealReg.Registration_Status__c = 'Re-Registered';
        oldDealReg.Reregistered_Date__c = Date.today();
        return oldDealReg;
    }
    
    public void changePreDist(){
    // Added below by Manik CR-00121519 
     dealReg.Preferred_Channel__c=ApexPages.CurrentPage().getParameters().get('distributorvalue');
     dealCountry = Apexpages.currentPage().getParameters().get('registrationCountry1');
  // CR-00120809 - Changed Preferred_Channel__c = 'VMware' to Preferred_Channel__c = 'VMware Distributor' - Swati
    if(dealReg.Preferred_Channel__c == 'VMware Distributor'){
        // Added below by Manik CR-00121519 
        PerfDistiCustomBool=false;
     // changes started  by sandip  for CR-00122078 
           // populatePreferredDist();
           getPrefDistItems();   //added by Vijit for Orion Phase2
      // changes end  by sandip  for CR-00122078    
            preDistBool = false;
        }else{
     // changes started  by sandip  for CR-00122078 
            PrefDistItems.clear();
            PrefDistItems.add(new SelectOption('','--None--'));
            dealReg.Preferred_Distributor__c = '';
      // changes end  by sandip  for CR-00122078   
            preDistBool = true; 
       // Added below by Manik CR-00121519 
           PerfDistiCustomBool=true;
          distributer='';     
        } 
    }    
     public void changePreDistributor(){
        if (programType == 'ELA'){
            preDistBool = false; 
        }else{
            preDistBool = true;
        } 
    }
    // Added below by Manik CR-00121519 
    public void assignMarketSegment()
    {
        marketSegement=ApexPages.CurrentPage().getParameters().get('marketsegement1');
    }
        
    // changes started  by sandip  for CR-00122078 
    public void populatePreferredDist(){
        //PrefDistItems = new List<SelectOption>();
       //Added as a part of L10N - CR-00013048    
       User loggedinUser = [Select Id, ContactId, contact.Language_Preference__c, contact.Prefered_Language_Formula__c, contact.Account.Geo__c,contact.Account.Sub_Region__c from User where Id =: UserInfo.getUserId()];
       
       if(loggedinUser.ContactId != NULL){
            userPreferredLanguage = loggedinUser.contact.Prefered_Language_Formula__c;
       }
       preDistBool = true;
       //PrefDistItems.add(new SelectOption('','--None--'));
       List<Geo_Preferred_Distributor_Mapping__c> geoPrefDist = Geo_Preferred_Distributor_Mapping__c.getall().values();
       list<string> geoPrefTempList = new List<string>();
       map<String,String> mapPrfList = new map<String,String>();
        if(geoPrefDist != null && !geoPrefDist.isEmpty()){
            //geoPrefList.sort();
            //Added by safiya for the CR-00110180
            for(Geo_Preferred_Distributor_Mapping__c geoPer: geoPrefDist){
                if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Sub_Region__c != Null && loggedinUser.Contact.Account.Sub_Region__c == 'French Caribbean'){
                    if(userPreferredLanguage != null && userPreferredLanguage != '' && geoPer.Sub_Region__c != null && geoPer.Sub_Region__c == 'French Caribbean' && geoPer.Language__c != null && geoPer.Language__c != '' && userPreferredLanguage.trim().ToUpperCase() == geoPer.Language__c.trim().ToUpperCase() && geoPer.Value__c != Null && geoPer.Value__c != ''){
                        //PrefDistItems.add(new SelectOption(geoPer.Value__c,geoPer.Value__c));
                        geoPrefTempList.add(geoPer.Value__c);
                        mapPrfList.put(geoPer.Value__c,geoPer.Value__c);
                    }
                }else if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && geoPer.Geo__c == loggedinUser.Contact.Account.Geo__c && userPreferredLanguage == geoPer.Language__c && geoPer.Value__c != Null && geoPer.Value__c != '' && geoPer.Translated_Value__c != null ){ //&& geoPer.Value__c != '' && geoPer.Value__c != Null && str == geoPer.Value__c
                    //PrefDistItems.add(new SelectOption(geoPer.Translated_Value__c, geoPer.Value__c));
                    geoPrefTempList.add(geoPer.Value__c);
                    mapPrfList.put(geoPer.Value__c,geoPer.Translated_Value__c);
                }                   
            }
            if(!geoPrefTempList.isEmpty())
            geoPrefTempList.sort();
            for(String strVal : geoPrefTempList){
                if(strVal  != '' && mapPrfList != null && mapPrfList.get(strVal) != null && mapPrfList.get(strVal) != ''){
                   // PrefDistItems.add(new SelectOption(mapPrfList.get(strVal),strVal));
                }
            }
            //doSort(PrefDistItems, FieldToSort.Value);
            //Ended by safiya for the CR-00110180
           
    }
    }

    // changes end  by sandip  for CR-00122078  
  

  
 public List<SelectOption> getproductItems(){
  List<SelectOption> options = new List<SelectOption>();
   Schema.DescribeFieldResult primInvolvmnt = Deal_Registration__c.VMware_Products__c.getDescribe();
     for(Schema.Picklistentry picklistEntry : primInvolvmnt.getPicklistValues()) {
                    options.add(new Selectoption(pickListEntry.getLabel(),pickListEntry.getValue()));
            }
      
       
        return options;
 }
 public List<SelectOption> getSharedDataPrefDistiItems(){
      if(dealReg.Joint_Selling_Opt_in__c!=null){
            sharedDataPrefDisti = dealReg.Joint_Selling_Opt_in__c;
        }
        else{
            sharedDataPrefDisti = 'Yes';
        }
     
  List<SelectOption> options = new List<SelectOption>();
   Schema.DescribeFieldResult primInvolvmnt = Deal_Registration__c.Joint_Selling_Opt_in__c.getDescribe();
     for(Schema.Picklistentry picklistEntry : primInvolvmnt.getPicklistValues()) {
                    options.add(new Selectoption(pickListEntry.getLabel(),pickListEntry.getValue()));
            }
      
       
        return options;
 }
 
 
 public  PageReference addProduct(){
     
    String pname = ApexPages.currentPage().getParameters().get('pname');
    String pqty = ApexPages.currentPage().getParameters().get('pqty');
    String pleadser = ApexPages.currentPage().getParameters().get('prdleadser');    
    Index = Index + 1;
    if(productListAdd!= null){ 
        productListAdd.add(new prodwrapper(pname,pqty,false,false,false,null,Index,false,false,0,pleadser,allowLeadServicesProduct.get(pname))); 
            
    }
        readyforAppcheck = true;
    submitButtonRender = true;
    return null;
 }
 
 /* Prasad : 30-Apr-2016 - Added for updating product qty -Starts */
   public PageReference updateProductQuantity(){
        String prodIndex = ApexPages.currentPage().getParameters().get('pIndex');
        String prodQtyNew = ApexPages.currentPage().getParameters().get('pQtyNew');
        String dealRegRecId  = ApexPages.currentPage().getParameters().get('Id');
        String prodPicklistNew = ApexPages.currentPage().getParameters().get('ppicklistNew');
        Integer prodIndexNumeric = Integer.valueOf(prodIndex);
        Partner_Select_Product__c dealProductToUpdate ; //= new Partner_Select_Product__c();
        String PageNameVal = String.valueOf(ApexPages.currentPage().getURL());
        Id prodId; 
        Integer prodQtyOld; 
        
      //  if(PageNameVal.contains('FullRegPage')){
            if(dealRegRecId == null || dealRegRecId == '' ){        // && dealRegRecId.startsWith() --> all validations on this id 
                if(productListAdd!= null && productListAdd.size() >= prodIndexNumeric){
                    prodwrapper ptoupdate = productListAdd.get(prodIndexNumeric);
                    if(ptoupdate.Quantity != null && ptoupdate.Quantity != ''){
                        prodQtyOld = Integer.valueOf(ptoupdate.Quantity); 
                            ptoupdate.Quantity = prodQtyNew; 
                            ptoupdate.isEditMode = false; 
                            ptoupdate.willingLeadServices = prodPicklistNew;
                             productListAdd.remove(prodIndexNumeric);
                             if(productListAdd.size() > prodIndexNumeric){   
                                productListAdd.add(prodIndexNumeric,ptoupdate);       //Integer.valueOf(prodIndex),
                            }else{
                                productListAdd.add(ptoupdate);       //Integer.valueOf(prodIndex),
                            }
                        
                    }else{
                        ptoupdate.Quantity = prodQtyNew; 
                        ptoupdate.isEditMode = false; // Prasad : 14-May-2016 - Qty Bugs
                        ptoupdate.willingLeadServices = prodPicklistNew;
                        if(ptoupdate.productId != null){
                           
              if(prodQtyNew!=null && prodQtyNew!='' && prodQtyNew.isNumeric()){
                            dealProductToUpdate = new Partner_Select_Product__c(Id=ptoupdate.productId,Quantity__c=Integer.valueOf(prodQtyNew),Willing_to_Lead_Services_Flag__c = prodPicklistNew);
              }else{
                 dealProductToUpdate = new Partner_Select_Product__c(Id=ptoupdate.productId,Quantity__c=null,Willing_to_Lead_Services_Flag__c = prodPicklistNew);
              }
                            upsert dealProductToUpdate;
                        }else{
                            productListAdd.remove(prodIndexNumeric);
                            if(productListAdd.size() > prodIndexNumeric){   
                                productListAdd.add(prodIndexNumeric,ptoupdate);       //Integer.valueOf(prodIndex),
                            }else{
                                productListAdd.add(ptoupdate);       //Integer.valueOf(prodIndex),
                            }
                        }   
                    }
                }   
            }else{
                // this is already saved deal record - so update the qty
                if(productListAdd!= null && productListAdd.size() >= prodIndexNumeric){
        prodwrapper ptoupdate = productListAdd.get(prodIndexNumeric);
                    if(ptoupdate.Quantity != null && ptoupdate.Quantity != ''){
                        prodQtyOld = Integer.valueOf(ptoupdate.Quantity); 
                        ptoupdate.Quantity = prodQtyNew; 
                            ptoupdate.isEditMode = false;
                            ptoupdate.willingLeadServices = prodPicklistNew;
                             if(ptoupdate.productId != null){
                               
                if(prodQtyNew!=null && prodQtyNew!='' && prodQtyNew.isNumeric()){
                                dealProductToUpdate = new Partner_Select_Product__c(Id=ptoupdate.productId,Quantity__c=Integer.valueOf(prodQtyNew),Willing_to_Lead_Services_Flag__c = prodPicklistNew);
                }
                else{
                  dealProductToUpdate = new Partner_Select_Product__c(Id=ptoupdate.productId,Quantity__c=null,Willing_to_Lead_Services_Flag__c = prodPicklistNew);
                }
                                upsert dealProductToUpdate;
                            }else{
                                productListAdd.remove(prodIndexNumeric);

                            if(productListAdd.size() > prodIndexNumeric){   
                                productListAdd.add(prodIndexNumeric,ptoupdate);       //Integer.valueOf(prodIndex),
                            }else{
                                productListAdd.add(ptoupdate);       //Integer.valueOf(prodIndex),
                            }
                            }
                        
                    }else{      // Prasad : Added New Condition 
                        ptoupdate.Quantity = prodQtyNew; 
                        ptoupdate.isEditMode = false; // Prasad : 14-May-2016 - Qty Bugs
                        ptoupdate.willingLeadServices = prodPicklistNew;
                        if(ptoupdate.productId != null){
                         
              
              if(prodQtyNew!=null && prodQtyNew!='' && prodQtyNew.isNumeric()){
                dealProductToUpdate = new Partner_Select_Product__c(Id=ptoupdate.productId,Quantity__c=Integer.valueOf(prodQtyNew),Willing_to_Lead_Services_Flag__c = prodPicklistNew);
              }
              else{
                            dealProductToUpdate = new Partner_Select_Product__c(Id=ptoupdate.productId,Quantity__c=null,Willing_to_Lead_Services_Flag__c = prodPicklistNew);
              }
                            upsert dealProductToUpdate;
                        }else{
        productListAdd.remove(prodIndexNumeric);
           
        if(productListAdd.size() > prodIndexNumeric){   
            productListAdd.add(prodIndexNumeric,ptoupdate);       //Integer.valueOf(prodIndex),
        }else{
            productListAdd.add(ptoupdate);       //Integer.valueOf(prodIndex),
        }
                        }   
                    }
                }   
            }
            /*if(productListAdd!= null && productListAdd.size() >= prodIndexNumeric){
                prodwrapper ptoupdate = productListAdd.get(prodIndexNumeric);
                if(ppicklistNew!=null && ppicklistNew!='' && ptoupdate.willingLeadServices!=ppicklistNew){
                    ptoupdate.willingLeadServices = ppicklistNew;
                }
            }*/
            
       // }
        //productListAdd.sort();
        return null; 
    }
 
/* Prasad : 30-Apr-2016 - Added for updating product qty -Ends */
  
/* Prasad : 5-May-2016 - Added for RemoveLink Starts - */   
 public PageReference removeProductFromList(){
        // 1. If Product is already a RLI 
        //    a. If Product is approved - can't remove from the list - non case - as remove link wont be shown
        //    b. If Product is not approved - remove from the list 
        // 2. If Product is Not an RLI
        List<prodwrapper> lstProductWrapperTemp = new List<prodwrapper>();
        prodwrapper prodToRemove, prodTemp; 
        Partner_Select_Product__c prodToDelete; 
        Integer newIndex = 0;
        Integer removeIndexVal = Integer.valueOf(rowToRemove);
        prodToRemove = productListAdd.get(removeIndexVal);
        
        if(prodToRemove.productId != null){
            prodToDelete = new Partner_Select_Product__c(Id = prodToRemove.productId);
            productListAdd.remove(removeIndexVal);
            delete prodToDelete;    
        }else{
            productListAdd.remove(removeIndexVal);      
        }
        for(prodwrapper p : productListAdd){
            lstProductWrapperTemp.add(p);
        }
        productListAdd.clear();
        
        for(Integer i= 0; i<lstProductWrapperTemp.size(); i++){
            prodTemp = lstProductWrapperTemp.get(i);
            prodTemp.count = i; 
            productListAdd.add(prodTemp);
        }
                Boolean flag = false;
                for(prodwrapper prd:productListAdd){
                        if(prd.approved==false && prd.rejected==false){
                                flag = true;
                        }
                }
                readyforAppcheck = flag;
        if(productListAdd.size() == 0){
            Index = -1; 
        }else{
            Index = productListAdd.size() - 1;
        }
        return null; 
    }
 
  /* Prasad : 5-May-2016 - Added for RemoveLink - Ends */   

  
  /* Prasad : 14-May-2016 - Qty Edit Bugs - Starts */     
  public PageReference openProductInEditMode(){
    String prodIndex = ApexPages.currentPage().getParameters().get('prdIndex');
    Integer prodIndexNumeric = Integer.valueOf(prodIndex);
    Integer flag = 0; 
    
    for(prodWrapper p1 : productListAdd){
        if(p1.isEditMode) {
            flag = 1;
            break;
        }
    }
    if(flag==0){
        prodwrapper ptoupdate = productListAdd.get(prodIndexNumeric);
        ptoupdate.isEditMode = true;
    }
    return null;
  }
  /* Prasad : 14-May-2016 - Qty Edit Bugs - Ends */    
  
  public Class prodwrapper{
  public String name {get; set;} 
  public Boolean benefits{get; set;}
  public Boolean approved{get; set;}
  public Boolean LeadServices{get; set;}
   public String Quantity{get; set;}
   public Integer count {get; set;}
   public Id productId {get; set;}
   public Boolean rejected{get;set;}
   public Boolean isDuplicate{get;set;}  //Added by Vijit for Duplicate Product Highlight Defect Fix
   public Boolean isEditMode {get;set;} // Prasad : 14-May-2016 - For UAT bugs 

public Decimal discount {get;set;}
public String willingLeadServices {get; set;} //Added for SDD requirement
public Boolean availleadSer {get;set;}
   public prodwrapper(String n,String q,Boolean b,Boolean app,Boolean leadser,Id prodId,Integer c,Boolean r, Boolean editMode,Decimal d,String willingleadservice,Boolean a){
   name = n;
   Quantity = q;
   benefits=b;
   approved =app;
   LeadServices=leadser;
   productId =prodId;
   count =c;
   rejected = r;
   isDuplicate = false;   //Added by Vijit for Duplicate Product Highlight Defect Fix
   this.isEditMode = false;   
   discount = d;
   willingLeadServices = willingleadservice;
   availleadSer = a;
   }
  }
  public void removeRowFromList(){
      for(Integer i=0;i<productListAdd.size();i++){
          if(productListAdd[i].count == Integer.valueof(rowToRemove) ){
              if(productListAdd[i].productId!=null && ((productListAdd[i].approved == true && productListAdd[i].rejected == false)|| (productListAdd[i].approved == false && productListAdd[i].rejected == true))){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Orion_submited_product_not_delete)); 
                    
              }
              else if(productListAdd[i].productId!=null &&(productListAdd[i].approved == false && productListAdd[i].rejected == false)){
                  deleteProduct.add(productListAdd[i].productId);
                  productListAdd.remove(i);
                  break;
              }
              else{ productListAdd.remove(i);
                break;
                }
              }
         
          }
          Integer j=0;
          Integer prodInt = 0;
          for(prodwrapper prodwrec:productListAdd){
              if(prodwrec.ProductId==null){
                  prodInt=prodInt+1;
                 
              }
                  
          j++;
          prodwrec.count =j;
          }
           Index =j;
         if(prodInt>0){
               submitButtonRender = true;
          }
          else{
               submitButtonRender = false;
          }
          
         
          
 }
   public List<SelectOption> getdataItems() {
            List<SelectOption> options = new List<SelectOption>();
          
                Set<String> Platgrp = new Set<String>();
     ProductListItem = new  List<SelectOption>();
      for(Product2 prodec:[Select Id,Registration_Product_Name__c from Product2 where Registration_Product_Name__c!=null and isActive= true and Transfer_to_Opportunity__c=true order by Registration_Product_Name__c asc]){
          Platgrp.add(prodec.Registration_Product_Name__c);
      }
       options.add(new SelectOption('--None--','--None--'));
      for(String platgrprec: Platgrp){
           options.add(new SelectOption(platgrprec,platgrprec));
      }
            return options;
        }
         public List<SelectOption> getleadServicesItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Yes','Yes'));
             options.add(new SelectOption('No','No'));
            return options;
        }
     /* REQ-38/40/41 - 9th March 2016 by Vijit Vijay - Dynamically control Preferred Distributor picklist fields based on Country selected. START */ 
    public void selectedCountry()
    {
        countrySelected = Apexpages.currentPage().getParameters().get('registrationCountry');       
    }
    
    public void getPrefDistItems()
    {
        if(dealReg.id != null  && dealReg.Country__c != null && dealCountry != null &&  dealReg.Country__c != dealCountry){
            dealReg.Country__c = dealCountry;
        }else if(dealReg.id == null && dealCountry != null && dealReg.Country__c != dealCountry){
            dealReg.Country__c = dealCountry;
        }
        PrefDistItems = new List<SelectOption>();
        list<Account> accList= new list<Account>();
        if(dealReg.Country__c!=null && dealReg.Country__c != ''){
            accList = [select id, Name, Country__c, Preferred_Distributor__c, Geographies_you_sell_into__c from Account where Is_Distributor_Account__c = true AND Geographies_you_sell_into__c INCLUDES (:dealReg.Country__c) and Account_Status_Formula__c = 'Active' and RecordType.id = :partnerAccRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%')order by name asc];
        }
        if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Preferred_Distributor__c != null && loggedinUser.Contact.Account.Preferred_Distributor__c != ''){
            PrefDistItems.add(new SelectOption(loggedinUser.Contact.Account.Preferred_Distributor__c,loggedinUser.Contact.Account.Preferred_Distributor__c));
        }else{
            PrefDistItems.add(new SelectOption('','--None--'));
        }   
 
        if(!accList.isEmpty()){ 
            for(Account acc: accList){                
                PrefDistItems.add(new SelectOption(acc.name,acc.Name));
            } 
        }      
    } 
    /* REQ-38/40/41 - 9th March 2016 by Vijit Vijay - Dynamically control Preferred Distributor picklist fields based on Country selected. END */
    // Added by Vijit below to fire validation if Country mismatch of Preferred Distributor on Account and that with Registration. START
    public boolean prefDistributorCountryCheck(){                
        boolean var = false;
        list<Account> accList= new list<Account>();
       
        if(dealReg.Orion_Preferred_Disti_ID__c != null){
        accList = [select id, Name, Partner_ID__c, Country__c, Preferred_Distributor__c, Geographies_you_sell_into__c from Account where Partner_ID__c =:dealReg.Orion_Preferred_Disti_ID__c];
        }
        
        String countrymismatchError = System.Label.Orion_DistributorCountryCheck;
        
        if(!accList.isEmpty()){
            for(Account acc: accList){
                
                if(loggedinUser != null && loggedinUser.Contact != null && loggedinUser.Contact.Account != null && loggedinUser.Contact.Account.Preferred_Distributor__c != null && loggedinUser.Contact.Account.Preferred_Distributor__c != '' && acc.Geographies_you_sell_into__c!=null && acc.Geographies_you_sell_into__c!='' && !acc.Geographies_you_sell_into__c.containsIgnoreCase(dealReg.Country__c)){         
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, countrymismatchError));
                    var = true;
                }
            }
        }   
       return var;
    }
    // Added by Vijit below to fire validation if Country mismatch of Preferred Distributor on Account and that with Registration. END
    /* CR-00138214 - 11th March 2016 by Vijit Vijay - Auto populate Customer Info based on email entered. START */      
    public void contactInfoPopulated()
    {        
        // Added by HEM on 26th-Aug-2016 - CR-00140589 - START   
        List<String> excludePFSTList = new List<String>();
        excludePFSTList = Orion_Record__c.getInstance('PFSTNames')!=null && Orion_Record__c.getInstance('PFSTNames').value__c!=null?Orion_Record__c.getInstance('PFSTNames').value__c.split(';'):'Airwatch_temporary;Renewals_Temporary;VMware Consumer'.split(';');        
        Set<String> excludePFSTSet=new Set<String>(excludePFSTList);      
        // Added by HEM on 26th-Aug-2016 - CR-00140589 - END
        emailSelected = Apexpages.currentPage().getParameters().get('registrationEmail');
        address1Selected = Apexpages.currentPage().getParameters().get('registrationAddress1');
        address2Selected = Apexpages.currentPage().getParameters().get('registrationAddress2');
        address3Selected = Apexpages.currentPage().getParameters().get('registrationAddress3');
        address4Selected = Apexpages.currentPage().getParameters().get('registrationAddress4');
        citySelected = Apexpages.currentPage().getParameters().get('registrationCity');
        zipSelected = Apexpages.currentPage().getParameters().get('registrationZip');
        stateSelected = Apexpages.currentPage().getParameters().get('registrationState');
        
        if(emailSelected!=null && emailSelected != ''){            
            List<Contact> conList = new List<Contact>();
            // Added by HEM on 26th-Aug-2016 - Query modified- CR-00140589 - START  
            conList =[Select Id,Country__c, Account.Primary_Field_Sales_Territory__r.Name, FirstName, Lastname, Phone, Department__c, Job_Function__c, account.id, account.name, account.EA_Number__c, account.Geo__c, account.Domain_Name__c, Address_1__c, Address_2__c, Address_3__c, Address_4__c, City__c, State__c, Zip_Code__c, account.Customer_ID__c from Contact where Email=:emailSelected and RecordType.id = :conRecordTypeID and Active_Status__c = 'Active' and (NOT Contact.Account.Name Like '%Test%') and (NOT Contact.Account.Name Like '%Default Consumer Account%') and (NOT Contact.Account.Name Like '%VMware%') AND (NOT Account.Primary_Field_Sales_Territory__r.Name in : excludePFSTSet)];
            // Added by HEM on 26th-Aug-2016 - - Query modified - CR-00140589 - END 
            if(!conList.isEmpty()){
                for(Contact con : conList){
                    accIdSET.add(con.account.id);
                    contactId = con.Id;                    
                    contactCountry = con.Country__c;
                    contactState = con.State__c;
                    contactAccount = con.account.id;
                    contactAccountGeo = con.account.Geo__c;
                    contactCity = con.City__c;
                    contactZipCode = con.Zip_Code__c;
                    contactAccountName = con.account.name;
                    contactDomain = con.account.Domain_Name__c;
                    dealReg.Address_1__c = con.Address_1__c;
                    dealReg.Country__c = con.Country__c;
                    dealReg.Company__c = con.account.name;
                    /*Commented as a part of CR-00140707: Orion Phase2 - START
                    dealReg.Department__c = con.Department__c;
                    dealReg.Job_Role__c = con.Job_Function__c;
                    dealReg.EA_Number__c = con.account.EA_Number__c;                           
                    dealReg.First_Name__c = con.FirstName;
                    dealReg.Last_Name__c = con.Lastname;
                    dealReg.Phone__c = con.Phone;
                    Commented as a part of CR-00140707: Orion Phase2 - END */
                    dealReg.State_Province__c = con.State__c;
                    dealReg.Address_2__c = con.Address_2__c;
                    dealReg.City__c = con.City__c;
                    dealReg.Address_3__c = con.Address_3__c;
                    dealReg.Zip_Postal_Code__c = con.Zip_Code__c;
                    dealReg.Address_4__c = con.Address_4__c;
                    dealReg.Account_Customer_ID__c = con.account.Customer_ID__c;
                    dealReg.Account_Populated__c = contactAccount;
                    dealReg.Orion_Customer_Domain__c = con.account.Domain_Name__c;              
                }   
            }
         }else{
            dealReg.State_Province__c = '--None--';
          }
        
    }
    /* CR-00138214 - 11th March 2016 by Vijit Vijay - Auto populate Customer Info based on email entered. END */
    //Added as part of CR-00140795 on 19/Aug/2016 - Vijit - START
    public boolean checkMultiAcc()
    {   
        List<Contact> conList1 = new List<Contact>();
        boolean multiAccLocal = false;
        
        if(dealReg.Email__c != '' && dealReg.Email__c != null){
            conList1 =[Select Id, account.id from Contact where Email = :dealReg.Email__c];
        }
        
        if(!conList1.isEmpty()){
            for(Contact con : conList1){
            accIdSET.add(con.account.id);       
            }   
        }
        System.debug(logginglevel.error,'accIdSET.size()   = '+accIdSET.size());
        if(accIdSET.size() > 1){    
            multiAccLocal = true; 
            accIdSET.clear();           
            
                      
        }else{
            multiAccLocal = false;
            
        }
        return multiAccLocal;
    }
    //Added as part of CR-00140795 on 19/Aug/2016 - Vijit - END
     Public PageReference EditPage(){
            PageReference pageRef;
            String booleanWindow  = DealRegEPP_Utilities.validateEditAccess(UserInfo.getUserId(),dealReg.Id);
            if(booleanWindow  == 'yes'){
                if(dealReg.Form_Navigation__c  == 1){
                pageRef =new PageReference('/apex/Orion_DealReg_BasicRegPage?Id='+DealReg.Id);
                pageRef.setRedirect(true);
                }
                else {
                pageRef =new PageReference('/apex/Orion_DealReg_FullRegPage?Id='+DealReg.Id);
                pageRef.setRedirect(true);
                }

            }
            else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Orion_Access_to_Deal)); 
            pageRef= null;
            }
            
            return pageRef;
  
  
  }
   Public PageReference newRegistrations(){
       PageReference pageRef;
       Boolean booleanWindow  = DealRegEPP_Utilities.isEligibleForBasicSubmission(UserInfo.getUserId());
       boolean IsProfessionalPartner = DealRegEPP_Utilities.checkProfessionalPartner(UserInfo.getUserId());
     boolean isPartnerSuspended = DealRegEPP_Utilities.checkPartnerSuspension(UserInfo.getUserId()); // added by Vijit for Partner Suspension CR - START
        if(isPartnerSuspended || IsProfessionalPartner){
      pageRef =  new PageReference('/apex/page?name=incentives.Advantage&sfdc.tabName=');
    }else{       // added by Vijit for Partner Suspension CR - END
       if(booleanWindow  == true){
         pageRef = new PageReference(dealregBasicURL1);   // Changes to fix Prod Issue - 12/08/2016 - Vijit
      }
       else{
        pageRef = new PageReference(dealregBasicURL1);    // Changes to fix Prod Issue - 12/08/2016 - Vijit
      }
    }  
       return pageRef;
   }
   Public PageReference requestClaim(){
       PageReference pageRef;
       String booleanWindow  = DealRegEPP_Utilities.validateEditAccess(UserInfo.getUserId(),dealReg.Id);
       if(booleanWindow  == 'yes'){
           pageRef = new PageReference('/apex/dealReg_ClaimRebate?Id='+dealReg.Id);
       }
       else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Orion_Access_to_Deal)); 
            pageRef= null;
         
       }
       return pageRef;
   }
    /* REQ-REG-058 - 15th March 2016 by Vijit Vijay - Check on registered Partner email entered in Primary Sales Contact email. START */
    public boolean primarySalesEmailCheck()
    {                
        boolean var = false;
        String primarySalesEmailError = System.Label.Orion_primarySalesEmailCheckError;
        List<Contact> contactList = new List<Contact>();
        contactList =[Select id, Email from Contact where Email=:dealReg.Primary_Sales_Contact_Email__c and RecordType.id = :partnerContRecordTypeID and Inactive_User__c = false];        
        if(contactList.isEmpty()){            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, primarySalesEmailError));
            var = true;
        }
            return var;
    }
    /* REQ-REG-058 - 15th March 2016 by Vijit Vijay - Check on registered Partner email entered in Primary Sales Contact email. END */
    // REQ-REG-059 - 21st April 2016 Added below method by Vijit for REQ-59- START
    public boolean checkEmailDomain(){
        boolean var = false;
        boolean domainFound = false; 
        boolean byPassGeo = false; 
        Map<String, Public_Domain_Websites__c> publicDomain;
        Map<String, Orion_Geo__c> checkGeo = Orion_Geo__c.getAll();
        String validationError = System.Label.Orion_EmailDomainValidation;
        
        String registrationEmail = (dealReg.Email__c.split('@').get(1));  
        for(Orion_Geo__c gc: checkGeo.values()){
            if(contactAccountGeo != null && (contactAccountGeo.equalsIgnoreCase(gc.Geo_Name__c))){                
                if(gc.Value__c){
                    byPassGeo = true; // ByPass validation based on the matching Geo
                    break;  
                }   
            }           
        }
        //Checking if validation need to be bypassed based on Geo.
        if(!byPassGeo){
            publicDomain = Public_Domain_Websites__c.getAll();
            for(Public_Domain_Websites__c pubDomainCheck : publicDomain.values()){
                if(registrationEmail.equalsIgnoreCase(pubDomainCheck.Website__c)){
                    domainFound = true;                 
                    break;
                }            
            }
            if(domainFound == true){            
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,validationError));
                var = true;
            }
        }   
        return var;
    }// REQ-REG-059 - 21st April 2016 Added below method by Vijit for REQ-59- END
    
    
    public pagereference Estimatortool(){
         PageReference pageRefer = new PageReference('/apex/EstimatorPage?oranId='+OranId);
          pageRefer.setRedirect(true);
        return pageRefer;
  
    }
  public PageReference checkleadservices(){
    String prodNamevalue = ApexPages.currentPage().getParameters().get('nameValue');
    if(allowLeadServicesProduct.get(prodNamevalue) == true){
      showLeadServices = true;
    }else{
      showLeadServices = false;
    }
    return null;
    
  }
    
    public List<prodwrapper> renderproductListAdd()
    {  
       
        List<Partner_Select_Product__c> regProdRec = new List<Partner_Select_Product__c>();
       
      try{ 
            if(RegId!=null){
                Integer Index1 = -1;
    //Prasad : 15-May-2016 - Commented extra SOQL below     
    //regProdRec = [Select Name,Quantity__c,Eligible_for_Benifits__c,Approved__c,Eligible_to_Lead_Services__c,Id,Rejected__c, Registration__c from Partner_Select_Product__c where Registration__c =:RegId];
           Boolean RecnotApproved;
           RecnotApproved = false;
            
            regProdRec = [Select Name,Quantity__c,Eligible_for_Benifits__c,Approved__c,Discount__c,Willing_to_Lead_Services_Flag__c,Eligible_to_Lead_Services__c,Id,Rejected__c, Registration__c from Partner_Select_Product__c where Registration__c =:RegId Order By CreatedDate];
            if(regProdRec!=null  && regProdRec.size()>0){
                for(Partner_Select_Product__c psprec: regProdRec){
                        Index1=Index1+1;
                        if(psprec.Approved__c==false && psprec.Rejected__c==false){
                            RecnotApproved = true;
                        }
                        
    // Prasad : 15-May-2016 - Added isEditMode = false as parameter
                        productListAdd.add(new prodwrapper(psprec.Name,String.valueOf(psprec.Quantity__c),psprec.Eligible_for_Benifits__c,psprec.Approved__c,psprec.Eligible_to_Lead_Services__c,psprec.Id,Index1,psprec.Rejected__c,false,psprec.Discount__c,psprec.Willing_to_Lead_Services_Flag__c,allowLeadServicesProduct.get(psprec.Name)));
                }
            } 
            Index = Index1;
            if(dealReg.Id == null){
                readyforAppcheck = true;
            }
            else if(dealReg.Registration_Status__c == 'Draft' || dealReg.Registration_Status__c == 'Returned'){
                readyforAppcheck = true;
            }
            else if(dealReg.Registration_Status__c=='Pending Administrative Review'){
                readyforAppcheck = false;
            }
            else if(RecnotApproved==true && (dealReg.Final_Approval_Date__c!=null || dealReg.Reject_Date__c!=null )){
                readyforAppcheck = true;
            }
            else if(RecnotApproved==false && (dealReg.Final_Approval_Date__c!=null || dealReg.Reject_Date__c!=null )){
                readyforAppcheck = false;
            }
            return productListAdd;          
            }
            else{
             return null;
            }
            
           
        }
        catch(Exception e){
            return null;
        }
      
    }
    Public PageReference ViewAddAttachment(){
     PageReference dealPage =new PageReference('/apex/PartnerAttachmentPage?Id='+dealReg.Id);
          
                return dealPage;
    }
    
    //Auto populate the PSCN Email & Phone As part of CD2 by Ibrahim
    public void copyPhoneEmail(){
        if(dealReg.Orion_Primary_Sales_Contact_Name__c != null){
        Contact c = [select Id, Email,Phone from Contact where Id =:dealReg.Orion_Primary_Sales_Contact_Name__c];
        dealReg.Primary_Sales_Contact_Phone__c = c.Phone;
        dealReg.Primary_Sales_Contact_Email__c = c.Email;
        }
    }
    public void copyAddConEmail(){
        if(dealReg.Orion_Additional_Contact_Name__c != null){
            Contact c = [select Id, Email from Contact where Id =:dealReg.Orion_Additional_Contact_Name__c];
            dealReg.Additional_Contact_Email__c = c.Email;
            }
        }
   //End chages for CD2 by Ibrahim.
   //This method is responsible to populate the primary sales contact details when Are_You_the_Primary_Sales_Contact__c =yes
   //By Ibrahim for Orion Phase 2
   public void showPrimaryContactDetails(){
      
       if(dealReg.Are_You_the_Primary_Sales_Contact__c=='Yes'){
           dealReg.Orion_Primary_Sales_Contact_Name__c = loggedinUser.ContactId;
           dealReg.Primary_Sales_Contact_Phone__c = loggedinUser.Contact.Phone;
           dealReg.Primary_Sales_Contact_Email__c = loggedinUser.Contact.Email;  
       }else{
           dealReg.Orion_Primary_Sales_Contact_Name__c = null;
           dealReg.Primary_Sales_Contact_Phone__c = null;
           dealReg.Primary_Sales_Contact_Email__c = null;
       } 
       
   }
   //End of modifications by Ibrahim.
     Public void refreshDealProductSection(){
      //pollerCount++;
      List<Partner_Select_Product__c> dealProductList = [Select id,Eligible_to_Lead_Services__c, Discount__c from Partner_Select_Product__c where registration__c =: thisDealId];
      deal_registration__c dealReg = [select id,Incentive_Program__c from deal_registration__c where id =: thisDealId limit 1]; 
      
        for(Partner_Select_Product__c psp  :dealProductList){
            for(prodwrapper pwrap :  productListAdd){
                if(pwrap.productId == psp.Id){
                   pwrap.LeadServices = psp.Eligible_to_Lead_Services__c;
                   pwrap.Discount = psp.Discount__c; // Prasad : 12-Jul-2016 - BUG-00149401
                }   
                if(dealReg.Incentive_Program__c == null){
                   pwrap.LeadServices = false;
                   psp.Eligible_to_Lead_Services__c = false;                   
                }
            }
        }
       if(dealReg.Incentive_Program__c == null){
          stopActionPoller = false;    
          regProgstamp = false;
       } 
       
       if(dealReg.Incentive_Program__c != null) { 
          stopActionPoller = true;    
          regProgstamp = true;
       }
      
   }
    //Added by Manu-CR-00138671-Start   
   public boolean isAirwatchOnly()
   {
        Integer countAirwatchProductDup = 0;
        for(prodwrapper wrap:productListAdd){
           for(Orion_Airwatch_Product__c obj: Orion_Airwatch_Product__c.getAll().values()){
               if(obj.ProductName__c.equalsIgnoreCase(wrap.name)){
                   countAirwatchProductDup = countAirwatchProductDup + 1;
               }                           
            }
        }
        if(countAirwatchProductDup == productListAdd.size())
            return true;
        else
            return false;
   }
    //Added by Manu-CR-00138671-Ends
    //Primary Sales Contact Name and Additional Name Validation Check by Ibrahim.
    public boolean ValidateContact()
    {                
        boolean var = false;
        String VaidatePartnerContactError = (Orion_Phase_II_Configurations__c.getInstance('ValidContactCheck')!=null && Orion_Phase_II_Configurations__c.getInstance('ValidContactCheck').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('ValidContactCheck').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('ValidContactCheck').value__c:'Error: Please Provide Valid Partner Contact';
        
        String InActiveUserError = (Orion_Phase_II_Configurations__c.getInstance('OrionInactiveUser')!=null && Orion_Phase_II_Configurations__c.getInstance('OrionInactiveUser').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('OrionInactiveUser').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('OrionInactiveUser').value__c:'Error: Please Provide Active Partner Contact';
        List<Contact> contactList = new List<Contact>();
        contactList =[Select id, Email,Recordtype.Name, Inactive_User__c from Contact where id =: dealreg.Orion_Primary_Sales_Contact_Name__c]; 
        
        boolean PartnerContact = true;
        boolean InActiveUser = true;     
        string ErrorMessage;
        
        for(Contact con : contactList){
            if(con.RecordType.Name == 'Partner Contact'){
               PartnerContact = false;
            }
            if(con.Inactive_User__c == false){
               InActiveUser  = false;
            }
        }
        
        if(PartnerContact){
           ErrorMessage = VaidatePartnerContactError;
        }
        
        if(InActiveUser){
           ErrorMessage = InActiveUserError;
        }
        
        if(PartnerContact || InActiveUser){            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ErrorMessage));
            var = true;
        }
            return var;
    }
    //End of contact validate contact
}