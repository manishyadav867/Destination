/************************************************************************************
* Name             : RS2_QuoteRequestProcessing
* Description      : RS2 Stabilization - CR-00135665, CR-00138229
* Created By       : Varsha Chougule (Accenture)
* Created Date     : 24th Feb 2016
*************************************************************************************
* Date         Change-Request          Modified By                    Description
*************************************************************************************
* BUG-00145189   Author:Nilanjana Mukherjee(Accenture)  Date: March 4,2016
* IBS-369        Author:Soumya Behera (Accenture)       Date: August 10,2016
*************************************************************************************/
public class RS2_QuoteRequestProcessing
{
    public static Map<String,Opportunity> opptyIDAndOpptyRecMap = new Map<String,Opportunity>();
    public static Map<Decimal,List<Opportunity>> contractIDAndOpptyRecMap = new Map<Decimal,List<Opportunity>>();
    public static Map<String,List<Opportunity>> contractNumAndOpptyRecMap = new Map<String,List<Opportunity>>();
    public static Map<Decimal, RS2_Opportunity_Case_Staging__c> contractIdCaseMap = new Map<Decimal,RS2_Opportunity_Case_Staging__c>();
    //public static period periodRec = new period();
    
    public static Map<id,List<RS2_Opportunity_Case_Staging__c>> caseIdValidStagingRecMap = new map<id,List<RS2_Opportunity_Case_Staging__c>>();
    public static Map<id,List<RS2_Opportunity_Case_Staging__c>> caseIdNotFoundStagingRecMap = new map<id,List<RS2_Opportunity_Case_Staging__c>>();
    public static Map<id,List<RS2_Opportunity_Case_Staging__c>> caseIdInvalidStagingRecMap = new map<id,List<RS2_Opportunity_Case_Staging__c>>();
    /*
        Method : processResponse
        Description : preparing staging record.
    
    */
    public static void processResponse(List<RS2_callEBSWebservice.contractDetails> responseList, Map<id,RS2_Opportunity_Case_Staging__c> stagingRecMap, Map<id,Case> caseMap, String requestStr, String responseStr)
    {
       
        String stagingIdStr = '';
        RS2_Opportunity_Case_Staging__c stagingRec = new RS2_Opportunity_Case_Staging__c();
        Map<id,Map<id,RS2_Opportunity_Case_Staging__c>> caseIdStagingMap = new Map<id,Map<id,RS2_Opportunity_Case_Staging__c>>();
        Set<String> opptyIDSet = new Set<String>();
        set<Decimal> contractIDSet = new set<Decimal>();
        Decimal contractIdWithLatestEndDate;
        DateTime latestEndDate;
        set<String> contractNumSet = new set<String>();
        for(RS2_callEBSWebservice.contractDetails response : responseList)
        {
            stagingIdStr = response.stagingId;
            stagingRec = stagingRecMap.get(stagingIdStr);
            if(response.contractId != null && response.contractId !='')
                stagingRec.EBS_Expiring_Contract_ID__c = Integer.ValueOf(response.contractId);
            stagingRec.EBS_Expiring_Contract_Number_and_Mod__c = response.contractNumberModifier;
            if(response.endDate!=null && response.endDate!=''){  
                stagingRec.Expiring_Contract_End_Date__c = DateTime.valueOfGMT(response.endDate.subString(0,19).replaceAll('T',' '));
                stagingRec.EBS_Expiring_Contract_End_Date__c= Date.valueOf(response.endDate.subString(0,10));
            }
            stagingRec.EBS_Opportunity_ID__c = response.OppurtuniyNumber;
            stagingRec.EBS_Exp_Contract_Flag__c = response.contractValidationFlag;
            stagingRec.EBS_Error_Message__c = response.validationMessage;
            stagingRec.request__c = requestStr;
            stagingRec.response__c = responseStr;
            
            if(stagingRec.EBS_Exp_Contract_Flag__c == RS2_Stabilization_Config_Setting__c.getInstance('EBS Exp Contract Flag - Yes').Value__c)
            {
                if(stagingRec.EBS_Opportunity_ID__c != null)
                {
                    opptyIDSet.addAll(stagingRec.EBS_Opportunity_ID__c.split(','));
                }
                if(stagingRec.EBS_Expiring_Contract_ID__c != null)
                {
                    contractIDSet.add(Integer.valueOf(stagingRec.EBS_Expiring_Contract_ID__c));
                    if(stagingRec.Expiring_Contract_End_Date__c != null && latestEndDate == null)
                    {
                        latestEndDate = stagingRec.Expiring_Contract_End_Date__c;
                        contractIdWithLatestEndDate = Integer.valueOf(stagingRec.EBS_Expiring_Contract_ID__c);
                    }
                    else if(stagingRec.Expiring_Contract_End_Date__c != null && latestEndDate > stagingRec.Expiring_Contract_End_Date__c)
                    {
                        latestEndDate = stagingRec.Expiring_Contract_End_Date__c;
                        contractIdWithLatestEndDate = Integer.valueOf(stagingRec.EBS_Expiring_Contract_ID__c);
                    }
                }
                contractNumSet.add(stagingRec.Source_Contract_Number__c);
                
                If(!caseIdValidStagingRecMap.isEmpty() && caseIdValidStagingRecMap.containsKey(stagingRec.Source_Case_Number__c))
                {
                    caseIdValidStagingRecMap.get(stagingRec.Source_Case_Number__c).add(stagingRec);
                }
                else
                {
                    caseIdValidStagingRecMap.put(stagingRec.Source_Case_Number__c, new List<RS2_Opportunity_Case_Staging__c>{stagingRec});
                }
            }
            else if(stagingRec.EBS_Exp_Contract_Flag__c == RS2_Stabilization_Config_Setting__c.getInstance('EBS Exp Contract Flag - Not Found').Value__c)
            {
                If(!caseIdNotFoundStagingRecMap.isEmpty() && caseIdNotFoundStagingRecMap.containsKey(stagingRec.Source_Case_Number__c))
                {
                    caseIdNotFoundStagingRecMap.get(stagingRec.Source_Case_Number__c).add(stagingRec);
                }
                else
                {
                    caseIdNotFoundStagingRecMap.put(stagingRec.Source_Case_Number__c, new List<RS2_Opportunity_Case_Staging__c>{stagingRec});
                }
            }
            else
            {
                If(!caseIdInvalidStagingRecMap.isEmpty() && caseIdInvalidStagingRecMap.containsKey(stagingRec.Source_Case_Number__c))
                {
                    caseIdInvalidStagingRecMap.get(stagingRec.Source_Case_Number__c).add(stagingRec);
                }
                else
                {
                    caseIdInvalidStagingRecMap.put(stagingRec.Source_Case_Number__c, new List<RS2_Opportunity_Case_Staging__c>{stagingRec});
                }
            }
            if(!caseIdStagingMap.isEmpty() && caseIdStagingMap.containsKey(stagingRec.Source_Case_Number__c))
            {
                caseIdStagingMap.get(stagingRec.Source_Case_Number__c).put(stagingRec.id,stagingRec);
            }
            else
            {
                Map<id,RS2_Opportunity_Case_Staging__c> tempStagingMap = new Map<id,RS2_Opportunity_Case_Staging__c>();
                tempStagingMap.put(stagingRec.id,stagingRec);
                caseIdStagingMap.put(stagingRec.Source_Case_Number__c, tempStagingMap);
            }
        }
        getAllOpptyRecords(opptyIDSet, contractIDSet, contractNumSet);
        getAllExistingCases(contractIdWithLatestEndDate);
        processStagingRecords(caseIdStagingMap, caseMap, contractIdWithLatestEndDate);
    }
    /*
        Method : processStagingRecords
        Description : Updating staging Record
    */
    public static void processStagingRecords(Map<id,Map<id,RS2_Opportunity_Case_Staging__c>> caseIdStagingMap, Map<id,Case> caseMap, Decimal contractIdWithLatestEndDate)
    {
        List<Case> caseListToUpdate = new List<Case>();
        List<Case> caseListToInsert = new List<Case>();
        List<RS2_Opportunity_Case_Staging__c> stagingListToUpdate = new List<RS2_Opportunity_Case_Staging__c>();
        Case quoteRequest;
        Map<id,String> stagingIdOpptyIdsMap = new Map<id,String>();
        //Comment out for IBS-369 Removing Quater
        //periodRec = [SELECT number, FiscalYearSettingsId,FiscalYearSettings.name from Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER];
        Boolean isCreateCase;
        Boolean isExitingCaseFound;
        Boolean isExitingOnHoldCaseFound;
        if(!caseIdStagingMap.isEmpty())
        {
            for(Id caseId : caseIdStagingMap.keySet())
            {
                quoteRequest = new Case();
                //quoteRequest.id = caseId;
                isCreateCase = true;
                isExitingCaseFound = false;
                isExitingOnHoldCaseFound=false;
                quoteRequest = caseMap.get(caseId);
                quoteRequest.Internal_Comments__c = caseMap.get(caseId).Internal_Comments__c;
                if(caseIdValidStagingRecMap.containsKey(caseId) && !caseIdValidStagingRecMap.get(caseId).isEmpty())
                {
                    stagingIdOpptyIdsMap = getOpptyRecordsForStaging(caseIdValidStagingRecMap.get(caseId));
                    if(!stagingIdOpptyIdsMap.isEmpty())
                    {
                        isCreateCase = false;
                        String messageStr = '';
                        for(id stagingId : stagingIdOpptyIdsMap.keySet())
                        {
                            caseIdStagingMap.get(caseId).get(stagingId).VMSTAR_Opportunity_ID__c = stagingIdOpptyIdsMap.get(stagingId);
                            if(messageStr=='')
                            {
                                messageStr =  RS2_Stabilization_Config_Setting__c.getInstance('Opportunity Exist Msg Part 1').Value__c + ' ' +stagingIdOpptyIdsMap.get(stagingId);
                            }    
                            else
                            {
                                messageStr = messageStr + ',' + stagingIdOpptyIdsMap.get(stagingId);
                            }    
                        }
                        quoteRequest.Internal_Comments__c = (quoteRequest.Internal_Comments__c != null ? quoteRequest.Internal_Comments__c+',' : '') + messageStr + ' ' +RS2_Stabilization_Config_Setting__c.getInstance('Opportunity Exist Msg Part 2').Value__c;
                    }
                    else
                    {
                        for(RS2_Opportunity_Case_Staging__c stagingRec : caseIdValidStagingRecMap.get(caseId))
                        {
                            if(contractIdCaseMap.containsKey(stagingRec.EBS_Expiring_Contract_ID__c))
                            {
                                isCreateCase = false;
                                isExitingCaseFound = true;
                                
                                if(contractIdCaseMap.get(stagingRec.EBS_Expiring_Contract_ID__c).Target_Case__r.Status=='On Hold'){
                                    isExitingOnHoldCaseFound = true;
                                }
                                
                                caseIdStagingMap.get(caseId).get(stagingRec.id).Existing_Target_Case__c = contractIdCaseMap.get(stagingRec.EBS_Expiring_Contract_ID__c).Target_Case__c;
                                
                                quoteRequest.Internal_Comments__c = (quoteRequest.Internal_Comments__c != null ? quoteRequest.Internal_Comments__c+',' : '') + RS2_Stabilization_Config_Setting__c.getInstance('Case Exist Msg Part 1').Value__c +' ' + contractIdCaseMap.get(stagingRec.EBS_Expiring_Contract_ID__c).Target_Case__r.caseNumber + ' ' +RS2_Stabilization_Config_Setting__c.getInstance('Case Exist Msg Part 2').Value__c;
                            }
                        }
                    }
                }
                if(caseIdNotFoundStagingRecMap.containsKey(caseId) && !caseIdNotFoundStagingRecMap.get(caseId).isEmpty())
                {
                    isCreateCase = false;
                    for(RS2_Opportunity_Case_Staging__c stagingRec: caseIdNotFoundStagingRecMap.get(caseId))
                    {
                        quoteRequest.Internal_Comments__c = (quoteRequest.Internal_Comments__c != null ? quoteRequest.Internal_Comments__c+',' : '') + stagingRec.EBS_Error_Message__c;
                    }
                }
                if(caseIdInvalidStagingRecMap.containsKey(caseId) && !caseIdInvalidStagingRecMap.get(caseId).isEmpty())
                {
                    isCreateCase = false;
                    for(RS2_Opportunity_Case_Staging__c stagingRec : caseIdInvalidStagingRecMap.get(caseId))
                    {
                        quoteRequest.Internal_Comments__c = (quoteRequest.Internal_Comments__c != null ? quoteRequest.Internal_Comments__c+',' : '') + stagingRec.EBS_Error_Message__c;
                    }
                }
                if(isCreateCase)
                {
                    if(contractIdWithLatestEndDate != null)
                    {
                        for(RS2_Opportunity_Case_Staging__c stagingRec : caseIdValidStagingRecMap.get(caseId))
                        {
                            if(stagingRec.EBS_Expiring_Contract_ID__c == contractIdWithLatestEndDate)
                            {
                                caseListToInsert.add(createChildCase(caseId, stagingRec.Source_Contract_Number__c, stagingRec.EBS_Expiring_Contract_Number_and_Mod__c));
                                if(quoteRequest.ownerId != null && quoteRequest.owner.name == RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c && quoteRequest.status == RS2_Stabilization_Config_Setting__c.getInstance('Case Status - Open/Working').Value__c)
                                {
                                    quoteRequest.status = RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c;
                                    quoteRequest.Sub_Status__c = RS2_Stabilization_Config_Setting__c.getInstance('Case Sub Status - Other Internal').Value__c;
                                }
                            }
                        }
                    }
                }
                else if(isExitingCaseFound)
                {
                    if(quoteRequest.ownerId != null && quoteRequest.owner.name == RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c && quoteRequest.status == RS2_Stabilization_Config_Setting__c.getInstance('Case Status - Open/Working').Value__c)
                    {
                        if(isExitingOnHoldCaseFound)
                        {
                            quoteRequest.status ='Open';
                            quoteRequest.Sub_Status__c = ' ';
                        }
                        else{
                            quoteRequest.status = RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c;
                            quoteRequest.Sub_Status__c = RS2_Stabilization_Config_Setting__c.getInstance('Case Sub Status - Other Internal').Value__c;
                        }
                    }
                }
                else
                {
                    if(quoteRequest.ownerId != null && quoteRequest.owner.name == RS2_Stabilization_Config_Setting__c.getInstance('Case Owner - PDS API').Value__c && quoteRequest.status == RS2_Stabilization_Config_Setting__c.getInstance('Case Status - Open/Working').Value__c)
                    {
                        quoteRequest.status = RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c;
                    }
                }
                caseListToUpdate.add(quoteRequest);
            }
            if(!caseListToInsert.isEmpty() || !caseListToUpdate.isEmpty())
            {
                Database.SaveResult[] srUpdateList;
                Database.SaveResult[] srInsertList;
                if(!caseListToUpdate.isEmpty())
                {
                    srUpdateList = Database.update(caseListToUpdate,false);
                }   
                if(!caseListToInsert.isEmpty())
                {
                    srInsertList = Database.insert(caseListToInsert,false);
                }    
                Id cId;
                Database.SaveResult sr;
                if(srInsertList!= null && !srInsertList.isEmpty())
                {
                    for(integer i =0; i< srInsertList.size(); i++)
                    {
                        sr = srInsertList[i];
                        cId = caseListToInsert[i].parentId;
                        if(cId!=null && !caseIdStagingMap.get(cId).isEmpty())
                        {
                            for(Id stagingId : caseIdStagingMap.get(cId).keySet())
                            {
                                if(sr.isSuccess()) 
                                {
                                    caseIdStagingMap.get(cId).get(stagingId).Target_Case__c = caseListToInsert[i].id;
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_VMSTAR_Message__c = '';
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_Error_Message__c  = '';
                                    caseIdStagingMap.get(cId).get(stagingId).Status__c = RS2_Stabilization_Config_Setting__c.getInstance('Staging Status - VMSTAR Success').Value__c;
                                }
                                else
                                {
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_Error_Message__c  = '';
                                    caseIdStagingMap.get(cId).get(stagingId).Status__c = RS2_Stabilization_Config_Setting__c.getInstance('Staging Status - VMSTAR Error').Value__c;
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_VMSTAR_Message__c = sr.getErrors()[0].getMessage();
                                }
                            }
                        }
                    }
                }
                if(srUpdateList!=null && !srUpdateList.isEmpty())
                {
                    for(integer i =0; i< srUpdateList.size(); i++)
                    {
                        sr = srUpdateList[i];
                        cId = caseListToUpdate[i].id;
                        if(cId!=null && !caseIdStagingMap.get(cId).isEmpty())
                        {
                            for(Id stagingId : caseIdStagingMap.get(cId).keySet())
                            {   
                                if(sr.isSuccess()) 
                                {
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_VMSTAR_Message__c = '';
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_Error_Message__c  = '';
                                    caseIdStagingMap.get(cId).get(stagingId).Status__c = RS2_Stabilization_Config_Setting__c.getInstance('Staging Status - VMSTAR Success').Value__c;
                                }
                                else
                                {
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_Error_Message__c  = '';
                                    caseIdStagingMap.get(cId).get(stagingId).Status__c = RS2_Stabilization_Config_Setting__c.getInstance('Staging Status - VMSTAR Error').Value__c;
                                    caseIdStagingMap.get(cId).get(stagingId).EBS_VMSTAR_Message__c = sr.getErrors()[0].getMessage();
                                }
                            }
                        }
                    }
                }
                for(id caseId : caseIdStagingMap.keySet())
                {
                    for(Id stagingId : caseIdStagingMap.get(caseId).keySet())
                    {
                        stagingListToUpdate.add(caseIdStagingMap.get(caseId).get(stagingId));
                    }
                }
                if(!stagingListToUpdate.isEmpty())
                {
                    Database.SaveResult[] srStagingList = Database.update(stagingListToUpdate,false);
                }
            }
        }
    }
    /*
        Method : getOpptyRecordsForStaging
        Description : getting stagingIdOpptyIdsMap
    */
    public static Map<id,String> getOpptyRecordsForStaging(List<RS2_Opportunity_Case_Staging__c> stagingList)
    {
        Map<id,String> stagingIdOpptyIdsMap = new Map<id,String>();
        for(RS2_Opportunity_Case_Staging__c stagingRec : stagingList)
        {
            if(stagingRec.EBS_Opportunity_ID__c != null && getOpptyFromOpptyId(stagingRec.EBS_Opportunity_ID__c) != '')
            {
                stagingIdOpptyIdsMap.put(stagingRec.id,getOpptyFromOpptyId(stagingRec.EBS_Opportunity_ID__c));
            }
            else if(stagingRec.EBS_Expiring_Contract_ID__c != null && getOpptyFromContractId(stagingRec.EBS_Expiring_Contract_ID__c) != '')
            {
                stagingIdOpptyIdsMap.put(stagingRec.id,getOpptyFromContractId(stagingRec.EBS_Expiring_Contract_ID__c));
            }
            else if(stagingRec.Source_Contract_Number__c != null && getOpptyFromContractNum(stagingRec.Source_Contract_Number__c) != null && !String.IsBlank(getOpptyFromContractNum(stagingRec.Source_Contract_Number__c)))
            {
                stagingIdOpptyIdsMap.put(stagingRec.id,getOpptyFromContractNum(stagingRec.Source_Contract_Number__c));
            }
        }
        
        return stagingIdOpptyIdsMap;
    }
    /*
        Method : getAllOpptyRecords
        Description : getting Oppty Record
    */
    public static void getAllOpptyRecords(Set<String> opptyIDSet, set<Decimal> contractIDSet, set<String> contractNumSet)
    {
        List<String> recordTypeIDList = new List<String>();
        List<String> opptyStageList = new List<String>();
        List<Opportunity> opptyList = new List<Opportunity>();
        String recordTyepNames = RS2_Stabilization_Config_Setting__c.getInstance('Valid Opportunity Record Type').Value__c;
        String opptyStageNames = RS2_Stabilization_Config_Setting__c.getInstance('Valid Opportunity Stage').Value__c;
        
        if(recordTyepNames!=null)
        {
            for(String recordTyep : recordTyepNames.split(','))
            {
                recordTypeIDList.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTyep).getRecordTypeId());
            }
        }
        if(opptyStageNames!=null)
        {
            opptyStageList = opptyStageNames.split(',');
        }
        // Added  Where Clause in Query {ORDER BY  stagename DESC,createdDate DESC} part of IBS-369 by Soumya Behera
        if(!recordTypeIDList.isEmpty() && !opptyStageList.isEmpty())
        {
             opptyList = [SELECT id, Opportunity_ID__c, RS2_Expiring_Contract_ID__c, RS2_Expiring_Contract_Number__c,
                          RS2_Expiring_Contract_End_Date__c
                          FROM Opportunity WHERE recordTypeId IN : recordTypeIDList AND StageName IN : opptyStageList
                          AND (Opportunity_ID__c IN : opptyIDSet OR RS2_Expiring_Contract_ID__c IN : contractIDSet OR
                          RS2_Expiring_Contract_Number__c IN : contractNumSet) ORDER BY  stagename DESC,createdDate DESC];
          
            if(!opptyList.isEmpty())
            {
                for(opportunity opptyRec : opptyList)
                {
                    if(opptyRec.Opportunity_ID__c!=null && opptyIDSet.contains(opptyRec.Opportunity_ID__c))
                    {
                        opptyIDAndOpptyRecMap.put(opptyRec.Opportunity_ID__c, opptyRec);
                    }
                    if(opptyRec.RS2_Expiring_Contract_ID__c!=null && contractIDSet.contains(opptyRec.RS2_Expiring_Contract_ID__c))
                    {
                        if(!contractIDAndOpptyRecMap.isEmpty() && contractIDAndOpptyRecMap.containsKey(opptyRec.RS2_Expiring_Contract_ID__c))
                        {
                            contractIDAndOpptyRecMap.get(opptyRec.RS2_Expiring_Contract_ID__c).add(opptyRec);
                        }
                        else
                        {
                            contractIDAndOpptyRecMap.put(opptyRec.RS2_Expiring_Contract_ID__c, new List<Opportunity>{opptyRec});
                        }
                    }
                    if(opptyRec.RS2_Expiring_Contract_Number__c!=null && contractNumSet.contains(opptyRec.RS2_Expiring_Contract_Number__c))
                    {
                        if(!contractNumAndOpptyRecMap.isEmpty() && contractNumAndOpptyRecMap.containsKey(opptyRec.RS2_Expiring_Contract_Number__c))
                        {
                            contractNumAndOpptyRecMap.get(opptyRec.RS2_Expiring_Contract_Number__c).add(opptyRec);
                        }
                        else
                        {
                            contractNumAndOpptyRecMap.put(opptyRec.RS2_Expiring_Contract_Number__c, new List<Opportunity>{opptyRec});
                        }
                    }
                }
            }
        }
    }
    /*
        Method : getAllExistingCases
        Description : getting Existing Cases
    */
    public static void getAllExistingCases(Decimal contractID)
    {
        
        List<RS2_Opportunity_Case_Staging__c> stagingList = new List<RS2_Opportunity_Case_Staging__c>();
        stagingList = [SELECT id, Target_Case__c, Target_Case__r.CaseNumber,Target_Case__r.Status,
                       EBS_Expiring_Contract_ID__c, Source_Contract_Number__c FROM RS2_Opportunity_Case_Staging__c
                       WHERE EBS_Expiring_Contract_ID__c = : contractID AND Target_Case__c != null AND (NOT Target_Case__r.Status LIKE '%Closed%')];
        
        if(!stagingList.isEmpty())
        {
            for(RS2_Opportunity_Case_Staging__c stagingRec : stagingList)
            {
                contractIdCaseMap.put(stagingRec.EBS_Expiring_Contract_ID__c, stagingRec);
            }
        }
        
    }
    /*
        Method : getOpptyFromOpptyId
        Description : getting Oppty ID
    */
    public static String getOpptyFromOpptyId(String ebsOpptyId)
    {
         String opptyIds ='';
        if(ebsOpptyId!=null)
        {
            //set<String> opttySet = new set<String>();
            list<String> opptylst = new list<String>();
            if(opptyIDAndOpptyRecMap != null && !opptyIDAndOpptyRecMap.IsEmpty()){
                opptylst.addAll(opptyIDAndOpptyRecMap.keySet());
            }
            if(opptylst != null && !opptylst.IsEmpty() && ebsOpptyId.containsIgnoreCase(opptylst[0]) ){
                opptyIds = opptylst[0];
            }  
            //Commented Out for IBS-369 Removing Stamping of Same Oppty
            /*
            //opptyIds = ebsOpptyId.split(',')[0];
            for(String opptyId : ebsOpptyId.split(','))
            {
                if(opptyIDAndOpptyRecMap.containsKey(opptyId))
                {
                    if(opptyIds =='')
                    {
                        opptyIds = opptyId;
                    }    
                    else
                    {
                        opptyIds = opptyIds + ',' + opptyId;
                    }
                }
            }*/
        }
        return opptyIds;
    }
    /*
        Method : getOpptyFromContractId
        Description : getting Oppty ID using Contract Id
    */
    public static String getOpptyFromContractId(Decimal ebsContractID)
    {
        String opptyIds ='';
        if(ebsContractID!=null && contractIDAndOpptyRecMap.containsKey(ebsContractID) && !contractIDAndOpptyRecMap.get(ebsContractID).isEmpty())
        {
			if(contractIDAndOpptyRecMap.get(ebsContractID).get(0).Opportunity_ID__c != null)
				opptyIds = contractIDAndOpptyRecMap.get(ebsContractID).get(0).Opportunity_ID__c;
            //Commented Out for IBS-369 Removing Stamping of Same Oppty
           /*for(Opportunity opp : contractIDAndOpptyRecMap.get(ebsContractID))
            {
                if(opptyIds =='')
                {
                    opptyIds = opp.Opportunity_ID__c;
                }
                else
                {
                    opptyIds = opptyIds + ',' + opp.Opportunity_ID__c;
                }
            }*/
        }
        return opptyIds;
    }
    /*
        Method : getOpptyFromContractNum
        Description : getting Oppty ID using Contract Number
    */
    public static String getOpptyFromContractNum(String ebsContractNum)
    {
        String opptyIds ='';
        //Commented Out for IBS-369 Removing Quater
        /*String fiscalYearStr = periodRec.FiscalYearSettings.name;
        Decimal lastFiscalYear = Integer.valueOf(fiscalYearStr);
        Decimal lastFiscalQuarter = periodRec.number;
        Decimal opptyYear;
        Decimal opptyQuarter;
        */
        if(ebsContractNum!=null && contractNumAndOpptyRecMap.containsKey(ebsContractNum) && !contractNumAndOpptyRecMap.get(ebsContractNum).isEmpty())
        {
            for(Opportunity opp : contractNumAndOpptyRecMap.get(ebsContractNum)){
                if(opp.RS2_Expiring_Contract_End_Date__c!=null){
                    //Commented Out for IBS-369 Removing Quater 
                    /*opptyYear = opp.RS2_Expiring_Contract_End_Date__c.year();
                      opptyQuarter = (((opp.RS2_Expiring_Contract_End_Date__c.month())-1)/3)+1;
                      if(opptyYear > lastFiscalYear || (opptyYear == lastFiscalYear && opptyQuarter >= lastFiscalQuarter))
                      {
                        if(opptyIds =='')
                        {
                            opptyIds = opp.Opportunity_ID__c;
                        }
                        else
                        {
                            opptyIds = opptyIds + ',' + opp.Opportunity_ID__c;
                        }
                      }*/
                    if(opp.Opportunity_ID__c != null)
						return opp.Opportunity_ID__c;
					else
						return null;
                }
            }
        }
        return opptyIds;
    }
    /*
        Method : createChildCase
        Description : Creating child record for Ad-hoc oppty cases
    */
    public static Case createChildCase(Id caseId, String ContractNumber, String Modifier)
    {
        Case newCase = new Case();
        newCase.ParentId = caseId;
        newCase.Reported_By__c = RS2_Informatica_Users__c.getInstance('RS2 Integration User').User_Id__c;
        newCase.Request_Type__c = RS2_Stabilization_Config_Setting__c.getInstance('Case Request Type').Value__c;
        newCase.Vmware_Contract_Number__c = ContractNumber;
        newCase.Modifier__c = Modifier;
        newCase.Reason = RS2_Stabilization_Config_Setting__c.getInstance('Case Reason').Value__c;
        newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal Operations').getRecordTypeId();
        newCase.Origin = RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c;
        newCase.Description = RS2_Stabilization_Config_Setting__c.getInstance('Case Description').Value__c+ContractNumber+' '+Modifier;
        newCase.Subject = RS2_Stabilization_Config_Setting__c.getInstance('Case Subject').Value__c;
        newCase.Status = RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c;
        newCase.Priority = RS2_Stabilization_Config_Setting__c.getInstance('Case Priority').Value__c;
        //newCase.CurrencyIsoCode = 'USD';
        newCase.Support_Queue__c = RS2_Stabilization_Config_Setting__c.getInstance('Case Support Queue').Value__c;
        //START-----added for new enchancement  BUG-00145189
         list<String> CaseCreated=new list<String>();
         CaseCreated=RS2_Stabilization_Config_Setting__c.getInstance('Case Created')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Created').Value__c!=null? RS2_Stabilization_Config_Setting__c.getInstance('Case Created').Value__c.split(','):new List<String>{'System'};
         newCase.Created__c=CaseCreated.get(0);  
        //END-----BUG-00145189
        return newCase;
    }
}