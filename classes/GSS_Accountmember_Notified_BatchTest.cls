@isTest(seeallData=true)
    private class GSS_Accountmember_Notified_BatchTest {
        public static list<case> tCases = new list<case>();
        public static User cowner;
        public static map<case,id> caseAcountIdMap = new map<case,id>();
        public static Map<Id,List<String>> accountIdEmailListMap = new  Map<Id,List<String>>();
        public static String caseId;
        public static case c0 = new case();
        public static case c1 = new case();
        public static case c3 = new case();
        public static case c4 = new case();
        public static List <Account_Member__c> memlist = new List <Account_Member__c>();
        public static List <Contact_Member__c> contlist = new List <Contact_Member__c>();
        public static GSS_SuppCenterRegion_Mapping__c businessHours = GSS_SuppCenterRegion_Mapping__c.getInstance('APJ');
        public static GSS_SuppCenterRegion_Mapping__c bHour = new GSS_SuppCenterRegion_Mapping__c();
        public static TimeZone tz = UserInfo.getTimeZone();
        public static Integer h = (tz.getOffset(DateTime.valueOf(System.now())))/(1000*60*60);
        public static Integer m = math.mod(tz.getOffset(DateTime.valueOf(System.now())),(1000*60*60))/(1000*60);
        
        public static List<Case_Extension__c> ceList = new List<Case_Extension__c>();
        public static User u;
        public static Id pro;
        public static Profile_Name_Mapping__c prf = CustomSettingUtility.getProfileNameMapping('GSS System Administrator');
        public static Account ac1;
        public static Contact newc;
        public static ID cRecordType = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CASE_CS').Record_Type_ID__c);
        public static void setupdata(){
            pro=Id.ValueOf(prf.Profile_Id__c);
            u = new User(Alias = 'alias',email='standarduser@testorg.com',emailencodingkey='UTF-8',Username = 'someuser@somedomain.com',
                    Lastname = 'somelastname',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',CommunityNickname = 'somecommunitynickname',
                    profileid =pro, country='United States', Division = 'APAC');
            insert(u);
            system.runAs(u){
            if(GSS_Configuration_Properties_list__c.getInstance('Date')==null){
                    GSS_Configuration_Properties_list__c config=new GSS_Configuration_Properties_list__c(name = 'Date', Setting_Type__c = 'Date Time will be like this 2015-08-08 09:10:06', Setting_value__c= '2015-08-08 09:10:06');
              insert config;
                }
          
             bHour.End_Time__c = String.valueOf(System.now().addHours(2).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';  bHour.GSS_Support_Center__c = 'Bangalore';  bHour.TimeZone__c = 'APJ1' ; bHour.Name = 'APJ1' ;
             insert bHour;
                //Creating Account for a customer
                ID recTypeAccountId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_ACC_EC').Record_Type_ID__c);
                ac1 = new Account(Name='AccountTest1',recordtypeId= recTypeAccountId , Country__c='INDIA' );
                insert ac1;
                
                //Creating Contact for a customer
                ID recordTypeConId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CON_CC').Record_Type_ID__c);
                newc = new Contact(FirstName='spanEmailContact',LastName='Test1',Email='email@spanEmail.com',recordtypeId=recordTypeConId);
                newc.accountid=ac1.id;
                insert newc;
                
                //Inserting User
                Profile_Name_Mapping__c pCusObj = CustomSettingUtility.getProfileNameMapping('GSS System Administrator');  
                Id pId = Id.ValueOf(pCusObj.Profile_Id__c);
                
               cowner = new User(alias = 'GSS223', email='user1@testorg.com',languagelocalekey='en_US', 
                    emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = pId, 
                    timezonesidkey='America/Los_Angeles', username='gssutiluser1@testorg2.com',isActive =true,division='EMEA');
                insert cowner;
                 Account_Member__c member = new Account_Member__c(Account__c=ac1.id,User__c=cowner.id,Subscribe__c=true);
                //Account_Member__c member2 = new Account_Member__c(Account__c=ac1.id, Subscribe__c=true,User__c=cowner.id);
                Account_Member__c member1 = new Account_Member__c(Account__c=ac1.id,User__c=cowner.id,Subscribe__c=true);
                memlist.add(member);
                memlist.add(member1);
                insert memlist;
                system.debug('############### memlist'+memlist);
                //system.debug('############### contact id'+newc.id);
                Contact_Member__c contactMember = new Contact_Member__c(Contact__c=newc.id,User__c=cowner.id,Subscribe__c=true);
                contlist.add(contactMember);
                Contact_Member__c contactMember1 = new Contact_Member__c(Contact__c=newc.id,User__c=cowner.id,Subscribe__c=true);
                contlist.add(contactMember1);
                insert contlist;
                //Creating Cases
                
                        
                //Creating Entitlement
                Entitlement Ent1 = new Entitlement(Name='TestENT1',GSS_Entitlement_Code__c='ASP',Accountid=ac1.id,Type='1',GSS_Entitlement_Status__c='Active');
                insert Ent1;
                
                //Creating Product
                Product2 prod1 = new Product2(Name='OtherProd1', GSS_Assignment_Group__c='SDK Product Group',GSS_Vsubcat__c='SubCat1,SC2,SC3', GSS_Product_vCat__c='Cat1;Cat2',templateId__c='00X80000001qoDg',
                                 GSS_Partner_vSubcat__c ='PartnerSubCat1;PSC2;PSC3;Configuration;Database',GSS_Product_Issue_type__c='Sales;john;Apple;Mango;Orange',GSS_Version__c='5.5',GSS_Build__c='1.0');
                insert prod1; 
                
                //tCases=new list<case>();
                 c0.Priority='3 - Medium'; c0.Entitlementid=Ent1.id; c0.productId=prod1.Id; c0.GSS_Additional_Emails__c='a.a@a.com,b.b@b.com'; c0.ownerid=cowner.id; c0.recordtypeId=cRecordType; c0.contactid=newc.id; c0.GSS_Language__c='eng'; c0.GSS_Problem_Category__c='licensing'; c0.Origin='email'; c0.status='open';  c0.Sub_Status__c='inbound message received'; c0.Description='hi how r u!'; c0.subject='testing for GSS_Caseaccount_notified'; c0.accountid = ac1.id;
                 
                 c0.GSS_First_Response_Due_Date__c = DateTime.valueOf(String.valueOf(System.now().year())+'-'+String.valueOf(System.now().month())+'-'+String.valueOf(System.now().addDays(1).day())+' '+String.valueOf(System.now().hour()+h) +':'+ String.valueOf(System.now().minute()+m)+':'+ String.valueOf(System.now().second()));
                 
                 c1.Priority='1 - Critical';c1.Entitlementid=Ent1.id; c1.ownerid=cowner.id; c1.recordtypeId=cRecordType; c1.contactid=newc.id;c1.GSS_Language__c='JPN'; c1.GSS_Problem_Category__c='licensing'; c1.Origin='email'; c1.status='open'; c1.Sub_Status__c='inbound message received'; c1.Description='hi how r u!'; c1.subject='testing for GSS_Caseaccount_notified'; c1.accountid = ac1.id;
                 c1.GSS_First_Response_Due_Date__c = System.now();
                 
                 
                 c3.Priority='4 - Low';c3.Entitlementid=Ent1.id; c3.ownerid=cowner.id; c3.recordtypeId=cRecordType; c3.contactid=newc.id;c3.GSS_Language__c='JPN'; c3.GSS_Problem_Category__c='licensing'; c3.Origin='email'; c3.status='open'; c3.Sub_Status__c='inbound message received'; c3.Description='hi how r u!'; c3.subject='testing for GSS_Caseaccount_notified'; c3.accountid = ac1.id;
                 c3.GSS_Center__c = 'Bangalore';  c3.GSS_Support_Customer_Region__c = 'APJ';
                 c3.GSS_First_Response_Due_Date__c =  DateTime.valueOf(String.valueOf(System.now().year())+'-'+String.valueOf(System.now().month())+'-'+String.valueOf(System.now().addDays(1).day())+' '+String.valueOf(System.now().hour()+h) +':'+ String.valueOf(System.now().minute()+m)+':'+ String.valueOf(System.now().second()));
                 
                 
                 c4.Priority='4 - Low';c4.Entitlementid=Ent1.id; c4.ownerid=cowner.id; c4.recordtypeId=cRecordType; c4.contactid=newc.id;c4.GSS_Language__c='JPN'; c4.GSS_Problem_Category__c='licensing'; c4.Origin='email'; c4.status='Closed'; c4.Sub_Status__c='inbound message received'; c4.Description='hi how r u!'; c4.subject='testing for GSS_Caseaccount_notified'; c4.accountid = ac1.id;
                 c4.GSS_Vcat__c = 'Licensing';
                 c4.GSS_Resolution__c = 'uyeyf';
                 c4.GSS_Symptoms__c = 'hiuidis';
                 c4.Issue_Type__c = 'Account Creation';
                 c4.GSS_Vsubcat__c = 'Accounting';
                 c4.GSS_Resolution_Code__c = 'Data Issues';
                 
                 //c4.GSS_Center__c = 'Bangalore';  c4.GSS_Support_Customer_Region__c = 'APJ';
                  c4.GSS_First_Response_Due_Date__c =  DateTime.valueOf(String.valueOf(System.now().year())+'-'+String.valueOf(System.now().month())+'-'+String.valueOf(System.now().addDays(1).day())+' '+String.valueOf(System.now().hour()+h) +':'+ String.valueOf(System.now().minute()+m)+':'+ String.valueOf(System.now().second()));
                 
                tCases.add(c0);
                tCases.add(c1); 
                tCases.add(c3);
                tCases.add(c4);
                
                insert tCases;
                 /*tCases[0].Sub_Status__c = 'Escalation Requested';
                 tCases[3].Priority = '4 - Low';
                 tCases[3].Status = 'Closed';
                 update tCases;   */       
                caseAcountIdMap = new   map<case,id>();
                List<String> stringlist =  new List<String>();
                stringlist.add('abc@example.com');
                caseAcountIdMap.put(tCases[0],tCases[0].id);
                accountIdEmailListMap.put(tCases[0].id,stringlist);
               
                GSS_UtilityClass.isPremierCaseCheck = true;
                GSS_Caseaccount_notified.soqlLimit = false;
            }
        }
    static testmethod void testUpdate1(){
    setupdata();
    Test.startTest();
    tCases[1].GSS_First_Response_Due_Date__c.addMinutes(15);
    tCases[1].Priority='1 - Critical';
    tCases[1].GSS_Vcat__c = 'Licensing';
    tCases[1].GSS_Resolution__c = 'uyeyf';
    tCases[1].GSS_Symptoms__c = 'hiuidis';
    tCases[1].Issue_Type__c = 'Account Creation';
    tCases[1].GSS_Vsubcat__c = 'Accounting';
    tCases[1].GSS_Resolution_Code__c = 'Data Issues';
    tCases[1].Status = 'Closed';
    update tCases[1];
    Test.stopTest();
    }

    static testmethod void testUpdate2(){
    setupdata();
    Test.startTest();
    tCases[1].GSS_First_Response_Due_Date__c.addMinutes(15);
    tCases[1].Priority='1 - Critical';
    tCases[1].GSS_Vcat__c = 'Licensing';
    tCases[1].GSS_Resolution__c = 'uyeyf';
    tCases[1].GSS_Symptoms__c = 'hiuidis';
    tCases[1].Issue_Type__c = 'Account Creation';
    tCases[1].GSS_Vsubcat__c = 'Accounting';
    tCases[1].GSS_Resolution_Code__c = 'Data Issues';
    tCases[1].Status = 'Closed';
    tCases[1].Sub_Status__c = 'Escalation Requested' ;
    update tCases[1];
    Test.stopTest();
    }

    static testmethod void testSev1(){
    setupdata();
    Test.startTest();
    tCases[1].GSS_First_Response_Due_Date__c.addMinutes(15);
    update tCases[1];
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }



    static testmethod void testUpdate3(){
    setupdata();
    Test.startTest();
    tCases[1].GSS_First_Response_Due_Date__c.addMinutes(55);
    tCases[1].Priority='3 - Medium';
    tCases[1].Status = 'Open';
    update tCases[1];
    Test.stopTest();
    }

    static testmethod void testSev2AndSev3(){
    setupdata();
    Test.startTest();
    tCases[1].GSS_First_Response_Due_Date__c.addMinutes(55);
    update tCases[1];
    GSS_Caseaccount_notified.checkHours(c1, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c1);
    GSS_Caseaccount_notified.casesCommitsInMorning(c1, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }
    static testmethod void testSev21AndSev3(){
    setupdata();
    Test.startTest();
    tCases[3].GSS_First_Response_Due_Date__c.addMinutes(55);
    update tCases[3];
    GSS_Caseaccount_notified.checkHours(c1, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c1);
    GSS_Caseaccount_notified.casesCommitsInMorning(c1, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testSev4(){
    setupdata();
    Test.startTest();
    tCases[1].GSS_First_Response_Due_Date__c.addMinutes(115);
    tCases[1].Priority='4 - Low';
    update tCases[1];
    GSS_Caseaccount_notified.checkHours(c1, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c1);
    GSS_Caseaccount_notified.casesCommitsInMorning(c1, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay8Sev3(){
    setupdata();
    Test.startTest();
    tCases[0].GSS_First_Response_Due_Date__c.addMinutes(1);
    tCases[0].Priority='3 - Medium';
    update tCases[0];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c0, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c0);
    GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay16Sev3(){
    setupdata();
    Test.startTest();
    tCases[0].GSS_First_Response_Due_Date__c.addMinutes(16);
    tCases[0].Priority='3 - Medium';
    update tCases[0];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c0, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c0);
    GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay24Sev3(){
    setupdata();
    Test.startTest();
    tCases[0].GSS_First_Response_Due_Date__c.addMinutes(24);
    tCases[0].Priority='3 - Medium';
    tCases[0].Sub_Status__c = 'Escalation Requested' ;
    update tCases[0];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c0, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c0);
    GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay32Sev3(){
    setupdata();
    Test.startTest();
    tCases[0].GSS_First_Response_Due_Date__c.addMinutes(35);
    tCases[0].Priority='3 - Medium';
    update tCases[0];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c0, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c0);
    GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay40Sev3(){
    setupdata();
    Test.startTest();
    tCases[0].GSS_First_Response_Due_Date__c.addMinutes(45);
    tCases[0].Priority='3 - Medium';
    update tCases[0];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c0, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c0);
    GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay48Sev3(){
    setupdata();
    Test.startTest();
    tCases[0].GSS_First_Response_Due_Date__c.addMinutes(50);
    tCases[0].Priority='3 - Medium';
    update tCases[0];
    GSS_Caseaccount_notified.checkHours(c0, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c0);
    GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }
    static testmethod void testNextDay55Sev3(){
    setupdata();
    Test.startTest();
    tCases[0].GSS_First_Response_Due_Date__c.addMinutes(55);
    tCases[0].Priority='3 - Medium';
    update tCases[0];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c0, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c0);
    GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }
    static testmethod void testNextDay8Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(1);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay16Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(16);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay24Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(24);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    bHour.End_Time__c = String.valueOf(System.now().addHours(1).hour())+'00';  bHour.Start_Time__c = String.valueOf(System.now().hour())+'00';
    update bHour;
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay27Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(27);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }
    static testmethod void testNextDay32Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(32);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay40Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(40);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testNextDay48Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(48);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }
       
    static testmethod void testNextDay55Sev4(){
    setupdata();
    Test.startTest();
    tCases[2].GSS_First_Response_Due_Date__c.addMinutes(55);
    tCases[2].Priority='4 - Low';
    update tCases[2];
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }

    static testmethod void testyNow(){
    setupdata();
    Test.startTest();
    //GSS_Caseaccount_notified.Method1();
    tCases[2].GSS_First_Response_Due_Date__c = System.now();
    tCases[2].Priority='4 - Low';
    update tCases[2];
    Set<id> caseIdSet = new Set<Id>();
    caseIdSet.add(tCases[2].id);
    GSS_Caseaccount_notified.checkHours(c3, bHour);
    GSS_Caseaccount_notified.checkBusinessDay(c3);
    GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
    //system.debug('###############caseList'+tCases);
    List<Account_Member__c> accMemList = [Select Id, User__c,User__r.Email,Subscribe__c,Account__r.Id
                                    from Account_Member__c 
                                    where Account__c = :ac1.id
                                        AND User__r.isActive =true 
                                        AND Subscribe__c=true ];
    system.debug('########### accMemList'+accMemList);
    //GSS_Caseaccount_notified.processCasesToSendEmailAM(tCases);
    GSS_Caseaccount_notified.processCasesToSendEmailAM_future(caseIdSet,true,true); 
    GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
    Database.executeBatch(exBatch);
    Test.stopTest();
    }
    static testmethod void testyNow1(){
        setupdata();
        Test.startTest();
        //GSS_Caseaccount_notified.Method1();
        GSS_Caseaccount_notified.soqlLimit = false;
        tCases[2].GSS_First_Response_Due_Date__c = System.now();
        tCases[3].Status = 'Open';
        //tCases[2].Status = 'Closed';
        tCases[2].Priority='4 - Low';
        tCases[3].Sub_Status__c = 'Escalation Requested';
        update tCases;
        Set<id> caseIdSet = new Set<Id>();
        caseIdSet.add(tCases[2].id);
        delete memlist;
        GSS_Caseaccount_notified.checkHours(c3, bHour);
        GSS_Caseaccount_notified.checkBusinessDay(c3);
        GSS_Caseaccount_notified.checkBusinessDay(c0);
        GSS_Caseaccount_notified.checkBusinessDay(c1);
        GSS_Caseaccount_notified.casesCommitsInMorning(c3, bHour);
        GSS_Caseaccount_notified.casesCommitsInMorning(c0, bHour);
        GSS_Caseaccount_notified.casesCommitsInMorning(c1, bHour);
       // GSS_Caseaccount_notified.processCasesToSendEmailAM(tCases);
        GSS_Caseaccount_notified.processCasesToSendEmailAM_future(caseIdSet,true,false); 
        GSS_Caseaccount_notified.processCasesToSendEmailAM_future(caseIdSet,false,true); 
        GSS_UtilityClass.isPremierCaseCheck = true;
        GSS_Accountmember_Notified_Batch exBatch = new GSS_Accountmember_Notified_Batch();
        Database.executeBatch(exBatch);
        Test.stopTest();
    }
    public static void setupData1(){
                Profile_Name_Mapping__c pCusObj = CustomSettingUtility.getProfileNameMapping('GSS System Administrator');  
                Id pId = Id.ValueOf(pCusObj.Profile_Id__c);
               cowner = new User(alias = 'GSS223', email='user1@testorg.com',languagelocalekey='en_US', 
                    emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = pId, 
                    timezonesidkey='America/Los_Angeles', username='gssutiluser1@testorg2.com',isActive =true,division='EMEA');
                insert cowner;
                ID recTypeAccountId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_ACC_EC').Record_Type_ID__c);
                ac1 = new Account(Name='AccountTest1',recordtypeId= recTypeAccountId , Country__c='INDIA' );
                insert ac1;
                ID recordTypeConId = Id.valueOf(Record_Type_Settings__c.getInstance('GSS_CON_CC').Record_Type_ID__c);
                newc = new Contact(FirstName='spanEmailContact',LastName='Test1',Email='email@spanEmail.com',recordtypeId=recordTypeConId);
                newc.accountid=ac1.id;
                insert newc;
                
                Account_Member__c member = new Account_Member__c(Account__c=ac1.id,User__c=cowner.id,Subscribe__c=true);
                //Account_Member__c member2 = new Account_Member__c(Account__c=ac1.id, Subscribe__c=true,User__c=cowner.id);
                Account_Member__c member1 = new Account_Member__c(Account__c=ac1.id,User__c=cowner.id,Subscribe__c=true);
                memlist.add(member);
                memlist.add(member1);
                insert memlist;
                system.debug('############### memlist'+memlist);
                //system.debug('############### contact id'+newc.id);
                Contact_Member__c contactMember = new Contact_Member__c(Contact__c=newc.id,User__c=cowner.id,Subscribe__c=true);
                contlist.add(contactMember);
                Contact_Member__c contactMember1 = new Contact_Member__c(Contact__c=newc.id,User__c=cowner.id,Subscribe__c=true);
                contlist.add(contactMember1);
                insert contlist;
    }
    static testmethod void testyNow2(){
        Test.startTest();
         setupData1();
        List<Case> caseList = [select id from case where Priority != '1 - Critical' and recordtypeId=:cRecordType limit 1];
        caseList[0].Priority = '1 - Critical';
        caseList[0].accountId = ac1.id;
        caseList[0].contactId = newc.id;
        update caseList;
        Test.stopTest();
    }
    }