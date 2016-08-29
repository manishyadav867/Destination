/***************************
Class Name: GSS_EscalationHistoryController
Description: Controller for GSS_EscalationRequest_History.
Author: Accenture(Jyolsna)
Created Date: 5-Aug-2016
CR: CR-00140215
*****************************/
public class GSS_EscalationHistoryController {
    public Id requestId;
    public Integer totalSize;
    public Map<Integer,List<EscalationHistWrapper>> mapPageNumlstHis;
    public List<EscalationHistWrapper> requestHistList{get;set;}
    public Integer numberOfpages;
    public Integer currentPageNumber{get;set;}
    public Integer pageSize{get;set;}
    public List<SelectOption> lstPageSize{get;set;}
    public String LongTextArea = 'Long Text Area';
    public GSS_EscalationHistoryController(ApexPages.StandardController controller) {
        requestId = ApexPages.currentPage().getParameters().get('Id');
        pageSize = 50;   
        lstPageSize = new List<SelectOption>();
        lstPageSize.add(new SelectOption('50','50'));
        lstPageSize.add(new SelectOption('100','100'));
        lstPageSize.add(new SelectOption('150','150'));
        lstPageSize.add(new SelectOption('200','200'));
        doChangePageSize();
    }
    
    public void buildPagination(List<EscalationHistWrapper> wrapList){
        totalSize = wrapList.size();
        List<EscalationHistWrapper> lstMapWrapperHistory = new List<EscalationHistWrapper>();
        mapPageNumlstHis = new Map<Integer,List<EscalationHistWrapper>>();
        Integer numberOfpages = 1;
        for(EscalationHistWrapper histWrap : wrapList){
            lstMapWrapperHistory.add(histWrap);
            if(lstMapWrapperHistory.size() == Integer.valueOf(pageSize)){
                mapPageNumlstHis.put(numberOfpages,lstMapWrapperHistory);
                lstMapWrapperHistory = new List<EscalationHistWrapper>();
                numberOfpages++;
            }
        }
        
        if(lstMapWrapperHistory.size() > 0){
            mapPageNumlstHis.put(numberOfpages,lstMapWrapperHistory);
        }
    }
   
    public void doNext(){
         if(currentPageNumber < mapPageNumlstHis.size()){
            currentPageNumber++;
            requestHistList = new List<EscalationHistWrapper>();
            requestHistList = mapPageNumlstHis.get(currentPageNumber);
        }
    }
    
     public void Previous(){
        if(currentPageNumber != 1){
            currentPageNumber--;
            requestHistList = new List<EscalationHistWrapper>();
            requestHistList = mapPageNumlstHis.get(currentPageNumber);
        }
    }
    
    public class EscalationHistWrapper implements Comparable{
        public String createdDate{get; set;}
        public String Name{get; set;}
        public Id requestId{get;set;}
        
