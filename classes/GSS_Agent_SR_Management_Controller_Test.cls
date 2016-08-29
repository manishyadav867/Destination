/*********************************************************************
* Class Name : GSS_Agent_SR_Management_Controller_Test
* Purpose    : Controller for Action Page
*              
* Author            Date            Comments        
* Accenture     16-May-2014        GSS Agent Console Project
* ********************************************************************/

@isTest(seealldata=true)

public class  GSS_Agent_SR_Management_Controller_Test{
     public static User u;
     public static case cc;
     public static List<case> caseCreated; 
     public static CaseTeamTemplateRecord casettr;
     public static CaseTeamTemplate casett;
     public static CaseTeamMember CTM;
     public static testMethod void testGSS_Agent_SR_Management_Controller(){
     PageReference pageref =Page.GSS_Agent_SR_Management;
     Test.setCurrentPage(pageref); 
     
     BB8_DataFactory.createCustomSettings();
        BB8_DataFactory.addEmailTemplateForMilestones();
        BB8_DataFactory.insertBB8IntegrationFields();
        BB8_DataFactory.insertBB8IntegrationFields();
System.runAs(new user (Id =userinfo.getuserid())) {  
      Account lstAccount = new Account();
        
        lstAccount.Name = 'Test1';
        lstAccount.Partner_ID__c = '1';
        lstAccount.RecordTypeId = recursive.PartnerAccountRecType;
        insert lstAccount;
        
      
     
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        u = new User(Alias = 'UsWF', Email='standarduser@testWForg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing_WF', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorgWF.com', Division='AMER');
        insert u; 
     
     Test.startTest();
     
     
     
     
     Entitlement ent = new Entitlement();
     ent.Name ='carrier grade Support';
     ent.GSS_Entitlement_Code__c ='CGS';
     ent.GSS_Entitlement_Status__c = 'Active';
     ent.AccountId = lstAccount.id;
     insert ent;
     
     
      cc = new Case();
       // Test data for case
        cc.RecordTypeId=[select Id from RecordType where SobjectType='Case' and Name='GSS Technical Support'].id;
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '4 - Low';
        cc.Status = 'New';
        cc.Sub_Status__c = 'Unassigned';
        cc.Subject = ' Task Test Subject';
        cc.Description = 'Test  Case Description';
        cc.Technical_Contact_Name__c='Technical Test';
        cc.entitlementid= ent.id;
        cc.First_Response_Date__c=system.now();
        cc.GSS_First_Response_Due_Date__c= system.now();
        insert cc;
        
        caseCreated = [select RecordTypeId,GSS_Support_Level__c,First_Response_Date__c,GSS_First_Response_Due_Date__c,GSS_First_Response_Due_Inn__c ,GSS_First_Resp_Met__c,GSS_Problem_Category__c,Priority,Status,Sub_Status__c,Subject,Description,Technical_Contact_Name__c,
        entitlementid,GSS_Entitlement_Code__c from case where id=:cc.id];
        
        Case_SLA__c sla = new Case_SLA__c();
        sla.Case__c = cc.id;
        sla.Final_correction_actual__c = system.now();
        sla.Final_Correction_due__c = system.now();
        sla.First_Response_Due_Date__c = system.now();
        sla.First_Response_Due_In__c = system.now();
        sla.Last_Stopped_Time__c = system.now();
        sla.RCA_Due__c = system.now();
        sla.RCA_Delivered__c = system.now();
        sla.Service_restoration_actual__c = system.now();
        sla.Service_restoration_due__c = system.now();
        insert sla;
        
        SR_Comments__c s = new SR_Comments__c();
         s.Technical_Contact_Name__c = 'Test Technical Contact';
         s.Notes_Type__c ='Management';
         s.Note_Description__c = 'Test Management Description';
         s.SR_Number__c = [SELECT Id FROM Case WHERE id=:cc.id LIMIT 1].Id;
         insert s; 
      }   
          System.runAs(u) {
        CaseTeamRole CTR = [select Id from CaseTeamRole where Name = 'To Be Notified' limit 1];
        CTM = new CaseTeamMember();
       
        CTM.MemberId=u.id;
        CTM.ParentId=cc.id;
        CTM.TeamRoleId = CTR.Id;
        insert CTM;
        
         casett = new CaseTeamTemplate();
        casett.Description='predefinescaseteam description';
        casett.Name='predefinedcaseteam';
            
        insert casett;
        
         casettr = new CaseTeamTemplateRecord();
        casettr.ParentId=cc.id;
        casettr.TeamTemplateId=casett.id;
        insert casettr; 
        } 
         
         
            pageref.getParameters().put('id',cc.id);
            apexpages.currentpage().getparameters().put('isdtp','vw');
            pageref.getParameters().put('strCaseId', cc.id);
            
            
        GSS_Agent_SR_Management_Controller tobj = new  GSS_Agent_SR_Management_Controller(new ApexPages.standardController(caseCreated[0]));
      
       
       
       List<String> editableFields1=tobj.editableFields;
      
       GSS_Agent_SR_Management_Controller.wrapperClass obj=new GSS_Agent_SR_Management_Controller.wrapperClass();
       GSS_Agent_SR_Management_Controller.WrapperTeamMember obj1=new GSS_Agent_SR_Management_Controller.WrapperTeamMember();
       
      List<GSS_Agent_Button_Map__c> butt = new List<GSS_Agent_Button_Map__c>();
      for(GSS_Agent_Button_Map__c button: [select Name, Label__c,SR_Management__c from GSS_Agent_Button_Map__c]){
          button.SR_Management__c =true;
          butt.add(button);
      }
      update butt;
      
       tobj.setTabVisibility();
       //tobj.getNumber();
       tobj.checkButtonVisibility();
       tobj.redirectSalesConsole();
       tobj.getRecordCaseSLA();
       tobj.getDetail();
       tobj.savecase();
       tobj.RecIDeletedd =CTM.id; 
       tobj.PreDefinedCTDelete =casettr.id;
       tobj.RemoveTM();
       
     
       
        Test.stopTest();
        }
        }