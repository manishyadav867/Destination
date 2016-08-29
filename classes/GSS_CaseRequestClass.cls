/** Class Name      : GSS_CaseRequestClass
  * Author            : Accenture - IDC (Harish Patkar)
  * JIRA #            : PP-17997
  * JIRA Description  : Create custom trigger to set Case De-escalated to True on Case 
  * Detail Description: This trigger execute when a Request is inserted.
  *                     This will update the Case Status.  
  *                             
  * 2/29/2012        Accenture IDC   Added Error handling code in catch block for CR-00008898   
  * 4/26/2012        Accenture IDC   Updated the method 'updateCaseStatusForRequest' for CR-00011784. 
  * 14-SEP-2013      Nierrbhayy      Added record type for Licensing Escalataions CR-00052193
  * 14-JUN-2016     Sakshi Suri     Added method to update PR number and Status from Primary Bug from case CR-00137171
  * 5-JUL-2016     Sneha Rathi     Added method to update Status on PR change CR-00137171
  * 2-Aug-2016      Jyolsna         Added method to insert record in objecttrackhistory for tracking change in 'current status' field : CR-00140215
  * 03-AUG-2016     Sneha Rathi         CR-00138663 : Added default contacts for escalation request
  **/

public class GSS_CaseRequestClass {
    
    public static void updateCaseStatusForRequest(List<GSS_Request__c> lstRequest){

        try{

            /* defining variables used in the class */
            Map<Id,Case> mapCases = new Map<Id,Case>();
            Set<Id> setECaseIds = new Set<Id>();
            Set<Id> setDECaseIds = new Set<Id>();
//Added below map variable for CR-00011784
            Map<Id, String> mapECaseAlert = new Map<Id, String>();
            // Defect BUG-00005881
            Set<Id> pendingCaseIds = new Set<Id>();
            Set<Id> nonPendingCaseIds = new Set<Id>();
            Id recTypeId = null;
            
            // Update by: Sneha - Moved the SOQL out of loop - Start
            Map<Id, Integer> mapRequestCount = new Map<Id, Integer>();
            Set<Id> setCaseNumber = new Set<Id>();
            for(GSS_Request__c gssReqObj : lstRequest)
            {
                setCaseNumber.add(gssReqObj.GSS_Case_Number__c);
            }
            for(AggregateResult ar : [Select GSS_Case_Number__c, count(id) from GSS_Request__c where GSS_Case_Number__c in :setCaseNumber and GSS_Status__c = 'Approved' group by GSS_Case_Number__c])
            {
                mapRequestCount.put((Id)ar.get('GSS_Case_Number__c'), (Integer)ar.get('expr0'));
            }
            // Update by: Sneha - Moved the SOQL out of loop - End
    
            /* collect the Approved and De-Escalated Cases Id  */
            for(GSS_Request__c gssReqObj : lstRequest) {
                // Update by: Sneha - Moved the SOQL out of loop - Start
                //Integer requestCount = [Select count() from GSS_Request__c where GSS_Case_Number__c = :gssReqObj.GSS_Case_Number__c and GSS_Status__c = 'Approved'];
                Integer requestCount = (mapRequestCount.get(gssReqObj.GSS_Case_Number__c) != null)? mapRequestCount.get(gssReqObj.GSS_Case_Number__c) : 0;
                // Update by: Sneha - Moved the SOQL out of loop - End
                if ( gssReqObj.GSS_Case_Number__c != null ) {               
                    if( gssReqObj.GSS_Status__c == 'Approved' ) {
                        setECaseIds.add(gssReqObj.GSS_Case_Number__c); 
//Addedd below statement for CR-00011784.                     
                        mapECaseAlert.put(gssReqObj.GSS_Case_Number__c, gssReqObj.GSS_Alert_Level__c);                      
                    } else {
                        // removed the criteria for fixing BUG-00005782
                        //else if((gssReqObj.GSS_Status__c == 'De-Escalated') && gssReqObj.GSS_Case_Number__c != null )
                        if ( requestCount == 0 )
                            setDECaseIds.add(gssReqObj.GSS_Case_Number__c);                     
                    }
                    
                    // Defect BUG-00005881
                    if ( gssReqObj.GSS_Status__c == 'Pending'  ) {
                        pendingCaseIds.add(gssReqObj.GSS_Case_Number__c);
                    } else {
                        nonPendingCaseIds.add(gssReqObj.GSS_Case_Number__c);
                    }
                }
            }           
            /* get all the Cases objects that we need to update   */         
//Added GSS_Esc_Alert_Level__c in the query for CR-00011784.         
            mapCases.putAll([Select Id, Status, GSS_Esc_Alert_Level__c  from Case where Id in :setECaseIds or 
                                        Id in :setDECaseIds or Id in :pendingCaseIds or Id in :nonPendingCaseIds]);
            
            /* Set the Case Status to Escalated and put into map */
            for(Id CaseId :setECaseIds)
            {
                mapCases.get(CaseID).status = 'Escalated';
//Addedd below statement for CR-00011784. 
                mapCases.get(CaseID).GSS_Esc_Alert_Level__c = mapECaseAlert.get(CaseId);                
            }
            
            /* Set the Case Status to Open and put into map  */
            for(Id CaseId :setDECaseIds)
            {
              system.debug('CaseIdCaseIdCaseId -- '+CaseId);
                mapCases.get(CaseID).status = 'Open';
            }
            
            // Defect BUG-00005881
            for(Id CaseId :pendingCaseIds)
            {
                mapCases.get(CaseId).GSS_Pending_Escalation__c = true;
            }

            for(Id CaseId :nonPendingCaseIds)
            {
                mapCases.get(CaseId).GSS_Pending_Escalation__c = false;
            }
            /* Update all the Cases with new Status */
            system.debug('----------new1-----'+mapCases.values()); 
            update mapCases.values();
            system.debug('End GSS_CaseRequestClass ...');
       }
       catch(Exception ex){
           //system.debug('GSS_CaseRequestClass : - '+ex.getMessage());
           GSS_UtilityClass.errorObjectInsertionMethod('GSS_Request__c', 'High', 'Unable to update the Case Status for GSS_Request__c', 'GSS_CaseRequestClass.class', 'Pending', 'Class');
           //Added Error handling code in catch block for CR-00008898
           CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_Request__c', 'GSS_CaseRequestClass');
           //End of code for CR-00008898 
       }
    }   
    
