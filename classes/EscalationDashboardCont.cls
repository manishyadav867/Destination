/**************************************************************************************
* Class Name   : EscalationDashboardCont
* Description  : Class is used in as controller to lightening component 'All Escalations' 
* CR / MOA Number    : CR-00136459
* Created By   : Deepak Kumar
* Created Date : 10/14/2015
************************Version Updates************************************************
 Updated Date(DD/MM/YYYY)         Updated By     CR/Defect Number         Comments
  16-Aug-16                       Deepak		 	CR-00140787           Remove licensing cases from escalation app view
************************Version Updates************************************************/
public class EscalationDashboardCont {
    private static string reqFields = 'Id,GSS_Case_Number__r.RecordTypeid, GSS_Account__c,Days_Escalated__c, Name,Escalation_Subject__c, GSS_Description__c, Escalated_Date__c,RequestId__c,'
        +' TSE_Phone__c, Selection__c, GSS_Status__c, Summary__c, Executive_Summary__c, Account_Formula__c, OwnerId, Owner_Name__c,Owner.Email,'
        +' GSS_Alert_Level__c, Account_Id__c , GSS_Case_Number__r.GSS_Product_Name__c ,GSS_Case_Number__r.GSS_Entitlement_Code__c , '
        +' GSS_Situation_Temp__c , Escalation_Age__c , Current_Status__c , GSS_Case_Number__r.Case_Age_Business_Days__c';
    
	private static Id escRecType = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_ESC_ESCREQ').Record_Type_ID__c);
	private static Id caseRecType = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
	
