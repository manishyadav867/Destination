//***************************************************************************************************************//
//Name       :  OpportunitySequenceController
//Description:  The controller process all the trigger event requests. 
//              Based on the request, the Controller calls appropriate methods to accomplish the requested task.
//
//Created By :  Accenture
//Date       :  June 16 2010
//**************************************************************************************************************//
/*Developer              Date         Description                                                                                   CR-Targeted Release Date 
 * Shubhra Sharma     23-Aug-2010     CR-00001333 : Called a method CheckAdOppReg()to stop the flow of AD+ opportunity                27-Aug-2010 
 *                                    through approval, when the opportunity is registered by Global OEM Alliance Partner.
 * Ananth Krishna     18-Oct-2010     CR-00001834 : invoked updateSharingRules method in afterUpdate method.                         06-Nov-2010
 * Dilip Mistry       05-Jan-2011       CR-00003073 : Commented the method invocation which were related to deal-registration process
 * Dilip Mistry       1/21/2011         Stoped Opportunity Owner Realignment process [Cycle4 TT&MA module]
 *                                      Commented method "OpportunityManagement.ownerReAssigment()" invocation  
 * Sneha Jain         11-May-2011     Set the flag to bypass the Oppty Validation rule [CR-4875]    
 *    
 *Mahendra Singh      17-Jun-2011    Cycle 5: Added method calls for Opportunity Partner Insert/Delete.
 *Radhika Bahl            25-Jun-2013    CR-00036633 By-passing the method call based on custom setting during data update
 * Amit Kumar         04-July-2013   XUPSell Project: A new method has been added in Before insert and Before Update method to populate the Opportunity owner in a Lookup Field.
 * Accenture          08-Aug-2013    Updated for GSM Project (CR-00047034). Call Exception Process.
 * Swasti Mohapatra   09-June-2014   CR-00089986 : Parent Opportunity flag must be True if child opportunity gets link with Parent
 * Bharat Parekh      12-Aug-2014    Added method call for renaissance project requirement.
 * Bharat Parekh      12-Nov-2014    Added method call inside beforeUpdate() method for CR-00116008.
 * Bhumika Udani      14-May- 2015   Added bypasschecks for airwatch as per CR-00134669
 * Varsha             03-July-2015   XFire Project (CR-00134261) - Prevent XSUS Opportunities from updation 
 * Sandip             05-August-2015   CR-00132447 - By pass Update opportunity validation during insertion 
 * 04 Sept 2015       Accenture           CR-00135145      02-Oct-2015   Made Changes for SFA Enhancement 
 *Manish Yadav         28.10.2015                Added Logic for CR-00135258 
 * 14 April 2016        Accenture           CR-00137530         Calling a method for populating text fields  
 *  Yoganand Gadekar         31/12/2015             Modified as part of Orion Phase 1 CR-00137297
 * Suresh Babu                 26/04/2016      CR-00138575 - Added method to fetch AESF Email and copying in AW_AE_Email__c field on opty
 * sameer                   12-May-2016      Added for CR-00138531 : whenever Aw Opportunity Id gets updated the , helper object also will be updated with Aw opportunity Id
 * Suresh                   09-May-2016         Added for CR-00138521:  Added code for opty teammembers insert on account,territory update
 * Shivang Vij             26/04/2016           CR-00138530 - Added method to fetch contactrole,AW products on MSO opportunity
 * Suresh Babu             26/04/2016           CR-00138575 - Added method to fetch AESF Email and copying in AW_AE_Email__c field on opty
 * Suresh                  09/05/2016           Added the calling of "L2O_OpportunityHelper" Apex class created for Lead Management
 * Teja Sri                09/06/2016           CR-00138565 - To Update stage if AW Stage is modified form 07a/07b to 06 
 *Sameer Kulakarni         6/15/2016            whenever AW Bill To field is inserted/updated Bill To Account UUID Field is  updated with UUID of Account slected in AW Bill To Field.
 * Saumya 				   8/18/2016 		    CR-00140618- 	XSUS lead Conversion Error
 */  
public class OpportunitySequenceController {
    