    /*
    
    Request Object Field                        GSS S1 Notification Recipients - Custom Setting 
    
    Global Account Manager (GAM)                GSS S1 Notification Recipients - Global Account Manager (GAM)
    VP Sales Global accounts                    GSS S1 Notification Recipients - VP Sales Global accounts
    VP Sales – Strategic Accounts               GSS S1 Notification Recipients - VP Sales – Strategic Accounts
    Global Director Sales Engineering           GSS S1 Notification Recipients - Global Director Sales Engineering
    VP Technical                                GSS S1 Notification Recipients - VP Technical
    VP R&D                                      GSS S1 Notification Recipients - VP R&D
    SR VP Global Support Services               GSS S1 Notification Recipients - - SR VP Global Support Services
    Chief Operating Officer                     GSS S1 Notification Recipients - Chief Operating Officer
    EVP                                         GSS S1 Notification Recipients - EVP
    CEO                                         GSS S1 Notification Recipients - CEO
    Support Account Manager (SAM)               Case Owner (If not a queue)
    Technical Account Manager (TAM)             Pull the user's email from the Account Team member having "Technical Account Manager"
    Support Center Director                     GSS S1 Notification Recipients - Pull the email that matches following conditions:  Case.Support/Center = GSS S1 Notification Recipients.Center and GSS S1 Notification Recipients.Name contains "Center Director"
    Case Owner Manager                          Pull the user's email that is the Case Owner's manager as specified in the 'GSS Manager' field on the User Record.  Do not pull this value if it’s the same email pulled from previous field "Support Center Director"
    Case Owner Manager 2                        Pull the user's email that is the Case Owner Manager's Manager as specified in the 'GSS Manager' field on the User Record.  Do not pull this value if it’s the same email pulled from previous field "Support Center Director"
    Case Owner Manager 3                        Pull the user's email that is the Case Owner Manager 2's Manager as specified in the 'GSS Manager' field on the User Record.  Do not pull this value if it’s the same email pulled from previous field "Support Center Director"
    Support Center Reg. Escalation Mgr (REM)    GSS S1 Notification Recipients - Pull the email that matches following conditions:  Case.Support/Center = GSS S1 Notification Recipients.Center and GSS S1 Notification Recipients.Name contains "Reg. Escalation Mgr (REM)"
    Global Escalation Manager (GEM)             GSS S1 Notification Recipients - Global Escalation Manager (GEM)

    */
    public static void updateS1NotificationEmails(List<GSS_Request__c> listWRRequest) {
        
        List<Id> caseIds = new List<Id>();
        for(GSS_Request__c request : listWRRequest)
            caseIds.add(request.GSS_Case_Number__c);
            
        Map<Id, Case> caseMap = new Map<Id, Case>([Select AccountId, Id, CaseNumber, OwnerId, Owner.Type, GSS_Support_Customer_Region__c from Case where Id in :caseIds]);
        Set<String> centerDirectorEmails = new Set<String>();
         
        
        Map<String, GSS_S1_Notification_Recipients__c> recipients = GSS_S1_Notification_Recipients__c.getAll();

        for(GSS_Request__c request : listWRRequest) {

            if ( request.S1_Red_Alert_Notifications__c == 'Yes' ) {
                
                Case caseObj = caseMap.get(request.GSS_Case_Number__c);
                if ( caseObj != null ) {
                    
                    request.GSS_VP_Sales_Global_Accounts__c = recipients.get('VP Sales Global accounts').Recipient__c;
                    request.GSS_VP_Sales_Strategic_Accounts__c = recipients.get('VP Sales – Strategic Accounts').Recipient__c;
                    request.GSS_Global_Director_Sales_Engineering__c = recipients.get('Global Director Sales Engineering').Recipient__c;
                    request.GSS_VP_Technical__c = recipients.get('VP Technical').Recipient__c;
                    request.GSS_VP_R_D__c = recipients.get('VP R&D').Recipient__c;
                    request.GSS_SR_VP_Global_Support_Services__c = recipients.get('SR VP Global Support Services').Recipient__c;
                    request.GSS_Chief_Operating_Officer__c = recipients.get('Chief Operating Officer').Recipient__c;
                    request.GSS_EVP__c = recipients.get('EVP').Recipient__c;
                    request.GSS_CEO__c = recipients.get('CEO').Recipient__c;
                    request.Global_Escalation_Manager_GEM__c = recipients.get('Global Escalation Manager (GEM)').Recipient__c;
                
                    if ( caseObj.AccountId != null ) {
                        List<AccountTeamMember> members = [SELECT TeamMemberRole, AccountId, UserId, User.Email FROM AccountTeamMember where accountId = :caseObj.AccountId];
                        for( AccountTeamMember member : members ) {
                            if ( member.TeamMemberRole == 'Technical Account Manager' )
                                request.GSS_Technical_Account_Manager_TAM__c = member.User.Email;
                            else if ( member.TeamMemberRole == 'Global Account Manager' )
                                request.GSS_Global_Account_Manager_GAM__c = member.User.Email;
                        }   
                    }

                    Set<String> recipientKeys = recipients.keySet();
                    for(String key : recipientKeys) {
                        if ( key.contains('center director') ) {
                            if ( caseObj.GSS_Support_Customer_Region__c != null && 
                                    recipients.get(key).Center__c != null && 
                                    caseObj.GSS_Support_Customer_Region__c.contains(recipients.get(key).Center__c))
                                request.GSS_Support_Center_Director__c = recipients.get(key).Recipient__c;
                            centerDirectorEmails.add(recipients.get(key).Recipient__c);
                        }
                        if ( key.contains('reg. escalation mgr (rem)') && 
                                caseObj.GSS_Support_Customer_Region__c != null && 
                                recipients.get(key).Center__c != null && 
                                caseObj.GSS_Support_Customer_Region__c.contains(recipients.get(key).Center__c))
                            request.GSS_Support_Center_Regional_Esc_Mgr__c = recipients.get(key).Recipient__c;                        
                    }       

                    User owner = [Select Id, Email, GSS_Manager__c, GSS_Manager__r.Email From User where Id = :caseObj.OwnerId];
                    if ( owner != null && !centerDirectorEmails.contains(owner.GSS_Manager__r.Email))
                        request.GSS_Case_Owner_Manager__c = owner.GSS_Manager__r.Email;

                    if ( caseObj.Owner.Type == 'User')
                        request.GSS_Support_Account_Manager_SAM__c = owner.Email;                    
                    
                    if ( owner.GSS_Manager__c != null ) {
                        User ownerManager2 = [Select Id, Email, GSS_Manager__c, GSS_Manager__r.Email From User where Id = :owner.GSS_Manager__c];
                        if ( ownerManager2 != null && !centerDirectorEmails.contains(ownerManager2.GSS_Manager__r.Email))
                            request.GSS_Case_Owner_Manager_2__c = ownerManager2.GSS_Manager__r.Email;
    
                        if ( ownerManager2.GSS_Manager__c != null ) {
                            User ownerManager3 = [Select Id, Email, GSS_Manager__c, GSS_Manager__r.Email From User where Id = :ownerManager2.GSS_Manager__c];
                            if ( ownerManager3 != null && !centerDirectorEmails.contains(ownerManager3.GSS_Manager__r.Email))
                                request.GSS_Case_Owner_Manager_3__c = ownerManager3.GSS_Manager__r.Email;
                        }
                    }
                }
            }
        }
    }
    
