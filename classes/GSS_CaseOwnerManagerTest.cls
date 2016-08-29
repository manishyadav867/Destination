/**
*2/29/2012        Accenture IDC   Added Error handling code in catch block for CR-00008898
**/
/* ***********************Version Updates*************************************************
//* Date              Developer               Description
//* ---------------------------------------------------------------------------------------
//* 06.10.2015        Jyolsna               RS2 H2 : CR-00135349
//*04-feb-2016        MSJ           Made changes for coverage CR-00137728
//* 07-Apr-2016       Jyolsna       Made changes for coverage CR-00137286
//*****************************************************************************************/
@isTest(SeeAllData=true)
private class GSS_CaseOwnerManagerTest 
{
    
    public static Account oAccount;
    public static user u= new user();
    public static user u1 = new user();
    public static Contact oContact;
    public static Product2 prod;
    public static Case caseobj;
    public static case c;
    public static List<Case> caseobjlist;
    public static Map<Id,Case> caseobjMap;
    public static Map<ID,User> ownerIdUser;
    public static Set<ID> ownerIds = new Set<ID>();
    //public static User objUser;
    public static void setupData1(){
        Id pId=[select id from profile where name ='System Administrator' limit 1].Id;
        List<user> uList=new List<user>();
        u.FirstName         = 'vmwareawer';
        u.LastName          = 'Softwaree098*';
        u.Email             = 'itshouldbeunique@GSS.com';
        u.Alias             = 'ngrd';
        u.Username          = 'itshouldbeunique@GSS.com';
        u.LocaleSidKey      = 'en_US';
        u.TimeZoneSidKey    = 'GMT';
        u.ProfileID         = pId;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.GSS_Business_Unit__c='GS-SS-CS-S-CNX';
        u.Division ='AMER';//CR-00137728
        uList.add(u);
        u1.FirstName         = 'vmwareawer';
        u1.LastName          = 'Softwaree098*';
        u1.Email             = 'itshouldbeunique2@GSS.com';
        u1.Alias             = 'ngrd2';
        u1.Username          = 'itshouldbeunique2@GSS.com';
        u1.LocaleSidKey      = 'en_US';
        u1.TimeZoneSidKey    = 'GMT';
        u1.ProfileID         = pId;
        u1.LanguageLocaleKey = 'en_US';
        u1.EmailEncodingKey  = 'UTF-8';
        u1.GSS_Business_Unit__c='GS-SS-CS-AS-CRK';
        u1.Division ='AMER';//CR-00137728
        uList.add(u1);  
        user user1 = [select id from user where profileid =: pId and IsActive = true limit 1];
        system.runAs(user1){
            Insert uList;            
        }

        String recId = Record_Type_Settings__c.getInstance('GSS_CASE_CS').Record_Type_ID__c;
        c= new Case(subject ='test',description='test',recordTypeId=recId,OwnerId=u.Id,GSS_Business_unit__c='GS-SS-CS-S-CNX');
        //case c1=new(subject ='test',description='test',recordTypeId=recId,OwnerId=u1.Id);
        //List<case> c = new List<case>();
        insert c; 
        //Start - 07-Apr-2016 - Jyolsna - CR-00137286 - creating Custom setting records 
        if(Profile_Name_Mapping__c.getInstance('Profile - 339')== null){
            List<Profile_Name_Mapping__c> profileList = new List<Profile_Name_Mapping__c>();
            Id profileId =[select id from profile where name ='GSS Licensing New' limit 1].Id;
            profileList.add(new Profile_Name_Mapping__c(Name = 'Profile - 339',Profile_Apex_Name__c = 'GSS Licensing New',Profile_Id__c = profileId,Profile_Name__c = 'GSS Licensing New'));
            insert profileList;
        }
        if(GSS_Queues_business_Unit__c.getInstance('GSS Education Support') == null){
            List<GSS_Queues_business_Unit__c> buList = new List<GSS_Queues_business_Unit__c>();
            buList.add(new GSS_Queues_business_Unit__c(Name = 'GSS Education Support',Business_Unit__c = 'GS-SS-CS-EDU'));
            insert buList;
        }
        //End - 07-Apr-2016 - Jyolsna   - CR-00137286 - creating Custom setting records 
    }
    public static void setupData()
    {    
        Record_Type_Settings__c oRTSACC = Record_Type_Settings__c.getInstance('GSS_ACC_EC');
        oAccount = new Account(name ='test', recordtypeid = oRTSACC.record_type_id__c, type = 'Customer', UUID__c = 'testUUrwerewID');
        try
        {       
            insert oAccount;
            system.debug('account inserted........');
        } catch(Exception e){
            //system.debug('Error inserting account.......');
             //Added Error handling code in catch block for CR-00008898
             CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Account', 'GSS_CaseOwnerManagerTest');
             //End of code for CR-00008898 
        }
        
        Record_Type_Settings__c oRTSCON = Record_Type_Settings__c.getInstance('GSS_CON_CC');
        oContact = new Contact(GSS_CN__c = 't1sb56rrt9', lastName = 'test', accountid = oAccount.ID, recordtypeid = oRTSCON.record_type_id__c, email = 'tes1111t@tes11111t.com');
        try
        {  
            insert oContact;
            system.debug('contact inserted........');
        } catch(Exception e){
            //system.debug('Error inserting contact.......');
             //Added Error handling code in catch block for CR-00008898
             CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Contact', 'GSS_CaseOwnerManagerTest');
             //End of code for CR-00008898 
        }
        
        prod = new product2(name='prod1111111');
        try
        {
            insert prod;
            system.debug('product inserted........');
        } catch(Exception e){
            //system.debug('Error inserting product...........');
             //Added Error handling code in catch block for CR-00008898
             CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'product2', 'GSS_CaseOwnerManagerTest');
             //End of code for CR-00008898 
        }

        
               
