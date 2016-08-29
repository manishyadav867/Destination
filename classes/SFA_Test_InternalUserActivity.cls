// ************************Version Updates********************************************
//
// Updated Date     Updated By          Update Comments 
//
// Dec-26, 2011     Dilip Mistry    Modified Code for CR-00007967
// 20-Feb-2012      Rakesh Poddar       Added Error handling code in catch block for CR-00008898 
// ************************************************************************************
@isTest(seeAllData=True)
private class SFA_Test_InternalUserActivity {
    
    public static testMethod void testInternalUserCheck()
    {
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Event> eventsList = new List<Event>();
        List<Task> tasksList = new List<Task>();
        List<User> usersList = new List<User>();
         Test.startTest();
        recursive.isAtFuture = true;

        /* Modified code for CR-00007967.Added Custom Settings to store the name and id of Profiles.*/
        Profile_Name_Mapping__c prf = CustomSettingUtility.getProfileNameMapping('System Administrator')    ;

         
         User u1 = new User(alias = 'test123', email='test1234test@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = prf.Profile_Id__c, country='United States',
            timezonesidkey='America/Los_Angeles', username='test1235test@noemail.com',Division='AMER');
        
        usersList.add(u1);
        
        User u2 = new User(alias = 'test12', email='test1254@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US',profileid = prf.Profile_Id__c, country='United States',
            timezonesidkey='America/Los_Angeles', username='test124test@testnoemail.com',Division='AMER');
        
        usersList.add(u2);
        
        insert usersList;
       System.RunAs(u1)
     {
       
        
        Account act1 = new Account();
        act1.RecordTypeId = String.ValueOf(recursive.PartnerAccountRecType);
        act1.Name = 'New Test Account 001';
        accountList.add(act1);
            
        insert accountList; 
        
        Contact cnt1 =  new Contact();
        cnt1.RecordTypeId = String.ValueOf(recursive.PartnerContactRecType);    
        System.debug('accountList[0].Id>>>>>>>'+accountList[0].Id);
        cnt1.AccountId = accountList[0].Id;
        cnt1.LastName = 'EFGH';
        cnt1.FirstName = 'ABCD';
        cnt1.Email = 'ABCD@EFGH.com';
        contactList.add(cnt1);
        
        insert contactList;
        
         
        
        Event event1 = new Event();
        event1.StartDateTime = System.Datetime.now();
        event1.EndDateTime = System.Datetime.newInstance(System.today()+1,System.Time.newInstance(0,0,0,0));
        event1.Subject = 'Test Event';
        event1.OwnerId = u1.Id;
        eventsList.add(event1);
        insert eventsList;
        
        Task task1 = new Task();
        task1.ActivityDate = System.today() + 5;
        task1.Priority = 'High';
        task1.Status = 'In Progress';
        task1.Subject = 'Test Task';
        task1.OwnerId = u1.Id;
        tasksList.add(task1);
        insert tasksList;
        
                
        eventsList.clear();
        event1.OwnerId = u2.Id;
        eventsList.add(event1);
        
        
        try 
        {
           update eventsList;
        }
        catch (Exception ex)
        {
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'Event', 'SFA_Test_InternalUserActivity');

        }      
        
        
        tasksList.clear();
        task1.OwnerId = u2.Id;
        tasksList.add(task1);
        try 
        {
           update tasksList;
        }
        catch (Exception ex)
        {
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'Task', 'SFA_Test_InternalUserActivity');

        }
        
        
     }
     Test.stopTest();
    }   
}