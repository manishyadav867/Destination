/*********************************************************************
* Class Name : GSS_Agent_Additional_Info_Controller
* Purpose    : Controller for Action Page
*              
* Author            Date            Comments        
* Accenture     6-April-2014        GSS Agent Console Project
* Accenture     11-July-2014        CR-00096132: GSS optimization 2.0
* Accenture     12-Sept-2014        CR-00107561: Adding SR Links button
* Accenture     20-Nov-2014         CR-00109419: Adding Request Related List
* Accenture     22-dev-2014         CR-00122294: code to add Audit history button
* Accenture     22-Mar-2016         CR-00138250: Adding Echo Related List  
* Accenture     7-Apr-2016          CR-00138257: Add ability to add multiple partner contact information 
* Accenture     1-jun-2016          CR-00138831: show the owner of the Request  in related request section
* Accenture     27-Jul-2016         CR-00139057: Ability to Delete Partner Information 
* ********************************************************************/

public class GSS_Agent_Additional_Info_Controller {

    public List<wrapperClass> wrapperList {get;set;}
    private final Case cs;
    public string strCaseId;
    public String CaseID{get;set;}
    public list<CaseTeamMember> lstcaseteammembers {get;set;}
    public Id cId{get;set;}
    public boolean showimage{get;set;}
    public String styleFieldWidth{get;set;}
    
    public string sourceTemplate{get;set;}
    //CR-00109419 : Request Id variables
    public Id assistId{get;set;}
    public Id promoteId{get;set;}
    public Id nonAlertId{get;set;}
    public Id escalationId{get;set;}
    //CR-00109419 : Request Id variables ends
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
    public string TabColor{get;set;} //CR-00096132 : For UI changes
    
    public List<GSS_Technical_Contact__c> PtnrContactList{get;set;} //CR-00138257
    public List<GSS_Request__c> RecordRequests{get; set;} //CR-00109419
    public List<Echo__c> RecordEcho{get; set;}//CR-00138250
    //Start for SR Team Related list in Additional Tab
    public List<WrapperTeamMember> lstWrapperTeamMember{get;set;}
    public String RecIDeletedd{get;set;}
    public String PreDefinedCTDelete{get;set;}
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
    public Boolean isServiceCloud=false;
  
