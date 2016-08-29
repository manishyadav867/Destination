/************************************************************************************
* Name             : RS2_RenewalQuoteAfterInsert
* Description      : RS2 - IBS-73 / IBS - 366
* Created By       : Accenture
* Created Date     : 12th Aug 2016
*************************************************************************************
* Date          Change-Request          Modified By             Description    
*************************************************************************************
*************************************************************************************/
public class RS2_RenewalQuoteAfterInsert
{
	public static final string CURRENCYMISMATCH = (RS2_Stabilization_Config_Setting__c.getInstance('CURRENCYMISMATCH')!=null && RS2_Stabilization_Config_Setting__c.getInstance('CURRENCYMISMATCH').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('CURRENCYMISMATCH').Value__c:'Currency missmatched');	
	public static final string COMMENT1 = (RS2_Stabilization_Config_Setting__c.getInstance('TEMPLATECOMMENT')!=null && RS2_Stabilization_Config_Setting__c.getInstance('TEMPLATECOMMENT').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('TEMPLATECOMMENT').Value__c:'The requested contract cannot be quoted in the desired currency.');
	public static final string COMMENT2 =(RS2_Stabilization_Config_Setting__c.getInstance('TEMPLATECOMMENT1')!=null && RS2_Stabilization_Config_Setting__c.getInstance('TEMPLATECOMMENT1').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('TEMPLATECOMMENT1').Value__c:'If you have any questions or concerns, please reach out to your Sales Renewals Rep.');	 
	public static final string TEMPLATECOMMENT = COMMENT1 + COMMENT2;
    public static final string SHORTTERMEND = (RS2_Stabilization_Config_Setting__c.getInstance('SHORTTERMEND')!=null && RS2_Stabilization_Config_Setting__c.getInstance('SHORTTERMEND').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('SHORTTERMEND').Value__c:'Short Term End Date');	
	public static final string FIVEYEARREQUEST = (RS2_Stabilization_Config_Setting__c.getInstance('FIVEYEARREQUEST')!=null && RS2_Stabilization_Config_Setting__c.getInstance('FIVEYEARREQUEST').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('FIVEYEARREQUEST').Value__c:'5-Plus Year Request');	
	public static final string CASESTATUSRESOLVED = 'Quoted/Resolved';
	/*
        Author :        Nilanjana Mukherjee
        Method :        quoteEndDateAfterInsert
        Description :   Will work on Renewals after insert only when Quote End Date is Different from User Requested 
    */
    public static void quoteEndDateAfterInsert(List<Renewal_Quote__c> requestedCaseList, Boolean InsertBol)
    {
        Map<id,String> caseNumberMap =new Map<id,String>();
        Set<String> VmstarCaseidset=new Set<String>();
         Set<String> ManualCaseidset=new Set<String>();
        Set<String> RCM5yearCaseidset=new Set<String>();
        Set<String> RCMless5yearCaseidset=new Set<String>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        List<Case_Extension__c> CaseList=new List<Case_Extension__c>();
        List<RCM_Attachments__c> rcmAttachmentList = new List<RCM_Attachments__c>();
        List<Attachment> CaseNotesAttchList=new List<Attachment>();
        List<CaseComment> CaseCommentList =new List<CaseComment>();
        Map<id,Attachment> CaseAttachmentMap =new Map<id,Attachment>();
        Map<id,CaseComment> CaseCommentMap =new Map<id,CaseComment>();
        Set<id> CsEx=new Set<id>();
        String OriginVmstar=(RS2_Stabilization_Config_Setting__c.getInstance('Case Origin')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Origin').Value__c:'VMSTAR');
        String OriginRCM=(RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Case Origin2').Value__c:'RCM');
        String PlusYearRequestRCM1 = (RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request RCM 1')!=null && RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request RCM 1').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request RCM 1').Value__c:' ');
        String PlusYearRequestRCM2 = (RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request RCM 2')!=null && RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request RCM 2').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request RCM 2').Value__c:' ');
        String RCMgreaterthan5year = PlusYearRequestRCM1 + '\n' + PlusYearRequestRCM2 ;
        
        String ShortTermEndDate1 = (RS2_Stabilization_Config_Setting__c.getInstance('Short Term End Date 1')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Short Term End Date 1').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Short Term End Date 1').Value__c:' ');
        String ShortTermEndDate2 = (RS2_Stabilization_Config_Setting__c.getInstance('Short Term End Date 2')!=null && RS2_Stabilization_Config_Setting__c.getInstance('Short Term End Date 2').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('Short Term End Date 2').Value__c:' ');
        String RCMlessthan5year = ShortTermEndDate1 + '\n' + ShortTermEndDate2 ;
        
        String PlusYearRequestpart1 = (RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request part1')!=null && RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request part1').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request part1').Value__c:' ');
        String PlusYearRequestpart2 = (RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request part2')!=null && RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request part2').Value__c!=null ? RS2_Stabilization_Config_Setting__c.getInstance('5-Plus Year Request part2').Value__c:' ');
        String VMSTAR5year = PlusYearRequestpart1 + '\n' +PlusYearRequestpart2 ;
        
        if(!requestedCaseList.isEmpty() && !recursive.caseUpdate ){
            for(Renewal_Quote__c rq:requestedCaseList){
                if(rq.Quote_End_Date__c!=null && !String.isblank(rq.Case__c)){
                    caseNumberMap.put(rq.id,rq.Case__c);
                }
            }
            if(!caseNumberMap.isEmpty() && caseNumberMap.values().size()>0){
                CaseList=[Select id,Case__c,Case__r.Notes__c,Case__r.CaseNumber,Case__r.Origin,Case__r.Contract_End_Date__c,Case__r.Vmware_Contract_Number__c,Quote_Date__c from Case_Extension__c Where Case__r.CaseNumber IN : caseNumberMap.values() AND Quote_Date__c!=null  AND Case__c!=null];
                
                if(!CaseList.isEmpty()){
                    for(Case_Extension__c cse: CaseList){
                        CsEx.add(cse.Case__c);
                    }
                }
                if(!CsEx.isEmpty()){
                    CaseNotesAttchList=[SELECT id,ParentID FROM Attachment WHERE ParentID IN:CsEx];
                    if(!CaseNotesAttchList.isEmpty() && CaseNotesAttchList.size()>0){
                        for(Attachment att:CaseNotesAttchList){
                            if(!CaseAttachmentMap.containsKey(att.ParentID)){
                                CaseAttachmentMap.put(att.ParentID,att);
                            }
                        }
                    }
                    CaseCommentList=[SELECT CommentBody,Id,ParentId FROM CaseComment where ParentId IN:CsEx];
                    if(!CaseCommentList.isEmpty() && CaseCommentList.size()>0){
                        for(CaseComment cc: CaseCommentList){
                          if(!CaseCommentMap.containsKey(cc.ParentID)){
                                CaseCommentMap.put(cc.ParentID,cc);
                            }
                        }
                    }
                }
            }
            Set<id> CaseUpdateId =new Set<id>();
            if(!CaseList.isEmpty()){
                system.debug('CaseList***'+CaseList);
                for(Case_Extension__c cse:CaseList){
                    if(cse.Case__r.Origin == OriginVmstar && cse.Case__r.Contract_End_Date__c!=null && cse.Quote_Date__c!=null){
                        if((!CaseCommentMap.isEmpty() && CaseCommentMap.containsKey(cse.Case__c) && CaseCommentMap.get(cse.Case__c)!=null ) || (!CaseAttachmentMap.isEmpty() && CaseAttachmentMap.containsKey(cse.Case__c) && CaseAttachmentMap.get(cse.Case__c)!=null)){
                            //Manual Processing
                            CaseUpdateId.add(cse.Case__c);
                            System.debug('CaseUpdateId*****'+CaseUpdateId);
                            ManualCaseidset.add(cse.Case__r.CaseNumber);
                            System.debug('ManualCaseidset*****'+ManualCaseidset);
                        }
                        else{
                            VmstarCaseidset.add(cse.Case__r.CaseNumber);
                            System.debug('VmstarCaseidset*****'+VmstarCaseidset);
                        }
                    }
                    else if(cse.Case__r.Origin == OriginRCM  && cse.Case__r.Contract_End_Date__c!=null && cse.Quote_Date__c!=null){
                        Decimal dateday=(Decimal.valueof(Date.valueof(system.today()).daysBetween(Date.valueof(cse.Case__r.Contract_End_Date__c)))/365).setscale(3);
                        System.debug('dateday*****'+dateday);
                        Decimal yearcal=dateday;
                        if(yearcal!=null && yearcal > 5){
                            System.debug('More Than 5 Year RCM*****'+yearcal);
                             if((!CaseCommentMap.isEmpty() && CaseCommentMap.containsKey(cse.Case__c) && CaseCommentMap.get(cse.Case__c)!=null ) || (!CaseAttachmentMap.isEmpty() && CaseAttachmentMap.containsKey(cse.Case__c) && CaseAttachmentMap.get(cse.Case__c)!=null)){
                                //Manual Processing
                                CaseUpdateId.add(cse.Case__c);
                                System.debug('CaseUpdateId*****'+CaseUpdateId);
                                ManualCaseidset.add(cse.Case__r.CaseNumber);
                                System.debug('ManualCaseidset*****'+ManualCaseidset);
                            }
                            else{
                                RCM5yearCaseidset.add(cse.Case__r.CaseNumber);
                                System.debug('RCM5yearCaseidset*****'+RCM5yearCaseidset);
                            }
                        }
                        else {
                            System.debug('Less Than 5 Year RCM*****'+yearcal);
                             if((!CaseCommentMap.isEmpty() && CaseCommentMap.containsKey(cse.Case__c) && CaseCommentMap.get(cse.Case__c)!=null ) || (!CaseAttachmentMap.isEmpty() && CaseAttachmentMap.containsKey(cse.Case__c) && CaseAttachmentMap.get(cse.Case__c)!=null)){
                                //Manual Processing
                                CaseUpdateId.add(cse.Case__c);
                                System.debug('CaseUpdateId*****'+CaseUpdateId);
                                ManualCaseidset.add(cse.Case__r.CaseNumber);
                                System.debug('ManualCaseidset*****'+ManualCaseidset);
                            }
                            else{
                                RCMless5yearCaseidset.add(cse.Case__r.CaseNumber);
                                System.debug('RCMless5yearCaseidset*****'+RCMless5yearCaseidset);
                            }
                        }
                    }
                }
                // On update insert the attachment
                if(!caseNumberMap.isEmpty() && InsertBol)
                {
                    for(Id caseNumber : caseNumberMap.keySet())
                    {                    
                        if(caseNumberMap.get(caseNumber)!=null){
                            if(!VmstarCaseidset.isEmpty() && VmstarCaseidset.contains(caseNumberMap.get(caseNumber))){
                                Id Renewalid = caseNumber;
                                String RenewalCaseNumber = caseNumberMap.get(caseNumber);
                                System.debug('Renewalid*****'+Renewalid);
                                System.debug('RenewalCaseNumber*****'+RenewalCaseNumber);
                                RCM_Attachments__c rcmAtt = new RCM_Attachments__c();
                                rcmAtt.Quote_Parent_Id__c = Renewalid;
                                rcmAtt.Name = FIVEYEARREQUEST;
                                rcmAtt.Comment__c = VMSTAR5year;
                                rcmAtt.CaseNumber__c = RenewalCaseNumber;
                                rcmAttachmentList.add(rcmAtt);
                            }
                            else if(!RCM5yearCaseidset.isEmpty() && RCM5yearCaseidset.contains(caseNumberMap.get(caseNumber))){
                                Id Renewal5id = caseNumber;
                                String Renewal5CaseNumber = caseNumberMap.get(caseNumber);
                                System.debug('Renewal5id*****'+Renewal5id);
                                System.debug('Renewal5CaseNumber*****'+Renewal5CaseNumber);
                                RCM_Attachments__c rcmAtt = new RCM_Attachments__c();
                                rcmAtt.Quote_Parent_Id__c = Renewal5id ;
                                rcmAtt.Name = FIVEYEARREQUEST;
                                rcmAtt.Comment__c = RCMgreaterthan5year ;
                                rcmAtt.CaseNumber__c = Renewal5CaseNumber ;
                                rcmAttachmentList.add(rcmAtt);
                            }
                            else if(!RCMless5yearCaseidset.isEmpty() && RCMless5yearCaseidset.contains(caseNumberMap.get(caseNumber))){
                                Id Renewalless5id = caseNumber;
                                String Renewalless5CaseNumber = caseNumberMap.get(caseNumber);
                                System.debug('Renewalless5id*****'+Renewalless5id);
                                System.debug('Renewalless5CaseNumber*****'+Renewalless5CaseNumber);
                                RCM_Attachments__c rcmAtt = new RCM_Attachments__c();
                                rcmAtt.Quote_Parent_Id__c = Renewalless5id ;
                                rcmAtt.Name = SHORTTERMEND;
                                rcmAtt.Comment__c = RCMlessthan5year;
                                rcmAtt.CaseNumber__c = Renewalless5CaseNumber ;
                                rcmAttachmentList.add(rcmAtt);
                            }
                        }
                    }
                }
            }
            if(rcmAttachmentList != null && !rcmAttachmentList.IsEmpty()){
                System.debug('rcmAttachmentList*****'+rcmAttachmentList);
                srList = Database.insert(rcmAttachmentList,false);
            }
            /**Updating Case Owner to manual Queue When Origin = VMSTAR**/
            List<Case> UpdateCaseOwnerList=new List<Case>();
            List<Case> UpdateCaseList=new List<Case>();
            if(InsertBol && !CaseUpdateId.isEmpty()){
                UpdateCaseList=[Select id,Ownerid,Status from Case where id IN:CaseUpdateId];
                if(!UpdateCaseList.isEmpty()){
                    for(Case cs:UpdateCaseList){
                        cs.Status= CASESTATUSRESOLVED;
                        UpdateCaseOwnerList.add(cs);
                    }
                }
                if(!UpdateCaseOwnerList.isEmpty()){
                    Database.SaveResult[] srList1 = Database.update(UpdateCaseOwnerList,false);
                }
            }
            // deleting the QPA creation when years>5 yr
            // get the list of Renewal quotes for which i need to delet the QPA
            list<Id> quoteIds = new List<Id>();
            system.debug('caseNumberMap value'+caseNumberMap);
            Map<String,Id> csNumberQuoteId = new Map<String,Id>();
            if(caseNumberMap != null && !caseNumberMap.IsEmpty()){
                for(Id ids: caseNumberMap.keySet()){
                    if(!csNumberQuoteId.containsKey(caseNumberMap.get(ids))){
                        csNumberQuoteId.put(caseNumberMap.get(ids),ids);
                    }
                }
            }
            system.debug('csNumberQuoteId@@@ soumya'+csNumberQuoteId);
            //&& RS2_Quoting__c.getInstance('Reactivequoteuser').value__C.contains(UserInfo.getUserId()
            if(caseNumberMap != null && !caseNumberMap.isEmpty() && ManualCaseidset!=null && !ManualCaseidset.isEmpty()){
                if(InsertBol){
                    for(String casenum: caseNumberMap.values()){
                        if(ManualCaseidset.contains(casenum)){
                            if(csNumberQuoteId.get(casenum) != null)
                                quoteIds.add(csNumberQuoteId.get(casenum));
                                system.debug('@@quotesIds'+quoteIds);
                        }
                    }
                }
                else if(!InsertBol && (RS2_Quoting__c.getInstance('Reactivequoteuser').value__C.contains(UserInfo.getUserId()) || RS2_Quoting__c.getInstance('RS2FMWUser').value__C.contains(UserInfo.getUserId()))){
                    for(String casenum: caseNumberMap.values()){
                        if(ManualCaseidset.contains(casenum)){
                            if(csNumberQuoteId.get(casenum) != null)
                                quoteIds.add(csNumberQuoteId.get(casenum));
                                system.debug('@@quoteIds'+quoteIds);
                        }
                    }
                }
            }
            list<RS2_Quote_Multiple_Partners__c> delectQPA = new list<RS2_Quote_Multiple_Partners__c>();
            list<Renewal_Quote__c> quoteListTobeUpdate = new list<Renewal_Quote__c>();
            list<Renewal_Quote__c> updateQuote = new list<Renewal_Quote__c>();
            if(quoteIds != null && !quoteIds.IsEmpty()){
                delectQPA=[select Id,Name,Account__c from RS2_Quote_Multiple_Partners__c where Renewal_Quote__c IN:quoteIds];
                quoteListTobeUpdate = [select Id,Name,Visible_Flag__c from Renewal_Quote__c where Id IN:quoteIds and Visible_Flag__c=true];
            }
                
            if(delectQPA != null && !delectQPA.IsEmpty()){
                Database.DeleteResult[] qpa_Dels = Database.delete(delectQPA,false);
            }
            
            if(quoteListTobeUpdate != null && !quoteListTobeUpdate.IsEmpty()){
                for(Renewal_Quote__c qote: quoteListTobeUpdate){
                    qote.Visible_Flag__c = false;
                    updateQuote.add(qote);
                }
            }
            if(updateQuote!= null && !updateQuote.IsEmpty()){
                recursive.caseUpdate=true;
                //recursive22.quoteUpdate = true;
                system.debug('updating the Quote');
                List<Database.SaveResult> result = Database.update(updateQuote, false);
            }
        }
    }
    /*
        Author :        Soumya Ranjan
        Method :        currecyChangeAfterInsert
        Description :   Will work on Renewals after insert only when Renewal Currency is Different from Case Currency
    */
    public static void currecyChangeAfterInsert (List<Renewal_Quote__c> requestedCaseList)
    {
        set<string> caseSet = new set<string>();
        list<Case> caseRecords = new list<Case>();
        Map<String,String> caseNumCurrency = new Map<String,String>();
        List<RCM_Attachments__c> rcmAttachmentList = new List<RCM_Attachments__c>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        // set the casenumbers
        if(requestedCaseList != null && !requestedCaseList.isEmpty()){
            for(Renewal_Quote__c quote: requestedCaseList){
                if(quote.Case__c != null && !String.IsBlank(quote.Case__c)){
                    caseSet.add(quote.Case__c);
                }
            }
        }
        // querying to the case object
        if(caseSet!= null && !caseSet.IsEmpty()){
            caseRecords = [select Id,CaseNumber,CurrencyIsoCode from Case where CaseNumber IN:caseSet ];
        }
        //building the CaseNumber => Currency map
        if(caseRecords != null && !caseRecords.isEmpty()){
            for(Case cs: caseRecords){
                if(caseNumCurrency != null && !caseNumCurrency.containsKey(cs.CaseNumber)){
                    caseNumCurrency.put(cs.CaseNumber,cs.CurrencyIsoCode);
                }
            }
        }
        if(requestedCaseList != null && !requestedCaseList.isEmpty()){
            if(caseNumCurrency != null && !caseNumCurrency.IsEmpty()){
                for(Renewal_Quote__c quote: requestedCaseList){
                    if(caseNumCurrency.containsKey(quote.Case__c)){
                        if(quote.CurrencyIsoCode != caseNumCurrency.get(quote.Case__c)){
                            RCM_Attachments__c rcmAtt = new RCM_Attachments__c();
                            rcmAtt.Quote_Parent_Id__c = quote.Id;
                            rcmAtt.Name = CURRENCYMISMATCH;
                            rcmAtt.Comment__c = TEMPLATECOMMENT;
                            rcmAtt.CaseNumber__c = quote.Case__c;
                            rcmAttachmentList.add(rcmAtt);
                        }
                    }
                }
            }
        }
        if(rcmAttachmentList != null && !rcmAttachmentList.IsEmpty()){
            srList = Database.insert(rcmAttachmentList,false);
        }
    }     
}