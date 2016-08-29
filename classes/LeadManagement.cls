//***************************************************************************************************************
        // Class Name: LeadManagement 
        // Description: This Class contains all lead processing method.
        // Created By: Amar Sonkar
        //
        // ************************Version Updates***********************************************************************
        //
        // Updated Date         Updated By          Update Comments 
        //7/31/2012 (Cycle 8)   Tarun Khandelwal     Added a method for cycle 8
        //4/12/2012             Somya Garg           Added Method for CR-00022666
        //12/19/2012            Bhawani Sharma       Added new method(calculateLeadAge) - CR-00018244 
        // 3/21/2013            Ponna Gopal          Added a method for CR-00034114
        // 14-05-2013           Harsimrat sachdeva   Added a method for CR - 00037547
        //14-5-2013             Archana Mujumdar     Added a method for CR-00039600
        //14-5-2013             Bhavesh Mistry       Added a method for CR-00037541 & CR-00039320 & CR-00037548& CR-00037545
        //13-07-2013            Radhika Bahl         Added a method "populateDescriptionOfCampaign" for CR-00041541
        //15-07-2013            Bharat Parekh        Added a method "assignExistingAccountTerritoryId" for CR-00043930.
        //23-08-2013            Bhavesh Mistry       Added for CR-00047143 & CR-00055046
        //19-12-2013            MSJ Singitham        Added for CR-00069091 
        //16/02/2014            Bharat Parekh        CR-00079655 - Added condition to update Lead owner Profile when Lead owner is same and Lead Owner Profile is blank.
        //19-05-2014            Manik Chaudhary      Modified code for CR-00088193
        //07-21-2014            Varsha Chougule      Added new Method for CR-00087401
        //8/23/2014             Deepthi Harikrishnan Added new method for CR-00106346
        //07-08-2014            Sanjib Mahanta      Added a method "emailNotificationToQualifiedLead"for CR-00104200
        //15-12-2014            Yoganand Gadekar    Added logic to update Campign product on lead as part of Renaisance Phase 2
        //12-12-2014            Sanjib Mahanta      Added logic for CR-00122081(Renaissance Phase-2)
        //01-21-2015            Vikram Tota         Added logic for CR-00121522
        // 03-02-2015           Manik Chaudhary     Added Code for CR-00124323
        // 16/04/2015           Manik Chaudhary    Added Method -updateExistingOpportunityFlag- for CR-00124553
        // 22-Apr-15            Deepak Kumar        Updated for - CR-00132427 | SDP 9.0 | Release 5-June-15 
        // 21-05-2015          Yoganand Gadekar    Modified as part of Lead_DealReg Conversion project CR-00134135
        // 12 Aug 2015      Accenture           CR-00134262      04-Sept-2015   Added updateLeadAccountMatchedFlag Method.
        // 10-07-2015          Yoganand Gadekar    Modified as part of Lead Deal Phase 2 Project CR-00133083
        // 17-08-2015           Sandip              Modified code for SFA/PRM defects CR-00135033 
        // 10-02-2015          Kush Dawar           CR-00135563  Tracking Campaigns - IT Outcome
        //  4/14/2016           Prateek Bhattacharya    Modified for CR-00138487 : Optimize Lead Account Match Batch
        // 06-05-2016           Syed ASwaN              CR-00138578 - Modified if condition to check for Bypass_DaaS_Call__c field.
         //  4/15/2016       Manish Yadav            Added Method for L2O-Management(Airwatch)- CR-00138421/CR-00138422/CR-00138422
        //  5/24/2016       Manish Yadav            Added Changes for L2O-Management(Airwatch)- CR-00138964
        //  5/30/2016       Manish Yadav            Added Chnges for L2O-Management(Airwatch)- CR-00139063
        //  06/22/2016      Sanjib Mahanta          Added changes for L2O-Project - Airwatch [BUG-00148725] 
        //  06/30/2016      Manish Yadav            Added changes for L2O-Project - Airwatch BUG-00149090
      //  08/02/2016      Manish Yadav            Added changes for CR-00140526
        //  08/03/2016      Sanjib Mahanta          Added Changes for CR-00140591
        //  08/22/2016      Manish Yadav       Added for CR-00140850 
        // **************************************************************************************************************

        public class LeadManagement {
            //***************************************************************************************************************
            // Method Name: emailCheck
            // Description: Checks whether Email Id is already present with Lead Record or not
            // Created By: Malkeet Singh
            // Against:-00020068
            //***************************************************************************************************************
            public static boolean RecursiveCheckForConvert=false;
            public static Boolean hybridEmail = false;  
            public static void emailCheck()
            {
                  List<Lead> triggernew = (List<Lead>)Trigger.new;
                  Map<Id,Lead> newMap = (Map<Id,Lead>)Trigger.NewMap;
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;

                  List<Lead> emailcheck = new List<Lead>();
                  Set<String> emailsets = new Set<String>();
                  Map<Id,String> profilemap = new Map<Id,String>();
                  Map<String,String> existingleadmap =  new Map<String,String>();

                  recursive.emailFlag = true;
                  for(Profile_Name_Mapping__c PM: Profile_Name_Mapping__c.getAll().values())
                    {
                        if(PM.Profile_Apex_Name__c == 'Commercial Rep'|| PM.Profile_Apex_Name__c == 'GA Rep'|| PM.Profile_Apex_Name__c == 'Hybrid Rep'||
                                        PM.Profile_Apex_Name__c == 'LDR'|| PM.Profile_Apex_Name__c == 'Named Rep' || PM.Profile_Apex_Name__c == 'Public Sector Rep'||
                                        PM.Profile_Apex_Name__c == 'SLED Rep')
                        profilemap.put(PM.Profile_Id__c,PM.Profile_Name__c);
                    }
                  
                  
                  //system.debug(UserInfo.getProfileId());
                  if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && profilemap != null && profilemap.size()>0 && profilemap.containsKey(UserInfo.getProfileId())) 
                    { 
                        for(Lead leadRec1 : (List<Lead>)trigger.new)
                        {
                            if((trigger.isInsert && leadRec1.Email != null) || (trigger.isUpdate && leadRec1.Email != null && ((oldMap.get(leadRec1.id).Email != null && leadRec1.Email != oldMap.get(leadRec1.id).Email) || (oldMap.get(leadRec1.id).Email == null && leadRec1.Email != null))))
                            {
                                Boolean intriggernew = false;
                                for(Lead leadRec2 : (List<Lead>)trigger.new)
                                {
                                    if(leadRec1.id !=leadRec2.id && leadRec2.Email != null && leadRec1.Email.toLowerCase() == leadRec2.Email.toLowerCase()) 
                                      {
                                        intriggernew = true;
                                        leadRec1.addError('Email address already exists on another lead');
                                      }
                                }
                                if(!intriggernew)
                                {
                                    emailcheck.add(leadRec1);
                                    emailsets.add(leadRec1.Email);
                                }
                            }
                        }
                        
                        
                        if(emailcheck != null && emailcheck.size()>0)
                        {
                            for(Lead existinglead: [select id, email from Lead where Email=:emailsets])
                            {
                                existingleadmap.put(existinglead.email.toLowerCase(),existinglead.id);
                            }
                            
                            for(Lead leadRec : emailcheck) 
                            {  
                              
                               if(existingleadmap != null && existingleadmap.size()>0 && existingleadmap.containsKey(leadRec.email.toLowerCase()))
                                {
                                    leadRec.addError('Email address already exists on another lead');
                                } 
                                
                            }
                        }
                    }
            }
            
            
            
        // ***************************************************************************************************
        // Method Name: populateRSOnLeadBeforeUpdateInsert
        // Description:  Invoke this method once lead inserted/updated to populate Record Source on Lead
        // Change Request # :  L2O-Management(Airwatch)- CR-00138421/CR-00138422/CR-00138422
        //***************************************************************************************************************
        public static void populateRSOnLeadBeforeUpdateInsert(){
            
            List<Lead> lsLead = (List<Lead>)Trigger.new;
            Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
            Map<Id,Lead> newMap = (Map<Id,Lead>)Trigger.newMap;
            
            if(lsLead != null && !lsLead.isEmpty()){
                for(Lead lead :lslead){

                 
                    String cated;
                    if(String.isNotBlank(lead.LeadSource)  && !lead.LeadSource.containsIgnoreCase('AirWatch')){
                        lead.Is_VMW_lead__c = true;
                        
                    }
                    if(lead.Is_VMW_lead__c){
                        cated = 'Checked';
                    }else{
                        cated = 'Unchecked';
                    }
                    L2O_AW_Lead_Source_Table__c leadSrcCus ;              
                    if(lead.Lead_Source_Most_Recent__c != null && String.isNotBlank(lead.Lead_Source_Most_Recent__c)){
                       leadSrcCus = L2O_AW_Lead_Source_Table__c.getInstance(lead.Lead_Source_Most_Recent__c);                    
                    }  
                    
                    if(leadSrcCus != null){
                        lead.AW_Lead_Source_Category__c = leadSrcCus.category__c;
                    }else{
                        lead.AW_Lead_Source_Category__c = '';
                    }
                    String con = lead.AW_Lead_Source_Category__c;              
                    
                    L2O_Record_Source_Field_Update__c recSourcefield =  L2O_Record_Source_Field_Update__c.getInstance(con+cated);
                    if(recSourcefield != null){
                        lead.Record_Source__c = recSourcefield.RSource__c;
                    }
                    
                    //Start Changes for CR-00138964
                    
                   //Updated Condition for CR-00140591
                    String labelAwLeadSource = System.Label.AW_Lead_Source_Category;
                    List<String> lsAwLeadSource = labelAwLeadSource.split('/', 2);
                    if(trigger.isInsert && lead.Record_Source__c != null && (lead.Record_Source__c.equals('AW-Contact Us') || lead.Record_Source__c.equals('AW-Free Trial'))){
                        for(String awLeadSource : lsAwLeadSource){
                          if(awLeadSource == con){
                            lead.Screening_Results__c= 'AW Qualified'; 
                          } 
                        }
                    } 
                    //END Changes for CR-00138964
                    //Start Changes for CR-00139063
                    
                    //CR-00140526 - Start Below CR-00140526 by Manish
                    if(lead.AW_Country__c != null && trigger.isBefore && trigger.isInsert){   
                        L2O_AW_Country_Mapping__c  awCountry = L2O_AW_Country_Mapping__c.getInstance(lead.AW_Country__c);                   
                        if(awCountry != null){                   
                            lead.Country__c = awCountry.country__c;                   
                        }                    
                    }else if(lead.AW_Country__c != null && lead.AW_Country__c != oldMap.get(lead.id).AW_Country__c){
                        L2O_AW_Country_Mapping__c  awCountry = L2O_AW_Country_Mapping__c.getInstance(lead.AW_Country__c);                   
                        if(awCountry != null){                   
                            lead.Country__c = awCountry.country__c;                   
                        } 
                    } 
                    //CR-00140526 - END Below CR-00140526 by Manish
                    
                    //End Changes for CR-00139063
                    if(trigger.isBefore && trigger.isUpdate){                   
                        if(lead.Is_VMW_lead__c && (lead.Record_Source__c == 'Hybrid') && (oldMap.get(lead.id).Record_Source__c != null) && (!lead.Hybrid_Execute__c)){
                            lead.Execute_Ownership_Realignment__c = true;
                            lead.Hybrid_Execute__c = true;
                        }                  
                        if(newMap.get(lead.id).AW_Lead_Source_Category__c != oldMap.get(lead.id).AW_Lead_Source_Category__c){
                          List<L2O_AW_Lead_Source_Category_Update__c> lsRecordSourceCatUp = L2O_AW_Lead_Source_Category_Update__c.getAll().values();                    
                            if(lsRecordSourceCatUp != null && !lsRecordSourceCatUp.isEmpty()){
                                for(L2O_AW_Lead_Source_Category_Update__c recordSourceCatUp : lsRecordSourceCatUp){
                                    if((recordSourceCatUp.AW_Lead_Source_Category_old__c == oldMap.get(lead.id).AW_Lead_Source_Category__c) &&
                                        (recordSourceCatUp.AW_Lead_Source_Category_New__c == newMap.get(lead.id).AW_Lead_Source_Category__c) &&
                                        (!recordSourceCatUp.Update_Record_Source__c)){
                                            newMap.get(lead.id).Record_Source__c = oldMap.get(lead.id).Record_Source__c;
                                        }                                    
                                }
                            }
                        }

                        if(lead.Record_Source__c != oldMap.get(lead.id).Record_Source__c){
                            lead.Previous_Record_Source__c = oldMap.get(lead.id).Record_Source__c;
                        }  

                       
                       
                    }              

                }
            
            }   
       
            
            
        }       
        
        
        
           
        // ***************************************************************************************************
        // Method Name: populateRSInsertManual
        // Description:  Invoke this method before insert Record Source on Lead
        // Change Request # :  L2O-Management(Airwatch)- CR-00138421/CR-00138422/CR-00138422
        //***************************************************************************************************************
             public static void populateRSInsertManual(){
               // System.debug(logginglevel.error,'In before insert');
                 List<Lead> lsLead = (List<Lead>)Trigger.new; 
              //   System.debug(logginglevel.error,'In before insert lead list'+lsLead);
                 Record_Source_Restriction__c recordSourceRes; 
                 List<Lead> lsLeadtoUpdate = new List<Lead>();
                     String createdByName = UserInfo.getName();
                     Profile  profileRecord = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId() LIMIT 1];
                     String ProfileName = profileRecord.Name;
                 for(Lead lead : lsLead){
                     recordSourceRes = Record_Source_Restriction__c.getInstance(createdByName);
                      if((lead.LeadSource !=null && lead.LeadSource != '') && (recordSourceRes == null) || (recordSourceRes != null && recordSourceRes.Inactive__c) || (ProfileName == System.Label.AMER_AW_Specialist_Profileid) || (ProfileName == System.Label.EMEA_AW_Specialist_Profileid)|| (ProfileName == System.Label.APJ_AW_Specialist_Profileid)){
                         lead.Record_Source__c = System.Label.RSManual;
                     }
                    
                 }
            
             }
             
             
        // ***************************************************************************************************
        // Method Name: populateAWRepEmailFromVMwareTerr
        // Description:  Invoke this method before Update to fetch AW Rep Email
        // Change Request # :  L2O-Management(Airwatch)- CR-00138421/CR-00138422/CR-00138422
        //***************************************************************************************************************
             public static void populateAWRepEmailFromVMwareTerritory(){
               // System.debug(logginglevel.error,'In populateAWRepEmailFromVMwareTerr insert');
                 List<Lead> lsLead = (List<Lead>)Trigger.new; 
                 Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.oldMap;
                 //set<Id> leadId = new Set<Id>();
                 set<id> terrID = new Set<Id>();
                 Map<Id, Lead> awRepEmailMap ;
                 Map<Id, VMWare_Territory__c> awRepEmailMapTerr ;
                 for(Lead lead : lsLead){
                     if(lead.Primary_Field_Sales_Territory__c != null){
                         //leadId.add(lead.id);
                         terrID.add(lead.Primary_Field_Sales_Territory__c);
                     } 
                 }
                 if(!terrID.isEmpty()){
                    
                    awRepEmailMapTerr = new Map<id,VMWare_Territory__c>([Select id, AW_AE_PSR__r.Email,AW_AE_PSR__r.Name from VMWare_Territory__c where id IN : terrID]);
                  //  System.debug('awRepEmailMapTerr>>>'+awRepEmailMapTerr);
                    if(awRepEmailMapTerr != null && !awRepEmailMapTerr.isEmpty()){
                          for(Lead leadMap : lsLead){                       
                              if(leadMap.Primary_Field_Sales_Territory__c != null && awRepEmailMapTerr.keyset().contains(leadMap.Primary_Field_Sales_Territory__c) && awRepEmailMapTerr.get(leadMap.Primary_Field_Sales_Territory__c).AW_AE_PSR__r.Email != ''){
                                  leadMap.AW_Rep_Email_VM__c = awRepEmailMapTerr.get(leadMap.Primary_Field_Sales_Territory__c).AW_AE_PSR__r.Email;
                                  leadMap.AE_PSR_Name__c = awRepEmailMapTerr.get(leadMap.Primary_Field_Sales_Territory__c).AW_AE_PSR__r.Name;
                              }                     
                          }
                 }
                 }             
            
             }
          //***************************************************************************************************************
            // Method Name: clearPartnerFieldsForDeclinedLead
            // Description: This method is to clear the Partner fields from a lead when lead is declined.
            // Created By: Tarun Khandelwal
            //***************************************************************************************************************
               public static void clearPartnerFieldsForDeclinedLead()
               {
                  List<Lead> triggernew = (List<Lead>)Trigger.new;
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;

                  if(trigger.isBefore && trigger.isUpdate) 
                  { 
                    for(Lead leadRec : triggernew)
                    {
                        // added leadRec.Status == '5 Retired' || leadRec.Status == 'Archieved' conditions for CR-00069091 by MSJ Singitham. 
                       if((leadRec.Status != oldMap.get(leadRec.Id).Status) && (leadRec.Status == '1 Partner Declined' || leadRec.Status == '5 Retired' || leadRec.Status == '5 Archived'))
                       {    
                            //leadRec.PartnerAccountId = null;
                            leadRec.Partner_Account__c = null;
                            leadRec.Partner_ID_1__c = '';
                       }
                    }
                  } 
                }
            //***************************************************************************************************************
            // Method Name:updatePostalCodes 
            // Description: This method update Postal code on lead.
            // Created By: Amar Sonkar
            //***************************************************************************************************************
            public static void updatePostalCodes()
            {
                Boolean flag=ByPassTrigger.userCustomMap('updatePostalCodes','Lead');//Added to ByPass Trigger at the time of Data Migration for Cycle 5
                List<Lead> triggernew = (List<Lead>)Trigger.new;
                List<Lead> triggerold = new List<Lead>();
                if(Trigger.isUpdate)
                    triggerold = (List<Lead>)Trigger.old;

                if(Trigger.isBefore)
                {
                    for(Integer i=0;i<triggernew.size();i++) {
                        if(Trigger.isInsert)
                            TAUtilities1.movePostalCodes(null, triggernew[i]);
                        else if (Trigger.isUpdate){
                             //Added to ByPass Trigger at the time of Data Migration for Cycle 5             
                            if(flag==false){
                            TAUtilities1.movePostalCodes(triggerold[i], triggernew[i]);
                          } //End of check for Cycle 5
                        }
                    }
                }
            }
            
            //***************************************************************************************************************
            // Method Name:updatePartnerAccountOnLead 
            // Description: This method update Partner account on lead.
            // Created By: Amar Sonkar
            //***************************************************************************************************************   
            public static void updatePartnerAccountOnLead()
            {
                Boolean flag=ByPassTrigger.userCustomMap('updatePartnerAccountOnLead','Lead');//Added to ByPass Trigger at the time of Data Migration for Cycle 5
                
                List<Lead> triggernew = (List<Lead>)Trigger.new;    
                
                // Modified by Accenture on 30th Sept against CR-00002044: When leads are pre-assigned with a Partner ID, the partner should be able to access the lead.
                    if(Trigger.isBefore){   
                        if(Trigger.isInsert)
                        PopulatePartnerAccountOnLead.populatePartner();
                         else if (Trigger.isUpdate){
                             //Added to ByPass Trigger at the time of Data Migration for Cycle 5             
                            if(flag==false){
                            PopulatePartnerAccountOnLead.populatePartner();
                           }//End of check for Cycle 5  
                        }
                    }// Code End for CR-00002044.
                    
            }
            
            //***************************************************************************************************************
            // Method Name:updateProductLeadFilter 
            // Description: This method update Product lead filter on lead.
            // Created By: Amar Sonkar
            //***************************************************************************************************************
            public static void updateProductLeadFilter()
            {
               
                  List<Lead> triggernew = (List<Lead>)Trigger.new;
                  Map<Id,Lead> newMap = (Map<Id,Lead>)Trigger.NewMap;
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;

                  // Changes Made by Dilip Mistry on 05-05-2011
                  // Against: CR-00005075
                  // Description:  Below code snippet copies "Lead Assignment Product" field value to multipicklist "Product Lead Filter"
                  if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
                    // Added the parameters to the below method to handle issue (more than 10000 rows) corresponding to CR-00009879 by Accenture.
                    LeadPopulateExistingRelatedObjectFlags.populateFlags(newMap,oldMap);// Onkar : This trigger should work on both before update and before insert
                    /* commenting as part of Renaisance Phase 2 - start
                    for(Lead leadRec : triggernew) {
                        //Modified if statement as part of Renaisance Phase 2 -start
                        //if(leadRec.Lead_Assignment_Product__c != null && (leadRec.Product_Lead_Filter__c == null || !leadRec.Product_Lead_Filter__c.contains(leadRec.Lead_Assignment_Product__c)) ) {
                        if(leadRec.Geo__c == 'EMEA' && leadRec.Lead_Assignment_Product_New__c != null && (leadRec.Product_Lead_Filter__c == null || (checkPicklistval(leadRec.Product_Lead_Filter__c,leadRec.Lead_Assignment_Product_New__c ))) ) {
                            leadRec.Product_Lead_Filter__c = (leadRec.Product_Lead_Filter__c != null? (leadRec.Product_Lead_Filter__c+ ';' +leadRec.Lead_Assignment_Product_New__c ): leadRec.Lead_Assignment_Product_New__c ); 
                           if(leadRec.Geo__c == 'EMEA' && leadRec.Product_Lead_Filter__c != null && leadRec.Product_Lead_Filter__c != ''){                        
                                leadRec.Product_Lead_Filter__c = removeDuplicateValues(leadRec.Product_Lead_Filter__c);
                            }
                        //Modified if statement as part of Renaisance Phase 2 -end
                        }
                    }Commenting as part of Renaisance phase 2 - end*/
                  } 
                
            }

            //***************************************************************************************************************
            // Method Name: createLDRNotesOnLead 
            // Description: This method is to save the LDR comment as notes on Lead.(Cycle -8)
            // Created By: Tarun Khandelwal
            //***************************************************************************************************************
            public static void createLDRNotesOnLead()
            {
                  List<Lead> triggernew = (List<Lead>)Trigger.new;
                  List<Note> newNotes = new List<Note>();
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;

                 if(trigger.isAfter && trigger.isUpdate) {
                   
                   for(Lead leadRec : triggernew) {
                        if((leadRec.Marketing_Comments__c != oldMap.get(leadRec.Id).Marketing_Comments__c) && leadRec.Marketing_Comments__c!=NULL && leadRec.Marketing_Comments__c!=''){
                                Note nt= new Note();
                                nt.Title=  'Marketing Comments';
                                nt.ParentId = leadRec.Id;
                                nt.Body = leadRec.Marketing_Comments__c;
                                newNotes.add(nt);
                        }
                        if((leadRec.Screening_Comments__c != oldMap.get(leadRec.Id).Screening_Comments__c) && leadRec.Screening_Comments__c!=NULL && leadRec.Screening_Comments__c!=''){
                                Note nt= new Note();
                                nt.Title=  'Screening Comments';
                                nt.ParentId = leadRec.Id;
                                nt.Body = leadRec.Screening_Comments__c;
                                newNotes.add(nt);
                        }
                        if((leadRec.Partner_Comments__c != oldMap.get(leadRec.Id).Partner_Comments__c) && leadRec.Partner_Comments__c!=NULL && leadRec.Partner_Comments__c!=''){
                                Note nt= new Note();
                                nt.Title=  'Partner Comments';
                                nt.ParentId = leadRec.Id;
                                nt.Body = leadRec.Partner_Comments__c;
                                newNotes.add(nt);
                        }
                    }
                 } 
                 If(newNotes.size()>0)
                    Insert newNotes;
            }
             /*------------------ Cycle 08 - PLM - Tarun Khandelwal -------------------------------*/
         // Method Name: track Lead Status Changes times 
            // Description: This method is to track the time of lead status changes.
            // Created By: Tarun Khandelwal

            public static void trackLeadStatusChangeTimes()
            {     List<Lead> triggernew = (List<Lead>)Trigger.new;
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
                 if(trigger.isBefore && trigger.isUpdate) {          
                   for(Lead leadRec : triggernew){
                       if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '0 New')
                        leadRec.Status_Changed_to_0_New__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '0 New Response')
                        leadRec.Status_Changed_to_0_New_Response__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '1 In Progress')
                        leadRec.Status_Changed_to_1_In_Progress__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '1 Marketing Qualified')
                        leadRec.Status_Changed_to_1_MarketingQualified__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '1 Partner Accepted')
                        leadRec.Status_Changed_to_1_Partner_Accepted__c = system.now();
                        else if(
                                ((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '1 Pass to Partner') 
                                    || 
                                 (leadRec.Status == '1 Pass to Partner' && (
                                        (leadRec.OwnerId != oldMap.get(leadRec.Id).OwnerID) 
                                            || 
                                        (leadRec.Partner_ID_1__c != oldMap.get(leadRec.Id).Partner_ID_1__c && leadRec.Partner_ID_1__c!=NULL && leadRec.Partner_ID_1__c!=''))))
                       {    
                            leadRec.Status_Changed_to_1_Pass_to_Partner__c = system.now();
                            leadRec.Passed_to_Partner__c = date.today();
                       }
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '2 Deferred/Future')
                        leadRec.Status_Changed_to_2_Deferred_Future__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '3 Existing Contact')
                        leadRec.Status_Changed_to_3_Existing_Contact__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '3 Existing Opportunity')
                        leadRec.Status_Changed_to_3_Existing_Oppty__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '3 New Contact')
                        leadRec.Status_Changed_to_3_New_Contact__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '4 New Opportunity')
                        leadRec.Status_Changed_to_4_New_Opportunity__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '4 Partner Registered')
                        leadRec.Status_Changed_to_4_Partner_Registered__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '5 Rejected')
                        leadRec.Status_Changed_to_5_Rejected__c = system.now();
                       else if((leadRec.Status != oldMap.get(leadRec.Id).Status) && leadRec.Status == '5 Retired')
                        leadRec.Status_Changed_to_5_Retired__c = system.now();      
                    } 
                 }
            }
          //*******************Cycle 08 PLM - Changes Ends : Tarun Khandelwal************************************/
            // Method Name: populateLeadOwnerName 
            // Description: This method is to populate the Lead Owner name in a field on lead.(Cycle -8)
            // Created By: Tarun Khandelwal
            //***************************************************************************************************************
         public static void populateLeadOwnerName()
            {    
            
               
                  List<Lead> triggernew = (List<Lead>)Trigger.new;
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
                  Map<Id,String> OwnerNameMap = new Map<Id,String>();
                  Map<Id,Boolean> OwnerIsActiveMap = new Map<Id,Boolean>();//CR-00122081: Added for Renaissance Phase-2
                  List<Id> queueOwnedLeads = new List<Id>();
                  List<Id> userOwnedLeads = new List<Id>();
                  Boolean isUpdate = LeadManagerPublicGroup__c.getValues('Lead Manager Public Group ID').Update_Owner_Fields__c;
                  
                 if(trigger.isBefore){       
                     if(trigger.isUpdate) {   
                       for(Lead leadRec : triggernew) {
                            if((leadRec.OwnerId != oldMap.get(leadRec.Id).OwnerId  || isUpdate) && (String.valueOf(leadRec.OwnerId).startsWith('00G'))){   
                                    queueOwnedLeads.add(leadRec.OwnerId);
                                }
                            if((leadRec.OwnerId != oldMap.get(leadRec.Id).OwnerId  || isUpdate) && (String.valueOf(leadRec.OwnerId).startsWith('005'))){
                                    userOwnedLeads.add(leadRec.OwnerId);
                                }
                            }
                        }
                    if(trigger.isInsert) {
                        for(Lead leadRec : triggernew) {
                              if(String.valueOf(leadRec.OwnerId).startsWith('00G')){                      
                                   queueOwnedLeads.add(leadRec.OwnerId);
                               }
                              if(String.valueOf(leadRec.OwnerId).startsWith('005')){
                                   userOwnedLeads.add(leadRec.OwnerId);
                               }
                            }
                        }
                if(queueOwnedLeads.size()>0)
                        {   List<Group> queueName = [Select Id,Name from Group where Id IN :queueOwnedLeads];
                         for (Group grp :queueName)
                             OwnerNameMap.put(grp.Id, grp.Name);            
                        }
                if(userOwnedLeads.size()>0)
                        {  List<User> userName = [Select Id,Name,IsActive from User where Id IN :userOwnedLeads];
                         for (User usr : userName){
                             OwnerNameMap.put(usr.Id, usr.Name);
                             OwnerIsActiveMap.put(usr.Id,usr.IsActive);// CR-00122081: Added for Renaissance Phase-2
                             }
                        }  
                    for(Lead leadRec : triggernew) {
                        if(trigger.isInsert || isUpdate || leadRec.OwnerId != oldMap.get(leadRec.Id).OwnerId  ){
                            leadRec.Owner_Name__c = OwnerNameMap.get(leadRec.OwnerId);
                            if(OwnerIsActiveMap.keyset().contains(leadRec.OwnerId) && OwnerIsActiveMap.get(leadRec.OwnerId) != null)
                                leadRec.Owner_Status__c = OwnerIsActiveMap.get(leadRec.OwnerId);  //CR-00122081: Added for Renaissance Phase-2     
                        }
                       }
                  } 
                  recursive.isLeadFirstRun=true;
                  
            }
        /*-----------------------Changes Ends : Tarun Khandelwal------------------------------------*/

        //---------Changes Start for CR-00015605: Sanjib ----------------------------------
        //--------- Modified below function for CR-00088193 by Manik Chaudhary
        public static void populateLeadScreeningOnCampaignMember(){

            if(!recursive.isCamMemUpdate){  
                recursive.isCamMemUpdate = true;
                List<Lead> listLead = new List<Lead>();
                List<CampaignMember> lstMember = new List<CampaignMember>();
                //Added by Manik Chaudhary against CR-00088193
            List<CampaignMember> lstcMemberupdate =new List<CampaignMember>();
                
                if(trigger.isUpdate && trigger.isAfter){        
                        listLead = [Select Id, LDR__r.Name,Status,LastModifiedDate, LDR__r.Id, LDR__c, Pass_to_Sales_Date__c, Screening_Results__c From Lead WHERE id IN:Trigger.new AND Status ='1 Marketing Qualified'];
                    if(listLead.size()>0){
                     // Below query changes by Manik Chaudhary against CR-00088193 to avoid the update of all the campaign members of all the leads
                     //  lstMember = [Select Id,Lead_Screening_Results__c, Lead_Screening_Pass_Date__c, Lead_Screening_Owner__c, LeadId, LastModifiedDate, CreatedDate ,Response_Date__c From CampaignMember WHERE leadid IN: Trigger.new AND Response_Date__c !=null order by Response_Date__c desc];
                        lstMember = [Select Id,Lead_Screening_Results__c, Lead_Screening_Pass_Date__c, Lead_Screening_Owner__c, LeadId, LastModifiedDate, CreatedDate ,Response_Date__c From CampaignMember WHERE leadid IN: listLead AND Response_Date__c !=null order by Response_Date__c desc];
                           if(lstMember.size()>0)  {                 
                                for(Lead le : listLead){
                                    lstMember[0].Lead_Screening_Results__c = le.Screening_Results__c;
                                    lstMember[0].Lead_Screening_Pass_Date__c = le.LastModifiedDate;
                                    lstMember[0].Lead_Screening_Owner__c = le.LDR__c;
                                }                 
                    lstcMemberupdate.add(lstMember[0]);
                    //Commented line below by Manik Chaudhary for CR-00088193
                    //update lstMember;}
                    if(!(lstcMemberupdate.isempty()))
                    {
                        Database.SaveResult[] rslts= Database.update(lstcMemberupdate,false);
                    }}
                    }
                
                }
            }
        }
        //---------Changes End for CR-00015605: Sanjib ----------------------------------

        //***************** Changes Start for CR-00022666: Somya ***************************/
        // Method Name: PartnerIdCheckForMasterAccountLayout 
        // Description: This method checks "Partner ID" field will only accept partner ID values that are tied directly to Master Account Layout record type 
        // Created By: Somya Garg
        //***********************************************************************************
        public static void PartnerIdCheckForMasterAccountLayout()
        {   
            
            //To hold the 'Master Account Layout' Record Type Id
            String PartnerAccountRecType = recursive.PartnerAccountRecType;
            //To hold account records
            set<String> setOfPartnerIds = new set<String>();
            //To hold the valid accounts
            set<String> setOfValidAccounts = new set<String>();
            List<Lead> triggernew = (List<Lead>)Trigger.new;
            Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
            
              //Populating the list with recently Partner Id's
            for(Lead leadRec : triggernew) 
              {
                if((trigger.isBefore && trigger.isInsert && leadRec.Partner_ID_1__c !=null && leadRec.Partner_ID_1__c !='')
                   ||
                (trigger.isBefore && trigger.isUpdate && leadRec.Partner_ID_1__c !=null && leadRec.Partner_ID_1__c != oldMap.get(leadRec.Id).Partner_ID_1__c))
                    setOfPartnerIds.add(leadRec.Partner_ID_1__c);                      
               } 
                   
             if(!setOfPartnerIds.isEmpty())
                {   
                  for (Account acc : [Select ID,Partner_ID__c from Account where Partner_ID__c IN :setOfPartnerIds AND RecordTypeId =: PartnerAccountRecType]) {
                    setOfValidAccounts.add(acc.Partner_ID__c);
                }
                }     
             for(Lead leadRec : triggernew) 
              {
                //Added for PLM2: Status != PLM_Constants.LEAD_STATUS_DECLINED condtion
                //Added for CR-00069091  &&  leadRec.Status != '5 Retired' && leadRec.Status != 'Archieved'    By    MSJ Singitham      
                if((trigger.isBefore && trigger.isInsert && leadRec.Partner_ID_1__c !=null && leadRec.Partner_ID_1__c !='')
                    || 
                (trigger.isBefore && trigger.isUpdate && leadRec.Partner_ID_1__c !=null && leadRec.Partner_ID_1__c != oldMap.get(leadRec.Id).Partner_ID_1__c && (leadRec.Status != PLM_Constants.LEAD_STATUS_DECLINED &&  leadRec.Status != '5 Retired' && leadRec.Status != '5 Archived')))
                    { if(!setOfValidAccounts.contains(leadRec.Partner_ID_1__c))
                        leadRec.addError('Invalid value entered for Partner ID');
                    }      
                }
            
        }

        /*---------Changes End for CR-00022666: Somya ----------------------------------*/

            
            /** Chages starts for- CR-00018244 ***/
            //This method is to populate the Date on Lead when Lead's status was stamped as New
            public static void calculateLeadAge(List<Lead> leads) {
                
                //Universal start date
                Date universalStartDate = date.newInstance(0001, 1, 1); 
                //Map<String, Integer> daysWithDayNumber = new Map<String, Integer>();

                //Loop through the leads and stamp the New Status Date
                for(Lead lead : leads) {
                    
                    //Check if this is lead met the criteria
                    if(lead.Status != null && lead.Status != '' 
                            && (lead.Status.equalsIgnoreCase('5 Rejected') 
                                || lead.Status.equalsIgnoreCase('1 In Progress') 
                                || lead.Status.equalsIgnoreCase('2 Deferred/Future')
                                || lead.Status.equalsIgnoreCase('3 Existing Contact')
                                || lead.Status.equalsIgnoreCase('3 Existing Opportunity')
                                || lead.Status.equalsIgnoreCase('3 New Contact')
                                || lead.Status.equalsIgnoreCase('4 New Opportunity')                                                                        
                               )
                            && lead.Date_When_Status_New__c != null
                            && lead.Time_In_New_Status_Hours__c == null) {
                        
                        //Start Age
                        DateTime startDate = lead.Date_When_Status_New__c;
                        
                        //End Date
                        DateTime endDate = DateTime.Now();
                        
                        //Hours difference
                        Decimal miliSeconds = decimal.valueOf((endDate.getTime() - lead.Date_When_Status_New__c.getTime()));
                        
                        //Find day number of start date
                        Integer startDay = Math.mod(universalStartDate.daysBetween(Date.valueOf(startDate)), 7);
                        
                        //Find day number of start date
                        Integer endDay = Math.mod(universalStartDate.daysBetween(Date.valueOf(endDate)), 7);
                        
                        //Days between Start date and end Date
                        Integer ageInDays = Date.valueOf(startDate).daysBetween(date.valueOf(endDate));
                        
                        //variable to hold the age in hours
                        Decimal agingMiliSeconds;

                        //Skip Weekends
                        if(Date.valueOf(startDate) == Date.valueOf(endDate)) {
                            
                            //Status changed on Same day
                            agingMiliSeconds = miliSeconds;
                        } else if(startDay > endDay) {
                            
                            //Aging Hours
                            agingMiliSeconds = miliSeconds - (1000*60*60*2*24*((ageInDays+7)/7));
                        } else {
                            
                            //Aging Hours
                            agingMiliSeconds = miliSeconds - (1000*60*60*2*24*(ageInDays/7));
                        }
                        
                        lead.Time_In_New_Status_Hours__c = agingMiliSeconds/(1000*60*60);
                    }
                }
            }
            /** Chages ends for- CR-00018244 ***/
            

            /******************* Code Added for CR-00034114 Start : Ponna Gopal******************************************/
            // Method Name: calculateLeadStatusUnprocessedAge 
            // Description: This method is used to populate the time taken (Number of Days Unprocessed) by a lead owner
            //                  to move the Lead from the statuses of ?0 New?, ?0 New Response? and ?1 Marketing Qualified?
            //                  to any other lead status.
            // Parameter  : List of Lead Records
            // Return     : void
            //***************************************************************************************************************
            
            public static void calculateLeadStatusUnprocessedAge(List<Lead> listLead) {
            
                // Global start date
                Date globalStartDate = date.newInstance(0001,1,1);
                String leadOwner;
                Date startDate;
                
                //Loop through the List of Leads
                for(Lead leadRecord : listLead) {
                    leadOwner = leadRecord.OwnerId;
                    if(leadRecord.Days_Unprocessed__c == null) {
                        leadRecord.Day_When_Status_New__c = System.Now();
                        //System.debug('leadRecord.Day_When_Status_New__c ********>>>>>'+leadRecord.Day_When_Status_New__c);
                    }
                    //Check if this lead meeting the criteria
                    if(leadRecord.Status != null && leadRecord.Status != '' 
                            && (leadRecord.Status.equalsIgnoreCase('1 In Progress') 
                                || leadRecord.Status.equalsIgnoreCase('2 Deferred/Future')
                                || leadRecord.Status.equalsIgnoreCase('3 Existing Contact')
                                || leadRecord.Status.equalsIgnoreCase('3 Existing Opportunity')
                                || leadRecord.Status.equalsIgnoreCase('3 New Contact')
                                || leadRecord.Status.equalsIgnoreCase('4 New Opportunity')         
                                || leadRecord.Status.equalsIgnoreCase('1 Partner Accepted')
                                || leadRecord.Status.equalsIgnoreCase('1 Pass to Partner')
                                || leadRecord.Status.equalsIgnoreCase('4 Partner Registered')
                                || leadRecord.Status.equalsIgnoreCase('5 Rejected')
                                || leadRecord.Status.equalsIgnoreCase('5 Retired')
                                || leadRecord.Status.equalsIgnoreCase('1 Partner Declined')
                            )
                            && leadOwner.trim().startsWith('005')
                            && leadRecord.Day_When_Status_New__c != null
                            && leadRecord.Days_Unprocessed__c == null) {
                    
                        
                        if(leadRecord.Pass_to_Sales_Date__c != null && leadRecord.Screening_Results__c!= '' && leadRecord.Screening_Results__c!= null && (
                                                                        leadRecord.Screening_Results__c.equalsIgnoreCase('Tele-Qualified')
                                                                        || leadRecord.Screening_Results__c.equalsIgnoreCase('BDR Qualified') 
                                                                        || leadRecord.Screening_Results__c.equalsIgnoreCase('Did Not Pass')
                                                                        )) {
                            startDate = Date.valueOf(leadRecord.Pass_to_Sales_Date__c);
                        }
                         else if(leadRecord.Distribution_Date__c != null && leadRecord.Screening_Results__c!= '' && leadRecord.Screening_Results__c!= null && (
                                                                        leadRecord.Screening_Results__c.equalsIgnoreCase('Pre-Qualified')
                                                                        || leadRecord.Screening_Results__c.equalsIgnoreCase('Passed - Existing Opportunity')
                                                                        || leadRecord.Screening_Results__c.equalsIgnoreCase('Passed Unscreened')
                                                                        || leadRecord.Screening_Results__c.equalsIgnoreCase('List Load')
                                                                        || leadRecord.Screening_Results__c.equalsIgnoreCase('Pre-Sales Qualified')
                                                                        )) {
                            startDate = leadRecord.Distribution_Date__c;
                        }
                        
                        //End Date
                        DateTime endDate = System.Now();
                        
                        // Check if startDate not null
                        if(startDate != null) {
                        
                            // Find the Day Number(in a week) in which the Start Day is going to fall
                            Integer dayNumberStartDay = Math.mod(globalStartDate.daysBetween(startDate), 7);
                            
                            // Find the Day Number(in a week) in which the End Day is going to fall
                            Integer dayNumberEndDay = Math.mod(globalStartDate.daysBetween(Date.valueOf(endDate)), 7);
                            
                            //Days between Start date and End Date
                            Integer ageInDays = startDate.daysBetween(Date.valueOf(endDate));
                            
                            //Variable to hold the Age in Days
                            Integer exactAgeInDays;
            
                            //Skip The Weekends
                            if(startDate == Date.valueOf(endDate)) {
                                //Status changed on Same day
                                exactAgeInDays = 0;
                            } 
                            else if(dayNumberStartDay > dayNumberEndDay) {
                                //Age in Days
                                exactAgeInDays = ageInDays - (2*((ageInDays+7)/7));
                            } 
                            else {
                                //Age in Days
                                exactAgeInDays = ageInDays - (2*(ageInDays/7));
                            }
                            //System.debug('exactAgeInDays >>>>>>'+ exactAgeInDays);
                            
                            // Assign to Days Unprocessed
                            if(exactAgeInDays >= 0) {
                                leadRecord.Days_Unprocessed__c = exactAgeInDays;
                            }
                            else {
                                leadRecord.Days_Unprocessed__c = null;
                            }
                            //System.debug('leadRecord.Days_Unprocessed__c >>>>>>'+leadRecord.Days_Unprocessed__c);
                            
                            // Reset the Flag Is Days Unprocessed
                           // leadRecord.Is_Days_Unprocessed__c = True;
                        }
                    }
                    
                }
            
            }
            /********************* Code Added for CR - 00034114 End *********************/

         
            
           //***************************************************************************************************************
            // Method Name: populateDescriptionOfCampaign
            // Description: populates Description of the Last Campaign Response field, on Lead
            // Created By: Radhika Bahl
            // for CR-00041541
            //***************************************************************************************************************
            public static void populateDescriptionOfCampaign()
            {
                System.debug('inside populateDescriptionOfCampaign');
                //added as part of Renaisance Phase 2- start
                  Map<Id,Lead> newMap = (Map<Id,Lead>)Trigger.NewMap;
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
                  map<id,lead> leadRecIdmap = new map<id,lead>();
                //added as part of Renaisance Phase 2- end

                List<Lead> listNewLead = (List<Lead>)Trigger.new;   
                Map<Id,Lead> mapCampaignIdLead = new Map<Id,Lead>();    //stores Last Campaign Response Id field and Lead Record
                //CR-00135563 - Start - Nov 2015 SFA Enhancement - Create a map to store campaign and all leads associated to it
                Map<String,List<Lead>> campaignIDLeadListMap = new Map<String,List<Lead>>();      
                //CR-00135563 - End - Nov 2015 SFA Enhancement
                  if((trigger.isBefore && trigger.isInsert) || (trigger.isBefore && trigger.isUpdate)) { //before update and insert of Lead
                        for(Lead leadRec : listNewLead) {                  

                            if(leadRec.Last_Campaign_Response_ID__c != Null && leadRec.Last_Campaign_Response_ID__c != '') {
                                mapCampaignIdLead.put(leadRec.Last_Campaign_Response_ID__c,leadRec);   //if Last Campaign Response on Lead is not Null, then create a map
                            }
                            //CR-00135563 - Start - Nov 2015 SFA Enhancement - Population Of Map
                            if(leadRec.Campaign_Id__c == Null || (leadRec.Campaign_Id__c != NUll && leadRec.Campaign_Id__c == '')){
                                leadRec.Solutions_for_IT_Outcomes__c = '';
                                leadRec.IT_Outcomes__c = '';
                            }
                            if((Trigger.isInsert && !String.isBlank(leadRec.Campaign_Id__c)) || (Trigger.isUpdate && !String.isBlank(leadRec.Campaign_Id__c) && leadRec.Campaign_Id__c != oldMap.get(leadRec.ID).Campaign_Id__c)){
                                if(campaignIDLeadListMap != Null){
                                    if(campaignIDLeadListMap.containsKey(leadRec.Campaign_Id__c) && campaignIDLeadListMap.get(leadRec.Campaign_Id__c) != Null){
                                    system.debug('.entered here first.');
                                        List<Lead> leadRecList = campaignIDLeadListMap.get(leadRec.Campaign_Id__c);
                                        leadRec.Solutions_for_IT_Outcomes__c = '';
                                        leadRec.IT_Outcomes__c = '';
                                        leadRecList.add(leadRec);
                                        campaignIDLeadListMap.put(leadRec.Campaign_Id__c,leadRecList);
                                    }
                                    if(!campaignIDLeadListMap.containsKey(leadRec.Campaign_Id__c) || (campaignIDLeadListMap.containsKey(leadRec.Campaign_Id__c) && campaignIDLeadListMap.get(leadRec.Campaign_Id__c) == Null)){
                                    system.debug('.entered here second.');
                                        List<Lead> leadRecList = new List<Lead>();
                                        leadRec.Solutions_for_IT_Outcomes__c = '';
                                        leadRec.IT_Outcomes__c = '';
                                        leadRecList.add(leadRec);
                                        campaignIDLeadListMap.put(leadRec.Campaign_Id__c,leadRecList);
                                    }
                                }
                            }                       
                            //CR-00135563 - End - Nov 2015 SFA Enhancement
                          //Added as part of Renaisance Phase 2 - start
                          if(trigger.isUpdate){
                              if(newMap.get(leadRec.id).Last_Campaign_Response__c != oldmap.get(leadRec.id).Last_Campaign_Response__c){
                                 //add lead assignment product to lead
                                 leadRecIdmap.put(leadRec.Campaign_id__c,leadRec);
                              }
                          }
                          //Added as part of Renaisance Phase 2 - end
                        }
                        //modified as part of Renaisance Phase 2
                    //CR-00135563 - Start - Nov 2015 SFA Enhancement - 
                    if(!mapCampaignIdLead.isEmpty() || leadRecIdmap.keyset().size() > 0 || (campaignIDLeadListMap != null && !campaignIDLeadListMap.isEmpty())) {// added OR condition as part of Renaisance Phase 2
                    //CR-00135563 - End - Nov 2015 SFA Enhancement - 
                          //added fields in Query and where clause Renaisance Phase 2
                           //CR-00135563 - Start - Nov 2015 SFA Enhancement - Added Name,Solutions_for_IT_Outcomes__c,IT_Outcomes__c Fields in the Query
                          List<Campaign> listCampaign = [Select Name,Solutions_for_IT_Outcomes__c,IT_Outcomes__c,Id,Description,Lead_Assignment_Product__c,Product_Lead_Filter__c from Campaign where Id IN : mapCampaignIdLead.keySet() OR id IN: leadRecIdmap.keyset() OR ID IN : campaignIDLeadListMap.keyset() order by LastModifiedDate]; //obtaining campaign's description field (whose id is on Lead i.e. in map created above)
                          //CR-00135563 - End - Nov 2015 SFA Enhancement
                          for(Campaign campaignRecord : listCampaign) {
                            if(mapCampaignIdLead.containsKey(campaignRecord.Id)) {
                              Lead leadRecord = mapCampaignIdLead.get(campaignRecord.Id);    //obtaining Lead record from the map created above, using the key (last response camapign ID)
                              leadRecord.Last_Campaign_Response_Description__c = campaignRecord.Description;    //updating Lead Record's Last Campaign Description field
                              System.debug('leadRecord.Last_Campaign_Response_Description__c'+leadRecord.Last_Campaign_Response_Description__c);
                            }
                            //Added as part of Renaisance Phase 2 - start
                             if(leadRecIdmap.keyset().contains(campaignRecord.id)){
                                 if(leadRecIdmap.get(campaignRecord.id).Product_Lead_Filter__c != null)
                                     leadRecIdmap.get(campaignRecord.id).Product_Lead_Filter__c = leadRecIdmap.get(campaignRecord.id).Product_Lead_Filter__c+';'+campaignRecord.Product_Lead_Filter__c;
                                 else
                                   leadRecIdmap.get(campaignRecord.id).Product_Lead_Filter__c = campaignRecord.Product_Lead_Filter__c;
                                 
                                 if(leadRecIdmap.get(campaignRecord.id).Lead_Assignment_Product_New__c != null)
                                    leadRecIdmap.get(campaignRecord.id).Lead_Assignment_Product_New__c= leadRecIdmap.get(campaignRecord.id).Lead_Assignment_Product_New__c+';'+campaignRecord.Lead_Assignment_Product__c;
                                 else
                                   leadRecIdmap.get(campaignRecord.id).Lead_Assignment_Product_New__c = campaignRecord.Lead_Assignment_Product__c;
                                 
                                 if(leadRecIdmap.get(campaignRecord.id).Lead_Assignment_Product_New__c != null)
                                    leadRecIdmap.get(campaignRecord.id).Lead_Assignment_Product_New__c = removeDuplicateValues(leadRecIdmap.get(campaignRecord.id).Lead_Assignment_Product_New__c);
                                 if(leadRecIdmap.get(campaignRecord.id).Product_Lead_Filter__c != null)
                                    leadRecIdmap.get(campaignRecord.id).Product_Lead_Filter__c = removeDuplicateValues(leadRecIdmap.get(campaignRecord.id).Product_Lead_Filter__c );
                             }
                            //CR-00135563 - Start - Nov 2015 SFA Enhancement 
                            if(campaignIDLeadListMap.containsKey(campaignRecord.Id)) {
                            system.debug('.entered here 9th.');
                            for(Lead leadRec : campaignIDLeadListMap.get(campaignRecord.Id)){
                                    //newMap.get(leadRec.ID).Solutions_for_IT_Outcomes__c = '22' ;
                                    //newMap.get(leadRec.ID).IT_Outcomes__c = '23' ;
                                    leadRec.Solutions_for_IT_Outcomes__c = campaignRecord.Solutions_for_IT_Outcomes__c ;
                                    leadRec.IT_Outcomes__c = campaignRecord.IT_Outcomes__c ;
                                }
                            }
                            //CR-00135563 - End - Nov 2015 SFA Enhancement
                            //Added as part of Renaisance Phase 2 - end
                          }
                    }
              }
                /* if((trigger.isBefore && trigger.isInsert) || (trigger.isBefore && trigger.isUpdate)) //before update and insert of Lead
                  { 
                    for(Lead leadRec : triggernew) 
                    {
                        //fetching campaign's description field on Lead
                       Campaign campObj=[select Id, Description from Campaign where Id=:leadRec.Last_Campaign_Response_ID__c];
                       leadRec.Last_Campaign_Response_Description__c=campObj.Description;
                       //System.debug('Description value:'+campObj.Description);
                    }
                  } */
            }
            // **************************************************************************************************************
            // Name       :   assignExistingAccountTerritoryId    
            // Description:   Method to update the Existing Account Territory Id on Leads on basis of 
            //                the primary field sales territory value on Accounts[CR-00043930]
            // Parameters :   none  
            // Returns    :   void
            // **************************************************************************************************************
            public static void assignExistingAccountTerritoryId() {
                Set<Id> setAccountId = new Set<Id>();
                List<Lead> triggerNew = (List<Lead>)Trigger.new;
                
                 //CR-00084385 Begin : Modified to fix too many SOQL error
                if(Trigger.isBefore && Trigger.isInsert){
                    for(Lead leadObj : triggerNew) {
                        if(leadObj.Account_Id__c != null) {
                           setAccountId.add(leadObj.Account_Id__c);
                        }
                    }
                }
                
                if(Trigger.isBefore && Trigger.isUpdate){
                    Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;         
                    for(Lead leadObj : triggerNew) {
                        if(leadObj.Account_Id__c != null && leadObj.Account_Id__c != mapOldLead.get(leadObj.Id).Account_Id__c ) {
                           setAccountId.add(leadObj.Account_Id__c);
                        }
                    }           
                }//end of if
               //CR-00084385 END
               
                if(!setAccountId.isEmpty()) {
                    Map<Id, Account> territoryIdToUpdate = new Map<Id, Account>([select Id,Primary_Field_Sales_Territory__c from Account where Id IN : setAccountId]);
                    for(Lead newLeads : triggerNew) {
                        if(territoryIdToUpdate.get(newLeads.Account_Id__c) != null) {
                            newLeads.Existing_Account_Territory_ID__c = territoryIdToUpdate.get(newLeads.Account_Id__c).Primary_Field_Sales_Territory__c;
                        }
                    }
                }
            }
            //***************************************************************************************************************
            // Method Name:populatePBMInformationOnLead 
            // Description: This method populate PBM,PFCT PBM,PFST PBM on lead.(CR-00039320)
            // Created By: Bhavesh Mistry 
            //***************************************************************************************************************  
            
        public static void populatePBMInformationOnLead ()  {
                       
                         
                        Boolean flag=ByPassTrigger.userCustomMap('populatePBMInformationOnLead','Lead');
                        if(flag) return;
                       
                        if(trigger.IsBefore &&(trigger.isUpdate || trigger.isInsert)) {
                        
                        List<Lead> triggerNewLeadList = (List<Lead>)Trigger.new;
                        Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;

                        //Map<Id,Lead> triggerNewLeadMap = (Map<Id,Lead>)Trigger.newMap;
                         List<lead> partnerLeadList=new List<lead>();
                        Set<Id> accountIdSet=new Set<Id>();
                        Set<Id> sptSet=new Set<Id>(); 
                        Set<Id> pfstSet=new Set<Id>(); 
                        Set<Id> pcstSet=new Set<Id>(); 
                        
                        Map<Id,VMWare_Territory__c> sptMap = null;
                        Map<Id,Account> accountMap = null;
                        Map<Id,VMWare_Territory__c> pfstMap = null;
                        Map<Id,VMWare_Territory__c> pcstMap = null;
                        
                        for(Lead olead :triggerNewLeadList ) {   
                                     //Add code for CR-00047143
                                    if( (olead.Partner_Account__c != null && olead.Partner_Account__c != oldMap.get(olead.Id).Partner_Account__c ) || 
                                          (olead.Channel_Overlay_Territory__c != oldMap.get(olead.Id).Channel_Overlay_Territory__c )||
                                          (olead.Strategic_partner_territory__c != oldMap.get(olead.Id).Strategic_partner_territory__c ) ||
                                          (olead.Primary_Field_Sales_Territory__c != oldMap.get(olead.Id).Primary_Field_Sales_Territory__c ) ||
                                          (olead.Primary_Channel_Sales_Territory__c != oldMap.get(olead.Id).Primary_Channel_Sales_Territory__c ))
                                        //End :CR-00047143
                                          {
                                            accountIdSet.add(olead.Partner_Account__c);
                                            sptSet.add(olead.Strategic_partner_territory__c);
                                            pfstSet.add(olead.Primary_Field_Sales_Territory__c);
                                            pcstSet.add(olead.Primary_Channel_Sales_Territory__c);
                                            partnerLeadList.add(olead);
                                           
                                         }
                                   } 
                
                         
                         if(accountIdSet.size()>0) {
                            accountMap = new Map<Id,Account>([Select Id,PBM__r.id,PBM__r.name from Account where Id IN:accountIdSet]);
                        
                         }
                         if(sptSet.size()>0) {
                            sptMap = new Map<Id,VMWare_Territory__c>([Select Id,PBM__c,Name,PBM__r.id,PBM__r.name from VMWare_Territory__c where Id IN:sptSet]);
                         }
                         if(pfstSet.size()>0) {
                            pfstMap=new Map<Id,VMWare_Territory__c>([Select Id,PBM__c,Name,PBM__r.id,PBM__r.name from VMWare_Territory__c where Id IN:pfstSet]);
                         }
                         if(pcstSet.size()>0) {
                            pcstMap=new Map<Id,VMWare_Territory__c>([Select Id,PBM__c,Name,PBM__r.id,PBM__r.name from VMWare_Territory__c where Id IN:pcstSet]);
                         }
                        if( !partnerLeadList.isempty())  {
                        
                          for(Lead leadNewRec:partnerLeadList)
                            {
                                    leadNewRec.PBM1__c =null;
                                    leadNewRec.PFCT_PBM1__c=null;
                                     leadNewRec.PFST_PBM1__c =null;
                             
                               if(leadNewRec.Partner_ID_1__c != null ) {
                                    if(leadNewRec.Channel_Overlay_Territory__c != null && leadNewRec.Partner_Account__c != null) {                              
                                             leadNewRec.PBM1__c = accountMap.get(leadNewRec.Partner_Account__c).PBM__r.id;
                                    }
                                    else if (leadNewRec.Strategic_partner_territory__c != null ) {
                                            leadNewRec.PBM1__c = sptMap.get(leadNewRec.Strategic_partner_territory__c).PBM__r.id;
                                    }
                                    else if (leadNewRec.Primary_Field_Sales_Territory__c != null ) {
                                            if(pfstMap.get(leadNewRec.Primary_Field_Sales_Territory__c).name.indexOf('C1')!=-1 || pfstMap.get(leadNewRec.Primary_Field_Sales_Territory__c).name.indexOf('C2')!=-1 || (pfstMap.get(leadNewRec.Primary_Field_Sales_Territory__c).name.indexOf('MidMkt')!=-1 && leadNewRec.HH_Cleansed__c ==true )) {
                                                      leadNewRec.PFST_PBM1__c = pfstMap.get(leadNewRec.Primary_Field_Sales_Territory__c).PBM__r.id;
                                              } else if (leadNewRec.Primary_Channel_Sales_Territory__c != null){
                                                    leadNewRec.PFCT_PBM1__c = pcstMap.get(leadNewRec.Primary_Channel_Sales_Territory__c).PBM__r.id;
                                              }
                                    } 
                                    else if (leadNewRec.Primary_Channel_Sales_Territory__c != null){
                                            leadNewRec.PFCT_PBM1__c = pcstMap.get(leadNewRec.Primary_Channel_Sales_Territory__c).PBM__r.id;
                                    
                                    }                                                    
                                }
                            }
                         }                  
                       }
                      
                  }
            //End Method
             
                
             //***************************************************************************************************************
            // Method Name:calculateActiveAssignedleads 
            // Description: This method calculate Total no of  active assigned lead to partner Account.(CR-00037548)
            // Created By: Bhavesh Mistry 
            //***************************************************************************************************************  
            
             public static void calculateActiveAssignedleads()  {
                        Boolean flag=ByPassTrigger.userCustomMap('calculateActiveAssignedleads','Lead');
                        if(flag) return; 
                      if(!recursive.isfirstrunAssignedLead){ 
                        recursive.isfirstrunAssignedLead= true;               
                        List<Lead> triggernew = (List<Lead>)Trigger.new;
                        List<Lead> triggerold = (List<Lead>)Trigger.old;
                        
                        Set<Id> setPartnerAccountIds = new Set<Id>();             
                        Set<Id> setAccountIds = new Set<Id>(); 

                        Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
                            for(Lead olead :triggernew ) {   
          
                                    if(olead.Partner_Account__c != null && mapOldLead.get(olead.Id).Partner_Account__c != null && oLead.Partner_Account__c != mapOldLead.get(olead.Id).Partner_Account__c )
                                    {
                                        setAccountIds.add(olead.Partner_Account__c);
                                        setAccountIds.add(mapOldLead.get(olead.Id).Partner_Account__c);
                                    }
                                    if(olead.Partner_Account__c == null &&  mapOldLead.get(olead.Id).Partner_Account__c != null)
                                    {
                                        setAccountIds.add(mapOldLead.get(olead.Id).Partner_Account__c);
                                    }
                                    if(olead.Partner_Account__c != null && mapOldLead.get(olead.Id).Partner_Account__c == null)
                                    {
                                        setAccountIds.add(olead.Partner_Account__c);
                                    }
                            }
                          
                         if(setAccountIds != null && setAccountIds.size()>0) {
                         /* get the Total number of Leads on partner Accounts. */
                        AggregateResult[] groupedResults  =[Select count(id) totalLead,Partner_Account__c  from Lead  where Partner_Account__c  IN : setAccountIds And (Status = '1 Pass to Partner' or Status='1 Partner Accepted' or Status = '1 In Progress' or Status ='4 Partner Registered' or Status ='2 Deferred/Future') group by Partner_Account__c]; 
                        
                        Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select Id,Number_of_active_assigned_leads__c from Account where Id IN : setAccountIds]);
                      
                       //   Check whether Number_of_active_assigned_leads__c field value is same as the total number of active leads in that Account.If the values are same 
                        //    then do nothing else update the field with the total number of Number_of_active_assigned_leads__c in that Account. 
                        if(groupedResults.size()>0){
                                for (AggregateResult acct : groupedResults ){             
                                    acctsToUpdate.get((id)acct.get('Partner_Account__c')).Number_of_active_assigned_leads__c = (Decimal)acct.get('totalLead'); 
                                    setPartnerAccountIds.add((id)acct.get('Partner_Account__c'));
                                }
                           }      
                    
                                for(Account oAccount: acctsToUpdate.values())
                                     {
                                         if(!setPartnerAccountIds.contains(oAccount.Id)){
                                         
                                              oAccount.Number_of_active_assigned_leads__c = 0;
                                            }
                                     }
                
                    update acctsToUpdate.values();
                   }             
              }        
           }//end of method
                  /*
            This method is built to restrict user's from changing the lead status at the time of insert/update
            */
            public static void restrictStatusUpdate(){

            Boolean flag=ByPassTrigger.userCustomMap('restrictStatusUpdate','Lead');
            if(flag) return;
            
            //bypass the validation in case of the trigger invoked by deal reg associotion
            if(PLM_Constants.isFromDealAssociate){
            return;
            }

             List<Lead> triggernew = (List<Lead>)Trigger.new;
             Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;

             String userProfileId = UserInfo.getProfileId();

             //CustomSettingUtility cs = new CustomSettingUtility();
             String profileName = CustomSettingUtility.getProfileName(userProfileId);

             //bypass the validation for system admin and api usre profiles
             if(profileName != null && ( profileName.equalsIgnoreCase('System Administrator') || profileName.equalsIgnoreCase('API User -Eloqua'))){
                 return;
             }

              if(trigger.isInsert) { 
                  
                  // custom setting for status values
                  for(Lead leadRec : triggernew){
                     if( leadRec.IsConverted == false && leadRec.Is_Deal_Registered__c == false && (leadRec.Status == '3 Existing Contact' || leadRec.Status == '3 New Contact' ||leadRec.Status == '3 Existing Opportunity' ||leadRec.Status == '4 New Opportunity' || leadRec.Status == '4 Partner Registered' )){

                      leadRec.addError('VMware Reps: This status is auto-populated once you click CONVERT and choose the appropriate option. VMware Partners: Please click \'Register Deal\' if this lead qualifies for opportunity registration.');

                    }//end of if
                  }//end of for
              }//end of insert logic

               if(trigger.isBefore && trigger.isUpdate) {

                   for(Lead leadRec : triggernew){
                        if(leadRec.Status != oldMap.get(leadRec.Id).Status){
                            if( leadRec.IsConverted == false && leadRec.Is_Deal_Registered__c == false && (leadRec.Status == '3 Existing Contact' || leadRec.Status == '3 New Contact' ||leadRec.Status == '3 Existing Opportunity' ||leadRec.Status == '4 New Opportunity' ||leadRec.Status == '4 Partner Registered' )){
                            leadRec.addError('VMware Reps: This status is auto-populated once you click CONVERT and choose the appropriate option. VMware Partners: Please click " Register Deal" if this lead qualifies for opportunity registration.');
                            }
                       }
                  }//end of for
              
                }//end of update logic
            }//end of method

         //***************************************************************************************************************
            // Method Name:updateLeadOwnerProfile
            // Description: This method calculates the profile of the lead owner and dosplays it(CR-00039600)
            // Created By: Archana Mujumdar 
            //***************************************************************************************************************  
             
           public static void updateLeadOwnerProfile()
           {
           
            Boolean flag=ByPassTrigger.userCustomMap('updateLeadOwnerProfile','Lead');
            if(flag) return;
            
            Map<Id,Lead> leadOldMap = (Map<Id,Lead>)Trigger.oldMap;
              Map<Id,Id> leadMap=new Map<Id,Id>();
              Map<Id,Lead> leadMapNew=new Map<Id,Lead>();
              Map<String, String> mapProfileNameMappings =new Map<String,String>();
                 Map<Id,User> userMap=new Map<Id,User>();
            if(trigger.IsBefore && trigger.isUpdate)
            {
                    for(Lead ld:(List<Lead>)Trigger.new)
                    {
                        String str=ld.OwnerId;
                       
                        if(ld.OwnerId!=leadOldMap.get(ld.Id).OwnerId)
                        {
                            if(!str.startsWith('005'))
                            {
                                ld.Lead_Owner_Profile__c=null;
                            }
                            else
                            {
                                leadMap.put(ld.Id,ld.OwnerId); 
                                leadMapNew.put(ld.Id,ld);
                            }
                        }
                        //CR-00079655 Start - Added logic to update Lead Owner Profile when Lead owner is same
                        
                        else if(ld.Lead_Owner_Profile__c == null){
                            if(!str.startsWith('005'))
                            {
                                ld.Lead_Owner_Profile__c=null;
                            }
                            else
                            {                       
                                leadMap.put(ld.Id,ld.OwnerId); 
                                leadMapNew.put(ld.Id,ld);
                            }
                        }
                        
                        // CR-00079655 - End
                    }
            }
            else if(trigger.IsBefore && trigger.isInsert)
            {
            for(Lead ld:(List<Lead>)Trigger.new)
                    {
                      String str=ld.OwnerId;
                     
                      if(!str.startsWith('005'))
                            {
                                ld.Lead_Owner_Profile__c=null;
                            }
                            else
                            {
                                leadMap.put(ld.Id,ld.OwnerId); 
                                  leadMapNew.put(ld.Id,ld);
                            }
                    
                    }
            
            }
            
            if(LeadMap.size()>0)
            {
            userMap=new Map<Id,User>([Select Id,ProfileId from user where Id IN:LeadMap.values()]);//check for the profile Id from the user
             for(Profile_Name_Mapping__c profCS: Profile_Name_Mapping__c.getAll().values()) {//check for the profile name 
                    mapProfileNameMappings.put(profCS.Profile_Id__c, profCS.Profile_Apex_Name__c);
                }
            }
          for(Id ld1:leadMap.keyset())
                    {
                    String str=leadMap.get(ld1);
                    String profileName;
                    if(str.startsWith('005'))
                    {
                    User usr=new User();
                    usr=userMap.get(str);
                    profileName=mapProfileNameMappings.get(usr.ProfileId);
                    Lead leadnew=leadMapNew.get(ld1);
                    leadnew.Lead_Owner_Profile__c=profileName;
                    }
                   }
           }
            //************************Code Added for CR-00037547 Start ******************************************************
            // Method Name:leadEntry 
            // Description: This method creates a record in Lead History Tracking every time Lead Status is changed.
            // Created By: Harsimrat Sachdeva
            //***************************************************************************************************************
        public static void leadHistoryEntry()
            {     
              
              List<Lead_History_Tracking__c> leadHistoryEntry = new List <Lead_History_Tracking__c> (); 
              List<Lead> triggernew = (List<Lead>)Trigger.new;
                  Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
                  if(trigger.isBefore&& trigger.isUpdate) {
                      for(Lead leadRec : triggernew){
                          if((leadRec.Partner_Account__c != oldMap.get(leadRec.Id).Partner_Account__c && oldMap.get(leadRec.Id).Partner_Account__c != null)){
                                leadRec.Previous_Partner__c=oldMap.get(leadRec.Id).Partner_Account__c;
                              }
                          }
                      }
                 if(trigger.isAfter && trigger.isUpdate) {  
                   for(Lead leadRec : triggernew){
                   
                        if((leadRec.isConverted == false)  && (leadRec.Status != oldMap.get(leadRec.Id).Status || leadRec.Partner_Account__c != oldMap.get(leadRec.Id).Partner_Account__c || leadRec.Conversion_Status__c != oldMap.get(leadRec.Id).Conversion_Status__c))
                         {
                      Lead_History_Tracking__c leadHistory=new Lead_History_Tracking__c();           
                      leadHistory.Lead_ID__c=leadRec.Id;
                      leadHistory.Lead_Status__c=leadRec.Status;
                      leadHistory.Pass_To_Partner_Date__c=leadRec.Passed_to_Partner__c;
                    
                        //Add code for CR-00055046
                      if(leadRec.Status_Changed_to_1_Partner_Accepted__c != null){            
                      leadHistory.Partner_accepted_Date__c=(leadRec.Status_Changed_to_1_Partner_Accepted__c).date();
                      
                     }
                    if(leadRec.Status_Changed_to_4_Partner_Registered__c!= null){
                    leadHistory.Partner_Registered_Date__c=(leadRec.Status_Changed_to_4_Partner_Registered__c).date();
                   
                    }
                    if(leadRec.Pass_to_Sales_Date__c!= null){
                      leadHistory.Screening_Pass_Date__c=(leadRec.Pass_to_Sales_Date__c).date();
                     
                     }  
                     if(leadRec.Status != null && leadRec.Status.equalsIgnoreCase('5 Rejected') && leadRec.Status_Changed_to_5_Rejected__c!=null){
                     leadHistory.Rejected_Date__c=(leadRec.Status_Changed_to_5_Rejected__c).date();
                     
                     }
                    leadHistory.Lead_Last_Modified_By__c=leadRec.LastModifiedById;
                    leadHistory.Lead_Owner_Id__c=leadRec.OwnerId;
                    leadHistory.Lead_Owner_Name__c=leadRec.Owner_Name__c;
                    leadHistory.Lead_Last_Modified_Date__c=leadRec.LastModifiedDate;
                    leadHistory.Conversion_Status__c=leadRec.Conversion_Status__c;
                    leadHistory.Previous_Owner__c=leadRec.Previous_Owner_del__c;
                    leadHistory.Current_Partner_ID__c=leadRec.Partner_Account__c;
                    leadHistory.Notes__c=leadRec.Description;
                    leadHistory.Opportunity_ID__c=leadRec.Report_convertedopportunityid__c;
                    leadHistory.Registration_ID__c=leadRec.Registration__c;
                    if(leadRec.Previous_Partner__c != null){
                        leadHistory.Previous_Partner_ID__c=leadRec.Previous_Partner__c;
                    }
                    leadHistoryEntry.add(leadHistory);
                    
                         }     

                                           
                                       }
                        if(recursive.HistoryFirstRun==true){
                         recursive.HistoryFirstRun=false;
                         if(leadHistoryEntry.size()>0)
                         {
                           insert leadHistoryEntry;
                         }
                                               }        
                    }
            }
            /********************* Code Added for CR - 00037547 End *********************/
            //***************************************************************************************************************
            // Method Name:updateSLADateonLead 
            // Description: This method update SLA for acceptance  and SLA Registration Date   on lead.(CR-00037545)
            // Created By: Bhavesh Mistry 
            //******************************************************************************************************************
        public static void updateSLADateonLead() {
                                    
                        
                         List<Lead> triggernew = (List<Lead>)Trigger.new;
                         Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
                         List<Lead> leadList = new List<Lead>();
                         Set<ID> partnerId = new set<ID>();
            
                  
                  for(Lead leadRec : triggernew) {
                   if(trigger.isBefore && trigger.isUpdate)  {            
                          if(leadRec.Partner_Account__c != null && leadRec.Partner_Account__c != oldMap.get(leadRec.Id).Partner_Account__c && leadRec.Status == '1 Pass to Partner')
                          {    
                                         
                              leadList.add(leadRec);
                              partnerId.add(leadRec.Partner_Account__c);
                          }
                       } 
                      if(trigger.isBefore && trigger.isInsert)  {            
                          if(leadRec.Partner_Account__c != null )
                          {    
                                         
                              leadList.add(leadRec);
                              partnerId.add(leadRec.Partner_Account__c);
                          } 
                      }
                  }
                     
                 if(partnerId != null && partnerId.size()>0 ) {
                  for(Account acct : [Select id, SLA_for_acceptance__c ,SLA_for_Registration__c FROM Account WHERE id IN: partnerId])
                  {
                      for(Integer j=0; j<leadList.size(); j++)
                        {
                                        
                          if(leadList[j].Partner_Account__c == acct.id && leadList[j].Partner_Account__c != null &&  leadList[j].Status =='1 Pass to Partner' && acct.SLA_for_acceptance__c != null && acct.SLA_for_Registration__c != null)  
                           {
                                
                              leadList[j].SLA_Acceptance_Date__c = date.today() + (Integer )acct.SLA_for_acceptance__c ;
                              leadList[j].SLA_Registration_Date__c = date.today() + (Integer)acct.SLA_for_Registration__c;
                           }
                      }       
                  } 
                 }
                 
               
                
            }
            //***************************************************************************************************************
            // Method Name:updateGEOFlag 
            // Description: This method updates Exclude Geo on lead.(CR-00037541)
            // Created By: Bhavesh Mistry 
            //***************************************************************************************************************  
           public static void updateGEOFlag()
          {
          
            List<Lead> triggernew = (List<Lead>)Trigger.new;
            Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
            
             for(Lead leadRec : triggernew) {
                 if(trigger.isBefore && trigger.isInsert) {
                    if(leadRec.Screening_Results__c == 'Tele-Qualified') {
                    leadRec.ISGEO__C= true;
                    }
                 }
                 if(trigger.isBefore && trigger.isUpdate) {
                            
                            String zip = mapOldLead.get(leadRec.Id).postal_code__c;
                            String city = mapOldLead.get(leadRec.Id).city__c;
                            String country = mapOldLead.get(leadRec.Id).country__c;
                            String oldAddress1 = mapOldLead.get(leadRec.Id).Address_1__c;
                            String oldAddress2 = mapOldLead.get(leadRec.Id).Address_2__c;
                            String oldScreeningResult = mapOldLead.get(leadRec.Id).Screening_Results__c;
                             if(leadRec.Address_1__c != oldAddress1 || leadRec.Address_2__c != oldAddress2 || leadRec.country__c != country || leadRec.city__c != city || leadRec.Postal_Code__c != zip || (leadRec.Screening_Results__c != oldScreeningResult && leadRec.Screening_Results__c == 'Tele-Qualified'))
                             {
                                 leadRec.ISGEO__C= true;
                             }
                 }
                 
                 
             }
             
         }
         
         //***************************************************************************************************************
            // Method Name:UpdateConAccAFterLeadConversion 
            // Description: This method updates field values on Contact those that were not updated during LeadConversion Process[BUG-00148725]
            // Created By: Sanjib Mahanta
            //***************************************************************************************************************  
         @future
         public static void UpdateConAccAFterLeadConversion(Set<Id> SetLeadId){
            List<Lead> triggernewList = new List<Lead>();
            if(SetLeadId != null){  
                triggernewList = [select id,isConverted,ConvertedContactId,ConvertedAccountId,ConvertedOpportunityId,Bounced_Email__c,Do_Not_Sync_Eloqua__c,AW_Lead_Score__c,
                                            Lead_Source_Most_Recent__c,AW_Lead_Source__c,Lead_Source_Detail_Most_Recent__c,
                                            Most_Recent_Traffic_Source__c,Most_Recent_Traffic_Source_Detai__c,Original_Traffic_Source__c,Original_Traffic_Source_Detail__c,
                                            AW_Region__c,Secondary_Lead_Source__c,AW_Email_Opt_Out__c,Record_Source__c,Legal_Acceptance_Contact__c,Legal_Acceptance_Date_Time__c,
                                            Legal_EULA_Filename__c,User_Agent__c,User_IP_Address__c,AW_Country__c,X3rd_Party_Emails__c,Industry_New__c,
                                            Notes_Comments__c,Partner_Contact_Email__c,Partner_Representative__c,Registered__c,AW_To_3rd_Party__c,Type__c,Solution_of_interest__c
                                            from Lead where Id IN:SetLeadId];
            }                               
            set<Id> conIdSet = new set<Id>();
            set<Id> AccIdSet = new set<Id>();
            set<Id> OppIdSet = new set<Id>();
            List<Contact> conList = new List<Contact>();
            List<Account_Extension__c> AccExList = new List<Account_Extension__c>();
            List<Opportunity> OppList = new List<Opportunity>();
            List<Contact> conListToUpdate = new List<Contact>();
            List<Account_Extension__c> AccExtentionListToUpdate = new List<Account_Extension__c>();
            List<Opportunity> OppListToUpdate = new List<Opportunity>();
            if(triggernewList != null && triggernewList.size() > 0){
                for(Lead olead :triggernewList){

                    if(olead.isConverted == true && olead.ConvertedContactId != null&& olead.ConvertedAccountId != null&& olead.ConvertedOpportunityId != null && RecursiveCheckForConvert == false) {
                        RecursiveCheckForConvert = true;
                        conIdSet.add(olead.ConvertedContactId);
                        AccIdSet.add(olead.ConvertedAccountId );
                        OppIdSet.add(olead.ConvertedOpportunityId);
                    }
                }
            }    
            if(conIdSet != null){
                conList = [Select Id,AW_Bounced_Email__c,AW_Do_Not_Sync_Eloqua__c,AW_Contact_Score__c,AW_Email_Opt_Out__c,AW_Lead_Source_Most_Recent__c,AW_Lead_Source__c,AW_Most_Recent_Lead_Source_Detail__c,AW_Most_Recent_Traffic_Source__c,AW_Most_Recent_Traffic_Source_Detail__c,AW_Original_Traffic_Source__c,AW_Original_Traffic_Source_Detail__c,AW_Region__c,AW_Secondary_lead_source__c,AW_Contact_field__c from Contact where Id IN:conIdSet];
            }  

            if(AccIdSet != null){
                
                AccExList = [Select Id,Account__c,Legal_Acceptance_Contact__c,AW_Lead_Source__c,Legal_Acceptance_Date_Time__c,Trial_EULA_Filename__c,AW_Notes__c,AW_Secondary_Lead_Source__c,User_Agent__c,User_IP_Address__c from Account_Extension__c  where Account__c IN:AccIdSet];
                
                
            }   

            if(OppIdSet != null){
                OppList = [Select Id,AW_Country__c,AW_3rd_Party_Emails__c,AW_Industry__c,AW_Lead_Source__c,AW_Notes_Comments__c,AW_Representative_Email__c,AW_Partner_Representative__c,AW_Region__c,AW_Registered__c,AW_To_3rd_Party__c,AW_Type__c,Solution_Of_interest__c from opportunity where Id IN:OppIdSet];
            }           
            if(triggernewList != null && triggernewList.size() > 0){          
                for(Lead lval:triggernewList){
                    
                   for(Contact con: conList){
                        
                    if(con.id == lval.ConvertedContactId){
                        
                        con.AW_Bounced_Email__c = lval.Bounced_Email__c;
                        con.AW_Do_Not_Sync_Eloqua__c = lval.Do_Not_Sync_Eloqua__c;
                        con.AW_Contact_Score__c = lval.AW_Lead_Score__c;
                        con.AW_Lead_Source_Most_Recent__c = lval.Lead_Source_Most_Recent__c;
                        con.AW_Lead_Source__c=lval.AW_Lead_Source__c;
                        con.AW_Most_Recent_Lead_Source_Detail__c = lval.Lead_Source_Detail_Most_Recent__c;
                        con.AW_Most_Recent_Traffic_Source__c = lval.Most_Recent_Traffic_Source__c;
                        con.AW_Most_Recent_Traffic_Source_Detail__c = lval.Most_Recent_Traffic_Source_Detai__c;
                        con.AW_Original_Traffic_Source__c = lval.Original_Traffic_Source__c;
                        con.AW_Original_Traffic_Source_Detail__c = lval.Original_Traffic_Source_Detail__c;
                        con.AW_Region__c=lval.AW_Region__c;
                        con.AW_Secondary_lead_source__c=lval.Secondary_Lead_Source__c;
                        con.AW_Email_Opt_Out__c = lval.AW_Email_Opt_Out__c;
                        
                        if(lval.Record_Source__c != null){
                            
                          L2OAWcontactPopulation__c L2OAWCP =L2OAWcontactPopulation__c.getInstance(lval.Record_Source__c);
                          if(L2OAWCP != null  && lval.Record_Source__c.contains(L2OAWCP.name)&& !(lval.Record_Source__c.contains('VMW Eloqua'))){ 
                              con.AW_Contact_field__c = L2OAWCP.AW_Contact__c;
                           }
                        }                  
                        conListToUpdate.add(con);
                    }   
                        
                   }
                    
                    
                    for(Account_Extension__c Acnt: AccExList){
                        
                    if(Acnt.Account__c == lval.ConvertedAccountId){
                        
                        Acnt.Legal_Acceptance_Contact__c  = lval.Legal_Acceptance_Contact__c;  
                        Acnt.AW_Lead_Source__c  = lval.AW_Lead_Source__c ;              
                        Acnt.Legal_Acceptance_Date_Time__c  = lval.Legal_Acceptance_Date_Time__c;               
                        Acnt.Trial_EULA_Filename__c  = lval.Legal_EULA_Filename__c;             
                        Acnt.AW_Notes__c  = lval.Notes_Comments__c;             
                        Acnt.AW_Secondary_Lead_Source__c  = lval.Secondary_Lead_Source__c;              
                        Acnt.User_Agent__c  = lval.User_Agent__c;               
                        Acnt.User_IP_Address__c  = lval.User_IP_Address__c;                
                                        
                        AccExtentionListToUpdate.add(Acnt);
                        
                    }           
                    
                    }
                    for(Opportunity Opp: OppList){
                        
                    if(Opp.id == lval.ConvertedOpportunityId){  
                        
                        Opp.AW_Country__c  = lval.AW_Country__c;
                        Opp.AW_3rd_Party_Emails__c  = lval.X3rd_Party_Emails__c;
                        Opp.AW_Industry__c  = lval.Industry_New__c;
                        Opp.AW_Lead_Source__c  = lval.AW_Lead_Source__c;
                        Opp.AW_Notes_Comments__c  = lval.Notes_Comments__c;
                        Opp.AW_Representative_Email__c  = lval.Partner_Contact_Email__c;
                        Opp.AW_Partner_Representative__c = lval.Partner_Representative__c;   
                        Opp.AW_Region__c  = lval.AW_Region__c;
                        Opp.AW_Registered__c  = lval.Registered__c;
                        Opp.AW_To_3rd_Party__c  = lval.AW_To_3rd_Party__c;
                        Opp.AW_Type__c  = lval.Type__c;
                        Opp.Solution_of_interest__c  = lval.Solution_of_interest__c;
                        //Start - Manish :: Added for CR-00140850 
                        Opp.Lead_Source_Most_Recent__c = lval.Lead_Source_Most_Recent__c;
                        //END - Manish :: Added for CR-00140850 
                        OppListToUpdate.add(Opp);
                        
                    }
                    
                    }
                System.debug('******conListToUpdate^^^^'+conListToUpdate);  
                }
            }   
            
            if(conListToUpdate.size() > 0 && conListToUpdate != null){
                Update conListToUpdate;
            }
            if(AccExtentionListToUpdate.size() > 0 && AccExtentionListToUpdate!= null){
                Update AccExtentionListToUpdate;
            }
            if(OppListToUpdate.size() > 0 && OppListToUpdate != null){
                Update OppListToUpdate;
            }
        }   
            
            /*-------------------------------------------------------------------------------------------------
            Method Name : emailNotificationToQualifiedLead
            Description: This method sends an email notification when the qualified lead is been assigned.(CR-00104200)
            Created By: Sanjib Mahanta
            -------------------------------------------------------------------------------------------------*/
            
            public static void emailNotificationToQualifiedLead() { 
            List<Lead> triggernew = (List<Lead>)Trigger.new;
            Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
            
            List<Messaging.SingleEmailMessage> sendEmailToAll = new List<Messaging.SingleEmailMessage>();
                    DateTime dtToday = System.today();
                     if(trigger.isUpdate && trigger.isAfter){  
                            for(Lead leadRec : triggernew){                       
                                String LeadId = leadRec.Id;
                                Decimal s;
                                if(leadRec.Pass_to_Sales_Date__c != null){
                                    Decimal hours = decimal.valueof((dtToday.getTime() - leadRec.Pass_to_Sales_Date__c.getTime())/(60*60));
                                    s = (hours/1000);
                                }                       
                                
                                String screeningDate = PLMStatic__c.getInstance('ScreeningDate').Value__c;
                                String lastOwnerDate;
                                String lastModifidDate;
                                if(leadRec.Ownership_Assigned_Date__c != null && leadRec.LastModifiedDate != null){                                                                   
                                    DateTime lastMDateTime = leadRec.LastModifiedDate;
                                    Date lastMDate = date.newinstance(lastMDateTime.year(), lastMDateTime.month(), lastMDateTime.day());
                                    lastModifidDate = String.valueOf(lastMDate);
                                    DateTime ownDateTime = leadRec.Ownership_Assigned_Date__c;
                                    Date lastOwnDate = date.newinstance(ownDateTime.year(), ownDateTime.month(), ownDateTime.day());
                                    lastOwnerDate = String.valueOf(lastOwnDate);
                                }
                                // Added Below If Condition by Manik for CR-00124323 to restrict the null pointer exception
                                
                                if(!String.isBlank(lastOwnerDate) && !String.isBlank(lastModifidDate)){
                                if(leadRec.Status =='1 Marketing Qualified' && leadRec.Screening_Results__c == 'Tele-Qualified' && Integer.valueof(s) <= Integer.valueOf(screeningDate) && String.valueOf(leadRec.OwnerId).startsWith('005') && leadRec.Lead_Owner_Profile__c != null && !leadRec.Lead_Owner_Profile__c.startsWith('Partner') && lastModifidDate.equals(lastOwnerDate) && leadRec.Owner__c != mapOldLead.get(leadRec.Id).Owner__c && leadRec.Execute_Ownership_Realignment__c != mapOldLead.get(leadRec.Id).Execute_Ownership_Realignment__c){
                                
                                
                                String str = '<font face="calibri">' + 'Dear '+ leadRec.Lead_Owner_Name__c+','+'<br></br>'+'This is to notify you that a Tele-Qualified lead has been assigned to you. Here is the link to the lead'+'<a href="'+System.Label.Partner_Lead_Url+'/'+LeadId+'"/>' +' '+leadRec.FirstName+''+ leadRec.LastName+'</a> ' ;    
                                
                                String emailAddr =leadRec.Lead_Owner_Email__c;                        
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                       
                                if(PLM_Constants.PLM_FLAG_SETTING.Is_Production__c){                          
                                   if (emailAddr != ''){
                                        String[] toAddresses = new String[] {emailAddr};
                                        mail.setToAddresses(toAddresses);
                                    }
                                    }
                                    else {
                                    
                                    //String toAddresses = 'sanjib.kumar.mahanta@accenture.com';
                                    //String[] toAddresses = new String[] {'sanjib.kumar.mahanta@accenture.com'};                       
                                                                               
                                    String staticEmailAddress = PLM_Constants.PLM_FLAG_SETTING.Static_Mailbox__c;
                                    String[] toAddresses = new String[] {staticEmailAddress};
                                    mail.setToAddresses(toAddresses);                            
                                    }
                                //String ccAddresses = 'sanjib.kumar.mahanta@accenture.com';
                                //String[] ccAddresses = new String[] {'sanjib.kumar.mahanta@accenture.com'}; 
                                mail.setOrgWideEmailAddressId(System.Label.L10N_EmailLebel_TeleQualified);
                                mail.setReplyTo(System.Label.L10N_ReplyTo_TeleQualified);
                                //mail.setCcAddresses(ccAddresses);   
                                mail.saveAsActivity = false;
                                mail.setSubject('A qualified lead has been assigned to you'); 
                                mail.setHtmlBody(str);
                                sendEmailToAll.add(mail);                       
                                   
                                }
                            }
                            }                   
                            if(sendEmailToAll != null && sendEmailToAll.size() > 0){                        
                                //Instantiating EmailResult Object
                                Messaging.SendEmailResult[] resultObj = new Messaging.SendEmailResult[]{};
                                resultObj = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> (sendEmailToAll), false);
                            }  
                                
                       }
                //}            
            }     
            /*-------------------------------------------------------------------------------------------------
            Method Name : emailNotificationForHybridLeads
            Description: This method sends an email notification when the Hybrid lead has been assigned.
            Created By: Sanjib Mahanta
            -------------------------------------------------------------------------------------------------*/
            
            public static void emailNotificationForHybridLeads() { 
            //System.debug(logginglevel.error,'***In emailNotificationForHybridLeads***' + lead.Record_Source__c);
            List<Lead> triggernew = (List<Lead>)Trigger.new;
            Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;        
            Map<Id,Lead> mapNewLead = (Map<Id,Lead>)Trigger.newMap;        
            List<Messaging.SingleEmailMessage> sendEmailToAll = new List<Messaging.SingleEmailMessage>();
            Set<Id> userId = new Set<Id>();
            Map<Id, User> userMap = new Map<Id, User>();
            List<User> listUser = new List<User>();
            Map<Id, Id> ldMap = new Map<Id, Id>();
                     if(trigger.isUpdate && trigger.isAfter && !hybridEmail){
                                 for(Lead userLead : triggernew){
                                     if(userLead.Record_Source__c != null && userLead.Record_Source__c =='Hybrid' && userLead.Previous_Record_Source__c !='VMW Eloqua' && userLead.Previous_Record_Source__c !='AW Partner' && mapOldLead.get(userLead.id).Owner__c != null && (userLead.Owner__c != mapOldLead.get(userLead.id).Owner__c)){
                                        userId.add(userLead.Previous_Owner_del__c);
                                        ldMap.put(userLead.id,userLead.Previous_Owner_del__c); 
                                     }  
                                 }
                                 if(userId != null){
                                     listUser = [Select id,Email,Name from User where id in : userId]; 
                                     if(!listUser.isEmpty()){
                                         for(User usr : listUser){
                                             userMap.put(usr.id,usr);
                                         }
                                         
                                     }
                                 }
                        
                            for(Lead leadRec : triggernew){                       
                                String LeadId = leadRec.Id;                      
                                String str = ''; 
                                String subjstr1 = '';
                                String subjstr2 = '';
                                String subjstr3 = '';
                                String URLL = URL.getSalesforceBaseUrl().toExternalForm();
                                String emailAddr = '';  
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                
                               // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 01***' + leadRec.Record_Source__c);
                               // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 02***' + leadRec.OwnerId);
                               // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 03***' + leadRec.Lead_Owner_Profile__c);
                               // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 04***' + leadRec.Owner__c);
                               // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 05***' + mapOldLead.get(leadRec.Id).Owner__c);
                              //  System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 08***' + leadRec.Previous_Record_Source__c);
                               // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 06***' + leadRec.Execute_Ownership_Realignment__c);
                              
                               // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads 08***' + leadRec.Previous_Record_Source__c);
                                if(leadRec.Record_Source__c =='Hybrid' && String.valueOf(leadRec.OwnerId).startsWith('005') && leadRec.Lead_Owner_Profile__c != null  && leadRec.Execute_Ownership_Realignment__c != mapOldLead.get(leadRec.Id).Execute_Ownership_Realignment__c && leadRec.Execute_Ownership_Realignment__c == false){                            
                                // System.debug(logginglevel.error,'***In emailNotificationForHybridLeads Filter pass***');
                               if(leadRec.Previous_Record_Source__c == 'VMW Eloqua' && leadRec.AW_Lead_Source_Category__c  != 'Partner'){
                                //  System.debug(logginglevel.error,'***In emailNotificationForHybridLeads Filter pass VMW Eloqua***');
                                    if(leadRec.AE_PSR_Name__c != null)
                                    str = '<font face="calibri">'+'Dear '+leadRec.AE_PSR_Name__c+'<br></br>'+'You are receiving this email because of a new Sales Lead in your territory. Please collaborate with your mapped Core Rep who is the owner of the Lead.'+'<br></br>'+'Click'+'<a href='+URLL+'/'+leadRec.id+'>here</a>'+' to access this Lead from '+leadRec.Company;    
                                    subjstr1 = 'A Lead from '+leadRec.Company+' has been identified for you' ; 
                                    mail.setSubject(subjstr1); 
                                } else if(leadRec.AW_Lead_Source_Category__c  != 'Partner'){
                                 //   System.debug('Inside AW Eloqua');
                                    if(!userMap.isEmpty() && !ldMap.isEmpty())
                                    str = '<font face="calibri">'+'Dear '+userMap.get(ldMap.get(leadRec.id)).Name+'<br></br>'+'You are receiving this email because your Lead has been assigned to a Core Rep in your territory. '+'<br></br>'+' Please collaborate and click '+'<a href='+URLL+'/'+leadRec.id+'>here</a>'+' to access this Lead from '+leadRec.Company;    
                                    subjstr2 = 'A Lead from '+leadRec.Company+' has been assigned to a Core Rep' ;
                                    mail.setSubject(subjstr2);
                                }else {
                                    
                                    str = '<font face="calibri">'+'You are receiving this email because your Lead has been assigned to a Core Rep in your territory. '+'<br></br>'+' Please collaborate and click '+'<a href='+URLL+'/'+leadRec.id+'>here</a>'+' to access this Lead from '+leadRec.Company;    
                                    subjstr3 = 'A Lead from '+leadRec.Company+' has been assigned to a Core Rep' ;
                                    mail.setSubject(subjstr3);
                                }
                               // System.debug(logginglevel.error,'Email Body >>>'+str);
                                if(leadRec.AW_Lead_Source_Category__c  == 'Partner'){
                                    emailAddr = System.Label.AW_Partner_Operation_Email_Group;
                                }else if(leadRec.Previous_Record_Source__c == 'VMW Eloqua' && leadRec.AW_Rep_Email_VM__c != null && leadRec.AW_Lead_Source_Category__c != 'Partner'){
                                    emailAddr =leadRec.AW_Rep_Email_VM__c; 
                                }else{
                                   // System.debug(logginglevel.error,'UserMap>>>>>'+userMap+'ldMap>>>>'+ldMap);
                                    if(!userMap.isEmpty() && !ldMap.isEmpty())
                                    emailAddr =userMap.get(ldMap.get(leadRec.id)).Email;                        
                                }               
                                
                              //  System.debug(logginglevel.error,'***In emailNotificationForHybridLeads Filter pass emailAddr***'+emailAddr);
                                if(PLM_Constants.PLM_FLAG_SETTING.Is_Production__c){                          
                                   if (emailAddr != ''){
                                        String[] toAddresses = new String[] {emailAddr};
                                        mail.setToAddresses(toAddresses);
                                        System.debug(logginglevel.error,'***In emailNotificationForHybridLeads Filter pass toAddresses***'+toAddresses);
                                    }
                                    }
                                    else {
                                    System.debug(logginglevel.error,'***In emailNotificationForHybridLeads Filter pass toAddresses else***');
                                    
                                    String staticEmailAddress = PLM_Constants.PLM_FLAG_SETTING.Static_Mailbox__c;
                                    String[] toAddresses = new String[] {staticEmailAddress};
                                    mail.setToAddresses(toAddresses);                            
                                    }
                                 
                                mail.setOrgWideEmailAddressId(System.Label.L10N_EmailLebel_TeleQualified);
                                mail.setReplyTo(System.Label.L10N_ReplyTo_TeleQualified);
                                mail.saveAsActivity = false;
                                mail.setHtmlBody(str);
                                sendEmailToAll.add(mail);                       
                                 System.debug(logginglevel.error,'***In emailNotificationForHybridLeads Filter pass toAddresses sendEmailToAll***' +sendEmailToAll);
                                   
                                }
                            
                            }                   
                            if(sendEmailToAll != null && sendEmailToAll.size() > 0){  
                                System.debug('!!!!!!!!!'+sendEmailToAll);
                                //Instantiating EmailResult Object
                                Messaging.SendEmailResult[] resultObj = new Messaging.SendEmailResult[]{};
                                resultObj = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> (sendEmailToAll), false);
                                hybridEmail = true;
                                system.debug('resultObj>>>'+resultObj);
                            }  
                                
                       }
                //}            
            }     
            
            
               //***************************************************************************************************************
            // Method Name:calculateNumberofleadswithOverdueSLA 
            // Description: This method calculate No of overdue SLA  on Partner account.(CR-00037548)
            // Created By: Bhavesh Mistry 
            //*************************************************************************************************************** 
            
            public static void calculateNumberofleadswithOverdueSLA()  {
                       
                        if(!recursive.isfirstrunSLAOverdue){ 
                        recursive.isfirstrunSLAOverdue = true;
                        List<Lead> triggernew = (List<Lead>)Trigger.new;
                        List<Lead> triggerold = (List<Lead>)Trigger.old;
                        
                        Set<Id> setPartnerAccountIds = new Set<Id>();             
                        Set<Id> setAccountIds = new Set<Id>(); 
                        
                        Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
                            for(Lead olead :triggernew ) {   
          
                                    if(olead.Partner_Account__c != null && mapOldLead.get(olead.Id).Partner_Account__c != null && oLead.Partner_Account__c != mapOldLead.get(olead.Id).Partner_Account__c )
                                    {
                                        setAccountIds.add(olead.Partner_Account__c);
                                        setAccountIds.add(mapOldLead.get(olead.Id).Partner_Account__c);
                                    }
                                    if(olead.Partner_Account__c == null &&  mapOldLead.get(olead.Id).Partner_Account__c != null)
                                    {
                                        setAccountIds.add(mapOldLead.get(olead.Id).Partner_Account__c);
                                    }
                                    if(olead.Partner_Account__c != null && mapOldLead.get(olead.Id).Partner_Account__c == null)
                                    {
                                        setAccountIds.add(olead.Partner_Account__c);
                                    }
                                    if(olead.Partner_Account__c != null && olead.SLA_Breached__c != mapOldLead.get(olead.Id).SLA_Breached__c && oLead.Partner_Account__c == mapOldLead.get(olead.Id).Partner_Account__c)
                                    {
                                        setAccountIds.add(olead.Partner_Account__c);
                                    }
                            }
                          if(setAccountIds != null && setAccountIds.size() >0) {  
                         /* get the Total number of Leads on partner Accounts. */
                        AggregateResult[] groupedResults  =[Select count(id) NoleadswithoverdueSLA,Partner_Account__c  from Lead  where Partner_Account__c  IN : setAccountIds And (SLA_Breached__c =true ) group by Partner_Account__c]; 
                        
                        Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select Id,Number_of_leads_with_overdue_SLA__c from Account where Id IN : setAccountIds]);
                       //   Check whether Number_of_leads_with_overdue_SLA__c field value is same as the total number of active leads in that Account.If the values are same 
                        //    then do nothing else update the field with the total number of Number_of_leads_with_overdue_SLA__c in that Account. 
                        if(groupedResults.size()>0){
                                for (AggregateResult acct : groupedResults ){             
                                    acctsToUpdate.get((id)acct.get('Partner_Account__c')).Number_of_leads_with_overdue_SLA__c = (Decimal)acct.get('NoleadswithoverdueSLA'); 
                                    setPartnerAccountIds.add((id)acct.get('Partner_Account__c'));
                                }
                           }      
                    
                                for(Account oAccount: acctsToUpdate.values())
                                     {
                                         if(!setPartnerAccountIds.contains(oAccount.Id)){
                                         
                                              oAccount.Number_of_leads_with_overdue_SLA__c = 0;
                                            }
                                     }
                    update acctsToUpdate.values();
                 }               
                      
           }
         }
            //***********************************************************************************************************************
            // Method Name : updateTAExecutionStatus
            // Description : This method is used to prevent the updation of TA execution status before completion of DaaS
            // Created By  : Varsha Chougule
            //***********************************************************************************************************************
            public static void updateTAExecutionStatus()
            {
                List<Lead> triggerNew = (List<Lead>)Trigger.new;
                Map<Id,Lead> oldLeadMap = (Map<Id,Lead>)Trigger.OldMap;
                if(trigger.isBefore && trigger.isUpdate)
                {
                    for(Lead leadObj : triggerNew)
                    {
                        if((oldLeadMap.get(leadObj.id)).TA_Execution_Status__c =='Waiting for DaaS call' && leadObj.TA_Execution_Status__c!='Waiting for DaaS call' && leadObj.DNB_Call_Status__c !='Completed' && leadObj.DNB_Call_Status__c!='Error')
                        {
                            leadObj.TA_Execution_Status__c ='Waiting for DaaS call';
                        }
                    }
                }
            }
            
            //***********************************************************************************************************************
            // Method Name: previousFieldUpdate
            // Description: To store territory related field history during lead update (CR-00106346)
            // Created By: Deepthi Harikrishnan
            // CR-00122081: Updated the method to capture previous status as well as previous value of product interest fields.
            // Updated By: Sanjib
            //***********************************************************************************************************************
            public static void previousTerritoryFieldUpdate() {

               List<Lead> triggernew = (List<Lead>)Trigger.new;

               Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
               
               //Before each lead gets updated, store the territory values and match reasons into its corresponding previous territory fields
               if(trigger.isBefore && trigger.isUpdate ) {
                
                    for(Lead leadObj : triggernew) {   
                        
                        Lead oldLeadRecord=mapOldLead.get(leadObj.Id);
                          
                        if(leadObj.Primary_Field_Sales_Territory__c != oldLeadRecord.Primary_Field_Sales_Territory__c) {
                          
                            leadObj.Previous_Primary_Field_Sales_Territory__c=oldLeadRecord.Primary_Field_Sales_Territory__c;
                        }
                        if(leadObj.Global_Overlay_Territory__c != oldLeadRecord.Global_Overlay_Territory__c) {
                                         
                            leadObj.Previous_Global_Overlay_Territory__c= oldLeadRecord.Global_Overlay_Territory__c;
                        }
                        if(leadObj.PFST_Match_Reason__c != oldLeadRecord.PFST_Match_Reason__c) {
                          
                            leadObj.Previous_PFST_Match_Reason__c=oldLeadRecord.PFST_Match_Reason__c;
                        }
                        if(leadObj.Global_Overlay_Territory_Match_Reason__c != oldLeadRecord.Global_Overlay_Territory_Match_Reason__c) {
                          
                            leadObj.Previous_Global_Overlay_Match_Reason__c=oldLeadRecord.Global_Overlay_Territory_Match_Reason__c;
                        }
                        // Start : Added below code for CR-00122081 [Renaissance Phase-2]
                        if(leadObj.Status != oldLeadRecord.Status){
                          
                            leadObj.Previous_Lead_Status__c=oldLeadRecord.Status;
                        }
                        if(leadObj.Products__c != oldLeadRecord.Products__c){
                          
                            leadObj.Previous__c=oldLeadRecord.Products__c;
                        }
                        if(leadObj.Primary_Product_Group_Interest__c != oldLeadRecord.Primary_Product_Group_Interest__c){
                          
                            leadObj.Primary_Product_Group_Interest_Before__c=oldLeadRecord.Primary_Product_Group_Interest__c;
                        }
                        if(leadObj.Product_Group_Interest__c != oldLeadRecord.Product_Group_Interest__c){
                          
                            leadObj.Secondary_Product_Group_Interest_Before__c=oldLeadRecord.Product_Group_Interest__c;                 
                        }
                        if(leadObj.Owner__c != oldLeadRecord.Owner__c && leadObj.Is_Specialist_ISR_owner__c == true){
                          
                            leadObj.Is_Specialist_ISR_owner__c = false;
                            leadObj.UpdateStatus__c = false;    
                        }
                       // if(leadObj.Record_Source__c != oldLeadRecord.Record_Source__c){
                          
                         //   leadObj.Previous_Record_Source__c=leadObj.Record_Source__c;                 
                        //}
                        
                        // End: CR-00122081
                    }
                }
            }
            //************************************************************************************************************************************
            //CR Number: CR-00122081 
            //Method Name: updateExecuteOwnershipRealignment
            // Description: To update Execute Ownership Realignment flag if the criteria on Lead Reassignment Rule matches the Lead fields records.
            // Created By: Sanjib Mahanta
            //************************************************************************************************************************************
            public static void updateExecuteOwnershipRealignment() {        
                
                if(trigger.isBefore && trigger.isUpdate){
                    List<Lead> triggernew = (List<Lead>)Trigger.new;
                    Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;       
                    List<Lead_Reassignment_Rule__c> listLeadReassignment = new List<Lead_Reassignment_Rule__c>();
                    Boolean isCampaignResponse = false;
                    String  leadGeo = '';            
                    for(Lead leadObj : triggernew){                
                        Lead oldLeadRecord = mapOldLead.get(leadObj.Id);
                        if(leadObj.Last_Campaign_Response__c != oldLeadRecord.Last_Campaign_Response__c) {
                           isCampaignResponse = true;
                            leadGeo = leadobj.GEO__c;               
                        }
                    }
                    if(isCampaignResponse && leadGeo != null){ 
                        
                        Boolean isProductInterestAfterMatch = false;
                        Boolean isProductInterestBeforeMatch = false;
                        Boolean isSecondaryProductInterestBeforeMatch = false;
                        Boolean isSecondaryProductInterestAfterMatch = false;
                        Integer lenISRUser = 0;
                        String strISR = '';                
                        Boolean isSpecialistISR = false;
                        Boolean isNumberOfDays = false;
                        
                        listLeadReassignment = [select Name,of_days_rejected__c,Closed_Reason__c,Distribution_Date__c,GEO__c,Lead_Owner__c,Number_Of_Days__c,New_Campaign_Response__c,Previous_Lead_Status__c,Primary_Product_Group_Interest_After__c,Primary_Product_Group_Interest_Before__c,Product_Interest_After__c,Product_Interest_Before__c,Response_Date__c,Screening_Result__c,Secondary_Product_Group_Interest_After__c,Secondary_Product_Group_Interest_Before__c,Last_Lead_Source__c,Status__c,User_is__c from Lead_Reassignment_Rule__c where GEO__c =: leadGeo and Active__c = true];
                        System.debug('listLeadReassignment>>>'+listLeadReassignment);
                        if(!listLeadReassignment.isEmpty() && listLeadReassignment.size()>0){
                            for(Lead leadObj : triggernew){
                                for(Lead_Reassignment_Rule__c lrrObj : listLeadReassignment){                               
                                        if(leadObj.Products__c != null && lrrObj.Product_Interest_After__c != null){    
                                         isProductInterestAfterMatch = matchMultiSelectFields(leadObj.Products__c,lrrObj.Product_Interest_After__c);
                                         }
                                         if(leadObj.Previous__c != null && lrrObj.Product_Interest_Before__c != null){                                 
                                         isProductInterestBeforeMatch = matchMultiSelectFields(leadObj.Previous__c,lrrObj.Product_Interest_Before__c);
                                         }
                                         if(leadObj.Product_Group_Interest__c != null && lrrObj.Secondary_Product_Group_Interest_After__c != null){ 
                                         isSecondaryProductInterestAfterMatch = matchMultiSelectFields(leadObj.Product_Group_Interest__c,lrrObj.Secondary_Product_Group_Interest_After__c);                              
                                         }
                                         if(leadObj.Secondary_Product_Group_Interest_Before__c != null && lrrObj.Secondary_Product_Group_Interest_Before__c != null){
                                         isSecondaryProductInterestBeforeMatch = matchMultiSelectFields(leadObj.Secondary_Product_Group_Interest_Before__c,lrrObj.Secondary_Product_Group_Interest_Before__c);                               
                                         }                                 
                                  
                                     
                                    if(leadObj.Products__c == null || lrrObj.Product_Interest_After__c == null)
                                            isProductInterestAfterMatch = true;
                                    if(leadObj.Previous__c == null || lrrObj.Product_Interest_Before__c == null)        
                                            isProductInterestBeforeMatch = true;
                                    if(leadObj.Product_Group_Interest__c == null || lrrObj.Secondary_Product_Group_Interest_After__c == null)           
                                            isSecondaryProductInterestBeforeMatch = true;
                                    if(leadObj.Secondary_Product_Group_Interest_Before__c == null || lrrObj.Secondary_Product_Group_Interest_Before__c == null)         isSecondaryProductInterestAfterMatch = true;    
                                    
                                    
                                    
                                    if(leadObj.ISR_User_Formula__c != null && leadObj.ISR_User_Formula__c != ''){
                                    String strISRUser = leadObj.ISR_User_Formula__c;
                                        if(strISRUser != null && strISRUser != ''){
                                            lenISRUser = strISRUser.length();
                                        }if(strISRUser != null && strISRUser != '' && lenISRUser > 32){
                                            strISR = strISRUser.subString(32,lenISRUser-13);
                                        }       
                                    }
                                    
                                    Boolean isOwnerMatch = false;                         
                                    if(lrrObj.Lead_Owner__c != null && lrrObj.Lead_Owner__c != '' && (leadObj.Lead_Owner_Name__c == strISR || leadObj.Is_Specialist_ISR_owner__c == true)){
                                        for(LeadReassignmentTriggeringUtility__c lrt:LeadReassignmentTriggeringUtility__c.getall().values()){
                                            if(lrt.Value__c == lrrObj.Lead_Owner__c){
                                                //System.debug('isOwnerMatch');
                                                isOwnerMatch = true;
                                            }   
                                        }
                                        
                                    }
                                                          
                                    Boolean isMatch = true;
                                    
                                    if(lrrObj.of_days_rejected__c != null){
                                        if(leadObj.of_Days_Rejected__c != lrrObj.of_days_rejected__c){                                
                                            isMatch = false;
                                            }
                                    }                             
                                    
                                    if(lrrObj.Closed_Reason__c != null && lrrObj.Closed_Reason__c != ''){
                                        if(leadObj.Closed_Reason__c != lrrObj.Closed_Reason__c )
                                            isMatch = false;
                                            
                                    }       
                                    
                                    if(lrrObj.Distribution_Date__c != null){ 
                                        if(leadObj.Distribution_Date__c != lrrObj.Distribution_Date__c)
                                            isMatch = false;                                 
                                            
                                    } 
                                    
                                    if(lrrObj.Last_Lead_Source__c != null && lrrObj.Last_Lead_Source__c != '' && leadObj.LeadSource != null && leadObj.LeadSource != ''){ 
                                        if(!lrrObj.Last_Lead_Source__c.contains(leadObj.LeadSource))
                                            isMatch = false;                                    
                                    }
                                    
                                    if(lrrObj.Number_Of_Days__c != null){  
                                        if(leadObj.Number_Of_Days__c <= lrrObj.Number_Of_Days__c){ 
                                            isMatch = false;
                                            isNumberOfDays = true;                                    
                                            }
                                    } 
                                    
                                    if(lrrObj.Previous_Lead_Status__c != null && lrrObj.Previous_Lead_Status__c != '' && leadObj.Previous_Lead_Status__c != null && leadObj.Previous_Lead_Status__c != ''){
                                        if(!lrrObj.Previous_Lead_Status__c.contains(leadObj.Previous_Lead_Status__c)){ 
                                            isMatch = false;                                    
                                        }   
                                    } 
                                    
                                    if(lrrObj.Response_Date__c != null && leadObj.Last_Response_Date__c != null){
                                        if(leadObj.Last_Response_Date__c != lrrObj.Response_Date__c )
                                            isMatch = false;
                                            
                                    }
                                                
                                    if(lrrObj.Screening_Result__c != null && lrrObj.Screening_Result__c != '' && leadObj.Screening_Results__c != null && leadObj.Screening_Results__c != ''){
                                        if(!lrrObj.Screening_Result__c.contains(leadObj.Screening_Results__c))
                                            isMatch = false;
                                              
                                    }
                                       
                                    if(lrrObj.Status__c != null && lrrObj.Status__c != '' && leadObj.status != null && leadObj.status != ''){
                                        if(!lrrObj.Status__c.contains(leadObj.status))                                    
                                            isMatch = false;                         
                                        
                                    }                          
                                    System.debug('>>'+isMatch+'>>'+isProductInterestAfterMatch+'>>'+isProductInterestBeforeMatch+'>>'+isSecondaryProductInterestBeforeMatch+'>>'+isSecondaryProductInterestAfterMatch+'>>'+isOwnerMatch);
                                    if(isMatch && isProductInterestAfterMatch && isProductInterestBeforeMatch && isSecondaryProductInterestBeforeMatch && isSecondaryProductInterestAfterMatch && isOwnerMatch){                            
                                        leadObj.Execute_Ownership_Realignment__c = true;                                
                                        leadObj.Lead_Reassignment_Rule_ID__c = lrrObj.Name;
                                        if(isNumberOfDays){
                                            isNumberOfDays = false;
                                            leadObj.UpdateStatus__c = true;
                                        }
                                    }
                                }
                        }   }
                    }   
                }   
            }
            //************************************************************************************************************************************
            // CR Number: CR-00122081 
            // Method Name: updateExecuteOwnershipRealignment
            // Description: Methods to compare multiselect fields.
            // Created By: Sanjib Mahanta
            //************************************************************************************************************************************
            public static Boolean matchMultiSelectFields(String leadValue, String lrrValue) {       
                List<String> sortedRulevalue=new List<String>();
                List<String> sortedLeadvalue=new List<String>();
                Boolean isMatch = false;
                if((leadValue!= null && leadValue.contains(';')) || (lrrValue != null && lrrValue.contains(';') )){
                    sortedLeadvalue = leadValue.split(';');
                    sortedLeadvalue.sort();
                    sortedRulevalue = lrrValue.split(';');                      
                    sortedRulevalue.sort();             
                }else if(leadValue != null || lrrValue != null) {
                    sortedLeadvalue.add(leadValue);
                    sortedRulevalue.add(lrrValue);          
                }
                
                if(sortedLeadvalue.size() <= sortedRulevalue.size()){
                    for(Integer i=0;i<sortedRulevalue.size();i++){
                    
                        for(Integer j=0;j<sortedLeadvalue.size();j++)
                        {                                           
                            if(sortedLeadvalue[j]==sortedRulevalue[i]){                             
                                isMatch = true;
                            }                               
                        }
                    }
                }
                return isMatch;
            }
           
           //************************************************************************************************************************************
            // CR Number: 
            // Method Name: checkPicklistval
            // Description: Methods to compare multiselect fields.
            // Created By: Yoganand
            //************************************************************************************************************************************
          
            public static Boolean checkPicklistval(String valtoCompare, String assignVal) {
                 Boolean valnotpresent = false;
                 List<String> pickListvalues = new List<String>();
                   if(assignVal!= null && assignVal.contains(';')){
                      pickListvalues = assignVal.split(';');
                           if(valtoCompare != null && valtoCompare != ''){
                                for(string PickVal : pickListvalues){
                                     if(!valtoCompare.contains(PickVal))
                                        valnotpresent = true;
                                }
                           }
                   }
                   else if(assignVal!= null && !(assignVal.contains(';')) && valtoCompare!= null){
                           if(!valtoCompare.contains(assignVal)){
                              valnotpresent = true;   
                           }                  
                   }
                return valnotpresent;
            }    
          // Method to remove the duplicate values from  a multi-picklist (ProductLeadFilter)
            Public static String removeDuplicateValues(String prodLeadFilters) {
                Set<String> productLeadFilterSet = new Set<String>();
                
                if(prodLeadFilters != null) {
                    for(String prd : prodLeadFilters.split(';')) {
                        if(prd.trim() != '' && prd.trim() != 'null') {
                            productLeadFilterSet.add(prd.trim());
                        }
                    }
                }
                String uniqueProductLeadFilter = '';
                if(productLeadFilterSet.size()>0) {
                    for(String prd : productLeadFilterSet) {
                        uniqueProductLeadFilter += prd + ';';
                    }
                }
                
                return uniqueProductLeadFilter;
            }
            
            //***************************************************************************************************************
            // Method Name:updateExecEngagement 
            // Description: This method will update Executive Engagement Date on lead. 
            // Date will be updated whenever lead is inserted or updated and Executive_Engagement__c is true
            // Created By: Vikram Tota
            //***************************************************************************************************************
            public static void updateExecEngagementDate()
            {
                if(Trigger.isBefore && Trigger.IsUpdate)
                {
                    Map<Id, Lead> leadMap = new Map<Id, Lead>();
                    Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
                    List<Lead> triggernew = (List<Lead>)Trigger.new;
                    
                    for(Lead ld : triggernew)
                    {
                        if(ld.Executive_Engagement__c == true 
                            && (mapOldLead.get(ld.Id).Executive_Engagement__c != ld.Executive_Engagement__c))
                        {
                            leadMap.put(ld.Id, ld); 
                        }
                    }
                    
                    if(!leadMap.isEmpty())
                    {
                        //querying lead and its associated latest campaign member sorted by first responded date.
                        //querying lead again for retrieving its associated campaign member record.
                        List<Lead> leadList = [SELECT id,
                                                        (SELECT Id, HasResponded, FirstRespondedDate, Response_Date__c 
                                                         FROM CampaignMembers 
                                                         WHERE HasResponded=true and Response_Date__c != null order by Response_Date__c desc limit 1)
                                               FROM Lead 
                                               WHERE id in :leadMap.keySet()];
                        
                        for(Lead leadRecord : leadList) 
                        {
                            if(!leadRecord.CampaignMembers.isEmpty())
                            {
                                Lead ld = leadMap.get(leadRecord.id);
                                ld.Executive_Engagement_Date__c = leadRecord.CampaignMembers[0].Response_Date__c; 
                            }
                        }                                      
                    }
                }
            } 
            
            //Added below method as part of Lead_DealReg Conversion project CR-00134135 
        public static void lockLeadRecord(){
           Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
           List<Lead> triggernew = (List<Lead>)Trigger.new;
           Lead_Deal_Conversion_Project_Switch__c cs  = Lead_Deal_Conversion_Project_Switch__c.getInstance();
           if(trigger.isupdate && trigger.isbefore && cs.Status__c == TRUE && !string.valueof(userinfo.getProfileId()).contains('00e80000001Bxcc') && !string.valueof(userinfo.getuserId()).contains('00580000001ueGj')){
                for(Lead lea: triggernew){
                //Modified as part of Lead Deal Phase 2 Project CR-00133083
                  if(lea.isconverted == FALSE){
                       if(oldMap.get(lea.id).is_locked__c == TRUE && lea.Is_Locked__c == TRUE){
                         lea.adderror(System.Label.Error_Message_for_Locked_Lead);
                       }
                  } 

                }
            }   
        }
        
         //Added below method as part of Lead_DealReg Conversion project CR-00134135
         Public static void revertOwnerhsipTAFlags(){
            List<Lead> triggernew = (List<Lead>)Trigger.new;
            Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.oldMap;
            Lead_Deal_Conversion_Project_Switch__c cs  = Lead_Deal_Conversion_Project_Switch__c.getInstance();
                 if(cs.Status__c == TRUE){
                     for(Lead leadRec : triggernew){
                          if(oldMap.get(leadRec.id).TA_Execution_Status__c != 'Send For TA' && leadRec.is_locked__c && leadRec.TA_Execution_Status__c == 'Send for TA'){
                             leadRec.Execute_TA_Engine__c = FALSE;
                             leadRec.TA_Execution_Status__c = oldMap.get(leadRec.id).TA_Execution_Status__c;
                              }
                              
                              if(oldMap.get(leadRec.id).Execute_Ownership_Realignment__c == FALSE && leadRec.is_locked__c && leadRec.Execute_Ownership_Realignment__c){
                                leadRec.Execute_Ownership_Realignment__c =  FALSE;
                              }
                              
                              if(oldMap.get(leadRec.id).is_locked__c == FALSE && leadRec.is_locked__c == TRUE && leadRec.Execute_Ownership_Realignment__c){
                                 leadRec.Execute_Ownership_Realignment__c = FALSE;
                              }
                              
                              if(oldMap.get(leadRec.id).is_locked__c == FALSE && leadRec.is_locked__c == TRUE && leadRec.TA_Execution_Status__c == 'Send for TA'){
                                  leadRec.Execute_TA_Engine__c = FALSE;
                              }
                          }
                      }
            }    
        
             //***************************************************************************************************************
            // Method Name:updateExistingOpportunityFlag 
            // Description: This method will update Existing Opportunity flag if an Open Opportunity is found (opportunity not in few stages mentioned in the query). 
            // Field will be updated whenever lead is inserted or updated based on criteria below
            // 1) UUID + Country 2) Duns + Country 3) Email Domain + Country
            // Created By: Manik Chaudhary
            //***************************************************************************************************************
            
            public static void updateExistingOpportunityFlag()
            {    
            if(Limits.getQueries()<Limits.getLimitQueries())
            {
                if((Trigger.isBefore && Trigger.IsInsert) || (Trigger.isBefore && Trigger.IsUpdate))
                {
                String OpportunityQuery ='Select Id,AccountId,Account.Name,Account.Website,Account.Country__c,Account.UUID__c,Account.DUNS__c,StageName from Opportunity where (StageName!=\'06 - Closed Won\' And StageName!=\'07 - Closed Lost\' And StageName!=\'07c - Closed Won\' And StageName!=\'08 - Closed Lost\') And Account.Account_Status__c =\'Active\' And Account.Geo__c=\'AMER\' And Account.Country__c In : ListLeadCountries';
                    String InitQuery=OpportunityQuery;
                    
                    Map<Id, Lead> leadMap = new Map<Id, Lead>();
                    Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
                    List<Lead> triggernew = (List<Lead>)Trigger.new;
                    Map<String,Opportunity> mpOptyUUID= new Map<String,Opportunity>();
                    Map<String,Opportunity> mpOptyDUNS= new Map<String,Opportunity>();
                     Map<String,Opportunity> mpOptySiteCountry= new Map<String,Opportunity>();
                     Map<String,Opportunity> mapAccountName = new Map<String,Opportunity>();
                     
                    Set<String> SetLeadUUID = new Set<String>();
                    List<String>LstLeadUUID= new List<String>();
                    Set<String> SetLeadDUNS = new Set<String>();
                    List<String>LstLeadDUNS= new List<String>();
                    Set<String>SetLeadEmailCountry = new Set<String>();
                    List<String>LstLeadEmailCountry = new List<String>();

                    set<String> SetleadFULLwebSite = new set<String>();
                    List<String> ListleadFULLwebSite = new List<String>();
                    Set<String> SetLeadCountries = new Set<String>();
                    List<String> ListLeadCountries = new List<String>();
                    
                    Map<String,Integer> mapUUIDint = new Map<String,Integer>();
                    Map<String,Integer> mapDUNSint = new Map<String,Integer>();
                    Map<String,Integer> mapDOMAINint = new Map<String,Integer>();
                       
                    String Q2;
                    
                    for(Lead ld : triggernew)
                    {
                        if((Trigger.isInsert) ||(Trigger.isUpdate && (mapOldLead.get(ld.id).Status!= ld.Status && (ld.Status=='0 New Response' || ld.Status=='0 New')) ||(mapOldLead.get(ld.id).Campaign__c!=ld.Campaign__c)))
                        {
                            if(ld.Geo__c=='AMER')
                            {   
                                if(ld.UUID__c!=null)
                                {
                                    SetLeadUUID.add(ld.UUID__c);
                                }
                                if(ld.DUNS__c!=null)
                                {
                                    SetLeadDUNS.add(ld.DUNS__c);
                                }
                                if(ld.email!=null && ld.Country__c!=null)
                                {
                                     if(ld.Email.Contains('@')){
                                        list<String> lstSplit = ld.Email.Split('@');
                                        if(!lstSplit.isEmpty() && lstSplit.Size() == 2 ){
                                            if(lstSplit[1] != null && lstSplit[1].trim() != ''){
                                                String EmailDomain = 'WWW.'+lstSplit[1].trim().ToUpperCase();
                                                setleadFULLwebSite.add(EmailDomain);
                                                if(lstSplit[1].trim().Contains('.')){
                                                    list<String> lstSplitDomains = lstSplit[1].trim().split('\\.'); 
                                                    if(lstSplitDomains != null && !lstSplitDomains.isEmpty()){
                                                        for(String str : lstSplitDomains){
                                                            if(str.trim() != '' && str != 'IN' && str != 'COM' && str != 'CO' && str != 'ORG'){
                                                                setleadFULLwebSite.add('%'+str.trim().ToUppercase()+'%');   
                                                            }
                                                        }   
                                                    }   
                                                }
                                            }
                                        }   
                                    }
                                       
                                   // System.debug('Website Lead'+ setleadFULLwebSite );
                                   // System.debug('Country Lead' + SetLeadCountries);
                                    
                                }
                                 SetLeadCountries.add(ld.Country__c);
                            }   
                        }            
                    }
                    if(!SetLeadCountries.isempty())
                    {
                        ListLeadCountries.addall(SetLeadCountries);
                    }
                    if(!SetLeadUUID.isempty())
                    {
                        LstLeadUUID.addall(SetLeadUUID);
                        Q2=' And ((Account.UUID__C in : LstLeadUUID )';
                        if(!SetLeadDUNS.isempty())
                        {
                            LstLeadDUNS.addall(SetLeadDUNS);
                            Q2 = Q2 + ' OR (Account.DUNS__c in : LstLeadDUNS )';
                        }
                        if(!setleadFULLwebSite.isempty() && !SetLeadCountries.isempty())
                        {
                            ListleadFULLwebSite.addall(setleadFULLwebSite);
                            
                            Q2=Q2+ ' OR ((Account.Website Like : ListleadFULLwebSite ))';
                        }
                        Q2 =Q2 +')';
                        
                    }
                    else if(!SetLeadDUNS.isempty())
                    {
                            LstLeadDUNS.addall(SetLeadDUNS);
                            Q2 = ' And ((Account.DUNS__c in : LstLeadDUNS )';
                        
                        if(!setleadFULLwebSite.isempty() && !SetLeadCountries.isempty())
                        {
                            ListleadFULLwebSite.addall(setleadFULLwebSite);
                                
                            Q2=Q2 + ' OR ((Account.Website Like : ListleadFULLwebSite) )';
                        }
                            Q2 = Q2 + ')' ;
                    }
                    else if(!setleadFULLwebSite.isempty() && !SetLeadCountries.isempty())
                    {
                                      
                        Set<id> sid= new Set<Id>();
                        ListleadFULLwebSite.addall(setleadFULLwebSite);
                        for(Account acc : [Select Id,Website,Country__c from Account where Website Like : ListleadFULLwebSite and Country__c in: ListLeadCountries])
                        {
                            sid.add(acc.id);
                        }
                        if(!sid.isempty()){
                        Q2=' And (AccountId in : sid';
                        Q2 = Q2 + ')' ;
                        }
                    }               
                    
                    if(Q2!=null)
                    {
                        OpportunityQuery= OpportunityQuery + Q2;
                    }
                   // System.debug('Query' + OpportunityQuery);
                    
                    List<Opportunity> OptyLst = new List<Opportunity>();
                    
                    if(!InitQuery.equals(OpportunityQuery))
                    {   
                        OptyLst=Database.query(OpportunityQuery);
                       // System.debug('ListofOpportunity'+ OptyLst);
                    }
                   
                    
                    if(!OptyLst.isempty())
                    {
                       // System.debug('Found a value');
                        
                        for(Opportunity op : OptyLst)
                        {
                            
                            if(op.Account.UUID__c!=null && SetLeadUUID.contains(op.Account.UUID__c))
                            {    
                               // System.debug('OpportunityId-UUID'+ op.id);              
                                if(!mpOptyUUID.containskey(op.Account.UUID__c))
                                {
                                    mpOptyUUID.put(op.Account.UUID__c,op);
                                    mapUUIDint.put(op.Account.UUID__c,0);
                                }
                                else
                                {
                                    
                                   // System.debug('Inside else UUID');
                                    if(!mpOptyUUID.get(op.Account.UUID__c).Account.Name.equalsignorecase(op.Account.Name))
                                    {
                                        
                                        mapUUIDint.put(op.Account.UUID__c,1);
                                       // System.debug('Inside If UUID 1');
                                    }
                                }
                            }
                            
                            if(op.Account.DUNS__C!=null && SetLeadDUNS.contains(op.Account.DUNS__C))
                            {
                              //  System.debug('OpportunityId-Duns'+ op.id);
                                if(!mpOptyDUNS.containskey(op.Account.Duns__c))
                                {
                                    mpOptyDUNS.put(op.Account.Duns__c,op);
                                    mapDUNSint.put(op.Account.Duns__c,0);
                                }
                                else
                                {
                                   // System.debug('Inside else Duns');

                                    if(!mpOptyDUNS.get(op.Account.Duns__c).Account.Name.equalsignorecase(op.Account.Name))
                                    {
                                        
                                        mapDUNSint.put(op.Account.Duns__c,1);
                                       // System.debug('Inside If DUNS 1');
                                    }
                                }
                            }
                            if(op.Account.Website!=null && op.Account.Website!='' && op.Account.Country__c!=null && op.Account.Country__c!='')
                            {
                                list<String> DomainLst=new list<String>();
                               // System.debug('OpportunityId-Web'+ op.id);
                                String s = String.valueof(op.Account.Website);
                                    s=s.toLowerCase();
                                if(s.contains('.'))
                                {
                                    s=s.trim();
                                    /*if(s.contains('//'))
                                    {
                                        s=s.replaceall('//','.');
                                    }
                                     List<String> spliitedWeb=s.Split('\\.');
                                    DomainLst.addall(spliitedWeb);
                                    */
                                    if(s.contains('http://')|| s.contains('https://'))
                                    {
                                        if(s.contains('http://'))
                                        {
                                            if(s.contains('www.'))
                                            {
                                                s=s.replaceall('http://','');
                                            }
                                            else
                                                s=s.replaceall('http://','www.');
                                        }
                                        else if(s.contains('https://'))
                                        {
                                            if(s.contains('www.'))
                                            {
                                                s=s.replaceall('https://','');
                                            }
                                            else
                                                s=s.replaceall('https://','www.');
                                        }
                                    }
                                    DomainLst.add(s);
                                }   
                                else if(!s.contains('.'))
                                {
                                    s=s.trim();
                                    if(s.contains('http://') || s.contains('https://'))
                                    {
                                        //List<String> spliitedWeb=s.Split('\\/\\/');
                                        //DomainLst.addall(spliitedWeb);
                                        if(s.contains('http://'))
                                        {
                                            s=s.replaceall('http://','www.');
                                        }
                                        else if(s.contains('https://'))
                                        {
                                            s=s.replaceall('https://','www.');
                                        }
                                    }
                                    DomainLst.add(s);
                                }
                               // System.debug(op.Account.Website);
                                
                               // System.debug('DomainLst' + DomainLst);
                                if(DomainLst.size()>0)
                                {
                                                             
                                    if(!mpOptySiteCountry.containskey(DomainLst[0]+op.Account.Country__c))
                                    {
                                        mpOptySiteCountry.put(DomainLst[0]+op.Account.Country__c,op);
                                        mapDOMAINint.put(DomainLst[0]+op.Account.Country__c,0);
                                      //  System.debug('Domain Value' + DomainLst[0]+op.Account.Country__c);
                                    }
                                    else
                                    {
                                       // System.debug('Inside else Domain');
                                        if(!mpOptySiteCountry.get(DomainLst[0]+op.Account.Country__c).Account.Name.equalsignorecase(op.Account.Name))
                                        {
                                           
                                            mapDOMAINint.put(DomainLst[0]+op.Account.Country__c,1);
                                           // System.debug('Inside If Domain 1');
                                        }
                                    }
                                }
                            }
                            
                                if(!mapAccountName.containskey(op.Account.Name+op.Account.Country__c))
                                {
                                    mapAccountName.put(op.Account.Name+op.Account.Country__c,op);
                                }
                            
                        }
                        
                        for(Lead ld : triggernew)
                        {   
                            String Domain;
                           // System.debug('Map'+mpOptySiteCountry);
                          if(ld.email!=null && ld.email!='')
                          {
                                 ld.email=ld.email.toLowercase();
                            if(ld.email.contains('@'))
                            {
                                list<String> lstSplit = ld.Email.Split('@');
                                if(lstSplit!=null && lstSplit.size()==2)
                                {
                                    if(lstSplit[1].trim()!='' && lstSplit[1]!=null)
                                    Domain='www.' + lstSplit[1].trim();
                                    //Domain =String.valueof(ld.email).substringBetween('@','.');
                                    
                                }
                            }
                          }
                          //  System.debug('Lead Domain' + Domain);
                            if(ld.UUID__c!=null)
                            {
                               // System.debug('Inside Lead If UUID');
                                if(mpOptyUUID.get(ld.UUID__C)!=null && mapUUIDint.get(ld.UUID__c)!=null)
                                {
                                   // System.debug('Inside Lead If UUID-> Match Found 1');
                                    if(mapUUIDint.get(ld.UUID__c)==0 && mpOptyUUID.get(ld.UUID__C).Account.Country__c.equalsignorecase(ld.Country__c)){
                                        ld.Existing_Account_Opportunity__c=true;
                                        continue;
                                    }
                                    if(mapUUIDint.get(ld.UUID__c)!=0)
                                    {
                                        if(mapAccountName.containskey(ld.Company+ld.Country__c))
                                        {
                                          
                                             //System.debug('Inside Lead If UUID-> Match Found 2');
                                             ld.Existing_Account_Opportunity__c=true;
                                             continue;
                                          
                                        }
                                        else
                                        {
                                            ld.Existing_Account_Opportunity__c=false;
                                        }
                                    }
                              }
                              else
                              {
                                  ld.Existing_Account_Opportunity__c=false;
                              }
                            }
                            if(ld.DUNS__c!=null)
                            {
                               // System.debug('Inside Lead If Duns');
                                if(mpOptyDUNS.get(ld.DUNS__c)!=null && mapDUNSint.get(ld.DUNS__c)!=null)
                                {
                                   // System.debug('Inside Lead If DUNS-> Match Found 1');
                                    if(mapDUNSint.get(ld.DUNS__c)==0 && mpOptyDUNS.get(ld.DUNS__c).Account.Country__c.equalsignorecase(ld.Country__c)){
                                        ld.Existing_Account_Opportunity__c=true;
                                        continue;
                                    }
                                    if(mapDUNSint.get(ld.DUNS__c)!=0)
                                    {
                                        if(mapAccountName.containskey(ld.Company+ld.Country__c))
                                        {
                                           
                                               // System.debug('Inside Lead If DUNS-> Match Found 2');
                                                ld.Existing_Account_Opportunity__c=true;
                                                continue;
                                           
                                        }
                                        else
                                        {
                                            ld.Existing_Account_Opportunity__c=false;
                                        }
                                     }
                                }
                                else
                                {
                                  ld.Existing_Account_Opportunity__c=false;
                                }
                            }
                            if(ld.Email!=null && ld.Email!='' && ld.Country__c!=null && ld.Country__c!='' && Domain!=null && mpOptySiteCountry.get(Domain+ld.country__c)!=null && mapDOMAINint.get(Domain+ld.country__c)!=null)
                            {
                               // System.debug('Inside Lead If Web');
                                if(mapDOMAINint.get(Domain+ld.country__c)==0 && mpOptySiteCountry.get(Domain+ld.country__c).Account.Country__c.equalsignorecase(ld.Country__c)){
                                    //System.debug('Inside Lead If Web-> Match Found 1');
                                    ld.Existing_Account_Opportunity__c=true;
                                    continue;
                                }
                                 if(mapDOMAINint.get(Domain+ld.country__c)!=0)
                                {
                                    if(mapAccountName.containskey(ld.Company+ld.Country__c))
                                    {
                                       
                                           // System.debug('Inside Lead If Web-> Match Found 2');
                                            ld.Existing_Account_Opportunity__c=true;
                                            continue;
                                      
                                    }
                                    else
                                    {
                                        ld.Existing_Account_Opportunity__c=false;
                                    }
                                }
                            }
                            
                             ld.Existing_Account_Opportunity__c=false;
                           
                            //System.debug('Lead value ' + ld.Existing_Account_Opportunity__c);
                        }
                        
                    }
                    else
                    {
                        for(Lead ldobj: triggernew)
                        {
                                if((Trigger.isInsert) ||(Trigger.isUpdate && (mapOldLead.get(ldobj.id).Status!= ldobj.Status && (ldobj.Status=='0 New Response' || ldobj.Status=='0 New')) ||(mapOldLead.get(ldobj.id).Campaign__c!=ldobj.Campaign__c)))
                                {
                                    if(ldobj.Geo__c=='AMER')
                                    {
                                ldobj.Existing_Account_Opportunity__c=false;
                                }
                        }
                    }
                }
             } 
           }
          }
          
           //***************************************************************************************************************
        // Method Name: sync_LDR_Lead_to_SDP 
        // Description: This method will sync the "1. Marketing Qualified" and "5. Rejected" Lead to SDP qualified/rejected through LDR process. 
        // Change Request # : CR-00132427 
        //***************************************************************************************************************
        public static void sync_LDR_Lead_to_SDP(List<Lead> leadList , Map<Id,Lead> oldLeadMap){
            
            Map<id, Lead> leadMapTOSync = new Map<id, Lead>();  
            
            for( Lead leadObj : leadList ){
            
                Lead oldLeadObj = oldLeadMap.get(leadObj.id);
                // If Lead status changed
                if( leadObj.Trial_Status__c =='Under Review' 
                    && ( (leadObj.status=='1 Marketing Qualified' && oldLeadObj.status!='1 Marketing Qualified') ||
                        (leadObj.status=='5 Rejected' && oldLeadObj.status!='5 Rejected'))) {
                        // Add the eligible leads in map for batch processing
                        //leadMapTOSync.put(leadObj.id,leadObj);
                        leadObj.isLDRLead__c = true;
                    
                    }
                 // If Trial Status changed
                 if( leadObj.Trial_Status__c =='Under Review' && oldLeadObj.Trial_Status__c !='Under Review'
                     && ( leadObj.status=='1 Marketing Qualified' ||leadObj.status=='5 Rejected')){
                     // Add the eligible leads in map for batch processing
                        //leadMapTOSync.put(leadObj.id,leadObj);
                        leadObj.isLDRLead__c = true;
                  }
            
            }
            
            // Call Batch class for SDP sync.
            //if(!leadMapTOSync.isEmpty() && BatchJobUtility.canScheduleBatchJob()){
                //Database.executeBatch(new SyncLeadtoSDPBatch(leadMapTOSync),20) ;
            //}
        }
        
        
        //***************************************************************************************************************
        // Method Name: sync_LDR_Lead_to_SDP_AI
        // Description: This method will sync the "1. Marketing Qualified" and "5. Rejected" Lead to SDP qualified/rejected through LDR process. 
        // Change Request # : CR-00132427 
        //***************************************************************************************************************
        public static void sync_LDR_Lead_to_SDP_AI(List<Lead> leadList){
            
            Map<id, Lead> leadMapTOSync = new Map<id, Lead>();  
            
            for( Lead leadObj : leadList ){
            
                if( leadObj.Trial_Status__c =='Under Review' 
                    && ( leadObj.status=='1 Marketing Qualified' ||leadObj.status=='5 Rejected')) {
                        // Add the eligible leads in map for batch processing
                        //leadMapTOSync.put(leadObj.id,leadObj);
                        leadObj.isLDRLead__c = true;
                    
                    }            
            
            }
            
            // Call Batch class for SDP sync.
            //if(!leadMapTOSync.isEmpty() && BatchJobUtility.canScheduleBatchJob() ){
               // Database.executeBatch(new SyncLeadtoSDPBatch(leadMapTOSync),20) ;
            //}
        }
        //***************************************************************************************************************
        // Method Name: updateLeadAccountMatchedFlag
        // Description:  
        // Change Request # :  CR-00134262 - SFA PRM Enhancement
        //***************************************************************************************************************
        public static void updateLeadAccountMatchedFlag(){
            Map<ID,Lead> oldMap = (Map<Id,Lead>)Trigger.OldMap;
            List<Lead> triggernew = (List<Lead>)Trigger.new;
            for(Lead leadRec : triggernew){
                if(Trigger.isInsert && recursive.leadAccountMatchFlag == false){
                    leadRec.Lead_Account_Match_Status__c = 'Waiting';
                }
                
                if(Trigger.isUpdate && recursive.leadAccountMatchFlag == false){
                    if((leadRec.Company != Null && !leadRec.Company.equalsIgnoreCase(oldMap.get(leadRec.ID).Company))
                      || (leadRec.City__c != Null && !leadRec.City__c.equalsIgnoreCase(oldMap.get(leadRec.ID).City__c))
                      || (leadRec.State_Province__c != Null && !leadRec.State_Province__c.equalsIgnoreCase(oldMap.get(leadRec.ID).State_Province__c))
                      || (leadRec.Country__c != Null && !leadRec.Country__c.equalsIgnoreCase(oldMap.get(leadRec.ID).Country__c))                  
                      || (leadRec.Industry != Null && !leadRec.Industry.equalsIgnoreCase(oldMap.get(leadRec.ID).Industry))
                      || (leadRec.UUID__c != Null && !leadRec.UUID__c.equalsIgnoreCase(oldMap.get(leadRec.ID).UUID__c))
                      || (leadRec.duns__c != Null && !leadRec.duns__c.equalsIgnoreCase(oldMap.get(leadRec.ID).duns__c))
                      || (leadRec.Postal_Code__c!= Null && !leadRec.Postal_Code__c.equalsIgnoreCase(oldMap.get(leadRec.ID).Postal_Code__c))
                      || (leadRec.Address_1__c!= Null && !leadRec.Address_1__c.equalsIgnoreCase(oldMap.get(leadRec.ID).Address_1__c))
                      || (leadRec.Address_2__c!= Null && !leadRec.Address_2__c.equalsIgnoreCase(oldMap.get(leadRec.ID).Address_2__c))){
                      
                         leadRec.Lead_Account_Match_Status__c = 'Waiting';
                    }
                }
            }
        }
        
        // ***************************************************************************************************
        // Method Name: updateExistingOpportunityFlagForEloqua
        // Description:  Invoke this method once lead inserted/updated by Eloqua Integration User
        // Change Request # :  CR-00135033 - SFA PRM Defects
        //***************************************************************************************************************
       public static void updateExistingOpportunityFlagForEloqua(List<Lead> LeadList)
            {    
            
                
                String OpportunityQuery ='Select Id,AccountId,Account.Name,Account.Website,Account.Country__c,Account.UUID__c,Account.DUNS__c,StageName from Opportunity where (StageName!=\'06 - Closed Won\' And StageName!=\'07 - Closed Lost\' And StageName!=\'07c - Closed Won\' And StageName!=\'08 - Closed Lost\') And Account.Account_Status__c =\'Active\' And Account.Geo__c=\'AMER\' And Account.Country__c In : ListLeadCountries';
                    String InitQuery=OpportunityQuery;
                    
                    Map<Id, Lead> leadMap = new Map<Id, Lead>();
                    Map<Id,Lead> mapOldLead = (Map<Id,Lead>)Trigger.oldMap;
                    List<Lead> triggernew = (List<Lead>)Trigger.new;
                    Map<String,Opportunity> mpOptyUUID= new Map<String,Opportunity>();
                    Map<String,Opportunity> mpOptyDUNS= new Map<String,Opportunity>();
                     Map<String,Opportunity> mpOptySiteCountry= new Map<String,Opportunity>();
                     Map<String,Opportunity> mapAccountName = new Map<String,Opportunity>();
                     
                    Set<String> SetLeadUUID = new Set<String>();
                    List<String>LstLeadUUID= new List<String>();
                    Set<String> SetLeadDUNS = new Set<String>();
                    List<String>LstLeadDUNS= new List<String>();
                    Set<String>SetLeadEmailCountry = new Set<String>();
                    List<String>LstLeadEmailCountry = new List<String>();

                    set<String> SetleadFULLwebSite = new set<String>();
                    List<String> ListleadFULLwebSite = new List<String>();
                    Set<String> SetLeadCountries = new Set<String>();
                    List<String> ListLeadCountries = new List<String>();
                    
                    Map<String,Integer> mapUUIDint = new Map<String,Integer>();
                    Map<String,Integer> mapDUNSint = new Map<String,Integer>();
                    Map<String,Integer> mapDOMAINint = new Map<String,Integer>();
                       
                    String Q2;
                    
                    for(Lead ld : LeadList)
                    {
                        
                            if(ld.Geo__c=='AMER')
                            {   
                                if(ld.UUID__c!=null)
                                {
                                    SetLeadUUID.add(ld.UUID__c);
                                }
                                if(ld.DUNS__c!=null)
                                {
                                    SetLeadDUNS.add(ld.DUNS__c);
                                }
                                if(ld.email!=null && ld.Country__c!=null)
                                {
                                     if(ld.Email.Contains('@')){
                                        list<String> lstSplit = ld.Email.Split('@');
                                        if(!lstSplit.isEmpty() && lstSplit.Size() == 2 ){
                                            if(lstSplit[1] != null && lstSplit[1].trim() != ''){
                                                String EmailDomain = 'WWW.'+lstSplit[1].trim().ToUpperCase();
                                                setleadFULLwebSite.add(EmailDomain);
                                                if(lstSplit[1].trim().Contains('.')){
                                                    list<String> lstSplitDomains = lstSplit[1].trim().split('\\.'); 
                                                    if(lstSplitDomains != null && !lstSplitDomains.isEmpty()){
                                                        for(String str : lstSplitDomains){
                                                            if(str.trim() != '' && str != 'IN' && str != 'COM' && str != 'CO' && str != 'ORG'){
                                                                setleadFULLwebSite.add('%'+str.trim().ToUppercase()+'%');   
                                                            }
                                                        }   
                                                    }   
                                                }
                                            }
                                        }   
                                    }
                                       
                                   // System.debug('Website Lead'+ setleadFULLwebSite );
                                   // System.debug('Country Lead' + SetLeadCountries);
                                    
                                }
                                 SetLeadCountries.add(ld.Country__c);
                            }   
                                   
                    }
                    if(!SetLeadCountries.isempty())
                    {
                        ListLeadCountries.addall(SetLeadCountries);
                    }
                    if(!SetLeadUUID.isempty())
                    {
                        LstLeadUUID.addall(SetLeadUUID);
                        Q2=' And ((Account.UUID__C in : LstLeadUUID )';
                        if(!SetLeadDUNS.isempty())
                        {
                            LstLeadDUNS.addall(SetLeadDUNS);
                            Q2 = Q2 + ' OR (Account.DUNS__c in : LstLeadDUNS )';
                        }
                        if(!setleadFULLwebSite.isempty() && !SetLeadCountries.isempty())
                        {
                            ListleadFULLwebSite.addall(setleadFULLwebSite);
                            
                            Q2=Q2+ ' OR ((Account.Website Like : ListleadFULLwebSite ))';
                        }
                        Q2 =Q2 +')';
                        
                    }
                    else if(!SetLeadDUNS.isempty())
                    {
                            LstLeadDUNS.addall(SetLeadDUNS);
                            Q2 = ' And ((Account.DUNS__c in : LstLeadDUNS )';
                        
                        if(!setleadFULLwebSite.isempty() && !SetLeadCountries.isempty())
                        {
                            ListleadFULLwebSite.addall(setleadFULLwebSite);
                                
                            Q2=Q2 + ' OR ((Account.Website Like : ListleadFULLwebSite) )';
                        }
                            Q2 = Q2 + ')' ;
                    }
                    else if(!setleadFULLwebSite.isempty() && !SetLeadCountries.isempty())
                    {
                                      
                        Set<id> sid= new Set<Id>();
                        ListleadFULLwebSite.addall(setleadFULLwebSite);
                        for(Account acc : [Select Id,Website,Country__c from Account where Website Like : ListleadFULLwebSite and Country__c in: ListLeadCountries])
                        {
                            sid.add(acc.id);
                        }
                        if(!sid.isempty()){
                        Q2=' And (AccountId in : sid';
                        Q2 = Q2 + ')' ;
                        }
                    }               
                    
                    if(Q2!=null)
                    {
                        OpportunityQuery= OpportunityQuery + Q2;
                    }
                   // System.debug('Query' + OpportunityQuery);
                    
                    List<Opportunity> OptyLst = new List<Opportunity>();
                    
                    if(!InitQuery.equals(OpportunityQuery))
                    {   
                        OptyLst=Database.query(OpportunityQuery);
                       // System.debug('ListofOpportunity'+ OptyLst);
                    }
                   
                    
                    if(!OptyLst.isempty())
                    {
                       // System.debug('Found a value');
                        
                        for(Opportunity op : OptyLst)
                        {
                            
                            if(op.Account.UUID__c!=null && SetLeadUUID.contains(op.Account.UUID__c))
                            {    
                               // System.debug('OpportunityId-UUID'+ op.id);              
                                if(!mpOptyUUID.containskey(op.Account.UUID__c))
                                {
                                    mpOptyUUID.put(op.Account.UUID__c,op);
                                    mapUUIDint.put(op.Account.UUID__c,0);
                                }
                                else
                                {
                                    
                                   // System.debug('Inside else UUID');
                                    if(!mpOptyUUID.get(op.Account.UUID__c).Account.Name.equalsignorecase(op.Account.Name))
                                    {
                                        
                                        mapUUIDint.put(op.Account.UUID__c,1);
                                       // System.debug('Inside If UUID 1');
                                    }
                                }
                            }
                            
                            if(op.Account.DUNS__C!=null && SetLeadDUNS.contains(op.Account.DUNS__C))
                            {
                              //  System.debug('OpportunityId-Duns'+ op.id);
                                if(!mpOptyDUNS.containskey(op.Account.Duns__c))
                                {
                                    mpOptyDUNS.put(op.Account.Duns__c,op);
                                    mapDUNSint.put(op.Account.Duns__c,0);
                                }
                                else
                                {
                                   // System.debug('Inside else Duns');

                                    if(!mpOptyDUNS.get(op.Account.Duns__c).Account.Name.equalsignorecase(op.Account.Name))
                                    {
                                        
                                        mapDUNSint.put(op.Account.Duns__c,1);
                                       // System.debug('Inside If DUNS 1');
                                    }
                                }
                            }
                            if(op.Account.Website!=null && op.Account.Website!='' && op.Account.Country__c!=null && op.Account.Country__c!='')
                            {
                                list<String> DomainLst=new list<String>();
                               // System.debug('OpportunityId-Web'+ op.id);
                                String s = String.valueof(op.Account.Website);
                                    s=s.toLowerCase();
                                if(s.contains('.'))
                                {
                                    s=s.trim();
                                    /*if(s.contains('//'))
                                    {
                                        s=s.replaceall('//','.');
                                    }
                                     List<String> spliitedWeb=s.Split('\\.');
                                    DomainLst.addall(spliitedWeb);
                                    */
                                    if(s.contains('http://')|| s.contains('https://'))
                                    {
                                        if(s.contains('http://'))
                                        {
                                            if(s.contains('www.'))
                                            {
                                                s=s.replaceall('http://','');
                                            }
                                            else
                                                s=s.replaceall('http://','www.');
                                        }
                                        else if(s.contains('https://'))
                                        {
                                            if(s.contains('www.'))
                                            {
                                                s=s.replaceall('https://','');
                                            }
                                            else
                                                s=s.replaceall('https://','www.');
                                        }
                                    }
                                    DomainLst.add(s);
                                }   
                                else if(!s.contains('.'))
                                {
                                    s=s.trim();
                                    if(s.contains('http://') || s.contains('https://'))
                                    {
                                        //List<String> spliitedWeb=s.Split('\\/\\/');
                                        //DomainLst.addall(spliitedWeb);
                                        if(s.contains('http://'))
                                        {
                                            s=s.replaceall('http://','www.');
                                        }
                                        else if(s.contains('https://'))
                                        {
                                            s=s.replaceall('https://','www.');
                                        }
                                    }
                                    DomainLst.add(s);
                                }
                               // System.debug(op.Account.Website);
                                
                               // System.debug('DomainLst' + DomainLst);
                                if(DomainLst.size()>0)
                                {
                                                             
                                    if(!mpOptySiteCountry.containskey(DomainLst[0]+op.Account.Country__c))
                                    {
                                        mpOptySiteCountry.put(DomainLst[0]+op.Account.Country__c,op);
                                        mapDOMAINint.put(DomainLst[0]+op.Account.Country__c,0);
                                      //  System.debug('Domain Value' + DomainLst[0]+op.Account.Country__c);
                                    }
                                    else
                                    {
                                       // System.debug('Inside else Domain');
                                        if(!mpOptySiteCountry.get(DomainLst[0]+op.Account.Country__c).Account.Name.equalsignorecase(op.Account.Name))
                                        {
                                           
                                            mapDOMAINint.put(DomainLst[0]+op.Account.Country__c,1);
                                           // System.debug('Inside If Domain 1');
                                        }
                                    }
                                }
                            }
                            
                                if(!mapAccountName.containskey(op.Account.Name+op.Account.Country__c))
                                {
                                    mapAccountName.put(op.Account.Name+op.Account.Country__c,op);
                                }
                            
                        }
                        
                        for(Lead ld : LeadList)
                        {   
                            String Domain;
                           // System.debug('Map'+mpOptySiteCountry);
                          if(ld.email!=null && ld.email!='')
                          {
                                 ld.email=ld.email.toLowercase();
                            if(ld.email.contains('@'))
                            {
                                list<String> lstSplit = ld.Email.Split('@');
                                if(lstSplit!=null && lstSplit.size()==2)
                                {
                                    if(lstSplit[1].trim()!='' && lstSplit[1]!=null)
                                    Domain='www.' + lstSplit[1].trim();
                                    //Domain =String.valueof(ld.email).substringBetween('@','.');
                                    
                                }
                            }
                          }
                          //  System.debug('Lead Domain' + Domain);
                            if(ld.UUID__c!=null)
                            {
                               // System.debug('Inside Lead If UUID');
                                if(mpOptyUUID.get(ld.UUID__C)!=null && mapUUIDint.get(ld.UUID__c)!=null)
                                {
                                   // System.debug('Inside Lead If UUID-> Match Found 1');
                                    if(mapUUIDint.get(ld.UUID__c)==0 && mpOptyUUID.get(ld.UUID__C).Account.Country__c.equalsignorecase(ld.Country__c)){
                                        ld.Existing_Account_Opportunity__c=true;
                                        ld.Check_for_ELOQUA_Integration__c = false;         //added for CR-00138487
                                        continue;
                                    }
                                    if(mapUUIDint.get(ld.UUID__c)!=0)
                                    {
                                        if(mapAccountName.containskey(ld.Company+ld.Country__c))
                                        {
                                          
                                             //System.debug('Inside Lead If UUID-> Match Found 2');
                                             ld.Existing_Account_Opportunity__c=true;
                                             ld.Check_for_ELOQUA_Integration__c = false;        //added for CR-00138487
                                             continue;
                                          
                                        }
                                        else
                                        {
                                            ld.Existing_Account_Opportunity__c=false;
                                        }
                                    }
                              }
                              else
                              {
                                  ld.Existing_Account_Opportunity__c=false;
                              }
                            }
                            if(ld.DUNS__c!=null)
                            {
                               // System.debug('Inside Lead If Duns');
                                if(mpOptyDUNS.get(ld.DUNS__c)!=null && mapDUNSint.get(ld.DUNS__c)!=null)
                                {
                                   // System.debug('Inside Lead If DUNS-> Match Found 1');
                                    if(mapDUNSint.get(ld.DUNS__c)==0 && mpOptyDUNS.get(ld.DUNS__c).Account.Country__c.equalsignorecase(ld.Country__c)){
                                        ld.Existing_Account_Opportunity__c=true;
                                        ld.Check_for_ELOQUA_Integration__c = false;         //added for CR-00138487
                                        continue;
                                    }
                                    if(mapDUNSint.get(ld.DUNS__c)!=0)
                                    {
                                        if(mapAccountName.containskey(ld.Company+ld.Country__c))
                                        {
                                           
                                               // System.debug('Inside Lead If DUNS-> Match Found 2');
                                                ld.Existing_Account_Opportunity__c=true;
                                                ld.Check_for_ELOQUA_Integration__c = false;     //added for CR-00138487
                                                continue;
                                           
                                        }
                                        else
                                        {
                                            ld.Existing_Account_Opportunity__c=false;
                                        }
                                     }
                                }
                                else
                                {
                                  ld.Existing_Account_Opportunity__c=false;
                                }
                            }
                            if(ld.Email!=null && ld.Email!='' && ld.Country__c!=null && ld.Country__c!='' && Domain!=null && mpOptySiteCountry.get(Domain+ld.country__c)!=null && mapDOMAINint.get(Domain+ld.country__c)!=null)
                            {
                               // System.debug('Inside Lead If Web');
                                if(mapDOMAINint.get(Domain+ld.country__c)==0 && mpOptySiteCountry.get(Domain+ld.country__c).Account.Country__c.equalsignorecase(ld.Country__c)){
                                    //System.debug('Inside Lead If Web-> Match Found 1');
                                    ld.Existing_Account_Opportunity__c=true;
                                    ld.Check_for_ELOQUA_Integration__c = false;     //added for CR-00138487
                                    continue;
                                }
                                 if(mapDOMAINint.get(Domain+ld.country__c)!=0)
                                {
                                    if(mapAccountName.containskey(ld.Company+ld.Country__c))
                                    {
                                       
                                           // System.debug('Inside Lead If Web-> Match Found 2');
                                            ld.Existing_Account_Opportunity__c=true;
                                            ld.Check_for_ELOQUA_Integration__c = false;     //added for CR-00138487
                                            continue;
                                      
                                    }
                                    else
                                    {
                                        ld.Existing_Account_Opportunity__c=false;
                                    }
                                }
                            }
                            
                             ld.Existing_Account_Opportunity__c=false;
                           
                            //System.debug('Lead value ' + ld.Existing_Account_Opportunity__c);
                ld.Check_for_ELOQUA_Integration__c = false;
                        }
                        
                    }
                    
                 if(LeadList.size()>0){    
             LA_BatchToFlagLeadsForReport.isAffectedLeadReportPull = true;   
            //database.update(LeadList);
            Database.update(LeadList, false);        //added for CR-00138487
            
             }    
           
          } 
    }