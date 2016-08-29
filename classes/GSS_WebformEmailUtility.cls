/**************************************************************************************
* Class Name   : GSS_WebformEmailUtility
* Purpose      : To Process Webform emails
* CR Number    : CR-00102921
* Created By   : Nierrbhayy
* Created Date : 28/07/2015
************************Version Updates************************************************
 Updated Date(DD/MM/YYYY)         Updated By     CR/Defect Number         Comments
* 16/09/2015                    Sakshi Suri        CR-00136175         Updated comma sepration in emails with semicolon
* 16-jun-2016                   Suresh Kumar       CR-00139127         Update  Status and Resolution on Inbound Email Received
* 20-july-2016                  Suresh Kumar       CR-00140163         Attach KB under related list section on case closed resolved by a KB
************************Version Updates************************************************/
global class GSS_WebformEmailUtility{
  public static boolean checkKXRecommender = false;
  public static Id cId ;
  public static String KXRecommender = System.Label.GSS_Webform;//CR-00139127
  public static String kbNumber ='';//CR-00140163
    /**
    * @param Messaging.InboundEmail email
    * @param Messaging.InboundEnvelope envelope
    * @param Integer oint
    * @return void
    * This method creates an Email Message in SFDC for a WorkItem
    *
    **/    
    public static void createWebformEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope, String status){
        Boolean isFilteredOut = false;
        Boolean attachmentSizeExceeded = false;
        String reason = '';
        
        Webform_Email__c emailMessage = new Webform_Email__c();
        emailMessage.FromAddress__c = email.fromAddress;
        //Populate cc addresses
        if(email.ccAddresses!=null){
            emailMessage.CcAddress__c = getEmailAddresses(email.ccAddresses);
        }
        //Populate to addresses
        if(email.toAddresses!=null){
            emailMessage.ToAddress__c = getEmailAddresses(email.toAddresses);
        }       
                
        emailMessage.FromName__c = email.fromName;
        emailMessage.Subject__c = email.Subject;
         system.debug('html body '+email.htmlBody);
        if(email.htmlBody != null){
            //CR-00139127 Starts
            if(!recursive.checkInbound){
                checkKXRecommender = email.htmlBody.contains(KXRecommender);//CR-00139127
                recursive.checkInbound = true;
            }//CR-00139127 Ends
            kbNumber = getKBNumber(email.htmlBody);//CR-00140163
            if(email.htmlBody.length()>70000){emailMessage.htmlBody__c = email.htmlBody.substring(0,69999);}
            else{emailMessage.HtmlBody__c = email.htmlBody;}
        }
        if(email.plainTextBody != null){
            //CR-00139127 Starts
            if(!recursive.checkInbound){
                checkKXRecommender = email.plainTextBody.contains(KXRecommender);//CR-00139127
                recursive.checkInbound = true;
            }//CR-00139127 Ends
            kbNumber = getKBNumber(email.plainTextBody);//CR-00140163
            if(email.plainTextBody.length()>70000){emailMessage.TextBody__c = email.plainTextBody.substring(0,69999);}
            else{emailMessage.TextBody__C = email.plainTextBody;}
        }
        if ((email.binaryAttachments != null && email.binaryAttachments.size() > 0) || (email.textAttachments != null && email.textAttachments.size() > 0)){
            emailMessage.HasAttachment__c = true;
        }

        emailMessage.MessageDate__c = System.now();
        emailMessage.Status__c = status;
        emailMessage.messageId__c=email.messageId;
        emailMessage.Incoming__c=true;                     

        insert emailMessage;
                       
        //Check out for Spam emails 
        List <GSS_Webform_Filters__c> filters = GSS_Webform_Filters__c.getAll().values();
        
        if(filters.size()>0){
            for(GSS_Webform_Filters__c emailbypass: filters){
                if(emailbypass.Active__c){
                    if(emailbypass.Subject__c){
                        String strSubject = email.Subject;
                        if(email.Subject.indexOf(emailbypass.rule__c.trim())>-1){
                            reason = 'ByPass Filter - '+emailbypass.rule__c.trim() + ' - Subject';
                            isFilteredOut = true;
                        }
                    }
                    if(emailbypass.From_Email__c){
                        if(email.fromAddress.indexOf(emailbypass.rule__c.trim())>-1){
                            reason = 'ByPass Filter - '+emailbypass.rule__c.trim() + ' - FromEmail';
                            isFilteredOut = true;                      
                        }
                    }
                    if(emailbypass.Body__c){
                        String strBody = '';
                        if(email.plainTextBody==null){
                            strBody = email.htmlBody;}
                        else{
                            strBody = email.plainTextBody;}
                        if(strBody.indexOf(emailbypass.rule__c.trim())>-1){
                            reason = 'ByPass Filter - '+emailbypass.rule__c.trim() + ' - body';
                            isFilteredOut = true;}                     
                    }   
                }
            }
        }      
        
        system.debug('isFilteredOut == '+isFilteredOut);
        
        if(isFilteredOut){
            emailMessage.Last_Sync_attempt_date__c=system.now();
            if(emailMessage.Sync_Attempts__c!=null){
                emailMessage.Sync_Attempts__c=emailMessage.Sync_Attempts__c+1;
            }else{
                emailMessage.Sync_Attempts__c=1;
            }
            if(emailMessage.Sync_Error_Detail__c!=null){
                emailMessage.Sync_Error_Detail__c=emailMessage.Sync_Error_Detail__c+ '\n---------------------------\n' +reason;
            }else{
                emailMessage.Sync_Error_Detail__c= ''+reason;
            }
        }else{
            //Look for related case.
            Id caseId=getCaseDetailsfromRefID(email.Subject);
            if(caseId!=null){           
                emailMessage.ParentId__c=caseId;
                emailMessage.Mark_For_Sync__c=true;
                emailMessage.Last_Sync_attempt_date__c=system.now();
            }
        }              
                
        //Validate Attachment size is within the prescribed limit.
        integer totalSize=0;
        integer maxSize=0;
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                String sizeStr = String.valueOf(email.binaryAttachments[i].Body);
                if(sizeStr!=null && sizeStr !=''){
                    sizeStr = sizeStr.replace('Blob[','').replace(']','').trim();
                }
                totalSize=totalSize+Integer.valueOf(sizeStr);
            }
        }
        if (email.textAttachments != null && email.textAttachments.size() > 0) {
            for (integer i = 0 ; i < email.textAttachments.size() ; i++) {
                String sizeStr = String.valueOf(Blob.valueOf(email.textAttachments[i].Body));
                if(sizeStr!=null && sizeStr !=''){
                    sizeStr = sizeStr.replace('Blob[','').replace(']','').trim();
                }
                totalSize=totalSize+Integer.valueOf(sizeStr);
            }
        }
        
        //Get Max attachment size from custom setting
        GSS_Webform_Variables__c wv = GSS_Webform_Variables__c.getOrgDefaults();
        if(wv.Max_Attachment_Size__c!=null){
            maxSize=wv.Max_Attachment_Size__c.intValue()*1000000;
        }else{
            maxSize=10*1000000; // Defaulting to 10 Mb
        }
        
        if(totalSize > maxSize){
            attachmentSizeExceeded=true;
        }
        if(attachmentSizeExceeded){
            reason ='Attachment size exceeded limit. Max size allowed is '+ maxSize + 'bytes, Current size is ' + totalSize + ' bytes.';
            emailMessage.Mark_For_Sync__c=false;
            emailMessage.Last_Sync_attempt_date__c=system.now();
            if(emailMessage.Sync_Attempts__c!=null){
                emailMessage.Sync_Attempts__c=emailMessage.Sync_Attempts__c+1;
            }else{
                emailMessage.Sync_Attempts__c=1;
            }
            if(emailMessage.Sync_Error_Detail__c!=null){
                emailMessage.Sync_Error_Detail__c=emailMessage.Sync_Error_Detail__c+ '\n---------------------------\n' +reason;
            }else{
                emailMessage.Sync_Error_Detail__c= ''+reason;
            }
        }       
        
        update emailMessage;
        
        //Adding binary attachments to Webform Email
        List<Attachment> allBinaryAttachments = new List<Attachment>();
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {       
                Attachment attachment = new Attachment();
                attachment.Name = email.binaryAttachments[i].filename;
                attachment.Body = email.binaryAttachments[i].Body;
                attachment.ParentId = emailMessage.id;
                allBinaryAttachments.add(attachment);                
            }
            
            if(!allBinaryAttachments.isEmpty()){
                database.insert(allBinaryAttachments);
            } 
        }    
        //Adding text attachments to Webform Email     
        List<Attachment> allTextAttachments = new List<Attachment>();
        if (email.textAttachments != null && email.textAttachments.size() > 0) {
            for (integer i = 0 ; i < email.textAttachments.size() ; i++) {       
                Attachment txtAttachment = new Attachment();
                txtAttachment.Name = email.textAttachments[i].filename;
                txtAttachment.Body = Blob.valueOf(email.textAttachments[i].Body);
                txtAttachment.ParentId = emailMessage.id;
                allTextAttachments.add(txtAttachment);
            }
            
            if(!allTextAttachments.isEmpty()){
                insert allTextAttachments;
            }
        }
        
        //Attempt to tag the email to the case:
        if(emailMessage.id!=null && emailMessage.ParentId__c!=null && !attachmentSizeExceeded){
            tagEmailToCase(String.ValueOf(emailMessage.id),String.ValueOf(emailMessage.ParentId__c));
        } 
    }
    
    /**
    * @param List<String> emailIDList
    * @return String
    * This method is used to get list of email ids as comma separated values
    *
    **/
    public static String getEmailAddresses(List<String> emailIDList){
        String strEmailIDs = '';
        if(emailIDList.size()==1){
            strEmailIDs = emailIDList[0];
        }else{
            for(integer i=0;i<emailIDList.size();i++){
                if(strEmailIDs == ''){//CR-00136175 Sakshi Suri 16th Sep 2015 updated null with ''
                    strEmailIDs = emailIDList[i];
                }else{
                    strEmailIDs = strEmailIDs  + ';'+emailIDList[i];//CR-00136175 Sakshi Suri 16th Sep 2015 Updated comma(,) with semicoln(;)
                }
            }
        }
        return strEmailIDs;            
    }
    
    /**
    * @param String stringWithRefId
    * @return Id
    * This method is used to get the case ID from the refID
    *
    **/
    public static Id getCaseDetailsfromRefID(String stringWithRefId){
        String caseIdstr=GSS_EmailToCaseUtility.validateRefId(stringWithRefId);
        Id caseId;
        try{
            if(caseIdstr!=''){
                List<Case> srcase = [select id, CaseNumber from case where Id = :caseIdstr limit 1];
                //If case exists send the case id
                if(srcase !=null && srcase.size()>0){
                    caseId=srcase[0].id;
                }
            }
        }catch(exception e){}
        return caseId;
    }
    
    /**
    * @param Id caseid
    * @return void
    * This method is used to update the substatus of the case to Inbound message received
    *
    **/
    public static void updateCaseSubStatus(Id caseid){
        system.debug(':::::::kbNumber1::::::'+kbNumber+':::::::'+caseid);
        try{
                if(caseid!=null){
                    List<Case> srcase = [select id,Status, GSS_Resolution_Code__c, Sub_Status__c, CaseNumber from case where Id = :caseid limit 1];
                    //If case exists send the case id CR-00139127 Starts
                    if(srcase !=null && srcase.size()>0){
                        cId = srcase[0].Id;
                        if(srcase[0].Sub_Status__c!='Inbound message received' && !checkKXRecommender && kbNumber == ''){//CR-00139127 added CR-00140163 check kbNumber
                            srcase[0].Sub_Status__c='Inbound message received';
                            database.update(srcase);
                            system.debug(':::::Case:::::'+srcase);
                        }
                       
                    }
                }
            
            } catch(exception e){} 
    }
    
    /**
    * @param Webform_Email__c wEmail
    * @param id caseId
    * @return void
    * This method is used to associate the email to the case
    *   
    **/
    webservice static void tagEmailToCase(string wEmailId,string caseId){
        if(wEmailId==null || caseId==null){
            return;
        }
        Webform_Email__c wEmail=[Select id,FromAddress__c, CcAddress__c, ToAddress__c, FromName__c, Subject__c, htmlBody__c, TextBody__c, HasAttachment__c, MessageDate__c, Status__c, Incoming__c, ParentId__c, Sync_Attempts__c, Sync_Error_Detail__c, Mark_For_Sync__c, Last_Sync_attempt_date__c from Webform_Email__c where id=:wEmailId limit 1];
        Integer maxSyncAttempt=5;
        GSS_Webform_Variables__c webformVariables = GSS_Webform_Variables__c.getOrgDefaults();
        if(webformVariables.Max_Sync_Attempts__c!=null){
            maxSyncAttempt=webformVariables.Max_Sync_Attempts__c.intValue();
        }        
        try{
            if(wEmail!=null){
                EmailMessage newEmail = new EmailMessage();
                newEmail.fromAddress = wEmail.FromAddress__c;        
                newEmail.CcAddress = wEmail.CcAddress__c;
                newEmail.ToAddress = wEmail.ToAddress__c;                
                newEmail.FromName = wEmail.FromName__c;
                newEmail.Subject = wEmail.Subject__c;
                if(wEmail.htmlBody__c != null){
                    if(wEmail.htmlBody__c.length()>32000){ 
                        newEmail.HtmlBody = wEmail.htmlBody__c.substring(0,31999);}
                    else{
                        newEmail.HtmlBody = wEmail.htmlBody__c;
                    }
                }
                if(wEmail.TextBody__c != null){
                    if(wEmail.TextBody__c.length()>32000){
                        newEmail.TextBody = wEmail.TextBody__c.substring(0,31999);}
                    else{
                        newEmail.TextBody = wEmail.TextBody__c;}
                }
                
                newEmail.MessageDate = wEmail.MessageDate__c;
                newEmail.Status = '0';
                newEmail.Incoming=wEmail.Incoming__c;                     
                newEmail.ParentId=caseId;
                database.insert(newEmail);
                
                updateCaseSubStatus(caseId);
                
                //Copy attachments to email object
                if(wEmail.HasAttachment__c){
                    List<GSS_File_Attachment__c > gssFileAttachments = new List<GSS_File_Attachment__c >();
                    List<Attachment> fileAttachments = new List<Attachment>();
                    for(Attachment att:[SELECT Id, Body, BodyLength, ContentType, Description, Name, ParentId FROM Attachment where  ParentId=:wEmail.id]){
                        Attachment efa = new Attachment();
                        efa.Name=att.Name;                
                        efa.Body=att.Body;
                        efa.ParentId=newEmail.id;            
                        fileAttachments.add(efa);
                        
                        //For GSS File Attachments
                        GSS_File_Attachment__c gfa = new GSS_File_Attachment__c();
                        gfa.GSS_File_Name__c = att.Name;
                        gfa.Case__c = caseId;
                        String sizeStr = String.valueOf(att.Body);
                        if(sizeStr!=null && sizeStr !=''){
                            sizeStr = sizeStr.replace('Blob[','').replace(']','').trim();
                        }
                        gfa.GSS_File_Size__c = Integer.valueOf(sizeStr);
                        gssFileAttachments.add(gfa);
                    }
                    database.insert(fileAttachments);
                    database.insert(gssFileAttachments);
                }
                
                wEmail.Tagged_to_Case__c=true;
                wEmail.Last_Sync_attempt_date__c=system.now();
                update wEmail;
            }
        }catch(exception e){
            if(wEmail!=null){
                if(wEmail.Sync_Attempts__c!=null){
                    wEmail.Sync_Attempts__c=wEmail.Sync_Attempts__c+1;
                }else{
                    wEmail.Sync_Attempts__c=1;
                }
                if(wEmail.Sync_Error_Detail__c!=null){
                    wEmail.Sync_Error_Detail__c=wEmail.Sync_Error_Detail__c+ '\n---------------------------\n' +e;
                }else{
                    wEmail.Sync_Error_Detail__c= ''+e;
                }
                if(wEmail.Sync_Attempts__c>maxSyncAttempt){
                    wEmail.Mark_For_Sync__c=false;
                }
                wEmail.Last_Sync_attempt_date__c=system.now();
                update wEmail;
            }
        }
    }
    // Sakshi Suri CR-00136182 Starts 
        /**
      * @param Case oCase
      * @param Messaging.InboundEmail email
      * @param GSS_E2C_Configuration__c E2CConfig
      * @return void
      * @CR CR-00136182
      * This method creates a task for the case
      *
      **/
    
    public static void createTask(Messaging.InboundEmail email, GSS_E2C_Configuration__c E2CConfig){       
        Task task = new Task();
        Id caseId=getCaseDetailsfromRefID(email.Subject);
        if(caseId!=null){ 
            Case oCase = [Select ContactId,OwnerId,Id from Case Where Case.id=:caseId];
            if(oCase!=null){
            if(oCase.ContactId!=null){
                task.WhoId = oCase.ContactId;
            }

            task.WhatId = oCase.Id;
                if(oCase.OwnerId!=null){
                
                     if(!string.valueOf(oCase.OwnerId).startsWith('00G'))
                          {
                            
                           task.OwnerId=oCase.OwnerId;
                           }
                 
                }
            }
            if(E2CConfig!=null){
                task.Subject = E2CConfig.Task_Subject__c ;
                task.status = E2CConfig.Task_Status__c;
                task.recordTypeId = (Id) E2CConfig.Task_Record_Type__c;
                task.type = E2CConfig.Task_Type__c;
            }
            task.description = '';
            task.ActivityDate = System.Today();  
            
            if(email.plainTextBody == null){
               if(email.htmlBody != null && email.htmlBody.length()>32000){
                      task.Description = email.htmlBody.substring(0,21999);
                }
                else{
                    task.Description = email.htmlBody;}
            }
            else{
                if(email.plainTextBody.length()>32000){
                    task.Description = email.plainTextBody.substring(0,21999);
                }
                else{
                    task.Description = email.plainTextBody;}                
            }        
        
            
            insert task;
        }
        
    }
    // Sakshi Suri CR-00136182 Ends 
    public static void updateCaseOnInboundMessageReceived(List<Case> triggerNew){
        //Suresh Kumar CR-00139127 Starts 
        if(kbNumber != ''){
            for(Case cs : triggerNew){
                    cs.Status = 'Closed - Resolved';
                    cs.Sub_Status__c = 'Resolved';
                    cs.GSS_Resolution_Code__c = 'KX Recommender';
                    if(!recursive.KBCheck && cs.Id != null){
                        createKBonCase(cs.Id, kbNumber);
                        recursive.KBCheck = true;
                    }
                }
            }//Suresh Kumar CR-00139127 Ends
        
        else if(checkKXRecommender && kbNumber == ''){
            for(Case cs : triggerNew){
                cs.Status = 'Closed - Resolved';
                cs.Sub_Status__c = 'Resolved';
                cs.GSS_Resolution_Code__c = 'KX Recommender';
            }
        }
    }
  //CR-00140163 Starts 
  @future//tag KB to case
    public static void createKBonCase(Id csId, String kbNumbers){
        system.debug('::::'+kbNumbers+'::::::::::::::::::::::csId:::::::::'+csId);
            List<GSS_Knova__c> knova = [select id, GSS_KB_ID__c from GSS_Knova__c where GSS_KB_ID__c =:kbNumbers];GSS_Case_Knova__c kb = new GSS_Case_Knova__c(GSS_Case_Number__c =csId, GSS_KnovaSFDCID__c =knova[0].Id);
            try{
                Database.insert(kb, false);
            }catch(Exception e){}
    }
    //Extract KB number from email
    public static String getKBNumber(String str){
        String KBNum ='';
        List<String> strList = str.split(' ');
        Set<String> strSet = new Set<String>(strList);
        for(String st : strSet){
            if(st.contains('KB')){
                List<String> subStr = st.split('');
                for(String s : subStr){
                    if(s.isNumeric()){
                        KBNum += s;
                    }
                }
                break;
            }
        }
        return KBNum;
    }
    //CR-00140163 Ends
    
}