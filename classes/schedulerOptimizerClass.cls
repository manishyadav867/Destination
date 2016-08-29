//***********************************************************************************
// Description : This class used to Merge multiple Schedulers.
// Author      : Pritesh Soni    
// Date        : 8/Aug/2016
// Parameters  : String SchedulingJobName,Integer MinutesToScheduleTheJob,String SchedulerCLassName
// ***********************************************************************************

public class schedulerOptimizerClass{
    //START:Added Method to reduce no of schedulers -Pritesh
    public static void schedulerMethod(String jobName,Integer minsToSchedule,String SchedulerClassName){        
        String BatchText='';
        String geoSpecificCronExp='';
        Integer toSchedule=0;
        List<CronTrigger> cronTriggerName = new List<CronTrigger>();
        if(!Test.isRunningTest()){
            if(!String.isBlank(jobName)){cronTriggerName=[SELECT CronExpression,CronJobDetailId,CronJobDetail.Name,Id,CronJobDetail.jobType FROM CronTrigger where CronJobDetail.jobType='7' and CronJobDetail.Name =:jobName];
            }
            if(cronTriggerName!= null && !cronTriggerName.isEmpty()){
                for(CronTrigger ct : cronTriggerName){
                    system.abortJob(ct.Id);
                }
            }
        }
        BatchText = String.valueof(system.now());
        BatchText = BatchText.substring(14,16);
        toSchedule = Integer.valueof(BatchText) + minsToSchedule ;
        if( toSchedule >= 60){
            toSchedule = toSchedule - 60;
        }
        List<ApexClass> apexClassList;
        String schedulerName='';
        if(!String.isBlank(SchedulerClassName)){
            apexClassList = [SELECT Name,NameSpacePrefix FROM ApexClass WHERE Name =:SchedulerClassName];
        }
        for(ApexClass ac:apexClassList){
            if(String.isBlank(ac.NameSpacePrefix)){
                schedulerName=ac.Name;
            }
        }
        Type t = Type.forName(schedulerName); 
        geoSpecificCronExp='0 '+toSchedule+' * * * ?';
        if(!Test.isRunningTest()){System.schedule(jobName,geoSpecificCronExp,(Schedulable)t.newInstance());
        }
        //END:Added logic merging multiple schedulers -Pritesh
    }   
}