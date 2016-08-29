/*
        @description As part of RCM track (RS2 Project)- To search and revise Quotes and create corresponding Requests
        @author Radhika Bahl
        @date 15th May, 2014
    
    Modifications:
    
    CR Number       Date                Modified By:
    CR-00120689     Nov 17, 2014        Manu Sharma(Accenture)
    BUG-00107043    Dec 17,2014         Manu Sharma(Accenture)
                    28 Nov 2014         Radhika(Optimization of the code)
                    2 Dec 2014          Archana (
                                        Issue 1: OPAs are not getting created when there is a single request for a contract number with quotes present and no QPA
                                        Issue 2: Returning request with the contract numbers which are having quotes. Contract numbers without quotes were being missed)
    CR-00128031     Feb 16, 2015        Manu Sharma(Accenture)
    CR-00119296     Mar 16, 2015        Manu Sharma(Accenture)
    CR-00119086     Mar 20, 2015        Manu Sharma(Accenture)
    CR-00110431     Mar 25, 2015        Manu Sharma(Accenture)
    CR-Jscape       Jul 18, 2015        Manu Sharma(Accenture)
    CR-00134510     May 28, 2015        Manu Sharma(Accenture)
    CR-00132077     Jun 12, 2015        Manu Sharma(Accenture)
    BUG-00123411    Jun 24, 2015        Manu Sharma(Accenture)
    BUG-00123644    Jun 26, 2015        Manu Sharma(Accenture)
    BUG-00124045    Jul 06, 2015        Manu Sharma(Accenture)
    BUG-00124692    Jul 07, 2015        Manu Sharma(Accenture)
    CR-00135058     Aug 18, 2015        Hemangini(Accenture) [RS2 H2 : CR-00135058 : Identify duplicate quote request cases]
    BUG-00131629    Sep 24, 2015        Hemangini(Accenture) [RS2 H2 : BUG-00131629 Fix]
    IBS-366         Aug 10, 2016        Soumya Behera (Accenture) [Currency (New quote requests)]
    */
      public class RCM_QuoteRequest
        { 
            //Begin::Declaring Constants
            public static final String COMPARISON_VALUE='Other';
            public static final String SUCCESS_STATUS='success';
            public static final String ERROR_STATUS='error';
            public static final String FAILURE_STATUS='failure';
            public static final String METHOD_COMPARE='method';
            public static final String JSONPOSTDATA='jsonPostData';
            public static final String METHOD_SUBMITQUOTEREQUESTS='submitQuoteRequests';
            public static final String METHOD_GETAVAILABLEQUOTES='getAvailableQuotesByContractNumber';
            //Added by Manu-CR-00128031-start
            public static final String METHOD_GETAVAILABLEPREACTIVEQUOTES='getAvailableReactiveQuotesByContractNumber';
            //Added by Manu-CR-00128031-end
            public static final String METHOD_SETQUOTEASACTIVE='setQuoteAsActive';
            public static final String METHOD_QUOTEREVISION='quoteRevision';
            public static final String ERROR_MESSAGE='Error occured ';
            public static final String DURATION_1AND3YEAR='1 and 3 Year';
            public static final String PDF_FILEFORMAT='pdf';
            public static final String XML_FILEFORMAT='xml';
            public static final String XLSX_FILEFORMAT='xlsx';
            public static final String XLS_FILEFORMAT='xls';
            public static final String DURATION_1YEAR='1 Year';
            public static final String DURATION_3YEAR='3 Year';
            public static final String CASE_RECORDTYPE='Renewal Operations';
            public static final String DISTRIBUTOR_PARTNER='Distributor';
            public static final String RESELLER_PARTNER='Corporate Reseller';
            public static final String CASE_STATUS_OPEN='open';
            public static final String CASE_REQUEST_TYPE='Single Quote';
            public static final String CASE_REQUEST_SUB_TYPE_NEW='New';
            public static final String CASE_REQUEST_SUB_TYPE_REVISION='Revision';
            public static final String CASE_ORIGIN='RCM';
            public static final String CASE_PRIORITY='3 - Medium';
            public static final String BLANK_VALUE='';
            public static final String ATTACHMENT_TYPE='\\.';
            
            public static final String HYPHEN_COMPARE='-';
            //Added by Manu-CR-00119296-start
            public static final String SLASH_COMPARE='/';
            //Added by Manu-CR-00119296-end
            public static final String SPACE_COMPARE=' ';
            public static final String COMMA_COMPARE=',';
            public static final String OPP_RECORDTYPE='Renewal Sales Opportunity';
            public static final String ALL_PARTNER='-1';
            public static final String SPLITVALUE='##';
            private static final String SEPARATOR_HYPHEN='/';
            //End::Declaring Constants
            
            public Database.DMLOptions dmlOpts;
            public AssignmentRule AR;
            public String responseData {get; set;}          
            public String postData;
            public Map<String,String> requestData=new Map<String,String>();
            public List<User> uList=new List<User>();
            public Account userAccount=new Account();
            public String selectedPartnerAccount{get;set;}
            public  Set<Id> accountSet= new Set<Id>();
            public List<Renewal_Partner_Group__c> userAccountList = new list<Renewal_Partner_Group__c>();
            public String partner {get;set;} //CR-00135058
    /*
        @description Final JSON Response for getAvailableQuotesByContractNumber()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class JSONResponse{
            public String status;
            public LIST<responseQuotes> data;
            public String message;
        }
    /*
        @description Final JSON Response for submitQuoteRequests()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class JSONResponses{
            public String status;
            public List<ResCaseList> data;
            public String message;
        }
        
        /*
        @description Final JSON Response for setQuoteAsActive()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class JSONResponseForActivatingQuote{
            public String status;
            public String data;
            public String message;
        }
    /*
        @description Common class created for handling exceptions
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class CommonErrors{
            public string status;
            public string data;
            public string message;
        }
    /*
    @return PageReference
    @param None
    */
            public PageReference redirectingToMethods(){
                String getSimilarExistingCaseMethod = 'getSimilarExistingCase'; //CR-00135058 - variable declaration
                uList=[select id, contactId,Account_Id__c from User where id=:userInfo.getUserId() and Partner_ID__c!=null and IsActive= true limit 1];
                if((!uList.isEmpty()) && (!String.isBlank(uList[0].Account_Id__c))){
                    //finding if the Account is Distributor or Reseller Partner
                    userAccount=[select Is_Reseller_Account__c,Is_Distributor_Account__c from Account where Id=:uList[0].Account_Id__c limit 1];
                }
                //to get request parameter from UI Team
                requestData=ApexPages.currentPage().getParameters();
                string Methodname=requestData.get(METHOD_COMPARE);
                postData= requestData.get(JSONPOSTDATA);
                system.debug('requestData>>'+requestData);
                system.debug('postData>>'+postData);
                system.debug('Methodname>>>>'+Methodname);
                //Changed by Archana -- for the BUG-- replaced individual account with multi partner Account
                  String partnerId=requestData.get('partner');
                  
                if(partnerId!=null &&partnerId!=BLANK_VALUE && partnerId==ALL_PARTNER) {
                    Id currentUserId = uList[0].Id;
                
                    userAccountList = RS2_RCMCommonUtility.Rcm_RetreiveAccounts(currentUserId);
                    If(!userAccountList.isEmpty()){
                        for(Renewal_Partner_Group__c rpg : userAccountList){
                            accountSet.add(rpg.Partner_name__c) ;
                        }
                    }
                    else{
                        accountSet.add(userAccount.Id);
                    }
                }
                else if(partnerId!=null && partnerId!=BLANK_VALUE && partnerId!=ALL_PARTNER){
                    List<Account> prmAccount = [ Select Id, Name, Partner_ID__c,Is_Distributor_Account__c,Is_Reseller_Account__c from Account where Partner_ID__c =: partnerId limit 1];
                    if(prmAccount.size()>0){
                        accountSet.add(prmAccount[0].Id);
                    }
                    else{
                        accountSet.add(userAccount.Id);
                    }
                }   
                if(Methodname!=null && Methodname.equalsIgnoreCase(METHOD_SUBMITQUOTEREQUESTS)){
                    try{
                        responseData=submitQuoteRequests();
                    }catch(Exception ex){CommonErrors cmerror=new CommonErrors();cmerror.status=FAILURE_STATUS;cmerror.data=BLANK_VALUE;cmerror.message=ERROR_MESSAGE+ex.getmessage();responseData=Json.serialize(cmerror);}
                }
                if(Methodname!=null && Methodname.equalsIgnoreCase(METHOD_GETAVAILABLEQUOTES)){ 
                    try{
                        responseData=getAvailableQuotesByContractNumber();
                    }catch(Exception ex){CommonErrors cmerror=new CommonErrors();cmerror.status=FAILURE_STATUS;cmerror.data=BLANK_VALUE;cmerror.message=ERROR_MESSAGE+ex.getmessage();responseData=Json.serialize(cmerror);}
                    //responseData=getAvailableQuotesByContractNumber();
                }
                
                //added by manu-CR-00128031-start
                if(Methodname!=null && Methodname.equalsIgnoreCase(METHOD_GETAVAILABLEPREACTIVEQUOTES)){ 
                    try{
                        responseData=getAvailableReactiveQuotesByContractNumber();
                    }catch(Exception ex){CommonErrors cmerror=new CommonErrors();cmerror.status=FAILURE_STATUS;cmerror.data=BLANK_VALUE;cmerror.message=ERROR_MESSAGE+ex.getmessage();responseData=Json.serialize(cmerror);}
                    //responseData=getAvailableQuotesByContractNumber();
                }
                //added by manu-CR-00128031-end
                
                
                if(Methodname!=null && Methodname.equalsIgnoreCase(METHOD_QUOTEREVISION)){
                    try{
                        responseData=quoteRevision();
                    }catch(Exception ex){CommonErrors cmerror=new CommonErrors();cmerror.status=FAILURE_STATUS;cmerror.data=BLANK_VALUE;cmerror.message=ERROR_MESSAGE+ex.getmessage();responseData=Json.serialize(cmerror);}
                }
                //CR-00135058 - Redirecting to the method - START
                if(Methodname!=null && Methodname.equalsIgnoreCase(getSimilarExistingCaseMethod)){
                    try{
                        responseData=getSimilarExistingCase();
                    }catch(Exception ex){CommonErrors cmerror=new CommonErrors();cmerror.status=FAILURE_STATUS;cmerror.data=BLANK_VALUE;cmerror.message=ERROR_MESSAGE+ex.getmessage();responseData=Json.serialize(cmerror);}
                }
                //CR-00135058 - Redirecting to the method - END
                return null;
            }
           
    /*
        @description JSON Request format for getAvailableQuotesByContractNumber()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class requestQuotes{
            public String contractNumber;
            public String snsLevel;
            public String specifySnsLevel;
            public String duration;
            public String endDate;
            public string opportunityId;
        }
    /*
        @description JSON Response format for getAvailableQuotesByContractNumber()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class quotes{
            public Id quoteId;
            public String support;
            public String duration;
            public string newStartDate;
            public string newEndDate;
            public String status;
            public Boolean active;
            //Added by Manu-CR-00119086-Start
            public string type;
            public string expirationDate;
            public string createdDate;
            public string daysToExpire;
            public string amount;
            //Added by Manu-CR-00119086-Start     
            
            //Added by Manu-CR-00110431-Start     
            public Boolean consolidation;
            //public String currencyField;
            //Added by Manu-CR-00110431-End     
            
            public List<attachments> attachmentIds;
        }
    /*
        @description JSON Response format for getAvailableQuotesByContractNumber()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class responseQuotes{
            public String contractNumber;
            public List<quotes> availableQuotes;
        }
    /*
        @description JSON Response format for getAvailableQuotesByContractNumber()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class attachments{
            //Modified/Added by Manu-CR-Jscape-Starts
            /*public String type;
            public Id attachmentId;*/
            private String RCMNotesAttId;
            private String AttachmentId;
            private String Url;
            private String FileSize;
            private String FileName;
            private String FileType; 
            //Modified/Added by Manu-CR-Jscape-Ends
        }
        public List<attachments> attchmnts;
        public List<Renewal_Quote__c> renewalQuotes=new List<Renewal_Quote__c>();
        public Set<Id> renewalQuotesSet=new Set<Id>();
        public List<requestQuotes> deserializedQuotesInfo=new List<requestQuotes>();
        public JSONResponse quotesJSON=new JSONResponse();
        public quotes foundQuote;
        public List<quotes> listOfFoundQuotes=new List<quotes>();
        public List<quotes> listOfFoundQuotes1=new List<quotes>();
        //Added by manu-CR-00134510-Starts
        public List<RS2_Quote_Multiple_Partners__c> listOfExpiredQPAs=new List<RS2_Quote_Multiple_Partners__c>();
        //Added by manu-CR-00134510-Ends
        public responseQuotes resQuote;
        public attachments a;
        public string quoteTypeProactive='Proactive';
        public string quoteTypeReactive='Reactive';
        public string quoteTypeReactivePDS='Reactive PDS';
        public List<responseQuotes> listOfResQuotes=new List<responseQuotes>();
        public List<RS2_Opp_Multiple_Partners__c> oppPartnerAcessList=new List<RS2_Opp_Multiple_Partners__c>();
        public Map<Id,RS2_Opp_Multiple_Partners__c> mapOppIdAndOppPartnerAccess = new Map<Id,RS2_Opp_Multiple_Partners__c>();
        public Map<Id,RS2_Quote_Multiple_Partners__c> mapQuoteIdAndQuotePartnerAccess = new Map<Id,RS2_Quote_Multiple_Partners__c>();
        public List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessList=new List<RS2_Quote_Multiple_Partners__c>();
        public Map<Id,Boolean> mapOppAndPartnerAccessFlag=new Map<Id,Boolean>();
        public Map<Id,Boolean> mapQuoteAndPartnerAccessFlag=new Map<Id,Boolean>();
        public Map<Id,RS2_Quote_Multiple_Partners__c> quoteIdAndQuotePartnerAccess=new Map<Id,RS2_Quote_Multiple_Partners__c>();
        public Map<Id,Boolean> mapQuoteIdAndPartnerAccessFlag=new Map<Id,Boolean>();
        public map<Id,Renewal_Quote__c> mapIdAndQuote=new Map<Id,Renewal_Quote__c>();
        public List<Renewal_Quote__c> listOfProactiveQuote=new List<Renewal_Quote__c>();
        public List<Renewal_Quote__c> listOfReactiveQuote=new List<Renewal_Quote__c>();
        public List<Renewal_Quote__c> listOfAccessibleQuotes=new List<Renewal_Quote__c>();
        public map<Id,Renewal_Quote__c> mapIdAndQuote1=new Map<Id,Renewal_Quote__c>();
        public List<Id> listIdsQuoteAccessAfterInsert=new List<Id>();
        public map<Id,Renewal_Quote__c> mapIdAndQuoteToInsert=new Map<Id,Renewal_Quote__c>();
        public List<RS2_Quote_Multiple_Partners__c> quotePartnerAccessInsert=new List<RS2_Quote_Multiple_Partners__c>();
        public List<Database.SaveResult> saveResultList=new List<Database.SaveResult>();
        public Database.SaveResult saveResultOppAccess; 
        public RS2_Quote_Multiple_Partners__c QPARecord;
        public RS2_Opp_Multiple_Partners__c oppPartnerAccessRecord;
        public List<Id> opportunityIdsList=new List<Id>();
        public List<Opportunity> opportunityList=new List<Opportunity>();
        public List<RS2_Quote_Multiple_Partners__c> listQuoteAccessAfterInsert=new List<RS2_Quote_Multiple_Partners__c>();
        public Map<Id,Renewal_Quote__c> mapRenewalQuote=new Map<Id,Renewal_Quote__c>();
        public Map<String,List<quotes>> mapContractAndQuotes=new Map<String,List<quotes>>();
        public List<String> listOfTotalContractNum=new List<String>();
        public List<String> listOfTotalContractNumWithoutOpptyId=new List<String>();
        public Map<String,List<Id>> mapContractAndListOpp=new Map<String,List<Id>>();
        public Map<String,String> mapQuoteIdAndContractNum=new Map<String,String>();
        public Map<String,List<Renewal_Quote__c>> mapContractAndListAccessibleQuotes=new Map<String,List<Renewal_Quote__c>>();
        public Map<String,List<Renewal_Quote__c>> mapContractAndListInaccessibleQuotes=new Map<String,List<Renewal_Quote__c>>();
    /*
        @return String
        @param None
    */
        private String getAvailableQuotesByContractNumber()
        {
            if(postData!=null){
                deserializedQuotesInfo = (List<requestQuotes>)JSON.deserialize(postData, List<requestQuotes>.class);
                system.debug('deserializedQuotesInfo>>>>'+deserializedQuotesInfo);
            }
            Id oppRecordtypeId=Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get(OPP_RECORDTYPE).getRecordTypeId();
            for(requestQuotes rq:deserializedQuotesInfo){
                //not searching for Quotes if SNS or Duration are 'Other'
                listOfTotalContractNum.add(rq.contractNumber);
                if(rq.opportunityId==null || rq.opportunityId=='')
                {
                listOfTotalContractNumWithoutOpptyId.add(rq.contractNumber);
                }
                else
                {
                opportunityIdsList.add(rq.opportunityId);
                }
            }
            if(!listOfTotalContractNumWithoutOpptyId.isEmpty())
            {
                
                    //Partner directly landing on Quote Request
                    //opportunityList=[Select RS2_Expiring_Contract_Number__c from Opportunity where RS2_Expiring_Contract_Number__c IN: listOfTotalContractNum and RS2_RCM_Renewal_Status__c='Open' and RecordTypeId=:oppRecordtypeId];
                    opportunityList=[Select RS2_Expiring_Contract_Number__c from Opportunity where RS2_Expiring_Contract_Number__c IN: listOfTotalContractNumWithoutOpptyId and RS2_RCM_Renewal_Status__c='Open' and RecordTypeId=:oppRecordtypeId];
                    for(Opportunity opprec:opportunityList)
                    {
                        opportunityIdsList.add(opprec.Id);
                    }
                    system.debug('opportunityIdsList>>>'+opportunityIdsList);
            }    
            
            
            
            
            
            //When a Partner searches for a Contract Number in RCM (Quote Request module), after validation of Contract Number, firstly a search is made in the "Opportunity Partners Access" object. If found then a second level search is performed in the "Quote Partner Access" object. This implies that a Partner must have an access to Opportunity (for the Contract Number entered) and the Quotes under those Opportunities.
            oppPartnerAcessList=[Select Opportunity__c from RS2_Opp_Multiple_Partners__c where Opportunity__c IN:opportunityIdsList and PartnerSharing__c != 'To be Deleted' AND Account__c IN: accountSet];
            //for one contract number, there can be multiple opportunities and each Opportunity can have (at maximum) 2 records in Opportunity Partners Access object, for a particular Partner.
            //creating a map of Opportunity Id and Opportunity partner Access record. This help in determining whether the next step should be inserting a record into Opportunity Partner Access(if partner doesn't have access) or going for Quote Partner Access search (if partner has access to the opportunity) 
            if(oppPartnerAcessList.size()>0){
                for(RS2_Opp_Multiple_Partners__c opa:oppPartnerAcessList){
                    if(!mapOppIdAndOppPartnerAccess.containsKey(opa.Opportunity__c)){
                        mapOppIdAndOppPartnerAccess.put(opa.Opportunity__c,opa);
                    }
                }
            }
            for(Id oppId:opportunityIdsList){
                if((!mapOppIdAndOppPartnerAccess.isEmpty()) && mapOppIdAndOppPartnerAccess.containsKey(oppId)){
                    mapOppAndPartnerAccessFlag.put(oppId,true); //partner has access to Opportunity
                }else if((!mapOppIdAndOppPartnerAccess.isEmpty()) && mapOppIdAndOppPartnerAccess.containsKey(oppId)==false){
                    mapOppAndPartnerAccessFlag.put(oppId,false); //partner doesn't have access to Opportunity as Opportunity Partner Access record is missing
                }
            }
            
            List<Id> oListForContractNum;
            
            for(String cn:listOfTotalContractNum){
                oListForContractNum=new List<Id>();
                if(!mapContractAndListOpp.containsKey(cn)){
                    for(Opportunity o:opportunityList){
                        if(o.RS2_Expiring_Contract_Number__c.equals(cn)){
                            oListForContractNum.add(o.id);
                        }
                    }
                    mapContractAndListOpp.put(cn,oListForContractNum);
                }
            }
            //Modified by Manu-CR-00110431-Start
            //renewalQuotes=[Select Id,(select Id,name from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Visible_Flag__c = true and Contract_Number__c IN:listOfTotalContractNum AND Opportunity__c IN:opportunityIdsList AND (Quote_Classification__c=:quoteTypeProactive OR Quote_Classification__c=:quoteTypeReactive OR Quote_Classification__c=:quoteTypeReactivePDS)];
            //Modified by Manu-CR-Jscape-Starts
            renewalQuotes=[Select Id,(select Attachment_Id__c,DownloadUrl__c,File_Location__c,File_Size__c,File_Name__c,File_Type__c,Quote_Parent_Id__c from RCM_Request_Attachments__r where islatest__c=true),(select Id,name,BodyLength,ParentId from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Visible_Flag__c = true and Contract_Number__c IN:listOfTotalContractNum AND Opportunity__c IN:opportunityIdsList AND (Quote_Classification__c=:quoteTypeProactive OR Quote_Classification__c=:quoteTypeReactive OR Quote_Classification__c=:quoteTypeReactivePDS)];
            //Modified by Manu-CR-Jscape-Starts
            //Modified by Manu-CR-00110431-End
            
            /*String query='Select Id,(select Id,name from Attachments),Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c from Renewal_Quote__c where Flag_For_Delete__c!=true and Visible_Flag__c = true and Contract_Number__c IN '+listOfTotalContractNum; 
            query=query+' AND Opportunity__c IN '+'\''+opportunityIdsList+ '\''; 
            query=query+' AND (Quote_Classification__c='+'\''+quoteTypeProactive+ '\' OR Quote_Classification__c='+'\''+quoteTypeReactive+'\')'; 
            system.debug('Final Query::'+query);
            renewalQuotes=Database.Query(query);*/
            system.debug('renewalQuotes>>>'+renewalQuotes);
            for(Renewal_Quote__c rqUnderOpp:renewalQuotes){
                renewalQuotesSet.add(rqUnderOpp.id);
                mapQuoteIdAndContractNum.put(rqUnderOpp.id,rqUnderOpp.Contract_Number__c);
                mapIdAndQuote.put(rqUnderOpp.id,rqUnderOpp);
                /*if(rqUnderOpp.Quote_Classification__c.equalsIgnoreCase(quoteTypeProactive)){
                    listOfProactiveQuote.add(rqUnderOpp);
                }*/
            }
            //now check for "Quote partner Access" under the above found Quotes - this determines if the Partner has access to Quotes or not.
            if(!renewalQuotesSet.isEmpty()){
                quotespartnerAccessList=[Select Renewal_Quote__c from RS2_Quote_Multiple_Partners__c where Renewal_Quote__c IN:renewalQuotesSet and PartnerSharing__c != 'To be Deleted' and  Account__c IN: accountSet];
            }
            //creating a map of Quote Id and Quote Partner Access record. This help in determining whether the next step should be inserting a record into Quote Partner Access(if partner doesn't have access) or displaying it
            if(quotespartnerAccessList.size()>0){
                for(RS2_Quote_Multiple_Partners__c qpa:quotespartnerAccessList){
                    if(!mapQuoteIdAndQuotePartnerAccess.containsKey(qpa.Renewal_Quote__c)){
                        mapQuoteIdAndQuotePartnerAccess.put(qpa.Renewal_Quote__c,qpa);
                    }
                }
            }
            List<Renewal_Quote__c> qList;
            for(Id quoteId:renewalQuotesSet){
                if((!mapQuoteIdAndQuotePartnerAccess.isEmpty()) && mapQuoteIdAndQuotePartnerAccess.containsKey(quoteId)){
                //Here QPA is Present
                    mapQuoteAndPartnerAccessFlag.put(quoteId,true); //partner has access to Opportunity
                    if(!mapContractAndListAccessibleQuotes.containsKey(mapQuoteIdAndContractNum.get(quoteId))){
                        qList=new List<Renewal_Quote__c>();
                        qList.add(mapIdAndQuote.get(quoteId));
                        mapContractAndListAccessibleQuotes.put(mapQuoteIdAndContractNum.get(quoteId),qList);
                    }else{
                        (mapContractAndListAccessibleQuotes.get(mapQuoteIdAndContractNum.get(quoteId))).add(mapIdAndQuote.get(quoteId));
                    }
                }else if((!mapQuoteIdAndQuotePartnerAccess.isEmpty()) && mapQuoteIdAndQuotePartnerAccess.containsKey(quoteId)==false){
                    mapQuoteAndPartnerAccessFlag.put(quoteId,false); //partner doesn't have access to Opportunity as Quote Partner Access record is missing
                    if(!mapContractAndListInaccessibleQuotes.containsKey(mapQuoteIdAndContractNum.get(quoteId))){
                        qList=new List<Renewal_Quote__c>();
                        qList.add(mapIdAndQuote.get(quoteId));
                        mapContractAndListInaccessibleQuotes.put(mapQuoteIdAndContractNum.get(quoteId),qList);
                    }else{
                        (mapContractAndListInaccessibleQuotes.get(mapQuoteIdAndContractNum.get(quoteId))).add(mapIdAndQuote.get(quoteId));
                    }
                }
        //Added by: Archana as OPAs are not getting created when there is a single request for a contract number with quotes present and no QPA--Start
                else if(mapQuoteIdAndQuotePartnerAccess.isEmpty()){
                //if the QPA List is empty and there are Quotes present
                    mapQuoteAndPartnerAccessFlag.put(quoteId,false);
                    if(!mapContractAndListInaccessibleQuotes.containsKey(mapQuoteIdAndContractNum.get(quoteId))){
                        qList=new List<Renewal_Quote__c>();
                        qList.add(mapIdAndQuote.get(quoteId));
                        mapContractAndListInaccessibleQuotes.put(mapQuoteIdAndContractNum.get(quoteId),qList);
                    }
                    else{
                        (mapContractAndListInaccessibleQuotes.get(mapQuoteIdAndContractNum.get(quoteId))).add(mapIdAndQuote.get(quoteId));
                    }
                
                }
                //Added by: Archana as OPAs are not getting created when there is a single request for a contract number with quotes present and no QPA--End
            }
            List<RS2_Opp_Multiple_Partners__c> oppPartnerAccessRecordList1=new List<RS2_Opp_Multiple_Partners__c>();
            List<Id> listIdsOppAccessAfterInsert=new List<Id>();
            for(String cNum:listOfTotalContractNum){
                if((mapContractAndListAccessibleQuotes.containsKey(cNum)) && !(mapContractAndListAccessibleQuotes.get(cNum)).isEmpty()){
                    //If any record is present in the Quote Partner Access, for any Proactive or Reactive Quote. Don't create any record, simply display the Quotes.
                    //Quotes on which the Partner has an access (Opportunity Partner Access + Quote Partner Access), developing response for those
                    //calling a method to create response for Accessible Quotes
                    listOfFoundQuotes=createResponseForFoundQuotes(mapContractAndListAccessibleQuotes.get(cNum));
                    system.debug('listOfFoundQuotes>>>>'+listOfFoundQuotes);
                    resQuote=new responseQuotes();
                    resQuote.contractNumber=cNum;
                    resQuote.availableQuotes=new List<quotes>(listOfFoundQuotes);
                    if(!mapContractAndQuotes.containsKey(resQuote.contractNumber)){
                        mapContractAndQuotes.put(resQuote.contractNumber,resQuote.availableQuotes);
                    }else{
                        for(quotes qf:listOfFoundQuotes){
                            (mapContractAndQuotes.get(resQuote.contractNumber)).add(qf);
                        }
                    }
                    listOfFoundQuotes.clear(); //clearing the list of found quotes for a particular Contract Number
                }
                if((mapContractAndListInaccessibleQuotes.containsKey(cNum)) && !(mapContractAndListInaccessibleQuotes.get(cNum)).isEmpty()){
                    for(Renewal_Quote__c rqInacc:mapContractAndListInaccessibleQuotes.get(cNum)){
                        //Modified by manu-CR-00134510-Starts
                        if(rqInacc.Quote_Expiry_Date__c>System.today())
                        {
                            //Begin::If Partner doesn't have access on an Opportunity
                            oppPartnerAccessRecord=new RS2_Opp_Multiple_Partners__c();
                            //oppPartnerAccessRecord.From_Apex__c=true;
                            oppPartnerAccessRecord.Incumbent_Flag__c=false;
                            oppPartnerAccessRecord.Opportunity__c=rqInacc.Opportunity__c;
                            oppPartnerAccessRecord.Account__c=userAccount.Id;
                            oppPartnerAccessRecordList1.add(oppPartnerAccessRecord);
                            
                            //filtering out Pro-active records
                            
                            //if(rqInacc.Quote_Classification__c.equalsIgnoreCase(quoteTypeProactive)){
                            
                            if(rqInacc.Quote_Classification__c.equalsIgnoreCase(quoteTypeProactive) /*&& rqInacc.Quote_Start_Date__c >System.today()*/)
                            //Modified by manu-CR-00134510-Ends
                            {
                                listOfProactiveQuote.add(rqInacc);
                            }
                        }
                    }
                    if(!oppPartnerAccessRecordList1.isEmpty()){
                        saveResultList=Database.insert(oppPartnerAccessRecordList1,false);
                        for(Renewal_Quote__c rqInaccPro:listOfProactiveQuote){
                            QPARecord=new RS2_Quote_Multiple_Partners__c();
                            QPARecord.Incumbent_Flag__c=false;
                            //QPARecord.From_Apex__c=true;
                            QPARecord.Opportunity__c=rqInaccPro.Opportunity__c;
                            QPARecord.Account__c=userAccount.Id; //to create access for the logged-in user (would not create access records for all partners in the Renewal Group)
                            QPARecord.Renewal_Quote__c=rqInaccPro.Id;
                            quotePartnerAccessInsert.add(QPARecord);
                        }
                        saveResultList.clear();
                        if(!quotePartnerAccessInsert.isEmpty()){
                            saveResultList=Database.insert(quotePartnerAccessInsert,false);
                        }
                        //Quotes on which the Partner has an access (Opportunity Partner Access + Quote Partner Access), developing response for those
                        //calling a method to create response for Accessible Quotes
                        listOfFoundQuotes=createResponseForFoundQuotes(listOfProactiveQuote);
                        system.debug('listOfFoundQuotes>>>>'+listOfFoundQuotes);
                        resQuote=new responseQuotes();
                        resQuote.contractNumber=cNum;
                        resQuote.availableQuotes=new List<quotes>(listOfFoundQuotes);
                        if(!mapContractAndQuotes.containsKey(resQuote.contractNumber)){
                            mapContractAndQuotes.put(resQuote.contractNumber,resQuote.availableQuotes);
                        }else{
                            for(quotes qf:listOfFoundQuotes){
                                (mapContractAndQuotes.get(resQuote.contractNumber)).add(qf);
                            }
                        }
                        listOfFoundQuotes.clear(); //clearing the list of found quotes for a particular Contract Number
                        quotePartnerAccessInsert.clear();
                    }
                }
                saveResultList.clear();
            }
            system.debug('mapContractAndQuotes>>>'+mapContractAndQuotes);
            //Added by Archana for the issue of showing only the contract numbers which are having the quotes.Others contract numbers were being missed. --Start
            for(String cNumber:listOfTotalContractNum){
                if(mapContractAndQuotes.containsKey(cNumber)){
                resQuote=new responseQuotes();
                resQuote.contractNumber=cNumber;
                resQuote.availableQuotes=new List<quotes>(mapContractAndQuotes.get(cNumber));
                listOfResQuotes.add(resQuote);
                }
                else{
                resQuote=new responseQuotes();
                resQuote.contractNumber=cNumber;
                resQuote.availableQuotes=new List<quotes>();
                listOfResQuotes.add(resQuote);
                }
            }
            //Added by Archana for the issue of showing only the contract numbers which are having the quotes.Others were being missed. End
        //Commented by Archana for the issue of showing only the contract numbers which are having the quotes.Others were being missed. Start
         /*   for(String c:mapContractAndQuotes.keySet()){
                resQuote=new responseQuotes();
                resQuote.contractNumber=c;
                resQuote.availableQuotes=new List<quotes>(mapContractAndQuotes.get(c));
                listOfResQuotes.add(resQuote);
            }
            if(mapContractAndQuotes.size()==0){
                resQuote=new responseQuotes();
                resQuote.contractNumber=deserializedQuotesInfo[0].contractNumber;
                resQuote.availableQuotes=new List<quotes>();
                listOfResQuotes.add(resQuote);
            }*/
            //Commented by Archana for the issue of showing only the contract numbers which are having the quotes.Others were being missed. --End
            //forming JSON response to be returned
            if(listOfResQuotes.size()>0){
                quotesJSON.status=SUCCESS_STATUS;
                quotesJSON.data=listOfResQuotes;
                system.debug('listOfResQuotes>>>>>'+listOfResQuotes);
                system.debug('serialized>>>'+quotesJSON.data);
                quotesJSON.message=BLANK_VALUE;
            }else{
                quotesJSON.status=ERROR_STATUS;
                quotesJSON.data=null;
                quotesJSON.message=System.Label.RS2_RCM_NoQuotesFound;
            }
            String res=JSON.serialize(quotesJSON);
            system.debug('res>>???'+res);
            return res;

            
        }
        //added by manu-CR-00128031-start
        private String getAvailableReactiveQuotesByContractNumber(){
        //List<String> snsLevelSet=new List<String>();
        //List<String> durationSet=new List<String>();
        Set<String> snsLevelSet=new Set<String>();
        Set<String> durationSet=new Set<String>();
            if(postData!=null){
                deserializedQuotesInfo = (List<requestQuotes>)JSON.deserialize(postData, List<requestQuotes>.class);
                system.debug('deserializedQuotesInfo>>>>'+deserializedQuotesInfo);
            }
            Id oppRecordtypeId=Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get(OPP_RECORDTYPE).getRecordTypeId();
            for(requestQuotes rq:deserializedQuotesInfo){
            if(rq.snsLevel!=null && rq.snsLevel!='')
            {
            snsLevelSet.add(rq.snsLevel);
            }
            if(rq.duration!=null && rq.duration!='')
            {
            durationSet.add(rq.duration);
            }
                //not searching for Quotes if SNS or Duration are 'Other'
                listOfTotalContractNum.add(rq.contractNumber);
                if(rq.opportunityId==null || rq.opportunityId=='')
                {
                listOfTotalContractNumWithoutOpptyId.add(rq.contractNumber);
                }
                else
                {
                opportunityIdsList.add(rq.opportunityId);
                }
            }
            if(!listOfTotalContractNumWithoutOpptyId.isEmpty())
            {
                
                    //Partner directly landing on Quote Request
                    //opportunityList=[Select RS2_Expiring_Contract_Number__c from Opportunity where RS2_Expiring_Contract_Number__c IN: listOfTotalContractNum and RS2_RCM_Renewal_Status__c='Open' and RecordTypeId=:oppRecordtypeId];
                    opportunityList=[Select RS2_Expiring_Contract_Number__c from Opportunity where RS2_Expiring_Contract_Number__c IN: listOfTotalContractNumWithoutOpptyId and RS2_RCM_Renewal_Status__c='Open' and RecordTypeId=:oppRecordtypeId];
                    for(Opportunity opprec:opportunityList)
                    {
                        opportunityIdsList.add(opprec.Id);
                    }
                    system.debug('opportunityIdsList>>>'+opportunityIdsList);
            }    
         
            //When a Partner searches for a Contract Number in RCM (Quote Request module), after validation of Contract Number, firstly a search is made in the "Opportunity Partners Access" object. If found then a second level search is performed in the "Quote Partner Access" object. This implies that a Partner must have an access to Opportunity (for the Contract Number entered) and the Quotes under those Opportunities.
            oppPartnerAcessList=[Select Opportunity__c from RS2_Opp_Multiple_Partners__c where Opportunity__c IN:opportunityIdsList and PartnerSharing__c != 'To be Deleted' AND Account__c IN: accountSet];
            //for one contract number, there can be multiple opportunities and each Opportunity can have (at maximum) 2 records in Opportunity Partners Access object, for a particular Partner.
            //creating a map of Opportunity Id and Opportunity partner Access record. This help in determining whether the next step should be inserting a record into Opportunity Partner Access(if partner doesn't have access) or going for Quote Partner Access search (if partner has access to the opportunity) 
            if(oppPartnerAcessList.size()>0){
                for(RS2_Opp_Multiple_Partners__c opa:oppPartnerAcessList){
                    if(!mapOppIdAndOppPartnerAccess.containsKey(opa.Opportunity__c)){
                        mapOppIdAndOppPartnerAccess.put(opa.Opportunity__c,opa);
                    }
                }
            }
            for(Id oppId:opportunityIdsList){
                if((!mapOppIdAndOppPartnerAccess.isEmpty()) && mapOppIdAndOppPartnerAccess.containsKey(oppId)){
                    mapOppAndPartnerAccessFlag.put(oppId,true); //partner has access to Opportunity
                }else if((!mapOppIdAndOppPartnerAccess.isEmpty()) && mapOppIdAndOppPartnerAccess.containsKey(oppId)==false){
                    mapOppAndPartnerAccessFlag.put(oppId,false); //partner doesn't have access to Opportunity as Opportunity Partner Access record is missing
                }
            }
            
            List<Id> oListForContractNum;
            
            for(String cn:listOfTotalContractNum){
                oListForContractNum=new List<Id>();
                if(!mapContractAndListOpp.containsKey(cn)){
                    for(Opportunity o:opportunityList){
                        if(o.RS2_Expiring_Contract_Number__c.equals(cn)){
                            oListForContractNum.add(o.id);
                        }
                    }
                    mapContractAndListOpp.put(cn,oListForContractNum);
                }
            }
            
            //Modified by Manu-CR-00110431,CR-00132077-Start
            //renewalQuotes=[Select Id,(select Id,name from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Visible_Flag__c = true and Contract_Number__c IN:listOfTotalContractNum AND Opportunity__c IN:opportunityIdsList AND (Quote_Classification__c=:quoteTypeReactive OR Quote_Classification__c=:quoteTypeReactivePDS) AND Support_Level__c in :snsLevelSet AND Support_Duration__c in :durationSet];
            
            if(snsLevelSet.contains('As Is'))
            {
                //Modified by Manu-CR-Jscape-Starts
    renewalQuotes=[Select Id,(select Attachment_Id__c,DownloadUrl__c,File_Location__c,File_Size__c,File_Name__c,File_Type__c,Quote_Parent_Id__c from RCM_Request_Attachments__r where islatest__c=true),(select Id,name,BodyLength,ParentId from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Visible_Flag__c = true and Contract_Number__c IN:listOfTotalContractNum AND Opportunity__c IN:opportunityIdsList AND (Quote_Classification__c=:quoteTypeReactive OR Quote_Classification__c=:quoteTypeReactivePDS) AND (Support_Level__c in :snsLevelSet OR As_Is__c=true) AND Support_Duration__c in :durationSet];
              //Modified by Manu-CR-Jscape-Ends
      }
            else
            {
                //Modified by Manu-CR-Jscape-Starts
    renewalQuotes=[Select Id,(select Attachment_Id__c,DownloadUrl__c,File_Location__c,File_Size__c,File_Name__c,File_Type__c,Quote_Parent_Id__c from RCM_Request_Attachments__r where islatest__c=true),(select Id,name,BodyLength,ParentId from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Visible_Flag__c = true and Contract_Number__c IN:listOfTotalContractNum AND Opportunity__c IN:opportunityIdsList AND (Quote_Classification__c=:quoteTypeReactive OR Quote_Classification__c=:quoteTypeReactivePDS) AND (Support_Level__c in :snsLevelSet) AND Support_Duration__c in :durationSet];
              //Modified by Manu-CR-Jscape-Ends
      }
            
            
            //Modified by Manu-CR-00110431,CR-00132077-End
            
            system.debug('renewalQuotes>>>'+renewalQuotes);
            for(Renewal_Quote__c rqUnderOpp:renewalQuotes){
                renewalQuotesSet.add(rqUnderOpp.id);
                mapQuoteIdAndContractNum.put(rqUnderOpp.id,rqUnderOpp.Contract_Number__c);
                mapIdAndQuote.put(rqUnderOpp.id,rqUnderOpp);
               
            }
            //now check for "Quote partner Access" under the above found Quotes - this determines if the Partner has access to Quotes or not.
            if(!renewalQuotesSet.isEmpty()){
                quotespartnerAccessList=[Select Renewal_Quote__c from RS2_Quote_Multiple_Partners__c where Renewal_Quote__c IN:renewalQuotesSet and PartnerSharing__c != 'To be Deleted' and  Account__c IN: accountSet];
            }
            //creating a map of Quote Id and Quote Partner Access record. This help in determining whether the next step should be inserting a record into Quote Partner Access(if partner doesn't have access) or displaying it
            if(quotespartnerAccessList.size()>0){
                for(RS2_Quote_Multiple_Partners__c qpa:quotespartnerAccessList){
                    if(!mapQuoteIdAndQuotePartnerAccess.containsKey(qpa.Renewal_Quote__c)){
                        mapQuoteIdAndQuotePartnerAccess.put(qpa.Renewal_Quote__c,qpa);
                    }
                }
            }
            List<Renewal_Quote__c> qList;
            for(Id quoteId:renewalQuotesSet){
                if((!mapQuoteIdAndQuotePartnerAccess.isEmpty()) && mapQuoteIdAndQuotePartnerAccess.containsKey(quoteId)){
                //Here QPA is Present
                    mapQuoteAndPartnerAccessFlag.put(quoteId,true); //partner has access to Opportunity
                    if(!mapContractAndListAccessibleQuotes.containsKey(mapQuoteIdAndContractNum.get(quoteId))){
                        qList=new List<Renewal_Quote__c>();
                        qList.add(mapIdAndQuote.get(quoteId));
                        mapContractAndListAccessibleQuotes.put(mapQuoteIdAndContractNum.get(quoteId),qList);
                    }else{
                        (mapContractAndListAccessibleQuotes.get(mapQuoteIdAndContractNum.get(quoteId))).add(mapIdAndQuote.get(quoteId));
                    }
                }else if((!mapQuoteIdAndQuotePartnerAccess.isEmpty()) && mapQuoteIdAndQuotePartnerAccess.containsKey(quoteId)==false){
                    mapQuoteAndPartnerAccessFlag.put(quoteId,false); //partner doesn't have access to Opportunity as Quote Partner Access record is missing
                    if(!mapContractAndListInaccessibleQuotes.containsKey(mapQuoteIdAndContractNum.get(quoteId))){
                        qList=new List<Renewal_Quote__c>();
                        qList.add(mapIdAndQuote.get(quoteId));
                        mapContractAndListInaccessibleQuotes.put(mapQuoteIdAndContractNum.get(quoteId),qList);
                    }else{
                        (mapContractAndListInaccessibleQuotes.get(mapQuoteIdAndContractNum.get(quoteId))).add(mapIdAndQuote.get(quoteId));
                    }
                }
        //Added by: Archana as OPAs are not getting created when there is a single request for a contract number with quotes present and no QPA--Start
                else if(mapQuoteIdAndQuotePartnerAccess.isEmpty()){
                //if the QPA List is empty and there are Quotes present
                    mapQuoteAndPartnerAccessFlag.put(quoteId,false);
                    if(!mapContractAndListInaccessibleQuotes.containsKey(mapQuoteIdAndContractNum.get(quoteId))){
                        qList=new List<Renewal_Quote__c>();
                        qList.add(mapIdAndQuote.get(quoteId));
                        mapContractAndListInaccessibleQuotes.put(mapQuoteIdAndContractNum.get(quoteId),qList);
                    }
                    else{
                        (mapContractAndListInaccessibleQuotes.get(mapQuoteIdAndContractNum.get(quoteId))).add(mapIdAndQuote.get(quoteId));
                    }
                
                }
                //Added by: Archana as OPAs are not getting created when there is a single request for a contract number with quotes present and no QPA--End
            }
            List<RS2_Opp_Multiple_Partners__c> oppPartnerAccessRecordList1=new List<RS2_Opp_Multiple_Partners__c>();
            List<Id> listIdsOppAccessAfterInsert=new List<Id>();
            for(String cNum:listOfTotalContractNum){
                if((mapContractAndListAccessibleQuotes.containsKey(cNum)) && !(mapContractAndListAccessibleQuotes.get(cNum)).isEmpty()){
                    //If any record is present in the Quote Partner Access, for any Proactive or Reactive Quote. Don't create any record, simply display the Quotes.
                    //Quotes on which the Partner has an access (Opportunity Partner Access + Quote Partner Access), developing response for those
                    //calling a method to create response for Accessible Quotes
                    listOfFoundQuotes=createResponseForFoundQuotes(mapContractAndListAccessibleQuotes.get(cNum));
                    system.debug('listOfFoundQuotes>>>>'+listOfFoundQuotes);
                    resQuote=new responseQuotes();
                    resQuote.contractNumber=cNum;
                    resQuote.availableQuotes=new List<quotes>(listOfFoundQuotes);
                    if(!mapContractAndQuotes.containsKey(resQuote.contractNumber)){
                        mapContractAndQuotes.put(resQuote.contractNumber,resQuote.availableQuotes);
                    }else{
                        for(quotes qf:listOfFoundQuotes){
                            (mapContractAndQuotes.get(resQuote.contractNumber)).add(qf);
                        }
                    }
                    listOfFoundQuotes.clear(); //clearing the list of found quotes for a particular Contract Number
                }
                if((mapContractAndListInaccessibleQuotes.containsKey(cNum)) && !(mapContractAndListInaccessibleQuotes.get(cNum)).isEmpty()){
                    for(Renewal_Quote__c rqInacc:mapContractAndListInaccessibleQuotes.get(cNum)){
                    
                    //Added by Manu-BUG-00124045-Start
                    if(rqInacc.Quote_Expiry_Date__c>System.Today())
                    {
                    //Added by Manu-BUG-00124045-Ends   
                        //Begin::If Partner doesn't have access on an Opportunity
                        oppPartnerAccessRecord=new RS2_Opp_Multiple_Partners__c();
                        //oppPartnerAccessRecord.From_Apex__c=true;
                        oppPartnerAccessRecord.Incumbent_Flag__c=false;
                        oppPartnerAccessRecord.Opportunity__c=rqInacc.Opportunity__c;
                        oppPartnerAccessRecord.Account__c=userAccount.Id;
                        oppPartnerAccessRecordList1.add(oppPartnerAccessRecord);
                        
                        //filtering out Pro-active records
                        
                        if(rqInacc.Quote_Classification__c.equalsIgnoreCase(quoteTypeReactive) || rqInacc.Quote_Classification__c.equalsIgnoreCase(quoteTypeReactivePDS ) ){
                        
                            listOfReactiveQuote.add(rqInacc);
                        }
                    }
                   }
                    if(!oppPartnerAccessRecordList1.isEmpty()){
                        saveResultList=Database.insert(oppPartnerAccessRecordList1,false);
                        for(Renewal_Quote__c rqInaccPro:listOfReactiveQuote){
                            QPARecord=new RS2_Quote_Multiple_Partners__c();
                            QPARecord.Incumbent_Flag__c=false;
                            //QPARecord.From_Apex__c=true;
                            QPARecord.Opportunity__c=rqInaccPro.Opportunity__c;
                            QPARecord.Account__c=userAccount.Id; //to create access for the logged-in user (would not create access records for all partners in the Renewal Group)
                            QPARecord.Renewal_Quote__c=rqInaccPro.Id;
                            quotePartnerAccessInsert.add(QPARecord);
                        }
                        saveResultList.clear();
                        if(!quotePartnerAccessInsert.isEmpty()){
                            saveResultList=Database.insert(quotePartnerAccessInsert,false);
                        }
                        //Quotes on which the Partner has an access (Opportunity Partner Access + Quote Partner Access), developing response for those
                        //calling a method to create response for Accessible Quotes
                        listOfFoundQuotes=createResponseForFoundQuotes(listOfReactiveQuote);
                        system.debug('listOfFoundQuotes>>>>'+listOfFoundQuotes);
                        resQuote=new responseQuotes();
                        resQuote.contractNumber=cNum;
                        resQuote.availableQuotes=new List<quotes>(listOfFoundQuotes);
                        if(!mapContractAndQuotes.containsKey(resQuote.contractNumber)){
                            mapContractAndQuotes.put(resQuote.contractNumber,resQuote.availableQuotes);
                        }else{
                            for(quotes qf:listOfFoundQuotes){
                                (mapContractAndQuotes.get(resQuote.contractNumber)).add(qf);
                            }
                        }
                        listOfFoundQuotes.clear(); //clearing the list of found quotes for a particular Contract Number
                        quotePartnerAccessInsert.clear();
                    }
                }
                saveResultList.clear();
            }
            system.debug('mapContractAndQuotes>>>'+mapContractAndQuotes);
            //Added by Archana for the issue of showing only the contract numbers which are having the quotes.Others contract numbers were being missed. --Start
            for(String cNumber:listOfTotalContractNum){
                if(mapContractAndQuotes.containsKey(cNumber)){
                resQuote=new responseQuotes();
                resQuote.contractNumber=cNumber;
                resQuote.availableQuotes=new List<quotes>(mapContractAndQuotes.get(cNumber));
                listOfResQuotes.add(resQuote);
                }
                else{
                resQuote=new responseQuotes();
                resQuote.contractNumber=cNumber;
                resQuote.availableQuotes=new List<quotes>();
                listOfResQuotes.add(resQuote);
                }
            }
            //Added by Archana for the issue of showing only the contract numbers which are having the quotes.Others were being missed. End
        
            //forming JSON response to be returned
            if(listOfResQuotes.size()>0){
                quotesJSON.status=SUCCESS_STATUS;
                quotesJSON.data=listOfResQuotes;
                system.debug('listOfResQuotes>>>>>'+listOfResQuotes);
                system.debug('serialized>>>'+quotesJSON.data);
                quotesJSON.message=BLANK_VALUE;
            }else{
                quotesJSON.status=ERROR_STATUS;
                quotesJSON.data=null;
                quotesJSON.message=System.Label.RS2_RCM_NoQuotesFound;
            }
            String res=JSON.serialize(quotesJSON);
            system.debug('res>>???'+res);
            return res;
                       
        }
        //Added by Manu-CR-00128031-end    
        public List<quotes> createResponseForFoundQuotes(List<Renewal_Quote__c> listOfAccessibleQuotes){
            listOfFoundQuotes1.clear();
            for(Renewal_Quote__c rq1:listOfAccessibleQuotes){
                attchmnts=new List<attachments>();
                foundQuote=new quotes();
                foundQuote.quoteId=rq1.Id;
                foundQuote.support=rq1.Support_Level__c;
                foundQuote.duration=rq1.Support_Duration__c;
               // foundQuote.newStartDate=rq1.Quote_Start_Date__c;
               // foundQuote.newEndDate=rq1.Quote_End_Date__c;
                
                //Modified by manu-CR-00119296-Start
                //String StartDatenew=String.valueOf(rq1.Quote_Start_Date__c.MONTH())+SEPARATOR_HYPHEN +String.valueOf(rq1.Quote_Start_Date__c.DAY())+SEPARATOR_HYPHEN+String.valueOf(rq1.Quote_Start_Date__c.YEAR());
                String StartDatenew=RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(rq1.Quote_Start_Date__c,SEPARATOR_HYPHEN);
                
                //String EndDatenew=String.valueOf(rq1.Quote_End_Date__c.MONTH())+SEPARATOR_HYPHEN +String.valueOf(rq1.Quote_End_Date__c.DAY())+SEPARATOR_HYPHEN+String.valueOf(rq1.Quote_End_Date__c.YEAR());
                String EndDatenew=RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(rq1.Quote_End_Date__c,SEPARATOR_HYPHEN);
                
                foundQuote.newStartDate=StartDatenew;
                
                foundQuote.newEndDate=EndDatenew;
                
                foundQuote.status=rq1.Status__c;
                foundQuote.active=rq1.Visible_Flag__c;
                
                //Added by Manu-CR-00119086-Start
                foundQuote.type=rq1.Quote_Classification__c;
                
                //foundQuote.expirationDate=String.valueOf(rq1.Quote_Expiry_Date__c.MONTH())+SEPARATOR_HYPHEN +String.valueOf(q1.Quote_Expiry_Date__c.DAY())+SEPARATOR_HYPHEN+String.valueOf(rq1.Quote_Expiry_Date__c.YEAR());               
                foundQuote.expirationDate=RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(rq1.Quote_Expiry_Date__c,SEPARATOR_HYPHEN);
                
                //foundQuote.createdDate=String.valueOf(rq1.createdDate.MONTH())+SEPARATOR_HYPHEN +String.valueOf(rq1.createdDate.DAY())+SEPARATOR_HYPHEN+String.valueOf(rq1.createdDate.YEAR());             
                foundQuote.createdDate=RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(rq1.createdDate.date(),SEPARATOR_HYPHEN);
                
                foundQuote.daysToExpire='';
                if(rq1.Quote_Expiry_Date__c!=null)
                {
                foundQuote.daysToExpire=String.valueOf(System.today().daysBetween(rq1.Quote_Expiry_Date__c));
                }
                
                foundQuote.amount='';
                if(rq1.Quote_List_Price__c!=null)
                {               
                foundQuote.amount = rq1.Quote_Currency__c + ' '+ String.valueOf(rq1.Quote_List_Price__c);
                }
                
                //Added by Manu-CR-00119086-End
                
                //Added by Manu-CR-00110431-End
                foundQuote.consolidation = rq1.Consolidation_Flag__c;
                //foundQuote.currencyField='';
                /*for(RCM_CurrencyList__c rcmCurrency:RCM_CurrencyList__c.getall().values())
                {
                    foundQuote.currencyList.add(rcmCurrency.CurrencyCode__c);
                }*/
                //foundQuote.currencyField=rq1.currencyisocode;
                //Added by Manu-CR-00110431-End
                
                //Modified by manu-CR-00119296-End
                //Added/Modified by Manu-Jscape
    List<String> typeOfFile=new List<String>();
                Boolean pdfFile=false, xmlFile=false, xlsFile=false, xlsxFile=false;
                set<Id>reactiveProactiveCheckSet=new set<Id>();
                if(rq1.RCM_Request_Attachments__r != null)
                {
                for(RCM_Attachments__c attachObj:rq1.RCM_Request_Attachments__r){
                        reactiveProactiveCheckSet.add(attachObj.Quote_Parent_Id__c);
                            //Added/Modified by Manu-CR-Jscape-Starts
                            a=new attachments();
                            a.RCMNotesAttId=attachObj.Id;
                            a.AttachmentId=attachObj.Attachment_Id__c;
                            if(attachObj.Attachment_Id__c!=null)
                            {
                            a.Url=attachObj.DownloadUrl__c;
                            }
                            else
                            {
                            a.Url=attachObj.File_Location__c;
                            }
                            a.FileSize=String.ValueOf(attachObj.File_Size__c);
                            a.FileName=attachObj.File_Name__c;

                            if(attachObj.File_Type__c!=null && attachObj.File_Type__c.equalsIgnoreCase(PDF_FILEFORMAT)&& pdfFile==false)
                            {
                            a.FileType=PDF_FILEFORMAT;
                            pdfFile=true;
                            }
                            else if(attachObj.File_Type__c!=null && attachObj.File_Type__c.equalsIgnoreCase(XLSX_FILEFORMAT)&& xlsxFile==false)
                            {
                            a.FileType=XLSX_FILEFORMAT;
                            xlsxFile=true;
                            }
                            else if(attachObj.File_Type__c!=null && attachObj.File_Type__c.equalsIgnoreCase(XML_FILEFORMAT)&& xmlFile==false)
                            {
                            a.FileType=XML_FILEFORMAT;
                            xmlFile=true;
                            }
                            else if(attachObj.File_Type__c!=null && attachObj.File_Type__c.equalsIgnoreCase(XLS_FILEFORMAT)&& xlsFile==false)
                            {
                            a.FileType=XLS_FILEFORMAT;
                            xlsFile=true;
                            }
                            attchmnts.add(a);
                            //Added/Modified by Manu-CR-Jscape-Ends
                    }
                }   
                if(rq1.Attachments != null && rq1.Quote_Classification__c=='Proactive')
                {
                   
                    for(Attachment attachObj2:rq1.Attachments)
                    {
                    if(reactiveProactiveCheckSet.isEmpty() || (!reactiveProactiveCheckSet.contains(attachObj2.ParentId))) {      
                    typeOfFile=new List<String>((attachObj2.name).split(ATTACHMENT_TYPE));
                        
                    if(typeOfFile.size()>0){
                        String fileFormat=typeOfFile[typeOfFile.size()-1];
                        system.debug('fileFormat>>>>>'+fileFormat);
                        if(fileFormat!=null && fileFormat.equalsIgnoreCase(PDF_FILEFORMAT)&& pdfFile==false){
                            a=new attachments();
                            
                            //Added/Modified by Manu-CR-Jscape-Starts
                            a.RCMNotesAttId='';
                            a.AttachmentId=attachObj2.Id;
                            a.Url= '/servlet/servlet.FileDownload?file='+attachObj2.Id;
                            a.FileSize=String.ValueOf(attachObj2.BodyLength/1024);
                            a.FileName=attachObj2.Name;
                            a.FileType=PDF_FILEFORMAT;
                            //Added/Modified by Manu-CR-Jscape-Starts
                            attchmnts.add(a);
                            pdfFile=true;
                        }else if(fileFormat!=null && fileFormat.equalsIgnoreCase(XLSX_FILEFORMAT)&& xlsxFile==false){
                            a=new attachments();
                            
                            //Added/Modified by Manu-CR-Jscape-Starts
                            a.RCMNotesAttId='';
                            a.AttachmentId=attachObj2.Id;
                            a.Url= '/servlet/servlet.FileDownload?file='+attachObj2.Id;
                            a.FileSize=String.ValueOf(attachObj2.BodyLength/1024);
                            a.FileName=attachObj2.Name;
                            a.FileType=XLSX_FILEFORMAT;
                            //Added/Modified by Manu-CR-Jscape-Starts
                            attchmnts.add(a);
                            xlsxFile=true;
                        }else if(fileFormat!=null && fileFormat.equalsIgnoreCase(XML_FILEFORMAT)&& xmlFile==false){
                            a=new attachments();
                            
                            //Added/Modified by Manu-CR-Jscape-Starts
                            a.RCMNotesAttId='';
                            a.AttachmentId=attachObj2.Id;
                            a.Url= '/servlet/servlet.FileDownload?file='+attachObj2.Id;
                            a.FileSize=String.ValueOf(attachObj2.BodyLength/1024);
                            a.FileName=attachObj2.Name;
                            a.FileType=XML_FILEFORMAT;
                            //Added/Modified by Manu-CR-Jscape-Starts
                            attchmnts.add(a);
                            xmlFile=true;
                        }
                        else if(fileFormat!=null && fileFormat.equalsIgnoreCase(XLS_FILEFORMAT)&& xlsFile==false){
                            a=new attachments();
                                                        
                            //Added/Modified by Manu-CR-Jscape-Starts
                            a.RCMNotesAttId='';
                            a.AttachmentId=attachObj2.Id;
                            a.Url= '/servlet/servlet.FileDownload?file='+attachObj2.Id;
                            a.FileSize=String.ValueOf(attachObj2.BodyLength/1024);
                            a.FileName=attachObj2.Name;
                            a.FileType=XLS_FILEFORMAT;
                            //Added/Modified by Manu-CR-Jscape-Starts
                            attchmnts.add(a);
                            xlsFile=true;
                        }
                    }
                   }
                   }
                }
                foundQuote.attachmentIds=new List<attachments>();
                foundQuote.attachmentIds.addAll(attchmnts);
                system.debug('foundQuote.quoteId>>>'+foundQuote.quoteId);
                if(!String.isBlank(foundQuote.quoteId)){
                    system.debug('foundQuote.quoteId>>>'+foundQuote.quoteId);
                    listOfFoundQuotes1.add(foundQuote);
                }
                attchmnts.clear();
                system.debug('foundQuote>>>'+foundQuote);
            }
            return listOfFoundQuotes1;
        }

    /*
    @return
    @param
    */
    private void setQuoteAsActive(List<Renewal_Quote__c> updateQuotesVisible){
        List<Renewal_Quote__c> renewalQuotesUpdated=new List<Renewal_Quote__c>();
        Database.SaveResult sr;
        for(Renewal_Quote__c updRQ:updateQuotesVisible){
            updRQ.Visible_Flag__c=true;
            renewalQuotesUpdated.add(updRQ);
        }
        saveResultList.clear();
        saveResultList=Database.update(renewalQuotesUpdated,false);
    }
    public class qRevision{
        public String reviseQuoteId;
        public String reviseSnsLevel;
        public String reviseOtherSnsLevel;
        public String reviseDuration;
        public String reviseEndDate;
        public Boolean reviseIsActive;
        public String reviseRemoveInstance;
        public Id reviseDistributorId;
        public Id reviseResellerId;
        public String reviseOther;
    }
    /*
        @description JSON Request format for quoteRevision()
        @author Radhika Bahl
        @date 15th May, 2014
    */
    public class requestQuoteRevision{
        public String contractNumber;
        public qRevision quoteRevisionRequest=new qRevision();
    }
    /*
        @return String
        @param None
    */
    public requestQuoteRevision deserializedReviseQInfo=new requestQuoteRevision();
    public responseQuotes revQuote=new responseQuotes();
    public List<Id> oppListForQuotes=new List<Id>();
    public List<responseQuotes> listOfResQuotesForRevision=new List<responseQuotes>();
    public Map<Id,Boolean> mapOppAndOPA1=new Map<Id,Boolean>();
    
    public String quoteRevision(){
    
    //Added by Manu-PDS PLUS-Starts
    String PopupFlag=ApexPages.CurrentPage().getParameters().get('popup');
    
    List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessExpiredList=new List<RS2_Quote_Multiple_Partners__c>();
    
    Map<Id,RS2_Quote_Multiple_Partners__c> mapRenQuoteIDAndQPA=new Map<Id,RS2_Quote_Multiple_Partners__c>();   
    
    Map<Id,RS2_Quote_Multiple_Partners__c> oppIdRenQuoteMap=new Map<Id,RS2_Quote_Multiple_Partners__c>();   
    //Added by Manu-PDS PLUS-Ends
        if(postData!=null){
            deserializedReviseQInfo = (requestQuoteRevision)JSON.deserialize(postData, requestQuoteRevision.class);
            system.debug('deserializedReviseQInfo>>>>'+deserializedReviseQInfo);
        }
        
        List<Renewal_Quote__c> updateQuotesVisible=new List<Renewal_Quote__c>();
        renewalQuotes.clear();
        renewalQuotesSet.clear();
        mapIdAndQuote.clear();
        quotespartnerAccessList.clear();
        listOfAccessibleQuotes.clear();
        listOfResQuotes.clear();
        oppListForQuotes.clear();
        opportunityList.clear();
        system.debug('deserializedReviseQInfo>>'+deserializedReviseQInfo);
        system.debug('deserializedReviseQInfo.contractNumber>>'+deserializedReviseQInfo.contractNumber);
        system.debug('deserializedReviseQInfo.quoteRevisionRequest.quoteId>>'+deserializedReviseQInfo.quoteRevisionRequest.reviseQuoteId);
        system.debug('deserializedReviseQInfo.quoteRevisionRequest.snsLevel>>'+deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel);
        system.debug('deserializedReviseQInfo.quoteRevisionRequest.duration>>'+deserializedReviseQInfo.quoteRevisionRequest.reviseDuration);
        //When a User clicks on Revise Quote Link, then firstly a search is made in the database to find matching Quotes. For that - the quote should have SNS and Duration, but not have any other field.
        if(deserializedReviseQInfo!=null && (!String.isBlank(deserializedReviseQInfo.contractNumber)) && (!String.isBlank(deserializedReviseQInfo.quoteRevisionRequest.reviseQuoteId)) && (!String.isBlank(deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel)) && (!String.isBlank(deserializedReviseQInfo.quoteRevisionRequest.reviseDuration))){
            
            //String query='Select Id,Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c  ,Quote_Classification__c from Renewal_Quote__c where Deleted_in_EBS__c!=true and Contract_Number__c='+'\''+deserializedReviseQInfo.contractNumber+ '\''+' AND Support_Level__c='+'\''+deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel+ '\''; 
            
            //Modified by manu-CR-00134510,CR-00132077,Jscape-Starts
            //String query='Select Id,(select Id,name from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Quote_Expiry_Date__c>TODAY and Quote_Start_Date__c >TODAY and Contract_Number__c='+'\''+deserializedReviseQInfo.contractNumber+ '\''+' AND Support_Level__c='+'\''+deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel+ '\''; 
            
            String query;
            /*if(deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel!=null && deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel!='' && deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel=='As Is')
            {
            query='Select Id,(select Id,name from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Contract_Number__c='+'\''+deserializedReviseQInfo.contractNumber+ '\''+' AND As_Is__c=true'; 
            }
            else if(deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel!=null && deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel!='' && deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel!='As Is')
            {*/
            query='Select Id,(select Attachment_Id__c,DownloadUrl__c,File_Location__c,File_Size__c,File_Name__c,File_Type__c,Quote_Parent_Id__c from RCM_Request_Attachments__r where islatest__c=true),(select Id,name,BodyLength,ParentId from Attachments),Contract_Number__c, Opportunity__c, Support_Level__c,Support_Duration__c,Quote_Start_Date__c,Quote_End_Date__c,Status__c,Visible_Flag__c,Quote_Classification__c,Quote_Expiry_Date__c,createdDate,Quote_List_Price__c,Quote_Currency__c,Consolidation_Flag__c,CurrencyIsoCode   from Renewal_Quote__c where Flag_For_Delete__c!=true and Contract_Number__c='+'\''+deserializedReviseQInfo.contractNumber+ '\''+' AND (Support_Level__c='+'\''+deserializedReviseQInfo.quoteRevisionRequest.reviseSnsLevel+ '\')';
            //}
            
            //Modified by manu-CR-00134510,CR-00132077,Jscape-Ends
            
            if(deserializedReviseQInfo.quoteRevisionRequest.reviseDuration!=DURATION_1AND3YEAR){
                query=query+' AND Support_Duration__c='+'\''+deserializedReviseQInfo.quoteRevisionRequest.reviseDuration+ '\'';     
            }else if(deserializedReviseQInfo.quoteRevisionRequest.reviseDuration.equalsIgnoreCase(DURATION_1AND3YEAR)){
                query=query+' AND Support_Duration__c IN ('+'\''+DURATION_1YEAR+ '\','+'\''+DURATION_3YEAR+ '\')';    
            }
            system.debug('Final Query::'+query);
            renewalQuotes=Database.Query(query);
            for(Renewal_Quote__c rq:renewalQuotes){
                //oppListForQuotes.add(rq.Opportunity__c);
                renewalQuotesSet.add(rq.id);
                mapIdAndQuote.put(rq.id,rq);
                if(rq.Visible_Flag__c==false){
                    updateQuotesVisible.add(rq);
                }
            }
            if(!updateQuotesVisible.isEmpty()){
                //these quotes have to be updated as Visible
                setQuoteAsActive(updateQuotesVisible);
            }
            //Modified by manu-CR-00134510,CR-00132077-Starts
            List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessList2=new List<RS2_Quote_Multiple_Partners__c>();
            //now check for "Quote partner Access" under the above found Quotes - this determines if the Partner has access to Quotes or not.
            if(!renewalQuotesSet.isEmpty()){
                quotespartnerAccessList=[Select Renewal_Quote__c,Renewal_Quote__r.Opportunity__c,Account__c from RS2_Quote_Multiple_Partners__c where PartnerSharing__c != 'To be Deleted' and  Renewal_Quote__c IN:renewalQuotesSet and Account__c IN: accountSet];
                
                quotespartnerAccessList2.addAll(quotespartnerAccessList);
            }
            
            
            
            for(RS2_Quote_Multiple_Partners__c qpaObj:quotespartnerAccessList)
            {
                mapRenQuoteIDAndQPA.put(qpaObj.Renewal_Quote__c,qpaObj);
            }
            
            List<Renewal_Quote__c> listOfQuotesForQPA=new List<Renewal_Quote__c>();
            List<Renewal_Quote__c> listOfQuotesForQPA2=new List<Renewal_Quote__c>();
            
            for(Renewal_Quote__c rqObj:renewalQuotes)
             {
                //Modified by Manu-BUG-00123411-Start
                if(mapRenQuoteIDAndQPA!=null && (mapRenQuoteIDAndQPA.isEmpty() || mapRenQuoteIDAndQPA.get(rqObj.id)==null) && rqObj.Quote_Expiry_Date__c!=null && rqObj.Quote_Expiry_Date__c>System.today())
                {
                //Modified by Manu-BUG-00123411-Ends    
                    
                    oppListForQuotes.add(rqObj.Opportunity__c);
                    listOfQuotesForQPA2.add(rqObj);
                    
                }
             }
            
            
            Map<Id,RS2_Opp_Multiple_Partners__c> opaIdOpaRecMap;
            Set<Id> OPAOpptyIdSet=new Set<Id>();
            if(!listOfQuotesForQPA2.isEmpty() && PopupFlag=='false')
            {
                 opportunityList=[select Id from Opportunity where ID IN:oppListForQuotes];
                 mapOppAndOPA1=createOpportunityPartnerAccess(opportunityList); //create Opportunity partner Access
                
                 opaIdOpaRecMap=new Map<Id,RS2_Opp_Multiple_Partners__c>([Select Id,Opportunity__c from RS2_Opp_Multiple_Partners__c where PartnerSharing__c != 'To be Deleted' and Opportunity__c IN:oppListForQuotes and Account__c IN:accountSet]);
                 
                 for(RS2_Opp_Multiple_Partners__c rOPAObj:opaIdOpaRecMap.values())
                 {
                    OPAOpptyIdSet.add(rOPAObj.Opportunity__c);
                 }
            
                    for(Renewal_Quote__c rq1:listOfQuotesForQPA2)
                    {
                        //quotes whose Opportunities have OPAs created successfully
                        
                        //if(opaIdOpaRecMap.get(rq1.Opportunity__c))
                        If(OPAOpptyIdSet.contains(rq1.Opportunity__c))
                        {
                            //OPA created, so add QPA
                            listOfQuotesForQPA.add(rq1);
                        }
                    }
                
                Map<Id,Boolean> mapQPAAndAccess=new map<Id,Boolean>();
                if(!listOfQuotesForQPA.isEmpty()){
                    mapQPAAndAccess=createQuotePartnerAccess(listOfQuotesForQPA); //create Quote partner Access
                }
                
                //For those Quotes, whose QPAs have been successfully created
                quotespartnerAccessList.clear();
                quotespartnerAccessList=[Select Renewal_Quote__c from RS2_Quote_Multiple_Partners__c where PartnerSharing__c != 'To be Deleted' and ID IN:mapQPAAndAccess.keySet()];
                
                for(RS2_Quote_Multiple_Partners__c qpa:quotespartnerAccessList){
                    
                    listOfAccessibleQuotes.add(mapIdAndQuote.get(qpa.Renewal_Quote__c));
                    
                    
                }
                
                
                listOfFoundQuotes=createResponseForFoundQuotes(listOfAccessibleQuotes); //creating JSON Response for these Quotes
                system.debug('listOfFoundQuotes>>>>'+listOfFoundQuotes);
                resQuote=new responseQuotes();
                resQuote.contractNumber=deserializedReviseQInfo.contractNumber;
                resQuote.availableQuotes=new List<quotes>(listOfFoundQuotes);
                listOfResQuotes.add(resQuote);//forming a list of response quotes for a list of contract numbers
                listOfFoundQuotes.clear(); //clearing the list of found quotes for a particular Contract Number
                mapOppAndOPA1.clear();
            }
            
            
            
            /*if(!quotespartnerAccessList.isEmpty())
            {
            Database.DeleteResult[] DR_Dels =Database.Delete(quotespartnerAccessList);
            CreateApexErrorLog.insertHandledExceptions(null, null,DR_Dels, null, 'ApexClass', 'RCM_QuoteRequest', 'quoteRevision');
    
            }*/
            
            
            
            
            //List<Renewal_Quote__c> listOfQuotesForQPA=new List<Renewal_Quote__c>();
            
            /*if(renewalQuotesSet.size()>0 && (!quotespartnerAccessList.isEmpty()))
            {
                //If any record is present in the Quote Partner Access, for any Proactive or Reactive Quote. Don't create any record, simply display the Quotes.
                for(RS2_Quote_Multiple_Partners__c qpa:quotespartnerAccessList){
                    
                    //Added/Modified by manu-CR-00134510-Starts
                    if(mapIdAndQuote.get(qpa.Renewal_Quote__c).Quote_Expiry_Date__c>System.today())
                    {
                    
                    listOfAccessibleQuotes.add(mapIdAndQuote.get(qpa.Renewal_Quote__c));
                    
                    }
                    else
                    {
                    listOfExpiredQPAs.add(qpa);
                    }
                    //Added/Modified by manu-CR-00134510-Ends
                
                }
                //Modified by manu-CR-00134510,CR-00132077-Ends
                
                
                
                listOfFoundQuotes=createResponseForFoundQuotes(listOfAccessibleQuotes);
                system.debug('listOfFoundQuotes>>>>'+listOfFoundQuotes);
                resQuote=new responseQuotes();
                resQuote.contractNumber=deserializedReviseQInfo.contractNumber;
                resQuote.availableQuotes=new List<quotes>(listOfFoundQuotes);
                listOfResQuotes.add(resQuote);//forming a list of response quotes for a list of contract numbers
                listOfFoundQuotes.clear(); //clearing the list of found quotes for a particular Contract Number
            }
            else if(renewalQuotesSet.size()>0 && (quotespartnerAccessList.isEmpty()))
            {
                opportunityList=[select Id from Opportunity where ID IN:oppListForQuotes];
                mapOppAndOPA1=createOpportunityPartnerAccess(opportunityList); //create Opportunity partner Access
                
                if(mapOppAndOPA1.size()>0){
                    for(Renewal_Quote__c rq1:renewalQuotes){//quotes whose Opportunities have OPAs created successfully
                        system.debug('mapOppAndOPA1>>>'+mapOppAndOPA1);
                        system.debug('rq1.Opportunity__c>>'+rq1.Opportunity__c);
                        if(mapOppAndOPA1.get(rq1.Opportunity__c)){
                            //OPA created, so add QPA
                            listOfQuotesForQPA.add(rq1);
                        }
                    }
                }
                Map<Id,Boolean> mapQPAAndAccess=new map<Id,Boolean>();
                if(!listOfQuotesForQPA.isEmpty()){
                    mapQPAAndAccess=createQuotePartnerAccess(listOfQuotesForQPA); //create Quote partner Access
                }else{
                    mapQPAAndAccess=createQuotePartnerAccess(renewalQuotes); //create Quote partner Access
                }
                //For those Quotes, whose QPAs have been successfully created
                quotespartnerAccessList=[Select Renewal_Quote__c from RS2_Quote_Multiple_Partners__c where PartnerSharing__c != 'To be Deleted' and ID IN:mapQPAAndAccess.keySet()];
                
                for(RS2_Quote_Multiple_Partners__c qpa:quotespartnerAccessList){
                    
                    listOfAccessibleQuotes.add(mapIdAndQuote.get(qpa.Renewal_Quote__c));
                    
                    
                }
                
                
                listOfFoundQuotes=createResponseForFoundQuotes(listOfAccessibleQuotes); //creating JSON Response for these Quotes
                system.debug('listOfFoundQuotes>>>>'+listOfFoundQuotes);
                resQuote=new responseQuotes();
                resQuote.contractNumber=deserializedReviseQInfo.contractNumber;
                resQuote.availableQuotes=new List<quotes>(listOfFoundQuotes);
                listOfResQuotes.add(resQuote);//forming a list of response quotes for a list of contract numbers
                listOfFoundQuotes.clear(); //clearing the list of found quotes for a particular Contract Number
                mapOppAndOPA1.clear();
            }*/
        
        
        //Added/Modified by manu-CR-00134510,BUG-00123644-Starts
        system.debug('##############Before Deleting Expired QPAs'+'quotespartnerAccessList2'+quotespartnerAccessList2+'PopupFlag'+PopupFlag);
        
        
         List<RS2_Quote_Multiple_Partners__c> quotespartnerAccessListToBeDeleted=new List<RS2_Quote_Multiple_Partners__c>();
        
         quotespartnerAccessListToBeDeleted=[Select Renewal_Quote__c,Renewal_Quote__r.Opportunity__c,Account__c from RS2_Quote_Multiple_Partners__c where PartnerSharing__c != 'To be Deleted' and  Renewal_Quote__c =:deserializedReviseQInfo.quoteRevisionRequest.reviseQuoteId and Account__c =:uList[0].Account_Id__c];
        
         if(!quotespartnerAccessListToBeDeleted.isEmpty() && PopupFlag=='true')
         {
            Database.DeleteResult[] DR_Dels =Database.Delete(quotespartnerAccessListToBeDeleted);
            CreateApexErrorLog.insertHandledExceptions(null, null,DR_Dels, null, 'ApexClass', 'RCM_QuoteRequest', 'quoteRevision');
         }
        
        
        /*
        if(!quotespartnerAccessList2.isEmpty() && PopupFlag=='true')
        {
            system.debug('##############Deleting Expired QPAs');
            for(RS2_Quote_Multiple_Partners__c QPAObj:quotespartnerAccessList2)
            {
                if(QPAObj.Renewal_Quote__c==deserializedReviseQInfo.quoteRevisionRequest.reviseQuoteId && QPAObj.Account__c==uList[0].Account_Id__c)
                {
                    quotespartnerAccessListToBeDeleted.add(QPAObj);
                }
            }
            //Database.DeleteResult[] DR_Dels =Database.Delete(quotespartnerAccessList2);
            Database.DeleteResult[] DR_Dels =Database.Delete(quotespartnerAccessListToBeDeleted);
            CreateApexErrorLog.insertHandledExceptions(null, null,DR_Dels, null, 'ApexClass', 'RCM_QuoteRequest', 'quoteRevision');
    
        }*/
        
        
        
        //Added/Modified by manu-CR-00134510,BUG-00123644-Ends
        
        
        }
        
        //forming JSON response to be returned
        if(listOfResQuotes.size()>0){
            quotesJSON.status=SUCCESS_STATUS;
            quotesJSON.data=listOfResQuotes;
            system.debug('listOfResQuotes>>>>>'+listOfResQuotes);
            quotesJSON.message=BLANK_VALUE;
        }else{
            quotesJSON.status=ERROR_STATUS;
            quotesJSON.data=null;
            quotesJSON.message=System.Label.RS2_RCM_NoQuotesFound;
        }
        String res=JSON.serialize(quotesJSON);
            system.debug('res>>???'+res);
            return res;
    }
    /*
        @return String
        @param None
    */
    public Map<Id,Boolean> mapOppAndOPA=new Map<Id,Boolean>();
    public Map<Id,Boolean> createOpportunityPartnerAccess(List<Opportunity> opportunityList){
        mapOppAndOPA.clear();
        List<RS2_Opp_Multiple_Partners__c> oppPartnerAccessRecordList=new List<RS2_Opp_Multiple_Partners__c>();
        List<RS2_Opp_Multiple_Partners__c> opAcc=new List<RS2_Opp_Multiple_Partners__c>();
        Map<Id,Id> OppAccessAndOpp =new Map<Id,Id>();
        for(Opportunity o:opportunityList){
            //Begin::If Partner doesn't have access on an Opportunity
            oppPartnerAccessRecord=new RS2_Opp_Multiple_Partners__c();
           // oppPartnerAccessRecord.From_Apex__c=true;
            oppPartnerAccessRecord.Incumbent_Flag__c=true;
            oppPartnerAccessRecord.Opportunity__c=o.id;
            oppPartnerAccessRecord.Account__c=userAccount.Id;
            oppPartnerAccessRecordList.add(oppPartnerAccessRecord);
        }
        saveResultList.clear();
        //inserting Opportunity Partner Access
        saveResultList=Database.insert(oppPartnerAccessRecordList,false);
        for(Database.SaveResult sr:saveResultList){
            if(sr.isSuccess()){
                mapOppAndOPA.put(sr.getId(),true);
            }
        }
        opAcc=[Select Opportunity__c from RS2_Opp_Multiple_Partners__c where PartnerSharing__c != 'To be Deleted' and Id IN:mapOppAndOPA.keySet()];
        mapOppAndOPA.clear();
        for(RS2_Opp_Multiple_Partners__c rop:opAcc){
            mapOppAndOPA.put(rop.Opportunity__c,true);
        }
        return mapOppAndOPA;
    }
    public Map<Id,Boolean> createQuotePartnerAccess(List<Renewal_Quote__c> listOfQuotesForQPA){
        quotePartnerAccessInsert.clear();
        saveResultList.clear();
        for(Renewal_Quote__c reqQuote:listOfQuotesForQPA){
            QPARecord=new RS2_Quote_Multiple_Partners__c();
            QPARecord.Incumbent_Flag__c=false;
           // QPARecord.From_Apex__c=true;
            QPARecord.Opportunity__c=reqQuote.Opportunity__c;
            QPARecord.Account__c=userAccount.Id; //to create access for the logged-in user (would not create access records for all partners in the Renewal Group)
            QPARecord.Renewal_Quote__c=reqQuote.Id;
            quotePartnerAccessInsert.add(QPARecord);
        }
        //inserting Quote Partner Access List
        saveResultList=Database.insert(quotePartnerAccessInsert,false);
        Map<Id,Boolean> mapQPAAndAccess=new map<Id,Boolean>();
        for(Database.SaveResult sr:saveResultList){
            if(sr.isSuccess()){
                mapQPAAndAccess.put(sr.getId(),true);
            }
        }
        return mapQPAAndAccess;
    }
    /*
        @description JSON Request format for submitQuoteRequests()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class requestCaseCreation{
            public String requestedBy;
            public String eaNumber;
            public String eaName;
            public String contractNumber;
            public List<revisedOrNewQuotes> revisedQuotes=new List<revisedOrNewQuotes>();
            public List<distributorContact> distributorContacts=new List<distributorContact>();
            public String notesToDistributor;
            
        }
    /*
        @description JSON Response format for submitQuoteRequests()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        
        public class ResCaseList{
            public String requestNumber;
            public string id;
            //CR-00135058 - Added response parameters - START
            public string eaName;
            public string eaNumber;
            public string contractNumber;
            public string supportLevel;
            public string duration;
            public string endDate;
            //CR-00135058 - Added response parameters - END
        }
            /*
        @description JSON Request format for submitQuoteRequests()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class revisedOrNewQuotes{
            public String quoteId;
            public String snsLevel;
            public String otherSnsLevel;
            public String duration;
            public String endDate;
            public Boolean isActive;
            public String removeInstance;
            public Id distributorId;
            public Id resellerId;
            public String other;
            //Added by Manu-CR-00110431-Start
            public Boolean refreshQuoteExpiration;
            public String revisionReason;
            public String currencyCustom;
            //Added by Manu-CR-00110431-Ends
            
            //Added by manu-BUG-00124692-Start
            public String popup;
            public String consolidation;
            //Added by manu-BUG-00124692-Ends
        }
    /*
        @description JSON Request format for submitQuoteRequests()
        @author Radhika Bahl
        @date 15th May, 2014
    */
        public class distributorContact{
            public String name;
            public String olddata;
            public String email;
            public Boolean bPrimary;
        }
        //public ResCaseList rCase;
        //public responseCaseCreation resCaseCreation=new responseCaseCreation();
        public List<ResCaseList> responseCaseList=new List<ResCaseList>();
        //map to store Contract Number and its corresponding list of Distributor Contacts
        public Map<String,List<distributorContact>> mapOfContractNumberAndDistributorContacts=new Map<String,List<distributorContact>>();
        public List<Distributor_Contact__c> distributorContactList=new List<Distributor_Contact__c>();
        public Distributor_Contact__c distributorC;
        public JSONResponses caseJSON=new JSONResponses();
        public List<Case> listOfCasesCreated=new List<Case>();
        public List<requestCaseCreation> deserializedCaseInfo=new List<requestCaseCreation>();
    /*
        @return String
        @param None
    */
            private String submitQuoteRequests(){
                if(postData!=null){
                    deserializedCaseInfo = (List<requestCaseCreation>)JSON.deserialize(postData, List<requestCaseCreation>.class);
                    system.debug('deserializedCaseInfo>>>>'+deserializedCaseInfo);
                }
                Boolean RequestNotCreated=false;
                Boolean revisedQuotesSizeZero=false;
                List<Database.SaveResult> srDCList=new List<Database.SaveResult>();
                List<Database.SaveResult> srList=new List<Database.SaveResult>();
                Id caseRecordtypeId=Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(CASE_RECORDTYPE).getRecordTypeId();
                system.debug('caseRecordtypeId>>>>'+caseRecordtypeId);
                //Calling "caseAssignment" method from RS2_RCMCommonUtility class
                AR=RS2_RCMCommonUtility.caseAssignment();
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox 
                if(AR != null){
                    dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                }  
        //added by manu-CR-00120689-start
                Set<Id> quoteIdSet=new Set<Id>();
                for(requestCaseCreation rcc1:deserializedCaseInfo){
                    for(revisedOrNewQuotes rq1:rcc1.revisedQuotes){
                          if(rq1.quoteId != '')
                         {
                           quoteIdSet.add(rq1.quoteId);
                         }  
                          
                    }
                }
                Map<Id,Renewal_Quote__c> quoteIdMap=null;
                if(quoteIdSet.size()>0)
                {
                quoteIdMap=new Map<Id,Renewal_Quote__c>([select name from Renewal_Quote__c where id in:quoteIdSet]);
                }
        //added by manu-CR-00120689-start
                for(requestCaseCreation rcc:deserializedCaseInfo){
                    if((!String.isBlank(rcc.contractNumber)) && (!String.isBlank(rcc.eaNumber))){
                        //Creating cases for Quote Revision- only valid if the user enters any value other than SNS and Duration for revision, else it would again search Quotes
                        revisedQuotesSizeZero=true;
                        system.debug('revisedQuotesSizeZero>>>'+revisedQuotesSizeZero);
                        system.debug('rcc.revisedQuotes>>>>>>>'+rcc.revisedQuotes);
                        for(revisedOrNewQuotes rq:rcc.revisedQuotes){
                        //find if the revisedQuotes list has values other than SnS and Duration i.e. case would be created
                            
                            if((!String.isBlank(rq.otherSnsLevel)) || (rq.endDate!=null) || (rq.isActive==true) || (!String.isBlank(rq.removeInstance)) || (!String.isBlank(rq.distributorId)) || (!String.isBlank(rq.resellerId)) || (!String.isBlank(rq.other)) || (!String.isBlank(rq.snsLevel)) || (!String.isBlank(rq.duration))){
                                revisedQuotesSizeZero=false;
                                system.debug('revisedQuotesSizeZero>>>'+revisedQuotesSizeZero);
                                Boolean flag=false;
                                String distributorContactsEmail=null;
                                Case newQuoteRequestCase=new Case();
                                //added by manu-CR-00120689-start
                                String temp='';
                                if(rq.quoteId!=null && rq.quoteId!='' && quoteIdMap!=null && quoteIdMap.size()>0 && quoteIdMap.get(rq.quoteId)!=null )
                                {
                                        temp=quoteIdMap.get(rq.quoteId).name;
                                        if(temp!=null && temp!='')
                                        {
                                            if(temp.contains('-R'))
                                            {
                                                temp=temp.substring(temp.indexOf('-R')+1,temp.length());
                                                newQuoteRequestCase.Modifier__c=temp;
                                                
                                            }
                                        }
                                }
                                //added by manu-CR-00120689-start
                                newQuoteRequestCase.GSS_IsFeature_Available__c=true;
                                if(userAccount.Is_Distributor_Account__c){
                                    newQuoteRequestCase.Partner_Type__c=DISTRIBUTOR_PARTNER;
                                }
                                else if(userAccount.Is_Reseller_Account__c){
                                    newQuoteRequestCase.Partner_Type__c=RESELLER_PARTNER;
                                }
                                newQuoteRequestCase.Channel_Partner_PRMID__c=userAccount.Id;
                                if(!String.isBlank(rq.resellerId)){
                                    newQuoteRequestCase.Channel_Partner__c=rq.resellerId;
                                    system.debug('rq.resellerId'+rq.resellerId);
                                }
                                system.debug('rq.distributorId'+rq.distributorId);
                                system.debug('rq.resellerId'+rq.resellerId);
                                if(!String.isBlank(rq.distributorId)){
                                    newQuoteRequestCase.Channel_Partner__c=rq.distributorId;
                                    system.debug('rq.distributorId'+rq.distributorId);
                                }
                                newQuoteRequestCase.Status=CASE_STATUS_OPEN;
                                newQuoteRequestCase.Request_Type__c=CASE_REQUEST_TYPE;
                                if(!String.isBlank(rcc.requestedBy)){
                                    newQuoteRequestCase.AccountId=rcc.requestedBy; //Added as part of Code Drop 2(Requested By field on Case)
                                }
                                system.debug('rq.quoteId????'+rq.quoteId);
                                if(rq.quoteId==null || rq.quoteId.equals(BLANK_VALUE)){
                                    //if Quote Id is blank then Request Sub-type is REVISION
                                    newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_NEW;
                                }else{
                                    //if Quote Id is blank then Request Sub-type is NEW
                                    //Added by manu-BUG-00124692-Start
                                    if(rq.popup!=null && rq.popup=='true')
                                    {
                                            if(rq.consolidation!=null && rq.consolidation=='true')
                                            {
                                                newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_REVISION;
                                            }
                                            else if(rq.consolidation!=null && rq.consolidation=='false')
                                            {
                                                newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_NEW;
                                            }
                                    }
                                    else if(rq.popup!=null && rq.popup=='false')
                                    {
                                            newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_REVISION;
                                    }
                                    //Added by manu-BUG-00124692-Ends 
                                    newQuoteRequestCase.Reason_for_Update__c=rq.snsLevel+','+rq.duration;
                                }
                                if(caseRecordtypeId!=null){
                                    newQuoteRequestCase.RecordTypeId=caseRecordtypeId;
                                }
                                /*for(distributorContact dc:rcc.distributorContacts){
                                    //comma separated list of email ids of Distributor Contacts
                                    if(distributorContactsEmail==null && flag==false){
                                        distributorContactsEmail=dc.email;
                                        flag=true;
                                    }else if(flag==true){
                                        distributorContactsEmail=distributorContactsEmail+COMMA_COMPARE+dc.email;
                                    }
                                }
                                if(!String.isBlank(distributorContactsEmail)){
                                    //newQuoteRequestCase.Email_Address__c=distributorContactsEmail;
                                }*/
                                newQuoteRequestCase.Email_Address__c=UserInfo.getUserEmail();
                                if(!String.isBlank(rcc.eaNumber)){
                                    newQuoteRequestCase.EA_Number__c=rcc.eaNumber;
                                    if((rcc.distributorContacts).size()>0 && !(rcc.distributorContacts.isEmpty())){
                                        mapOfContractNumberAndDistributorContacts.put(rcc.eaNumber,rcc.distributorContacts);//this would be used to insert Distributor Contacts for corresponding cases.
                                        system.debug('mapOfContractNumberAndDistributorContacts>>'+mapOfContractNumberAndDistributorContacts);
                                    }
                                }
                                if(!String.isBlank(rcc.eaName)){
                                    newQuoteRequestCase.EA_Name__c=rcc.eaName;
                                }
                                if(!String.isBlank(rcc.contractNumber)){
                                    newQuoteRequestCase.Vmware_Contract_Number__c=rcc.contractNumber;
                                }
                                newQuoteRequestCase.GSS_Support_Level__c=rq.snsLevel;
                                if((!String.isBlank(rq.duration)) && rq.duration.equalsIgnorecase(DURATION_1AND3YEAR)){
                                    newQuoteRequestCase.Duration_Level__c=DURATION_1YEAR;
                                }else{
                                    newQuoteRequestCase.Duration_Level__c=rq.duration;
                                }
                                if(!String.isBlank(rq.endDate)){
                                    //Modified by manu-CR-00119296-Start
                                    String month=(rq.endDate).substringBefore(SLASH_COMPARE);
                                    String day=(rq.endDate).substringBetween(SLASH_COMPARE);
                                    String year=(rq.endDate).substringAfterLast(SLASH_COMPARE).substringBefore(SPACE_COMPARE);
                                    //Modified by manu-CR-00119296-End
                                    newQuoteRequestCase.Contract_End_Date__c=date.valueof (year + HYPHEN_COMPARE + month + HYPHEN_COMPARE + day); 
                                }
                                //newQuoteRequestCase.Partner_Notes__c=rq.other; commented as part of BUG-00094543 and added the below field "Description"
                                newQuoteRequestCase.Description=rq.other;
                                newQuoteRequestCase.Remove_Instance__c=rq.removeInstance;
                                newQuoteRequestCase.Q11_SnS__c=rq.otherSnsLevel;
                                newQuoteRequestCase.Origin=CASE_ORIGIN;
                                newQuoteRequestCase.Priority=CASE_PRIORITY;
                                newQuoteRequestCase.Description_Short__c=rcc.notesToDistributor;
                                //Setting the DMLOption on Case instance
                                if(dmlOpts != null){
                                    newQuoteRequestCase.setOptions(dmlOpts); 
                                }  
                                
                                //Added by Manu-CR-00110431-Start
                                /*newQuoteRequestCase.Make_Quote_Active__c=rq.refreshQuoteExpiration;
                                  newQuoteRequestCase.Reason_for_Update__c=rq.revisionReason;
                                  newQuoteRequestCase.CurrencyIsoCode=rq.currencyCustom; 
                                 */
                                if(rq.refreshQuoteExpiration!=null)
                                {
                                newQuoteRequestCase.Make_Quote_Active__c=rq.refreshQuoteExpiration;
                                }
                                
                                if(rq.revisionReason!=null && rq.revisionReason!='')
                                {
                                newQuoteRequestCase.Reason_for_Update__c=rq.revisionReason;
                                }
                                
                                if(rq.currencyCustom!=null && rq.currencyCustom!='')
                                {
                                newQuoteRequestCase.CurrencyIsoCode=rq.currencyCustom;                              
                                }
                                //Added by Manu-CR-00110431-End
                                
                                system.debug('newQuoteRequestCase>>>>'+newQuoteRequestCase);
                                
                                
                                
                                listOfCasesCreated.add(newQuoteRequestCase);
                                
                                //creating a separate case if duration is 1 & 3 Year otherwise only a single case gets created.
                                if((!String.isBlank(rq.duration)) && rq.duration.equalsIgnorecase(DURATION_1AND3YEAR)){
                                    newQuoteRequestCase=new Case();
                                    
                                    
                                        //added by manu-CR-00120689-start
                                        String temp1='';
                                        if(rq.quoteId!=null && rq.quoteId!='' && quoteIdMap!=null && quoteIdMap.size()>0 && quoteIdMap.get(rq.quoteId)!=null )
                                        {
                                                temp1=quoteIdMap.get(rq.quoteId).name;
                                                if(temp1!=null && temp1!='')
                                                {
                                                    if(temp1.contains('-R'))
                                                    {
                                                        temp1=temp1.substring(temp1.indexOf('-R')+1,temp1.length());
                                                        newQuoteRequestCase.Modifier__c=temp1;
                                                        //system.debug('########newQuoteRequestCase.Modifier__c'+newQuoteRequestCase.Modifier__c);
                                                    }
                                                    
                                                }
                                        }
                                        //added by manu-CR-00120689-start
                                    
                                    
                                    if(userAccount.Is_Distributor_Account__c){
                                        newQuoteRequestCase.Partner_Type__c=DISTRIBUTOR_PARTNER;
                                    }
                                    else if(userAccount.Is_Reseller_Account__c){
                                        newQuoteRequestCase.Partner_Type__c=RESELLER_PARTNER;
                                    }
                                    newQuoteRequestCase.Channel_Partner_PRMID__c=userAccount.Id;
                                    if(!String.isBlank(rq.resellerId)){
                                        newQuoteRequestCase.Channel_Partner__c=rq.resellerId;
                                    }
                                    if(!String.isBlank(rq.distributorId)){
                                        newQuoteRequestCase.Channel_Partner__c=rq.distributorId;
                                    }
                                    newQuoteRequestCase.Status=CASE_STATUS_OPEN;
                                    newQuoteRequestCase.Request_Type__c=CASE_REQUEST_TYPE;
                                    if(!String.isBlank(rcc.requestedBy)){
                                        newQuoteRequestCase.AccountId=rcc.requestedBy; //Added as part of Code Drop 2(Requested By field on Case)
                                    }
                                    system.debug('rq.quoteId????'+rq.quoteId);
                                    if(rq.quoteId==null || rq.quoteId.equals(BLANK_VALUE)){
                                        //if Quote Id is blank then Request Sub-type is REVISION
                                        newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_NEW;
                                    }else{
                                        //if Quote Id is blank then Request Sub-type is NEW
                                        //newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_REVISION;
                                        
                                        //Added by manu-BUG-00124692-Start
                                        if(rq.popup!=null && rq.popup=='true')
                                        {
                                                if(rq.consolidation!=null && rq.consolidation=='true')
                                                {
                                                    newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_REVISION;
                                                }
                                                else if(rq.consolidation!=null && rq.consolidation=='false')
                                                {
                                                    newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_NEW;
                                                }
                                        }
                                        else if(rq.popup!=null && rq.popup=='false')
                                        {
                                                newQuoteRequestCase.Request_Sub_Type__c=CASE_REQUEST_SUB_TYPE_REVISION;
                                        }
                                        //Added by manu-BUG-00124692-Ends 
                                        
                                        newQuoteRequestCase.Reason_for_Update__c=rq.snsLevel+','+rq.duration;
                                    }
                                    if(caseRecordtypeId!=null){
                                        newQuoteRequestCase.RecordTypeId=caseRecordtypeId;
                                    }
                                    /*for(distributorContact dc:rcc.distributorContacts){
                                        //comma separated list of email ids of Distributor Contacts
                                        if(distributorContactsEmail==null && flag==false){
                                            distributorContactsEmail=dc.email;
                                            flag=true;
                                        }else if(flag==true){
                                            distributorContactsEmail=distributorContactsEmail+COMMA_COMPARE+dc.email;
                                        }
                                    }
                                    if(!String.isBlank(distributorContactsEmail)){
                                        //newQuoteRequestCase.Email_Address__c=distributorContactsEmail;
                                    }*/
                                    newQuoteRequestCase.Email_Address__c=UserInfo.getUserEmail();
                                    if(!String.isBlank(rcc.eaNumber)){
                                        newQuoteRequestCase.EA_Number__c=rcc.eaNumber;
                                        if((rcc.distributorContacts).size()>0 && !(rcc.distributorContacts.isEmpty())){
                                            mapOfContractNumberAndDistributorContacts.put(rcc.eaNumber,rcc.distributorContacts);//this would be used to insert Distributor Contacts for corresponding cases.
                                            system.debug('mapOfContractNumberAndDistributorContacts>>'+mapOfContractNumberAndDistributorContacts);
                                        }
                                    }
                                    if(!String.isBlank(rcc.eaName)){
                                        newQuoteRequestCase.EA_Name__c=rcc.eaName;
                                    }
                                    if(!String.isBlank(rcc.contractNumber)){
                                        newQuoteRequestCase.Vmware_Contract_Number__c=rcc.contractNumber;
                                    }
                                    newQuoteRequestCase.GSS_Support_Level__c=rq.snsLevel;
                                    newQuoteRequestCase.Duration_Level__c=DURATION_3YEAR;
                                    if(!String.isBlank(rq.endDate)){
                                        //Modified by manu-CR-00119296-Start
                                        String month=(rq.endDate).substringBefore(SLASH_COMPARE);
                                        String day=(rq.endDate).substringBetween(SLASH_COMPARE);
                                        String year=(rq.endDate).substringAfterLast(SLASH_COMPARE).substringBefore(SPACE_COMPARE);
                                        //Modified by manu-CR-00119296-End
                                        newQuoteRequestCase.Contract_End_Date__c=date.valueof (year + HYPHEN_COMPARE + month + HYPHEN_COMPARE + day); 
                                    }
                                    //newQuoteRequestCase.Partner_Notes__c=rq.other; commented as part of BUG-00094543 and added the below field "Description"
                                    newQuoteRequestCase.Description=rq.other;
                                    newQuoteRequestCase.Remove_Instance__c=rq.removeInstance;
                                    newQuoteRequestCase.Q11_SnS__c=rq.otherSnsLevel;
                                    newQuoteRequestCase.Origin=CASE_ORIGIN;
                                    newQuoteRequestCase.Priority=CASE_PRIORITY;
                                    newQuoteRequestCase.Description_Short__c=rcc.notesToDistributor;
                                    newQuoteRequestCase.GSS_IsFeature_Available__c=true;
                                    //Setting the DMLOption on Case instance
                                    if(dmlOpts != null){
                                        newQuoteRequestCase.setOptions(dmlOpts); 
                                    }  
                                    //Added by Manu-CR-00110431-Start
                                    /*newQuoteRequestCase.Make_Quote_Active__c=rq.refreshQuoteExpiration;
                                    newQuoteRequestCase.Reason_for_Update__c=rq.revisionReason;
                                    newQuoteRequestCase.CurrencyIsoCode=rq.currencyCustom; */
                                    if(rq.refreshQuoteExpiration!=null)
                                    {
                                    newQuoteRequestCase.Make_Quote_Active__c=rq.refreshQuoteExpiration;
                                    }
                                    
                                    if(rq.revisionReason!=null && rq.revisionReason!='')
                                    {
                                    newQuoteRequestCase.Reason_for_Update__c=rq.revisionReason;
                                    }
                                    
                                    if(rq.currencyCustom!=null && rq.currencyCustom!='')
                                    {
                                    newQuoteRequestCase.CurrencyIsoCode=rq.currencyCustom;                              
                                    }       
                                    //Added by Manu-CR-00110431-End                                
                                    
                                    system.debug('newQuoteRequestCase>>>>'+newQuoteRequestCase);

                                    listOfCasesCreated.add(newQuoteRequestCase);
                                }
                            }
                        }                       
                        
                    }
                    if(revisedQuotesSizeZero==true){
                        RequestNotCreated=true; //Request(i.e. case) can only be created if 'Other' is selected in Duration (and/or SnS) or in Revised Quotes scenario
                        system.debug('revisedQuotesSizeZero>>>'+revisedQuotesSizeZero);
                    }
                }
                if(listOfCasesCreated.size()>0){
                    system.debug('cases generated>>'+listOfCasesCreated);
                    srList = Database.insert(listOfCasesCreated, false);
                }
                Set<Id> caseIds=new Set<Id>();
                for(Database.SaveResult sr:srList){
                    if(sr.isSuccess()){
                        system.debug('case id>>'+sr.getId());
                        caseIds.add(sr.getId());
                    }else{
                        system.debug('case error>>'+sr.getErrors());
                    }
                }
                List<Id> caseIdList=new List<Id>();
                List<Case> casesCreated=new List<Case>([select CaseNumber,EA_Number__c, EA_Name__c, Vmware_Contract_Number__c, GSS_Support_Level__c, Duration_Level__c, Contract_End_Date__c from Case where Id IN: caseIds limit 10000]);
                for(Case c:casesCreated){
                    caseIdList.add(c.Id);
                    ResCaseList rCase=new ResCaseList();
                    rCase.requestNumber=c.CaseNumber;
                    rCase.id=c.Id;
                    //CR-00135058 - Added response parameters - START
                    rCase.eaName=c.EA_Name__c;
                    rCase.eaNumber=c.EA_Number__c;
                    rCase.contractNumber=c.Vmware_Contract_Number__c;
                    rCase.supportLevel=c.GSS_Support_Level__c;
                    rCase.duration=c.Duration_Level__c;
                    if(c.Contract_End_Date__c != null){
                        rCase.endDate=RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(c.Contract_End_Date__c,SEPARATOR_HYPHEN);
                    }else{
                        rCase.endDate='';
                    }
                    //CR-00135058 - Added response parameters - END
                    responseCaseList.add(rCase);
                    //resCaseCreation.id.add(c.Id);
                    system.debug('mapOfContractNumberAndDistributorContacts.get(c.EA_Number__c)?????'+mapOfContractNumberAndDistributorContacts.get(c.EA_Number__c));
                    //logic to create Distributor Contacts for each inserted case
                    if((mapOfContractNumberAndDistributorContacts.get(c.EA_Number__c)!=null) && (!String.isBlank(c.EA_Number__c))){
                        List<distributorContact> listOfDCforCase=new List<distributorContact>();
                        listOfDCforCase.addAll(mapOfContractNumberAndDistributorContacts.get(c.EA_Number__c));
                        system.debug('mapOfContractNumberAndDistributorContacts.get(c.EA_Number__c)>>>'+mapOfContractNumberAndDistributorContacts.get(c.EA_Number__c));
                    
                        system.debug(c.EA_Number__c);
                        for(distributorContact dc:listOfDCforCase){
                            distributorC=new Distributor_Contact__c();  
                            system.debug('dc.email>>'+dc.email);
                            system.debug('dc.name>>'+dc.name);
                            if((!String.isBlank(dc.email))&&(!String.isBlank(dc.name))){
                                distributorC.Email__c=dc.email;
                                distributorC.Name=dc.name;
                                distributorC.primary_contact__c=dc.bPrimary;
                                distributorC.Request__c=c.id;
                                
                                //Addded by Manu-RS2 H2 - CR-00135058-Start
                                distributorC.RS2_Unique_Key__c = c.id +'#'+dc.email; //Case Id + Email Id
                                //Addded by Manu-RS2 H2 - CR-00135058-End
                                distributorContactList.add(distributorC);//this list would be inserted at the end to create Distributor Contacts for each Case
                                system.debug('distributorContactList>>>'+distributorContactList);
                            }
                        }
                        listOfDCforCase.clear();
                    }
                }
                //added by manu-BUG-00107043-start
                List<Distributor_Contact__c> disConList=new List<Distributor_Contact__c>();
                List<Distributor_Contact__c> distributorContactList2=new List<Distributor_Contact__c>();
                Map<String,List<Distributor_Contact__c>> DisConMap=new Map<String,List<Distributor_Contact__c>>();
                Map<String,String> DistContNewAndOldValueMap=new Map<String,String>();
                //Making a map of old and new values of distributor contacts sent in request
                for(requestCaseCreation rcc:deserializedCaseInfo)
                {
                    for(distributorContact distContObj:rcc.distributorContacts)
                    {
                            if(distContObj.olddata!=null && distContObj.olddata!='')
                            {
                                DistContNewAndOldValueMap.put(distContObj.name+distContObj.email,distContObj.olddata);
                                //System.debug('Map of old and new values from request'+DistContNewAndOldValueMap);
                            }
                    }
                }
                disConList=[select id,name,createdbyid,Email__c,primary_contact__c,Request__c from Distributor_Contact__c where createdbyid=:userinfo.getUserId()];
                for(Distributor_Contact__c distConObj:disConList)
                {
                    if(DisConMap.get(distConObj.name+SPLITVALUE+distConObj.Email__c)==null)
                    {
                    List<Distributor_Contact__c> tempDistContList=new List<Distributor_Contact__c>();
                    tempDistContList.add(distConObj);
                    DisConMap.put(distConObj.name+SPLITVALUE+distConObj.Email__c,tempDistContList);
                    //System.debug('Map od name+email and distributor object@@@@@@@@@@@'+DisConMap);
                    }
                    else if(DisConMap.get(distConObj.name+SPLITVALUE+distConObj.Email__c)!=null)
                    {
                    List<Distributor_Contact__c> tempDistContList=DisConMap.get(distConObj.name+SPLITVALUE+distConObj.Email__c);
                    tempDistContList.add(distConObj);
                    DisConMap.put(distConObj.name+SPLITVALUE+distConObj.Email__c,tempDistContList);
                    }
                }
                String temp;
                String temp2;
                String oldValueFromMap;
                distributorContactList2.addAll(distributorContactList);
                for(Distributor_Contact__c distConObj2:distributorContactList2)
                {
                    temp=distConObj2.name+distConObj2.Email__c;
                    System.debug('Printing temp value###########'+temp);
                    if(DistContNewAndOldValueMap.get(temp)!=null)
                    {
                        oldValueFromMap=DistContNewAndOldValueMap.get(temp);
                        if(DisConMap.get(oldValueFromMap)!=null)
                        {
                            //distConObj2.id=DisConMap.get(temp).id;
                            //List<String> oldAndNewValueHashed=oldValueFromMap.split(SPLITVALUE);
                            List<Distributor_Contact__c> tempDistContList=DisConMap.get(oldValueFromMap);
                            for(Distributor_Contact__c dc:DisConMap.get(oldValueFromMap))
                            {
                                Distributor_Contact__c DistContObj=dc;
                                DistContObj.name=distConObj2.name;                      
                                DistContObj.Email__c=distConObj2.Email__c;
                                DistContObj.primary_contact__c=distConObj2.primary_contact__c;
                                
                                //Addded by Manu-RS2 H2 - CR-00135058-Start
                                DistContObj.RS2_Unique_Key__c=DistContObj.Request__c+'#'+distConObj2.Email__c;
                                //Addded by Manu-RS2 H2 - CR-00135058-End
                                
                                distributorContactList.add(DistContObj);
                                //System.debug('inside condition###########'+'old object values'+DistContObj+'DistContObj.name'+DistContObj.name+' : '+'DistContObj.Email__c '+DistContObj.Email__c);
                            }
                        }
                    }
                }
                //added by manu-BUG-00107043-end
                //to create Distributor Contacts for each Case
                if(distributorContactList.size()>0 && !(distributorContactList.isEmpty())){
                   //modified by manu-BUG-00107043-start 
                    //srDCList=Database.insert(distributorContactList, false);
                    Database.upsert(distributorContactList, false);
                   //modified by manu-BUG-00107043-end
                   // RS2_RCMCommonUtility.sendEmailDistContact(caseIdList);
                    //system.debug('distributorContactList>>>>'+distributorContactList);
                }
                if(responseCaseList!=null && responseCaseList.size()>0){
                    caseJSON.status=SUCCESS_STATUS;
                    caseJSON.data=responseCaseList;
                    caseJSON.message=BLANK_VALUE;
                }else{
                    if(RequestNotCreated==false){
                        caseJSON.status=ERROR_STATUS;
                        caseJSON.data=responseCaseList;
                        caseJSON.message=System.Label.RS2_RCM_RequestNotCreated;
                    }else if(RequestNotCreated==true){
                        caseJSON.status=ERROR_STATUS;
                        caseJSON.data=responseCaseList;
                        caseJSON.message=System.Label.RS2_RCM_RequestNotCreatedNoRevision;
                    }
                }
                String res=JSON.serialize(caseJSON);
                return res;
            }
            
            /*
            @description JSON Request format for getSimilarExistingCase() is List of requestCaseSearch instances. RS2 H2 - CR-00135058
            */
            public class requestCaseSearch{
                public String contractNumber;
                public String supportLevel;
                public String durationLevel;
                public String endDate;
                public String currencyCustom; // Added as part of IBS-366 - Soumya Behera
            }
            
            /*
            @description attribute 'existingCaseList' in ContractNumWithExistingCase is List of ExistingCase instances. RS2 H2 - CR-00135058
            */
            public class ExistingCase{
                public String requestNumber;
                public string id;
                public string requestedBy;
                public string requestedByEmail;
                public string requestedDate;                
                public string eaName;
                public string eaNumber;
                public string contractNumber;
                public string supportLevel;
                public string duration;
                public string endDate;
            }
            
            /*
            @description attribute 'data' in JSONResponseForExistingCase is List of ContractNumWithExistingCase instances. RS2 H2 - CR-00135058
            */
            public class ContractNumWithExistingCase{
                public String contractNumber;
                public List<ExistingCase> existingCaseList;
            }
            
            /*
            @description JSON Response format for getSimilarExistingCase(). RS2 H2 - CR-00135058
            */
            public class JSONResponseForExistingCase{
                public String status;
                public List<ContractNumWithExistingCase> data;
                public String message;
            }
            
            //CR-00135058 - Variable Declaration -STARTS
            public List<requestCaseSearch> deserializedJSONRequest = new List<requestCaseSearch>();
            public JSONResponseForExistingCase caseJSON2 = new JSONResponseForExistingCase();
            //CR-00135058 - Variable Declaration -ENDS
            
            /*
            @description Method added to get Similar case if one exists when the Quote is not found. RS2 H2 - CR-00135058
            @return String
            @param None
            */
            public String getSimilarExistingCase()
            {
              if(postData!=null){
                deserializedJSONRequest = (List<requestCaseSearch>)JSON.deserialize(postData, List<requestCaseSearch>.class);
              }
              RS2_RequestsController rs2_RequestsControllerInstance = new RS2_RequestsController();
              this.partner = ApexPages.CurrentPage().getParameters().get('partner');
              
              ExistingCase existingCaseRec;
              List<ExistingCase> existingCaseListData = new List<ExistingCase>();
              contractNumWithExistingCase contractNumWithExistingCaseRecord = new ContractNumWithExistingCase();
              List<ContractNumWithExistingCase> contractNumWithExistingCaseList = new List<ContractNumWithExistingCase>();
              String userId = UserInfo.getUserId();
              Set<String> partnerIdSet = new Set<String>();
              list<Distributor_Contact__c> distContactList = new list<Distributor_Contact__c>();
              Distributor_Contact__c distContact;
              List<Case> retrievedCaseList = new List<Case>();
              Map<string, List<Case>> contractNumCaseLstMap = new Map<string, List<Case>>();
              Set<string> uniqueIdentifierSet = new Set<string>();
              List<string> dateStrList = new List<string>();
              string uniqueKey = '';
              string uniqueIdentifier = '';
              string dateString = '';
              string blankEndDateStr = 'blankEndDate';
              date endDate;
              
              Set<String> contractNumSet = new Set<String>();
              Set<String> supportLevelSet = new Set<String>();
              Set<String> durationLevelSet = new Set<String>();
              Set<String> currencyValueSet = new Set<String>(); // Added as part of IBS-366 - Soumya Behera
              
              //populating the sets to be used in case query and uniqueIdentifierSet to segregate eligible cases from all the retrieved cases
              for(requestCaseSearch reqCaseSearch : deserializedJSONRequest){
                    contractNumSet.add(reqCaseSearch.contractNumber);
                    supportLevelSet.add(reqCaseSearch.supportLevel);
                    currencyValueSet.add(reqCaseSearch.currencyCustom); // Added as part of IBS-366 - Soumya Behera
                    //in case of Duration = '1 and 3 Year'
                    if(DURATION_1AND3YEAR.equalsIgnoreCase(reqCaseSearch.durationLevel)){
                        //add both '1 year' and '3 year' in the set to query for duplicate cases
                        durationLevelSet.add(DURATION_1YEAR);
                        durationLevelSet.add(DURATION_3YEAR);
                        
                        //add both the combinations to uniqueIdentifierSet
                        uniqueIdentifier = reqCaseSearch.contractNumber +'#'+ reqCaseSearch.supportLevel +'#'+ DURATION_1YEAR +'#'+ blankEndDateStr+'#'+reqCaseSearch.currencyCustom; //Added currency as part of IBS-366 - Soumya Behera
                        uniqueIdentifierSet.add(uniqueIdentifier.toLowerCase());
                        uniqueIdentifier = reqCaseSearch.contractNumber +'#'+ reqCaseSearch.supportLevel +'#'+ DURATION_3YEAR +'#'+ blankEndDateStr+'#'+reqCaseSearch.currencyCustom; // Added currency as part of IBS-366 - Soumya Behera
                        uniqueIdentifierSet.add(uniqueIdentifier.toLowerCase());
                    }
                    else if(COMPARISON_VALUE.equalsIgnoreCase(reqCaseSearch.durationLevel)){
                        //add the date value to the uniqueIdentifier also when the duration is 'Other'
                        durationLevelSet.add(COMPARISON_VALUE);
                        
                        if(String.isNotBlank(reqCaseSearch.endDate)){
                            dateStrList = reqCaseSearch.endDate.split(SEPARATOR_HYPHEN); //date format from request is mm/dd/yyyy
                            endDate = Date.newInstance(Integer.valueOf(dateStrList[2]), Integer.valueOf(dateStrList[0]), Integer.valueOf(dateStrList[1])); //date.newinstance(year, month, date)
                            
                            uniqueIdentifier = reqCaseSearch.contractNumber +'#'+ reqCaseSearch.supportLevel +'#'+ COMPARISON_VALUE +'#'+ endDate.format()+'#'+reqCaseSearch.currencyCustom; //Added currency as part of IBS-366 - Soumya Behera
                            uniqueIdentifierSet.add(uniqueIdentifier.toLowerCase());
                        }
                    }
                    else{
                        //add the values from the request if it's not '1 and 3 Year' or 'Other'
                        durationLevelSet.add(reqCaseSearch.durationLevel);
                        
                        uniqueIdentifier = reqCaseSearch.contractNumber +'#'+ reqCaseSearch.supportLevel +'#'+ reqCaseSearch.durationLevel +'#'+ blankEndDateStr+'#'+reqCaseSearch.currencyCustom; //  Added currency as part of IBS-366 - Soumya Behera
                        uniqueIdentifierSet.add(uniqueIdentifier.toLowerCase());
                    }
              }
              
              //getting values from custom settings
              String renewalsRecordType = Record_Type_Settings__c.getInstance('CaseRenewalOperations').Record_Type_ID__c;
              String CustomerRequests = Parameters__c.getInstance('Request Origin Customer').UI_Mapping__c;
              String PartnerRequests = Parameters__c.getInstance('Request Origin Partner').UI_Mapping__c;

              //populate partnerIdSet set
              if(partner=='-1')
              {
                partnerIdSet = rs2_RequestsControllerInstance.retrievePRMIDs(userId);
              }
              else
              {
                partnerIdSet.add(partner);
              }
              
              //querying for similar cases that are not closed
              // Added condtion of CurrencyISOcode as part of IBS 366 by Soumya Behera
              for(case caseRec : [SELECT Id, CaseNumber, CreatedById, CreatedBy.Name, CreatedBy.Email, CreatedDate, Email_Address__c, Vmware_Contract_Number__c, GSS_Support_Level__c, Duration_Level__c, Contract_End_Date__c, EA_Name__c, EA_Number__c FROM Case WHERE RecordTypeId = :renewalsRecordType AND (Origin= :CustomerRequests OR Origin = :PartnerRequests) AND (CreatedById=:userId OR Case.Account.Partner_ID__c IN :partnerIdSet) AND Vmware_Contract_Number__c  IN: contractNumSet AND GSS_Support_Level__c IN: supportLevelSet AND Duration_Level__c IN: durationLevelSet AND CurrencyIsoCode IN: currencyValueSet AND isclosed=false order by lastModifiedDate desc]){
                    if(caseRec.Contract_End_Date__c != null){
                        dateString = caseRec.Contract_End_Date__c.format();
                    }else{
                        dateString = blankEndDateStr;
                    }
                    uniqueKey = '';
                    uniqueKey = caseRec.Vmware_Contract_Number__c +'#'+ caseRec.GSS_Support_Level__c +'#'+ caseRec.Duration_Level__c +'#'+ dateString+'#'+caseRec.CurrencyIsoCode; // added CurrencyIsoCode as part of IBS 366 by Soumya Behera
                    //adding only the cases that satisfy all the 3 criteria of Contract Number, Support Level and Duration 
                    if(String.isNotBlank(uniqueKey) && uniqueIdentifierSet.contains(uniqueKey.toLowerCase())){
                        if(!contractNumCaseLstMap.isEmpty() && contractNumCaseLstMap.containsKey(caseRec.Vmware_Contract_Number__c)){
                            contractNumCaseLstMap.get(caseRec.Vmware_Contract_Number__c).add(caseRec);
                        }
                        else{
                            contractNumCaseLstMap.put(caseRec.Vmware_Contract_Number__c, new List<Case>{caseRec});
                        }
                    }
              }
              
              //Iterating the Eligible cases to populate the response
              if(!contractNumCaseLstMap.isEmpty()){
                    for(string contractNum : contractNumCaseLstMap.keySet()){
                        existingCaseListData = new List<ExistingCase>();
                        contractNumWithExistingCaseRecord = new ContractNumWithExistingCase();
                        
                        for(case caseRecord : contractNumCaseLstMap.get(contractNum)){
                            existingCaseRec = new ExistingCase();
                            
                            existingCaseRec.requestNumber = caseRecord.CaseNumber;
                            existingCaseRec.id = caseRecord.id;
                            existingCaseRec.requestedBy = caseRecord.CreatedBy.Name;
                            existingCaseRec.requestedByEmail = caseRecord.CreatedBy.Email;
                            existingCaseRec.requestedDate = RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(caseRecord.CreatedDate.date(),SEPARATOR_HYPHEN); //converting from DateTime to Date to String                            
                            existingCaseRec.duration = caseRecord.Duration_Level__c;
                            existingCaseRec.eaName = caseRecord.EA_Name__c;
                            existingCaseRec.eaNumber = caseRecord.EA_Number__c;
                            existingCaseRec.contractNumber = caseRecord.Vmware_Contract_Number__c;
                            existingCaseRec.supportLevel = caseRecord.GSS_Support_Level__c;
                            if(caseRecord.Contract_End_Date__c != null){
                                existingCaseRec.endDate = RS2_RCMCommonUtility.formatDateWithSpecifiedSymbol(caseRecord.Contract_End_Date__c,SEPARATOR_HYPHEN);
                            }else{
                                existingCaseRec.endDate = '';
                            }
                            
                            existingCaseListData.add(existingCaseRec);
                            
                            //Do not create Distributor Contact for the user who was the original requestor. BUG-00131629
                            if(caseRecord.CreatedById != UserInfo.getUserId()){
                                //creating Distributor Contact record for each case
                                distContact = new Distributor_Contact__c();
                                distContact.Request__c = caseRecord.id;
                                distContact.Email__c = UserInfo.getUserEmail();
                                distContact.Name = UserInfo.getName();
                                distContact.RS2_Unique_Key__c = caseRecord.id +'#'+UserInfo.getUserEmail(); //Case Id + Email Id
                                distContactList.add(distContact);
                            }
                        }
                        contractNumWithExistingCaseRecord.contractNumber = contractNum;
                        contractNumWithExistingCaseRecord.existingCaseList = existingCaseListData;
                        contractNumWithExistingCaseList.add(contractNumWithExistingCaseRecord);
                    }
              }
              
              //upsert distContactList. Changed from insert to upsert for BUG-00131629
              if(!distContactList.isEmpty()){
                    Database.UpsertResult[] urList = Database.upsert(distContactList, Distributor_Contact__c.RS2_Unique_Key__c, false);
                    if(!urList.isEmpty()){
                        RS2_OpptyIDUtill.insertHandledExceptions(null, null, urList, 'ApexClass', 'RCM_QuoteRequest', 'getSimilarExistingCase');
                    }
              }
              
              //if case was found, add the data and mark the status as success
              if(!contractNumWithExistingCaseList.isEmpty()){
                    caseJSON2.status = SUCCESS_STATUS;
                    caseJSON2.data = contractNumWithExistingCaseList;
                    caseJSON2.message = null;
              }else{
                    caseJSON2.status = ERROR_STATUS;
                    caseJSON2.data = Null;
                    caseJSON2.message = System.Label.RS2_H2_NoCasesFound;
              }
              String res=JSON.serialize(caseJSON2); 
              return res;
            }
        }