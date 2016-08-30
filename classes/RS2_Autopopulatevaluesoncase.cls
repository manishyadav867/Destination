/**************************************************************************************************************
    Name           : RS2_Autopopulatevaluesoncase
    Decription     : Created for RS2 to populate the case values from Opportunity in Quoting Module [Against "CR-00087919"]
    Created by     : Ravikiran D
    Date           : 6th May, 2014.
**************************************************************************************************************
Modified By                 Modified Date             Comments 
    Mayur Srivastava        12-Nov-14                 BUG-00104949 : Optimized the flow in order to avoid 101 SOQL
    Updates        : BUG-00105767 fix - Added record type filter condition in Oppty query -  RaviKiran D
    RaviKiran D             12-Dec-2014               BUG-00107477(Enhancement) - Changed the "Service_Contract_Number__c" reference of Opportunity to 
                                                      "RS2_Expiring_Contract_Number__c"
**************************************************************************************************************/

public class RS2_Autopopulatevaluesoncase{

    
    /***********************************************************************************************
    * Method Name: mapServieContarctOpp
    * Description: Mapping the Service Contract Numbers and the Opportunities related.
    * @Param: List(Opportunity)
    * @return: void 
    ***********************************************************************************************/
    static string opptyrectypeid = RS2_Quoting__c.getInstance('SharingRecordTypeIds').Value__c; // get the value of 'Renewal Sales Opportunity' oppty record type Id
    static map<string,list<Opportunity>> serviceContactOppMap = new map<string,list<Opportunity>>();
    public static void mapServieContarctOpp(List<Opportunity> newlist){
        try{          
            set<Id> ownerIdSet = new set<Id>();
            for(Opportunity opp : newlist){
                    list<Opportunity> oppList;
                    if(serviceContactOppMap.isEmpty()){
                        oppList = new list<Opportunity>();
                        oppList.add(opp);
                        serviceContactOppMap.put(opp.RS2_Expiring_Contract_Number__c,oppList);
                    }else{
                        if(serviceContactOppMap.get(opp.RS2_Expiring_Contract_Number__c) != null){
                            oppList = new list<Opportunity>();
                            oppList = serviceContactOppMap.get(opp.RS2_Expiring_Contract_Number__c);
                            oppList.add(opp);
                            serviceContactOppMap.put(opp.RS2_Expiring_Contract_Number__c,oppList);
                        }else{
                            oppList = new list<Opportunity>();                        
                            oppList.add(opp);
                            serviceContactOppMap.put(opp.RS2_Expiring_Contract_Number__c,oppList);
                        }
                    }
                }
        }Catch(Exception e){CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_Autopopulatevaluesoncase', 'mapServieContarctOpp');
        }
    }   


    /***********************************************************************************************
    * Method Name: populateValuesFromOpp
    * Description: Populate the Opp Value into case value when cases are created
    * @Param: list of Case
    * @return: void 
    ***********************************************************************************************/   
    public static Record_Type_Settings__c custRecTypeId=Record_Type_Settings__c.getValues('CaseRenewalOperations');
    private static String recId = custRecTypeId.Record_Type_ID__c;

