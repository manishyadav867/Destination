/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

 /*
 * Accenture     18-July-2014        CR-00102156 Hotfix: Changing fields: Next_Touch_Activity_Date__c -> Next_Touch_Date__c & Next_Touch_Activity__c -> TSE_Next_Step__c 
 * Accenture    29-Jul-2016     CR-00139057
 */ 

@isTest(seealldata = true)
private class GSS_Agent_Additional_Info_ControllerTest {
  
    public static   Case cc ;
    public static GSS_Agent_Additional_Info_Controller.wrapperClass ercls;
    public static GSS_Agent_Additional_Info_Controller.WrapperTeamMember wtmcls;
     public static list<SR_Comments__c> lstsrcomments = new list<SR_Comments__c>();
     public static  CaseTeamMember casetm,casetm1;
     public static UserRole tempuserrole;
     public static User tempUser1,tempUser2;
     public static Contact con,con1;
     public static CaseTeamRole casetr;
     public static CaseTeamTemplate casett;
     public static CaseTeamTemplateRecord casettr;
     public static CaseTeamTemplateMember casettm,casettm1 ;
     public static GSS_Agent_Field_Map__c afMap;
     public static GSS_Technical_Contact__c gtc;
     public static Echo__c ech;
     public static CaseTeamMember ct;
     
