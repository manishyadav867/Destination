/*********************************************************************************************************
// Name:L2O_OpportunityHelperTest
// Description: This is a Test Class used to cover the code for L2O_OpportunityHelper class
// Created By: Accenture (July 29 2016)

// ************************Version Updates******************************************************************/
@isTest(seeAllData = true)
public class L2O_OpportunityHelperTest{
    public static Opportunity opptyRecd;
    public static Opportunity opptyRecd12;
    public static List<Account> acctList;
    public static List<Opportunity> opplists = new List<Opportunity>(); 
    public static List<Account_Extension__c> acctExtList ;
    public static User u1;
    public static User u2;
    public static User u3;
    public static String oppRId;
    public static Contact contRecd = new Contact();
    public static void setupdata(){
        List<PLMStatic__c> plmList = new List<PLMStatic__c>();
            PLMStatic__c plms1 = new PLMStatic__c();
            plms1.Name = 'MasterAccountLayoutRecType';
            plmList.add(plms1);
            
            PLMStatic__c plms2 = new PLMStatic__c();
            plms2.Name = 'PartnerLocationRecType';
            plmList.add(plms2);
            
            PLMStatic__c plms3 = new PLMStatic__c();
            plms3.Name = 'VirtualPartnerAccountRecType';
            plmList.add(plms3);
            database.insert(plmList, false);
            
            List<DNBI_Properties__c> dnbipList = new List<DNBI_Properties__c>();
            
            DNBI_Properties__c  dnbip = new DNBI_Properties__c();
            dnbip.Name = 'Integration_Batch_Size';
            dnbip.DNB_Value__c= '50';
            dnbipList.add(dnbip);
            
         
            DNBI_Properties__c  dnbip1 = new DNBI_Properties__c();
            dnbip1.Name = 'OutputRecordCountDNBIMaxQuantity';
            dnbip1.DNB_Value__c= '50';
            dnbipList.add(dnbip1);
         
            DNBI_Properties__c  dnbip2 = new DNBI_Properties__c();
            dnbip2.Name = 'OutputRecordCountDNBIMaxQuantityForCMP';
            dnbip2.DNB_Value__c= '50';
            dnbipList.add(dnbip2);
         
            DNBI_Properties__c  dnbip3 = new DNBI_Properties__c();
            dnbip3.Name = 'ConfidenceCode';
            dnbip3.DNB_Value__c= '50';
            dnbipList.add(dnbip3);
         
            DNBI_Properties__c  dnbip4 = new DNBI_Properties__c();
            dnbip4.Name = 'ConfidenceCode_AccountSearch';
            dnbip4.DNB_Value__c= '50';
            dnbipList.add(dnbip4);
         
            DNBI_Properties__c  dnbip5 = new DNBI_Properties__c();
            dnbip5.Name = 'Dummy_DNBCall_Id';
            dnbip5.DNB_Value__c= '50';
            dnbipList.add(dnbip5);
         
            DNBI_Properties__c  dnbip6 = new DNBI_Properties__c();
            dnbip6.Name = 'TrilliumMatchingScore';
            dnbip6.DNB_Value__c= '50';
            dnbipList.add(dnbip6);
         
            DNBI_Properties__c  dnbip7 = new DNBI_Properties__c();
            dnbip7.Name = 'SearchPriority';
            dnbip7.DNB_Value__c= '50';
            dnbipList.add(dnbip7);
         
            DNBI_Properties__c  dnbip8 = new DNBI_Properties__c();
            dnbip8.Name = 'QueryBatchSize';
            dnbip8.DNB_Value__c= '50';
            dnbipList.add(dnbip8);
         
            DNBI_Properties__c  dnbip9 = new DNBI_Properties__c();
            dnbip9.Name = 'EndPointURL';
            dnbip9.DNB_Value__c= '50';
            dnbipList.add(dnbip9);
           
            database.insert(dnbipList, false);
      
      //Adding OpportunityTeamMemberRole__c data
      List<OpportunityTeamMemberRole__c> otmList = new List<OpportunityTeamMemberRole__c>();
      if(OpportunityTeamMemberRole__c.getInstance('AW AE/PSR')==null){
        OpportunityTeamMemberRole__c otmr1 = new OpportunityTeamMemberRole__c(name='AW AE/PSR',Access__c='Edit');
        otmList.add(otmr1);
      }
      if(OpportunityTeamMemberRole__c.getInstance('AW SAM')==null){
        OpportunityTeamMemberRole__c otmr2 = new OpportunityTeamMemberRole__c(name='AW SAM',Access__c='Edit');
        otmList.add(otmr2);
      }
      if(OpportunityTeamMemberRole__c.getInstance('AW SE')==null){
        OpportunityTeamMemberRole__c otmr3 = new OpportunityTeamMemberRole__c(name='AW SE',Access__c='Edit');
        otmList.add(otmr3);
      }
      if(OpportunityTeamMemberRole__c.getInstance('EISR')==null){
        OpportunityTeamMemberRole__c otmr4 = new OpportunityTeamMemberRole__c(name='EISR',Access__c='Edit');
        otmList.add(otmr4);
      }
      if(otmList!=null){
        upsert otmList;
      }
      
      
      
      //Adding L2O variables data
      if(L2O_Variables__c.getOrgDefaults()==null){
        L2O_Variables__c l2o = new L2O_Variables__c(SetupOwnerId =UserInfo.getOrganizationId(), 
        Name = 'VMware',
        Airwatch_URL__c='https://na3.salesforce.com/',
        CAM_Read_Write_Access__c=true,
        Enable_CAM_On_Oppty_Team__c=false,
        Enable_CAM_On_Oppty__c=true,
        Enable_Contact_Role_Validation_On_Oppty__c=true,
        Enable_Technical_Contact_Validation_Oppt__c=true,
        L2O_Enable_Primary_Con_Deal_Closure_Val__c=true,
        SSO_App_Url__c='/idp/login?app=0spf0000000005B',
        SSO_Open_Quote__c=false);
        upsert l2o;
            }
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            Profile p1 = [SELECT Id FROM Profile WHERE Name='AMER AW Specialist']; 
            u1 = new User(Alias = 'csouser1', Email='testmembusr1@test.com', 
                            EmailEncodingKey='UTF-8', LastName='TestingMemb1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p1.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testmembuser1@testorg.com', IsActive=true, CurrencyIsoCode='USD',Division='AMER');
        
            insert u1; 
            
            u2 = new User(Alias = 'csouser2', Email='testmembusr@test.com', 
                                EmailEncodingKey='UTF-8', LastName='TestingMemb2', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testmembuser2@testorg3.com', IsActive=true, CurrencyIsoCode='USD',Division='AMER');
            
            insert u2; 
            
            u3 = new User(Alias = 'csouser1', Email='testmembusr1@test.com', 
                            EmailEncodingKey='UTF-8', LastName='TestingMemb1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testmembuser1@testorg.com33', IsActive=true, CurrencyIsoCode='USD',Division='AMER');
        
            insert u3; 
            
            VMWare_Territory__c vmwareTer1 = new VMWare_Territory__c(Name='Test',AW_AE_PSR__c=u1.id);
             insert vmwareTer1;
            
            acctList = new List<Account>();
             String acctRId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End Customer').getRecordTypeId();
             
             Account accRec1=new Account(Name='TestAccount1',RecordtypeId=acctRId,CurrencyIsoCode='USD',Country__c='India',Primary_Field_Sales_Territory__c = vmwareTer1.id);
             acctList.add(accRec1);
             
             Account accRecd2=new Account(Name='TestAccount2',RecordtypeId=acctRId,CurrencyIsoCode='USD',Country__c='India');
             acctList.add(accRecd2);
             insert acctList;
             
            acctExtList = new List<Account_Extension__c>();
             acctExtList=[select id,AW_SE_Manual_Override__c from Account_Extension__c where  Account__c in : acctList];
                       
             acctExtList[0].AW_SE_Manual_Override__c = u1.id;
             update acctExtList;
             
             acctExtList[0].AW_SE_Manual_Override__c = null;
             update acctExtList;
               
               
           oppRId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
              Date myDate = date.newInstance(2017, 12, 20);
              opptyRecd=new Opportunity(Name='TestOppty123',StageName='02-Qualified',CloseDate=myDate,AccountId=acctList[0].id,CurrencyIsoCode='USD',recordtypeid=oppRId,Business_Line__c= 'AW',Route_to_Market__c='Channel',VMWProductLine__c = 'abcd' );
              insert opptyRecd;
              opptyRecd12=new Opportunity(Name='TestOppty12',StageName='07a - Agreement to Purchase',CloseDate=myDate,AccountId=acctList[0].id,CurrencyIsoCode='USD',recordtypeid=oppRId,Business_Line__c= 'AW',Route_to_Market__c='Channel',VMWProductLine__c = 'abcd');
              insert opptyRecd12;
              
               OpportunityTeamMember otm=new OpportunityTeamMember (userid=u2.id,opportunityid=opptyRecd.id,TeamMemberRole='Channel Account Manager',OpportunityAccessLevel='Read');
                insert otm;
            
             contRecd=new Contact(LastName='TestContact',Email='testcont@test.com',Accountid=acctList[1].id );
             insert contRecd;
        
    }
    public static testmethod void L2O_HeplerMethod(){
                                 
              
              setupdata();
              test.startTest(); 
             //PriceBook2 pb = [select id, IsStandard from Pricebook2 where IsStandard = true];  
            //List<Product2> prods = new List<Product2>();
               List<PriceBookEntry> pbe = new List<PriceBookEntry>();
               Product2  prod =new Product2(Name='TestAWProduct1',isActive=true,CurrencyISOCode='USD',Division__c = 'SDDC', Product_Group__c = 'MOBILE',Platform_Group__c ='EMM', Product_Platform__c = 'SCL');
               insert prod;
                 
                 Product2  prod2 =new Product2(Name='TestAWProduct2',isActive=true,CurrencyISOCode='USD',Division__c = 'SDDC', Product_Group__c = 'WORKSPACE SERVICES',Platform_Group__c ='EMM', Product_Platform__c = 'SCL');
               insert prod2;
                 
                 Id pricebookId = Test.getStandardPricebookId();
                 Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
                 insert customPB;
             
                 pbe.add(new PriceBookEntry(PriceBook2Id=pricebookId,product2Id=prod.Id,CurrencyISOCode='USD',UnitPrice=20,isActive=true,useStandardPrice=false));
                 pbe.add(new PriceBookEntry(PriceBook2Id=customPB.id,product2Id=prod.Id,CurrencyISOCode='USD',UnitPrice=20,isActive=true,useStandardPrice=false)); 
                 pbe.add(new PriceBookEntry(PriceBook2Id=pricebookId,product2Id=prod2.Id,CurrencyISOCode='USD',UnitPrice=20,isActive=true,useStandardPrice=false));
                 pbe.add(new PriceBookEntry(PriceBook2Id=customPB.id,product2Id=prod2.Id,CurrencyISOCode='USD',UnitPrice=20,isActive=true,useStandardPrice=false));                     
                 insert pbe;
           
              
                  VMWare_Territory__c vmwareTer = new VMWare_Territory__c(Name='Test',AW_AE_PSR__c=u1.id);
                  insert vmwareTer;
                  
                  vmwareTer.AW_AE_PSR__c = u2.id;
                  update vmwareTer;
                  
                  
                  
                 
             
                  OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=opptyRecd.Id,PriceBookEntryId=pbe[1].Id,UnitPrice=10,Quantity=1,Quantity__c=1, Amount__c = 10, SNS__c = '1 Year',SNS_Amount__c = 10,Product_Discount_Amount__c =1.0,AirWatch_Product__c = true);
                  OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=opptyRecd12.Id,PriceBookEntryId=pbe[1].Id,UnitPrice=10,Quantity=1,Quantity__c=1, Amount__c = 20, SNS__c = '1 Year',SNS_Amount__c = 15,Product_Discount_Amount__c =1.0,AirWatch_Product__c = true);
                  List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                  oliList.add(oli);
                  oliList.add(oli2);
                  insert oliList;
                  
