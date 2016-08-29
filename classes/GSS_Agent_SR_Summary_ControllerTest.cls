/*********************************************************************
* Class Name : GSS_Agent_SR_Summary_ControllerTest
* Purpose    : Test Class For  GSS_Agent_SR_Summary_Controller
*              
* Author            Date            Comments        
* Accenture     19-May-2014        GSS Agent Console Project
* ********************************************************************/
@isTest(seealldata=true)

public class  GSS_Agent_SR_Summary_ControllerTest{
 
    public static Case cc;
    public static GSS_Knova__c kn;
    public static GSS_Case_Knova__c kw;
    public static GSS_Bugzilla__c bg;
    public static GSS_Case_BugZilla__c bug;
    public static SR_Comments__c s;
    public static SR_Comments__c s2;
    public static SR_Comments__c s3;
    public static Task tsk;
    public static List <Task> BugtskList = new List <Task>();
    public static EmailMessage emj;
    public static EmailMessage emj2;
    public static EmailMessage emj3;
    public static EmailMessage emj4;
    public static EmailMessage emj5;
    public static EmailMessage emj6;
    public static Attachment attach;
    public static GSS_File_Attachment__c fa;
    public static CaseComment c;
    public static CaseComment c2;
    public static GSS_SAP_History__c sap; 
    //edited on 16th may 2016
    //public static List<GSS_Agent_SR_Summary_Controller> GSSAgentSRSummaryList;
   // public static GSS_Agent_SR_Summary_Controller GSSAgentSRSummaryOBJ;  
 
    public static void preparetestdata()
    {   
        // Test data for case
        cc = new Case();
        cc.RecordTypeId=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);        
        cc.GSS_Support_Level__c = '1';
        cc.GSS_Problem_Category__c = 'OS';
        cc.Priority = '4 - Low';
        cc.Status = 'New';
        cc.Sub_Status__c = 'Unassigned';
        cc.Subject = 'Task Test Subject';
        cc.Description = 'Test  Case Description';
        cc.Technical_Contact_Name__c='Technical Test';                
        insert cc;
        // case update
        cc.Description = 'Test  Case Description updated';
        update cc;
        //Insert Knova Article
        kn = new GSS_Knova__c();
        kn.GSS_Alternate_Case__c = 'Test Case';
        insert kn;
        
        kw = new GSS_Case_Knova__c();
        kw.GSS_Case_Number__c = cc.id;
        kw.GSS_KnovaSFDCID__c = kn.id;
        insert kw;
        
        //Insert PR
        bg = new GSS_Bugzilla__c();
        bg.GSS_Bug_ID__c = 'test bug';
        insert bg;

        bug = new  GSS_Case_BugZilla__c();
        bug.GSS_CaseNumber__c = cc.id;
        bug.GSS_BugSFDCID__c = bg.id;
        insert bug;
        
        //Insert SR comment
        s = new SR_Comments__c();
        s.Technical_Contact_Name__c = 'Test Technical Contact';
        s.Notes_Type__c ='SR Management Internal Notes';
        s.Note_Description__c = 'Test Management Description';
        s.SR_Number__c = cc.id;
        insert s;
        //Insert SR comment 2
        s2 = new SR_Comments__c();
        s2.Technical_Contact_Name__c = 'Test Technical Contact';
        s2.Notes_Type__c ='SR Management Internal Notes';
        s2.Note_Description__c = 'Test Management Description';
        s2.Type_of_SR_Comment__c = 'Log Analysis';
        s2.SR_Number__c = cc.id;
        insert s2; 

        //
        s3= new SR_Comments__c();
        s3.Technical_Contact_Name__c = 'Test Technical Contact';
        s3.Notes_Type__c ='SR Management Internal Notes';
        s3.Type_of_SR_Comment__c = 'Log Analysis';
        s3.SR_Number__c = cc.id;
        insert s3;          
        
        //Insert Call outbound task
        tsk=new Task();       
        tsk.WhatId= cc.Id;        
        tsk.priority='normal';       
        tsk.Status = 'Completed';
        tsk.Type = 'Call Outbound' ;
        tsk.Subject ='Email' ;
        tsk.ActivityDate =  system.today();
        insert tsk;
        
        //Insert Email Message
        emj = new EmailMessage();
        emj.FromName = 'test@email.com';
        emj.ToAddress = 'test@email.com';
        emj.Subject = 'Test';
        emj.TextBody = 'This is a test Email';
        emj.ParentId = cc.Id; 
        insert emj;
        
        emj2 = new EmailMessage();
        emj2.HtmlBody = 'tes data';
        emj2.Incoming = true;
        emj2.FromName = 'test@email.com';
        emj2.ToAddress = 'test@email.com';
        emj2.Subject = 'Test';
        emj2.TextBody = 'This is a test Email';
        emj2.ParentId = cc.Id; 
        insert emj2;
        