  /* 
   * Method Name      : populateEntitlementNameOnRequest
   * Author           : Accenture - IDC (Harish Patkar)
   * CR #             : CR-00004411
   * Description      : This method is used to populate the Entitlement Name on Request Object from the associated Case.
   *                    This functionlity works only when a Request is created.         
   **/
     
    public static void populateEntitlementNameOnRequest(List<GSS_Request__c> lRequests){
        Map<Id,List<GSS_Request__c>> caseId_reqObj = new Map<Id,List<GSS_Request__c>>();
        
            for (GSS_Request__c oRequest : lRequests)
            {
                List<GSS_Request__c> tempreqObj = new List<GSS_Request__c>();
                if(caseId_reqObj.containsKey(oRequest.GSS_Case_Number__c))
                {
                    tempreqObj = caseId_reqObj.get(oRequest.GSS_Case_Number__c);
                }
                tempreqObj.add(oRequest);
                caseId_reqObj.put(oRequest.GSS_Case_Number__c,tempreqObj);
            }
            Map<Id,Case> caseId_caseObj = new Map<Id,Case>([Select Id,Entitlement.Name from Case where Id in :caseId_reqObj.KeySet()]);
            List<GSS_Request__c> tempreqObj = new List<GSS_Request__c>();
            for(Case c : caseId_caseObj.Values())
            {
                for(GSS_Request__c r : caseId_reqObj.get(c.id))
                {
                        r.GSS_Entitlement_Name__c = c.Entitlement.Name;
                }
            }
     }
   
