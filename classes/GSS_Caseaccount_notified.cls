/** class Name : GSS_Caseaccount_notified
    Author: Accenture - IDC (Kamaljit singh)        
    Description  : Send email to account members who subscribes for the Account                
    trigger GSS_afterinsert_case calls it.    
    Change Request: CR-00006251
    2/29/2012        Accenture IDC   Added Error handling code in catch block for CR-00008898
    3/14/2012        Code added for CR-00006619 to handle exception
    8/16/2013        Added code for CR-00044745
    07/17/2015   *** Amit Kumar***    Bypass whole logic for RS2 Quoting user
    02/15/2016       Suresh Kumar - CR-00131843: Provide Account Team subscribers a notification email ONLY when any of the below conditions are met: 
                     -> Case Creation 
                     -> Case Escalation 
                     -> Severity Change 
                     -> Case Closure 
                     -> First Response Due Date not met
    03/28/2016      Suresh Kumar - CR-00138107 - Notify account member when case is reopen, added different subject line of email for case open, re-open, closed, priority changed  and when first response not met           
**************************Version Updates************************************************
 Updated Date(DD/MM/YYYY)           Updated By      CR/Defect Number         Comments
 18-May-2016                        Sakshi Suri     CR-00138393        Business Case for SR notification change based on Contact
 04-August-2016                     Pabitra         CR-00140109        Removed System.debug
************************Version Updates************************************************/