    public static void populateValuesFromOpp(List<Case> newlist){ 
        try{
            set<string> serviceContractNumbers = new set<string>();
            for (Case c : newlist){
                if(c.RecordTypeid == recId){
                    if(c.Vmware_Contract_Number__c != null && c.Vmware_Contract_Number__c != '' 
                    && !c.Vmware_Contract_Number__c.contains(',')){
                        serviceContractNumbers.add(c.Vmware_Contract_Number__c);
                    }                    
                }     
            }
            list<Opportunity> oppList = new list<Opportunity>();
            if(serviceContractNumbers != null && !serviceContractNumbers.isEmpty()){
                oppList = [Select Id,Name,RS2_Expiring_Contract_Number__c from Opportunity where RecordTypeId =:opptyrectypeid and RS2_Expiring_Contract_Number__c IN : serviceContractNumbers];
                //System.debug('Opplist record type'+oppList);
            }
            
            if(oppList != null && !oppList.isEmpty()){
                RS2_Autopopulatevaluesoncase.mapServieContarctOpp(oppList);
            }
            
            if(serviceContactOppMap != null && !serviceContactOppMap.isEmpty()){
                for(Case c : newlist){
                    if(c.Vmware_Contract_Number__c != null){
                        if(serviceContactOppMap.get(c.Vmware_Contract_Number__c) != null){
                            if(!(serviceContactOppMap.get(c.Vmware_Contract_Number__c).size() > 1)){
                                c.Opportunity_ID__c = serviceContactOppMap.get(c.Vmware_Contract_Number__c)[0].Id;
                                //System.debug('Oppty Id'+serviceContactOppMap.get(c.Vmware_Contract_Number__c)[0].Id);
                            }
                        }
                    }
                }
            }          
            
            List<String> OppIds= new List<String>();
            set<Id> accountIds = new set<Id>();
            for (Case c : newlist){
                if(c.RecordTypeid == recId){
                    if(c.RecordTypeid == recId && c.Origin == RS2_Quoting__c.getInstance('Online Renewals').Value__c){
                        c.Request_Type__c = c.Origin ;
                    } 
    
                    if (c.Opportunity_ID__c != null){  
                        OppIds.add(c.Opportunity_ID__c);  
                    }
                    
                    if(c.Account_Subscription__c != null){
                        accountIds.add(c.Account_Subscription__c);
                    }
                    
                    if(c.AccountId != null){
                        accountIds.add(c.AccountId);
                    }
                    
                    if(c.Channel_Partner__c != null){
                        accountIds.add(c.Channel_Partner__c);
                    }else if(c.Channel_Partner__c == null){
                        c.Channel_Partner_PRMID__c = null;
                        c.Channel_Partner_Type__c = null;
                    }              
                }                
            }
            
            Map<id,Opportunity> listOppmap;
            if(OppIds != null && !OppIds.isEmpty()){
                listOppmap = new Map<id,Opportunity>([SELECT id,AccountId,Account.Name,Account.Sales_Classification__c,Account.RS2_Special_Pricing__c,RS2_Line_of_Business_to__c,vSUS__c FROM Opportunity WHERE id In: OppIds]);
            }
            
            map<Id,Account> accountMap;
            if(accountIds != null && !accountIds.isEmpty()){
                accountMap = new map<Id,Account>([Select Id,Name,Sales_Classification__c,RS2_Special_Pricing__c,Partner_Type__c,Partner_ID__c,Is_Distributor_Account__c,Is_Reseller_Account__c from Account where ID IN : accountIds]);
            }
            
            for (Case c : newlist){
                if(c.RecordTypeid == recId){
                    if(c.AccountId != null){
                        if(accountMap != null && !accountMap.isEmpty()){
                            if(accountMap.get(c.AccountId) != null){
                                if(accountMap.get(c.AccountId).Is_Distributor_Account__c){
                                    c.Partner_Type__c = RS2_Quoting__c.getInstance('Distributor').Value__c;
                                }else if(accountMap.get(c.AccountId).Is_Reseller_Account__c){
                                    c.Partner_Type__c = RS2_Quoting__c.getInstance('Reseller').Value__c;
                                }                          
                            }                            
                        }
                    }
                    if(c.Channel_Partner__c != null){
                        if(accountMap != null && !accountMap.isEmpty()){
                            if(accountMap.get(c.Channel_Partner__c) != null){
                                if(accountMap.get(c.Channel_Partner__c).Is_Distributor_Account__c){
                                    c.Channel_Partner_Type__c = RS2_Quoting__c.getInstance('Distributor').Value__c;
                                }else if(accountMap.get(c.Channel_Partner__c).Is_Reseller_Account__c){
                                    c.Channel_Partner_Type__c = RS2_Quoting__c.getInstance('Reseller').Value__c;
                                }
                                c.Channel_Partner_PRMID__c = accountMap.get(c.Channel_Partner__c).Partner_ID__c;                                
                            }                            
                        }
                    } 
                    if (c.Opportunity_ID__c != null){
                        Opportunity Opp =listOppmap.get(c.Opportunity_ID__c);
                        if(Opp != null){
                            c.Line_of_Business__c = Opp.RS2_Line_of_Business_to__c;
                            c.vSUS__c = Opp.vSUS__c;
                            c.Account_Subscription__c = Opp.AccountId;
                            c.Customer_Classification__c = '';
                            if(Opp.Account.Sales_Classification__c != null){
                                if(Opp.Account.Sales_Classification__c == RS2_Quoting__c.getInstance('Federal').Value__c){   
                                    c.Customer_Classification__c = RS2_Quoting__c.getInstance('Federal').Value__c + ' ; ';
                                }
                                if(Opp.Account.Sales_Classification__c  == RS2_Quoting__c.getInstance('Public Sector').Value__c){
                                    c.Customer_Classification__c += RS2_Quoting__c.getInstance('International Government').Value__c + ' ; ';
                                }
                                if(Opp.Account.Sales_Classification__c  == RS2_Quoting__c.getInstance('Global').Value__c){
                                    c.Customer_Classification__c += RS2_Quoting__c.getInstance('Global Account').Value__c + ' ; ';
                                }
                            }
                            if(Opp.Account.RS2_Special_Pricing__c  != null && Opp.Account.RS2_Special_Pricing__c == True){
                                c.Customer_Classification__c += RS2_Quoting__c.getInstance('Special Pricing').Value__c;
                            }
                        }                        
                    }
                    if(c.Account_Subscription__c != null){
                        if(accountMap != null){
                            if(accountMap.get(c.Account_Subscription__c) != null){
                                c.Customer_Classification__c = '';
                                if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c != null){
                                    if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c == RS2_Quoting__c.getInstance('Federal').Value__c){   
                                        c.Customer_Classification__c = RS2_Quoting__c.getInstance('Federal').Value__c + ' ; ';
                                    }
                                    if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c  == RS2_Quoting__c.getInstance('Public Sector').Value__c){
                                        c.Customer_Classification__c += RS2_Quoting__c.getInstance('International Government').Value__c + ' ; ';
                                    }
                                    if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c  == RS2_Quoting__c.getInstance('Global').Value__c){
                                        c.Customer_Classification__c += RS2_Quoting__c.getInstance('Global Account').Value__c + ' ; ';
                                    }
                                }
                                if(accountMap.get(c.Account_Subscription__c).RS2_Special_Pricing__c  != null 
                                && accountMap.get(c.Account_Subscription__c).RS2_Special_Pricing__c == True){
                                    c.Customer_Classification__c += RS2_Quoting__c.getInstance('Special Pricing').Value__c;
                                }
                            }
                        }
                    }                    
                }
                
            }
        }catch(Exception e){ CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_Autopopulatevaluesoncase', 'populateValuesFromOpp');
        }  
    }
    
    /***********************************************************************************************
    * Method Name: updateValuesFromOpp
    * Description: Updates the Customer Classification field if the Opportunity/Account is updated.
    * @Param: List(Case), Map(Id,Case)
    * @return: void 
    ***********************************************************************************************/

    public static void updateValuesFromOpp(List<Case> newlist,map<Id,Case> oldMap){
        try{
        
            set<string> serviceContractNumbers = new set<string>();
            for (Case c : newlist){
                if(c.RecordTypeid == recId){
                    if(c.Vmware_Contract_Number__c != oldMap.get(c.Id).Vmware_Contract_Number__c){
                        if(c.Vmware_Contract_Number__c != null && c.Vmware_Contract_Number__c != '' 
                        && !c.Vmware_Contract_Number__c.contains(',')){
                            serviceContractNumbers.add(c.Vmware_Contract_Number__c);
                        }else{
                            c.Opportunity_ID__c = null;
                        }
                    }
                                        
                }
                
            }
            list<Opportunity> oppList = new list<Opportunity>();
            if(serviceContractNumbers != null && !serviceContractNumbers.isEmpty()){
                oppList = [Select Id,Name,RS2_Expiring_Contract_Number__c from Opportunity where RecordTypeId =:opptyrectypeid and RS2_Expiring_Contract_Number__c IN : serviceContractNumbers];
            }
            
            if(oppList != null && !oppList.isEmpty()){
                RS2_Autopopulatevaluesoncase.mapServieContarctOpp(oppList);
            }
            
            if(serviceContactOppMap != null && !serviceContactOppMap.isEmpty()){
                for(Case c : newlist){
                    if(c.Vmware_Contract_Number__c != oldMap.get(c.Id).Vmware_Contract_Number__c){
                        if(c.Vmware_Contract_Number__c != null){                            
                            if(serviceContactOppMap.get(c.Vmware_Contract_Number__c) != null){
                                if(!(serviceContactOppMap.get(c.Vmware_Contract_Number__c).size() > 1)){
                                    c.Opportunity_ID__c = serviceContactOppMap.get(c.Vmware_Contract_Number__c)[0].Id;
                                }
                            }
                        }else if(c.Vmware_Contract_Number__c == null){
                            c.Opportunity_ID__c = null;
                        }
                    }                    
                }
            }          
                      
            set<Id> oppIdSet = new set<Id>();
            set<Id> accountIsSet = new set<Id>();
            for(Case c : newlist){
                if(c.RecordTypeId == recId){
                    if(oldMap.get(c.Id).Opportunity_ID__c != c.Opportunity_ID__c){
                        if(c.Opportunity_ID__c != null){
                            oppIdSet.add(c.Opportunity_ID__c);
                        }
                    }
                    
                    if(oldMap.get(c.Id).Account_Subscription__c != c.Account_Subscription__c){
                        if(c.Account_Subscription__c != null){
                            accountIsSet.add(c.Account_Subscription__c);
                        }
                    }
                    
                    if(oldMap.get(c.Id).Channel_Partner__c != c.Channel_Partner__c){
                        if(c.Channel_Partner__c != null){
                            accountIsSet.add(c.Channel_Partner__c);
                        }
                    }  
                    if(oldMap.get(c.Id).AccountId != c.AccountId){
                        if(c.AccountId != null){
                            accountIsSet.add(c.AccountId);
                        }
                    }                  
                }
            }
            
            Map<id,Opportunity> listOppmap;
            if(oppIdSet != null && !oppIdSet.isEmpty()){
                listOppmap = new Map<id,Opportunity>([SELECT id,AccountId,Account.Name,Account.Sales_Classification__c,Account.RS2_Special_Pricing__c,RS2_Line_of_Business_to__c,vSUS__c FROM Opportunity WHERE id In: oppIdSet]);
            }
            
            map<Id,Account> accountMap;
            if(accountIsSet != null && !accountIsSet.isEmpty()){
                accountMap = new map<Id,Account>([Select Id,Is_Distributor_Account__c,Is_Reseller_Account__c,Name,Sales_Classification__c,RS2_Special_Pricing__c,Partner_Type__c,Partner_ID__c from Account where ID IN : accountIsSet]);
            }           
            
            for (Case c : newlist){
                if(c.RecordTypeid == recId){
                    if(oldMap.get(c.Id).AccountId != c.AccountId){
                        if(c.AccountId != null){
                            if(accountMap != null && !accountMap.isEmpty()){
                                if(accountMap.get(c.AccountId) != null){
                                    if(accountMap.get(c.AccountId).Is_Distributor_Account__c){
                                        c.Partner_Type__c = RS2_Quoting__c.getInstance('Distributor').Value__c;
                                    }else if(accountMap.get(c.AccountId).Is_Reseller_Account__c){
                                        c.Partner_Type__c = RS2_Quoting__c.getInstance('Reseller').Value__c;
                                    }     
                                }                            
                            }
                        }else if(c.AccountId == null){
                            c.Partner_Type__c = null;                            
                        }
                    }
                  if(oldMap.get(c.Id).Channel_Partner__c != c.Channel_Partner__c){
                        if(c.Channel_Partner__c != null){
                            if(accountMap != null && !accountMap.isEmpty()){
                                if(accountMap.get(c.Channel_Partner__c) != null){
                                    if(accountMap.get(c.Channel_Partner__c).Is_Distributor_Account__c){
                                        c.Channel_Partner_Type__c = RS2_Quoting__c.getInstance('Distributor').Value__c;
                                    }else if(accountMap.get(c.Channel_Partner__c).Is_Reseller_Account__c){
                                        c.Channel_Partner_Type__c = RS2_Quoting__c.getInstance('Reseller').Value__c;
                                    }
                                    c.Channel_Partner_PRMID__c = accountMap.get(c.Channel_Partner__c).Partner_ID__c;                                    
                                }                            
                            }
                        }else if(c.Channel_Partner__c == null){
                            c.Channel_Partner_PRMID__c = null;
                            c.Channel_Partner_Type__c = null;
                        }
                    }  
                    if (oldMap.get(c.Id).Opportunity_ID__c != c.Opportunity_ID__c){
                        if(c.Opportunity_ID__c != null){
                            Opportunity Opp =listOppmap.get(c.Opportunity_ID__c);
                            if(Opp != null){
                                c.Line_of_Business__c = Opp.RS2_Line_of_Business_to__c;
                                c.vSUS__c = Opp.vSUS__c;
                                c.Account_Subscription__c = Opp.AccountId;
                                c.Customer_Classification__c = '';
                                if(Opp.Account.Sales_Classification__c != null){
                                    if(Opp.Account.Sales_Classification__c == RS2_Quoting__c.getInstance('Federal').Value__c){   
                                        c.Customer_Classification__c = RS2_Quoting__c.getInstance('Federal').Value__c + ' ; ';
                                    }
                                    if(Opp.Account.Sales_Classification__c  == RS2_Quoting__c.getInstance('Public Sector').Value__c){
                                        c.Customer_Classification__c += RS2_Quoting__c.getInstance('International Government').Value__c + ' ; ';
                                    }
                                    if(Opp.Account.Sales_Classification__c  == RS2_Quoting__c.getInstance('Global').Value__c){
                                        c.Customer_Classification__c += RS2_Quoting__c.getInstance('Global Account').Value__c + ' ; ';
                                    }
                                }
                                if(Opp.Account.RS2_Special_Pricing__c  != null && Opp.Account.RS2_Special_Pricing__c == True){
                                    c.Customer_Classification__c += RS2_Quoting__c.getInstance('Special Pricing').Value__c;
                                }
                            } 
                        }else if(c.Opportunity_ID__c == null){
                            c.Line_of_Business__c = '';
                            c.vSUS__c = False;
                            if(!(oldMap.get(c.Id).Account_Subscription__c != c.Account_Subscription__c && c.Account_Subscription__c != null)){
                                c.Account_Subscription__c = null;
                                c.Customer_Classification__c = '';
                            }                                                
                        }                                                                       
                    }                    
                    if(oldMap.get(c.Id).Account_Subscription__c != c.Account_Subscription__c){
                        if(c.Account_Subscription__c != null){                            
                            if(accountMap != null){                                
                                if(accountMap.get(c.Account_Subscription__c) != null){
                                    c.Customer_Classification__c = '';
                                    if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c != null){
                                        if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c == RS2_Quoting__c.getInstance('Federal').Value__c){   
                                            c.Customer_Classification__c = RS2_Quoting__c.getInstance('Federal').Value__c + ' ; ';
                                        }
                                        if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c  == RS2_Quoting__c.getInstance('Public Sector').Value__c){
                                            c.Customer_Classification__c += RS2_Quoting__c.getInstance('International Government').Value__c + ' ; ';
                                        }
                                        if(accountMap.get(c.Account_Subscription__c).Sales_Classification__c  == RS2_Quoting__c.getInstance('Global').Value__c){
                                            c.Customer_Classification__c += RS2_Quoting__c.getInstance('Global Account').Value__c + ' ; ';
                                        }
                                    }
                                    if(accountMap.get(c.Account_Subscription__c).RS2_Special_Pricing__c  != null 
                                    && accountMap.get(c.Account_Subscription__c).RS2_Special_Pricing__c == True){
                                        c.Customer_Classification__c += RS2_Quoting__c.getInstance('Special Pricing').Value__c;
                                    }
                                }
                            }
                        }else if(c.Account_Subscription__c == null){                          
                            c.Customer_Classification__c = '';                    
                        }                         
                    }                    
                }
                
            }           
             
        }Catch(Exception e){CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_Autopopulatevaluesoncase', 'updateValuesFromOpp');
        }
    }   
     
    /***********************************************************************************************
    * Method Name: updateSupportQueue
    * Description: Updates the Queue Name into Support Queue field if the Case Owner is updated.
    * @Param: List of Case, Map of Id,Case
    * @return: void 
    ***********************************************************************************************/

    public static void updateSupportQueue(List<Case> newlist,map<Id,Case> oldMap){
        try{          
            set<Id> ownerIdSet = new set<Id>();
            for(Case c : newlist){
                if(c.RecordTypeId == recId && oldMap.get(c.Id).OwnerId != c.OwnerId){
                    ownerIdSet.add(oldMap.get(c.Id).OwnerId);
                }
            }
            //12-Nov-14    Mayur Srivastava    BUG-00104949 | Added if condition - Starts
            Map<Id,Group> queueMap = new Map<Id,Group>();
            if(ownerIdSet != NULL && !ownerIdSet.isEmpty())
                queueMap  = new Map<Id,Group>([SELECT Id,Name FROM Group WHERE Id IN: ownerIdSet AND Type = 'Queue']);
            //12-Nov-14    Mayur Srivastava    BUG-00104949 | Added if condition - Starts
            for(Case c : newlist){
                if(c.RecordTypeId == recId){ 
                    if(oldMap.get(c.Id).OwnerId != c.OwnerId){
                        if(queueMap != null && !queueMap.isEmpty()){
                            if(queueMap.get(oldMap.get(c.Id).OwnerId) != null){
                                c.Support_Queue__c = queueMap.get(oldMap.get(c.Id).OwnerId).Name;
                            }
                        }
                    }                
                }
            } 
        }Catch(Exception e){CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_Autopopulatevaluesoncase', 'updateSupportQueue');
        }
    }
    /***********************************************************************************************
    * Method Name: updateRenewalCaseOwner
    * Description: Updates the Case Owner for the Renewal Cases (RecordType = "Renewal Operations" 
                    && Request Type = "RELA Quote")
    * @Param: List of Case, Map of Id,Case
    * @return: void 
    ***********************************************************************************************/
    public static Renewal_Config__c renewal_Config = Renewal_Config__c.getValues('Renewal Operations');
    public static OnOffSwitch__c RS2_switch = OnOffSwitch__c.getValues('RS2_Workload_Allocation');
    public static void updateRenewalCaseOwner(List<Case> newCases){
        
        try{
            //system.debug('*******Custom setting - Switch ON***'+RS2_switch);
            //system.debug('*******Custom setting - Renewal Operations***'+renewal_Config);
            if(newCases != null && RS2_switch != null && RS2_switch.Active__c && renewal_Config != null && renewal_Config.CaseRecordTypeId__c != null){
               //system.debug('*******Custom setting - Switch ON*****');
               Map<Renewal_Rule_Scenario__c,List<Renewals_User_Data__c>> ruleScnaRenewalUsers = new Map<Renewal_Rule_Scenario__c,List<Renewals_User_Data__c>>();
                list<Case> caseSet = new list<Case>();
                list<Case> proactiveCaseSet = new list<Case>();
                //system.debug('#cases to process@@Soumya'+newCases.size());
                for (Case c : newCases){
                    //logic only for the "Renewal Operations" and reactive Cases
                    if(c.RecordTypeid == renewal_Config.CaseRecordTypeId__c && (String.isBlank(c.QC_Type__c) || c.QC_Type__c.equalsIgnoreCase('Reactive'))){
                        
                        caseSet.add(c);      
                    } 
                    else if(c.RecordTypeid == renewal_Config.CaseRecordTypeId__c && c.QC_Type__c.equalsIgnoreCase('Proactive')){
                        //System.debug('Assigning proactive cases***'+c);
                        if(renewal_Config.proactive_default_queue__c != null)
                            c.ownerId = renewal_Config.proactive_default_queue__c ;
                    }  
                }
                // building RulesScenario => List<Case>
                Map<Renewal_Rule_Scenario__c,list<Case>> ruleScenarioCasesMap = new Map<Renewal_Rule_Scenario__c,list<Case>>();
                Map<String,map<string,list<Case>>> ruleCasesMap = new Map<String,map<string,list<Case>>>();
                List<Renewal_Rule_Scenario__c> ListRenewalRuleSc = new List<Renewal_Rule_Scenario__c>();
                system.debug('# cases to process in this engine @@Soumya'+caseSet.size());
                for(Case cs: caseSet){
                    if(!ruleCasesMap.containsKey('Renewal Operations')){
                        map<string,list<Case>> tempCaseMap = new Map<String,List<Case>>();
                        tempCaseMap.put(cs.Request_Type__c,new list<case>{cs});
                        ruleCasesMap.put('Renewal Operations',tempCaseMap);
                    }
                    else {
                        if(!ruleCasesMap.get('Renewal Operations').containsKey(cs.Request_Type__c)){
                            ruleCasesMap.get('Renewal Operations').put(cs.Request_Type__c,new List<Case>{cs});    
                        }else if(ruleCasesMap.get('Renewal Operations').containsKey(cs.Request_Type__c) && ruleCasesMap.get('Renewal Operations').get(cs.Request_Type__c) != null){
                            ruleCasesMap.get('Renewal Operations').get(cs.Request_Type__c).add(cs);
                        }
                    }
                }                
                list<Renewal_Rule_Scenario__c> renewalScenarios = [select Id,Case_Record_Type__c,Case_Request_Type__c,Assign_Direct__c,(select Id,Parameter__c,Value__c from Renewal_Requirements__r) from Renewal_Rule_Scenario__c ];
                //system.debug('Number Renewal Rule Scenarion ### @@Soumya '+renewalScenarios.size());
                
                //Get all assign direct values
                List<String> qNames = new List<String>();
                for(Renewal_Rule_Scenario__c ruleScenario: renewalScenarios){
                    if(ruleScenario.Assign_Direct__c != null && !String.isBlank(ruleScenario.Assign_Direct__c)){
                        qNames.add(ruleScenario.Assign_Direct__c);
                    }
                }
                
                //System.debug('All asign direct values*****'+qNames);
                Map<String,String> qMap = new Map<String,String>();
                if(!qNames.isEmpty()){ 
                //System.debug('Creating Map***'+qNames.size());
                    for(Group g :  [Select id,name from group where name IN: qNames and Type = 'Queue']){System.debug('found group***'+g);
                        qMap.put(g.name,g.id);
                    }
                }
                //System.debug('qMap*****'+qMap);
                //System.debug('Case Map**@@Soumya***'+ruleCasesMap);
                if(ruleCasesMap != null && !ruleCasesMap.IsEmpty() && renewalScenarios != null && !renewalScenarios.isEmpty()){
                    for(Renewal_Rule_Scenario__c ruleScenario: renewalScenarios){
                        if(!ruleScenarioCasesMap.containsKey(ruleScenario)){
                            if(ruleCasesMap.containsKey(ruleScenario.Case_Record_Type__c) && ruleCasesMap.get(ruleScenario.Case_Record_Type__c) != null && ruleCasesMap.get(ruleScenario.Case_Record_Type__c).containsKey(ruleScenario.Case_Request_Type__c) && ruleCasesMap.get(ruleScenario.Case_Record_Type__c).get(ruleScenario.Case_Request_Type__c) != null ){
                                //Check for assign direct
                                if(!String.isBlank(ruleScenario.Assign_Direct__c) && qMap.containsKey(ruleScenario.Assign_Direct__c)) {
                                    //Assign all the cases to this queue.
                                    assignDirectToQueue(qMap.get(ruleScenario.Assign_Direct__c),ruleCasesMap.get(ruleScenario.Case_Record_Type__c).get(ruleScenario.Case_Request_Type__c));
                                    //System.debug('calling assgin to direct*****'+qNames);
                                }
                                else{
                                    List<Case> rsCases = ruleCasesMap.get(ruleScenario.Case_Record_Type__c).get(ruleScenario.Case_Request_Type__c);
                                    ruleScenarioCasesMap.put(ruleScenario,rsCases);
                                }
                            }
                        }
                    }
                }
                //system.debug('Number ruleScenarioCasesMap ### @@Soumya '+ruleScenarioCasesMap.size());
                if(ruleScenarioCasesMap != null && !ruleScenarioCasesMap.IsEmpty()){
                    ListRenewalRuleSc.addAll(ruleScenarioCasesMap.KeySet());
                }
                List<Renewal_Requirement__c> renw_Req = new List<Renewal_Requirement__c>();
                
                if(ListRenewalRuleSc != null && !ListRenewalRuleSc.IsEmpty()){
                    for(Renewal_Rule_Scenario__c rewRenewalRule : ListRenewalRuleSc){
                        if(rewRenewalRule.Renewal_Requirements__r != null && !rewRenewalRule.Renewal_Requirements__r.IsEmpty()){
                            renw_Req.addAll(rewRenewalRule.Renewal_Requirements__r);
                        }
                    }
                }
                //system.debug('*****Requirments*****>>>>'+renw_Req);
                string whereconditon = null;
                integer i = 1;
                integer totalsize = renw_Req.size();
                if(totalsize > 0){
                    whereconditon = 'Where ';
                    for(Renewal_Requirement__c req : renw_Req){
                        whereconditon = whereconditon + '( Parameter__c = '+'\''+req.Parameter__c +'\''+' and Value__c =  '+'\''+ req.Value__c +'\''+')';
                        if( totalsize > i ){
                          whereconditon = whereconditon + ' OR ';
                        }
                        i = i + 1;
                    }
                }
                //system.debug(whereconditon);
                RS2_CaseAssignmentUtility RS2caseUtil = new RS2_CaseAssignmentUtility();
                if(whereconditon != null){
                    ruleScnaRenewalUsers = RS2caseUtil.getEligibleUser(ruleScenarioCasesMap.keySet(),whereconditon,system.now());
                }
                system.debug('*****ruleScnaRenewalUsers******'+ruleScnaRenewalUsers);
                if(ruleScnaRenewalUsers != null && !ruleScnaRenewalUsers.isEmpty()){
                    for(Renewal_Rule_Scenario__c renewalRule: ruleScnaRenewalUsers.keyset()){
                        if(ruleScenarioCasesMap.containsKey(renewalRule)&& ruleScnaRenewalUsers.containsKey(renewalRule)){
                            //system.debug('#Cases for the assignment engine'+ruleScenarioCasesMap.get(renewalRule).size());
                            RS2caseUtil.RS2_assignCaseOwner(ruleScenarioCasesMap.get(renewalRule),ruleScnaRenewalUsers.get(renewalRule));
                        }
                    }
                }else{
                    RS2_CaseAssignmentUtility.IS_Renewal_Analysts_Not_Found = true;
                    //system.debug('****assigning to Queue*****'+renewal_Config.Default_Queue_Id__c);
                    if(ruleScenarioCasesMap != null && !ruleScenarioCasesMap.IsEmpty()){
                        for(List<case> listCs: ruleScenarioCasesMap.values()){
                            for(Case cs : listCs){
                            //system.debug('****assigning to Queue*****'+renewal_Config.Default_Queue_Id__c);
                                if(renewal_Config.Default_Queue_Id__c != null)
                                    cs.ownerId = renewal_Config.Default_Queue_Id__c;
                            }   
                        }
                    }
                }
            }else{
                 system.debug('*******Custom setting - Switch OFF*****');
            }
            
        }Catch(Exception e){system.debug('****Error Message*****>>>'+e.getlinenumber()+e.getmessage());CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'RS2_Autopopulatevaluesoncase', 'updateRenewalCaseOwner');
        }
    }
    
    public static void assignDirectToQueue(String qId,List<Case> cList){
        if(!cList.isEmpty()){
            System.debug('Assigning*****');
            for(Case c : cList){
                c.ownerId = qId; //should be updated as this is running in before insert trigger.
            }
        }
    }
       
}