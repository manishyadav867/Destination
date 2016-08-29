//*********************************************************************************************************
// Name:L2O_OpportunityHelper
// Description: (CR-00138530 )This is a class for fetching contact roles,Aw products on MSO opprtunity.
// Created Date: 23-April-2016
// Created By: Accenture 

// ************************Version Updates*****************************************************************
//
// Updated Date         Updated By                 Update Comments 
// 10/06/2016      Shivang Vij          CR-00140097 conditional changes requried for certain validation rules
// 02/08/2016      Nierrbhayy Patel     CR-00140583 Remove 'Deal Includes AW Product' condition for CAM Validation rule
// 03/08/2016      Nierrbhayy Patel     CR-00140587 Added condition for Business Line = VMware and AW Sub stage=Free Trial
// 04/08/2016      Shivang vij          CR-00140146 Changes on the Validation Rules
// 23/08/2016      Shivang Vij          CR-00140793 Changes in Validation Rules
// ********************************************************************************************************
public Class L2O_OpportunityHelper{
    
    public static Boolean recursiveCheck = false;
    public static Boolean recursiveCheckSEOverrideOnOpty = false;//CR-00138571
    public static Boolean isterritoryupdate = false;
    public static Boolean isaccountupdteonopty = false;
    public static Boolean isoptyteaminsert = false;
    public static Boolean freeTrialPrimaryVR = false;           //CR-00140146
     
    
    /***********************************************************************************************
    Method Name: enforceValidationRules
    Description:  method for different validation rules 
    @return: None
    @throws: none
    ***********************************************************************************************/ 
    public static void enforceValidationRules(List<Opportunity> triggerNewList, Map<id,opportunity>triggerOldMap){
        L2O_Variables__c CAMsDetails = L2O_Variables__c.getOrgDefaults();
        List<String> AWprofileNamesList = System.Label.AW_Profiles.split(',');
        List<String> GeoSalesOperationsprofileNamesList = System.Label.L2OGeoSalesOperationsProfiles.split(',');
        List<String> CoreGeoSalesprofileNamesList = System.Label.L2OCoreGeoSales.split(',');
        List<String> AWGeoSalesprofileNamesList = System.Label.L2OAWGeoSales.split(',');
        Boolean CAMPresent = false;
        List<String> listByPassRTMforAW = system.label.FRBypassRTMFOrOppty.split(',');      //getting RTM required for AW
        Map<ID,String> checkVMWProductLineMap = new Map<ID,String>();       //CR-00140146
    Set<ID> freeTrialVROpptySet = new Set<ID>();        //CR-00140146
        List<OpportunityTeamMember> OpptyTeamMemberList = new List<OpportunityTeamMember>();
        set<String> setByPassRTMforAW = new set<String>();
        setByPassRTMforAW.addAll(listByPassRTMforAW);
                
        Map<id,opportunity> qualifiedOpptiesForTeamMemberVR = new Map<id,opportunity>();   
        String MSORecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(system.label.OpptyRecordTypeMSO).getRecordTypeId();           //'Managed Sales Opportunity' Record type
        set<String> AWProfileNamesSet = new set<String>();
        AWProfileNamesSet.addAll(AWprofileNamesList);
        set<String> GeoSalesOperationsprofileNamesSet = new set<String>();
        GeoSalesOperationsprofileNamesSet.addAll(GeoSalesOperationsprofileNamesList);
        set<String> CoreGeoSalesprofileNamesSet = new set<String>();
        CoreGeoSalesprofileNamesSet.addAll(CoreGeoSalesprofileNamesList);
        set<String>AWGeoSalesprofileNamesSet = new set<String>();
        AWGeoSalesprofileNamesSet.addAll(AWGeoSalesprofileNamesList);
        
        try{
            Id profileId = userInfo.getProfileId();
        
            Profile queryProfile;
            if(profileId != null && UserInfo.getUserType() != 'PartnerNetwork' && UserInfo.getName() != 'Connection User'){
                queryProfile=[Select Id,Name from Profile where Id=:profileId]; 
            }
            String profileName = 'Dummy';
            
            if(queryProfile != null){
                profileName = queryProfile.Name;
            }
            
            Map<id,opportunity> qualifiedOppties = new Map<id,opportunity>();
            Set<Id>primaryOCROpptySet = new Set<Id>();
            Set<Id>primaryOCROpptyDealClosureSet = new Set<Id>();
            Set<Id>technicalOCROpptySet = new Set<Id>();
            
            for(Opportunity oppty : triggerNewList){
                if(oppty.RecordTypeId == MSORecordTypeId/* && oppty.Business_Line__c==system.label.FRBypassBusinessLineonOppty && oppty.No_of_Airwatch_Products__c > 0*/){              //validation qualification for primary contact and technical contact to avoid query if possible
                    qualifiedOppties.put(oppty.id,oppty);
                    if(triggerOldMap.get(oppty.ID).VMWProductLine__c != null){
                        checkVMWProductLineMap.put(oppty.Id,triggerOldMap.get(oppty.ID).VMWProductLine__c);
                    }
                }
                //CR-00140583 -  removed conditions for 'Deal Includes AW Product' (VMWProductLine__c and No_of_Airwatch_Products__c commented)
                if(/*triggerOldMap.get(oppty.ID).VMWProductLine__c != null && */oppty.RecordTypeID == MSORecordTypeId && (oppty.Business_Line__c == system.label.FRBypassBusinessLineonOppty /*|| oppty.No_of_Airwatch_Products__c > 0*/)&& setByPassRTMforAW.contains(oppty.Route_To_Market__c) && AWProfileNamesSet.contains(profileName)){          //check if the oppty is having AW products on it
                    qualifiedOpptiesForTeamMemberVR.put(oppty.id,oppty);
                }
            }
            if(!qualifiedOpptiesForTeamMemberVR.isEmpty()){             //validation for CAM
                OpptyTeamMemberList = [select id, TeamMemberRole, OpportunityID from OpportunityTeamMember where OpportunityId in : qualifiedOpptiesForTeamMemberVR.keyset()];
                
                for(Opportunity oppty : qualifiedOpptiesForTeamMemberVR.values()){
                    if(!OpptyTeamMemberList.isEmpty()){
                        for(OpportunityTeamMember otm : OpptyTeamMemberList){
                            if(otm.OpportunityID == oppty.ID && otm.TeamMemberRole == system.label.OpptyTeamCamRole){
                                CAMPresent = true;
                            }
                        }
                    }else{
                        CAMPresent = false;
                    }
                    if(!CAMPresent && CAMsDetails != null && CAMsDetails.Enable_CAM_On_Oppty__c){
                        oppty.addError(system.label.CAMValidationRule);               //throw error if yes
                        continue;
                    }
                    CAMPresent = false;
                }
            }
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            map<Id,List<OpportunityContactRole>> opptyContactRoleListMap = new map<Id,List<OpportunityContactRole>>();
            List<OpportunityContactRole> iteratorForMap;
            Boolean technicalRole = true;
            Boolean primaryRole = true;
            Boolean primaryOpptyClosureRole = true;
            
            if(!qualifiedOppties.values().isEmpty()){
                ocrList = [Select Id, OpportunityId, isprimary, Role from OpportunityContactRole where OpportunityId IN : qualifiedOppties.keyset()];
                
                if(!ocrList.isEmpty()){
                    for(OpportunityContactRole ocr : ocrList){
                        if(opptyContactRoleListMap.containskey(ocr.OpportunityId)){
                            iteratorForMap = opptyContactRoleListMap.get(ocr.OpportunityId);
                            iteratorForMap.add(ocr);
                        }else{
                            iteratorForMap = new List<OpportunityContactRole>();
                            iteratorForMap.add(ocr);
                            opptyContactRoleListMap.put(ocr.OpportunityID,iteratorForMap);
                        }
                    }
                }
            
                for(Opportunity oppty : qualifiedOppties.Values()){                   //Check if roles exist in the map or contact role isn't required
                    //if(checkVMWProductLineMap.get(oppty.Id) != null && oppty.No_of_Airwatch_Products__c > 0){
                        system.debug('+++++++Here');
                        
                        freeTrialPrimaryVR = (oppty.AW_Sub_Stage__c==system.label.L2O_FreeTrial && AWProfileNamesSet.contains(profileName));
                        
                        technicalRole = (checkVMWProductLineMap.get(oppty.Id) != null && oppty.No_of_Airwatch_Products__c > 0 && System.Label.MSOTrackAWDealOppStageVals.contains(oppty.StageName) && oppty.Business_Line__c==system.label.FRBypassBusinessLineonOppty && AWProfileNamesSet.contains(profileName));
                        //CR-00140587 starts : commenting old condition. adding new condition
                        //primaryRole = (oppty.Business_Line__c==system.label.FRBypassBusinessLineonOppty && System.Label.AWStageForPrimaryContactValidation.contains(oppty.StageName) && (GeoSalesOperationsprofileNamesSet.contains(profileName) || AWGeoSalesprofileNamesSet.contains(profileName)));
                        
                        primaryRole = (checkVMWProductLineMap.get(oppty.Id) != null && oppty.No_of_Airwatch_Products__c > 0 && ((oppty.Business_Line__c==system.label.FRBypassBusinessLineonOppty && System.Label.AWStageForPrimaryContactValidation.contains(oppty.StageName)) || 
                                        (oppty.Business_Line__c==system.label.L2O_Business_Line_Vmware && oppty.AW_Sub_Stage__c==system.label.L2O_FreeTrial)) && 
                                        (GeoSalesOperationsprofileNamesSet.contains(profileName) || AWGeoSalesprofileNamesSet.contains(profileName)));
                        system.debug('primaryRole ======== '+primaryRole );
                        //CR-00140587 ends
                        //CR-00140793: Included AW_Sub_Stage__c=Free Trial in OR condition with Stage and Business Line
                        primaryOpptyClosureRole = (checkVMWProductLineMap.get(oppty.Id) != null && oppty.No_of_Airwatch_Products__c > 0 && ((oppty.Business_Line__c==system.label.FRBypassBusinessLineonOppty && System.Label.MSOTrackAWDealOppStageVals.contains(oppty.StageName)) || oppty.AW_Sub_Stage__c==system.label.L2O_FreeTrial)&& CoreGeoSalesprofileNamesSet.contains(profileName));
                        system.debug('+++++'+technicalRole+primaryRole+primaryOpptyClosureRole+'++++++');
                        if(opptyContactRoleListMap.get(oppty.Id) != null && !opptyContactRoleListMap.get(oppty.Id).isEmpty()){
                            for(OpportunityContactRole ocr : opptyContactRoleListMap.get(oppty.Id)){
                                if(!(technicalRole && (oppty.AW_Bill_To__c==null || oppty.Bill_Ship_Complete__c==False || ocr.Role != system.label.Technicalcontact_role))){
                                    technicalOCROpptySet.add(oppty.ID);
                                }
                                if(!(primaryRole && (oppty.Business_Line__c == null || oppty.AW_Industry__c == null ||oppty.AW_Market_Segment__c == null ||oppty.AW_Country__c == null||oppty.AW_Region__c == null || oppty.AW_Type__c == null ||oppty.Route_to_Market__c == null ||oppty.Type_of_Business__c == null||oppty.AW_Deployment__c== null || !ocr.isPrimary))){      //CR-00140097
                                    primaryOCROpptySet.add(oppty.ID);
                                }
                                if(!(primaryOpptyClosureRole && (oppty.Business_Line__c == null || oppty.AW_Industry__c == null ||oppty.AW_Market_Segment__c == null||oppty.AW_Country__c == null||oppty.AW_Region__c == null||oppty.AW_Type__c == null||oppty.Route_to_Market__c == null||oppty.Type_of_Business__c == null||oppty.AW_Deployment__c == null || !ocr.isPrimary))){        //CR-00140097
                                    primaryOCROpptyDealClosureSet.add(oppty.ID);
                                }
                                if(!(freeTrialPrimaryVR && (oppty.Bill_Ship_Complete__c == false || !ocr.isPrimary))){
                                    freeTrialVROpptySet.add(oppty.Id);
                                }
                            }
                        }else{
                            if(!technicalRole){
                                technicalOCROpptySet.add(oppty.ID);
                            }
                            if(!primaryRole){
                                primaryOCROpptySet.add(oppty.ID);
                            }
                            if(!primaryOpptyClosureRole){
                                primaryOCROpptyDealClosureSet.add(oppty.ID);
                            }
                            if(!freeTrialPrimaryVR){
                                freeTrialVROpptySet.add(oppty.Id);
                            }
                        }
                    //}
                }
                if(!qualifiedOppties.Values().isEmpty()){
                    for(Opportunity oppty : qualifiedOppties.Values()){
                        if(!freeTrialVROpptySet.contains(oppty.Id) && CAMsDetails != null && CAMsDetails.Enable_Free_Trial_Validation_On_Oppty__c){
                            Oppty.addError(system.label.oppFreetrialVR);
                                continue;
                        }
                        if(oppty.No_of_Airwatch_Products__c > 0){
                            if(!primaryOCROpptySet.contains(oppty.Id) && CAMsDetails != null && CAMsDetails.Enable_Contact_Role_Validation_On_Oppty__c){
                                Oppty.addError(system.label.opptyContactRoleValidation);
                                continue;
                            }
                            if(!primaryOCROpptyDealClosureSet.contains(oppty.Id) && CAMsDetails != null && CAMsDetails.L2O_Enable_Primary_Con_Deal_Closure_Val__c){
                                Oppty.addError(system.label.opptyPrimaryContactRoleDealClosure);
                                continue;
                            }
                            if(!technicalOCROpptySet.contains(oppty.Id) && CAMsDetails != null && CAMsDetails.Enable_Technical_Contact_Validation_Oppt__c){
                                oppty.addError(system.label.Techincal_contact_exception);
                                continue;
                            }
                        }
                    }
                }
            }
        }catch(Exception exc){
            ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','enforceValidationRules');
        }
    }

    /***********************************************************************************************
    Method Name: teritoryUserLookupUpdate
    Description:  method To delete Opportunity team members and to invoke createOppTeMem method when Teritory user Lookup fields are updated
    @return: None
    @throws: none
    ***********************************************************************************************/  
    @Future
    public static void teritoryUserLookupUpdate(set<Id> setUpdatedTerittories){
        try{ 
            String MSORTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
            Set<ID> setOpptyId = new Set<ID>();
            Set<String> Roles= new set<String>();
            
            Map<Id,Account> mapAcc = new Map<Id,Account>([select id from Account where Primary_Field_Sales_Territory__c IN:setUpdatedTerittories]);
            system.debug('#Accounts associated to the PSFT'+mapAcc.size());
            
            Roles.add(system.label.AW_AE_PSR);
            Roles.add(system.label.AW_SE);
            Roles.add(system.label.AW_SAM);
            Roles.add(system.label.EISR);
            
            if(mapAcc.keyset()!=null){
                for(Opportunity opp:[select id from Opportunity where AccountID IN:mapAcc.keyset() and isClosed=false and recordTypeid=:MSORTId and No_of_Airwatch_Products__c>0 AND AWOpportunityID__c!=null]){
                    setOpptyId.add(opp.id);                 
                }
                
                if(setOpptyId != null && !setOpptyId.isEmpty() && Roles != null && !Roles.isEmpty()){
                    List<OpportunityTeamMember> otmToDelete = [select id,OpportunityId from OpportunityTeamMember where OpportunityID IN :setOpptyId and TeamMemberRole In :Roles];
                    system.debug('#Oppty team members to delete'+otmToDelete.size());
                    If(otmToDelete!= null && !otmToDelete.isEmpty()){
                        try{
                            delete otmToDelete;    
                        }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','teritoryUserLookupUpdate delete otmToDelete');} 
                    }
                    
                    L2O_OpportunityHelper.createOppTeMem(setOpptyId,null);
                    
                }
            }
        }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','teritoryUserLookupUpdate');}   
    }
    
    
    /***********************************************************************************************
    Method Name: SEOverrideOnOpty (CR-00138571)
    Description:  method To update AW SE on opportunity teams when AW SE Manual Override is modified on Opportunity
    @return: None
    @throws: none
    ***********************************************************************************************/  
    public static void SEOverrideOnOpty(list<Opportunity> newList, map<Id,Opportunity> oldMap){
        try{
            Map<String,OpportunityTeamMemberRole__c> optyTeamroles=OpportunityTeamMemberRole__c.getall();
            String MSORTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
            set<Id> accids = new set<Id>();
            set<Id> OptyIds = new Set<Id>();
            Map<id,id> OptySEMap = new Map<Id,Id>();
            Map<Id,Id> optyWithNoSEOverride = new Map<Id,Id>();
            Map<id,Id> AccSEMap=new Map<id,id>();
            List<OpportunityTeamMember> teamMembersToInsert= new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> teamMembersToDelete= new List<OpportunityTeamMember>();
            
            if(newList != null && !newList.isEmpty()){
                for(Opportunity opty : newList){
                    if(oldMap.get(opty.Id) != null){
                        if(oldMap.get(opty.Id).AW_SE_Manual_Override__c!= opty.AW_SE_Manual_Override__c && !opty.isClosed && opty.recordTypeid==MSORTId && opty.No_of_Airwatch_Products__c>0 && opty.AWOpportunityID__c!=null){
                            OptyIds.add(opty.Id);
                            If(opty.AW_SE_Manual_Override__c!=null){
                                OptySEMap.put(opty.Id,opty.AW_SE_Manual_Override__c);
                            }else{
                                accids.add(opty.AccountId);
                                optyWithNoSEOverride.put(Opty.id,opty.AccountId);
                            }                       
                        }
                    }
                }
            }
            if(accids!=null && !accids.isEmpty()){
                for(Account a: [Select Id,AccountExtension__r.AW_SE_Manual_Override__c,Primary_Field_Sales_Territory__r.AW_SE__c from account where id in :accids ]){
                    if(a.AccountExtension__r.AW_SE_Manual_Override__c!=null){
                        AccSEMap.put(a.Id,a.AccountExtension__r.AW_SE_Manual_Override__c);
                    }else if(a.Primary_Field_Sales_Territory__r.AW_SE__c!=null){
                        AccSEMap.put(a.Id,a.Primary_Field_Sales_Territory__r.AW_SE__c);
                    }
                }
                for(ID oID : optyWithNoSEOverride.keySet()){
                    if(AccSEMap.get(optyWithNoSEOverride.get(oID))!=null){
                        OptySEMap.put(oID,AccSEMap.get(optyWithNoSEOverride.get(oID)));
                    }               
                }
            }
            if(OptyIds!=null && !OptyIds.isEmpty()){
                for(OpportunityTeamMember otm: [select id,OpportunityId from OpportunityTeamMember where OpportunityID IN:OptyIds and TeamMemberRole=:system.label.AW_SE]){
                    if(OptySEMap.get(otm.OpportunityId)!=null && optyTeamroles.get(system.label.AW_SE)!=null){                      
                        system.debug('OptySEMap.get(otm.OpportunityId) :'+OptySEMap.get(otm.OpportunityId));
                        OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                        opptyteaMem.OpportunityId = otm.OpportunityId;
                        opptyteaMem.UserId=OptySEMap.get(otm.OpportunityId);                                                     
                        opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_SE).name;
                        opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_SE).Access__c;
                        teamMembersToInsert.add(opptyteaMem);
                        
                    }
                    teamMembersToDelete.add(otm);                   
                }
            }
            
           
            If(teamMembersToDelete!=null && !teamMembersToDelete.isEmpty()){
                try{
                    delete teamMembersToDelete;    
                }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(), 'High','ApexClass','L2O_OpportunityHelper','SEOverrideOnOpty delete teamMembersToDelete');} 
            }
            If(teamMembersToInsert!=null && !teamMembersToInsert.isEmpty()){
                try{
                    insert teamMembersToInsert;    
                }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(), 'High','ApexClass','L2O_OpportunityHelper','SEOverrideOnOpty insert teamMembersToInsert');} 
            }
        }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(), 'High','ApexClass','L2O_OpportunityHelper','SEOverrideOnOpty');}   
    }
    
    /***********************************************************************************************
    Method Name: checkTeritoryUpdate
    Description: method for checking Teritory Update on account and deleting old territories which are in asscoaited opportunity in Opportunity team roles.
    @return: None
    @throws: none
    ***********************************************************************************************/  
    public static void checkTeritoryUpdate(list<Account> newList, map<Id,Account> oldMap){
        try{
            String MSORTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
            set<Id> accountids = new set<Id>();
            set<Id> opptyids = new set<Id>();
            Set<String> Roles= new set<String>();
            
            if(newList != null && !newList.isEmpty()){
                for(Account acc : newList){
                    if(oldMap.get(acc.Id)!= null){
                        if(oldMap.get(acc.Id).Primary_Field_Sales_Territory__c != acc.Primary_Field_Sales_Territory__c){
                            accountids.add(acc.Id);
                        }
                    }
                }
            }
            //delete old Opportunity team Members for Teritory change on Account.
            if(accountids!=null && !accountids.isEmpty()){
                
                For(Opportunity o:[select id from Opportunity where AccountId IN:accountids and isClosed=false and recordTypeid=:MSORTId and No_of_Airwatch_Products__c>0 AND AWOpportunityID__c!=null]){
                    opptyids.add(o.id);
                }
                
                if(opptyids != null && !opptyids.isEmpty()){
                    Roles.add(system.label.AW_AE_PSR);
                    Roles.add(system.label.AW_SE);
                    Roles.add(system.label.AW_SAM);
                    Roles.add(system.label.EISR);
                    list<OpportunityTeamMember> OpptyTeaMemToDelete = [Select Id from OpportunityTeamMember where OpportunityId IN:opptyids and TeamMemberRole In :Roles];
                    if(OpptyTeaMemToDelete != null && !OpptyTeaMemToDelete.isEmpty()){
                        try{
                            delete OpptyTeaMemToDelete;
                        }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','checkTeritoryUpdate delete OpptyTeaMemToDelete');}
                    }
                }
            }
            //call createOppTeMem method for creating Opportunity Team Members for Teritory Users.
            if(accountids != null && !accountids.isEmpty()){
                L2O_OpportunityHelper.createOppTeMem(null,accountids);
            }
        }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','checkTeritoryUpdate');}
    }
    
    /***********************************************************************************************
    Method Name: checkOptyAccountUpdate
    Description: method for checking account update on opportunity and deleting old territories which are in asscoaited opportunity in Opportunity team roles.
    @return: None
    @throws: none
    ***********************************************************************************************/ 
    
    public static void checkOptyAccountUpdate(list<Opportunity> newList, map<Id,Opportunity> oldMap){
        try{
            
            String MSORTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
            Set<String> Roles= new set<String>();
            set<Id> optyids = new set<Id>();
            
            if(newList != null && !newList.isEmpty()){
                for(Opportunity opty : newList){
                    if(oldMap.get(opty.Id) != null){
                        if(oldMap.get(opty.Id).Accountid!= opty.Accountid && !opty.isClosed && opty.recordTypeid==MSORTId && opty.No_of_Airwatch_Products__c>0 && opty.AWOpportunityID__c!=null){
                            optyids.add(opty.Id);
                        }
                    }
                }

            }
            
            //delete old Opportunity team Members for Teritory change on Account.
            if(optyids!=null && !optyids.isEmpty()){
                
                Roles.add(system.label.AW_AE_PSR);
                Roles.add(system.label.AW_SE);
                Roles.add(system.label.AW_SAM);
                Roles.add(system.label.EISR);
                list<OpportunityTeamMember> OpptyTeaMemToDelete = [Select Id from OpportunityTeamMember where OpportunityId IN:optyids and TeamMemberRole In :Roles];
                if(OpptyTeaMemToDelete != null && !OpptyTeaMemToDelete.isEmpty()){
                    try{
                        delete OpptyTeaMemToDelete;
                    }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','checkOptyAccountUpdate delete OpptyTeaMemToDelete');}
                }
            }
            
            //call createOppTeMem method for creating Opportunity Team Members for Teritory Users.
            if(optyids != null && !optyids.isEmpty()){
                L2O_OpportunityHelper.createOppTeMem(optyids,null);
            }
            
        } catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','checkOptyAccountUpdate');}
    }
    
    /***********************************************************************************************
    Method Name: AWSEOverrideUpdateFromAccount (CR-00138571)
    Description: method for populating AW SE override team memebers in the opptys
    @return: None
    @throws: none
    ***********************************************************************************************/ 
    public static void AWSEOverrideUpdateFromAccount(Map<id,id> accountIdSEOverrideMap){
        try{
            Map<String,OpportunityTeamMemberRole__c> optyTeamroles=OpportunityTeamMemberRole__c.getall();
            Set<id> opptyId=new Set<Id>();
            Map<id,id> OpptySEMap=new Map<id,id>();
            List<OpportunityTeamMember> otmToInsert= new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> otmToDelete= new List<OpportunityTeamMember>();
            String MSORTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
            
            for(Opportunity o :[Select Id,AW_SE_Manual_Override__c,AccountId from Opportunity where AccountId IN:accountIdSEOverrideMap.keyset() and recordTypeid=:MSORTId AND No_of_Airwatch_Products__c>0 AND AWOpportunityID__c!=null AND IsClosed=false]){
                opptyId.add(o.id);
                if(o.AW_SE_Manual_Override__c!=null){
                    OpptySEMap.put(o.id,o.AW_SE_Manual_Override__c);
                }else{
                    OpptySEMap.put(o.id,accountIdSEOverrideMap.get(o.AccountId));
                }
                
            }
            
            for(OpportunityTeamMember otm: [select id,OpportunityId from OpportunityTeamMember where OpportunityID IN:opptyId and TeamMemberRole=:system.label.AW_SE]){                
                otmToDelete.add(otm);
            }
      for(Id oid: opptyId){
        if(OpptySEMap.get(oid)!=null && optyTeamroles.get(system.label.AW_SE)!=null){
          OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
          opptyteaMem.OpportunityId = oid;
          opptyteaMem.UserId=OpptySEMap.get(oid);                                                    
          opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_SE).name;
          opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_SE).Access__c;
          otmToInsert.add(opptyteaMem);
        }
      }
            if(otmToDelete!=null){
                try{
                    delete otmToDelete;
                }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','AWSEOverrideUpdateFromAccount delete otmToDelete');}             
            }
            if(otmToInsert!=null){
                try{
                    insert otmToInsert;
                }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','AWSEOverrideUpdateFromAccount insert otmToInsert');}             
            }
        }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','AWSEOverrideUpdateFromAccount');}
    }
    
    /***********************************************************************************************
    Method Name: AWSEOverrideDeleteFromAccount (CR-00138571)
    Description: method for populating AW SE override team memebers in the opptys
    @return: None
    @throws: none
    ***********************************************************************************************/ 
    public static void AWSEOverrideDeleteFromAccount(Set<Id> AccountIDs){
        try{
            Map<String,OpportunityTeamMemberRole__c> optyTeamroles=OpportunityTeamMemberRole__c.getall();
            Set<id> opptyId=new Set<Id>();
            Map<id,id> OpptySEMap=new Map<id,id>();
            List<OpportunityTeamMember> otmToInsert= new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> otmToDelete= new List<OpportunityTeamMember>();
            String MSORTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
            
            for(Opportunity o :[Select Id,AW_SE_Manual_Override__c from Opportunity where AccountId IN:AccountIDs and recordTypeid=:MSORTId AND No_of_Airwatch_Products__c>0 AND AWOpportunityID__c!=null AND IsClosed=false]){ 
                opptyId.add(o.id);
                if(o.AW_SE_Manual_Override__c!=null){
                    OpptySEMap.put(o.id,o.AW_SE_Manual_Override__c);
                }               
            }
            
            for(OpportunityTeamMember otm: [select id,OpportunityId from OpportunityTeamMember where OpportunityID IN:opptyId and TeamMemberRole=:system.label.AW_SE]){
                if(OpptySEMap.get(otm.OpportunityId)!=null && optyTeamroles.get(system.label.AW_SE)!=null){
                    OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                    opptyteaMem.OpportunityId = otm.OpportunityId;
                    opptyteaMem.UserId=OpptySEMap.get(otm.OpportunityId);                                                    
                    opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_SE).name;
                    opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_SE).Access__c;
                    otmToInsert.add(opptyteaMem);
                }
                otmToDelete.add(otm);           
                
            }       
            if(otmToDelete!=null){
                try{
                    delete otmToDelete;
                }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','AWSEOverrideDeleteFromAccount delete otmToDelete');}             
            }
            if(otmToInsert!=null){
                try{
                    insert otmToInsert;
                }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','AWSEOverrideDeleteFromAccount insert otmToInsert');}             
            }
        }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','AWSEOverrideDeleteFromAccount');}
    }   
    
    
    /***********************************************************************************************
    Method Name: createOppTeMem
    Description: method for inserting account & opportunity related territories in Opportunity team roles.
    @return: None
    @throws: none
    ***********************************************************************************************/ 
    public static void createOppTeMem(set<Id> oppIds,set<id> accountIds){
    try{
    Map<String,OpportunityTeamMemberRole__c> optyTeamroles=OpportunityTeamMemberRole__c.getall();
    List<OpportunityTeamMember> listOpptyTeamMem = new List<OpportunityTeamMember>();
    String MSORecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
        if(oppIds != null && !oppIds.isEmpty()){
            listOpptyTeamMem = new List<OpportunityTeamMember>();
            list<Opportunity> opptyList = [Select Id,Account.Primary_Field_Sales_Territory__c,
                                            Account.Primary_Field_Sales_Territory__r.AW_AE_PSR__c,
                                            Account.Primary_Field_Sales_Territory__r.EISR__c,
                                            Account.Primary_Field_Sales_Territory__r.AW_SAM__c,
                                            Account.Primary_Field_Sales_Territory__r.AW_SE__c,
                                            Account.AccountExtension__r.AW_SE_Manual_Override__c,
                                            AW_SE_Manual_Override__c                                            
                                            from opportunity where RecordtypeId=:MSORecordTypeId AND No_of_Airwatch_Products__c>0 AND AWOpportunityID__c!=null AND IsClosed=false AND Id IN :oppIds];
            if(opptyList != null && !opptyList.isEmpty()){                                
                for(Opportunity opp : opptyList){
                    if(opp.Account.Primary_Field_Sales_Territory__c != null){
                        if(opp.Account.Primary_Field_Sales_Territory__r.AW_AE_PSR__c != null && optyTeamroles.get(system.label.AW_AE_PSR)!=null){
                            OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                            opptyteaMem.OpportunityId = opp.Id;
                            opptyteaMem.UserId = opp.Account.Primary_Field_Sales_Territory__r.AW_AE_PSR__c;
                            opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_AE_PSR).name;
                            opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_AE_PSR).Access__c;
                            listOpptyTeamMem.add(opptyteaMem);
                        }
                        if(opp.Account.Primary_Field_Sales_Territory__r.EISR__c!= null && optyTeamroles.get(system.label.EISR)!=null){
                            OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                            opptyteaMem.OpportunityId = opp.Id;
                            opptyteaMem.UserId = opp.Account.Primary_Field_Sales_Territory__r.EISR__c;
                            opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.EISR).name;
                            opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.EISR).Access__c;
                            listOpptyTeamMem.add(opptyteaMem);
                        }
                        if(opp.Account.Primary_Field_Sales_Territory__r.AW_SAM__c != null && optyTeamroles.get(system.label.AW_SAM)!=null){
                            OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                            opptyteaMem.OpportunityId = opp.Id;
                            opptyteaMem.UserId = opp.Account.Primary_Field_Sales_Territory__r.AW_SAM__c;
                            opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_SAM).name;
                            opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_SAM).Access__c;
                            listOpptyTeamMem.add(opptyteaMem);
                        }
                        if(optyTeamroles.get(system.label.AW_SE)!=null){
                            OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                            opptyteaMem.OpportunityId = opp.Id;                         
                            if(opp.AW_SE_Manual_Override__c!=null){
                                opptyteaMem.UserId = opp.AW_SE_Manual_Override__c;
                            }    
                            else if(opp.Account.AccountExtension__r.AW_SE_Manual_Override__c !=null){
                                opptyteaMem.UserId=opp.Account.AccountExtension__r.AW_SE_Manual_Override__c;
                            }
                            else if(opp.Account.Primary_Field_Sales_Territory__r.AW_SE__c != null ){
                                opptyteaMem.UserId=opp.Account.Primary_Field_Sales_Territory__r.AW_SE__c;                              
                            }  
                            opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_SE).name;
                            opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_SE).Access__c;
                            if(opptyteaMem.UserId!=null){
                                listOpptyTeamMem.add(opptyteaMem);
                            }
                        }
                    }
                }
            }         
        }
        if(accountIds != null && !accountIds.isEmpty()){
            listOpptyTeamMem = new List<OpportunityTeamMember>();
            list<Account> accountList = [Select Id,Primary_Field_Sales_Territory__c,
                                            Primary_Field_Sales_Territory__r.AW_AE_PSR__c,
                                            Primary_Field_Sales_Territory__r.EISR__c,
                                            Primary_Field_Sales_Territory__r.AW_SAM__c,
                                            Primary_Field_Sales_Territory__r.AW_SE__c,
                                            AccountExtension__r.AW_SE_Manual_Override__c,
                                            (Select Id,AW_SE_Manual_Override__c from Opportunities where RecordtypeId= :MSORecordTypeId AND AWOpportunityID__c!=null AND No_of_Airwatch_Products__c>0 AND IsClosed=false)
                                            from Account where Id IN : accountIds];
            if(accountList != null && !accountList.isEmpty()){                                
                for(Account acc : accountList){
                    if(acc.Opportunities != null && !acc.Opportunities.isEmpty()){
                        for(Opportunity opp : acc.Opportunities){
                            if(acc.Primary_Field_Sales_Territory__c != null){
                                if(acc.Primary_Field_Sales_Territory__r.AW_AE_PSR__c != null && optyTeamroles.get(system.label.AW_AE_PSR)!=null){
                                    OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                                    opptyteaMem.OpportunityId = opp.Id;
                                    opptyteaMem.UserId = acc.Primary_Field_Sales_Territory__r.AW_AE_PSR__c;
                                    opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_AE_PSR).name;
                                    opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_AE_PSR).Access__c;
                                    listOpptyTeamMem.add(opptyteaMem);
                                }
                                if(acc.Primary_Field_Sales_Territory__r.EISR__c != null && optyTeamroles.get(system.label.EISR)!=null){
                                    OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                                    opptyteaMem.OpportunityId = opp.Id;
                                    opptyteaMem.UserId = acc.Primary_Field_Sales_Territory__r.EISR__c;
                                    opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.EISR).name;
                                    opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.EISR).Access__c;
                                    listOpptyTeamMem.add(opptyteaMem);
                                }
                                if(acc.Primary_Field_Sales_Territory__r.AW_SAM__c != null && optyTeamroles.get(system.label.AW_SAM)!=null){
                                    OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                                    opptyteaMem.OpportunityId = opp.Id;
                                    opptyteaMem.UserId = acc.Primary_Field_Sales_Territory__r.AW_SAM__c;
                                    opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_SAM).name;
                                    opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_SAM).Access__c;
                                    listOpptyTeamMem.add(opptyteaMem);
                                }
                                if(optyTeamroles.get(system.label.AW_SE)!=null){
                                    OpportunityTeamMember opptyteaMem = new OpportunityTeamMember();
                                    opptyteaMem.OpportunityId = opp.Id;
                                    if(opp.AW_SE_Manual_Override__c!=null){
                                         opptyteaMem.UserId = opp.AW_SE_Manual_Override__c;
                                    }    
                                    else if(acc.AccountExtension__r.AW_SE_Manual_Override__c!=null){
                                        opptyteaMem.UserId = acc.AccountExtension__r.AW_SE_Manual_Override__c;
                                    }else if(acc.Primary_Field_Sales_Territory__r.AW_SE__c != null){
                                        opptyteaMem.UserId= acc.Primary_Field_Sales_Territory__r.AW_SE__c;                               
                                    }                                         
                                    opptyteaMem.TeamMemberRole=optyTeamroles.get(system.label.AW_SE).name;
                                    opptyteaMem.OpportunityAccessLevel=optyTeamroles.get(system.label.AW_SE).Access__c;
                                    if(opptyteaMem.UserId!=null){
                                        listOpptyTeamMem.add(opptyteaMem);
                                    }
                                }
                            }
                        }                  
                    }
                }
            }     
        }
        if(listOpptyTeamMem != null && !listOpptyTeamMem.isEmpty()){
            system.debug('#Oppty Team Members being inserted:'+listOpptyTeamMem.size());
            try{
                insert listOpptyTeamMem;
            }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','createOppTeMem insert listOpptyTeamMem');}
        }
    }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','L2O_OpportunityHelper','createOppTeMem');}
    }   
}