/*******************************************************************************************************************
                * Class Name : Test_GSS_UpdateCaseFirstResponse
                * Purpose    : Test class for doing unit testing for the trigger GSS_UpdateCaseFirstResponseTime
                *
                * JIRA       : PP-17991
                * ******************************************************************************************************************
                * Author                               Date            Remarks 
                *
                * HCL-Amit                           07-oct-2010     Created
                * HCL-Amit                           09-oct-2010     Modified to use the recordtype.
                * ****************************************************************************************************************/

            @isTest
            private class Test_GSS_UpdateCaseFirstResponse{
            public static Case testcase;
            public static Case testcase1;
            public static Case testcase2;
            public static List<Case> lstcase;
            public static Entitlement entl;
            public static Entitlement objEntitlement,tempobjEntitlement;
            public static Account acc=new Account();
            public static Account testAccount;
            public static Contact objContact;
            public static Country__c objCountry;
            public static State__c objState ;
            static List<SlaProcess> listSlaProcess;
            static List<String> EntitlementName=new List<String>();
            static User testUser1;
        
            static void setUpData(){
                
                BB8_DataFactory.createCustomSettings();
                BB8_DataFactory.addEmailTemplateForMilestones();
                BB8_DataFactory.insertBB8IntegrationFields();
                
                String RecTypeId;    
                Map<Id, Schema.RecordTypeInfo> mapRecTypeInfo   = new Map<Id, Schema.RecordTypeInfo>();
                       
                mapRecTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosById();// Fetching record types for Account
                system.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$mapRecTypeInfo:'+mapRecTypeInfo);
                for(Schema.RecordTypeInfo recInfo : mapRecTypeInfo.values())
                {
                    if(recInfo.Name.equalsIgnorecase('PARTNER LOCATION'))
                    {
                        RecTypeId = recInfo.recordTypeId;
                        break;
                    }
                }
                
                system.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$RecTypeId:'+RecTypeId);   
                   
                testAccount = new Account();
                testAccount.Name = 'Test Account';        
                testAccount.Country__c = 'INDIA';
                testAccount.Type='Public Sector';
                System.debug('$$$$$$$$$$$$$$$$$$$$$$testAccount:'+testAccount);
                insert testAccount;
                System.debug('$$$$$$$$$$$$$$$$$$$$$$testAccount:'+testAccount);
                
                EntitlementName.add('CSC Entitlement');
                EntitlementName.add('SDK');
                listSlaProcess=[select id,Name from SlaProcess where name in:EntitlementName];
                
               objEntitlement = new Entitlement();
                objEntitlement.Name = EntitlementName[0];
               // SlaProcess objSlaProcess =[select id,Name from SlaProcess where name=:'CSC Entitlement'];
                SlaProcess objSlaProcess=listSlaProcess[0]; 
                objEntitlement.SlaProcessId =objSlaProcess.id; 
                objEntitlement.StartDate = Date.Today();
                objEntitlement.AccountId = testAccount.Id;
                objEntitlement.GSS_Entitlement_Code__c='CSCOEM';
                insert objEntitlement;
                
                tempobjEntitlement = new Entitlement();
                tempobjEntitlement .Name = EntitlementName[1];
              //  SlaProcess objSlaProcess1 =[select id,Name from SlaProcess where name=:'CSC Entitlement Old'];
                SlaProcess objSlaProcess1=listSlaProcess[1]; 
                tempobjEntitlement.SlaProcessId =objSlaProcess1.id; 
                tempobjEntitlement.StartDate = Date.Today();
                tempobjEntitlement.AccountId = testAccount.Id;
                tempobjEntitlement.GSS_Entitlement_Code__c='CSCOEM';
                insert tempobjEntitlement;  

              //  System.debug('$$$$$$$$$$$$$$$$$$ ENtitlement'+objEntitlement);
                
                RecTypeId = '';
                mapRecTypeInfo= Schema.SObjectType.Case.getRecordTypeInfosById();// Fetching record types for Case
                for(Schema.RecordTypeInfo recInfo : mapRecTypeInfo.values())
                {
                    if(recInfo.Name.toUpperCase()=='GSS TECHNICAL SUPPORT')
                    {
                        RecTypeId = recInfo.recordTypeId;
                    }
                }

                       
                testCase = new Case(Origin='Email',GSS_Preferred_Method_of_Contact__c='Email',
                                //GSS_First_Response_Met__c = false,GSS_First_Response_Due_Date__c =(System.now()),
                                GSS_First_Response_Due_Date__c =(System.now()),
                                Priority='3 - Medium', GSS_Problem_Category__c='OS',GSS_Support_Level__c='2',
                                GSS_Support_Customer_Region__c='NASA',RecordTypeId = RecTypeId,
                                GSS_Available_24_7__c='yes',Status='New',Subject ='testing',Description='testing');
                


                    testCase.Escalation_Reason__c='Test Reason';
                    testCase.First_Response_Date__c=System.now()-1;
                    testCase.GSS_Acknowledged_TSE__c = true;
                    insert testCase;
                    

                    
                    
                    
                    System.debug('*********************casemilestone:'+[select caseid from casemilestone where caseid=:testCase.id]);
                    System.debug('*********************flag : '+testCase.GSS_First_Resp_Met__c+'  ###date'+testCase.First_Response_Date__c);
            }

            public static testMethod void testCaseSevAndEntitlementChng(){ 
                
                Test.startTest();
                
                setUpData();
                testcase.Priority='4 - Low';
                System.debug('**********Old_Response_Due_Date:'+testCase.GSS_First_Response_Due_Date__c);
                Update testcase;
                System.debug('**********New_Response_Due_Date:'+testCase.GSS_First_Response_Due_Date__c);
                
               // testcase.Entitlementid=tempobjEntitlement.id;
               // update testcase;   
                
                Test.stopTest();

                   
                
             }

             
                static void SetupData_RegionCalc()
                {    
                    BB8_DataFactory.createCustomSettings();
                    BB8_DataFactory.addEmailTemplateForMilestones();
                    BB8_DataFactory.insertBB8IntegrationFields();
                    string RecTypeId = '';
                    Map<Id, Schema.RecordTypeInfo> mapRecTypeInfo = new Map<Id, Schema.RecordTypeInfo>();
                    
                    Profile p = [select id from profile where name='Standard User']; 
                    testUser1 = new User(alias = 'GSSUser1', email='user1@testorg.com',languagelocalekey='en_US', 
                        emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = p.Id, 
                        timezonesidkey='America/Los_Angeles', username='gssupdatecaseuser1@testorg1.com');
                    
                    insert testUser1;
                    
                    List<Country__c> lstCountry = new List<Country__c>();
                    objCountry = new Country__c();
                    objCountry.Name = 'INDIA';
                    objCountry.Region__c = 'APJ';
                    lstCountry.add(objCountry);
                    //insert objCountry;
                    
                    objCountry = new Country__c();
                    objCountry.Name = 'JAPAN';
                    objCountry.Region__c = 'NASA-UNKNOWN';
                    lstCountry.add(objCountry);
                    
                    objCountry = new Country__c();
                    objCountry.Name = 'CHINA';
                    objCountry.Region__c = '';
                    lstCountry.add(objCountry);
                    
                    insert lstCountry;
                        
                    objState = new State__c();
                    objState.Active__c = true;
                    objState.State_Province_Full_Name__c = 'Delhi';
                    objState.Country__c=objCountry.Id;
                    objState.Region__c = 'APJ';
                    objState.Area_Code__c = '011';
                    insert objState;        
                    
                    RecTypeId = '';
                    mapRecTypeInfo= Schema.SObjectType.Account.getRecordTypeInfosById();// Fetching record types for Case
                    for(Schema.RecordTypeInfo recInfo : mapRecTypeInfo.values())
                    {
                        if(recInfo.Name.toUpperCase()=='CONSULTING ACCOUNT')
                        {
                            RecTypeId = recInfo.recordTypeId;
                            break;
                        }
                    }
                    
                    testAccount = new Account();
                    testAccount.RecordTypeId = RecTypeId;
                    testAccount.Name = 'Test Account';
                    testAccount.Country__c = 'INDIA';
                    testAccount.Type='Public Sector';
                    insert testAccount;
                    
                    RecTypeId = '';
                    mapRecTypeInfo= Schema.SObjectType.Contact.getRecordTypeInfosById();// Fetching record types for Contact
                    for(Schema.RecordTypeInfo recInfo : mapRecTypeInfo.values())
                    {
                        if(recInfo.Name.toUpperCase()=='CONSULTING CONTACT')
                        {
                            RecTypeId = recInfo.recordTypeId;
                            break;
                        }
                    }
                    
                    objContact = new Contact();
                    objContact.RecordTypeId = RecTypeId;
                    objContact.LastName = 'Test';
                    objContact.AccountID = testAccount.ID;
                    objContact.Email = 'test@test.com';
                    objContact.Phone='(011) 234-5678';
                    insert objContact;
                                 
                    
                   objEntitlement = new Entitlement();
                    objEntitlement.Name = 'Test Entitlement';
                    SlaProcess objSlaProcess =[select id,Name from SlaProcess where name=:'CSC Entitlement'];
                    objEntitlement.slaProcessId = objSlaProcess.id;
                    objEntitlement.StartDate = Date.Today();
                    objEntitlement.AccountId = testAccount.Id;
                    objEntitlement.GSS_Entitlement_Code__c='CSCOEM';
                    insert objEntitlement;
                            
                    
                    RecTypeId ='';
                    mapRecTypeInfo= Schema.SObjectType.Case.getRecordTypeInfosById();// Fetching record types for Case
                    for(Schema.RecordTypeInfo recInfo : mapRecTypeInfo.values())
                    {
                        if(recInfo.Name.toUpperCase()=='GSS TECHNICAL SUPPORT')
                        {
                            RecTypeId = recInfo.recordTypeId;
                        }
                    }
                    
                    system.debug('**********************Case RecTypeId'+RecTypeId);       
                                    
                    testCase = new Case();
                    testCase.ContactID = objContact.Id;
                    testCase.AccountID = testAccount.Id;
                    testCase.EntitlementId = objEntitlement.id;
                    testCase.RecordTypeId = RecTypeId;
                    testCase.GSS_Support_Level__c='1';
                    testCase.GSS_Problem_Category__c = 'Installation';
                    testCase.Priority = '2 - High';
                    testCase.Status = 'New';
                    testCase.Subject = 'Subject';
                    testCase.Description = 'Description';
                    testCase.GSS_Preferred_Method_of_Contact__c = 'Email';
                    testCase.Origin = 'Phone';
                    testCase.GSS_Country__c = 'JAPAN';
                    
                    testCase1 = new Case();
                    testCase1.GSS_Alternate_Contact__c = objContact.Id;
                    testCase1.AccountID = testAccount.Id;
                    testCase1.EntitlementId = objEntitlement.id;
                    testCase1.RecordTypeId = RecTypeId;
                    testCase1.GSS_Support_Level__c='1';
                    testCase1.GSS_Problem_Category__c = 'Installation';
                    testCase1.Priority = '2 - High';
                    testCase1.Status = 'New';
                    testCase1.Subject = 'Subject';
                    testCase1.Description = 'Description';
                    testCase1.GSS_Preferred_Method_of_Contact__c = 'Email';
                    testCase1.Origin = 'Phone';
                    testCase1.GSS_Country__c = 'CHINA';
                    
                    lstcase = new List<Case>();
                    
                    testCase2 = new Case();
                    testCase2.GSS_Alternate_Contact__c = objContact.Id;
                    testCase2.AccountID = testAccount.Id;
                    testCase2.EntitlementId = objEntitlement.id;
                    testCase2.RecordTypeId = RecTypeId;
                    testCase2.GSS_Support_Level__c='1';
                    testCase2.GSS_Problem_Category__c = 'Installation';
                    testCase2.Priority = '2 - High';
                    testCase2.Status = 'New';
                    testCase2.Subject = 'Subject';
                    testCase2.Description = 'Description';
                    testCase2.GSS_Preferred_Method_of_Contact__c = 'Email';
                    testCase2.Origin = 'Phone';
                    testCase2.GSS_Country__c = 'INDIA';
                    lstCase.add(testCase2);
                    
                    testCase2 = new Case();
                    testCase2.GSS_Alternate_Contact__c = objContact.Id;
                    testCase2.AccountID = testAccount.Id;
                   testCase2.EntitlementId = objEntitlement.id;
                    testCase2.RecordTypeId = RecTypeId;
                    testCase2.GSS_Support_Level__c='1';
                    testCase2.GSS_Problem_Category__c = 'Installation';
                    testCase2.Priority = '2 - High';
                    testCase2.Status = 'New';
                    testCase2.Subject = 'Subject';
                    testCase2.Description = 'Description';
                    testCase2.GSS_Preferred_Method_of_Contact__c = 'Email';
                    testCase2.Origin = 'Phone';
                    testCase2.GSS_Country__c = 'JAPAN';
                    lstCase.add(testCase2);
                    
                    testCase2 = new Case();
                    testCase2.ContactID = objContact.Id;
                    testCase2.AccountID = testAccount.Id;
                    testCase2.EntitlementId = objEntitlement.id;
                    testCase2.RecordTypeId = RecTypeId;
                    testCase2.GSS_Support_Level__c='1';
                    testCase2.GSS_Problem_Category__c = 'Installation';
                    testCase2.Priority = '2 - High';
                    testCase2.Status = 'New';
                    testCase2.Subject = 'Subject';
                    testCase2.Description = 'Description';
                    testCase2.GSS_Preferred_Method_of_Contact__c = 'Email';
                    testCase2.Origin = 'Phone';
                    testCase2.GSS_Country__c = 'JAPAN';
                    lstCase.add(testCase2);
                    
                    GSS_UpdateCaseFirstResponse.getResponseDates(lstCase);
                }

                public static testMethod void InsertCase()
                {
                    SetupData_RegionCalc();
                    Test.StartTest();
                     
                         
                    insert testCase;
                    
                    testCase.OwnerId = testUser1.id;
                    update testCase;
                    
                    lstcase.add(testCase1);
                    
                    insert lstCase;
                            
                    Test.StopTest();
                } 
                //Created for BB-8 project
                public static testMethod void CGSCase(){
                    //enter cgs entitlement
                         BB8_DataFactory.createCustomSettings();
                    BB8_DataFactory.addEmailTemplateForMilestones();
                    BB8_DataFactory.insertBB8IntegrationFields();
                    
                        System.runAs([select Id from User where isActive=true and Profile.Name ='System Administrator' LIMIT 1][0]) {
                            QnC_Case_Properties__c qncProps = QnC_Case_Properties__c.getOrgDefaults();
                            qncProps.Turn_On_Admin_Group_Sharing__c = true;
                            qncProps.Turn_On_Requester_Sharing__c = true;
                            qncProps.Turn_On_Owner_Sharing_AMER__c = false;
                            upsert qncProps;
                        }
    
                        GSS_UtilityClass.isBeforeInsert_Case = true;
                        GSS_UtilityClass.isBeforeUpdate_Case = true;
                        GSS_UtilityClass.isAfterInsert_Case = true;
                        GSS_UtilityClass.isAfterUpdate_Case = true;
                        
                        Id accRecordType = (Id)(Record_Type_Settings__c.getInstance('GSS_ACC_EC').Record_Type_ID__c);
                        Id contRecordType = (Id)(Record_Type_Settings__c.getInstance('GSS_CON_CC').Record_Type_ID__c);
                        Id techCaseRecType = (Id)(Record_Type_Settings__c.getInstance('GSS_CASE_TS').Record_Type_ID__c);
                        Id prodId = (Id)(GSS_Configuration_Properties_list__c.getInstance('Test ProductId').Setting_value__c);        
                                
                        // Insert Account
                        Account act=new account(name='testing acct',recordtypeId=accRecordType,Country__c='albania',type='territory');        
                        insert act;
                        // Insert Contact       
                        Contact cont =new contact(LastName='testing user',email='testing@testing.com',recordtypeId=contRecordType,accountid=act.id 
                                        ,GSS_CN__c='127382729');        
                        insert cont ;
                         List<slaprocess> slaProcessList;
                         Entitlement e;
                        List<Entitlement> entitlementList = [Select id,name,GSS_Entitlement_Code__c from Entitlement where GSS_Entitlement_Code__c='CGS' limit 1];
                        if(entitlementList.isEmpty()){//none found in existing system, then create a new entitlement with code as CGS
                            slaProcessList = [select name,id from slaprocess where name='carrier grade support' limit 1];
                            //Insert Entitlement
                            e = new Entitlement(name='abcd', AccountId=act.id,EndDate=system.today().addMonths(5),StartDate=System.today(),SlaProcessId=slaProcessList[0].id,GSS_Entitlement_Code__c='CGS');    
                            insert e;
                            entitlementList.add(e);
                        }
                         
                        List<Case> caseInsertList = new List<Case>();
                        
                        // Insert Case : Status[Closed] , Priority[2 - High]
                        Case newCase_one = new Case();
                        newCase_one.Status = 'open' ;
                        newCase_one.Sub_Status__c = 'Resolved';
                        newCase_one.RecordTypeId = techCaseRecType ;
                        newCase_one.EA_Number__c = '111839722';
                        newCase_one.ProductId=prodId;
                        newCase_one.Priority='2 - High';       
                        newCase_one.contactId=cont.id;
                        newCase_one.GSS_Email_Address__c='test@test.com';
                        newCase_one.Subject='Testing';
                        newCase_one.Description='Testing';
                        newCase_one.First_Response_Date__c = System.now().addHours(1);
                        newCase_one.entitlementId=entitlementList[0].id;
                        
                        caseInsertList.add(newCase_one);
                        
                         // Insert Case : Status[Open] , Priority[2 - High]
                       Case newCase_two = new Case();
                        newCase_two.Status = 'open' ;
                        newCase_two.Sub_Status__c = 'Unassigned';
                        newCase_two.RecordTypeId = techCaseRecType ;
                        newCase_two.EA_Number__c = '111839722';
                        newCase_two.ProductId=prodId;
                        newCase_two.Priority='2 - High';    
                        newCase_two.Subject='Testing';
                        newCase_two.Description='Testing';      
                        newCase_two.contactId=cont.id;
                        newCase_two.First_Response_Date__c = System.now().addHours(1);
                       newCase_two.entitlementId=entitlementList[0].id;
                        
                        caseInsertList.add(newCase_two);
                        Test.startTest();
                        insert caseInsertList ;
                        //Test.stopTest();
                        Set<Id> caseIdSet = new Set<Id>();
                       caseIdSet.add(newCase_one.id);
                       caseIdSet.add(newCase_two.id);
                       GSS_UpdateCaseFirstResponse.updateFirstResponse(caseIdSet);
                       GSS_UpdateCaseFirstResponse.getCGSResponseDates(caseIdSet);
                     
                       CaseMilestone milestone = [select TargetDate, caseId, IsCompleted, MilestoneTypeId,CompletionDate from CaseMilestone where caseid =: newCase_one.id AND MilestoneTypeId =: Label.MilestoneTypeId limit 1];
                                                     
                                if(milestone != null && !milestone.IsCompleted ){//first response
                                    milestone.CompletionDate = System.now();
                                    System.debug('milestone*****b4 update'+milestone);
                                    update milestone;
                                    
                                }   
                        System.debug('milestone*****'+milestone);
                        
                        GSS_UtilityClass.isAfterUpdate_Case = false;
                        //Change the case priority
                        newCase_one.Priority='3 - Medium';
                        update newCase_one;
                        Test.stopTest();
                        //GSS_UpdateCaseFirstResponse.AU_FirstResponse(new List<Case>{newCase_one},oldMap);
                        //GSS_UpdateCaseFirstResponse.getResponseDates(caseInsertList);
                       
                       //Adding sla milestone
                      
                            
                             CaseSLASequenceController.isCaseSLAMilestoneAfterUpdate = true;
                             Case_Sla__c caseSLA1 = new Case_Sla__c(Case__c = newCase_one.id,Final_correction_actual__c=System.now(),Final_Correction_due__c=System.now().addMonths(1),First_Response_Due_Date__c=System.now().addMonths(1),First_Response_Due_In__c = System.now(),RCA_Delivered__c=System.now(),RCA_Due__c=System.now().addMonths(1),Service_restoration_actual__c=System.now(),Service_restoration_due__c=System.now().addMonths(1));
                             Case_Sla__c caseSLA2 = new Case_Sla__c(Case__c = newCase_two.id,Final_correction_actual__c=System.now(),Final_Correction_due__c=System.now().addMonths(1),First_Response_Due_Date__c=System.now().addMonths(1),First_Response_Due_In__c = System.now(),RCA_Delivered__c=System.now(),RCA_Due__c=System.now().addMonths(1),Service_restoration_actual__c=System.now(),Service_restoration_due__c=System.now().addMonths(1));
                             insert new List<Case_Sla__c>{caseSLA1};
                             insert new List<Case_Sla__c>{caseSLA2};
                             newCase_two.Priority='3 - Medium';
                             update newCase_two;
                             
                             
                             
                             List<Entitlement> entitlementListASP = [Select id,name,GSS_Entitlement_Code__c from Entitlement where GSS_Entitlement_Code__c='ASP' limit 1];
                            GSS_UtilityClass.isAfterUpdate_Case = true;
                            // Insert Case : Status[Open] , Priority[2 - High]
                            Case newCase_3 = new Case();
                            if(entitlementListASP.size()>0){
                                
                                newCase_3.Status = 'open' ;
                                newCase_3.Sub_Status__c = 'Unassigned';
                                newCase_3.RecordTypeId = techCaseRecType ;
                                newCase_3.EA_Number__c = '111839722';
                                newCase_3.ProductId=prodId;
                                newCase_3.Priority='2 - High';    
                                newCase_3.Subject='Testing';
                                newCase_3.Description='Testing';      
                                newCase_3.contactId=cont.id;
                                newCase_3.First_Response_Date__c = System.now().addHours(1);
                                newCase_3.entitlementId=entitlementListASP[0].id;
                                insert newCase_3;
                            }   
                            //change the entitlement to CGS
                            newCase_3.entitlementId=entitlementList[0].id;
                            update newCase_3;
                            
                            //deactivate case triggers
                            GSS_UtilityClass.isBeforeUpdate_Case =true;
                            GSS_UtilityClass.isAfterUpdate_Case = true;
                            newCase_two.Priority='4 - Low';
                             update newCase_two;                             
                             GSS_UpdateCaseFirstResponse.runPopulateCGSMilestone = true;
                             Map<id,DateTime> responseDates = new Map<id,DateTime>();
                             responseDates.put(newCase_two.id, system.now());
                             GSS_UpdateCaseFirstResponse.populateCGSMilestones(responseDates,new Set<Id>{newCase_two.id});
                             GSS_UpdateCaseFirstResponse.populateCGSMilestones(responseDates,new Set<Id>{newCase_3.id});
                             
                }
            }