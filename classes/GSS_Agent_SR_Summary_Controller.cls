/*********************************************************************
* Class Name : GSS_Agent_SR_Summary_Controller
* Purpose    : Controller for Action Page
*              
* Author            Date            Comments        
* Accenture     6-April-2014        GSS Agent Console Project


CR-00096132
Purpose: 1. To show Public comments in Call Outbound/Call Inbound and Webex filters(created during webex session).
         2. To show Call Outbound /Call inbound (created during webex session) in Webex filters.
Author:  Manu Sharma
Date :   11-July-2014
Accenture     8-Sept-2014         CR-00104420 : Update to non public case comments
Accenture     24-Sept-2014   CR-00107561 : Fix for Collection size error(Max 1000 records can be shown)
Accenture     20-Oct-2014    CR-00110761 : Adding Short description throughout the code.
Accenture     26-Dec-2014    CR-00116268 : OPtimizing History tab. Changes made throughout the code.
Accenture     26-Dec-2014    CR-00123420 : HTML to TEXT code for Emailbody. Added SAP to History
Accenture     01-Apr-2015    CR-00130456 : Filter retains value code added and DisplayAll functionality updated
Accenture     20-Apr-2015    CR-00132166 : Filter fixes during page navigation.
Accenture     6-Aug-2015     CR-00134278 : Added Name and Timestamp in popup for Email
Accenture     21-Apr-2016    CR-00138260 : History filters functionality (check all when entering history and uncheck when not wanted)
Accenture     22-Apr-2016    CR-00138263 : Adding Audit History information to History page
Accenture     05-May-2016    CR-00134277 : Adding Log Analysis information to History page
Accenture     20-Jun-2016    CR-00138097 : Added filters VCE Task, VCE Note,VCE Attachment
Accenture     20-july-2016   CR-00140144 : displaying the correct username in Audit history
Accenture     28-july-2016   CR-00139056 : All the filters on the History tab of VMStar Ultra have to be checked by default
* ********************************************************************/

public class GSS_Agent_SR_Summary_Controller{

    public Integer value{get;set;}
    public String fetchId2{get;set;}    
    public Integer popupLength{get;set;}    
    public String plusminuscheck{get;set;}    
    public String displayAll{get;set;}    
    public integer outboundEmailCount{get;set;}
    public integer inboundEmailCount{get;set;}
    public integer outboundCallCount{get;set;}
    public integer inboundCallCount{get;set;}
   
    public integer SRCommentsCount{get;set;}
    public integer publicCommentsCount{get;set;}
    
    public String expandObjectType{get;set;}//Pabitra

    public GSS_Agent_Variables__c prfID=GSS_Agent_Variables__c.getOrgDefaults();//CR-00138263
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097
    public String partnerVceCase = Record_Type_Settings__c.getInstance('GSS_Partner_VCE').Record_Type_ID__c; 
    public String vmwareVceCase = Record_Type_Settings__c.getInstance('GSS_CASE_VCE').Record_Type_ID__c;
    public Id vceTaskRecordTypeId = VCEStatic__c.getInstance('VCETaskRecordType').Value__c; 
    public boolean isVceProfile {get;set;}
    //End - 20-Jun-2016 - Jyolsna - CR-00138097
    public void setplusminus(){
        this.plusminuscheck='true';
    }

    public Id id{get;set;}
    public transient List<wrapperClass> wlist{get;set;}
    public List<wrapperClass> wlistWithLimit{get;set;} //CR-00107561
    public String fetchId{get;set;}
    public String fetchType{get;set;}
    public String linkRecordId{get;set;}
    public String linkRecordType{get;set;}
    public String objectType{get;set;}

    public String[] listtypes=new String[]{};
        
    public String[] getListtypes() {
        return listtypes;
    }

    public void setListtypes(String[] listtypes) {
        this.listtypes= listtypes;
    }

    public String checkType{get;set;}
    public String checkValue{get;set;}
    public String emailCheck{get;set;}
    public String webexCheck{get;set;}
    public String meetingCheck{get;set;}
    public String callCheck{get;set;}
    public String commentCheck{get;set;}
    public String attachmentCheck{get;set;}
    public String ikbCheck{get;set;}
    public String prCheck{get;set;}
    public String sapCheck{get;set;}//CR-00123420 
    public String othersCheck{get;set;}
    public String ikburl{get;set;}  
    public String prURL{get;set;}
    public String prID{get;set;} 
    public String auditCheck{get;set;} //CR-00138263
    public String laCheck{get; set;} //CR-00134277
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097
    public String vceAttCheck{get; set;} 
    public String vceNoteCheck{get; set;} 
    public String vceTaskCheck{get; set;}
    //End - 20-Jun-2016 - Jyolsna - CR-00138097
    public Integer count=0;

    transient List<task> tList{get;set;}
    transient List<attachment> aList{get;set;}
    transient List<GSS_File_Attachment__c> gList{get;set;}
    transient List<CaseComment> cList{get;set;}
    transient List<GSS_Case_Knova__c> iList{get;set;}
    transient List<GSS_Case_BugZilla__c> pList{get;set;}
    transient List<SR_Comments__c> sList{get;set;}
    transient List<EmailMessage> eList{get;set;}
    transient List<GSS_SAP_History__c> sapList{get;set;}//CR-00123420 
    transient List<CaseHistory> auditList{get;set;}//CR-00138263
    transient List<SR_Comments__c> laList{get;set;}//CR-00134277
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097
    transient List<VCE_Attachment_Link__c> atList{get;set;}
    transient List<VCE_Case_Note__c> noteList{get;set;}
    transient List<Task> taskList{get;set;}
    //End - 20-Jun-2016 - Jyolsna - CR-00138097
    
    //CR-00107561 starts
    public integer callManualCount{get;set;}
    public integer emailCount{get;set;}
    public integer webexCount{get;set;}
    public integer callCount{get;set;}
    public integer commentsCount{get;set;}
    public integer attachmentCount{get;set;}
    public integer iKBCount{get;set;}
    public integer PRCount{get;set;}
    public integer othersCount{get;set;}
    public integer sapCount{get;set;}//CR-00123420 
    public integer laCount{get;set;}//CR-00134277
    //CR-00107561 ends
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097
    public integer vceAttCount{get;set;}
    public integer vceNoteCount{get;set;}
    public integer vceTaskCount{get;set;}
    //End - 20-Jun-2016 - Jyolsna - CR-00138097
    public integer auditCount{get;set;}//CR-00138263
    public boolean disable{get;set;}
    //CR-00110761: variables for pagination
    public integer shortDescLength{get;set;}
    public integer pagesize{get;set;}
    public integer currentPage{get;set;}
    public integer startCount{get;set;}
    public integer endCount{get;set;} 
    public boolean isPreviousAvailable{get;set;}
    public boolean isNextAvailable{get;set;} 
    //CR-00110761: variables for pagination ends    
   
