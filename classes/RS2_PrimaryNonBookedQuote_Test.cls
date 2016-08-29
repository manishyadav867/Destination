/***************************************************************************
 * Name         : RS2_PrimaryNonBookedQuote_Test
 * Author       : Suman Kumar Patro [Accenture] 
 * Created Date : May 23, 2014 [Against CR-00089987]
 * Usage        : This is a test class for RS2_PrimaryNonBookedQuote trigger.
 ***************************************************************************/
 /*************************Version Updates********************************************
* Date              Developer               Description
* -----------------------------------------------------------------------------------       
* 31st Aug 2015 CR-00134711      Kshipra             Modified code for CR-00134711 (RS2 H2 Project) 
***********************************************************************************/
@isTest(seeAllData = true)
private class RS2_PrimaryNonBookedQuote_Test{

    public static void setupData(){
        List<opportunity> opptyList = New List<opportunity>();
        List<Renewal_Quote__c> RQuoteList = New List<Renewal_Quote__c>();
        List<Renewal_Quote__c> UpdateRQuoteList = New List<Renewal_Quote__c>();
        
        String OppRTid = Record_Type_Settings__c.getValues('RS2_Renewal_Sales_Opportunity').Record_Type_ID__c;
        
        //Insert opportunity records
        opportunity oppty1 = new opportunity(RecordTypeId = OppRTid,Name = 'Accenture test oppty1', StageName = '01 - Not Contacted', CloseDate = System.Today(), amount = 200); 
        opportunity oppty2 = new opportunity(RecordTypeId = OppRTid,Name = 'Accenture test oppty2', StageName = '01 - Not Contacted', CloseDate = System.Today(), amount = 300,Parent_Consolidated__c=true);//Added Parent_Consolidated__c field for CR-00134711 
        opptyList.add(oppty1);
        opptyList.add(oppty2);
        Insert opptyList;
        
        
        //Insert Renewal Quote records
        Renewal_Quote__c RQ1 = new Renewal_Quote__c(Name = 'Qoute1', Opportunity__c = opptyList[0].id, Quote_Net_Price__c = 6000,Primary_Flag__c = True);
        Renewal_Quote__c RQ2 = new Renewal_Quote__c(Name = 'Qoute2', Opportunity__c = opptyList[0].id, Quote_Net_Price__c = 8000,Primary_Flag__c = False);
        Renewal_Quote__c RQ3 = new Renewal_Quote__c(Name = 'Qoute3', Opportunity__c = opptyList[1].id, Quote_Net_Price__c = 9000,Primary_Flag__c = True,Quote_Classification__c = 'Reactive');
        Renewal_Quote__c RQ4 = new Renewal_Quote__c(Name = 'Qoute4', Opportunity__c = opptyList[1].id, Quote_Net_Price__c = 3000,Primary_Flag__c = False);
        RQuoteList.add(RQ1);
        RQuoteList.add(RQ2);
        RQuoteList.add(RQ3);
        RQuoteList.add(RQ4);
        Insert RQuoteList;
        
        
        //Update Renewal Quote records
        RQ4.Primary_Flag__c = true;
        RQ4.Quote_Net_Price__c = 25000;
        RQ1.Quote_Net_Price__c = 45000;
        UpdateRQuoteList.add(RQ4);
        UpdateRQuoteList.add(RQ1);
        update UpdateRQuoteList;
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
    static testmethod void PrimaryQuoteTest() {
        Rs2_customsetting();
        Test.starttest();
        setupData();
        Test.stoptest();
    }
}