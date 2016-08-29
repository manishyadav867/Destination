/**********************************************************
 * Class Name : GSS_CaseRequestClassTest
 * Purpose    : This the utility class is to test GSS_CaseRequestClass 
 * JIRA       : PP-17997
 * ********************************************************************************       
 * Author                                Date            Remarks
 * Accenture - IDC (Harish Patkar)                     28-Sep-10       Created
 * Accenture - IDC                      21-Feb-2012       updated the class to Increase the code coverage for CR-00003886.
 * *******************************************************
 * Author                               Date            Remarks
 * Samar Saha                           8/29/2012       CR-00018248 : increase code coverage     
 * Nierrbhayy Patel                     9/14/2013       CR-00052193 : optimized
 ************************************************************************************/
 
@isTest(seealldata=true)
private class GSS_CaseRequestClassTest {

    public static Case testCase1;
    public static Case testCase2;

    private static Id recTypeIdCase;
    private static Id recTypeIdCase2;
    public static Account testAccount;
    
    //Start changes for CR-00003886
    public static Id pro;
    public static List<User> usr;
    public static List<AccountTeamMember> accTeamMembers;
    public static Account testAccount0; 
    public static List<Account> listAccounts;
    public static List<GSS_Request__c> lstReqObj;
    public static GSS_Request__c reqObj1;
    public static GSS_Request__c reqObj2;
    //End 
    