    /***********************************************************************************************
    Method Name: beforeInsert
    Description: Invokes all the methods in sequence before inserting an Opportunity.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static boolean RecursiveCheckForBillTo=false;
    public static boolean runOnceCheck = True; // change for CR-00140618 
    public static void beforeInsert(){
        // **** Commented out after implementation of DealRegistration functionality ******//
        // To set the IsOppReg flag for all Opportunity Registrations
        //OpportunityManagement.setIsOppRegFlag();
        //system.debug('-----insert');
        //CR-00132447: Added by Sandip "checkOpportunityUpdateValidation"  
       
        recursive.checkOpportunityUpdateValidation =true;
        //START - CR-00134669 – 20.05.2015 – BHUMIKA UDANI - MAKE APPRIOPRIATE CHANGES FOR AWO
        AW_ConnectionUtility.insertCheckForAWO(trigger.new);
        //END - CR-00134669 – 14.05.2015  – BHUMIKA UDANI - MAKE APPRIOPRIATE CHANGES FOR AWO        
        
        // To pre-set values of childs from parent opportunity      
        OpportunityManagement.updateChildsParentsOpp();
        // XUPSell Project: Amit Kumar :  04-July-2013 : START***********************************
        //    XUPSell_RoutingThresholdAndAction.updateopportunityownerlookup();
        // XUPSell Project: Amit Kumar :  04-July-2013 : END***********************************
   
        //To Calculate Deal Range Value from Amount
        DealRangeCalculator.execute();
        
        //Convert Opportunity amount to USD.
        OpportunityAmountCurrencyConvertor.calculateConvertedAmt();
        
        OpportunityManagement.populateBusinessUnitOnOpportunity(); 
        
        //Added as part of Renaissance Project - Start  
        //Added for CR-00100127
        OpportunityManagement.addEduRepAndSSM(); 
        // Added as part of Renaissance Project - End
        
        //CR-00135145 Start - SFA Enhancement Oct Release
        OpportunityManagement.updateRouteToMarket();
        //CR-00135145 End - SFA Enhancement Oct Release
        
        // added by swasti to covert "excution status"
        RS2_OpportunityTerritoryAssignment.populateExecutionStatus(); 
        
        //Added for CR-00039841: Archana Mujumdar
        OpportunityManagement.countOfLeadsAssociatedwithOpportunity();
        
        //Created for GSM Project (CR-00047034)
        GSM_ExceptionReporting exceptionRep = new GSM_ExceptionReporting();
        exceptionRep.newOpptyException();
        //Changes for GSM end.
        
