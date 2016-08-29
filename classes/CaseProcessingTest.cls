//*************************************************************************************
// Name             : CaseProcessingTest
// Description      : Class to increase test coverage of "CaseProcessing"
// Created By       : Nilanjana Mukherjee
// Created Date     : 06/22/2015
// TestCoverage     : 79%
// ************************************************************************************
@isTest(seealldata=true)
private class CaseProcessingTest
{ 
    public static Case testCase1,testCase2,testCase3,testCase4,testCase5;
    public static CaseHistory testCasehistory1;
    public static BB_8_SLA_integration_fields__c SlaInt;
    public static GSS_Premier_Entitlement__c PreEnt1;
    public static User u,u1,u2;
    public static List<AccountTeamMember> accTeamMembers;
    public static List<Account> listAccounts;
    public static Account testAccount0,testAccount;
    public static Task Task2; 
    public static List<Contact> listContacts;
    public static Contact testContact,testContact0;  
    public static Record_Type_Settings__c oRTSACC = Record_Type_Settings__c.getInstance('GSS_ACC_EC');
    public static Record_Type_Settings__c oRTSCON = Record_Type_Settings__c.getInstance('GSS_CON_CC');
    public static Id Case_PN_RecordType=Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Case_PN').Record_Type_ID__c);
    public static Id Case_PN_RecordType1 = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_SDP_FED').Record_Type_ID__c);
    public static string Task_sendAlert_RecordType=Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Task_SendAlert').Record_Type_ID__c);
    public static String Ivradmin =GSS_Configuration_Properties_list__c.getInstance('IVR_ADMIN').setting_value__c ;
    public Static Id caseAdminId = Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('CaseAdmin').setting_value__c); 
    public Static Id SiteUser = Id.ValueOf(GSS_Configuration_Properties_list__c.getInstance('SiteUser').setting_value__c);
    public static datetime dt = datetime.now();
    public static datetime newdate =dt.addSeconds(+5);
    public static String rct =Record_Type_Settings__c.getValues('RCM_Case_Renewal_Operations').Record_Type_ID__c;
    public static Id carpathiaRecType = Id.valueof(Record_Type_Settings__c.getInstance('GSS_CASE_SDP_FED').Record_Type_ID__c); 
    public static Id myVmwareRTITSup = Id.valueOf(Record_Type_Settings__c.getInstance('ITAppsSupport').Record_Type_ID__c);
    public static Id myVmwareRTCommon=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_MyVmwareCommonCase').Record_Type_ID__c);
    public static Id techSupport = Id.valueOf(Record_Type_Settings__c.getValues('GSS_CASE_TS').Record_Type_ID__c);
    public static Id recTypeIdCase=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_LIC').Record_Type_ID__c);
    public static Id recTypeIdCase2=Id.valueOf(Record_Type_Settings__c.getInstance('SubscriptionServices').Record_Type_ID__c);
    public static Id vceRecdTyp = Id.valueOf(Record_Type_Settings__c.getValues('GSS_Partner_VCE').Record_Type_ID__c);
    public static Profile_Name_Mapping__c prf = CustomSettingUtility.getProfileNameMapping('GSS System Administrator');
    public static Profile_Name_Mapping__c prf1 = CustomSettingUtility.getProfileNameMapping('Carpathia');
    public static Id prf2= Profile_Name_Mapping__c.getInstance('Profile - 150').Profile_Id__c;
    public static GSSSupportLevel__c support=GSSSupportLevel__c.getInstance('Brazil');
    public static GSS_ServiceNow_Parameters__c  gssSNParameter = GSS_ServiceNow_Parameters__c.getOrgDefaults();
    public static Carpathia_Variables__c  carpathiaAccRec = Carpathia_Variables__c.getInstance('Carpathia Account');      
    public static Carpathia_Variables__c  carpathiaConRec = Carpathia_Variables__c.getInstance('Carpathia Contact');    
    public static Id pro;
    public static Id pro1;
    public static Id pro2;
    public static string sup;
    public static string sup1;
    public static string cId;
    public static Id SalesOpsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Ops').getRecordTypeId();
 
    public static void setupdata()
    {   
        if(HistoryTrackingSetting__c.getInstance('Case-Owner') == null){
            List<HistoryTrackingSetting__c> historyList = new List<HistoryTrackingSetting__c>();
            historyList.add(new HistoryTrackingSetting__c(Name = 'Case-Owner',ApiFieldName__c = 'OwnerId',DataType__c = 'Lookup',FieldLabel__c = 'Owner',Object__c = 'Case'));
            insert historyList;
        }
        pro=Id.ValueOf(prf.Profile_Id__c);
        pro1= Id.ValueOf(prf1.Profile_Id__c);         
        sup=String.valueOf(support.Country__c);
        sup1=String.valueOf(support.Support_Level__c);
        Id roleId = [select Id from UserRole where PortalType = 'Partner' LIMIT 1].Id;

         u = new User(Alias = 'alias',email='standarduser@testorg.com',emailencodingkey='UTF-8',Username = 'someuser@somedomain.com',
                Lastname = 'somelastname',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname',
                profileid =pro, country='United States', Division = 'APAC');
         insert(u);

        listAccounts = new List<Account>();
        testAccount = new Account();
        testAccount.Name = 'Test Account1';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.RecordTypeId=oRTSACC.record_type_id__c;
        testAccount.GSS_S1_Red_Alert_Notifications__c = true;
        testAccount.OwnerId = u.Id;
        listAccounts.add(testAccount);

        testAccount0 = new Account();
        testAccount0.Name = 'Test Account';        
        testAccount0.Country__c = 'INDIA';
        testAccount0.Type='Public Sector';
        testAccount.RecordTypeId=oRTSACC.record_type_id__c;
        testAccount0.GSS_S1_Red_Alert_Notifications__c = true;
        testAccount0.OwnerId = u.Id;
        listAccounts.add(testAccount0);       

        insert listAccounts;

        listContacts = new List<Contact>();
        testContact = new Contact();
        testContact.LastName= 'Test Contact1';        
        testContact.Email= 'Test@gmail.com';
        testContact.Phone='0000000';
        testContact.AccountId=listAccounts[0].Id;
        testContact.RecordTypeId=oRTSCON.record_type_id__c;
        listContacts.add(testContact);

        testContact0 = new Contact();
        testContact0.LastName= 'Test Contact1';        
        testContact0.Email= 'Test@gmail.com';
        testContact0.Phone='0000000';
        testContact0.AccountId=listAccounts[0].Id;
        testContact0.RecordTypeId=oRTSCON.record_type_id__c;
        listContacts.add(testContact0);

        insert listContacts;

          System.runAs(u)
         {
         
                u1 = new User(Alias = 'alias',email='standarduser@testorg.com',emailencodingkey='UTF-8',Username = 'someuser@somedomain.com',
                Lastname = 'somelastname',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname',
                profileid=pro1 , country='United States',ContactId=listContacts[0].Id);
                u1.userRoleId = roleId;
             
         } 
          
        u.GSS_Manager__c = u1.Id;         
        update u;

     if(OnOffSwitch__c.getInstance('GTMOpsCoE') == null){
            List<OnOffSwitch__c> GtmSwitch = new List<OnOffSwitch__c>();
            GtmSwitch.add(new OnOffSwitch__c(Name = 'GTMOpsCoE',Active__c=True));
            insert GtmSwitch;
        }
    }
    static testMethod void  updateCaseAdditionalEmailstest ()
    {
        setUpData();

        Test.startTest();  

        List<Case> listCase = new List<Case>();
        testCase1 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',GSS_ScreenPopTime__c=newdate ,
                             GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='Escalated',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[1].Id,RecordTypeId = recTypeIdCase2);
        listCase.add(testCase1);

        insert listCase;
         


        Test.stopTest();

    }
    public static testMethod void  BI_ClassifyCasesByRecordTypetest()
    {
        setUpData();

        Test.startTest();  

        List<Case> listCase = new List<Case>();

         testCase2 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                             GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Active',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('PSO').getRecordTypeId());
        listCase.add(testCase2); 

        insert listCase;
        Test.stopTest();
    }

    public static testMethod void  BI_ClassifyCasesByRecordTypetest1()
    {
        setUpData();

        Test.startTest();  

        List<Case> listCase = new List<Case>();


        testCase5 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                             GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing5', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Active',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTITSup);
        listCase.add(testCase5);

        insert listCase;
        testCase5.status='New';

        update listCase;
         
        Test.stopTest();
    }
    
    public static testMethod void  BI_PopulateTechnicalContacttest()
    {
        setUpData();
        Test.startTest();
        GSS_USer_Data__c userData = new GSS_USer_Data__c(User__c = u.id,WorkloadPoints__c = 0,Reset_Workload_Point__c = 0,Prevent_Duplicate__c = 'test111111@test.com');
        insert userData;
        List<Case> listCase = new List<Case>();
        GSS_Config_Properties__c workload= GSS_Config_Properties__c.getOrgDefaults();
        workload.GSS_WorkLoad_points_for_Licensing_cases__c = true;
        update workload;
        testCase1 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                             GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Active',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[1].Id,RecordTypeId = recTypeIdCase2);
        listCase.add(testCase1);


        testCase2 = new Case(Origin='Phone',GSS_Preferred_Method_of_Contact__c='Phone',Priority='1 - Critical', 
                            GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Complete',
                           GSS_Country__c='Brazil', Description='Testing-PP-17997-2',ContactId = listContacts[0].Id, RecordTypeId = techSupport ,IT_Track__c='MDM',Technical_Contact_Name__c=null,Technical_Contact_Phone__c=null,Technical_Contact_Email__c=null,GSS_Preferred_Phone_Number__c='0000000' );
        listCase.add(testCase2);
        

        insert listCase;
        testCase1.Count_Comments__c=6;

        testCase1.OwnerId = u.Id;
        
        update  listCase;

        Test.stopTest();
    }
    public static testMethod void AI_ClassifyCasesByRecordTypetest()
    {
        setUpData();

        Test.startTest(); 
        GSS_USer_Data__c userData = new GSS_USer_Data__c(User__c = u.id,WorkloadPoints__c = 0,Reset_Workload_Point__c = 0,Prevent_Duplicate__c = 'test111111@test.com');
        insert userData;
        GSS_Config_Properties__c workload= GSS_Config_Properties__c.getOrgDefaults();
        workload.GSS_WorkLoad_points_for_Licensing_cases__c = true;
        update workload;
        List<Case> listCase = new List<Case>();

        testCase2 = new Case(Origin='Phone',GSS_Preferred_Method_of_Contact__c='Phone',Priority='1 - Critical', 
                        GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Complete',
                       GSS_Country__c='India', Description='Testing-PP-17997-2',ContactId = listContacts[0].Id, RecordTypeId = techSupport ,IT_Track__c='MDM',Technical_Contact_Name__c=null,Technical_Contact_Phone__c=null,Technical_Contact_Email__c=null,GSS_Preferred_Phone_Number__c='0000000' );
        listCase.add(testCase2);
        testCase3 = new Case(Origin='Phone',GSS_Preferred_Method_of_Contact__c='Phone',Priority='1 - Critical', 
                            GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Complete',
                           GSS_Country__c='Brazil', Description='Testing-PP-17997-2',ContactId = listContacts[0].Id, RecordTypeId = recTypeIdCase ,IT_Track__c='MDM',Technical_Contact_Name__c=null,Technical_Contact_Phone__c=null,Technical_Contact_Email__c=null,GSS_Preferred_Phone_Number__c='0000000',Customer_Contact_Name__c = listContacts[0].Id );
        listCase.add(testCase3);
        
        insert listCase;
        testCase3.OwnerId = u.Id;
        update  listCase;
        Test.stopTest();
        }
    public static testMethod void  AI_AcctConSyncAndAvayaFuturetest()
    {
        string flag='false';
        setUpData();
        Test.startTest(); 
        List<Case> listCase = new List<Case>();
        testCase1 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='Escalated',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                         Description='Testing-PP-17997-1',AccountId= listAccounts[1].Id,RecordTypeId = recTypeIdCase);
        listCase.add(testCase1);

        testCase4 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',               
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='Escalated',Subject ='Testing4', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTCommon);
        listCase.add(testCase4);

        testCase5 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing5', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTITSup);
        listCase.add(testCase5);

        insert listCase;       
        testCase4.Status='New';           
        update listCase;


        Test.stopTest();
    }
    public void calculateCasePhoneQtest()
    {
        setUpData();

        Test.startTest();  
        Id CSR = (Id)(Profile_Name_Mapping__c.getInstance('Profile - 150').Profile_Id__c);

        u2 = new User(Alias = 'alias',email='standarduser2@testorg.com',emailencodingkey='UTF-8',Username = 'someuser2somedomain.com',
            Lastname = 'somelastname2',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname2',
            profileid =CSR , country='United States',ContactId = listContacts[0].Id);
        insert(u2);

        List<Case> listCase = new List<Case>();


        testCase2 = new Case(Origin='Phone',GSS_Preferred_Method_of_Contact__c='Phone',Priority='1 - Critical',GSS_Center__c='Bangalore',
                        GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Complete',
                       GSS_Country__c='Brazil', Description='Testing-PP-17997-2',ContactId = listContacts[0].Id, RecordTypeId = techSupport ,IT_Track__c='MDM',Technical_Contact_Name__c=null,Technical_Contact_Phone__c=null,Technical_Contact_Email__c=null,GSS_Preferred_Phone_Number__c='0000000' );
        listCase.add(testCase2);

        testCase5 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',Actual_Response_Time__c=null,
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing5', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTITSup);
        listCase.add(testCase5);

        insert listCase;

        Test.stopTest();
    }

    public static void testDataforVceCase(){
        setupData();
        List<PRofile> profileList = [select id from Profile where Name = 'GSS Premier Services'];
         u2 = new User(Alias = 'alias',email='standarduser2@testorg.com',emailencodingkey='UTF-8',Username = 'someuser11@somedomain.com',
            Lastname = 'somelastname2',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname2',
            profileid =profileList[0].id , country='United States');
        insert(u2);
        List<Case> listCase = new List<Case>();
        testCase2 = new Case(RecordTypeId = vceRecdTyp,Origin='Phone',GSS_Preferred_Method_of_Contact__c='Phone',Priority='1 - Critical',GSS_Center__c='Bangalore',GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Complete',GSS_Country__c='Brazil', Description='Testing-PP-17997-2',IT_Track__c='MDM',Technical_Contact_Name__c=null,Technical_Contact_Phone__c=null,Technical_Contact_Email__c=null );
        listCase.add(testCase2);
        testCase5 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',Actual_Response_Time__c=null,
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing5', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = vceRecdTyp,Technical_Contact_Name__c=null,Technical_Contact_Phone__c=null,Technical_Contact_Email__c=null,VCE_Prime_Engineer_First_Name__c='testFN',VCE_Prime_Engineer_Last_Name__c = 'testLN',Customer_Contact_First_Name__c = 'testCFN',Customer_Contact_Last_Name__c = 'testCLN');
        listCase.add(testCase5);
        testCase1 = new Case(RecordTypeId = techSupport,Origin='Phone',GSS_Preferred_Method_of_Contact__c='Phone',Priority='1 - Critical',GSS_Center__c='Bangalore',GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Complete',GSS_Country__c='Brazil', Description='Testing-PP-17997-2' ,IT_Track__c='MDM',GSS_Third_Party_Contact_Name__c='test',GSS_Third_Party_Email_Phone__c='test@test.com',GSS_Third_Party_Ticket__c='0000' );
        listCase.add(testCase1);
        system.runAs(u2){
            insert listCase;
        }
        testCase1.GSS_Third_Party_Contact_Name__c = 'test1';
        system.runAs(u2){
            update testCase1;
        }
    }
    
    public static testMethod void testMethodforVceCase(){
        test.startTest();
        testDataforVceCase();
        test.stopTest();
    }
    
    public static testmethod void TA_CreateEmailTasktest1()
    {
        setUpData();
        Test.startTest();  
        List<Case> listCase = new List<Case>();
        testCase1 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='New',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='India',Count_Comments__c=3,
                         Description='Testing-PP-17997-1',AccountId= listAccounts[1].Id,RecordTypeId =Case_PN_RecordType);
        listCase.add(testCase1);
        insert listCase;
        testCase1.Status='In Progress';
        update listCase;
        Test.stopTest();  

    }
    
     public static testmethod void TA_CreateEmailTasktest2()
    {
        setUpData();
        Test.startTest();  
        List<Case> listCase = new List<Case>();
        testCase2 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='Escalated',Subject ='Testing2', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='New',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='India',Count_Comments__c=3,
                         Description='Testing-PP-17997-1',AccountId= listAccounts[1].Id,RecordTypeId =Case_PN_RecordType);
        listCase.add(testCase2);
        insert listCase;
        testCase2.Status='New';
        update listCase;
        Test.stopTest();  

    }
    
    /* public static testmethod void TA_CreateEmailTasktest3()
    {
        setUpData();
        Test.startTest();  

        List<Case> listCase = new List<Case>();
        testCase3 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing3', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='New',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='India',Count_Comments__c=3,
                         Description='Testing-PP-17997-1',AccountId= listAccounts[1].Id,RecordTypeId =Case_PN_RecordType);
        listCase.add(testCase3);
        insert listCase;
        testCase3.Status='Escalated';

        update listCase;
        Test.stopTest();  

    }*/
    
    
    
   /* public static testmethod void beforeUpdateCaseInitializationtest()
    {
        setUpdata();
        test.starttest();
             List<Case> listCase = new List<Case>();



        testCase4 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing4', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='India',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTCommon);
        listCase.add(testCase4);

        testCase5 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',Defect__c='###',Severity__c='S4',Count_Comments__c=1,
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing5', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='India',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTITSup);
        listCase.add(testCase5);

        insert listCase; 

        testCase5.Count_Comments__c=2;
        testCase5.status='In Progress';
        testCase5.Defect__c='@@@';       
        testCase4.RecordTypeId =myVmwareRTITSup;

        //update listCase;

        test.stoptest();
    }*/

    public static testmethod void updateRelatedListCounttest(){
        test.starttest();
        setUpdata();

        List<Case> listCase = new List<Case>();

        testCase1 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Active',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId=carpathiaRecType,ContactId=listContacts[0].Id);
        listCase.add(testCase1); 
        testCase4 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing4', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='India',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTCommon);
        listCase.add(testCase4);

        testCase2 = new Case(Origin='Phone',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                         GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing4', GSS_Support_Customer_Region__c ='APJ',IT_Track__c='MDM',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='India',
                         Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,RecordTypeId = myVmwareRTCommon);
        listCase.add(testCase2);
        insert listCase;
        testCase1.AccountId=listAccounts[1].Id;         
        update testCase1;


        test.stoptest();

        List<Case> oldlistCase=new List<Case>([select id,ParentId from case where ParentId!=null limit 1]);
        CaseProcessing Cp=new CaseProcessing();
        Cp.updateRelatedListCount(listCase,oldlistCase);

    }
   
    public static void setupData1(){
        
        testAccount = new Account();
        testAccount.Name = 'Test Account1';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        insert testAccount;
        
        testAccount0 = new Account();
        testAccount0.Name = 'Test Account2';        
        testAccount0.Country__c = 'CHINA';
        testAccount0.Type='Private Sector';
        testAccount0.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        insert testAccount0;
        

        testContact = new Contact();
        testContact.FirstName = 'New';
        testContact.LastName = 'Test Contact1';        
        testContact.Email = 'Test@gmail.com';
        testContact.Phone = '00323400000';
        testContact.AccountId = testAccount.Id;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        insert testContact;
        
        Entitlement  etm = new Entitlement(name = 'test etntitlement', Type = '1', AccountId= testAccount.Id, StartDate = date.newInstance(2012,05,22), EndDate = date.newInstance(2012,06,2), GSS_Entitlement_Code__c = 'IPS', GSS_Entitlement_Status__c = 'Active');
        insert etm;

        testCase1 = new Case(Origin='Email',Priority='1 - Critical',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', Sub_Status__c = 'Inbound message received', Description='Testing-PP-17997-1', AccountId= testAccount.Id, RecordTypeId =Case_PN_RecordType1, ContactId = testContact.Id, EntitlementId = etm.id, GSS_Ack_Additional_Email__c = 'test1@gmail.com');
        insert testCase1;
        
    }

    public static void setupData2(){
        testAccount = new Account();
        testAccount.Name = 'Test Account1';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        insert testAccount;
        
        testAccount0 = new Account();
        testAccount0.Name = 'Test Account2';        
        testAccount0.Country__c = 'CHINA';
        testAccount0.Type='Private Sector';
        testAccount0.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        insert testAccount0;
        

        testContact = new Contact();
        testContact.FirstName = 'New';
        testContact.LastName = 'Test Contact1';        
        testContact.Email = 'Test@gmail.com';
        testContact.Phone = '00323400000';
        testContact.AccountId = testAccount.Id;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        insert testContact;
        
        Entitlement  etm = new Entitlement(name = 'test etntitlement', Type = '1', AccountId= testAccount.Id, StartDate = date.newInstance(2012,05,22), EndDate = date.newInstance(2012,06,2), GSS_Entitlement_Code__c = 'IPS', GSS_Entitlement_Status__c = 'Active');
        insert etm;

        GSS_ServiceNow_Parameters__c  gssSDPchecks = GSS_ServiceNow_Parameters__c.getOrgDefaults();
        if(!gssSDPchecks.Is_Production__c){
            gssSDPchecks.Is_Production__c = true;
            upsert gssSDPchecks;
        }
        testCase2 = new Case(Origin='Email',Priority='1 - Critical',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', Sub_Status__c = 'Inbound message received', Description='Testing-PP-17997-1', AccountId= testAccount0.Id, RecordTypeId =Case_PN_RecordType1, ContactId = testContact.Id, EntitlementId = etm.id, GSS_Ack_Additional_Email__c = 'test1@gmail.com');
        insert testCase2;
        
    }
    
    public static testmethod void sendingAckEmailSDPTest1(){
        Test.startTest();  
        setupData1();
        Test.stopTest();
    }
    
    public static testmethod void sendingAckEmailSDPTest2(){
        Test.startTest();  
        setupData2();        
        Test.stopTest();
    }
    
     public static testmethod void bbb8pauseClkTest(){
        BB8_DataFactory.createCustomSettings();
        BB8_DataFactory.addEmailTemplateForMilestones();
        BB8_DataFactory.insertBB8IntegrationFields();
        //Creating Account for Customer
        Id recTypeAccId=Id.valueOf(Record_Type_Settings__c.getValues('GSS_ACC_EC').Record_Type_ID__c);
        Account ac1 = new Account(Name='AccountTest1',recordtypeId= recTypeAccId, Country__c='INDIA' );
        insert ac1;
        
         Entitlement ent = new Entitlement();
         ent.Name ='carrier grade Support';
         ent.GSS_Entitlement_Code__c ='CGS';
         ent.GSS_Entitlement_Status__c = 'Active';
         ent.AccountId = ac1.id;
         insert ent;
    
        //Creating Contact for a customer
        Id recTypeConId=Id.valueOf(Record_Type_Settings__c.getValues('GSS_CON_CC').Record_Type_ID__c);
        Contact ct1 = new Contact(FirstName='spanEmailContact',LastName='Test1',Email='email@spanEmail.com',recordtypeId=recTypeConId);
        ct1.accountid=ac1.id;
        insert ct1;

        Case cc = new Case();
        // Test data for case
        cc.RecordTypeId=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        cc.entitlementid= ent.id;
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '4 - Low';
        cc.Status = 'New';
        cc.Sub_Status__c = 'Unassigned';
        cc.Subject = ' Task Test Subject';
        cc.Description = 'Test  Case Description';
        cc.Technical_Contact_Name__c='Technical Test';
        cc.contactid=ct1.id;
        
        insert cc;
        
        
        Case_SLA__c sla = new Case_SLA__c();
        sla.Case__c = cc.id;
        sla.Final_correction_actual__c = system.now();
        sla.Final_Correction_due__c = system.now();
        sla.First_Response_Due_Date__c = system.now();
        sla.First_Response_Due_In__c = system.now();
        sla.Last_Stopped_Time__c = system.now();
        sla.RCA_Due__c = system.now();
        sla.RCA_Delivered__c = system.now();
        
        insert sla;
        
        Test.startTest();
        //change the case status to waiting for customer
        GSS_UtilityClass.isSystemUpdatedCaseSubStatusCheck = true;
        cc.Sub_Status__c= 'Customer To Confirm Fix';
        update cc;
        cc.Sub_Status__c = 'Fix Succeeded';
        update cc;
        
        Test.stopTest();
     
     } 
      public static testmethod void bbb8CaseClsTest(){
        BB8_DataFactory.createCustomSettings();
        BB8_DataFactory.addEmailTemplateForMilestones();
        BB8_DataFactory.insertBB8IntegrationFields();
        //Creating Account for Customer
        Id recTypeAccId=Id.valueOf(Record_Type_Settings__c.getValues('GSS_ACC_EC').Record_Type_ID__c);
        Account ac1 = new Account(Name='AccountTest1',recordtypeId= recTypeAccId, Country__c='INDIA' );
        insert ac1;
        
         Product2 prod = new Product2(Name='OtherProd12', GSS_Assignment_Group__c='SDK Product Group',GSS_Vsubcat__c='SubCat1,SC2,SC3', GSS_Product_vCat__c='Cat1;Cat2',
                         GSS_Partner_vSubcat__c ='PartnerSubCat1;PSC2;Configuration;Database',GSS_Product_Issue_type__c='Sales;john;Apple;Mango;Orange',GSS_Version__c='5.5',GSS_Build__c='1.0');
        insert prod;
        
         Entitlement ent = new Entitlement();
         ent.Name ='carrier grade Support';
         ent.GSS_Entitlement_Code__c ='CGS';
         ent.GSS_Entitlement_Status__c = 'Active';
         ent.AccountId = ac1.id;
         insert ent;
    
        //Creating Contact for a customer
        Id recTypeConId=Id.valueOf(Record_Type_Settings__c.getValues('GSS_CON_CC').Record_Type_ID__c);
        Contact ct1 = new Contact(FirstName='spanEmailContact',LastName='Test1',Email='email@spanEmail.com',recordtypeId=recTypeConId);
        ct1.accountid=ac1.id;
        insert ct1;

        Case cc = new Case();
        // Test data for case
        cc.RecordTypeId=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        cc.entitlementid= ent.id;
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '4 - Low';
        cc.Status = 'New';
        cc.Sub_Status__c = 'Assigned';
        cc.Subject = ' Task Test Subject';
        cc.Description = 'Test  Case Description';
        cc.Technical_Contact_Name__c='Technical Test';
        cc.GSS_Vcat__c='vCat';
        cc.GSS_Sub_Type__c = 'test';
        cc.GSS_Vsubcat__c ='sub cat';
        cc.Issue_Type__c = 'Issue Type';
        cc.GSS_Resolution__c = 'test';
        cc.GSS_Resolution_Code__c = 'By Customer';
        cc.GSS_Symptoms__c = 'Test';
        cc.GSS_Is_Issue_Subtype_Active__c = false;
        cc.First_Response_Date__c = System.now().addmonths(1);
        cc.ProductId  = prod.id;
        //cc.Product.GSS_Version__c = '1.0';
        
        cc.contactid=ct1.id;
       
        
        insert cc;
        
        
        Case_SLA__c sla = new Case_SLA__c();
        sla.Case__c = cc.id;
        sla.Final_correction_actual__c = system.now();
        sla.Final_Correction_due__c = system.now();
        sla.First_Response_Due_Date__c = system.now();
        sla.First_Response_Due_In__c = system.now();
        //sla.Last_Stopped_Time__c = system.now();
        sla.RCA_Due__c = system.now();
        sla.RCA_Delivered__c = system.now();
        
        insert sla;
        
        Test.startTest();
       
        cc.Status= 'Duplicate';
        update cc;
        
        Test.stopTest();
     
     }
     public static void setupData3(){
     testAccount = new Account();
        testAccount.Name = 'Test Account1';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        insert testAccount;
        
        testAccount0 = new Account();
        testAccount0.Name = 'Test Account2';        
        testAccount0.Country__c = 'CHINA';
        testAccount0.Type='Private Sector';
        testAccount0.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        insert testAccount0;
        

        testContact = new Contact();
        testContact.FirstName = 'New';
        testContact.LastName = 'Test Contact1';        
        testContact.Email = 'Test@gmail.com';
        testContact.Phone = '00323400000';
        testContact.AccountId = testAccount.Id;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        insert testContact;
        
        Entitlement  etm = new Entitlement(name = 'test etntitlement', Type = '1', AccountId= testAccount.Id, StartDate = date.newInstance(2012,05,22), EndDate = date.newInstance(2012,06,2), GSS_Entitlement_Code__c = 'IPS', GSS_Entitlement_Status__c = 'Active');
        insert etm;

        GSS_ServiceNow_Parameters__c  gssSDPchecks = GSS_ServiceNow_Parameters__c.getOrgDefaults();
        if(!gssSDPchecks.Is_Production__c){
            gssSDPchecks.Is_Production__c = true;
            upsert gssSDPchecks;
        }
        testCase2 = new Case(Origin='Email',Priority='1 - Critical',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', Sub_Status__c = 'Inbound message received', Description='Testing-PP-17997-1', AccountId= testAccount0.Id, RecordTypeId =SalesOpsRecordTypeId, ContactId = testContact.Id, EntitlementId = etm.id, GSS_Ack_Additional_Email__c = 'test1@gmail.com');
        insert testCase2;
        cId = testCase2.Id;
        //testCasehistory1 =  [Select CaseId, Case.Status, Field, OldValue, NewValue, CreatedDate From CaseHistory Where CaseId=: testCase2.id];//
         system.debug('>>>>>>>>testCasehistory1'+testCasehistory1 );
        // insert testCasehistory1 ;
     }
     
   public static testmethod void calculateCaseStatusTimeTest(){
         Test.startTest();
        setupData3();
         
       testCasehistory1 = new CaseHistory(CaseId = testCase2.id, Field ='Status');
       insert testCasehistory1;
        testCase2.Status ='Re-opened';
         Update testCase2;
         
          Test.stopTest();
     }
     /*public static testmethod void calculateCaseStatusTimeTest1(){
         Test.startTest();
        setupData3();
        
        testCase2.Status ='Re-opened';
      
        Update testCase2;
          testCasehistory1 = new CaseHistory(CaseId = testCase2.id, Field ='Status');
       insert testCasehistory1;
   testCasehistory1 = [Select CaseId, Case.Status, Field, OldValue, NewValue, CreatedDate From CaseHistory where CaseId=: cId ];
       
          Test.stopTest();
     }*/
     public static testmethod void calculateCaseStatusTimeTest1(){
        
        List<Account> aList = new List<Account>();
        testAccount = new Account();
        testAccount.Name = 'Test Account1';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        //insert testAccount;
        aList.add(testAccount);
        
        testAccount0 = new Account();
        testAccount0.Name = 'Test Account2';        
        testAccount0.Country__c = 'CHINA';
        testAccount0.Type='Private Sector';
        testAccount0.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account Layout').getRecordTypeId();
        //insert testAccount0;
        aList.add(testAccount0);
        
        insert aList;
        
        testContact = new Contact();
        testContact.FirstName = 'New';
        testContact.LastName = 'Test Contact1';        
        testContact.Email = 'Test@gmail.com';
        testContact.Phone = '00323400000';
        testContact.AccountId = testAccount.Id;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        insert testContact;
        
        Entitlement  etm = new Entitlement(name = 'test etntitlement', Type = '1', AccountId= testAccount.Id, StartDate = date.newInstance(2012,05,22), EndDate = date.newInstance(2012,06,2), GSS_Entitlement_Code__c = 'IPS', GSS_Entitlement_Status__c = 'Active');
        insert etm;
        
        Test.startTest();
        
        GSS_ServiceNow_Parameters__c  gssSDPchecks = GSS_ServiceNow_Parameters__c.getOrgDefaults();
        if(!gssSDPchecks.Is_Production__c){
            gssSDPchecks.Is_Production__c = true;
            upsert gssSDPchecks;
        }
        PreEnt1= new GSS_Premier_Entitlement__c(Code__c= 'IPS',CaseSeverityForExclusion__c= '1 - Critical;2 - High',Entitlement__c= 'IPS',isActive__c= true, isOpcoEnabled__c= true, isWFNotifsActive__c= true, isAssignmentEnabled__c=true, Name= 'IPS' );
        insert PreEnt1;
        SlaInt = new BB_8_SLA_integration_fields__c(Available_for_Portal__c= true, Case_Priorities__c= '1 - Critical,2 - High,3 - Medium,4 - Low', Eligible_For_Case_Closure_Validation__c= true, Entitlement_Code__c= 'IPS', Field_API_Name__c= 'Final_correction_actual__c',Is_Active__c= true, IsMilestoneButtonVisible__c= false,Is_Target_Date__c= false ,MetFieldAPIName__c= '', Milestone_Name__c= 'test2', Object_API_Name__c= 'Case_SLA__c', Portal_SLA_Field__c= 'slatest742016313', Row_Order_Number__c= 4, Should_mail_be_delivered_to_owner__c= true , name='testHulk' );
        insert SlaInt; 
        testCase2 = new Case(Origin='Email',Priority='1 - Critical',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', Sub_Status__c = 'Inbound message received', Description='Testing-PP-17997-1', AccountId= testAccount0.Id, RecordTypeId =SalesOpsRecordTypeId, ContactId = testContact.Id, EntitlementId = etm.id, GSS_Ack_Additional_Email__c = 'test1@gmail.com');
        insert testCase2;
        cId = testCase2.Id;
        //testCasehistory1 =  [Select CaseId, Case.Status, Field, OldValue, NewValue, CreatedDate From CaseHistory Where CaseId=: testCase2.id];//

       testCasehistory1 = new CaseHistory(CaseId = testCase2.id, Field ='Status');
       insert testCasehistory1;
       
       //caseExtension record 1. lookup filed main Case__c=testCase2.id
        testCase2.Status ='Closed';
        Update testCase2;
         
        Test.stopTest();
     }
}