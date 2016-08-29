/*********************************************************************
* Class Name : GSS_Agent_Reply_Email_Controller
* Purpose    : Controller for Reply Email page
*              
* Author            Date            Comments        
* Accenture     6-April-2014        GSS Agent Console Project
* Accenture     11-July-2014        CR-00096132: GSS optimization 2.0
* Accenture     20-Aug-2014         CR-00107197: Email Signature functionality added
* Accenture     24-Sept-2014        CR-00107561: Proper sending of Emails 
* Accenture     16-Oct-2014         CR-00110761: Additional Buttons
* Accenture     20-Nov-2014         CR-00109419: Add "Do Not Delete" Message and Signature Formatting
* Accenture     26-Dec-2014         CR-00116268: Increase Email size 
* Accenture     13-Feb-2015         CR-00123420: Personal Templates
* Accenture     01-Apr-2015         CR-00130456: adding Attachments from templates
* Accenture     05-Jun-2015         CR-00134240: E2C Thread Id dynamic logic
* Accenture     12-Aug-2015         CR-00134276: If Technical Contact isn't the Primary Contact include the Primary contact in outbound emails
* Accenture     15-Sep-2015         CR-00135635: To populate Start time,end time and duration of an activity.   
* Accenture     21-Sep-2015         CR-00136175: Added Checks for Additional to field to avoid duplication of email
* Accenture     15-02-2016          CR-00136983: Code Change for addition to field.
*Accenture      14-Mar-2016         CR-00134366 :GSS Technical Support - Optimization Template drop down
*Accenture      15-Jul-2016         CR-00139055 :Adding Status and Sub-Status fields to Reply and ReplyAll Page
* ********************************************************************/

