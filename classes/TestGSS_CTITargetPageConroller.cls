/********************************************************** 
* Class Name : TestGSS_CTITargetPageConroller
* Purpose    : Test Class to perform unit test for the controller GSS_CTITargetPageConroller
* JIRA       : PP-18395     
* ******************************************************* 
* Author                    Date         Remarks 
* HCL Technologies-Aditya   21-Oct-10    Created 
* *********************************************************/

@isTest(seeAllData = true)
private class TestGSS_CTITargetPageConroller {
    
    static Case testCase;
    static void setupData(){
    recursive.isAtfuture = true;
        testCase=new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email'
                            ,Priority='1 - Critical', GSS_Problem_Category__c='OS',GSS_Support_Level__c='2'
                            ,Status='New',Subject ='testing',Description='testing');
        insert testCase;
    }
    static testMethod void myUnitTest() {


        setupData();
        Test.startTest();
        
        
        testCase = [select id,caseNumber,Customer_Contact_Phone__c,Origin,GSS_Preferred_Method_of_Contact__c,Priority, GSS_Problem_Category__c,GSS_Support_Level__c
                            ,GSS_Routing_Channel__c,Status,Subject,Description from case where id =:testCase.id];
        PageReference pageRefObj=new PageReference('/apex/GSS_CTITargetPage');
        Test.setCurrentPage(pageRefObj);
        ApexPages.currentPage().getParameters().put('CN',testCase.Customer_Contact_Phone__c);
        ApexPages.currentPage().getParameters().put('PreferredMOC',testCase.GSS_Preferred_Method_of_Contact__c);
        ApexPages.currentPage().getParameters().put('ProblemCategory',testCase.GSS_Problem_Category__c);
        ApexPages.currentPage().getParameters().put('CallBackPhone',testCase.Origin);
        ApexPages.currentPage().getParameters().put('SRStatus',testCase.Status);
        ApexPages.currentPage().getParameters().put('RoutingChannel',testCase.GSS_Routing_Channel__c);
        ApexPages.currentPage().getParameters().put('AgentType','tse');
        ApexPages.currentPage().getParameters().put('id',testCase.Id);
        ApexPages.currentPage().getParameters().put('caseNumber',testCase.caseNumber);
        ApexPages.currentPage().getParameters().put('allowNavigate','1');
        ApexPages.currentPage().getParameters().put('SRNumber',testCase.CaseNumber);
        
        GSS_CTITargetPageController controllerInstance=new GSS_CTITargetPageController();
        controllerInstance.cId = testCase.Id;
        controllerInstance.caseNumber = testCase.caseNumber;
        controllerInstance.agentType = 'tse';
        controllerInstance.CTITargetPageRedirect();
        controllerInstance.getShowCSRDashBoard();
        
        String strCSRParams=controllerInstance.getCSRparamas();
        String strURL=controllerInstance.getURL();
        //system.debug('---strCSRParams----'+strCSRParams);
        //system.debug('---strURL----'+strURL);
        //GSS_CTITargetPageController controllerInstance2=new GSS_CTITargetPageController();
        test.stoptest();
        }
        
        static testMethod void myUnitTest2() {
        

        setupData();
        Test.startTest();
        
        
        
        GSS_CTITargetPageController controllerInstance2=new GSS_CTITargetPageController();
        controllerInstance2.CTITargetPageRedirect();
        controllerInstance2.getShowCSRDashBoard();
 
        GSS_CTITargetPageController controllerInstance3=new GSS_CTITargetPageController();
        controllerInstance3.noCase=true;
        controllerInstance3.CTITargetPageRedirect();
        controllerInstance3.getShowCSRDashBoard();
        
        Test.stopTest();
    }
}