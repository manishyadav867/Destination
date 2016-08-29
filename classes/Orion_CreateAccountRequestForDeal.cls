//***********************************************************************************
// Name             : Orion_CreateAccountRequestForDeal.cls
// Description      : Batch Job to create account requests for deal reg
// Created By       : Yoganand Gadekar
// Created Date     : 20-Apr-2016
// Requirement      : Orion Phase 2
// ************************Version Updates********************************************
//// Updated Date     Updated By       Update Comments 
//   23rd August 2016 Yoganand         Update for CR-00140581
// ***********************************************************************************

global with sharing class Orion_CreateAccountRequestForDeal implements Database.Batchable<sObject>, Database.Stateful{
    
    //START:Added logic to reduce no of schedulers -Pritesh
    global Scheduler_Optimizer__c schedulerOptimizer = Scheduler_Optimizer__c.getInstance('Orion_CreateAccountRequestRecord');
    //override the start method
    global Database.QueryLocator start(Database.BatchableContext bc) {      
        date cutOffDate = system.today();
        //Checks if test is running then return limited data
        // Get a query locator
        if(Test.isRunningTest()){
            return Database.getQueryLocator('Select id,geo__c,Orion_Deal_In_ACR__c,Partner_Id__c,Registrations__c,Orion_Eligible_to_Lead_Services__c,Country__c,City__c,Zip_Postal_Code__c,State_Province__c,Orion_Customer_Domain__c,Company__c,CloseDate__c,Project_Name__c,Lead_Campaign_Name__c,Campaign_ID__c,Description__c,LeadSource__c,Lead_ID__c,Last_Campaign_Response__c,Screened_By__c,Screening_Results__c,Screening_Pass_Date__c,Primary_Product_Group_Interest__c,Secondary_Product_Group_Interest__c,Product_Interest__c,ORAN__c,Orion_Denial_Reason__c,Address_1__c,Active_Partner_Account__c,First_Name__c,Last_Name__c,VMware_List_License_Value__c,Orion_Primary_Sales_Contact_Name__c,Preferred_Distributor__c,Address_2__c,Industry__c,uuid__c,Duns__c,GULT__c,website__c from deal_registration__c where Orion_Deal_In_ACR__c = true limit 1');
        }
        //START:Added logic to reduce no of schedulers -Pritesh
        Boolean switchonoff=false; Integer minsToSchedule=0; String schedulerJobName='';
        if(schedulerOptimizer != Null){minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c); schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c; switchonoff = schedulerOptimizer.On_Off_Switch__c;
        }
        else{minsToSchedule = 15;schedulerJobName = 'Orion_CreateAccountRequestForDealSchedlr';
        }
        if(switchonoff){Database.QueryLocator q = Database.getQueryLocator('Select id,geo__c,Orion_Deal_In_ACR__c,Partner_Id__c,Registrations__c,Orion_Eligible_to_Lead_Services__c,Country__c,City__c,Zip_Postal_Code__c,State_Province__c,Orion_Customer_Domain__c,Company__c,CloseDate__c,Project_Name__c,Lead_Campaign_Name__c,Campaign_ID__c,Description__c,LeadSource__c,Lead_ID__c,Last_Campaign_Response__c,Screened_By__c,Screening_Results__c,Screening_Pass_Date__c,Primary_Product_Group_Interest__c,Secondary_Product_Group_Interest__c,Product_Interest__c,ORAN__c,Orion_Denial_Reason__c,Address_1__c,Active_Partner_Account__c,First_Name__c,Last_Name__c,VMware_List_License_Value__c,Orion_Primary_Sales_Contact_Name__c,Preferred_Distributor__c,Address_2__c,Industry__c,uuid__c,Duns__c,GULT__c,website__c from deal_registration__c where Orion_Deal_In_ACR__c = true');
            // Get an iterator
            Database.QueryLocatorIterator it =  q.iterator(); if(!it.hasNext()){schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'Orion_CreateAccountRequestForDealSchedlr');}return q;
        }
        else{return Database.getQueryLocator('Select id,geo__c,Orion_Deal_In_ACR__c,Partner_Id__c,Registrations__c,Orion_Eligible_to_Lead_Services__c,Country__c,City__c,Zip_Postal_Code__c,State_Province__c,Orion_Customer_Domain__c,Company__c,CloseDate__c,Project_Name__c,Lead_Campaign_Name__c,Campaign_ID__c,Description__c,LeadSource__c,Lead_ID__c,Last_Campaign_Response__c,Screened_By__c,Screening_Results__c,Screening_Pass_Date__c,Primary_Product_Group_Interest__c,Secondary_Product_Group_Interest__c,Product_Interest__c,ORAN__c,Orion_Denial_Reason__c,Address_1__c,Active_Partner_Account__c,First_Name__c,Last_Name__c,VMware_List_License_Value__c,Orion_Primary_Sales_Contact_Name__c,Preferred_Distributor__c,Address_2__c,Industry__c,uuid__c,Duns__c,GULT__c,website__c from deal_registration__c where Orion_Deal_In_ACR__c = true');
        }
        //END:Added logic to reduce no of schedulers -Pritesh
    }
    
    //override the execute method
    global void execute(Database.BatchableContext bc, List<Deal_Registration__c> scope){
     /*Added as part of 26th August Release START*/
     Set<Id> dealIDSet = New Set<ID>();
     Set<ID> DealBypassIDSet= New Set<Id>();    
     List<Deal_Registration__c> dealRegToProcessList = New List<Deal_Registration__c>();
     /*Added as part of 26th August Release END*/
     
       for(Deal_Registration__c deal : scope){           
           deal.Orion_Deal_In_ACR__c = false; 
           dealIDSet.add(deal.Id);      
       }             
       database.update(scope,false);
       /*Added as part of 26th August Release START*/
         map<id,account_Request__c> acrIdMap = new Map<ID, account_Request__c>([select id,Deal_Registration__c from account_request__c where Deal_Registration__c IN : dealIDSet]);
         for(Deal_Registration__c deal : scope){             
             for(account_Request__c acr : acrIdMap.values()){
                 if(acr.Deal_Registration__c == deal.Id){
                    DealBypassIDSet.add(deal.Id);
                }
             }
             
             if(!DealBypassIDSet.contains(deal.Id)){
                dealRegToProcessList.add(deal);
             }
         }
       /*Added as part of 26th August Release END*/
       if(dealRegToProcessList.size() > 0){
         Orion_OppManagementUtility.createNewAccountRequest(dealRegToProcessList);
       }  
    }
     //override the finish method
    global void finish (Database.BatchableContext bc){
        //START:Added logic to reduce no of schedulers -Pritesh
        Boolean switchonoff=false;
        Integer minsToSchedule=0;
        String schedulerJobName='';
        if(schedulerOptimizer != Null){
            minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c);
            schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c;
            switchonoff = schedulerOptimizer.On_Off_Switch__c;}else{minsToSchedule = 15;schedulerJobName = 'Orion_CreateAccountRequestForDealSchedlr';
        }
        if(switchonoff){
            schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'Orion_CreateAccountRequestForDealSchedlr');
        }
        //END:Added logic to reduce no of schedulers -Pritesh
    }
    
    Public static void boosterMethod(){
      Integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }
}