        //CR-00137530 - Start --> Calling newly created method
        OpportunityManagement.populateAssociatedAccountIds();
        //CR-00137530 - End
    }//end of method
    
    /***********************************************************************************************
    Method Name: beforeInsertL2O
    Description: Invokes all the methods in sequence before inserting an Opportunity for L2O project.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static void beforeInsertL2O(List<Opportunity> triggerNew){
    
        // START - CR-00138575 - To populate Contact Role on Opportunity
        //L2O_ConnectionHelperForOpptyteam.AWAEEmailcheck(triggerNew);
        // END - CR-00138575 - To populate Contact Role on Opportunity
        
    }
    /***********************************************************************************************
    Method Name: beforeUpdate
    Description: Invokes all the methods in sequence before updating an Opportunity.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static void beforeUpdate(){
        
        system.debug('startrecursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('startrecursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);
        
        OpportunityManagement.preventOppUpdateforOrionApprover();//added as part of Orion Phase 1 CR-00137297
        system.debug('1recursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('1recursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);
        //START - CR-00134261- 3rd July 2015 - Varsha - Prevent XSUS Opportunities from updation
          XFireUtilityClass.preventXSUSOppFormUpdate(trigger.new);
          system.debug('2recursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('2recursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);
        //END - CR-00134261- 3rd July 2015 - Varsha - Prevent XSUS Opportunities from updation
    
        //START - CR-00134669 – 14.05.2015 – BHUMIKA UDANI - SEND UPDATES TO PUBLISHED VMSTAR OPPORTUNITY TO AIRWATCH                
        AW_ConnectionUtility.seggregrateAWOOpportunityRecords(trigger.oldMap, trigger.newMap);system.debug('3recursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('3recursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);                
        
        //END CR-00134496 – 14.05.2015 – BHUMIKA UDANI - SEND UPDATES TO PUBLISHED VMSTAR OPPORTUNITY TO AIRWATCH
        
        //START - ETM Upgrade - BUG-00118397 - Khalid Ansari - Do not update territory to blank if a blank value is send by Informatica
        if (Trigger.isBefore && Trigger.isUpdate 
            && ETM_Do_Not_Delete_Territory_Values__c.getOrgDefaults().Target_Objects__c.contains('Opportunity')
            && UserInfo.getUserName().contains('etmintegration@vmware.com.vmw')) {
    
            TAUtilities.revertINFABlankTerrUpdate_Opp(trigger.oldMap, trigger.new);
            
        }
        //START - ETM Upgrade - BUG-00118397 - Khalid Ansari - Do not update territory to blank if a blank value is send by Informatica
        
        // Added as part of Renaissance Project - Start  
        if(!recursive.isCheckForProductPlatformGroup){     
           OpportunityManagement.checkForProductPlatformGroup();
            recursive.isCheckForProductPlatformGroup=true;
        }
        // Added as part of Renaissance Project - End
        
        // **** Commented out after implementation of DealRegistration functionality ******//
        // To set the IsOppReg flag for all Opportunity Registrations 
        //OpportunityManagement.setIsOppRegFlag();
         // XUPSell Project: Amit Kumar :  04-July-2013 : START***********************************
            XUPSell_RoutingThresholdAndAction.updateopportunityownerlookup();
            system.debug('4recursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('4recursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation); 
            if(!recursive.ispopulateISREmail){
            OpportunityManagement.populateISREmail();
             recursive.ispopulateISREmail=true;
            }
        // XUPSell Project: Amit Kumar :  04-July-2013 : END***********************************
       
        
        // Added as part of Renaissance Project for CR-00116008 - Start
           if(runOnceCheck){// change for CR-00140618 	
            OpportunityManagement.updateOpportunityProductsList();
            runOnceCheck = false; // change for CR-00140618 
           } 
           
       system.debug('5recursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('5recursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation); 
        // Added as part of Renaissance Project for CR-00116008 - End
        
        //Added as part of CR-00004875 - Sneha - May 11, 2011
        //Calling method to check Validation rule
        
       //CR-00036633 Changes start
        ByPassMethodOnOpportunity__c obj=ByPassMethodOnOpportunity__c.getInstance('MethodcheckValidationRule');
              
        if(obj.IsByPassed__c == false) {  //execute the method only if it should not be by-passed (based on custom setting)
           OpportunityUpdateValidationCheck.checkValidationRule();
        }
        //CR-00036633 Changes end
        // CR CR-00042038 : AC (Static call to opportunity Management class to update the value of Route to Market)
           OpportunityManagement.updateRouteToMarket();

        // To pre-set values of childs from parent opportunity      
        OpportunityManagement.updateChildsParentsOpp();
        
        // **** Commented out after implementation of DealRegistration functionality ******//
        // To Update Partner Level and Partner Type
        //OpportunityManagement.updateParterLevel();
        
        //To Calculate Deal Range Value from Amount
        DealRangeCalculator.execute();

        //Convert Opportunity amount to USD.
        OpportunityAmountCurrencyConvertor.calculateConvertedAmt();
        
        OpportunityManagement.populateBusinessUnitOnOpportunity();
        
        // Cycle 5 change
        if(!alreadyUpdatedHelper.hasAlreadyUpdated()){

         OpportunityPartnerSync.syncOppPartnerBeforeUpdate();
         alreadyUpdatedHelper.setAlreadyUpdated();// change for CR-00140618 
        } 
     
     //Added for CR-00039841: Archana Mujumdar
        OpportunityManagement.countOfLeadsAssociatedwithOpportunity();
        
        if(!recursive.isGSM_ExceptionReporting){   
        //Created for GSM Project (CR-00047034)
            GSM_ExceptionReporting exceptionRep = new GSM_ExceptionReporting();
            //Added for CR-00058319
            exceptionRep.isOpp = TRUE;
            exceptionRep.exceptionCheck(Trigger.new);
            recursive.isGSM_ExceptionReporting=true;
            }
        //Changes for GSM end

        //CR-00137530 - Start --> Calling newly created method
        OpportunityManagement.populateAssociatedAccountIds();
        //CR-00137530 - End        
    }//end of method
    
    /***********************************************************************************************
    Method Name: beforeUpdateL2O
    Description: Invokes all the methods in sequence before updating an Opportunity for L2O project.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static void beforeUpdateL2O(List<Opportunity> triggerNew, List<Opportunity> triggerOld, Map<id,opportunity>triggerNewMap, Map<id,opportunity>triggerOldMap){
         
         List<Opportunity> QualifiedOptyVMW =new List<opportunity>();
         List<Opportunity> QualifiedOptyAW =new List<opportunity>();
       //Start- CR-00138565 - To Update stage if AW Stage is modified form 07a/07b to 06 Added by Teja
       for(Opportunity o:triggerNew){
            if((triggerOldMap!=Null||!triggerOldMap.isEmpty()) && (triggerOldMap.get(o.id).AWStage__c=='07a - Agreement to Purchase' || triggerOldMap.get(o.id).AWStage__c=='07b - Awaiting OEM Activation') && (o.AWStage__c=='06 - Negotiate') && (o.AW_Sub_Stage__c=='Contract/PO Pending - Update Required') ){
                triggerNewMap.get(o.id).StageName=triggerNewMap.get(o.id).AWStage__c;
               
            }
            
             //Ends- CR-00138565
            
            //added by sameer kulakarni : Bill To Field Flow from Vmstar to AW and vice versa
        
            if((o.AWOpportunityID__c != triggerOldMap.get(o.id).AWOpportunityID__c ) || ( o.AW_Bill_To__c !=triggerOldMap.get(o.id).AW_Bill_To__c  )) {
                //Bill to flow from VMStar to AW 
               
                if(o.AW_Bill_To__c == null){
                    
                    o.Bill_To_Account_UUID__c=null;
                     RecursiveCheckForBillTo=true;
                     
                }
                else{
                    
                    QualifiedOptyVMW.add(o);
                   
                }
            }
           
            if( o.Bill_To_Account_UUID__c !=triggerOldMap.get(o.id).Bill_To_Account_UUID__c ){
                 //Bill to flow from  AW to VMStar
                 if(o.Bill_To_Account_UUID__c !=null ){
                    QualifiedOptyAW.add(o);
                 }
                 else{
                     o.AW_Bill_To__c = null;
                     RecursiveCheckForBillTo=true;
                 }
            }
         }
         
         
        if(!QualifiedOptyVMW.isEmpty() &&  RecursiveCheckForBillTo==false) {
            //Bill to flow from VMStar to AW 
           
            OpportunitySequenceController.BeforeUpdateBillToOnVMW(QualifiedOptyVMW);
        }
        if(!QualifiedOptyAW.isEmpty() && RecursiveCheckForBillTo==false) {
             //Bill to flow from  AW to VMStar
            OpportunitySequenceController.BeforeUpdateBillToOnAW(QualifiedOptyAW);
        }
       
            
        //CR-00138530 Method Called to enforce validation rules
      if(!L2O_OpportunityHelper.recursiveCheck){
          L2O_OpportunityHelper.enforceValidationRules(triggerNew, triggerOldMap);
          L2O_OpportunityHelper.recursiveCheck = true;
      }
        // START - CR-00138575 - Added method to fetch AESF Email and copying in AW_AE_Email__c field on opty
        //L2O_ConnectionHelperForOpptyteam.AWAEEmailcheck(TriggerNew);
        // END - CR-00138575 - Added method to fetch AESF Email and copying in AW_AE_Email__c field on opty
    }

    /***********************************************************************************************
    Method Name: afterInsert
    Description: Invokes all the methods in sequence after inserting an Opportunity.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static void afterInsert(){
        
        
        //START - CR-00134669 – 20.05.2015 – BHUMIKA UDANI - UPDATE ACCOUNT REQUEST
        AW_ConnectionUtility.updateARWithOpptyId(trigger.new);
        AW_ConnectionUtility.afterEventAWOChecks(trigger.oldMap, trigger.newMap);  
        //END - CR-00134669 – 14.05.2015  – BHUMIKA UDANI - UPDATE ACCOUNT REQUEST
               
        
        // To pre-set values of childs from parent opportunity  
        OpportunityManagement.updateChildsParentsOpp();
        
        // CR CR-00042038 : AC (Static call to opportunity Management class to update the value of Route to Market)
           OpportunityManagement.updateRouteToMarket();
        
        // **** Commented out after implementation of DealRegistration functionality ******//
        // Evaluates the criteria to determin if any of the opportunities need to be processed
        //OpportunityManagement.processAssignment();
        
        // **** Commented out after implementation of DealRegistration functionality ******//
        // To reassign the approver on a submitted opportunity
        //OpportunityManagement.reassignApprover();

        // Below code section is commented 
        // By   : Dilip Mistry [Accenture]
        // Date : 1/21/2011
        // Description : Code section is commented to stop the opportunity owner realignment process [Cycle4 M&A module]
        // To process opportunities , realigning territories on the basis of account owner
        //OpportunityManagement.ownerReAssigment();
        // [Cycle4 M&A module] changes Ends Here
        
        //To update the Booked Amount field of Split Opportunity
        new UpdateSplitOpportunity().execute();
        // Cycle 5 change
        OpportunityPartnerSync.syncOppPartnerAfterInsert();
    }//end of method
    
   

    /***********************************************************************************************
    Method Name: afterUpdate
    Description: Invokes all the methods in sequence after updating an Opportunity.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static void afterUpdate(){
        
        // To pre-set values of childs from parent opportunity  
        OpportunityManagement.updateChildsParentsOpp();

        // **** Commented against CR-00003073 [code cleanup CR] ******//
        // Evaluates the criteria to determin if any of the opportunities need to be processed
        //OpportunityManagement.processAssignment();
        
        //Added for CR-00135258 
        
        AW_ConnectionUtility.afterEventAWOChecks(trigger.oldMap, trigger.newMap);  
        //Added for CR-00135258    
        
        // **** Commented against CR-00003073 [code cleanup CR] ******//
        // To reassign the approver on a submitted opportunity
        //OpportunityManagement.reassignApprover();
        
        //To update the Booked Amount field of Split Opportunity
        new UpdateSplitOpportunity().execute();
        
        // **** Commented out after implementation of DealRegistration functionality ******//
        /*
        * Changed By: Dilip Mistry
        * Change Date: 27-July-2010
        * Chnage Against: CR-00001872
        * Change Desc: activate the workflow rule "OppReg - Inactivate Unaddressed Registrations"
        */
        // **** Commented against CR-00003073 [code cleanup CR] ******//
        // To inactivate the unaddressed registration
        // OpportunityManagement.inactivateUnaddressedRegistration();
        
        // **** Commented against CR-00003073 [code cleanup CR] ******//
        // 3rd Party Opp Reg functions (submit for approval and send updates to 3rd Party)
        //OpportunityManagement.tpsProcessing();
 
        
       //on opportunity owner change , sharing rules are inserted for the new owner
       OpportunityUpdateSharingRules.updateSharingRules();
        
       // Added as part of Renaissance Project - Start  
       //Added for CR-00100127 : Provide manual sharing of the record; if the Edu_Rep__c value changes
       OpportunityManualSharing.updateManualSharing();
       // Added as part of Renaissance Project - End  
    }//end of method
    
    /***********************************************************************************************
    Method Name: afterUpdateL2O
    Description: Invokes all the methods in sequence after updating an Opportunity for L2O project.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static void afterUpdateL2O(List<Opportunity> triggerNew, List<Opportunity> triggerOld, Map<id,opportunity>triggerNewMap, Map<id,opportunity>triggerOldMap){
        //Added by sameer: CR-00138531 satrts here
        Map<Id,Opportunity> qualifiedOpptyMap = new Map<Id,Opportunity>();
        for(opportunity oppty : triggerNewMap.values()){
            if(oppty.AWOpportunityID__c != null && oppty.AWOpportunityID__c != triggerOldMap.get(oppty.id).AWOpportunityID__c){
                qualifiedOpptyMap.put(oppty.id,oppty);
            }
        }
        if(!qualifiedOpptyMap.values().isEmpty()){
            L2O_ConnectionHelperForOpptyteam.updatedAWOpptyIDonOpportunity(qualifiedOpptyMap);
        }
        //Added by sameer: CR-00138531 Ends here 
        
        //added by suresh-CR-00138521-STARTS//
        if(!L2O_OpportunityHelper.isaccountupdteonopty){
            L2O_OpportunityHelper.checkOptyAccountUpdate(TriggerNew,TriggeroldMap); 
            L2O_OpportunityHelper.isaccountupdteonopty=true;
        }   

        if(!L2O_OpportunityHelper.isoptyteaminsert){
            set<Id> optyids = new set<Id>();
            set<Id>opportunityIds=new set<Id>();
            
            for(opportunity opty:triggernew){
                if(TriggeroldMap.get(opty.Id).AWOpportunityID__c== null && opty.AWOpportunityID__c!=null){
                    optyids.add(opty.Id);
                }
            }
            if(optyids.size()>0){
                L2O_OpportunityHelper.createOppTeMem(optyids,null);//added by suresh
            }
            L2O_OpportunityHelper.isoptyteaminsert = true;
        }
        //added by suresh-CR-00138521-END
        if(!L2O_OpportunityHelper.recursiveCheckSEOverrideOnOpty){
            L2O_OpportunityHelper.SEOverrideOnOpty(TriggerNew,TriggeroldMap);
            L2O_OpportunityHelper.recursiveCheckSEOverrideOnOpty=true;
        }
       
        
    }
    
    /* Added by Swasti for CR-00089986 to Make Parent Consolidated Flag as True   */
    public static void afterUpdateRS2_ParentOpportunityAmount(List<Opportunity>  oppList,Map<Id,Opportunity> OldMap){
        RS2_OpportunityConsolidation.RS2_ParentOpportunityAmount(oppList,OldMap);
    }
    
    /***********************************************************************************************
    Method Name: afterDelete
    Description: Invokes all the methods in sequence after deleting an Opportunity.
    @Param: None
    @return: None
    @throws: none
    ***********************************************************************************************/
    public static void afterDelete(){      
        
        // To pre-set values of childs from parent opportunity  
        OpportunityManagement.updateChildsParentsOpp();

    }//end of method
    
    /**************************************************************************************************
    method name: BeforeUpdateBillToOnVMW
    Added by   :sameer Kulakarni
    Descrption : whenever AW Bill To field is inserted/updated Bill To Account UUID Field is  updated with UUID of Account slected in AW Bill To Field.
    ***************************************************************************************************/
    public static void BeforeUpdateBillToOnVMW(List<Opportunity>QualifiedOppty) {  
    try{
      Map<id,string> UUIDMap=new map<id,string>();
      List<id> BillToId=new List<id>();
      for(Opportunity opty :QualifiedOppty){
        if(opty.AW_Bill_To__c != null){
          BillToId.add(opty.AW_Bill_To__c);
        }
      }
      if(!BillToId.isEmpty()){
        for(Account ac:[select id ,UUID__c from account where id =:BillToId]){
          if(ac.UUID__c != null){
            UUIDMap.put(ac.id,ac.UUID__c);
          }
        }
      }      
         
      for(opportunity opty :QualifiedOppty){         
        opty.Bill_To_Account_UUID__c=UUIDMap.get(opty.AW_Bill_To__c);        
        RecursiveCheckForBillTo=true;         
      }
    }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','OpportunitySequenceController','BeforeUpdateBillToOnVMW');}
  }
    
  /**************************************************************************************************
  method name: BeforeUpdateBillToOnAW
  Added by   :sameer Kulakarni
  Descrption :whenever Bill_To_Account_UUID__c updates , the AW_Bill_To__c will populates account by referring  Bill_To_Account_UUID__c (UUID)
   ***************************************************************************************************/        
  public static void BeforeUpdateBillToOnAW(List<Opportunity>QualifiedOppty) {  
    try{
      Map<string,id> UUIDMap=new map<string,id>();
      List<string> BillToId=new List<string>();
      for(Opportunity opty :QualifiedOppty){
        if(opty.Bill_To_Account_UUID__c != null){
          BillToId.add(opty.Bill_To_Account_UUID__c);
        }
      }
      if(!BillToId.isEmpty()){
        for(Account ac:[select id ,UUID__c from account where  UUID__c =:BillToId]){
          if(ac.UUID__c != null){
            UUIDMap.put(ac.UUID__c,ac.id);
          }
        }
      }        
         
      for(opportunity opty :QualifiedOppty){           
         opty.AW_Bill_To__c=UUIDMap.get(opty.Bill_To_Account_UUID__c);
         RecursiveCheckForBillTo=true;
      }
    }catch(Exception exc){ErrorHandling.onErrorHandling(exc.getMessage(),'High','ApexClass','OpportunitySequenceController','BeforeUpdateBillToOnAW');}
  }

}