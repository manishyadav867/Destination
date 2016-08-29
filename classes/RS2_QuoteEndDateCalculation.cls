/************************************************************************************
* Name             : RS2_QuoteEndDateCalculation
* Description      : RS2 - IBS-73 
* Created By       : NIlanjana Mukherjee (Accenture)
* Created Date     : 8th Aug 2016
*************************************************************************************
* Date          Change-Request          Modified By             Description    
*************************************************************************************
*************************************************************************************/
public class RS2_QuoteEndDateCalculation
{
    /*
        Method :        quoteEndDateAfterInsert
        Description :   Will work on case after insert only when Case Record Type equals "Renewal Operations"
                        Case Origin equals "RCM" and Request Sub Type equals "New,Revision" 
                        and Duration Level equals "Non-Standard Term,Others" and Contract_End_Date__c!=null 
    */
    
    public static void quoteEndDateAfterInsert(List<RS2_Opportunity_Case_Staging__c > requestedStagingList, Map<id,RS2_Opportunity_Case_Staging__c > oldStagingMap)
    {
        String CaseRecordTypeId=(RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c:'0128000000044mWAAQ');
        
        String OriginVmstar=(RS2_Stabilization_Config_Setting__c.getInstance('Case Origin')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c:'VMSTAR');
        
        String OriginRCM=(RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2').Value__c:'RCM');
        
        String NewCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case New')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c:'New');
        
        String RevisionCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case Revision')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c:'Revision');
        
        String NonStandTerm=(RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term').Value__c:'Non-Standard Term');
        
        String Other=(RS2_Stabilization_Config_Setting__c.getInstance('Others')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Others').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Others').Value__c:'Other');
        List<Case> requestedCaseList=new List<Case>();
        Set<String> CaseidSet=new Set<String>();
        List<Case> newCaseList=new List<Case>();
        List<Case> newCaseListRCM=new List<Case>();
        if(!requestedStagingList.isEmpty()){
            for(RS2_Opportunity_Case_Staging__c stg :requestedStagingList){
                if(stg.Source_Case_Number__c!=null && stg.EBS_Expiring_Contract_End_Date__c != null && !oldStagingMap.isEmpty() && oldStagingMap.get(stg.id).EBS_Expiring_Contract_End_Date__c != stg.EBS_Expiring_Contract_End_Date__c){
                    CaseidSet.add(stg.Source_Case_Number__c);
                }
            }
            system.debug('CaseidSet***'+CaseidSet);
            if(!CaseidSet.isEmpty()){
                requestedCaseList=[Select id,status,recordTypeId,Duration_Level__c,Request_Sub_Type__c,Contract_End_Date__c,Origin,Request_Type__c,Vmware_Contract_Number__c from Case where ID IN:CaseidSet AND recordTypeId=:CaseRecordTypeId AND Origin IN ('RCM') AND status IN ('Open','On Hold') AND Duration_Level__c IN ('Other','Non-Standard Term') AND Request_Sub_Type__c IN ('New','Revision')];
            }
        }
        if(!requestedCaseList.isEmpty())
        {
            system.debug('requestedCaseList***'+requestedCaseList);
            for(case quoteRequest : requestedCaseList)
            {
                if(quoteRequest.Origin== OriginRCM && (quoteRequest.status=='Open' || quoteRequest.status=='On Hold') && (quoteRequest.Duration_Level__c== Other || quoteRequest.Duration_Level__c== NonStandTerm) && quoteRequest.Contract_End_Date__c!=null && (quoteRequest.Request_Sub_Type__c== NewCase || quoteRequest.Request_Sub_Type__c== RevisionCase))
                {
                    System.debug('LINE  43 ********************');
                    newCaseListRCM.add(quoteRequest);
                }
            }
        }
        if(!newCaseListRCM.isEmpty()){
            System.debug('newCaseListRCM***'+newCaseListRCM);
            quoteEndDateOriginRCM(newCaseListRCM);
        }
    }
    /*
        Method :        quoteEndDateAfterInsert
        Description :   Will work on case after insert only when Case Record Type equals "Renewal Operations"
                        Case Origin equals "VMSTAR" and Request Sub Type equals "New,Revision" 
                        and Duration Level equals "Non-Standard Term,Others" and Contract_End_Date__c!=null 
    */
    
    public static void quoteEndDateVmstarAfterInsert(List<Case> requestedCaseList)
    {
        String CaseRecordTypeId=(RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c:'0128000000044mWAAQ');
        
        String OriginVmstar=(RS2_Stabilization_Config_Setting__c.getInstance('Case Origin')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c:'VMSTAR');
        
        String OriginRCM=(RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2').Value__c:'RCM');
        
        String NewCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case New')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c:'New');
        
        String RevisionCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case Revision')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c:'Revision');
        
        String NonStandTerm=(RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term').Value__c:'Non-Standard Term');
        
        String Other=(RS2_Stabilization_Config_Setting__c.getInstance('Others')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Others').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Others').Value__c:'Other');
        
        List<Case> newCaseList=new List<Case>();
        List<Case> newCaseListRCM=new List<Case>();
        
        if(!requestedCaseList.isEmpty())
        {
            for(case quoteRequest : requestedCaseList)
            {
                if(quoteRequest.recordTypeId == CaseRecordTypeId && (quoteRequest.Duration_Level__c == NonStandTerm || quoteRequest.Duration_Level__c == Other) && (quoteRequest.Request_Sub_Type__c== NewCase || quoteRequest.Request_Sub_Type__c== RevisionCase) && quoteRequest.Contract_End_Date__c!=null && quoteRequest.Origin== OriginVmstar)
                {
                    System.debug('LINE  43 ********************');
                    newCaseList.add(quoteRequest);
                }
            }
        }
        if(!newCaseList.isEmpty()){
            quoteEndDateOriginVMSTAR(newCaseList);
        }
    }
    /*
        Method :        quoteEndDateAfterUpdate
        Description :   Will work on case after update only when Case Record Type equals "Renewal Operations"
                        Case Origin equals "VMSTAR" and Request Sub Type equals "New, Revision"and Duration Level equals "Non-Standard Term","Others" and (Status="Open" && SubStatus=" "
                        or Status="On Hold" && SubStatus="Other Internal") and Contract_End_Date__c!=null && Old Contract_End_Date__c!=new Contract_End_Date__c
    */
    public static void quoteEndDateAfterUpdate(List<Case> requestedCaseList, Map<id,Case> oldCaseMap)
    {
        String CaseRecordTypeId=(RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case RecordType').Value__c:'0128000000044mWAAQ');
        
        String OriginVmstar=(RS2_Stabilization_Config_Setting__c.getInstance('Case Origin')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c:'VMSTAR');
        
        String NewCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case New')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case New').Value__c:'New');
        
        String RevisionCase=(RS2_Stabilization_Config_Setting__c.getInstance('Case Revision')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Revision').Value__c:'Revision');
        
        String NonStandTerm=(RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Non-Standard Term').Value__c:'Non-Standard Term');
        
        String Other=(RS2_Stabilization_Config_Setting__c.getInstance('Others')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Others').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Others').Value__c:'Other');
        
        String onHold=(RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Status - On Hold').Value__c:'On Hold');
        
        String statusvar=(RS2_Stabilization_Config_Setting__c.getInstance('Case Status')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Status').Value__c:'Open');
        
        String otherinter=(RS2_Stabilization_Config_Setting__c.getInstance('Other Internal')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Other Internal').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Other Internal').Value__c:'Other Internal');
        
        List<Case> newUpdateCaseList=new List<Case>();
        
        if(!requestedCaseList.isEmpty())
        {
            for(case quoteRequest : requestedCaseList)
            {
                if(quoteRequest.recordTypeId == CaseRecordTypeId && quoteRequest.Origin== OriginVmstar && (quoteRequest.Duration_Level__c == NonStandTerm || quoteRequest.Duration_Level__c == Other) && (quoteRequest.Request_Sub_Type__c== NewCase || quoteRequest.Request_Sub_Type__c== RevisionCase) && ((quoteRequest.Status==statusvar && String.isblank(quoteRequest.Sub_Status__c))||(quoteRequest.Status==onHold && quoteRequest.Sub_Status__c == otherinter)) && quoteRequest.Contract_End_Date__c!=null && !oldCaseMap.isEmpty() &&  oldCaseMap.get(quoteRequest.id).Contract_End_Date__c != quoteRequest.Contract_End_Date__c) 
                {
                    System.debug('LINE  85 ********************');
                    newUpdateCaseList.add(quoteRequest);
                }
            }
        }
        if(!newUpdateCaseList.isEmpty()){
            quoteEndDateOriginVMSTAR(newUpdateCaseList);
        }
    }
    /*
        Method :        quoteEndDateOriginVMSTAR
        Description :   Will work on case after update/after insert and Origin=VMSTAR
    */
    public static void quoteEndDateOriginVMSTAR(List<Case> newVMSTARCaseList)
    {
        
        List<Attachment> CaseNotesAttchList= new List<Attachment>();
        Set<id> Caseidset=new Set<id>();
        List<Case> Casegreaterthn5year=new List<Case>();
        List<Case> CaseOwnerList=new List<Case>();
        List<Case> UpdateCaseOwnerList=new List<Case>();
        Set<id> CaseLessthan5year =new Set<id>();
        List<Case_Extension__c> CaseLessthan5yearList=new LIst<Case_Extension__c>();
        List<Case_Extension__c> caseExtnList=new LIst<Case_Extension__c>();
        List<Case_Extension__c> caseExtnUpdateList=new LIst<Case_Extension__c>();
        Map<id,Case_Extension__c> caseExtnMap=new Map<id,Case_Extension__c>();
        if(!newVMSTARCaseList.isEmpty()){ // && !recursive.caseUpdate){
            system.debug('newVMSTARCaseList***'+newVMSTARCaseList);
            
            for(Case c:newVMSTARCaseList){
                Decimal dateday=(Decimal.valueof(Date.valueof(system.today()).daysBetween(Date.valueof(c.Contract_End_Date__c)))/365).setscale(3);
               
                system.debug('year******'+dateday);
                Decimal yearcal;
                yearcal = dateday;
                if(yearcal!=null && yearcal > 5){
                    System.debug('More Than 5 Year*****');
                    Caseidset.add(c.id);
                    System.debug('Caseidset*****'+Caseidset);
                }
                else if(yearcal!=null){
                    CaseLessthan5year.add(c.id);
                }
            }
            if(!Caseidset.isEmpty()){
                caseExtnList=[Select id,Case__c,Quote_Date__c from Case_Extension__c where Case__c IN:Caseidset];
            }
            if(!caseExtnList.isEmpty()){
                for(Case_Extension__c ce:caseExtnList){
                    caseExtnMap.put(ce.Case__c,ce);
                }
            
                for(Case cs:newVMSTARCaseList){
                    if(!caseExtnMap.isEmpty() && caseExtnMap.containskey(cs.id))
                    {
                        //When there is not notes && attachment related to CaseNotesAttchList
                        for(Case_Extension__c cee: caseExtnMap.values()){
                            cee.Quote_Date__c= (Date.valueof(system.today().addDays(-1))).addYears(5);
                            caseExtnUpdateList.add(cee);
                            system.debug('caseExtnUpdateList***'+caseExtnUpdateList);
                        }
                    }
                }
            }
            if(!CaseLessthan5year.isEmpty() ){
                CaseLessthan5yearList=[Select id,Case__c,Quote_Date__c from Case_Extension__c where (Case__c IN:CaseLessthan5year)];
                
                if(!CaseLessthan5yearList.isEmpty()){
                    for(Case_Extension__c CsEx:CaseLessthan5yearList){
                        CsEx.Quote_Date__c=null;
                        caseExtnUpdateList.add(CsEx);
                        system.debug('caseExtnUpdateList***'+caseExtnUpdateList);
                    }
                }
                
            }
            if(!caseExtnUpdateList.isEmpty()){
                
                Database.SaveResult[] srList = Database.update(caseExtnUpdateList,false);
            }
        }
    } 
    /*
        Method :        quoteEndDateOriginRCM
        Description :   Will work on case after insert and Origin=RCM
    */
    public static void quoteEndDateOriginRCM(List<Case> newRCMCaseList)
    {
        List<Case> Caseidlesslist=new List<Case>();
        List<Case> Casegreaterthn5year=new List<Case>();
        Set<id> Caseattset=new Set<id>();
        Set<id> CaseNoattset=new Set<id>();
        
        List<Attachment> CaseNotesAttchList= new List<Attachment>();
        Set<id> Caseidset=new Set<id>();
        List<Case_Extension__c> caseExtnList=new LIst<Case_Extension__c>();
        List<Case_Extension__c> caseExtnUpdateList=new LIst<Case_Extension__c>();
        Map<id,Case_Extension__c> caseExtnMap=new Map<id,Case_Extension__c>();
        if(!newRCMCaseList.isEmpty()){
            system.debug('newRCMCaseList***'+newRCMCaseList);
            
            for(Case c:newRCMCaseList){
               Decimal dateday=(Decimal.valueof(Date.valueof(system.today()).daysBetween(Date.valueof(c.Contract_End_Date__c)))/365).setscale(3);
               system.debug('year******'+dateday);
               Decimal yearcal=dateday;
               system.debug('year******'+yearcal);
                if(yearcal!=null && yearcal > 5){
                    System.debug('More Than 5 Year*****');
                    Caseidset.add(c.id);
                    System.debug('Caseidset*****'+Caseidset);
                } 
                else{
                    Caseidlesslist.add(c);
                    System.debug('Caseidlesslist*****'+Caseidlesslist);
                }   
            }
            //When RequestedEndDate - SystemDate> 5 years
            if(!Caseidset.isEmpty()){
               
                caseExtnList=[Select id,Case__c,Quote_Date__c from Case_Extension__c where Case__c IN:Caseidset];
                if(!caseExtnList.isEmpty()){
                    for(Case_Extension__c ce:caseExtnList){
                        caseExtnMap.put(ce.Case__c,ce);
                    }
                }
                for(Case cs:newRCMCaseList){
                    if(!caseExtnMap.isEmpty() && caseExtnMap.containskey(cs.id) && caseExtnMap.get(cs.id)!=null)
                    {
                        //When there is not notes && attachment related to CaseNotesAttchList
                        Case_Extension__c cee=new Case_Extension__c();
                        cee.id=caseExtnMap.get(cs.id).id;
                        cee.Quote_Date__c= (Date.valueof(system.today().addDays(-1))).addYears(5);
                        caseExtnUpdateList.add(cee);
                        system.debug('caseExtnUpdateList***'+caseExtnUpdateList);
                    }
                }
            }
            //When RequestedEndDate - SystemDate !> 5 year
            Set<String> ContrNum=new Set<String>();
            List<RS2_Opportunity_Case_Staging__c> RS2OppList=new List<RS2_Opportunity_Case_Staging__c>();
            Map<id,Set<String>> ConsolidationMap=new Map<id,Set<String>>();
            Set<id> Caseid =new Set<id>();
            map<String,Date> ContrDateMap=new map<String,Date>();
            map<id,Date> SingleQuoteExpDatemap=new map<id,Date>();
            map<id,Date> ConsoQuoteExpDatemap=new map<id,Date>();
            map<id,Date> FinalQuoteExpDatemap=new map<id,Date>();
            Set<id> CaseExtparent=new Set<id>();
            List<Case_Extension__c> CaseExtList=new List<Case_Extension__c>();  
            map<id,Date> CaseExtExpDateMap=new map<id,Date>();
            //string timezone = string.valueof(UserInfo.getTimeZone());
           // system.debug('timezone***'+timezone);
            if(!Caseidlesslist.isEmpty()){
                for(Case c: Caseidlesslist){
                    if(c.Request_Type__c=='Quote Consolidation'){
                        ContrNum.addall((c.Vmware_Contract_Number__c).split(','));
                        system.debug('ContrNum***'+ContrNum);
                        ConsolidationMap.put(c.id,ContrNum);
                        Caseid.add(c.id);
                        system.debug('ConsolidationMap***'+ConsolidationMap);
                    }
                    else{
                        ContrNum.add(c.Vmware_Contract_Number__c);
                        system.debug('ContrNum***'+ContrNum);
                        Caseid.add(c.id);
                    }
                }
                if(!ContrNum.isEmpty() && !Caseid.isEmpty()){
                    RS2OppList=[Select id,Source_Contract_Number__c,Source_Case_Number__c,EBS_Expiring_Contract_End_Date__c from RS2_Opportunity_Case_Staging__c where Source_Contract_Number__c IN:ContrNum and Source_Case_Number__c IN: Caseid And EBS_Expiring_Contract_End_Date__c!=null order by EBS_Expiring_Contract_End_Date__c ASC];
                    system.debug('RS2OppList***'+RS2OppList);
                    
                    if(!RS2OppList.isEmpty()){
                        for(RS2_Opportunity_Case_Staging__c  opp:RS2OppList){
                            if(!ContrDateMap.containskey(opp.Source_Contract_Number__c))
                            {
                                /*String myDate;
                                myDate = opp.EBS_Expiring_Contract_End_Date__c;//.format('yyyy-MM-dd HH:mm:ss','PST');  
                                system.debug('myDate@@@@'+myDate );
                                */
                                ContrDateMap.put(opp.Source_Contract_Number__c,opp.EBS_Expiring_Contract_End_Date__c);
                                system.debug('ContrDateMap***'+ContrDateMap);
                            }
                        }
                    }
                    if(!ContrDateMap.isEmpty()){
                        for(Case c: Caseidlesslist){
                            if(c.Request_Type__c =='Single Quote' && ContrDateMap.containskey(c.Vmware_Contract_Number__c)){
                                SingleQuoteExpDatemap.put(c.id,ContrDateMap.get(c.Vmware_Contract_Number__c));
                                system.debug('SingleQuoteExpDatemap***'+SingleQuoteExpDatemap);
                            }
                            else if(c.Request_Type__c =='Quote Consolidation'&& !ConsolidationMap.isEmpty() && ConsolidationMap.containskey(c.id)){
                                for(String s:ConsolidationMap.get(c.id)){
                                   if(ContrDateMap.containskey(s)){
                                       if(!ConsoQuoteExpDatemap.containskey(c.id))
                                        {
                                            ConsoQuoteExpDatemap.put(c.id,ContrDateMap.get(s));
                                        }
                                        else if(ConsoQuoteExpDatemap.containskey(c.id) && ContrDateMap.get(s) < ConsoQuoteExpDatemap.get(c.id)) {
                                             ConsoQuoteExpDatemap.put(c.id,ContrDateMap.get(s));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    system.debug('@@@ConsoQuoteExpDatemap@@@'+ConsoQuoteExpDatemap);
                    //Get All the Case Exp Contract Date
                    if(!SingleQuoteExpDatemap.isEmpty())
                    {
                        FinalQuoteExpDatemap.putall(SingleQuoteExpDatemap);
                        System.debug('FinalQuoteExpDatemap***'+FinalQuoteExpDatemap);
                    }
                    if(!ConsoQuoteExpDatemap.isEmpty())
                    {
                        FinalQuoteExpDatemap.putall(ConsoQuoteExpDatemap);
                        System.debug('FinalQuoteExpDatemap***'+FinalQuoteExpDatemap);
                    }
                }
                for(Case c: Caseidlesslist){
                    if(!FinalQuoteExpDatemap.isEmpty() && FinalQuoteExpDatemap.containskey(c.id)){
                        if((FinalQuoteExpDatemap.get(c.id) > (Date.valueof(System.today()))) || (FinalQuoteExpDatemap.get(c.id) == (Date.valueof(System.today())))){
                            Decimal diffdate=(Decimal.valueof(FinalQuoteExpDatemap.get(c.id).daysBetween(Date.valueof(c.Contract_End_Date__c)))/365).setscale(3); 
                            system.debug('diffdate******'+diffdate);
                            Decimal yearcal=diffdate;
                            
                            if(yearcal < 1){
                                System.debug('yearcal*****'+yearcal);
                                CaseExtExpDateMap.put(c.id,Date.valueof(FinalQuoteExpDatemap.get(c.id).addYears(1)));// removed .addDays(1)
                                CaseExtparent.add(c.id);
                                system.debug('CaseExtExpDateMap******'+CaseExtExpDateMap);
                            }
                        }
                        else{
                            Decimal diffdate=(Decimal.valueof(Date.valueof(System.today()).daysBetween(Date.valueof(c.Contract_End_Date__c)))/365).setscale(3); //.round()
                            system.debug('diffdate******'+diffdate);
                            Decimal yearcal=diffdate;
                           
						    if(yearcal < = 1){
                                CaseExtExpDateMap.put(c.id,Date.valueof((Date.valueof(system.today().addDays(-1))).addYears(1)));
                                CaseExtparent.add(c.id);
                                system.debug('CaseExtExpDateMap******'+CaseExtExpDateMap);
                            }
                        }
                    }
                }
                if(!CaseExtparent.isEmpty()){
                    CaseExtList=[Select id,Case__c,Quote_Date__c from Case_Extension__c where Case__c IN:CaseExtparent];
                    if(!CaseExtList.isEmpty()){
                        if(!CaseExtExpDateMap.isEmpty()){
                            for(Case_Extension__c cexe:CaseExtList){
                                if(CaseExtExpDateMap.containskey(cexe.Case__c)){
                                    cexe.Quote_Date__c= CaseExtExpDateMap.get(cexe.Case__c);
                                    caseExtnUpdateList.add(cexe);
                                }
                            }
                        }
                    }
                }
            }
            if(!caseExtnUpdateList.isEmpty()){
               Database.SaveResult[] srList = Database.update(caseExtnUpdateList,false);
            }
        }
    }
}