   /* 
    * Method Name      : validateEscalatedCaseRequest
    * Author           : Accenture - IDC (Harish Patkar)
    * CR #             : CR-00005164
    * Description      :        
    **/
     
     public static void validateEscalatedCaseRequest(Case ocase){
        // Added condition for Licensing escalation record type for CR-00052193    
        if(Record_Type_Settings__c.getValues('GSS_REQ_ER') != null && Record_Type_Settings__c.getValues('GSS_REQ_LER') != null && ocase !=null ){
            //Created a set of IDs for CR-00052193
            Set <Id> recTypeSet = new Set<Id>();
            Id escRecType =  Record_Type_Settings__c.getValues('GSS_REQ_ER').Record_Type_ID__c;
            Id licEscRecType = Record_Type_Settings__c.getValues('GSS_REQ_LER').Record_Type_ID__c;
            recTypeSet.add(escRecType);
            recTypeSet.add(licEscRecType);
            
            GSS_Request__c oRequest = null;
            try{
                //CR-00052193 changed "RecordTypeId in"
                oRequest = [Select Id,Name,GSS_Status__c from GSS_Request__c where RecordTypeId in :recTypeSet AND GSS_Case_Number__c=:ocase.Id AND GSS_Status__c='Approved' limit 1];
            }catch(Exception e){ system.debug('***NO Escalation with Approved Status is found***');}
            if(oRequest!=null){ 
                throw new CaseStatusValidationException(' You have to de-escalate first Request with No. '+oRequest.Name+' , then you can change Case Status.');
                //oRequest.GSS_Status__c.addError('You have to de-escalate first Request with No. '+oRequest.Name+' , then you can change Case Status.');
            }
        }
    
     }
     
