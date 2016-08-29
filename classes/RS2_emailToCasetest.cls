@isTest(seeallData = True)
public class RS2_emailToCasetest{
    
    public static list<string> emailIdList = new list<string>();
    public static Messaging.InboundEmail.BinaryAttachment inAtt; 
    public static Messaging.InboundEmail.BinaryAttachment inAtt1;
    public static Messaging.InboundEmail.BinaryAttachment inAtt2;
    public static Messaging.InboundEmail.TextAttachment attachmenttext1 = new Messaging.InboundEmail.TextAttachment();
    public static Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
    public static Messaging.InboundEmail.TextAttachment[] TextAttachments = new Messaging.InboundEmail.TextAttachment[]{attachmenttext1,attachmenttext};
    public static Messaging.InboundEmail.BinaryAttachment binaryAttachment1 = new Messaging.InboundEmail.BinaryAttachment();
    public static Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[]{binaryAttachment1};

    public static Messaging.InboundEmail createEmail(string htmlbody,string plainTextBody, Messaging.InboundEmail.BinaryAttachment[] binaryAttachment, Messaging.InboundEmail.TextAttachment[] textAttachment){

        binaryAttachment1.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('plainTextBody'),Blob.valueOf('test_key'));
        binaryAttachment1.Body = b;
        binaryAttachments[0] =  binaryAttachment1 ;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        emailIdList.add('informatica@xv.com');
        email.toAddresses = emailIdList;      
        email.ccAddresses = emailIdList;      
        email.subject = 'test &&&:email-to-case';
        email.plaintextbody = plainTextBody;
        email.TextAttachments = TextAttachments ;
        email.binaryAttachments = binaryAttachments;
        return email;

    }
    
     public static Messaging.InboundEmail createEmail1(string htmlbody,string plainTextBody, Messaging.InboundEmail.BinaryAttachment[] binaryAttachment, Messaging.InboundEmail.TextAttachment[] textAttachment){
        attachmenttext1.body = 'Test body';
        attachmenttext1.fileName = 'TestFile.txt';
        attachmenttext1.mimeTypeSubType = 'texttwo/plain';
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        emailIdList.add('informatica@xv.com');
        email.toAddresses = emailIdList;      
        email.ccAddresses = emailIdList;      
        email.subject = 'Opportunity Load &&& :(DEV15) RS2-OPPORTUNITY LOAD DATA ERR';
        email.htmlbody = htmlbody;
        email.TextAttachments = TextAttachments;
        email.binaryAttachments = binaryAttachments;
        return email;
    }
    public static Messaging.InboundEmail createEmail2(string htmlbody,string plainTextBody, Messaging.InboundEmail.BinaryAttachment[] binaryAttachment, Messaging.InboundEmail.TextAttachment[] textAttachment){
        attachmenttext.body = 'Test body';
        attachmenttext.fileName = 'TestFile.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        binaryAttachment1.Filename = 'test.pdf';
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        emailIdList.add('informatica@xv.com');
        email.toAddresses = emailIdList;      
        email.ccAddresses = emailIdList;      
        email.subject = 'test &&& :email';
        email.plaintextbody = plainTextBody;
        email.TextAttachments = textAttachment;
        email.binaryAttachments = binaryAttachments;
        return email;
    }
    
    public static Messaging.InboundEnvelope createEnv(string toAddress){
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'tannu.saigal@accenture.com';
        env.toAddress = toAddress;
        return env;
    }

    public static testmethod void setupdataforsingleopp(){
        string body =  '<html><body>/n<h1>Account & Contact Information</h1>/n<h4>Account Name: GSS Test Account </h4></body></html>';    
        Messaging.InboundEmail email = RS2_emailToCasetest.createEmail(body,null,null,TextAttachments);
        Messaging.InboundEnvelope env = RS2_emailToCasetest.createEnv('renewalshotlineapacdev@accenture.com');  
        Test.startTest();
		GSS_UtilityClass.isAfterInsert_Case = true;		
		GSS_UtilityClass.isBeforeUpdate_Case = true ;
		GSS_UtilityClass.isAfterUpdate_Case = true ;
		GSS_UtilityClass.isBeforeInsert_Case = true ;
        RS2_emailToCase rsemailtocas = new RS2_emailToCase();
        rsemailtocas.handleInboundEmail(email, env);
        Test.stopTest();

    }
    
    public static testmethod void setupdataformultipleopp(){
        string plainTextBody = 'Account & Contact Information\nAccount Name: 4Refuel Canada Ltd\nRequestor Email: bbarmi@4refuel.com\nAccount Number: 115465167\nRequestor Name: Bhag Barmi\nRequestor Phone: 604--513-0386\nSupport Contracts: ,\nRenewal Information\nSupport Level: Basic\nQuote Duration: 1 year\nCo-Term Date:2014-03-29\nCo-Term Consolidation:\nEstimate Purchase Date: 2014-03-29\nAdditional Information\nPreferred Partner: Use the same partner as the last time.\nAdditional Comments: test';
        string toAddress = 'informatica@test.com';
        Messaging.InboundEmail email = RS2_emailToCasetest.createEmail(null,plainTextBody,binaryAttachments,null);
        Messaging.InboundEnvelope env = RS2_emailToCasetest.createEnv(toAddress);
        Test.startTest();
		GSS_UtilityClass.isAfterInsert_Case = true;		
		GSS_UtilityClass.isBeforeUpdate_Case = true ;
		GSS_UtilityClass.isAfterUpdate_Case = true ;
		GSS_UtilityClass.isBeforeInsert_Case = true ;
        RS2_emailToCase rsemailtocas1 = new RS2_emailToCase();
        rsemailtocas1.handleInboundEmail(email, env);
        
        Test.stopTest();
    } 
    public static testmethod void setupdatafornoopp(){
        set<id> ids = new Set<Id>();
        string plainTextBody = 'Account & Contact Information \r\n Account Name: 4Refuel Canada Ltd\nRequestor Email: bbarmi@4refuel.com\nAccount Number: 115465167\nRequestor Name: Bhag Barmi\nRequestor Phone: 604--513-0386\nSupport Contracts: 7638473\nRenewal Information\nSupport Level: Basic\nQuote Duration: 1 year & 3 year\nCo-Term Date:2014-03-29\nCo-Term Consolidation:\nEstimate Purchase Date: 2014-03-29\nAdditional Information\nPartnerID:56157380 \nAdditional Comments: test';
        string htmlbody =plainTextBody ;
        string toAddress = 'myvmware@test.com';
        List<case> caseInsertList = caseAgeTestData();
        Messaging.InboundEmail email = RS2_emailToCasetest.createEmail1(null,plainTextBody,binaryAttachments,null);
        Messaging.InboundEmail email2 = RS2_emailToCasetest.createEmail1(htmlbody,null,binaryAttachments,null);
        Messaging.InboundEmail email3 = RS2_emailToCasetest.createEmail2(null,plainTextBody,binaryAttachments,null);
        emailIdList.add('eee@abc.com');        
        email.toAddresses = emailIdList; 
        Messaging.InboundEnvelope env = RS2_emailToCasetest.createEnv(toAddress);
        List<Case> cs = [select id, CaseNumber, CreatedById,CreatedBy.Name, sub_status__c,email_address__c from case where origin = 'system' and recordtype.name = 'Renewal Operations' limit 1];
        cs[0].email_address__c = 'test@gmail.com';
        cs[0].Request_Type__c = 'Single Quote';
        cs[0].EA_Name__c = 'test';
        cs[0].Vmware_Contract_Number__c = '12454587';
        cs[0].Contract_Start_Date__c = System.Today();
        cs[0].Contract_End_Date__c = System.Today();
        cs[0].GSS_Support_Level__c = 'Basic';
        cs[0].Duration_Level__c = '1 Year';
        cs[0].sub_status__c  = 'Partner/End User';
        cs[0].status  = 'On Hold';
        
        update cs[0];
		list<case> caslist = new list<case>();
        list<Attachment> ac = [select id, Name, Body from Attachment where parentId =: cs[0].id limit 1];        
		Id RecordTypeforRnwlOperations = Schema.SObjectType.case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId(); 
		caslist.add(new case( RecordTypeId = RecordTypeforRnwlOperations, Request_Type__c = 'Quote Consolidation',Origin = 'RCM', Status = 'Closed', Vmware_Contract_Number__c = '123496', GSS_Support_Level__c = 'Basic', Duration_Level__c = '1 year'));
		
        Test.startTest();
		GSS_UtilityClass.isAfterInsert_Case = true;		
		GSS_UtilityClass.isBeforeUpdate_Case = true ;
		GSS_UtilityClass.isAfterUpdate_Case = true ;
		GSS_UtilityClass.isBeforeInsert_Case = true ;
		RS2_SpamEmailToCaseUtility.carryDMLInsert(caslist);
        
		RS2_emailToCase rsemailtocas1 = new RS2_emailToCase();
        RS2_E2CUtilityClass.insertAttachment(email,caseInsertList, true);
        rsemailtocas1.handleInboundEmail(email, env);
        RS2_E2CUtilityClass.processEmailToCreateCase(email,env);
        RS2_E2CUtilityClass.processEmailToCreateCase(email2,env);
		//RS2_SpamEmailToCaseUtility.processSpamEmailToCreateCase(email,env, null);
        RS2_E2CUtilityClass.createSampleSpam(email,env);
        RS2_E2CUtilityClass.createSampleSpam(email2,env);
        RS2_E2CUtilityClass.splitEmailBody(plainTextBody);
        RS2_E2CUtilityClass.insertAttachment(email2,caseInsertList, true);
        //RS2_E2CUtilityClass.emailNotificationMgmt(caseInsertList);
		RS2_E2CUtilityClass.emailNotificationMgmt(cs);
        RS2_E2CUtilityClass.createSpamEmail(null,email,env);
        if(cs != null && !cs.isEmpty()){
        ids.add(cs[0].id);
        RS2_E2CUtilityClass.insertSpamAttachment(cs[0].id,email);
        RS2_E2CUtilityClass.emailNotificationMgmt(cs);
        RS2_E2CUtilityClass.returnCaseList(ids);
        }
        Test.stopTest();
  
    }
    public static testmethod void spamEmailTest(){
        set<id> ids = new Set<Id>();
        RS2_QuotingTestDataFactory.returnSpamRecords();
        string plainTextBody = 'Account & Contact Information \r\n Account Name: 4Refuel Canada Ltd\nRequestor Email: bbarmi@4refuel.com\nAccount Number: 115465167\nRequestor Name: Bhag Barmi\nRequestor Phone: 604--513-0386\nSupport Contracts: 7638473\nRenewal Information\nSupport Level: Basic\nQuote Duration: 1 year & 3 year\nCo-Term Date:2014-03-29\nCo-Term Consolidation:\nEstimate Purchase Date: 2014-03-29\nAdditional Information\nPartnerID:56157380 \nAdditional Comments: test';
        string htmlbody =plainTextBody ;
        string toAddress = 'myvmware@test.com';
        List<case> caseInsertList = caseAgeTestData();
        Messaging.InboundEmail email = RS2_emailToCasetest.createEmail1(null,plainTextBody,binaryAttachments,null);
        Messaging.InboundEmail email2 = RS2_emailToCasetest.createEmail1(htmlbody,null,binaryAttachments,null);
        Messaging.InboundEmail email3 = RS2_emailToCasetest.createEmail2(null,plainTextBody,binaryAttachments,null);
        emailIdList.add('eee@abc.com');        
        email.toAddresses = emailIdList; 
        Messaging.InboundEnvelope env = RS2_emailToCasetest.createEnv(toAddress);
        List<Case> cs = [select id, CaseNumber, CreatedById,CreatedBy.Name, email_address__c from case where origin = 'system' and recordtype.name = 'Renewal Operations' limit 1];
        cs[0].email_address__c = 'test@gmail.com';
        cs[0].Request_Type__c = 'Single Quote';
        cs[0].EA_Name__c = 'test';
        cs[0].Vmware_Contract_Number__c = '12454587';
        cs[0].Contract_Start_Date__c = System.Today();
        cs[0].Contract_End_Date__c = System.Today();
        cs[0].GSS_Support_Level__c = 'Basic';
        cs[0].Duration_Level__c = '1 Year';
        cs[0].sub_status__c  = 'Partner/End User';
        cs[0].status  = 'On Hold';
        
        update cs[0];
        Test.startTest();		
		GSS_UtilityClass.isAfterInsert_Case = true;		
		GSS_UtilityClass.isBeforeUpdate_Case = true ;
		GSS_UtilityClass.isAfterUpdate_Case = true ;
		GSS_UtilityClass.isBeforeInsert_Case = true ;
        RS2_SpamEmailToCaseUtility.processE2CForOpptyId(email);
        Test.StopTest();
    }
    public static list<case> caseAgeTestData(){
        RTFinder rtf=RTFinder.getRTFinder();
        Id RecordTypeforRnwlOperations = Schema.SObjectType.case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId(); 
        list<case> caseList = new list<case>();
        List<BusinessHours> bhs = [select id from BusinessHours where IsDefault=true];
        caseList.add(new case( RecordTypeId = RecordTypeforRnwlOperations, Request_Type__c = 'Quote Consolidation',Origin = 'RCM', Status = 'Closed', Vmware_Contract_Number__c = '123496', GSS_Support_Level__c = 'Basic', Duration_Level__c = '1 year'));
        /**      
        try{
            Insert caslist;
        }
        catch(exception e){
           system.debug('ee  '+e);
        }**/
        // 
        caseList = [select CreatedDate,Status, sub_status__c, Email_Address__c,ClosedDate,RS2CaseAgeHrs__c, Date_Completed__c,Id from Case where status = 'closed' and recordtypeid =: RecordTypeforRnwlOperations  limit 1];
        return caseList;
    }       
}