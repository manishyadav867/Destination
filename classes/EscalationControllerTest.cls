/*
 * Name : EscalationControllerTest
 * Description : Test Class for EscalationController
 * Author : Sneha Rathi, Accenture
 * Created Date : 30/9/2015
 * */
@isTest(seeAllData=true)
private class EscalationControllerTest 
{
    private static  Map<Id, GSS_Request__c>gssrMap ;
    private static  Map<Id, Case> caseMap;
    private static GSS_Request__c gssr;
    private static Case caseOb;
    private static GSS_Case_BugZilla__c pr1;
    private static Request_Contact__c reqContct;
    private static void setupData(){
    String escalationRecordTypeName = 'Escalation Request';
    GSS_Request__c  gssRequest = new GSS_Request__c();
    List<Account> listAccount = new List<Account>();
     
    List<PLMStatic__c> plmList = new List<PLMStatic__c>();
    PLMStatic__c plms1 = new PLMStatic__c();
    plms1.Name = 'MasterAccountLayoutRecType';
    plmList.add(plms1);
 
    PLMStatic__c plms2 = new PLMStatic__c();
    plms2.Name = 'PartnerLocationRecType';
    plmList.add(plms2);
    
    PLMStatic__c plms3 = new PLMStatic__c();
    plms3.Name = 'VirtualPartnerAccountRecType';
    plmList.add(plms3);
    database.insert(plmList, false);
    
    List<DNBI_Properties__c> dnbipList = new List<DNBI_Properties__c>();
    
    DNBI_Properties__c  dnbip = new DNBI_Properties__c();
    dnbip.Name = 'Integration_Batch_Size';
    dnbip.DNB_Value__c= '50';
    dnbipList.add(dnbip);
    
 
    DNBI_Properties__c  dnbip1 = new DNBI_Properties__c();
    dnbip1.Name = 'OutputRecordCountDNBIMaxQuantity';
    dnbip1.DNB_Value__c= '50';
    dnbipList.add(dnbip1);
 
    DNBI_Properties__c  dnbip2 = new DNBI_Properties__c();
    dnbip2.Name = 'OutputRecordCountDNBIMaxQuantityForCMP';
    dnbip2.DNB_Value__c= '50';
    dnbipList.add(dnbip2);
 
    DNBI_Properties__c  dnbip3 = new DNBI_Properties__c();
    dnbip3.Name = 'ConfidenceCode';
    dnbip3.DNB_Value__c= '50';
    dnbipList.add(dnbip3);
 
    DNBI_Properties__c  dnbip4 = new DNBI_Properties__c();
    dnbip4.Name = 'ConfidenceCode_AccountSearch';
    dnbip4.DNB_Value__c= '50';
    dnbipList.add(dnbip4);
 
    DNBI_Properties__c  dnbip5 = new DNBI_Properties__c();
    dnbip5.Name = 'Dummy_DNBCall_Id';
    dnbip5.DNB_Value__c= '50';
    dnbipList.add(dnbip5);
 
    DNBI_Properties__c  dnbip6 = new DNBI_Properties__c();
    dnbip6.Name = 'TrilliumMatchingScore';
    dnbip6.DNB_Value__c= '50';
    dnbipList.add(dnbip6);
 
    DNBI_Properties__c  dnbip7 = new DNBI_Properties__c();
    dnbip7.Name = 'SearchPriority';
    dnbip7.DNB_Value__c= '50';
    dnbipList.add(dnbip7);
 
    DNBI_Properties__c  dnbip8 = new DNBI_Properties__c();
    dnbip8.Name = 'QueryBatchSize';
    dnbip8.DNB_Value__c= '50';
    dnbipList.add(dnbip8);
 
    DNBI_Properties__c  dnbip9 = new DNBI_Properties__c();
    dnbip9.Name = 'EndPointURL';
    dnbip9.DNB_Value__c= '50';
    dnbipList.add(dnbip9);
 
    database.insert(dnbipList, false);
    
    List<ETM_Constants__c> etmList = new List<ETM_Constants__c>();
    ETM_Constants__c etm = new ETM_Constants__c();
    etm.name = 'xys';
    etm.Field_Name__c= 'xyz__c';
    etmList.add(etm);
    database.insert(etmList, false);
 
    List<TA_Properties__c> tapList = new List<TA_Properties__c>();
    TA_Properties__c tap = new TA_Properties__c();
    tap.name = 'TA_Processing_Rules';
    tap.Run_New_TA_Engine__c = true;
    tapList.add(tap);
    database.insert(tapList, false);
 
    List<Record_Type_Settings__c > rtsList = new List<Record_Type_Settings__c >();
    
 
    Record_Type_Settings__c rtss1 = new Record_Type_Settings__c();
    rtss1.name = 'ITAppsSupport';
    rtss1.Record_Type_ID__c = '012800000003inmAAA';
    rtsList.add(rtss1);
 
    Record_Type_Settings__c rtss2 = new Record_Type_Settings__c();
    rtss2.name = 'GSS_MyVmwareCommonCase';
    rtss2.Record_Type_ID__c = '012800000003inr';
    rtsList.add(rtss2);
 
    Record_Type_Settings__c rtss3 = new Record_Type_Settings__c();
    rtss3.name = 'GSS_CASE_TS';
    rtss3.Record_Type_ID__c = '01280000000cYyhAAE';
    rtsList.add(rtss3);
 
    Record_Type_Settings__c rtss4 = new Record_Type_Settings__c();
    rtss4.name = 'GSS_CASE_LIC';
    rtss4.Record_Type_ID__c = '01280000000cYyXAAU';
    rtsList.add(rtss4);
    
    Record_Type_Settings__c rtss5 = new Record_Type_Settings__c();
    rtss5.name = 'PRM_Acc_PL';
    rtsList.add(rtss5);
 
    Record_Type_Settings__c rtss6 = new Record_Type_Settings__c();
    rtss6.name = 'PRM_Acc_MAL';
    rtsList.add(rtss6);
    
    Record_Type_Settings__c rtss7 = new Record_Type_Settings__c();
    rtss7.name = 'caseTest';
    rtss7.App_Type__c = 'sales';
    rtss7.Object_Type__c = 'standerd';
    rtss7.Record_Type_ID__c = 'xyz';
    rtss7.Record_Type_Name__c = 'x';
    rtsList.add(rtss7);
    
    Record_Type_Settings__c rtss8 = new Record_Type_Settings__c();
    rtss8.name = 'RCM_Case_Renewal_Operations';
    rtss8.Record_Type_ID__c = '0128000000044mW';
    rtsList.add(rtss8);
 
    Record_Type_Settings__c rtss9 = new Record_Type_Settings__c();
    rtss9.name = 'SubscriptionServices';
    rtss9.Record_Type_ID__c = '012800000003wadAAA';
    rtsList.add(rtss9);
 
    Record_Type_Settings__c rtss10 = new Record_Type_Settings__c();
    rtss10.name = 'GSS_CASE_SDP_FED';
    rtss10.Record_Type_ID__c = '0128000000044a0AAA';
    rtsList.add(rtss10);
    
     Record_Type_Settings__c rtss11 = new Record_Type_Settings__c();
     rtss11.name = 'GSS_CASE_CS';
     rtss11.Record_Type_ID__c = '01280000000cYySAAU';
     rtsList.add(rtss11);
     
     Record_Type_Settings__c rtss12 = new Record_Type_Settings__c();
     rtss12.name = 'CaseRenewalOperations';
     rtss12.Record_Type_ID__c = '0128000000044mW';
     rtsList.add(rtss12);
     
     Record_Type_Settings__c rtss13 = new Record_Type_Settings__c();
     rtss13.name = 'SFA_Case_PN';
     rtss13.Record_Type_ID__c = '01280000000BWUuAAO';
     rtsList.add(rtss13);
 
     Record_Type_Settings__c rtss14 = new Record_Type_Settings__c();
     rtss14.name = 'SFA_Task_SendAlert';
     rtss14.Record_Type_ID__c = '012n00000008XyA';
     rtsList.add(rtss14);
     
     Record_Type_Settings__c rtss15 = new Record_Type_Settings__c();
     rtss15.name = 'SFA_Case_BI';
     rtss15.Record_Type_ID__c = '01280000000BWUsAAO';
     rtsList.add(rtss15);
 
     Record_Type_Settings__c rtss16 = new Record_Type_Settings__c();
     rtss16.name = 'SFA_Case_HSZ';
     rtss16.Record_Type_ID__c = '01280000000cYy3AAE';
     rtsList.add(rtss16);
     
     Record_Type_Settings__c rtss17 = new Record_Type_Settings__c();
     rtss17.name = 'SFA_Case_QnC';
     rtss17.Record_Type_ID__c = '012800000003qL4AAI';
     rtsList.add(rtss17);
     
     Record_Type_Settings__c rtss18 = new Record_Type_Settings__c();
     rtss18.name = 'SFA_Acc_EC';
     rtss18.Record_Type_ID__c = '012800000003inr';
     rtsList.add(rtss18);
     
     Record_Type_Settings__c rtss19 = new Record_Type_Settings__c();
     rtss19.name = 'SFA_Acc_NAR';
     rtss19.Record_Type_ID__c = '012800000003inr';
     rtsList.add(rtss19);
     
     Record_Type_Settings__c rtss = new Record_Type_Settings__c();
     rtss.name = 'GSS_ACC_EC';
     rtsList.add(rtss);
     
     Record_Type_Settings__c rtss20 = new Record_Type_Settings__c();
     rtss20.name = 'GSS_TASK_GT';
     rtss20.Record_Type_ID__c = '01280000000cYz1AAE';
     rtsList.add(rtss20);
        
     database.insert(rtsList, false);

    ETM_Do_Not_Delete_Territory_Values__c etmdndtv = new ETM_Do_Not_Delete_Territory_Values__c();
    etmdndtv.name = 'Target Objects';
    etmdndtv.Target_Objects__c = 'Account';
    insert etmdndtv ;
 
    LeadManagerPublicGroup__c lmpg = new LeadManagerPublicGroup__c();
    lmpg.name = 'Lead Manager Public Group ID';
    insert lmpg;
 
    SFA_Send_Alert_Task_Properties__c sfa = new SFA_Send_Alert_Task_Properties__c();
    sfa.name = 'checkFlag';
    sfa.Value__c = 'true';
    insert sfa;
 
    MDF_Integration_System__c mdfis = new MDF_Integration_System__c();
    mdfis.name = 'cci';
    insert mdfis;
 
    bChannels__c bc = new bChannels__c();
    bc.name = 'testMe';
    bc.isactive__c = true;
    insert bc;
 
    
        Account acc = new Account( Name = 'Test Account', Address_1_del__c = 'Test Address', City__c = 'Test City', country__c = 'United States',
        Zip_Postal_Code__c = '1111111',Website ='www.test.com',RecordTypeId= recursive.CustomerAccountRecType, GEO__c='AMER' );
        system.debug('account...................'+acc);
        insert acc; 
 
        List<GSS_Configuration_Properties_list__c> gsscpList = new List<GSS_Configuration_Properties_list__c>();
        
        GSS_Configuration_Properties_list__c gssc = new GSS_Configuration_Properties_list__c();
        gssc.name = 'IVR_ADMIN';
        gssc.Setting_value__c = '00580000003lPxuAAE';
        gsscpList.add(gssc);
         
        GSS_Configuration_Properties_list__c gssc1 = new GSS_Configuration_Properties_list__c();
        gssc1.name = 'CaseAdmin';
        gssc1.Setting_value__c ='00580000003bv8T';
        gsscpList.add(gssc1);
         
        GSS_Configuration_Properties_list__c gssc2 = new GSS_Configuration_Properties_list__c();
        gssc2.name = 'SiteUser';
        gssc2.Setting_value__c ='005800000036VAh';
        gsscpList.add(gssc2);
        
        GSS_Configuration_Properties_list__c gssc3 = new GSS_Configuration_Properties_list__c();
        gssc3.name = 'CarpathiaEmail';
        gssc3.Setting_value__c ='test@test.com';
        gsscpList.add(gssc3);
        
        database.insert(gsscpList, false);
        
        List<Profile_Name_Mapping__c> profMapList = new List<Profile_Name_Mapping__c>();
        
        Profile_Name_Mapping__c prof1 = new Profile_Name_Mapping__c();
        prof1.name='Profile - 210 - Carpathia';
        prof1.Profile_Id__c='00e800000015PqE';
        profMapList.add(prof1);
        
        insert profMapList;
        
         List<VCEStatic__c> vcesList = new List<VCEStatic__c>();
      
         VCEStatic__c vce = new VCEStatic__c();
         vce.name = 'DefaultEnt';
         vce.Value__c = '55080000000gsyO';
         vcesList.add(vce);
         
         VCEStatic__c vce1 = new VCEStatic__c();
         vce1.name = 'VCECaseRecordType';
         vce1.Value__c = '55080000000gsyO';
         vcesList.add(vce1);
         
         VCEStatic__c vce2 = new VCEStatic__c();
         vce2.name = 'VCECaseOutboundRecType';
         vce2.Value__c = '55080000000gsyO';
         vcesList.add(vce2);
         
         VCEStatic__c vce3 = new VCEStatic__c();
         vce3.name = 'ConnectionId';
         vce3.Value__c = '55080000000gsyO';
         vcesList.add(vce3);
         
         VCEStatic__c vce4 = new VCEStatic__c();
         vce4.name = 'GSS Premier Services';
         vce4.Value__c = '55080000000gsyO';
         vcesList.add(vce4);
         
         VCEStatic__c vce5 = new VCEStatic__c();
         vce5.name = 'Vmware';
         vce5.Value__c = '55080000000gsyO';
         vcesList.add(vce5);
         
         
         VCEStatic__c vce6 = new VCEStatic__c();
         vce6.name = 'TaskRecType';
         vce6.Value__c = '01280000000cYz6';
         vcesList.add(vce6);
         
         VCEStatic__c vce7 = new VCEStatic__c();
         vce7.name = 'VCETaskRecordType';
         vce7.Value__c = '01280000000cYz6AAE';
         vcesList.add(vce7);

         
         database.insert(vcesList, false);
         
         EmailThreshold__c eth = new EmailThreshold__c();
         eth.name = 'Duration';
         eth.DurationInSec__c = 30;
         insert eth;
         
         EmailAlias__c ea = new EmailAlias__c();
         ea.name = 'EmailAdd1';
         ea.Values__c = 'gsdevstratus@vmware.com';
         insert ea;
 
         List<GSS_Configuration_Properties_list__c> gsscpLists = new List<GSS_Configuration_Properties_list__c>();
         
         GSS_Configuration_Properties_list__c gsscpl = new GSS_Configuration_Properties_list__c();
         gsscpl.name = 'GSS API User Profile';
         gsscpl.Setting_value__c = '00e80000001Wej1AAC';
         gsscpLists.add(gsscpl);
         
         GSS_Configuration_Properties_list__c gsscp2 = new GSS_Configuration_Properties_list__c();
         gsscp2.name = 'GSS IVR API Profile';
         gsscp2.Setting_value__c = '00e80000001WejGAAS';
         gsscpLists.add(gsscp2);
         
         GSS_Configuration_Properties_list__c gsscp3 = new GSS_Configuration_Properties_list__c();
         gsscp3.name = 'ConnectionUser';
         gsscp3.Setting_value__c = '00580000004OHZJ';
         gsscpLists.add(gsscp3);
         
         database.insert(gsscpLists, false);
         
         WorkflowObjectCs__c wfo = new WorkflowObjectCs__c();
         wfo.name = 'A-IsWorkflowActive';
         insert wfo;
         
         SFA_Send_Alert_Task_Properties__c sfasatp = new SFA_Send_Alert_Task_Properties__c();
         sfasatp.name = 'UserName';
         sfasatp.Value__c = 'Vmware Partner Network1';
         insert sfasatp;
 
         CaseManager__c cm = new CaseManager__c();
         cm.name = 'dont test me';
         insert cm;
         
         List<RS2_Quoting__c> rs2qList = new List<RS2_Quoting__c>();
         RS2_Quoting__c rsq = new RS2_Quoting__c();
         rsq.name = 'SharingRecordTypeIds';
         rsq.Value__c = '0128000000044mg';
         rs2qList.add(rsq);
         
         RS2_Quoting__c rsq1 = new RS2_Quoting__c();
         rsq1.name = 'quotingintegrationuser';
         rsq1.Value__c = '005n0000000u1A5AAI';
         rs2qList.add(rsq1);
         
         RS2_Quoting__c rsq2 = new RS2_Quoting__c();
         rsq2.name = 'RS2_Case_Record_Type';
         rsq2.Value__c = '0128000000044mRAAQ';
         rs2qList.add(rsq2);
         
         RS2_Quoting__c rsq3 = new RS2_Quoting__c();
         rsq3.name = 'TemplateSubStatusValues';
         rsq3.Value__c = 'Partner/End User';
         rs2qList.add(rsq3);
         
         RS2_Quoting__c rsq4 = new RS2_Quoting__c();
         rsq4.name = 'TemplateRequestTypeValues';
         rsq4.Value__c = 'IB Request';
         rs2qList.add(rsq4);
         
         RS2_Quoting__c rsq5 = new RS2_Quoting__c();
         rsq5.name = 'TemplateRequestSubTypeValues';
         rsq5.Value__c = 'Revision';
         rs2qList.add(rsq5);
         database.insert(rs2qList, false);
    
        Id RecTypeId = Schema.SObjectType.GSS_Request__c.getRecordTypeInfosByName().get('Escalation Request').getRecordTypeId();
        
        List<Case> lstCase = new List<Case>();
        
        Case caseobj = new Case(Sub_Status__c = 'Working', GSS_Support_Customer_Region__c='APJ',GSS_Resolution_Code__c = 'Other Reason',Case_Resolution__c = 'abcde',GSS_Available_24_7__c = 'Yes',GSS_Severity__c = '2 - High',Description = 'xyz',GSS_Support_Level__c = '1',GSS_Problem_Category__c = 'Licensing',Status = 'Open',Subject = 'abc', AccountId = acc.id);
        Case caseobj1 = new Case( Sub_Status__c = 'Working',GSS_Support_Customer_Region__c='ANZ',GSS_Resolution_Code__c = 'Other Reason',Case_Resolution__c = 'abcde',GSS_Available_24_7__c = 'Yes',GSS_Severity__c = '2 - High',Description = 'xyz',GSS_Support_Level__c = '1',GSS_Problem_Category__c = 'Licensing',Status = 'Open',Subject = 'abc',AccountId = acc.id);
        caseOb = caseobj;
        lstCase.add(caseobj);
        lstCase.add(caseobj1);
        
        database.insert(lstCase, false);
        
   
        List<GSS_Request__c> lstGSSReq = new List<GSS_Request__c>();
   
        gssr = new GSS_Request__c();
        gssr.GSS_Case_Number__c = lstCase[0].id;
        gssr.RecordTypeId = RecTypeId;
        gssr.GSS_Alert_Level__c = '1.1 Purple';
        lstGSSReq.add(gssr);
        
        GSS_Request__c gssr1 = new GSS_Request__c();
        gssr1.GSS_Case_Number__c = lstCase[1].id;
        gssr1.RecordTypeId = RecTypeId;
        gssr1.GSS_Alert_Level__c = '1.1 Purple';
        lstGSSReq.add(gssr1);
        
        database.insert(lstGSSReq, false);
        
        reqContct = new Request_Contact__c();
        reqContct.User__c = UserInfo.getUserId();
        reqContct.Contact_Type__c = 'Internal VMW';
        reqContct.Request__c = gssr.id;
        reqContct.Subscribed__c = false;
        insert reqContct;
     
     
        GSS_Bugzilla__c gssb = new GSS_Bugzilla__c();
        gssb.GSS_Bug_ID__c = caseobj1.id;
        insert gssb;
      
        GSS_Case_BugZilla__c pr =new GSS_Case_BugZilla__c();
        pr.GSS_CaseNumber__c = caseobj1.id;
        pr.GSS_BugSFDCID__c = gssb.id;
        pr.GSS_Primary_Bug__c = true;
        insert pr;
   }
    
