/************************************************************************************
* Name             : RS2_StabilizationUtility
* Description      : RS2 Stabilization - CR-00135665,CR-00138229
* Created By       : Varsha Chougule (Accenture)
* Created Date     : 23rd Feb 2016
*************************************************************************************
* Date          Change-Request          Modified By             Description    
*************************************************************************************
* 4th Aug 2016   IBS-367            Nilanjana Mukherjee       Update Source-Case Status='Open' When Ad-hoc Case Status='On-Hold'
*************************************************************************************/
public class RS2_StabilizationUtility
{
    /*
        Method : processQuoteRequest
        Description : RS2_callEBSWebservice.callEBSWebService is called and passing list of Case
    */
    public static void processQuoteRequest(List<Case> quoteRequestList)
    {
        List<Case> sourceQuoteRequestList = validateQuoteRequest(quoteRequestList);
        Set<id> stagingIdSet = createStagingRecords(sourceQuoteRequestList);
        List<RS2_Opportunity_Case_Staging__c> stagingList = new List<RS2_Opportunity_Case_Staging__c>();
        Map<id,Set<id>> caseStagingIdMap = new Map<id,Set<id>>();
        Integer maxLimit=integer.valueof(RS2_Stabilization_Config_Setting__c.getInstance('Max_Limit')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Max_Limit').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Max_Limit').Value__c:'50');
        Integer count=0;
       