    static void preparetestdata() {
        
        cc = new Case(RecordType = new RecordType(Name='GSS Technical Support'));
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '3 - Medium';
        cc.Status = 'New';
        cc.Sub_Status__c = 'Unassigned';
        cc.Subject = 'Test Subject';
        cc.Description = 'Test Description';
        cc.Next_Touch_Date__c=system.today();
        cc.GSS_Third_Party_Email_Phone__c = 'test@test.com';
        cc.GSS_Third_Party_Contact_Name__c = 'test';
        cc.GSS_Third_Party_Ticket__c = '1234';
        insert cc;
          
        SR_Comments__c sr1 = new SR_Comments__c();
        sr1.SR_Number__c= cc.Id;
        sr1.Technical_Contact_Name__c='test1';
        sr1.Notes_Type__c='Internal Notes ' + GSS_Agent_Tab_Visibility__c.getInstance('Additional Information').Tab_Name__c;
        sr1.Note_Description__c='test description1';
        lstsrcomments.add(sr1); 
        
        SR_Comments__c sr2 = new SR_Comments__c();
        sr2.SR_Number__c= cc.Id;
        sr2.Technical_Contact_Name__c='test2';
        sr2.Notes_Type__c='Internal Notes ' + GSS_Agent_Tab_Visibility__c.getInstance('Additional Information').Tab_Name__c;
        sr2.Note_Description__c='Internal Note Additional Information';
        lstsrcomments.add(sr2); 
        insert lstsrcomments;
        
        Account a = new Account(RecordType = new RecordType(Name='Named Account Request'));
        a.Name = 'Test Account';
        insert a;
        
        System.runAs(new User(Id = UserInfo.getUserId())){
        tempuserrole = new UserRole(Name='CEO');
        insert tempuserrole;  
         
         
       tempUser1 = new User(UserRoleId = tempuserrole.Id, FirstName = UserInfo.getFirstName(), LastName= UserInfo.getLastName(),ProfileId=UserInfo.getProfileId(),Username=DealRegTestClassSetupUtility.getRandomString(5)+'@gmail.com',Email=DealRegTestClassSetupUtility.getRandomString(5)+'@test1.com' ,Alias='karjun',CommunityNickname= 'karjunsingh' ,TimeZoneSidKey='America/Los_Angeles',
      LocaleSidKey='en_US',EmailEncodingKey='UTF-8',LanguageLocaleKey= 'en_US',Division='AMER');
      insert tempUser1; 
      
      tempUser2 = new User(UserRoleId = tempuserrole.Id, FirstName = 'test', LastName= 'class',ProfileId=UserInfo.getProfileId(),Username=DealRegTestClassSetupUtility.getRandomString(5)+'@ymail.com',Email=DealRegTestClassSetupUtility.getRandomString(5)+'@test2.com' ,Alias='flas',CommunityNickname= 'flastn' ,TimeZoneSidKey='America/Los_Angeles',
      LocaleSidKey='en_US',EmailEncodingKey='UTF-8',LanguageLocaleKey= 'en_US',Division='AMER');
      insert tempUser2;   
         
         con=new Contact(RecordType = new RecordType(Name='Customer Contact'));
         con.LastName='Arora';
         con.Email='xyz@abc.com';
         con.Accountid=a.id;
         insert con;
         
         con1=new Contact(RecordType = new RecordType(Name='Customer Contact'));
         con1.LastName='modi';
         con1.Email='modi@bjp.com';
         con1.Accountid=a.id;
         insert con1;
        
        casetr = new CaseTeamRole();
        casetr.AccessLevel='Edit';
        casetr.Name='teamewrwe';
        casetr.PreferencesVisibleInCSP=true;
        insert casetr;
      
        List<CaseTeamMember> tmlist=new List<CaseTeamMember>();
        
        casetm = new CaseTeamMember();
        casetm.MemberId=con.id;
        casetm.ParentId=cc.id;
        casetm.TeamRoleId=casetr.id;
        //casetm.TeamTemplateMemberId=con.Id;
        //casetm.LastModifiedById=UserInfo.getUserId();
        //casetm.LastModifiedBy.Name=UserInfo.getName();
        //insert casetm;
        tmlist.add(casetm);
        system.debug('casetm=='+casetm);
        
        casetm1 = new CaseTeamMember();
        casetm1.MemberId=tempUser1.id;
        casetm1.ParentId=cc.id;
        casetm1.TeamRoleId=casetr.id;
        //insert casetm1;
        tmlist.add(casetm1);
        system.debug('casetm1=='+casetm1);
        
        casett = new CaseTeamTemplate();
        casett.Description='predefinescaseteam description';
        casett.Name='predefinedcaseteam';
        //casett.LastModifiedById=UserInfo.getUserId();
        //casett.LastModifiedBy.Name=UserInfo.getName();        
        insert casett;
        
        casettr = new CaseTeamTemplateRecord();
        casettr.ParentId=cc.id;
        casettr.TeamTemplateId=casett.id;
        insert casettr; 
        
        List<CaseTeamTemplateMember> tmtemplist =new List<CaseTeamTemplateMember>();
        casettm = new CaseTeamTemplateMember();
        casettm.MemberId = con1.id;
        casettm.TeamRoleId = casetr.id;
        casettm.TeamTemplateId = casett.id;
        //insert casettm;
        tmtemplist.add(casettm);
        
        casettm1 = new CaseTeamTemplateMember();
        casettm1.MemberId = tempUser2.id;
        casettm1.TeamRoleId = casetr.id;
        casettm1.TeamTemplateId = casett.id;
        //insert casettm1;
        tmtemplist.add(casettm1);
        insert tmtemplist;
       
        //List<GSS_Agent_Button_Map__c> gList=[select name,label__c,Additional_Information__c from GSS_Agent_Button_Map__c];
        List<GSS_Agent_Button_Map__c> gList=GSS_Agent_Button_Map__c.getall().values();
        for(GSS_Agent_Button_Map__c g:gList)
        {
            g.Additional_Information__c=true;
        }
        update gList;
        
       
        } 
        afMap = GSS_Agent_Field_Map__c.getValues('Account Tier');
        afMap.isActive__c = true;
        update afMap;
        
         System.debug('test class debug'+afMap);
         
         
         ech = new Echo__c();
         
         ct = new CaseTeamMember(ParentId = cc.ID, MemberId = con.ID, TeamRoleId = casetr.id);
         insert ct;
        gtc = new GSS_Technical_Contact__c(Case__c = cc.ID, IsPartnerContact__c = true);
        insert gtc;
    }
  

