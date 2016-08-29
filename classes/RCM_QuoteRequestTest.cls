/***********************************************************************************************************
* Class Name    : RCM_QuoteRequestTest
* Purpose       : This is the Test Class for RCM_QuoteRequest
* Created Date  : 07.11.2014        
* ***********************Version Updates*************************************************
* Date              Developer               Description
* ---------------------------------------------------------------------------------------
* 01.09.2015        Jyolsna               RS2 H2 : CR-00135058
*****************************************************************************************/
@isTest(SeeAllData=true)
public class RCM_QuoteRequestTest{
    public static List<Account> accList{get;set;}
    public static List<Contact> conList{get;set;}
    public static List<Case> caseList{get;set;}
    public static List<User> userList{get;set;}
    public static List<Opportunity> oppList{get;set;}
    public static List<Renewal_Quote__c> rqList{get;set;}
    public static List<Renewal_Quote__c> reqList{get;set;}
    public static List<Group_custom__c> grpList{get;set;}
    public static List<Renewal_Partner_Group__c> rpgList{get;set;}
    public static List<Renewal_User_Group__c> rpuList{get;set;}
    public static User usr=new User();
   public static EA_Lookup__c earec;
    private static void setupTestData(){
         //user newuser = new user ()
         Profile_Name_Mapping__c prf = CustomSettingUtility.getProfileNameMapping('System Administrator');
         List<User> sysusr = new List<User>();
         sysusr.add(new User(alias = 'u184', email='newuser47@testorg.com67236', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = prf.Profile_Id__c, IsActive = true,
            timezonesidkey='America/Los_Angeles', username='newuser47@inforte.com324234'));
         insert sysusr; 
         System.runAs(sysusr[0]){ 
            accList=new List<Account>();
            conList=new List<Contact>();
            userList=new List<User>();
            rqList=new List<Renewal_Quote__c>();
            reqList=new List<Renewal_Quote__c>();
            grpList=new List<Group_custom__c>();
            rpgList=new List<Renewal_Partner_Group__c>();
            rpuList=new List<Renewal_User_Group__c>();
            oppList= new List<Opportunity>();
            User usr1=new User();
            userList.add(usr1);
                         
            accList=RS2_RCM_TestDataUtitlity.createResellAccounts(1);
            conList=RS2_RCM_TestDataUtitlity.createDistResellPartnerContacts(accList,1,userList);
            grpList=RS2_RCM_TestDataUtitlity.creatResellerRenewalGroup(1);
            rpgList=RS2_RCM_TestDataUtitlity.createRenewalPartnerGroup(accList,grpList,1);
            rpuList=RS2_RCM_TestDataUtitlity.createRenewalUserGroup(grpList,1,userList);
            earec=new EA_Lookup__c(Name='TestEALookup',Customer_Name__c='TestName1234');
            insert earec;
         }
    }  
     public static void Rs2_customsetting()
    {  
        if(((RS2_Stabilization_Config_Setting__c.getAll()).isEmpty()) || ((WebService_Callout__c.getAll()).isEmpty()))
        {
        
        List<RS2_Stabilization_Config_Setting__c> RS2Config=new List<RS2_Stabilization_Config_Setting__c>();
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Created',Value__c='System'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Description',Value__c='No Opportunity:'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Exist Msg Part 1',Value__c='Ad hoc opportunity creation case request'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Exist Msg Part 2',Value__c='that is in open status should be used for this quote to check on the renewal sales opportunity creation'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Origin',Value__c='VMSTAR'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Owner - PDS API',Value__c='PDS API'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Priority',Value__c='3 - Medium'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Reason',Value__c='No Opportunity'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Request Type',Value__c='Ad-Hoc Opportunity Load'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Status',Value__c='Open'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Status - On Hold',Value__c='On Hold'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Status - Open/Working',Value__c='Open/Working'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Sub Status - Other Internal',Value__c='Other Internal'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Subject',Value__c='Ad-Hoc Load Auto Case Request'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Support Queue',Value__c='Expert Quoting Top Deals & RELA'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='EBS Exp Contract Flag - No',Value__c='No'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='EBS Exp Contract Flag - Not Found',Value__c='Not Found'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='EBS Exp Contract Flag - Yes',Value__c='Yes'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Error Msg - Max Limit',Value__c='At a time maximum 50 records can be processed'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Error Msg - No Record Selected',Value__c='Please select the records'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Error Msg - Wrong Status Selected',Value__c='You have selected one or more records with Status other than EBS Error/VMSTAR Error'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Max_Limit',Value__c='50'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Opportunity Case Reason',Value__c='No Opportunity'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Opportunity Case Staging Status - New',Value__c='New'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Opportunity Exist Msg Part 1',Value__c='Use Renewal Sales Opportunity'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Opportunity Exist Msg Part 2',Value__c='is available for this quote request'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Opportunity Request - Request Type',Value__c='Quote Upload Failure,Ad-Hoc Opportunity Load'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Quote Request - Origin',Value__c='RCM,VMSTAR'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Quote Request - Reques Sub Type',Value__c='New,Revision'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Quote Request - Request Type',Value__c='Single Quote,Quote Consolidation'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Reporcessing Staging Status',Value__c='EBS Error,VMSTAR Error'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Staging Status - EBS Error',Value__c='EBS Error'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Staging Status - VMSTAR Error',Value__c='VMSTAR Error'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Staging Status - VMSTAR Success',Value__c='VMSTAR Success'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Success Msg',Value__c='Selected records are sent for processing'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Valid Opportunity Record Type',Value__c='OEM Royalty,Renewal Sales Opportunity,RELA Opportunity'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Valid Opportunity Stage',Value__c='01 - Not Contacted,02 - Contacted,03 - Quoted,04 - Negotiate,05 - Agreement to Purchase'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case New',Value__c='New'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Others',Value__c='Other'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Origin2',Value__c='RCM'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Quote Consolidation',Value__c='Quote Consolidation'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case RecordType',Value__c='0128000000044mWAAQ'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Revision',Value__c='Revision'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Case Single Quote',Value__c='Single Quote'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Non-Standard Term',Value__c='Non-Standard Term'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='5-Plus Year Request part1',Value__c='Your quote cannot be provided as requested, as renewals longer than 5 years from today\'s date in duration are not supported.Refer to Solution 5398 for detailed approval requirements.'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='5-Plus Year Request part2',Value__c='A quote has been provided for the maximum approved term.'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='5-Plus Year Request RCM 1',Value__c='Your quote cannot be provided as requested, as quote requests longer than 5 years from today\'s date in duration are not supported. A quote has been provided for the maximum approved term.'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='5-Plus Year Request RCM 2',Value__c='If you have any questions or concerns, please reach out to your Renewals Sales Representative.'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Short Term End Date 1',Value__c='VMware Renewals policy dictates that all contracts must be renewed for a minimum of 1-year from the date of quote creation (for Expired contracts), or 1-year from the end date of Active contracts.'));
        RS2Config.add(new RS2_Stabilization_Config_Setting__c(Name='Short Term End Date 2',Value__c='Express approval for shorter termed contracts can be granted by your Renewals Sales Representative.'));
        insert RS2Config;
        
        
        List<WebService_Callout__c> webcalloutlist = new List<WebService_Callout__c>();
        WebService_Callout__c webcalloutObj1 = new WebService_Callout__c(Name = 'RS2_FMW_EBS_Token',Authorization__c = 'Basic dWhybnN3NzZrOGpxanM1NjdqYXU3M3JlOjZNY2FVU2tqVldDVTNXQzNDYWpmd1NZVw==',Body__c = 'grant_type=client_credentials',Content_Type__c = 'application/x-www-form-urlencoded',EndPointUrl__c = 'https://api-dev.vmware.com/dev/token',Timeout__c = 120000);
        WebService_Callout__c webcalloutObj2 = new WebService_Callout__c(Name = 'RS2_FMW_EBS_Webservice',Authorization__c = 'Bearer',Body__c = '',  Content_Type__c = 'application/xml;charset=UTF-8',EndPointUrl__c = 'https://api-dev.vmware.com/dev14/ValidateContract',Timeout__c = 120000);
        webcalloutlist.add(webcalloutObj1);
        webcalloutlist.add(webcalloutObj2);
        insert webcalloutlist;
        }
        if((RS2_Quoting__c.getAll()).isEmpty())
        {
            RS2_Quoting__c rsq=new RS2_Quoting__c();
            rsq.name='Reactivequoteuser';
            rsq.Value__c='005800000081u6tAAA';
            insert rsq;
        }
    }
    
