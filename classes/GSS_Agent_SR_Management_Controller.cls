/********************************************************************
* Class Name : GSS_Agent_SR_Management_Controller
* Purpose    : Controller for Action Page
*              
* Author            Date            Comments        
* Accenture     6-April-2014        GSS Agent Console Project
* Accenture     11-July-2014        CR-00096132: GSS optimization 2.0
* Accenture     12-Sept-2014        CR-00107561: Adding SR Links button
* Accenture     10-Oct-2014         CR-00098356: Code added by Abhishek Shubham for attaching Solutions.
* Accenture     19-Nov-2014         CR-00109419: Code to add SR Team related list
* Accenture     22-Dec-2014         CR-00122294/CR-00116268: code to add Audit history button/ITR/Prs
* Accenture     18-Feb-2015         CR-00123420: Queue Search
* Accenture     11-Apr-2015         CR-00132166: Owner Hover for TSMs
* Deepak Kumar  03-Feb-2016         JIRA:BB-13: Added Opco Documents tab in Ultra. 
* Suresh Kumar 07-jun-2016          CR-00138773 added RPQ details in related list 
* Jyolsna       09-Jun-2016         CR-00138097: Added VCE Info tab in Ultra
* Jyolsna       14-Jul-2016         CR-00138560: Added Error Message for Sev1 PREM Transfer queue
*********************************************************************/

