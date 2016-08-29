/************************************************************************************
* Name             : RS2_StabilizationUtilityTest
* Description      : RS2 Project (CR-)
* Created By       : Shiwali Jain(Accenture)
* Created Date     : 28.03.2016
*************************************************************************************
* Date         Change-Request          Modified By                    Description
*************************************************************************************
*
*************************************************************************************/

@isTest(seeAllData=true)
public class RS2_StabilizationUtilityTest
{ 
  public static Id oRTSACC = Record_Type_Settings__c.getInstance('CaseRenewalOperations').Record_Type_ID__c;
  public static Case testCase1;
  public static Case testCase2;
  public static Case testCase3;
  public static Case testCase4;
  public static Case testCase5;
  public static List<Account> listAccounts;
  public static Account testAccount;
  public static Account testAccount1;
  public static List<Case> listCase;
  public static List<Case> listCase1;
  public static List<RS2_Opportunity_Case_Staging__c> OppoCaseStaginglist; 
  public static RS2_Opportunity_Case_Staging__c OppoCaseStagingObj;
  public static RS2_Opportunity_Case_Staging__c OppoCaseStagingObj1;
  public static RS2_Opportunity_Case_Staging__c OppoCaseStagingObj2;
  public static Map<ID,Case> casemap;
  public static Map<ID,Case> casemap1;
  public static  RS2_callEBSWebservice.contractDetails contractdetailObj;
  public static String contractId,stagingId,caseNumber,contractNumber,contractNumberModifier,endDate,OppurtuniyNumber,contractValidationFlag,validationMessage;
  public static List<RS2_Opportunity_Case_Staging__c> caseStagingList;
  public static RS2_Opportunity_Case_Staging__c rs2OpptyObj;
  public static List<RS2_callEBSWebservice.contractDetails> responseList;
  public static RS2_callEBSWebservice.contractDetails responseObj;
  public static RS2_callEBSWebservice.contractDetails responseObj1;
  public static RS2_callEBSWebservice.contractDetails responseObj2;
  public static RS2_callEBSWebservice.contractDetails responseObj3;
  public static Map<id,RS2_Opportunity_Case_Staging__c> stagingRecMap;
  public static List<Contract> contractList = new List<Contract>();
  public static Map<String,List<Opportunity>> contractNumAndOpptyRecMap = new Map<String,List<Opportunity>>();
  public static Opportunity OpptyObj;
  public static List<Opportunity> OpptyList;
  
  
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
            List<RS2_Quoting__c> RS2Quote2=new List<RS2_Quoting__c>();
			RS2_Quoting__c rsq=new RS2_Quoting__c();
			rsq.name='Reactivequoteuser';
			rsq.Value__c='005800000081u6tAAA';
			RS2Quote2.add(rsq);
			RS2_Quoting__c rsq1=new RS2_Quoting__c();
			rsq1.name='RS2FMWUser';
			rsq1.Value__c='00580000006ZY2fAAG';
			RS2Quote2.add(rsq1);
			insert RS2Quote2;
        }
    }
   public static void setupdata()
    {     
        listAccounts = new List<Account>();
        testAccount = new Account();
        testAccount.Name = 'Test Account1';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.GSS_S1_Red_Alert_Notifications__c = true;
        listAccounts.add(testAccount);  

        testAccount1 = new Account();
        testAccount1.Name = 'Test Account2';        
        testAccount1.Country__c = 'UNITED STATES';
        testAccount1.Partner_ID__c = '10012771';
        listAccounts.add(testAccount1);    
        insert listAccounts;
        

        
        listCase = new List<Case>();
        testCase1 = new Case(Origin='RCM',GSS_Preferred_Method_of_Contact__c='Email',Internal_Comments__c='hello example',QC_Type__c = 'Proactive',Contract_End_Date__c = system.Today(),Make_Quote_Active__c = true,CurrencyIsoCode = 'USD',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Non-Standard Term',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Request_Sub_Type__c='New',Vmware_Contract_Number__c='12345678');
        listCase.add(testCase1);
        
          testCase2 = new Case(status='Open/Working',Internal_Comments__c='hello example',Origin='RCM',GSS_Preferred_Method_of_Contact__c='Email',QC_Type__c = 'Proactive',Contract_End_Date__c = system.Today(),Make_Quote_Active__c = true,CurrencyIsoCode = 'USD',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Non-Standard Term',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Request_Sub_Type__c='New',Vmware_Contract_Number__c='12345678');
        listCase.add(testCase2);
        
        testCase3 = new Case(status='Open/Working',Origin='RCM',Internal_Comments__c='hello example',GSS_Preferred_Method_of_Contact__c='Email',QC_Type__c = 'Proactive',Contract_End_Date__c = system.Today(),Make_Quote_Active__c = true,CurrencyIsoCode = 'USD',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Non-Standard Term',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Request_Sub_Type__c='New',Vmware_Contract_Number__c='12345678');
        listCase.add(testCase3);
        
        testCase4 = new Case(status='Open/Working',Origin='RCM',Internal_Comments__c='hello example',GSS_Preferred_Method_of_Contact__c='Email',QC_Type__c = 'Proactive',Contract_End_Date__c = system.Today(),Make_Quote_Active__c = true,CurrencyIsoCode = 'USD',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Non-Standard Term',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[1].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Request_Sub_Type__c='New',Vmware_Contract_Number__c='12345678');
        listCase.add(testCase4);
        insert listCase;
        
      
        
        OppoCaseStaginglist = new List<RS2_Opportunity_Case_Staging__c>();
        OppoCaseStagingObj = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',Existing_Target_Case__c = listCase[0].id,Source_Case_Number__c = listCase[0].id,
        Target_Case__c = listCase[0].id,Status__c='EBS Error');
        OppoCaseStaginglist.add(OppoCaseStagingObj);
        OppoCaseStagingObj1 = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',Existing_Target_Case__c = listCase[2].id,Source_Case_Number__c = listCase[2].id,Target_Case__c = listCase[2].id,Status__c='EBS Error');
        OppoCaseStaginglist.add(OppoCaseStagingObj1);
        OppoCaseStagingObj2 = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',Existing_Target_Case__c = listCase[1].id,Source_Case_Number__c = listCase[1].id,Target_Case__c = listCase[1].id,Status__c='EBS Error');
        OppoCaseStaginglist.add(OppoCaseStagingObj2);
        
        insert OppoCaseStaginglist;
        
        contractList.add(new Contract(accountId = listAccounts[0].id,Status = 'Draft',CTA_Sign_Date__c = Date.Valueof(System.today() - 2),I_Agree__c = true,Contract_Type__c = 'Click Through',Program_Type__c = 'Solution Provider'));
        insert contractList;
    }
    
  public static testMethod void method1()
    {
       
        Rs2_customsetting();
        setupdata();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new JscapeMockHttpResponseGenerators());
        String error = 'Error';
        String req = 'Request';
        String res = 'Response';
        String source = 'VMStar';
        RS2_callEBSWebservice.updateStagingRecords(OppoCaseStaginglist,error,req,res,source);
        String source1 = 'EBS';
        RS2_callEBSWebservice.updateStagingRecords(OppoCaseStaginglist,error,req,res,source1);
        test.stopTest();
    }
     
 public static testMethod void method2()
    {
        test.startTest();
        Rs2_customsetting();
        setupdata();
        List<RS2_Opportunity_Case_Staging__c> OppCasStaglist = new List<RS2_Opportunity_Case_Staging__c>();
        RS2_Opportunity_Case_Staging__c OpCaseStagObj = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',Existing_Target_Case__c = listCase[0].id,Source_Case_Number__c = listCase[0].id,Target_Case__c = listCase[0].id,Status__c='EBS Error');
        OppCasStaglist.add(OpCaseStagObj);
        insert OppCasStaglist;
        
        stagingRecMap = new Map<id,RS2_Opportunity_Case_Staging__c> ();
        for(RS2_Opportunity_Case_Staging__c obj1:OppCasStaglist)
            {
                stagingRecMap.put(obj1.id,obj1);
            }
   
        casemap = new Map<ID,Case>();
        for(Case c:listCase)
        {
            casemap.put(c.id,c);
        } 
        
        responseList = new List<RS2_callEBSWebservice.contractDetails>();
        responseObj = new RS2_callEBSWebservice.contractDetails();
        responseObj.contractId = '12345678';
        responseObj.stagingId = OppCasStaglist[0].id;
        responseObj.caseNumber= 'casenumber';
        responseObj.contractNumber= 'contractnumber';
        responseObj.contractNumberModifier= 'contractnumbermodifier';
        responseObj.endDate=string.valueof(DateTime.Now());
        responseObj.OppurtuniyNumber='12345678' ;
        responseObj.contractValidationFlag= 'Yes';
        responseObj.validationMessage= 'Success'; 
        responseList.add(responseObj);
       
        
        String requestStr = 'req';
        String response = 'res';
        RS2_QuoteRequestProcessing.processResponse(responseList,stagingRecMap,caseMap,requestStr,response);
        test.stopTest();
    }
    public static testMethod void method3()
    {
        Rs2_customsetting();
        test.startTest();
        setupdata();
        
        OpptyObj = new Opportunity(RS2_Expiring_Contract_Number__c = listCase[0].id,RS2_Expiring_Contract_ID__c=12345678,
                          RS2_Expiring_Contract_End_Date__c = date.today(),StageName = '07c - Closed Won',Application_Virtualized__c='MS Office',CloseDate = date.today(),Name = 'abc');
        
        OpptyList=new List<Opportunity>();
        
        OpptyList.add(OpptyObj);
        
        for(Opportunity obj11:OpptyList)
            {
                contractNumAndOpptyRecMap.put(obj11.ID,OpptyList);
            }
        List<ID> StagingIdlist = new List<ID>();
        for(RS2_Opportunity_Case_Staging__c stagingids : OppoCaseStaginglist){
        StagingIdlist.add(stagingids.id);
        }
        
        List<RS2_Opportunity_Case_Staging__c> OppCasStaglist = new List<RS2_Opportunity_Case_Staging__c>();
        RS2_Opportunity_Case_Staging__c OpCaseStagObj = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',Existing_Target_Case__c = listCase[0].id,Source_Case_Number__c = listCase[0].id,Target_Case__c = listCase[0].id,Status__c='EBS Error');
        
        OppCasStaglist.add(OpCaseStagObj);
        insert OppCasStaglist;
        
        stagingRecMap = new Map<id,RS2_Opportunity_Case_Staging__c> ();
        for(RS2_Opportunity_Case_Staging__c obj1:OppCasStaglist)
            {
                stagingRecMap.put(obj1.id,obj1);
            }
   
        casemap = new Map<ID,Case>();
        for(Case c:listCase)
        {
            casemap.put(c.id,c);
        } 
        
        responseList = new List<RS2_callEBSWebservice.contractDetails>();
        responseObj = new RS2_callEBSWebservice.contractDetails();
        responseObj.contractId = '12345678';
        responseObj.stagingId = OppCasStaglist[0].id;
        responseObj.caseNumber= 'casenumber';
        responseObj.contractNumber= 'contractnumber';
        responseObj.contractNumberModifier= 'contractnumbermodifier';
        responseObj.endDate=string.valueof(DateTime.Now());
        responseObj.OppurtuniyNumber='12345678' ;
        responseObj.contractValidationFlag= 'Yes';
        responseObj.validationMessage= 'Success'; 
        responseList.add(responseObj);
       
        
        String requestStr = 'req';
        String response = 'res';
        System.debug('responseList--->'+responseList);
        System.debug('stagingRecMap--->'+stagingRecMap);
        System.debug('caseMap--->'+caseMap);
        System.debug('requestStr--->'+requestStr);
        System.debug('response--->'+response);
            
        RS2_QuoteRequestProcessing.processResponse(responseList,stagingRecMap,caseMap,requestStr,response);
       String ebsContractNum = 'ebsContractNum';
        RS2_QuoteRequestProcessing.getOpptyFromContractNum('ebsContractNum'); 
        test.stopTest();
    }
    public static testMethod void method4()
    {
       
        setupdata();
        Rs2_customsetting();
        test.startTest();
        
        listCase[0].status='Closed';
        update listCase[0];
       
        List<ID> StagingIdlist = new List<ID>();
        for(RS2_Opportunity_Case_Staging__c stagingids : OppoCaseStaginglist){
        StagingIdlist.add(stagingids.id);
        }
        
        casemap = new Map<ID,Case>();
        for(Case c:listCase)
        {
            casemap.put(c.id,c);
        } 
        
        RS2_StabilizationUtility.validateQuoteRequest(listCase);
        test.stopTest();
    }
    public static testMethod void method5()
    {
       
        setupdata();
        Rs2_customsetting();
        test.startTest();
        List<ID> StagingIdlist = new List<ID>();
        for(RS2_Opportunity_Case_Staging__c stagingids : OppoCaseStaginglist){
        StagingIdlist.add(stagingids.id);
        }
         
        RS2_reprocessStagingRecords.checkStagingRecords(StagingIdlist);
        test.stopTest();
    }
    public static testMethod void method6()
    {
        
       
        setupdata();
        Rs2_customsetting();
        
        test.startTest();
         
        List<RS2_Opportunity_Case_Staging__c> OppCasStaglist = new List<RS2_Opportunity_Case_Staging__c>();
        RS2_Opportunity_Case_Staging__c OpCaseStagObj = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',EBS_Expiring_Contract_ID__c = 1234, 
        Expiring_Contract_End_Date__c = datetime.now(),EBS_Opportunity_ID__c='12345678',Existing_Target_Case__c = listCase[0].id,Source_Case_Number__c = listCase[0].id,Target_Case__c = listCase[0].id,Status__c='EBS Error');
        OppCasStaglist.add(OpCaseStagObj);
        RS2_Opportunity_Case_Staging__c OpCaseStagObj1 = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',EBS_Expiring_Contract_ID__c = 1234,Expiring_Contract_End_Date__c = null ,EBS_Opportunity_ID__c= null,Existing_Target_Case__c = listCase[0].id,Source_Case_Number__c = listCase[0].id,Target_Case__c = listCase[0].id,Status__c='EBS Error');
        OppCasStaglist.add(OpCaseStagObj1);
         RS2_Opportunity_Case_Staging__c OpCaseStagObj2 = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes', EBS_Expiring_Contract_ID__c = null,Expiring_Contract_End_Date__c = datetime.now(),EBS_Opportunity_ID__c= '',Existing_Target_Case__c = listCase[0].id,Source_Case_Number__c = listCase[0].id,Target_Case__c = listCase[0].id,Status__c='EBS Error');
        OppCasStaglist.add(OpCaseStagObj2);
        insert OppCasStaglist;
        
        stagingRecMap = new Map<id,RS2_Opportunity_Case_Staging__c> ();
        for(RS2_Opportunity_Case_Staging__c obj1:OppCasStaglist)
        {
            stagingRecMap.put(obj1.id,obj1);
        }
        casemap = new Map<ID,Case>();
        for(Case c:listCase)
        {
            casemap.put(c.id,c);
        } 
        responseList = new List<RS2_callEBSWebservice.contractDetails>();
        responseObj = new RS2_callEBSWebservice.contractDetails();
        responseObj.contractId = '12345678';
        responseObj.stagingId = OppCasStaglist[0].id;
        responseObj.caseNumber= 'casenumber';
        responseObj.contractNumber= '12345678';
        responseObj.contractNumberModifier= 'contractnumbermodifier';
        responseObj.endDate=string.valueof(DateTime.Now());
        responseObj.OppurtuniyNumber='12345678' ;
        responseObj.contractValidationFlag= 'No';
        responseObj.validationMessage= 'Error'; 
        responseList.add(responseObj);
        
        responseObj1 = new RS2_callEBSWebservice.contractDetails();
        responseObj1.contractId = '12345678';
        responseObj1.stagingId = OppCasStaglist[0].id;
        responseObj1.caseNumber= null;
        responseObj1.contractNumber= null;
        responseObj1.contractNumberModifier= null;
        responseObj1.endDate=string.valueof(DateTime.Now());
        responseObj1.OppurtuniyNumber = null ;
        responseObj1.contractValidationFlag= 'Not Found';
        responseObj1.validationMessage= 'Error'; 
        responseList.add(responseObj1);
        
        responseObj2 = new RS2_callEBSWebservice.contractDetails();
        responseObj2.contractId = '12345678';
        responseObj2.stagingId = OppCasStaglist[0].id;
        responseObj2.caseNumber= null;
        responseObj2.contractNumber= null;
        responseObj2.contractNumberModifier= null;
        responseObj2.endDate=null;
        responseObj2.OppurtuniyNumber = null ;
        responseObj2.contractValidationFlag= 'yes';
        responseObj2.validationMessage= ''; 
        responseList.add(responseObj2);
        
        responseObj3 = new RS2_callEBSWebservice.contractDetails();
        responseObj3.contractId = '12345678';
        responseObj3.stagingId =  OppCasStaglist[0].id;
        responseObj3.caseNumber= null;
        responseObj3.contractNumber= null;
        responseObj3.contractNumberModifier= null;
        responseObj3.endDate=string.valueof(DateTime.Now());
        responseObj3.OppurtuniyNumber = null ;
        responseObj3.contractValidationFlag= 'Found';
        responseObj3.validationMessage= 'Success'; 
        responseList.add(responseObj3);
        
        String requestStr = 'req';
        String response = 'res';
        RS2_QuoteRequestProcessing.processResponse(responseList,stagingRecMap,caseMap,requestStr,response);
        String requestStr1 = null;
        String response1 = null;
        RS2_QuoteRequestProcessing.processResponse(responseList,stagingRecMap,caseMap,requestStr1,response1);
        String requestStr2 = 'example';
        String response2 = 'example';
        RS2_QuoteRequestProcessing.processResponse(responseList,stagingRecMap,caseMap,requestStr2,response2);
        test.stopTest();
        
    }
}