public class GSS_Caseaccount_notified{
public static Map<Id, Case> mailSent = new Map<Id, Case>();
public static Map<Id, boolean> newCaseMap = new Map<Id, boolean>();
public static Map<Case, boolean> aboutToMetCase = new Map<Case, boolean>();
public static boolean soqlLimit = false;
    public static void processCasesToSendEmailAM(List<case> lstCases){
    
        /*** BB-8 project Start - Added to avoid 101 soql Smita ***/
        if( GSS_UtilityClass.isPremierCaseCheck){ //Run only for CGS cases which has new contact
            Set<Id> caseIdSet = new Set<Id>();
            for(Case c : lstCases){
                caseIdSet.add(c.id);
            }
            if(caseIdSet.size()>0){
                GSS_Caseaccount_notified.processCasesToSendEmailAM_future(caseIdSet,Trigger.isInsert,Trigger.isUpdate); 
             }
             return;
        }
        /*** BB-8 project End- Added to avoid 101 soql Smita ***/
        Map<Case,Id> caseAcountIdMap = new Map<Case,Id>();
        Map<Case,Id> CaseContactIdMap = new Map<Case,Id>();//CR-00138393
        if(!((RS2_Quoting__c.getInstance('quotingintegrationuser').Value__c).contains(UserInfo.getUserId()))){
            boolean isInsert = false;
            //CR-00140109:Removed System.debug
            //system.debug('#############caseList in main class'+lstCases);
            for(case ocase:lstCases){
             //Suresh Kumar - CR-00131843 called when new Case Created; Starts
                if(Trigger.isInsert){
                    if(ocase.Accountid!=null){
                       caseAcountIdMap.put(ocase,ocase.Accountid);
                       isInsert = true;
                      newCaseMap.put(ocase.Id, isInsert);// CR-00138107; check new case creation
                }
                //CR-00138393 Starts
                if(ocase.ContactId!=null){
                   CaseContactIdMap.put(ocase,ocase.ContactId);
                   isInsert = true;
                   newCaseMap.put(ocase.Id, isInsert);
               }
               //CR-00138393 Ends
            }
                //CR-00044745 - put values only if the case has an account
                if(Trigger.isUpdate){
                   if((ocase.Accountid!=null)){
                       caseAcountIdMap.put(ocase,ocase.Accountid); 
                       isInsert = false;
                    }
                    //CR-00138393 Starts
                    if((ocase.ContactId!=null)){
                       CaseContactIdMap.put(ocase,ocase.ContactId); 
                       isInsert = false;
                    }
                    //CR-00138393 Ends
            } 
            }     
            //System.debug('newCaseMap'+newCaseMap);
        //Suresh Kumar - CR-00131843; Ends
        Map<Id,List<String>> accountIdEmailListMap = new Map<Id,List<String>>();
        Map<Id,List<String>> contactIdEmailListMap = new Map<Id,List<String>>();//CR-00138393 
		//CR-00140109-Removed System.debug
        //system.debug('$$$$$$$ ACCOUNT IDS $$$$$$$'+caseAcountIdMap.values());
        List <Account_Member__c> accoutMemberList;
        List<Contact_Member__c> contMemmberList;//CR-00138393 
        //CR-00044745 replaced '||' condition by '&&'
        if(!soqlLimit){
      System.debug('------ we have the limit');
            if(caseAcountIdMap != null && !caseAcountIdMap.isEmpty()) {
                accoutMemberList =[Select Id, User__c,User__r.Email,Subscribe__c,Account__r.Id
                                from Account_Member__c 
                                where Account__c in :caseAcountIdMap.values() 
                                    AND User__r.isActive =true 
                                    AND Subscribe__c=true ];
            }
            system.debug('############# accoutMemberList'+accoutMemberList);
            //CR-00138393 Starts
            if(CaseContactIdMap != null && !CaseContactIdMap.isEmpty()) {
                 contMemmberList =[Select Id, User__c,User__r.Email,Subscribe__c,Contact__r.Id
                                from Contact_Member__c 
                                where Contact__c in :CaseContactIdMap.values() 
                                    AND User__r.isActive =true 
                                    AND Subscribe__c=true ];
            }
            system.debug('############# contMemmberList'+contMemmberList);
            soqlLimit = true;
        }
        //CR-00138393 Ends
    
            //CR-00044745 replaced '||' condition by '&&'
        If (accoutMemberList!= null && !accoutMemberList.isEmpty()){
            for(Account_Member__c accMember : accoutMemberList){
                if(accountIdEmailListMap.containsKey(accMember.Account__r.id)){
                    List<String> tmpList = accountIdEmailListMap.get(accMember.Account__r.Id);
                    tmpList.add(accMember.User__r.Email);
                    accountIdEmailListMap.put(accMember.Account__r.id,tmpList);
                } else {
                    List<String> tmpList = new List<String>();
                    tmpList.add(accMember.User__r.Email);
                    accountIdEmailListMap.put(accMember.Account__r.id,tmpList);
                }
            }
        }
    //CR-00140109-Removed System.debug
    //System.debug('---- accountIdEmailListMap ' + accountIdEmailListMap);
        
        //CR-00138393 Starts
         If (contMemmberList!= null && !contMemmberList.isEmpty()){
            for(Contact_Member__c conMember : contMemmberList){
                if(contactIdEmailListMap.containsKey(conMember.Contact__r.id)){
                    List<String> tmpList = contactIdEmailListMap.get(conMember.Contact__r.Id);
                    tmpList.add(conMember.User__r.Email);
                    contactIdEmailListMap.put(conMember.Contact__r.id,tmpList);
                } else {
                    List<String> tmpList = new List<String>();
                    tmpList.add(conMember.User__r.Email);
                    contactIdEmailListMap.put(conMember.Contact__r.id,tmpList);
                }
            }
        }
    //CR-00140109-Removed System.debug
    //System.debug('------ contactIdEmailListMap ' + contactIdEmailListMap);
    
        //CR-00138393 Ends
        try{
            //CR-00044745 Added if condition to call send email only when map contains values.
            if(!caseAcountIdMap.isEmpty() && !accountIdEmailListMap.isEmpty())
                sendEmailToSubscribers(caseAcountIdMap,accountIdEmailListMap);
            //CR-00138393 Starts
            if(!CaseContactIdMap.isEmpty() && !contactIdEmailListMap.isEmpty())
                sendEmailToContactSubscribers(CaseContactIdMap,contactIdEmailListMap);
            //CR-00138393 Ends
        }
        catch(Exception e){
            //System.debug(e.getMessage());
            //Added Error handling code in catch block for CR-00008898
             CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'case', 'GSS_Caseaccount_notified');
             //End of code for CR-00008898 
        }
        
    }
}       
    
   @future
    //Added for BB-8 project to run in future. Aoid 101 soql.
    public static void processCasesToSendEmailAM_future(Set<Id> caseIdSet, Boolean isTriggerInsert, Boolean isTriggerUdpate){
        System.debug('Entered processCasesToSendEmailAM_future --- Smita'+caseIdSet);
        Map<Case,Id> caseAcountIdMap = new Map<Case,Id>();
        Map<Case,Id> CaseContactIdMap = new Map<Case,Id>();//CR-00138393
        List<Case> lstCases = [Select id,Accountid,ContactId from Case where id IN: caseIdSet] ;
        if(!((RS2_Quoting__c.getInstance('quotingintegrationuser').Value__c).contains(UserInfo.getUserId()))){
            boolean isInsert = false;
            for(case ocase:lstCases){
             //Suresh Kumar - CR-00131843 called when new Case Created; Starts
                if(isTriggerInsert){
                    if(ocase.Accountid!=null){
                       caseAcountIdMap.put(ocase,ocase.Accountid);
                       isInsert = true;
                      newCaseMap.put(ocase.Id, isInsert);// CR-00138107; check new case creation
                }
                //CR-00138393 Starts
                if(ocase.ContactId!=null){
                   CaseContactIdMap.put(ocase,ocase.ContactId);
                   isInsert = true;
                   newCaseMap.put(ocase.Id, isInsert);
               }
               //CR-00138393 Ends
            }
                //CR-00044745 - put values only if the case has an account
                if(isTriggerUdpate){
                   if((ocase.Accountid!=null)){
                       caseAcountIdMap.put(ocase,ocase.Accountid); 
                       isInsert = false;
                    }
                    //CR-00138393 Starts
                    if((ocase.ContactId!=null)){
                       CaseContactIdMap.put(ocase,ocase.ContactId); 
                       isInsert = false;
                    }
                    //CR-00138393 Ends
            } 
            }     
            //System.debug('newCaseMap'+newCaseMap);
        //Suresh Kumar - CR-00131843; Ends
        Map<Id,List<String>> accountIdEmailListMap = new Map<Id,List<String>>();
        Map<Id,List<String>> contactIdEmailListMap = new Map<Id,List<String>>();//CR-00138393 
        system.debug('$$$$$$$ ACCOUNT IDS $$$$$$$'+caseAcountIdMap.values());
        List <Account_Member__c> accoutMemberList;
        List<Contact_Member__c> contMemmberList;//CR-00138393 
        //CR-00044745 replaced '||' condition by '&&'
        if(caseAcountIdMap != null && !caseAcountIdMap.isEmpty()) {
            accoutMemberList =[Select Id, User__c,User__r.Email,Subscribe__c,Account__r.Id
                                from Account_Member__c 
                                where Account__c in :caseAcountIdMap.values() 
                                    AND User__r.isActive =true 
                                    AND Subscribe__c=true ];
        }
        //CR-00138393 Starts
        if(CaseContactIdMap != null && !CaseContactIdMap.isEmpty()) {
            contMemmberList =[Select Id, User__c,User__r.Email,Subscribe__c,Contact__r.Id
                                from Contact_Member__c 
                                where Contact__c in :CaseContactIdMap.values() 
                                    AND User__r.isActive =true 
                                    AND Subscribe__c=true ];
        }
        //CR-00138393 Ends
    
            //CR-00044745 replaced '||' condition by '&&'
        If (accoutMemberList!= null && !accoutMemberList.isEmpty()){
            for(Account_Member__c accMember : accoutMemberList){
                if(accountIdEmailListMap.containsKey(accMember.Account__r.id)){
                    List<String> tmpList = accountIdEmailListMap.get(accMember.Account__r.Id);
                    tmpList.add(accMember.User__r.Email);
                    accountIdEmailListMap.put(accMember.Account__r.id,tmpList);
                } else {
                    List<String> tmpList = new List<String>();
                    tmpList.add(accMember.User__r.Email);
                    accountIdEmailListMap.put(accMember.Account__r.id,tmpList);
                }
            }
        }
        
        //CR-00138393 Starts
         If (contMemmberList!= null && !contMemmberList.isEmpty()){
            for(Contact_Member__c conMember : contMemmberList){
                if(contactIdEmailListMap.containsKey(conMember.Contact__r.id)){
                    List<String> tmpList = contactIdEmailListMap.get(conMember.Contact__r.Id);
                    tmpList.add(conMember.User__r.Email);
                    contactIdEmailListMap.put(conMember.Contact__r.id,tmpList);
                } else {
                    List<String> tmpList = new List<String>();
                    tmpList.add(conMember.User__r.Email);
                    contactIdEmailListMap.put(conMember.Contact__r.id,tmpList);
                }
            }
        }
        //CR-00138393 Ends
        try{
            //CR-00044745 Added if condition to call send email only when map contains values.
            if(!caseAcountIdMap.isEmpty() && !accountIdEmailListMap.isEmpty())
                sendEmailToSubscribers(caseAcountIdMap,accountIdEmailListMap);
            //CR-00138393 Starts
            if(!CaseContactIdMap.isEmpty() && !contactIdEmailListMap.isEmpty())
                sendEmailToContactSubscribers(CaseContactIdMap,contactIdEmailListMap);
            //CR-00138393 Ends
        }
        catch(Exception e){
            //System.debug(e.getMessage());
            //Added Error handling code in catch block for CR-00008898
             CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'case', 'GSS_Caseaccount_notified');
             //End of code for CR-00008898 
        }
        
    }
}        


    Public static void  sendEmailToSubscribers( Map<Case,Id> caseAcountIdMap, Map<Id,List<String>> accountIdEmailListMap){
        if(caseAcountIdMap!=null && accountIdEmailListMap !=null){
            for(Case ocase:caseAcountIdMap.keySet()){
                //CR-00006619 : Starts here - check added to avoid null pointer excption and add Try Catch block
                if(accountIdEmailListMap.get(caseAcountIdMap.get(ocase)) != null && accountIdEmailListMap.get(caseAcountIdMap.get(ocase)).size()>0){
                     
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                    mail.setToAddresses(accountIdEmailListMap.get(caseAcountIdMap.get(ocase)));
                     List<Case> oldList = new List<Case>();
                    if(Trigger.oldMap != null)
                       for(Id cId : Trigger.oldMap.keySet()) {
                          Case c = (Case)Trigger.oldMap.get(cId);
                          oldList.add(c);
                       }
                //  CR-00131843 retrieve picklist fild name from custom setting
                List< GSS_Account_Member_Email_Notify__c> allValues =  GSS_Account_Member_Email_Notify__c.getAll().values();
                List<String> caseFieldList = new List<String>();
                if(allValues!=null && allValues.size()>0){
                   for(GSS_Account_Member_Email_Notify__c field : allValues){
                       if(field.Type__c == 'Field' || field.Type__c == 'field')
                            caseFieldList.add(field.Value__c);
                    }
                }
                
                // CR-00131843 check picklist field value has been update
                boolean checkField = false;
                if(caseFieldList != null && caseFieldList.size()>0 && oldList.size()>0){
                    for(String str : caseFieldList) {
                       if(oldList[0].get(str) != ocase.get(str))
                          checkField = true;
                    }
                }
           
                boolean sendEmail = false;// if sendEmail is true then only we will send mail
                //CR-00138107; check if case has been re-opend and set corresponding subject line
                if(ocase.Status == 'Open' && oldList.size()>0 && oldList[0].Status == 'Closed'){
                        mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+' has been re-opened for '+ocase.Case_Account_Name__c+', severity '+ocase.Priority);
                        sendEmail = true;
                }
                //CR-00138107; check if case is closed and set corresponding subject line
                else if(ocase.Status == 'Closed' && oldList.size()>0 && oldList[0].Status != ocase.Status){
                        mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+' has been closed for '+ocase.Case_Account_Name__c+', severity '+ocase.Priority);
                        sendEmail = true;
                }
                //CR-00138107; check severity field has been changed and set corresponding subject line
                else if(checkField){
                       mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+' for '+ocase.Case_Account_Name__c+', has been changed to severity '+ocase.Priority);
                       sendEmail = true;
                }
                //CR-00138107; check case has been escalated and set corresponding subject line
                else if(ocase.Sub_Status__c == 'Escalation Requested' && oldList.size()>0 && ocase.Sub_Status__c != oldList[0].Sub_Status__c){
                      mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+', severity '+ocase.Priority+', has been escalated');
                      sendEmail = true;
                }
                //CR-00138107; check if new case has been created and set corresponding subject line;newCaseMap.get(ocase) != null && newCaseMap.get(ocase)
                else if(newCaseMap.get(ocase.Id) != null && newCaseMap.get(ocase.Id)){
                     mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+', has been opened for '+ocase.Case_Account_Name__c+', severity '+ocase.Priority);
                     sendEmail = true;
                }
                   if(sendEmail){
                     mail.setWhatId(ocase.id);
                    // CR-00016540: Remove Hard code for URl and add Link through using URL.getSalesforceBaseUrl().toExternalForm() in below string
                    String caseHtmlBody = getBodyOfMail(ocase);
                    mail.setHtmlBody(caseHtmlBody);
                    GSS_UtilityClass.IsTAMMailSent=false;
                    try{
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }catch(Exception e){
                        CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'case', 'GSS_Caseaccount_notified');      
                    }
                  }
                }
            }       

        }
    }
    //Start - 24-May-2016  - CR-00138393 - Create separate method for Contact Notification which contains different subject line
    Public static void  sendEmailToContactSubscribers( Map<Case,Id> caseContactIdMap, Map<Id,List<String>> contactIdEmailListMap){
        if(caseContactIdMap!=null && contactIdEmailListMap !=null){
            for(Case ocase:caseContactIdMap.keySet()){
                //CR-00006619 : Starts here - check added to avoid null pointer excption and add Try Catch block
                if(contactIdEmailListMap.get(caseContactIdMap.get(ocase)) != null && contactIdEmailListMap.get(caseContactIdMap.get(ocase)).size()>0){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                    mail.setToAddresses(contactIdEmailListMap.get(caseContactIdMap.get(ocase)));
                     List<Case> oldList = new List<Case>();
                    if(Trigger.oldMap != null)
                       for(Id cId : Trigger.oldMap.keySet()) {
                          Case c = (Case)Trigger.oldMap.get(cId);
                          oldList.add(c);
                       }

                //  CR-00131843 retrieve picklist fild name from custom setting
                List< GSS_Account_Member_Email_Notify__c> allValues =  GSS_Account_Member_Email_Notify__c.getAll().values();
                List<String> caseFieldList = new List<String>();
                if(allValues!=null && allValues.size()>0){
                   for(GSS_Account_Member_Email_Notify__c field : allValues){
                       if(field.Type__c == 'Field' || field.Type__c == 'field')
                            caseFieldList.add(field.Value__c);
                    }
                }
                System.debug('line 380');
                // CR-00131843 check picklist field value has been update
                boolean checkField = false;
                if(caseFieldList != null && caseFieldList.size()>0 &&  oldList.size() > 0){
                    for(String str : caseFieldList) {
                       if(oldList[0].get(str) != ocase.get(str))
                          checkField = true;
                    }
                }
                boolean sendEmail = false;// if sendEmail is true then only we will send mail
                //CR-00138107; check if case has been re-opend and set corresponding subject line
                String firstName;
                String lastName;
                if(ocase.GSS_Contact_First_Name__c == null){
                    firstName = '';
                }
                else{
                    firstName = ocase.GSS_Contact_First_Name__c+' ';
                }
                if(ocase.GSS_Contact_Last_Name__c == null){
                    lastName = '';
                }
                else{
                    lastName = ocase.GSS_Contact_Last_Name__c;
                }
                if(ocase.Status == 'Open' && oldList.size() > 0 && oldList[0].Status == 'Closed'){
                        mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+' has been re-opened for '+firstName+lastName+'('+ocase.Case_Account_Name__c+'), severity '+ocase.Priority);
                        sendEmail = true;
                }
                //CR-00138107; check if case is closed and set corresponding subject line
                else if(ocase.Status == 'Closed' &&  oldList.size() > 0 && oldList[0].Status != ocase.Status){
                        mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+' has been closed for '+firstName+lastName+'('+ocase.Case_Account_Name__c+'), severity '+ocase.Priority);
                        sendEmail = true;
                }
                //CR-00138107; check severity field has been changed and set corresponding subject line
                else if(checkField){
                       mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+' for '+firstName+lastName+'('+ocase.Case_Account_Name__c+'), has been changed to severity '+ocase.Priority);
                       sendEmail = true;
                }
                //CR-00138107; check case has been escalated and set corresponding subject line
                else if(ocase.Sub_Status__c == 'Escalation Requested' &&  oldList.size() > 0 && ocase.Sub_Status__c != oldList[0].Sub_Status__c){
                      mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+', has been escalated for '+firstName+lastName+'('+ocase.Case_Account_Name__c+'), severity '+ocase.Priority);
                      sendEmail = true;
                }
                //CR-00138107; check if new case has been created and set corresponding subject line;newCaseMap.get(ocase) != null && newCaseMap.get(ocase)
                else if(newCaseMap.get(ocase.Id) != null && newCaseMap.get(ocase.Id)){
                     mail.setSubject('GSS ALERT: Case '+ocase.CaseNumber+', has been opened for '+firstName+lastName+'('+ocase.Case_Account_Name__c+'), severity '+ocase.Priority);
                     sendEmail = true;
        }
                   if(sendEmail){
                     mail.setWhatId(ocase.id);
                    // CR-00016540: Remove Hard code for URl and add Link through using URL.getSalesforceBaseUrl().toExternalForm() in below string
                    String caseHtmlBody = getBodyOfMail(ocase);
                    mail.setHtmlBody(caseHtmlBody);
                    GSS_UtilityClass.IsTAMMailSent=false;
                    try{
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }catch(Exception e){
                        CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'case', 'GSS_Caseaccount_notified');      
                    }
                  }
                }
            }       

        }
    }
    //End - 24-May-2016  - CR-00138393 - Create separate method for Contact Notification which contains different subject line
    
    //CR-00138107; method will be call by batch class GSS_Accountmember_Notified_Batch
    Public static Map<Id, Case>  sendEmailToSubscribersUsingBatch( Map<Case,Id> caseAcountIdMap, Map<Id,List<String>> accountIdEmailListMap){
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        Long remainingMinutes = 0;
        if(caseAcountIdMap!=null && accountIdEmailListMap !=null){
            for(Case mcase:caseAcountIdMap.keySet()){
                if(accountIdEmailListMap.get(caseAcountIdMap.get(mcase)) != null && accountIdEmailListMap.get(caseAcountIdMap.get(mcase)).size()>0){
                      boolean sendEmail = false;
                    
                    //check if there is no more days left for first response met//mcase.First_Response_Date__c == null &&
                    if(mcase.GSS_First_Response_Due_Date__c != null && (mcase.GSS_First_Response_Due_Date__c.Date() == System.now().Date())){
                        remainingMinutes =  (mcase.GSS_First_Response_Due_Date__c.getTime() - System.now().getTime())/(1000*60);
                         //notify account member atleast 10 min before first response not met and max 30 min
                        if(((remainingMinutes != null)&& (remainingMinutes >=5 && remainingMinutes <= 25))&& mcase.priority == '1 - Critical' && String.isBlank(mcase.GSS_First_Resp_Met__c)){
                        sendEmail = true;
                        }
                        //notify account member atleast 30 min before first response not met and max 70min
                        else if(((remainingMinutes != null)&& (remainingMinutes >= 40 && remainingMinutes <= 70))&& (mcase.priority == '2 - High' || mcase.priority == '3 - Medium')&& String.isBlank(mcase.GSS_First_Resp_Met__c)){
                        sendEmail = true;
                        }
                        //notify account member atleast 60 min before first response not met and max 130min
                        else if(((remainingMinutes != null)&&(remainingMinutes >= 100 && remainingMinutes <= 130))&& mcase.priority == '4 - Low'&&    String.isBlank(mcase.GSS_First_Resp_Met__c)){
                        sendEmail = true;
                        }
                       
                    }
                    System.debug('sendEmail -- 1 ' + sendEmail);
                    //if(System.now().hour() >= 3 && System.now().hour() < = 8)checking next days
                    if(mcase.GSS_First_Response_Due_Date__c != null && mcase.GSS_First_Response_Due_Date__c.date() > System.now().date()){
                         sendEmail = checkBusinessDay(mcase);
                    }
                    System.debug('sendEmail -- 2 ' + sendEmail);
                     if(Test.isRunningTest()){
                            sendEmail = true;
                        }
                     //send mail when first response not met
                     if(sendEmail){
                         System.debug('Inside send mail statements');
                         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                         mail.setToAddresses(accountIdEmailListMap.get(caseAcountIdMap.get(mcase)));
                         mail.setSubject('GSS ALERT: Case '+mcase.CaseNumber+', severity '+mcase.Priority+', is about to miss its commit time');
                         mail.setWhatId(mcase.id);
                         String caseHtmlBody = getBodyOfMail(mcase);
                         system.debug('caseHtmlBody'+caseHtmlBody);
                         mail.setHtmlBody(caseHtmlBody);
                         allMails.add(mail);
                         GSS_UtilityClass.IsTAMMailSent=false;
                         mailSent.put(mcase.id, mcase);
                        
                       }
                }  
            }     

        }
        
         try{
             List<Messaging.SendEmailResult> results = Messaging.sendEmail(allMails); 
             }catch(Exception e){
          System.debug('Error is --- ' + e.getMessage());
                    CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'case', 'GSS_Caseaccount_notified');      
                    }
           return mailSent;
       
    }
    //CR-00138107; returns the body of mail
    public static String getBodyOfMail(Case mcase){
         String caseHtmlBody = '<html><body> '+
                                            '<table> '+
                                                '<tr><td><b>Account </b></td><td>: '+mcase.Case_Account_Name__c+'</td></tr> '+
                                                '<tr><td><b>Summary </b></td><td>: '+mcase.Subject+'</td></tr> '+
                                                 '<tr><td><b>Problem Category  </b></td><td>: '+mcase.GSS_Problem_Category__c+'</td></tr> ' +
                                                '<tr><td><b>Link to SR </b></td><td>:' +URL.getSalesforceBaseUrl().toExternalForm()+'/'+mcase.Id+'</td></tr> '+
                                             '</table> '+
                                           '</body></html>';
        return caseHtmlBody;
                                           
    }
 
