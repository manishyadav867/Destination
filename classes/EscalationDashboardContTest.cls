@isTest(seeAllData=true)
class EscalationDashboardContTest{
    public static testMethod void testMyclass1(){
        EscalationDashboardCont.getAllEscalationsCount('PName','EName','CName','AName',true,true,true,true);
        EscalationDashboardCont.getAllEscalations( 1 ,'PName','EName','CName', 'AName',true,true,true,true);
    }
    public static testMethod void testMyclass2(){
        case cse = new case(GSS_Problem_Category__c='Storage',Sub_Status__c='Unassigned',subject='test',Description='test');
        insert cse;
        GSS_Request__c reqobj = new GSS_Request__c(GSS_Case_Number__c=cse.id,GSS_Description__c='TestDescription');
        insert reqobj;
        Request_Contact__c reqConOb = new Request_Contact__c(Request__c=reqobj.id,user__c=UserInfo.getUserId());
        insert reqConOb;
        EscalationDashboardCont.subscribeRequest(reqConOb.Request__c);
    }
}