        emj3 = new EmailMessage();
        emj3.HtmlBody = 'tes data';
        emj3.Incoming = true;
        emj3.ToAddress = 'test@email.com';
        emj3.Subject = 'Test';
        emj3.TextBody = 'This is a test Email';
        emj3.ParentId = cc.Id; 
        insert emj3;
        
        emj4 = new EmailMessage();
        emj4.HtmlBody = 'tes data';
        emj4.Incoming = true;
        emj4.ToAddress = 'test@email.com';
        emj4.Subject = 'Test';
        emj4.ParentId = cc.Id; 
        insert emj4;
        
        emj5 = new EmailMessage();
        emj5.Incoming = true;
        emj5.ToAddress = 'test@email.com';
        emj5.Subject = 'Test';
        emj5.ParentId = cc.Id;  
        insert emj5;
        
        emj6 = new EmailMessage();
        emj6.Incoming = true;
        emj6.ToAddress = 'test@email.com';
        emj6.Subject = 'Test';
        emj6.TextBody = '';
        emj6.ParentId = cc.Id;  
        insert emj6;
        
        
        //Insert Attachments
        attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cc.id;
        insert attach;
        
        //Insert File Attachment
        fa = new GSS_File_Attachment__c();
        fa.case__c = cc.id;
        insert fa;
        
        //Insert Case comments
        c= new CaseComment();
        c.CommentBody = '[Call Inbound Notes & Webex] Test Comment Description';
        c.IsPublished = true; 
        c.ParentId = cc.id;         
        insert c;
        
        //Insert Case comments
        c2= new CaseComment();
        c2.CommentBody = '[Call Outbound Notes] Test Comment Description';
        c2.IsPublished = true; 
        c2.ParentId = cc.id;         
        insert c2;
        
        //insert SAP
        sap=new GSS_SAP_History__c();
        sap.Symptoms__c='test symptoms';
        sap.Assessment__c='test Assessment';
        sap.Plan__c='test Plan';
        sap.Case__c=cc.id;
        insert sap;        
        