                  opptyRecd.AWOpportunityID__c=oppRId;
                  opptyRecd.PriceBook2Id=customPB.id;
                  update opptyRecd;
                  
                  opptyRecd12.AWOpportunityID__c=oppRId;
                  opptyRecd12.PriceBook2Id=customPB.id;
                  update opptyRecd12;
                  
                  List<opportunity> Lopp=[select id,StageName,Name,AccountId,CloseDate,No_of_Airwatch_Products__c,CurrencyISOCode,VMWProductLine__c,recordtypeid,Route_to_Market__c,Business_Line__c from Opportunity where id=:opptyRecd.Id or id=:opptyRecd12.Id ];
                  
                List<Opportunity> optyList = new List<Opportunity>();
                optyList.add(Lopp[0]);
                optyList.add(Lopp[1]);
                Map<ID,Opportunity> optyMap = new Map<ID,Opportunity>();
                optyMap.put(Lopp[0].id,Lopp[0]);
                optyMap.put(Lopp[1].id,Lopp[1]);
                
                List<OpportunityContactRole> opptycntRoleList = new List<OpportunityContactRole>();
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.Role='Reseller';
                ocr.ContactId=contRecd.id;
                ocr.OpportunityId=opptyRecd.id;
                ocr.IsPrimary=true;
                opptycntRoleList.add(ocr);
                
