/*******************************************************************************************************************
 * Class Name : GSS_UpdateCaseFirstResponse
 * Purpose    : Apex Helper class  for the trigger GSS_UpdateCaseFirstResponseTime
 *
 * JIRA       : PP-17991
 * ******************************************************************************************************************
 * Author                               Date            Remarks 
 *
 * HCL-Amit                           07-oct-2010     Created
 * HCL-Amit                           09-oct-2010     Modified according to the review comments.
 * Accenture-Harish                   07-oct-2011     Modified for the CR-00006673
 * VMware-Sourabh                     28-oct-2011     Modified for CR-6610
 * Serko                              03-apr-2012     Modified for CR-00006744
 * Nilanka                            11-Feb-2013     Code commented by Nilanka for SDP (Line 70 to 75). Un-used code.
 * Harish                             12-Feb-2013     Null check for Old cases while uplifting/downgrading Severity
 * Mayur Srivastava                   06-Nov-2015     SDP Nov Release | CR-00121548
 * Ananth Krishna                     16-Feb-2016     CGS related changes
 * Pabitra Pramanick				  08-aug-2016	  CR-00140109:Removed System.debug
 * ****************************************************************************************************************/

global class GSS_UpdateCaseFirstResponse{
    
    
      public static Map<Id,String> oldCasesInUpdate;  // Harish Patkar : Added for CR-00006673
      /** Start BB-8 Changes Jira:BB-77 Declaring variables **/
      public static Map<String,CaseMilestone> cgsMilestoneMap = new Map<String,CaseMilestone>();
    public static Set<Id> premierCaseIdsSet = new Set<Id>(); //BB-8 : set of premier type cases
    public static Boolean runPopulateCGSMilestone = false;
    public static Map<id,CaseMilestone> responseFirstResponseCompletedDates = new Map<id,CaseMilestone>();
	 /** End BB-8 Changes Jira:BB-77 Declaring variables **/
	/* 
     * Called from webservice - Method to update the first response due date 
     * Updates only if the first response due date changed
     * params: Set<Id> - Set of Case Ids
     * returns: none
     */
    public static void updateFirstResponse(Set<Id> newCaseIds){
       
        Map<Id, DateTime> responseDates = getResponseDates(newCaseIds);
        List<Case> casesToUpdate = new List<Case>();
      
        system.debug('***** Commit time is not NULL ***$$$$ ' +GSS_UpdateCaseFirstResponse.oldCasesInUpdate );
        
        //build set of Entitlements that prevent updating the First Response Field CR-00006744
        Map<String,GSSEntitlements__c> Ent_codes = GSSEntitlements__c.getAll();
        Set<String> Ent_codes_List = new Set<String>();
        
        for (GSSEntitlements__c ent : Ent_codes.values()) {
            try {
                Ent_codes_List.add((String)(ent.Entitlement_Code__c));
            } catch (Exception e) {CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'GSSEntitlements__c', 'GSS_UpdateCaseFirstResponse');}
        }
        system.debug('*GSSEntitlements__c from Custom settings ' + Ent_codes_List );
        
        if ( !responseDates.isEmpty() ) {
            //06/11/2015  Mayur Srivastava  SDP Nov Release | CR-00121548 - Added RecordTypeID, OwnerID and Owner Email in SOQL
            List<Case> cases = new List<Case>([Select Id, RecordTypeId, OwnerID, Owner.Email, GSS_First_Response_Due_Date__c, Priority, GSS_Entitlement_Code__c from Case where Id In :responseDates.keySet()]);
            for(Case caseObject : cases ) {
                
		// CR-00006673 : Update this method as a part of CR-00006673 : Starts here  
                 //CR-6610:Sourabh:4-Nov-2011 - added condition to exclude VCE entitlement     
                
		 // CR-00006744
            system.debug('***** Check GSS Entitlement Code for exclutions ~~~~~ ' +caseObject.GSS_Entitlement_Code__c );
                if (!Ent_codes_List.contains(caseObject.GSS_Entitlement_Code__c)){
                      
                    if(caseObject.GSS_First_Response_Due_Date__c != null && caseObject.GSS_Entitlement_Code__c != 'VCE'){
                        if (oldCasesInUpdate !=null && responseDates.containsKey(caseObject.Id) && 
                            isFirstResponseTimeUpdate(caseObject.GSS_First_Response_Due_Date__c ,responseDates.get(caseObject.Id)) &&
                            isSeverityUpgraded(caseObject.Priority, oldCasesInUpdate.get(caseObject.Id))) {
                                system.debug('****Severity is upgraded and should be updated ****');    
                                caseObject.GSS_First_Response_Due_Date__c = responseDates.get(caseObject.Id);   
                                casesToUpdate.add(caseObject);
                        }
                        // Code commented by Nilanka on 11-Feb-2013 for SDP. 
                        // This loop is only used to print a single line, no business logic associated.
                        // This line is throwing Null-Pointer exception sometime, based on certain input condition experienced in SDP.                        
                        /**else if(responseDates.containsKey(caseObject.Id) &&
                                !isFirstResponseTimeUpdate(caseObject.GSS_First_Response_Due_Date__c ,responseDates.get(caseObject.Id)) &&
                                isSeverityUpgraded(caseObject.Priority, oldCasesInUpdate.get(caseObject.Id))
                                ){
                                    system.debug('**** Severity is not needed to be updated ****'); 
                            }**/
                    
                        else if(oldCasesInUpdate !=null && responseDates.containsKey(caseObject.Id) &&
                                !isSeverityUpgraded(caseObject.Priority, oldCasesInUpdate.get(caseObject.Id))){
                                system.debug('**** Severity Downgraded IT has to be updated ******************** ');
                                caseObject.GSS_First_Response_Due_Date__c = responseDates.get(caseObject.Id);
                                casesToUpdate.add(caseObject);
                                }
                    }
                
                    else{
                        if (responseDates.containsKey(caseObject.Id)) {
                        caseObject.GSS_First_Response_Due_Date__c = responseDates.get(caseObject.Id);
                        casesToUpdate.add(caseObject);
                        }
                    }
                }
            }
            // CR-00006673 : Ends here 

            
            system.debug('***** Is Case elegible for update  ****' + casesToUpdate.isEmpty());
            if ( !casesToUpdate.isEmpty() )
                update casesToUpdate;
      
      //06/11/2015  Mayur Srivastava  SDP Nov Release | CR-00121548 - Starts
      
      //system.debug('***** First Response Due Date  ****' + casesToUpdate[0].GSS_First_Response_Due_Date__c+'Contact ID is'+casesToUpdate[0].ContactID+'Owner ID is'+casesToUpdate[0].OwnerID+'Owner Email is'+casesToUpdate[0].Owner.Email);
      
      GSS_ServiceNow_Parameters__c  SDPchecks = GSS_ServiceNow_Parameters__c.getOrgDefaults();
      List<Case> caselist = new List<Case>();
      
      if(!casesToUpdate.isEmpty())
      {
          for(Case c : casesToUpdate)
          {
            //system.debug('Inside for loop - Kill Switch Value '+SDPchecks.CarpathiaOwnerEmailcheck__c+' Record Type Id '+c.RecordTypeId+' Record Type ID '+Record_Type_Settings__c.getInstance('GSS_CASE_SDP_FED').Record_Type_ID__c+' Static Variable '+GSS_UtilityClass.isCarpathiaEmailSent);
            
            if(SDPchecks.CarpathiaOwnerEmailcheck__c && (c.RecordTypeId == Record_Type_Settings__c.getInstance('GSS_CASE_SDP_FED').Record_Type_ID__c) && (c.GSS_First_Response_Due_Date__c != null) && !GSS_UtilityClass.isCarpathiaEmailSent)
            {
              caselist.add(c);
            }
          }
      }
      if(caselist!=NULL && !caselist.isEmpty())
      {
        GSS_UtilityClass.sendEmailtoOwner(caselist);
      }
      //06/11/2015  Mayur Srivastava  SDP Nov Release | CR-00121548 - Ends
        }
    
    // Ananth || 17-Feb-2016 || CGS related changes
            if(!responseDates.isEmpty() && !cgsMilestoneMap.isEmpty()){
            //map to hold all sla related cgs case
            Map<Id,Case_SLA__c> cgsCaseSLAMap = new Map<Id,Case_SLA__c>();
            Set<String> milestoneNames = new Set<String>{Label.Final_Correction,Label.RCA_Due,Label.Service_Restoration};
            // retrive all CGS related milestones
            List<MilestoneType> milestoneList = [SELECT Id, Name FROM MilestoneType where name IN : milestoneNames];
            // create a map of milestones
            Map<String, Id> milestoneMap = new Map<String, Id>();    
            for (MilestoneType mt : milestoneList ){
                milestoneMap.put(mt.name , mt.id); 
                system.debug('mt.name :: '+mt.name);                
                system.debug('mt.id :: '+mt.id);
            }
            
            // retrieve all cgs milesontes associated to Cases
            for(Case_SLA__c cSLA : [SELECT Case__c,Service_restoration_due__c,Final_Correction_due__c,
                                            RCA_Due__c,First_Response_Due_Date__c FROM Case_SLA__c 
                                            WHERE Case__c IN : newCaseIds]){
                cgsCaseSLAMap.put(cSLA.Case__c,cSLA);
                system.debug('cSLA :: '+cSLA);
                system.debug('cSLA :: '+cSLA.Case__c);
            }
            
            system.debug('Existing cases :: '+newCaseIds);
            
            List<Case_SLA__c> cgsCaseSLA = new List<Case_SLA__c>();
            Case_SLA__c cgsCase;
            CaseMilestone milestone;
            for(Id caseId : newCaseIds){
              milestone = null;
                // use case - cgs case sla's doesnt exist
                if(!cgsCaseSLAMap.containsKey(caseId)){
                        cgsCase = new Case_SLA__c();
                        String cmId = caseid;
                        system.debug('CASE ID :: '+cmId);
                        system.debug('milestoneMap.get(Label.Service_Restoration) :: '+milestoneMap.get(Label.Service_Restoration));
                        system.debug(':: :: '+cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration)));
                        milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration));
                        if(milestone != null){
                          System.debug('checking Label.Service_Restoration');
                            cgsCase.Service_restoration_due__c = milestone.TargetDate;
                        }   
                        milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction));
                        if(milestone != null){
                          System.debug('checking Label.Final_Correction');
                            cgsCase.Final_Correction_due__c = milestone.TargetDate;
                        }
                        milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due));
                        if(milestone != null){
                          System.debug('checking Label.RCA_Due');
                            cgsCase.RCA_Due__c = milestone.TargetDate;
                        }
                        Datetime responseDueDate = responseDates.get(caseId);
                        if(responseDueDate != null){
                        cgsCase.First_Response_Due_Date__c = responseDueDate;
                        }                   
                        cgsCase.Case__c = caseId;
                        //add to list
                        cgsCaseSLA.add(cgsCase);
                    //end of IF
                }else{
                    // use case - cgs case sla's exist - update them
                    cgsCase = cgsCaseSLAMap.get(caseId);
                    System.debug('Degrading Milestone****'+cgsCase);
                    Boolean isChanged = false;
                    String cmId = caseid;
          
                    //Service Restoration
          if(cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration)) != null){
            milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration));
            
            if(cgsCase.Service_restoration_due__c != milestone.TargetDate){
                cgsCase.Service_restoration_due__c = milestone.TargetDate;
                isChanged = true;
            }
                    }
          
          //Final Correction
          if(cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction)) != null){
            milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction));
            if(cgsCase.Final_Correction_due__c != milestone.TargetDate){
                cgsCase.Final_Correction_due__c = milestone.TargetDate;
                isChanged = true;
            }
                    }
          
          //RCA
          if(cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due)) != null){
            milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due));
            if(cgsCase.RCA_Due__c != milestone.TargetDate){
              cgsCase.RCA_Due__c = milestone.TargetDate;
              isChanged = true;
            }
                    }
                    
          //check For Severity Degrade
          if(cgsCase.Service_restoration_due__c!= null && cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration))==null){
            cgsCase.Service_restoration_due__c = null;
            cgsCase.Service_restoration_actual__c = null;
            System.debug('Degrading service restoration****');
            isChanged = true;
          }
          if(cgsCase.RCA_Due__c!= null && cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due))==null){
            cgsCase.RCA_Due__c = null;
            cgsCase.RCA_Delivered__c = null;
            System.debug('Degrading RCA****');
            isChanged = true;
          }
          if(cgsCase.Final_Correction_due__c!= null && cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction))==null){
            cgsCase.Final_Correction_due__c = null;
            cgsCase.Final_Correction_actual__c = null;
            System.debug('Degrading Final_Correction****');
            isChanged = true;
          }
          
          Datetime responseDueDate = responseDates.get(caseId);
                    if(cgsCase.First_Response_Due_Date__c != responseDueDate){
                        cgsCase.First_Response_Due_Date__c = responseDueDate;
                        isChanged = true;
                    }
                        
                    //add to update list
                    if(isChanged){
                        cgsCaseSLA.add(cgsCase);
                    }
                }//end of else
        
      }//end of for           
                    //system.debug('MilestoneTypeId :: '+milestone.MilestoneTypeId);                  
                    //system.debug('Service_restoration_due__c :: '+cgsCase.Service_restoration_due__c);
                   // system.debug('Final_Correction_due__c :: '+cgsCase.Final_Correction_due__c);
                   // system.debug('RCA_Due__c :: '+cgsCase.RCA_Due__c);
                   // system.debug('First_Response_Due_Date__c :: '+cgsCase.First_Response_Due_Date__c);
                    
             try{
              if ( !cgsCaseSLA.isEmpty() ){
                      for(Database.UpsertResult ur : Database.upsert(cgsCaseSLA,false)){
                          if(ur.isSuccess()){
                              //myIds.add(ur.getId());
                              system.debug(' ++++++++++++ '+ur.getId());
                          }else{
                              for(Database.Error err : ur.getErrors()){
                              String errorMsgs = ur.getId() + ': ' + err.getMessage() + '(' + err.getStatusCode() + ')' + '\n';  
                              CreateApexErrorLog.insertHandledExceptions(null, null, null, null, 'ApexClass', 'Case_SLA__c', 'GSS_UpdateCaseFirstResponse:CaseID :errorMsgs '); 
                              system.debug(' ++++++++++++ '+errorMsgs);
                              }
                          }
                      }
              }//end of DML IF
             }   catch (Exception e) {CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Case_SLA__c', 'GSS_UpdateCaseFirstResponse');}   
        }
    // Ananth || 17-Feb-2016 || CGS related changes
            
    }//end of the method
    
    
    public static void populateCGSMilestones(Map<Id, DateTime> responseDates, Set<Id> newCaseIds){
    
        // Ananth || 17-Feb-2016 || CGS related changes
            system.debug('entering  populateCGSMilestones:: runPopulateCGSMilestone--'+runPopulateCGSMilestone);   
            if(!cgsMilestoneMap.isEmpty()  && (!responseDates.isEmpty() || runPopulateCGSMilestone)){
              system.debug('entering first if condition of  populateCGSMilestones:: ');   
            //map to hold all sla related cgs case
            Map<Id,Case_SLA__c> cgsCaseSLAMap = new Map<Id,Case_SLA__c>();
            Set<String> milestoneNames = new Set<String>{Label.Final_Correction,Label.RCA_Due,Label.Service_Restoration};
            // retrive all CGS related milestones
            List<MilestoneType> milestoneList = [SELECT Id, Name FROM MilestoneType where name IN : milestoneNames];
            // create a map of milestones
            Map<String, Id> milestoneMap = new Map<String, Id>();    
            for (MilestoneType mt : milestoneList ){
                milestoneMap.put(mt.name , mt.id); 
                system.debug('mt.name :: '+mt.name);                
                system.debug('mt.id :: '+mt.id);
            }
            
            // retrieve all cgs milesontes associated to Cases
            for(Case_SLA__c cSLA : [SELECT Case__c,Service_restoration_due__c,Final_Correction_due__c,
                                            RCA_Due__c,First_Response_Due_Date__c FROM Case_SLA__c 
                                            WHERE Case__c IN : newCaseIds]){
                cgsCaseSLAMap.put(cSLA.Case__c,cSLA);
                system.debug('cSLA :: '+cSLA);
                system.debug('cSLA :: '+cSLA.Case__c);
            }
            
            system.debug('Existing cases :: '+newCaseIds);
            
            List<Case_SLA__c> cgsCaseSLA = new List<Case_SLA__c>();
            Case_SLA__c cgsCase;
            CaseMilestone milestone;
            for(Id caseId : newCaseIds){
                // use case - cgs case sla's doesnt exist
                if(!cgsCaseSLAMap.containsKey(caseId)){
                        cgsCase = new Case_SLA__c();
                        String cmId = caseid;
                        system.debug('CASE ID :: '+cmId);
                        system.debug('milestoneMap.get(Label.Service_Restoration) :: '+milestoneMap.get(Label.Service_Restoration));
                        system.debug(':: :: '+cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration)));
                        milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration));
                        if(milestone != null){
                            cgsCase.Service_restoration_due__c = milestone.TargetDate;
                        }   
                        milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction));
                        if(milestone != null){
                            cgsCase.Final_Correction_due__c = milestone.TargetDate;
                        }
                        milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due));
                        if(milestone != null){
                            cgsCase.RCA_Due__c = milestone.TargetDate;
                        }
            System.debug('responseFirstResponseCompletedDates*****'+responseFirstResponseCompletedDates); // This will be populated when entitlemetn is changed after completing the first response
            if(!runPopulateCGSMilestone){ //This condition will rarely come as the slas will already be populated while insertion
              Datetime responseDueDate = responseDates.get(caseId);
              if(responseDueDate != null){
              cgsCase.First_Response_Due_Date__c = responseDueDate;
              }
            } 
			else if(runPopulateCGSMilestone && !responseFirstResponseCompletedDates.keySet().isEmpty()){
			//This is for scenario where first response is completed and then the user is changing the entitlement to CGS
				CaseMilestone firstResponseMilestone = responseFirstResponseCompletedDates.get(caseId);
				if(firstResponseMilestone != null){
					cgsCase.First_Response_Due_Date__c = firstResponseMilestone.TargetDate;
					cgsCase.First_Response_Due_In__c = firstResponseMilestone.CompletionDate;
				}
			}
                        cgsCase.Case__c = caseId;
                        //add to list
                        cgsCaseSLA.add(cgsCase);
                    //end of IF
                }else{
                    // use case - cgs case sla's exist - update them
                    cgsCase = cgsCaseSLAMap.get(caseId);
                    System.debug('Degrading Milestone****'+cgsCase);
                    Boolean isChanged = false;
                    String cmId = caseid;
          milestone = null;
          System.debug('cgsMilestoneMap Milestone****'+cgsMilestoneMap);
                    //Service Restoration
          if(cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration)) != null){
            milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration));
            System.debug('Service_Restoration Milestone****');
            if(cgsCase.Service_restoration_due__c != milestone.TargetDate){
                cgsCase.Service_restoration_due__c = milestone.TargetDate;
                isChanged = true;
                System.debug('Service_Restoration Milestone changed****');
            }
                    }
          
          //Final Correction
          if(cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction)) != null){
            milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction));
            System.debug('Final_Correction Milestone****');
            if(cgsCase.Final_Correction_due__c != milestone.TargetDate){
                cgsCase.Final_Correction_due__c = milestone.TargetDate;
                isChanged = true;
                System.debug('Final_Correction Milestone chagned****');
            }
                    }
          
          //RCA
          if(cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due)) != null){
            milestone = cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due));
            System.debug('RCA_Due Milestone****');
            if(cgsCase.RCA_Due__c != milestone.TargetDate){
              cgsCase.RCA_Due__c = milestone.TargetDate;
              isChanged = true;
              System.debug('RCA_Due Milestone chagned****');
            }
                    }
                    
          //check For Severity Degrade
          if(cgsCase.Service_restoration_due__c!= null && cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Service_Restoration))==null){
            cgsCase.Service_restoration_due__c = null;
            cgsCase.Service_restoration_actual__c = null;
            System.debug('Degrading service restoration****');
            isChanged = true;
          }
          if(cgsCase.RCA_Due__c!= null && cgsMilestoneMap.get(cmId + milestoneMap.get(Label.RCA_Due))==null){
            cgsCase.RCA_Due__c = null;
            cgsCase.RCA_Delivered__c = null;
            System.debug('Degrading RCA****');
            isChanged = true;
          }
          if(cgsCase.Final_Correction_due__c!= null && cgsMilestoneMap.get(cmId + milestoneMap.get(Label.Final_Correction))==null){
            cgsCase.Final_Correction_due__c = null;
            cgsCase.Final_Correction_actual__c = null;
            System.debug('Degrading Final_Correction****');
            isChanged = true;
          }
                    
                    if(!runPopulateCGSMilestone){ //Dont stamp first response if it is already populated
            Datetime responseDueDate = responseDates.get(caseId);
            if(cgsCase.First_Response_Due_Date__c != responseDueDate){
              cgsCase.First_Response_Due_Date__c = responseDueDate;
              isChanged = true;
            }
                    }    
                    //add to update list
                    if(isChanged){
                        cgsCaseSLA.add(cgsCase);
                    }
                }//end of else
            }//end of for           
                    //system.debug('MilestoneTypeId :: '+milestone.MilestoneTypeId);                  
                    //system.debug('Service_restoration_due__c :: '+cgsCase.Service_restoration_due__c);
                   // system.debug('Final_Correction_due__c :: '+cgsCase.Final_Correction_due__c);
                   // system.debug('RCA_Due__c :: '+cgsCase.RCA_Due__c);
                   // system.debug('First_Response_Due_Date__c :: '+cgsCase.First_Response_Due_Date__c);
                    
             try{
              if ( !cgsCaseSLA.isEmpty() ){
                      for(Database.UpsertResult ur : Database.upsert(cgsCaseSLA,false)){
                          if(ur.isSuccess()){
                              //myIds.add(ur.getId());
                              system.debug(' ++++++++++++ '+ur.getId());
                          }else{
                              for(Database.Error err : ur.getErrors()){
                              String errorMsgs = ur.getId() + ': ' + err.getMessage() + '(' + err.getStatusCode() + ')' + '\n';   
                              CreateApexErrorLog.insertHandledExceptions(null, null, null, null, 'ApexClass', 'Case_SLA__c', 'GSS_UpdateCaseFirstResponse:CaseID :errorMsgs ');
                              system.debug(' ++++++++++++ '+errorMsgs);
                              }
                          }
                      }
              }//end of DML IF
             }   catch (Exception e) {CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Case_SLA__c', 'GSS_UpdateCaseFirstResponse');}   
        }
    // Ananth || 17-Feb-2016 || CGS related changes
            
    }//end of the method

    /* 
     * Future method to update the first response due date 
     * Updates only if the first response due date changed
     * params: Set<Id> - Set of Case Ids
     * returns: none
     */
     
    @future
    public static void futureUpdateResponseDate(Set<Id> newCaseIds) {
        updateFirstResponse(newCaseIds);        
    }
    
    @future
    public static void futureUpdateResponseDate(Set<Id> newCaseIds,Map<Id,String> oldCasesInUpdatenew) {
        oldCasesInUpdate = oldCasesInUpdatenew;
        updateFirstResponse(newCaseIds);        
    }
    
    @future
    public static void futureUpdateResponseDate(Set<Id> newCaseIds,Map<Id,String> oldCasesInUpdatenew, boolean isTAMMailSentCheck) {        
        oldCasesInUpdate = oldCasesInUpdatenew;
        GSS_UtilityClass.IsTAMMailSent = isTAMMailSentCheck;
        updateFirstResponse(newCaseIds);      //CGS change BB-8 project  
    }
  /** CGS Method to get slas stamped **/
  @future
    public static void futureUpdateResponseDate(Set<Id> newCaseIds,Map<Id,String> oldCasesInUpdatenew, boolean isTAMMailSentCheck,Set<Id> premierCaseIds) {        
        
        System.debug('Entered Gss_UpdateCaseFirstResponse::futureUpdateResponseDate with 4 params ::premierCaseIds'+premierCaseIds);
        oldCasesInUpdate = oldCasesInUpdatenew;
        GSS_UtilityClass.IsTAMMailSent = isTAMMailSentCheck;
    premierCaseIdsSet = premierCaseIds ;    
    System.debug('Entered Gss_UpdateCaseFirstResponse::futureUpdateResponseDate with 4 params ::premierCaseIdsSet'+premierCaseIdsSet);
        updateFirstResponse(newCaseIds);        
    }
    
    /**
     * For existing code to work without issues
     * @param caseRecords
     * @return caseRecords
     */
    public static List<Case> getResponseDates(List<Case> caseRecords) {
        
        Set<Id> newCaseIds = new Set<Id>();
        for(Case cs : caseRecords ) {
            newCaseIds.add(cs.Id);
        }
        
        Map<Id, DateTime> responseDates = getResponseDates(newCaseIds);
        for( Case caseObject : caseRecords ) {
            if ( responseDates.containsKey(caseObject.Id) )
                caseObject.GSS_First_Response_Due_Date__c = responseDates.get(caseObject.Id);
        }       
        return caseRecords;
    }


    /*
     * Private method to return the first response due dates from 
     * CaseMileStone objects
     * params: Set<Id> - Set of Case Ids
     * returns: Map<Id, DateTime> - Map of Case Id and First response due date
     */
    private static Map<Id, DateTime> getResponseDates(Set<Id> caseIds) {
    /** CGS BB-8 changes Start **/
        System.debug('Entered getResponseDates');
        Map<id,DateTime> responseDates = new Map<id,DateTime>();
        Map<id,CaseMilestone> milestoneMap = new Map<id,CaseMilestone>();
        responseFirstResponseCompletedDates = new Map<id,CaseMilestone>();
        if ( caseIds.size() > 0 ) {
            for(CaseMilestone milestone : [select TargetDate, caseId, IsCompleted, MilestoneTypeId,CompletionDate from CaseMilestone
                                             where caseid IN: caseIds  order by caseid, targetdate]){
                if(!milestoneMap.containsKey(milestone.caseId) &&  milestone.MilestoneTypeId == Label.MilestoneTypeId ) // will run only for fisrt response milestone
                    milestoneMap.put(milestone.caseId, milestone);
                else{
                    String case_milesstone_Id = milestone.caseId;
                    system.debug('CASE ID :: '+ case_milesstone_Id);
                    case_milesstone_Id = case_milesstone_Id + milestone.MilestoneTypeId;
                    system.debug('MILESTONE ID :: '+ milestone.MilestoneTypeId);
                    cgsMilestoneMap.put(case_milesstone_Id, milestone);
                    system.debug('case_milesstone_Id :: '+ case_milesstone_Id);
                    system.debug('cgsMilestoneMap :: '+ cgsMilestoneMap);
                }
            }
            system.debug('milestoneMap :: '+ milestoneMap);
            if ( !milestoneMap.isEmpty() )
            {
                for(Id caseId : caseIds ) 
                {
                    CaseMilestone milestone = milestoneMap.get(caseId);
                    if( milestone != null && !milestone.IsCompleted )
                        responseDates.put(caseId, milestone.TargetDate);
					else if( milestone != null && milestone.IsCompleted )
                        responseFirstResponseCompletedDates.put(caseId, milestone);	
                }
            }
        }
    system.debug('getResponseDates->responseDates :: '+ responseDates);
    if(responseDates.keySet().isEmpty() && !premierCaseIdsSet.isEmpty()){//case is degraded manually whose first response date is already complete
      runPopulateCGSMilestone = true; //Mark the flag to specially populate the premier entitlment SLAs
      system.debug('calling GSS_updateCaseFirstResponse populateCGSMilestones premierCaseIdsSet*** '+ premierCaseIdsSet);
      populateCGSMilestones(responseDates,premierCaseIdsSet);
    }
        return responseDates;
    } 
     /** CGS BB-8 changes End **/
     /** Created for CGS BB-8 project JIRA:BB-77**/
  
      public static Map<Id, DateTime> getCGSResponseDates(Set<Id> caseIds) {
        
        Map<id,DateTime> responseDates = new Map<id,DateTime>();
        Map<id,CaseMilestone> milestoneMap = new Map<id,CaseMilestone>();
        
        if ( caseIds.size() > 0 ) {
            for(CaseMilestone milestone : [select TargetDate, caseId, CompletionDate,IsCompleted, MilestoneTypeId from CaseMilestone
                                             where caseid IN: caseIds  order by caseid, targetdate]){
                if(!milestoneMap.containsKey(milestone.caseId) &&  milestone.MilestoneTypeId == Label.MilestoneTypeId )
                    milestoneMap.put(milestone.caseId, milestone);
                else{
                    String case_milesstone_Id = milestone.caseId;
                    system.debug('CASE ID :: '+ case_milesstone_Id);
                    case_milesstone_Id = case_milesstone_Id + milestone.MilestoneTypeId;
                    system.debug('MILESTONE ID :: '+ milestone.MilestoneTypeId);
                    cgsMilestoneMap.put(case_milesstone_Id, milestone);
                    system.debug('case_milesstone_Id :: '+ case_milesstone_Id);
                    system.debug('cgsMilestoneMap :: '+ cgsMilestoneMap);
                }
            }
             
            if ( !milestoneMap.isEmpty() )
            {
                for(Id caseId : caseIds ) 
                {
                    CaseMilestone milestone = milestoneMap.get(caseId);
                    if( milestone != null && !milestone.IsCompleted )
                        responseDates.put(caseId, milestone.TargetDate);
                }
            }
        }
        return responseDates;
    }

    /**
      * Called by After Insert Trigger
      */
    public static void AI_FirstResponse(List<Case> GSSCases) {
        
        // Added to ignore the future call if its called from web service
        // as the Response due date is set in the web service code itself
     
        if ( GSS_UtilityClass.isWebServiceCall )
            return; 
            
        // Code START to launch first response future method
        Set<Id> newCaseIds = new Set<Id>();
        
        //Added for ByPassing the Trigger in Case of Data Migration
        Boolean flag = ByPassTrigger.userCustomMap('GSS_UpdateCaseFirstResponse','Case');  
      
        if( !flag ) {
            for(Case cs : GSSCases) {
                newCaseIds.add(cs.Id);
            }
        
            if( newCaseIds.size() > 0 ) {
          
                GSS_UpdateCaseFirstResponse.futureUpdateResponseDate(newCaseIds);
             
            }
        }
    }
    
    /**
      * Called by After Update Trigger
      */
    public static void AU_FirstResponse(List<Case> GSSCases, Map<ID,Case>oldMap) {
        
        // Added to ignore the future call if its called from web service
        // as the Response due date is set in the web service code itself
        if ( GSS_UtilityClass.isWebServiceCall )
            return; 
        
        Case oldCase; 
        Set<Id> newCaseIds = new set<Id>();
    
        //Added for BB-8
    Map<String , GSS_Premier_Entitlement__c > premierEnt  = GSS_Premier_Entitlement__c.getAll();
        Set<String> entNameSet = new Set<String>();
    
        for(GSS_Premier_Entitlement__c entObj : premierEnt.values()){
                    // Pick all active premier entitlements
                    if(entObj.isActive__c  ){
                        entNameSet.add(entObj.Code__c);
                    }
        }
    //End for BB-8
    
        //Added for ByPassing the Trigger in Case of Data Migration
        Boolean flag = ByPassTrigger.userCustomMap('GSS_UpdateCaseFirstResponse','Case');
        if( !flag ){
            oldCasesInUpdate = new Map<Id,String>(); 
             //Begin:Sourabh:CR-6610:28-Oct-2010
             Set<Id> vceCaseList= new Set<Id>();  
            //End:Sourabh:CR-6610:28-Oct-2010
			//CR-00140109:Removed System.debug
            //System.debug('#####GSSCases:='+GSSCases);                  
            for(Case cs : GSSCases) {
                oldCase = oldMap.get(cs.id);
				//CR-00140109:Removed System.debug
                //System.debug('#####oldCase :='+oldCase );
                //System.debug('#####cs:='+cs);
             if(  (oldCase != null && cs!=null && cs.Priority != oldCase.Priority ) || ( oldCase != null && cs!=null && cs.EntitlementId != oldCase.EntitlementId)
                    || ( oldCase != null && cs!=null && cs.GSS_Support_Customer_Region__c != oldCase.GSS_Support_Customer_Region__c)
                    || ( oldCase != null && cs!=null && oldCase.Description == 'Enter Customer Description Here' && cs.Description != oldCase.Description))
 {
                   
                    newcaseIds.add(cs.Id);
                    oldCasesInUpdate.put(oldCase.Id, oldCase.Priority);
                    //Begin:Sourabh:CR-6610:3-Nov-2010 
                    if(cs.GSS_Entitlement_Code__c == 'VCE')
                     {
                       vceCaseList.add(cs.id); 
                     }                    
                    //End:Sourabh:CR-6610:3-Nov-2010
                    
          //Query for premier entitlement BB-8 changes
          if(entNameSet!= null &&  cs.GSS_Entitlement_Code__c!= null && entNameSet.contains(cs.GSS_Entitlement_Code__c)){
          System.debug('Preparing GSS_UpdateCaseFirstResponse :: premierCaseIdsSet****');
                       premierCaseIdsSet.add(cs.id); 
                     }
          
          }
            }
            //Begin:Sourabh:CR-6610:3-Nov-2010
            if( vceCaseList.size() > 0 )
               {
                 List<Case> cx = new List<Case>([Select Id, SlaStartDate, CreatedDate from Case where Id In :vceCaseList]);
                 for(Case co : cx ) 
                     {   
                       co.SlaStartDate = co.CreatedDate;    
                     }      
                 try
                 {
                    update cx; 
                 }  
                 catch ( System.DmlException e) 
                 {
                   System.debug(e.getMessage());
                 }
               }
            //End:Sourabh:CR-6610:3-Nov-2010   
	    /** Start - BB-8 changes **/
            if( newCaseIds.size() > 0 && !premierCaseIdsSet.isEmpty()){
               System.debug('calling GSS_UpdateCaseFirstResponse.futureUpdateResponseDate****'+premierCaseIdsSet);
                GSS_UpdateCaseFirstResponse.futureUpdateResponseDate(newCaseIds,oldCasesInUpdate,GSS_UtilityClass.IsTAMMailSent,premierCaseIdsSet);
            }
            /** End - BB-8 changes **/
       else if(newCaseIds.size() > 0){
              GSS_UpdateCaseFirstResponse.futureUpdateResponseDate(newCaseIds,oldCasesInUpdate,GSS_UtilityClass.IsTAMMailSent);
            }     
        }//if(flag==false){
    }
    
    
  /*********************************************************************************************** 
        Method Name       : isSeverityUpgraded
        Author            : Harish Patkar (Accenture)
        CR #              : CR-00006673
        @ Param           : String, String
        @ Return          : Boolean
        Description       : This method is used to check whether Severity is upgrated or degraded
     ***********************************************************************************************/
    
    public static boolean isSeverityUpgraded(String newSeverity, String oldSeverity){
        system.debug('Checking Priority ** NEW **'+ newSeverity + ' ** OLD ** '+oldSeverity);
        if(newSeverity != '' && newSeverity != null && oldSeverity != '' && oldSeverity != null){
            Integer newSeverityValue = Integer.valueOf((newSeverity.substring(0,1)).trim());
            Integer oldSeverityValue = Integer.valueOf((oldSeverity.substring(0,1)).trim());    
            if(newSeverityValue < oldSeverityValue){
                return true;
            }   
        }
        
        return false;
    }


  /*********************************************************************************************** 
        Method Name       : isFirstResponseTimeUpdate
        Author            : Harish Patkar (Accenture)
        CR #              : CR-00006673
        @ Param           : DateTime, DateTime
        @ Return          : Boolean
        Description       : This method is used to check the correct Response Time. 
     ***********************************************************************************************/

    public static boolean isFirstResponseTimeUpdate(Datetime oldFirstResponseTime, Datetime newFirstResponseTime){
        
        System.debug('NEW FTIME = '+newFirstResponseTime +' OLD FTIME = '+oldFirstResponseTime + ' TIME NOW = '+ System.now());
        
        Datetime timeNow = System.now();

        if( (oldFirstResponseTime.getTime() - timeNow.getTime()) > (newFirstResponseTime.getTime() - timeNow.getTime())){
            return true;
        }else{
            return false;
        }       
        return false;
        
    }

