/**Class Name: PLM_AcceptLeadsTest
/** Created By: Accenture
/** Created Date: 03-Oct-2012
/** Purpose: To increase the test coverage of the "PLM_Accept Leads" Class
/** Log Details: (Please find the details bellow)
/*******************************CHANGE LOG****************************************************************************
* Author                               Date            Remarks 
*Archana Mujumdar                   15-Sept-2013    Added testMethods to increase the code coverage for PLM2
*Manik Chaudhary                    25/04/2015        Added testMethod to cover LeadManagement Class for CR-00124553
*Vijit Vijay                        26/08/2015        Added testMethod to cover LeadManagement Class for CR-00135033
*******************************************************************************************************************/

@isTest(seealldata=true)
private class PLM_AcceptLeadsTest{



//test Method to test the data
   static testMethod void testAcceptLeads(){
        
       //Insert Leads
       Lead lead = new Lead(Company='Test1',LastName='Lead1',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes');
       insert lead;
       
       Lead lead1 = new Lead(Company='Test2',LastName='Lead2',Status='1 In Progress',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes');
       insert lead1;
       
       
       Test.startTest();
       
       ApexPages.currentPage().getParameters().put('retUrl','/');
       ApexPages.currentPage().getParameters().put('selectedRecords',lead.id);
    
                            
       //Creating an instance of the "PLM_AcceptLeads" class                            
       PLM_AcceptLeads.acceptLead(lead.Id);
       try {
       
           PLM_AcceptLeads.acceptLead(null);
       } catch(Exception e) {
       }
       
       List<Lead> leads=new List<Lead>();
       lead1.Date_When_Status_New__c=system.today();
       lead1.Time_In_New_Status_Hours__c=1;
       leads.add(lead1);
       update leads;
       LeadManagement.calculateLeadAge(leads);
   }
   /***************Added by Archana Mujumdar for PLM2 -START**********************************/
    static testMethod void testDeclineLeads(){
        
       //Insert Leads
       Lead lead = new Lead(Company='Test1',LastName='Lead1',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes');
       insert lead;
       
       Test.startTest();
       
       ApexPages.currentPage().getParameters().put('retUrl','/');
       ApexPages.currentPage().getParameters().put('selectedRecords',lead.id);

                            
       //Creating an instance of the "PLM_AcceptLeads" class                            
       PLM_AcceptLeads.declineLead(lead.Id);
       try {
       
           PLM_AcceptLeads.declineLead(null);
       } catch(Exception e) {
       }
       Test.stopTest();
   }
   static testMethod void testacceptBulkLeads(){
        
       //Insert Leads
       List<Lead> leadList=new List<Lead>(); 
       leadList.add(new Lead(Company='Test1',LastName='Lead1',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes'));
       leadList.add(new Lead(Company='Test2',LastName='Lead2',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes'));
       insert leadList;
       String str=leadList[0].id+','+leadList[1].id;   
       Test.startTest();
       
                  
        
       
       
       ApexPages.currentPage().getParameters().put('retUrl','/');
       ApexPages.currentPage().getParameters().put('selectedRecords',str);
    
       //Creating an instance of the "PLM_AcceptLeads" class                            
       PLM_AcceptLeads.acceptLeads(str);
       try {
       
           PLM_AcceptLeads.acceptLeads(null);
          
         
                     
       } catch(Exception e) {
       }
       Test.stopTest();
   }
    /***************Added by Archana Mujumdar for PLM2 -END**********************************/
    
    /***************Added by Manik Chaudhary for LeadManagement Coverage CR-00124553**********************************/
    static testMethod void testMethodtocoverLeadManagement(){
        Profile_Name_Mapping__c adminprofile = CustomSettingUtility.getProfileNameMapping('LDR'); 
        
         Profile_Name_Mapping__c usrprofile = CustomSettingUtility.getProfileNameMapping('Partner Rep Basic-Leads');  
                
        List<User> usr1 = new List<User>();
          
             usr1.add( new User(alias = 'neser1', email='newus23@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testi23g', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = adminprofile.Profile_Id__c, 
            timezonesidkey='America/Los_Angeles', division = 'AMER',username='newu3er@inforte.com.vmw'));

          insert usr1;          
        
            List<Account> acct=new List<Account>();
            List<Opportunity> optylst= new List<Opportunity>();
        
        
         acct.add(new Account(
                    name = 'ApexTestCasesPartner',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.PartnerAccountRecType                    
        ));
        acct.add(new Account(
                    name = 'ApexTestCasesPartner1',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.PartnerAccountRecType
        ));
         acct.add(new Account(
                    name = 'ApexTestCasesPartner2',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312'
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner32',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312'
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner322',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='https://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312'
        ));
        
        insert acct;
        
         optylst.add(new Opportunity(
                    name = 'optyTestone',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[2].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTesttwo',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[3].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTestthree',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[4].id
        ));
        
        Test.starttest();
        
        insert optylst;
        
        Campaign campaignObj = new Campaign();
                campaignObj.Name = 'My Test Campaign';
                campaignObj.Lead_Assignment_Product__c = 'VMware';
                campaignObj.Product_Lead_Filter__c = 'VMware';
                campaignObj.Geo__c = 'AMER';
                campaignObj.Type = 'MKTG Direct Mail';
                campaignObj.IsActive = true;
                campaignObj.Status = 'In Progress';
                campaignObj.StartDate = System.today()-1;
                campaignObj.EndDate = System.today()+30;
                campaignObj.Led_By__c = 'VMware-Led';
                campaignObj.Period__c = '11Q4';
                campaignObj.Major_Initiatives__c = 'Regional Campaign';
                campaignObj.Campaign_Driver__c ='Sales';
                campaignObj.Business_Outcome__c = 'Security';
                campaignObj.Call_To_Action__c = 'Blog';
                campaignObj.IT_Outcomes__c='Business Mobility';
                campaignObj.Supporting_Products__c = 'ACE';
                campaignObj.Solution_Focus__c = 'Management';
                campaignObj.Solutions_for_IT_Outcomes__c ='Hybrid Cloud';
                campaignObj.Target_Audience__c='Practitioner';
                campaignObj.Theme__c = 'Business Mobility';
                insert campaignObj;
                string s = (string)campaignObj.id;
        
           List<Lead> leadList=new List<Lead>(); 
          
          System.runas(usr1[0])
          {
              leadList.add(new Lead(Company='Test1',LastName='Lead1',Email ='test1@tdt.com',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getuserid(),
              Partner_Account__c=acct[0].id,Products__c='ADV',Previous__c='ADV',Product_Group_Interest__c='Management',Secondary_Product_Group_Interest_Before__c='COMPUTE',Executive_Engagement__c=false, Is_Specialist_ISR_owner__c = true,Partner_ID_1__c=acct[1].Partner_ID__c,Campaign_id__c = s));
              
              
              leadList.add(new Lead(Company='Test2',LastName='Lead2',Email ='test2@tdt.com',Status='1 Marketing Qualified',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getUserid(),Campaign_id__c = s));
              
              leadList.add(new Lead(Company='ApexTestCasesPartner2',LastName='Lead3',Email ='test4@tdt.com',Status='0 New',State_Province__c='CA',Country__c='United States',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getuserid(),UUID__c='1-Test',
              Partner_Account__c=acct[0].id,Products__c='ADV',Duns__c='22312',Previous__c='ADV',Product_Group_Interest__c='Management',Secondary_Product_Group_Interest_Before__c='COMPUTE',Executive_Engagement__c=false,Campaign_id__c = s));  
             
              leadList.add(new Lead(Company='ApexTestCasesPartner2',Duns__c='22312',LastName='Lead4',Email ='test5@tdt.com',Status='1 Marketing Qualified',Country__c='United States',State_Province__c='CA',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getUserid(),Campaign_id__c = s));
               
                
              insert leadList;
              
             
              leadList[1].Partner_Account__c= acct[1].id;
              update leadList[1];

               
              
              
             Test.stopTest(); 
             
             CampaignMember CM = new Campaignmember(Response_Date__c = system.today(), leadid= leadList[3].id,CampaignId= campaignObj.id);
              insert CM;
              
              
              
             LeadManagement.populateLeadScreeningOnCampaignMember();
             Lead_Reassignment_Rule__c lRR=new Lead_Reassignment_Rule__c(
                                     of_days_rejected__c=1,Closed_Reason__c='0 Partner',
                                     Distribution_Date__c=System.today(),GEO__c='EMEA',Lead_Owner__c=usr1[0].id,
                                     Number_Of_Days__c=1,New_Campaign_Response__c=true,Previous_Lead_Status__c='0 New',
                                     Primary_Product_Group_Interest_After__c='SUITES',Primary_Product_Group_Interest_Before__c='ENTERPRISE DESKTOP',
                                     Response_Date__c=System.today(),Screening_Result__c='Tele-Qualified',
                                     Secondary_Product_Group_Interest_After__c='SERVICES',Secondary_Product_Group_Interest_Before__c='SERVICES',
                                     Last_Lead_Source__c='MKTG Direct Mail',Status__c='1 In Progress',User_is__c=false,Active__c=true
                                         );
                 insert lRR;
         
            
            leadList[0].Status='1 In Progress';
            leadList[0].Date_When_Status_New__c=System.today();
            leadList[0].Pass_to_Sales_Date__c=System.today() +3;
            leadList[0].Screening_Results__c='Passed - Existing Opportunity';
            leadList[0].Primary_Product_Group_Interest__c='EMERGING SOLUTIONS';
           // List<Campaign> cm=[Select Id,Name from Campaign limit 1];
           
           
                
        
            if(campaignObj!=null)
            {
                leadList[0].Last_Campaign_Response_ID__c=campaignObj.id;
                leadList[0].Last_Campaign_Response__c=campaignObj.name;
            }
                if(!acct.isempty())
                {
                    leadList[0].Partner_Account__c=acct[1].id;
                    leadList[0].Partner_ID_1__c=acct[1].Partner_ID__c;
                    
                }
                leadList[0].Executive_Engagement__c=true;
                leadList[0].Marketing_Comments__c='TestMarket';
                leadList[0].Screening_Comments__c='TestScreen';
                leadList[0].Partner_Comments__c='TestPartner';
                leadList[0].Time_In_New_Status_Hours__c=null;
            update leadList[0];
            
            Boolean Returnvalue= LEadManagement.checkPicklistval('Test1','Test2;Test4');
            String Returnvalue1= LeadManagement.removeDuplicateValues('Test1;Test2');
            Boolean Returnvalue2=LeadManagement.matchMultiSelectFields('Test1;Test2','Test3;Test4');
            LeadManagement.calculateLeadAge(leadList);
            LeadManagement.updateExistingOpportunityFlagForEloqua(leadList); // Added by Vijit for CR-00135033
          }
         
          
    }
    static testMethod void testMethodtocoverLeadManagement1(){
                 
        Profile_Name_Mapping__c adminprofile = CustomSettingUtility.getProfileNameMapping('LDR'); 
        
         Profile_Name_Mapping__c usrprofile = CustomSettingUtility.getProfileNameMapping('Partner Rep Basic-Leads');  
                
        List<User> usr1 = new List<User>();
          
             usr1.add( new User(alias = 'neser1', email='newus23@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testi23g', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = adminprofile.Profile_Id__c, 
            timezonesidkey='America/Los_Angeles',division = 'AMER', username='newu3er@inforte.com.vmw'));

          insert usr1;          
        
            List<Account> acct=new List<Account>();
            List<Opportunity> optylst= new List<Opportunity>();
        
        
         acct.add(new Account(
                    name = 'ApexTestCasesPartner',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.PartnerAccountRecType                    
        ));
        acct.add(new Account(
                    name = 'ApexTestCasesPartner1',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.PartnerAccountRecType
        ));
         acct.add(new Account(
                    name = 'ApexTestCasesPartner2',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312'
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner32',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312'
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner322',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='https://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312', Account_Status__c = 'Active' 
        )); //Added by Vijit for CR-00135033
        
        insert acct;
        
         optylst.add(new Opportunity(
                    name = 'optyTestone',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[2].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTesttwo',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[3].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTestthree',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[4].id
        ));
        
        Test.starttest(); 
        insert optylst;
        
        Campaign campaignObj = new Campaign();
                campaignObj.Name = 'My Test Campaign';
                campaignObj.Lead_Assignment_Product__c = 'VMware';
                campaignObj.Product_Lead_Filter__c = 'VMware';
                campaignObj.Geo__c = 'AMER';
                campaignObj.Type = 'MKTG Direct Mail';
                campaignObj.IsActive = true;
                campaignObj.Status = 'In Progress';
                campaignObj.StartDate = System.today()-1;
                campaignObj.EndDate = System.today()+30;
                campaignObj.Led_By__c = 'VMware-Led';
                campaignObj.Period__c = '11Q4';
                campaignObj.Major_Initiatives__c = 'Regional Campaign';
                campaignObj.Campaign_Driver__c ='Sales';
                campaignObj.Business_Outcome__c = 'Security';
                campaignObj.Call_To_Action__c = 'Blog';
                campaignObj.IT_Outcomes__c='Business Mobility';
                campaignObj.Supporting_Products__c = 'ACE';
                campaignObj.Solution_Focus__c = 'Management';
                campaignObj.Solutions_for_IT_Outcomes__c ='Hybrid Cloud';
                campaignObj.Target_Audience__c='Practitioner';
                campaignObj.Theme__c = 'Business Mobility';
                insert campaignObj;
        
           List<Lead> leadList=new List<Lead>(); 
          
          //Updated below by Vijit for CR-00135033
      System.runas(usr1[0])
          {
              leadList.add(new Lead(Company='Test1',LastName='Lead1',Email ='test1@tdt.com',Status='0 New',Country='United States',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getuserid(),
              Partner_Account__c=acct[0].id,Products__c='ADV',Previous__c='ADV',Product_Group_Interest__c='Management',Secondary_Product_Group_Interest_Before__c='COMPUTE',Executive_Engagement__c=false, Is_Specialist_ISR_owner__c = true));
              
              
              leadList.add(new Lead(Company='Test2',Account_Id__c= acct[0].id ,LastName='Lead2',Email ='test2@tdt.com',Status='1 Marketing Qualified',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getUserid()));
              
              leadList.add(new Lead(Company='ApexTestCasesPartner2',LastName='Lead3', Email ='test4@tdt.com',Status='0 New',State_Province__c='CA',Country__c='United States',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getuserid(),
              Partner_Account__c=acct[0].id,Products__c='ADV',Duns__c='22312',Previous__c='ADV',Product_Group_Interest__c='Management',Secondary_Product_Group_Interest_Before__c='COMPUTE',Executive_Engagement__c=false));  
             
              leadList.add(new Lead(Company='ApexTestCasesPartner2',Account_Id__c = acct[0].id, Duns__c='22312',LastName='Lead4',Email ='test5@tdt.com',Status='1 Marketing Qualified',Country__c='United States',State_Province__c='CA',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getUserid()));
               
              
              insert leadList;
              
              
              
              leadList[1].Partner_Account__c= acct[1].id;
              update leadList[1];

             
              
             Test.stopTest();   
              
             
             CampaignMember CM = new Campaignmember(Response_Date__c = system.today(), leadid= leadList[3].id,CampaignId= campaignObj.id);
              insert CM;
              
             
              
             LeadManagement.populateLeadScreeningOnCampaignMember();
             Lead_Reassignment_Rule__c lRR=new Lead_Reassignment_Rule__c(
                                     of_days_rejected__c=1,Closed_Reason__c='0 Partner',
                                     Distribution_Date__c=System.today(),GEO__c='EMEA',Lead_Owner__c=usr1[0].id,
                                     Number_Of_Days__c=1,New_Campaign_Response__c=true,Previous_Lead_Status__c='0 New',
                                     Primary_Product_Group_Interest_After__c='SUITES',Primary_Product_Group_Interest_Before__c='ENTERPRISE DESKTOP',
                                     Response_Date__c=System.today(),Screening_Result__c='Tele-Qualified',
                                     Secondary_Product_Group_Interest_After__c='SERVICES',Secondary_Product_Group_Interest_Before__c='SERVICES',
                                     Last_Lead_Source__c='MKTG Direct Mail',Status__c='1 In Progress',User_is__c=false,Active__c=true
                                         );
                 insert lRR;
         
            
            leadList[0].Status='1 In Progress';
            leadList[0].Date_When_Status_New__c=System.today();
            leadList[0].Pass_to_Sales_Date__c=System.today() +3;
            leadList[0].Screening_Results__c='Tele-Qualified';
            leadList[0].Primary_Product_Group_Interest__c='EMERGING SOLUTIONS';
           // List<Campaign> cm=[Select Id,Name from Campaign limit 1];
           
           
                
        
            if(campaignObj!=null)
            {
                leadList[0].Last_Campaign_Response_ID__c=campaignObj.id;
                leadList[0].Last_Campaign_Response__c=campaignObj.name;
            }
                if(!acct.isempty())
                {
                    leadList[0].Partner_Account__c=acct[1].id;
                    leadList[0].Partner_ID_1__c=acct[1].Partner_ID__c;
                    
                }
                leadList[0].Executive_Engagement__c=true;
                leadList[0].Marketing_Comments__c='TestMarket';
                leadList[0].Screening_Comments__c='TestScreen';
                leadList[0].Partner_Comments__c='TestPartner';
                leadList[0].Time_In_New_Status_Hours__c=null;
            update leadList[0];
            
            Boolean Returnvalue= LEadManagement.checkPicklistval('Test1','Test2;Test4');
            String Returnvalue1= LeadManagement.removeDuplicateValues('Test1;Test2');
            Boolean Returnvalue2=LeadManagement.matchMultiSelectFields('Test1;Test2','Test3;Test4');
            LeadManagement.calculateLeadAge(leadList);
            LeadManagement.updateExistingOpportunityFlagForEloqua(leadList); //Added by Vijit for CR-00135033
          }
          
          
    }
    //Added by Vijit for CR-00135033 - START
    static testMethod void testMethodtocoverLeadManagement2(){
        Profile_Name_Mapping__c adminprofile = CustomSettingUtility.getProfileNameMapping('LDR'); 
        
         Profile_Name_Mapping__c usrprofile = CustomSettingUtility.getProfileNameMapping('Partner Rep Basic-Leads');  
                
        List<User> usr1 = new List<User>();
          
             usr1.add( new User(alias = 'neser1', email='newus23@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testi23g', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = adminprofile.Profile_Id__c, 
            timezonesidkey='America/Los_Angeles',division = 'AMER', username='newu3er@inforte.com.vmw'));

          insert usr1;          
        
            List<Account> acct=new List<Account>();
            List<Opportunity> optylst= new List<Opportunity>();
        
        
         acct.add(new Account(
                    name = 'ApexTestCasesPartner',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.PartnerAccountRecType                    
        ));
        acct.add(new Account(
                    name = 'ApexTestCasesPartner1',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.PartnerAccountRecType
        ));
         acct.add(new Account(
                    name = 'ApexTestCasesPartner2',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312'
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner32',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312'
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner322',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='https://www.tdt.com',
                    UUID__c='1-Test',
                    Duns__c='22312', Account_Status__c = 'Active' 
        ));
        
        insert acct;
        
         optylst.add(new Opportunity(
                    name = 'optyTestone',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[2].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTesttwo',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[3].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTestthree',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[4].id
        ));
        
        
        insert optylst;
        
        Campaign campaignObj = new Campaign();
                campaignObj.Name = 'My Test Campaign';
                campaignObj.Lead_Assignment_Product__c = 'VMware';
                campaignObj.Product_Lead_Filter__c = 'VMware';
                campaignObj.Geo__c = 'AMER';
                campaignObj.Type = 'MKTG Direct Mail';
                campaignObj.IsActive = true;
                campaignObj.Status = 'In Progress';
                campaignObj.StartDate = System.today()-1;
                campaignObj.EndDate = System.today()+30;
                campaignObj.Led_By__c = 'VMware-Led';
                campaignObj.Period__c = '11Q4';
                campaignObj.Major_Initiatives__c = 'Regional Campaign';
                campaignObj.Campaign_Driver__c ='Sales';
                campaignObj.Business_Outcome__c = 'Security';
                campaignObj.Call_To_Action__c = 'Blog';
                campaignObj.IT_Outcomes__c='Business Mobility';
                campaignObj.Supporting_Products__c = 'ACE';
                campaignObj.Solution_Focus__c = 'Management';
                campaignObj.Solutions_for_IT_Outcomes__c ='Hybrid Cloud';
                campaignObj.Target_Audience__c='Practitioner';
                campaignObj.Theme__c = 'Business Mobility';
                insert campaignObj;
        
           List<Lead> leadList=new List<Lead>(); 
          
          System.runas(usr1[0])
          {
              leadList.add(new Lead(Company='Test1',LastName='Lead1',Email ='test1@tdt.com',Status='0 New',Country='United States',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getuserid(),
              Partner_Account__c=acct[0].id,Products__c='ADV',Previous__c='ADV',Product_Group_Interest__c='Management',Secondary_Product_Group_Interest_Before__c='COMPUTE',Executive_Engagement__c=false, Is_Specialist_ISR_owner__c = true));
              
              
              leadList.add(new Lead(Company='Test2',Account_Id__c= acct[0].id ,LastName='Lead2',Email ='test2@tdt.com',Status='1 Marketing Qualified',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getUserid()));
              
              leadList.add(new Lead(Company='ApexTestCasesPartner2',LastName='Lead3', Email ='test4@tdt.com',Status='0 New',State_Province__c='CA',Country__c='United States',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getuserid(),
              Partner_Account__c=acct[0].id,Products__c='ADV',Previous__c='ADV',Product_Group_Interest__c='Management',Secondary_Product_Group_Interest_Before__c='COMPUTE',Executive_Engagement__c=false));  
             
              leadList.add(new Lead(Company='ApexTestCasesPartner2',Account_Id__c = acct[0].id,LastName='Lead4',Email ='test5@tdt.com',Status='1 Marketing Qualified',Country__c='United States',State_Province__c='CA',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',LDR__c=Userinfo.getUserid()));
               
                
              insert leadList;              
              leadList[1].Partner_Account__c= acct[1].id;
              
              Test.starttest();
              update leadList[1];


              
              
              
             
             CampaignMember CM = new Campaignmember(Response_Date__c = system.today(), leadid= leadList[3].id,CampaignId= campaignObj.id);
              insert CM;
             LeadManagement.populateLeadScreeningOnCampaignMember();
             Lead_Reassignment_Rule__c lRR=new Lead_Reassignment_Rule__c(
                                     of_days_rejected__c=1,Closed_Reason__c='0 Partner',
                                     Distribution_Date__c=System.today(),GEO__c='EMEA',Lead_Owner__c=usr1[0].id,
                                     Number_Of_Days__c=1,New_Campaign_Response__c=true,Previous_Lead_Status__c='0 New',
                                     Primary_Product_Group_Interest_After__c='SUITES',Primary_Product_Group_Interest_Before__c='ENTERPRISE DESKTOP',
                                     Response_Date__c=System.today(),Screening_Result__c='Tele-Qualified',
                                     Secondary_Product_Group_Interest_After__c='SERVICES',Secondary_Product_Group_Interest_Before__c='SERVICES',
                                     Last_Lead_Source__c='MKTG Direct Mail',Status__c='1 In Progress',User_is__c=false,Active__c=true
                                         );
                 insert lRR;
                 
            
            
            leadList[0].Status='1 In Progress';
            leadList[0].Date_When_Status_New__c=System.today();
            leadList[0].Pass_to_Sales_Date__c=System.today() +3;
            leadList[0].Screening_Results__c='Tele-Qualified';
            leadList[0].Primary_Product_Group_Interest__c='EMERGING SOLUTIONS';
           // List<Campaign> cm=[Select Id,Name from Campaign limit 1];
           
           
                
        
            if(campaignObj!=null)
            {
                leadList[0].Last_Campaign_Response_ID__c=campaignObj.id;
                leadList[0].Last_Campaign_Response__c=campaignObj.name;
            }
                if(!acct.isempty())
                {
                    leadList[0].Partner_Account__c=acct[1].id;
                    leadList[0].Partner_ID_1__c=acct[1].Partner_ID__c;
                    
                }
                leadList[0].Executive_Engagement__c=true;
                leadList[0].Marketing_Comments__c='TestMarket';
                leadList[0].Screening_Comments__c='TestScreen';
                leadList[0].Partner_Comments__c='TestPartner';
                leadList[0].Time_In_New_Status_Hours__c=null;
            update leadList[0];
            
            Boolean Returnvalue= LEadManagement.checkPicklistval('Test1','Test2;Test4');
            String Returnvalue1= LeadManagement.removeDuplicateValues('Test1;Test2');
            Boolean Returnvalue2=LeadManagement.matchMultiSelectFields('Test1;Test2','Test3;Test4');            
            LeadManagement.updateExistingOpportunityFlagForEloqua(leadList);
          }
          Test.stopTest();
          
    }
   //Added by Vijit for CR-00135033 - END
   public static  testmethod void LeadmanagmentcoverAW(){
     
      Profile pf = [Select Id from Profile where Name = 'System Administrator'];
             list<user> userList11 = new list<user>();
             userList11.add(new User(alias = 'standt', email='standardldruser@testorg.com',
                                    emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = pf.id,
                                    timezonesidkey='America/Los_Angeles', username='ldrUser@testorg.com',Division = 'AMER'
                                    ,IsDataMigrationUser__c =true));
                                    
            insert  userList11 ;
            
            test.starttest();           
             System.runAs(userList11[0]){
             list<VMWare_Territory__c> territoryList = new list<VMWare_Territory__c>();
             
             territoryList.add(new VMWare_Territory__c(Name = 'TestTerritory1',LDR__c = userList11[0].Id,EM_ISR_IAR__c = userList11[0].Id,EM_LDR__c = userList11[0].Id,EM_Rep__c = userList11[0].Id,iPBM__c = userList11[0].Id,ISR_IAR__c = userList11[0].Id,Edu_Rep__c = userList11[0].Id,SSM__c = userList11[0].Id,PBM__c = userList11[0].Id,Rep__c = userList11[0].Id,Spring_ISR_IAR__c = userList11[0].Id,Spring_LDR__c = userList11[0].Id,AW_AE_PSR__c = userList11[0].Id,Spring_Rep__c = userList11[0].Id,SSROMRinLatAM__c = userList11[0].Id ));        
                //1
             territoryList.add(new VMWare_Territory__c(Name = 'TestTerritory2',LDR__c = userList11[0].Id,EM_ISR_IAR__c = userList11[0].Id,EM_LDR__c = userList11[0].Id,EM_Rep__c = userList11[0].Id,iPBM__c = userList11[0].Id,ISR_IAR__c = userList11[0].Id,Edu_Rep__c = userList11[0].Id,SSM__c = userList11[0].Id,PBM__c = userList11[0].Id,Rep__c = userList11[0].Id,Spring_ISR_IAR__c = userList11[0].Id,Spring_LDR__c = userList11[0].Id,AW_AE_PSR__c = userList11[0].Id,Spring_Rep__c = userList11[0].Id,SSROMRinLatAM__c = userList11[0].Id ));   
                //2
             insert territoryList;
             
        list<Account> acct= new list<Account>();
       acct.add(new Account(
                    name = 'ApexTestCasesPartner',
                    Geo__c = 'AMER',
                    Region__c = 'North', 
                    RecordTypeId= recursive.CustomerAccountRecType,
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,      
                    UUID__c = '1-8964Y',
                    Website = 'www.abcd.com',
                    DUNS__c = '1906329906'                    
        ));
        acct.add(new Account(
                    name = 'ApexTestCasesPartner1',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,                    
                    UUID__c = '1-8964Y',
                    Website = 'abcd',
                    DUNS__c = '1906329906',Account_Status__c = 'Active'
        ));
         acct.add(new Account(
                    name = 'ApexTestCasesPartner2',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-8964Y',
                    Duns__c='1906329906',Account_Status__c = 'Active'
                   
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner32',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='http://www.tdt.com',
                    UUID__c='1-8964Y',
                    Duns__c='1906329906',Account_Status__c = 'Active'
        ));
        
        acct.add(new Account(
                    name = 'ApexTestCasesPartner322',
                    Geo__c = 'AMER',
                    Region__c = 'North',    
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,
                    RecordTypeId= recursive.CustomerAccountRecType,
                    website='www.abcd.com',
                    UUID__c='1-8964Y',
                    Duns__c='1906329906', Account_Status__c = 'Active' 
        ));
        
        insert acct;
        list<Opportunity> optylst= new list<Opportunity>();
         optylst.add(new Opportunity(
                    name = 'optyTestone',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[2].id
        ));
        
         optylst.add(new Opportunity(
                    name = 'optyaTestone',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[1].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTesttwo',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[3].id
        ));
        
        optylst.add(new Opportunity(
                    name = 'optyTestthree',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[4].id
        ));
        
        
        insert optylst;
        
        List<Contact> cntList = new List<Contact>();
            
            Contact cont1 = new Contact(lastname = 'testContact1',email = 'pabitra2@test.com',recordtypeid=recursive.ConsultingContactRecType);
            cntList.add(cont1);
             
            Contact cont2 = new Contact(lastname = 'testContact2',email = 'pabitra1@test.com',recordtypeid=recursive.ConsultingContactRecType);
            cntList.add(cont2);
            
            insert cntList;
        
       //Insert Leads
       List<Lead> leadList=new List<Lead>(); 
       leadList.add(new Lead(Company='Test1',LastName='Lead1',Status='0 New',Country='HUNGARY',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',Lead_Source_Most_Recent__c = 'Verizon',AW_Country__c = 'United States',AW_Lead_Source_Category__c='Free Trial/Contact Us',Country__c =  'United States',Primary_Field_Sales_Territory__c = territoryList[0].Id,UUID__c = '1-8964Y',DUNS__c = '1906329906',email='abcd@accenture.com'));
       
       leadList.add(new Lead(Company='Test2',LastName='Lead2',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',Lead_Source_Most_Recent__c = 'Verizon',AW_Country__c = 'United States',Country__c =  'United States',UUID__c = '1-8964Y',DUNS__c = '1906329906',email='abcd@accenture.com'));
       
       leadList.add(new Lead(Company='Test3',LastName='Lead2',Status='0 New',Country='HUNGARY',Geo__c='AMER',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',Lead_Source_Most_Recent__c = 'Verizon',AW_Country__c = 'United States',Country__c = 'United States',UUID__c = '1-8964Y',DUNS__c = '1906329906',email='tdt@accy.com'));
       
       leadList.add(new Lead(Company='Test4',LastName='Lead2',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',Lead_Source_Most_Recent__c = 'Verizon',AW_Country__c = 'United States',Country__c = 'United States',UUID__c = '1-8964Y',DUNS__c = '1906329906',email='abcd@accenture.com'));
       
       Set<Id> SetLeadId = new Set<Id>();
       insert leadList;
       for(lead l :leadList ){
       
        SetLeadId.add(l.id);
       }
       LeadManagement.UpdateConAccAFterLeadConversion(SetLeadId);
       //String str=leadList[0].id+','+leadList[1].id;   
       
       leadList[0].Primary_Field_Sales_Territory__c = territoryList[1].id;
       update leadList;
       
       
       LeadManagement.updateExistingOpportunityFlagForEloqua(leadList);
             }
             
     Test.stopTest();
   }
    public static  testmethod void LeadmanagmentcoverAW1(){
    
    
     list<Account> acct= new list<Account>();
       acct.add(new Account(
                    name = 'ApexTestCasesPartner',
                    Geo__c = 'AMER',
                    Region__c = 'North', 
                    RecordTypeId= recursive.CustomerAccountRecType ,
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,      
                    UUID__c = '1-8964Y',
                    Website = 'www.abcd.com',
                    DUNS__c = '1906329906'));                    
       
       acct.add(new Account(
                    name = 'ApexTestCasesPartner11',
                    Geo__c = 'AMER',
                    Region__c = 'North', 
                    RecordTypeId= recursive.CustomerAccountRecType ,
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,      
                    UUID__c = '1-8964Y',
                    Website = 'www.abcd.com',
                    DUNS__c = '1906329906')); 
                    
      acct.add(new Account(
                    name = 'ApexTestCasesPartner112',
                    Geo__c = 'AMER',
                    Region__c = 'North', 
                    RecordTypeId= recursive.CustomerAccountRecType ,
                    Country__c = 'United States',
                    country_type__c = 'Developed' ,      
                    UUID__c = '1-8964Y',
                    Website = 'www.abcd.com',
                    DUNS__c = '1906329906'));                   
       
        
        insert acct;
        //system.debug('!@#!#!@!@#!@!!acct'+acct.RecordTypeId);
        
        list<Opportunity> optylst= new list<Opportunity>();
         optylst.add(new Opportunity(
                    name = 'optyTestone',
                    recordtypeid=recursive.ManagedSalesOpportunityRecType ,
                    Stagename='02 - Qualified',
                    
                    CloseDate=System.today()+1 ,
                    accountid=acct[0].id
        ));
        
         
        
        
        insert optylst;
        system.debug('!@#!#!@!@#!@!!recursive.CustomerContactRecType'+recursive.CustomerContactRecType);
    
    List<Contact> cntList = new List<Contact>();
            
            Contact cont1 = new Contact(lastname = 'testContact1',email = 'pabitra2@test.com',Accountid = acct[0].id ,recordtypeid=recursive.CustomerContactRecType );
            cntList.add(cont1);
             
            Contact cont2 = new Contact(lastname = 'testContact2',email = 'pabitra1@test.com',Accountid = acct[0].id,recordtypeid=recursive.CustomerContactRecType );
            cntList.add(cont2);
            
            insert cntList;
    system.debug('!@#!#!@!@#!@!!cont1'+cont1.RecordTypeId);
    system.debug('!@#!#!@!@#!@!!cont2'+cont2.RecordTypeId);
    
    
    List<Lead> leadList=new List<Lead>(); 
    
    leadList.add(new Lead(Company='Test5',LastName='Lead2',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',AW_Country__c = 'United States',Record_Source__c ='Hybrid',Country__c = 'United States',UUID__c = '1-8964Y',DUNS__c = '1906329906',email='abcd@accenture.com',isConverted =true,ConvertedContactId= cntList[0].id ,ConvertedAccountId = acct[0].id ,ConvertedOpportunityId = optylst[0].id ,Previous_Record_Source__c = 'VMW Eloqua',AW_Lead_Source_Category__c = 'Generic',Lead_Owner_Profile__c='test',Partner_Account__c = acct[1].id ,AW_Lead_Source__c = 'REFERRAL – APPLE', Lead_Source_Most_Recent__c = 'AW Contact Us Form',LeadSource = 'MKTG Direct Mail'));
    
    leadList.add(new Lead(Company='Test5',LastName='Lead2',Status='0 New',Country='HUNGARY',Geo__c='EMEA',Lead_Assignment_Product__c='vFabric',Pre_qualified__c='Yes',AW_Country__c = 'United States',Record_Source__c ='Hybrid',Country__c = 'United States',UUID__c = '1-8964Y',DUNS__c = '1906329906',email='abcd@accenture.com',Partner_Account__c = acct[1].id, Lead_Source_Most_Recent__c = 'AW Contact Us Form',LeadSource = 'MKTG Direct Mail',Lead_Owner_Profile__c = 'test',Execute_Ownership_Realignment__c = true,Previous_Record_Source__c = 'VMWEloqua',AW_Lead_Source_Category__c = 'Generic'));
       Set<Id> SetLeadId = new Set<Id>();
       insert leadList;
       leadList[1].Partner_Account__c = acct[2].id;
       leadList[1].Execute_Ownership_Realignment__c = false;
       update leadList;
       for(lead l :leadList ){
       
        SetLeadId.add(l.id);
       }
       LeadManagement.UpdateConAccAFterLeadConversion(SetLeadId);
    
    
    }
}