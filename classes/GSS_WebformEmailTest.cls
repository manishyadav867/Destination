/** 
* Class Name : GSS_WebformEmailTest
* Author : Nierrbhayy
* Description : Test class for GSS_WebformEmail, GSS_WebformEmailUtility and GSS_WebformEmailSyncBatch
**/

@isTest(seeAllData=true)
global class GSS_WebformEmailTest{

    private static Messaging.InboundEmail email = new Messaging.InboundEmail();
    private static Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    private static GSS_WebformEmail catcher ;
    private static List<String> emailToAddress ;
    private static Messaging.InboundEmail.BinaryAttachment[] binaryAttachments ;
    private static Messaging.InboundEmail.BinaryAttachment binaryAttachment;
    private static Messaging.InboundEmail.BinaryAttachment attachment ;
    private static Messaging.InboundEmail.TextAttachment[] textAttachments ;
    private static Messaging.InboundEmail.TextAttachment textAttachment;
    private static Messaging.InboundEmail.TextAttachment tAttachment ;
    private static Messaging.InboundEmail.Header hditem;
                  
    /* setUpData() method sets intial data for configuring email, attaches binary and text attachments */                         
    static void setUpData(){
    
        ID recTypeCaseId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        Case c1 = new Case(recordtypeId= recTypeCaseId,GSS_Support_Level__c='Testing',Priority='1 - Critical',GSS_Problem_Category__c='OS');
        insert c1;
        string refgenx=GSS_EmailToCaseUtility.generateRefId(c1.id);
        
        emailToAddress = new List<String>();
        emailToAddress.add('testpurposeonly@vvmware.com');
        emailToAddress.add('2ndDuplicateUser@test.com');
        email.ccAddresses = emailToAddress;
        email.subject = 'case no ref: ' + refgenx;
        email.plainTextBody = 'case no ref: :ref';
        email.htmlBody = 'case no ref: :ref' ;
        envelope.fromAddress = 'qafedralsupport@test.com';    
        envelope.ToAddress = 'testpurposeonly@vvmware.com';    
        email.toAddresses = emailToAddress;
        email.fromAddress = 'testsupportx@test.com';
        binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[2];  
        binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'),
        Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;

        attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        binaryAttachments[1] = attachment ;
         
        email.binaryAttachments =    new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        textAttachments = new Messaging.InboundEmail.TextAttachment[2];  
        textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.Filename = 'test.txt';
        b = Crypto.generateMac(algorithmName, Blob.valueOf('test'),
        Blob.valueOf('test_key'));
        textAttachment.Body = 'Sandbox: VMware acknowledges your Support Request';
        textAttachments[0] =  textAttachment ;

        tAttachment = new Messaging.InboundEmail.TextAttachment();
        tAttachment.body = 'Sandbox: VMware acknowledges your Support Request';
        tAttachment.fileName = 'textfile.txt';
        tAttachment.mimeTypeSubType = 'text/plain';
        TextAttachments[1] = tAttachment ;
         
        email.TextAttachments =    new Messaging.inboundEmail.TextAttachment[] { tAttachment };

        hditem= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        hditem.name='Date';
        hditem.value='Sun, 16 Aug 2015 14:08:37 -0700';
        email.headers[0]=hditem;
        
        //inserting Webform Filters
        List <GSS_Webform_Filters__c> filterList = new List <GSS_Webform_Filters__c>();
        GSS_Webform_Filters__c filter1 = new GSS_Webform_Filters__c(Name='testClass_subject',Active__c=true,Subject__c=true,rule__c='bypass');
        GSS_Webform_Filters__c filter2 = new GSS_Webform_Filters__c(Name='testClass_fromEmail',Active__c=true,From_Email__c=true,rule__c='bypass@bypass.com');
        GSS_Webform_Filters__c filter3 = new GSS_Webform_Filters__c(Name='testClass_body',Active__c=true,Body__c=true,rule__c='bypass body');
        filterList.add(filter1);
        filterList.add(filter2);
        filterList.add(filter3);
        insert filterList;
         Scheduler_Optimizer__c Custlist1= Scheduler_Optimizer__c.getInstance('GSS_WebformEmailSyncBatchRecord');
        if(Custlist1==null){
            Scheduler_Optimizer__c sc=new Scheduler_Optimizer__c();
            sc.name='GSS_WebformEmailSyncBatchRecord';
            sc.On_Off_Switch__c=True;
            sc.Scheduler_Job_Name__c = 'GSS_WebformEmailSyncBatch';
            sc.Time_in_Minutes_0_59__c=10;
            insert sc;
        }
    }
        
    static void EmailToCase(){
        catcher = new GSS_WebformEmail();
    }

    static testMethod void validEmailwithRefIdTest(){
    
        setUpData();
        
        Test.startTest();
        
        EmailToCase();
        catcher.handleInboundEmail(email, envelope);  
        
        Test.stopTest();

    }
    
    static testMethod void validEmailwithInvalidRefIdTest(){
    
        setUpData();
        
        Test.startTest();
        email.subject = 'Brand New Subject: No Ref ID';
        EmailToCase();
        catcher.handleInboundEmail(email, envelope);  
        
        Test.stopTest();

    }
    
    static testMethod void validEmailwithFilterTest(){
    
        setUpData();
        
        Test.startTest();
        email.subject = 'bypass me';
        EmailToCase();
        catcher.handleInboundEmail(email, envelope);  
        
        Test.stopTest();

    }
    
    static testMethod void webformEmailSyncBatchTest1(){
    
        ID recTypeCaseId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        Case c1 = new Case(recordtypeId= recTypeCaseId,GSS_Support_Level__c='Testing',Priority='1 - Critical',GSS_Problem_Category__c='OS');
        insert c1;
        string refgenx=GSS_EmailToCaseUtility.generateRefId(c1.id);
        
        Webform_Email__c w1=new Webform_Email__c(Subject__c='test '+ refgenx,Sync_Attempts__c=1,Sync_Error_Detail__c='Error',Mark_For_Sync__c=true,Tagged_to_Case__c=false,ParentId__c=c1.id);
        
        insert w1;
        Test.startTest();
        
        DataBase.executeBatch(new GSS_WebformEmailSyncBatch(),1); 
        
        Test.stopTest();

    }
    
    static testMethod void webformEmailSyncBatchTest2(){
        
        Webform_Email__c w2=new Webform_Email__c(Subject__c='test',Sync_Attempts__c=1,Sync_Error_Detail__c='Error',Mark_For_Sync__c=true,Tagged_to_Case__c=false);
        insert w2;
        Test.startTest();
        
        DataBase.executeBatch(new GSS_WebformEmailSyncBatch(),1); 
        
        Test.stopTest();

    }
    
    static testMethod void webformEmailSyncBatchTest3(){
    
        ID recTypeCaseId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        Case c1 = new Case(recordtypeId= recTypeCaseId,GSS_Support_Level__c='Testing',Priority='1 - Critical',GSS_Problem_Category__c='OS');
        insert c1;
        string refgenx=GSS_EmailToCaseUtility.generateRefId(c1.id);
        
        Webform_Email__c w3=new Webform_Email__c(Subject__c='test '+ refgenx,Sync_Attempts__c=1,Sync_Error_Detail__c='Error',Mark_For_Sync__c=true,Tagged_to_Case__c=false);
        
        insert w3;
        Test.startTest();
        
        DataBase.executeBatch(new GSS_WebformEmailSyncBatch(),1); 
        
        Test.stopTest();

    }

}