/***************************
Class Name: GSS_RequestHistoryController
Description: Controller for GSS_RequestHistoryComponent.
Author: Accenture(Jyolsna)
Created Date: 2-Aug-2016
CR: CR-00140215
*****************************/
public class GSS_RequestHistoryController{
    public string historyLimit = 'GSS_History_Limit';
    public Id RecordId {get;set;}
    public string ObjectName {get;set;}
    public Integer totalSize;
    public Integer counter = 0;
    public Integer pageSize;
    GSS_Configuration_Properties_list__c cpl= GSS_Configuration_Properties_list__c.getValues(historyLimit);{
        if(cpl!= null){
            pageSize = Integer.valueof(cpl.Setting_value__c);
        }
        else{
           pageSize = 5;
        }
    }
 
    public List<ObjectHistoryTracker__c> requestHistList{
        get{
            return getrequestHistList(RecordId);
        }
    }
    public GSS_RequestHistoryController(){
        
    }
    
    public List<ObjectHistoryTracker__c> getrequestHistList(Id RecordId){
        List<ObjectHistoryTracker__c> historyList = new List<ObjectHistoryTracker__c>();
        List<ObjectHistoryTracker__c> totalHistoryList = new List<ObjectHistoryTracker__c>();
        List<GSS_FieldHistoryTrack__c> fieldTrackList = GSS_FieldHistoryTrack__c.getall().values();
        Set<String> fieldNameSet = new Set<string>();
        if(fieldTrackList != null && !fieldTrackList.isEmpty()){
            for(GSS_FieldHistoryTrack__c fieldVal:fieldTrackList){
                if(fieldVal.Object__c == ObjectName){
                    fieldNameSet.add(fieldVal.FieldApi__c);
                }
            }
        }
        if(RecordId != null){
            String query1 = 'SELECT Id,Name,ObjectId__c,Object__c, Field__c, NewValueLong__c, OldValueLong__c, CreatedDate, CreatedById, CreatedBy.Name FROM ObjectHistoryTracker__c WHERE ObjectId__c Like \''+RecordId+'\'AND Object__c Like \''+ObjectName +'\'AND Field__c IN:fieldNameSet ORDER BY CreatedDate DESC, Id DESC' ;
            String setOffset = ' LIMIT :pageSize OFFSET :counter';
            String query2 = query1+setOffset;
            totalHistoryList = Database.Query(query1);
            historyList = Database.Query(query2);
            totalSize = totalHistoryList.size();
        }
        return historyList;
    }
     public PageReference next(){
        counter+=pageSize;
        return null;
    }
    
    public PageReference previous(){
        counter-=pageSize;
        return null;
    }
    
    public Boolean getDisablePrevious(){
        if(counter>0){
            return false;
        }
        else{
            return true;
        }
    }
    public Boolean getDisableNext(){
        if(counter+pageSize < totalSize){
            return false;
        }
        else{
            return true;
        }
    }
    
    public Integer getpageNumber(){
        if(totalSize == 0){
            return 0;
        }
        else{
            return counter/pageSize + 1;
        }
    }
    
    public Integer gettotalPages(){
        if(math.mod(totalSize,pageSize) > 0){
            return (totalSize/pageSize) + 1;
        }
        else{
            return totalSize/pageSize;
        }
    }
    
}