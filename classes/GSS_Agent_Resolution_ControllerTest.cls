/*********************************************************************
* Class Name : GSS_Agent_Resolution_ControllerTest
* Purpose    : Test Class For GSS_Agent_Resolution_Controller
*              
* Author            Date            Comments        
* Accenture     15-May-2014        GSS Agent Console Project
* ********************************************************************/
// ******************************Version Update************************************************
// Modified Date     Modifiedby            Comments
// 15/01/2015        Sakshi Suri            Case Record Type name change from GSS Licensing to GS-SS Customer Support //CR-00102901
// ********************************************************************************************
@isTest(seealldata=true)

public class GSS_Agent_Resolution_ControllerTest{
    
     public static testMethod void testGSS_Agent_Resolution_Controller(){
     
      Product2 prod  = new Product2();
        prod.Name = 'Iphone';
        prod.Product_Group__c='END USER COMPUTING';
        prod.GSS_Product_Issue_type__c = '3PS integration Issues';
        prod.GSS_Product_vCat__c = 'Test Data';
        prod.GSS_Vsubcat__c ='Test Category,Sub Category';
        prod.GSS_Version__c ='Test Version';
        prod.GSS_Product_vCat__c = 'Test Category';
        prod.GSS_Partner_vSubcat__c ='Test Partner Sub Category';
        
        insert prod;
       
      Account a = new Account();
        a.RecordTypeId=[select Id from RecordType where SobjectType='Account' and Name='Master Account Layout'].id;
        a.Name = 'Test Account';
        insert a;
       
      Entitlement e = new Entitlement();
        e.Name = 'Test Entitlement';
        e.GSS_Entitlement_Code__c = 'ASP';
        e.AccountId = a.id;
        insert e;
        
       GSS_IssueTypeDependentPicklistValues__c is = new GSS_IssueTypeDependentPicklistValues__c();
       is.Name = 'Test Setting';
       is.Product_Issue_Type__c = '3PS integration Issues';
       is.Sub_Type__c = 'Test Sub Type';
       insert is;
       
  
        Case cc = new Case();
        cc.RecordTypeId=[select Id from RecordType where SobjectType='Case' and Name='GS-SS Customer Support'].id; //CR-00102901
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '3 - Medium';
        cc.Status = 'New';
        cc.Sub_Status__c = 'unassigned';
        cc.Subject = 'Test Subject';
        cc.Description = 'Test Description';
        cc.Technical_Contact_Name__c = 'Sumit';
        cc.GSS_Partner__c = 'Request New Value';
        cc.GSS_Vcat__c = 'Customer Service Request';
        cc.GSS_Vsubcat__c = '3rd Party Storage Device';
        cc.GSS_Vsubcat2__c = 'ACF – Credit Rebill';
        cc.GSS_Issue_Type__c = '3PS integration Issues';
        cc.Issue_Type__c = '3PS integration Issues';
        cc.ProductId= prod.id;
        cc.Entitlementid = e.id;
        insert cc;
        
        GSS_Product_vCat_vSubcat_Dependency_List__c  gp = new GSS_Product_vCat_vSubcat_Dependency_List__c();
        gp.Name = 'Test Name';
        gp.ProductId__c = prod.id;
        gp.Product_Name__c = 'Iphone';  
        gp.Product_vCat__c = 'Customer Service Request';
        gp.Product_vSubcat__c = 'Customer;Service';
        insert gp;
       
        
        GSS_Populate_Product_Issue_Types__c  issue = new GSS_Populate_Product_Issue_Types__c();
        issue.name = 'Test Issue';
        issue.Issue_Type__c = '3PS integration Issues';
        insert issue;
        
  
       List<GSS_Agent_Button_Map__c>buttonList = new  List<GSS_Agent_Button_Map__c>();
      buttonList = [select Resolution_Information__c,Label__c from GSS_Agent_Button_Map__c ];
       for (GSS_Agent_Button_Map__c g : buttonList)
       {
          g.Resolution_Information__c = true;
       }
        
        update buttonList;
        
            
        
      SR_Comments__c s = new SR_Comments__c();
        s.Technical_Contact_Name__c = 'Test Technical Contact';
        s.Notes_Type__c ='Internal Note Resolution Information';
        s.Note_Description__c = 'Test Management Description';
        s.SR_Number__c = [SELECT Id FROM Case WHERE id=:cc.id LIMIT 1].Id;
        insert s;
    
        PageReference pageref=Page.GSS_Agent_Resolution;
        Test.setcurrentpage(pageref);
        pageRef.getParameters().put('id',cc.id);  
             
   
      Test.startTest();
        
       GSS_Agent_Resolution_Controller cobj = new GSS_Agent_Resolution_Controller();
        
        cobj.CaseId = cc.id;
        cobj.setrequiredfields();
        cobj.checkButtonVisibility();
        cobj.getOcase();
        cobj.refreshSubType();
        cobj.strVCat = 'Customer Service Request';
        cobj.strVSubCat = 'Test Partner Sub Category';
        cobj.strPartner  = 'Test Partner';
        cobj.strIssueType = '3PS integration Issues';
        
        cobj.refreshVsubcatsValues();
        cobj.refreshPartner();
        cobj.refreshPartnerComponent();
        cobj.redirectSalesConsole();
        cobj.doEdit();
        cobj.savecase();
        cobj.closeSR();
        cobj.strVCat = 'Request New Value';
        cobj.strVSubCat = 'Request New Value';
        cobj.strPartner  = 'partner';
        cobj.strIssueType = '3PS integration Issues';
        cobj.refreshVsubcatsValues();
        cobj.refreshPartner();
        cobj.strProductName = 'Iphone';
        cc.GSS_Vcat__c = '';
        update cc;
        gp.Product_vSubcat__c = '';
        update gp;
        GSS_Agent_Resolution_Controller cobj1=new GSS_Agent_Resolution_Controller();
        cobj1.refreshVsubcatsValues();
        
      Test.stopTest();
      
      }
       public static testMethod void test1GSS_Agent_Resolution_Controller(){
     
      Product2 prod  = new Product2();
        prod.Name = 'Iphone';
        prod.Product_Group__c='END USER COMPUTING';
        prod.GSS_Product_Issue_type__c = '3PS integration Issues';
        prod.GSS_Product_vCat__c = '';
        prod.GSS_Vsubcat__c ='Test Category,Sub Category';
        prod.GSS_Version__c ='Test Version';
        prod.GSS_Product_vCat__c = 'Test Category';
        prod.GSS_Partner_vSubcat__c ='Test Partner Sub Category';
        
        insert prod;
       
      Account a = new Account();
        a.RecordTypeId=[select Id from RecordType where SobjectType='Account' and Name='Master Account Layout'].id;
        a.Name = 'Test Account';
        insert a;
       
      Entitlement e = new Entitlement();
        e.Name = 'Test Entitlement';
        e.GSS_Entitlement_Code__c = 'ASP';
        e.AccountId = a.id;
        insert e;
        
       GSS_IssueTypeDependentPicklistValues__c is = new GSS_IssueTypeDependentPicklistValues__c();
       is.Name = 'Test Setting';
       is.Product_Issue_Type__c = '3PS integration Issues';
       is.Sub_Type__c = 'Test Sub Type';
       insert is;
       
  
        Case cc = new Case();
        cc.RecordTypeId=[select Id from RecordType where SobjectType='Case' and Name='GSS CS Admin'].id;
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '3 - Medium';
        cc.Status = 'New';
        cc.Sub_Status__c = 'unassigned';
        cc.Subject = 'Test Subject';
        cc.Description = 'Test Description';
        cc.Technical_Contact_Name__c = 'Sumit';
        cc.GSS_Partner__c = 'Request New Value';
        cc.GSS_Vcat__c = 'Customer Service Request';
        cc.GSS_Vsubcat__c = '3rd Party Storage Device';
        cc.GSS_Vsubcat2__c = 'ACF – Credit Rebill';
        cc.GSS_Issue_Type__c = '3PS integration Issues';
        cc.Issue_Type__c = '3PS integration Issues';
        cc.ProductId= prod.id;
        cc.Entitlementid = e.id;
     
         
        insert cc;
        
        GSS_Product_vCat_vSubcat_Dependency_List__c  gp = new GSS_Product_vCat_vSubcat_Dependency_List__c();
        gp.Name = 'Test Name';
        gp.ProductId__c = prod.id;
        gp.Product_Name__c = 'Iphone';  
        gp.Product_vCat__c = 'Customer Service Request';
        gp.Product_vSubcat__c = '';
        insert gp;
       
        
        GSS_Populate_Product_Issue_Types__c  issue = new GSS_Populate_Product_Issue_Types__c();
        issue.name = 'Test Issue';
        issue.Issue_Type__c = '3PS integration Issues';
        insert issue;
            
        
      SR_Comments__c s = new SR_Comments__c();
        s.Technical_Contact_Name__c = 'Test Technical Contact';
        s.Notes_Type__c ='Internal Note Resolution Information';
        s.Note_Description__c = 'Test Management Description';
        s.SR_Number__c = [SELECT Id FROM Case WHERE id=:cc.id LIMIT 1].Id;
        insert s;
    
        PageReference pageref=Page.GSS_Agent_Resolution;
        Test.setcurrentpage(pageref);
        pageRef.getParameters().put('id',cc.id);  
             
   
      Test.startTest();
        
       GSS_Agent_Resolution_Controller cobj = new GSS_Agent_Resolution_Controller();
        
        cobj.CaseId = cc.id;
        cobj.setrequiredfields();
        cobj.checkButtonVisibility();
        cobj.getOcase();
        cobj.refreshSubType();
        cobj.strVCat = 'Customer Service Request';
        cobj.strVSubCat = 'Test Partner Sub Category';
        cobj.strPartner  = 'Test Partner';
        cobj.strIssueType = '3PS integration Issues';
        
        cobj.refreshVsubcatsValues();
        cobj.refreshPartner();
        cobj.refreshPartnerComponent();
        cobj.redirectSalesConsole();
        cobj.doEdit();
        cobj.savecase();
        cobj.closeSR();
        cobj.strVCat = 'Request New Value';
        cobj.strVSubCat = 'Request New Value';
        cobj.strPartner  = 'partner';
        cobj.strIssueType = '3PS integration Issues';
        cobj.refreshVsubcatsValues();
        cobj.refreshPartner();
        

        
     
      Test.stopTest();
      
      }
      public static testMethod void test2GSS_Agent_Resolution_Controller(){
     
      Product2 prod  = new Product2();
        prod.Name = 'Iphone';
        prod.Product_Group__c='END USER COMPUTING';
        prod.GSS_Product_Issue_type__c = '3PS integration Issues';
        prod.GSS_Product_vCat__c = 'Iphone';
        prod.GSS_Vsubcat__c ='Test Category,Sub Category';
        prod.GSS_Version__c ='Test Version';
        prod.GSS_Product_vCat__c = 'Test Category';
        prod.GSS_Partner_vSubcat__c ='Test Partner Sub Category';
        
        insert prod;
       
      Account a = new Account();
        a.RecordTypeId=[select Id from RecordType where SobjectType='Account' and Name='Master Account Layout'].id;
        a.Name = 'Test Account';
        insert a;
       
      Entitlement e = new Entitlement();
        e.Name = 'Test Entitlement';
        e.GSS_Entitlement_Code__c = 'ASP';
        e.AccountId = a.id;
        insert e;
        
       GSS_IssueTypeDependentPicklistValues__c is = new GSS_IssueTypeDependentPicklistValues__c();
       is.Name = 'Test Setting';
       is.Product_Issue_Type__c = '3PS integration Issues';
       is.Sub_Type__c = 'Test Sub Type';
       insert is;
       
  
        Case cc = new Case();
        cc.RecordTypeId=[select Id from RecordType where SobjectType='Case' and Name='GSS Technical Support'].id;
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '3 - Medium';
        cc.Status = 'New';
        cc.Sub_Status__c = '';
        cc.Subject = 'Test Subject';
        cc.Description = 'Test Description';
        cc.Technical_Contact_Name__c = 'Sumit';
        cc.GSS_Partner__c = 'Request New Value';
        cc.GSS_Vcat__c = 'Customer Service Request';
        cc.GSS_Vsubcat__c = '3rd Party Storage Device';
        cc.GSS_Vsubcat2__c = 'ACF – Credit Rebill';
        cc.GSS_Issue_Type__c = '3PS integration Issues';
        cc.Issue_Type__c = '3PS integration Issues';
        cc.ProductId= prod.id;
        cc.Entitlementid = e.id;
        insert cc;
        
        GSS_Product_vCat_vSubcat_Dependency_List__c  gp = new GSS_Product_vCat_vSubcat_Dependency_List__c();
        gp.Name = 'Test Name';
        gp.ProductId__c = prod.id;
        gp.Product_Name__c = '';  
        gp.Product_vCat__c = 'Customer Service Request';
        gp.Product_vSubcat__c = '';
        insert gp;
       
        
        GSS_Populate_Product_Issue_Types__c  issue = new GSS_Populate_Product_Issue_Types__c();
        issue.name = 'Test Issue';
        issue.Issue_Type__c = '3PS integration Issues';
        insert issue;
            
        
      SR_Comments__c s = new SR_Comments__c();
        s.Technical_Contact_Name__c = 'Test Technical Contact';
        s.Notes_Type__c ='Internal Note Resolution Information';
        s.Note_Description__c = 'Test Management Description';
        s.SR_Number__c = [SELECT Id FROM Case WHERE id=:cc.id LIMIT 1].Id;
        insert s;
    
        PageReference pageref=Page.GSS_Agent_Resolution;
        Test.setcurrentpage(pageref);
        pageRef.getParameters().put('id',cc.id);  
             
   
      Test.startTest();
        
       GSS_Agent_Resolution_Controller cobj = new GSS_Agent_Resolution_Controller();
        
        cobj.CaseId = cc.id;
        cobj.setrequiredfields();
        cobj.checkButtonVisibility();
        cobj.getOcase();
        cobj.refreshSubType();
        cobj.strVCat = 'Customer Service Request';
        cobj.strVSubCat = 'Test Partner Sub Category';
        cobj.strPartner  = 'Test Partner';
        cobj.strIssueType = '3PS integration Issues';
        cobj.strProductName  = '';
        cobj.refreshVsubcatsValues();
        cobj.refreshPartner();
        cobj.refreshPartnerComponent();
        cobj.redirectSalesConsole();
        cobj.doEdit();
        cobj.savecase();
        cobj.closeSR();
        cobj.strVCat = 'Request New Value';
        cobj.strVSubCat = 'Request New Value';
        cobj.strPartner  = 'partner';
        cobj.strIssueType = '3PS integration Issues';
        cobj.refreshVsubcatsValues();
        cobj.refreshPartner();
        

      Test.stopTest();
      
      }
      
      
      
       
    
   }