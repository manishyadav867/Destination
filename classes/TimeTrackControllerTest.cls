/********************************************************** 
* Class Name : CaseTimeTrackDetailReportControllerTest
* Purpose    : Test class for CaseTimeTrackDetailReportController
* ******************************************************* 
* Author               Date            Remarks 
* Vivekanand Deshmane         11-April-12       Created - Coverage(88%)
* *********************************************************/

@isTest
public class TimeTrackControllerTest{
 public static Case testCase;
 public static GSS_Request__c req;  
   public static void setUpData(){
        String RecTypeId;    
        Map<Id, Schema.RecordTypeInfo> mapRecTypeInfo = new Map<Id, Schema.RecordTypeInfo>();
        // Fetching Record Type Info for Account.   
       
        mapRecTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosById();
        for(Schema.RecordTypeInfo recInfo : mapRecTypeInfo.values())
        {
            if(recInfo.Name.equalsIgnorecase('End Customer'))
            {
                RecTypeId = recInfo.recordTypeId;
                break;
            }
        }
      
        String RecTypeCaseId;    
        Map<Id, Schema.RecordTypeInfo> mapRecTypeCaseInfo = new Map<Id, Schema.RecordTypeInfo>();
        // Fetching Record Type Info for Case.   
        mapRecTypeCaseInfo = Schema.SObjectType.Case.getRecordTypeInfosById();
        for(Schema.RecordTypeInfo recInfo : mapRecTypeCaseInfo.values())
        {
            if(recInfo.Name.equalsIgnorecase('GSS Technical Support'))
            {
                RecTypeCaseId = recInfo.recordTypeId;
                break;
            }
        }
              
      testCase = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',
                    Priority='3 - Medium', GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',
                    GSS_Support_Customer_Region__c='NASA',RecordTypeId = RecTypeCaseId ,
                    GSS_Available_24_7__c='yes',Status='New',Subject ='testing',Description='testing');

