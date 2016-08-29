//***************************************************************************************************************//
//Name       :  Lead_Campaign_MappingBatch  
//Description:  Screening owner will populate from newly associated campaign if screening owner is eloqua integration user
//Created By :  safiya mohammad
//Date       :  Feb 08 2012
//CR-00137430 :Campaign Association changes
//Manish Yadav     10-06-2015    Added Condition to handle AW Eloqua User
//Prateek          23-08-2016    Added Logic for merging multiple schedulers.       
//**************************************************************************************************************//
global class Lead_Campaign_MappingBatch implements Database.Batchable<sObject>{
     global Set<id> userid = new Set<id>();
     global Lead_Campaign_MappingBatch(){}
     // Added Logic for merging multiple schedulers - Start
     global Scheduler_Optimizer__c schedulerOptimizer = Scheduler_Optimizer__c.getInstance('Lead_Campaign_MappingBatchRecord');
      global String query;
      // Added Logic for merging multiple schedulers - End
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        List<Record_Source_Restriction__c> rsrList = Record_Source_Restriction__c.getall().values(); //ELoqua User Changes
        Set<String> eloquaStr = new Set<String>(); //ELoqua User Changes
        List<User> userList = new List<User>();
        // Start : AW ELoqua User Changes
        for(Record_Source_Restriction__c rsr : rsrList){
            if(!rsr.Inactive__c){    
                eloquaStr.add(rsr.Name);
            }
        }
         // userid= [select id,name from User where name ='Eloqua Integration'].id;
          userList = [select id,name from User where name IN :eloquaStr];
          if(!userList.isEmpty()){
              for(User usr :userList){
                 userid.add(usr.id);
              }
          }
          
         // END : AW ELoqua User Changes
        String vMwareLeadRecordTypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('VMware Lead Record Type').getRecordTypeId(); 
        query = 'select id,LDR__c,GEO__c,Screening_Results__c from Lead where recordtypeid =:vMwareLeadRecordTypeid AND LDR__c =: userid AND (Screening_Results__c=\'Pre-Qualified\' OR Screening_Results__c=\'Tele-Qualified\') AND GEO__c=\'EMEA\'';
        // Added Logic for merging multiple schedulers - Start
        Boolean switchonoff=false;
        Integer minsToSchedule=0;
        String schedulerJobName='';
        if(schedulerOptimizer != Null){
            switchonoff = schedulerOptimizer.On_Off_Switch__c;
            minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c);
            schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c;
        }
        else{
            minsToSchedule = 15;
            schedulerJobName = 'ScheduleLead_Campaign_MappingBatch';
        }
        if(switchonoff){
             Database.QueryLocator q = Database.getQueryLocator(query);
            // Get an iterator
            Database.QueryLocatorIterator it =  q.iterator();
            if(!it.hasNext()){
                schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'ScheduleLead_Campaign_MappingBatch');
            }
            return q;
        }
        else{
            return Database.getQueryLocator(query);
        }  // Added Logic for merging multiple schedulers - End
    }
    
    global void execute(Database.BatchableContext BC, List <Lead> listOfLead) {        
         set<Id> leadIds =  new set<Id>();
         set<Id> campaignIds =  new set<Id>();
         map<Id,id> Leadid_Campaignid =  new map<Id,Id>();
         List<CampaignMember> CMList;
         list<Lead> leadtoUpdated = new list<Lead>();
        String campaignApiName = 'Campaign';
        String leadApiName = 'Lead';
        String sQuery = 'SELECT Id,';
        map<id,Campaign> mapCampaign;
       
         list<Lead_Campaign_Field_Mapping__c> mappingenrichmentlist;
         
        if(!listOfLead.isEmpty()){
            for (Lead lead: listOfLead) {
                leadIds.add(lead.id);
            }
            CMList = [SELECT id,CampaignID, LeadID, Status,Lead_Screening_Owner__c FROM CampaignMember WHERE LeadID IN:leadIds ORDER BY lastmodifiedDate DESC];            
            if(!CMList.isEmpty()){
                for(CampaignMember cM:CMList ){
                    
                        
                    if(!Leadid_Campaignid.containskey(cM.LeadID)){
                        campaignIds.add(cM.CampaignID);
                        Leadid_Campaignid.put(cM.LeadID,cM.CampaignID);
                    }
                    
                    
                    
                }
                
                if(Leadid_Campaignid.values().size()>0){
                        mapCampaign = new map<id,Campaign>([select id,ownerId,Solution_Focus__c from Campaign where Id IN:Leadid_Campaignid.values()] )    ;         
                }
                for(Lead ld:listOfLead){
                    if(Leadid_Campaignid.containskey(ld.id) && mapCampaign.containskey(Leadid_Campaignid.get(ld.id))){
                        Campaign camp;
                        camp = mapCampaign.get(Leadid_Campaignid.get(ld.id));
                        
                        if( ld.GEO__c == 'EMEA'  && (ld.Screening_Results__c == 'Pre-Qualified' || ld.Screening_Results__c == 'Tele-Qualified')){
                                        
                                System.debug('Printing lead 90'+ld);
                                ld.LDR__c = camp.ownerId;
                                ld.Primary_Product_Group_Interest__c = camp.Solution_Focus__c;
                                 
                             leadtoUpdated.add(ld);
                            
                        }   
                    }
                }
                
                    
                    
            }              
                     
              If(leadtoUpdated.size()>0){           
                    
                       Database.SaveResult[] srList = Database.Update(leadtoUpdated, false);     
                       for (Database.SaveResult sr : srList) {
                       
                           if (!sr.isSuccess()) {
                               for(Database.Error err : sr.getErrors()) {
                                   System.debug('The following error has occurred.'+err.getmessage());  
                               }
                           }
                       }                      
                }    
            }            
    }
    global void finish(Database.BatchableContext BC) {
        // Added Logic for merging multiple schedulers - Start
    Boolean switchonoff=false;
        Integer minsToSchedule=0;
        String schedulerJobName='';
        if(schedulerOptimizer != Null){
            switchonoff = schedulerOptimizer.On_Off_Switch__c;
            minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c);
            schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c;
        }
        else{
            minsToSchedule = 10;
            schedulerJobName = 'ScheduleLead_Campaign_MappingBatch';
        }
        if(switchonoff){
            schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'ScheduleLead_Campaign_MappingBatch');
        }
  // Added Logic for merging multiple schedulers - End
}
}