        if(!stagingIdSet.isEmpty())
        {
            stagingList = [SELECT id, Source_Case_Number__c FROM RS2_Opportunity_Case_Staging__c WHERE id IN : stagingIdSet];
            if(!stagingList.isEmpty())
            {
                for(RS2_Opportunity_Case_Staging__c stagingRec : stagingList)
                {
                    if(!caseStagingIdMap.isEmpty() && caseStagingIdMap.containsKey(stagingRec.Source_Case_Number__c))
                    {
                        caseStagingIdMap.get(stagingRec.Source_Case_Number__c).add(stagingRec.id);
                    }
                    else
                    {
                        caseStagingIdMap.put(stagingRec.Source_Case_Number__c, new Set<id>{stagingRec.id});
                    }
                }
            }
            if(!caseStagingIdMap.isEmpty())
            {
                for(id caseId : caseStagingIdMap.keySet())
                {                    
                    if(caseStagingIdMap.get(caseId)!=null)
                    {
                        if(count < maxLimit)
                        {
                            RS2_callEBSWebservice.callEBSWebService(caseStagingIdMap.get(caseId));
                        }                       
                    }
                    count=count+1;
                }
            }
        }
    }
    /*
        Method : validateQuoteRequest
        Description :  passing list of Case and returning Source Quote Request list
    */
    public static List<Case> validateQuoteRequest(List<Case> quoteRequestList)
    {
        String renewalOperationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
        String requestType =(RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Request Type')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Request Type').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Request Type').Value__c:'Single Quote,Quote Consolidation');
        String requestSubType =(RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Reques Sub Type')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Reques Sub Type').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Reques Sub Type').Value__c:'New,Revision');
        String origin = (RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Origin')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Origin').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Origin').Value__c:'RCM,VMSTAR');
        
        List<Case> sourceQuoteRequestList = new List<Case>();
        
        if(!quoteRequestList.isEmpty())
        {
            for(case quoteRequest : quoteRequestList)
            {
                if(quoteRequest.recordTypeId == renewalOperationRecordType && quoteRequest.Request_Type__c!=null && requestType.contains(quoteRequest.Request_Type__c) && quoteRequest.Request_Sub_Type__c!=null && requestSubType.contains(quoteRequest.Request_Sub_Type__c) && quoteRequest.Origin!=null && origin.contains(quoteRequest.Origin))
                {
                    sourceQuoteRequestList.add(quoteRequest);
                }
            }
        }
        return sourceQuoteRequestList;
    }
    /*
        Method :        createStagingRecords
        Description :   inserting Case Staging Record
    */
    public static set<Id> createStagingRecords(List<Case> quoteRequestList)
    {
        Set<Id> stagingIdSet = new Set<Id>();
        String newStatus=(RS2_Stabilization_Config_Setting__c.getInstance('Opportunity Case Staging Status - New')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Opportunity Case Staging Status - New').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Opportunity Case Staging Status - New').Value__c:'New');
       
       if(quoteRequestList!=null && !quoteRequestList.isEmpty())
        {
            List<RS2_Opportunity_Case_Staging__c> caseStagingList = new List<RS2_Opportunity_Case_Staging__c>();
            RS2_Opportunity_Case_Staging__c caseStagingRecord;
            List<String> contractNumberList = new List<String>();
            for(case quoteRequest : quoteRequestList)
            {
                if(quoteRequest.Vmware_Contract_Number__c != null)
                {
                    contractNumberList = quoteRequest.Vmware_Contract_Number__c.split(',');
                    for(String contractNumber : contractNumberList)
                    {
                        caseStagingRecord = new RS2_Opportunity_Case_Staging__c();
                        caseStagingRecord.Source_Case_Number__c = quoteRequest.id;
                        caseStagingRecord.Source_Contract_Number__c = contractNumber;
                        caseStagingRecord.Status__c = newStatus ;
                        //RS2_Stabilization_Config_Setting__c.getInstance('Opportunity Case Staging Status - New').Value__c;
                        caseStagingList.add(caseStagingRecord);
                    }
                }
            }
            if(!caseStagingList.isEmpty())
            {
                list<Database.SaveResult> srList = Database.Insert(caseStagingList);
                if(srList!=null && !srList.isEmpty())
                {
                    for(Database.SaveResult sr : srList)
                    {
                        if(sr.isSuccess())
                        {
                            stagingIdSet.add(sr.getId());
                        }
                    }
                }
            }
        }
        return stagingIdSet;
    }
    /*
        Method :        updateQuoteRequestToWorking
        Description :   Updating status='Open/Working'
    */
    public static void updateQuoteRequestToWorking(List<Case> quoteRequestList)
    {
        if(!quoteRequestList.isEmpty())
        {
            String renewalOperationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
            String requestType = (RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Request Type')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Request Type').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Request Type').Value__c:'Single Quote,Quote Consolidation');
            String requestSubType = (RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Reques Sub Type')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Reques Sub Type').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Reques Sub Type').Value__c:'New,Revision');
            String origin = (RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Origin')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Origin').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Quote Request - Origin').Value__c:'RCM,VMSTAR');
            String openworkingstatus=(RS2_Stabilization_Config_Setting__c.getInstance('Case Status - Open/Working')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Status - Open/Working').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Status - Open/Working').Value__c:'Open/Working');
            for(case quoteRequest : quoteRequestList)
            {
                if(quoteRequest.recordTypeId == renewalOperationRecordType && quoteRequest.Request_Type__c!=null && requestType.contains(quoteRequest.Request_Type__c) && quoteRequest.Request_Sub_Type__c!=null && requestSubType.contains(quoteRequest.Request_Sub_Type__c) && quoteRequest.Origin!=null && origin.contains(quoteRequest.Origin))
                {
                    quoteRequest.status = openworkingstatus;
                    //RS2_Stabilization_Config_Setting__c.getInstance('Case Status - Open/Working').Value__c
                }
            }
        }
    }
    /*
        Method :        updateQuoteRequestToOpen
        Description :   Updating status='Open'
    */
    public static void updateQuoteRequestToOpen(List<Case> opptyRequestList, Map<id,Case> oldCaseMap)
    {
        String renewalOperationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();   
        List<RS2_Opportunity_Case_Staging__c> stagingList = new List<RS2_Opportunity_Case_Staging__c>();
        Set<id> opptyRequestIdSet = new Set<id>();
        if(!opptyRequestList.isEmpty())
        {
            for(case opptyRequest : opptyRequestList)
            {
                if(opptyRequest.recordTypeId == renewalOperationRecordType && opptyRequest.status != null && opptyRequest.status.contains('Closed') && oldCaseMap.get(opptyRequest.id).status != opptyRequest.status)
                {
                    opptyRequestIdSet.add(opptyRequest.id);
                }
            }
        }
        if(!opptyRequestIdSet.isEmpty())
        {
            stagingList = [SELECT id, Source_Case_Number__c, Source_Case_Number__r.status, Source_Case_Number__r.Sub_Status__c,Source_Case_Number__r.ownerId, Source_Case_Number__r.owner.name FROM RS2_Opportunity_Case_Staging__c WHERE Target_Case__c IN : opptyRequestIdSet OR Existing_Target_Case__c IN : opptyRequestIdSet];
            
            Case caseRec;
            Map<id,Case> quoteRequestMap = new Map<id,Case>();
            String pdsapi=(RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c:'PDS API');
            String onHold=(RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c:'On Hold');
            String statusvar=RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c;
            if(!stagingList.isEmpty())
            {
                for(RS2_Opportunity_Case_Staging__c stagingRecord : stagingList)
                {
                    //if(stagingRecord.Source_Case_Number__r.ownerId != null && stagingRecord.Source_Case_Number__r.owner.name == RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c && stagingRecord.Source_Case_Number__r.status == RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c)
                    if(stagingRecord.Source_Case_Number__r.ownerId != null && stagingRecord.Source_Case_Number__r.owner.name == pdsapi && stagingRecord.Source_Case_Number__r.status == onHold)
                    {
                        caseRec = new Case();
                        caseRec.id = stagingRecord.Source_Case_Number__c;
                        //caseRec.status = RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c;
                        caseRec.status = statusvar;
                        caseRec.Sub_Status__c = null;
                        quoteRequestMap.put(caseRec.id, caseRec);
                    }
                }
                if(!quoteRequestMap.isEmpty() && quoteRequestMap.values().size()>0)
                {
                    recursive.updateCaseStatusHistoryExecuted = false;
                    Database.SaveResult[] srList = Database.update(quoteRequestMap.values(),false);
                }
            }
        }
    }
    /*
        Author :        Nilanjana
        Method :        UpdateSourceToOpen
        Description :   Updating status='Open' on Source Case When its Ad-hoc Case is Updated to Status='On-Hold'
    */
    public static void UpdateSourceToOpen(List<Case> opptyRequestList, Map<id,Case> oldCaseMap)
    {
        
        String onHold=(RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c:'On Hold');
        
        String pdsapi=(RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c:'PDS API');
           
        String statusvar=(RS2_Stabilization_Config_Setting__c.getInstance('Case Status')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c:'Open');
        
        String SingleQuote=(RS2_Stabilization_Config_Setting__c.getInstance('Case Single Quote')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Single Quote').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Single Quote').Value__c:'Single Quote');
        
        String Consolidation=(RS2_Stabilization_Config_Setting__c.getInstance('Case Quote Consolidation')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Quote Consolidation').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Quote Consolidation').Value__c:'Quote Consolidation');
        
        String NewCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case New')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c:'New');
        
        String RevisionCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case Revision')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c:'Revision');
        
        String InternalComment=(RS2_Stabilization_Config_Setting__c.getInstance('Case Internal Comment')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Internal Comment').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Internal Comment').Value__c:'Case has been routed for manual quoting as Adhoc Case has been placed On Hold');
        
        String CaseRecordTypeId=(RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c:'0128000000044mWAAQ');
        
        //String renewalOperationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();   
        
        List<RS2_Opportunity_Case_Staging__c> stagingList = new List<RS2_Opportunity_Case_Staging__c>();
        Set<id> opptyRequestIdSet = new Set<id>();
        
        if(!opptyRequestList.isEmpty())
        {
            for(case opptyRequest : opptyRequestList)
            {
                if(opptyRequest.recordTypeId == CaseRecordTypeId && opptyRequest.Request_Type__c=='Ad-Hoc Opportunity Load' && opptyRequest.status != null && opptyRequest.status.contains(onHold) && oldCaseMap.get(opptyRequest.id).status != opptyRequest.status)
                {
                    opptyRequestIdSet.add(opptyRequest.id);
                }
            }
        }
        if(!opptyRequestIdSet.isEmpty())
        {
            stagingList = [SELECT id, Source_Case_Number__c, Source_Case_Number__r.status, Source_Case_Number__r.Sub_Status__c,Source_Case_Number__r.ownerId, Source_Case_Number__r.owner.name,Source_Case_Number__r.Request_Type__c,Source_Case_Number__r.Request_Sub_Type__c,Source_Case_Number__r.Internal_Comments__c FROM RS2_Opportunity_Case_Staging__c WHERE Target_Case__c IN : opptyRequestIdSet OR Existing_Target_Case__c IN : opptyRequestIdSet];
            
            Case caseRec;
            Map<id,Case> quoteRequestMap = new Map<id,Case>();
           
            if(!stagingList.isEmpty())
            {
                for(RS2_Opportunity_Case_Staging__c stagingRecord : stagingList)
                {
                     if(stagingRecord.Source_Case_Number__c!=null && (stagingRecord.Source_Case_Number__r.Request_Type__c==SingleQuote || stagingRecord.Source_Case_Number__r.Request_Type__c==Consolidation) && (stagingRecord.Source_Case_Number__r.Request_Sub_Type__c==NewCase || stagingRecord.Source_Case_Number__r.Request_Sub_Type__c==RevisionCase) && stagingRecord.Source_Case_Number__r.ownerId != null && stagingRecord.Source_Case_Number__r.owner.name == pdsapi && stagingRecord.Source_Case_Number__r.status == onHold )
                    {
                        caseRec = new Case();
                        caseRec.id = stagingRecord.Source_Case_Number__c;
                        caseRec.status = statusvar;
                        caseRec.Sub_Status__c = null;
                        quoteRequestMap.put(caseRec.id, caseRec);
                    }
                }
                if(!quoteRequestMap.isEmpty() && quoteRequestMap.values().size()>0)
                {
                    Database.SaveResult[] srList = Database.update(quoteRequestMap.values(),false);
                }
            }
        }
    }    
}