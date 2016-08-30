@isTest(SeeAllData = true)

public class RS2_CaseAssignmentUtilityTest{
    
    
  static Id caseRecordTypeId;
  static Id eventRecordTpeId;
  static Id qId;
  static Id devRecordTypeforopp;
  static User user1;
  static User user_nonAvailable;
  static User user_Available;
  static User user2;  
  static Renewals_User_Data__c rudata;
  static Renewals_User_Data__c rudata1;
  static Renewals_User_Data__c rudata3;
  static Event ev;
  static Event ev1;
  static Event ev2;
  static Event evFree;
  static Case cse;
  static Case cse1;
  static Case cse2;
  static Case cse3;
  static Case cse4;
  static Case cse5;
  static Case cse6;
  static Opportunity opp1;
  static List <Renewals_User_Data__c>  RenewalUserList;
  static List<Case> caseList;
  static List<Event> eventList;
  public static void Rs2_customsetting()
    {  
         if(((RS2RenewalQuote__c.getAll()).isEmpty())){
            List<RS2RenewalQuote__c> RS2RenewalQuoteList = new List<RS2RenewalQuote__c>();
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Success', Value__c='SUCCESS'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='System', Value__c='System'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Vmstar', Value__c='VMSTAR'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Vmstar Success', Value__c='VMSTAR SUCCESS'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Yes', Value__c='Yes'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='3-Medium', Value__c='3-Medium'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Ad-Hoc Load Auto Case Request', Value__c='Ad-Hoc Load Auto Case Request'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Ad-Hoc Opportunity Load', Value__c='Ad-Hoc Opportunity Load'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Case Cannot be Updated', Value__c='Case Cannot be Updated'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Closed', Value__c='Closed'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Error', Value__c='ERROR'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Failed Update', Value__c='CANNOT UPDATE RENEWAL QUOTE'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Failure', Value__c='FAILURE'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Invalid Transaction', Value__c='INVALID TRANSACTION'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='No Case', Value__c='No Case Found Related to the Case Number'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='No Opportunity', Value__c='No Opportunity'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='No Oppty', Value__c='NO OPPORTUNITY'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='No Quotes', Value__c='NO RECORD FOUND IN VMSTAR RELATED TO RENEWAL ID'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='No Record', Value__c='NO RECORD RECIVED IN LIST'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='On Hold', Value__c='On Hold'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Open', Value__c='Open'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Proactive', Value__c='Proactive'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='QUF Case Failed', Value__c='QUF Case Failed'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Quote Upload Failure', Value__c='Quote Upload Failure'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Quoted/Resolved', Value__c='Quoted/Resolved'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Reactive', Value__c='Reactive'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Record Cannot Be Processed', Value__c='RenewalQuote_Id OR ExpiringServiceContract_Number OR ExpiringServiceContract_Id is NULL OR EBSQuoteNumber_Modifier is NULL & Record Cannnot be Processed'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Renewal opportunity does not exist', Value__c='Renewal opportunity does not exist'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Res Code1', Value__c='SFDC-001'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Res Code2', Value__c='SFDC-002'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Res Code3', Value__c='SFDC-003'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Res Code4', Value__c='SFDC-004'));
            RS2RenewalQuoteList.add(new RS2RenewalQuote__c(Name='Res Code5', Value__c='SFDC-005'));
            insert RS2RenewalQuoteList;
        }
        if(Renewal_Config__c.getAll().isEmpty())
        {
            System.debug('Renewal_Config__c.getAll()'+Renewal_Config__c.getAll());
            String caseRecordTypeId1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
            String eventRecordTpeId1 = Schema.SObjectType.Event.getRecordTypeInfosByName().get('RS2 Renewal').getRecordTypeId();  
            String qId1 = [select id from group where type='Queue' and name='Expert Quoting Top Deals & RELA' limit 1].id;    
            AssignUserProfile.executeUserProAssigTrigger = false;
            
            List<Renewal_Config__c> rConfigList = [Select id,name from Renewal_Config__c  where name='Renewal Operations'];
            if(rConfigList.IsEmpty()){
                datetime tDate = System.now().addDays(-2);                                        
                Renewal_Config__c rconfig= new Renewal_Config__c(proactive_default_queue__c=qId1,Assignment_Engine_Threshold_Date__c=tDate,Assigned_WP__c=10,CaseRecordTypeId__c=caseRecordTypeId1,Default_Queue_Id__c=qId1,Event_Record_Type_ID__c=eventRecordTpeId1,Minute_Of_Shift__c=30,On_Hold_WP__c=2,Request_Type__c='RELA Quote',Name='Renewal Operations');
                insert rconfig;
                 System.debug('rconfig'+rconfig);
            }
        }
        System.debug('switchOn'+OnOffSwitch__c.getInstance('RS2_Workload_Allocation'));
        if(OnOffSwitch__c.getInstance('RS2_Workload_Allocation')==null)
        {
            System.debug('switchOn'+OnOffSwitch__c.getInstance('RS2_Workload_Allocation'));
            OnOffSwitch__c switchOn = new OnOffSwitch__c(Name = 'RS2_Workload_Allocation',Active__c = true);
            insert switchOn;
            System.debug('switchOn'+switchOn);
           
        }
        if(Scheduler_Optimizer__c.getAll().isEmpty()){
            Scheduler_Optimizer__c schedulerRecord7 = new Scheduler_Optimizer__c();
            schedulerRecord7.Name = 'RS2_CaseAssignmentBatchRecord';
            schedulerRecord7.On_Off_Switch__c = True;
            schedulerRecord7.Scheduler_Job_Name__c = 'RS2_CaseAssignmentBatch';
            schedulerRecord7.Time_in_Minutes_0_59__c = 30;
            insert schedulerRecord7;
        }
    }
  
