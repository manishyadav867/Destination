@isTest(seeAllData = true)
public class RS2_RenewalQuoteAfterInserttest{ 
    public static Id oRTSACC =Record_Type_Settings__c.getInstance('CaseRenewalOperations').Record_Type_ID__c;
    public static Id OppRTid = Record_Type_Settings__c.getValues('RS2_Renewal_Sales_Opportunity').Record_Type_ID__c;
    public static List<RS2_Opportunity_Case_Staging__c> OppoCaseStaginglist; 
    public static List<Account> listAccounts;
    public static List<Case> listCase;
    public static  List<opportunity> opptyList = New List<opportunity>();
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
    public static void testdata1(){
        
        listAccounts = new List<Account>();
        Account testAccount = new Account();
        testAccount.Name = 'Test Acc';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.GSS_S1_Red_Alert_Notifications__c = true;
        listAccounts.add(testAccount);  

         Account testAccount1 = new Account();
        testAccount1.Name = 'Test Acc1';        
        testAccount1.Country__c = 'UNITED STATES';
        testAccount1.Partner_ID__c = '10012771';
        listAccounts.add(testAccount1);    
        insert listAccounts;
        

        
        listCase = new List<Case>();
        Case testCase1 = new Case(Origin='RCM',status='Open',Request_Sub_Type__c='New',GSS_Preferred_Method_of_Contact__c='Email',Internal_Comments__c='hello example4',QC_Type__c = 'Reactive',Contract_End_Date__c = system.Today(),Make_Quote_Active__c = true,CurrencyIsoCode = 'JPY',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Other',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Vmware_Contract_Number__c='12345644');
        listCase.add(testCase1);
        
        Case testCase2 = new Case(status='Open',Internal_Comments__c='hello example2',Origin='VMSTAR',GSS_Preferred_Method_of_Contact__c='Email',QC_Type__c = 'Reactive',Contract_End_Date__c = system.Today(),Make_Quote_Active__c = true,CurrencyIsoCode = 'USD',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Non-Standard Term',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Request_Sub_Type__c='New',Vmware_Contract_Number__c='12345622');
        listCase.add(testCase2);
        
         Case testCase3 = new Case(status='Open',Internal_Comments__c='hello example3',Origin='VMSTAR',GSS_Preferred_Method_of_Contact__c='Email',QC_Type__c = 'Reactive',Contract_End_Date__c = system.Today(),Make_Quote_Active__c = true,CurrencyIsoCode = 'EUR',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Non-Standard Term',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Request_Sub_Type__c='New',Vmware_Contract_Number__c='12345633');
        listCase.add(testCase3);
        
        Case testCase4 = new Case(Origin='RCM',status='Open',Request_Sub_Type__c='New',GSS_Preferred_Method_of_Contact__c='Email',Internal_Comments__c='hello example4',QC_Type__c = 'Reactive',Contract_End_Date__c = system.Today().addyears(6),Make_Quote_Active__c = true,CurrencyIsoCode = 'JPY',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                             GSS_Problem_Category__c='OS',Duration_Level__c = 'Other',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                             Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Vmware_Contract_Number__c='12345644');
        listCase.add(testCase4);
        
        insert listCase;
        
        
        
        listCase[1].Contract_End_Date__c= system.Today().adddays(-2);
        listCase[1].status='Open';
        listCase[1].Sub_Status__c=' ';
        listCase[2].Contract_End_Date__c= system.Today().addyears(6);
        listCase[2].status='Open';
        listCase[2].Sub_Status__c=' ';
        update listCase;
        
        
        OppoCaseStaginglist = new List<RS2_Opportunity_Case_Staging__c>();
        RS2_Opportunity_Case_Staging__c OppoCaseStagingObj = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',Source_Case_Number__c = listCase[0].id);
        OppoCaseStaginglist.add(OppoCaseStagingObj);
        
        RS2_Opportunity_Case_Staging__c OppoCaseStagingObj1 = new RS2_Opportunity_Case_Staging__c(EBS_Exp_Contract_Flag__c='Yes',Source_Case_Number__c = listCase[3].id);
        OppoCaseStaginglist.add(OppoCaseStagingObj1);
        
        
        insert OppoCaseStaginglist;
        
        OppoCaseStaginglist[0].EBS_Expiring_Contract_End_Date__c=Date.valueof(System.today());
        OppoCaseStaginglist[1].EBS_Expiring_Contract_End_Date__c=Date.valueof(System.today());
        update OppoCaseStaginglist;
    }
    public static testMethod  void quoteEndDateAfterInserttest(){
        
        Rs2_customsetting();
        testdata1(); 
        test.starttest();
        
        List<CaseComment> CssList =new  List<CaseComment>();
        CssList.add(new CaseComment(CommentBody='Approved',ParentId=listCase[0].id));
        insert CssList;
        
      
        List<Renewal_Quote__c> RQuoteList = New List<Renewal_Quote__c>();
        List<Renewal_Quote__c> UpdateRQuoteList = New List<Renewal_Quote__c>();
        
        //Insert opportunity records
        opportunity oppty1 = new opportunity(RecordTypeId = OppRTid,Name = 'Accenture test oppty1', StageName = '01 - Not Contacted', CloseDate = System.Today(), amount = 200); 
        opportunity oppty2 = new opportunity(RecordTypeId = OppRTid,Name = 'Accenture test oppty2', StageName = '01 - Not Contacted', CloseDate = System.Today(), amount = 300,Parent_Consolidated__c=true);//Added Parent_Consolidated__c field for CR-00134711 
        opptyList.add(oppty1);
        opptyList.add(oppty2);
        Insert opptyList;
        
        List<Case> newCaseList=new List<Case>([Select id,CaseNumber from Case where Id IN:listCase]);
        
        //Boolean InsertBol=true;
       
        //Insert Renewal Quote records
        Renewal_Quote__c RQ1 = new Renewal_Quote__c(Name = 'TestQoute1', Opportunity__c = opptyList[0].id, Quote_Net_Price__c = 6000,Primary_Flag__c = True,Quote_Classification__c = 'Reactive',Case__c=newCaseList[0].CaseNumber,Quote_End_Date__c=system.today(),CurrencyIsoCode='USD');
        Renewal_Quote__c RQ2 = new Renewal_Quote__c(Name = 'TestQoute2', Opportunity__c = opptyList[0].id, Quote_Net_Price__c = 8000,Primary_Flag__c = True,Quote_Classification__c = 'Reactive',Case__c=newCaseList[1].CaseNumber,Quote_End_Date__c=system.today(),CurrencyIsoCode='EUR');
        Renewal_Quote__c RQ3 = new Renewal_Quote__c(Name = 'TestQoute3', Opportunity__c = opptyList[1].id, Quote_Net_Price__c = 9000,Primary_Flag__c = True,Quote_Classification__c = 'Reactive',Case__c=newCaseList[2].CaseNumber,Quote_End_Date__c=system.today(),CurrencyIsoCode='JPY');
        Renewal_Quote__c RQ4 = new Renewal_Quote__c(Name = 'TestQoute4', Opportunity__c = opptyList[1].id, Quote_Net_Price__c = 3000,Primary_Flag__c = True,Case__c=newCaseList[3].CaseNumber,Quote_End_Date__c=system.today(),CurrencyIsoCode='USD');
        RQuoteList.add(RQ1);
        RQuoteList.add(RQ2);
        RQuoteList.add(RQ3);
        RQuoteList.add(RQ4);
        Insert RQuoteList;
        
        RQuoteList[0].Visible_Flag__c=true;
        update RQuoteList;
        
        RS2_RenewalQuoteAfterInsert.quoteEndDateAfterInsert(RQuoteList,true);
        
        RS2_RenewalQuoteAfterInsert.currecyChangeAfterInsert(RQuoteList);
        
        test.stoptest();
    }
     public static void setupdata(){
        listAccounts = new List<Account>();
        Account testAccount = new Account();
        testAccount.Name = 'Test Acc';        
        testAccount.Country__c = 'INDIA';
        testAccount.Type='Public Sector';
        testAccount.GSS_S1_Red_Alert_Notifications__c = true;
        listAccounts.add(testAccount);  
        insert listAccounts;
        
        opportunity oppty1 = new opportunity(RecordTypeId = OppRTid,Name = 'Accenture test oppty1', StageName = '01 - Not Contacted', CloseDate = System.Today(), amount = 200); 
        opptyList.add(oppty1);
        Insert opptyList;
    }
    public static testMethod  void quoteEndDateAfterInserttest3(){
        List<Renewal_Quote__c> RQuoteList1 = New List<Renewal_Quote__c>();
        List<Renewal_Quote__c> RQuoteList2 = New List<Renewal_Quote__c>();
        
        Rs2_customsetting();
        setupdata();
        listCase = new List<Case>();
            Case testCase4 = new Case(Origin='RCM',status='Open',Request_Sub_Type__c='New',GSS_Preferred_Method_of_Contact__c='Email',Internal_Comments__c='hello example4',QC_Type__c = 'Reactive',Contract_End_Date__c = system.Today().addyears(6),Make_Quote_Active__c = true,CurrencyIsoCode = 'JPY',Reason_for_Update__c = 'The quote provided by VMware does not match with what was requested',Priority='1 - Critical',GSS_ScreenPopTime__c=datetime.now(),
                                 GSS_Problem_Category__c='OS',Duration_Level__c = 'Other',GSS_Support_Level__c='2',Subject ='Testing1', GSS_Support_Customer_Region__c ='APJ',GSS_Additional_Emails__c='test@gmail.com',Region_First_Response__c='NASA',RNV_Status__c='Escalated',GSS_Preferred_Phone_Number__c='00000',GSS_Country__c='Brazil',Count_Comments__c=3,
                                 Description='Testing-PP-17997-1',AccountId= listAccounts[0].Id,recordTypeId=oRTSACC,Request_Type__c='Single Quote',Vmware_Contract_Number__c='12345644');
            listCase.add(testCase4);
            insert listCase;
        test.starttest();
        User u=[Select id from User where id ='00580000006ZY2fAAG'];
        system.runAs(u){
            Case_Extension__c csExt = [select Id,Case__c,Quote_Date__c from Case_Extension__c where Case__c  =: testCase4.Id];
            csExt.Quote_Date__c = Date.valueof(system.now());
            update csExt;
            //Case_Extension__c csExt = new Case_Extension__c(Case__c = listCase[0].Id,Quote_Date__c = date.valueof(system.today())); 
            //insert csExt;
            List<CaseComment> CssList =new  List<CaseComment>();
            CssList.add(new CaseComment(CommentBody='Approved',ParentId=listCase[0].id));
            insert CssList;
            
            
            
            List<Case> newCaseList=new List<Case>();
            if(!listCase.isEmpty())
            newCaseList= [Select id,CaseNumber from Case where Id IN:listCase];
            
            Renewal_Quote__c RQ1 = new Renewal_Quote__c(Name = 'TestQoute1', Opportunity__c = opptyList[0].id, Quote_Net_Price__c = 6000,Primary_Flag__c = True,Quote_Classification__c = 'Reactive',Case__c=newCaseList[0].CaseNumber,Quote_End_Date__c=system.today(),CurrencyIsoCode='USD');
            RQuoteList1.add(RQ1);
            Insert RQuoteList1;
            
            RQuoteList1[0].Visible_Flag__c=true;
            RQuoteList2.addall(RQuoteList1);
            update RQuoteList2;
        }
        test.stoptest();
    }
}