    private static testMethod void testRCM_QuoteRequestQuoteSearch1(){
        setupTestData();
        Rs2_customsetting();
        test.startTest();
         Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[0].id!=null){
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            insert reqList;
            
           
            
        }
        if(!oppList.isEmpty() && oppList[1].id!=null){
            rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = False,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
        }
        
        System.runAs(userList[0]){
            if(!oppList.isEmpty() && oppList[0].id!=null){
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                insert rqList;
                
                Blob bodyOfAttachment= Blob.valueof('the body of the attachment');
                List<Attachment> attach = new List<Attachment>();
                attach.add(new Attachment(Name = 'test.pdf',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xml',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xlsx',ParentId = rqList[2].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xls',ParentId = rqList[2].Id,body = bodyOfAttachment));
                insert attach;
            }
           
            List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessList=new List<RS2_Quote_Multiple_Partners__c>();
            RS2_Quote_Multiple_Partners__c quotespartnerAccessobj=new RS2_Quote_Multiple_Partners__c(Renewal_Quote__c=rqlist[1].id,PartnerSharing__c='Ready For Sharing',Account__c=accList[0].id,Opportunity__c = oppList[1].id);
            quotespartnerAccessList.add(quotespartnerAccessobj);
            insert quotespartnerAccessList;
            
            //RCM_QuoteRequest.requestCaseSearch requestcasesearchobj=new RCM_QuoteRequest.requestCaseSearch();
            //requestcasesearchobj.contractNumber='23';
            //requestcasesearchobj.supportLevel='2';
            //requestcasesearchobj.durationLevel='2';
            PageReference pageRef = Page.RS2_QuoteRequestSP;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('method', 'getAvailableQuotesByContractNumber');
            System.currentPageReference().getParameters().put('partner', '-1');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":""}]');
            RCM_QuoteRequest obj=new RCM_QuoteRequest();
            obj.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":""}]');
            RCM_QuoteRequest obj1=new RCM_QuoteRequest();
            obj1.redirectingToMethods();
            //obj2.getAvailableQuotesByContractNumber();
            
            System.currentPageReference().getParameters().put('method', 'getAvailableQuotesByContractNumber');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":"+oppList[1].id+"}]');
            RCM_QuoteRequest obj2=new RCM_QuoteRequest();
            obj2.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":"+oppList[1].id+"}]');
            RCM_QuoteRequest obj3=new RCM_QuoteRequest();
            obj3.redirectingToMethods();
                      
            System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":"+oppList[1].id+"},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"System.today().adddays(7)","opportunityId":"+oppList[1].id+"}]');
            RCM_QuoteRequest obj4=new RCM_QuoteRequest();
            obj4.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getSimilarExistingCase');
            //System.currentPageReference().getParameters().put('partner', '-1');
            //System.currentPageReference().getParameters().put('jsonPostData','[{"RCM_QuoteRequest.requestCaseSearch":{"contractNumber":"1234","supportLevel":"2","durationLevel":"2"}}]');
            RCM_QuoteRequest obj5=new RCM_QuoteRequest();
            obj5.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getSimilarExistingCase'); // soumya
            //System.currentPageReference().getParameters().put('partner', '-1');
            //System.currentPageReference().getParameters().put('jsonPostData','[{"RCM_QuoteRequest.requestCaseSearch":{"contractNumber":"1234","supportLevel":"2","durationLevel":"2"}}]');
            RCM_QuoteRequest obj6=new RCM_QuoteRequest();
            obj6.redirectingToMethods();
            /*,"requestCaseSearch":{"contractNumber":"1234","supportLevel":"2","durationLevel":"2"}*/
        }
        test.StopTest();               
    }
    
    private static testMethod void testRCM_QuoteRequestQuoteSearchnew1(){
        setupTestData();
        Rs2_customsetting();
        test.startTest();
         Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[0].id!=null){
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            insert reqList;
            
           
            
        }
        if(!oppList.isEmpty() && oppList[1].id!=null){
            rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = False,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
        }
        
        System.runAs(userList[0]){
            if(!oppList.isEmpty() && oppList[0].id!=null){
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                insert rqList;
                
                Blob bodyOfAttachment= Blob.valueof('the body of the attachment');
                List<Attachment> attach = new List<Attachment>();
                attach.add(new Attachment(Name = 'test.pdf',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xml',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xlsx',ParentId = rqList[2].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xls',ParentId = rqList[2].Id,body = bodyOfAttachment));
                insert attach;
            
            }
           
            List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessList=new List<RS2_Quote_Multiple_Partners__c>();
            RS2_Quote_Multiple_Partners__c quotespartnerAccessobj=new RS2_Quote_Multiple_Partners__c(Renewal_Quote__c=rqlist[1].id,PartnerSharing__c='Ready For Sharing',Account__c=accList[0].id,Opportunity__c = oppList[1].id);
            quotespartnerAccessList.add(quotespartnerAccessobj);
            insert quotespartnerAccessList;
            
            PageReference pageRef = Page.RS2_QuoteRequestSP;
            Test.setCurrentPage(pageRef);
                      
            System.currentPageReference().getParameters().put('method', 'getSimilarExistingCase');
            //System.currentPageReference().getParameters().put('partner', '-1');
            //System.currentPageReference().getParameters().put('jsonPostData','[{"RCM_QuoteRequest.requestCaseSearch":{"contractNumber":"1234","supportLevel":"2","durationLevel":"2"}}]');
            RCM_QuoteRequest obj1=new RCM_QuoteRequest();
            obj1.redirectingToMethods();
           
        }
        test.StopTest();               
    }
    private static testMethod void testRCM_QuoteRequestQuoteSearch2(){
        List<RS2_Opp_Multiple_Partners__c> deleteOPA=new List<RS2_Opp_Multiple_Partners__c>();
        List<RS2_Quote_Multiple_Partners__c> qpa = new List<RS2_Quote_Multiple_Partners__c>();
        setupTestData();
        Rs2_customsetting();
        test.startTest();
         Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[0].id!=null){
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            insert reqList;
            
           
            
        }
        if(!oppList.isEmpty() && oppList[1].id!=null)
            {
            rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='1 Year',Primary_Flag__c = False,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(5)));
            }
        
