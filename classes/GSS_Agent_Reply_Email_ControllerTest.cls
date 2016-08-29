@isTest(seealldata=true)
public class  GSS_Agent_Reply_Email_ControllerTest{
    
    public static Case cc;
    public static EmailMessage em;
    public static Attachment att;
    public static EmailTemplate validEmailTemplate;
    
    public static void preparetestdata(){
     if(GSS_Configuration_Properties_list__c.getInstance('EmailTemplateFolder_Id')==null){
            Folder fldr = [select id from folder limit 1];
            insert new GSS_Configuration_Properties_list__c(name='EmailTemplateFolder_Id',setting_value__c=String.valueof(fldr.id));
        }
   
        //Creating Account for Customer
        Id recTypeAccId=Id.valueOf(Record_Type_Settings__c.getValues('GSS_ACC_EC').Record_Type_ID__c);
        Account ac1 = new Account(Name='AccountTest1',recordtypeId= recTypeAccId, Country__c='INDIA' );
        insert ac1;
    
        //Creating Contact for a customer
        Id recTypeConId=Id.valueOf(Record_Type_Settings__c.getValues('GSS_CON_CC').Record_Type_ID__c);
        Contact ct1 = new Contact(FirstName='spanEmailContact',LastName='Test1',Email='email@spanEmail.com',recordtypeId=recTypeConId);
        ct1.accountid=ac1.id;
        insert ct1;

        cc = new Case();
        // Test data for case
        cc.RecordTypeId=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
        
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '4 - Low';
        cc.Status = 'New';
        cc.Sub_Status__c = 'Unassigned';
        cc.Subject = ' Task Test Subject';
        cc.Description = 'Test  Case Description';
        cc.Technical_Contact_Name__c='Technical Test';
        cc.Technical_Contact_Email__c='techconemail@test.com';
        cc.contactid=ct1.id;
        
        insert cc;
        
        SR_Comments__c s = new SR_Comments__c();
        s.Technical_Contact_Name__c = 'Test Technical Contact';
        s.Notes_Type__c ='Management';
        s.Note_Description__c = 'Test Management Description';
        s.SR_Number__c = cc.Id;
        insert s;          
         
        document d=new document();
        d.name='Sumit Arora';
        d.AuthorId = UserInfo.getUserId();
        d.folderID=UserInfo.getUserId();
        insert d;
         
        EmailMessage emj = new EmailMessage();
        emj.FromAddress= 'testfrom@email.com';
        emj.ToAddress = 'test@email.com';
        emj.Subject = 'test';
        emj.TextBody = 'This is a test Email';
        
        emj.ParentId = cc.Id; 
        insert emj;
        em=emj;
        
        String attname = 'StringToBlob';
        Blob attbody = Blob.valueof(attname);
        
        Attachment newAtt = new Attachment();
        newAtt.Name = 'Test';
        newAtt.body=attbody;
        newAtt.parentid=emj.id;
        newAtt.ContentType='content';
        insert newAtt;
        att=newAtt;
        
        User Admin = [SELECT Id FROM User WHERE Name='Case Admin'];
        if(Admin!=null){
            System.runAs(Admin){       
                validEmailTemplate = new EmailTemplate();
                validEmailTemplate.isActive = true;
                validEmailTemplate.Name = 'My Personal TEst template';
                validEmailTemplate.DeveloperName = 'My_Personal_TEst_template_random';
                validEmailTemplate.TemplateType = 'text';
                validEmailTemplate.FolderId = UserInfo.getUserId();
                validEmailTemplate.Subject = 'Your Subject Here';
                insert validEmailTemplate;
            }
        }
    }
    
    
    public static testMethod void test2(){

         Test.starttest();
        GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;
 preparetestdata();
        ByPassTrigger.userCustomMap('updateEmailCount','EmailMessage');

        PageReference pageref =Page.GSS_Agent_Reply_Email;
        Test.setCurrentPage(pageref); 
        pageref.getParameters().put('cid', cc.id);
        pageref.getparameters().put('deletefile','deletefile'); 
        pageRef.getParameters().put('tab','SR Management');
        pageRef.getParameters().put('reply','1');
        pageRef.getParameters().put('fw','1');
        GSS_Agent_Reply_Email_Controller cobj1 = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));

        pageref.getParameters().put('ID', cc.id);
        System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));

        GSS_Agent_Reply_Email_Controller tobj = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));
        //tobj.case_id=cc.id;
       
        
       
        tobj.newAttachments=new List<Attachment>{new attachment()};
        tobj.addTo='test1@email.com';
        tobj.To='test2@email.com';
        tobj.emmes.CcAddress='test@email.com';
        tobj.emmes.BccAddress='test@email.com';

        //tobj.setTempValue();
        tobj.genRefID();
    
        String attname = 'StringToBlob';
        Blob attbody = Blob.valueof(attname);
        tobj.attbody=attbody ;
        tobj.attname=attname;
        tobj.setreandfw();

        tobj.saveAttachment();
        tobj.save();
        tobj.addmore();
        

        tobj.cc='test1@email.com';
        tobj.bcc='test2@email.com';
        tobj.addto='test3@email.com';
        tobj.to='test4@email.com';
        tobj.snipemail();
       // tobj.reply();
        Test.stopTest();

    }
      public static testMethod void test1(){  
       Test.starttest();
         GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;
preparetestdata();
        ByPassTrigger.userCustomMap('updateEmailCount','EmailMessage');

        PageReference pageref =Page.GSS_Agent_Reply_Email;
        Test.setCurrentPage(pageref); 
        pageref.getParameters().put('cid', cc.id);
        pageref.getparameters().put('deletefile','deletefile'); 
        pageRef.getParameters().put('tab','SR Management');
        pageRef.getParameters().put('reply','1');
        pageRef.getParameters().put('fw','1');
        GSS_Agent_Reply_Email_Controller cobj1 = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));

        pageref.getParameters().put('ID', cc.id);
        System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));

        GSS_Agent_Reply_Email_Controller tobj = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));
      
     
      
      
        
        tobj.done();
       /* tobj.template2();
        tobj.template3();
        tobj.template4();
        tobj.template5();
        tobj.deleteDocs();*/
        tobj.deleteAttachment();
        tobj.getMyPersonalTemplateOptions();
        if(validEmailTemplate!=null){
            tobj.t1=validEmailTemplate.id;
            tobj.template1();
        }
         Test.stopTest();
      }
       public static testMethod void test4(){  
       Test.starttest();
         GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;
preparetestdata();
        ByPassTrigger.userCustomMap('updateEmailCount','EmailMessage');

        PageReference pageref =Page.GSS_Agent_Reply_Email;
        Test.setCurrentPage(pageref); 
        pageref.getParameters().put('cid', cc.id);
        pageref.getparameters().put('deletefile','deletefile'); 
        pageRef.getParameters().put('tab','SR Management');
        pageRef.getParameters().put('reply','1');
        pageRef.getParameters().put('fw','1');
        GSS_Agent_Reply_Email_Controller cobj1 = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));

        pageref.getParameters().put('ID', cc.id);
        System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));

        GSS_Agent_Reply_Email_Controller tobj = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));

       tobj.template2();
         tobj.template3();
          tobj.getGSSTemplateOptions();
        tobj.setSelected_Template();
         tobj.getStatus();
        tobj.getSubStatus();
        tobj.displayError('Error');
      
         Test.stopTest();
      }
       public static testMethod void test3(){  
       Test.starttest();
         GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;
preparetestdata();
        ByPassTrigger.userCustomMap('updateEmailCount','EmailMessage');

        PageReference pageref =Page.GSS_Agent_Reply_Email;
        Test.setCurrentPage(pageref); 
        pageref.getParameters().put('cid', cc.id);
        pageref.getparameters().put('deletefile','deletefile'); 
        pageRef.getParameters().put('tab','SR Management');
        pageRef.getParameters().put('reply','1');
        pageRef.getParameters().put('fw','1');
        GSS_Agent_Reply_Email_Controller cobj1 = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));

        pageref.getParameters().put('ID', cc.id);
        System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));

        GSS_Agent_Reply_Email_Controller tobj = new GSS_Agent_Reply_Email_Controller(new ApexPages.standardController(em));

        tobj.template4();
        tobj.template5();
      
       
        tobj.deleteDocs();
        tobj.getUser();
        
         Test.stopTest();
      }
}