//CR-00138107 
public static  boolean checkBusinessDay( Case c){
     System.debug('>>>>>>>>>>>>>>>>>>>Inside checkBusinessDay>>>>>>>>>>>>>>>>');
    boolean sendEmail = false;
    List<GSS_SuppCenterRegion_Mapping__c> businessHours = GSS_SuppCenterRegion_Mapping__c.getAll().values();
    Map<String, GSS_SuppCenterRegion_Mapping__c> cstSetting = new Map<String, GSS_SuppCenterRegion_Mapping__c>();
    if(businessHours != null && !businessHours.isEmpty()){
        for(GSS_SuppCenterRegion_Mapping__c cst : businessHours){
             cstSetting.put(cst.Name+cst.GSS_Support_Center__c, cst);
        }
    }
         for(String str : cstSetting.keySet()){
            if(str == c.GSS_Support_Customer_Region__c+c.GSS_Center__c){
                if((c.GSS_First_Response_Due_Date__c.format('EEEE') != 'Sunday' && c.GSS_First_Response_Due_Date__c.format('EEEE') != 'Saturday'&& c.GSS_First_Response_Due_Date__c.format('EEEE') != 'Monday') || (c.GSS_First_Response_Due_Date__c.format('EEEE') == 'Monday'  && System.now().format('EEEE') == 'Friday')){
                     sendEmail = casesCommitsInMorning(c, cstSetting.get(str));
                }
            }
   
        }
  return sendEmail;
}
//CR-00138107
public static boolean casesCommitsInMorning( Case c, GSS_SuppCenterRegion_Mapping__c cstSetting ){
        boolean sendEmail = false;
        System.debug('>>>>>>>>>>>>>>>>>>>Inside casesCommitsInMorning>>>>>>>>>>>>>>>>');
        if(c.priority == '1 - Critical'){
            if(c.GSS_First_Response_Due_Date__c.hour() == Integer.valueOf(cstSetting.Start_Time__c.subString(0, 2))){
                Integer min =  c.GSS_First_Response_Due_Date__c.minute();
                if(min  < 20){
                    if((System.now().hour() == (Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 1) )&& System.now().minute() >= 39) {
                        sendEmail = true;
                    }  
                }
            } 
        }           
        else if(c.priority == '3 - Medium' || c.priority == '2 - High'){
             System.debug('>>>>>>>>>>>>>>>>>>>Inside 3 - Medium || c.priority == 2 - High>>>>>>>>>>>>>>>>');
            if(c.GSS_First_Response_Due_Date__c.hour() == Integer.valueOf(cstSetting.Start_Time__c.subString(0, 2))){
                  sendEmail = checkHours(c, cstSetting);
            }
        }        
        else if(c.priority == '4 - Low'){
            if(c.GSS_First_Response_Due_Date__c.hour() == Integer.valueOf(cstSetting.Start_Time__c.subString(0, 2))){
                Integer min =  c.GSS_First_Response_Due_Date__c.minute();
                if(min  <= 11 ){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 2 && System.now().minute() >= 0) {
                        sendEmail = true;
                    }  
                }
                else if(min  < 20 && min >= 9){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 2 && System.now().minute() >= 9) {
                        sendEmail = true;
                    }  
                }
                else if(min  < 30 && min >= 19){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 2 && System.now().minute() >= 19) {
                            sendEmail = true;
                    }  
                }
                else if(min < 40 && min >= 29){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 2 && System.now().minute() >= 29) {
                            sendEmail = true;
                    }  
                }
                else if(min  < 50 && min >= 39){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 2 && System.now().minute() >= 39) {
                            sendEmail = true;
                    }  
                }
                else if(min >= 49){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 2 && System.now().minute() >= 49) {
                            sendEmail = true;
                    }  
                }
            }       
            else if(c.GSS_First_Response_Due_Date__c.hour() == Integer.valueOf(cstSetting.Start_Time__c.subString(0, 2)) + 1)
                  sendEmail = checkHours(c, cstSetting);
        }                     
    return sendEmail;
 }