  public static void setupdata(){
    caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
    eventRecordTpeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('RS2 Renewal').getRecordTypeId();  
    qId = [select id from group where type='Queue' and name='Expert Quoting Top Deals & RELA' limit 1].id;    
    AssignUserProfile.executeUserProAssigTrigger = false;
    
    renewalUserList=new  List <Renewals_User_Data__c> ();
    caseList=new List <Case>();
    
    devRecordTypeforopp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
    
    Profile p = [select id from Profile where Name = 'Renewal Operations'];
            
    String pid = p.id;
    List<User> uList = [select id from User where profileId =: pId and isActive=true limit 1];
    if(uList.isEmpty()){ 
        user1 = new User(alias = 'newUser1', email='newuser123@testorg.com',emailencodingkey='UTF-8', lastname='Test SUCHIN Contact1', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id, IsActive = true,timezonesidkey='America/Los_Angeles', username='newuser123@inforte.com');               
        insert user1;
    }else {
        user1 = uList[0];
    }
     // IBS Rule Scenarios - Creation records 
       
       Renewal_Rule_Scenario__c rulScenario = new Renewal_Rule_Scenario__c();
       rulScenario.Case_Record_Type__c = 'Renewal Operations';
       rulScenario.Case_Request_Type__c = 'RELA Quote';
       insert rulScenario;//mixed DML error
       
       // IBS Renewal_Requirement - Creation records 
       
       Renewal_Requirement__c ren_req = new Renewal_Requirement__c();
       ren_req.Parameter__c = 'Request Type';
       ren_req.Renewal_Rule_Scenario__c = rulScenario.Id;
       ren_req.Value__c = 'RELA Quote';
       
       insert ren_req;
       
    rudata = new Renewals_User_Data__c ();
    rudata.Capacity__c=10;
    rudata.Available__c=True;
    rudata.Max_Workload__c=100;
    rudata.Total_Cases_Assigned__c=0;
    rudata.Last_Assigned_Date__c=System.now();
    rudata.Handling_Escalated_Case__c=false;
    rudata.WorkloadPoints__c=0;
    rudata.User__c=UserInfo.getUserID();
    RenewalUserList.add(rudata);
           
           
    rudata1 = new Renewals_User_Data__c ();
    rudata1.Capacity__c=10;
    rudata1.Available__c=True;
    rudata1.Max_Workload__c=100;
    rudata1.Total_Cases_Assigned__c=0;
    rudata1.Last_Assigned_Date__c=System.now();
    rudata1.Handling_Escalated_Case__c=false;
    rudata1.WorkloadPoints__c=0;
    rudata1.User__c=user1.id;
    RenewalUserList.add(rudata1);
           
    insert RenewalUserList; 
    
    Id userId = rudata.User__c;
    rudata1.User__c = userId;
    try{
        update rudata1;
    }catch (Exception e){
        system.debug('DO NOTHING');
    }
    
    List<RS2_Renewal_Skill__c> skillList = new List<RS2_Renewal_Skill__c>();
    RS2_Renewal_Skill__c skill1 = new RS2_Renewal_Skill__c(Parameter__c='Request Type',Value__c='RELA Quote',Renewal_User_Data__c=rudata.id);
    RS2_Renewal_Skill__c skill2 = new RS2_Renewal_Skill__c(Parameter__c='Request Type',Value__c='RELA Quote',Renewal_User_Data__c=rudata1.id);
    skillList.add(skill1);
    skillList.add(skill2);
    insert skillList;   
    
    eventList = new List<Event>();
    ev=new Event();
    ev.Startdatetime= system.now().addDays(-1);
    ev.Enddatetime=system.now().addDays(2);
    ev.ShowAs='Busy';
    ev.ownerId=UserInfo.getUserID();
    ev.Subject='IBS Cases';
    ev.recordTypeId=eventRecordTpeId ;
    eventList.add(ev);
           
    ev1=new Event();
    ev1.Startdatetime= system.now().addDays(-1);
    ev1.Enddatetime=system.now().addDays(2);
    ev1.ShowAs='Busy';
    ev1.ownerId=user1.id;
    ev1.Subject='IBS Cases';
    ev1.recordTypeId=eventRecordTpeId ;
    eventList.add(ev1);
           
    insert eventList;
    
    account acc1 = new account();
    acc1.name = 'test acc1 RS2';
    acc1.Sales_Classification__c = 'Global';
    acc1.RS2_Special_Pricing__c = True;  
    //insert acc1;
    
    opp1 = new Opportunity();
    opp1.Name = 'Test opp1 RS2';
    opp1.StageName = '02-Contacted';
    opp1.CloseDate = system.today();
    opp1.RS2_Line_of_Business_to__c  = 'Test LOB1';
    opp1.Service_Contract_Number__c = 'Test';
    //opp1.accountId = acc1.id;
    opp1.RecordTypeId = devRecordTypeforopp ;
    insert opp1;
    
  }
     

