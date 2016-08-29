/****************************************************************
/**Class Name: GSS_RequestHistoryControllerTest 
/** Created By:<Accenture>
/** Created Date:12-Aug-2016
/** Purpose: Test Class For GSS_RequestHistoryController
/*************************************************************/
@isTest(SeeAllData=true)
public class GSS_RequestHistoryControllerTest{
    public static GSS_Request__c Req;
    public static List<GSS_Request__c> ReqList;
    public static void setupData(){
        if(GSS_FieldHistoryTrack__c.getInstance()==null){
            List<GSS_FieldHistoryTrack__c> fieldList = new List<GSS_FieldHistoryTrack__c>();
            fieldList.add(new GSS_FieldHistoryTrack__c(Name='Request-Current Status', FieldApi__c='Current_Status__c', DataType__c='Long Text Area',FieldLabel__c='Current Status',Object__c='GSS_Request__c'));
            Database.insert(fieldList);
        }
        List<case> caseList = new List<Case>();
        ReqList = new List<GSS_Request__c>();
        Record_Type_Settings__c oRTSReqER = Record_Type_Settings__c.getInstance('GSS_REQ_ER');
        caseList.add(new Case(Priority = 'Medium'));
        insert caseList;
        Req = new GSS_Request__c();
        Req.GSS_Case_Number__c = caseList[0].id;
        Req.GSS_Status__c = 'New' ;
        Req.GSS_Requesting_To_Group__c = 'Desktop' ;
        Req.GSS_Level__c = 'Level 2' ;
        Req.GSS_Description__c = 'test';
        Req.GSS_Action_Required__c = 'Knowledge Gap Area';
        Req.GSS_Knowledge_Gap_Area__c = 'Documentation';
        Req.Current_Status__c = 'test';
        Req.RecordTypeId = oRTSReqER.Record_Type_ID__c ;
        Req.GSS_Escalation_Reason__c = 'test';
        
        ReqList.add(Req);
        insert ReqList;
        Req.Current_Status__c = 'test1';
        update ReqList[0]; 

    }
    static testMethod void GSSTests(){
        
        setupData();
        PageReference pageRef = Page.GSS_RequestHistoryPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().Put('Id',ReqList[0].id);
        GSS_RequestHistoryController ReqHisCon = new GSS_RequestHistoryController();
        Test.StartTest();
        
        ReqHisCon.previous();
        ReqHisCon.next();
        ReqHisCon.getDisablePrevious();
        ReqHisCon.getDisableNext();
        ReqHisCon.getpageNumber();
        ReqHisCon.getrequestHistList(Req.id);
        ReqHisCon.gettotalPages();
        Test.StopTest();
    }
}