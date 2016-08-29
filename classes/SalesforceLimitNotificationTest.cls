@isTest
public class SalesforceLimitNotificationTest
{
public static testmethod void mymethod()
{
SFConnectedappinfo__c sc=new SFConnectedappinfo__c();
sc.Name='Notify';
sc.Consumer_Key__c='3MVG9Nc1qcZ7BbZ3HrMpdLwZA3X0Z.WqXgeP3JW92WmCRavajJM3M.Pjfi.DZl2tXynAazfeRGV1fYV4ufuqE';
sc.Consumer_Secret__c='2911886552206626063';
sc.password__c='fdgh';
sc.username__c='kk@vmware.com';
insert sc;

List<SFLimitNotification__c> slist=new List<SFLimitNotification__c>();

SFLimitNotification__c s=new SFLimitNotification__c();
s.Name='HighUsagePercent';
s.Value__c='80';
slist.add(s);

SFLimitNotification__c s1=new SFLimitNotification__c();
s1.Name='LowUsagePercent';
s1.Value__c='50';
slist.add(s1);

SFLimitNotification__c s2=new SFLimitNotification__c();
s2.Name='MediumUsagePercent';
s2.Value__c='60';
slist.add(s2);

SFLimitNotification__c s3=new SFLimitNotification__c();
s3.Name='Status';
s3.Value__c='On';
slist.add(s3);

SFLimitNotification__c s4=new SFLimitNotification__c();
s4.Name='UserList';
s4.Value__c='005340000082kuH';
slist.add(s4);

SFLimitNotification__c s5=new SFLimitNotification__c();
s5.Name='DONT REPLY';
s5.Value__c='dontreply@vmware.com';
slist.add(s5);

insert slist;
Test.StartTest();
PageReference pageRef = Page.SalesforceLimitPage;
Test.setCurrentPageReference(pageRef);
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerate());

SalesforceLimitNotification.deserializeResponse d=new SalesforceLimitNotification.deserializeResponse(); 
SalesforceLimitNotification.ReturnAccessToken();

List<SalesforceLimitNotification.DailyApiLimit> res= new List<SalesforceLimitNotification.DailyApiLimit>();
res=SalesforceLimitNotification.getCallLimitRestAPI();
SalesforceLimitNotification.UsageCalc();
SalesforceLimitNotification.UsageCalc();

SalesforceLimitNotification.sendLimitEmail('testpurpose');
Test.stopTest();
        

}

}