 public testmethod static void testMethod1()
   { 
            Rs2_customsetting();
            setupdata();
            GSS_UtilityClass.isBeforeUpdate_Case = true;
            GSS_UtilityClass.isAfterInsert_Case = true;
            GSS_UtilityClass.isAfterUpdate_Case = true;
            //Reactive non escalated case
            cse=new Case();
            cse.GSS_Support_Level__c='1';
            cse.GSS_Problem_Category__c='Feature Request';
            cse.Status='Open';
            cse.Sub_Status__c='Assigned';
            cse.Priority='2 - High';
            cse.RecordTypeId = caseRecordTypeId;
            cse.QC_Type__c = 'Reactive';
            cse.Request_Type__c = 'RELA Quote';
            cse.EA_Number__c = '12345';
            cse.IsEscalated=false;
            cse.Origin = 'VMSTAR';
            cse.Opportunity_ID__c = opp1.id ;
            caseList.add(cse);
            
            //Reactive escalated case 
            cse2=new Case();
            cse2.GSS_Support_Level__c='1';
            cse2.GSS_Problem_Category__c='Feature Request';
            cse2.Status='Open';
            cse2.Sub_Status__c='Assigned';
            cse2.Priority='2 - High';
            cse2.RecordTypeId = caseRecordTypeId;
            cse2.QC_Type__c = 'Reactive';
            cse2.Request_Type__c = 'RELA Quote';
            cse2.EA_Number__c = '12345';
            cse2.IsEscalated=true;
            cse2.Origin = 'VMSTAR';
            cse2.Opportunity_ID__c = opp1.id ;
            //caseList.add(cse2);
            
            //Reactive ON Hold Case
            cse4=new Case();
            cse4.GSS_Support_Level__c='1';
            cse4.GSS_Problem_Category__c='Feature Request';
            cse4.Status='On Hold';
            cse4.Sub_Status__c='Assigned';
            cse4.Priority='2 - High';
            cse4.RecordTypeId = caseRecordTypeId;
            cse4.QC_Type__c = 'Reactive';
            cse4.Request_Type__c = 'RELA Quote';
            cse4.EA_Number__c = '12345';
            cse4.IsEscalated=false;
            cse4.Origin = 'VMSTAR';
            cse4.Opportunity_ID__c = opp1.id ;
            caseList.add(cse4);
            
            //Proactive non escalated case
            cse3=new Case();
            cse3.GSS_Support_Level__c='1';
            cse3.GSS_Problem_Category__c='Feature Request';
            cse3.Status='Open';
            cse3.Sub_Status__c='Assigned';
            cse3.Priority='2 - High';
            cse3.RecordTypeId = caseRecordTypeId;
            cse3.QC_Type__c = 'Proactive';
            cse3.Request_Type__c = 'RELA Quote';
            cse3.EA_Number__c = '12345';
            cse3.IsEscalated=false;
            cse3.Origin = 'VMSTAR';
            cse3.Opportunity_ID__c = opp1.id ;
            caseList.add(cse3);
            
            //Reactive non escalated case
            cse6=new Case();
            cse6.GSS_Support_Level__c='1';
            cse6.GSS_Problem_Category__c='Feature Request';
            cse6.Status='Open';
            cse6.Sub_Status__c='Assigned';
            cse6.Priority='2 - High';
            cse6.RecordTypeId = caseRecordTypeId;
            cse6.QC_Type__c = 'Reactive';
            cse6.Request_Type__c = 'RELA Quote';
            cse6.EA_Number__c = '12345';
            cse6.IsEscalated=false;
            cse6.Origin = 'VMSTAR';
            cse6.Opportunity_ID__c = opp1.id ;
            caseList.add(cse6);
            
            
            test.starttest();  
            System.runAs(user1){
                insert caseList;
            }
            
           
            rudata.capacity__c=3;
            rudata.Max_Workload__c=30;
            update rudata;
            evFree=new Event();
            evFree.Startdatetime= system.now().addDays(-1);
            evFree.Enddatetime=system.now().addDays(2);
            evFree.ShowAs='Free';
            evFree.ownerId=UserInfo.getUserID();
            evFree.Subject='OOO';
            evFree.recordTypeId=eventRecordTpeId ;
            insert evFree;
           
           //Reactive non escalated case
            cse5=new Case();
            cse5.GSS_Support_Level__c='1';
            cse5.GSS_Problem_Category__c='Feature Request';
            cse5.Status='Open';
            cse5.Sub_Status__c='Assigned';
            cse5.Priority='2 - High';
            cse5.RecordTypeId = caseRecordTypeId;
            cse5.QC_Type__c = 'Reactive';
            cse5.Request_Type__c = 'RELA Quote';
            cse5.EA_Number__c = '12345';
            cse5.IsEscalated=false;
            cse5.Origin = 'VMSTAR';
            cse5.Opportunity_ID__c = opp1.id ;
            insert cse5;
            
            delete evFree;
            
            test.stoptest();  
   }
   public static testMethod void testMethod2(){
    Rs2_customsetting();
    setupdata();
    GSS_UtilityClass.isBeforeUpdate_Case = true;
    GSS_UtilityClass.isBeforeInsert_Case = true;
    GSS_UtilityClass.isAfterInsert_Case = true;
    GSS_UtilityClass.isAfterUpdate_Case = true;
    GSS_UtilityClass.isTaskTriggerCheck = true;
    
    //Proactive non escalated case
    cse3=new Case();
    cse3.GSS_Support_Level__c='1';
    cse3.GSS_Problem_Category__c='Feature Request';
    cse3.Status='Open';
    cse3.Sub_Status__c='Assigned';
    cse3.Priority='2 - High';
    cse3.RecordTypeId = caseRecordTypeId;
    cse3.QC_Type__c = 'Reactive';
    cse3.Request_Type__c = 'RELA Quote';
    cse3.EA_Number__c = '12345';
    cse3.IsEscalated=false;
    cse3.Origin = 'VMSTAR';
    cse3.Opportunity_ID__c = opp1.id ;
    cse3.ownerId = user1.id;
    insert cse3;
    Case_Extension__c ext = new Case_Extension__c(case__c = cse3.id);
    insert ext;
    RS2_CaseAssignmentUtility.IS_WP_Processed = false;
    RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
    
    GSS_UtilityClass.isBeforeUpdate_Case = false;
    test.starttest();
    cse3.status = 'On Hold'; //Status change scenario
    update cse3;
    RS2_CaseAssignmentUtility.IS_WP_Processed = false;
    RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;     
    rudata.capacity__c=4;
    rudata.Max_Workload__c=40;
    update rudata;
    String uid = user1.id;
   // List<String> ids = new List<String>{cse.id,cse2.id,cse3.id,cse4.id};
    //Case c = [Select id,ownerId from Case where ownerId =: uid and id IN: ids limit 1];
    cse3.ownerId = userInfo.getUserId(); // Owner change scenario
    update cse3;
    RS2_CaseAssignmentUtility.IS_WP_Processed = false;
    RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
    cse3.ownerId = qId; // Owner change scenario
    update cse3;
    RS2_CaseAssignmentUtility.IS_WP_Processed = false;
    RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
    cse3.status ='Open'; 
    cse3.ownerId = user1.id;// Owner change scenario
    update cse3;
    RS2_CaseAssignmentUtility.IS_WP_Processed = false;
    RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
    RS2_CaseAssignmentUtility.IS_Renewal_Analysts_Not_Found = true;
    RS2_CaseAssignmentUtility.populateCaseFlagForNoEligibleFound(new List<case>{cse3});
    RS2_CaseAssignmentUtility.IS_WP_Processed = false;
    RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
     cse3.IsEscalated = true;
     update cse3;
    RS2_CaseAssignmentUtility.IS_WP_Processed = false;
    RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
    cse3.status = 'Closed';
    update cse3; // Case closure scenario     
    test.stoptest();
   }
   public static void setupdata2(){
    caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
    eventRecordTpeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('RS2 Renewal').getRecordTypeId();  
    qId = [select id from group where type='Queue' and name='Expert Quoting Top Deals & RELA' limit 1].id;    
    AssignUserProfile.executeUserProAssigTrigger = false;
    
    renewalUserList=new  List <Renewals_User_Data__c> ();
    caseList=new List <Case>();
    
    devRecordTypeforopp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
    
    Profile p = [select id from Profile where Name = 'Renewal Operations'];
            
    String pid = p.id;
   
    user_nonAvailable = new User(alias = 'sbsbsb', email='newuser1234@testorg.com',emailencodingkey='UTF-8', lastname='Test SUCHIN Contact1', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id, IsActive = true,timezonesidkey='America/Los_Angeles', username='newuser123@inforte.com');               
    insert user_nonAvailable;
    
    user_Available = new User(alias = 'sbsbk', email='newuser1235@testorg.com',emailencodingkey='UTF-8', lastname='Test SUCHIN Contact2', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id, IsActive = true,timezonesidkey='America/Los_Angeles', username='newuser123444@inforte.com');               
    insert user_Available;
    
    user1 = new User(alias = 'sbsbk', email='newuser12356@testorg.com',emailencodingkey='UTF-8', lastname='Test SUCHIN Contac32', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id, IsActive = true,timezonesidkey='America/Los_Angeles', username='newuser12344444@inforte.com');               
    insert user1;
    
    user2 = new User(alias = 'sbsb123', email='newuser2356@testorg.com',emailencodingkey='UTF-8', lastname='Test SUCHIN123', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id, IsActive = true,timezonesidkey='America/Los_Angeles', username='newuser12348@inforte.com');               
    insert user2;
    
    // IBS Rule Scenarios - Creation records 
       
       Renewal_Rule_Scenario__c rulScenario = new Renewal_Rule_Scenario__c();
       rulScenario.Case_Record_Type__c = 'Renewal Operations';
       rulScenario.Case_Request_Type__c = 'RELA Quote';
       insert rulScenario;//mixed DML error
       
       // IBS Renewal_Requirement - Creation records 
       
       Renewal_Requirement__c ren_req = new Renewal_Requirement__c();
       ren_req.Parameter__c = 'Request Type';
       ren_req.Renewal_Rule_Scenario__c = rulScenario.Id;
       ren_req.Value__c = 'RELA Quote';
       
       insert ren_req;
       
    rudata = new Renewals_User_Data__c ();
    rudata.Capacity__c=10;
    rudata.Available__c=true;
    rudata.Max_Workload__c=100;
    rudata.Total_Cases_Assigned__c=10;
    rudata.Last_Assigned_Date__c=System.now();
    rudata.Handling_Escalated_Case__c=false;
    rudata.WorkloadPoints__c=100;
    rudata.User__c = user2.Id;
    RenewalUserList.add(rudata);
    
    rudata = new Renewals_User_Data__c ();
    rudata.Capacity__c=10;
    rudata.Available__c=true;
    rudata.Max_Workload__c=100;
    rudata.Total_Cases_Assigned__c=0;
    rudata.Last_Assigned_Date__c=System.now();
    rudata.Handling_Escalated_Case__c=false;
    rudata.WorkloadPoints__c=0;
    rudata.User__c = user1.Id;
    RenewalUserList.add(rudata);
    
    rudata3 = new Renewals_User_Data__c ();
    rudata3.Capacity__c=10;
    rudata3.Available__c=false;
    rudata3.Max_Workload__c=100;
    rudata3.Total_Cases_Assigned__c=0;
    rudata3.Last_Assigned_Date__c=System.now();
    rudata3.Handling_Escalated_Case__c=false;
    rudata3.WorkloadPoints__c=0;
    rudata3.User__c = user_nonAvailable.Id;
    RenewalUserList.add(rudata3);
    
    rudata1 = new Renewals_User_Data__c ();
    rudata1.Capacity__c=10;
    rudata1.Available__c=True;
    rudata1.Max_Workload__c=100;
    rudata1.Total_Cases_Assigned__c=0;
    rudata1.Last_Assigned_Date__c=System.now();
    rudata1.Handling_Escalated_Case__c=false;
    rudata1.WorkloadPoints__c=0;
    rudata1.User__c= user_Available.id;
    RenewalUserList.add(rudata1);
           
           
    insert RenewalUserList;
   
    List<RS2_Renewal_Skill__c> skillList = new List<RS2_Renewal_Skill__c>();
    RS2_Renewal_Skill__c skill1 = new RS2_Renewal_Skill__c(Parameter__c='Request Type',Value__c='RELA Quote',Renewal_User_Data__c=rudata3.id);
    RS2_Renewal_Skill__c skill2 = new RS2_Renewal_Skill__c(Parameter__c='Request Type',Value__c='RELA Quote',Renewal_User_Data__c=rudata1.id);
    RS2_Renewal_Skill__c skill3 = new RS2_Renewal_Skill__c(Parameter__c='Request Type',Value__c='RELA Quote',Renewal_User_Data__c=rudata.id);
    skillList.add(skill1);
    skillList.add(skill2);
    skillList.add(skill3);
    insert skillList;   
    
    eventList = new List<Event>();
    ev=new Event();
    ev.Startdatetime= system.now().addDays(-1);
    ev.Enddatetime=system.now().addDays(2);
    ev.ShowAs='Busy';
    ev.ownerId=user_nonAvailable.id;
    ev.Subject='IBS Cases';
    ev.recordTypeId=eventRecordTpeId ;
    eventList.add(ev);
     
    ev1=new Event();
    ev1.Startdatetime= system.now().addDays(-1);
    ev1.Enddatetime=system.now().addDays(2);
    ev1.ShowAs='Busy';
    ev1.ownerId=user_Available.id;
    ev1.Subject='IBS Cases';
    ev1.recordTypeId=eventRecordTpeId ;
    eventList.add(ev1); 
    //insert eventList;
    
    ev2=new Event();
    ev2.Startdatetime= system.now().addDays(-1);
    ev2.Enddatetime=system.now().addDays(2);
    ev2.ShowAs='Busy';
    ev2.ownerId=user_Available.id;
    ev2.Subject='IBS Cases';
    ev2.recordTypeId=eventRecordTpeId ;
    eventList.add(ev2); 
    insert eventList;
    
    account acc1 = new account();
    acc1.name = 'test acc1 RS2';
    acc1.Sales_Classification__c = 'Global';
    acc1.RS2_Special_Pricing__c = True;  
    //insert acc1;
    
    opp1 = new Opportunity();
    opp1.Name = 'Test opp1 RS2';
    opp1.StageName = '02-Contacted';
    opp1.CloseDate = system.today();
    opp1.RS2_Line_of_Business_to__c  = 'Test LOB1';
    opp1.Service_Contract_Number__c = 'Test';
    //opp1.accountId = acc1.id;
    opp1.RecordTypeId = devRecordTypeforopp ;
    insert opp1;
    
  }
   