   private static testmethod void testFollowing(){
      //setupData();
        
        Id RecTypeId = Schema.SObjectType.GSS_Request__c.getRecordTypeInfosByName().get('Escalation Request').getRecordTypeId();
        
        List<Case> lstCase = new List<Case>();
        
        Case caseobj = new Case(Sub_Status__c = 'Working', GSS_Support_Customer_Region__c='APJ',GSS_Resolution_Code__c = 'Other Reason',Case_Resolution__c = 'abcde',GSS_Available_24_7__c = 'Yes',GSS_Severity__c = '2 - High',Description = 'xyz',GSS_Support_Level__c = '1',GSS_Problem_Category__c = 'Licensing',Status = 'Open',Subject = 'abc');
        Case caseobj1 = new Case( Sub_Status__c = 'Working',GSS_Support_Customer_Region__c='ANZ',GSS_Resolution_Code__c = 'Other Reason',Case_Resolution__c = 'abcde',GSS_Available_24_7__c = 'Yes',GSS_Severity__c = '2 - High',Description = 'xyz',GSS_Support_Level__c = '1',GSS_Problem_Category__c = 'Licensing',Status = 'Open',Subject = 'abc');
        caseOb = caseobj;
        lstCase.add(caseobj);
        lstCase.add(caseobj1);
        
        insert lstCase;
          
        List<GSS_Request__c> lstGSSReq = new List<GSS_Request__c>();
   
        gssr = new GSS_Request__c();
        gssr.GSS_Case_Number__c = lstCase[0].id;
        gssr.RecordTypeId = RecTypeId;
        gssr.GSS_Alert_Level__c = '1.1 Purple';
        gssr.GSS_Status__c = 'Approved';
        gssr.GSS_Escalation_Reason__c = 'Request for an update';
        lstGSSReq.add(gssr);
        
        GSS_Request__c gssr1 = new GSS_Request__c();
        gssr1.GSS_Case_Number__c = lstCase[1].id;
        gssr1.RecordTypeId = RecTypeId;
        gssr1.GSS_Alert_Level__c = '1.1 Purple';
        gssr1.GSS_Status__c = 'Approved';
        gssr1.GSS_Escalation_Reason__c = 'Request for an update';
        
        lstGSSReq.add(gssr1);
        
        insert lstGSSReq;
        
        List<Request_Contact__c> reqContctList = new List<Request_Contact__c>();
        
        reqContctList.add(new Request_Contact__c(User__c = UserInfo.getUserId(),Contact_Type__c = 'Internal VMW', Request__c = lstGSSReq[0].id, Subscribed__c = false));
        
        reqContctList.add(new Request_Contact__c(User__c = UserInfo.getUserId(),Contact_Type__c = 'Internal VMW', Request__c = lstGSSReq[1].id, Subscribed__c = true));
        
        insert reqContctList;
        
      EscalationController.getFollowing('APJ');
      EscalationController.getRecommended('ANZ');
      EscalationController.getAllActive('APJ');
      EscalationController.getAllClosed('ANZ');
      EscalationController.getAllEscalations('APJ');
      EscalationController.subscribeRequest(reqContctList[0].id);
      EscalationController.subscribeRequest(reqContctList[1].id);
      EscalationController.prepareRequestList(lstGSSReq);
      //EscalationController.UnsubscribeRequest(gssr.id);
       
   }  
}