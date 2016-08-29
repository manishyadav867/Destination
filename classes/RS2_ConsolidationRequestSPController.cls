/*
    @description As part of RCM track (RS2 Project)- For Consolidated Quote Request
    @author Mrutyunjay Palai
    @date 26th July, 2014
    Changes made by Avaneesh Singh 12-Dec-2014 related to defect Description_Short__c is not populating 
    
    Change:             Date:               Author:
    
    CR-00119296         Mar 15, 2015        Manu Sharma(Accenture)
    CR-00136357         Sep 30, 2015        Manu Sharma(Accenture)
    IBS-366             Aug 10, 2016        Soumya Behera (Accenture) [Currency (New quote requests)]
*/
public  class RS2_ConsolidationRequestSPController 
{
    public static final String METHOD_COMPARE='method';
    public static final String BLANK_VALUE='';
    public static final String FAILURE_STATUS='failure';
    public static final String ERROR_MESSAGE='Error occured ';
    public static final String JSONPOSTDATA='jsonPostData';
    public static final String METHOD_SUBMITQUOTECONSOLIDATION='submitQuoteConsolidationRequests';
    public static final String CASE_RECORDTYPE='Renewal Operations';
    public static final String COMMA=',';
    public static final String COMPARE_HYPHEN='-';
    //Added by manu-CR-00119296-Start
    public static final String COMPARE_SLASH='/';
    //Added by manu-CR-00119296-End
    public static final String COMPARE_SPACE=' ';
    public static final String CASE_TYPE='RCM';
    public static final String CASE_PRIORITY='3 – Medium';
    public static final String CASE_REQUESTTYPE='Quote Consolidation';
    public static final String CASE_REQUESTSUBTYPE='New';
    public static final String PARTNER_DISTRIBUTOR='Distributor';
    public static final String PARTNER_RESELLER='Corporate Reseller';
    public static final String COMPARE_CASE='Case';
    public static final String SEPARATOR_SLASH='/';
    public string JSonSring{get;set;}
/*
    @description As part of RCM track (RS2 Project)- For storing Renewal Details Request
    @author Mrutyunjay Palai
    @date 26th July, 2014
*/
    public  class RenewalDetails {
        public List<String> contractNumbers;
        public string requestedBy;
        public String eaNumber;
        public String eaName;
        public String snsLevel;
        public String specifySnsLevel;
        public string duration;
        public String endDate;
        public String removeInstances;
        public String distributorId;
        public String resellerId;
        public String others;
        public String currencyCustom; // Added as part of IBS-366 - by Soumya Behera
        
    }
/*
    @description As part of RCM track (RS2 Project)- For storing Distributor Contacts
    @author Mrutyunjay Palai
    @date 26th July, 2014
*/
    public  class DistributorContacts {
        public String name;
        public String email;
        public String bPrimary;
    }
    
/*
    @description As part of RCM track (RS2 Project)- For storing Request
    @author Mrutyunjay Palai
    @date 26th July, 2014
*/
    public  class RenewalDistDetails
    {
        public RenewalDetails renewalDetails;
        public List<DistributorContacts> distributorContacts;
        public String notesToDistributor; //Changes made by Avaneesh Singh 12-Dec-2014 related to defect Description_Short__c is not populating 
    }
/*
    @description As part of RCM track (RS2 Project)- For storing JSON Response
    @author Mrutyunjay Palai
    @date 26th July, 2014
*/
    public  class Reponsedetail
    {
        public string status;
        public string message;
        public List<responseData> data;
    }
    
/*
    @description As part of RCM track (RS2 Project)- For storing Response data
    @author Mrutyunjay Palai
    @date 26th July, 2014
*/
    public  class responseData
    {
        public string requestNumber;
        public string id;
        //Added by Manu-CR-00136357(RS2-H2)-Start
            public string eaName;
            public string eaNumber;
            public string contractNumber;
            public string supportLevel;
            public string duration;
            public string endDate;
        //Added by Manu-CR-00136357(RS2-H2)-Start
    }
/*
    @description As part of RCM track (RS2 Project)- Common Errors to store exceptions
    @author Mrutyunjay Palai
    @date 26th July, 2014
*/
    public  class commonErrors
    {
        public string status;
        public string data;
        public string message;
    }
    /*public RS2_ConsolidationRequestSPController()
    {
                  
    }*/
    
/*
    @return void
    @param None
*/
    public void PageloadMethods()
    {
        try
        {
            Map<String, String> paramMap=ApexPages.currentPage().getParameters();  
            string Methodname=paramMap.get(METHOD_COMPARE);
            if(Methodname.equalsIgnoreCase(METHOD_SUBMITQUOTECONSOLIDATION))
            {
                string JSONRequest=paramMap.get(JSONPOSTDATA);
                JSonSring=submitQuoteConsolidationRequests(JSONRequest); 
            }
        }
        catch(Exception ex)
        {
            commonErrors cmerror=new commonErrors();
            cmerror.status=FAILURE_STATUS;
            cmerror.data=BLANK_VALUE;
            cmerror.message=ERROR_MESSAGE+ex.getmessage();
            JSonSring=Json.serialize(cmerror); 
        }
    }
    
/*
    @return String
    @param String
*/
    public string submitQuoteConsolidationRequests(string JSONRequest)
    {
        
        String Jsonstr;
        List<RenewalDistDetails> deserializedReseller = (List<RenewalDistDetails>)JSON.deserialize(JSONRequest, List<RenewalDistDetails>.class);
        
        Map<string,List<DistributorContacts>> RenewalDetailsMap=new Map<string,List<DistributorContacts>>();
        List<Case> Caselist=new List<Case>();
        //system.debug('testingdeserializedReseller'+deserializedReseller);
        for(RenewalDistDetails RenewDist:deserializedReseller)
        {
            RenewalDetails renewalDetail=RenewDist.renewalDetails;
            String notesToDistributor=RenewDist.notesToDistributor;
            List<DistributorContacts> distributorContact=RenewDist.distributorContacts;
            String eaNumber=renewalDetail.eaNumber;
            RenewalDetailsMap.put(eaNumber,distributorContact);
            if(renewalDetail.duration!=null && renewalDetail.duration!='1 and 3 Year')
            {
            case caseobj=createCase(renewalDetail,renewalDetail.duration,notesToDistributor); //Changes made by Avaneesh Singh 12-Dec-2014 related to defect Description_Short__c is not populating , By Adding parameter notesToDistributor
            Caselist.add(caseobj);
            }
            else if(renewalDetail.duration=='1 and 3 Year')
            {
            case caseobj1year=createCase(renewalDetail,'1 Year',notesToDistributor); //Changes made by Avaneesh Singh 12-Dec-2014 related to defect Description_Short__c is not populating , By Adding parameter notesToDistributor
            Caselist.add(caseobj1year);
            case caseobj3year=createCase(renewalDetail,'3 Year',notesToDistributor); //Changes made by Avaneesh Singh 12-Dec-2014 related to defect Description_Short__c is not populating , By Adding parameter notesToDistributor
            Caselist.add(caseobj3year);
            }
            
            
        }
        
        Map<string,id> CaseidEAMap=new Map<string,id>();
        Database.SaveResult[] insertedCase;
        try
        {
        insertedCase=Database.insert(Caselist);
        }
        catch(Exception ex)
        {
        //system.debug('testing'+ex.getmessage());
        }
        List<string> casids=new List<string>(); 
        for (integer indx=0;indx<insertedCase.size();indx++) 
        {
       
        Database.SaveResult sr=insertedCase[indx];
        
        Case casobj=Caselist[indx];
        if (sr.isSuccess()) 
        {
            casids.add(sr.getId());
            CaseidEAMap.put(casobj.EA_Number__c,sr.getId());
            //system.debug('Success: ' + sr.getId());
        }
        else 
        {      
            for(Database.Error err : sr.getErrors()) 
            {                        
                ////system.debug(err.getStatusCode() + ': ' + err.getMessage());
                ////system.debug('this error: ' + err.getFields());
            }
        }
        }
        List<string> CaseNo=new List<string>();
        List<responseData> Reponsedetaillst=new List<responseData>();
        
        //Modified by Manu-CR-00136357(RS2-H2)-Start
        for(Case cas:[select Id,CaseNumber,EA_Name__c,EA_Number__c,Vmware_Contract_Number__c,GSS_Support_Level__c,Duration_Level__c,Contract_End_Date__c from Case where Id IN: casids])
        //Modified by Manu-CR-00136357(RS2-H2)-End
        {
        responseData Resdata=new responseData();
        Resdata.id=cas.Id;
        Resdata.requestNumber=cas.CaseNumber;
        
        //Added by Manu-CR-00136357(RS2-H2)-Start
        Resdata.eaName=cas.EA_Name__c;
        Resdata.eaNumber=cas.EA_Number__c;
        Resdata.contractNumber=cas.Vmware_Contract_Number__c;
        Resdata.supportLevel=cas.GSS_Support_Level__c;
        Resdata.duration=cas.Duration_Level__c;
        if(cas.Contract_End_Date__c != null){
            Resdata.endDate=RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(cas.Contract_End_Date__c,SEPARATOR_SLASH);
        }else{
            Resdata.endDate='';
        }
        //Added by Manu-CR-00136357(RS2-H2)-End
        
        Reponsedetaillst.add(Resdata);
        }   
        

        
        Reponsedetail resdetails=new Reponsedetail();
        resdetails.data=Reponsedetaillst;
        resdetails.status='success';
        resdetails.message=BLANK_VALUE;
        
        Jsonstr=Json.serialize(resdetails); 
        List<Distributor_Contact__c> DistContlist=new List<Distributor_Contact__c>();
        for(string eanum:RenewalDetailsMap.keyset())
        {
        Id casid=CaseidEAMap.get(eanum);
        List<DistributorContacts> tempdiscontlist=RenewalDetailsMap.get(eanum);
        for(DistributorContacts distcontact:tempdiscontlist)
        {
        Distributor_Contact__c discontobj=new Distributor_Contact__c(Request__c=casid,Email__c=distcontact.email,Name=distcontact.Name,primary_contact__c=boolean.valueof(distcontact.bPrimary));
        DistContlist.add(discontobj);
        }
        }
        insert DistContlist;
        //RS2_RCMCommonUtility.sendEmailDistContact(casids);
        return Jsonstr;
    } 
    //Changes made by Avaneesh Singh 12-Dec-2014 related to defect Description_Short__c is not populating , By Adding parameter notesToDistributor
    public case createCase(RenewalDetails renewalDetail,string duration,String notesToDistributor)
    {
    
    //RenewalDetails renewalDetail=RenewDist.renewalDetails;
        List<Account> acclist=new List<Account>();
        User usr= [Select ContactId,Contact.AccountId from User where Id =: UserInfo.getUserId() limit 1];
        if(usr.ContactId!=null && usr.Contact.AccountId!=null)
        {
        Id accntId = usr.Contact.AccountId;
        acclist = [ Select Id, Is_Distributor_Account__c,Is_Reseller_Account__c, Name, Partner_ID__c,Partner_Type__c from Account where Id=:accntId];
        }
            String Caserectype=Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(CASE_RECORDTYPE).getRecordTypeId();
            List<string> lststr=renewalDetail.contractNumbers;
            //system.debug('testlststr'+lststr+ ''+lststr.size());
                string Contractnos=BLANK_VALUE;
                integer indx=0;
                for(string str:lststr)
                {
                    
                    if(indx==lststr.size()-1)
                    Contractnos+=str;
                    else
                        Contractnos+=str+COMMA;
                }
                if(!String.isBlank(Contractnos))
                Contractnos=Contractnos.removeEnd(COMMA);
            //system.debug('tesContractnos'+Contractnos);        
            Case caseobj=new Case();
            //added to remove BUG-00096801
            // Added as part of IBS-366 - by Soumya Behera
            if(renewalDetail.currencyCustom != null && !String.IsBlank(renewalDetail.currencyCustom)){
                caseobj.CurrencyIsoCode = renewalDetail.currencyCustom;
            }
            if(renewalDetail.requestedBy!=null && renewalDetail.requestedBy!='' )
            {
            caseobj.AccountId=renewalDetail.requestedBy;
            }
            if(Contractnos!=BLANK_VALUE)
            caseobj.Vmware_Contract_Number__c=Contractnos;
            if(renewalDetail.eaNumber!=null)
            caseobj.EA_Number__c=renewalDetail.eaNumber;
             if(renewalDetail.eaName!=null)
             caseobj.EA_Name__c=renewalDetail.eaName;
            if(renewalDetail.snsLevel!=null)
            caseobj.GSS_Support_Level__c=renewalDetail.snsLevel;
            if(renewalDetail.specifySnsLevel!=null)
            caseobj.Q11_SnS__c=renewalDetail.specifySnsLevel;
            if(duration!=null)
            caseobj.Duration_Level__c=duration;
            
            if(!String.isBlank(renewalDetail.endDate))
            {
          
                //Modified by manu-CR-00119296-Start
                String month=(renewalDetail.endDate).substringBefore(COMPARE_SLASH);
                String day=(renewalDetail.endDate).substringBetween(COMPARE_SLASH);
                String year=(renewalDetail.endDate).substringAfterLast(COMPARE_SLASH).substringBefore(COMPARE_SPACE);
                //Modified by manu-CR-00119296-End
                caseobj.Contract_End_Date__c=date.valueof(year + COMPARE_HYPHEN + month + COMPARE_HYPHEN + day);
                
            }
            if(renewalDetail.removeInstances!=null)
            caseobj.Remove_Instance__c=renewalDetail.removeInstances;
            if(!String.isBlank(renewalDetail.distributorId))
            caseobj.Channel_Partner__c=renewalDetail.distributorId;
            if(!String.isBlank(renewalDetail.resellerId))
            caseobj.Channel_Partner__c=renewalDetail.resellerId;
            if(renewalDetail.others!=null)
            caseobj.Description=renewalDetail.others;
            //Changes made by Avaneesh Singh 12-Dec-2014 related to defect Description_Short__c is not populating Start
            if(notesToDistributor!=null && !String.isBlank(notesToDistributor)){
             caseobj.Description_Short__c=notesToDistributor;
            }
            //End of Chnage by Avaneesh Singh
            caseobj.Origin=CASE_TYPE;
            caseobj.recordTypeId=Caserectype;
            caseobj.Priority=CASE_PRIORITY;
            caseobj.Request_Type__c=CASE_REQUESTTYPE;
            caseobj.Request_Sub_Type__c=CASE_REQUESTSUBTYPE;
            caseobj.Email_Address__c=UserInfo.getUserEmail();
            caseobj.GSS_IsFeature_Available__c=true;
            if(acclist!=null && acclist.size()>0)
            {
             if(acclist[0].Is_Distributor_Account__c){
                                    caseobj.Partner_Type__c=PARTNER_DISTRIBUTOR;
                                }
                                else if(acclist[0].Is_Reseller_Account__c){
                                    caseobj.Partner_Type__c=PARTNER_RESELLER;
                                }
            }                   
               AssignmentRule AR = new AssignmentRule();
               list<AssignmentRule> assignmentRuleList = [select id from AssignmentRule where SobjectType =: COMPARE_CASE and Active = true limit 1];
               if(!assignmentRuleList.isEmpty() && assignmentRuleList != null){
                   //system.debug('*****assignmentRuleList--->'+assignmentRuleList);
                   if(assignmentRuleList[0] != null){
                       
                       AR = assignmentRuleList[0];
                   }
               }                                                  
               Database.DMLOptions dmlOpts = new Database.DMLOptions();
               if(AR != null){
                   dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
               }                                 
                   
               if(dmlOpts != null){
                   caseobj.setOptions(dmlOpts); 
               }  
    return caseobj;
    }
}