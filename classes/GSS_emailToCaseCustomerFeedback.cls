/** 
  * Class Name        : GSS_emailToCaseCustomerFeedback
  * CR Description    : SR creation and update based on online form
  * CR #              : CR-00138183
  * Created Date      : 07-Apr-2016
  * Created By        : Accenture
  ************************Version Updates************************************************
  Updated Date(DD/MM/YYYY)         Updated By     CR/Defect Number         Comments
  * 2/08/2016                    Suresh Kumar    CR-00139089              change web to web feedback
************************Version Updates************************************************/

global class GSS_emailToCaseCustomerFeedback implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try
        {
            //fetch the defaults details from the custom settings
            Id customerSupportRecTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_LIC').Record_Type_ID__c);
            Id customerContactRecTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Con_Cust').Record_Type_ID__c);    
            GSS_Customer_Feedback_Defaults__c defaultDetails = GSS_Customer_Feedback_Defaults__c.getInstance('Defaults');
            
            //fetching the details entered in the form from the email
            String plainEmailBody = email.plaintextbody;
            Integer spos =  plainEmailBody.indexOf('Data Provided in Form');
            Integer epos = plainEmailBody.indexOf('refer=');
            String dataProvidedInForm = plainEmailBody.subString(spos,epos);
            
            //intialise a new case and add details for the mandatory details
            Case c = new Case();
            c.RecordTypeId = customerSupportRecTypeId;
            c.Status = 'New';
            c.Sub_Status__c = 'Inbound message received';
            c.Priority = '3 - Medium';
            c.GSS_Problem_Category__c = 'Licensing';
            c.GSS_Vcat__c = 'My VMware Help';
            c.GSS_Vsubcat__c = 'Portal information';
            c.GSS_Language__c = 'ENG';
            c.Subject = 'Form Submittal: VMWare - Customer_Feedback';
            c.Description = dataProvidedInForm;
            c.Origin = 'Web Feedback';//CR-00139089 
            c.OwnerId = Id.valueOf(defaultDetails.Owner_Id__c);
            c.GSS_Business_unit__c = (GSS_Queues_business_Unit__c.getInstance('VMware Web Customer Feedback Queue') != null? GSS_Queues_business_Unit__c.getInstance('VMware Web Customer Feedback Queue').Business_Unit__c : '' );
            
            //fetching the Contacts for Contact Name and Customer Contact Name
            List<String> lstEmails = new List<String>();
            lstEmails.add(defaultDetails.Contact_Email__c);
            String customerContactEmail = fetchFieldResponse(dataProvidedInForm, 'Email=', 'Email_Verify=');
            if(customerContactEmail.contains('<'))
            {
                customerContactEmail = customerContactEmail.subString(0, customerContactEmail.indexOf('<'));
            }
            lstEmails.add(customerContactEmail);
            Boolean customerContactExists = false;
            for(Contact con : [Select id, Name, Email, Phone from Contact where email in :lstEmails])
            {
                if(con.email.equals(defaultDetails.Contact_Email__c))
                {
                    c.ContactId = con.id;
                }
                else
                {
                    customerContactExists = true;
                    c.Customer_Contact_Name__c = con.id;
                    c.Customer_Contact_Phone__c = con.Phone;
                    c.Customer_Contact_Email__c = con.Email;
                }
            }
            
            //if the customer contact does not exist, create one under Vmware.com Account and assign the newly created contact to the Customer Contact Name
            if(!customerContactExists)
            {
                Contact con = new Contact();
                con.RecordTypeId = customerContactRecTypeId;
                con.Email = customerContactEmail;
                con.AccountId = Id.valueOf(defaultDetails.Account_Id__c);
                con.FirstName = fetchFieldResponse(dataProvidedInForm, 'First Name=', 'Last Name=');
                con.LastName = fetchFieldResponse(dataProvidedInForm, 'Last Name=', 'Email=');
                Database.insert(con);
                c.Customer_Contact_Name__c = con.id;
                c.Customer_Contact_Email__c = customerContactEmail;
            }
            String contactPermission = fetchFieldResponse(dataProvidedInForm, 'May We Contact You?=', 'Preferred Method of Contact=');
            c.Email_Note__c = contactPermission;
            Database.insert(c);
            System.debug('The newly created case --- ' + c.id);
            
            //Send email to  licensing_escalations@vmware.com
            Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            toAddresses.add(defaultDetails.Licensing_Escalations_Email__c);
            mailObj.setToAddresses(toAddresses);
            mailObj.setSubject(email.subject);
            mailObj.setHtmlBody(email.htmlBody);
            Messaging.SendEmailResult[] resultObj = new Messaging.SendEmailResult[]{};
            Messaging.SingleEmailMessage[] mailObjects = new Messaging.SingleEmailMessage[] { mailObj};
            
            
            //Draft the acknowledge email if the user has opted to get updates
            if(contactPermission.equalsIgnoreCase('yes'))
            {
                OrganizationProperties__c orgProperties = OrganizationProperties__c.getOrgDefaults();
                Id contactId = orgProperties.Default_Contact__c;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String toAddress = 'test@test.com';
                mail.setTemplateId(Id.valueOf(defaultDetails.Acknowledgement_Email_Template__c));
                mail.setWhatId(c.Id);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(contactId);
                mail.setToAddresses(new String[] {toAddress });
                if(!Test.isRunningTest()){
                  Savepoint sp = Database.setSavepoint();
                  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                  Database.rollback(sp);
                }
                //get the email subject & body
                String subjectEmail = mail.getSubject() ;
                String bodyEmail = mail.getplaintextbody();
                if(Test.isRunningTest())
                {
                    subjectEmail = 'Test Subject';
                    bodyEmail = 'Test Body';
                }
                
                Messaging.SingleEmailMessage mailObj1 = new Messaging.SingleEmailMessage(); 
                List<String> toAddresses1 = new List<String>();
                toAddresses1.add(customerContactEmail);
                mailObj1.setToAddresses(toAddresses1);
                mailObj1.setplaintextbody(bodyEmail);
                mailObj1.setSubject(subjectEmail);
                mailObj1.setBccSender(false);
                mailObj1.setSaveAsActivity(false);
                mailObj1.setOrgWideEmailAddressId(defaultDetails.Org_Wide_Email_Address__c);
                mailObjects.add(mailObj1);
            }
            
            //Send the emails
            resultObj = Messaging.sendEmail(mailObjects);
            result.success = true;
        }
        catch (Exception ex) 
        {
          System.debug('error is --- ' + ex);
          result.success = false;
          CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'Case','GSS_emailToCaseCustomerFeedback');
        }
      return result;
  }
  
  
  /*
    Method Name : fetchFieldResponse
    Description : Function to take out the sub-string between first & second label from the string provided
    Params : String, String, String
    Return type : string
  */
  private string fetchFieldResponse(String searchString, String firstLabel, String secondLabel)
  {
    Integer firstLabelpos = searchString.indexOf(firstLabel);
    Integer secondLabelpos = searchString.indexOf(secondLabel);
    String resultString = searchString.subString(firstLabelpos + firstLabel.length(), secondLabelpos ).trim();
    return resultString;
  }
}