        System.runAs(userList[0]){
            
            
            if(!oppList.isEmpty() && oppList[0].id!=null){
                
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(5)));
                
                //rqlist.add(new Renewal_Quote__c(Name = 'Test Quote3',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
                
                insert rqList;

                Blob bodyOfAttachment= Blob.valueof('the body of the attachment');
                List<Attachment> attach = new List<Attachment>();
                attach.add(new Attachment(Name = 'test.pdf',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xml',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xlsx',ParentId = rqList[1].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xls',ParentId = rqList[1].Id,body = bodyOfAttachment));
                insert attach;

                
            }
            
            
            if(oppList[0].Id!=null && accList[0].id!=null){
                for(RS2_Opp_Multiple_Partners__c op:[select id from RS2_Opp_Multiple_Partners__c where (Opportunity__c =:oppList[0].Id OR Opportunity__c =:oppList[1].Id) and Account__c=:accList[0].id]){
                    deleteOPA.add(op);
                }
            }
            if(!deleteOPA.isEmpty()){
                delete deleteOPA;
            }
            if(!rqList.isEmpty() && oppList[0].Id!=null && accList[0].id!=null && rqList[1].Id!=null){
                for(RS2_Quote_Multiple_Partners__c qp:[select id from RS2_Quote_Multiple_Partners__c where (Opportunity__c =:oppList[0].Id OR Opportunity__c =:oppList[1].Id) and Account__c=:accList[0].id and Renewal_Quote__c=:rqList[1].Id]){
                    qpa.add(qp);
                }
            }
            if(!qpa.isEmpty()){
                delete qpa;
            }
            PageReference pageRef = Page.RS2_QuoteRequestSP;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('method', 'getAvailableQuotesByContractNumber');
             System.currentPageReference().getParameters().put('partner', '-1');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":""}]');
            RCM_QuoteRequest obj=new RCM_QuoteRequest();
            obj.redirectingToMethods();
            
             System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber()');
             System.currentPageReference().getParameters().put('partner', '-1');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"As Is","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":""}]');
            RCM_QuoteRequest obj1=new RCM_QuoteRequest();
            obj1.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber()');
             System.currentPageReference().getParameters().put('partner', '1019030');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"As Is","specifySnsLevel":"","duration":"1 Year","endDate":"System.today()","opportunityId":""},{"contractNumber":"","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"System.today()","opportunityId":""}]');
             RCM_QuoteRequest obj2=new RCM_QuoteRequest();
            obj2.redirectingToMethods();
            /*System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber');
            RCM_QuoteRequest obj2=new RCM_QuoteRequest();
            obj2.redirectingToMethods();*/
            
        
        }
        test.StopTest();               
    }
    
    
    
    
    
    
    private static testMethod void testRCM_ReactiveQuoteRequestQuoteSearch2(){
        List<RS2_Opp_Multiple_Partners__c> deleteOPA=new List<RS2_Opp_Multiple_Partners__c>();
        List<RS2_Quote_Multiple_Partners__c> qpa = new List<RS2_Quote_Multiple_Partners__c>();
        setupTestData();
        Rs2_customsetting();
        test.startTest();
         Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[0].id!=null){
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            insert reqList;
            
           
            
        }
        //if(!oppList.isEmpty() && oppList[1].id!=null)
            {
            //rqlist.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Production',Support_Duration__c='1 Year',Primary_Flag__c = False,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            }
       
        System.runAs(userList[0]){
            
            
            if(!oppList.isEmpty() && oppList[0].id!=null)
            {
                
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive PDS',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345577',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                
                insert rqList;   
                
                Blob bodyOfAttachment= Blob.valueof('the body of the attachment');
                List<Attachment> attach = new List<Attachment>();
                attach.add(new Attachment(Name = 'test.pdf',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xml',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xlsx',ParentId = rqList[1].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xls',ParentId = rqList[1].Id,body = bodyOfAttachment));
                insert attach;
                
            }
            
            
            if(oppList[0].Id!=null && accList[0].id!=null){
                for(RS2_Opp_Multiple_Partners__c op:[select id from RS2_Opp_Multiple_Partners__c where (Opportunity__c =:oppList[0].Id) and Account__c=:accList[0].id]){
                    deleteOPA.add(op);
                }
            }
            if(!deleteOPA.isEmpty()){
                //delete deleteOPA;
            }
            if(!rqList.isEmpty() && oppList[0].Id!=null && accList[0].id!=null && rqList[1].Id!=null){
                for(RS2_Quote_Multiple_Partners__c qp:[select id from RS2_Quote_Multiple_Partners__c where (Opportunity__c =:oppList[0].Id) and Account__c=:accList[0].id and Renewal_Quote__c=:rqList[1].Id]){
                    qpa.add(qp);
                }
            }
            if(!qpa.isEmpty()){
                //delete qpa;
            }
            PageReference pageRef = Page.RS2_QuoteRequestSP;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber');
            System.currentPageReference().getParameters().put('partner', '-1');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":""}]');
            
            RCM_QuoteRequest obj=new RCM_QuoteRequest();
            obj.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('partner', '1019030');
            
            RCM_QuoteRequest obj2=new RCM_QuoteRequest();
            obj2.redirectingToMethods();
            
        }
        test.StopTest();               
    }
    
        
    private static testMethod void testRCM_QuoteRequestRevision(){
        setupTestData();
        Rs2_customsetting();
        test.startTest();
         Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[0].id!=null){
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            insert reqList;
            
           
            
        }
        
        System.runAs(userList[0]){
            if(!oppList.isEmpty() && oppList[0].id!=null){
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = false,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = False,Visible_Flag__c = false,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote3',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                insert rqList;
                
                Blob bodyOfAttachment= Blob.valueof('the body of the attachment');
                List<Attachment> attach = new List<Attachment>();
                attach.add(new Attachment(Name = 'test.pdf',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xml',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xlsx',ParentId = rqList[1].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xls',ParentId = rqList[1].Id,body = bodyOfAttachment));
                insert attach;
                
                List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessList1=new List<RS2_Quote_Multiple_Partners__c>();
                RS2_Quote_Multiple_Partners__c quotespartnerAccessobj1=new RS2_Quote_Multiple_Partners__c(Renewal_Quote__c=rqlist[2].id,PartnerSharing__c='Ready For Sharing',Account__c=accList[0].id,Opportunity__c = oppList[0].id);
                quotespartnerAccessList1.add(quotespartnerAccessobj1);
                insert quotespartnerAccessList1;
                ApexPages.CurrentPage().getParameters().put('popup','false');
                if(!rqList.isEmpty()){
                    if(rqList[0].Id!=null){
                        PageReference pageRef = Page.RS2_QuoteRequestSP;
                        Test.setCurrentPage(pageRef);
                        System.currentPageReference().getParameters().put('method', 'quoteRevision');
                        System.currentPageReference().getParameters().put('partner', '-1');
                        System.currentPageReference().getParameters().put('popup', 'false');
                        System.currentPageReference().getParameters().put('jsonPostData','{"contractNumber":"12345566","quoteRevisionRequest":{"reviseQuoteId":"'+String.valueOf(rqList[0].Id)+'","reviseSnsLevel":"Basic","reviseOtherSnsLevel":"","reviseDuration":"1 Year","reviseEndDate":"","reviseIsActive":false,"reviseRemoveInstance":"","reviseDistributorId":"","reviseResellerId":"","reviseOther":""}}');
                        RCM_QuoteRequest obj=new RCM_QuoteRequest();
                        obj.redirectingToMethods();
                    }
                    if(rqList[1].Id!=null){
                        System.currentPageReference().getParameters().put('method', 'quoteRevision');
                        System.currentPageReference().getParameters().put('popup', 'false');
                        System.currentPageReference().getParameters().put('jsonPostData','{"contractNumber":"12345566","quoteRevisionRequest":{"reviseQuoteId":"'+String.valueOf(rqList[1].Id)+'","reviseSnsLevel":"Basic","reviseOtherSnsLevel":"","reviseDuration":"1 Year","reviseEndDate":"","reviseIsActive":false,"reviseRemoveInstance":"","reviseDistributorId":"","reviseResellerId":"","reviseOther":""}}');
                        RCM_QuoteRequest obj=new RCM_QuoteRequest();
                        obj.redirectingToMethods();
                    }
                    if(rqList[2].Id!=null){
                        System.currentPageReference().getParameters().put('method', 'quoteRevision');
                        System.currentPageReference().getParameters().put('jsonPostData','{"contractNumber":"12345566","quoteRevisionRequest":{"reviseQuoteId":"'+String.valueOf(rqList[2].Id)+'","reviseSnsLevel":"Basic","reviseOtherSnsLevel":"","reviseDuration":"1 Year","reviseEndDate":"","reviseIsActive":false,"reviseRemoveInstance":"","reviseDistributorId":"","reviseResellerId":"","reviseOther":""}}');
                        RCM_QuoteRequest obj=new RCM_QuoteRequest();
                        obj.redirectingToMethods();
                    }
                }
            }
        }
        test.StopTest();               
    }   
    
    
    private static testMethod void testRCM_QuoteRequestSubmit(){
        setupTestData();
        Rs2_customsetting();
        test.startTest();
         Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[0].id!=null){
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            insert reqList;
            
           
            
        }
        
        System.runAs(userList[0]){
        
        rqlist.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = false,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
        
        rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = False,Visible_Flag__c = false,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
        
        insert rqList;
        
            if(!reqList.isEmpty() && (reqList[0].Id!=null))
            {
                PageReference pageRef = Page.RS2_QuoteRequestSP;
                Test.setCurrentPage(pageRef);
                System.currentPageReference().getParameters().put('method', 'submitQuoteRequests');
                 System.currentPageReference().getParameters().put('partner', '-1');
                System.currentPageReference().getParameters().put('jsonPostData','[{"eaNumber":"'+earec.Name+'","eaName":"'+earec.Name+'","contractNumber":"12345566","revisedQuotes":[{"quoteId":"'+String.valueOf(rqList[0].Id)+'","snsLevel":"Production","otherSnsLevel":"","duration":"1 and 3 Year","endDate":"12/31/2014","isActive":false,"active":false,"removeInstance":"123438769","distributorId":"","resellerId":"","other":"","distObj":null,"resellerObj":null}],"distributorContacts":[{"name":"test","email":"test@test.com","bPrimary":true}],"notesToDistributor":"testing"}]');
                RCM_QuoteRequest obj=new RCM_QuoteRequest();
                obj.redirectingToMethods();
            }
        }
        test.StopTest();               
    }
    //START - CR-00135058
    private static testMethod void testgetSimilarExistingCase(){
        setupTestData();
        Rs2_customsetting();
        test.startTest();
        Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        System.runAs(userList[0]){
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[0].id!=null){
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE));
            reqList.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            insert reqList;
            
           
            
        }
        
        String CustomerRequests = Parameters__c.getInstance('Request Origin Customer').UI_Mapping__c;
        String renewalsRecordType = Record_Type_Settings__c.getInstance('CaseRenewalOperations').Record_Type_ID__c;
        Id endCustomerRecType = (Id)( Record_Type_Settings__c.getInstance('GSS_ACC_EC').Record_Type_ID__c);
        Date todayDate = system.today();
            Account a = new Account(Name = 'TestAccount',Partner_ID__c = '1019030',RecordTypeId = endCustomerRecType);
            insert a;
            Case caseObj = new Case(Email_Address__c = 'test@test.com',RecordTypeId = renewalsRecordType,Origin = CustomerRequests,AccountId = a.id,Vmware_Contract_Number__c = '12345566',GSS_Support_Level__c = '2',Duration_Level__c = 'Other',Contract_End_Date__c = Date.newInstance(2015 , 09 ,18));
            insert caseObj;
            PageReference pageRef = Page.RS2_QuoteRequestSP;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('method', 'getSimilarExistingCase');
            System.currentPageReference().getParameters().put('partner', '-1');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","durationLevel":"1 and 3 Year","supportLevel":"2","endDate":"12/31/2014","currencyCustom":"USD"}]');
            RCM_QuoteRequest obj5=new RCM_QuoteRequest();
            obj5.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getSimilarExistingCase');
            System.currentPageReference().getParameters().put('partner', '1019030');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","durationLevel":"Other","supportLevel":"2","endDate":"9/18/2015","currencyCustom":"USD"}]');
            RCM_QuoteRequest obj6=new RCM_QuoteRequest();
            obj6.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getSimilarExistingCase');
            System.currentPageReference().getParameters().put('partner', '-1');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","durationLevel":"3 Year","supportLevel":"1","endDate":"12/31/2014","currencyCustom":"USD"}]');
            RCM_QuoteRequest obj7=new RCM_QuoteRequest();
            obj7.redirectingToMethods();
            
        }
        
        test.stopTest();    
    }
     //END - CR-00135058
     // START - IBS - 366
      private static testMethod void testRCM_QuoteRequestQ(){
        setupTestData();
        Rs2_customsetting();
        test.startTest();
         Id oppRecordtypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales Opportunity').getRecordTypeId();
        if(oppRecordtypeId!=null && earec!=null){
            oppList.add(new Opportunity(stageName='02 - Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-1',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345566',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            oppList.add(new Opportunity(stageName='01 - Not Contacted',Existing_Reseller__c=accList[0].id,Name='Test Opp 007-2',EA_NAME__c=earec.Name,EA_NUMBER__c=earec.Name,RS2_Expiring_Contract_Number__c='12345577',CloseDate=date.today(),ownerid=userList[0].id,recordtypeId=oppRecordtypeId));
            insert oppList;
        }
        if(!oppList.isEmpty() && oppList[1].id!=null){
            rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = False,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
            rqlist.add(new Renewal_Quote__c(Name = 'Test Quote2',Support_Level__c='Production',Support_Duration__c='3 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Reactive',Contract_Number__c='12345566',Opportunity__c = oppList[1].id, Flag_for_delete__c = FALSE));
        }
        
        System.runAs(userList[0]){
            if(!oppList.isEmpty() && oppList[0].id!=null){
                rqlist.add(new Renewal_Quote__c(Name = 'Test Quote1',Support_Level__c='Basic',Support_Duration__c='1 Year',Primary_Flag__c = True,Visible_Flag__c = True,Quote_Classification__c = 'Proactive',Contract_Number__c='12345566',Opportunity__c = oppList[0].id, Flag_for_delete__c = FALSE,Quote_Expiry_Date__c=system.today().adddays(7)));
                insert rqList;
                
                Blob bodyOfAttachment= Blob.valueof('the body of the attachment');
                List<Attachment> attach = new List<Attachment>();
                attach.add(new Attachment(Name = 'test.pdf',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xml',ParentId = rqList[0].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xlsx',ParentId = rqList[2].Id,body = bodyOfAttachment));
                attach.add(new Attachment(Name = 'test123.xls',ParentId = rqList[2].Id,body = bodyOfAttachment));
                insert attach;
                list<RCM_Attachments__c> lstRcmReqAtt = new list<RCM_Attachments__c>();
                RCM_Attachments__c rcmrequestAtt = new RCM_Attachments__c(
                    Name= '377343272_Manual_Quote_42395774_R_18JUL16_04_29_46_18072016043008_Quote.pdf',
                    File_Name__c='377343272_Manual_Quote_42395774_R_18JUL16_04_29_46_18072016043008_Quote',
                    File_Location__c='/2016/Q3/377343272_Manual_Quote_42395774_R_18JUL16_04_29_46_18072016043008_Quote.pdf',
                    File_Size__c= 28,
                    File_Type__c='PDF',
                    Quote_Parent_Id__c =rqList[0].Id ,
                    islatest__c =true,
                    Attachment_Id__c =attach[0].Id );
                lstRcmReqAtt.add(rcmrequestAtt);
                RCM_Attachments__c rcmrequestAtt2 = new RCM_Attachments__c(
                    Name= '377343272_Manual_Quote_42395774_R_18JUL16_04_29_46_18072016043009_Quote.pdf',
                    File_Name__c='377343272_Manual_Quote_42395774_R_18JUL16_04_29_46_18072016043009_Quote',
                    File_Location__c='/2016/Q3/377343272_Manual_Quote_42395774_R_18JUL16_04_29_46_18072016043009_Quote.pdf',
                    File_Size__c=28,
                    File_Type__c='PDF',
                    Quote_Parent_Id__c =rqList[1].Id ,
                    islatest__c =true,
                    Attachment_Id__c =attach[1].Id );
                    lstRcmReqAtt.add(rcmrequestAtt2);
                insert lstRcmReqAtt;
            }
           
            List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessList=new List<RS2_Quote_Multiple_Partners__c>();
            RS2_Quote_Multiple_Partners__c quotespartnerAccessobj=new RS2_Quote_Multiple_Partners__c(Renewal_Quote__c=rqlist[1].id,PartnerSharing__c='Ready For Sharing',Account__c=accList[0].id,Opportunity__c = oppList[1].id);
            quotespartnerAccessList.add(quotespartnerAccessobj);
            insert quotespartnerAccessList;

            PageReference pageRef = Page.RS2_QuoteRequestSP;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('method', 'getAvailableQuotesByContractNumber');
            System.currentPageReference().getParameters().put('partner', '-1');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":""}]');
            RCM_QuoteRequest obj=new RCM_QuoteRequest();
            obj.redirectingToMethods();
            /*
            System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":""}]');
            RCM_QuoteRequest obj1=new RCM_QuoteRequest();
            obj1.redirectingToMethods();
            //obj2.getAvailableQuotesByContractNumber();
            
            System.currentPageReference().getParameters().put('method', 'getAvailableQuotesByContractNumber');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":"+oppList[1].id+"}]');
            RCM_QuoteRequest obj2=new RCM_QuoteRequest();
            obj2.redirectingToMethods();
            
            System.currentPageReference().getParameters().put('method', 'getAvailableReactiveQuotesByContractNumber');
            System.currentPageReference().getParameters().put('jsonPostData','[{"contractNumber":"12345566","snsLevel":"Basic","specifySnsLevel":"","duration":"1 Year","endDate":"","opportunityId":""},{"contractNumber":"12345577","snsLevel":"Production","specifySnsLevel":"","duration":"3 Year","endDate":"","opportunityId":"+oppList[1].id+"}]');
            RCM_QuoteRequest obj3=new RCM_QuoteRequest();
            obj3.redirectingToMethods();
            */
            
            Map<Id,Boolean> IdMaptestOPA = new Map<Id,Boolean>();
            RCM_QuoteRequest rcmreQ = new RCM_QuoteRequest();
            IdMaptestOPA = rcmreQ.createOpportunityPartnerAccess(oppList);
            
            Map<Id,Boolean> IdMaptestQPA = new Map<Id,Boolean>();
            RCM_QuoteRequest rcmreQ2 = new RCM_QuoteRequest();
            IdMaptestQPA = rcmreQ2.createQuotePartnerAccess(rqlist);
        }
        test.StopTest();               
    }
    // END - IBS - 366
}