    static testMethod void myUnitTest1() {
        
         PageReference pageRef = Page.GSS_Agent_Additional_Info;
         Test.setCurrentPage(pageRef);

         GSS_UtilityClass.isBeforeInsert_Case=true;
         GSS_UtilityClass.isBeforeUpdate_Case=true;
         GSS_UtilityClass.isAfterInsert_Case=true;
         GSS_UtilityClass.isAfterUpdate_Case=true;         
         preparetestdata();
         test.startTest();
         
        GSS_Agent_Additional_Info_Controller obj = new GSS_Agent_Additional_Info_Controller(new ApexPages.StandardController(cc));  
            obj.cId= cc.Id;
            ApexPages.currentPage().getParameters().put('id',cc.Id);        
            ApexPages.currentPage().getParameters().put('RecIDeletedd',casetm.id);
            ApexPages.currentPage().getParameters().put('isdtp','vw');
            ApexPages.currentPage().getParameters().put('cId',cc.Id);
                     
         ercls = new GSS_Agent_Additional_Info_Controller.wrapperClass();
         wtmcls = new GSS_Agent_Additional_Info_Controller.WrapperTeamMember();
         
         
         obj.checkButtonVisibility();
         obj.getDetail();
         obj.savecase();
         obj.RecIDeletedd= casetm.id;
         obj.PreDefinedCTDelete = casettr.id;
         obj.RemoveTM();
         obj.deleteTechCont();
         List<GSS_Technical_Contact__c> contList = [select id,Additional_Technical_Contact_Name__c,GSS_Third_Party_Email_Phone__c,GSS_Third_Party_Ticket__c, Case__c, CreatedDate,IsPartnerContact__c from GSS_Technical_Contact__c where Case__c=:cc.ID And IsPartnerContact__c=true order by CreatedDate Desc];
         ApexPages.currentPage().getParameters().put('idToDel',contList[0].Id);
         obj.deleteTechCont();
         
         List<String> editableFields2=obj.editableFields;
         
         PageReference pageref1 =Page.GSS_Agent_SR_Management;
         Test.setCurrentPage(pageref1);
         GSS_Agent_SR_Management_Controller tobj = new  GSS_Agent_SR_Management_Controller(new ApexPages.standardController(cc));
         
         ApexPages.currentPage().getParameters().put('id',cc.id);
         ApexPages.currentPage().getParameters().put('isdtp','vw');
         ApexPages.currentPage().getParameters().put('RecIDeletedd',casetm.id);
         ApexPages.currentPage().getParameters().put('strCaseId', cc.id);
         List<String> editableFields1=tobj.editableFields;
         GSS_Agent_SR_Management_Controller.wrapperClass Wobj=new GSS_Agent_SR_Management_Controller.wrapperClass();
         GSS_Agent_SR_Management_Controller.WrapperTeamMember Wobj1 =new GSS_Agent_SR_Management_Controller.WrapperTeamMember();
         
         
         tobj.setTabVisibility();
         tobj.checkButtonVisibility();
         tobj.redirectSalesConsole();
         tobj.RecIDeletedd= casetm.id;
         tobj.PreDefinedCTDelete = casettr.id;
         tobj.RemoveTM();
         tobj.getDetail();
         tobj.savecase();
         Test.stopTest();
         
         
    }
    static testmethod void testUnit2(){
        preparetestdata();
        test.startTest();
        PageReference pageRef = Page.GSS_Agent_Additional_Info;
        Test.setCurrentPage(pageRef);
        GSS_Agent_Additional_Info_Controller obj = new GSS_Agent_Additional_Info_Controller(new ApexPages.StandardController(cc));  
        obj.cId= cc.Id;
        List<GSS_Technical_Contact__c> contList = [select id,Additional_Technical_Contact_Name__c,GSS_Third_Party_Email_Phone__c,GSS_Third_Party_Ticket__c, Case__c, CreatedDate,IsPartnerContact__c from GSS_Technical_Contact__c where Case__c=:cc.ID And IsPartnerContact__c=true order by CreatedDate Desc];
        ApexPages.currentPage().getParameters().put('idToDel',contList[0].Id);
        GSS_Technical_Contact__c gtc1 = new GSS_Technical_Contact__c(Case__c = cc.ID, IsPartnerContact__c = true);
        insert gtc1;
        obj.deleteTechCont();
        test.stopTest();
    }
}