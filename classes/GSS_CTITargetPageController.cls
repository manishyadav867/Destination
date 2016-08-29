/**********************************************************************************
 * Class Name : GSS_CTITargetPageController
 * Purpose    : This class was created to receive the query string from the IVRSystem 
 *              and navigate to the case or contact as needed.If neither option is possible
 *              then the 'ShowCSRDashBoard' method will return  true.
 * ********************************************************************************       
 * Author                               Date            Remarks
 * HCL Technologies - Aditya            14-Oct-10        Created
 * Accenture Agent console change       15-May-14       Updated
 * Accenture 							04-Aug-16		CR-00140109:Removed System.debug
 *********************************************************************************/
 
public with sharing class GSS_CTITargetPageController {
    
    
    //parameter headers on the query string
    public static final String PARAM_ID = 'CaseId';
    public static final String PARAM_CASE_NUMBER = 'SRNumber';
    public static final String PARAM_CON_NUMBER = 'CN';
    public static final String PARAM_PROD_NAME = 'ProductName';
    public static final String PARAM_MOC = 'PreferredMOC';
    public static final String PARAM_ALT_ID = 'AltId';
    //public static final String PARAM_ALT_ID = 'AlternateId';
    //public static final String PARAM_ALT_ID_TYPE = 'AlternateIdType';
    public static final String PARAM_ALT_ID_TYPE = 'AltIdType';
    public static final String PARAM_AGENT = 'paramAgent';
    public static final String PARAM_TRANSFER_REASON='TransferReason'; 
    public static final String PARAM_PROBLEM_CATEGORY='ProblemCategory';
    public static final String PARAM_CALL_BACK_PHONE='CallBackPhone';
    public static final String PARAM_AGENT_TYPE='AgentType';
    public static final String PARAM_SERVER_DOWN='ServerDown';
    public static final String PARAM_TECHNICAL_CONTACT='TechnicalContact';
    public static final String PARAM_SR_STATUS='SRStatus';
    public static final String PARAM_ENTITLEMENT_CODE='EntitlementCode';
    public static final String PARAM_ROUTING_CHANNEL='RoutingChannel';
    public Case c;
    
    //Parameter to send in the url for CSRDashBoard
    public String CSRDashParams{get;set;}
    public Id cId{get;set;}
    public String caseNumber{get;set;}
    public String altID{get;set;}
    public String conNum{get;set;}
    public String productName{get;set;}
    public String MOC{get;set;}
    public String problemCategory{get;set;}
    public String srStatus{get;set;}
    public String routingChannel{get;set;}
    public String csr{get;set;}
    public String agentType{get;set;}
    public String contactPhone{get;set;}
    public String altIdType{get;set;}
    public String entitlementCode{get;set;}
    public String callBackNum{get;set;}
    public String ANI{get;set;}
    public String DNIS{get;set;}
    public String ServerDown{get;set;}
    public String CSR_Email = [select id,email from user where id =: userinfo.getuserId()].email;
    public String CSRDashboardURL{get; set;}
    private Case uCase;
    public Boolean noCase;
    private String dQueue;
    
    public GSS_CTITargetPageController(){
//      CR-00004345 Move to getCSRParamas function
//        String str = userInfo.getUserId();
//        GSS_Config_Properties__c strURL = GSS_Config_Properties__c.getInstance(str);
//        CSRDashboardURL = strURL.GSS_CSR_Dashboard_pop_up_URL__c;
        
        uCase = null;
        noCase = true;
        dQueue = GSS_Configuration_Properties_list__c.getInstance('Default Queue').setting_value__c;
        getRequestParameterData();
        system.debug('-----cID--in constructor----'+cID);
        if(isValidParam(cId)){
            //get the case details by using the Id
            List<Case> lc=[SELECT id,ownerid,lastmodifieddate ,isClosed from Case c WHERE c.id=:cId];
            if(lc.size()>0)
                uCase=lc.get(0);
        }else{
                if(isValidParam(caseNumber)){
                    //get the case details by using the case number
                    List<Case> lc = [SELECT id, ownerid, lastmodifieddate ,isClosed From Case c 
                            Where (c.caseNumber = :caseNumber or c.GSS_Alternate_Case__c = :caseNumber) limit 1];
                    if(lc.size()>0)
                        uCase=lc.get(0);
                }
            }
            system.debug('-------uCase------>>>>>'+uCase);
            if(uCase!=null)
                noCase=false;
        }   
    
    public String getCSRparamas()
    {
        String str = userInfo.getUserId(); // CR-00004345
        GSS_Config_Properties__c strURL = GSS_Config_Properties__c.getInstance(str);
        CSRDashboardURL = strURL.GSS_CSR_Dashboard_pop_up_URL__c;
       //caseNumber = [select id, casenumber from case where id =: c.id].casenumber;
       // CSRDashParams='AgentType='+agentType+'&Case_Num='+caseNumber+'&PreferredMOC='+MOC+'&CallBackNum='+conNum+'&ProductName='+productName+'&AlternateId='+altId+'&AlternateIdType='+altIdType+'&aeCallFromSFDC=InitiateSR'+'&ANI='+ANI+'&DNIS='+DNIS+'&problemCategory='+problemCategory+'&ServerDown'+ServerDown+'&CSR_Email='+CSR_Email;                       
       
        CSRDashParams='AgentType='+agentType+'&PreferredMOC='+MOC+'&CallBackPhone='+CallBackNum+'&CSNum='+conNum+'&ProductName='+productName+'&AlternateId='+altId+'&AlternateIdType='+altIdType+'&aeCallFromSFDC=InitiateSR'+'&ANI='+ANI+'&DNIS='+DNIS+'&problemCategory='+problemCategory+'&ServerDown='+ServerDown+'&CSR_Email='+CSR_Email;                       
       
        system.debug('-----CSRDashParams-----'+CSRDashParams);
        return CSRDashParams;
    }
    
    public String getURL()
    {
        GSS_Config_Properties__c gssConfigProp = GSS_Config_Properties__c.getOrgDefaults();
        return gssConfigProp.CustomerPortalURL__c;
    }
    
    private static boolean isValidParam(String paramValue){
        return !(paramValue == null || paramValue == '');
    }
    public void getRequestParameterData(){
        system.debug('----In getRequestParameterData Method----');
        if(ApexPages.currentPage().getParameters().get(PARAM_ID)!= null && ApexPages.currentPage().getParameters().get(PARAM_ID) !=' ')
            cId = ApexPages.currentPage().getParameters().get(PARAM_ID).trim();

        caseNumber=ApexPages.currentPage().getParameters().get(PARAM_CASE_NUMBER);
        if(caseNumber == null || caseNumber ==' '){
            caseNumber = '';
        }
        conNum=ApexPages.currentPage().getParameters().get(PARAM_CON_NUMBER);
        if (conNum == null || conNum ==' ')
        {
            conNum ='';
        }
        productName=ApexPages.currentPage().getParameters().get(PARAM_PROD_NAME);
        if(productName == null || productName==' '){
            productName = '';
        }
           MOC=ApexPages.currentPage().getParameters().get(PARAM_MOC);
          if(MOC == null || MOC ==' '){
                MOC = '';
          }
        problemCategory=ApexPages.currentPage().getParameters().get(PARAM_PROBLEM_CATEGORY);
        if(problemCategory == null || problemCategory == ' '){
            problemCategory = '';
        }
        srStatus=ApexPages.currentPage().getParameters().get(PARAM_SR_STATUS);
        if(srStatus == null || srStatus == ' '){
            srStatus = '';
        }
        routingChannel=ApexPages.currentPage().getParameters().get(PARAM_ROUTING_CHANNEL);
        if(routingChannel == null || routingChannel == ' '){
            routingChannel='';
        }
        entitlementCode=ApexPages.currentPage().getParameters().get(PARAM_ENTITLEMENT_CODE);
        if(entitlementCode == null || entitlementCode == ' '){
            entitlementCode = '';
        }
        csr = ApexPages.currentPage().getParameters().get(PARAM_AGENT);
        if(csr == null || csr == ' '){
            csr = '';
        }
        agentType=ApexPages.currentPage().getParameters().get(PARAM_AGENT_TYPE);
        if(agentType == null || agentType == ' '){
            agentType = '';
        }
        callBackNum=(ApexPages.currentPage().getParameters().get(PARAM_CALL_BACK_PHONE));
        if(callBackNum == null || callBackNum ==' '){
            callBackNum = '';
        }
        altId=ApexPages.currentPage().getParameters().get(PARAM_ALT_ID);
        if(altId == null || altId == ' '){
            altId = '';
        }
        altIdType=ApexPages.currentPage().getParameters().get(PARAM_ALT_ID_TYPE);
        if(altIdType == null || altIdType == ' '){
            altIdType = '';
        }
        ServerDown=ApexPages.currentPage().getParameters().get(PARAM_SERVER_DOWN);
        if(ServerDown == null || ServerDown ==' '){
            ServerDown = '';
        }
        //need to make sure ServerDown is the right value (should be Yes/No - comes in as Y/N)
        if (ServerDown == 'Y') {
            ServerDown = 'Yes';
            }
            if (ServerDown == 'N') {
            ServerDown = 'No';
            }
        
    }
    /*private void makeNewCase(){
        //creation of new case comes here
        system.debug('----In makeNewCase method------');
        c=new Case();
        c.Sub_Status__c='Shell Case';
        //Find the associated Contact
        if(isValidParam(conNum)){
            List<Contact> lct=New List<Contact>([SELECT id,GSS_CN__c FROM Contact WHERE GSS_CN__c=:conNum]);
            if(lct.size()>0){
                c.ContactId=lct.get(0).id;
            } 
            //Find the associated product
            if(isValidParam(productName)){
                List<Product2> lp=new List<Product2>([SELECT id from Product2 where name=:productName]);
                if(lp.size()>0){
                    c.ProductId=lp.get(0).id;
                }
            }
            //Put method of contact in place
            if(isValidParam(MOC)){
                c.GSS_Preferred_Method_of_Contact__c=MOC;
            }
            c.Origin='Phone';
            if(isValidParam(problemCategory))
                c.GSS_Problem_Category__c=problemCategory;
            //if(isValidParam(entitlementCode))
                //c.GSS_Entitlement_Code__c=entitlementCode;
            if(isValidParam(srStatus))
                c.Status=srStatus;
            if(isValidParam(routingChannel))
                c.GSS_Routing_Channel__c=routingChannel;
          
        }
        //GSS_Case_Record_Type__c caseUpdateSetting = GSS_Case_Record_Type__c.getOrgDefaults();
        //List<RecordType> lstRecordType = [select id,Name from RecordType where SobjectType='Case' and name = :caseUpdateSetting.GSS_Technical_Support__c.trim() ];      
        //system.debug('lstRecordType '+lstRecordType);
       // if(lstRecordType != null && (!lstRecordType.isEmpty()))
        //{
            //c.recordTypeId =  lstRecordType[0].id;
        //}
        c.Origin = 'Phone';
        //set Owner to default Queue
        c.OwnerId=(ID)dQueue;
        uCase=c;
        insert c;
    }*/
    private void updateOwner(){
        //updation of Owner code comes here
        ID curr = UserInfo.getUserID();
        //if the person receiving the call is not the owner
        if (uCase.ownerID != curr) {
            uCase.ownerid = curr;
            uCase.Sub_Status__c = 'Assigned';
            uCase.GSS_ScreenPopTime__c = System.now();  // CR-00004345
        }
    }
    public PageReference CTITargetPageRedirect(){
        system.debug('-------noCase---in CTITargetPageRedirect-----'+noCase);
        if(noCase){
            //Create a new Case
            //commented out to eliminate shell case, JK 11/29
            //makeNewCase();
            //System.Debug('makeNewCase was executed');
            return null;
        }
        if (isValidParam(agentType) && agentType.equalsignorecase('tse') && ucase != null &&  (!ucase.isClosed)){
            
                updateOwner();
                System.Debug('update owner was executed');
                update uCase;
            
        }
		//CR-00140109:Removed System.debug
        //System.Debug('Here is the page reference returned: ' +uCase.Id);
        //return new PageReference('/'+uCase.Id+'/d?retURL=/'+uCase.Id);
        return new PageReference('/'+uCase.Id+'/d?cin=true&retURL=/'+uCase.Id); // Agent console change
    }
    public String getShowCSRDashBoard()
    {
        if(noCase){
        //if(noCase && isValidParam(ApexPages.currentPage().getParameters().get('allowNavigate'))){
           System.debug('Returning TRUE from getShowCSRDashBoard()');
           return 'true';
        }
        System.debug('Returning FALSE from getShowCSRDashBoard()');
        return 'false';
    }
}