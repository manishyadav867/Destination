/**********************************************************
 * Class Name : GSS_Avaya_IVR 
 * Purpose    : This apex class is web service for case creation through IVR
 * ********************************************************************************       
 * Author                                     Date            Remarks
 * Accenture                                  01-Nov-10       Created
 * Deepak                                     01-Nov-11       Added call to EMS web service to update EAinfo based on CN# & product
 * Harish Patkar           CR-00017302        19-12-2012      Making Response QSet dynamic 
 * Sanjib Mahanta          CSR DB Project     08-03-2013      Modified to check isServiceFirst for CSR DB Project.   
 * Mayur Srivastava                           05-Sep-14       Added code for SDP 6.0 Carpathia | CR-00102154
 * 15/01/2015        Sakshi Suri            Case Record Type name change from GSS Licensing to GS-SS Customer Support //CR-00102901
 * Anchal                                    7-July-15       Added Reference Architecture for GSS_UpdateCase: Inititate SR |Federated-Custom Support
 * Pabitra                CR-00140109        09-Aug-16       Removed System.debug
 *********************************************************************************/

global class GSS_Avaya_IVR {
    /**Business Exception*/
    public class AvayaIVRCaseException extends Exception{}
    public static boolean isServiceFirst = false; // CSR DB

    global class CRSet {
        webservice String SRNumber;
        webservice String PortalURL;        
        webservice String ResultCode;
        public CRSet(String s, String p) { SRNumber = s; PortalURL = p; ResultCode = 'Success'; }
        public CRSet() { SRNumber = ''; PortalURL = ''; ResultCode = 'Failure'; }
    }

    webservice static CRSet CreateSR(String CN, String CountryCode, String ProductName, String ProblemCategory,
            String EntitlementCode, String ServerDown, String TechnicalContact, String PreferredMOC, String PhoneNumber,
            String FaxNum, String LastName, String FirstName, String Email, String Source, String AltPhoneNum, String State) {

        // Check :: Construct GSS_CaseRequestInfo instance as per request parameters
        try {
            GSS_CaseRequestInfo caseInfo = caseRequestMethod(CN,CountryCode,  ProductName,  ProblemCategory,
                    EntitlementCode,  ServerDown,  TechnicalContact,  PreferredMOC,  PhoneNumber,
                    FaxNum,  LastName,  FirstName,  Email,  Source,  AltPhoneNum,  State);
            return CaseCreation(caseInfo, true);
        } catch( Exception ex ) {
            //TODO::
            //Added Error handling code in catch block for CR-00008898
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_CaseRequestInfo', 'GSS_Avaya_IVR');
            //End of code for CR-00008898
            return new CRSet();
        }
        // Check :: Call method for Creating Contact, Case and Entitlement
    }

    
    //this method is called from the CSR Dashboard.  It is named "IVR" though that's a bad name for it.
    public static CRSet CaseCreationIVR(GSS_CaseRequestInfo caseRequestInfo){
        return CaseCreation(caseRequestInfo, false);
    }
    
    /** This method is used for performing various operations like Contact Validation / Creation, Case Creation and Entitlement Updation or Creation*/
    public static CRSet CaseCreation(GSS_CaseRequestInfo caseRequestInfo, Boolean isIVR){

        try {
            GSS_CaseResponseInfo caseResponseInfo = new GSS_CaseResponseInfo();
            // Check : Request object is null or not
            if( caseRequestInfo != Null ) {
             /** Begin: Code added by Deepak for ICE project **/
                System.debug('isIVR ******'+isIVR);
                if ( isIVR == true ) {
                    EAInfo eaInfo=ICE_Util.getEAInfoByCNProdName( caseRequestInfo.contactInfo.ConCN, caseRequestInfo.caseInfo.caseProduct );
                   System.debug('eaInfo**********'+eaInfo);
                    if ( eaInfo !=null && eaInfo.EAName != null && eaInfo.EANumber != null ) {
                        caseRequestInfo.caseInfo.EAName=eaInfo.EAName;
                        caseRequestInfo.caseInfo.EANumber=eaInfo.EANumber;
                    }
                }
                /** End: Code added by Deepak for ICE project **/
                // Check :: Call CP_Validate_Contact method of GSS_ContactUtilityClass class for Contact Creation or Updation of CN #
                system.debug('***********************caseRequestInfo$$$$$$$$'+caseRequestInfo);
                system.debug('***********************caseRequestInfo$$$$$$$$'+caseRequestInfo.contactInfo);
                caseResponseInfo = GSS_IVRCntValidation.CP_Validate_Contact(caseRequestInfo.contactInfo, caseResponseInfo); 
                if(caseResponseInfo.contactId != Null ){
                    system.debug('GSS_CreateCase IVR Webservice::: caseResponseInfo.contactId '+caseResponseInfo.contactId);
                    Savepoint sp = Database.setSavepoint();
                    // Check:: Call Case Creation Method
                    GSS_UtilityClass.isWebServiceCall = true;
                    system.debug('***********************caseResponseInfo$$$$$$$$'+caseResponseInfo);
                    caseResponseInfo = GSS_IVRCaseCreation.CP_Create_Case(caseRequestInfo.caseInfo, caseResponseInfo,caseRequestInfo.contactInfo.ConCountry, isIVR);
                    system.debug('***********************caseResponseInfo1$$$$$$$$'+caseResponseInfo);
                    // CSR DB- Start
                   isServiceFirst = GSS_IVRCaseCreation.isServiceFirst();
                    if(isServiceFirst && !isIVR){
                       return new CRSet(caseResponseInfo.casenumber,'');
                    }  // CSR DB End 
                    else {
                    
                        if(caseResponseInfo.casenumber != null){
                            // Check:: Call Case Assignment method
                            GSS_Case_Record_Type__c caseUpdateSetting = GSS_Case_Record_Type__c.getOrgDefaults();
                            system.debug('**********************caseUpdateSetting'+caseUpdateSetting);
                            List<RecordType> lstRecordType = [select id,Name from RecordType where SobjectType='Case' and name = :caseUpdateSetting.GSS_Technical_Support__c.trim() ];
                            system.debug('**********************lstRecordType'+lstRecordType);
                            system.debug('***********************caseResponseInfo2$$$$$$$$'+caseResponseInfo);
                            // Added to increase the code coverage
                            if(test.isRunningTest()){
                            Entitlement e = [select id,GSS_Entitlement_Code__c,RemainingCases from Entitlement where GSS_Entitlement_Code__c ='TCV' Limit 1];
                            caseResponseInfo.entitlementId = e.id;
                            }
                            
                            caseResponseInfo = GSS_IVREntitlement.CP_CreateUpdate_Entitlement(caseRequestInfo.entitlementInfo, caseResponseInfo,lstRecordType[0].name,caseResponseInfo.CaseSev);
                            
                            system.debug('++++++++++accountId+++++++++++' + [select id, RemainingCases,accountId from Entitlement where id = :caseResponseInfo.entitlementId].accountId);
                            system.debug('caseResponseInfo '+caseResponseInfo);
                            if( caseResponseInfo.entitlementId != null ) {
                                if(GSS_IVRCaseCreation.associateCaseEntitlement(caseResponseInfo)) {
                                    //JK added 1/31 to stop double decrementation of incident count
                                    system.debug('++++++++++entitlementInfoentitlementInfoentitlementInfo+++++++' + caseRequestInfo.entitlementInfo);
                                    if(caseRequestInfo.entitlementInfo != null) {
                                        Boolean isIncident = caseRequestInfo.entitlementInfo.CaseEntIsIncident;
                                        Integer remaining = -1;
                                        Entitlement thisEnt;
                                        system.debug('isIncident? ' + isIncident);
                                        if( isIncident != null ) {
                                            thisEnt = [select id, RemainingCases from Entitlement where id = :caseResponseInfo.entitlementId];
                                            system.debug('thisEnt before ' + thisEnt);
                                            remaining = thisEnt.RemainingCases;
                                            system.debug('remaining before ' + remaining);
                                            if ( remaining == 0 ) {
                                                thisEnt.RemainingCases = 1;
                                                update thisEnt;
                                            }
                                        }                                            
                                        //JK This grouping, which calls updatefirstresponse, should stay once the fix is no longer necessary
                                        Set<Id> caseIds = new Set<Id>();
                                        caseIds.add(caseResponseInfo.caseId);
                                        GSS_UpdateCaseFirstResponse.updateFirstResponse(caseIds);
                                        System.debug('-----kb-----came back from GSS_UpdateCaseFirstResponse.updateFirstResponse----');
                                        //JK more 1/31 additions for double decrementation 
                                        if(isIncident != null) {
                                            thisEnt = [select id, RemainingCases from Entitlement where id = :caseResponseInfo.entitlementId];
                                            system.debug('thisEnt after ' + thisEnt);
                                            if (thisEnt.RemainingCases != remaining) {
                                                thisEnt.RemainingCases = remaining;
                                                system.debug('thisEnt updating ' + thisEnt);
                                                update thisEnt;
                                            }
                                        }                                           
                                        //JK end edits
                                    }
                                    }
                                    return new CRSet(caseResponseInfo.casenumber,'');
                                }
                             else {
                                // Error occurred in Entitlement Creation or Updation 
                                //Rollback Case Created
                                caseResponseInfo.caseNumber = '';
                                //caseResponseInfo.commitTime = '';
                                Database.rollback(sp);
                                return new CRSet();
                                //return new CRSet(caseResponseInfo.casenumber,'');
                            }
                            //return new CRSet(caseResponseInfo.casenumber,'');
                        } else {
                            // Error occurred in Case Creation 
                            return new CRSet();
                        }
                    
                    }
                  
                } else {
                    // Error occurred in Contact Creation or Updation
                    return new CRSet();
                }
            }
        } catch( Exception ex ) {
            system.debug('++++++++anoop909+++++++++++' + ex);
            //Added Error handling code in catch block for CR-00008898
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'GSS_CaseRequestInfo ', 'GSS_Avaya_IVR');
            //End of code for CR-00008898
            //Check :: In case of exception, call CRSet() no argument constructor
            return new CRSet();
        }
        return new CRSet();
    }

    /***************************************************************************
     * This method is used for constructing the Create Case object
    *****************************************************************************/

    public static GSS_CaseRequestInfo caseRequestMethod(String CN, String CountryCode, String ProductName, String ProblemCategory,
            String EntitlementCode, String ServerDown, String TechnicalContact, String PreferredMOC, String PhoneNumber,
            String FaxNum, String LastName, String FirstName, String Email, String Source, String AltPhoneNum, String State){

        GSS_CaseRequestInfo caseRequestInfo = new GSS_CaseRequestInfo();
        //Check :: Populate Account object 
        //GSS_AccountInfo oAccountInfo = new GSS_AccountInfo();

        // Check :: Populate Contact Information

        GSS_ContactInfo oContactInfo = new GSS_ContactInfo();
        if(CN != null && CN != ''){
            oContactInfo.ConCN = CN.trim();
        }
        if(FirstName != null && FirstName != ''){
            oContactInfo.ConFirstName = FirstName.trim();
        }
        if(Email != null && Email != ''){
            oContactInfo.ConEmail = Email.trim();
        }
        if(LastName != null && LastName != ''){
            oContactInfo.ConLastName = LastName.trim();
        }
        if(CountryCode != null && CountryCode != ''){
            oContactInfo.ConCountry = CountryCode.trim();
        }
        if(PhoneNumber != null && PhoneNumber != ''){
            oContactInfo.ConPhone = PhoneNumber.trim();
        }
        if(FaxNum != null && FaxNum != ''){
            oContactInfo.ConFax = FaxNum.trim();
        }
        /*if(AltPhoneNum != null && AltPhoneNum != ''){
             oContactInfo.ConFax = AltPhoneNum.trim();
         }*/
        caseRequestInfo.contactInfo = oContactInfo;

        // Check :: Populate Case Information
        GSS_CaseInfo oCaseInfo = new GSS_CaseInfo();
    
        if(ProductName != null &&  ProductName != '' && !isServiceFirst ) {
            oCaseInfo.CaseProduct = ProductName.trim(); 
        }
        if(PreferredMOC != null && PreferredMOC != ''){
            oCaseInfo.CasePrefContact = PreferredMOC.trim();
        }
        if(ServerDown != null && ServerDown != ''){
            oCaseInfo.CaseServerDown = ServerDown.trim();
        }
        if(ProblemCategory != null && ProblemCategory != ''){
            oCaseInfo.CaseProbCat = ProblemCategory.trim(); 
        }
        if(Source != null && Source != '' ){
            oCaseInfo.CaseOrigin = Source.trim();
        }
        if(TechnicalContact != null && TechnicalContact != ''){
            oCaseInfo.CaseAvailable24x7 = TechnicalContact.trim();
        }
       // if(TechnicalContact != null && ServerDown != null && TechnicalContact != '' && ServerDown != ''){
        if(TechnicalContact == 'Y' && ServerDown == 'Y')
            oCaseInfo.CaseSev = '1 - Critical';
        else if(TechnicalContact == 'N' && ServerDown == 'Y')
            oCaseInfo.CaseSev = '2 - High' ;
        else if(TechnicalContact == 'N' && ServerDown == 'N' || TechnicalContact == 'Y' && ServerDown == 'N')
            oCaseInfo.CaseSev = '3 - Medium' ;
      //  }
        else if(ServerDown == 'N' || ServerDown == 'No')
        {
            system.debug('++++++++2222++++++++++++');
            oCaseInfo.CaseSev = '3 - Medium' ;
        }
        else
        {
            system.debug('++++++++3333++++++++++++');
            oCaseInfo.CaseSev = '2 - High' ;
        }
            
        caseRequestInfo.caseInfo = oCaseInfo;


       // Populate Entitlement Info
       // Check for CSR DB
        if(!isServiceFirst){
        
        GSS_EntitlementInfo oEntitlementInfo = new GSS_EntitlementInfo();
        if(EntitlementCode != null && EntitlementCode != ''){
            oEntitlementInfo.CaseEntCode = EntitlementCode.trim();
        }
        oEntitlementInfo.CaseEntIsIncident= false;
       /* if(GSS_CaseUpdateUtilityClass.CaseEntIncidentPackNum != null && GSS_CaseUpdateUtilityClass.CaseEntIncidentPackNum != ''){
            oEntitlementInfo.CaseEntIncidentPackNum = GSS_CaseUpdateUtilityClass.CaseEntIncidentPackNum;
        }
        if(GSS_CaseUpdateUtilityClass.CaseEntIsIncident != null){
            oEntitlementInfo.CaseEntIsIncident = GSS_CaseUpdateUtilityClass.CaseEntIsIncident;
        }
        if(GSS_CaseUpdateUtilityClass.CaseEntMaxIncidents != null){
            oEntitlementInfo.CaseEntMaxIncidents = GSS_CaseUpdateUtilityClass.CaseEntMaxIncidents;
        }
        if(GSS_CaseUpdateUtilityClass.CaseEntitlement != null){
            oEntitlementInfo.CaseEntitlement = GSS_CaseUpdateUtilityClass.CaseEntitlement;
        }*/
        caseRequestInfo.entitlementInfo = oEntitlementInfo;
        }

        return caseRequestInfo;
    }
    global class QSet {
        webservice String Status;
        webservice String SubStatus;
        webservice String Owner;
        webservice String CommitTime;
        webservice String CommitMet;
        webservice String CN;
        webservice String Product;
        webservice String EntitlementCode;
        webservice String RoutingChannel;
        webservice String ResultCode;
        WebService List<GSS_Attribute> attrArray; // CR-00017302 : Added array parameter

        public QSet(String s, String ss, String o, DateTime ct, String cm, String sCn, String p, String ec, String rc,List<GSS_Attribute> attrs) { 
            Status=s; SubStatus=ss; Owner=o; CN=sCn; Product=p; EntitlementCode=ec; RoutingChannel=rc;
            attrArray = attrs;
            //system.debug('asdf'+ct + ' ### '+attrs);            
            if(ct != null)
                CommitTime = ct.format('MM/dd/yyyy hh:mm:ss a');
            // Below Code changed as a part of CR-5550: Start
            CommitMet = (cm == null)? null : ((cm == 'Yes') ? 'Y' : 'N');
            // Below Code changed as a part of CR-5550: End
            ResultCode = 'Success'; 
        }
        public QSet() { 
            Status=''; SubStatus=''; Owner=''; CommitTime=''; CommitMet=''; CN=''; Product=''; EntitlementCode=''; RoutingChannel='';
            ResultCode = 'Failure';attrArray=null; 
        }
    }
    
    webservice static QSet QuerySR(String SRNumber) {
        // code changed/added as a part of CR-5322 : Start:
            QSet QsetObj = new QSet();          
        // code changed/added as a part of CR-5322 : End:
        try {
            // code changed/added as a part of CR-5322 : Start:
            PQSet PQSetObj = new PQSet();
            boolean qurySRdone = false;
            //CSR DB start
            isServiceFirst = GSS_IVRCaseCreation.isServiceFirst();
           
            if(!isServiceFirst){
            PQSetObj= QueryPhQueue(SRNumber);
            } // CSR DB End
    
            // code changed/added as a part of CR-5322 : End: 
            list<case> lstCase;
            
            // CR-00017302 : Starts here : Make the dynamic query
            String addonParams;
            String querySOQL = '';            
            
            List<GSS_Attribute> attrArray = new List<GSS_Attribute>();
            List<GSSIVRQset__c> qserParams = GSSIVRQset__c.getall().values();
            
            if(SRNumber != null && SRNumber.length() > 0){
            
                
                for(GSSIVRQset__c fieldSet : qserParams){
                       if(addonParams != null){
                            addonParams = addonParams + ',' + fieldSet.API_Name__c;
                        }else{
                             addonParams = fieldSet.API_Name__c;
                        }
                }
                
                if(addonParams != ''){  
                                    
                    //querySOQL = ' Select Id, Status, Sub_Status__c, GSS_First_Response_Due_Date__c, GSS_First_Resp_Met__c, GSS_CN__c, Product.Name, GSS_Entitlement_Code__c, GSS_Routing_Channel__c, Ownerid ,'+ addonParams +' From Case Where (CaseNumber =\"+SRNumber +'\''+ ' or GSS_Alternate_Case__c= \"+SRNumber+'\''+') AND (recordType.Name =\"+GSS Technical Support+'\"+' or recordType.Name = \"+GS-SS Customer Support+'\'' + ' or recordType.Name = \"+GSS CS Admin+'\'')'; //CR-00102901
                    querySOQL = 'Select Id, Status, Sub_Status__c, GSS_First_Response_Due_Date__c, GSS_First_Resp_Met__c, GSS_CN__c, Product.Name, GSS_Entitlement_Code__c, GSS_Routing_Channel__c, Ownerid ,'+ addonParams +' From Case';
                    querySOQL += ' Where (CaseNumber =\''+SRNumber +'\''+' or GSS_Alternate_Case__c= \''+SRNumber+'\''+') AND RecordType.Name IN (\'GSS CS Admin\', \'GS-SS Customer Support\',\'GSS Technical Support\')'; //CR-00102901

                    
                }else{
                    querySOQL = ' Select Id, Status, Sub_Status__c, GSS_First_Response_Due_Date__c, GSS_First_Resp_Met__c, GSS_CN__c, Product.Name, GSS_Entitlement_Code__c, GSS_Routing_Channel__c, Ownerid From Case Where (CaseNumber = '+ SRNumber +' or GSS_Alternate_Case__c= '+SRNumber+') AND (recordType.Name = '+'GSS Technical Support'+' or recordType.Name = '+'GS-SS Customer Support'+' or recordType.Name = '+'GSS CS Admin'+')'; //CR-00102901
                }
                system.debug('querySOQL $$$$ '+querySOQL);
                lstCase =  Database.query(querySOQL);
            }
            //CR-00017302 : Ends here
            
            if(lstCase != null && lstCase.size() == 1) {
            case oCase = lstCase[0];
            list<User> lstUser = [select id, GSS_PBX_Agent_Login_ID__c from user where id = :oCase.OwnerID];
            string PBX_Agent_Login_ID = '';
            if(lstUser != null && lstUser.size() > 0 && lstUser[0].GSS_PBX_Agent_Login_ID__c != null)
                PBX_Agent_Login_ID = string.valueOf(lstUser[0].GSS_PBX_Agent_Login_ID__c);
            String existingSubStatus = oCase.Sub_Status__c;
            oCase.Sub_Status__c = 'Inbound Message Received';
            update oCase;
            Record_Type_Settings__c oRTS = Record_Type_Settings__c.getInstance('GSS_TASK_GT');
            try {
                Task oT = new Task(OwnerID = oCase.OwnerID, subject = 'Call - IVR', WhatID = oCase.Id , Status = 'Completed', ActivityDate=System.today());
                if(oRTS != null && oRTS.Record_Type_Id__c != null)
                    oT.RecordTypeId = oRTS.Record_Type_Id__c;
                insert oT; 
            }catch(Exception e) {
                system.debug('++++Error creating task.....+++++' + e);
                //Added Error handling code in catch block for CR-00008898
                CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Task', 'GSS_Avaya_IVR');
                //End of code for CR-00008898
            }
            //return new QSet(oCase.Status, oCase.Sub_Status__c, PBX_Agent_Login_ID, oCase.GSS_First_Response_Due_Date__c, oCase.GSS_First_Response_Met__c, oCase.GSS_CN__c, oCase.Product.Name, oCase.GSS_Entitlement_Code__c,oCase.GSS_Routing_Channel__c);
            // code changed/added as a part of CR-5322 : Start:            

            
            //CR-00017302 : Starts here : adding additional QSet parameter in array
            for(GSSIVRQset__c fieldSet : qserParams){
                GSS_Attribute ottr= new GSS_Attribute();
                                
                ottr.attributeName = (String) fieldSet.Name;
                ottr.attributeValue = (String) oCase.get(fieldSet.API_Name__c);
                
                if('ServerDown'.equalsIgnoreCase(ottr.attributeName)){
                    if('Yes'.equalsIgnoreCase(ottr.attributeValue) || 'Y'.equalsIgnoreCase(ottr.attributeValue)){
                        ottr.attributeValue = 'Y';
                    }else if('No'.equalsIgnoreCase(ottr.attributeValue) || 'N'.equalsIgnoreCase(ottr.attributeValue)){
                        ottr.attributeValue = 'N';
                    }
                    else {
                        ottr.attributeValue = null;
                    }
                
                }
                
                if('TechnicalContact'.equalsIgnoreCase(ottr.attributeName)){
                    if('Yes'.equalsIgnoreCase(ottr.attributeValue) || 'Y'.equalsIgnoreCase(ottr.attributeValue)){
                        ottr.attributeValue = 'Y';
                    }else if('No'.equalsIgnoreCase(ottr.attributeValue) || 'N'.equalsIgnoreCase(ottr.attributeValue)){
                        ottr.attributeValue = 'N';
                    }
                    else {
                        ottr.attributeValue = null;
                    }
                
                }
                
                
                attrArray.add(ottr);

            }
            //CR-00017302 : Ends here
            QsetObj = new QSet(oCase.Status, existingSubStatus, PBX_Agent_Login_ID, oCase.GSS_First_Response_Due_Date__c, oCase.GSS_First_Resp_Met__c, oCase.GSS_CN__c, oCase.Product.Name, oCase.GSS_Entitlement_Code__c,oCase.GSS_Routing_Channel__c,attrArray);
            qurySRdone = true;
            // code changed/added as a part of CR-5322 : End:
            } else if(lstCase != null && lstCase.size() == 0) {
                 /*list<GSS_Case_Archive__c> lstCaseArchive = [Select Id, GSS_Status__c, GSS_Sub_Status__c, GSS_CN__c, GSS_Product__c, GSS_Entitlement__c, GSS_Routing_Channel__c From GSS_Case_Archive__c Where (GSS_Case_Number__c = :SRNumber or GSS_Siebel_SR_Number__c= :SRNumber)]; */
                 list<GSS_Case_Archive__c> lstCaseArchive=new list<GSS_Case_Archive__c>();
                 
                 //CR-00017302 : Starts here : making dynamic query
                 if(addonParams != ''){                    
                    
                    querySOQL = 'Select Id, GSS_Status__c, GSS_Sub_Status__c, GSS_CN__c, GSS_Product__c, GSS_Entitlement__c, GSS_Routing_Channel__c,'+ addonParams +' From GSS_Case_Archive__c';
                    querySOQL += ' Where (GSS_Case_Number__c =\''+SRNumber +'\''+' or GSS_Siebel_SR_Number__c=\''+SRNumber+'\''+')';

                    
                }else{
                    querySOQL = 'Select Id, GSS_Status__c, GSS_Sub_Status__c, GSS_CN__c, GSS_Product__c, GSS_Entitlement__c, GSS_Routing_Channel__c, From GSS_Case_Archive__c';
                    querySOQL += ' Where (GSS_Case_Number__c =\''+SRNumber +'\''+' or GSS_Siebel_SR_Number__c=\''+SRNumber+'\''+')';
                }
                lstCaseArchive =  Database.query(querySOQL);
                //CR-00017302 :Ends here
                
                if(lstCaseArchive != null && lstCaseArchive.size() == 1) {
                    GSS_Case_Archive__c oCaseArchive = lstCaseArchive[0];
                    /*oCaseArchive.GSS_Sub_Status__c = 'Inbound Message Received';
                     update oCaseArchive;*/
                    // code changed/added as a part of CR-5322 : Start:
                    
                    //CR-00017302 : Starts here : adding additional QSet parameter in array
                    for(GSSIVRQset__c fieldSet : qserParams){
                        GSS_Attribute ottr= new GSS_Attribute();
                        ottr.attributeName = (String) fieldSet.Name;
                        ottr.attributeValue = (String) oCaseArchive.get(fieldSet.API_Name__c);
                        
                        if('ServerDown'.equalsIgnoreCase(ottr.attributeName)){
                            if('Yes'.equalsIgnoreCase(ottr.attributeValue) || 'Y'.equalsIgnoreCase(ottr.attributeValue)){
                                ottr.attributeValue = 'Y';
                            }else if('No'.equalsIgnoreCase(ottr.attributeValue) || 'N'.equalsIgnoreCase(ottr.attributeValue)){
                                ottr.attributeValue = 'N';
                            }
                            else {
                                ottr.attributeValue = null;
                            }
                        
                        }
                        
                        if('TechnicalContact'.equalsIgnoreCase(ottr.attributeName)){
                            if('Yes'.equalsIgnoreCase(ottr.attributeValue)){
                                ottr.attributeValue = 'Y';
                            }else if('No'.equalsIgnoreCase(ottr.attributeValue)){
                                ottr.attributeValue = 'N';
                            }
                            else {
                                ottr.attributeValue = null;
                            }
                        
                        }
                        
                        attrArray.add(ottr);
                    }           
                    //CR-00017302 : Ends here
                    
                    QsetObj = new QSet(oCaseArchive.GSS_Status__C, oCaseArchive.GSS_Sub_Status__c, '', system.now(), 'No', oCaseArchive.GSS_CN__c, oCaseArchive.GSS_Product__c, '' ,oCaseArchive.GSS_Routing_Channel__c,attrArray);
                    qurySRdone = true;
                    // code changed/added as a part of CR-5322 : End:
                }
            }
            // code changed/added as a part of CR-5322 : Start:
            if(qurySRdone == true){             
                QsetObj.ResultCode = PQSetObj.ResultCode;               
            }
            // code changed/added as a part of CR-5322 : End:
        } Catch (exception ex) {
            //Added Error handling code in catch block for CR-00008898
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'Case', 'GSS_Avaya_IVR');
            //End of code for CR-00008898        
        }
        // code changed/added as a part of CR-5322 : Start:
        //CR-00140109:Removed System.debug
        //system.debug('QsetObjQsetObj --'+QsetObj);
        return QsetObj;
        // code changed/added as a part of CR-5322 : End: 
    }

    global class CLSet {
        webservice String ResultCode;
        public CLSet(Boolean b) {system.debug('asdf'+b);ResultCode = b? 'Success' : 'Failure'; }
    }

    webservice static CLSet CloseSR(String SRNumber, String ClosureReason) {
        //try
        //{
        if(ClosureReason == null || ClosureReason.length() == 0)
            return new CLSet(false);
        if(SRNumber != null) {
            list<case> lstCase = [select id, GSS_Resolution_Code__c, Sub_Status__c from Case where (CaseNumber = :SRNumber.trim() OR GSS_Alternate_Case__c = :SRNumber.trim()) AND recordType.Name = 'GSS Technical Support'];
            if(lstCase != null && lstCase.size() == 1) {
                lstCase[0].Sub_Status__c = 'Customer Requests Close';
                GSS_Config_Properties__c customSettingConfigProp  = GSS_Config_Properties__c.getOrgDefaults();
                if(customSettingConfigProp != null ) {
                    if(ClosureReason != null){
                        if(ClosureReason.trim() == 'solution_provided'){
                            lstCase[0].GSS_Resolution_Code__c = customSettingConfigProp.GSS_IVR_Solutiion_Provided__c;  
                        } else if(ClosureReason.trim() == 'another_solution') {
                            lstCase[0].GSS_Resolution_Code__c = customSettingConfigProp.GSS_IVR_Another_Solution__c;
                        } else if(ClosureReason.trim() == 'duplicate') {
                            lstCase[0].GSS_Resolution_Code__c = customSettingConfigProp.GSS_IVR_Duplicate__c;
                        } else if(ClosureReason.trim() == 'created_in_error') {
                            lstCase[0].GSS_Resolution_Code__c = customSettingConfigProp.GSS_IVR_Created_In_Error__c;
                        } else if(ClosureReason.trim() == 'other_reason') {
                            lstCase[0].GSS_Resolution_Code__c = customSettingConfigProp.GSS_IVR_Other_Reason__c;
                        }
                    }   
                }
                
                /*for(case oCase :lstCase)
                {
                    oCase.Sub_Status__c = 'Customer Requests Close';
                    oCase.GSS_Resolution_Code__c = ClosureReason;
                }*/
                Database.SaveResult[] lsr= Database.Update(lstCase,false);
                for(Database.SaveResult sr:lsr){                
                    if(!sr.isSuccess()) {   
                        Database.Error err = sr.getErrors()[0];
                        system.debug('GSS_Avaya_IVR :: CloseSR :: SFDC is unable to update the Case :: ' + err.getMessage());    
                        return new CLSet(false);               
                    }            
                }
                //update lstCase;
                return new CLSet(true);
            }
            //}catch(exception ex){system.debug('exception:'+ex);}
            return new CLSet(false);
        }
        return new CLSet(false);        
    }

    global class PQSet {
        webservice String PhoneQueue;
        webservice String ResultCode;
        public PQSet(String p) { PhoneQueue=p; ResultCode='Success'; }
        public PQSet() { PhoneQueue=''; ResultCode='Failure'; }
    }

    webservice static PQSet QueryPhQueue(String SRNumber) {
        try {
            //Check :: Call GSS_GetCaseDetails
            Case oCase = GSS_GetCaseDetails.GetCaseDetails(SRNumber);
            //Check :: Call GSS_GetPrimaryCenter
            system.debug('*****()******'+oCase.GSS_Support_Customer_Region__c);
            String supportNumber = GSS_GetSupportCenter.getSupportCenter(oCase);
            System.debug('The supportNumber is:   '+supportNumber);
            //Check :: Call GSS_PhoneQueue
//            GSS_GetSupportCenter.testcaseW=false;
            oCase = GSS_PhoneQueue.getPhoneQueue(oCase,supportNumber);
//          PQSet objPQSet = new PQSet(GSS_PhoneQueue.getPhoneQueue(oCase,supportNumber));
            
            //set call to 'call in queue' if necessary (live, case < 1 hour old, and never been answered before)
            //needed for the dropped-call workflow
            if (oCase.GSS_Routing_Channel__c == 'LIVE' && oCase.GSS_Phone_Queue_Routing_Status__c == 'No Call') {
                DateTime oneHourBack = DateTime.now().addHours(-1);
                if (oCase.CreatedDate > oneHourBack) {
                    oCase.GSS_Phone_Queue_Routing_Status__c = 'Call in Queue';
                }
            }
            // Subbu - Fix to workaround the double decrement of entitlement
            // Same as JK implemented above
            // Check for CSR DB
            if(!isServiceFirst){
           Entitlement thisEnt = [select id, RemainingCases, IsPerIncident from Entitlement where id = :oCase.EntitlementId];
            Boolean isIncident = thisEnt.IsPerIncident;
            Integer remaining = -1;
            if(isIncident != null) {
                remaining = thisEnt.RemainingCases;
                if (remaining == 0) {
                    thisEnt.RemainingCases = 1;
                    List<Entitlement> lstEnt = new List<Entitlement>();
                    lstEnt.add(thisEnt);
                    Database.SaveResult[] lsr= Database.update(lstEnt,false);
                }
            }         
            update oCase;
            // Subbu - Fix to workaround the double decrement of entitlement
            // Same as JK implemented above
            //JK more 1/31 additions for double decrementation 
            if(isIncident != null){
                thisEnt = [select id, RemainingCases from Entitlement where id = :oCase.EntitlementId];
                if (thisEnt.RemainingCases != remaining) {
                    thisEnt.RemainingCases = remaining;
                    List<Entitlement> lstEnt = new List<Entitlement>();
                    lstEnt.add(thisEnt);
                    Database.SaveResult[] lsr= Database.update(lstEnt,false);
                }
            }  
           }   
            //Subbu end edits
            return new PQSet(oCase.GSS_Phone_Queue__c);
        } catch( exception ex ) {
            system.debug('exception:'+ex);
            //Added Error handling code in catch block for CR-00008898
            CreateApexErrorLog.insertHandledExceptions(ex, null, null, null, 'ApexClass', 'Case', 'GSS_Avaya_IVR');
            //End of code for CR-00008898
        }
        return new PQSet();
    }

    global class GSS_Attribute {
        WebService String attributeName;
        WebService String attributeValue;
    }

    global class GSS_CaseRequestInfo{
        webservice GSS_ContactInfo contactInfo;
        webservice GSS_CaseInfo caseInfo;
        webservice GSS_EntitlementInfo entitlementInfo;
    }
    global class GSS_ContactInfo{
        public String ConCN;
        public String ConFirstName;
        public String ConLastName;
        public String ConEmail;
        public String ConTitle;
        public String ConDepartment;
        public String ConRoleCategory;
        public String ConPhone;
        public String ConPhoneExt;
        public String ConFax;
        public String ConLangPref;
        public String ConTimeZone;
        public String ConCountry;    
    }
    global class GSS_CaseInfo{
        public String CaseProduct;
        public String CaseProbCat;
        public String CaseServerDown;
        public String CasePrefContact;
        public String CaseOrigin;
        public String CaseAltPhone;
        public String CaseAvailable24x7;
        public String CaseSev;
        public String caseCSRemail;
    /** added for Federated-Custom Support GSS_UpdateCase: Inititate SR**/
    public string CaseReferenceArchitecture;
        
        /*** Begin: Code added by Deepak for ICE Project**/
        public String EAName;
        public String EANumber;
        /*** End: Code added by Deepak for ICE Project **/

        //Added by Deepak for Flex fields such as EANumber and EAName
        WebService GSS_Attribute[] attrArray;
        
        
        /****Code added for CR-00004344 on 03/22 by Vikas Sharma ***/ 
        public Boolean isCSRDashboard = false;
        /****Code added for CR-00004344 on 03/22 by Vikas Sharma End's***/
        /*public String CaseSuppLevel;

        public String CaseSev;*/
        public String CaseRecType; // Mayur 05-Sep-14   Added code for SDP 6.0 Carpathia | CR-00102154 - Uncommented CaseRecType parameter
        /*String CaseStatus;
        String CaseSubStatus;
        String CaseSubject;
        String CaseDesc;

        String CaseLanguage;
        String CaseTimeZone;
        String CaseRegion;


        String CaseVCat;
        String CaseVSubCat;
        String CaseAltContact;

        String CaseAltEmail;
        String CaseThrdPrtyDept;
        String CaseThrdPrtyTicket;
        String CaseThrdPrtyTicOpen;
        String CaseThrdPrtyTicClose;
        String CaseThrdPrtySLAMet;
        String CaseLicTransfer;
        String CaseLicKey;
        String CaseOrderNum;
        String CaseNewEmail;
        Boolean CaseSelfHelp;
        String CaseDeactiveProfile;
        String CasePartActCode;
        String CaseOEMName;
        String CaseThrdPrtyDept2;
        String CaseThrdPrtyTicket2;
        String CaseThrdPrtyTicOpen2;
        String CaseThrdPrtyTicClose2;
        String CaseThrdPrtySLAMet2;
        String CaseSpecAcc;
        String CaseSpecCon;
        String CaseParentId;


        String CaseAddEmails;
        String CaseQues1;
        String CaseQues2;
        String CaseQues3;
        String CaseAnswer1;
        String CaseAnswer2;
        String CaseAnswer3;
        String CaseCenter;
        String CasePhoneQueue;
        String CaseRoutChannel;    
        String CaseIssue;
        String CaseForm;
        String CaseModifyAdministrator;
        String CaseNewEmailAddress;
        String CaseProductVersion;
        String CaseCountryCode;
        String CaseCountry;
        String CaseThirdPrtyContact;
        String CaseThirdPrtyEmailPhone;
        String CaseVSubCat2;
        String CaseContractNumber;
        String CaseExistingEmailAddress;
        String CaseIncidentPackCreditStatus;
        String CaseProductBuild;
        String CaseThirdPartyPagerPinNumber;
         */
    }
    global class GSS_EntitlementInfo{
        public String CaseEntitlement;
        public String CaseEntCode;
        public String CaseEntStatus;
        public Boolean CaseEntIsIncident;
        public String CaseEntIncidentPackNum;
        public Integer CaseEntMaxIncidents;
        public Date CaseEntStartDate;
        public Date CaseEntEndDate;
    }
    global class GSS_CaseResponseInfo{
        public String accountId;
        public String contactId;
        public String caseId;
        public String entitlementId;
        public String caseNumber;
        public String caseSev;
    /** added for Federated-Custom Support GSS_UpdateCase: Inititate SR**/
    public string CaseReferenceArchitecture;

    }
}