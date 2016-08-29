@isTest(SeeAllData=true)

public class  GSS_EscalationHistoryControllerTest{
    public static list<GSS_Request__c> ReqList = new list<GSS_Request__c>();
    public static GSS_Request__c Req;
    public static List<case> caseList = new List<Case>();
    public static User cowner,cowner1;
    public static Record_Type_Settings__c oRTSReqER = Record_Type_Settings__c.getInstance('GSS_REQ_ER');
    
    public static void setupData(){
        
        List<USer> userList = new List<USer>();
        Profile p = [select id from profile where name='System Administrator' LIMIT 1];          
        cowner   = new User(alias = 'GSS223', email='user1@testorg.com',languagelocalekey='en_US', 
            emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', 
            profileid =Id.valueOf(p.id),
            timezonesidkey='America/Los_Angeles', username='gssutiluser1@testorg2.com',isActive =true,division = 'AMER');
        cowner1  = new User(alias = 'GSS2231', email='user2@testorg.com',languagelocalekey='en_US', 
            emailencodingkey='UTF-8', lastname='Testing1',localesidkey='en_US', 
            profileid =Id.valueOf(p.id),
            timezonesidkey='America/Los_Angeles', username='gssutiluser2@testorg2.com',isActive =true,division = 'AMER');
            userList.add(cowner);
            userList.add(cowner1);
        insert userList;
        system.runAs(cowner){
        }
        if(HistoryTrackingSetting__c.getInstance('Request-Alert Level') == null){
            List<HistoryTrackingSetting__c> histTrackList = new List<HistoryTrackingSetting__c>();
            histTrackList.add(new HistoryTrackingSetting__c(Name='Request-Alert Level', ApiFieldName__c='GSS_Alert_Level__c', DataType__c='Picklist',FieldLabel__c='Alert Level',Object__c='GSS_Request__c'));
            histTrackList.add(new HistoryTrackingSetting__c(Name='Request-Current Status', ApiFieldName__c='Current_Status__c', DataType__c='Long Text Area',FieldLabel__c='Current Status',Object__c='GSS_Request__c'));
            histTrackList.add(new HistoryTrackingSetting__c(Name='Request-Description', ApiFieldName__c='GSS_Description__c', DataType__c='Long Text Area',FieldLabel__c='Description',Object__c='GSS_Request__c'));
            histTrackList.add(new HistoryTrackingSetting__c(Name='Request-Escalation Summary', ApiFieldName__c='Executive_Summary__c', DataType__c='Long Text Area',FieldLabel__c='Escalation Summary',Object__c='GSS_Request__c'));
            histTrackList.add(new HistoryTrackingSetting__c(Name='Request-Owner', ApiFieldName__c='Owner', DataType__c='Lookup',FieldLabel__c='Owner',Object__c='GSS_Request__c'));
            histTrackList.add(new HistoryTrackingSetting__c(Name='Request-Status', ApiFieldName__c='GSS_Status__c', DataType__c='Picklist',FieldLabel__c='Status',Object__c='GSS_Request__c'));
            Database.insert(histTrackList);
        }
        
        caseList.add(new Case(Priority = 'Medium',ownerId = cowner.id));
        insert caseList;
        
        Req = new GSS_Request__c();
        Req.GSS_Case_Number__c = caseList[0].id;
        Req.GSS_Status__c = 'New' ;
        Req.GSS_Requesting_To_Group__c = 'Desktop' ;
        Req.GSS_Level__c = 'Level 2' ;
        Req.GSS_Description__c = 'test';
        Req.GSS_Action_Required__c = 'Knowledge Gap Area';
        Req.GSS_Knowledge_Gap_Area__c = 'Documentation';
        Req.ownerId = cowner1.id;
        Req.Current_Status__c = 'test';
        Req.RecordTypeId = oRTSReqER.Record_Type_ID__c ;
        Req.GSS_Escalation_Reason__c = 'test';
        
        ReqList.add(Req);
        insert ReqList;
        ReqList[0].GSS_Status__c='Approved';
        ReqList[0].ownerId = cowner.id;
        Req.GSS_Description__c = 'test1';
        update ReqList[0];
        
        List<Action_History__c> lstCommHistory = new List<Action_History__c>();
        Action_History__c actnhist = new Action_History__c();
        actnhist.Action__c = 'Pending' ;
        actnhist.BCC_Address__c = 'test';
        actnhist.CC_Address__c = 'test';
        actnhist.Details_Subset__c = 'test';
        actnhist.From_Address__c ='test';
        actnhist.Details__c = 'test';
        actnhist.Subject__c = 'test';
        actnhist.To_Address__c = 'test';
        actnhist.Request__c = ReqList[0].id;
        actnhist.Visible_to_Customer__c = True;
        lstCommHistory.add(actnhist);
        insert lstCommHistory;
        
        
        
        
        }
         public static testmethod  void method1(){
        setupData();
        test.starttest();
        PageReference pageRef = Page.GSS_RequestHistoryPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().Put('Id',ReqList[0].id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ReqList[0]);
        GSS_EscalationHistoryController gss = new GSS_EscalationHistoryController(sc);
        //gss.buildPagination();
        gss.doChangePageSize();
        gss.doNext();
        gss.Previous();
        gss.getDisablePrevious();
        gss.getDisableNext();
        gss.gettotalPages();
       
        test.stoptest();
        
        }
        }