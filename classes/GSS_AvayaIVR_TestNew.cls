/**
* 7/29/2015        Anchal Jindal   Modified to increase the code coverage of GSS_Avaya_IVR || August 2015 Release
**/
    @istest(seeAllData=true)
    private class GSS_AvayaIVR_TestNew{
    static String CN;
    static String CountryCode;
    static String ProductName;
    static String ProblemCategory;
    static String EntitlementCode;
    static String ServerDown;
    static String TechnicalContact;
    static String PreferredMOC;
    static String PhoneNumber;
    static String FaxNum;
    static String LastName;
    static String FirstName;
    static String Email;
    static String Source;
    static String AltPhoneNum;
    static String State;
    static String ClosureReason;
    static String SRNumber;
    static String Snum;
    static String Snum1;
    public static Entitlement myent;
    
    public static void setupCustomSettingData() {
       /* System.runAs([select Id from User where isActive=true and Profile.Name ='System Administrator' LIMIT 1][0]) { */
            QnC_Case_Properties__c qncProps = QnC_Case_Properties__c.getOrgDefaults();
            qncProps.Turn_On_Admin_Group_Sharing__c = true;
            qncProps.Turn_On_Requester_Sharing__c = false;
            qncProps.Turn_On_Owner_Sharing_AMER__c=false;
            upsert qncProps;
       // }
}

    static void setupdata1(){
        setupCustomSettingData();
        // to Bypass Trigger
        List<ByPassTriggerForDataMigration__c> bypassList = ByPassTriggerForDataMigration__c.getall().values();
        for(ByPassTriggerForDataMigration__c leadbypass : bypassList){
            if((leadbypass.Object_Name__c == 'Lead') || (leadbypass.Object_Name__c == 'Case') ||(leadbypass.Object_Name__c == 'Task')|| (leadbypass.Object_Name__c == 'Account') || (leadbypass.Object_Name__c == 'Contact') || (leadbypass.Object_Name__c == 'Entitlement')){
                leadbypass.User_Name__c = UserInfo.getName();
            }
        }
        update bypassList;

        // Account Creation
        ID recTypeAccountId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_ACC_EC').Record_Type_ID__c);
        Account ac1 = new Account(Name='OOTOAccountTest1',recordtypeId= recTypeAccountId , Country__c='GERMANY',State__c='BAYERN' );
        insert ac1;

        //Record Type
        ID recordTypeConId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CON_CC').Record_Type_ID__c);
        ID recTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        
        //Contact Creation
        Contact ct1 = new Contact(FirstName='spanEmailContact',LastName='Test1',Email='email@spanEmail.com',GSS_CN__c ='231546',recordtypeId=recordTypeConId);
        ct1.accountid=ac1.id;
        insert ct1; 

        //Insert Product
        Product2 testProduct = new Product2(ProductCode='0123', Name='Test Product', IsActive= true, 
        GSS_Version__c='Version 1.0,Version 1.1',GSS_Group__c='Service Product',
        GSS_Build__c='Test1,Test2',Family='Desktop',Description='Desktop Product',GSS_Assignment_Group__c='Service SME Group',GSS_Vsubcat__c='subcat1,subcat2');        
        insert testProduct;


        //Retrieve entitlement Record
        //Entitlement myentitlement = [Select Id,GSS_Entitlement_Code__c,RemainingCases From Entitlement where GSS_Entitlement_Code__c = 'CPS' AND Status ='Active' limit 1];
        //insert Entitlement
        Entitlement myentitlement = new Entitlement(Name='testtt',GSS_Entitlement_Code__c='anc');
        myentitlement.accountid=ac1.id;
        insert myentitlement;

        //Insert Case
        Case  testCase1 = new Case(Origin='Email',GSS_Routing_Channel__c = 'LIVE',GSS_Phone_Queue_Routing_Status__c = 'No Call',GSS_Preferred_Method_of_Contact__c='Email',Product=testProduct,GSS_Support_Customer_Region__c='APJ',recordtypeId=recTypeId ,Priority ='1-Critical', GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',GSS_Time_Zone__c='SE Asia Standard Time',Status='New',Subject ='testing',Description='testing',GSS_Language__c='ENG',GSS_Severity__c = '1',GSS_Phone_Queue__c='1234567',contactId = ct1.id,EntitlementId=myentitlement.Id);
        insert testCase1;


        //Update Entitlement Record
        myentitlement.IsPerIncident= True;
        myentitlement.RemainingCases = 0;
        myentitlement.CasesPerEntitlement=3;
        update myentitlement;
        
        //insert new entitlement
        myent = new Entitlement(Name='Code Cover Ent',GSS_Entitlement_Code__c='TCV');
        myent.accountid=ac1.id;
        myent.IsPerIncident= True;
        myent.RemainingCases = 3;
        myent.CasesPerEntitlement=5;
        insert myent;
        
        //Query Contact and Case
        Contact con = [Select Id,FirstName,LastName,GSS_CN__c,country__c,state__c,email from Contact where id = :ct1.id];
        Case newCase = [select casenumber from case where id = :testCase1.id];

        CN = con.GSS_CN__c;
        CountryCode = con.country__c;
        ProductName = testProduct.Name;
        ProblemCategory = 'Test';
        EntitlementCode = 'Test';
        ServerDown = 'Test';
        TechnicalContact = 'Test';
        PreferredMOC = 'Test';
        PhoneNumber = '123456789';
        FaxNum = '12233456789';
        LastName = con.FirstName;
        FirstName = con.FirstName;
        Email = con.Email;
        Source = 'email';
        AltPhoneNum = '83625628332';
        State = con.state__c; 
        ClosureReason='Test';      
        SRNumber=newCase.CaseNumber;

        System.debug('SRNUMBER....'+newCase.CaseNumber);
        System.debug('CN....'+con.GSS_CN__c);
    }

    /*** static void setupdata2(){

        CN = '';
        CountryCode = 'US';
        ProductName = 'Test';
        ProblemCategory = 'Test';
        EntitlementCode = 'Test';
        ServerDown = 'Test';
        TechnicalContact = 'Test';
        PreferredMOC = 'Test';
        PhoneNumber = '123456789';
        FaxNum = '12233456789';
        LastName = 'Test';
        FirstName = 'Test';
        Email = 'testing@test.com';
        Source = 'email';
        AltPhoneNum = '83625628332';
        State = 'CA'; 
        ClosureReason='Test';
        SRNumber='14520217310';
    } ***/
   

    static testMethod void caseRequestMethodTest1(){
        Test.starttest();
        setupdata1();
        //Cover caseCreation with IVR as True
        GSS_Avaya_IVR.CreateSR(CN,CountryCode, ProductName, ProblemCategory, EntitlementCode, ServerDown, TechnicalContact, PreferredMOC, PhoneNumber, FaxNum, LastName, FirstName, Email, Source, AltPhoneNum, State);
        
        //Cover caseCreation with IVR as False
        GSS_Avaya_IVR.GSS_CaseRequestInfo caseInfo = new GSS_Avaya_IVR.GSS_CaseRequestInfo();
        caseInfo  = GSS_Avaya_IVR.caseRequestMethod(CN,CountryCode,  ProductName,  ProblemCategory,
        EntitlementCode,  ServerDown,  TechnicalContact,  PreferredMOC,  PhoneNumber,
        FaxNum,  LastName,  FirstName,  Email,  Source,  AltPhoneNum,  State); 

        GSS_Avaya_IVR.CaseCreationIVR(caseInfo);
        
        //CaseCreation method with Case Request info as null
        caseInfo = null;
        GSS_Avaya_IVR.CaseCreation(caseInfo,true);
        GSS_Avaya_IVR.CaseCreationIVR(caseInfo);
        
        Test.stoptest();
    }

    static testMethod void caseRequestMethodTest2(){

        Test.starttest();
        setupdata1();
        CN = '';
        // Case Creation with CN number as null
        GSS_Avaya_IVR.CreateSR(CN,CountryCode, ProductName, ProblemCategory, EntitlementCode, ServerDown, TechnicalContact, PreferredMOC, PhoneNumber, FaxNum, LastName, FirstName, Email, Source, AltPhoneNum, State);
        Test.stoptest();

    }
// Covers QueryPhQueue and  QuerySR
    static testMethod void caseRequestMethodTest3(){
        Test.starttest();
        setupdata1();
        snum= '12345';
        snum1 = '';
        System.debug('SR Number method2...'+SRNumber);
        GSS_Avaya_IVR.QueryPhQueue(SRNumber);
        GSS_Avaya_IVR.QueryPhQueue(snum);
        GSS_Avaya_IVR.QuerySR(SRNumber);
        GSS_Avaya_IVR.QuerySR(snum);
        GSS_Avaya_IVR.QuerySR(snum1);
        Test.stoptest();
    }

    //Covers Close SR with different ClosureReason
    static testMethod void caseRequestMethodTest4(){
        Test.starttest();
        setupdata1();
        System.debug('SR Number method3...'+SRNumber);
        GSS_Avaya_IVR.CloseSR(SRNumber,'solution_provided');
        GSS_Avaya_IVR.CloseSR(SRNumber,'another_solution');
        GSS_Avaya_IVR.CloseSR(SRNumber,'duplicate');
        GSS_Avaya_IVR.CloseSR(SRNumber,'created_in_error');
        GSS_Avaya_IVR.CloseSR(SRNumber,'other_reason');
        GSS_Avaya_IVR.CloseSR(SRNumber,'');

        Test.stoptest(); 
    }
    static testMethod void caseRequestMethodTest5(){        
        Test.starttest();
        SRNumber= 'abcs';
        GSS_Avaya_IVR.CloseSR(SRNumber,'solution_provided');
        GSS_Avaya_IVR.QueryPhQueue(SRNumber);
        GSS_Avaya_IVR.QuerySR(SRNumber);        
        Test.stoptest(); 
    }
    static testMethod void caseRequestMethodTest6(){        
        Test.starttest();
        setupdata1();
        GSSIVRQset__c[] oldsettings = GSSIVRQset__c.getAll().values(); 
        delete oldsettings;
        GSSIVRQset__c newCS = new GSSIVRQset__c(Name = 'something');
        insert newCS;
        GSS_Avaya_IVR.QuerySR(SRNumber);        
        Test.stoptest(); 
    }
   

}