    //CR-00134278 Sakshi Suri Added Name and timestamp in popup Starts
    public String localFormmattedDate{get; set;}
    public Date dateval{get;set;}
    public String custTimeVal ;
    public string timeVal{get; set;}
    //CR-00134278 Sakshi Suri Added Name and timestamp in popup Ends
    public GSS_Agent_SR_Summary_Controller(ApexPages.StandardController controller) {
    //CR-00110761 starts
    currentPage=1;
    isPreviousAvailable=false;
    isNextAvailable=false;
    //CR-00110761 ends
    
    
    expandObjectType='CaseComments';//Pabitra
    
    GSS_Agent_Variables__c agentVars;
        try{
        agentVars= GSS_Agent_Variables__c.getOrgDefaults();             
        prURL=agentvars.prurl__c;         
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'prURL : field not not found.Please contact your system administrator.');
            ApexPages.addMessage(myMsg); 
        }
        
        try
        {
        id=apexpages.currentpage().getparameters().get('id');
        }
        catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Case Id Found.Please contact your system administrator.');
           ApexPages.addMessage(myMsg); 
        }
        
        try{
            popupLength= Integer.valueOf(agentVars.popupLength__c);
            pagesize=Integer.valueOf(agentVars.Records_per_page__c); 
            shortDescLength=Integer.valueOf(agentVars.Short_Description_Length__c);                        
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'PopUp Length or Page Size or Short description length not found.Please contact your system administrator.');
            ApexPages.addMessage(myMsg); 
        }
        if(pagesize==null || pagesize<0 || pagesize>1000){
            pagesize=1000;
        }
        if(shortDescLength==null){
            shortDescLength=120;
        }
        /**********************CR-00138097 Starts*********************/ 
        Case ocase;
        if(Id != null){ 
            ocase = [SELECT Id,recordtypeId from Case WHERE Id =:Id];
        } 
        isVceProfile = false;
        Map<String, GSS_Profile_Functionality_Configurations__c> allVceProfile = Gss_ProfileUtility.getProfileIdAndName('Ultra_VCE_Permission__c');
        if((allVceProfile != null && allVceProfile.containsKey(UserInfo.getProfileId())) && (ocase != null) && (ocase.recordtypeId == partnerVceCase || ocase.recordtypeId == vmwareVceCase)){
            isVceProfile = true;
            
        }
        /*******************CR-00138097 Ends************************/   
        setData();
        displayList();
        this.plusminuscheck='false';
        //CR-00139056 starts
        listtypes=new String[]{'emailCheck','webexCheck','callCheck','commentCheck','attachmentCheck','ikbCheck','prCheck','othersCheck','sapCheck','laCheck'};  
        //CR-00139056 ends  
    //CR-00138260 Starts
    //CR-00134277 - Added laCheck to the List
    //CR-00138097 - Added vceAttCheck,vceNoteCheck
    if(UserInfo.getProfileId()==prfID.PremeirProfileId__c){
        String [] additionalTab = new String[]{'auditCheck','vceAttCheck','vceNoteCheck','vceTaskCheck'};
        listtypes.addAll(additionalTab);
    } 
      //CR-00138260 Ends 
    }
            
    public void DisplayAllRecords()
    {
     
    if(UserInfo.getProfileId()!=prfID.PremeirProfileId__c){
    auditCheck='false';
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097 - display vce attachment, vce note filters to GSS Premier service profile only
    vceAttCheck='false';
    vceNoteCheck='false';
    vceTaskCheck='false';
    //End - 20-Jun-2016 - Jyolsna - CR-00138097 - display vce attachment, vce note filters to GSS Premier service profile only
    }    
        //listtypes=new //String[]{'emailCheck','webexCheck','callCheck','commentCheck','attachmentCheck','ikbCheck','prCheck','othersCheck','sapCheck'}; 
        //setCheck();
        //CR-00130456: Added code to uncheck checkboxes on display all
        listtypes=new String[]{};  
        emailCheck='true';
        webexCheck='true';
        meetingCheck='true';
        callCheck='true';
        commentCheck='true';
        attachmentCheck='true';
        ikbCheck='true';
        prCheck='true';
        othersCheck='true';
        sapCheck='true';
        auditCheck='true';//CR-00138263 
        laCheck='true';//CR-00134277 : Added laCheck 
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
        vceAttCheck='true';
        vceNoteCheck='true';
        vceTaskCheck='true';
    //End - 20-Jun-2016 - Jyolsna - CR-00138097 
        displayList();
       
    }
    
    public void RefreshList()
    {
        setData();
        displayList();
    }
    
    

    public String searchCheck(String check){
    
        Integer flag=0;

        for(String str:listtypes){
            if(str==check){
                flag=1;
                break;
            }
        }
        if(flag==1){            
            return 'true';
        }
        else{            
            return 'false';
        }
    }

    public void setLinkType(){
    try{
        task t;
        casecomment c; 

        if(objectType=='task'){
            
            for(task t1:this.tList){
                if(t1.id==linkRecordId){
                  t=t1;  
                }
            }

            if(linkRecordType=='true'){
                t.IsVisibleInSelfService=false;
                update t;
            }
            else if(linkRecordType=='false'){
                t.IsVisibleInSelfService=true;
                update t;
            }
        }
        else if(objectType=='CaseComments'){
            
            for(casecomment c1:this.cList){
                if(c1.id==linkRecordId){
                  c=c1;  
                }
            }
            if(linkRecordType=='true'){
                c.ispublished =false;
                update c;
            }
            else if(linkRecordType=='false'){
                c.ispublished =true;
                update c;
            }
        }
    }
    catch(Exception e)
    {
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while setting up make public/make private links. Please contact your system administrator.');
         ApexPages.addMessage(myMsg); 
    }
        //setData();
        displayList();
    }
    
    
    public void emptylisttypes()
    {    
        listtypes=new String[]{};    
        setCheck();
    }
    
    public void setCheck(){          
        
        emailCheck=searchCheck('emailCheck');
        webexCheck=searchCheck('webexCheck');
        meetingCheck='false';
        callCheck=searchCheck('callCheck');
        commentCheck=searchCheck('commentCheck');
        attachmentCheck=searchCheck('attachmentCheck');
        ikbCheck=searchCheck('ikbCheck');
        prCheck=searchCheck('prCheck');
        othersCheck=searchCheck('othersCheck');
        sapCheck=searchCheck('sapCheck');//CR-00123420 
        auditCheck=searchCheck('auditCheck'); //CR-00138263 
        laCheck=searchCheck('laCheck');//CR-00134277
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
        vceAttCheck=searchCheck('vceAttCheck');
        vceNoteCheck=searchCheck('vceNoteCheck');
        vceTaskCheck=searchCheck('vceTaskCheck');
    //End - 20-Jun-2016 - Jyolsna - CR-00138097 
        currentPage=1;//CR-00132166: setting current page to 1
        displayList();
    }
    
        
    public void setData(){
        //CR-00138263    Start
        if(UserInfo.getProfileId()!=prfID.PremeirProfileId__c){
            auditCheck='false';
        }
       if(id != null){
       try{
        this.tList=[select id,Type,Description,IsVisibleInSelfService,CallType,Subject,who.name,createddate,CreatedBy.Name from task where whatid=:id and recordtypeId !=: vceTaskRecordTypeId];//CR-00138097:filter non vce task
        this.aList=[select id,name,Description,createddate,CreatedBy.Name from attachment where parentid=:id];
        this.gList=[select case__c, createddate,CreatedBy.Name,GSS_File_Comments__c,GSS_File_Name__c,GSS_File_Size__c,GSS_File_Source__c,GSS_File_Type__c,GSS_File_Upload_Date__c,Legacy_Source__c from GSS_File_Attachment__c where Case__c=:id and GSS_File_Source__c!='Email'];
        this.cList=[select id,ispublished,CommentBody,createddate,CreatedBy.Name from CaseComment where parentid=:id];
        this.iList=[select id,Name,GSS_Solution_Description__c,GSS_KB_ID__c,GSS_Public_URL__c,GSS_KB_Short_URL__c,createddate,CreatedBy.Name from GSS_Case_Knova__c where GSS_Case_Number__c=:id]; //CR-00123420 : added GSS_KB_ID__c in Query
        this.pList=[select id,Name,GSS_Bug_Resolution__c,createddate,GSS_BugSFDCID__r.Name,GSS_BugSFDCID__r.GSS_Bug_ID__c,GSS_Bug_Status__c,CreatedBy.Name from GSS_Case_BugZilla__c where GSS_CaseNumber__c=:id];
        //CR-00134277 : added filter to fetch just the SR Comments and not log analysis
        this.sList=[select id,Name,Note_Description__c,Notes_Type__c,createddate,CreatedBy.Name from SR_Comments__c where SR_Number__c=:id and Type_of_SR_Comment__c != 'Log Analysis'];
        this.eList=[select id,Subject,TextBody,Incoming,createddate,CreatedBy.Name,hasattachment from EmailMessage where parentid=:id];
        this.sapList=[select id,Symptoms__c,Assessment__c,Plan__c,SAP_Rich__c,createddate,CreatedBy.Name from GSS_SAP_History__c where Case__c=:id]; //CR-00123420: Added SAP Query
        this.auditList=[SELECT Id,Field,createddate,CreatedById,NewValue,OldValue FROM CaseHistory WHERE CaseId =:id];//CR-00138263 
        //CR-00134277 : Fetching the log analysis 
        this.laList=[select id,Name,Note_Description__c,Notes_Type__c,createddate,CreatedBy.Name from SR_Comments__c where SR_Number__c=:id and Type_of_SR_Comment__c = 'Log Analysis'];
        //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
        this.atList=[select id,Name,createddate,CreatedBy.Name from VCE_Attachment_Link__c where Case__c=:id];
        this.noteList=[select id,Name,createddate,CreatedBy.Name from VCE_Case_Note__c  where Case__c=:id];
        this.taskList=[select id,Type,Description,IsVisibleInSelfService,CallType,Subject,who.name,createddate,CreatedBy.Name from Task  where whatid=:id and recordtypeId=:vceTaskRecordTypeId];
        //End - 20-Jun-2016 - Jyolsna - CR-00138097 
       }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'SOQL Error while querying the page data.Please contact your system administrator.');
            ApexPages.addMessage(myMsg); 
        }
       }
    }

    public Integer calcRows(String text)
    {
    Integer count=0;
    Integer breaks=0;
    Integer rowbreaks=0;
    try{
        for(Integer i=0;i<text.length();i++)
        {
            if(text.substring(i,i+1)=='\n')
            {
                count++;
            }
        }
        breaks=(Integer)Math.ceil((text.length()/100));      
      
    rowbreaks=count+breaks;
    if(rowbreaks==0&&(text!=''&&text!=null))
    {
        rowbreaks=1;
    }    
    
    else
    {
        rowbreaks+=1;
    }   
    
    
    }
    Catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while calculating number of rows to be displayed in collapsible section.Please contact your system administrator.');
            ApexPages.addMessage(myMsg); 
        }
           
    return(rowbreaks); 
    
    }
    public void displayList(){
    
    try{
        //CR-00110761 starts
        startCount=(currentPage-1)*pagesize;
        endCount=startCount+pagesize-1;        
        //CR-00110761 ends
        wlist=new List<wrapperClass>();
        wlistWithLimit= new List<wrapperClass>(); //CR-00107561

        List<task> tList=this.tList;
        List<attachment> aList=this.aList;
        List<CaseComment> cList=this.cList;
        List<GSS_Case_Knova__c> iList=this.iList;
        List<GSS_Case_BugZilla__c> pList=this.pList;
        List<SR_Comments__c> sList=this.sList;
        List<EmailMessage> eList=this.eList;
        List<GSS_SAP_History__c> sapList=this.sapList; //CR-00123420
        List<CaseHistory> auditList=this.auditList; //CR-00138263 
        List<SR_Comments__c> laList=this.laList; //CR-00134277
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
        List<VCE_Attachment_Link__c> atList=this.atList;
        List<VCE_Case_Note__c > noteList=this.noteList;
        List<Task > taskList=this.taskList;
        //End - 20-Jun-2016 - Jyolsna - CR-00138097 
    
        wrapperClass obj;
        //CR-00107561 starts
        //CR-00130456: Added checks to retain filter count
        if(emailCheck!='false'){
            emailCount=0;
        }
        if(webexCheck!='false'){
            webexCount=0;
        }
        if(callCheck!='false'){
            callCount=0;
        }
        if(commentCheck!='false'){
            commentsCount=0;
        }
        if(attachmentCheck!='false'){
            attachmentCount=0;
        }
        if(ikbCheck!='false'){
            iKBCount=0;
        }
        if(prCheck!='false'){
            PRCount=0;
        }
        if(othersCheck!='false'){
            othersCount=0;
        }
        if(sapCheck!='false'){
            sapCount=0; //CR-00123420
        }
        //CR-00138263 Start
        if(auditCheck!='false'){
            auditCount=0;
        }
        //CR-00138263 Ends
        //CR-00107561 ends
        //CR-00134277 - Start
        if(laCheck!='false'){
            laCount=0;
        }   
        //CR-00134277 - End
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
        if(vceAttCheck!='false'){
            vceAttCount=0;
        } 
        if(vceNoteCheck!='false'){
            vceNoteCount=0;
        } 
        if(vceTaskCheck!='false'){
            vceTaskCount=0;
        } 
        //End - 20-Jun-2016 - Jyolsna - CR-00138097 
    
    //if(tList != null){
        for(task t:[select id,Type,Description,IsVisibleInSelfService,CallType,Subject,who.name,createddate,CreatedBy.Name from task where whatid=:id and recordtypeId !=: vceTaskRecordTypeId]){//CR-00138097: filter non vce task
            obj=new wrapperClass();
            obj.id=t.id;
            obj.subject=t.subject;
            //obj.name=t.who.name;
            obj.name=t.CreatedBy.Name;
            obj.createddate=t.createddate; 
            obj.description=t.Description;

            //obj.rows=calcRows(obj.description);
            
            
               try
               {
               if(obj.description.length()>popupLength)
                {
                obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';
                }
                else
                {
                obj.popupDescription=obj.description;
                }
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
           /*
         CR-00096132 :Starts
         Purpose:To show Call Outbound /Call inbound (created during webex session) in Webex filters.
       */   
            if(t.type=='Outbound Email'||t.type=='Inbound Email'||t.type=='Meeting'||t.type=='Webex Session' || t.type=='Webex Notes' ||(t.type=='Call'&& t.calltype=='Inbound')||(t.type=='Call'&& t.calltype=='Outbound')||(t.type=='Call Inbound')|| (t.type=='Call Outbound')||t.type=='Call Manual')
            {
                if(t.type=='Call'){
                    obj.type= t.type+' '+t.calltype;
                }
                else{
                    obj.type= t.type;
                }
            }
            else{ 
                if(t.Subject!=null && t.Subject.contains('Bug ') && t.CreatedBy.Name=='GSS-Bugzilla Integration User'){
                    if(t.Subject.contains('has been updated')){
                        obj.type='PR';
                        obj.objtype='PRs';
                        obj.description=t.Subject;
                    }
                    if(t.Subject.contains('associated to Case')){
                        obj.type='doNotDisplay';
                        obj.objtype='doNotDisplay';
                        obj.description=t.Subject;
                    }
                    if(t.Subject.contains('has been unassociated with this case')){
                        obj.type='doNotDisplay';
                        obj.objtype='doNotDisplay';
                        obj.description=t.Subject;
                    }
                }else{
                    obj.type='Others';
                    obj.objtype='others';
                }
            }

            if(obj.type!='Others' && obj.type!='PR')
            {
            obj.objtype='task';
            }
            
            obj.linkType=t.IsVisibleInSelfService;
            Integer checkduplicate=0;
            if(!(obj.type=='Outbound Email')&&!(obj.type=='Inbound Email')&&!(obj.type=='Meeting'&& meetingCheck=='false') &&!((obj.type=='Webex Session'||obj.type=='Webex Notes')&& webexCheck=='false')&&!(obj.type=='Call Inbound' && callCheck=='false')&&!(obj.type=='Call Outbound' &&callCheck=='false')&&!(obj.type=='Others'&& othersCheck=='false')&&!(obj.type=='Call Manual'&& callCheck=='false') &&!(obj.type=='PR' && prCheck=='false')){
                
                if(obj.type=='Others'){
                    obj.type=t.type;
                }
                
                wlist.add(obj);
                checkduplicate=1;
                
            }
            
           
            if((obj.subject=='Call Inbound & Webex' || obj.subject=='Call Outbound & Webex') && webexCheck=='true' && checkduplicate==0)
            {
                wlist.add(obj);
            }
            checkduplicate=0;
    /* CR-00096132 :Ends */
        }
     // }  
        if(!(emailCheck=='false'))
        {
       // if(eList != null){
        //CR-00123420: Added HTMLBody, FromName and FromAddress
        for(EmailMessage e:[select id,Subject,TextBody,HTMLBody,Incoming,createddate,CreatedBy.Name,hasattachment,FromName,FromAddress from EmailMessage where parentid=:id]) 
        {
                obj=new wrapperClass();
                obj.id=e.id;
                obj.subject=e.Subject;
                obj.createddate=e.createddate;
                
                if(e.hasattachment==true)
                {
                obj.hasattachments=true;
                }
         
                /*List<String> popUp=t.description.split('\n',3);
                System.debug('MANU8888'+popUp);*/
     
                String fullEmailBody=e.TextBody;
        //CR-00123420: Added code to display HTML emails in history
                if(fullEmailBody==null || fullEmailBody==''){
                    //fullEmailBody=e.HTMLBody.replaceAll('<(.|\n)*?>',''); //CR-00123420 - Email text not showing (Ipad) 
                    //CR-00130456: Updated description message for HTML Emails without text body
                    if(e.HTMLBody!=null){
                        fullEmailBody='Click and Select HTML body to view Email';
                    }else{
                        fullEmailBody='No Description Available';
                    }
                }
                String emailBodyFrom2=fullEmailBody;
                                               
                try{
                    Integer countTillFrom1=fullEmailBody.indexOf('From:');
                    Integer countTillFrom2;
                    
                    if(countTillFrom1!=-1){
                        countTillFrom2=fullEmailBody.indexof('From:',countTillFrom1+4);
                        emailBodyFrom2=fullEmailBody.substring(0,countTillFrom2);
                    }
                }
                catch(Exception ex2)
                {
                    System.debug('This email does not have any from: tag within email body: '+ex2);
                }
                obj.description=emailBodyFrom2;
                //obj.rows=calcRows(obj.description);
                //System.debug('@@@@@@@@@@@@@@%%%%%%%%######Manu555'+obj.description); 
             
               
               
               
                if(e.incoming==true)
                {
                    obj.type='Inbound Email';
            //CR-00123420 - Added code to display sender name for inbound emails
                    if(e.FromName!=null){
                        obj.name=e.FromName;
                    }else{
                        obj.name=e.FromAddress;
                    }
                }
                else if(e.incoming==false)
                {
                obj.type='Outbound Email';
                obj.name=e.CreatedBy.Name; //CR-00123420 - Added code to display sender name for inbound emails
                }
                
                obj.objType='Email';
                
                //obj.name=e.CreatedBy.Name;
                //CR-00134278 Sakshi Suri Added Name and timestamp in popup Starts
                try{
        //getting the field value from the case record
        
        custTimeVal  =  string.valueOf(e.createddate);
       
        //null check    
        if(custTimeVal==null || custTimeVal=='')
        {
            localFormmattedDate = '';
            timeVal = '';
        }
        else
        {
            //getting the date component of the date in text field
            if(custTimeVal!=null && custTimeVal!='')
            {
                dateval = GSS_UtilityClass.getConvertDate(custTimeVal);  
               
            }else
            {
                dateval = null;
            }
                
            //converting the date in the user locale date format
            localFormmattedDate = '';      
            String user_locale = UserInfo.getLocale(); 
            GSS_LocaleFormat__c locDateSett = GSS_LocaleFormat__c.getInstance(user_locale);
        
                //getting the time component of the date in the text field
                if(locDateSett.Is_24_Hr_Format__c == true)
                {
                    timeVal = custTimeVal.substring(11);
                }
                else
                {
                    timeVal = GSS_UtilityClass.getConvertTime(custTimeVal.substring(11));
                }
        
              
            if (dateval != null)
            {       //formatting the date
                    try
                    {
                        localFormmattedDate  = dateval.format();                   
                    }catch (Exception exp)
                    {
                        localFormmattedDate  = custTimeVal.substring(0,10);                    
                    }       
            }                    
        }
    }  
    catch(Exception ex){
        localFormmattedDate = '';
        timeVal = '';
    }
                //CR-00134278 Sakshi Suri Added Name and timestamp in popup Ends
                
                
                try
               {
               if(obj.description.length()>popupLength)
                {
               obj.popupDescription='Sender: '+obj.name+'\nSend Date and Time: '+localFormmattedDate+' '+timeVal+'\n\n'+obj.description.substring(0,popupLength);//+'\n\n-----Click Expandpublicnote to see the rest of details-----'; //CR-00134278 Sakshi Suri Added Name and timestamp in popup
                }
                else
                {
                obj.popupDescription='Sender: '+obj.name+'\nSend Date and Time: '+localFormmattedDate+' '+timeVal+'\n\n'+obj.description;//CR-00134278 Sakshi Suri Added Name and timestamp in popup
                }
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
                if(!(obj.type=='Outbound Email'&& emailCheck=='false')&&!(obj.type=='Inbound Email'&& emailCheck=='false'))
                {
                wlist.add(obj);
                }
                
        
        }
        //}
        }

        if(!(attachmentCheck=='false')){
        //if(aList != null){
            for(attachment a:[select id,name,Description,createddate,CreatedBy.Name from attachment where parentid=:id]){
                obj=new wrapperClass();
                obj.id=a.id;
                obj.subject=a.name;
                obj.description=a.Description;
                //obj.rows=calcRows(obj.description);
               try
               {
               if(obj.description.length()>popupLength)
                {
                obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';
                }
                else
                {
                obj.popupDescription=obj.description;
                }
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
                obj.createddate=a.createddate;
                obj.type='Attachment';
                obj.objType='Attachments';
                obj.name=a.CreatedBy.Name;
                wlist.add(obj);
            }
           //} 
        }
        
        if(!(attachmentCheck=='false')){
        //if(gList != null){
          if(!Test.isRunningTest()){
            for(GSS_File_Attachment__c g:[select case__c, createddate,CreatedBy.Name,GSS_File_Comments__c,GSS_File_Name__c,GSS_File_Size__c,   GSS_File_Source__c,GSS_File_Type__c,GSS_File_Upload_Date__c,Legacy_Source__c from GSS_File_Attachment__c where Case__c=:id and GSS_File_Source__c!='Email']){
                obj=new wrapperClass();
                obj.id=g.id;
                obj.subject=g.GSS_File_Name__c;
                obj.description='GSS File Attachment \n****************************************\n'+'File Name: '+g.GSS_File_Name__c+'\nFile Size: '+g.GSS_File_Size__c+'\nFile Source: '+g.GSS_File_Source__c+'\nFile Type: '+g.GSS_File_Type__c+'\nFile Upload Date: '+
                g.GSS_File_Upload_Date__c;
                //obj.rows=calcRows(obj.description);
               try
               {
               if(obj.description.length()>popupLength)
                {
                obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';
                }
                else
                {
                obj.popupDescription=obj.description;
                }
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
                obj.createddate=g.createddate;
                //obj.type='Attachment';
                obj.type='GSS File Attachment';
                obj.objType='Attachments';
                obj.name=g.CreatedBy.Name;
                wlist.add(obj);
            }
          }
           //} 
        }
        
        /* CR-00096132 :Starts 
       Purpose: To show Public comments in Call Outbound/Call Inbound and Webex filters(created during webex session). 
    */
        if(!(commentCheck=='false') || callCheck=='true' || webexCheck=='true' ) {
        // if(cList != null){
            for(casecomment c:[select id,ispublished,CommentBody,createddate,CreatedBy.Name from CaseComment where parentid=:id]){
                obj=new wrapperClass();
                obj.id=c.id;
                //obj.subject=c.commentbody;
                
                obj.description=c.CommentBody;
                // CR-00104420 Added condition to check if comment is public or private
                if(c.ispublished){
                    obj.subject='Public Comment';
                }else{
                    obj.subject='Case Comment';
                }
                
                if(obj.description.contains('[Call Inbound Notes & Webex]'))
                {
                    obj.subject='Call Inbound Notes & Webex';
                }
                else if(obj.description.contains('[Call Outbound Notes & Webex]'))
                {
                    obj.subject='Call Outbound Notes & Webex';
                }
                else if(obj.description.contains('[Call Inbound Notes]'))
                {
                    obj.subject='Call Inbound Notes';
                }
                else if(obj.description.contains('[Call Outbound Notes]'))
                {
                    obj.subject='Call Outbound Notes';
                }
                
                
                //obj.rows=calcRows(obj.description);
                try
               {
               if(obj.description.length()>popupLength)
                {
                obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';
                }
                else
                {
                obj.popupDescription=obj.description;
                }
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
                obj.createddate=c.createddate;
                obj.type='CaseComment';
                obj.objType='CaseComments';
                obj.name=c.CreatedBy.Name;
                obj.linkType=c.ispublished;
                
    
                Integer checkDuplicate=0;
                
                if((obj.description.contains('[Call Outbound Notes') && callCheck=='true') || (obj.description.contains('[Call Inbound Notes')&& callCheck=='true') )
                {
                    wlist.add(obj);
                    checkDuplicate=1;
                
                }
                if((checkDuplicate==0)&&((obj.description.contains('[Call Inbound Notes & Webex]') && webexCheck=='true') || (obj.description.contains('[Call Outbound Notes & Webex]') && webexCheck=='true')))
                {
                    wlist.add(obj);
                    checkDuplicate=1;
                }
                
                if(checkDuplicate==0 && !(commentCheck=='false'))
                {
                    wlist.add(obj);
                }
                
                checkDuplicate=0;
    /* CR-00096132 :Ends */
            }
           //} 
        }
        
        if(!(ikbCheck=='false')){
         // if(iList != null){
        //CR-00123420 - Added GSS_KB_ID__c in query
            for(GSS_Case_Knova__c i:[select id,Name,GSS_Solution_Description__c,GSS_KB_ID__c,GSS_Public_URL__c,GSS_KB_Short_URL__c,createddate,CreatedBy.Name from GSS_Case_Knova__c where GSS_Case_Number__c=:id]){
                obj=new wrapperClass();
                obj.id=i.id;
                //obj.subject=i.Name;
                //obj.subject=i.GSS_Public_URL__c;       
                obj.subject=i.GSS_KB_Short_URL__c;
                obj.description='KB  '+i.GSS_KB_ID__c+ ':\n'+i.GSS_Solution_Description__c; //CR-00123420: Added KB to Description
                //obj.rows=calcRows(obj.description);
                try
               {
               if(obj.description.length()>popupLength)
                {
                obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';
                }
                else
                {
                obj.popupDescription=obj.description;
                }
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
                obj.createddate=i.createddate;  
                obj.type= 'KB';
                obj.objtype='KBs';
                obj.name=i.CreatedBy.Name;
                wlist.add(obj);
            }
          // } 
        }
        
        if(!(prCheck=='false')){
         //if(pList != null){
            for(GSS_Case_BugZilla__c p:[select id,Name,GSS_Bug_Resolution__c,createddate,GSS_BugSFDCID__r.Name,GSS_BugSFDCID__r.GSS_Bug_ID__c,GSS_Bug_Status__c,CreatedBy.Name from GSS_Case_BugZilla__c where GSS_CaseNumber__c=:id]){
                obj=new wrapperClass();
                obj.id=p.id;
                obj.Description='PR '+ p.GSS_BugSFDCID__r.GSS_Bug_ID__c;//CR-00123420 Added PR to Description
                //obj.Description=p.GSS_Bug_Resolution__c;
                //obj.rows=calcRows(obj.description);
                try
               {
               /*if(obj.description.length()>popupLength)
                {
                obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';
                }
                else
                {
                obj.popupDescription=obj.description;
                }*/
                    obj.popupDescription='*****************\n'+' Bug Status: '+p.GSS_Bug_Status__c+' \n Bug Resolution: ' + p.GSS_Bug_Resolution__c +  ' \n CB Number '+p.Name+'\n*****************';                
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
                //obj.subject=p.name;
                obj.subject=p.GSS_BugSFDCID__r.GSS_Bug_ID__c;                
                obj.createddate=p.createddate;
                obj.type='PR';
                obj.objType='PRs';
                obj.name=p.CreatedBy.Name;
                wlist.add(obj);
            }
          // } 
        }
        //CR-00123420: Added code for SAP History
        if(!(sapCheck=='false')){
            if(!Test.isRunningTest()){
                for(GSS_SAP_History__c sap:[select id,Symptoms__c,Assessment__c,Plan__c,SAP_Rich__c,createddate,CreatedBy.Name from GSS_SAP_History__c where Case__c=:id]){
                    obj=new wrapperClass();
                    obj.id=sap.id;
                    obj.Description='S: '+ sap.Symptoms__c + '\n\nA: ' + sap.Assessment__c + '\n\nP: ' + sap.Plan__c;
                    obj.popupDescription='S: '+ sap.Symptoms__c + '\n\nA: ' + sap.Assessment__c + '\n\nP: ' + sap.Plan__c;
                    obj.subject='SAP History';                
                    obj.createddate=sap.createddate;
                    obj.type='SAP';
                    obj.objType='SAP';
                    obj.name=sap.CreatedBy.Name;
                    wlist.add(obj);
                }
            }
        }
        
        if(!(commentCheck=='false')){
        
         // if(sList != null){
              //CR-00134277 : Adding filter to fetch just the SR Comments
              for(SR_Comments__c s:[select id,Name,Note_Description__c,Notes_Type__c,createddate,CreatedBy.Name from SR_Comments__c where SR_Number__c=:id and Type_of_SR_Comment__c != 'Log Analysis']){
                obj=new wrapperClass();
                obj.id=s.id;
               // obj.subject=s.Note_Description__c;    
                obj.subject=s.Notes_Type__c;
                //obj.subject=s.Name;
                
                obj.Description=s.Note_Description__c;
                //obj.rows=calcRows(obj.description);
                try
               {
               if(obj.description.length()>popupLength)
                {
                               
                obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';

                }
                else
                {
                obj.popupDescription=obj.description;
                }
              }
              catch(Exception ex)
              {
                  obj.popupDescription='No Description Available';
              }
                obj.createddate=s.createddate;
                obj.type='SR Comments';
                obj.objType='SR Comments';
                obj.name=s.CreatedBy.Name;
                wlist.add(obj);
            }
           //} 
        }
        
        //CR-00134277 - Start - Fetching the log Analysis details from SR Comment
        if(!(laCheck=='false')){
              for(SR_Comments__c s:[select id,Name,Note_Description__c,Notes_Type__c,createddate,CreatedBy.Name from SR_Comments__c where SR_Number__c=:id and Type_of_SR_Comment__c = 'Log Analysis']){
                obj=new wrapperClass();
                obj.id=s.id;
                obj.subject=s.Notes_Type__c;
                obj.Description=s.Note_Description__c;
                try
                {
                   if(obj.description.length()>popupLength)
                    {
                        obj.popupDescription=obj.description.substring(0,popupLength);//+'\n\n-----Click Expand(+) to see the rest of details-----';
                    }
                    else
                    {
                        obj.popupDescription=obj.description;
                    }
                }
                catch(Exception ex)
                {
                    obj.popupDescription='No Description Available';
                }
                obj.createddate=s.createddate;
                obj.type='Log Analysis';
                obj.objType='Log Analysis';
                obj.name=s.CreatedBy.Name;
                wlist.add(obj);
            }
        }
        //CR-00134277 - End
        
        //CR-00138263 Starts
        if(!(auditCheck=='false')){
        List<CaseHistory> cHList=new List<CaseHistory>();
        cHList=[SELECT Id,Field,createddate,CreatedBy.Name,NewValue,OldValue FROM CaseHistory WHERE CaseId =:id];//CR-00140144 added CreatedBy.Name
        //Set<Id> usIdSet=new Set<Id>();
        //for(CaseHistory U:cHList){usIdSet.add(u.CreatedById);}
        //List<User> createdBy=new List<User>();
        //createdBy=[Select id,Name from User Where id IN: usIdSet limit 1];
            for(CaseHistory caseHis:cHList){
                obj=new wrapperClass();
                obj.id=caseHis.id;
                obj.Description='Changed '+caseHis.Field+' from '+caseHis.OldValue+' to '+caseHis.NewValue+'.';
                obj.popupDescription='Changed '+caseHis.Field+' from '+caseHis.OldValue+' to '+caseHis.NewValue+'.';
                obj.subject='CaseHistory';                
                obj.createddate=caseHis.createddate;
                obj.type='CaseHistory';
                obj.objType='CaseHistory';
                //obj.name=createdBy[0].Name;
                obj.name=caseHis.CreatedBy.Name;//CR-00140144
                wlist.add(obj);
                System.debug(':::::::::::::::::Name:::::::::::::::::::'+ obj.name);
            }
        }
        //CR-00138263 Ends
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
        if(!(vceAttCheck=='false') && isVceProfile == true){
            for(VCE_Attachment_Link__c attachment:[select id,Name,Attachment_URL__c,createddate,CreatedBy.Name from VCE_Attachment_Link__c where Case__c=:id]){
        
                obj=new wrapperClass();
                obj.id=attachment.id;
                obj.Description=attachment.Name;
                obj.subject='VCE Attachment';                
                obj.createddate=attachment.createddate;
                obj.type='VCE Attachment';
                obj.objType='VCE Attachment';
                obj.name=attachment.createdBy.Name;
                obj.popupDescription = attachment.Attachment_URL__c;
                wlist.add(obj);
            }
        }
        if(!(vceNoteCheck=='false') && isVceProfile == true){
            for(VCE_Case_Note__c  note:[select id,Note_Comments__c,Name,createddate,CreatedBy.Name from VCE_Case_Note__c  where Case__c=:id]){
        
                obj=new wrapperClass();
                obj.id=note.id;
                obj.Description=note.Note_Comments__c;
                obj.subject='VCE Note';                
                obj.createddate=note.createddate;
                obj.type='VCE Note';
                obj.objType='VCE Note';
                obj.name=note.createdBy.Name;
                obj.popupDescription = note.Note_Comments__c;
                wlist.add(obj);
            }
        }
        if(!(vceTaskCheck=='false') && isVceProfile == true){
            for(Task  taskRec:[select id,Type,Description,CallType,Subject,who.name,createddate,CreatedBy.Name from Task where whatid=:id and recordtypeId=:vceTaskRecordTypeId]){
        
                obj=new wrapperClass();
                obj.id=taskRec.id;
                obj.Description=taskRec.Description;
                obj.subject='VCE Task';                
                obj.createddate=taskRec.createddate;
                obj.type='VCE Task';
                obj.objType='VCE Task';
                obj.name=taskRec.createdBy.Name;
                obj.popupDescription = taskRec.Description;
                wlist.add(obj);
            }
        }
    //End - 20-Jun-2016 - Jyolsna - CR-00138097 
        
        wlist.sort();
        //CR-00107561: Displaying only recent 999 records to avoid collection size error
        integer ListCount=0;
        for(wrapperClass w: wlist){
            if(w.Type=='Outbound Email' || w.Type=='Inbound Email'){                
                emailCount=emailCount+1;
            }            
            if(w.Type=='Webex Session' || w.Type=='Webex Notes'){
                webexCount=webexCount+1;
            }
            if(w.Type=='Call outbound' || w.Type=='Call Inbound' || w.Type=='Call Manual'){
                callCount=callCount+1;
            }
            if(w.Type=='SR Comments' || w.Type=='CaseComment'){
                commentsCount=commentsCount+1;
            }
            //CR-00134277 - Start 
            if(w.Type=='Log Analysis'){
                laCount=laCount+1;  
            }
            //CR-00134277 - End
        //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
            if(w.Type=='VCE Attachment'){
                vceAttCount=vceAttCount+1;  
            }
            if(w.Type=='VCE Note'){
                vceNoteCount=vceNoteCount+1;  
            }
            if(w.Type=='VCE Task'){
                vceTaskCount=vceTaskCount+1;  
            }
        //End - 20-Jun-2016 - Jyolsna - CR-00138097 
            if(w.Type=='Attachment' || w.type=='GSS File Attachment'){
                attachmentCount=attachmentCount+1;
            }
            if(w.Type=='KB'){
                iKBCount=iKBCount+1;
            }
            if(w.Type=='PR'){
                PRCount=PRCount+1;
            }
        //CR-00123420: Added code for SAP Count
            if(w.Type=='SAP'){
                sapCount=sapCount+1;
            }
            //CR-00130456: Corrected Others filter
            if(w.Type=='Others' || w.Type=='Other'){
                othersCount=othersCount+1;
            }
            //CR-00138263 Start
            if(w.Type=='CaseHistory' || w.Type=='CaseHistory'){
                auditCount=auditCount+1;
            }
            //CR-00138263 Ends
            //CR-00110761 modified if condition
            if(ListCount >= startCount && ListCount <= endCount && w.type!='doNotDisplay'){
                w.shortDescription=makeDescriptionShort(w.Description);
                if(w.shortDescription==null || w.shortDescription==''){
                    w.shortDescription='No Description Available';
                }
                wlistWithLimit.add(w);                
            }
            ListCount++;
        }
        //CR-00107561 ends   
        //CR-00110761 starts
        if(currentPage>1){
            isPreviousAvailable=true;
        }else{
            isPreviousAvailable=false;
        }
        if(wlist!=null && wlist.size() > endCount){
            isNextAvailable=true;
        }else{
            isNextAvailable=false;
        }       
        //CR-00110761 ends
             
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while dislaying data.Please contact your system administrator.');
            ApexPages.addMessage(myMsg); 
        }
    }
      
    
    //CR-00110761 Methods for Next page and previous page
    public void goNextPage(){
        currentPage=currentPage+1;
        displayList();
    }
    
    public void goPreviousPage(){
        currentPage=currentPage-1;
        displayList();
    }
    //CR-00110761 ends


    public void viewAction(){
    try{
        fetchId= ApexPages.currentPage().getParameters().get('detailLink');
        fetchType=ApexPages.currentPage().getParameters().get('objType');
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while fetching page parameters. Please contact your system administrator.');
            ApexPages.addMessage(myMsg); 
        }
        //return (new PageReference('/'+fetchId+'?retURL='+id));
    }

    public void edit(){
    try{
        fetchId= ApexPages.currentPage().getParameters().get('editLink');
        fetchType=ApexPages.currentPage().getParameters().get('objType');
        System.debug('#######@@@@@@@@@@@@@@Manu3'+fetchId+fetchType);
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while fetching page parameters. Please contact your system administrator.');
        }
        /*if(fetchType=='CaseComments'){
            return(new PageReference('/'+fetchId+'/e?parent_id='+Id+'&retURL='+Id));
            //return(new PageReference('https://cs3.salesforce.com/00aQ0000002IqFs/e?parent_id=5008000000EZrur&retURL=%2F5008000000EZrur'));
        }
        else if (fetchType=='task') {
            return(new PageReference('/'+fetchId+'/e?id='+fetchId+'&nooverride=0'));
        }
        else{
            return (new PageReference('/'+fetchId+'/e?retURL='+id));
            //return null;
        }
        */
    }
    
    public void reply()
    {
        try{
        
        fetchId= ApexPages.currentPage().getParameters().get('replyLink');
        fetchType=ApexPages.currentPage().getParameters().get('objType');
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while fetching page parameters. Please contact your system administrator.');
        }
        //return (new PageReference('/_ui/core/email/author/EmailAuthor?email_id='+fetchId+'&replyToAll=0&retURL=%2'+id));
    }
    
    public void toAll()
    {
    try{
        fetchId= ApexPages.currentPage().getParameters().get('toAllLink');
        fetchType=ApexPages.currentPage().getParameters().get('objType');
        //return (new PageReference('/_ui/core/email/author/EmailAuthor?email_id='+fetchId+'&replyToAll=1&retURL=%2'+id));
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while fetching page parameters. Please contact your system administrator.');
        }
    }



    public void deleteRecord(){
    try{
        fetchId= ApexPages.currentPage().getParameters().get('deleteLink');
        fetchType=ApexPages.currentPage().getParameters().get('objType');

        if(fetchType=='task'){
            Task tObj=[select id from Task where id=:fetchId];            
            delete tObj;
        }
        else if(fetchType=='Attachments'){
            attachment aObj=[select id from attachment where id=:fetchId];
            delete aObj;
        }
        else if(fetchType=='CaseComments'){
            casecomment cObj=[select id from casecomment where id=:fetchId];
            delete cObj;
        }
        else if(fetchType=='KBs'){
            GSS_Case_Knova__c iObj=[select id from GSS_Case_Knova__c where id=:fetchId];
            delete iObj;
        }
        else if(fetchType=='PRs'){
            GSS_Case_BugZilla__c pObj=[select id from GSS_Case_BugZilla__c where id=:fetchId];
            delete pObj;
        }
        else if(fetchType=='SR Comments'){
            //CR-00134277 : Added Filter for SR Comment
            SR_Comments__c sObj=[select id from SR_Comments__c where id=:fetchId and Type_of_SR_Comment__c != 'Log Analysis'];
            delete sObj;
        } 
        //CR-00134277 : Start
        else if(fetchType=='Log Analysis')
        {
            SR_Comments__c sObj=[select id from SR_Comments__c where id=:fetchId and Type_of_SR_Comment__c = 'Log Analysis'];
            delete sObj;
        }
        //CR-00134277 : En
    //Start - 20-Jun-2016 - Jyolsna - CR-00138097 
        else if(fetchType=='VCE Attachment')
        {
            VCE_Attachment_Link__c sObj=[select id,Name,createddate,CreatedBy.Name from VCE_Attachment_Link__c where id=:fetchId];
            delete sObj;
        }
     else if(fetchType=='VCE Note')
        {
            VCE_Case_Note__c  sObj=[select id,Name,createddate,CreatedBy.Name from VCE_Case_Note__c  where id=:fetchId];
            delete sObj;
        }
        else if(fetchType=='VCE Task')
        {
            Task  sObj=[select id from Task where id=:fetchId];
            delete sObj;
        }
    //End - 20-Jun-2016 - Jyolsna - CR-00138097 
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while deleting record. Please contact your system administrator.');
        }
        setData();
        displayList();
    
    }
    
    
    public void view(){
    try{
        fetchId= ApexPages.currentPage().getParameters().get('viewLink');
        fetchType=ApexPages.currentPage().getParameters().get('objType');
        }
        catch(Exception e)
        {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while fetching page parameters. Please contact your system administrator.');
        }
    }
    
    //CR-00110761: Added method to generate short description.
    public string makeDescriptionShort(string description){
        
        string shortDesc;
        if(description!=null && description!=''){
            shortDesc=description.remove('** Please do not change the subject line of this email if you wish to respond. **');
        }
        if(shortDesc!=null && shortDesc.length()>shortDescLength){
            shortDesc=shortDesc.substring(0,shortDescLength-1);
        }
        return shortDesc;
    }

    public class wrapperClass implements Comparable{

        public Integer compareTo(Object wrapperClass) {
            wrapperClass wrapperClassObj= (wrapperClass)wrapperClass;
            if (createddate == wrapperClassObj.createddate ) return 0;
            if (createddate < wrapperClassObj.createddate) return 1;
            return -1;      
        }
        public Id id{get;set;}
        public string subject {get;set;}
        public string name{get;set;}
        public datetime createddate{get;set;}
        public string type{get;set;}
        public string objtype{get;set;}
        public boolean linkType{get;set;}
        public String description{get;set;}
        public String shortDescription{get;set;} //CR-00110761
        public String popupDescription{get;set;}
        public Integer rows{get;set; }
        public boolean hasattachments{get;set;}
    }

}