        testCase.Escalation_Reason__c='Test Reason';
        insert testCase;
         req=new GSS_Request__c();
        req.GSS_Case_Number__c=testCase.Id;
        insert req;
       } 
       
       public static testmethod void  thirdPartyTimeTrck(){
           Test.startTest();
       //Setup to inset case in DB.
           setUpData();
            List<Case> caseList=[SELECT Id FROM Case Where Id=:testCase.Id];
        if(caseList.size()>0){
            Case caseObj=caseList.get(0);
            //System.currentPagereference().getParameters().put('caseId',caseObj.Id);
            //System.currentPagereference().getParameters().put('caseUserName','Vivekanand Deshmane');
            //System.currentPagereference().getParameters().put('timeTrackDate',timeTrackDate);
              PageReference cView = new ApexPages.StandardController(caseObj).view();
              string fullURL ='https://cs12.salesforce.com/'+caseObj.Id;
               TimeTrackController.thirdPartyTimeTrck('00:00:30',fullURL,'View') ;
              TimeTrackController.findContacts('00:00:30',fullURL);
              string fullReqURL ='https://cs12.salesforce.com/'+req.Id;
               TimeTrackController.findContacts('00:00:30',fullReqURL );
               string fullActivityURL='https://cs12.salesforce.com/00TV00000030QKx?retURL=%2F'+caseObj.Id;
               TimeTrackController.findContacts('00:00:30',fullActivityURL);
               TimeTrackController.getTemTime(fullURL);
               TimeTrackController.getTemTimeOfUser(fullURL);
                TimeTrackController.insertTempTimeTrack(fullURL);
                //TimeTrackController.updateTimeTrack(fullURL);
               TimeTrackController.getTimeInSec('00:02:30');
              System.currentPagereference().getParameters().put('URL',fullURL);
               System.currentPagereference().getParameters().put('extraTime','0:02:03');
                TimeTrackController tc=new TimeTrackController(new ApexPages.StandardController(caseObj));
                TimeTrackController.insertTempTimeTrack(fullURL);
                tc.saveTimerData();
             /**   tc.saveOnFocusTimerData();
                 
                TimeTrackController.insertTempTimeTrack(fullURL);
               TimeTrackController.removeEntryFromTempTimeTrack(fullURL);**/
              
              }
         Test.stopTest();

       } 
       public static testmethod void  otherWorkTimeTrck(){
           Test.startTest();
       //Setup to inset case in DB.
           setUpData();
            List<Case> caseList=[SELECT Id FROM Case Where Id=:testCase.Id];
        if(caseList.size()>0){
            Case caseObj=caseList.get(0);
            TimeTrackController.otherWorkTimeTrck('00:00:30',caseObj.Id,'Additional Work');
             string fullActivityURL='https://cs3.salesforce.com/500Q0000004JgW4?what_id='+caseObj.Id;
             TimeTrackController.recordId(fullActivityURL);
             
             TimeTrackController.recordId('https://cs3.salesforce.com/a2bQ0000004JgW4?what_id='+caseObj.Id);
             
             TimeTrackController.recordId('https://cs3.salesforce.com/500Q0000004JgW4?parent_id='+caseObj.Id);
             TimeTrackController.recordId('https://cs3.salesforce.com/500Q0000004JgW4?CaseID='+caseObj.Id);
             TimeTrackController.recordId('https://cs3.salesforce.com/500Q0000004JgW4?p3_lkid='+caseObj.Id);
            
             TimeTrackController.recordId('https://cs3.salesforce.com/500Q0000004JgW4?id='+caseObj.Id);
             TimeTrackController.mode(fullActivityURL);
             TimeTrackController.mode('https://cs3.salesforce.com/500Q0000004JgW4?parent_id='+caseObj.Id);
             TimeTrackController.mode('https://cs3.salesforce.com/500Q0000004JgW4?CaseID='+caseObj.Id);
             TimeTrackController.mode('https://cs3.salesforce.com/500Q0000004JgW4?p3_lkid='+caseObj.Id);
             TimeTrackController.mode('https://cs3.salesforce.com/A2BQ0000004JgW4?p3_lkid=A2BQ0000004JgW4');
             TimeTrackController.mode('https://cs3.salesforce.com/500Q0000004JgW4?id='+caseObj.Id);
             TimeTrackController.mode('https://cs12.salesforce.com/500V0000001q5TJ/e?retURL=%2F500V0000001q5TJ');
             TimeTrackController.mode('https://cs3.salesforce.com/500Q0000004JgW4?parent_id='+caseObj.Id+'&&retURL=1');
             TimeTrackController.mode('https://cs3.salesforce.com/002Q00000056z3NM?parent_id='+caseObj.Id);
             TimeTrackController.mode('https://cs3.salesforce.com/002Q00000056z3NM?pid='+caseObj.Id+'&&kp=null');
              
             TimeTrackController.recordIdForRequest('https://cs3.salesforce.com/500Q0000004JgW4?pid='+caseObj.Id+'&&kp='+caseObj.Id);
             TimeTrackController.recordIdForRequest('https://cs3.salesforce.com/500Q0000004JgW4?parent_id='+caseObj.Id);
             TimeTrackController.recordIdForRequestFromChildObject('https://cs3.salesforce.com/002Q00000056z3NM');
             TimeTrackController.recordIdForRequestFromAttachment ('https://cs3.salesforce.com/00PQ00000056z3NM');
             TimeTrackController tc=new TimeTrackController(new ApexPages.StandardController(caseObj));
            
            }
            Test.stopTest(); 
        }  
        
         public static testmethod void  WebexTimeTrack(){
           Test.startTest();
       //Setup to inset case in DB.
          setUpData();
          
          List<Case> caseList=[SELECT Id FROM Case Where Id=:testCase.Id];
            if(caseList.size()>0){
                Case caseObj=caseList.get(0);
                string fullURL ='https://cs12.salesforce.com/'+caseObj.Id;
                 TimeTrackController tc=new TimeTrackController(new ApexPages.StandardController(caseObj));
                 tc.saveOnFocusTimerData();
                 
                TimeTrackController.insertTempTimeTrack(fullURL);
               TimeTrackController.removeEntryFromTempTimeTrack(fullURL);
                System.currentPagereference().getParameters().put('URL','https://cs3.salesforce.com/'+caseObj.Id);
               TimeTrackController.weExTempTimeTrackEntry();
                 Datetime x=Datetime.now();
                 WebExTempTimTrack__c webExc = new WebExTempTimTrack__c ();
                  webExc .Case__c=caseObj.Id;
                  webExc.time__c=x.addDays(-5).addSeconds(20)+'';
                   webExc.User__c=UserInfo.getUserId();
                  insert webExc ;
                  
                  
                   
                   List<WebExTempTimTrack__c> temList2 = [Select Id ,User__c,time__c,Case__c from WebExTempTimTrack__c where User__c=:UserInfo.getUserId() and Case__c=:caseObj.Id  order by id desc limit 1 ];
               TimeTrackController.weExTimeTrackEntry(temList2,'Web Ex Session',caseObj.Id);
               
             }
             Test.stopTest(); 
        }      
}