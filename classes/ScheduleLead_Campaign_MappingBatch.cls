/*********************************************************************************************************
Apex Class   :                 ScheduleLead_Campaign_MappingBatch
Created By   :                 Accenture
Created Date :                 02 - FEB- 2016
Release Date :                 04 - MARCH- 2016
Description  :                 CR-00137430 - Scheduler for Lead_Campaign_MappingBatch .
*********************************************************************************************************/
//************************Version Updates***********************************************************************
//Prateek          23-08-2016    Added Logic for merging multiple schedulers.
//***************************************************************************************************************    
global class ScheduleLead_Campaign_MappingBatch implements Schedulable {
    
    global void execute(SchedulableContext SC){
        
        Id cronTrigId = SC.getTriggerId();    
        Integer concurrentBatchCount = BatchJobUtility.getConcurrentBatchCount();
        if ((!Test.isRunningTest() && concurrentBatchCount < 100) || (Test.isRunningTest() && concurrentBatchCount < 2)){
            Database.executebatch(new Lead_Campaign_MappingBatch(),Integer.valueOf(Label.lead_campaign_Mapping_batch_size));//Commented for reducing schedule jobs - Prateek            
        }/**else{
            try{
            
                DateTime timeNow = System.now();        
                timeNow = timeNow.addMinutes(Integer.valueOf(Label.Lead_Campaign_batch_schedule_string));
                String chron_Str = '' + timeNow.second() + ' ' + timeNow.minute() + ' * * * ?';
                System.abortJob(cronTrigId);                 
                System.schedule('Lead campaign mapping'+system.now(), chron_Str, new ScheduleLead_Campaign_MappingBatch());
            }Catch(AsyncException ex){
            }
        }**/
    }
}