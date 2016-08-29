@isTest(SeeAllData=true)
 public class GSS_emailToCaseCustomerFeedbackTest{
        
    public static testMethod void testMethod1(){
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Subject';
        email.fromName = 'test test';
        email.plainTextBody = 'Data Provided in Form :: Hello, this a test email body. First Name=Pabitra Last Name=Pramanick Email=abc@abc.com Email_Verify=Yes May We Contact You?=yes Preferred Method of Contact=Email refer=me';
        envelope.fromAddress = 'user@acme.com';
        
        Test.startTest();
        GSS_emailToCaseCustomerFeedback catcher = new GSS_emailToCaseCustomerFeedback();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        Test.stopTest();   
        //System.assertEquals( result.success  ,true);
    }
    public static testMethod void testMethod2(){
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        if(GSS_Customer_Feedback_Defaults__c.getInstance('Defaults') == null){
            GSS_Customer_Feedback_Defaults__c newDefaults = new GSS_Customer_Feedback_Defaults__c();
            newDefaults.Name = 'Defaults';
            Account acc=[Select id from Account where recordType.name='End Customer' limit 1];
            if(acc != null){
                newDefaults.Account_Id__c = acc.id;
            }
            //newDefaults.Account_Id__c = '0018000001IIcpiAAD'; //for Sandbox
            //newDefaults.Account_Id__c = '0018000001IG8oAAAT'; //for production, Default Consumer Account11
            newDefaults.Licensing_Escalations_Email__c = 'licensing_escalations_dummy@vmware.com'; //for sandboxes 
            //newDefaults.Licensing_Escalations_Email__c = 'licensing_escalations@vmware.com'; //for production
            List<EmailTemplate> emailTemp = [Select id from EmailTemplate where Folder.DeveloperName = 'GSS_Email_Templates' and DeveloperName = 'GSS_Acknowledge_Customer_Feedback']; 
            if(emailTemp != null)
            {
                newDefaults.Acknowledgement_Email_Template__c = emailTemp[0].id;
            }
            OrgWideEmailAddress owda= [Select Id from OrgWideEmailAddress where Address like '%webform%' LIMIT 1];
            if ( owda != null ) {
                newDefaults.Org_Wide_Email_Address__c = owda.Id;
            }
            //newDefaults.Contact_Email__c = 'scottb2-alias@vmware.com'; //for production
            newDefaults.Contact_Email__c = 'scottb2-alias-dummy@vmware.com'; //for sandbox
            List<Group> lstGrp = [Select id from Group where Name = 'VMware Web Customer Feedback Queue'];
            if(lstGrp != null && lstGrp.size() > 0)
            {
                newDefaults.Owner_Id__c = lstGrp[0].id;
            }
            Database.insert(newDefaults);
        }
        GSS_Customer_Feedback_Defaults__c defaultDetails = GSS_Customer_Feedback_Defaults__c.getInstance('Defaults');
        
        email.subject = 'Test Subject';
        email.fromName = 'test test';
        email.plainTextBody = 'Data Provided in Form :: Hello, this a test email body. First Name=Pabitra Last Name=Pramanick Email=abc@abc.com<4 Email_Verify=Yes May We Contact You?=yes Preferred Method of Contact=Email  refer=me';
        envelope.fromAddress = 'user@acme.com';
        
        Contact con = new Contact();
        con.RecordTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Con_Cust').Record_Type_ID__c);
        con.AccountId = Id.valueOf(defaultDetails.Account_Id__c);
        con.Email = 'abc@abc.com';
        con.FirstName = 'Pabitra';
        con.LastName = 'Pramanick';
        insert con;
        
        Test.startTest();
        GSS_emailToCaseCustomerFeedback catcher = new GSS_emailToCaseCustomerFeedback();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        Test.stopTest();   
        //System.assertEquals( result.success  ,true);
    }
}