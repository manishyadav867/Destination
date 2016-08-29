//***********************************************************************************
// Name             : Orion_AutoApprovalInACRForDeal.cls
// Description      : Batch Job to create account requests for deal reg
// Created By       : Yoganand Gadekar
// Created Date     : 20-Apr-2016
// Requirement      : Orion Phase 2,
// ************************Version Updates********************************************
//// Updated Date     Updated By       Update Comments 
//   03.08.2016      PRITESH SONI      Added Method schedulerMethod for merging multiple schedulers.
//   23.08.2016      Hem Gayal      Added by HEM on 26th-Aug-2016 - CR-00140589
// ***********************************************************************************

global with sharing class Orion_AutoApprovalInACRForDeal implements Database.Batchable<sObject>, Database.Stateful{
    //START:Added reduce no of schedulers -Pritesh
    global Scheduler_Optimizer__c schedulerOptimizer = Scheduler_Optimizer__c.getInstance('Orion_AutoApprovalInACRRecord');
    global Database.QueryLocator start(Database.BatchableContext bc) {      
        date cutOffDate = system.today();
        //Checks if test is running then return limited data
        if(Test.isRunningTest()){
            return Database.getQueryLocator('Select id,Deal_Registration__c,Request_Status__c,DS_Account_Name__c  from account_request__c limit 2');
        }
        //START:Added logic to reduce no of schedulers -Pritesh
        Boolean switchonoff = false; Integer minsToSchedule = 0; String schedulerJobName = '';
        if(schedulerOptimizer != Null){minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c);schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c;switchonoff = schedulerOptimizer.On_Off_Switch__c;
        }
        else{
            minsToSchedule = 15; schedulerJobName = 'Orion_AutoApprovalInACRForDealScheduler';
        }
        if(switchonoff){Database.QueryLocator q = Database.getQueryLocator('Select id,Request_Status__c,Deal_Registration__c,DS_Account_Name__c from account_request__c where Request_Status__c = '+'\''+'Completed'+'\''+' and Deal_Registration__c != null and Deal_ACR__c = true');
            // Get an iterator
             Database.QueryLocatorIterator it =  q.iterator();if(!it.hasNext()){schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'Orion_AutoApprovalInACRForDealScheduler');
            }return q;
        }
        else{return Database.getQueryLocator('Select id,Request_Status__c,Deal_Registration__c,DS_Account_Name__c from account_request__c where Request_Status__c = '+'\''+'Completed'+'\''+' and Deal_Registration__c != null and Deal_ACR__c = true');
        }
        //END:Added logic to reduce no of schedulers -Pritesh
       
    }
    
    //override the execute method
    global void execute(Database.BatchableContext bc, List<account_request__c> scope){
       //1. Added by HEM on 26th-Aug-2016 - CR-00140589 - START
       Set<Id> accIds = new Set<Id>();
       //1. Added by HEM on 26th-Aug-2016 - CR-00140589 - END
       List<deal_registration__c> dealRegUpdateList = New List<deal_registration__c>();
       map<id,id> dealAccMap = new map<id,id>();
       for(account_request__c acr : scope){
           dealAccMap.put(acr.Deal_Registration__c,acr.DS_Account_Name__c);
           //2. Added by HEM on 26th-Aug-2016 - CR-00140589 - START
           accIds.add(acr.DS_Account_Name__c);
           //2. Added by HEM on 26th-Aug-2016 - CR-00140589 - END
           acr.Deal_ACR__c = false;
       }
       database.update(scope,false);
       
       for(id dealId : dealAccMap.keyset()){
           deal_registration__c dealRec = new deal_registration__c(
           id = dealId,
           Account_Populated__c = dealAccMap.get(dealId)
           );
          dealRegUpdateList.add(dealRec); 
       }
       
       database.update(dealRegUpdateList,false);
       //3. Added by HEM on 26th-Aug-2016 - CR-00140589 - START
       List<Account> accountList = new List<Account>();
       Set<Id> eligibleAccountIdSet = new Set<Id>();
       if(!accIds.isEmpty()){           
            List<String> excludePFSTList = new List<String>();
            excludePFSTList = Orion_Record__c.getInstance('PFSTNames')!=null && Orion_Record__c.getInstance('PFSTNames').value__c!=null?Orion_Record__c.getInstance('PFSTNames').value__c.split(';'):'Airwatch_temporary;Renewals_Temporary;VMware Consumer'.split(';');        
            Set<String> excludePFSTSet=new Set<String>(excludePFSTList);
            System.debug('-----excludePFSTSet------'+excludePFSTSet);         
            accountList = [Select Id, Name, Primary_Field_Sales_Territory__r.Name from Account where (Id in : accIds AND (NOT Primary_Field_Sales_Territory__r.Name in : excludePFSTSet))];
            for(Account acc : accountList){
                eligibleAccountIdSet.add(acc.Id);
            }           
       }
        //3. Added by HEM on 26th-Aug-2016 - CR-00140589 - END
        for(account_request__c acr : scope){
        Orion_OppManagementUtility.acrDealApproval = true;
        try{
            if(acr.Deal_Registration__c != null){
                //4. Added by HEM on 26th-Aug-2016 - CR-00140589 - START
                if(eligibleAccountIdSet.contains(acr.DS_Account_Name__c)){
                //4. Added by HEM on 26th-Aug-2016 - CR-00140589 - END
                    Orion_OppManagementSequenceController.searchEndCustomerAccount(acr.Deal_Registration__c,acr.DS_Account_Name__c);
                }
            }   
        }
        catch(exception ex){
          
        }           
      }
      
    }
     //override the finish method
    global void finish (Database.BatchableContext bc){
        //START:Added logic to reduce no of schedulers -Pritesh
        Boolean switchonoff = false;
        Integer minsToSchedule = 0;
        String schedulerJobName = '';
        if(schedulerOptimizer != Null){
            minsToSchedule = Integer.valueOf(schedulerOptimizer.Time_in_Minutes_0_59__c);
            schedulerJobName = schedulerOptimizer.Scheduler_Job_Name__c;
            switchonoff = schedulerOptimizer.On_Off_Switch__c;
        }
        else{
            minsToSchedule = 15; schedulerJobName = 'Orion_AutoApprovalInACRForDealScheduler';
        }
        if(switchonoff){
             schedulerOptimizerClass.schedulerMethod(schedulerJobName,minsToSchedule,'Orion_AutoApprovalInACRForDealScheduler');
        }
        //END:Added logic to reduce no of schedulers -Pritesh
    }  
}