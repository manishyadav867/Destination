/** Trigger Name      : GSS_CaseOwnerManager
  * Author            : Accenture - IDC (Harish Patkar)
  * JIRA #            : PP-18436
  * JIRA Description  : Create custom trigger to Update the Case Owner Manager Field 
  * Detail Description: This class is update the Owner Manager Email on Case. It gets the value of Case Owner Manager Email from User object.
  *                             
  **/
  // 8/2/2012         Teja Sane       Added functionality for update case owner name for CR-00011952
  // 10/8/2012        Teja Sane       Added functionality for update case owner name for CR-00013752
  // 2-Feb-2013       Nitin Bhalla    Added functionality for update of Commit Defaulter's Name to Field CR-00028703
  // 4/26/2013        Pradnya         Added code to update case owner managers field when case is assigned to any Queue for CR-00030433
  // 19/6/2015        MSJ             Added code for Populating Business unit on case with User's business unit value for CR-00131921
  // 14/7/2015        MSJ             Added Condition to blank BU unit if queue name is not present in custom setting for CR-00135228.
  // 24-July-2015     Ashwin Dash     CR-00135394  -  Added If Condition added for reducing the no. of SOQL
  // 11-Aug-2015      MSJ             Added functionality for CR-00135328 - removed record type check.
  // 24-Sep-2015      Jyolsna Raghavan  RS2 H2 Project- CR-00135349 - added case renewal operations record type check
  // 02-Feb-2016      MSJ               CR-00137728 - Added Null Check As a part of reducing SOQL Count. 
  // 29-Mar-2016      Jyolsna Raghavan  CR-00137286 - Added code to GSS Business Unit - Transfer logic update for '*CS-EDU"' -> '<blank>'
  // 14-Jul-2016    Nilanjana      Added code for RS2 QUF 101
  // 13-Jul-2016      Jyolsna Raghavan  CR-00139004 - Transfer Details NOT captured from GSS Education Support queue to other queues with Blank Business Unit
  