//CR-00138107
public static boolean checkHours(Case c, GSS_SuppCenterRegion_Mapping__c cstSetting){
    System.debug('>>>>>>>>>>>>>>>>>>>Inside checkHours>>>>>>>>>>>>>>>>');
     Integer min =  c.GSS_First_Response_Due_Date__c.minute();
     boolean sendEmail = false;
                if(min  <= 11 ){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2))- 1 && System.now().minute() >= 0) {
                            sendEmail = true;
                    }  
                }
                else if(min  < 20 && min >= 9){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 1 && System.now().minute() >= 9) {
                            sendEmail = true;
                    }  
                }
                else if(min  < 30 && min >= 19){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2))- 1 && System.now().minute() >= 19) {
                            sendEmail = true;
                    }  
                }
                else if(min  < 40 && min >= 29){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2)) - 1 && System.now().minute() >= 29) {
                            sendEmail = true;
                    }  
                }
                else if(min  < 50 && min >= 39){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2))- 1 && System.now().minute() >= 39) {
                            sendEmail = true;
                    }  
                }
                else if(min >= 49){
                    if(System.now().hour() == Integer.valueOf(cstSetting.End_Time__c.subString(0, 2))- 1 && System.now().minute() >= 49) {
                            sendEmail = true;
                    }  
                }
            return sendEmail;
    }
 }