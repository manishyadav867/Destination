@isTest(seealldata = true)
Public class RS2_AutopopulatevaluesoncaseTest{
  static Id devRecordTypeforcase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
  static Id devRecordTypeforaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End Customer').getRecordTypeId();
  static Id devRecordTypeforopp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
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
        List<RS2_Feature_Enable__c> RS2FeatureEnableList = new List<RS2_Feature_Enable__c>([Select id,name,RunQUF101Flow__c from RS2_Feature_Enable__c]); 
        if(RS2FeatureEnableList!=null && RS2FeatureEnableList.size()>0){
            for(RS2_Feature_Enable__c r:RS2FeatureEnableList){
                            r.RunQUF101Flow__c=true;
            }
            update RS2FeatureEnableList;
        }
        if(Renewal_Config__c.getAll().isEmpty())
        {
            System.debug('Renewal_Config__c.getAll()'+Renewal_Config__c.getAll());
            String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
            String eventRecordTpeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('RS2 Renewal').getRecordTypeId();  
            String qId = [select id from group where type='Queue' and name='Expert Quoting Top Deals & RELA' limit 1].id;    
            AssignUserProfile.executeUserProAssigTrigger = false;
            
            List<Renewal_Config__c> rConfigList = [Select id,name from Renewal_Config__c  where name='Renewal Operations'];
            if(rConfigList.IsEmpty()){
                datetime tDate = System.now().addDays(-2);                                        
                Renewal_Config__c rconfig= new Renewal_Config__c(proactive_default_queue__c=caseRecordTypeId,Assignment_Engine_Threshold_Date__c=tDate,Assigned_WP__c=10,CaseRecordTypeId__c=caseRecordTypeId,Default_Queue_Id__c=qId,Event_Record_Type_ID__c=eventRecordTpeId,Minute_Of_Shift__c=30,On_Hold_WP__c=2,Request_Type__c='RELA Quote',Name='Renewal Operations');
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
     static testMethod void runRS2_Autopopulatevaluesoncase()
        {
        Rs2_customsetting();
          Group testGroup = new Group(Name='test group', Type='Queue');
          insert testGroup;
          
          System.runAs(new User(Id=UserInfo.getUserId()))
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
            
          List<case> caseList = new List<case>();
          List<opportunity> oppList = new List<opportunity>();
          List<RS2_Quoting__c> csList = new List<RS2_Quoting__c>();  
       
          account acc1 = new account();
              acc1.name = 'test acc1 RS2';
              acc1.Sales_Classification__c = 'Global';
              acc1.RS2_Special_Pricing__c = True;
              acc1.RecordTypeId =  devRecordTypeforaccount; 
              insert acc1;
          
          account acc2 = new account();
              acc2.name = 'test acc2 RS2';
              acc2.Sales_Classification__c = 'Federal';
              acc2.RS2_Special_Pricing__c = False;
              acc2.RecordTypeId =  devRecordTypeforaccount;  
              insert acc2;

          account acc3 = new account();
              acc3.name = 'test acc3 RS2';
              acc3.Sales_Classification__c = 'Public Sector';
              acc3.RS2_Special_Pricing__c = false;
              acc3.RecordTypeId =  devRecordTypeforaccount;               
              insert acc3;
              
                 
          Opportunity opp1 = new Opportunity();
              opp1.Name = 'Test opp1 RS2';
              opp1.StageName = '02-Contacted';
              opp1.CloseDate = system.today();
              opp1.RS2_Line_of_Business_to__c  = 'Test LOB1';
              opp1.Service_Contract_Number__c = 'Test';
              opp1.accountId = acc1.id;
              opp1.RecordTypeId = devRecordTypeforopp ;
              oppList.add(opp1);
       
          Opportunity opp2= new Opportunity();
              opp2.Name = 'Test opp2 RS2';
              opp2.StageName = '02-Contacted';
              opp2.CloseDate = system.today();
              opp2.RS2_Line_of_Business_to__c  = 'Test LOB2';
              opp2.Service_Contract_Number__c = 'Test';
              opp2.accountId = acc2.id;
              opp2.RecordTypeId = devRecordTypeforopp ;
              oppList.add(opp2);
          
          Opportunity opp3 = new Opportunity();
              opp3.Name = 'Test opp3 RS2';
              opp3.StageName = '02-Contacted';
              opp3.CloseDate = system.today();
              opp3.Service_Contract_Number__c = 'test';
              opp3.RS2_Line_of_Business_to__c  = 'Test LOB3';
              opp3.accountId = acc3.id;
              opp3.RecordTypeId = devRecordTypeforopp ;
              oppList.add(opp3);
              
           if(oppList.Size()> 0)
                {insert oppList;
                
            }
        
          Case cas1 = new Case();
              cas1.Status = 'Open';
              cas1.Origin = 'VMSTAR';
              cas1.Opportunity_ID__c = opp1.id ;
              cas1.RecordTypeId = devRecordTypeforcase;
              cas1.Account_Subscription__c = opp1.accountid;
              cas1.Channel_Partner__c = opp1.accountid;
              caselist.add(cas1);
     
          Case cas2 = new Case();
              cas2.Status = 'Open';
              cas2.Origin = 'VMSTAR';
              cas2.Vmware_Contract_Number__c = 'test';
              cas2.RecordTypeId = devRecordTypeforcase;
              caselist.add(cas2);
         
          Case cas3 = new Case();
              cas3.Status = 'Open';
              cas3.Opportunity_ID__c = opp3.id ;
              cas3.Origin = 'Online Renewals';
              cas3.RecordTypeId = devRecordTypeforcase;
              cas3.Account_Subscription__c = opp2.accountid;
              cas3.Channel_Partner__c = opp2.accountid;
              cas3.Vmware_Contract_Number__c = 'test1';
              cas3.OwnerId = testGroup.Id;
              //cas3.Customer_Classification__c = 'Public Sector';
              caselist.add(cas3);
              
           Case cas4 = new Case();
              cas4.Status = 'Open';
              cas4.Origin = 'VMSTAR';
              cas4.RecordTypeId = devRecordTypeforcase;
              cas4.Vmware_Contract_Number__c = 'test,test';
              cas4.Opportunity_ID__c = opp2.id; 
              caselist.add(cas4);
       
           if(caseList.Size()> 0)
                {insert caseList;}
              
              caseList[0].Channel_Partner__c = opp2.accountid;
              caseList[2].Channel_Partner__c = null;
              caseList[2].Opportunity_ID__c = opp2.id;
              caseList[2].ownerid = UserInfo.getUserId();
              update caseList;
          
              caseList[2].Opportunity_ID__c = null;
              caseList[1].Vmware_Contract_Number__c = 'test1,test1';
              caseList[3].Vmware_Contract_Number__c = 'test1 test1';
              caseList[2].Vmware_Contract_Number__c = null ; 
              update caseList;
  
        }
        static testMethod void runRS2_Autopopulatevaluesoncase1()
        {
            Rs2_customsetting();
              Group testGroup = new Group(Name='test group', Type='Queue');
              insert testGroup;
          
          System.runAs(new User(Id=UserInfo.getUserId()))
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
            
          List<case> caseList = new List<case>();
          List<opportunity> oppList = new List<opportunity>();
          List<RS2_Quoting__c> csList = new List<RS2_Quoting__c>();  
       
          account acc1 = new account();
              acc1.name = 'test acc1 RS2';
              acc1.Sales_Classification__c = 'Global';
              acc1.RS2_Special_Pricing__c = True;
              acc1.RecordTypeId =  devRecordTypeforaccount; 
              insert acc1;
          
          account acc2 = new account();
              acc2.name = 'test acc2 RS2';
              acc2.Sales_Classification__c = 'Federal';
              acc2.RS2_Special_Pricing__c = False;
              acc2.RecordTypeId =  devRecordTypeforaccount;  
              insert acc2;

          account acc3 = new account();
              acc3.name = 'test acc3 RS2';
              acc3.Sales_Classification__c = 'Public Sector';
              acc3.RS2_Special_Pricing__c = false;
              acc3.RecordTypeId =  devRecordTypeforaccount;               
              insert acc3;
              
                 
          Opportunity opp1 = new Opportunity();
              opp1.Name = 'Test opp1 RS2';
              opp1.StageName = '02-Contacted';
              opp1.CloseDate = system.today();
              opp1.RS2_Line_of_Business_to__c  = 'Test LOB1';
              opp1.Service_Contract_Number__c = 'Test';
              opp1.accountId = acc1.id;
              opp1.RecordTypeId = devRecordTypeforopp ;
              oppList.add(opp1);
       
          Opportunity opp2= new Opportunity();
              opp2.Name = 'Test opp2 RS2';
              opp2.StageName = '02-Contacted';
              opp2.CloseDate = system.today();
              opp2.RS2_Line_of_Business_to__c  = 'Test LOB2';
              opp2.Service_Contract_Number__c = 'Test';
              opp2.accountId = acc2.id;
              opp2.RecordTypeId = devRecordTypeforopp ;
              oppList.add(opp2);
          
          Opportunity opp3 = new Opportunity();
              opp3.Name = 'Test opp3 RS2';
              opp3.StageName = '02-Contacted';
              opp3.CloseDate = system.today();
              opp3.RS2_Line_of_Business_to__c  = 'Test LOB3';
              opp3.accountId = acc3.id;
              opp3.RecordTypeId = devRecordTypeforopp ;
              opp3.RS2_Expiring_Contract_Number__c='123456';
              oppList.add(opp3);
           
           Case cas1 = new Case();
              cas1.Status = 'Open';
              cas1.Origin = 'VMSTAR';
              cas1.Opportunity_ID__c = opp1.id ;
              cas1.RecordTypeId = devRecordTypeforcase;
              cas1.Account_Subscription__c = opp1.accountid;
              cas1.Channel_Partner__c = opp1.accountid;
              cas1.Vmware_Contract_Number__c='123456';
              cas1.AccountId=acc1.id;
              caselist.add(cas1);
              
           if(oppList.Size()> 0)
            {
                insert oppList;
            }
            insert caselist;
            RS2_Autopopulatevaluesoncase.mapServieContarctOpp(oppList);
             
            caselist[0].AccountId=acc2.id;
            caselist[0].Vmware_Contract_Number__c='123457';
            update caselist;
        }
}