public with sharing class GSS_CaseOwnerManager {

    /*********************************************************************************************** 
     * Method Name       : updateCaseOwnerManagerEmail
     * Author            : Accenture (Harish Patkar)
     * JIRA #            : PP-18436, Visualforce- Case Assignment VisualForce Results Page
     * @ Param           : Set<Id>, List<Id> 
     * @ Return          : Void
     * Description       : This method is update the Owner Manager Email on Case and it is called from Trigger :: GSS_AfterInsertUpdateOwnerManagerEmail.
     ***********************************************************************************************/
     public static String renewalsRecordType = Record_Type_Settings__c.getInstance('CaseRenewalOperations').Record_Type_ID__c!=null?Record_Type_Settings__c.getInstance('CaseRenewalOperations').Record_Type_ID__c:Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();//CR-00135349 - Added for Variable declaration

    public static void updateGSS_owner_email(List<Case> caseList){
        User thisOwner;
        Map<ID,User> ownerId_UserObj;//CR-00137728
        Set<ID> ownerIds = new Set<ID>();
        
        
       for(Case objCase: caseList){
            ownerIds.add(objCase.OwnerId);
        }
        //Start CR-00137728 - Added Null Check As a part of reducing SOQL Count.
        if(ownerIds !=null && ownerIds.size()>0){
            ownerId_UserObj = new Map<ID,User>([select id,GSS_Manager__c, Email,Name,Extension from user where id in:ownerIds]);
        }
        //END CR-00137728 - Added Null Check As a part of reducing SOQL Count.
        for(Case objCase: caseList){            
                thisOwner = ownerId_UserObj.containsKey(objCase.OwnerID)?ownerId_UserObj.get(objCase.OwnerID):null; //CR-00137728
                if(thisOwner != null) {
                   objCase.GSS_Owner_Email1__c = thisOwner.Email;
                   //CR-00135349 - Added if condition to process case records which are not having record typpe as renewal operations
                   if(!objCase.RecordTypeId.equals(renewalsRecordType)){
                       objcase.GSS_Owner_Manager__c=thisOwner.GSS_Manager__c;
                   }
                   objCase.Case_Owner_Name__c = thisOwner.Name;//CR-00011952
                   objCase.TSE_Extension__c = thisOwner.Extension;//CR-00013752
                }
                else
                {
                    objCase.GSS_Owner_Email1__c = null;
                    objCase.Case_Owner_Name__c =null;
                    objCase.TSE_Extension__c = null;
                    //CR-00135349 - Added if condition to process case records which are not having record typpe as renewal operations
                    if(!objCase.RecordTypeId.equals(renewalsRecordType)){
                         objcase.GSS_Owner_Manager__c= null; //CR-00030433 Update Case Owner Managers Field if case owner is a Queue
                    }
                }
            
        }
    }

    public static void updateManagerEmail(List<Case> caseList){
        User thisOwner;
        Set<ID> ownerIds = new Set<ID>();
        for(Case objCase: caseList){
            ownerIds.add(objCase.OwnerId);
        }
  Map<ID,User> ownerIdCaseManagerEmail = new Map<ID,User>([select id,Email,GSS_Manager__c, GSS_Manager__r.Email from user where id in:ownerIds]);
        //Added for QUF 101 Flow - Nilanjana START
         System.debug('QUF 101 Flag is true');
        if(!recursive.RS2RenewalQuoteFlag){
              System.debug('QUF 101 Flag is false');
            ownerIdCaseManagerEmail = new Map<ID,User>([select id,Email,GSS_Manager__c, GSS_Manager__r.Email from user where id in:ownerIds]);
        }
        else{
            ownerIdCaseManagerEmail = new Map<ID,User>();
        }
        //Added for QUF 101 Flow - Nilanjana STOP
        for(Case objCase: caseList){
            
                system.debug('+++++++444444444444444++++++');
                thisOwner = ownerIdCaseManagerEmail.get(objCase.OwnerID);
                if(thisOwner != null) {
                    objCase.GSS_Owner_Manager_Email__c = thisOwner.GSS_Manager__r.Email;
                    objCase.GSS_Owner_Email__c = thisOwner.Email;
                    //CR-00135349 - Added if condition to process case records which are not having record typpe renewal operations
                    if(!objCase.RecordTypeId.equals(renewalsRecordType)){
                        objcase.GSS_Owner_Manager__c = thisOwner.GSS_Manager__c;
                    }
                } else {
                    objCase.GSS_Owner_Manager_Email__c = null;
                    objCase.GSS_Owner_Email__c = null;
                    //CR-00135349 - Added if condition to process case records which are not having record typpe renewal operations
                    if(!objCase.RecordTypeId.equals(renewalsRecordType)){
                        objCase.GSS_Owner_Manager__c = null;
                    }
                }
        }
    }
    
    //CR-00131921 GSS - July Release Start
    public static void BI_UpdateBusinessUnit(List<Case> caseList){
        User thisOwner;
        Set<ID> ownerIds = new Set<ID>();
        Id customerSupportId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_LIC').Record_Type_ID__c); 
        Id csAdminId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_CS').Record_Type_ID__c); 
        for(Case objCase: caseList){
            ownerIds.add(objCase.OwnerId);
        }
        Map<ID,User> ownerId_UserObj = new Map<ID,User>([select id,GSS_Business_Unit__c from user where id in:ownerIds]);
        for(Case objCase: caseList){
            thisOwner = ownerId_UserObj.get(objCase.OwnerID);
            if(thisOwner != null) {
                if((!objCase.isClosed) && thisOwner.GSS_Business_Unit__c!= null && thisOwner.GSS_Business_Unit__c !='') //CR-00131921 //CR-00135328 removed record type check.
                    objCase.Gss_Business_unit__c =thisOwner.GSS_Business_Unit__c; 
            }
        }
    }
    
    public static void BU_UpdateBusinessUnit(List<case> CaseList,Map<id,case> oldMap){
        Id customerSupportId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_LIC').Record_Type_ID__c); 
        Id csAdminId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_CS').Record_Type_ID__c); 
        Set<ID> queueIds = new Set<ID>();
        set<ID> userIds = new Set<ID>();
        Map<ID,String> queueNamesMap = new Map<ID,String>(); 
        Map<Id,String> userBu_Map = new Map<id,string>();
        Map<Id,String> userNameMap = new MAP<Id,String>();
        Map<ID,Group> caseQueueIds;
        Map<ID,User> userMaps;
        String cS_S = label.GSS_BUsiness_Unit_values_CS_S;
        String cS_A = Label.GSS_Business_Unit_values_CS_A;
        //Start 29-Mar-2016   Jyolsna   CR-00137286 Variable Declaration
        String cS_EDU = Label.GSS_Business_Unit_values_CS_EDU;
        //End 29-Mar-2016     Jyolsna   CR-00137286 Variable Declaration
        
        for(Case objCase: caseList){
            if(string.ValueOf(objCase.OwnerId).startsWith('00G'))
                queueIds.add(objCase.OwnerId);
            if(String.ValueOf(objCase.OwnerId).startswith('005'))
                userIds.add(objCase.OwnerId);
        }
        
        for(case cRec : oldMap.Values()){
            if(string.ValueOf(cRec.OwnerId).startsWith('00G'))
                queueIds.add(cRec.OwnerId);
            if(String.ValueOf(cRec.OwnerId).startswith('005'))
                userIds.add(cRec.OwnerId);
        }
        //START CR-00135394  -  Modified If Condition added for reducing the no. of SOQL
        if(queueIds!=null && queueIds.size() > 0){
            caseQueueIds = new Map<Id,Group>([select Id,Name from Group where type='Queue' and id in:queueIds]);
        }
        if(userIds!=null && userIds.size() > 0){
            userMaps = new Map<Id,User>([select GSS_Business_Unit__c,Name from User where id in:userIds]);
        }
        //END CR-00135394  -  Modified If Condition added for reducing the no. of SOQL
        if(caseQueueIds!=null){
            for(Group g:caseQueueIds.values()){
                queueNamesMap.put(g.id,g.Name);         
            }
        }
        if(userMaps!=null){
            for(User u:userMaps.values()){
                userBu_Map.put(u.id,u.GSS_Business_Unit__c);
                userNameMap.put(u.id,u.Name);
            }
        }
       
        Map<String,GSS_Queues_business_Unit__c> qNameMap = GSS_Queues_business_Unit__c.getall();
        for(case cObj :CaseList){                        
            // removed recordtype check for CR-00135328
                if(cObj.Ownerid != null &&  string.ValueOf(cObj.ownerId).startsWith('00G')){
                    //HotFix CR-00135228 - Start
                    if(qNameMap!= null && queueNamesMap!= null && queueNamesMap.containsKey(cObj.Ownerid) && qNameMap.containsKey(queueNamesMap.get(cObj.Ownerid)) && qNameMap.get(queueNamesMap.get(cObj.Ownerid)).Business_Unit__c != null && qNameMap.get(queueNamesMap.get(cObj.Ownerid)).Business_Unit__c!='')
                        cObj.GSS_Business_unit__c = string.ValueOf(qNameMap.get(queueNamesMap.get(cObj.Ownerid)).Business_Unit__c);
                    else{
                        cObj.GSS_Business_unit__c = '';
                    }
                    //HotFix CR-00135228 - End
                }
                if(cObj.ownerId!= null && userBu_Map!=null && string.ValueOf(cObj.ownerId).startsWith('005'))
                    if(cObj.ownerId != oldMap.get(cObj.id).OwnerId)
                        cObj.GSS_Business_unit__c = string.ValueOf(userBu_Map.get(cObj.ownerid));
                    
                if(oldMap!= null && oldMap.containsKey(cObj.id) && (oldMap.get(cObj.id).GSS_Business_unit__c != null) && String.ValueOf(oldMap.get(cObj.id).GSS_Business_unit__c).contains(cS_S) && cObj.ownerId != null){
                    if(string.ValueOf(cObj.ownerId).startsWith('00G')){
                        if(qNameMap != null && queueNamesMap!= null && queueNamesMap.containsKey(cObj.Ownerid) && queueNamesMap.get(cObj.Ownerid) != null && qNameMap.containskey(queueNamesMap.get(cObj.Ownerid)) && qNameMap.get(queueNamesMap.get(cObj.Ownerid)) != null && qNameMap.get(queueNamesMap.get(cObj.Ownerid)).Business_Unit__c != null && qNameMap.get(queueNamesMap.get(cObj.Ownerid)).Business_Unit__c != '' && string.ValueOf(qNameMap.get(queueNamesMap.get(cObj.Ownerid)).Business_Unit__c).contains(cS_A)){
                            cObj.Transferred_Date_Time__c = system.now();
                            if(String.ValueOf(oldMap.get(cObj.id).ownerId).startsWith('00G'))
                                cObj.Transferred_From__c = queueNamesMap.get(oldMap.get(cObj.id).ownerId);
                            if(String.ValueOf(oldMap.get(cObj.id).ownerId).startsWith('005'))
                                cObj.Transferred_From__c = userNameMap.get(oldMap.get(cObj.id).ownerId);
                            cObj.Transferred_From_BU__c = oldMap.get(cObj.id).GSS_Business_unit__c;                     
                            cObj.Transferred_By__c = userInfo.getUserId();                  
                        }
                    }
                    if(string.ValueOf(cObj.ownerId).startsWith('005')){
                        if(UserMaps!= null && oldMap!=null && UserMaps.containsKey(cObj.ownerId) && UserMaps.get(cObj.ownerId).GSS_Business_Unit__c != null && String.ValueOf(UserMaps.get(cObj.ownerId).GSS_Business_Unit__c).contains(cS_A)){
                            cObj.Transferred_Date_Time__c = system.now();
                            if(String.ValueOf(oldMap.get(cObj.id).ownerId).startsWith('00G'))
                                cObj.Transferred_From__c = queueNamesMap.get(oldMap.get(cObj.id).ownerId);
                            if(String.ValueOf(oldMap.get(cObj.id).ownerId).startsWith('005'))
                                cObj.Transferred_From__c = userNameMap.get(oldMap.get(cObj.id).ownerId);
                            cObj.Transferred_From_BU__c = oldMap.get(cObj.id).GSS_Business_unit__c;                     
                            cObj.Transferred_By__c = userInfo.getUserId();
                        }
                    }
                }
                //Start 29-Mar-2016   Jyolsna   CR-00137286 - Transfer logic update for '*CS-EDU"' -> '<blank>'
                if(oldMap!= null && oldMap.containsKey(cObj.id) && ((oldMap.get(cObj.id).GSS_Business_unit__c == null) || ((oldMap.get(cObj.id).GSS_Business_unit__c != null) && String.ValueOf(oldMap.get(cObj.id).GSS_Business_unit__c) != cObj.GSS_Business_unit__c)) && cObj.GSS_Business_unit__c != null && String.ValueOf(cObj.GSS_Business_unit__c).contains(cS_EDU) ){
                            cObj.Transferred_Date_Time__c = null;
                            cObj.Transferred_From__c = '';
                            cObj.Transferred_From_BU__c = '';                     
                            cObj.Transferred_By__c = null;  
                }
                //CR-00139004: Modified condition. put isBlank method
                if(oldMap!= null && oldMap.containsKey(cObj.id) && (oldMap.get(cObj.id).GSS_Business_unit__c != null) && String.ValueOf(oldMap.get(cObj.id).GSS_Business_unit__c).contains(cS_EDU) && String.isBlank(cObj.GSS_Business_unit__c) ){
                    cObj.Transferred_Date_Time__c = system.now();
                    if(String.ValueOf(oldMap.get(cObj.id).ownerId).startsWith('00G'))
                        cObj.Transferred_From__c = queueNamesMap.get(oldMap.get(cObj.id).ownerId);
                    if(String.ValueOf(oldMap.get(cObj.id).ownerId).startsWith('005'))
                        cObj.Transferred_From__c = userNameMap.get(oldMap.get(cObj.id).ownerId);
                    cObj.Transferred_From_BU__c = oldMap.get(cObj.id).GSS_Business_unit__c;                     
                    cObj.Transferred_By__c = userInfo.getUserId();
                }
                //End 29-Mar-2016     Jyolsna   CR-00137286 - Transfer logic update for '*CS-EDU"' -> '<blank>'   
        
    
        }
    }
    //CR-00131921 GSS - July Release End 
    
    public static void updateCaseOwnerManagerEmail(List<Case> caseList){
        Map<String,ID> caseIdCaseOwnerIdMap = new Map<String,ID>();
        Map<ID, User> ownerIdUser = new Map<ID, User>();
        Set<ID> ownerIds = new Set<ID>();
        List<Case>updateCaseList = new List<Case>();
        System.debug('Class called**********************');
        for(Case objCase: caseList){
                caseIdCaseOwnerIdMap.put(objCase.CaseNumber, objCase.OwnerId);
                ownerIds.add(objCase.OwnerId);
        }
        
        if(ownerIds != null && ownerIds.size()>0){
            for(User objUser : [select id, Email, GSS_Manager__r.Email from user where id in:ownerIds]){
                if(objUser.GSS_Manager__r.Email != null)
                    ownerIdUser.put(objUser.id, objUser);
            }
        }
        
        for(Case objCase: caseList){
            
                String ownerId = caseIdCaseOwnerIdMap.get(objCase.CaseNumber);
                    if(ownerId != null && ownerId.startsWith('005')){
                        if(ownerIdUser.containsKey(ownerId))
                        {
                            objCase.GSS_Owner_Manager_Email__c = ownerIdUser.get(ownerId).GSS_Manager__r.Email;
                            objCase.GSS_Owner_Email__c = ownerIdUser.get(ownerId).Email;
                            //CR-00135349 - Added if condition to process case records which are not having record typpe renewal operations
                            if(!objCase.RecordTypeId.equals(renewalsRecordType)){
                                objcase.GSS_Owner_Manager__c = ownerIdUser.get(ownerId).GSS_Manager__c;
                            }
                        }
                    }else{
                        objCase.GSS_Owner_Manager_Email__c = null;
                        objCase.GSS_Owner_Email__c = null;
                        //CR-00135349 - Added if condition to process case records which are not having record typpe renewal operations
                        if(!objCase.RecordTypeId.equals(renewalsRecordType)){
                            objcase.GSS_Owner_Manager__c = null;
                        }
                    }
        }
     }

/*********************************************************************************************** 
     * Method Name       : updateCommitDefaulter
     * Author            : Accenture (Nitin Bhalla)
     * @ Param           : List<Case> caseList , String stat 
     * @ Return          : Void
     * Description       : CR-00028703 This method is update the name of Commit Defaulter
     ***********************************************************************************************/
    
      
      public static void updateCommitDefaulter(List<Case> caseList , String isstatus){
        
        //CR-00035683 Starts
        if (isstatus == 'upd'){
            Map<id,case> uMap = new Map<id,case>([select id ,Case.owner.Name from case where id in :caseList]);
            if(!uMap.isEmpty()){
                for(Case objCase: caseList){
                    if(objCase.Commit_Defaulter__c != null && objCase.GSS_First_Response_Due_Date__c != null){
                        if (  (objCase.Commit_Defaulter__c != string.valueof(uMap.get(objCase.ID).owner.name)   )&& objCase.GSS_First_Response_Due_Date__c >=  datetime.now() ){
                        
                            objCase.Commit_Defaulter__c = string.valueof(uMap.get(objCase.ID).owner.name) ;
                            
                        }
                    }
                }
            }
        }
        //CR-00035683 Ends
    }
    
    
     public static void updateCommitDefaulter(List<Case> caseList  ){
        
        for(Case objCase: caseList){
            objCase.Commit_Defaulter__c = userinfo.getName();
        }
    }
         // CR-00028703 ends
    /*********************************************************************************************** 
     * Method Name       : inserCaseOwnerManagerEmail
     * Author            : Accenture (Harish Patkar)
     * JIRA #            : PP-18436, Visualforce- Case Assignment VisualForce Results Page
     * @ Param           : Set<Id>, List<Id> 
     * @ Return          : Void
     * Description       : This method is update the Owner Manager Email on Case and it is called from Trigger :: GSS_AfterInsertUpdateOwnerManagerEmail.
     ***********************************************************************************************/

    public static List<Case> insertCaseOwnerManagerEmail(List<Case> caseList){
        Map<String,ID> caseIdCaseOwnerIdMap = new Map<String,ID>();
        Map<ID,String> ownerIdCaseManagerEmail = new Map<ID,String>();
        Set<ID> ownerIds = new Set<ID>();
        List<Case>updateCaseList = new List<Case>();
        List<ID> onUpdateCaseIds = new List<ID>();//sud code
          for(Case objCase: caseList){
                caseIdCaseOwnerIdMap.put(objCase.CaseNumber, objCase.OwnerId);
                ownerIds.add(objCase.OwnerId);
                onUpdateCaseIds.add(objCase.Id);
            }
            System.debug('ownerIds list*********'+ownerIds);
            if(ownerIds != null && ownerIds.size()>0){
                for(User objUser : [select id, GSS_Manager__r.Email from user where id in: ownerIds]){
                    if(objUser.GSS_Manager__r.Email != null && objUser.GSS_Manager__r.Email != '')
                        ownerIdCaseManagerEmail.put(objUser.id, objUser.GSS_Manager__r.Email);
                }
            }
        System.debug('ownerIdCaseManagerEmail *********'+ownerIdCaseManagerEmail);
    //sud code starts 2
        for(Case objCase : [select id, CaseNumber, GSS_Owner_Manager_Email__c from case where id in: onUpdateCaseIds]){

                 String ownerId = caseIdCaseOwnerIdMap.get(objCase.CaseNumber);
                //System.debug('ownerId*******'+ownerId);
                if(ownerId != null && ownerId.startsWith('005')){
                    objCase.GSS_Owner_Manager_Email__c = ownerIdCaseManagerEmail.get(ownerId);
                    //System.debug('objCase.GSS_Owner_Manager_Email__c***'+objCase.GSS_Owner_Manager_Email__c);
                }else{
                        objCase.GSS_Owner_Manager_Email__c = null;
                }
                updateCaseList.add(objCase);
        }
         return updateCaseList;              
    }
    
    public static void BU_MgrEmail(List<Case> ChangedGSSCases) {
        updateManagerEmail(ChangedGSSCases);     
    }
    public static void BU_MgrEmail(List<Case> GSSCases, Map<ID,Case> oldMap) {
        updateManagerEmail(GSS_UpdateWPTriggerHelper.ownerChange(GSSCases,oldMap));     
    } 
    public static void BI_MgrEmail(List<Case> GSSCases) {
        updateManagerEmail(GSSCases);
    }
    public static List<Case> AI_MgrEmail(List<Case> GSSCases) {
        //updateManagerEmail(GSSCases);
        
        //if(GSSCases.size()>0){
              GSS_UtilityClass.isManagerEmailUpdate1 = true;
              return GSS_CaseOwnerManager.insertCaseOwnerManagerEmail(GSSCases);
       //}        
    }
    
/***********************************************************************************************      
 * Method Name      : updateTSEOwnerForEscalationCas    
 * Author           : Chaitanya Varma    
 * CR #             : CR-00008628
 * @ Return         : Void     
 * Description      : For the Re-Assignment cases when the owner is changed the Escalated request owner has to update as TSM of the TSE.           
 ***********************************************************************************************/    
 public static void updateTSEOwnerForEscalationCase(List<Case> caseList, Map<ID,Case> oldMap){   
     Set<ID> ownerIds    = new Set<ID>();      
     Set<Id> ReqCaseIds  = new Set<Id>();     
     Map<Id,Id> caseIdNewOwnerIdMap=new Map<Id,Id>();      
     
     for(Case objCase: caseList){            
         Id oldOwnerId = oldMap.get(objCase.Id).OwnerId;      
         if((objCase.OwnerId != oldOwnerId)){               
             ownerIds.add(objCase.OwnerId);               
             ReqCaseIds.add(objCase.Id);                   
             caseIdNewOwnerIdMap.put(objCase.Id,objCase.OwnerId );   
         }
     }             

     Id ERRecordTypeId =[Select Id from RecordType where name='Escalation Request' and SObjectType='GSS_Request__c'].Id;   

     List<GSS_Request__c> lstRequest = new List<GSS_Request__c>([Select Id,GSS_Case_Number__c, GSS_Case_Owner_Manager__c from GSS_Request__c where GSS_Case_Number__c in :ReqCaseIds and GSS_Alert_Level__c='1- Watchlist' and RecordTypeId=:ERRecordTypeId]); 
     
     System.debug('lstRequest.size()'+lstRequest.size());  
     
     Map<ID,User> userIdMap = new Map<ID,User>([select id, GSS_Manager__c  from user where id in:ownerIds]);      
     
     System.debug('userIdMap.size()'+userIdMap.size());               

     if ( lstRequest != null && lstRequest.size()> 0 && userIdMap !=null & userIdMap.size()>0 )       
     {      
         for(GSS_Request__c gssReqObj : lstRequest)
         {            
             Id ownerId=caseIdNewOwnerIdMap.get(gssReqObj.GSS_Case_Number__c);            

             User u=userIdMap.get(ownerId);               

             if(u.GSS_Manager__c!=null)
             {         
                 gssReqObj.OwnerId=u.GSS_Manager__c;       
             }      
             update lstRequest;    
        }   
     }
 } 
 /***********************************************************************************************      
 * End of the CR-00008628
 ***********************************************************************************************/    
}
