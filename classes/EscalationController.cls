/**************************************************************************************
* Class Name   : EscalationController
* Description  : Class is used in as controller to lightening component 'My Escalations' 
* CR / MOA Number    : CR-00136459
* Created By   : Deepak Kumar
* Created Date : 10/14/2015
************************Version Updates************************************************
 Updated Date(DD/MM/YYYY)         Updated By     CR/Defect Number         Comments
  16-Aug-16                       Deepak		 	CR-00140787           Remove licensing cases from escalation app view
************************Version Updates************************************************/
Public Class EscalationController {
    
    private static string reqFields = 'Id,GSS_Case_Number__r.RecordTypeid, GSS_Account__c, Name,Escalation_Subject__c,Owner.Email,Current_Status__c, GSS_Description__c, Escalated_Date__c,RequestId__c, TSE_Phone__c,GSS_Case_Number__r.GSS_Entitlement_Code__c,Escalation_Age__c,GSS_Case_Number__r.Case_Age_Business_Days__c,Days_Escalated__c,GSS_Case_Number__r.GSS_Product_Name__c,Selection__c, GSS_Status__c, Summary__c, Executive_Summary__c, Account_Formula__c, OwnerId, Owner_Name__c, GSS_Alert_Level__c, Account_Id__c';
        
	private static Id escRecType = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_ESC_ESCREQ').Record_Type_ID__c);
	private static Id caseRecType = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c); 
    
    /*
        Method Name : getFollowing
        Description : Fetch all the escalation request which current logged in user is following 
        Params : String
        Return Type : List<GSS_Request__c>
    */
     @AuraEnabled
     public static List<GSS_Request__c> getFollowing(String regionStr) {
        System.debug('regionStr::'+regionStr); 
         
            list<GSS_Request__c> followingList = new list<GSS_Request__c>();
            list<Request_Contact__c> reqConts = new list<Request_Contact__c>();
            List<GSS_Request__c> following = new List<GSS_Request__c>();
        try{    
            reqConts = [Select id, Subscribed__c,User__c,Request__c from Request_Contact__c where Subscribed__c = true and User__c =: UserInfo.getUserId()];
            
            if(!reqConts.isEmpty()){
        
                Set<Id> reqIds = new Set<Id>();
                for(Request_Contact__c reqCon : reqConts){
                    reqIds.add(reqCon.Request__c);
                }
            
                String queryStr = 'SELECT ' + reqFields
                    + ', (Select id, Subscribed__c,User__c from Request_Contacts__r where User__c = \'' + UserInfo.getUserId() +'\') ' + 
                    + ' FROM GSS_Request__c where Id in '+String.format( '(\'\'{0}\'\')', new List<String> { String.join( new List<Id>(reqIds) , '\',\'') })+' AND '+
                    + 'RecordTypeid = \'' + escRecType + '\' AND '
                    + 'GSS_Alert_Level__c <> null AND '
                    + 'GSS_Status__c in (\'Assigned\',\'Pending\', \'Approved\', \'New\', \'Work In Progress\') '
					+ 'AND GSS_Case_Number__r.RecordTypeid = \'' + caseRecType + '\''; // Added for CR-00140787 
                if(regionStr != 'All')
                {
                    queryStr = queryStr + 'AND GSS_Case_Number__r.GSS_Support_Customer_Region__c= \'' + regionStr + '\''; 
                }
                queryStr = queryStr + 'ORDER BY GSS_Alert_Level__c,GSS_Account__c NULLS LAST';
                System.debug('following query -->' + queryStr);
                following = Database.query(queryStr);
            
            }
            if(following.size() > 0)
            {
               followingList = prepareRequestList(following);
            }
        }catch(exception ex){
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Request__c','getFollowing');
            return followingList;
        }
        return followingList;
     }
     
     /*
        Method Name : getRecommended
        Description : Fetch all the escalation request which current logged in user is recommended for 
        Params : String
        Return Type : List<GSS_Request__c>
    */
    @AuraEnabled
     public static List<GSS_Request__c> getRecommended(String regionStr) {
        
        
             list<GSS_Request__c> recommendedList= new list<GSS_Request__c>();
             list<Request_Contact__c> reqConts = new list<Request_Contact__c>();
             List<GSS_Request__c> recommended = new List<GSS_Request__c>();
        try{
        reqConts = [Select id, Subscribed__c,User__c,Request__c from Request_Contact__c where Subscribed__c = false and User__c =: UserInfo.getUserId()];
        
        if(!reqConts.isEmpty()){
    
                Set<Id> reqIds = new Set<Id>();
                for(Request_Contact__c reqCon : reqConts){
                    reqIds.add(reqCon.Request__c);
                }
             
                String queryStr = 'SELECT ' + reqFields
                + ', (Select id, Subscribed__c from Request_Contacts__r where User__c = \'' + UserInfo.getUserId() +'\') ' + 
                + ' FROM GSS_Request__c where Id in '+String.format( '(\'\'{0}\'\')', new List<String> { String.join( new List<Id>(reqIds) , '\',\'') })+' AND '+
                + 'RecordTypeid = \'' + escRecType + '\' AND '
                + 'GSS_Alert_Level__c <> null AND '
                + 'GSS_Status__c in (\'Assigned\',\'Pending\', \'Approved\', \'New\', \'Work In Progress\') '
				+ 'AND GSS_Case_Number__r.RecordTypeid = \'' + caseRecType + '\'';// Added for CR-00140787 
                if(regionStr != 'All')
                {
                    queryStr = queryStr + 'AND GSS_Case_Number__r.GSS_Support_Customer_Region__c= \'' + regionStr + '\''; 
                }
                queryStr = queryStr + 'ORDER BY GSS_Alert_Level__c,GSS_Account__c NULLS LAST';
                System.debug(queryStr);
                recommended = Database.query(queryStr);
        }  
        if(recommended.size() > 0)
        {
                recommendedList = prepareRequestList(recommended);
        }
        }catch(exception ex){
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Request__c','getRecommended');
            return recommendedList;
        }
        return recommendedList;
      
     }
    
    /*
        Method Name : getAllActive
        Description : Fetch all the escalation request which are active and open 
        Params : String
        Return Type : List<GSS_Request__c>
    */  
     @AuraEnabled
     public static List<GSS_Request__c> getAllActive(String regionStr)
     {  
        
         List<GSS_Request__c> allActiveList = new List<GSS_Request__c>();
         list<Request_Contact__c> reqConts = new list<Request_Contact__c>();
         List<GSS_Request__c> activeRequests = new List<GSS_Request__c>();
        try{
        reqConts = [Select id, Subscribed__c,User__c,Request__c from Request_Contact__c where User__c =: UserInfo.getUserId()];
        System.debug('reqConts-Active::'+reqConts);
            if(!reqConts.isEmpty()){
    
                Set<Id> reqIds = new Set<Id>();
                for(Request_Contact__c reqCon : reqConts){
                    reqIds.add(reqCon.Request__c);
                }
            
            String queryStr = 'SELECT ' + reqFields
            + ', (Select id, Subscribed__c from Request_Contacts__r where User__c = \'' + UserInfo.getUserId() +'\') ' +  
            + 'FROM GSS_Request__c where Id in '+String.format( '(\'\'{0}\'\')', new List<String> { String.join( new List<Id>(reqIds) , '\',\'') })+' AND '+
            + 'RecordTypeid = \'' + escRecType + '\' AND '
            + 'GSS_Alert_Level__c <> null AND '
            + 'GSS_Status__c in (\'Assigned\', \'Approved\', \'New\', \'Pending\', \'Work in Progress\') '
			+ 'AND GSS_Case_Number__r.RecordTypeid = \'' + caseRecType + '\'';// Added for CR-00140787 
            if(regionStr != 'All')
            {
                queryStr = queryStr + 'AND GSS_Case_Number__r.GSS_Support_Customer_Region__c= \'' + regionStr + '\''; 
            }
            queryStr = queryStr + 'ORDER BY GSS_Alert_Level__c,GSS_Account__c NULLS LAST';
            activeRequests = Database.query(queryStr); 
            }
            if(activeRequests.size() > 0)
            {
                allActiveList = prepareRequestList(activeRequests);
            } 
            }catch(exception ex){
                CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Request__c','allActiveList');
                return allActiveList;
           }    
        //}
        System.debug('allActiveList::'+allActiveList);
       return allActiveList;
     }
    /*
        Method Name : getAllClosed
        Description : Fetch all the escalation request which are closed 
        Params : String
        Return Type : List<GSS_Request__c>
    */  
     @AuraEnabled
     public static List<GSS_Request__c> getAllClosed(String regionStr)
     {  
        
         List<GSS_Request__c> allClosedList = new List<GSS_Request__c>();
         list<Request_Contact__c> reqConts = new list<Request_Contact__c>();
         List<GSS_Request__c> closedRequests = new List<GSS_Request__c>();
        try{
         reqConts = [Select id, Subscribed__c,User__c,Request__c from Request_Contact__c where User__c =: UserInfo.getUserId()];
        
            if(!reqConts.isEmpty()){
    
                Set<Id> reqIds = new Set<Id>();
                for(Request_Contact__c reqCon : reqConts){
                    reqIds.add(reqCon.Request__c);
                }
         
                String queryStr = 'SELECT ' + reqFields
                + ', (Select id, Subscribed__c from Request_Contacts__r where User__c = \'' + UserInfo.getUserId() +'\') ' + 
                + 'FROM GSS_Request__c where Id in '+String.format( '(\'\'{0}\'\')', new List<String> { String.join( new List<Id>(reqIds) , '\',\'') })+' AND '+
                + 'RecordTypeid = \'' + escRecType + '\' AND '
                + 'GSS_Alert_Level__c <> null AND '
                + 'GSS_Status__c in (\'Rejected\', \'Resolved\', \'De-Escalated\', \'Info Povided\') '
				+ 'AND GSS_Case_Number__r.RecordTypeid = \'' + caseRecType + '\'';// Added for CR-00140787 
                if(regionStr != 'All')
                {
                    queryStr = queryStr + 'AND GSS_Case_Number__r.GSS_Support_Customer_Region__c= \'' + regionStr + '\''; 
                }
                queryStr = queryStr + 'ORDER BY GSS_Alert_Level__c,GSS_Account__c NULLS LAST';
                closedRequests = Database.query(queryStr); 
            }
             if(closedRequests.size() > 0)
             {
                 allClosedList = prepareRequestList(closedRequests);
             }
          }catch(exception ex){
                CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Request__c','allClosedList');
                return allClosedList;
          }  
        //}
         return allClosedList;
     }
    /*
        Method Name : getAllClosed
        Description : Fetch all the escalation requests 
        Params : String
        Return Type : List<GSS_Request__c>
    */
     @AuraEnabled
     public static List<GSS_Request__c> getAllEscalations(String regionStr)
     {  
     
         List<GSS_Request__c> allEscalations = new List<GSS_Request__c>();
         list<Request_Contact__c> reqConts = new list<Request_Contact__c>();
         List<GSS_Request__c> allRequests = new List<GSS_Request__c>();
        try{
         reqConts = [Select id, Subscribed__c,User__c,Request__c from Request_Contact__c where User__c =: UserInfo.getUserId()];
         System.debug('reqConts-All::'+reqConts);
            if(!reqConts.isEmpty()){
    
                Set<Id> reqIds = new Set<Id>();
                for(Request_Contact__c reqCon : reqConts){
                    reqIds.add(reqCon.Request__c);
                }
         
               String queryStr = 'SELECT ' + reqFields
                + ', (Select id, Subscribed__c from Request_Contacts__r where User__c = \'' + UserInfo.getUserId() +'\') ' + 
                + 'FROM GSS_Request__c where Id in '+String.format( '(\'\'{0}\'\')', new List<String> { String.join( new List<Id>(reqIds) , '\',\'') })+' AND '+
                + 'RecordTypeid = \'' + escRecType + '\' AND '
                + 'GSS_Alert_Level__c <> null '
				+ 'AND GSS_Case_Number__r.RecordTypeid = \'' + caseRecType + '\'';// Added for CR-00140787 
                if(regionStr != 'All')
                {
                    queryStr = queryStr + 'AND GSS_Case_Number__r.GSS_Support_Customer_Region__c= \'' + regionStr + '\''; 
                }
                queryStr = queryStr + 'ORDER BY GSS_Alert_Level__c,GSS_Account__c NULLS LAST';
                allRequests = Database.query(queryStr); 
            }
             if(allRequests.size() > 0)
             {
                 allEscalations = prepareRequestList(allRequests);
             }
        }catch(exception ex){
                CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Request__c','allEscalations');
                return allEscalations;
        }
        System.debug('allEscalations::'+allEscalations);
        return allEscalations;
     }
    /*
        Method Name : prepareRequestList
        Description : Sort list as per color code.
        Params : List<GSS_Request__c>
        Return Type : List<GSS_Request__c>
    */
    public static List<GSS_Request__c> prepareRequestList(List<GSS_Request__c> lstRequests)
    {
                
        list<GSS_Request__c> Red_List= new list<GSS_Request__c>();
         list<GSS_Request__c> Orange_List = new list<GSS_Request__c>();
         list<GSS_Request__c> Yellow_List = new list<GSS_Request__c>();
         list<GSS_Request__c> Watch_List = new list<GSS_Request__c>();
         list<GSS_Request__c> Purple_List = new list<GSS_Request__c>();
        List<GSS_Request__c> escalationRequestList = new List<GSS_Request__c>();
        try{
        for(GSS_Request__c req : lstRequests){
                if(req.Request_Contacts__r.size()>0){
                        if(req.Request_Contacts__r[0].Subscribed__c == true)
                            req.Selection__c = 'Following';
                        else
                            req.Selection__c = 'Recommended';
                        /*String execSummary = req.Executive_Summary__c;
                        String customer = req.GSS_Account__c;
                        if(execSummary!=null && execSummary.length()>20){
                            execSummary = execSummary.substring(0,17);
                            execSummary += '...';
                            req.Executive_Summary__c = execSummary;
                        }else{
                            req.Executive_Summary__c = execSummary;
                        }*/
                        
                        if(req.GSS_Alert_Level__c=='4  Red'){
                            Red_List.add(req);
                        }else if(req.GSS_Alert_Level__c=='3  Orange'){
                            Orange_List.add(req);
                        }else if(req.GSS_Alert_Level__c=='2 Yellow'){
                            Yellow_List.add(req);
                        }else if(req.GSS_Alert_Level__c=='1- Watchlist'){
                            Watch_List.add(req);
                        }else if(req.GSS_Alert_Level__c=='1.1 Purple'){
                            Purple_List.add(req);
                        }
                        //escalationRequestList.add(req);
                } 
            }
        //escalationRequestList.clear();
            for(GSS_Request__c reqs:Red_List){
                 escalationRequestList.add(reqs);
             }
             for(GSS_Request__c reqs:Orange_List){
                     escalationRequestList.add(reqs);
                 }
             for(GSS_Request__c reqs:Yellow_List){
                     escalationRequestList.add(reqs);
                 }
             for(GSS_Request__c reqs:Watch_List){
                     escalationRequestList.add(reqs);
                 }
             for(GSS_Request__c reqs:Purple_List){
                     escalationRequestList.add(reqs);
                 }    
        }catch(exception ex){
                CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Request__c','escalationRequestList');
                return escalationRequestList;
        }        
        return escalationRequestList;
    }
     /*
        Method Name : subscribeRequest
        Description : Subscribe the user for getting push notification
        Params : String
        Return Type : Boolean
    */
     @AuraEnabled
     public static Boolean subscribeRequest(String requestId) {
         Boolean val = false;
         if(requestId!=null && requestId!=''){
             List<Request_Contact__c> reqContacts = [Select Subscribed__c from Request_Contact__c 
                                                        where Request__c = :requestId and
                                                     User__c = :UserInfo.getUserId()
                                                    ];
             if(reqContacts!=null && reqContacts.size() > 0)
             {
                 if(reqContacts[0].Subscribed__c){                     
                     reqContacts[0].Subscribed__c = false;
                 }else{
                     reqContacts[0].Subscribed__c = true;
                 }                 
                 Database.update(reqContacts[0]); 
                 val = true;
             }else{
                 Request_Contact__c reqCon = new Request_Contact__c(User__c=UserInfo.getUserId(),
                                                 Request__c = requestId , Contact_Type__c ='Executive VMW',
                                                 Subscribed__c=true);
                 Database.insert(reqCon,false); 
                 val = true;
             }             
         }
         return val ;
     }
     /*
        Method Name : UnsubscribeRequest
        Description : UnSubscribe the user for getting push notification
        Params : String
        Return Type : Boolean
    
     @AuraEnabled
     public static Boolean UnsubscribeRequest(String requestId) {
         Boolean val = false;
         if(requestId!=null && requestId!=''){
             List<Request_Contact__c> reqContacts = [Select Subscribed__c from Request_Contact__c 
                                                        where Request__c = :requestId and
                                                     User__c = :UserInfo.getUserId()
                                                    ];
             if(reqContacts!=null && reqContacts.size() > 0)
             {
                 reqContacts[0].Subscribed__c = false;
                 Database.update(reqContacts[0]); 
                 val = true;
             }    
         }
         return val;
     }*/
}