                OpportunityContactRole ocr2 = new OpportunityContactRole();
                ocr2.Role='Distributor';
                ocr2.ContactId=contRecd.id;
                ocr2.OpportunityId=opptyRecd.id;
                ocr2.IsPrimary=false;
                opptycntRoleList.add(ocr2);
              
                insert opptycntRoleList;
                
                 OpportunityTeamMember otm2=new OpportunityTeamMember (userid=u3.id,opportunityid=opptyRecd.id,TeamMemberRole='Channel Account Manager',OpportunityAccessLevel='Read');
                insert otm2;
                
                OpportunityTeamMember otm3=new OpportunityTeamMember (userid=u1.id,opportunityid=opptyRecd.id,TeamMemberRole='Channel Account Manager',OpportunityAccessLevel='Read');
                insert otm3;           
                  
                
                Map<Id,Account> acctMap = new Map<Id,Account>();
                acctMap.put(acctList[0].id,acctList[0]);
                Set<ID> acctSet = new Set<ID>();
                Set<ID> optySet = new Set<ID>();
                acctSet.add(acctList[0].id);
                optySet.add(opptyRecd.id);
                
                System.runAs(u1){
                L2O_OpportunityHelper.enforceValidationRules(optyList,optyMap);
                L2O_OpportunityHelper.checkTeritoryUpdate(acctList,acctMap);
                L2O_OpportunityHelper.createOppTeMem(optySet,acctSet);
                    
                 VMWare_Territory__c vmwareTrt = new VMWare_Territory__c(Name='Testing');
                 insert vmwareTrt;
             
                VMWare_Territory__c vmwareTert = new VMWare_Territory__c(Name='Test');
                insert vmwareTert;
             
                String acctRIdd = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End Customer').getRecordTypeId();
                Account accRec3 = new Account(Name='TestAccount1',RecordTypeId=acctRIdd ,type='SLED' , Primary_Field_Sales_Territory__c = vmwareTert.Id );
                insert accRec3;
                
                
                String oppRIdd = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
                     
                opplists.add(new Opportunity(Name='test',AccountId=accRec3.Id,RecordTypeId=oppRIdd,CloseDate=System.Today(),StageName='02 - Qualified',currencyISOCode='USD',Route_to_Market__c='Channel',VMWProductLine__c = 'abcd',Business_Line__c = 'AW',AW_SE_Manual_Override__c = u1.id ));
                     
                opplists.add(new Opportunity(Name='test12',AccountId=accRec3.Id,RecordTypeId=oppRIdd,CloseDate=System.Today(),StageName='02 - Qualified',currencyISOCode='USD',Route_to_Market__c='Channel',VMWProductLine__c = 'abcd',Business_Line__c = 'AW',AW_SE_Manual_Override__c = u1.id ));
                
                
                
                insert opplists;
                system.debug('*********************123');
                
               
                 opplists[0].accountid =accRec3.Id;
                 opplists[0].AW_SE_Manual_Override__c = u2.id;
                 update opplists;
                   
                   
                   accRec3.Primary_Field_Sales_Territory__c = vmwareTrt.Id;
                   
                   update accRec3;
                                     
                   
             
        
        }
         test.stopTest();
    
    }