   public static testMethod void testMethod3(){
        Rs2_customsetting();
        setupdata2();
        GSS_UtilityClass.isBeforeUpdate_Case = true;
        GSS_UtilityClass.isBeforeInsert_Case = true;
        GSS_UtilityClass.isAfterInsert_Case = true;
        GSS_UtilityClass.isAfterUpdate_Case = true;

        cse3=new Case();
        cse3.GSS_Support_Level__c='1';
        cse3.GSS_Problem_Category__c='Feature Request';
        cse3.Status='Open';
        cse3.Sub_Status__c='Assigned';
        cse3.Priority='2 - High';
        cse3.RecordTypeId = caseRecordTypeId;
        cse3.QC_Type__c = 'Reactive';
        cse3.Request_Type__c = 'RELA Quote';
        cse3.EA_Number__c = '12345';
        cse3.IsEscalated=false;
        cse3.Origin = 'VMSTAR';
        cse3.Opportunity_ID__c = opp1.id ;
        //cse3.ownerId = user1.id;
        
        insert cse3;
        Case_Extension__c ext = new Case_Extension__c(case__c = cse3.id);
        insert ext;
        RS2_CaseAssignmentUtility.IS_WP_Processed = false;
        RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
        
        GSS_UtilityClass.isBeforeUpdate_Case = false;
        
        RS2_CaseAssignmentUtility.IS_WP_Processed = false;
        RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;     
        try{
            cse3.ownerId = user_nonAvailable.Id; // Owner change scenario
            update cse3;
        }catch(Exception e)
        {
            system.debug('DO NOTHING');
        }
         RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;     
        try{
            cse3.ownerId = User2.Id; // Owner change scenario
            update cse3;
        }catch(Exception e)
        {
            system.debug('DO NOTHING');
        }
    }
    public static testMethod void testMethod4(){
        Rs2_customsetting();
        setupdata2();
        
        GSS_UtilityClass.isBeforeUpdate_Case = true;
        GSS_UtilityClass.isBeforeInsert_Case = true;
        GSS_UtilityClass.isAfterInsert_Case = true;
        GSS_UtilityClass.isAfterUpdate_Case = true;
        
        String rConfig = String.valueof(Renewal_Config__c.getInstance('Renewal Operations')!=null && Renewal_Config__c.getInstance('Renewal Operations').CaseRecordTypeId__c!=null ? Renewal_Config__c.getInstance('Renewal Operations').CaseRecordTypeId__c:'0128000000044mWAAQ');
        String rConfig1=String.valueof(Renewal_Config__c.getInstance('Renewal Operations')!=null && Renewal_Config__c.getInstance('Renewal Operations').Request_Type__c!=null ? Renewal_Config__c.getInstance('Renewal Operations').Request_Type__c:'RELA Quote');
        
        cse3=new Case();
        cse3.GSS_Support_Level__c='1';
        cse3.GSS_Problem_Category__c='Feature Request';
        cse3.Status='Open';
        cse3.Sub_Status__c='Assigned';
        cse3.Priority='2 - High';
        cse3.RecordTypeId =rConfig;
        cse3.Request_Type__c =rConfig1;
        cse3.EA_Number__c ='12345';
        cse3.IsEscalated=false;
        cse3.Origin = 'VMSTAR';
        cse3.Opportunity_ID__c = opp1.id ;
        cse3.ownerId = user1.id;
        cse3.QC_Type__c =' ';
        insert cse3;
        
        cse4=new Case();
        cse4.GSS_Support_Level__c='1';
        cse4.GSS_Problem_Category__c='Feature Request';
        cse4.Status='Open';
        cse4.Sub_Status__c='Assigned';
        cse4.Priority='2 - High';
        cse4.RecordTypeId =rConfig;
        cse4.Request_Type__c =rConfig1;
        cse4.EA_Number__c ='12345';
        cse4.IsEscalated=false;
        cse4.Origin = 'VMSTAR';
        cse4.Opportunity_ID__c = opp1.id ;
        cse4.ownerId = user2.id;
        cse4.QC_Type__c =' ';
        insert cse4;
        
        Case_Extension__c ext = new Case_Extension__c(case__c = cse3.id);
        Case_Extension__c ext1 = new Case_Extension__c(case__c = cse4.id);
        insert ext;
        insert ext1;
        
        RS2_CaseAssignmentUtility.IS_WP_Processed = false;
        RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
        GSS_UtilityClass.isBeforeUpdate_Case = false;
        RS2_CaseAssignmentUtility.IS_WP_Processed = false;
        RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false; 
        test.starttest();
        cse3.ownerId = user2.id;
        cse3.IsEscalated = true;
        cse3.RecordTypeId =rConfig;
        update cse3;
        cse4.ownerId = user2.id;
        cse4.IsEscalated = true;
        cse4.RecordTypeId =rConfig;
        update cse4;
        test.stoptest();
    }
    public static testMethod void testMethod5(){
        Rs2_customsetting();
        setupdata2();
        
        GSS_UtilityClass.isBeforeUpdate_Case = true;
        GSS_UtilityClass.isBeforeInsert_Case = true;
        GSS_UtilityClass.isAfterInsert_Case = true;
        GSS_UtilityClass.isAfterUpdate_Case = true;
        
        String rConfig = String.valueof(Renewal_Config__c.getInstance('Renewal Operations')!=null && Renewal_Config__c.getInstance('Renewal Operations').CaseRecordTypeId__c!=null ? Renewal_Config__c.getInstance('Renewal Operations').CaseRecordTypeId__c:'0128000000044mWAAQ');
        String rConfig1=String.valueof(Renewal_Config__c.getInstance('Renewal Operations')!=null && Renewal_Config__c.getInstance('Renewal Operations').Request_Type__c!=null ? Renewal_Config__c.getInstance('Renewal Operations').Request_Type__c:'RELA Quote');
        
        cse3=new Case();
        cse3.GSS_Support_Level__c='1';
        cse3.GSS_Problem_Category__c='Feature Request';
        cse3.Status='Open';
        cse3.Sub_Status__c='Assigned';
        cse3.Priority='2 - High';
        cse3.RecordTypeId =rConfig;
        cse3.Request_Type__c =rConfig1;
        cse3.EA_Number__c ='12345';
        cse3.IsEscalated=false;
        cse3.Origin = 'VMSTAR';
        cse3.Opportunity_ID__c = opp1.id ;
        cse3.ownerId = user1.id;
        cse3.QC_Type__c =' ';
        insert cse3;
        Case_Extension__c ext = new Case_Extension__c(case__c = cse3.id);
        insert ext;
        RS2_CaseAssignmentUtility.IS_WP_Processed = false;
        RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
        GSS_UtilityClass.isBeforeUpdate_Case = false;
        RS2_CaseAssignmentUtility.IS_WP_Processed = false;
        RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false; 
        test.starttest();
        cse3.ownerId = user2.id;
        cse3.Status='Closed';
        cse3.RecordTypeId =rConfig;
        update cse3;
        test.stoptest();
    }
     public static testMethod void testMethod6(){
        Rs2_customsetting();
        setupdata2();
        
        GSS_UtilityClass.isBeforeUpdate_Case = true;
        GSS_UtilityClass.isBeforeInsert_Case = true;
        GSS_UtilityClass.isAfterInsert_Case = true;
        GSS_UtilityClass.isAfterUpdate_Case = true;
        
        String rConfig = String.valueof(Renewal_Config__c.getInstance('Renewal Operations')!=null && Renewal_Config__c.getInstance('Renewal Operations').CaseRecordTypeId__c!=null ? Renewal_Config__c.getInstance('Renewal Operations').CaseRecordTypeId__c:'0128000000044mWAAQ');
        String rConfig1=String.valueof(Renewal_Config__c.getInstance('Renewal Operations')!=null && Renewal_Config__c.getInstance('Renewal Operations').Request_Type__c!=null ? Renewal_Config__c.getInstance('Renewal Operations').Request_Type__c:'RELA Quote');
        
        cse3=new Case();
        cse3.GSS_Support_Level__c='1';
        cse3.GSS_Problem_Category__c='Feature Request';
        cse3.Status='Open';
        cse3.Sub_Status__c='Assigned';
        cse3.Priority='2 - High';
        cse3.RecordTypeId =rConfig;
        cse3.Request_Type__c =rConfig1;
        cse3.EA_Number__c ='12345';
        cse3.IsEscalated=false;
        cse3.Origin = 'VMSTAR';
        cse3.Opportunity_ID__c = opp1.id ;
        cse3.ownerId = user1.id;
        cse3.QC_Type__c =' ';
        insert cse3;
        Case_Extension__c ext = new Case_Extension__c(case__c = cse3.id);
        insert ext;
        RS2_CaseAssignmentUtility.IS_WP_Processed = false;
        RS2_CaseAssignmentUtility.IS_Executed_Same_Transaction = false;
        GSS_UtilityClass.isBeforeUpdate_Case = false;
        
        test.starttest();
        cse3.ownerId = user2.id;
        cse3.Status='ON_HOLD';
        cse3.RecordTypeId =rConfig;
        update cse3;
        test.stoptest();
    }
}