    @AuraEnabled
    public static Integer getAllEscalationsCount(String PName, String EName, String CName, String AName,Boolean ALRed,Boolean ALYellow,Boolean ALOrange,Boolean ALPurple)
    {
        Integer escalationsCount=0;
        String psName = '%'+PName+'%';
         String esName = '%'+EName+'%';
         String csName = '%'+CName+'%';
         String asName = '%'+AName+'%';
        
        String queryStr = 'SELECT COUNT()' +   
                ' FROM GSS_Request__c where '
				+ 'RecordTypeid = \'' + escRecType + '\' AND '// Added for CR-00140787 
				+ ' GSS_Case_Number__r.RecordTypeid = \'' + caseRecType + '\' AND ';// Added for CR-00140787 
				
             if(PName !='' && PName != null){
                 queryStr =  queryStr + 'GSS_Case_Number__r.GSS_Product_Name__c LIKE :psName AND';                                      
                                        
             } 
             if(EName!='' && EName!= null){
                 queryStr =  queryStr + ' GSS_Case_Number__r.GSS_Entitlement_Code__c LIKE :esName AND';                                      
                                        
             }  
             if(CName!='' && CName!= null){
                 queryStr =  queryStr + ' GSS_Status__c LIKE :csName AND';                                     
                                        
             } 
             if(AName!='' && AName!= null){
                 queryStr =  queryStr +  ' GSS_Account__c LIKE :asName AND';                                      
                                        
             }  
    
        queryStr += ' GSS_Status__c in (\'Assigned\', \'Approved\', \'New\', \'Pending\', \'Work in Progress\')';
            
        Boolean anyFilterOnAlertLevel = false;
if (ALRed == true || ALOrange == true || ALYellow == true  || ALPurple == true)
{
    queryStr += ' AND (';
    if(ALRed == true){
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'4  Red\'';
        anyFilterOnAlertLevel = true;
     }
     if(ALOrange == true){
         if (anyFilterOnAlertLevel == true)
         {
             queryStr+=' OR ';
         }
         anyFilterOnAlertLevel = true;
         
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'3  Orange\'';
     }
      if(ALYellow == true){
          if (anyFilterOnAlertLevel == true)
         {
             queryStr+=' OR ';
         }
         anyFilterOnAlertLevel = true;
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'2 Yellow\'';
     }
     if(ALPurple == true){
         if (anyFilterOnAlertLevel == true)
         {
             queryStr+=' OR ';
         }
         anyFilterOnAlertLevel = true;
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'1.1 Purple\'';
     }  
    queryStr += ')';
}
        
        System.debug('queryStrcount::==>'+queryStr);
        escalationsCount = Database.countQuery(queryStr); 
        
        return escalationsCount;
    }
    @AuraEnabled
     public static List<GSS_Request__c> getAllEscalations(Integer offset, String PName, String EName, String CName, String AName,Boolean ALRed,Boolean ALYellow,Boolean ALOrange,Boolean ALPurple)
     {  
         List<GSS_Request__c> allEscalations = new List<GSS_Request__c>();
         List<GSS_Request__c> allRequests = new List<GSS_Request__c>();
        //list<Request_Contact__c> reqConts = new list<Request_Contact__c>();
         
         /*reqConts = [Select id, Subscribed__c,User__c,Request__c from Request_Contact__c where User__c =: UserInfo.getUserId()];
            
         if(!reqConts.isEmpty()){
        
            Set<Id> reqIds = new Set<Id>();
            for(Request_Contact__c reqCon : reqConts){
                  reqIds.add(reqCon.Request__c);
            }
         }*/
         String psName = '%'+PName+'%';
         String esName = '%'+EName+'%';
         String csName = '%'+CName+'%';
         String asName = '%'+AName+'%';
         
         String queryStr = 'SELECT ' + reqFields +   
                ', (Select id, Subscribed__c,User__c from Request_Contacts__r where User__c = \'' + UserInfo.getUserId() +'\') '+
                ' FROM GSS_Request__c where  '
				+ 'RecordTypeid = \'' + escRecType + '\' AND ' // Added for CR-00140787
				+ ' GSS_Case_Number__r.RecordTypeid = \'' + caseRecType + '\' AND ';// Added for CR-00140787 				
             if(PName !='' && PName != null){
                 queryStr =  queryStr + ' GSS_Case_Number__r.GSS_Product_Name__c LIKE :psName AND';                                      
                                        
             } 
             if(EName!='' && EName!= null){
                 queryStr =  queryStr + ' GSS_Case_Number__r.GSS_Entitlement_Code__c LIKE :esName AND';                                      
                                        
             }  
             if(CName!='' && CName!= null){
                 queryStr =  queryStr + ' GSS_Status__c LIKE :csName AND';                                     
                                        
             } 
             if(AName!='' && AName!= null){
                 queryStr =  queryStr +  ' GSS_Account__c LIKE :asName AND';                                      
                                        
             }          
         
                                        
                                       
            queryStr = queryStr+    ' GSS_Status__c in (\'Assigned\', \'Approved\', \'New\', \'Pending\', \'Work in Progress\') ';
            Boolean anyFilterOnAlertLevel = false;
if (ALRed == true || ALOrange == true || ALYellow == true  || ALPurple == true)
{
    queryStr += ' AND (';
    if(ALRed == true){
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'4  Red\'';
        anyFilterOnAlertLevel = true;
     }
     if(ALOrange == true){
         if (anyFilterOnAlertLevel == true)
         {
             queryStr+=' OR ';
         }
         anyFilterOnAlertLevel = true;
         
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'3  Orange\'';
     }
      if(ALYellow == true){
          if (anyFilterOnAlertLevel == true)
         {
             queryStr+=' OR ';
         }
         anyFilterOnAlertLevel = true;
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'2 Yellow\'';
     }
     if(ALPurple == true){
         if (anyFilterOnAlertLevel == true)
         {
             queryStr+=' OR ';
         }
         anyFilterOnAlertLevel = true;
         queryStr =  queryStr + 'GSS_Alert_Level__c =\'1.1 Purple\'';
     }  
    queryStr += ')';
}
            
             queryStr +=   ' ORDER BY GSS_Alert_Level__c DESC LIMIT 10 OFFSET ' + offset;       
        
         System.debug('queryStr::'+queryStr);
         allRequests = Database.query(queryStr); 
         
         for(GSS_Request__c req : allRequests){
              if(req.Request_Contacts__r.size()>0){
                  if(req.Request_Contacts__r[0].Subscribed__c == true){
                           req.Selection__c = 'Following';
                  }
              }   
         } 
         System.debug('allRequests::'+allRequests.size());
         return allRequests;
     }
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
 
    
}