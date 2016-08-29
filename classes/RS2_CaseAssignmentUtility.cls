/***************************************************************************************************************
* Name          :  RS2_CaseAssignmentUtility
* Description   : This is the utility class for the RS2 Renewal Case Assignment
*                          
* Created By    : Smitarani Sahoo && Soumya Behera (Accenture)
* Created Date  : 7/4/2016
***************************************************************************************************************/
public class RS2_CaseAssignmentUtility{
    //public static list<Renewals_User_Data__c> eligibleUserForCase = new list<Renewals_User_Data__c>();
    public static Map<Id,Renewals_User_Data__c> eligibleUserForCaseMap = new Map<Id,Renewals_User_Data__c>();
    public static Boolean IS_WP_Processed = false;
    public static Boolean IS_Executed_Same_Transaction = false;
    public static Boolean IS_Renewal_Analysts_Not_Found = false;
    public static Final string val_Escalated = 'Escalated';
    public static Final string val_Non_Escalated = 'Non_Escalated';
    public static Final String CLOSED = 'Closed';
    public static Final String ON_HOLD = 'On Hold';
    public static Final Integer MAX_WORKLOADPOINTS = 9999999;
    public RS2_CaseAssignmentUtility(){}
    /**
    * Description : Method to assign case owner to eligible user 
    * Param : cases:            List of Case  
    *         eligibleUser :    eligble user to whom we need to assign cases
    **/
    public void  RS2_assignCaseOwner(list<Case> cases,list<Renewals_User_Data__c> eligibleUserForCase){
        try{
            Map<String,list<Case>> caseMap = new Map<String,list<Case>>();
            Renewal_Config__c rConfig = Renewal_Config__c.getInstance('Renewal Operations');
            Final Integer ON_HOLD_WP;
            Final Integer ASSIGNED_WP; 
            if(rConfig != null){
                if(rConfig.On_Hold_WP__c != null)
                    ON_HOLD_WP = Integer.valueOf(rConfig.On_Hold_WP__c);else ON_HOLD_WP = 0;
                if(rConfig.Assigned_WP__c != null)
                    ASSIGNED_WP = Integer.valueOf(rConfig.Assigned_WP__c); else ASSIGNED_WP = 0;
            }
            list<Case> escalatedCaseList = new list<Case>();
            list<Case> escalatedCaseListSorted = new list<Case>();
            list<Case> updateCaseOnBatch = new list<Case>();
            RS2_CaseAssignmentUtility.CaseAgeWrapper [] esCaseAgeWappListSorted = new List<RS2_CaseAssignmentUtility.CaseAgeWrapper >();
            list<Case> non_EscalatedCaseList = new list<Case>();
            list<Case> non_escalatedCaseListSorted = new list<Case>();
            RS2_CaseAssignmentUtility.CaseAgeWrapper [] non_esCaseAgeWappListSorted = new List<RS2_CaseAssignmentUtility.CaseAgeWrapper >();
            eligibleUserForCaseMap.clear();
            if(eligibleUserForCase != null && !eligibleUserForCase.IsEmpty()){
                for(Renewals_User_Data__c userData : eligibleUserForCase){
                    if(!eligibleUserForCaseMap.containsKey(userData.Id)){
                        eligibleUserForCaseMap.put(userData.Id,userData);
                    }
                }
            }
            if(!IS_Executed_Same_Transaction && cases != null && !cases.IsEmpty() && eligibleUserForCase != null && !eligibleUserForCase.IsEmpty()){
                // populate the map according to escalated and non-escalated as KEY
                IS_Executed_Same_Transaction  = true;
                for(case c: cases){
                    if(c.IsEscalated){
                        if(!caseMap.containsKey(val_Escalated)){
                            list<Case> newCases = new list<Case>();
                            newCases.add(c);
                            caseMap.put(val_Escalated,newCases);
                        }else{
                            caseMap.get(val_Escalated).add(c);
                        }
                    }else{
                        if(!caseMap.containsKey(val_Non_Escalated)){
                            list<Case> newCases = new list<Case>();
                            newCases.add(c);
                            caseMap.put(val_Non_Escalated,newCases);
                        }else{
                            caseMap.get(val_Non_Escalated).add(c);
                        }
                    }
                }
                // Need to sort the case based on the Case AGE
                if(caseMap != null && caseMap.containsKey(val_Escalated) && caseMap.get(val_Escalated) != null){
                    escalatedCaseList.addAll(caseMap.get(val_Escalated));
                }
                // sorted the escalated case
                if(escalatedCaseList != null && !escalatedCaseList.isEmpty()){
                    for(case escase: escalatedCaseList){
                        esCaseAgeWappListSorted.add(new RS2_CaseAssignmentUtility.CaseAgeWrapper(escase));
                    }
                    esCaseAgeWappListSorted.sort();
                }
                if(esCaseAgeWappListSorted != null && !esCaseAgeWappListSorted.isEmpty()){
                    for(RS2_CaseAssignmentUtility.CaseAgeWrapper casAgewapp: esCaseAgeWappListSorted){
                        escalatedCaseListSorted.add(casAgewapp.cas);
                    }
                }
                // sorted the non-escalated case
                if(caseMap != null && caseMap.containsKey(val_Non_Escalated) && caseMap.get(val_Non_Escalated) != null){
                    non_EscalatedCaseList.addAll(caseMap.get(val_Non_Escalated));
                }
                if(non_EscalatedCaseList != null && !non_EscalatedCaseList.isEmpty()){
                    for(case non_escase: non_EscalatedCaseList){
                        non_esCaseAgeWappListSorted.add(new RS2_CaseAssignmentUtility.CaseAgeWrapper(non_escase));
                    }
                    non_esCaseAgeWappListSorted.sort();
                }
                if(non_esCaseAgeWappListSorted != null && !non_esCaseAgeWappListSorted.isEmpty()){
                    for(RS2_CaseAssignmentUtility.CaseAgeWrapper casAgewapp: non_esCaseAgeWappListSorted){
                        non_escalatedCaseListSorted.add(casAgewapp.cas);
                    }
                }
                
            }
            List<Renewals_User_Data__c> escalatedCaseAssignedUser = new List<Renewals_User_Data__c>();
            for(Case cs: escalatedCaseListSorted){
                Renewals_User_Data__c userdata = RS2_CaseAssignmentUtility.mostEligibleRenewalUser(eligibleUserForCaseMap.values(),cs);
                if(userdata != null){
                    cs.ownerId = userdata.User__c;
                    Renewals_User_Data__c user_data = eligibleUserForCaseMap.get(userdata.Id);
                    user_data.WorkloadPoints__c = user_data.WorkloadPoints__c + ASSIGNED_WP;
                    user_data.Total_Cases_Assigned__c = user_data.Total_Cases_Assigned__c + 1;
                    user_data.Last_Assigned_Date__c = system.now();
                    user_data.Handling_Escalated_Case__c= true;
                    updateCaseOnBatch.add(cs);
                }
                else{
                    if(RS2_Autopopulatevaluesoncase.renewal_Config != null && RS2_Autopopulatevaluesoncase.renewal_Config.Default_Queue_Id__c != null){
                        cs.ownerId = RS2_Autopopulatevaluesoncase.renewal_Config.Default_Queue_Id__c;
                    }
                }
            }
            for(Case cs: non_escalatedCaseListSorted){
                Renewals_User_Data__c userdata = RS2_CaseAssignmentUtility.mostEligibleRenewalUser(eligibleUserForCase,cs);
                if(userdata != null){
                    cs.ownerId = userdata.User__c;
                    updateCaseOnBatch.add(cs);
                    Renewals_User_Data__c user_data = eligibleUserForCaseMap.get(userdata.Id);
                    if(cs.status != ON_HOLD){
                        user_data.WorkloadPoints__c = user_data.WorkloadPoints__c + ASSIGNED_WP;
                        user_data.Total_Cases_Assigned__c = user_data.Total_Cases_Assigned__c + 1;
                        user_data.Last_Assigned_Date__c = system.now();
                    }else{ // On Hold cases
                        user_data.WorkloadPoints__c = user_data.WorkloadPoints__c + ON_HOLD_WP;
                        user_data.Total_Cases_Assigned__c = user_data.Total_Cases_Assigned__c + 1;
                        user_data.Last_Assigned_Date__c = system.now();
                    }
                   //system.debug('*****most eligibleUserForCase***'+eligibleUserForCase); 
                }
                else{
                    if(RS2_Autopopulatevaluesoncase.renewal_Config != null && RS2_Autopopulatevaluesoncase.renewal_Config.Default_Queue_Id__c != null){
                        cs.ownerId = RS2_Autopopulatevaluesoncase.renewal_Config.Default_Queue_Id__c;
                    }
                }
            }
            if(IS_WP_Processed && updateCaseOnBatch != null && !updateCaseOnBatch.IsEmpty()){
                database.update(updateCaseOnBatch,false);
            }
            if(eligibleUserForCaseMap.values() != null && eligibleUserForCaseMap.values().size() > 0){
                database.update(eligibleUserForCaseMap.values(),false);
            }
        }catch(Exception e){ CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_CaseAssignmentUtility', 'RS2_assignCaseOwner');
       } 
    }
    public class CaseAgeWrapper implements Comparable {
        public Case cas;
        // Constructor
        public CaseAgeWrapper(Case c) {
            cas = c;
        }
        // Compare opportunities based on the case age.
        public integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            CaseAgeWrapper compareToCase = (CaseAgeWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            integer returnValue = 0;
            system.debug('****cas.Case_Age_Hours__c*****'+cas.Case_Age_Hours__c);
            if(cas.Case_Age_Hours__c != null){
                if (( cas.Case_Age_Hours__c * 60) < (compareToCase.cas.Case_Age_Hours__c * 60)) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if (( cas.Case_Age_Hours__c * 60) > (compareToCase.cas.Case_Age_Hours__c * 60)) {
                    // Set return value to a negative value.
                    returnValue = -1;
                }
            }
            
            return returnValue;       
        }
    }
        /***********************************************************************************************
        * Method Name: mostEligibleRenewalUser
        * Description: This method finds the lowest case assigned / workload user
        * @Param: List of Renewals_User_Data__c
        * @return: Renewals_User_Data__c 
        ***********************************************************************************************/
        public static Map<String,Renewals_User_Data__c> contractOwnerIdMap = new Map<String,Renewals_User_Data__c>();
        public static Renewals_User_Data__c mostEligibleRenewalUser(List<Renewals_User_Data__c> renewalUsersList,Case cs){  
            try{
                Map<Id,Renewals_User_Data__c> renewalUsers = new Map<Id,Renewals_User_Data__c>();
                Map<Decimal,List<Renewals_User_Data__c>> renewalUserLowestWorkLoadMap = new Map<Decimal,List<Renewals_User_Data__c>>();
                Map<DateTime,List<Renewals_User_Data__c>> UserLowestCaseAssignedDT = new Map<DateTime,List<Renewals_User_Data__c>>();
                for(Renewals_User_Data__c rewUser: renewalUsersList){
                    if(!string.IsBlank(cs.Vmware_Contract_Number__c) && contractOwnerIdMap.containsKey(cs.Vmware_Contract_Number__c) && (contractOwnerIdMap.get(cs.Vmware_Contract_Number__c).Id == rewUser.Id) ){
                        if((rewUser.Capacity__c > rewUser.Total_Cases_Assigned__c) && (rewUser.WorkloadPoints__c < rewUser.Max_Workload__c)){
                            return rewUser;
                        }
                    }
                }       
                List<Renewals_User_Data__c> eligibleWorkloadUser = new List<Renewals_User_Data__c>();
                List<Renewals_User_Data__c> eligibleCaseAssingedUser = new List<Renewals_User_Data__c>();
                for(Renewals_User_Data__c rewUser: renewalUsersList){
                    if((rewUser.Capacity__c > rewUser.Total_Cases_Assigned__c) && (rewUser.WorkloadPoints__c < rewUser.Max_Workload__c) ){
                        if((rewUser.Handling_Escalated_Case__c && !cs.IsEscalated ) && !renewalUserLowestWorkLoadMap.containsKey(rewUser.WorkloadPoints__c)){
                            List<Renewals_User_Data__c> temnew = new list<Renewals_User_Data__c>();
                            temnew.add(rewUser);
                            renewalUserLowestWorkLoadMap.put(rewUser.WorkloadPoints__c,temnew);
                        }else if((rewUser.Handling_Escalated_Case__c && !cs.IsEscalated ) && renewalUserLowestWorkLoadMap.containsKey(rewUser.WorkloadPoints__c)){
                            renewalUserLowestWorkLoadMap.get(rewUser.WorkloadPoints__c).add(rewUser);
                        }
                        else if(!rewUser.Handling_Escalated_Case__c && !renewalUserLowestWorkLoadMap.containsKey(rewUser.WorkloadPoints__c)){
                            List<Renewals_User_Data__c> temnew = new list<Renewals_User_Data__c>();
                            temnew.add(rewUser);
                            renewalUserLowestWorkLoadMap.put(rewUser.WorkloadPoints__c,temnew);
                        }
                        else if(!rewUser.Handling_Escalated_Case__c && renewalUserLowestWorkLoadMap.containsKey(rewUser.WorkloadPoints__c)){
                            renewalUserLowestWorkLoadMap.get(rewUser.WorkloadPoints__c).add(rewUser);
                        }
                    }
                }
                list<Decimal> temp_WorkloadKeyList = new List<Decimal>();      
                temp_WorkloadKeyList.addAll(renewalUserLowestWorkLoadMap.KeySet());
                Decimal lowestWorkload= MAX_WORKLOADPOINTS;
                for(Decimal tempLowest: temp_WorkloadKeyList){
                    if(tempLowest < lowestWorkload){
                        lowestWorkload = tempLowest;
                    }
                }
                if(lowestWorkload != MAX_WORKLOADPOINTS){
                    eligibleWorkloadUser = renewalUserLowestWorkLoadMap.get(lowestWorkload);
                }
                if(eligibleWorkloadUser != null && eligibleWorkloadUser.size() > 1){
                    for(Renewals_User_Data__c rewUser: eligibleWorkloadUser){
                        if(rewUser.Last_Assigned_Date__c != null){
                            if(!UserLowestCaseAssignedDT.containsKey(rewUser.Last_Assigned_Date__c)){
                                List<Renewals_User_Data__c> temnew = new list<Renewals_User_Data__c>();
                                temnew.add(rewUser);
                                UserLowestCaseAssignedDT.put(rewUser.Last_Assigned_Date__c,temnew);
                            }
                            else{
                                UserLowestCaseAssignedDT.get(rewUser.Last_Assigned_Date__c).add(rewUser);
                            }   
                        }
                        else{
                            if(!String.IsBlank(cs.Vmware_Contract_Number__c)){
                                contractOwnerIdMap.put(cs.Vmware_Contract_Number__c,rewUser);
                            }
                            return rewUser;
                        }
                    }
                    list<DateTime> dT_caseAssigned = new List<DateTime>();
                    DateTime caseDateTime = null;
                    if(UserLowestCaseAssignedDT != null && !UserLowestCaseAssignedDT.IsEmpty()){
                        dT_caseAssigned.addAll(UserLowestCaseAssignedDT.KeySet());
                        caseDateTime= system.now().addHours(1);
                        for(DateTime dt: dT_caseAssigned){
                            if(caseDateTime > dt){
                                caseDateTime = dt;
                            }
                        }
                    }
                    if(caseDateTime != null && caseDateTime != system.now().addHours(1)){
                        eligibleCaseAssingedUser = UserLowestCaseAssignedDT.get(caseDateTime);
                    }
                }
                 else if((!eligibleWorkloadUser.IsEmpty() && eligibleWorkloadUser.size()==1)){
                    if(!String.IsBlank(cs.Vmware_Contract_Number__c)){
                        contractOwnerIdMap.put(cs.Vmware_Contract_Number__c,eligibleWorkloadUser[0]);
                    }
                    return eligibleWorkloadUser[0];
                }
                if(eligibleCaseAssingedUser != null && !eligibleCaseAssingedUser.IsEmpty()){
                    if(!String.IsBlank(cs.Vmware_Contract_Number__c)){
                        contractOwnerIdMap.put(cs.Vmware_Contract_Number__c,eligibleCaseAssingedUser[0]);
                    }
                    return eligibleCaseAssingedUser[0];
                }else{
                    return null;
                }       
            }Catch(Exception e){CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_CaseAssignmentUtility', 'mostEligibleRenewalUser');return null;
            }
        }
        