    //Method to set up data
    public static void setUpData(){    
    
        recTypeIdCase=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_LIC').Record_Type_ID__c);
        recTypeIdCase2=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_CS').Record_Type_ID__c);
        
        //Start changes for CR-00003886

        Profile_Name_Mapping__c prf = CustomSettingUtility.getProfileNameMapping('GSS System Administrator');
        pro= Id.ValueOf(prf.Profile_Id__c);

        usr = new List<User>();
        usr.add( new User (Alias = 'alias1',email='standarduser1@testorg.com',emailencodingkey='UTF-8',Username = 'someuser1@somedomain.com',Lastname = 'somelastname1',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname1',profileid = pro, country='INDIA', Division = 'APAC'));
        usr.add( new User (Alias = 'alias2',email='standarduser2@testorg.com',emailencodingkey='UTF-8',Username = 'someuser2@somedomain.com',Lastname = 'somelastname2',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname2',profileid = pro, country='INDIA', Division = 'AMER'));
        usr.add( new User (Alias = 'alias3',email='standarduser3@testorg.com',emailencodingkey='UTF-8',Username = 'someuser3@somedomain.com',Lastname = 'somelastname3',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname3',profileid = pro, country='INDIA', Division = 'EMEA'));
              
        Insert usr;

        usr[0].GSS_Manager__c = usr[1].Id;
        usr[1].GSS_Manager__c = usr[2].Id;

        update usr;
        //End 
        
        listAccounts = new List<Account>();
        testAccount = new Account();
        testAccount.Name = 'Test Account1';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.GSS_S1_Red_Alert_Notifications__c = true;
        listAccounts.add(testAccount);
        
        testAccount0 = new Account();
        testAccount0.Name = 'Test Account';        
        testAccount0.Country__c = 'INDIA';
        testAccount0.Type='Public Sector';
        testAccount0.GSS_S1_Red_Alert_Notifications__c = true;
        listAccounts.add(testAccount0);
       
        insert listAccounts;
        
        accTeamMembers = new List<AccountTeamMember>();
        accTeamMembers.add(new AccountTeamMember( TeamMemberRole = 'Technical Account Manager', AccountId = listAccounts[0].Id, UserId = usr[0].Id));
        accTeamMembers.add(new AccountTeamMember( TeamMemberRole = 'Global Account Manager', AccountId = listAccounts[1].Id, UserId = usr[0].Id));
        
        Insert accTeamMembers;
    
        List<Case> listCase = new List<Case>();
        testCase1 = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',Priority='1 - Critical',
                             GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing1', GSS_Support_Customer_Region__c = 'APJ',
                             Description='Testing-PP-17997-1',AccountId = listAccounts[1].Id,RecordTypeId = recTypeIdCase);
        listCase.add(testCase1);
     
        
        testCase2 = new Case(Origin='Phone',GSS_Preferred_Method_of_Contact__c='Phone',Priority='1 - Critical', 
                            GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',Status='New',Subject ='Testing2', GSS_Support_Customer_Region__c = 'APJ',
                            Description='Testing-PP-17997-2',AccountId = listAccounts[0].Id, RecordTypeId = recTypeIdCase2);
        listCase.add(testCase2);
        insert listCase;
        
        testCase1.Account = listAccounts[1];
        testCase1.OwnerId = usr[0].Id;
        testCase2.Account = listAccounts[0];
        testCase2.OwnerId = usr[0].Id;
        update listCase;
        
        
    }
    
    public static void setUpData1(){  

        //get the RecordTypeId for Escalation Request
        Id recTypeId=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_REQ_ER').Record_Type_ID__c);
        
        lstReqObj = new List<GSS_Request__c> ();
        
        reqObj1 = new GSS_Request__c();
        reqObj1.GSS_Case_Number__r = testCase1;
        reqObj1.GSS_Escalation_Request_Type__c = 'Licensing';
        reqObj1.GSS_Description__c = 'testing';
        reqObj1.GSS_Situation_Factor__c = 'cm: CAP';
        reqObj1.GSS_Status__c = 'pending';
        reqObj1.GSS_Escalation_Reason__c = 'Test Approval';
        reqObj1.RecordTypeId = recTypeId;
        reqObj1.GSS_Case_Number__r.Account.GSS_S1_Red_Alert_Notifications__c = true;
        reqObj1.GSS_Case_Number__c = testCase1.id;
        reqObj1.GSS_Escalation_Reason__c = 'Test';
        reqObj1.Current_Status__c = 'test';
        lstReqObj.add(reqObj1);
        
        
        reqObj2 = new GSS_Request__c();
        //reqObj2.GSS_Case_Number__r = testCase1;
        reqObj2.GSS_Escalation_Request_Type__c = 'Licensing';
        //reqObj2.GSS_Description__c = 'testing';
        reqObj2.GSS_Situation_Factor__c = 'cm: CAP';
        //reqObj2.GSS_Status__c = 'pending';
        reqObj2.GSS_Escalation_Reason__c = 'Test Approval';
        reqObj2.RecordTypeId = recTypeId;
        //reqObj2.GSS_Case_Number__r.Account.GSS_S1_Red_Alert_Notifications__c = true;
        //reqObj2.GSS_Case_Number__c = testCase1.id;
        reqObj2.GSS_Escalation_Reason__c = 'Test';
        reqObj2.Current_Status__c = 'test';
        lstReqObj.add(reqObj2);
        
        insert lstReqObj; 
                
    }
    
    static testMethod void testEscalateRequestApproved(){
    
        setUpData();
        

        Test.startTest();  
        setUpData1();
        System.debug('Query at Start 1 ' + Limits.getQueryRows());
        lstReqObj[0].GSS_Status__c='Approved';
        Update lstReqObj;
        System.debug('Query at end 1 ' + Limits.getQueryRows());
        Test.stopTest();
    } 
    
    static testMethod void testUpdateCaseEscalationStatus(){
    
        setUpData();
        

        Test.startTest();  
        setUpData1();
        System.debug('Query at Start 1 ' + Limits.getQueryRows());
        GSS_CaseRequestClass.updateCaseStatusForRequest(lstReqObj);    
        System.debug('Query at end 1 ' + Limits.getQueryRows());
        Test.stopTest();
    }   
    static testMethod void testvalidateEscalatedCaseRequest(){
        
        setUpData();
        Test.startTest();
        System.debug('Query at Start 2' + Limits.getQueryRows());  
        GSS_CaseRequestClass.validateEscalatedCaseRequest(testCase2);
        System.debug('Query at end 2' + Limits.getQueryRows());
        Test.stopTest();
        
    }
    
    static testMethod void testUserFromEscalatedProfiles(){
   
        Profile_Name_Mapping__c  pCusObj = CustomSettingUtility.getProfileNameMapping('GSS System Administrator'); 
        pro = Id.ValueOf(pCusObj.Profile_Id__c);
        Test.startTest();  
        System.debug('Query at Start 3 ' + Limits.getQueryRows());
        GSS_CaseRequestClass.isUserFromEscalatedProfiles(pro);
        System.debug('Query at end 3 ' + Limits.getQueryRows());
        Test.stopTest();
    
    }
    
    static testMethod void testIsUserFromEscalatedProfiles(){
       
        Test.startTest();  
        System.debug('Query at Start 4 ' + Limits.getQueryRows());
        GSS_CaseRequestClass.isUserFromEscalatedProfiles(null);
        System.debug('Query at end 4 ' + Limits.getQueryRows());
        Test.stopTest();
    
    }
    
    static testMethod void testinsertDefaultRequestContacts()
    {
        setUpData();
        Test.startTest();  
        setUpData1();
        Test.stopTest();
    }

}