public static testmethod void L2O_HeplerMethod2(){
            
       
            
            list<user> userList11 = new list<user>();
            id pfid=Profile_Name_Mapping__c.getInstance('Profile - 1').Profile_Id__c;
            userList11.add(new User(alias = 'standt', email='standardldruser@testorg.com',
                                    emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = pfid,
                                    timezonesidkey='America/Los_Angeles', username='ldrUser@testorg.com',Division = 'AMER'));
                                    
            userList11.add(new User(alias = 'sd12t', email='stansdsdardldruser@te12storg.com',
                                    emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = pfid,
                                    timezonesidkey='America/Los_Angeles', username='ldrUser1@testorg.com',Division = 'AMER'));
                                    
            userList11.add(new User(alias = 'sd14t', email='stansd23sdardldruser@te12storg.com',
                                    emailencodingkey='UTF-8', lastname='Testing3', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = pfid,
                                    timezonesidkey='America/Los_Angeles', username='ldrUser2@testorg.com',Division = 'AMER'));
                                    
            userList11.add(new User(alias = 's4514t', email='stansd23sdardldruser@te12storg.com',
                                    emailencodingkey='UTF-8', lastname='Testing4', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = pfid,
                                    timezonesidkey='America/Los_Angeles', username='ldghUser2@testorg.com',Division = 'AMER'));                                 
                                    
            insert userList11 ;
            
                     
             System.runAs(userList11[3]){
             list<VMWare_Territory__c> territoryList = new list<VMWare_Territory__c>();
             
             territoryList.add(new VMWare_Territory__c(Name = 'TestTerritory1',LDR__c = userList11[0].Id,EM_ISR_IAR__c = userList11[0].Id,EM_LDR__c = userList11[0].Id,EM_Rep__c = userList11[0].Id,iPBM__c = userList11[0].Id,ISR_IAR__c = userList11[0].Id,Edu_Rep__c = userList11[0].Id,SSM__c = userList11[0].Id,PBM__c = userList11[0].Id,Rep__c = userList11[0].Id,Spring_ISR_IAR__c = userList11[0].Id,Spring_LDR__c = userList11[0].Id,AW_AE_PSR__c = userList11[0].Id,Spring_Rep__c = userList11[0].Id,SSROMRinLatAM__c = userList11[0].Id ,EISR__c = userList11[0].Id,AW_SAM__c = userList11[0].Id,AW_SE__c = userList11[0].Id));        
                //1
             territoryList.add(new VMWare_Territory__c(Name = 'TestTerritory2',LDR__c = userList11[1].Id,EM_ISR_IAR__c = userList11[1].Id,EM_LDR__c = userList11[1].Id,EM_Rep__c = userList11[1].Id,iPBM__c = userList11[1].Id,ISR_IAR__c = userList11[1].Id,Edu_Rep__c = userList11[1].Id,SSM__c = userList11[1].Id,PBM__c = userList11[1].Id,Rep__c = userList11[1].Id,Spring_ISR_IAR__c = userList11[1].Id,Spring_LDR__c = userList11[1].Id,AW_AE_PSR__c = userList11[1].Id,Spring_Rep__c = userList11[1].Id,SSROMRinLatAM__c = userList11[1].Id ,EISR__c = userList11[1].Id,AW_SAM__c = userList11[1].Id));          
                //2
            territoryList.add(new VMWare_Territory__c(Name = 'TestTerritory2',LDR__c = userList11[1].Id,EM_ISR_IAR__c = userList11[1].Id,EM_LDR__c = userList11[1].Id,EM_Rep__c = userList11[1].Id,iPBM__c = userList11[1].Id,ISR_IAR__c = userList11[1].Id,Edu_Rep__c = userList11[1].Id,SSM__c = userList11[1].Id,PBM__c = userList11[1].Id,Rep__c = userList11[1].Id,Spring_ISR_IAR__c = userList11[1].Id,Spring_LDR__c = userList11[1].Id,AW_AE_PSR__c = userList11[1].Id,Spring_Rep__c = userList11[1].Id,SSROMRinLatAM__c = userList11[1].Id ,EISR__c = userList11[1].Id,AW_SAM__c = userList11[1].Id,AW_SE__c = userList11[1].Id));
            //3         
             insert territoryList;  
                
                PriceBook2 pb = [select id, IsStandard from Pricebook2 where IsStandard = true limit 10];
                
                list<pricebookEntry> pblist = new list<pricebookEntry>();
                list<product2> plist=new list<product2>();
        
                plist.add(new Product2(Name='abc',CurrencyIsoCode='USD',Hybrid_Cloud__c = true)); //VSPP
                plist.add(new Product2(Name='abc',CurrencyIsoCode='USD',services__c = false, Hybrid_Cloud__c = false)); //License
                insert plist;
                
                pblist.add(new PriceBookEntry(PriceBook2Id=pb.id,product2Id=plist[0].Id,CurrencyISOCode='USD',UnitPrice=0,isActive=true,useStandardPrice=false));
                pblist.add(new PriceBookEntry(PriceBook2Id=pb.id,product2Id=plist[1].Id,CurrencyISOCode='USD',UnitPrice=0,isActive=true,useStandardPrice=false));
                
                insert pblist;
             
        
                String oppRIdd = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Sales Opportunity').getRecordTypeId();
                acctList = new List<Account>();
                String acctRId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End Customer').getRecordTypeId();
                 
                 Account accRec1=new Account(Name='TestAccount1',RecordtypeId=acctRId,CurrencyIsoCode='USD',Country__c='India',Primary_Field_Sales_Territory__c = territoryList[0].id);
                 acctList.add(accRec1);
                 Account accRecd2=new Account(Name='TestAccount2',RecordtypeId=acctRId,CurrencyIsoCode='USD',Country__c='India',Primary_Field_Sales_Territory__c = territoryList[1].id);
                 acctList.add(accRecd2);
                 
                 Account accRecd3=new Account(Name='TestAccount3',RecordtypeId=acctRId,CurrencyIsoCode='USD',Country__c='India',Primary_Field_Sales_Territory__c = territoryList[2].id);
                 acctList.add(accRecd3);
             
                insert acctList;
             
            
                opplists.add(new Opportunity(Name='test',AccountId=acctList[0].Id,RecordTypeId=oppRIdd,CloseDate=System.Today(),StageName='02 - Qualified',currencyISOCode='USD',Route_to_Market__c='Channel',VMWProductLine__c = 'abcd',Business_Line__c = 'Vmware',AWOpportunityID__c = '',AW_SE_Manual_Override__c = userList11[0].Id ));
                         
                opplists.add(new Opportunity(Name='test12',AccountId=acctList[1].Id,RecordTypeId=oppRIdd,CloseDate=System.Today(),StageName='02 - Qualified',currencyISOCode='USD',Route_to_Market__c='Channel',VMWProductLine__c = 'abcd',Business_Line__c = 'Vmware',AWOpportunityID__c = '',AW_SE_Manual_Override__c = userList11[1].Id));
                
                opplists.add(new Opportunity(Name='test123',AccountId=acctList[1].Id,RecordTypeId=oppRIdd,CloseDate=System.Today(),StageName='02 - Qualified',currencyISOCode='USD',Route_to_Market__c='Channel',VMWProductLine__c = 'abcd',Business_Line__c = 'Vmware',AWOpportunityID__c = '',AW_SE_Manual_Override__c = userList11[1].Id));
                    
                insert opplists;
            
            list<OpportunityLineItem> ollist=new list<OpportunityLineItem>();
            
            ollist.add(new OpportunityLineItem(Quantity=1466.37,Monthly_Revenue__c=66666.45,Duration_Months__c=2,OpportunityId=opplists[0].id,UnitPrice=12345,
            Before_Rebate_Amount__c=666666,Applied_Flat_Rebate__c=false,PriceBookEntryId=pblist[0].id,SNS_Amount__c=10.00,Amount__c = 1234.0,ACV_Amount__c=1111.23,
            AirWatch_Product__c = true));   
            
            ollist.add(new OpportunityLineItem(Quantity=1476.37,Monthly_Revenue__c=76666.45,Duration_Months__c=2,OpportunityId=opplists[0].id,UnitPrice=12345,
            Before_Rebate_Amount__c=666666,Applied_Flat_Rebate__c=false,PriceBookEntryId=pblist[0].id,SNS_Amount__c=10.00,Amount__c = 1234.0,ACV_Amount__c=1111.23,
            AirWatch_Product__c = true));
            
            ollist.add(new OpportunityLineItem(Quantity=1466.37,Monthly_Revenue__c=66666.45,Duration_Months__c=2,OpportunityId=opplists[1].id,UnitPrice=12345,
            Before_Rebate_Amount__c=666666,Applied_Flat_Rebate__c=false,PriceBookEntryId=pblist[0].id,SNS_Amount__c=10.00,Amount__c = 1234.0,ACV_Amount__c=1111.23,
            AirWatch_Product__c = true));   
            
            ollist.add(new OpportunityLineItem(Quantity=1476.37,Monthly_Revenue__c=76666.45,Duration_Months__c=2,OpportunityId=opplists[1].id,UnitPrice=12345,
            Before_Rebate_Amount__c=666666,Applied_Flat_Rebate__c=false,PriceBookEntryId=pblist[0].id,SNS_Amount__c=10.00,Amount__c = 1234.0,ACV_Amount__c=1111.23,
            AirWatch_Product__c = true));

            insert ollist;
            system.debug('ollist759'+ollist);
            
             set<Id> setUpdatedTerittories = new set<Id>();
             //list<Opportunity> newList = new list<Opportunity> ();
             set<Id> oppIds = new set<Id>();      
             set<id> accountIds = new set<id>();                   
             for(opportunity o :opplists){
                 
                 oppIds.add(o.id);
                 
             }
             
              for(account a :acctList){
                setUpdatedTerittories.add(a.Primary_Field_Sales_Territory__c);
                 accountIds.add(a.id);
             }
             
             L2O_OpportunityHelper.createOppTeMem(oppIds,accountIds);
                          
             opplists[0].AW_SE_Manual_Override__c = userList11[2].id;
             opplists[1].AW_SE_Manual_Override__c = null;
             opplists[0].AccountId=acctList[1].Id;
             opplists[1].AccountId=acctList[0].Id;
             oppLists[0].AWOpportunityID__c='TestId';
             oppLists[1].AWOpportunityID__c='TestId';
             oppLists[2].AWOpportunityID__c='TestId';
             L2O_OpportunityHelper.recursiveCheckSEOverrideOnOpty = false;
             L2O_OpportunityHelper.isaccountupdteonopty=false;
             
             
             test.startTest();
             update opplists ;
             
             
             
             L2O_OpportunityHelper.teritoryUserLookupUpdate(setUpdatedTerittories);
            
            
            
             list<Account_Extension__c> AEx = [select id,name,Account__c,AW_SE_Manual_Override__c from Account_Extension__c where Account__c in :accountIds limit 5]; 
             
             AEx[0].AW_SE_Manual_Override__c = userList11[3].id;
             AEx[1].AW_SE_Manual_Override__c = userList11[2].id;
                                     
             update AEx;
             
             AEx[0].AW_SE_Manual_Override__c = null;
             AEx[1].AW_SE_Manual_Override__c = null;    
            update AEx;          
             
            //L2O_OpportunityHelper.LoCounter();    
             
            test.stopTest();  
        }
     }
     
     
             

}