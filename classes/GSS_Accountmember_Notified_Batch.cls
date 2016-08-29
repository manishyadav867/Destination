/**************************************************************************************
* Class Name   : GSS_Accountmember_Notified_Batch
* Purpose      : Notify account member on First response met
* CR Number    : CR-00138107  
* Created By   : Suresh kumar
* Created Date : 17/03/2016
************************Version Updates************************************************
 Updated Date(DD/MM/YYYY)         Updated By     CR/Defect Number         Comments
 18-May-2016                      Sakshi Suri       CR-00138393         Business Case for SR notification change based on Contact
 03-Aug-2016                      PRITESH SONI                          Added Method schedulerMethod for merging multiple schedulers.
************************Version Updates************************************************/

global class GSS_Accountmember_Notified_Batch implements Database.Batchable<sObject>{
    
    List<Case_Extension__c> csExtList = new List<Case_Extension__c>();
    Set<Id> caseIdSet = new Set<Id>();
    Map<Case, Id> caseAcountIdMap = new  Map<Case, Id>();
    Map<Case, Id> caseContactIdMap = new  Map<Case, Id>();//CR-00138393 
    DateTime dateTimeValue; 
    Map<Id, Case> sentMail;
    
    GSS_Configuration_Properties_list__c gsscpList = GSS_Configuration_Properties_list__c.getValues('Date');//returns date and time 
    Set<Id> caseExtIdSetForTest;
    /*
    public GSS_Accountmember_Notified_Batch(Set<Id> caseExtIdSetForTest)
    {
        this.caseExtIdSetForTest=caseExtIdSetForTest;
    }
    */
    //returns list of Case_Extension__c record 
    //Added to merging multiple schedulers -Pritesh
    global Scheduler_Optimizer__c schedulerOptimizer = Scheduler_Optimizer__c.getInstance('GSS_AccMembNotifyBatchSchedulorRecord');
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query;
        if(Test.isRunningTest())
            query = 'select id, Case__r.Id, Case__r.GSS_First_Resp_Met__c, createdDate, Check_No__c from Case_Extension__c where Check_No__c = false and case__r.Subject = \'testing for GSS_Caseaccount_notified\' and CreatedDate >= Today  limit 10';
        else        
            query = 'select id, Case__r.Id, Case__r.GSS_First_Resp_Met__c, createdDate, Check_No__c, Case__r.GSS_First_Response_Due_Date__c from Case_Extension__c where Case__r.GSS_First_Response_Due_Date__c != null AND Case__r.GSS_First_Resp_Met__c =\' \' AND Check_No__c = false';
        //START:Added logic merging multiple schedulers -Pritesh
        Boolean switchonoff=false;
        Integer minsToSchedule=0;
        String schedulerJobName='';
        if(schedulerOptimizer != Null){
            switchonoff = schedulerOptimizer.On_Off_Switch__c;
            minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c);
            schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c;
        }
        else{
            minsToSchedule = 10;
            schedulerJobName = 'GSS_AccMembNotifyBatchSchedulor';
        }
        if(switchonoff){
             Database.QueryLocator q = Database.getQueryLocator(query);
            // Get an iterator
            Database.QueryLocatorIterator it =  q.iterator();
            if(!it.hasNext()){
                schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'GSS_AccMembNotifyBatchSchedulor');
            }
            return q;
        }
        else{
            return Database.getQueryLocator(query);
        }
        //END:Added logic merging multiple schedulers -Pritesh
    }
    
    //method to update case extension and send mail to account member on first response met
    global void execute(Database.BatchableContext bc, List<Case_Extension__c> caseExtList){
        
        for(Case_Extension__c csExt : caseExtList){
            caseIdSet.add(csExt.Case__r.Id);
        }
        
        dateTimeValue = DateTime.valueOf(gsscpList.Setting_value__c);
        //CR-00138393 Starts
        List<Case> cseList = new List<Case>();
        cseList=[select id, AccountId,ContactId, CaseNumber,Priority,Case_Account_Name__c,Subject, GSS_First_Resp_Met__c,First_Response_Date__c,GSS_First_Response_Due_Date__c, createdDate,GSS_Problem_Category__c, GSS_Center__c, GSS_Support_Customer_Region__c, GSS_Time_Zone__c from Case where Id IN :caseIdSet AND createdDate > :dateTimeValue];
        /*for(Case cs : [select id, AccountId, CaseNumber,Priority,Case_Account_Name__c,Subject, GSS_First_Resp_Met__c,First_Response_Date__c,GSS_First_Response_Due_Date__c, createdDate,GSS_Problem_Category__c, GSS_Center__c, GSS_Support_Customer_Region__c, GSS_Time_Zone__c from Case where  AccountId != null AND Id IN :caseIdSet AND createdDate > :dateTimeValue])*/
        for(Case cs:cseList){
        if(cs.AccountId!=null){
            caseAcountIdMap.put(cs, cs.AccountId);
        }
        if(cs.ContactId!=null){
            caseContactIdMap.put(cs,cs.ContactId);
        }
        }
        //CR-00138393 ends
        System.debug('caseAcountIdMap:'+caseAcountIdMap);
        Map<Id,List<String>> accountIdEmailListMap = new Map<Id,List<String>>();
        Map<Id,List<String>> contactIdEmailListMap = new Map<Id,List<String>>();//CR-00138393
        system.debug('$$$$$$$ ACCOUNT IDS $$$$$$$'+caseAcountIdMap.values());
        List <Account_Member__c> accoutMemberList;
        List <Contact_Member__c> contMemmberList;//CR-00138393
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
            if(!caseAcountIdMap.isEmpty() && !accountIdEmailListMap.isEmpty())
                sentMail = GSS_Caseaccount_notified.sendEmailToSubscribersUsingBatch(caseAcountIdMap,accountIdEmailListMap);
            //CR-00138393 Starts
            if(!CaseContactIdMap.isEmpty() && !contactIdEmailListMap.isEmpty())
                sentMail= GSS_Caseaccount_notified.sendEmailToSubscribersUsingBatch(CaseContactIdMap,contactIdEmailListMap);
            //CR-00138393 Ends
             try{
                    //get all case extensions for associated case the mail had been sent
                    if(!sentMail.isEmpty())                 
                        for(Case_Extension__c csExt : [select Check_No__c, Case__r.Id from Case_Extension__c where Case__r.Id IN: sentMail.keySet() ]){
                            csExt.Check_No__c = true;
                            csExtList.add(csExt);
                    }
                    Database.update(csExtList, false);//update case extension;
                }catch(Exception e){
                CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Case_Extension__c', 'GSS_Accountmember_notified_Batch');
              }
        }
        catch(Exception e){
          CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'case', 'GSS_Accountmember_notified_Batch');
    
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
    
        //START:Added logic merging multiple schedulers -Pritesh
        Boolean switchonoff=false;
        Integer minsToSchedule=0;
        String schedulerJobName='';
        if(schedulerOptimizer != Null){
            switchonoff = schedulerOptimizer.On_Off_Switch__c;
            minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c);
            schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c;
        }
        else{
            minsToSchedule = 10;
            schedulerJobName = 'GSS_AccMembNotifyBatchSchedulor';
        }
        if(switchonoff){
             schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'GSS_AccMembNotifyBatchSchedulor');
        }
        //END:Added logic merging multiple schedulers -Pritesh
    }
}