        public EscalationHistWrapper(String createdDate, String name, Id reqId){
            this.createdDate = createdDate;
            this.Name = Name;
            this.requestId = reqId;
        }
          public Integer compareTo(Object compareTo)
        {
            EscalationHistWrapper other = (EscalationHistWrapper) compareTo;
            if (this.createdDate < other.createdDate)
                return 1;
            else if (this.createdDate == other.createdDate)
                return 0;
            return -1;
        }
    }
     public Boolean getDisablePrevious(){
        if(currentPageNumber>1){
            return false;
        }
        else{
            return true;
        }
    }
    public Boolean getDisableNext(){
        if(currentPageNumber < mapPageNumlstHis.size()){
            return false;
        }
        else{
            return true;
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
    public void doChangePageSize(){
        List<EscalationHistWrapper> wrapList = new List<EscalationHistWrapper>();
        List<GSS_Request__History> reqHistList = new List<GSS_Request__History>();
        List<ObjectHistoryTracker__c > nontrackableHistList = new List<ObjectHistoryTracker__c >();
        List<Action_History__c> lstCommHistory = new List<Action_History__c>();
        set<String> trackableFieldSet = new Set<String>();
        set<String> nonTrackableFieldSet = new Set<String>();
        Map<String,String> apiNameandLabelMap = new Map<String,String>();
        List<HistoryTrackingSetting__c> fieldList = new List<HistoryTrackingSetting__c>();
        String oldVal,newVal,action,createdDateStr;
        String objApiName = 'GSS_Request__c';
        
        fieldList = [select id,FieldLabel__c,ApiFieldName__c,DataType__c,Object__c from HistoryTrackingSetting__c where Object__c =: objApiName];
        
        if(fieldList != null && !fieldList.isEmpty()){
            for(HistoryTrackingSetting__c hT: fieldList){
                if(hT.DataType__c.contains(LongTextArea)){
                    nonTrackableFieldSet.add(ht.ApiFieldName__c);
                }
                else{
                    trackableFieldSet.add(ht.ApiFieldName__c);
                }
                apiNameandLabelMap.put(ht.ApiFieldName__c,ht.FieldLabel__c);
            } 
        }
        if(requestId != null){
            reqHistList = [select Field, CreatedById,CreatedBy.Name, CreatedDate, NewValue, OldValue from GSS_Request__History where Field in: trackableFieldSet and ParentId =:requestId ORDER BY CreatedDate DESC];
            nontrackableHistList  = [SELECT Id,Name,ObjectId__c,Object__c, Field__c, NewValueLong__c, OldValueLong__c, CreatedDate, CreatedById, CreatedBy.Name FROM ObjectHistoryTracker__c WHERE ObjectId__c =:requestId AND Object__c =:objApiName ORDER BY CreatedDate DESC];
            lstCommHistory = [Select Id,Name,Action__c,Details_Subset__c,CreatedDate,Details__c, CreatedBy.Name,From_Address__c,To_Address__c,CC_Address__c,BCC_Address__c,Subject__c FROM Action_History__c WHERE Request__c =: requestId Order By Name asc];
            totalSize = reqHistList.size()+nontrackableHistList.size()+lstCommHistory.size();
            if(reqHistList != null && !reqHistList.isEmpty()){
                for(GSS_Request__History reqHist: reqHistList){
                    if(reqHist.field == 'Owner'){
                            if(!((String.valueOf(reqHist.oldvalue) != null && (String.valueOf(reqHist.oldvalue).startswith('005') || String.valueOf(reqHist.oldvalue).startswith('00G'))) || 
                            (String.valueOf(reqHist.newvalue) != null && (String.valueOf(reqHist.newvalue).startswith('005') || String.valueOf(reqHist.newvalue).startswith('00G'))))){
                                oldVal = String.valueOf(reqHist.OldValue);
                                newVal = String.valueOf(reqHist.NewValue);
                                action = '<b>'+reqHist.CreatedBy.Name+'<br/>'+ apiNameandLabelMap.get(reqHist.Field)+' Changed </b><br/>' +'from '+ oldVal  +' to '+newVal;
                                createdDateStr = reqHist.createdDate.format('MM/dd/yyyy HH:mm a');
                                wrapList.add(new EscalationHistWrapper(createdDateStr,action,requestId));  
                            }
                    }
                    else{
                        oldVal = String.valueOf(reqHist.OldValue);
                        newVal = String.valueOf(reqHist.NewValue);
                        action =  '<b>'+reqHist.CreatedBy.Name+'<br/>'+ apiNameandLabelMap.get(reqHist.Field)+' Changed </b><br/>' +'from '+ oldVal  +' to '+newVal;
                        createdDateStr = reqHist.createdDate.format('MM/dd/yyyy HH:mm a');
                        wrapList.add(new EscalationHistWrapper(createdDateStr,action,requestId));
                    }
                }
            }
            if(nontrackableHistList != null && !nontrackableHistList.isEmpty()){
                for(ObjectHistoryTracker__c objHist: nontrackableHistList){
                    oldVal = String.valueOf(objHist.OldValueLong__c);
                    newVal = String.valueOf(objHist.NewValueLong__c);
                    action =  '<b>'+objHist.CreatedBy.Name+'<br/>'+ apiNameandLabelMap.get(objHist.Field__c)+' Changed </b><br/>' +'from '+ oldVal  +' to '+newVal;
                    createdDateStr = objHist.createdDate.format('MM/dd/yyyy HH:mm a');
                    wrapList.add(new EscalationHistWrapper(createdDateStr,action,requestId));
                }
            }
            if(lstCommHistory != null && !lstCommHistory.isEmpty()){
                for(Action_History__c actHist: lstCommHistory){
                    action =  '<b>From:</b>'+((actHist.From_Address__c==Null)?'':actHist.From_Address__c)+'</br>'+
                                '<b>To:</b>'+((actHist.To_Address__c==Null)?'':actHist.To_Address__c)+'</br>'+
                                '<b>CC:</b>'+((actHist.CC_Address__c==Null)?'':actHist.CC_Address__c)+'</br>'+
                                '<b>BCC:</b>'+((actHist.BCC_Address__c==Null)?'':actHist.BCC_Address__c)+'</br>'+
                                '<b>Subject:</b>'+((actHist.Subject__c==Null)?'':actHist.Subject__c)+'</br>'+
                                '<b>Details:</b>'+((actHist.Details__c== null) ? '' : actHist.Details__c )+'</br>';
                    createdDateStr = actHist.createdDate.format('MM/dd/yyyy HH:mm a');
                    wrapList.add(new EscalationHistWrapper(createdDateStr,action,requestId));
                }
            }
            if(!wrapList.isEmpty()){
                wrapList.sort();
                buildPagination(wrapList);
                currentPageNumber = 0;
                doNext();
            }
            
        }
    }
}