    public GSS_Agent_Additional_Info_Controller(ApexPages.StandardController controller) {
    //CR-00096132 : Added Try catch block
    try{
        
        cId = ApexPages.currentPage().getParameters().get('id');
       if(!test.isrunningtest()){
        controller.addFields(editableFields);
       } 
        this.cs = (Case)controller.getRecord();
        if(apexpages.currentpage().getparameters().get('isdtp') == 'vw'){
            isServiceCloud = true;
        }
        
        sourceTemplate=GSS_Agent_Template__c.getInstance('Additional Information template').TemplateId__c;
            
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

        PtnrContactList=getPtnrContactList();//CR-00138257
        
        Case ocase;
        String NT = 'Internal Notes ' + GSS_Agent_Tab_Visibility__c.getInstance('Additional Information').Tab_Name__c; //CR-00096132 : variable used to fetch correct comments according to tab name
        if(cs.Id<>null){ 
            ocase = [SELECT Id,(select Id from SR_Comments__r where Notes_Type__c=:NT) from Case WHERE Id =:cs.ID];

            showimage = false;
            if(ocase.SR_Comments__r.size()>0){
                showimage = true;
            }
        }
        styleFieldWidth='220';
        RecordRequests=getRecordRequests(); //CR-00109419
        RecordEcho=getRecordEcho();//CR-00138250
        TabColor=GSS_Agent_Tab_Visibility__c.getInstance('Additional Information').TabColor__c; //CR-00096132: Fetching Tab Colour from custom settings
        //CR-00109419 : setting Ids
        assistId=Schema.SObjectType.GSS_Request__c.getRecordTypeInfosByName().get('Assist Request').getRecordTypeId();
        promoteId=Schema.SObjectType.GSS_Request__c.getRecordTypeInfosByName().get('Promote Request').getRecordTypeId();
        nonAlertId=Schema.SObjectType.GSS_Request__c.getRecordTypeInfosByName().get('Non-Alert Request').getRecordTypeId();
        escalationId=Schema.SObjectType.GSS_Request__c.getRecordTypeInfosByName().get('Escalation Request').getRecordTypeId();
        //CR-00109419 ends
       }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on loading page. Please contact your System Administrator.');
            ApexPages.addMessage(myMsg); 
        }
     }
     
    public List<WrapperTeamMember> getDetail(){
        
        lstcaseteammembers = new list<CaseTeamMember>();
        list<CaseTeamTemplateRecord> lstpredefinedcaseteam = new list<CaseTeamTemplateRecord>();
        list<CaseTeamMember> lstmemberscaseteams = new list<CaseTeamMember>();
        lstWrapperTeamMember=new List<WrapperTeamMember>();
        
        Schema.DescribeSObjectResult dsrcon = Contact.SObjectType.getDescribe();
        String objPrefixContact = dsrcon.getKeyPrefix();
        Schema.DescribeSObjectResult dsruser = User.SObjectType.getDescribe();
        String objPrefixUser = dsruser.getKeyPrefix();
        lstcaseteammembers = [select MemberId, TeamRole.Name,TeamRole.PreferencesVisibleInCSP,TeamRole.AccessLevel,LastModifiedById,LastModifiedBy.Name,TeamTemplateMemberId from CaseTeamMember where ParentId =: cId];
        
        
        if(lstcaseteammembers!=null && !lstcaseteammembers.isEmpty()){
        for(CaseTeamMember objcaseteammember:lstcaseteammembers ){
                    if(objcaseteammember.TeamTemplateMemberId == null){
                        lstmemberscaseteams.add(objcaseteammember);
                    }               
                }
            }
            
            
            
        lstpredefinedcaseteam = [select id,TeamTemplateId,TeamTemplate.Name,TeamTemplate.Description,TeamTemplate.LastModifiedById,TeamTemplate.LastModifiedBy.Name from CaseTeamTemplateRecord where ParentId=:cId];
        
        
        
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
      
        Map<Id,Contact> mapContact=new Map<Id,Contact>([Select Id,LastName,FirstName from Contact where id in:setContactId]);
        Map<Id,User> mapUser=new Map<Id,User>([Select Id,UserName,Name from User where id in:setuserId]);

     
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
    
      public List<String> editableFields {
        
        get{
            wrapperList = new List<wrapperClass>();

            List<GSS_Agent_Field_Map__c> caseFields = [select Label__c,Field_API_Name__c,Read_Only__c,Order__c,style__c,Required__c,Name,HelpText__c from GSS_Agent_Field_Map__c where isActive__c=true and Tab_Name__c='Additional Information' order by Order__c];
            
            editableFields = new List<String>();
         
            for(integer i=0;i<caseFields.size();i++){

                wrapperClass wrapperObj = new wrapperClass(); 
                editableFields.add(caseFields[i].Field_API_Name__c);
                wrapperObj.fieldName = caseFields[i].Field_API_Name__c;
                wrapperObj.label = caseFields[i].Label__c;
                wrapperObj.helpText= caseFields[i].helpText__c;
                wrapperObj.required = caseFields[i].required__c;
                wrapperObj.style = caseFields[i].style__c;
                wrapperObj.readOnly= caseFields[i].Read_Only__c;
                wrapperList.add(wrapperObj);

            }
            return editableFields;
        }
        private set;
    }
    
    public void checkButtonVisibility(){
        
        for(GSS_Agent_Button_Map__c button: [select Name, Label__c from GSS_Agent_Button_Map__c where Additional_Information__c=true]){
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
    
    //CR-00109419 Starts
    public List<GSS_Request__c> getRecordRequests(){
        try{
            if(cId != null){
                RecordRequests= [SELECT Id,GSS_Case_Number__c, GSS_Alert_Level__c, GSS_Actions_Taken__c, GSS_Is_Esc__c, GSS_Knowledge_Gap_Area__c, RecordType.Name, Name, GSS_Status__c, GSS_Action_Required__c,GSS_Highest_Alert_Level__c,GSS_List__c, Owner.Name, ownerId FROM GSS_Request__c where GSS_Case_Number__c= :cId];//CR-00138831 added Owner.Name in query
            }
            return RecordRequests;
        }
        catch(Exception e){
            //Added Error handling code
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error in fetching Requests Records. Please contact your System Administrator.');
            ApexPages.addMessage(myMsg); 
            return null;   
        }
    }
    //CR-00109419 Ends
   
    // CR-00138250 Starts
    public List<Echo__c> getRecordEcho(){
    System.debug('Enterned Echo Method');
        try{
            if(cId != null){
            System.debug('********CID!=null********'+cId);
                RecordEcho= [SELECT Call_Duration__c,Gss_Abandonment_Time__c,Gss_CN__c,Gss_Location__c,Gss_Reason_Code__c,Case_Abandon__c,Id,Name,Notes__c,Gss_Email_Address__c FROM Echo__c where Case_Abandon__c= :cId];
            }
        System.debug('********RecordEcho*********'+RecordEcho);
            return RecordEcho;
        }
        catch(Exception e){
            //Added Error handling code
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error in fetching Requests Records. Please contact your System Administrator.');
            ApexPages.addMessage(myMsg); 
            return null;   
        }
    }
   // CR-00138250 Ends
    public class wrapperClass{
         public string fieldName{get;set;}
         public string label{get;set;}
         public string helpText{get;set;}
         public string style{get;set;}
         public boolean readOnly{get;set;}
         public boolean required{get;set;}                 
    
    }
    
    public PageReference savecase() {
        try{
            
            update cs;
            setPCList(); //CR-00138257
           
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getmessage());
            ApexPages.addMessage(myMsg); 
        }
        
        return null;
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
   
    //CR-00138257 Starts Sakshi
   public void setPCList(){
        PtnrContactList=getPtnrContactList();
    }
   
   public List<GSS_Technical_Contact__c> getPtnrContactList(){
        PtnrContactList= [Select Additional_Technical_Contact_Name__c,GSS_Third_Party_Email_Phone__c,GSS_Third_Party_Ticket__c, Case__c, CreatedDate,IsPartnerContact__c from GSS_Technical_Contact__c where Case__c=:cs.ID And IsPartnerContact__c=true order by CreatedDate Desc];
        if(PtnrContactList.size()>0){
        List<GSS_Technical_Contact__c> PtnrContactList2=removeDuplicates(PtnrContactList);
        return PtnrContactList2;
        }
        else{return PtnrContactList;}
    }
   
   public List<GSS_Technical_Contact__c> removeDuplicates(List<GSS_Technical_Contact__c> tList){ 
        List<GSS_Technical_Contact__c> deleteDuplicateContList = new List<GSS_Technical_Contact__c>();// Added by Jyolsna - CR-00139057
        try{
            for(Integer i=0;i<tList.size();i++){
                  String str1=tList[i].Additional_Technical_Contact_Name__c+tList[i].GSS_Third_Party_Email_Phone__c+tList[i].GSS_Third_Party_Ticket__c;
                    for(Integer j=0;j<tList.size();j++)
                    {
                       String str2=tList[j].Additional_Technical_Contact_Name__c+tList[j].GSS_Third_Party_Email_Phone__c+tList[j].GSS_Third_Party_Ticket__c;
                       if(str1.equals(str2)&&j!=i)
                       {
                           deleteDuplicateContList.add(tList[j]);// Adding duplicate records to list - Jyolsna - CR-00139057 
                           tList.remove(j);
                           j--;
                           continue;
                       }                     
                    }
            }
            //Start - Jyolsna - CR-00139057 - deleting duplicate records
            if(deleteDuplicateContList != null && !deleteDuplicateContList.isEmpty()){
                delete deleteDuplicateContList;
            }
        }catch(Exception ex){
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Agent_Additional_Info_Controller', 'getPtnrContactList');
        }
        //End - Jyolsna - CR-00139057 - deleting duplicate records
        return tList;         
                   
    }
    //CR-00138257  Ends Sakshi
    
    //Start - Jyolsna - CR-00139057 - to delete Partner Information
    public void deleteTechCont(){
        try{
            String partContId = System.CurrentPageReference().getParameters().get('idToDel');
            List<GSS_Technical_Contact__c> delContList = new List<GSS_Technical_Contact__c>();
            Decimal i = 0;
            List<GSS_Technical_Contact__c> currentTechContList = [select id,Additional_Technical_Contact_Name__c,GSS_Third_Party_Email_Phone__c,GSS_Third_Party_Ticket__c, Case__c, CreatedDate,IsPartnerContact__c from GSS_Technical_Contact__c where Case__c=:cs.ID And IsPartnerContact__c=true order by CreatedDate Desc];
            if(currentTechContList != null && !currentTechContList.isEmpty()){
                Decimal j;
                for(GSS_Technical_Contact__c cont:currentTechContList ){
                    if(cont.id.equals(partContId)){
                        j=i;
                        delContList.add(cont);
                        break;
                    }
                    i++;
                }
                if(currentTechContList.size()==1 && delContList != null && !delContList.isEmpty()){
                    cs.GSS_Third_Party_Email_Phone__c = null;
                    cs.GSS_Third_Party_Contact_Name__c = null;
                    cs.GSS_Third_Party_Ticket__c = null;
                }
                else if(j==0){
                    cs.GSS_Third_Party_Email_Phone__c = currentTechContList[1].GSS_Third_Party_Email_Phone__c;
                    cs.GSS_Third_Party_Contact_Name__c = currentTechContList[1].Additional_Technical_Contact_Name__c;
                    cs.GSS_Third_Party_Ticket__c = currentTechContList[1].GSS_Third_Party_Ticket__c;
                }
            }
            if(delContList != null && !delContList.isEmpty()){
                delete delContList;
                savecase();
            }
        }catch(Exception ex){
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Agent_Additional_Info_Controller', 'deleteTechCont');
        }
    }
    //End - Jyolsna - CR-00139057 - to delete Partner Information
}