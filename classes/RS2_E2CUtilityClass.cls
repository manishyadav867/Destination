/**********************************************************************************************************
Creted By      : N. V V L Vinay Kumar
Creted On      : 20-May-2014
Cr No.         : CR-00087968
Description    : This Class is refered in the Email Service Class RS2_emailToCase

Update History    
Updated Date        Updated By        CR NO.                        Update Description
5 July 2014         Hemangini       CR-00087870                     Added check for calling Opportunity Identification Exception Handling method
12 Dec 2014         Ravi Kiran D    BUG-00107477(Enhancement) -     Changed the "Service_Contract_Number__c" reference of Opportunity to "RS2_Expiring_Contract_Number__c"
02 March 2015       Bhumika Udani   CR-00128726                     Moved two workflow conditions into trigger sendEmailUpdateCheck
16 March 2015       Ravi Arrabelli  CR-00129659                     Added logic to capture Partner Info, Channel Partner Info and Parent Case
06 May 2015      Bhumika Udani   CR-00128726            Fixing test failure
09-Aug-16        Pabitra        CR-00140109               Removed System.debug
**********************************************************************************************************/

public Class RS2_E2CUtilityClass{

    //Constructor - Start
    public RS2_E2CUtilityClass(){
    }
    //Constructor - End 
    
    public static void createSampleSpam(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        
        GSS_Spam_Email__c oSpam = new GSS_Spam_Email__c();
            
            oSpam.CreatedFromRS2__c = true;
            oSpam.Subject__c = email.subject;
            oSpam.From_Address__c = email.fromAddress;
            oSpam.From_Name__c = email.fromName;
            oSpam.To_Address__c = emailIDFrmList(email.toAddresses);
            
            oSpam.Message_Date__c = System.now();
            oSpam.HTML_Body__c = envelope.fromAddress;
            oSpam.Text_Body__c = email.plainTextBody;
            oSpam.Status__c = 'New';      
            oSpam.Reason__c =  envelope.ToAddress;
            
            if(email.ccAddresses!=null){
                oSpam.Cc_Address__c = emailIDFrmList(email.ccAddresses);
            }
        insert oSpam;
    
    }
    
    //Method for splitting the Email Body - Start
    public static list<string> splitEmailBody(string emailBody){
        list<string> emailBodyAfterSplit = new list<string>();
        if(emailBody != null){
            emailBodyAfterSplit = emailBody.split('\n', 0);
        }
        return emailBodyAfterSplit;
    }
    //Method for splitting the Email Body - End
    
    //Method to Insert attachments from Email and Email as Attachment - Start
    public static void insertAttachment(Messaging.InboundEmail email, list<Case> caseList, Boolean isRCMAttachment){
        try{
            if(caseList != null && !caseList.isEmpty()){            
                
                list<Attachment> attachmentList = new list<Attachment>();
                
                //creating attachment with Email Body
                Attachment attInstance = new Attachment();
                
                for(Case caserec : caseList){
                    //creating attachment with Email Body - Start
                    attInstance = new Attachment();
                    attInstance.ParentId = caserec.Id;
                    attInstance.Name = 'Email';
                    attInstance.ContentType = 'pdf';
                    if(email.plainTextBody != null){
                        attInstance.body = Blob.valueOf(email.plainTextBody);
                    }else if(email.htmlBody != null){
                        attInstance.body = Blob.valueOf(email.htmlBody);
                    }
                    //creating attachment with Email Body - End
                    
                    attachmentList.add(attInstance);
                    
                    //creating attachment from Email binary attachments - Start
                    if (email.binaryAttachments != null){
                        if(!email.binaryAttachments.isEmpty()){
                            Attachment binaryAttInstance;
                            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                                binaryAttInstance = new Attachment();
                                binaryAttInstance.ParentId = caserec.Id;                        
                                binaryAttInstance.Name = email.binaryAttachments[i].filename;                        
                                binaryAttInstance.body = email.binaryAttachments[i].Body;                        
                                attachmentList.add(binaryAttInstance);
                            }
                        }
                    }
                    //creating attachment from Email binary attachments - End
                    
                    //creating attachment from Email text attachments - Start
                    if (email.textAttachments != null){
                        if(!email.textAttachments.isEmpty()){
                            Attachment textAttInstance;
                            for (integer i = 0 ; i < email.textAttachments.size() ; i++) {                            
                                textAttInstance = new Attachment();
                                textAttInstance.ParentId = caserec.Id;                        
                                textAttInstance.Name = email.textAttachments[i].filename;                        
                                textAttInstance.body = blob.valueOf(email.textAttachments[i].Body);
                                attachmentList.add(textAttInstance);
                            }
                        }
                    }
                    //creating attachment from Email text attachments - End
                }         
                
                //attachment insertion - Start 
                if(!attachmentList.isEmpty()){
                    try{                                
                        list<Database.SaveResult> lstAttachInsert = Database.insert(attachmentList,false);
                        
                        if(lstAttachInsert != null && !lstAttachInsert.isEmpty()){
                            CreateApexErrorLog.insertHandledExceptions(null,lstAttachInsert, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'insertAttachment');
                        }                    
                        
                        if(isRCMAttachment){
                            list<RCM_Attachments__c> rcmAttachmentsList = new list<RCM_Attachments__c>();
                            RCM_Attachments__c rcmAttachment;
                            for(Attachment a : attachmentList){
                                rcmAttachment = new RCM_Attachments__c();
                                rcmAttachment.Attachment_Id__c = a.Id;
                                rcmAttachment.Case_Parent_Id__c = a.ParentId;
                               if(a.Name == 'Email'){
                                    rcmAttachment.Visible__c = FALSE;
                                }else{
                                    rcmAttachment.Visible__c = TRUE;
                                }

                                rcmAttachment.Name = a.Name;
                                rcmAttachmentsList.add(rcmAttachment);
                            }
                            
                            if(rcmAttachmentsList != null && !rcmAttachmentsList.isEmpty()){
                                list<Database.SaveResult> lstRCMAttachInsert = Database.insert(rcmAttachmentsList,false);
                                
                                if(lstRCMAttachInsert != null && !lstRCMAttachInsert.isEmpty()){
                                    CreateApexErrorLog.insertHandledExceptions(null,lstRCMAttachInsert, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'insertAttachment');
                                }                   
                                
                            }
                        }
                        
                    }catch(Exception e){
                        CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'insertAttachment');
                    }
                }
                //attachment insertion - end                      
            }
        
        }catch(Exception e){
            CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'insertAttachment');
        }          
    }
    //Method to Insert attachments from Email and Email as Attachment - End    
    
    //Method for processing the email and creating the Case in My VMWare Email TO Case scenario.- Start
    public static void processEmailToCreateCase(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        system.debug('envelope   '+envelope);
        try{           
            
            String[] emailSplits = envelope.ToAddress.split('@');
            String emailAlias = emailSplits[0].toLowerCase();           
            system.debug('envelope   '+envelope);
            system.debug('emailAlias   '+emailAlias);
            list<Case> caseList = new list<Case>();
            
            //Fetching the assignment rules on case - Start 
            AssignmentRule AR;
            list<AssignmentRule> assignmentRuleList = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            if(!assignmentRuleList.isEmpty() && assignmentRuleList != null){
                
                if(assignmentRuleList[0] != null){
                    AR = new AssignmentRule();
                    AR = assignmentRuleList[0];
                }
            }                 
            //Fetching the assignment rules on case - End
                
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox - Start         
            Database.DMLOptions dmlOpts;
            if(AR != null){
                dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            }    
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox - End
            
            
            //ADDED CHECK FOR CR-00087870 - Oppty ID Exception Handling -START
            
            //if emailAlias is informatica AND email subject split by ':' equals the email Subject from RS2_OI_Static_Values__c AND a record is present in RS2_E2C_Email_Alias_Setup__c for the email alias, then call the Oppty ID Exception Handling method. Else continue with the processing here.
            if(emailAlias.equalsIgnoreCase(RS2_OI_Static_Values__c.getInstance('Exception Handling Email Alias').Value__c) 
            && email.subject.split(':',0)[0].trim().equalsIgnoreCase(RS2_OI_Static_Values__c.getInstance('Exception Handling Email Subject').Value__c) 
            && RS2_E2C_Email_Alias_Setup__c.getInstance(RS2_OI_Static_Values__c.getInstance('Exception Handling Email Alias').Value__c) != null){
            
                RS2_ExceptionHandling.processE2CForOpptyId(email,envelope); 
            
            }
            //CHECK FOR CR-00087870 - Oppty ID Exception Handling -END
            else{
                
                Case newCase;
                Case newCase1;
                
                list<string> emailBodyAfterSplit = new list<string>();
                String emailPlainBody = email.plainTextBody;
                String emailHTMLBody = email.htmlBody;        
                
                //splitting the Email Body - Start
                if(emailPlainBody != '' && emailPlainBody != null){        
                    emailBodyAfterSplit = RS2_E2CUtilityClass.splitEmailBody(emailPlainBody);         
                }else if(emailHTMLBody != '' && emailHTMLBody != null){
                    emailBodyAfterSplit = RS2_E2CUtilityClass.splitEmailBody(emailHTMLBody);
                }
                //splitting the Email Body - End                
                
                RS2_E2C_Email_Alias_Setup__c systemAttributeValues = RS2_E2C_Email_Alias_Setup__c.getValues(emailAlias);
                if((emailPlainBody != '' && emailPlainBody != null) || (emailHTMLBody != '' && emailHTMLBody != null)){
                    if(systemAttributeValues != null){
                        //Checking if the case cration process is active for the Email Alias and then assigning case attribute values - Start
                        if(systemAttributeValues.Is_Active__c){                      
                            newCase = new Case();
                        
                            if(systemAttributeValues.Is_Subject__c){
                                if(email.subject != '' && email.subject != null){
                                  newCase.Subject = email.subject.trim();
                                }                 
                            }
                        
                            Map<String, RS2_E2C_Field_Mapping_and_Configuration__c> standardAttributeAPINameMap = RS2_E2C_Field_Mapping_and_Configuration__c.getAll();
                            Map<String, Schema.SObjectField> standardAttributes = Schema.SObjectType.RS2_E2C_Email_Alias_Setup__c.fields.getMap();
                            
                            for(String  stAtt : standardAttributes.keySet()){                               
                               String fieldName = standardAttributes.get(stAtt).getDescribe().getLabel();
                               String fieldapi = standardAttributes.get(stAtt).getDescribe().getName();
                               
                                if(standardAttributeAPINameMap.containsKey(fieldName)){
                                    system.debug('==> fieldName = '+standardAttributeAPINameMap.get(fieldName).API_Name__c);                  
                                    if(systemAttributeValues.get(fieldapi) != null){                      
                                        if(standardAttributeAPINameMap.get(fieldName).Type__c.equalsIgnoreCase('static') &&
                                            standardAttributeAPINameMap.get(fieldName).Is_Active__c &&  
                                            standardAttributeAPINameMap.get(fieldName).Module_Name__c.equalsIgnoreCase('Quote')){
                                            newCase.put(standardAttributeAPINameMap.get(fieldName).API_Name__c,systemAttributeValues.get(fieldapi));
                                        }                   
                                    }                                    
                                }     
                            }
                             
                            //Parsing the email body for capturing the attributes if Is_Attributes_from_Body__c is True - Start.
                            if(systemAttributeValues.Is_Attributes_from_Body__c){
                                //retreving the attribute and api values from custom setting and assigning to the case fields - Start            
                                list<RS2_E2C_Field_Mapping_and_Configuration__c> mappingConfigurationList = RS2_E2C_Field_Mapping_and_Configuration__c.getAll().values();          
                                
                                //Parsing the Email Body and getting the attribute Values - Start
                                if(!emailBodyAfterSplit.isEmpty() && emailBodyAfterSplit != null){            
                                    for(String bValue : emailBodyAfterSplit){
                                        if(!mappingConfigurationList.isEmpty() && mappingConfigurationList != null){
                                            for(RS2_E2C_Field_Mapping_and_Configuration__c mapConfig : mappingConfigurationList){
                                                if(mapConfig.Email_Alias__c != null){
                                                    if(mapConfig.Email_Alias__c.equalsIgnoreCase(emailAlias)){
                                                        if(mapConfig.Type__c != null){
                                                            if(mapConfig.Type__c.equalsIgnoreCase('dynamic')&& 
                                                            mapConfig.Is_Active__c && mapConfig.Module_Name__c.equalsIgnoreCase('Quote')){
                                                                
                                                                Map<String,String> partnerMap= new Map<String,String>(); //Added for CR-00129659
                                                                if(bValue.contains(mapConfig.Name)){
                                                                    list<string> bodyList = new list<string>();
                                                                    if(systemAttributeValues.Delimator__c != null && systemAttributeValues.Delimator__c != ''){                                                                        
                                                                        bodyList =  bValue.split(systemAttributeValues.Delimator__c.trim(),0);                                                                                               
                                                                        if(bodyList.size() >= 2){
                                                                            if(bodyList[1].trim() != null && bodyList[1].trim() != ''){                                                                         
                                                                                if(bodyList[1].trim().contains('<')){
                                                                                    list<string> slist = bodyList[1].trim().split('<');
                                                                                    system.debug('****slist---->'+slist);
                                                                                    if(!bodyList[1].trim().split('<').isEmpty() 
                                                                                    && bodyList[1].trim().split('<')[0].trim() != null 
                                                                                    && bodyList[1].trim().split('<')[0].trim() != ''){
                                                                                        if(mapConfig.API_Name__c != null && mapConfig.API_Name__c != ''){
                                                                                            if(mapConfig.Data_Type__c != null){
                                                                                                if(mapConfig.Data_Type__c.equalsIgnoreCase('Boolean')){
                                                                                                    newCase.put(mapConfig.API_Name__c,Boolean.valueOf(bodyList[1].trim().split('<')[0].trim()));
                                                                                                }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Number')){
                                                                                                    newCase.put(mapConfig.API_Name__c,Integer.valueOf(bodyList[1].trim().split('<')[0].trim()));
                                                                                                }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Date')){
                                                                                                    newCase.put(mapConfig.API_Name__c,Date.valueOf(bodyList[1].trim().split('<')[0].trim()));
                                                                                                }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Date/Time')){
                                                                                                    newCase.put(mapConfig.API_Name__c,Datetime.valueOf(bodyList[1].trim().split('<')[0].trim()));
                                                                                                }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Email')){                                                                                        
                                                                                                    string s = bodyList[1].trim().split('<')[0].trim();
                                                                                                    system.debug('####s---->'+s);
                                                                                                    newCase.put(mapConfig.API_Name__c,bodyList[1].trim().split('<')[0].trim());                                                                                  
                                                                                                }else{
                                                                                                    newCase.put(mapConfig.API_Name__c,bodyList[1].trim().split('<')[0].trim());
                                                                                                }                                            
                                                                                            }
                                                                                        } 
                                                                                    }
                                                                                }else{
                                                                                    if(mapConfig.API_Name__c != null && mapConfig.API_Name__c != ''){
                                                                                        if(mapConfig.Data_Type__c != null){
                                                                                            if(mapConfig.Data_Type__c.equalsIgnoreCase('Boolean')){
                                                                                                newCase.put(mapConfig.API_Name__c,Boolean.valueOf(bodyList[1].trim()));
                                                                                            }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Number')){
                                                                                                
                                                                                                //Added as part CR-00129659 - Part 1 START
                                                                                                
                                                                                                if(bValue.contains('Partner ID')||bValue.contains('Channel Partner PRMID')){
                                                                                                    partnerMap.put(bodyList[0].trim(),bodyList[1].trim());                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                }else if(bValue.contains('Parent Case')){
                                                                                                    list<Case> csList = [Select Id from Case where CaseNumber=:bodyList[1].trim()];
                                                                                                    if(!csList.isEmpty()){
                                                                                                        newCase.ParentId = csList[0].Id;
                                                                                                    }
                                                                                                }else{    
                                                                                                    
                                                                                                //Added as part of CR-00129659 - Part 1 END
                                                                                                                                                                                                    
                                                                                                    newCase.put(mapConfig.API_Name__c,Integer.valueOf(bodyList[1].trim()));
                                                                                                }
                                                                                            }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Date')){
                                                                                                newCase.put(mapConfig.API_Name__c,Date.valueOf(bodyList[1].trim()));
                                                                                            }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Date/Time')){
                                                                                                newCase.put(mapConfig.API_Name__c,Datetime.valueOf(bodyList[1].trim()));
                                                                                            }else if(mapConfig.Data_Type__c.equalsIgnoreCase('Email')){
                                                                                                string s = bodyList[1].trim();                                                                                                
                                                                                                if(bodyList[1].trim().contains('<')){                                                                                    
                                                                                                    if(bodyList[1].trim().split('<',0)[0].trim() != null &&
                                                                                                    bodyList[1].trim().split('<',0)[0].trim() != ''){
                                                                                                        newCase.put(mapConfig.API_Name__c,bodyList[1].trim().split('<',0)[0].trim());
                                                                                                    }
                                                                                                }else{
                                                                                                    newCase.put(mapConfig.API_Name__c,bodyList[1].trim().split('<',0)[0].trim());
                                                                                                }
                                                                                                
                                                                                            }else{
                                                                                                newCase.put(mapConfig.API_Name__c,bodyList[1].trim());
                                                                                            }                                            
                                                                                        }
                                                                                    } 
                                                                                }
                                                                            }                                
                                                                        }
                                                                    }//end of if(systemAttributeValues.Delimator__c != null && systemAttributeValues.Delimator__c != '')                                                                                                       
                                                                }
                                                                //Added as part CR-00129659 - Part 2 START
                                                                
                                                                if(!partnerMap.isEmpty()){
                                                                    list<Account> lsAcc = [Select Id,Partner_ID__c from Account where Partner_ID__c=:partnerMap.values()];
                                                                    for (integer i=0;i<lsAcc.size();i++){
                                                                        if (partnerMap.get('Partner ID')==lsAcc[i].Partner_ID__c){
                                                                            newCase.AccountId = lsAcc[i].Id;
                                                                        }else if(partnerMap.get('Channel Partner PRMID')==lsAcc[i].Partner_ID__C){
                                                                            newcase.Channel_Partner__c = lsAcc[i].Id;
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                //Added as part CR-00129659 - Part 2 END
                                                            }
                                                        }
                                                    }
                                                }
                                            }                        
                                        }
                                        
                                        
                                        //For MyVMWare Scenario parsing the Prefered Partner value to get Partner ID and retreving the Account - Start.    
                                        if(systemAttributeValues.Is_Prefred_Partner__c){
                                            if(bValue.contains('Preferred Partner')){
                                                if(systemAttributeValues.Delimator__c != null && systemAttributeValues.Delimator__c != ''){
                                                     list<string> sList = bValue.split(systemAttributeValues.Delimator__c.trim(),0);                                                                        
                                                    if(sList.size() >= 3){
                                                        if(sList[2].trim() != null && sList[2].trim() != ''){
                                                            if(sList[2].trim().contains('>')){
                                                                if(!sList[2].trim().split('<').isEmpty() 
                                                                && sList[2].trim().split('<')[0].trim() != null 
                                                                && sList[2].trim().split('<')[0].trim() != ''){
                                                                    list<Account> accList = [Select Id from Account where Partner_ID__c=:sList[2].trim().split('<')[0].trim()];
                                                                    if(!accList.isempty()){                                                    
                                                                        newCase.AccountId = accList[0].Id;                                                                                                                          
                                                                    }
                                                                }                                                    
                                                            }else{
                                                                list<Account> accList = [Select Id from Account where Partner_ID__c=:bValue.split(':',0)[2].trim()];
                                                                if(!accList.isempty()){                                                    
                                                                    newCase.AccountId = accList[0].Id;                                                                                                                       
                                                                }
                                                            }                                                
                                                        }                                    
                                                    }
                                                }//end of if(systemAttributeValues.Delimator__c != null && systemAttributeValues.Delimator__c != '')                                       
                                            }
                                        }
                                        //For MyVMWare Scenario parsing the Prefered Partner value to get Partner ID and retreving the Account - End.                                                                             
                                    }       
                                }
                                //Parsing the Email Body and getting the attribute Values - End
                                //retreving the attribute and api values from custom setting and assigning to the case fields - end                          
                                 
                                //Based on VMware Contract Number get the Opportunity, based on Opportunity result assign case variables - Start
                                if(systemAttributeValues.Is_Opportunity_Mapping__c){
                                    if(newCase.Vmware_Contract_Number__c != null){                                       
                                        if(newCase.Vmware_Contract_Number__c.contains(',')){
                                            newCase.Request_Type__c = RS2_Quoting__c.getInstance('Quote Consolidation').Value__c;
                                            newCase.Request_Sub_Type__c = RS2_Quoting__c.getInstance('New').Value__c;
                                        }else{
                                            newCase.Request_Type__c = RS2_Quoting__c.getInstance('Single Quote').Value__c;
                                            newCase.Request_Sub_Type__c = RS2_Quoting__c.getInstance('New').Value__c;                                             
                                            list<Opportunity> opplist = [Select Id from Opportunity where RS2_Expiring_Contract_Number__c =:newCase.Vmware_Contract_Number__c.trim()];
                                            if(!opplist.isempty()){
                                                if(opplist.size() == 1){                                             
                                                     newCase.Opportunity_ID__c = opplist[0].Id;
                                                 }else if(opplist.size() > 1){
                                                     newCase.Reason = RS2_Quoting__c.getInstance('Multiple Opportunities').Value__c;
                                                 }                                              
                                             }else{
                                                 newCase.Reason = RS2_Quoting__c.getInstance('No Opportunity').Value__c;
                                             }
                                        }                                       
                                    }
                                }                                
                                //Based on service Contract Number get the Opportunity, based on Opportunity result assign case variables - end            
                                
                                //IF Quote Duration is 1&3 Years creating new Case - Start
                                if(systemAttributeValues.Is_Quote_Duration_Multiple__c){
                                    if(newCase.Duration_Level__c != null){
                                        if(newCase.Duration_Level__c.contains('&')){
                                            newCase.Duration_Level__c = RS2_Quoting__c.getInstance('1 year').Value__c;
                                            newCase1 = new Case();
                                            if(!mappingConfigurationList.isEmpty() && mappingConfigurationList != null){
                                                for(RS2_E2C_Field_Mapping_and_Configuration__c mapConfig : mappingConfigurationList){
                                                    if(mapConfig.Is_Active__c && mapConfig.Module_Name__c.equalsIgnoreCase('Quote')){
                                                        newCase1.put(mapConfig.API_Name__c,newCase.get(mapConfig.API_Name__c));
                                                    }
                                                }
                                            }
                                            newCase1.Request_Type__c =  newCase.Request_Type__c;
                                            newCase1.Request_Sub_Type__c =  newCase.Request_Sub_Type__c;
                                            newCase1.Reason =  newCase.Reason;
                                            newCase1.Opportunity_ID__c =  newCase.Opportunity_ID__c;
                                            newCase1.Duration_Level__c =  RS2_Quoting__c.getInstance('3 year').Value__c;  
                                            newCase1.AccountId = newCase.AccountId;                                    
                                        }                                    
                                    }
                                }
                                //IF Quote Duration is 1&3 Years creating new Case - End
                            }
                            //Parsing the email body for capturing the attributes if Is_Attributes_from_Body__c is True - End.
                             
                            //If body need to be captured in Description field - Start.
                            if(systemAttributeValues.Is_Body_To_Description__c){
                                if(emailPlainBody != '' && emailPlainBody != null){        
                                    newCase.Description = emailPlainBody;         
                                }else if(emailHTMLBody != '' && emailHTMLBody != null){
                                    newCase.Description = emailHTMLBody;
                                }                  
                            }
                            //If body need to be captured in Description field - End.                     
                       }
                       //Checking if the case cration process is active for the Email Alias and then assigning case attribute values - End 
                    }
                    
                    if(newCase != null){
                        //Setting the DMLOption on Case instance
                        if(dmlOpts != null){
                            newCase.setOptions(dmlOpts);                     
                        }
                        caseList.add(newCase);
                    }
                    
                    if(newCase1 != null){
                        //Setting the DMLOption on Case instance
                        if(dmlOpts != null){
                            newCase1.setOptions(dmlOpts);                     
                        }
                        caseList.add(newCase1);
                    }                                                 
                }          
                
                if(caseList != null && !caseList.isEmpty()){
                    try{
                        list<Database.SaveResult> lstCaseInsert = Database.insert(caseList,false);
                        system.debug('lstCaseInsert--->'+lstCaseInsert);  
                        if(lstCaseInsert != null && !lstCaseInsert.isEmpty()){
                            checkCaseInsertion(lstCaseInsert, email, envelope);
                            //CreateApexErrorLog.insertHandledExceptions(null, lstCaseInsert, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'processEmailToCreateCase');
                        }    
                        if(caseList != null && !caseList.isEmpty()){
                            RS2_E2CUtilityClass.insertAttachment(email,caseList,systemAttributeValues.Is_RCM_Comment_Attachment__c);
                        }                       
                    }catch(Exception e){
                        CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'processEmailToCreateCase');                       
                    }
               }             
            }        
        }Catch(Exception e){
            system.debug('exception e -->'+e.getmessage());
            CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'processEmailToCreateCase');
        }       
    }
    //Method for processing the email and creating the Case in My VMWare Email TO Case scenario.- End           
    /***********************************************************************************************
    * Method Name: checkCaseInsertion
    * Description: 
    * @Param: List of Case and Map of old case records
    * @return: void 
    ***********************************************************************************************/    
    public static void checkCaseInsertion(list<Database.SaveResult> caseInsertList,Messaging.InboundEmail email, Messaging.InboundEnvelope envelope ){
        try{
            for(Database.SaveResult srObj : caseInsertList){
                if(!srObj.isSuccess()){
                    createSpamEmail(srObj.getErrors(),email,envelope);
                }               
            }
        }catch(Exception exc){
            CreateApexErrorLog.insertHandledExceptions(exc, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'checkCaseInsertion');
        }
    }
    public static void createSpamEmail(list<Database.Error> errList, Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        try{
            GSS_Spam_Email__c oSpam = new GSS_Spam_Email__c();
            
            oSpam.CreatedFromRS2__c = true;
            oSpam.Subject__c = email.subject;
            oSpam.From_Address__c = email.fromAddress;
            oSpam.From_Name__c = email.fromName;
            oSpam.ToAddressText__c = envelope.toAddress.split('@')[0];
            oSpam.To_Address__c = envelope.toAddress;
            //oSpam.To_Address__c = email.toAddresses;
            oSpam.Message_Date__c = System.now();
            oSpam.HTML_Body__c = email.htmlBody;
            oSpam.Text_Body__c = email.plainTextBody;
            oSpam.Status__c = 'New';      
            oSpam.Reason__c =  errList[0].getMessage() + ' - ' +errList[0].getFields();
            
            if(email.ccAddresses!=null){
                oSpam.Cc_Address__c = emailIDFrmList(email.ccAddresses);
            }
            
            //insert oSpam;
            
            database.saveResult sr = Database.insert(oSpam,false);
            
            if(sr.isSuccess()){
                insertSpamAttachment(oSpam.id,email);
            }       
        }catch(exception exc){
            CreateApexErrorLog.insertHandledExceptions(exc, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'createSpamEmail');
        }
    }
    public static void insertSpamAttachment(Id parentId , Messaging.InboundEmail email){
        try{
            list<Attachment> attachmentList = new list<Attachment>();
            
            if (email.binaryAttachments != null){
                if(!email.binaryAttachments.isEmpty()){
                    Attachment binaryAttInstance;
                    for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                        binaryAttInstance = new Attachment();
                        binaryAttInstance.ParentId = parentId;                        
                        binaryAttInstance.Name = email.binaryAttachments[i].filename;                        
                        binaryAttInstance.body = email.binaryAttachments[i].Body;                        
                        attachmentList.add(binaryAttInstance);
                    }
                }
            }
            //creating attachment from Email text attachments - Start
            if (email.textAttachments != null){
                if(!email.textAttachments.isEmpty()){
                    Attachment textAttInstance;
                    for (integer i = 0 ; i < email.textAttachments.size() ; i++) {                            
                        textAttInstance = new Attachment();
                        textAttInstance.ParentId = parentId;                        
                        textAttInstance.Name = email.textAttachments[i].filename;                        
                        textAttInstance.body = blob.valueOf(email.textAttachments[i].Body);
                        attachmentList.add(textAttInstance);
                    }
                }
            }
            
            list<database.saveResult> srList = Database.insert(attachmentList,false);
            if(!srList.isEmpty()){
                CreateApexErrorLog.insertHandledExceptions(null,srList, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'insertSpamAttachmentFailure');
            }               
        }catch(exception ex){
            CreateApexErrorLog.insertHandledExceptions(ex,null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'insertSpamAttachmentException');
        }
        
    }
    /***********************************************************************************************
    * Method Name: sendEmailUpdateCheck
    * Description: Method to send Email Notifications for Case on HOLD for RCM on Case Update
    * @Param: List of Case and Map of old case records
    * @return: void 
    ***********************************************************************************************/    
    //public static void sendEmailNotificationonUpdate(List<Case> newlist,map<Id,Case> oldMap){
    
    public static void sendEmailUpdateCheck(List<Case> newlist,map<Id,Case> oldMap, boolean operation){
        
        // GET THE CASE FIELD SCHEMA 
        Map<String, Schema.SObjectField> caseSchemaFieldMap = Schema.SObjectType.case.fields.getMap();
        string renewalOperationsRT = Record_Type_Settings__c.getInstance('CaseRenewalOperations').Record_Type_ID__c;
        Set<id> caseIdSet = new set<id>();
        /*
        c.Sub_Status__c.equalsIgnoreCase('CSO') || 
        c.Sub_Status__c.equalsIgnoreCase('IT') || 
        c.Sub_Status__c.equalsIgnoreCase('Sales Rep') || 
        c.Sub_Status__c.equalsIgnoreCase('Other Internal')|| 
        c.Sub_Status__c.equalsIgnoreCase('Special Handling')
        */
        List<Case> proceesCaseList = new List<Case>();
        Map<String,RS2EmailTemplateCriteria__c> emailTemplateList = RS2EmailTemplateCriteria__c.getAll();
        Map<String, Schema.SObjectField> standardAttributes = Schema.SObjectType.case.fields.getMap();
        Map<String, Schema.SObjectField> finalFields = new Map<string, Schema.SObjectField>();
        string SubStatus = RS2_Quoting__c.getInstance('TemplateSubStatusValues').value__c;
        string RequestType = RS2_Quoting__c.getInstance('TemplateRequestTypeValues').value__c;
        string RequestSubType = RS2_Quoting__c.getInstance('TemplateRequestSubTypeValues').value__c;
        
        try{  
            // DYNAMIC FEILD RELATED FILTER MAPPING
            for(String apiValue : caseSchemaFieldMap.keyset()){
                if(emailTemplateList.containsKey(apiValue) ){
                    if(emailTemplateList.get(apiValue).IsActive__c){
                        finalFields.put(apiValue,caseSchemaFieldMap.get(apiValue) );
                    }
                }
            }   
            // CONDITION CHECKING 
            for(Case c : newlist){
                Integer mandate = finalFields.keyset().size();
                Integer countMandate = 0;
                for(string fieldcheck : finalFields.keyset()){
                    if(c.get(fieldcheck) == emailTemplateList.get(fieldcheck.toLowerCase()).value__c){                
                        countMandate ++;
                    }
                    if(mandate == countMandate){
                        // IF UPDATE OPERATION
                        if(operation){
                            system.debug('operation');
                            if(!oldMap.keyset().isEmpty()){                         
                                system.debug('oldMap Qulified');
                                if((c.Request_Type__c != oldMap.get(c.id).Request_Type__c || c.Sub_Status__c != oldMap.get(c.id).Sub_Status__c||c.request_sub_type__c != oldMap.get(c.id).Request_Sub_Type__c || c.status != oldMap.get(c.id).status ) && (RequestType.contains(c.Request_Type__c) || SubStatus.contains(c.Sub_Status__c) ||RequestSubType.contains(c.request_sub_type__c) )){
                                    caseIdSet.add(c.id);
                                }                           
                            }
                        }                       
                        // IF INSERT OPERATION
                        else{
                            system.debug('operation');
                            if(RequestType.contains(c.Request_Type__c) || SubStatus.contains(c.Sub_Status__c) ||RequestSubType.contains(c.request_sub_type__c) ){                           
                                system.debug('Qulified');
                                caseIdSet.add(c.id);
                            }
                        }
                    }
                }
            }        
            //CR-00140109 : Removed System.debug
            //System.debug('--CaseIdset-->'+CaseIdset);     
            if(!caseIdSet.isEmpty()){
                proceesCaseList = returnCaseList(caseIdSet);
                emailNotificationMgmt(proceesCaseList);       
            }
        }   
        catch(exception UpdateException){
        system.debug('UpdateException '+UpdateException);
            CreateApexErrorLog.insertHandledExceptions(UpdateException, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'sendEmailNotificationonUpdate');
        } 
    }    
    /***********************************************************************************************
    * Method Name: returnCaseList
    * Description: SOQL to fetch the createdBy.name and other case fields
    * @Param: set of case id
    * @return: void 
    ***********************************************************************************************/   
    public static List<case> returnCaseList(set<id> caseIdSet){
        List<Case> returnCaseList = new List<Case>();
        if(!caseIdSet.isEmpty()){
            returnCaseList = [select id, Origin,CaseNumber, Vmware_Contract_Number__c,Sub_Status__c, Contract_Start_Date__c, Contract_End_Date__c, email_Address__c, Subject, CreatedById, CreatedBy.name,EA_Name__c,Account.Name,Request_Type__c from Case where Id=: caseIdSet];
        }
        return returnCaseList;
    }
    /***********************************************************************************************
    * Method Name: sendEmailNotification
    * Description: Method to send Email Notifications for Case Cancellation for RCM and VMSTAR scenarios
    * @Param: List of Case
    * @return: void 
    ***********************************************************************************************/        
    public static void emailNotificationMgmt(List<Case> CaseRecords){   
        
        Map<string,EmailTemplate> templateMap = new map<string, EmailTemplate>();
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        List<Task> tsklist = new List<Task>();
        Id caseId;
        Messaging.SingleEmailMessage recievedEmailObj = new Messaging.SingleEmailMessage();
        for(EmailTemplate tempObj : [SELECT Id, Subject, HtmlValue,DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'RS2_New_Portal_Email_Template_Request_On_Hold_Partner_Follow_Up' or DeveloperName = 'RS2NewPortalEmailTemplateRequestOnHoldQuoted']){
            templateMap.put(tempObj.DeveloperName,tempObj);
        }
        
        for(Case caseRec:CaseRecords){                   
            if(caseRec.email_Address__c != NULL ){ 
                EmailTemplate template = new EmailTemplate(); //FIXING TEST FAILURE
                if(caseRec.sub_status__c.equalsIgnoreCase('Partner/End User')){
                    template = templateMap.get('RS2_New_Portal_Email_Template_Request_On_Hold_Partner_Follow_Up');
                }
                if(caseRec.sub_status__c.equalsIgnoreCase('Opportunity Load')){
                    template = templateMap.get('RS2NewPortalEmailTemplateRequestOnHoldQuoted');
                }
                String htmlBody = template.HtmlValue;
                String subject = template.Subject;
                
                // SUBJECT REPLACE
                subject = subject.replace('{!Case.Request_Type__c}', caseRec.Request_Type__c);
                subject = subject.replace('{!Case.CaseNumber}', caseRec.CaseNumber);
                subject = subject.replace('{!Case.EA_Name__c}', caseRec.EA_Name__c);
                subject = subject.replace('{!Case.Vmware_Contract_Number__c}', caseRec.Vmware_Contract_Number__c);
                
                string dateValue = string.valueOf(system.today());
                // BODY REPLACE             
                htmlBody = htmlBody.replace('{!Case.CreatedBy}', caseRec.CreatedBy.Name);
                htmlBody = htmlBody.replace('{!Today}',dateValue);
                htmlBody = htmlBody.replace('{!Case.Vmware_Contract_Number__c}',caseRec.Vmware_Contract_Number__c);
                
                if(caseRec.Contract_Start_Date__c !=null){
                    dateValue = string.valueOf(caseRec.Contract_Start_Date__c);
                    htmlBody = htmlBody.replace('{!Case.Contract_Start_Date__c}',dateValue);
                }else{
                    htmlBody = htmlBody.replace('{!Case.Contract_Start_Date__c}','');
                }
                if(caseRec.Contract_End_Date__c !=null){
                    dateValue = string.valueOf(caseRec.Contract_End_Date__c);
                    htmlBody = htmlBody.replace('{!Case.Contract_End_Date__c}',dateValue);
                }else{
                    htmlBody = htmlBody.replace('{!Case.Contract_End_Date__c}','');
                }
                if(caseRec.EA_Name__c != null){
                    htmlBody = htmlBody.replace('{!Case.EA_Name__c}',caseRec.EA_Name__c);
                }else{
                    htmlBody = htmlBody.replace('{!Case.EA_Name__c}','');
                }
                htmlBody = htmlBody.replace('{!Case.CaseNumber}', caseRec.CaseNumber);
                htmlBody = htmlBody.replace('{!Organization.Id}', UserInfo.getOrganizationId());
            
                recievedEmailObj = createSingleEmail(subject,htmlBody);                                            
                recievedEmailObj.setToAddresses(new String[]{caseRec.email_Address__c});                
                
                // TASK CREATION                
                Task tObj = createTask(caseRec.Id);
                tsklist.add(tObj);  
                
                emailList.add(recievedEmailObj);
            }  
            /**            
else if(caseRec.Origin.equalsIgnoreCase('VMSTAR')){
                EmailTemplate template = templateMap.get('RS2_New_CMT_Email_Template_Request_Cancelled');
                String htmlBody = template.HtmlValue;
                String subject = template.Subject;
                
                // SUBJECT REPLACE
                subject = subject.replace('{!Case.Request_Type__c}', caseRec.Request_Type__c);
                subject = subject.replace('{!Case.CaseNumber}', caseRec.CaseNumber);
                
                // BODY REPLACE             
                htmlBody = htmlBody.replace('{!Case.CreatedBy}', caseRec.CreatedBy.Name);
                htmlBody = htmlBody.replace('{!Case.Id}', caseRec.Id);
                
                recievedEmailObj = createSingleEmail(subject,htmlBody);                             
                recievedEmailObj.setTargetObjectId(caseRec.CreatedById);                 

                // TASK CREATION                
                Task tObj = createTask(caseRec.Id);
                tsklist.add(tObj);  
                
                emailList.add(recievedEmailObj);
            }  
            **/ 
            
        }
        
        // PASS FOR SEND EMAIL
        System.debug('Email List is empty or not---->'+emaillist);
        if(!emailList.isEmpty()){
            sendNotification(emaillist);
        }
        
        // INSERT TASKS
        if(!tsklist.isEmpty()){
            insertTask(tsklist);            
        }
    }
    /***********************************************************************************************
    * Method Name: sendNotification
    * Description: Sends email using the Messaging.sendEmail method
    * @Param: List of SingleEmailMessage
    * @return: void 
    ***********************************************************************************************/  
    public static void sendNotification(list<Messaging.SingleEmailMessage> singleEmailList){            
        try{
            System.debug(LoggingLevel.Error, 'email count---->'+singleEmailList.size());
            Messaging.sendEmail(singleEmailList);
            System.debug(LoggingLevel.Error, 'email sent---->');
        }
        catch(exception sendEmailException){
            system.debug('sendEmailException '+sendEmailException);
            CreateApexErrorLog.insertHandledExceptions(sendEmailException, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'sendNotification');
        }    
    }
    /***********************************************************************************************
    * Method Name: createTask
    * Description: returns task Instance
    * @Param: Case Id against which task is to be created
    * @return: void 
    ***********************************************************************************************/     
    public static task createTask(Id whatIdInstance ){
        system.debug('whatIdInstance   '+whatIdInstance);
        task tObj = new Task(WhatId = whatIdInstance, Subject = RS2_Quoting__c.getInstance('SendEmailTaskSubject').value__c, ActivityDate = date.today(), Status = RS2_Quoting__c.getInstance('PartnerShareValueCompleted').value__c,Priority = RS2_Quoting__c.getInstance('Low').value__c);                   
        return tObj;                   
    }
    /***********************************************************************************************
    * Method Name: createSingleEmail
    * Description: returns Messaging.SingleEmailMessage
    * @Param: Case Id against which task is to be created
    * @return: void 
    ***********************************************************************************************/     
    public static Messaging.SingleEmailMessage createSingleEmail(String subjectReplaced, string bodyReplaced){
        Messaging.SingleEmailMessage singleEmailObj = new Messaging.SingleEmailMessage();
        //email noReplyId = RS2_Quoting__c.getInstance('OrgWideEmailAddressId').Value__c;
        //singleEmailObj.setorgWideEmailAddressId(noReplyId);
        //singleEmailObj.setorgWideEmailAddressId(UserInfo.getOrganizationId());
        singleEmailObj.setorgWideEmailAddressId(RS2_Quoting__c.getInstance('OrgWideEmailAddressId').value__c);
        singleEmailObj.setUseSignature(false); 
        singleEmailObj.setSubject(subjectReplaced);
        singleEmailObj.setHtmlBody(bodyReplaced);
        singleEmailObj.setSaveAsActivity(false);
        
        return singleEmailObj;
        
    }
    /***********************************************************************************************
    * Method Name: insertTask
    * Description: returns task Instance
    * @Param: Case Id against which task is to be created
    * @return: void 
    ***********************************************************************************************/     
    public static void insertTask(List<task> toBeInsertedTaskList){
        try{
            insert toBeInsertedTaskList;
            System.debug('email sent---->');
        }
        catch(exception insertTaskException){
            system.debug('insertTaskException '+insertTaskException);
            CreateApexErrorLog.insertHandledExceptions(insertTaskException, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'insertTask');
        }  
    }
    /***********************************************************************************************
    * Method Name: emailIDFrmList
    * Description: constructs a string with concatenated email addresses
    * @Param: List<string>
    * @return: string 
    ***********************************************************************************************/  
    public static string emailIDFrmList(List<String> emailIDList){
        String strEmailIDs = '';
        try{
            if(emailIDList.size()==1){
                strEmailIDs = emailIDList[0];
            }
            else{
                for(integer i=0;i<emailIDList.size();i++){
                    if(strEmailIDs == null){
                        strEmailIDs = emailIDList[i];
                    }
                    else{
                        strEmailIDs = strEmailIDs  + ','+emailIDList[i];
                    }
                }
            }           
        }
        catch(exception exc){
            CreateApexErrorLog.insertHandledExceptions(exc, null, null, null, 'ApexClass', 'RS2_E2CUtilityClass', 'emailIDFrmList');
        }
        return strEmailIDs;
    }
    
}