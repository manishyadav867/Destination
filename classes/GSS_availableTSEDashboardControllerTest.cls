@isTest(SeeAllData = true)
public class GSS_availableTSEDashboardControllerTest 
{
    public static Event evt1 = new Event();
    public static Event evt2 = new Event();  
    public static Event evt3 = new Event();  
    
    
    public static void Setupdata()
    {  
        //Inserting User
        Profile_Name_Mapping__c pCusObj = CustomSettingUtility.getProfileNameMapping('GSS System Administrator');  
        Id pId = Id.ValueOf(pCusObj.Profile_Id__c);
        
        List<User> userList = new List<User>(); 
            
            
        User evtowner1 = new User(alias = 'GSS223', email='user@testorg.com',languagelocalekey='en_US', 
            emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = pId, 
            timezonesidkey='America/Los_Angeles', username='gssuluser@testorg2.com',isActive =true, Division = 'AMER');
        userList.add(evtowner1);   
        User evtowner2 = new User(alias = 'aachary', email='aachary=vmware.com@example.com',languagelocalekey='en_US', 
            emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = pId, 
            timezonesidkey='Asia/Kolkata', username='aachary@vmwa.com.vmw.dev1',isActive =true, Division = 'AMER');
        userList.add(evtowner2);
        User evtowner3 = new User(alias = 'aachutha', email='aachuthavmware.com@example.com',languagelocalekey='en_US', 
            emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = pId, 
            timezonesidkey='Asia/Kolkata', username='aautha@vmware.com.vmw.dev1',isActive =true, Division = 'AMER');
        userList.add(evtowner3); 
        Database.insert(userList);  

        List<GSS_User_Data__c> lstUserData = new List<GSS_User_Data__c>();
        GSS_User_Data__c usdata = new   GSS_User_Data__c(WorkloadPoints__c=1,Reset_Workload_Point__c=0,Prevent_Duplicate__c='xya.abab@hahsa.com',User__c=evtowner1.id,User_under_Shift__c=true);
        lstUserData.add(usdata);
        GSS_User_Data__c usdata2 = new  GSS_User_Data__c(WorkloadPoints__c=1,Reset_Workload_Point__c=0,Prevent_Duplicate__c='xya.aba@hahsa.com',User__c=evtowner2.id,User_under_Shift__c=true);
        lstUserData.add(usdata2);
        GSS_User_Data__c usdata3 = new GSS_User_Data__c(WorkloadPoints__c=1,Reset_Workload_Point__c=0,Prevent_Duplicate__c='xya.ab@hahsa.com',User__c=evtowner3.id,User_under_Shift__c=true);
        lstUserData.add(usdata3);
        Database.insert(lstUserData);

        
        Map<String, GSS_Region_Shift_Timings__c> mapShiftTimings = GSS_Region_Shift_Timings__c.getAll();
        if(mapShiftTimings.size() == 0)
        {
            List<GSS_Region_Shift_Timings__c> lstShifTDetails = new List<GSS_Region_Shift_Timings__c>();
            lstShifTDetails.add(new GSS_Region_Shift_Timings__c(Name='APAC', Start_Time__c='00:30', End_Time__c='10:30'));
            lstShifTDetails.add(new GSS_Region_Shift_Timings__c(Name='EMEA', Start_Time__c='06:30', End_Time__c='16:30'));
            lstShifTDetails.add(new GSS_Region_Shift_Timings__c(Name='NASA', Start_Time__c='14:30', End_Time__c='00:30'));
            Database.insert(lstShifTDetails);
        }
        
        List<Event> evtList = new List<Event>();
        evt1.OwnerId=evtowner1.Id;
        evt1.DurationInMinutes = 241;
        evt1.ActivityDateTime = DateTime.newInstance(system.today().year(), system.today().month(), system.today().Day(), 00, 30, 00);
        evtList.add(evt1);
        
        evt2.OwnerId=evtowner2.Id;
        evt2.DurationInMinutes = 260;
        evt2.ActivityDateTime = DateTime.newInstance(system.today().year(), system.today().month(), system.today().Day(), 07, 00, 00);
        evtList.add(evt2);          
                           
        evt3.OwnerId=evtowner3.Id;
        evt3.DurationInMinutes = 600;
        evt3.ActivityDateTime = DateTime.newInstance(system.today().year(), system.today().month(), system.today().Day(), 14, 30, 00);
        evtList.add(evt3);          
        Database.Insert(evtList);                     
    }
    
    public static Testmethod void positivetest()
    {
        Setupdata();
        PageReference pageRef = Page.GSS_availableTSEDashboardPage;
        Test.setCurrentPage(pageRef);   
        test.startTest();
        GSS_availableTSEDashboardController tseDashboard = new GSS_availableTSEDashboardController(); 
        test.stopTest();
    }
   
}