    /* 
     * Method Name      : isUserFromEscalatedProfile
     * Author           : Accenture - IDC (Harish Patkar)
     * CR #             : CR-00005164
     * Description      :        
     **/
     public static boolean isUserFromEscalatedProfiles(Id profileId){
        
        if(profileId != null){
            GSS_Case_Escalation_Excluded_Profile__c profileSetting = GSS_Case_Escalation_Excluded_Profile__c.getValues(profileId);
            if(profileSetting != null){
                if(profileSetting.Profile_Id__c != null && profileSetting.Profile_Id__c !=''){
                    system.debug('Profile '+profileSetting.Profile_Name__c+' is present in Custom Setting and eligible for this change.');
                    return true;
                }
                else{
                    //system.debug(' Profile with Profile Id '+profileId+' is NOT eligible for this change.');
                    return false;
                }
            }
            else{
                    //system.debug('Profile with Profile Id '+profileId+' is NOT eligible for this change.');
                    return false;
                }
        }
        
        return false;
     }
     /* 
   * Method Name      : populatePRStatusOnRequest
   * Author           : Sakshi Suri
   * CR #             : CR-00137171
   * Description      : This method is used to populate the PR Status on Request Object from the associated Case.
   *                    This functionlity works only when a Request is created.         
   **/
     
     public static void populatePRandStatusOnRequest(List<GSS_Request__c> lRequests){
     System.debug('enterned method>>>>Sakshi');
        Map<Id,List<GSS_Request__c>> caseId_reqObj = new Map<Id,List<GSS_Request__c>>();
        
            for (GSS_Request__c oRequest : lRequests)
            {
                List<GSS_Request__c> tempreqObj = new List<GSS_Request__c>();
                if(caseId_reqObj.containsKey(oRequest.GSS_Case_Number__c))
                {
                    tempreqObj = caseId_reqObj.get(oRequest.GSS_Case_Number__c);
                }
                tempreqObj.add(oRequest);
                caseId_reqObj.put(oRequest.GSS_Case_Number__c,tempreqObj);
            }
            Map<Id,GSS_Case_BugZilla__c> PRId_PRObj = new Map<Id,GSS_Case_BugZilla__c>([Select Id,GSS_Bug_Status__c,GSS_Primary_Bug__c,GSS_CaseNumber__c,GSS_Bug_ID__c,GSS_BugSFDCID__c,PRNumber__c from GSS_Case_BugZilla__c where GSS_CaseNumber__c in :caseId_reqObj.KeySet() and GSS_Primary_Bug__c = true]);
            List<GSS_Request__c> tempreqObj = new List<GSS_Request__c>();
            for(GSS_Case_BugZilla__c c : PRId_PRObj.Values())
            {
                for(GSS_Request__c r : caseId_reqObj.get(c.GSS_CaseNumber__c))
                {
                        r.PR_Number__c = c.PRNumber__c;
                        r.PR_Status__c = c.GSS_Bug_Status__c;
                }
            }
     }
     
   /* 
   * Method Name      : populatePRStatusOnRequest
   * Author           : Sneha Rathi, Accenture
   * CR #             : CR-00137171
   * Description      : This method is used to populate the PR Status on Request Object from the associated Case if the PR Number is changed        
   **/
     