global class GSS_Agent_SR_Management_Controller {
  
  final string COLON = ':'; // Constant for Separator, ':' JIRA:BB-13
    final string LEADING_ZERO = '0'; // Constant for appending Leading zero. JIRA:BB-13
    Time lastRefreshTime; // Instance variable for holding current time. JIRA:BB-13
    public boolean checkRender{get;set;}
    public String caseNumber{get;set;}
    public Case caseObj {get;set;}
    public string openInboundNotes {get;set;}
    public boolean searchQueue{get;set;}//CR-00123420  
    
    List <GSS_Agent_Tab_Visibility__c> tabVisibilityList{get;set;}
    public boolean srManagementTab{get;set;}
    public boolean contactEntitlementTab{get;set;}
    public boolean problemDefinitionTab{get;set;}
    public boolean actiontTab{get;set;}
    public boolean resolutionInfoTab{get;set;}
    public boolean srSummaryTab{get;set;}
    public boolean additionalInfoTab{get;set;}
    public boolean additionalTab1{get;set;}
    public boolean additionalTab2{get;set;}
    public boolean opcoDocumentsTab {get; set;} // JIRA:BB-13
    public boolean vceInfoTab {get; set;} // CR-00138097
    
    public string srManagementTabName{get;set;}
    public string contactEntitlementTabName{get;set;}
    public string problemDefinitionTabName{get;set;}
    public string actiontTabName{get;set;}
    public string resolutionInfoTabName{get;set;}
    public string srSummaryTabName{get;set;}
    public string additionalInfoTabName{get;set;}
    public string additionalTab1Name{get;set;}
    public string additionalTab2Name{get;set;}
    public string opcoDocumentsTabName{get;set;} // JIRA:BB-13
    public string vceInfoTabName{get;set;} //  CR-00138097
    public final string more{get;set;}//Jira:B-305
    public boolean isConsole{get;set;}
    public string ErrorMessage{get;set;} //added for CR-00138560
    public string sourceTemplate{get;set;}
    
    public Boolean isEditCase {get; set;}
    public Boolean isServiceCloud=false;
    public string strCaseId;
    public ID gssprofileID = UserInfo.getProfileId() ;
    public Case cs{get;set;}
    public List<wrapperClass> wrapperList {get;set;}
    public List<wrapperClass> wrapperListSecond {get;set;}
    public List<wrapperClass> wrapperListAdditionalInfo {get;set;}
    public List<wrapperClass> wrapperListProductInfo {get;set;}
    public List<wrapperClass> wrapperListResolutionInfo {get;set;}
    public List<wrapperClass> wrapperListContactEntitlementInfo{get;set;}
    
    //Button variables
    public boolean isSRCommentButtonVisible{get;set;}
    public boolean isSRTeamButtonVisible{get;set;}
    public boolean isBugzillaButtonVisible{get;set;}
    public boolean isCallOutboundButtonVisible{get;set;}
    public boolean isCloneButtonVisible{get;set;}
    public boolean isLogACallButtonVisible{get;set;}
    public boolean isPublicCommentButtonVisible{get;set;}
    public boolean isReassignButtonVisible{get;set;}
    public boolean isScriptsButtonVisible{get;set;}
    public boolean isKBButtonVisible{get;set;}
    public boolean isSendEmailButtonVisible{get;set;}
    public boolean isAttachmentButtonVisible{get;set;}
    public boolean isWebexButtonVisible{get;set;}
    public boolean isSRLinkVisible{get;set;}//CR-00107561
    public boolean isHistoryVisible{get;set;}//CR-00122294
    
    public string SRCommentButtonLabel{get;set;}
    public string SRTeamButtonLabel{get;set;}
    public string BugzillaButtonLabel{get;set;}
    public string CallOutboundButtonLabel{get;set;}
    public string CloneButtonLabel{get;set;}
    public string LogACallButtonLabel{get;set;}
    public string PublicCommentButtonLabel{get;set;}
    public string ReassignButtonLabel{get;set;}
    public string ScriptsButtonLabel{get;set;}
    public string KBButtonLabel{get;set;}
    public string SendEmailButtonLabel{get;set;}
    public string AttachmentButtonLabel{get;set;}
    public string WebexButtonLabel{get;set;}
    public string SRLinkLabel{get;set;}//CR-00107561
    public string HistoryLabel{get;set;}//CR-00122294
    public string OwnerId{get;set;} //CR-00132166
    public string SubStatusStyle{get;set;}
    public List<RPQ_Details__c> rpqList{get;set;}
    public List<RPQ_Details__c> allRPQList = new List<RPQ_Details__c>();
    public boolean isVceCase;//  CR-00138097
    
    //CR-00109419 Starts
    public list<CaseTeamMember> lstcaseteammembers {get;set;}    
    public String RecIDeletedd{get;set;}
    public String PreDefinedCTDelete{get;set;}
    public List<WrapperTeamMember> lstWrapperTeamMember{get;set;}
    public class WrapperTeamMember{
        public String RecId{get;set;}
        public String MemberName{get;set;}
        public String TeamMemberRole{get;set;}
        public String LastModifiedName{get;set;}
        public String CaseAccess{get;set;}
        public Boolean VisibleinCustomerPortal{get;set;}
        public Boolean ispredefinedcaseteam{get;set;}
        public String predefinedcaseteamid{get;set;}
    }
    
    set<Id> setContactId=new set<Id>();
    set<Id> setuserId=new set<Id>();
    
    //CR-00109419 Ends
    
    
    
   
    public List<Case> RecordCases{get; set;}    
    private Id strCaseParentId;
    private Id CaseId;
    public Id cId{get;set;}
    public boolean showimage{get;set;}
    public string frdMet {get;set;}    
    public String TabColor{get;set;}//CR-00096132 : For UI changes 
    //CR-00116268 starts
    public list<GSS_Case_BugZilla__c> PRlist{get;set;}
    public String BugsURL{get;set;}
    public Datetime FirRespDate{get;set;}
    public string FirRespString{get;set;}
    public Datetime FirstRespDue {get;set;}
    //CR-00116268 ends
     
    // BB-8 Project Changes
      public Map<Decimal,wrapperClassSLA> WrprObjMap;
        public List<wrapperClassSLA> WrprObjList;
          public List<Case_SLA__c> CaseSLAList{get;set;}
        public string url{get;set;}
       // public List<BB_8_SLA_integration_fields__c> SLACustmSettingList= BB_8_SLA_integration_fields__c.getall().values();
       public List<BB_8_SLA_integration_fields__c> SLACustmSettingList;
 public Case_SLA__c CaseSLA{get;set;}
         public boolean isServiceRestorationButtonVisible{get;set;}
        public boolean isRCAButtonVisible{get;set;}
        public boolean isFinalCorrectionButtonVisible{get;set;}
        public boolean checkForPremiumSupport{get;set;}
    // BB-8 Project changes end 
   
    
    public GSS_Agent_SR_Management_Controller(ApexPages.StandardController controller) {
    
    try{
         // populating Last Refresh Time.
        DateTime currDate = System.now(); // JIRA:BB-13
        lastRefreshTime = currDate.time(); // JIRA:BB-13
        redirectSalesConsole();
        checkForPremiumSupport = true; //Jira:BB-305
        cId = ApexPages.currentPage().getParameters().get('id');
        openInboundNotes = ApexPages.currentPage().getParameters().get('cin');
        sourceTemplate=GSS_Agent_Template__c.getInstance('SR Management Email').TemplateId__c;
        SubStatusStyle=GSS_Agent_Field_Map__c.getInstance('Sub Status').style__c;
        //Start - 9-Jun-2016 - Jyolsna - CR-00138097 - recordtype for vce case 
        isVceCase = false;   
        Id partnerVceCase = Id.valueof(Record_Type_Settings__c.getInstance('GSS_Partner_VCE').Record_Type_ID__c);
        Id vmwareVceCase = Id.valueof(Record_Type_Settings__c.getInstance('GSS_CASE_VCE').Record_Type_ID__c);
        //setTabVisibility();//Commented by Jyolsna
        //End - 9-Jun-2016 - Jyolsna - CR-00138097 - recordtype for vce case 
        more = '<i>..more</i>'; //Jira:BB-305
        List<Case>  ocase = new List<Case>();
        String NT = 'Internal Notes ' + GSS_Agent_Tab_Visibility__c.getInstance('SR Management').Tab_Name__c;//CR-00096132 : variable used to fetch correct comments according to tab name
        if(cId!=null){ //Jira:BB-305 - Adding entitlement code
            //CR-00122294: Added First_Response_Date__c
        //CR-00132166: adding OwnerId
        //CR-00138097: added recordtypeId
            ocase = [SELECT Id, priority,GSS_First_Response_Due_Date__c, EA_Number__c, OwnerId,GSS_Entitlement_Code__c,GSS_First_Resp_Met__c,First_Response_Date__c,RecordTypeId,(select Id, Note_Description__c from SR_Comments__r where Notes_Type__c=:NT) from Case WHERE Id =:cId];
        }
        //Start - 9-Jun-2016 - Jyolsna - CR-00138097 - recordtype for vce case 
            if(!ocase.isEmpty()){
                if(ocase[0].recordtypeId == partnerVceCase || ocase[0].recordtypeId == vmwareVceCase){
                    isVceCase = true;
                }
                
            }
            setTabVisibility();     
            
        //End - 9-Jun-2016 - Jyolsna - CR-00138097 - recordtype for vce case 
  //BB-8 changes  Jira-305
        SLACustmSettingList = [select id,name,Case_Priorities__c,Eligible_For_Case_Closure_Validation__c,Entitlement_Code__c,Field_API_Name__c,Is_Active__c,Is_Target_Date__c,
                       MetFieldAPIName__c,Milestone_Name__c,Object_API_Name__c,Portal_SLA_Field__c,Row_Order_Number__c,IsMilestoneButtonVisible__c from BB_8_SLA_integration_fields__c where Entitlement_Code__c =:ocase[0].GSS_Entitlement_Code__c];
        showimage = false;
        /*******************************************************************CR-00138773 starts**************************************************/
            if(String.isNotBlank(ocase[0].EA_Number__c)){
             rpqList = [select ID, Name, RPQ_Link__c,EA_Number__c,EA_Name__c, Description__c, Status__c, Start_Date__c, End_Date__c,Account__c from RPQ_Details__c where EA_Number__c =: ocase[0].EA_Number__c ];
            }
        /*********************************************************************Ends**************************************************************/
        if(!ocase.isEmpty()){
            if(ocase[0].SR_Comments__r.size()>0){
                showimage = true;
            }
            frdMet = ocase[0].GSS_First_Resp_Met__c;            
            FirRespDate = ocase[0].First_Response_Date__c; //CR-00122294
            FirstRespDue = ocase[0].GSS_First_Response_Due_Date__c;
            OwnerId = ocase[0].OwnerId;//CR-00132166
            
            //BB-8 Project change start
            if(SLACustmSettingList.size()>0){
                 checkForPremiumSupport = false;
       } 
        }    
       //BB-8 Project change end

        
        if(!test.isrunningtest()){
        controller.addFields(editableFields);
        //BB-8 Project change start
        controller.addFields(new List<String>{'GSS_Entitlement_Code__c','Priority'});
        //BB-8 Project change end
        }
        
        this.cs = (Case)controller.getRecord();
        
        searchQueue=false;//CR-00123420
        isSRCommentButtonVisible = false;
        isSRTeamButtonVisible = false;
        isBugzillaButtonVisible = false;
        isCallOutboundButtonVisible = false;
        isCloneButtonVisible = false;
        isLogACallButtonVisible = false;
        isPublicCommentButtonVisible = false;
        isReassignButtonVisible = false;
        isScriptsButtonVisible = false;
        isKBButtonVisible = false;
        isSendEmailButtonVisible = false;
        isAttachmentButtonVisible = false;
        isWebexButtonVisible = false;
        isSRLinkVisible= false; //CR-00107561
        isHistoryVisible=false;//CR-00122294
        isConsole = false;
        checkButtonVisibility();
        checkMilestoneButtonVisisbility();//Jira - BB-305
        
        CaseId=this.cs.Id;
        ErrorMessage = null; //added for CR-00138560: initializing as null

        RecordCases=getRecordCases();
        
        if(apexpages.currentpage().getparameters().get('isdtp') == 'vw'){
            isServiceCloud = true;
            isConsole = true;
        }
        
        TabColor=GSS_Agent_Tab_Visibility__c.getInstance('SR Management').TabColor__c;//CR-00096132: Fetching Tab Colour from custom settings  
        //CR-00116268 starts        
        PRlist=GetPRlist();
        if(PRlist.size()>0){
            GSS_Agent_Variables__c csData=GSS_Agent_Variables__c.getOrgDefaults();
            BugsURL=csData.prurl__c+'?id=';
        }
        //CR-00116268 ends
    }catch (exception e){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on Loading the page. Please contact your System Administrator.');
            ApexPages.addMessage(myMsg); 
    }
    
  }  
    
    //CR-00116268: Method to get list of associated PRs
    public List<GSS_Case_BugZilla__c> GetPRlist(){
        
        if(CaseId!=null){
           //BB-8 changes  : Jira- BB-20 Accenture
            PRlist=[select Name,GSS_Primary_Bug__c,GSS_Bug_ID__c,id,GSS_Bug_Status__c,CreatedDate,GSS_BugSFDCID__r.GSS_Bug_ID__c,GSS_BugSFDCID__r.Bug_Summary__c,
            GSS_CaseNumber__r.GSS_Product_Name__c,GSS_BugSFDCID__r.Bug_Update_Number__c,GSS_BugSFDCID__r.Bug_Updated_By__c,GSS_BugSFDCID__r.Bug_Updated_On__c,GSS_BugSFDCID__r.Bug_Update__c from GSS_Case_BugZilla__c where GSS_CaseNumber__c =:CaseId ORDER BY CreatedDate desc];
        }    
        return PRlist;
    }
       /*
        Method to return time in a formatted Time in HH:MM:SS format.Added for JIRA:BB-13
    */
    public String getLastRefreshTimeHMS() {     
        String lstRefTime;
        
        if(lastRefreshTime.hour() < 10) {
            lstRefTime = LEADING_ZERO + lastRefreshTime.hour() + COLON ;
        } else {
            lstRefTime = lastRefreshTime.hour() + COLON ;
        }
        
        if(lastRefreshTime.minute() < 10) {
            lstRefTime = lstRefTime  + LEADING_ZERO + lastRefreshTime.minute() + COLON ;
        } else {
            lstRefTime = lstRefTime  + lastRefreshTime.minute() + COLON ;
        }
        
        if(lastRefreshTime.second() < 10) {
            lstRefTime =lstRefTime + LEADING_ZERO + lastRefreshTime.second();
        } else {
            lstRefTime = lstRefTime  + lastRefreshTime.second();
        }
        
        return lstRefTime ;
    }
    public void setTabVisibility(){
    
    try{
        // code change start for BB-8 Project
        string ProfileID = userInfo.getProfileId();
        List<GSS_Agent_AdditionaTab_Access_By_Profile__c> ProfileIdList = GSS_Agent_AdditionaTab_Access_By_Profile__c.getall().values();
        Boolean IsTabAccessible = false;
        for(GSS_Agent_AdditionaTab_Access_By_Profile__c PList : ProfileIdList){
            if (PList.IsActive__c == true) {
                if(ProfileID == PList.ProfileId__c){
                 IsTabAccessible = true;
                 break;
                } 
            }
            
        }       
        // code change end for BB-8 Project
        
        //Start - 9-Jun-2016 - Jyolsna - CR-00138097 - only vce profile have access to vce info tab
        Boolean isVceProfile = false;
        Map<String, GSS_Profile_Functionality_Configurations__c> allVceProfile = Gss_ProfileUtility.getProfileIdAndName('Ultra_VCE_Permission__c');
        if(allVceProfile != null && allVceProfile.containsKey(ProfileID)){
            isVceProfile = true;
        }
        //End - 9-Jun-2016 - Jyolsna - CR-00138097 - only vce profile have access to vce info tab
        
        tabVisibilityList=[select  Name,isVisible__c,Tab_Name__c from GSS_Agent_Tab_Visibility__c]; 
        
        for(GSS_Agent_Tab_Visibility__c t:tabVisibilityList){
            if(t.Name=='SR Management'){
                this.srManagementTab=t.isVisible__c;  
                this.srManagementTabName=t.Tab_Name__c;
            }
            else if(t.Name=='Contact & Entitlement'){
                this.contactEntitlementTab=t.isVisible__c;  
                this.contactEntitlementTabName=t.Tab_Name__c;  
            }
            else if(t.Name=='Problem Definition'){
                this.problemDefinitionTab=t.isVisible__c;  
                this.problemDefinitionTabName=t.Tab_Name__c;
            }
            else if(t.Name=='Action'){
                this.actiontTab=t.isVisible__c;  
                this.actiontTabName=t.Tab_Name__c;
            }
            else if(t.Name=='Resolution Information'){
                this.resolutionInfoTab=t.isVisible__c;  
                this.resolutionInfoTabName=t.Tab_Name__c;
            }
            else if(t.Name=='SR Summary'){
                this.srSummaryTab=t.isVisible__c;  
                this.srSummaryTabName=t.Tab_Name__c;  
            }
            else if(t.Name=='Additional Information'){
                this.additionalInfoTab=t.isVisible__c;  
                this.additionalInfoTabName=t.Tab_Name__c;
            }
            // code change start for BB-8 Project
            else if(t.Name=='Additional Tab 1'){
                if(IsTabAccessible){
                    this.additionalTab1=t.isVisible__c;  
                    this.additionalTab1Name=t.Tab_Name__c; 
                }               
            }
            else if(t.Name=='Additional Tab 2'){
                if(IsTabAccessible){
                    this.additionalTab2=t.isVisible__c;  
                    this.additionalTab2Name=t.Tab_Name__c;
                }
            //JIRA:BB-13: Added Opco Documents tab in Ultra.
            }else if(t.Name=='Opco Document'){
                if(IsTabAccessible){
                    this.opcoDocumentsTab=t.isVisible__c;  
                    this.opcoDocumentsTabName=t.Tab_Name__c;
                }               
            }
            // code change end for BB-8 Project
            //Start - 9-Jun-2016 - Jyolsna - CR-00138097 - only vce profile have access to vce info tab
            else if(t.Name=='VCE Info'){
                if(isVCEProfile && isVceCase){
                    this.vceInfoTab=t.isVisible__c;  
                    this.vceInfoTabName=t.Tab_Name__c;
                }               
            }
            //End - 9-Jun-2016 - Jyolsna - CR-00138097 - only vce profile have access to vce info tab
        }
    }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on opening Tabs. Need to setup GSS Agent Tab Visiblity custom settings.');
            ApexPages.addMessage(myMsg); 
    }

    }
    
    public void checkButtonVisibility(){
    
    try{
        
        for(GSS_Agent_Button_Map__c button: [select Name, Label__c from GSS_Agent_Button_Map__c where SR_Management__c=true]){
            if(button.name=='Add SR Team Member'){
                isSRTeamButtonVisible=true;
                SRTeamButtonLabel=button.Label__c;
            }                
            if(button.name=='Bugzilla'){
                isBugzillaButtonVisible=true;
                BugzillaButtonLabel=button.Label__c;
            }                
            if(button.name=='Call Outbound'){
                isCallOutboundButtonVisible=true;
                CallOutboundButtonLabel=button.Label__c;
            }
            if(button.name=='Clone SR'){
                isCloneButtonVisible=true;
                CloneButtonLabel=button.Label__c;
            }
            if(button.name=='Log a call'){
                isLogACallButtonVisible=true;           
                LogACallButtonLabel=button.Label__c;
            }                
            if(button.name=='Public Comments'){
                isPublicCommentButtonVisible=true;
                PublicCommentButtonLabel=button.Label__c;
            }                
            if(button.name=='Reassign'){
                isReassignButtonVisible=true;
                ReassignButtonLabel=button.Label__c;
            }                
            if(button.name=='Script Server Attachments'){
                isScriptsButtonVisible=true;
                ScriptsButtonLabel=button.Label__c;
            }                
            if(button.name=='Search iKb'){
                isKBButtonVisible=true;
                KBButtonLabel=button.Label__c;
            }                
            if(button.name=='Send Customer Email'){
                isSendEmailButtonVisible=true;
                SendEmailButtonLabel=button.Label__c;
            }                
            if(button.name=='SR Comments'){
                isSRCommentButtonVisible=true;
                SRCommentButtonLabel=button.Label__c;
            }                
            if(button.name=='Upload Attachment'){
                isAttachmentButtonVisible=true;
                AttachmentButtonLabel=button.Label__c;
            }                
            if(button.name=='Webex Session'){
                isWebexButtonVisible=true;
                WebexButtonLabel=button.Label__c;
            }
            //CR-00107561 - starts
            if(button.name=='SR Links'){
                isSRLinkVisible=true;
                SRLinkLabel=button.Label__c;
            }
            //CR-00122294  - Starts
            if(button.name=='Audit History'){
                isHistoryVisible=true;
                HistoryLabel=button.Label__c;
            }                 
            //CR-00122294  - ends
            
        }
    }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on Loading Buttons. Need to setup GSS Agent Button Map custom settings.');
            ApexPages.addMessage(myMsg); 
    }
    
    }
   
           
    public List<Case> getRecordCases(){
      if(CaseId != null){
        RecordCases= [Select Id,casenumber,TSE_Synopsis__c,owner.Name,ParentId, Subject, Status, Priority,RecordType.Name  from Case where ParentId=:CaseId  AND Id != null AND ParentId != null];
      }
        return RecordCases;
    }
        
     public List<String> editableFields {
     
        get{
        
        
        
        wrapperList = new List<wrapperClass>();
        wrapperListSecond = new List<wrapperClass>();
        //BB-8 Project Changes Start
        List<GSS_Agent_Field_Map__c> caseFields;        
        if(checkForPremiumSupport){
             caseFields = [select Label__c,Field_API_Name__c,Read_Only__c,Order__c,style__c,Required__c,Name,HelpText__c from GSS_Agent_Field_Map__c where isActive__c=true and Tab_Name__c='SR Management'  order by Order__c];
        }else{
             caseFields = [select Label__c,Field_API_Name__c,Read_Only__c,Order__c,style__c,Required__c,Name,HelpText__c from GSS_Agent_Field_Map__c where isActive__c=true and Tab_Name__c='SR Management' and HideForPremiumEntitlement__c=:checkForPremiumSupport order by Order__c];
        }
        //BB-8 Project Changes end
        editableFields = new List<String>();
        for(integer i=0;i<caseFields.size();i++){
        wrapperClass wrapperObj = new wrapperClass();
        wrapperClass wrapperObjSecond = new wrapperClass();
        integer sum = math.mod(i,2);
        //CR-00122294: Severity read only until ITR - Populated
        if(caseFields[i].Field_API_Name__c == 'priority'){
            if(FirRespDate == null){
                if(sum == 0 ){
                editableFields.add(caseFields[i].Field_API_Name__c);
                wrapperObj.fieldName = caseFields[i].Field_API_Name__c;
                wrapperObj.label = caseFields[i].label__c;
                wrapperObj.helpText= caseFields[i].helpText__c;
                wrapperObj.required = caseFields[i].required__c;
                wrapperObj.style = caseFields[i].style__c;
                wrapperObj.readOnly = true;
                wrapperList.add(wrapperObj);
                }else{
                editableFields.add(caseFields[i].Field_API_Name__c);
                wrapperObjSecond.fieldName = caseFields[i].Field_API_Name__c;
                wrapperObjSecond.label = caseFields[i].label__c;
                wrapperObjSecond.helpText= caseFields[i].helpText__c;
                wrapperObjSecond.required = caseFields[i].required__c;
                wrapperObjSecond.style = caseFields[i].style__c;
                wrapperObjSecond.readOnly = true;
                wrapperListSecond.add(wrapperObjSecond);
                }
            }else{
                if(sum == 0 ){
                editableFields.add(caseFields[i].Field_API_Name__c);
                wrapperObj.fieldName = caseFields[i].Field_API_Name__c;
                wrapperObj.label = caseFields[i].label__c;
                wrapperObj.helpText= caseFields[i].helpText__c;
                wrapperObj.required = caseFields[i].required__c;
                wrapperObj.style = caseFields[i].style__c;
                wrapperObj.readOnly = caseFields[i].read_only__c;
                wrapperList.add(wrapperObj);
                }else{
                editableFields.add(caseFields[i].Field_API_Name__c);
                wrapperObjSecond.fieldName = caseFields[i].Field_API_Name__c;
                wrapperObjSecond.label = caseFields[i].label__c;
                wrapperObjSecond.helpText= caseFields[i].helpText__c;
                wrapperObjSecond.required = caseFields[i].required__c;
                wrapperObjSecond.style = caseFields[i].style__c;
                wrapperObjSecond.readOnly = caseFields[i].read_only__c;
                wrapperListSecond.add(wrapperObjSecond);
                }           
            }
        }//CR-00122294 ends
        else if(caseFields[i].Field_API_Name__c == 'GSS_First_Response_Due_Inn__c'){
        system.debug('fields coming lines....'+caseFields[i]);
        if(frdMet=='' || frdMet==null){
        if(sum == 0 ){
        editableFields.add(caseFields[i].Field_API_Name__c);
        wrapperObj.fieldName = caseFields[i].Field_API_Name__c;
        wrapperObj.label = caseFields[i].label__c;
        wrapperObj.helpText= caseFields[i].helpText__c;
        wrapperObj.required = caseFields[i].required__c;
        wrapperObj.style = caseFields[i].style__c;
        wrapperObj.readOnly = caseFields[i].read_only__c;
        
        wrapperList.add(wrapperObj);
        }else{
        editableFields.add(caseFields[i].Field_API_Name__c);
        wrapperObjSecond.fieldName = caseFields[i].Field_API_Name__c;
        wrapperObjSecond.label = caseFields[i].label__c;
        wrapperObjSecond.helpText= caseFields[i].helpText__c;
        wrapperObjSecond.required = caseFields[i].required__c;
        wrapperObjSecond.style = caseFields[i].style__c;
        wrapperObj.readOnly = caseFields[i].read_only__c;
        wrapperListSecond.add(wrapperObjSecond);
        }
        }
        }else{
        if(sum == 0 ){
        editableFields.add(caseFields[i].Field_API_Name__c);
        wrapperObj.fieldName = caseFields[i].Field_API_Name__c;
        wrapperObj.label = caseFields[i].label__c;
        wrapperObj.helpText= caseFields[i].helpText__c;
        wrapperObj.required = caseFields[i].required__c;
        wrapperObj.style = caseFields[i].style__c;
        wrapperObj.readOnly = caseFields[i].read_only__c;
        wrapperList.add(wrapperObj);
        }else{
        editableFields.add(caseFields[i].Field_API_Name__c);
        wrapperObjSecond.fieldName = caseFields[i].Field_API_Name__c;
        wrapperObjSecond.label = caseFields[i].label__c;
        wrapperObjSecond.helpText= caseFields[i].helpText__c;
        wrapperObjSecond.required = caseFields[i].required__c;
        wrapperObjSecond.style = caseFields[i].style__c;
        wrapperObjSecond.readOnly = caseFields[i].read_only__c;
        wrapperListSecond.add(wrapperObjSecond);
        }
        }
        }
        return editableFields ;
        }
        private set;
    
    }
    
    
    public pagereference redirectSalesConsole(){
       string pageURL = ApexPages.currentPage().getURL(); 
       
       strCaseId = apexpages.currentpage().getparameters().get('id');
       if(isServiceCloud  == false){
                // CR-00098356 : Changes begin.
                //pagereference pr = new pagereference
                String CorrectURL=('/' + strCaseId + '?nooverride=1&' + pageURL.substring(pageURL.indexOf('?', 0)+1, pageURL.length()));
                //pagereference pr = new pagereference('/' + strCaseId +  pageURL.substring(pageURL.indexOf('?', 0), pageURL.length()));                
                String CaseIdRemove=('id='+strCaseId + '&');
                CorrectURL=CorrectURL.remove(CaseIdRemove);
                pagereference  finalURl = new pagereference(CorrectURL); 
                // CR-00098356 : Changes end.

                finalURl.setRedirect(true);
                return finalURl ;
            
        }
              
               
                return null;
      
              
    }
        
    
    public PageReference savecase() {
        try{
            update cs;

        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getmessage());
            //Start - 14-Jul-2016 - Jyolsna - CR-00138560 : if the validation error for Prem transfer queue throws, then set errormessage.
            if(e.getmessage().contains(Label.GSS_Prevent_Sev1_cases_assignment_to_Prem)){
                ErrorMessage = Label.GSS_Prevent_Sev1_cases_assignment_to_Prem;
            }
            else if(!e.getmessage().contains(Label.BB_8_Case_Sub_Status_Manual_Change_Error_Msg)) {    //BB-8 changes  : Jira- BB-305 Accenture
                ApexPages.addMessage(myMsg); 
            }
            //End - 14-Jul-2016 - Jyolsna - CR-00138560
        }
        
        return null;
    }
    

    
     public class wrapperClass{
         public string fieldName{get;set;}
         public string label{get;set;}
         public string helpText{get;set;}
         public string style{get;set;}
         public boolean readOnly{get;set;}
         public boolean required{get;set;}                 
    
    }
    
    //CR-00109419 Starts
    public List<WrapperTeamMember> getDetail(){
        
        lstcaseteammembers = new list<CaseTeamMember>();
        list<CaseTeamTemplateRecord> lstpredefinedcaseteam = new list<CaseTeamTemplateRecord>();
        list<CaseTeamMember> lstmemberscaseteams = new list<CaseTeamMember>();
        lstWrapperTeamMember=new List<WrapperTeamMember>();
        
        Schema.DescribeSObjectResult dsrcon = Contact.SObjectType.getDescribe();
        String objPrefixContact = dsrcon.getKeyPrefix();
        Schema.DescribeSObjectResult dsruser = User.SObjectType.getDescribe();
        String objPrefixUser = dsruser.getKeyPrefix();
        if(cId != null){
          lstcaseteammembers = [select MemberId, TeamRole.Name,TeamRole.PreferencesVisibleInCSP,TeamRole.AccessLevel,LastModifiedById,LastModifiedBy.Name,TeamTemplateMemberId from CaseTeamMember where ParentId =: cId];
        }
        
        if(lstcaseteammembers!=null && !lstcaseteammembers.isEmpty()){
        for(CaseTeamMember objcaseteammember:lstcaseteammembers ){
                    if(objcaseteammember.TeamTemplateMemberId == null){
                        lstmemberscaseteams.add(objcaseteammember);
                    }               
                }
            }
            
            
        if(cId != null){
          lstpredefinedcaseteam = [select id,TeamTemplateId,TeamTemplate.Name,TeamTemplate.Description,TeamTemplate.LastModifiedById,TeamTemplate.LastModifiedBy.Name from CaseTeamTemplateRecord where ParentId=:cId];
        }
                
        if(lstmemberscaseteams!=null && !lstmemberscaseteams.isEmpty()){
            for( CaseTeamMember c:lstmemberscaseteams){
                if(c.MemberId!=null && string.valueOf(c.MemberId).substring(0,3)==objPrefixContact){
                    setContactId.add(c.MemberId);
                }
                else if(c.MemberId!=null && string.valueOf(c.MemberId).substring(0,3)==objPrefixUser){
                    setuserId.add(c.MemberId);
                }
            }
        }
        Map<Id,Contact> mapContact = null;
        Map<Id,User> mapUser = null;
        if(setContactId!= null){
          mapContact=new Map<Id,Contact>([Select Id,LastName,FirstName from Contact where id in:setContactId]);
        }
        if(setuserId != null){
          mapUser=new Map<Id,User>([Select Id,UserName,Name from User where id in:setuserId]);
        }
     
        if(lstmemberscaseteams!=null && !lstmemberscaseteams.isEmpty()){
            for( CaseTeamMember c:lstmemberscaseteams){
                WrapperTeamMember w=new WrapperTeamMember();
                if(c.MemberId!=null && string.valueOf(c.MemberId).substring(0,3)==objPrefixContact){
                    
                    w.MemberName=mapContact.get(c.MemberId).LastName;
                    w.MemberName=MapContact.get(c.MemberId).FirstName+'  '+MapContact.get(c.MemberId).LastName;

                }
                else if(c.MemberId!=null && string.valueOf(c.MemberId).substring(0,3)==objPrefixUser){
                    
                    w.MemberName=mapUser.get(c.MemberId).Name;
                }
                
                w.LastModifiedName=c.LastModifiedBy.Name;
                if(c.TeamRoleId!=null ){
                    w.TeamMemberRole=c.TeamRole.Name;
                    w.CaseAccess=c.TeamRole.AccessLevel;
                    w.VisibleinCustomerPortal=c.TeamRole.PreferencesVisibleInCSP;
                }
                w.ispredefinedcaseteam=false;
                w.RecId= c.Id;
                lstWrapperTeamMember.add(w);
            }
        }
            if(lstpredefinedcaseteam!=null && !lstpredefinedcaseteam.isEmpty()){
            for( CaseTeamTemplateRecord pct:lstpredefinedcaseteam){
                WrapperTeamMember w=new WrapperTeamMember();
                if(pct.TeamTemplateId!=null){
                    
                    w.MemberName = pct.TeamTemplate.Name;               
                }
                
                w.LastModifiedName=pct.TeamTemplate.LastModifiedBy.Name;            
                w.TeamMemberRole='Team';
                w.CaseAccess='-';
                w.VisibleinCustomerPortal=True;
                w.ispredefinedcaseteam=true;            
                w.RecId= pct.Id;
                w.predefinedcaseteamid=pct.Id;
                lstWrapperTeamMember.add(w);
            }
        }
        return lstWrapperTeamMember;
        // End for SR Team Related list in Additional Tab      
    }
    
    
    public PageReference RemoveTM() {

        if (RecIDeletedd != null) {
            List<CaseTeamMember> ct = [ Select Id From CaseTeamMember  Where Id =: RecIDeletedd ];
            try{
                delete ct;
            } catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getmessage());
                ApexPages.addMessage(myMsg); 
            }

        } 
        if(PreDefinedCTDelete != null){

            List<CaseTeamTemplateRecord> pct = [ Select Id From CaseTeamTemplateRecord  Where Id =: PreDefinedCTDelete ];
            try{
                delete pct;

            } catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getmessage());
                ApexPages.addMessage(myMsg); 
            }                                  

        }
        return null; 
    }
    //CR-00109419 Ends
    /**
    * Purpose : To get the sla milestones related to Premeier entitlement Case - BB-8 changes JIRA : BB-305
    * Param : None
    * Return : List of milestone records
    **/
    public List<wrapperClassSLA> getRecordCaseSLA(){
         
         if(cs!=null){
             WrprObjList=new List<wrapperClassSLA>();      
               WrprObjMap = new Map<Decimal,wrapperClassSLA>();
               CaseSLAList = new List<Case_SLA__c>();
               CaseSLA=new Case_SLA__c();
                 Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
                 List<BB_8_SLA_integration_fields__c> newSLAFields = BB_8_SLA_integration_fields__c.getall().values();
                  List<BB_8_SLA_integration_fields__c> caseSlaTargetFields = new List<BB_8_SLA_integration_fields__c>();
                   Set<String> entCodeSet = new Set<String>();
                String SOQL_SLA='';
              String SOQL='';
             
            for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
                    // Pick all active premier entitlements
                    if(entObj.isActive__c){
                        entCodeSet.add(entObj.code__c);
                        
                    }
            }
            //system.debug('Ent code is '+cs);
             //system.debug('entCodeSet '+entCodeSet);
            for( BB_8_SLA_integration_fields__c integrationfield : newSLAFields ) { 
                    if( cs.GSS_Entitlement_Code__c!= null && integrationfield.Is_Active__c && entCodeSet.contains(integrationfield.Entitlement_Code__c) && cs.GSS_Entitlement_Code__c.equalsIgnoreCase(integrationfield.Entitlement_Code__c) && integrationfield.Object_API_Name__c != '' && integrationfield.Object_API_Name__c != null && integrationfield.Object_API_Name__c.equalsIgnoreCase('Case_SLA__c') ){
                        caseSlaTargetFields.add(integrationfield);
                    }
                               
                }
                
                for( BB_8_SLA_integration_fields__c integrationfield : caseSlaTargetFields ) { 
                            SOQL_SLA += '' + integrationfield.Field_API_Name__c + ', ';
                    }
                    
                    if(SOQL_SLA != '') { //Adding check for non CGS entitlement
                        
                        SOQL += 'Select '+SOQL_SLA+'id,name,case__c,Last_Stopped_Time__c from Case_SLA__c where Case__c =: cId limit 1' ;
                    }   
                    
                    System.debug('SOQL_SLA BB8****'+SOQL);
                    
                 try{   
             CaseSLAList=Database.query(SOQL);
             }
             catch(Exception e){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.GSS_BB8_Case_SLA_Milestone_Error));
            return NULL;    
            }
             
            
             //url='/'+CaseSLA.id;
             if(!CaseSLAList.isEmpty()){
                CaseSLA = CaseSLAList[0];
                 for(BB_8_SLA_integration_fields__c b:SLACustmSettingList){
                 //WrprObj.add(new wrapperClassSLA(Integer.valueOf(b.Row_Order_Number__c),b.Name,datetime.valueOf(CaseSLA.get(b.Field_API_Name__c))));
                    if(!WrprObjMap.containsKey(b.Row_Order_Number__c)){
                        //add the key and value
                        if(b.Is_Target_Date__c){
                        //Fill the target place holder of wrapper class
                            wrapperClassSLA wObj = new wrapperClassSLA();
                            wObj.RowNumber = b.Row_Order_Number__c;
                            if((CaseSLA.get(b.Field_API_Name__c)) != '' && CaseSLA.get(b.Field_API_Name__c) != null){
                                wObj.dueVal = dateTime.valueOf(CaseSLA.get(b.Field_API_Name__c));
                            }   
                            wObj.sla=b.Portal_SLA_Field__c;
                            wObj.milestoneName = b.Milestone_Name__c;
                            //WrprObjMap.put(b.Row_Order_Number__c,new wrapperClassSLA(b.Row_Order_Number__c,'',CaseSLA.get(b.Field_API_Name__c)+''));
                            WrprObjMap.put(b.Row_Order_Number__c,wObj);
                           
                        }
                 
                        else{
                        //Fill the acutal place holder of the wrapper class
                            wrapperClassSLA wObj = new wrapperClassSLA();
                            wObj.RowNumber = b.Row_Order_Number__c;
                            if((CaseSLA.get(b.Field_API_Name__c)) != '' && CaseSLA.get(b.Field_API_Name__c) != null){
                                wObj.actualVal = dateTime.valueOf(CaseSLA.get(b.Field_API_Name__c)); 
                            }
                           //wObj.actualVal2= String.ValueofGmt(wObj.actualVal); 
                             wObj.sla=b.Portal_SLA_Field__c;             
                            wObj.milestoneName = b.Milestone_Name__c;
                            //WrprObjMap.put(b.Row_Order_Number__c,new wrapperClassSLA(b.Row_Order_Number__c,CaseSLA.get(b.Field_API_Name__c)+'',''));
                            WrprObjMap.put(b.Row_Order_Number__c,wObj);
                        }
                    }
                    else{
                        //Key value already present
                        if(b.Is_Target_Date__c){
                            if((CaseSLA.get(b.Field_API_Name__c)) != '' && CaseSLA.get(b.Field_API_Name__c) != null){
                                WrprObjMap.get(b.Row_Order_Number__c).dueVal = dateTime.valueOf(CaseSLA.get(b.Field_API_Name__c));
                            }
                            
                                                 
                        }
                        else{
                            if((CaseSLA.get(b.Field_API_Name__c)) != '' && CaseSLA.get(b.Field_API_Name__c) != null){     
                                WrprObjMap.get(b.Row_Order_Number__c).actualVal = dateTime.valueOf(CaseSLA.get(b.Field_API_Name__c));
                            }
                            
                              
                         }
                        
                        if(WrprObjMap.get(b.Row_Order_Number__c).actualVal!=NULL && WrprObjMap.get(b.Row_Order_Number__c).dueVal!=NULL && WrprObjMap.get(b.Row_Order_Number__c).actualVal < WrprObjMap.get(b.Row_Order_Number__c).dueVal){
                            WrprObjMap.get(b.Row_Order_Number__c).metField='Yes';
                            
                        }
                        else{
                            WrprObjMap.get(b.Row_Order_Number__c).metField='No';
                        }
                        if(WrprObjMap.get(b.Row_Order_Number__c).dueVal!=NULL){
                            WrprObjList.add(WrprObjMap.get(b.Row_Order_Number__c));
                            
                            }
                            
                    }
                 }
                } 
                  
             System.debug('WrprObjMap****'+WrprObjMap);
             
             if(!WrprObjList.isEmpty()){
                populateRemainingTime(WrprObjList);
                WrprObjList.sort();
                System.debug('Record SLA ***'+WrprObjList); 
                return WrprObjList;
             }
             }
             return null;
         }
         
          public List<Schema.FieldSetMember> getFields() {
            return SObjectType.Case_SLA__c.fieldSets.CaseSLAFields.getFields();
        }
        
         /**
      * Purpose : Class to hold sla milestones - BB-8 changes JIRA : BB-305
      * Param : None
      * Return : List of milestone records
      **/
        public class wrapperClassSLA implements comparable{
        
             public Decimal RowNumber{get;set;}
             public datetime actualVal{get;set;}   //datetime  String.ValueofGmt
             public datetime dueVal{get;set;}
             public String milestoneName{get;set;}
             public string metField{get;set;}
             public string sla{get;set;}
             public datetime lastStoppedTime{get;set;}
             public string timeRemaining {get;set;}
             
            // Implement the compareTo() method
            public Integer compareTo(Object compareTo) {
                wrapperClassSLA compareToSla = (wrapperClassSLA)compareTo;
                if (RowNumber == compareToSla.RowNumber) return 0;
                if (RowNumber > compareToSla.RowNumber) return 1;
                return -1;       
            }
             
         /* public wrapperClassSLA(Decimal i,String actualVal,String dueVal){
          this.RowNumber=i;
          this.actualVal=datetime.valueOf(actualVal);
          this.dueVal=datetime.valueOf(dueVal);
          }*/
           
           }
           /** Method to populate remaining time field of wraper class **/
           public void populateRemainingTime(List<wrapperClassSLA> WrprObjList){
                //populate the last stopped time
                List<CaseMilestone> casemileList=new List<CaseMilestone> ();
                casemileList=[select MilestoneType.Name, TimeRemainingInMins from CaseMilestone where caseId=:cId ];
                if(!WrprObjList.isEmpty() && CaseSLA != null){
                    for(wrapperClassSLA sla : WrprObjList){
                    for(CaseMilestone cm:casemileList){
                    if(cm.MilestoneType.Name.equalsIgnoreCase(sla.milestoneName)){
                      sla.timeRemaining=cm.TimeRemainingInMins ;
                    }
                    }
                       /* if(sla.dueVal != null){
                            sla.lastStoppedTime = CaseSLA.Last_Stopped_Time__c;
                            if(sla.metField != null && sla.metField.equalsIgnoreCase('Yes')){ // milestone completed
                                sla.timeRemaining = '00.00';
                            }
                            else if(CaseSLA.Last_Stopped_Time__c != null && sla.actualVal == null){ // milestone paused
                                //sla.lastStoppedTime = CaseSLA.Last_Stopped_Time__c;
                                //sla.timeRemaining = ((sla.dueVal.getTime()-sla.lastStoppedTime.getTime())/1000)/60;
                                //sla.timeRemaining = sla.timeRemaining.setScale(2, RoundingMode.HALF_UP);
                                System.debug('getMinutesRemaining(sla.dueVal,sla.lastStoppedTime)***'+sla.dueVal+'***'+System.now());
                                sla.timeRemaining = getMinutesRemaining(sla.dueVal,sla.lastStoppedTime);
                            }
                            else if(sla.actualVal != null){ // milestone violated
                                //sla.timeRemaining = ((sla.dueVal.getTime()-sla.actualVal.getTime())/1000)/60;
                                //sla.timeRemaining = sla.timeRemaining.setScale(2, RoundingMode.HALF_UP);
                                System.debug('getMinutesRemaining(sla.dueVal,sla.actualVal)***'+sla.dueVal+'***'+System.now());
                                sla.timeRemaining = getMinutesRemaining(sla.dueVal,sla.actualVal);
                            }
                            else if(CaseSLA.Last_Stopped_Time__c == null && sla.actualVal == null){ // milestone clock ticking
                                //sla.timeRemaining = ((sla.dueVal.getTime()-System.now().getTime())/1000)/60;
                                //sla.timeRemaining = sla.timeRemaining.setScale(2, RoundingMode.HALF_UP);
                                System.debug('getMinutesRemaining(sla.dueVal,System.now()***'+sla.dueVal+'***'+System.now());
                                sla.timeRemaining = getMinutesRemaining(sla.dueVal,System.now());
                                
                            }
                           /* if(sla.timeRemaining < 0){
                                sla.timeRemaining = 0.00;
                            } */
                       // } 
                    }
                }
           }
            /** BB-8 changes - Method to to get the minutes remaining **/
        /*   public String getMinutesRemaining(Datetime maxTime,Datetime minTime){
                Decimal minutesRemaining = 00;
                Decimal secRemaining=00;
                String timeRemaining;
                if(maxtime != null && minTime != null){
                    minutesRemaining = (maxTime.getTime() - minTime.getTime()) / 60000;
                    if(minutesRemaining>0){
                        secRemaining = (Math.mod((maxTime.getTime() - minTime.getTime()),60000))/1000;
                        timeRemaining = minutesRemaining +'.'+ secRemaining;
                    }
                    else{
                        timeRemaining = '00.00';
                    }
                }
                return timeRemaining;
           } */
           /** BB-8 changes - Method to enable/disable milestone email buttons on the page based on caes priority **/
           public void checkMilestoneButtonVisisbility(){
                isServiceRestorationButtonVisible = false;
                isRCAButtonVisible = false;
                isFinalCorrectionButtonVisible = false;
                
                
                for(BB_8_SLA_integration_fields__c b:SLACustmSettingList){
                    if(b.Case_Priorities__c!= null && b.Case_Priorities__c.contains(cs.Priority) && b.Is_Target_Date__c){
                        if(b.Field_API_Name__c!= null && b.Field_API_Name__c.equalsIgnorecase('Service_restoration_due__c')){
                            isServiceRestorationButtonVisible = true;
                        }
                        else if(b.Field_API_Name__c!= null && b.Field_API_Name__c.equalsIgnorecase('RCA_Due__c')){
                            isRCAButtonVisible = true;
                        }
                        if(b.Field_API_Name__c!= null && b.Field_API_Name__c.equalsIgnorecase('Final_Correction_due__c')){
                            isFinalCorrectionButtonVisible = true;
                        }
                        
                    }
                    
                }
           }
        /*********CR-00138773 starts*****/ 
    public List<RPQ_Details__c> getrpqLists(){
         allRPQList.clear();
         if(rpqList != null && rpqList.size()>0){
             allRPQList.addAll(rpqList);
         }
         return allRPQList;
    }
  /*********CR-00138773 starts*****/
 }