global class GSS_Agent_Reply_Email_Controller
{
    public string userSignature {get;set;} //CR-00107197
    public string originalBody; //CR-00107197
    //Start -  15-Jul-2016 - CR-00139055
    public Case caserecord{get;set;} 
    public String statusVal{get;set;} { statusVal = '-- Select --';} 
    public String subStatusVal{get;set;}{ subStatusVal = '-- Select --';} 
     public Static Set<String> subStatusSet = new Set<String>{'Assigned','Customer To Confirm Fix','Customer Requests Close','On Hold Per Customer','Waiting on Customer','Waiting on Escalation Engineer', 'Waiting on Partner','Wait on Engineering','Working'};
    public ID case_id{get;set;} 
    //End -  15-Jul-2016 - CR-00139055
    public User usr {get;set;}
    public String to {get; set;} 
    public String subject {get; set;} 
    public String body {get; set;} 
    public String addto {get; set;}
    public String cc {get; set;}
    public String bcc {get; set;}
    public emailmessage emailMessage;
    public String replyType{get;set;}
    public Id templateId{get;set;} 
    public String templateType{get;set;}
    public EmailTemplate eTemp{get;set;} 
    public string sendBody{get;set;}
    public string sendBody1{get;set;}
    public String hashtml{get;set;}
    public EmailMessage emmes{get;set;}
    public  List<Attachment> tempatt{get;set;}
    public transient blob attbody{get;set;}
    public String attname{get;set;}
    public Set<Id> docSet{get;set;}
    public transient List<Document> docList{get;set;}
    public String tempvalue{get;set;}
    public boolean disablesend{get;set;}
    public boolean disablesend2{get;set;}
    public boolean errorFound{get;set;} //CR-00107561
    public String label1{get;set;}
    public String label2{get;set;}
    public String label3{get;set;}
    public String label4{get;set;}
    public String label5{get;set;}
    public String t1{get;set;}
    public String t2{get;set;}
    public String t3{get;set;}
    public String t4{get;set;}
    public String t5{get;set;}
    // CR-00096132 start:added boolean variables to control the visibility of buttons from custom settings
    public Boolean isVisible1{get;set;}
    public Boolean isVisible2{get;set;}
    public Boolean isVisible3{get;set;}
    public Boolean isVisible4{get;set;}
    public Boolean isVisible5{get;set;}
    public String refid{get;set;}
   // CR-00096132 end: 
   // CR-00110761 starts
    public String label6{get;set;}
    public String label7{get;set;}
    public String label8{get;set;}
    public String label9{get;set;}
    public String label10{get;set;}
    public String t6{get;set;}
    public String t7{get;set;}
    public String t8{get;set;}
    public String t9{get;set;}
    public String t10{get;set;}    
    public Boolean isVisible6{get;set;}
    public Boolean isVisible7{get;set;}
    public Boolean isVisible8{get;set;}
    public Boolean isVisible9{get;set;}
    public Boolean isVisible10{get;set;}
    public String selectedTemplateId {get;set;}//CR-00123420
    public String selectedTemplate_Id {get;set;} //CR-00134366
    public static Id EmailFolderId = GSS_Configuration_Properties_list__c.getInstance('EmailTemplateFolder_Id').setting_value__c;//CR-00134366 
    // CR-00110761 ends
    //CR-00109419 start: Constant variable declaration
    private final String DO_NOT_REMOVE_HTML = '<b><font color="red">---------------Do not delete below this line---------------</font></b>';
    private final String DO_NOT_REMOVE_TEXT = '---------------Do not delete below this line---------------';
    private final String ORIGINAL_EMAIL_IDENTIFIER = '--------------- Original Message---------------'; //CR-00116268
    //CR-00109419 end
    public string caseSynopsis{get;set;}//CR-00116268
    public DateTime openedTime; //CR-00135635
    
   
    public GSS_Agent_Reply_Email_Controller(ApexPages.StandardController controller) {
        disablesend=false;
        disablesend2=false;
        errorFound=false; //CR-00107561
        openedTime = dateTime.valueOf(system.now()); //CR-00135635

        // CR-00110761 - Adding code for template buttons   
        //Retrieve custom setting values
            label1=GSS_Agent_Template__c.getInstance('SRS Email 1').Label__c;
            label2=GSS_Agent_Template__c.getInstance('SRS Email 2').Label__c;
            label3=GSS_Agent_Template__c.getInstance('SRS Email 3').Label__c;
            label4=GSS_Agent_Template__c.getInstance('SRS Email 4').Label__c;
            label5=GSS_Agent_Template__c.getInstance('SRS Email 5').Label__c; 
            label6=GSS_Agent_Template__c.getInstance('SRS Email 6').Label__c;
            label7=GSS_Agent_Template__c.getInstance('SRS Email 7').Label__c;
            label8=GSS_Agent_Template__c.getInstance('SRS Email 8').Label__c;
            label9=GSS_Agent_Template__c.getInstance('SRS Email 9').Label__c;
            label10=GSS_Agent_Template__c.getInstance('SRS Email 10').Label__c;
            t1=GSS_Agent_Template__c.getInstance('SRS Email 1').TemplateId__c;
            t2=GSS_Agent_Template__c.getInstance('SRS Email 2').TemplateId__c;
            t3=GSS_Agent_Template__c.getInstance('SRS Email 3').TemplateId__c;
            t4=GSS_Agent_Template__c.getInstance('SRS Email 4').TemplateId__c;
            t5=GSS_Agent_Template__c.getInstance('SRS Email 5').TemplateId__c;
            t6=GSS_Agent_Template__c.getInstance('SRS Email 6').TemplateId__c;
            t7=GSS_Agent_Template__c.getInstance('SRS Email 7').TemplateId__c;
            t8=GSS_Agent_Template__c.getInstance('SRS Email 8').TemplateId__c;
            t9=GSS_Agent_Template__c.getInstance('SRS Email 9').TemplateId__c;
            t10=GSS_Agent_Template__c.getInstance('SRS Email 10').TemplateId__c;
            //code added for phase 2
            isVisible1=GSS_Agent_Template__c.getInstance('SRS Email 1').isActive__c;
            isVisible2=GSS_Agent_Template__c.getInstance('SRS Email 2').isActive__c;
            isVisible3=GSS_Agent_Template__c.getInstance('SRS Email 3').isActive__c;
            isVisible4=GSS_Agent_Template__c.getInstance('SRS Email 4').isActive__c;
            isVisible5=GSS_Agent_Template__c.getInstance('SRS Email 5').isActive__c; 
            isVisible6=GSS_Agent_Template__c.getInstance('SRS Email 6').isActive__c;
            isVisible7=GSS_Agent_Template__c.getInstance('SRS Email 7').isActive__c;
            isVisible8=GSS_Agent_Template__c.getInstance('SRS Email 8').isActive__c;
            isVisible9=GSS_Agent_Template__c.getInstance('SRS Email 9').isActive__c;
            isVisible10=GSS_Agent_Template__c.getInstance('SRS Email 10').isActive__c;
        
         
        
        
        //CR-00107197: Signature fetching starts
        List <User> uList = [select id, FirstName,LastName, Signature from User where id=:UserInfo.getUserId() limit 1];
        if(uList[0]!=null){
            userSignature =uList[0].Signature;
            if(userSignature==null ){
                userSignature='';
            }
        }//CR-00107197: Signature fetching ends
                
        docSet=new Set<Id>();
        
        
        tempatt=new List<Attachment>();
        if(docSet.size()>0)
        {
        docList=[select id,name,body from document where id in :docSet];
        
            for(Document d1:docList)
            {
                Attachment a1=new Attachment(body=d1.body,name=d1.name);
            }
        }
        
        
        
        
        
       
        this.emailMessage= (emailmessage)controller.getRecord();
        //CR-00107561 Added Technical contact email to query
  //CR-00116268 Added parent.TSE_Synopsis__c to query
        emmes = [select parentid,parent.contactid,parent.account.name,parent.TSE_Synopsis__c,parent.contact.name,parent.casenumber,parent.Technical_Contact_Email__c, parent.Technical_Contact_Name__c,textbody,FromAddress,subject,BccAddress,CcAddress,createddate,ToAddress,htmlbody,Incoming,parent.contact.email,parent.GSS_Additional_Emails__c from emailmessage where id=:emailmessage.id];//Sakshi Suri Added Contact.Email in SOQL CR-00134276
//CR-00136175: Added Checks for Additional To field to avoid duplication of email Starts
        string toAddress_Str = emmes.ToAddress;
        set<String> uniqueEmailid = new set<string>();
        
        for(string toadd : toAddress_Str.split(';')){
            if(toadd!= '' && toadd!= null){
                uniqueEmailid.add(toadd);               
            }
        }
        if(!uniqueEmailid.isEmpty()){
            for(string str:uniqueEmailid){
            
      
                if(addto == null){
                    
                    addto=str+';';
                    
                }
               
                if(addto != null && (!addto.containsIgnoreCase(str))){
                
                    addto=addto+str+';';
                    
                }
            }
        }
        
        
//CR-00136175: Added Checks for Additional To field to avoid duplication of email Ends
        List<Attachment>  newAttachments=new List<Attachment>{new Attachment()};
          
          try{
    //CR-00116268
          if(emmes!=null){
              caseSynopsis=emmes.parent.TSE_Synopsis__c;
          }
          
          if(emailmessage.htmlbody==null)
          {
              hashtml='false';
              emailmessage.htmlbody=emailmessage.textbody.replace('\n','<br>');
          }
          else
          {
              hashtml='true';
          }
          }
          catch(Exception ex)
          {
               hashtml='false';
          }
       
         
         to=emmes.FromAddress.remove('webform@vmware.com').remove('webformqa@vmware.com').remove('webformdev@vmware.com');//CR-00110761- strip webform
         //to=emmes.FromAddress;
         //CR-00110761 Adding technical contact email if not already present
         if(to!=null && emmes.parent.Technical_Contact_Email__c!=null && !to.contains(emmes.parent.Technical_Contact_Email__c)){
             if(emmes.parent.Technical_Contact_Email__c!=null){
                 to=emmes.parent.Technical_Contact_Email__c + ';'+ to;
             }
         }
         if(to=='' && emmes.parent.Technical_Contact_Email__c!=null){
             to=emmes.parent.Technical_Contact_Email__c;
         }
         //CR-00110761 ends
         subject = emmes.subject;
         //CR-00107197: Appending Signature in the mail chain starts
         //CR-00109419: Adding Do not Delete message and signature formatting
         GSS_Agent_Variables__c  AgentVars = GSS_Agent_Variables__c.getOrgDefaults();
         string fontfamily = AgentVars.Signature_Font__c;
         String addText='<br><br> <font face="'+ fontfamily +'">' + userSignature.replace('\n','<br>') + ' </font><br>'+  DO_NOT_REMOVE_HTML+'<br><br>' + ORIGINAL_EMAIL_IDENTIFIER + '</br></br><br>'+'<b>From: </b>['+emmes.FromAddress+']<br>'+'<b>Sent: </b>'+emmes.createddate+'<br>'+'<b>To: </b>'+emmes.ToAddress+'<br>'+'<b>Subject: </b>'+emmes.subject+'<br><br>';
         
         
         //emailmessage.htmlbody=addText+emailmessage.htmlbody;
         originalBody = addText+emailmessage.htmlbody;
         emailmessage.htmlbody=originalBody;
         //CR-00107197: Appending Signature in the mail chain ends
         sendBody=emmes.textbody+addText;
         

         cc=emmes.CcAddress;

         bcc=emmes.BccAddress;
         //addto=emmes.ToAddress;
         //Sakshi Suri If Technical Contact isn't the Primary Contact include the Primary contact in outbound emails  CR-00134276 Starts
         if(emmes.parent.GSS_Additional_Emails__c!=null){
            if(emmes.parent.Contact.Email!=null && (!emmes.parent.Contact.Email.equalsIgnoreCase(emmes.parent.Technical_Contact_Email__c))&&(!emmes.parent.GSS_Additional_Emails__c.containsIgnoreCase(emmes.parent.Contact.Email)) && (!addto.containsIgnoreCase(emmes.parent.Contact.Email))){
            //CR-00136983 starts
                if(addto.contains(';')){
                addto=addto+emmes.parent.Contact.Email;}
                else{
                addto=addto+';'+emmes.parent.Contact.Email;}
            //CR-00136983 ends    
         }
         }
         else{
         if(emmes.parent.Contact.Email!=null && (!emmes.parent.Contact.Email.equalsIgnoreCase(emmes.parent.Technical_Contact_Email__c)) && (!addto.containsIgnoreCase(emmes.parent.Contact.Email))){
            //CR-00136983 starts
            if(addto.contains(';')){
                addto=addto+emmes.parent.Contact.Email;}
                else{
                addto=addto+';'+emmes.parent.Contact.Email;}
            //CR-00136983 Ends
         }
         }
         //Sakshi Suri If Technical Contact isn't the Primary Contact include the Primary contact in outbound emails  CR-00134276 Ends
       try{
         
         //Code changed for CR-00136983 Start
         addto=addto.replace('webform@vmware.com;','');
         addto=addto.replace('webform@vmware.com','');
         addto=addto.replace('webformqa@vmware.com;','');
         addto=addto.replace('webformqa@vmware.com','');
         addto=addto.replace('webformdev@vmware.com;','');  
         addto=addto.replace('webformdev@vmware.com','');
         //Code changed for CR-00136983 End       
       }
       catch(exception ex)
       {
           
       }  
       
         //added t remove bug 00087214:start
        
         //added t remove bug 00087214 :ends
         
         //added by manu change end
         
         try{
            templateType=ApexPages.currentPage().getParameters().get('Template1');
         }
         catch(Exception ex)
         {
            
         }
      setreplyandreplyall();
       // CR-00139055 Starts ( Srishti )
    caserecord=[Select Id, Sub_Status__c, Status, casenumber,GSS_Language__C,TSE_Synopsis__c,Technical_Contact_Name__c,Account.Name,Technical_Contact_Email__c,GSS_Additional_Emails__c,contactid,Contact.Email,recordtypeId from Case where Id=:emmes.parentId];
    if(caserecord!=null){ 
            statusVal = caserecord.Status;
            subStatusVal = caserecord.Sub_Status__c;
    }
    //CR-00139055 ends 
                     
    }

    public void setreplyandreplyall(){
        try{
            String reply=ApexPages.currentPage().getParameters().get('reply');
            if(reply.equals('1'))
            {
                this.cc='';
                this.bcc='';
                 //Sakshi Suri If Technical Contact isn't the Primary Contact include the Primary contact in outbound emails  CR-00134276 Starts
                if(emmes.parent.Contact.Email!=null && (!emmes.parent.Contact.Email.equalsIgnoreCase(emmes.parent.Technical_Contact_Email__c))){
                this.addto=emmes.parent.Contact.Email;
                }
                //Sakshi Suri If Technical Contact isn't the Primary Contact include the Primary contact in outbound emails  CR-00134276 Ends
                else{
                this.addto='';
                }
            }
            
            }
        catch(Exception ex3)
        {
            
        }
       
    }
             
       public void setreandfw()
       {
       
             try{
                String forwardemail=ApexPages.currentpage().getParameters().get('fw');

                if(forwardemail.equals('1'))
                {      
                    subject='FW: '+subject;
                    this.to=emmes.parent.Technical_Contact_Email__c; //CR-00107561: Populating To email for Forward email
                    this.cc='';
                    this.addto='';
                    this.bcc='';
                    List<Attachment> exatt =  [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Parentid=:emailmessage.Id];
                    for(Attachment a:exatt){
                        attachpreviousfiles(a.Name,a.Body);
                    }
                    
                     if(docSet.size()>0)
                        {
                        docList=[select id,name,body from document where id in :docSet];
                        
                            for(Document d1:docList)
                            {
                                Attachment a1=new Attachment(body=d1.body,name=d1.name);
                            }
                        }
                }
                else
                {  
                        try{
                        if(!subject.contains('RE'))
                        {
                        subject='RE: '+subject;
                        }
                        }
                        catch(Exception ex)
                        {
                            
                        }
                }
                }
                catch(Exception ex4)
                {
                    
                }
                emailmessage.subject=subject;  
       }
       
    //method to add existing attachments to email   
       public void attachpreviousfiles(String attname,Blob attbody){
           tempatt=new List<Attachment>();

                
                if(attbody.size()==0)
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot add a file with  0bytes size.');
                    ApexPages.addMessage(myMsg);
                }
                else
                {
                    if(attname!=null)
                    {               
                        document d=new document(body=attbody,name=attname, AuthorId = UserInfo.getUserId(),FolderId = UserInfo.getUserId(),Description='temp__email__attachment');                               
                        insert d;
                        docSet.add(d.id);                               
                        d.body=null;                      
                        attname=null;
                    }
                    
                    if(docSet.size()>0)
                    {
                        docList=[select id,name,body from document where id in :docSet];
                    
                        for(Document d1:docList)
                        {
                           
                           Attachment a1=new Attachment(name=d1.name);
                            tempatt.add(a1);
                            
                        }
                    }
                }
       
       }
       
    
    public void template1() {
        templateId=t1;
        setTemplate2();
    }
    public void template2() {
        templateId=t2;
        setTemplate2();
    }
    public void template3() {
        templateId=t3;
        setTemplate2();
    }
    public void template4() {
        templateId=t4;
        setTemplate2();
    }
    public void template5() {
        templateId=t5;
        setTemplate2();
    }
    //CR-00110761 - Adding template methods for button 6 to 10
    public void template6() {
        templateId=t6;
        setTemplate2();
    }
    public void template7() {
        templateId=t7;
        setTemplate2();
    }
    public void template8() {
        templateId=t8;
        setTemplate2();
    }
    public void template9() {
        templateId=t9;
        setTemplate2();
    }
    public void template10()    {
        templateId=t10;
        setTemplate2();
    }
      
    
    
    // method to set template
    public void setTemplate2(){
        
        deleteDocs(); //CR-00130456: Deleting exisiting docs
        tempatt.clear(); //CR-00130456: Clearing current attachment list
        
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(templateId);
        msg.setWhatId(emmes.parentid); 
        msg.setTargetObjectId(emmes.parent.contactid);        
        msg.setToAddresses(new List<String>{'x@x.x.dev'}); 
        lstMsgs.add(msg);
        
        //CR-00096132: Added Try catch block 
        try{
            //CR-00130456 starts: Fetching attachments from templates to add on the email
            List<Attachment> exatt =  [SELECT Id, Name, Body FROM Attachment WHERE Parentid=:templateId];
            for(Attachment a:exatt){
                attachpreviousfiles(a.Name,a.Body);
            }
            //CR-00130456 ends 

             //create a savepoint, execute sendemail, and then rollback
             Savepoint sp = Database.setSavepoint();
             Messaging.sendEmail(lstMsgs); //This will not actually send any email
             Database.rollback(sp);
         }catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on retrieving template body. Please contact your System Administrator.');
            ApexPages.addMessage(myMsg); 
        }  
         
     for (Messaging.SingleEmailMessage email : lstMsgs) {
         emailmessage.TextBody=email.getPlainTextBody();
         
         emailmessage.subject=email.getSubject();
         if(!emailmessage.subject.contains('ref:_')){
             genRefID();
             emailmessage.subject+=' '+refid;
         }
        
         emailmessage.HTMLBody=email.getHTMLBody();  
          
     }
     try{
            if(emailmessage.htmlbody==null){
                hashtml='false';
                //CR-00107197: Adding signature with original body
                emailmessage.htmlbody=emailmessage.TextBody.replace('\n','<br>')+ originalBody;
            }
            else{
                //CR-00107197: Adding signature with original body
                emailmessage.htmlbody=emailmessage.htmlbody+ originalBody;
                hashtml='true';
            }
        }catch(Exception ex){
            hashtml='false';
        }
    
   }
      
     public void genRefID(){
       //Generating REF ID
        String OID = ((String)(UserInfo.getOrganizationId())).substring(0,15);
        String case_id_string=((String)emmes.parentId).substring(0,15);
        //CR-00134240 Starts
        //NA6 Split: Updated REF ID formula
        //refid='[ ref:_'+ OID.substring(0,5)+ OID.substring(OID.length()-11,OID.length()).replace('0','') + '._' + case_id_string.substring(0,5) + case_id_string.substring(case_id_string.length()-10,case_id_string.length()).substring(0,5).replace('0','') + case_id_string.substring(case_id_string.length()-5,case_id_string.length())  + ':ref ]';  
        refid=GSS_EmailToCaseUtility.generateRefId(case_id_string);
        //CR-00134240 Ends             
   } 
       
   public User getUser() {
        return usr;
    }
    
        // the parent object id
    public Id sobjId = ApexPages.currentPage().getParameters().get('id');
    
    // list of existing attachments - populated on demand
    public List<Attachment> attachments;
    
    // list of new attachments to add
     public List<Attachment> newAttachments {get; set;}
    
    // the number of new attachments to add to the list when the user clicks 'Add More'
    public static final Integer NUM_ATTACHMENTS_TO_ADD=1;
 

    // Add more attachments action method
    public void addMore()
    {
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++)
        {
            newAttachments.add(new Attachment());
        }
    }    
    
    // Save action method
    public void save()
    {
        List<Attachment> toInsert=new List<Attachment>();
        for (Attachment newAtt : newAttachments)
        {
            if (newAtt.Body!=null)
            {
                newAtt.parentId=sobjId;
                toInsert.add(newAtt);
            }
        }
       
        newAttachments.clear();
        newAttachments.add(new Attachment());
        
        // null the list of existing attachments - this will be rebuilt when the page is refreshed
        attachments=null;
    }
    
    // Action method when the user is done
    public PageReference done()
    {
        // send the user to the detail page for the sobject
        return new PageReference('/' + sobjId);
    }
    
    public void snipEmail()
    {
                String temp2=emailmessage.HTMLBody;
                String temp3=temp2;
                
                
                   Integer flag=0;
                   Integer temp4;
                   Integer temp1;
               
               /*Manu Sharma: code to avoid first From: slab snip */
               try
               {               
                temp1=temp3.indexOf('From:');
                
                
               
               
                temp4=temp3.indexof('From:',temp1+4);
                
               
               }
               catch(Exception ex)
               {
                   
                   flag=1;
               }
              
                if(temp1!=-1&&temp4!=-1&&flag==0)
                {
                
                temp3=temp3.substring(0,temp4);
                
                }
                
                emailmessage.HTMLBody=temp3;
                reply();
    }
    
    public pagereference reply(){

    String[] finalcc;
    String[] finalbcc;
    errorFound=false; //CR-00107561
            
                
    
    Messaging.reserveSingleEmailCapacity(2);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    
    //Setting From Address
    OrgWideEmailAddress owda= [Select Id, Address,DisplayName from OrgWideEmailAddress where Address like '%webform%' LIMIT 1];
    if ( owda != null ) {
        mail.setOrgWideEmailAddressId(owda.Id);
        mail.setReplyTo(owda.Address);
    }
    
    
     // CR-00139055 - Start - Case Updated (Srishti)
        system.debug('The code reached here -- ' + statusVal + subStatusVal);
            if(statusVal!=null && statusVal != '-- Select --' && subStatusVal!=null && subStatusVal != '-- Select --'){
                caserecord.Status = statusVal;
                caserecord.Sub_Status__c = subStatusVal;
                system.debug('The code reached in if -- ' + statusVal + subStatusVal);
                try{
                    update caserecord;
                }catch(DMLException e){
                    displayError('Case did not get updated. Please contact your System Administrator');  
                }               
            }
            // CR-00139055  - End
    
    
    String[] finalTo=new String[]{};
     if(addto.length() > 4){
    finalTo=addto.trim().split(';',0);
    }  
    
    if(to.length() > 4){
    //finalTo.add(to);
    finalTo.addAll(to.trim().split(';',0)); // CR-00107561 fixing semi colon error in to field
    }
     
    if(finalTo.size() > 0){
    mail.setToAddresses(finalTo);
    }else{     
        displayError('Please specify either a To: or Additional To:'); 
         disablesend=false;
         return null;  
    }
    
    if(cc.length() > 4){
    finalcc = cc.trim().split(';',0);
    mail.setCcAddresses(finalcc);
    }
    
    if(bcc.length() > 4){
    finalbcc = bcc.trim().split(';',0);
    mail.setBccAddresses(finalbcc);
    }
    
    mail.setSubject(subject);
    mail.setBccSender(false);
   
    
    
    Id id1=ApexPages.CurrentPage().getparameters().get('id');
    
    

    EmailMessage em=emmes;
    mail.setToAddresses(finalTo);
    //CR-00116268 Starts
    Integer currentHTMLBodyLength= emailmessage.HTMLBody.substring(0,emailmessage.HTMLBody.indexOf(ORIGINAL_EMAIL_IDENTIFIER, 0)).length() - DO_NOT_REMOVE_HTML.length();
    Integer currentTextBodyLength= emailmessage.HTMLBody.substring(0,emailmessage.HTMLBody.indexOf(ORIGINAL_EMAIL_IDENTIFIER, 0)).length() - DO_NOT_REMOVE_TEXT.length();
    //CR-00116268 ends
    //CR-00109419 : added by manu-start Remove do not delete when sending email
    emailmessage.HTMLBody=emailmessage.HTMLBody.replace(DO_NOT_REMOVE_HTML,'');
    emailmessage.textbody=emailmessage.textbody.replace(DO_NOT_REMOVE_TEXT,'');      
    //CR-00109419 : added by manu-end
    mail.setHtmlBody(emailmessage.HTMLBody);
    //CR-00116268 Starts
    String emailTextDescription='';
    String emailHTMLDescription='';
    If(emailmessage.textbody.length()>32000){
        emailTextDescription=emailmessage.textbody.substring(0,32000);
    }else{
        emailTextDescription=emailmessage.textbody;
    }
    If(emailmessage.HTMLBody.length()>32000){
        emailHTMLDescription=emailmessage.HTMLBody.substring(0,32000);
    }else{
        emailHTMLDescription=emailmessage.HTMLBody;
    }
    //CR-00116268 Ends
   transient List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
    
    EmailMessage em1=emmes;
        //CR-00116268: Replacing entire body(emailmessage.textbody) with current body(emailTextDescription)
        Task t=new Task(Subject=this.subject,Description=emailTextDescription,OwnerId=Userinfo.getuserid(),Status='Completed',Type='Outbound Email',Priority='Normal',whoid=em1.parent.contactid,whatid=em1.parentid,ActivityDate=date.today());
        //insert t; //CR-00107197
 
    //CR-00116268: replacing HTML and TextBody with current body
    EmailMessage newEmail = new EmailMessage(
    FromAddress = owda.Address,
    FromName = owda.DisplayName,
    ToAddress = to+';'+addto,
    BccAddress=bcc,
    CcAddress=cc,
    Subject = subject,
    HtmlBody = emailHTMLDescription,
    TextBody= emailTextDescription,
    ParentId = em1.parentid,
    Activityid=t.id,
    MessageDate=system.now()
    );  
    
    //insert newEmail; 
    
    
    
    tempatt=new List<Attachment>();
    if(docSet.size()>0){        
        docList=[select id,name,body from document where id in :docSet];
        for(Document d1:docList){
            Attachment a1=new Attachment(body=d1.body,name=d1.name);
            tempatt.add(a1);
        }
    }
    for (Attachment a : tempatt){
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();               
        if(a.Body!=null){
            efa.setFileName(a.Name);                
            efa.setBody(a.Body);                
            fileAttachments.add(efa);
            //a.parentid=newEmail.id;
        }
    }
    
    try{
        mail.setFileAttachments(fileAttachments);
        mail.setUseSignature(false);//CR-00107197: Disabling standard salesforce signature      
    //CR-00107561: Check html body length before sending email.
    //CR-00116268: Checking current body only
    if(currentHTMLBodyLength <32000 && currentTextBodyLength <32000){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }else{
            //CR-00107561: Throw error message
            errorFound=true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Length of HTML Body exceeded limit of 32000. Current length is ['+ currentHTMLBodyLength +']');
            ApexPages.addMessage(myMsg);
        }
    }catch(Exception ex){
            errorFound=true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on sending Email. Please contact your System Administrator. ['+ ex +']');
            ApexPages.addMessage(myMsg); 
    }
    //CR-00107561: If no errors found, create related email message and task.
    if(!errorFound){
        // CR-00135635 -Start- To populate Actual Start Time and end time of activity. 
        t.Actual_End__c=system.now();
        Integer sec = Integer.valueof(Math.Floor((system.now().getTime() - openedTime.getTime())/ (1000.0)));/*system.now()-openedTime;*/
        t.Actual_Start__c = openedTime;
        t.CallDurationInSeconds=sec;
        // CR-00135635 -end- To populate Actual Start Time,end time and duration of activity.
        insert t;
        insert newEmail;
        
        for (Attachment a : tempatt){                              
            if(a.Body!=null){                   
                a.parentid=newEmail.id;
            }
        }
        try{
            database.insert(tempatt,false);
        }catch(Exception ex){}                  
        for(Attachment a1:tempatt) {
            a1.body=null;
        }
        deleteDocs();
    }
    disablesend=true;
    
    return null;
    }
    
     public void displayError(String err){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,err);
            ApexPages.addMessage(myMsg);    
      }
    
    public void deleteDocs(){
      try{
            docList=[select id,AuthorId,FolderId,Description from document where AuthorID=:UserInfo.getUserId() AND FolderId=:UserInfo.getUserId() AND Description='temp__email__attachment'];
        
            /*for(Document d1:docList)
            {
                delete d1;
            }*/
            delete docList;
         }
            catch(Exception ex){
                
            }
    }

    public PageReference saveAttachment()
    {
    disablesend2=true;
    tempatt=new List<Attachment>();

        
        if(attbody.size()==0)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot add a file with  0bytes size.');//Same old drama 
            ApexPages.addMessage(myMsg);
        }
        else
        {
        if(attname!=null)
        {
        
        document d=new document(body=attbody,name=attname, AuthorId = UserInfo.getUserId(),FolderId = UserInfo.getUserId(),Description='temp__email__attachment');
      
     
        insert d;
        docSet.add(d.id);
        
        
        d.body=null;
               
        attname=null;
        }
        
        if(docSet.size()>0)
        {
            docList=[select id,name,body from document where id in :docSet];
        
            for(Document d1:docList)
            {
               
               Attachment a1=new Attachment(name=d1.name);
                tempatt.add(a1);
            
            }
        }
        }
        return null;
    }
    
  
  public void deleteAttachment()
    {
    tempatt=new List<Attachment>();
    
    if(docSet.size()>0)
        {
            docList=[select id,name,body from document where id in :docSet];
        
            for(Document d1:docList)
            {
                
                Attachment a1=new Attachment(name=d1.name);
               
                tempatt.add(a1);
              }  
                
               
                
        }
    
    String deletefile=ApexPages.currentPage().getParameters().get('deletefile');
    
        for(Integer i=0;i<tempatt.size();i++)
        {
        
            if(tempatt[i].name.equals(deletefile))
            {
            
                tempatt.remove(i);
                docSet.remove(docList.get(i).id);
                docList.remove(i);

                break;
                
            }
        }
        
    }
     //CR-00134366 GSS Technical Support - Optimization Code Starts
    public List<SelectOption> getGSSTemplateOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select Template--'));   
        for (EmailTemplate t : [select Id,Name, isActive from EmailTemplate where FolderId = :EmailFolderId order by name]) {
            if(t.IsActive){
                options.add(new SelectOption(t.Id,t.Name));
            }
        }
        return options;
    }
    
    public void setSelected_Template() {
        if(selectedTemplate_Id!=null && selectedTemplate_Id!=''){
            templateId=selectedTemplate_Id;
            setTemplate2();
        }
    }
    //CR-00134366 GSS Technical Support - Optimization Code ends
    //CR-00123420 : Personal Template code starts   
    public List<SelectOption> getMyPersonalTemplateOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select Template--'));
        // Each User has a 'My Personal Templates' folder of EmailTemplates, whose Id is the User's Id
        // CR-00116268: Sorting alpabetically
        for (EmailTemplate t : [select Id,Name, isActive from EmailTemplate where FolderId = :UserInfo.getUserId() order by name]) {
            if(t.IsActive){
                options.add(new SelectOption(t.Id,t.Name));
            }
        }
        return options;
    }
    
    public void setSelectedTemplate() {
    System.debug('Entered setSelectedTemplate'+selectedTemplateId);
        
        if(selectedTemplateId!=null && selectedTemplateId!=''){
        System.debug('Entered If'+selectedTemplateId);
            templateId=selectedTemplateId;
            System.debug('Template'+templateId);
            setTemplate2();
        }
    }
    //CR-00123420 : Personal Template code ends   
   //CR-00139055 - Start - functions that get values for Status and Sub-status fields (Srishti)
        public  List<SelectOption> getStatus() {   
            List<SelectOption> slOpList = new List<SelectOption>();
            if(caserecord.Status != 'Open')
                slOpList.add(new SelectOption(caserecord.Status, caserecord.Status));
            slOpList.add(new SelectOption('Open', 'Open'));
            return slOpList;   
        }

        public List<SelectOption> getSubStatus(){
            List<SelectOption> sbStList = new List<SelectOption>();
                if(statusVal != null){
                    if(statusVal.contains(caserecord.Status) && caserecord.Sub_Status__c == null)
                    {
                        sbStList.add(new selectOption('--None--', '--None--'));
                    }
                    if(statusVal.contains(caserecord.Status) && caserecord.Sub_Status__c != null && !subStatusSet.contains(caserecord.Sub_Status__c))
                    {
                        sbStList.add(new selectOption(caserecord.Sub_Status__c, caserecord.Sub_Status__c));
                    }
                    if(statusVal.contains('Open')){
                        sbStList.add(new selectOption('Assigned', 'Assigned'));
                        sbStList.add(new selectOption('Customer To Confirm Fix', 'Customer To Confirm Fix'));
                        sbStList.add(new selectOption('Customer Requests Close', 'Customer Requests Close'));
                        sbStList.add(new selectOption('On Hold Per Customer', 'On Hold Per Customer'));
                        sbStList.add(new selectOption('Waiting on Customer', 'Waiting on Customer'));
                        sbStList.add(new selectOption('Waiting on Escalation Engineer', 'Waiting on Escalation Engineer'));
                        sbStList.add(new selectOption('Waiting on Partner', 'Waiting on Partner'));
                        sbStList.add(new selectOption('Wait on Engineering', 'Wait on Engineering'));
                        sbStList.add(new selectOption('Working', 'Working'));
                    }
                }
            return sbStList;
       }
// CR-00139055 - End   
}