        User Bugger = [SELECT Id FROM User WHERE Name='GSS-Bugzilla Integration User'];
        if(Bugger!=null){
            System.runAs(Bugger){
                Task Bugtsk=new Task();       
                Bugtsk.WhatId= cc.Id;        
                Bugtsk.priority='normal';       
                Bugtsk.Status = 'Completed';
                Bugtsk.Type = 'Other' ;
                Bugtsk.Subject ='Bug 1111111 has been updated' ;
                Bugtsk.ActivityDate =  system.today();
                BugtskList.add(Bugtsk);
                Task Bugtsk1=new Task();       
                Bugtsk1.WhatId= cc.Id;        
                Bugtsk1.priority='normal';       
                Bugtsk1.Status = 'Completed';
                Bugtsk1.Type = 'Other' ;
                Bugtsk1.Subject ='Bug 1111111 associated to Case' ;
                Bugtsk1.ActivityDate =  system.today();
                BugtskList.add(Bugtsk1);
                Task Bugtsk2=new Task();       
                Bugtsk2.WhatId= cc.Id;        
                Bugtsk2.priority='normal';       
                Bugtsk2.Status = 'Completed';
                Bugtsk2.Type = 'Other' ;
                Bugtsk2.Subject ='Bug 1111111 has been unassociated with this case' ;
                Bugtsk2.ActivityDate =  system.today();
                BugtskList.add(Bugtsk2);
                database.insert(BugtskList);
            }
        }
    
    }
   
    public static testMethod void SummaryPageMethod1(){
        
        GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;

        preparetestdata();
        PageReference pageref =Page.GSS_Agent_SR_Management;
        Test.setCurrentPage(pageref);
                    
        pageref.getParameters().put('id',cc.id);
        pageref.getParameters().put('ikbURL',kw.id);
        pageref.getParameters().put('prID',bug.id);
        pageref.getParameters().put('editLink',tsk.id);
        pageref.getParameters().put('replyLink',cc.id);
        pageref.getParameters().put('toAllLink',cc.id);
        pageref.getParameters().put('deleteLink',tsk.id);
        pageref.getParameters().put('viewLink',cc.id);
        pageref.getParameters().put('fetchId2','example');
             
        Test.startTest();      
            
            System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));
            GSS_Agent_SR_Summary_Controller tobj = new  GSS_Agent_SR_Summary_Controller(new ApexPages.standardController(cc));
            GSS_Agent_SR_Summary_Controller.wrapperClass obj=new GSS_Agent_SR_Summary_Controller.wrapperClass();
            pageref.getParameters().put('objType','task');
            pageref.getParameters().put('detailLink',tsk.id);
            tobj.objectType = 'CaseComments';
            tobj.linkRecordId = tsk.id;
            tobj.setplusminus();
            tobj.calcRows('test test \n test test\n test test');
            tobj.getListtypes();            
            tobj.setLinkType();         
            tobj.setCheck();
            tobj.setData();
            tobj.displayList();
            tobj.viewAction();
            tobj.edit();
            tobj.reply();
            tobj.toAll();
            tobj.deleteRecord();
            tobj.view();
            tobj.goNextPage();
            tobj.goPreviousPage();
            

        Test.stopTest();
    }
    
    public static testMethod void SummaryPageMethod2(){
        
        GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;

        preparetestdata();
        c.CommentBody = '[Call Outbound Notes & Webex] Test Comment Description';
        update c;
        PageReference pageref =Page.GSS_Agent_SR_Management;
        Test.setCurrentPage(pageref);
                    
        pageref.getParameters().put('id',cc.id);
        pageref.getParameters().put('ikbURL',kw.id);
        pageref.getParameters().put('prID',bug.id);
        pageref.getParameters().put('editLink',tsk.id);
        pageref.getParameters().put('replyLink',cc.id);
        pageref.getParameters().put('toAllLink',cc.id);
        pageref.getParameters().put('deleteLink',tsk.id);
        pageref.getParameters().put('viewLink',cc.id);
             
        Test.startTest();     
        
            System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));
            GSS_Agent_SR_Summary_Controller tobj = new  GSS_Agent_SR_Summary_Controller(new ApexPages.standardController(cc));
            GSS_Agent_SR_Summary_Controller.wrapperClass obj=new GSS_Agent_SR_Summary_Controller.wrapperClass();
            pageref.getParameters().put('objType','task');
            pageref.getParameters().put('detailLink',tsk.id);
        
            tobj.DisplayAllRecords();
            tobj.RefreshList();
            tobj.emptylisttypes();
        
        Test.stopTest();
    }
    
    public static testMethod void SummaryPageDeleteItems1()
    {
        
        GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;

        preparetestdata();
        c.CommentBody = '[Call Inbound Notes] Test Comment Description';
        update c;
        PageReference pageref =Page.GSS_Agent_SR_Management;
        PageReference pageref1 =Page.GSS_Agent_SR_Management;
        Test.setCurrentPage(pageref);
        Test.setCurrentPage(pageref1);
                    
        pageref.getParameters().put('id',cc.id);
        pageref.getParameters().put('ikbURL',kw.id);
        pageref.getParameters().put('prID',bug.id);
        pageref.getParameters().put('editLink',tsk.id);
        pageref.getParameters().put('replyLink',cc.id);
        pageref.getParameters().put('toAllLink',cc.id);
        pageref.getParameters().put('deleteLink',tsk.id);
        pageref.getParameters().put('viewLink',cc.id);
        
        pageref1.getParameters().put('id',cc.id);
        pageref1.getParameters().put('ikbURL',kw.id);
        pageref1.getParameters().put('prID',bug.id);
        pageref1.getParameters().put('editLink',tsk.id);
        pageref1.getParameters().put('replyLink',cc.id);
        pageref1.getParameters().put('toAllLink',cc.id);
        pageref1.getParameters().put('deleteLink',tsk.id);
        pageref1.getParameters().put('viewLink',cc.id);
        
             
        Test.startTest();     
        
            System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));
            GSS_Agent_SR_Summary_Controller tobj = new  GSS_Agent_SR_Summary_Controller(new ApexPages.standardController(cc));
            GSS_Agent_SR_Summary_Controller.wrapperClass obj=new GSS_Agent_SR_Summary_Controller.wrapperClass();
            pageref.getParameters().put('objType','task');
            pageref.getParameters().put('detailLink',tsk.id);
            
            pageref1.getParameters().put('objType','SR Comments');
            pageref1.getParameters().put('deleteLink',s.id);
        
            pageref.getParameters().put('objType','Attachments');
            pageref.getParameters().put('deleteLink',attach.id);
            
            pageref1.getParameters().put('objType','KBs');
            pageref1.getParameters().put('deleteLink',kw.id);
            
            tobj.deleteRecord();
            pageref.getParameters().put('objType','CaseComments');
            pageref.getParameters().put('deleteLink',c.id);
            
            pageref1.getParameters().put('objType','PRs');
            pageref1.getParameters().put('deleteLink',bug.id);
        //modified on 16th May 2016 
            pageref1.getParameters().put('objType','CaseComments');
            pageref1.getParameters().put('deleteLink',bug.id);
            
            pageref1.getParameters().put('objType','SR Comments');
            pageref1.getParameters().put('deleteLink',tsk.id);
            
            pageref.getParameters().put('objType','Attachments');
            pageref.getParameters().put('deleteLink',tsk.id);
            
            pageref.getParameters().put('objType','Log Analysis');
            pageref.getParameters().put('deleteLink',s.id);
            
            tobj.objectType = 'task';
            tobj.setLinkType();
            tobj.deleteRecord();
            
            String [] str = new String[]{'auditCheck','vceAttCheck','vceNoteCheck','vceTaskCheck'};
            tobj.setListtypes(str);
            tobj.SRCommentsCount = 7;
            tobj.publicCommentsCount = 6;
            tobj.inboundCallCount = 5; 
            tobj.outboundCallCount = 4;
            tobj.inboundEmailCount = 3;
            tobj.outboundEmailCount = 2;
            tobj.displayAll = 'test';
            tobj.fetchId2 = 'test';
            tobj.value = 9;
            tobj.checkType = 'str';
            tobj.checkValue = 'test';
            tobj.ikburl = 'test';
            tobj.prID = 'test';
            tobj.callManualCount = 0;
        
            Test.stopTest();
    }
    public static testMethod void coverRemaining(){
        Case cs = new Case();
        cs.RecordTypeId=Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);        
        cs.GSS_Support_Level__c = '1';
        cs.GSS_Problem_Category__c = 'OS';
        cs.Priority = '4 - Low';
        cs.Status = 'New';
        cs.Sub_Status__c = 'Unassigned';
        cs.Subject = 'Task Test Subject';
        cs.Description = 'Test  Case Description';
        cs.Technical_Contact_Name__c='Technical Test';                
        insert cs;
        PageReference pageref = Page.GSS_Agent_SR_Summary;
        pageref.getParameters().put('id',cs.id);
        Test.setCurrentPage(pageref);
        GSS_Agent_SR_Summary_Controller tobj = new  GSS_Agent_SR_Summary_Controller(new ApexPages.standardController(cs));
        String [] str = new String[]{'auditCheck','vceAttCheck','vceNoteCheck','vceTaskCheck'};
        
        tobj.setListtypes(str);
        tobj.SRCommentsCount = 7;
        tobj.publicCommentsCount = 6;
        tobj.inboundCallCount = 5; 
        tobj.outboundCallCount = 4;
        tobj.inboundEmailCount = 3;
        tobj.outboundEmailCount = 2;
        tobj.displayAll = 'test';
        tobj.fetchId2 = 'test';
        tobj.value = 9;
        tobj.checkType = 'str';
        tobj.checkValue = 'test';
        tobj.ikburl = 'test';
        tobj.prID = 'test';
        tobj.callManualCount = 0;
    }
  /*  public static testMethod void SummaryPageDeleteItems2()
    {
        
        GSS_UtilityClass.isBeforeInsert_Case=true;
        GSS_UtilityClass.isBeforeUpdate_Case=true;
        GSS_UtilityClass.isAfterInsert_Case=true;
        GSS_UtilityClass.isAfterUpdate_Case=true;

        preparetestdata();
        c.CommentBody = '[Call Outbound Notes] Test Comment Description';
        update c;
        PageReference pageref =Page.GSS_Agent_SR_Management;
        Test.setCurrentPage(pageref);
                    
        pageref.getParameters().put('id',cc.id);
        pageref.getParameters().put('ikbURL',kw.id);
        pageref.getParameters().put('prID',bug.id);
        pageref.getParameters().put('editLink',tsk.id);
        pageref.getParameters().put('replyLink',cc.id);
        pageref.getParameters().put('toAllLink',cc.id);
        pageref.getParameters().put('deleteLink',tsk.id);
        pageref.getParameters().put('viewLink',cc.id);
             
        Test.startTest();     
        
            System.debug('######## '+ApexPages.currentPage().getParameters().get('ID')+'^^^^^^^ '+pageref.getParameters().get('ID'));
            GSS_Agent_SR_Summary_Controller tobj = new  GSS_Agent_SR_Summary_Controller(new ApexPages.standardController(cc));
            GSS_Agent_SR_Summary_Controller.wrapperClass obj=new GSS_Agent_SR_Summary_Controller.wrapperClass();
            
            pageref.getParameters().put('objType','SR Comments');
            pageref.getParameters().put('deleteLink',s.id);
            tobj.deleteRecord();
            pageref.getParameters().put('objType','KBs');
            pageref.getParameters().put('deleteLink',kw.id);
            tobj.viewAction();
            tobj.deleteRecord();
            pageref.getParameters().put('objType','PRs');
            pageref.getParameters().put('deleteLink',bug.id);
            tobj.viewAction();
            tobj.deleteRecord();
            
        Test.stopTest();
    } */
    
}