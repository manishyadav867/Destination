/****************************************************************************************************************
 * Name         : RS2_PrimaryNonBookedQuote
 * Author       : Suman Kumar Patro [Accenture] 
 * Created Date : April 26, 2014 [Against CR-00089987]
 * Usage        : Update primary quote field values in opportunity record and validate primary quote requirment.
 ****************************************************************************************************************/
/***************************************************************************************************************
 Update Date                     Update By                          Update Comments
 
06/12/2014                       RaviKiran D[Accenture]            Added the functionality in RS2 - Quoting Module on Creation of Renewal Quote by calling Apex class "RS2_IncumbentResellerdistributor"
07-08-2015    CR-00134345        Abhishek Shubham[Accenture]       Changed the method signature and sequence of code for RS2_PrimaryQuoteUtilityClass.primaryQuoteTriggerHelper();           
08/12/2016    IBS-73             Nilanjana Mukherjee               Added new Functinality RS2_RenewalQuoteAfterInsert.quoteEndDateAfterInsert();
08/12/2016    IBS-366            Soumya Ranjan                     Added new Functinality RS2_RenewalQuoteAfterInsert.currecyChangeAfterInsert();
****************************************************************************************************************/
trigger RS2_PrimaryNonBookedQuote on Renewal_Quote__c (after update, after insert, before update, before insert) {
      
    //Bypass trigger functionality for Data Migration user.
    Boolean flag=ByPassTrigger.userCustomMap('RS2_PrimaryNonBookedQuote','Renewal_Quote__c'); 
    if(flag){ 
        return;
    }    
    try{       
        RS2_SM_Configuration_Settings__c myCS1 = RS2_SM_Configuration_Settings__c.getValues('Trigger_RS2_PrimaryNonBookedQuote');        
        if(myCS1.Active__c){       
           //Update old primary quotes and Update Opportunity as per primary quote value
            RS2_PrimaryQuoteUtilityClass.primaryQuoteTriggerHelper((List<Renewal_Quote__c>)Trigger.new, (Map<Id,Renewal_Quote__c>)Trigger.OldMap);
           //RS2_PrimaryQuoteUtilityClass.primaryQuoteTriggerHelper();        //Commented for   CR-00134345.
        }        
        RS2_IncumbentResellerdistributor createquote = new RS2_IncumbentResellerdistributor();
        List<Renewal_Quote__C> updatedQuoteList = new List<Renewal_Quote__C>();
        if(trigger.isInsert && trigger.isAfter){ 
         
            createquote.updateMultiplePartnersonQuotecreate(trigger.new);
            System.debug('trigger.new***'+trigger.new);
            // Below Code Added by Swasti for New CR :00131830 (QPA for Reactive Quotes)
            if (RS2_Quoting__c.getInstance('ReactiveQuoteInsert').value__C =='TRUE'){
            RS2_QPAforReactiveQuotes.CreateQPAReactiveQuotes(trigger.new);
            }
            //******Added new Class for IBS-73 && IBS-366 *******START******//  
                RS2_RenewalQuoteAfterInsert.quoteEndDateAfterInsert(trigger.new,true);
                RS2_RenewalQuoteAfterInsert.currecyChangeAfterInsert(trigger.new); 
            //******Added new Class for IBS-73 && IBS-366 *******END******//
        }
        if(trigger.isUpdate && trigger.isBefore){
            RS2_CompetingResellerUtil.infoCDSStatusUpdate(trigger.new,trigger.oldMap);
        }
        //Below Code Added by Ravi for New CR :00131830 (QPA for Reactive Quotes) - Start
        if(trigger.isUpdate && trigger.isAfter){
            if (RS2_Quoting__c.getInstance('ReactiveQuoteUpdate').value__C =='TRUE'){
                for(Renewal_Quote__C updatedQuote:Trigger.New){
                    if (RS2_Quoting__c.getInstance('Reactivequoteuser').value__C.contains(UserInfo.getUserId())){
                        updatedQuoteList.add(updatedQuote);
                    }
                }
                if(!updatedQuoteList.isEmpty()){
                    RS2_QPAforReactiveQuotes.CreateQPAReactiveQuotes(updatedQuoteList);
                }
                
            }
            //******Added new Class for IBS-73 *******START******//  
            RS2_RenewalQuoteAfterInsert.quoteEndDateAfterInsert(trigger.new,false);
            //******Added new Class for IBS-73 *******END******//
            createquote.updateMultiplePartnersonQuotecreate(trigger.new);
        }
        //Below Code Added by Ravi for New CR :00131830 (QPA for Reactive Quotes) - End
        //Check the trigger status 
    }
    catch(Exception ex){
        CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexTrigger', 'RS2_PrimaryNonBookedQuote', 'RS2_PrimaryNonBookedQuote');
    }   
}