//CR 12844 Starts

 /*********************************************************************************************** 
        Method Name       : updateCustomerFR
        Author            : Shridhar Patankar (Accenture)
        CR #              : CR-00012844
        @ Param           : DateTime, DateTime
        @ Return          : void
        Description       : This method is used to check the correct Response Time.
        Updated           : Nitin Bhalla CR-12844(DST Implementation) 27-Aug-2012 
     ***********************************************************************************************/

    public static void updateCustomerFR(List<Case> GSSCases){
        system.debug('GSS_UpdateCaseFirstResponse :: updateCustomerFR :: Starts');
        
        for(Case cs : GSSCases) {   
        system.debug('@@@ Case Detail 12844 +'+cs);
            if(cs.GSS_First_Response_Due_Date__c !=null && cs.GSS_Time_Zone__c !=null ){
               DateTime myDate2;
               Datetime cusTime = cs.GSS_First_Response_Due_Date__c;
                System.debug('cusTime 12844  cusTime ====>' + cusTime );
                String cusTimeStr = cusTime +'';
                //cs.GSS_Time_Zone__c='(GMT-08:00) Pacific Standard Time';
                //update cs;
                String timezone = cs.GSS_Time_Zone__c;
                System.debug('cusTimeStr in GMT 12844 cusTimeStr ====>' + cusTimeStr );
                if(timezone.indexof('GMT+')!=-1||timezone.indexof('GMT-')!=-1){                
                timezone=timezone.substring(12);               
                }
                System.debug('####### 12844 timezone' + timezone);
                
             
               
                
                 String  Offset_Hours='00';
                 String  Offset_Minutes='00';
               
               
                if(GSSTimeZoneOffset__c.getinstance(timezone)!=null){
                Offset_Hours=GSSTimeZoneOffset__c.getinstance(timezone).Offset_Hours__c;
                Offset_Minutes=GSSTimeZoneOffset__c.getinstance(timezone).Offset_Minutes__c;
                  System.debug(' Offset_Hours 12844====>' +  Offset_Hours);
                    System.debug('  Offset_Minutes 12844====>' +   Offset_Minutes);
                }
               
                 DateTime myDate1=cusTime.addMinutes(Integer.valueof(Offset_Minutes)).addHours(Integer.valueof(Offset_Hours));
       
              
                                                             
                String strConvertedDate = myDate1.formatGMT('MM/dd/yyyy HH:mm');
                System.debug(' Customer Time Before DST 12844 ====>' +  strConvertedDate );

  /***********************************************************************************************************
           Author            : Nitin Bhalla (Accenture)        
           CR #              : CR-000012844        
           Description       : Following Code is used to implement DST to Customer Response Time DueDate field.
   ***********************************************************************************************************/
       


String  Offset_Minutes_dst = '00' ;
String  Offset_Hours_dst = '00' ;
String Offset_StartDate ;
String Offset_EndDate ;
DateTime Offset_StartDate1 ;
DateTime Offset_EndDate1 ;


Boolean Dstcheck ;
if(GSSTimeZoneOffset__c.getinstance(timezone)!=null)
{
Dstcheck = GSSTimeZoneOffset__c.getinstance(timezone).DST__c ;
}
system.debug('12844 Dst Check value for ' + timezone + ' is ' + Dstcheck );




if (Dstcheck == true)
        {      
            
            
            String Flag = 'F' ;
            Map<String,GSSDstTimeZoneOffset__c> mapTargets = new Map<String,GSSDstTimeZoneOffset__c>();
            mapTargets = GSSDstTimeZoneOffset__c.getAll();
            for(GSSDstTimeZoneOffset__c DstTimeZoneOffset : mapTargets.values()) 
                {       
                    
                    if( (DstTimeZoneOffset !=null) && (DstTimeZoneOffset.Timezone__c).equals (Timezone))
                        { 
                            
                            Offset_Hours_dst = GSSDstTimeZoneOffset__c.getinstance(DstTimeZoneOffset.Name).DstOffset_Hours__c;
                            Offset_Minutes_dst = GSSDstTimeZoneOffset__c.getinstance(DstTimeZoneOffset.Name).DstOffset_Minutes__c;
                            //Strings Captured
                            Offset_StartDate = GSSDstTimeZoneOffset__c.getinstance(DstTimeZoneOffset.Name).Start_Date_Dst__c ;
                            Offset_EndDate = GSSDstTimeZoneOffset__c.getinstance(DstTimeZoneOffset.Name).End_Date_dst__c ;
                            //String to Date .Time take as 0000 Hours
                            Offset_StartDate1 = date.valueOf(Offset_StartDate);
                            Offset_EndDate1 = date.valueOf(Offset_EndDate) ;
                            
                                                    
                        System.debug('12844*************** Current DstTimeZoneOffset: in string :' + DstTimeZoneOffset.Name + '<DST Start Date> ' + Offset_StartDate + ' <DST end Date> ' + Offset_EndDate + ' <With hour and minute as> ' + Offset_Hours_dst + ' '+ Offset_Minutes_dst);
                        System.debug('12844*************** Current DstTimeZoneOffset: After Datetime conversion : start date' + Offset_StartDate1 + ' EndDate ' +   Offset_EndDate1 + 'COMPARE WITH ' + myDate1);
                            if ((myDate1 >= Offset_StartDate1) && ( myDate1 < Offset_EndDate1))
                                {
                                    System.debug('12844*************** Converting Flag For ' + DstTimeZoneOffset.Name);
                                    Flag = 'T';
                                    
                                    break;
                                }
                        }
                }
            if (Flag.equals('T'))
                {
                    myDate2=myDate1.addMinutes(Integer.valueof(Offset_Minutes_dst)).addHours(Integer.valueof(Offset_Hours_dst));
                    system.debug(' 12844 Final Converted Date after DST addition' + myDate2);
                    strConvertedDate = myDate2.formatGMT('MM/dd/yyyy HH:mm');
                }
            
            }
            //DST ends
                   
            cs.GSS_Customer_Timezone_FirstResponseDate__c = strConvertedDate ;
            System.debug('timezone test3' + timezone);
            System.debug(' 12844 String to put on Disply' +cs.GSS_Customer_Timezone_FirstResponseDate__c );
        }
            else
                {
                    cs.GSS_Customer_Timezone_FirstResponseDate__c=''; 
                    System.debug('Error : Either Timezone or First Response Date is NULL.');
                }           
        }
        system.debug('12844 GSS_UpdateCaseFirstResponse :: updateCustomerFR :: Ends');
    }
    


}