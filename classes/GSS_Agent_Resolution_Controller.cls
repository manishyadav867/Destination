/*********************************************************************
  * Class Name : GSS_Agent_Resolution_Controller
  * Purpose    : Controller for Resolution Information Page
  *              
  * Author            Date            Comments        
  * Accenture     6-April-2014        GSS Agent Console Project
  * Accenture     11-July-2014        CR-00096132: GSS optimization 2.0
  * Accenture     08-Sept-2014        CR-00107561: For VCE Entitlements Partner compliance field should be displayed 
  * Accenture     12-Sept-2014        CR-00107561: Adding SR Links button
  * Accenture     22-dev-2014         CR-00122294: code to add Audit history button
  * Accenture     12- May -2015       CR-00123270: Case cannot be closed with open assist record
  * Accenture     6th'Jul'15         CR-00135123 New record type "GSS Technical Support – PD" that mirrors GSS CS Admin 
  * Accenture     9-Sept-2015         CR-00135064 : Non - GSS Technical Support Cases cannot be closed using Ultra. 
  * Dalia Pan     4-Nov-2015          CR-00136382 : Removing Issue Type, Sub Type & Resolution Code Validation from Page. 
  * Dalia Pan    5-Jan-2016        CR-00137136 : Adding GSS_Workaround_Available__c field & validation.
  * Sakshi Suri  30-Mar-2016       CR-00138253 :EA number exposed to details
  * Sandip Wankhede 29-Feb-2016       BB-8 Project : Case can not be closed if any milestone related SR is open(CGS entitlement)
  * Jyolsna 28-Jun-2016     CR-00138097: added validation for VCE case
  *Suresh Kumar 4-august-2016 CR-00140332 : added entitlement name in banner
  * ********************************************************************/
  public class GSS_Agent_Resolution_Controller{

    public final Case ocase;
    public final Product2 ProductObject{get;set;}
      
    // boolean variables to check record type
    public boolean isTechSupport{get;set;}
    public boolean isCSAdmin{get;set;}
    public boolean isLicensing{get;set;}
    
    public string TechCon{get;set;}
    public string CaseNum{get;set;}
    public string TechPhone{get;set;}
    public string AccName {get;set;}
    public string EAName {get;set;}//CR-00138253
    public string EANumber {get;set;}//CR-00138253
    
    public String CaseID{get;set;}
    
    public String strProdId{get; set;} 
    public String strProductName{get; set;} // Property to hold selected product Name.
    //public string strworkaround{get;set;}
    //Adding variables for CR-00026553
    public String strProductVersion{get; set;} // Property to hold selected product Version. 
    public List<SelectOption> strProductVersionItems{get; set;}
    public boolean isVersionRequired {get;set;}
    public boolean isASPCase{get;set;}
    public boolean showRequiredFields{get;set;}   
    public boolean errorFound{get;set;}
    public boolean closeSuccess{get;set;}//CR-00107561
    
    // variables for issue type
    public List<SelectOption> strIssueTypeItems{get; set;}
    public String strIssueType{get;set;} 
    
    // variables adding for sub type
    public List<GSS_Populate_Product_Issue_Types__c> Populate_Product_Issue_Types_Values{get; set;} 
    public List<GSS_IssueTypeDependentPicklistValues__c> ProductIssueTypeDependentPicklistValues;
    public List<SelectOption> strSubTypeItems{get;set;}
    public List<String> lstIssueTypesToSearch{get; set;}
    
    public Boolean isIssueSubTypeEditable{get; set;}
    public String strSubType{get;set;}
    public String strSubTypeNote{get;set;}
    public String strSupportType{get;set;} //CR-00137136
      
    // variables for Vcat and VsubCat
    public List<SelectOption> strVCatItems{get;set;}
    public String strVCat{get;set;}
    public String strVSubCat{get;set;}
    public List<SelectOption> strVSubCatItems{get;set;}
    public Boolean isVSubCatDisabled {get; set;} 
    
    public List<SelectOption> strVSubCatObjItems{get;set;} //CR-00044677
    
    // variables for Partner and Partner Component
    public Boolean isPartnerVisible{get; set;} 
    public String strPartner {get;set;}
    public List<SelectOption> strPartnerItems{get;set;}
    public List<String> lstProductPartnerVSubCat{get;set;}
    List<GSS_PartnerComponent_Relation__c> PartnerComponent_RelationList;
    public Boolean isDisabledPartner{get; set;}
    public List<SelectOption> strPartnerComponentItems{get;set;}
    public String strPartnerComponent {get;set;}
    public Boolean isPartnerComponentDisabled {get; set;}
    public boolean showimage{get;set;}
    
    //CR-00006747 start
    public string strPlatform{get;set;}
    public string strPlatformVersion{get;set;}
    public Boolean isVfabricProduct{get;set;}
    //CR-00006747 end
    public Boolean isServiceCloud=false;
    public string strCaseId;
    public Id cId{get;set;}
      
    public Boolean showDuplicate{get;set;}//CR-00107561
    public string sourceTemplate{get;set;}
    public Boolean isVceCase{get;set;}//Added for CR-00138097
    
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
    public boolean haserrors{get;set;}
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
    public string TabColor{get;set;}//CR-00096132 : For UI changes
    //CR-00096132 - Helptext changes start
    public string symptomsHelpText{get;set;}
    public string ITRHelpText{get;set;}   
    //CR-00096132 - Helptext changes End
    public string HistoryLabel{get;set;}//CR-00122294
    public id accID{get;set;}
    public string caseSynopsis{get;set;}//CR-00122294
    public string entitlementName{get;set;}//CR-00140332


    
    
      
    public void setrequiredfields()
    {
    this.showRequiredFields=false;
    }
    
    
    public GSS_Agent_Resolution_Controller() {
        
      isIssueSubTypeEditable=false;

      //CR-00024599 - Starts                 
      this.isTechSupport=false;
      this.isCSAdmin=false;
      this.isLicensing=false;
      this.isVersionRequired=false; //CR-00026553
      this.isVfabricProduct=false; //CR-00006747
      this.isASPCase=false;
      this.showRequiredFields=false;
      this.errorFound=false;
      this.showDuplicate= false;//CR-00107561
      this.closeSuccess=false;//CR-00107561
      //CR-00024599 - Ends  
      //Start - 28-Jun-2016 - Jyolsna - CR-00138097  
      this.isVceCase = false;
      String partnerVceCase = Record_Type_Settings__c.getInstance('GSS_Partner_VCE').Record_Type_ID__c; 
      String vmwareVceCase = Record_Type_Settings__c.getInstance('GSS_CASE_VCE').Record_Type_ID__c;
      //End - 28-Jun-2016 - Jyolsna - CR-00138097  
      sourceTemplate=GSS_Agent_Template__c.getInstance('Resolution Information template').TemplateId__c;
      
      //CR-00096132 - Helptext changes start
      GSS_Agent_Field_Map__c symptomsRec = new GSS_Agent_Field_Map__c();
      GSS_Agent_Field_Map__c ITRRec = new GSS_Agent_Field_Map__c();
      symptomsRec = GSS_Agent_Field_Map__c.getInstance('Symptoms');
      ITRRec = GSS_Agent_Field_Map__c.getInstance('First Response Date');
      
      if(symptomsRec!=null){
        symptomsHelpText=symptomsRec.HelpText__c;
      }else{
        symptomsHelpText='';
      }
      
      if(ITRRec !=null){
        ITRHelpText=ITRRec.HelpText__c;
      }else{
        ITRHelpText='';
      }
      //CR-00096132 - Helptext changes End
        
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
      
      checkButtonVisibility();
      
      
      //CR-00026553 - Adding GSS_Product_Version__c in the query
      //CR-00025463 - Adding GSS_Resolution_Code_LS__c in the query
      cId = ApexPages.currentPage().getParameters().get('id');
      
      String NT = 'Internal Notes ' + GSS_Agent_Tab_Visibility__c.getInstance('Resolution Information').Tab_Name__c;//CR-00096132 : variable used to fetch correct comments according to tab name
      if(cId != null){
      //CR-00122294: added accountId and TSE_Synopsis__c
      //CR-00137136 : Adding GSS_Workaround_Available__c in the below query. 
      // BB-8 Project added Entitlementid in soql query
      ocase=[SELECT Id, priority,ownerId, GSS_Entitlement_Code__c,TSE_Synopsis__c,Technical_Contact_Email__c,Entitlementid, KB_SearchString__c,Technical_Contact_Name__c,AccountId,Account.Name,Technical_Contact_Phone__c, CaseNumber,RecordTypeId,ProductId, GSS_Vcat__c,GSS_Vsubcat__c,GSS_Vsubcat2__c,GSS_Issue_Type__c,GSS_Sub_Type__c,
        GSS_Sub_Type_notes__c,GSS_Partner__c,GSS_IsFeature_Available__c,GSS_Resolution__c,GSS_Resolution_Code__c,GSS_Feature__c,
        GSS_Symptoms__c,First_Response_Date__c,GSS_Is_Issue_Subtype_Active__c,GSS_Partner_Component__c,(select Id from SR_Comments__r where Notes_Type__c=:NT),
        GSS_Product_Version__c,GSS_Resolution_Code_LS__c, Product_Platform__c, Platform_Version_Other__c,Status, Sub_Status__c, GSS_Workaround__c,
        GSS_Workaround_Available__c,
        GSS_Partner_Compliance__c,GSS_Partner_Non_Compliance_Reasons__c,GSS_Duplicate_Case__c, Entitlement.GSS_Entitlement_Code__c,EA_Name__c,EA_Number__c, Entitlement.Name FROM Case
                 WHERE Id =:cId];//CR-00138253 Added EA_Name__c and EA_Number__c to Query CR-00138253-added query Entitlement.Name
        CaseID=ocase.Id;
        TechCon=ocase.Technical_Contact_Name__c;
        CaseNum=ocase.caseNumber;
        AccName=ocase.Account.Name;
        EAName=ocase.EA_Name__c;//CR-00138253
        EANumber=ocase.EA_Number__c;//CR-00138253
        accID=ocase.AccountId; //CR-00122294
        TechPhone=ocase.Technical_Contact_Phone__c;
        caseSynopsis=ocase.TSE_Synopsis__c;//CR-00122294
        entitlementName = ocase.Entitlement.Name;//CR-00140332
        showimage = false;
        //CR-00107561 - set showDuplicate based on case Sub status value
        if(ocase.Sub_Status__c=='Duplicate'){
          showDuplicate=true;
        } 
        //CR-00137136 - Start -Defaulting it to Breakfix if null
        //if(ocase.GSS_Workaround_Available__c ==null || ocase.GSS_Workaround_Available__c==''){
        //  this.ocase.GSS_Workaround_Available__c='Break/Fix';
        //} 
        //CR-00137136 - End
        
        strIssueType = ocase.GSS_Issue_Type__c;
        strVSubCat=ocase.GSS_Vsubcat__c;
        strVCat=ocase.GSS_Vcat__c;
        strSubType =ocase.GSS_Sub_Type__c;
        strPartner = ocase.GSS_Partner__c;
        strPartnerComponent=ocase.GSS_Partner_Component__c ;
        strProductVersion = ocase.GSS_Product_Version__c;   
        strPlatform= ocase.Product_Platform__c;
        strPlatformVersion= ocase.Platform_Version_Other__c;
        strSupportType = ocase.GSS_Workaround_Available__c; //CR-00137136
        
        if(ocase.SR_Comments__r.size()>0){
          showimage = true;
        }
        //CR-00107561: Added condition for VCE codes
        if(ocase.Entitlement.GSS_Entitlement_Code__c=='ASP' || (ocase.Entitlement.GSS_Entitlement_Code__c!=null && ocase.Entitlement.GSS_Entitlement_Code__c.startsWith('VCE'))){
          isASPCase = true;
        }
        
      //checking record type of the case
      Record_Type_Settings__c techSupport = Record_Type_Settings__c.getValues('GSS_CASE_TS');
      Record_Type_Settings__c csAdmin = Record_Type_Settings__c.getValues('GSS_CASE_CS');
      //CR-00135123 Sakshi Suri 6th'Jul'15 New record type "GSS Technical Support – PD" that mirrors GSS CS Admin Starts
      Record_Type_Settings__c tsPrsnlDsk=new Record_Type_Settings__c();
      if(Record_Type_Settings__c.getValues('GSS_CASE_TS_PD')!= null){
      tsPrsnlDsk = Record_Type_Settings__c.getValues('GSS_CASE_TS_PD');
      //CR-00135123 Sakshi Suri 6th'Jul'15 New record type "GSS Technical Support – PD" that mirrors GSS CS Admin Ends
      }
      Record_Type_Settings__c licensing = Record_Type_Settings__c.getValues('GSS_CASE_LIC'); 
      Record_Type_Settings__c sdp = Record_Type_Settings__c.getValues('GSS_CASE_SDP'); //BUG-00049185 added for SDP record type 
     
      if(ocase.RecordTypeId == techSupport.Record_Type_ID__c ){
        this.isTechSupport = true;
        this.isCSAdmin= false;
        this.isLicensing = false;
        this.isVceCase = false;//Added for CR-00138097 

      }
      else{
        if(ocase.RecordTypeId == csAdmin.Record_Type_ID__c || ocase.RecordTypeId == tsPrsnlDsk.Record_Type_ID__c){//CR-00135123 Sakshi Suri 6th'Jul'15 New record type "GSS Technical Support – PD" that mirrors GSS CS Admin 
          this.isTechSupport = false;
          this.isCSAdmin= true;
          this.isLicensing = false;
           this.isVceCase = false;//Added for CR-00138097
          }
    //Start - 28-Jun-2016 - Jyolsna - CR-00138097  
          else if(ocase.recordtypeId == partnerVceCase || ocase.recordtypeId == vmwareVceCase){
            this.isTechSupport = false;
            this.isCSAdmin= false;
            this.isLicensing = false;
            this.isVceCase = true;
          }
      //End - 28-Jun-2016 - Jyolsna - CR-00138097  
        else{
        //BUG-00049185 added or condition as Closecase for SDP should be similar to that of Licensing
           if(ocase.RecordTypeId == licensing.Record_Type_ID__c || ocase.RecordTypeId == sdp.Record_Type_ID__c ){
             this.isTechSupport = false;
             this.isCSAdmin= false;
             this.isLicensing = true;
             this.isVceCase = false;
             }
           }
         }
      
      
      // CR-00026553 Adding GSS_Version__c in the Query
      if (ocase.ProductId != null ) {    
        ProductObject =[SELECT Id,Name,GSS_Product_vCat__c, GSS_Vsubcat__c,GSS_Product_Issue_Type__c,GSS_Version__c,VFabric_Product__c  From Product2 Where Id =:ocase.ProductId];
        strProdId = productObject.Id;
        strProductName = productObject.Name;
        isVfabricProduct = productObject.VFabric_Product__c;//CR-00006747

          // Get issue type from product
          if (ProductObject.GSS_Product_Issue_Type__c != null && !''.equals(ProductObject.GSS_Product_Issue_Type__c)) {
            String[] temp = ProductObject.GSS_Product_Issue_Type__c.split(';');
            List<SelectOption> issueOptions = new List<SelectOption>();
            issueOptions.add(new SelectOption('', '--None--')); 
            issueOptions.add(new SelectOption('Non-Technical Support Issue', 'Non-Technical Support Issue'));
                     
            for(String temp1 : temp ) {
              issueOptions.add(new SelectOption(temp1.trim(),temp1.trim()));        
            }
            //issueOptions.add(new SelectOption('Request New Value', 'Request New Value'));
            strIssueTypeItems = issueOptions;    
            
            if(strVSubCat!=null){
                  refreshPartner();
                  refreshPartnerComponent();      
            }else{
              this.isPartnerVisible=false;        
            }
                    
            
            refreshSubType();
          }
          
          // Get version CR-00026553 Start
          if(productObject.GSS_Version__c != null && !''.equals(productObject.GSS_Version__c) && productObject.GSS_Version__c.contains('N/A')==false && productObject.GSS_Version__c.contains('NA')==false){
            this.isVersionRequired=true;
          }
          
          List<SelectOption> optionsV = new List<SelectOption>();
          if ( productObject.GSS_Version__c != null && !''.equals(productObject.GSS_Version__c)) {
            //this.isVersionRequired=true;
            String[] temp = productObject.GSS_Version__c.split(',');
            optionsV = new List<SelectOption>();
            optionsV.add(new SelectOption('', '--None--'));
            for(String temp1 : temp ) {
              optionsV.add(new SelectOption(temp1.trim(),temp1.trim()));        
            }
            strProductVersionItems = optionsV;
            strProductVersion = ocase.GSS_Product_Version__c;
          } // CR-00026553 end
          
           // Get vcat from product
          if ( ProductObject.GSS_Product_vCat__c != null && !''.equals(ProductObject.GSS_Product_vCat__c)) {
             List<SelectOption> options = new List<SelectOption>();

            options = new List<SelectOption>();
            String[] values = productObject.GSS_Product_vCat__c.split(';');
            
            options.add(new SelectOption('', '--None--'));                
      
            for(String value : values ) {
              options.add(new SelectOption(value.trim(),value.trim()));        
            }
      
            //options.add(new SelectOption('Request New Value', 'Request New Value'));
            strVCatItems = options;
            strVCat=ocase.GSS_Vcat__c;
            
            refreshVsubcatsValues();
          }
       
      } 
      }
      
      TabColor=GSS_Agent_Tab_Visibility__c.getInstance('Resolution Information').TabColor__c;//CR-00096132: Fetching Tab Colour from custom settings 
      
    }
    //start -  CR-00138097
    public void checkStatus(){
          
      }
      //End -  CR-00138097
    public Case getOcase() {
      return ocase;
    }

    /**
     * @param List: None
     * @return: void
     * Decsription : Refresh subtype depending upon the value in issue type
     *               Custom setting required : GSS_IssueTypeDependentPicklistValue
     **/

    public void refreshSubType(){

      List<SelectOption> IssueSubTypeOptions = new List<SelectOption>();
      IssueSubTypeOptions.add(new SelectOption('', '--None--'));

      

      // Get issue type to be searched in product issue type, from custom settings
      Populate_Product_Issue_Types_Values = GSS_Populate_Product_Issue_Types__c.getall().values();
      lstIssueTypesToSearch=new List<String>();
      for(GSS_Populate_Product_Issue_Types__c temp : Populate_Product_Issue_Types_Values){
        lstIssueTypesToSearch.add(temp.Issue_Type__c);
      }
      

      //Check whether selected issue type exists in List of issue types required to enable subtype.
      boolean blnIssueType=isStringInList(strIssueType,lstIssueTypesToSearch);

      

      if(blnIssueType==true){
        // if it is then Issue SubType, Issue SubType Notes editable
        isIssueSubTypeEditable=true;
        

      }
      else{
        // if it's not then don't make Issue SubType, Issue SubType Notes editable
        isIssueSubTypeEditable=false;
         

      }

      

      if(blnIssueType==true){

        ProductIssueTypeDependentPicklistValues = GSS_IssueTypeDependentPicklistValues__c.getall().values();
        If(strIssueType!=null && strIssueType!=''){
          for(GSS_IssueTypeDependentPicklistValues__c tempRecord : ProductIssueTypeDependentPicklistValues){
            
            if(tempRecord.Product_Issue_Type__c.equalsIgnoreCase(strIssueType)){
              
              if(tempRecord.Product_Issue_Type__c != null){
                if(tempRecord.Sub_Type__c != null){    
                  String[] temp = tempRecord.Sub_Type__c.split(';');
                  for(String temp1 : temp ) {
                    IssueSubTypeOptions.add(new SelectOption(temp1.trim(),temp1.trim()));        
                  }
                  //options.add(new SelectOption(tempRecord.Partner__c,tempRecord.Partner__c));
                }
              }
            }
          }
        }
          //IssueSubTypeOptions.add(new SelectOption('Request New Value', 'Request New Value'));
      }
      
      strSubTypeItems = IssueSubTypeOptions;
    }
    
    /**
     * @param List: string , List<String>
     * @return: boolean
     * Decsription : Check whether a string exists in list
     **/

    Public boolean isStringInList(string strSearchString , List<String> lstValues){
        
      if(lstValues!=null){        
        for(String str : lstValues){
          if(str!=null && str.equalsIgnoreCase(strSearchString)){
            
            return true;
          }
        }
      }
       
      return false;        
    }
    
    
    /**
     * @param List: None
     * @return: void
     * Decsription :  Refresh Vsubcat depending upon the value in issue type
     *                Custom setting required : GSS_Product_vCat_vSubcat_Dependency
     **/

    public void refreshVsubcatsValues()
    {
    
     
       // if Vcat is selected as 'Request New Value' disable vsubcat, hide partner & component. Else enable and show.
      if(strVCat!=null && strVcat.equalsIgnoreCase('Request New Value')==true){
        List<SelectOption> options = new List<SelectOption>();
         
        
        options.add(new SelectOption('', '--None--'));
        strVSubCatItems = options;
        isVSubCatDisabled=true;
        
        
        return;
      }else{
        isVSubCatDisabled=false;            
        
      }

      
      boolean isVcatInCustSet=false;
      
      List<SelectOption> options1 = new List<SelectOption>();
       
      
      if((strProductName!=null || !''.equals(strProductName))&& strVCat!=null)
      {  options1.add(new SelectOption('', '--None--'));
        List<GSS_Product_vCat_vSubcat_Dependency_List__c> lstVsubcat=[Select Product_vSubcat__c from GSS_Product_vCat_vSubcat_Dependency_List__c where Product_Name__c=:strProductName and Product_vCat__c = :strVCat limit 1];
        String Vsubcat;
        if(lstVsubcat.size()>0)
           Vsubcat  =  lstVsubcat[0].Product_vSubcat__c;
        if(Vsubcat!=null)
        {
          if(Vsubcat.contains(';'))
          {
            
            String []splitVsubcats=Vsubcat.split(';');
            for(String temp1:splitVsubcats)
            {
              options1.add(new SelectOption(temp1.trim(),temp1.trim()));
            }
          }else
          {
            
            options1.add(new SelectOption(Vsubcat.trim(),Vsubcat.trim()));
          }
           
           //options1.add(new SelectOption('Request New Value', 'Request New Value'));                  
          strVSubCatItems = options1;
          
        }
        else if(strProductName!=null && !strProductName.equals('')&&(Vsubcat==null || ''.equals(Vsubcat)))
        {
                 
          String VsubcatProduct=[Select GSS_Vsubcat__c from Product2 where name=:strProductName].GSS_Vsubcat__c;
          List<SelectOption> options2 = new List<SelectOption>();
          options2.add(new SelectOption('', '--None--'));
          if(VsubcatProduct!=null&& VsubcatProduct.contains(','))
          {
            String []splitVsubcats=VsubcatProduct.split(',');
            if(splitVsubcats.size()!=0)
            {
              for(String temp1:splitVsubcats)
              {
                options2.add(new SelectOption(temp1.trim(),temp1.trim()));
              }
            }else
            {
              options2.add(new SelectOption(VsubcatProduct.trim(),VsubcatProduct.trim()));  
            }
            //options2.add(new SelectOption('Request New Value', 'Request New Value'));
            strVSubCatItems = options2;
          }
        }               
      }
      else if((strProductName!=null || !''.equals(strProductName))&& (strVCat==null || ''.equals(strVCat)))
      {
        String Vsubcat=[Select GSS_Vsubcat__c from Product2 where name=:strProductName].GSS_Vsubcat__c;
        List<SelectOption> options2 = new List<SelectOption>();
        options2.add(new SelectOption('', '--None--'));
        if(Vsubcat!=null&& Vsubcat.contains(','))
        {
          String []splitVsubcats=Vsubcat.split(',');
          if(splitVsubcats.size()!=0)
          {
            for(String temp1:splitVsubcats)
            {
              options2.add(new SelectOption(temp1.trim(),temp1.trim()));
            }
          }else
          {
            options2.add(new SelectOption(Vsubcat.trim(),Vsubcat.trim()));  
          }
           //options2.add(new SelectOption('Request New Value', 'Request New Value'));
          strVSubCatItems = options2;
        }           
      }   
        
    }

    /**
     * @param List: None
     * @return: void
     * Decsription : Displays and Refreshes the Partner value based on VsubCat Selected
     **/

    public void refreshPartner(){
           // check whether VSubCat on case screen is one of the ProductPartnerVSubCat
           PartnerComponent_RelationList = GSS_PartnerComponent_Relation__c.getall().values(); 

      Product2 prodObject=[Select GSS_Partner_vSubcat__c From Product2 p where p.Id=:strProdId ];
      if ( prodObject.GSS_Partner_vSubcat__c != null && !''.equals(prodObject.GSS_Partner_vSubcat__c) ) {
        String[] values = prodObject.GSS_Partner_vSubcat__c.split(';');
        lstProductPartnerVSubCat = new List<String>();
        for(String value: values){
          lstProductPartnerVSubCat.add(value);
        }
         

      }
      boolean blnVSubCatInProductPartnerVSubcat=isStringInList(strVSubCat, lstProductPartnerVSubCat);

      // if it is then make partner and partner component visible
      if(blnVSubCatInProductPartnerVSubcat==true){

        MakePartnerVisible();

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));

        Set<String> uniqueValue = new Set<String>();
        

        If(strVSubCat!=null && strVSubCat!=''){
          for(GSS_PartnerComponent_Relation__c tempRecord : PartnerComponent_RelationList){
            
            if(tempRecord.vsubcat__c.equalsIgnoreCase(strVSubCat)){
              
              if(tempRecord.Partner__c != null && uniqueValue.contains(tempRecord.Partner__c)==false){
                uniqueValue.add(tempRecord.Partner__c);
                options.add(new SelectOption(tempRecord.Partner__c,tempRecord.Partner__c));
              }
            }
          }
        }
        //options.add(new SelectOption('Request New Value', 'Request New Value'));

        if(uniqueValue.isEmpty())
          isDisabledPartner = true;
        else
          isDisabledPartner = false;
        
        strPartnerItems = options;
      }
      else
        isPartnerVisible=false;
    }

    /**
     * @param List: None
     * @return: void
     * Decsription : This function will be executed when user selects VSubCat to check whether to 
     *  display the Partner and Partner Component fields 
     **/

    public void MakePartnerVisible(){
      if(isStringInList(strVSubCat,lstProductPartnerVSubCat)==true){
        isPartnerVisible=true;
        
      }
      else 
        isPartnerVisible=false;
    }
    
     /**
     * @param List: None
     * @return: void
     * Decsription : Displays and Refreshes the Partner component value based on Partner Selected
     **/

    public void refreshPartnerComponent(){
      PartnerComponent_RelationList = GSS_PartnerComponent_Relation__c.getall().values(); 

      // Check if Request New Value is selected on Partner. If yes disable partner component else keep enabled 
      if(strPartner!=null && strPartner.equalsIgnoreCase('Request New Value')){
        isPartnerComponentDisabled = false;
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('Request New Value', 'Request New Value'));
        options.add(new SelectOption('', '--None--'));
        strPartnerComponentItems = options;
        return;
      }
      else{
        isPartnerComponentDisabled = false;         
      }

      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('', '--None--'));

      Set<String> uniqueValue = new Set<String>();
      
      If(strPartner!=null && strPartner!=''){
        for(GSS_PartnerComponent_Relation__c tempRecord : PartnerComponent_RelationList){
          
          if(tempRecord.Partner__c.equalsIgnoreCase(strPartner)){
            
            if(tempRecord.Partner_Component__c!=null && uniqueValue.contains(tempRecord.Partner_Component__c)==false){
              uniqueValue.add(tempRecord.Partner_Component__c);
              options.add(new SelectOption(tempRecord.Partner_Component__c,tempRecord.Partner_Component__c));
            }
          }
        }
      }
      
           
      strPartnerComponentItems = options;
    }
    
       
    
    public pagereference redirectSalesConsole(){
      
       strCaseId = apexpages.currentpage().getparameters().get('id');
       if(isServiceCloud  == false){
        pagereference pr = new pagereference('/' + strCaseId + '?nooverride=1');
        pr.setRedirect(true);
        return pr;
      }
      return null;
      
    }
    
    public pagereference doEdit(){
      
       strCaseId = apexpages.currentpage().getparameters().get('id');
        pagereference pr = new pagereference('/e');
        pr.setRedirect(true);
        return pr;
      }
    
    
    //save function updates the case 
    public void savecase(){
     try{
      if(ocase.Sub_Status__c=='Close in 24 hours - No cust Resp'||ocase.Sub_Status__c=='Close in 24 hours - Resolved'||ocase.Sub_Status__c=='Close in 72 hours - No Cust Resp'||ocase.Sub_Status__c=='Close in 72 hours - Resolved')
      {
         closeSR();
      }
      else
      {
         this.showRequiredFields=false;    
      }
      ocase.GSS_Vcat__c=strVCat; 
      ocase.GSS_Vsubcat__c=strVSubCat;
      ocase.GSS_Issue_Type__c=strIssueType; 
      ocase.GSS_Sub_Type__c=strSubType; 
      ocase.GSS_Partner__c =strPartner;
      ocase.GSS_Partner_Component__c=strPartnerComponent;
      ocase.GSS_Product_Version__c=strProductVersion; 
      //ocase.GSS_Workaround__c =strworkaround;
      
      if(isIssueSubTypeEditable){
        ocase.GSS_Is_Issue_Subtype_Active__c=true;
      }else{
        ocase.GSS_Is_Issue_Subtype_Active__c=false;
      }

      update ocase;
      }catch(Exception ex){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage());
        if(!ex.getmessage().contains(Label.BB_8_Case_Sub_Status_Manual_Change_Error_Msg))
            ApexPages.addMessage(myMsg); 
      }
         
   
       
    }

    public void closeSR(){
      try{
        showRequiredFields=true;
        errorFound=false;
        //Start - CR-00135064 - Dalia Pan
        //System.debug('*******isTechSupport*******'+isTechSupport);
        String errorMessage = System.Label.GSS_Ultra_Resolution_Error_Message; //Error Messages for closing non- GSS Technical Support Cases.   
      Record_Type_Settings__c techSupportPD = Record_Type_Settings__c.getValues('GSS_CASE_TS_PD'); //GSS Technical Support – PD Record Type
      
        //Save with Status closed where the case is non-GSS Technical Support
//Added condition for vce case : CR-00138097 
        if(isVceCase == false && isTechSupport == false && ocase.RecordTypeId != techSupportPD.Record_Type_ID__c && (ocase.Status.contains('Closed') || ocase.Status =='Open/Close in 24 hours' || (ocase.Status == 'Open' && ocase.Sub_Status__c.contains('Close in')))){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
          errorFound=true;
        }else{
        //End - CR-00135064 - Dalia Pan
          //Error Messages for Resolution, resolution Code, Symptoms
          if(ocase.First_Response_Date__c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Intial Target Response Date is Required to Close the Case'));
            errorFound=true;
          }
                
          //Save Vcat or give error if blank

      //Added condition for vce case : CR-00138097 
          if(isVceCase == false){
              if(strVCat!=null && !''.equals(strVCat)){
                ocase.GSS_Vcat__c=strVCat; 
              }else{
                if(!isIssueSubTypeEditable){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Vcat is Required to Close the Case'));
                  errorFound=true;
                }
              }
          }
          
          //Save Vsubcat or give error if blank
    //Added condition for vce case : CR-00138097 
          if(isVceCase == false){
             
              if(strVSubCat!=null && !''.equals(strVSubCat)){
                ocase.GSS_Vsubcat__c=strVSubCat;
              }else{
                if(!isIssueSubTypeEditable && !isVSubCatDisabled){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Vsubcat is Required to Close the Case'));
                errorFound=true;
                }
              }
          }
          //CR-00136382 - START - Removing Issue Type & Sub Type validation from Page. 
          /*
          //Save Issue Type or give error if blank
          if(strIssueType!=null && !''.equals(strIssueType)){
            ocase.GSS_Issue_Type__c=strIssueType; 
          }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Issue Type is Required to Close the Case'));
            errorFound=true;
          }
          
          //Save Sub Type or give error if blank
          if(strSubType!=null && !''.equals(strSubType)){
            ocase.GSS_Sub_Type__c=strSubType; 
          }else{
            if(isIssueSubTypeEditable){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'SubType is Required to Close the Case'));
            errorFound=true;
            }
          }
          */
          //CR-00136382 - END
          
          //Save Partner or give error if blank
          //Added condition for vce case : CR-00138097 
           if(isVceCase == false){
              if(isPartnerVisible ){
                if(strPartner!=null && !''.equals(strPartner)){
                  ocase.GSS_Partner__c =strPartner; 
                }else{
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Partner is Required to Close the Case'));
                  errorFound=true;
                }
              }
           }
          //Save Partner Component or give error if blank
           //Added condition for vce case : CR-00138097 
           if(isVceCase == false){
              if(isPartnerVisible ){
                if(strPartnerComponent!=null && !''.equals(strPartnerComponent)){
                  ocase.GSS_Partner_Component__c=strPartnerComponent;
                }else{
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Partner Component is Required to Close the Case'));
                  errorFound=true;
                }
              }
           }
                
          //Save Version or give error if blank
          //Added condition for vce case : CR-00138097 
          if( isVceCase == false){
              if(strProductVersion!=null && !''.equals(strProductVersion)){
                ocase.GSS_Product_Version__c=strProductVersion;
              }else{
                if(isVersionRequired && (ocase.GSS_Product_Version__c==null || ocase.GSS_Product_Version__c=='')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Product Version is Required to Close the Case'));
                errorFound=true;
                }
              }
          } 
          //Error Messages for Resolution, resolution Code, Symptoms
          if(ocase.GSS_Resolution__c==null || ''.equals(ocase.GSS_Resolution__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Resolution is Required to Close the Case'));
            errorFound=true;
          }
          //CR-00136382 - START 
          //Removing Resolution Code validation from Page. 
          //Added Resolution Code for vce case : CR-00138097 
        if( isVceCase == true){
          if(ocase.GSS_Resolution_Code__c==null || ''.equals(ocase.GSS_Resolution_Code__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Resolution Code is Required to Close the Case'));
            errorFound=true;
          }
        }
        
      
      //CR-00136382 - END
      //CR-00137136 - Start
          //Adding Support Type validation from Page.
          //Added condition for vce case : CR-00138097 
          if(isVceCase == false){
              if((ocase.GSS_Workaround_Available__c == null || ''.equals(ocase.GSS_Workaround_Available__c)) 
                || (ocase.GSS_Workaround_Available__c != 'Break/Fix' 
                  && ocase.GSS_Workaround_Available__c != 'Break/Fix & RCA' 
                  && ocase.GSS_Workaround_Available__c != 'RCA Only' 
                  && ocase.GSS_Workaround_Available__c != 'Consultative – Customer' 
                  && ocase.GSS_Workaround_Available__c != 'Consultative – VMware' 
                  && ocase.GSS_Workaround_Available__c != 'No Support Required' 
                  && ocase.GSS_Workaround_Available__c != 'Feature Request')){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Support Type is Required to Close the Case'));
                errorFound=true;
              }
          }
      //CR-00137136 - End   
          if(ocase.GSS_Symptoms__c==null || ''.equals(ocase.GSS_Symptoms__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Symptoms is Required to Close the Case'));
            errorFound=true;
          }
         
          
          if(isIssueSubTypeEditable){
            ocase.GSS_Is_Issue_Subtype_Active__c=true;
          }else{
            ocase.GSS_Is_Issue_Subtype_Active__c=false;
          }
          
          //Error message for status other than closed
          if(isVceCase == false){
              if(ocase.status!='Closed'&& !(ocase.Sub_Status__c=='Close in 24 hours - No cust Resp'||ocase.Sub_Status__c=='Close in 24 hours - Resolved'||ocase.Sub_Status__c=='Close in 72 hours - No Cust Resp'||ocase.Sub_Status__c=='Close in 72 hours - Resolved')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Status should be changed to close manually to close the case'));
                errorFound=true;
              }
          }
          else{
              if((ocase.status!='Closed' && ocase.status!='Closed - Resolved')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Status should be changed to close manually to close the case'));
                errorFound=true;
              }
          }
          //Error Message when sub status is not selected
           //Added condition for vce case : CR-00138097 
           if(isVceCase == false){
                if(ocase.sub_status__c==null ||''.equals(ocase.sub_status__c)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Sub Status is required to close the case'));
                    errorFound=true;
                }
        //Start - 28-Jun-2016 - CR-00138097 
           }else{
                if(ocase.status == 'Closed' && (ocase.sub_status__c==null ||''.equals(ocase.sub_status__c))){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Sub Status is required to close the case'));
                    errorFound=true;
                }
           }
       //End - 28-Jun-2016 - CR-00138097 
          //Error Messages for Vfabric products. Product Platform and Platform version.
     //Added condition for vce case : CR-00138097 
          if(isVceCase == false){
              if(isVfabricProduct && (ocase.Product_Platform__c==null || ''.equals(ocase.Product_Platform__c))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Product Platform is required to close the case'));
                errorFound=true;
              }
              if(isVfabricProduct && (ocase.Platform_Version_Other__c==null ||''.equals(ocase.Platform_Version_Other__c))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Platform Version is required to close the case'));
                errorFound=true;
              }
          }
          
          //Error Messages for Partner Compliance
          if(isASPCase && 'No'.equalsIgnoreCase(ocase.GSS_Partner_Compliance__c) && (ocase.GSS_Partner_Non_Compliance_Reasons__c==null || ''.equals(ocase.GSS_Partner_Non_Compliance_Reasons__c))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'If Partner Compliance is No then Partner Non Compliance Reasons should be filled'));
            errorFound=true;
          }
           //Start - 28-Jun-2016 - : CR-00138097 
          if(isVceCase && isASPCase && ocase.GSS_Partner_Compliance__c== null ||ocase.GSS_Partner_Compliance__c ==''){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Partner Compliance Checklist must be complete to close this case'));
            errorFound=true;    
          }
          //End - 28-Jun-2016 - : CR-00138097 
          //Error Message for duplicate Substatus
          if(ocase.sub_status__c=='Duplicate' && (ocase.GSS_Duplicate_Case__c==null || ''.equals(ocase.GSS_Duplicate_Case__c))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Duplicate Case number is required to close this case'));
            errorFound=true;
          }
          
          // CR-00123270 - start
          // Error message if assist requests are not closed
          List<GSS_Request__c> clist  = [SELECT Id, GSS_Status__c FROM GSS_Request__c WHERE GSS_Case_Number__c =: CaseId AND RecordType.Name ='Assist Request' AND GSS_Status__c != 'Closed - Complete' AND GSS_Status__c != 'Closed' AND GSS_Status__c !='Closed - Invalid']; 

          if(clist.size()>0){ 
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Case cannot be closed if it has open assist request/s'));
          errorFound=true;
          }
          // CR-00123270 - end
          
          // Code start for BB-8 Project
             
              Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
              Set<String> entNameSet = new Set<String>();
              
               for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
                        // Pick all active premier entitlements
                        if(entObj.isActive__c  ){
                            
                            entNameSet.add(entObj.code__c);
                        }
                }
          
          
             
              if((!String.isBlank(CaseId))&& entNameSet.contains(ocase.GSS_Entitlement_Code__c)){
                  
                  Map<String , BB_8_SLA_integration_fields__c > fieldsNameRecords = BB_8_SLA_integration_fields__c.getAll();
                  List<string> ActiveFields = new List<string>();
                  string query = 'select id,case__c';
                  for(BB_8_SLA_integration_fields__c fieldsName : fieldsNameRecords.values()){
                        // Pick all active premier entitlements
                        if((fieldsName.Is_Active__c) && (fieldsName.Entitlement_Code__c == ocase.Entitlement.GSS_Entitlement_Code__c) && (!fieldsName.Is_Target_Date__c) && ocase.priority != null && fieldsName.Case_Priorities__c != null && fieldsName.Case_Priorities__c.containsIgnoreCase(ocase.priority) && fieldsName.Eligible_For_Case_Closure_Validation__c){
                            
                            query = query+','+fieldsName.Field_API_Name__c;
                            ActiveFields.add(fieldsName.Field_API_Name__c);
                        }
                  }
                  
                  query = query + ' from case_SLA__c where case__c = \''+CaseId+'\'';
                  List<case_SLA__c> caseMilestoneList;
                   system.debug('Query '+query);
                  if(fieldsNameRecords.size()>0){
                      
                      caseMilestoneList=database.query(query);
                  }
                  
                  system.debug('Query '+query);
                  
                
                for(Case_SLA__c  CML:caseMilestoneList){
                    for(string fieldsName : ActiveFields){
                    system.debug('FieldName '+CML.get(fieldsName));
                        if(CML.get(fieldsName) == null){
                            system.debug('Error 1');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.BB8_case_closure_error_msg));
                            errorFound = true;
                        }
                    }
                }
              }
              
          
          // Code end for BB-8 Project
          if(!errorFound){                
            closeSuccess=true;//CR-00107561
            update ocase;
          }
        } //CR-00135064 : closing bracket
        
        //URL for the close case page
      }catch(Exception ex){
         closeSuccess=false;//CR-00107561
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage());
         ApexPages.addMessage(myMsg); 
      } 
    

    }
    
    public void checkButtonVisibility(){
      
      for(GSS_Agent_Button_Map__c button: [select Name, Label__c from GSS_Agent_Button_Map__c where Resolution_Information__c=true]){
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
        //CR-00107561 - ends
        //CR-00122294 - starts
        if(button.name=='Audit History'){
          isHistoryVisible=true;
          HistoryLabel=button.Label__c;
        }
        //CR-00122294 - ends                  

      }
    
    }

  }