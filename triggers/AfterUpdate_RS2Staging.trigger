//*************************************************************************************
// Name             : AfterUpdate_RS2Staging
// Description      : Triggers When Existing Target Case field is Updated
// Created By       : Nilanjana Mukherjee
// Created Date     : 08/12/2016
// ************************************************************************************

trigger AfterUpdate_RS2Staging  on RS2_Opportunity_Case_Staging__c (after insert,after update) {
       
    if(trigger.isAfter && trigger.isUpdate)  
    {
        System.debug('*****Staging Record***'+Trigger.new);
        RS2_QuoteEndDateCalculation.quoteEndDateAfterInsert(Trigger.New,Trigger.oldMap);
        
        //RS2OpportunityCaseStagingController.afterUpdate(Trigger.New, Trigger.oldMap) ;  
    }
}