        Record_Type_Settings__c caserec = Record_Type_Settings__c.getInstance('GSS_CASE_TS');
        caseobj = new Case(productId = prod.id,GSS_Support_Customer_Region__c = 'EMEA',accountId = oAccount.id,contactId = oContact.id,Sub_Status__c = 'Working',GSS_Resolution_Code__c = 'Other Reason',Case_Resolution__c = 'abcde',GSS_Available_24_7__c = 'Yes',GSS_Severity__c = '2 - High',Description = 'xyz',recordtypeid=caserec.record_type_id__c,GSS_Support_Level__c = '1',GSS_Problem_Category__c = 'Licensing',Status = 'Open',Subject = 'abc',ownerid=userinfo.getUserId());
        try
        {       
            insert caseobj;
            system.debug('case inserted........');
        } catch(Exception e){
            //system.debug('Error inserting case.......');
             //Added Error handling code in catch block for CR-00008898
             CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Case', 'GSS_CaseOwnerManagerTest');
             //End of code for CR-00008898 
       }
    }
    

    static testMethod void testmethod1() 
    {
        setupdata();
        test.starttest();
    
        caseobjlist = new List<Case>();
        caseobjlist.add(caseobj);
        caseobjMap = new Map<Id,Case>();
        caseobjMap.put(caseobj.id,caseobj);
        GSS_CaseOwnerManager.insertCaseOwnerManagerEmail(caseobjlist);
        GSS_CaseOwnerManager.updateCaseOwnerManagerEmail(caseobjlist);
        GSS_CaseOwnerManager.updateManagerEmail(caseobjlist);
        GSS_CaseOwnerManager.updateCommitDefaulter(caseobjlist ,'upd');
         GSS_CaseOwnerManager.updateCommitDefaulter(caseobjlist);
        GSS_CaseOwnerManager.AI_MgrEmail(caseobjlist);
        GSS_CaseOwnerManager.BI_MgrEmail(caseobjlist);
        GSS_CaseOwnerManager.BU_MgrEmail(caseobjlist);
        GSS_CaseOwnerManager.BU_MgrEmail(caseobjlist,caseobjMap);
        GSS_CaseOwnerManager.updateTSEOwnerForEscalationCase(caseobjlist,caseobjMap);
        caseobjlist[0].ownerId=[select id from Group where name ='GSS CS DEFAULT'].id;
        update caseobjlist;
        GSS_CaseOwnerManager.updateManagerEmail(caseobjlist);
        GSS_CaseOwnerManager.updateCaseOwnerManagerEmail(caseobjlist);
        GSS_CaseOwnerManager.updateTSEOwnerForEscalationCase(caseobjlist,caseobjMap);
        test.stoptest();
    }
    static testmethod void testmethod2(){
        setupData1();
        test.startTest();
        caseobjMap = new Map<Id,Case>();
        caseobjMap.put(c.id,c);
        caseobjlist = new List<Case>();
        c.ownerId=[select id from Group where name ='GSS CS DEFAULT'].id;
        update c;
        case case2=[select id,ownerid,GSS_Business_unit__c,RecordTypeId,subject from case where id=:c.id];
        caseobjlist.add(case2);
        system.debug(caseobjMap);
        system.debug('....'+caseobjlist);
        GSS_CaseOwnerManager.BU_UpdateBusinessUnit(caseobjlist,caseobjMap);
        test.stoptest();
    }
    static testmethod void testmethod3(){
        setupData1();
        test.startTest();
        caseobjMap = new Map<Id,Case>();
        caseobjMap.put(c.id,c);
        caseobjlist = new List<Case>();
        c.ownerId=u1.id;
        update c;
        case case2=[select id,ownerid,GSS_Business_unit__c,RecordTypeId,subject from case where id=:c.id];
        caseobjlist.add(case2);
        system.debug(caseobjMap);
        system.debug('....'+caseobjlist);
        GSS_CaseOwnerManager.BU_UpdateBusinessUnit(caseobjlist,caseobjMap);
        test.stoptest();
    }
    //Start - 07-Apr-2016 - Jyolsna - CR-00137286 - to increase code coverage 
    static testmethod void testmethod4(){
        setupData1();
        test.startTest();
        caseobjMap = new Map<Id,Case>();
        caseobjMap.put(c.id,c);
        caseobjlist = new List<Case>();
        c.ownerId=[select id from Group where name ='Customer Support - Account Specialists'].id;
        update c;
        case case2=[select id,ownerid,GSS_Business_unit__c,RecordTypeId,subject from case where id=:c.id];
        caseobjlist.add(case2);
        system.debug(caseobjMap);
        system.debug('....'+caseobjlist);
        GSS_CaseOwnerManager.BU_UpdateBusinessUnit(caseobjlist,caseobjMap);
        test.stoptest();
    }
     static testmethod void testmethod5(){
        
        setupData1();
        test.startTest();
        c.GSS_Business_unit__c = 'GS-SS-CS-EDU';
        update c;
        caseobjMap = new Map<Id,Case>();
        caseobjMap.put(c.id,c);
        caseobjlist = new List<Case>();
        c.ownerId=u1.id;
        update c;
        case case2=[select id,ownerid,GSS_Business_unit__c,RecordTypeId,subject from case where id=:c.id];
        caseobjlist.add(case2);
        system.debug(caseobjMap);
        system.debug('....'+caseobjlist);
        GSS_CaseOwnerManager.BU_UpdateBusinessUnit(caseobjlist,caseobjMap);
        test.stoptest();
    }
    //End - 07-Apr-2016 - Jyolsna   - CR-00137286 - to increase code coverage 
}