    public static void populatePRandStatusOnRequestUpdate(List<GSS_Request__c> newRequests, Map<Id, GSS_Request__c> oldRequests){
        Map<Id,List<GSS_Request__c>> caseId_reqObj = new Map<Id,List<GSS_Request__c>>();
        Set<String> setPRNumber = new Set<String>();
        for (GSS_Request__c oRequest : newRequests)
        {
            if(oRequest.PR_Number__c != oldRequests.get(oRequest.id).PR_Number__c)
            {
                setPRNumber.add(oRequest.PR_Number__c);
            }
        }
        
        if(setPRNumber.size() > 0)
        {
            Map<String, String> mapBugzillaDetails = new Map<String, String>();
            List<GSS_Bugzilla__c> lstBugzilla = [Select GSS_Bug_ID__c, GSS_Bug_Status__c from GSS_Bugzilla__c where GSS_Bug_ID__c in :setPRNumber];
            for(GSS_Bugzilla__c bug : lstBugzilla)
            {
                mapBugzillaDetails.put(bug.GSS_Bug_ID__c, bug.GSS_Bug_Status__c);
            }
            for (GSS_Request__c oRequest : newRequests)
            {
                if(oRequest.PR_Number__c != oldRequests.get(oRequest.id).PR_Number__c)
                {
                    oRequest.PR_Status__c = mapBugzillaDetails.get(oRequest.PR_Number__c);
                }
            }
        }
            
     }
    //Start - 2-Aug-2016 - Jyolsna - CR-00140215
    public static void createCurrentStatusHist(List<GSS_Request__c> lstRequest,Map<Id,GSS_Request__c> oldMap){
        String LongTextArea = 'Long Text Area';
		String RequestObject = 'GSS_Request__c';
        Map<String,HistoryTrackingSetting__c> FieldTrackingMap = new Map<String,HistoryTrackingSetting__c>();
        List<HistoryTrackingSetting__c> FieldTrackingList = HistoryTrackingSetting__c.getall().values();
        List<ObjectHistoryTracker__c> trackList = new List<ObjectHistoryTracker__c>();
        if(FieldTrackingList != null && !FieldTrackingList.isEmpty()){
            for(HistoryTrackingSetting__c histTrack: FieldTrackingList){
                if(histTrack.Object__c == RequestObject && histTrack.DataType__c.contains(LongTextArea)){
                    FieldTrackingMap.put(histTrack.ApiFieldName__c,histTrack);
                }
            }
        }
        for(GSS_Request__c req: lstRequest){
            sObject reqnew = req;
            GSS_Request__c reqOld = oldMap.get(req.Id);
            sObject rold = reqOld; 
            if(FieldTrackingMap != null){
                for(String s: FieldTrackingMap.keySet()){
                    if(reqnew.get(s) != rold.get(s)){
                        ObjectHistoryTracker__c hT = new ObjectHistoryTracker__c();
                        hT.Object__c = RequestObject;
                        hT.ObjectId__c = req.id;
                        hT.CreatedBy__c = Userinfo.getUserId();
                        hT.CreatedDate__c = system.now();
                        hT.NewValueLong__c = String.valueof(reqnew.get(s));
                        hT.OldValueLong__c = String.valueOf(rold.get(s));
                        hT.Field__c = s;
                        trackList.add(hT);
                    }
                }
            }
        }
        if(trackList != null && !trackList.isEmpty()){
            Database.SaveResult[] resultList = Database.insert(trackList, false);
            CreateApexErrorLog.insertHandledExceptions(null, resultList, null, null, 'ApexClass', 'GSS_CaseRequestClass', 'createCurrentStatusHist');
        }
    }
    //End - 2-Aug-2016 - Jyolsna - CR-00140215
    
//CR-00138663 - Start - Insert the default Request Contacts
    public static void insertDefaultRequestContacts(List<GSS_Request__c> lstEscalationRequests)
    {
        List<Request_Contact__c> lstRequestContact = new List<Request_Contact__c>();
        List<GSS_Default_Escalation_Request_Contacts__c> lstDefaultReqContacts = GSS_Default_Escalation_Request_Contacts__c.getAll().values();
        if(lstDefaultReqContacts.size() > 0)
        {
            for(GSS_Request__c escReq : lstEscalationRequests)
            {
                for(GSS_Default_Escalation_Request_Contacts__c defaultReqContact : lstDefaultReqContacts)
                {
                    List<String> lstAlertLevels = defaultReqContact.Request_Alert_Level__c.split(',');
                    Set<String> setAlertLevels = new Set<String>();
                    setAlertLevels.addAll(lstAlertLevels);
                    if(setAlertLevels.contains(escReq.GSS_Alert_Level__c))
                    {
                        Request_Contact__c reqCon = new Request_Contact__c();
                        reqCon.Request__c = escReq.id;
                        reqCon.Name = defaultReqContact.Name;
                        reqCon.Contact_Email__c = defaultReqContact.Request_Contact_Email__c;
                        reqCon.Contact_Type__c = defaultReqContact.Request_Contact_Type__c;
                        lstRequestContact.add(reqCon);
                    }
                }
            }
            try
            {
                if(lstRequestContact.size() > 0)
                {
                    insert lstRequestContact;
                }
            }
            catch(Exception ex)
            {
                CreateApexErrorLog.insertHandledExceptions( ex, null , null, null, 'ApexClass', 'GSS_CaseRequestClass', 'insertDefaultRequestContacts');
            }   
        }   
    }
    //CR-00138663 - End - Insert the default Request Contacts
     
     public class CaseStatusValidationException extends Exception {}
   
}