        /**
    * Description : Method to get the list of users who are free to get the RS2 case assigned
    * Param : Center : Support Center of User Data
    *         caseDate : Date of assignment. Check the even of the user for this date
    *         minOnShift : Min minutes that a user should be available on shift for caseDate
    **/
    public Map<Renewal_Rule_Scenario__c,List<Renewals_User_Data__c>> getEligibleUser(Set<Renewal_Rule_Scenario__c> ruleScenarios , String userSkillWhereClase , DateTime caseDate){
        String RS2_RTId;
        Map<String,Renewals_User_Data__c> eligibleUserData = new Map<String,Renewals_User_Data__c>();
        Map<Id,Renewals_User_Data__c> toFilterEventUserData = new Map<Id,Renewals_User_Data__c>();
        Map<Renewal_Rule_Scenario__c,List<Renewals_User_Data__c>> ruleScenarioUserData = new Map<Renewal_Rule_Scenario__c,List<Renewals_User_Data__c>>();
        Map<Renewals_User_Data__c,Set<String>> skills = new Map<Renewals_User_Data__c,Set<String>>();
        Renewal_Config__c rConfig = Renewal_Config__c.getInstance('Renewal Operations');
        Integer minutesOnShift = 0; 
        RS2_RTId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('RS2 Renewal').getRecordTypeId();
        if(rConfig != null){
            if(rConfig.Minute_Of_Shift__c != null)
                minutesOnShift =Integer.valueOf(rConfig.Minute_Of_Shift__c);
            if(rConfig.Event_Record_Type_ID__c != null)
                RS2_RTId = rConfig.Event_Record_Type_ID__c;
        } 
        String queryString = 'Select id,name,Available__c,Total_Cases_Assigned__c,User__c,WorkloadPoints__c,Max_Workload__c,Handling_Escalated_Case__c,Capacity__c ,Last_Assigned_Date__c,(select Parameter__c,Value__c from RS2_Renewal_Skill__r ) FROM Renewals_User_Data__c  WHERE Available__c=true AND id IN (select Renewal_User_Data__c from RS2_Renewal_Skill__c ' + userSkillWhereClase + ')';
        
        if(!String.isBlank(RS2_RTId) && minutesOnShift!=null && !String.isBlank(queryString)){
            //Get list of user data
            List<Renewals_User_Data__c> renewalUsrData = Database.Query(queryString);
            for(Renewals_User_Data__c usrData : renewalUsrData){
                //check the capacity of each user
                if(usrData.Capacity__c > usrData.Total_Cases_Assigned__c ){
                    toFilterEventUserData.put(usrData.User__c,usrData);
                } 
            }
            if(toFilterEventUserData.keySet() != null){
                DateTime windowStartTime = caseDate;
                DateTime windowEndTime = caseDate.addMinutes(minutesOnShift);
                Set<String> nonAvailableOwner = new Set<String>();
                //get the event of each user
                 for (Event e : [SELECT Id, Startdatetime, Enddatetime, ShowAs, IsRecurrence, ownerID 
                        FROM Event 
                        WHERE ownerID in :toFilterEventUserData.keySet()
                        AND StartDateTime <= :windowStartTime 
                        AND EndDateTime >= :windowEndTime
                        AND RecordTypeId = :RS2_RTId     
                        ORDER BY ownerID, StartDateTime, EndDateTime]) {
                            if(e.ShowAs == 'Busy'){
                                eligibleUserData.put(e.ownerID,toFilterEventUserData.get(e.ownerID));
                            }
                            else{
                                nonAvailableOwner.add(e.ownerID);
                            }
                            
                }
                //Removing the owners who had overlapping events e.g Analyst A {Busy:1pm - 3pm, OOO: 2pm-3pm}
                if(!nonAvailableOwner.isEmpty() && eligibleUserData!= null){
                    //remove the users for original list who are not available
                    for(String ownerId : nonAvailableOwner){
                        if(eligibleUserData.containsKey(ownerId)){
                            eligibleUserData.remove(ownerId);
                        }
                    }
                }
            }
            if(!eligibleUserData.isEmpty()){
                for(Renewals_User_Data__c userData:eligibleUserData.values()){
                    for(RS2_Renewal_Skill__c skill : userData.RS2_Renewal_Skill__r){
                        if(!skills.containsKey(userData)){
                            skills.put(userData,new Set<String>{skill.Parameter__c+':'+skill.Value__c});
                        }
                        else{
                            skills.get(userData).add(skill.Parameter__c+':'+skill.Value__c);
                        }
                    }
                }
                //Map the user data for each rule scenario
                for(Renewal_Rule_Scenario__c rs : ruleScenarios){
                    for(Renewals_User_Data__c userData : eligibleUserData.values()){
                        boolean isEligible =  hasUserSkill(skills.get(UserData),rs);
                        if(isEligible){
                            if(!ruleScenarioUserData.containsKey(rs)){
                                ruleScenarioUserData.put(rs,new List<Renewals_User_Data__c>{userData});
                            }
                            else{
                                ruleScenarioUserData.get(rs).add(userData);
                            }
                        }
                        
                    }
                }
            }
        }   
        return ruleScenarioUserData;
    }
    public Boolean hasUserSkill(Set<String> skills,Renewal_Rule_Scenario__c rs){
        //Check if the user is eligible
        for(Renewal_Requirement__c req : rs.Renewal_Requirements__r){ 
            if(!skills.contains(req.Parameter__c+':'+req.Value__c)){
                return false;
            }
        }
        return true;
    }      
    /**
    * Description : Method to update the workload points for the cases closed,owner and status changed
    * Param : List of cases
    * Return : null
    **/
    public static void calWorkloadPoint(List<Case> newCasesList,Map<Id,Case> oldCases){
        try{
            OnOffSwitch__c RS2_switch = OnOffSwitch__c.getValues('RS2_Workload_Allocation');
            if(newCasesList != null && RS2_switch != null && RS2_switch.Active__c && !IS_WP_Processed && !IS_Executed_Same_Transaction ){
                IS_Executed_Same_Transaction = true;
                Renewal_Config__c rConfig = Renewal_Config__c.getInstance('Renewal Operations');
                Final Integer ON_HOLD_WP;
                Final Integer ASSIGNED_WP;
                Final String REACTIVE = 'Reactive';
                string recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
                string reqType = 'RELA Quote';
                if(rConfig != null){
                    if(rConfig.CaseRecordTypeId__c != null)
                        recTypeId = rConfig.CaseRecordTypeId__c;
                    if(rConfig.Request_Type__c != null)
                        reqType = rConfig.Request_Type__c;
                    if(rConfig.On_Hold_WP__c != null)
                        ON_HOLD_WP = Integer.valueOf(rConfig.On_Hold_WP__c); else ON_HOLD_WP = 0;
                    if(rConfig.Assigned_WP__c != null)
                        ASSIGNED_WP = Integer.valueOf(rConfig.Assigned_WP__c); else ASSIGNED_WP  = 0;
                }
                Map<Id,Renewals_User_Data__c> ownerUserMap = new Map<Id,Renewals_User_Data__c>();
                set<String> ownerIds = new set<String>();
                Map<Id,Renewals_User_Data__c> toUpdate = new Map<Id,Renewals_User_Data__c>();
                List<Case> newCases = new List<Case>();
                map<Id,Integer> OwnerEscalatedCaseMap  = new map<Id,Integer>();         
                //Separate out the renewal cases
                for(Case c : newCasesList){
                    if(c.recordtypeId == recTypeId && c.Request_Type__c.equalsIgnoreCase(reqType) && (String.isBlank(c.QC_Type__c) || c.QC_Type__c.equalsIgnoreCase(REACTIVE))){
                        newCases.add(c);
                    }
                }
                if(!newCases.isEmpty() && !oldCases.isEmpty()){
                    //get list of owner ids
                    for(Case oCase : newCases){
                        if(oldCases.containsKey(oCase.id) && ((oCase.status.equalsIgnoreCase(CLOSED) && !oldCases.get(oCase.id).status.equalsIgnoreCase(CLOSED)) || (oCase.isEscalated != oldCases.get(oCase.id).isEscalated) || (oldCases.get(oCase.id).ownerId != oCase.ownerId) || ((oldCases.get(oCase.id).status != oCase.status) && (oldCases.get(oCase.id).status.equalsIgnoreCase(ON_HOLD) || oCase.status.equalsIgnoreCase(ON_HOLD))))){
                            ownerIds.add(oCase.ownerId);
                            if(oldCases.get(oCase.id).ownerId != oCase.ownerId){ // capturing older case owned id also
                                ownerIds.add(oldCases.get(oCase.id).ownerId);
                            }
                        }
                    }
                    if(ownerIds != null && !ownerIds.isEmpty()){
                        // 29th July - Part of Enhancmenet/efect fix 
                        List<AggregateResult> listCases = [select count(Id) Totalcases,OwnerId from Case where OwnerId IN: ownerIds and IsEscalated = true and Status != 'Closed' and RecordTypeId =: recTypeId and Request_Type__c =: reqType and (QC_Type__c =: REACTIVE OR QC_Type__c ='' OR QC_Type__c = null) group by OwnerId];
                        if(listCases != null && !listCases.IsEmpty()){
                            for(AggregateResult agg: listCases){
                                if(!OwnerEscalatedCaseMap.containsKey((ID)agg.get('OwnerId'))){
                                    OwnerEscalatedCaseMap.put((ID)agg.get('OwnerId'),Integer.valueof(agg.get('Totalcases')));
                                } 
                            }  
                        }
                    }
                    if(!ownerIds.isEmpty()){
                        for(Renewals_User_Data__c userData : [select Id,name,Available__c,Last_Assigned_Date__c,Capacity__c,Handling_Escalated_Case__c,Total_Cases_Assigned__c,User__c,User__r.Name,WorkloadPoints__c,Max_Workload__c from  Renewals_User_Data__c where User__c IN: ownerIds]){
                            //Prepare map of case and userdata
                            ownerUserMap.put(userData.User__c,userData);
                        }
                    }
                    //Prepare map of userdata and case
                    for(Case oCase : newCases){
                        Renewals_User_Data__c newUserData = null;
                        Renewals_User_Data__c oldUserData = null;
                        
                        if(!toUpdate.containsKey(oCase.ownerId)){
                            newUserData = ownerUserMap.get(oCase.ownerId);
                        }
                        else{
                            newUserData = toUpdate.get(oCase.ownerId);
                        }
                        if(!toUpdate.containsKey(oldCases.get(oCase.id).ownerId)){
                            oldUserData = ownerUserMap.get(oldCases.get(oCase.id).ownerId);
                        }
                        else{
                            oldUserData = toUpdate.get(oldCases.get(oCase.id).ownerId);
                        }
                        //Check for closed status
                        if(newUserData != null && oCase.status.equalsIgnoreCase(CLOSED) && !oldCases.get(oCase.id).status.equalsIgnoreCase(CLOSED)){
                            //decrease the wp and total case assigned.If escalated, uncheck the checkbox
                            newUserData.Total_Cases_Assigned__c = newUserData.Total_Cases_Assigned__c - 1;
                            if(oldCases.get(oCase.id).status.equalsIgnoreCase(ON_HOLD)){
                                newUserData.WorkloadPoints__c = newUserData.WorkloadPoints__c - ON_HOLD_WP;
                            }
                            else{
                                newUserData.WorkloadPoints__c = newUserData.WorkloadPoints__c - ASSIGNED_WP;
                            }   
                            if(oCase.IsEscalated != null && oCase.IsEscalated && OwnerEscalatedCaseMap != null && OwnerEscalatedCaseMap.containskey(newUserData.User__c) && OwnerEscalatedCaseMap.get(newUserData.User__c) == 1){ //Based on assumption that analyst can have only 1 escalated case
                                newUserData.Handling_Escalated_Case__c = false;
                            }
                            //Add to the map
                            toUpdate.put(newUserData.User__c,newUserData);
                        }
                        //Condition for owner change - Decrease older userdata wp and increase current user data wp
                        else if((newUserData != null || oldUserData!= null) && oldCases.get(oCase.id).ownerId != oCase.ownerId){
                            if(ocase.status != null && ocase.status.equalsIgnoreCase(ON_HOLD)){ //WP is 2
                                if(oldUserData != null){
                                    oldUserData.WorkloadPoints__c = oldUserData.WorkloadPoints__c - ON_HOLD_WP;
                                    oldUserData.Total_Cases_Assigned__c = oldUserData.Total_Cases_Assigned__c - 1;
                                }
                                if(newUserData != null){
                                    newUserData.WorkloadPoints__c = newUserData.WorkloadPoints__c + ON_HOLD_WP;
                                    newUserData.Total_Cases_Assigned__c = newUserData.Total_Cases_Assigned__c + 1;
                                    newUserData.Last_Assigned_Date__c = system.now();
                                }
                            }
                            else{ //WP is 10 
                                if(oldUserData != null){
                                    oldUserData.WorkloadPoints__c = oldUserData.WorkloadPoints__c - ASSIGNED_WP;
                                    oldUserData.Total_Cases_Assigned__c = oldUserData.Total_Cases_Assigned__c - 1;
                                }
                                if(newUserData != null){
                                    newUserData.WorkloadPoints__c = newUserData.WorkloadPoints__c + ASSIGNED_WP;
                                    newUserData.Total_Cases_Assigned__c = newUserData.Total_Cases_Assigned__c + 1;
                                    newUserData.Last_Assigned_Date__c = system.now();
                                }
                            }
                            if(oCase.IsEscalated != null && oCase.IsEscalated){ //Based on assumption that analyst can have only 1 escalated case
                                if(oldUserData != null && OwnerEscalatedCaseMap != null){
                                    if(OwnerEscalatedCaseMap.containskey(oldUserData.User__c) && OwnerEscalatedCaseMap.get(oldUserData.User__c) == 1){
                                        oldUserData.Handling_Escalated_Case__c = false;
                                    }
                                    else if(OwnerEscalatedCaseMap.containskey(oldUserData.User__c) && OwnerEscalatedCaseMap.get(oldUserData.User__c) > 1){
                                        Integer i = OwnerEscalatedCaseMap.get(oldUserData.User__c);
                                        i = i -1;
                                        OwnerEscalatedCaseMap.put(oldUserData.User__c,i);
                                    }
                                }
                                if(newUserData != null)
                                    newUserData.Handling_Escalated_Case__c = true;
                            }   
                            //Add to the map
                            if(newUserData != null){
                                toUpdate.put(newUserData.User__c,newUserData);
                            }
                            if(oldUserData != null){
                                toUpdate.put(oldUserData.User__c,oldUserData);
                            }
                        }
                        //Conditon for status change
                        else if(newUserData != null && (oldCases.get(oCase.id).status != oCase.status) && (oldCases.get(oCase.id).status.equalsIgnoreCase(ON_HOLD) || oCase.status.equalsIgnoreCase(ON_HOLD))){
                            
                            if(oldCases.get(oCase.id).status != null && oldCases.get(oCase.id).status.equalsIgnoreCase(ON_HOLD)){ //Consider case to be resumed- change WP from 2 to 10
                                newUserData.WorkloadPoints__c = newUserData.WorkloadPoints__c + (ASSIGNED_WP - ON_HOLD_WP);
                            }
                            else{ //Considering the status was put on hold - change the WP from 10 to 2
                                newUserData.WorkloadPoints__c = newUserData.WorkloadPoints__c - (ASSIGNED_WP - ON_HOLD_WP);
                            }
                            
                            //Add to the map
                            toUpdate.put(newUserData.User__c,newUserData);
                        }
                        //Changing the escalation 
                        else if(oCase.isEscalated != oldCases.get(oCase.id).isEscalated && newUserData != null){
                            
                            if(oCase.isEscalated != null && oCase.isEscalated){ // the case is converted to escalated
                                newUserData.Handling_Escalated_Case__c = true;
                            }
                            else{ // the case is converted to non escalated
                                if( OwnerEscalatedCaseMap != null && OwnerEscalatedCaseMap.containskey(newUserData.User__c) && OwnerEscalatedCaseMap.get(newUserData.User__c) == 1)
                                    newUserData.Handling_Escalated_Case__c = false;
                                else if(OwnerEscalatedCaseMap.containskey(newUserData.User__c) && OwnerEscalatedCaseMap.get(newUserData.User__c) > 1){
                                     Integer i = OwnerEscalatedCaseMap.get(newUserData.User__c);
                                     i = i -1;
                                     OwnerEscalatedCaseMap.put(newUserData.User__c,i);
                                }
                            }
                            
                            //Add to the map
                            toUpdate.put(newUserData.User__c,newUserData);
                        }
                        
                    }
                    
                    if(toUpdate != null){
                        database.update(toUpdate.values(),false);
                    }
                }
            }       
        }catch(Exception e){ CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_CaseAssignmentUtility', 'calWorkloadpoints'); }
    } 
    
    /**
    * Description : Method to update the case extension flag Renewal Analysts Not Found for those cases which did not find any eligible users
    * Param : List of cases
    * Return : null
    **/
    public static void populateCaseFlagForNoEligibleFound(List<Case> newCasesList){
        try{
             OnOffSwitch__c RS2_switch = OnOffSwitch__c.getValues('RS2_Workload_Allocation');
             
            if(newCasesList != null && RS2_switch != null && RS2_switch.Active__c && IS_Renewal_Analysts_Not_Found){
                Renewal_Config__c rConfig = Renewal_Config__c.getInstance('Renewal Operations');
                String recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
                if(rConfig.CaseRecordTypeId__c != null)
                    recTypeId = rConfig.CaseRecordTypeId__c;
                List<Case_Extension__c> caseExtensionList = new List<Case_Extension__c>();
                Set<Id> caseIds = new Set<Id>();
                for(Case oCase : newCasesList){
                    if(oCase.recordTypeId == recTypeId && oCase.request_Type__c == 'RELA Quote' && (String.isBlank(oCase.QC_Type__c) || oCase.QC_Type__c.equalsIgnoreCase('Reactive'))){
                        if(rConfig.Default_Queue_Id__c != null && (oCase.ownerId == rConfig.Default_Queue_Id__c)){
                            caseIds.add(oCase.id);
                        }
                    }
                }
                if(!caseIds.isEmpty()){
                    for(Case_Extension__c oCaseExtension: [Select id,Renewal_Analysts_Not_Found__c,Case__c from Case_Extension__c where case__c IN: caseIds]){
                        oCaseExtension.Renewal_Analysts_Not_Found__c = true;
                        caseExtensionList.add(oCaseExtension);
                    }
                }
                if(!caseExtensionList.isEmpty()){
                    database.update(caseExtensionList,false);
                }
            }
        }
        Catch(Exception e){CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_CaseAssignmentUtility', 'populateCaseFlagForNoEligibleFound');
        }
    }
    /**
    * Description : This method to check the duplicate user in the renewal User Data object at the time of Insert / Update
    * Param : Trigger.New
    * Return : null
    **/ 
    public static void duplicateRenewalUserData(List<Renewals_User_Data__c> renewalUserDataList){
        list<Renewals_User_Data__c> Existing_RenewalUser = new list<Renewals_User_Data__c>();
        Map<Id,Renewals_User_Data__c> existingRenwalUserMap = new Map<Id,Renewals_User_Data__c>();
        set<Id> newSetUpIds = new set<Id>();
        if(trigger.isInsert){
            for(Renewals_User_Data__c reUser: renewalUserDataList){
                if(reUser.User__c != null){
                    newSetUpIds.add(reUser.User__c);
                }
            }
        }
        if(trigger.IsUpdate){
            for(Renewals_User_Data__c reUser: renewalUserDataList){
                if(reUser.User__c != null && (((Renewals_User_Data__c)trigger.oldMap.get(reUser.Id)).User__c != reUser.User__c)){
                    newSetUpIds.add(reUser.User__c);
                }
            }
        }
        if(newSetUpIds != null && !newSetUpIds.IsEmpty()){
            Existing_RenewalUser = [select Id,Name,Available__c,Capacity__c,Total_Cases_Assigned__c,User__c from Renewals_User_Data__c where User__c IN: newSetUpIds];
        }
        if(Existing_RenewalUser != null && !Existing_RenewalUser.IsEmpty()){
            for(Renewals_User_Data__c userData: Existing_RenewalUser){
                if(!existingRenwalUserMap.containsKey(userData.User__c)){
                    existingRenwalUserMap.put(userData.User__c,userData);
                }
            }
        }
        for(Renewals_User_Data__c reUser: renewalUserDataList){
            if(existingRenwalUserMap.containsKey(reUser.User__c)){
                reUser.addError('This user already exists '+existingRenwalUserMap.get(reUser.User__c).Name);
            }
        }
    }   
}