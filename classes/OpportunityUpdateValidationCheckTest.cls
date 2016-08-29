//*****************************************************************************************************
// Name             : OpportunityUpdateValidationCheckTest.cls
// Description      : To cover code of OpportunityUpdateValidationCheck class for CR-00132447
//  Created By      : Swati Anshu
// Modified By       : Archana Mujumdar - Accenture
// Created Date     : 29/06/2015
// Modified By       : Hem Gayal - Accenture
// Created Date     : 20/07/2015
// ************************Version Updates*******************************************************************
// 
// *********************************************************************************************************

@isTest(seeAllData = true)
private class OpportunityUpdateValidationCheckTest
{
    static testMethod void OpportunityUpdateValidationCheck_TestMethod1()
    {
        Test.startTest();       
        Profile_Name_Mapping__c p = Profile_Name_Mapping__c.getValues('Profile - 120');

        User u = new User(alias = 'standt', email='standarduser@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Profile_Id__c,timezonesidkey='America/Los_Angeles', username='etminQZXCtegn54fdxwesldnbvfKPGG@vmware.com.vmw',Division='APAC');
        insert u;
        system.runAs(u)
        {
            Account act1 = new Account(RecordTypeId = String.ValueOf(recursive.CustomerAccountRecType),Name = 'New Test Account 001',
            Address_1_del__c = 'test',Address_2__c = 'test',City__c = 'SC',Country__c = 'United States',Region__c='North America',State__c = 'CA',Zip_Postal_Code__c = '95051',Account_Status__c = 'Active');

            insert act1;

            Contact cont=new Contact(AccountId=act1.Id,Email='asd@asd.com',Department__c='Human Resources',Job_Function__c='CIO',LastName='truework', Primary_Contact__c=true);

            insert cont;
            /*
            User u = new User(alias = 'standt', email='standarduser@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Profile_Id__c,timezonesidkey='America/Los_Angeles', username='etminQZXCtegn54fdxwesldnbvfKPGG@vmware.com.vmw');
            insert u;
            */
            recursive.checkOpportunityUpdateValidation = false;
            recursive.isUpdateOpportunity = false;
            Opportunity opp = new Opportunity();
            opp=new Opportunity(stageName = '02 - Qualified',Forecast_Status__c = 'Upside',accountid = act1.id,
            Additional_Opportunity_Information__c = 'Test',amount = 1500,Application_Virtualized__c = 'Not Applicable',Primary_Solution__c = 'PaaS',Salesprism_Identifier__c= 'SalesPrism',RecordTypeId=recursive.ManagedSalesOpportunityRecType,Opportunity_Products__c='VCLOUD HYBRID SERVICES',Buying_Program__c = null ,CloseDate = date.today(),Competitor__c = 'None',Description = 'Test',
            ForecastCategoryName = 'Omitted',Name = 'Test Opp 007-1',ownerid=u.id);          
            insert opp;

            Pricebook2 stdpb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];

            // Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true,IsStandard = true);
            // insert pbk1;

            Product2 prd1 = new Product2(Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
            insert prd1;
            PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
            insert pbe1;

            OpportunityLineItem lineItem1 = new OpportunityLineItem();
            lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=200);

            insert lineItem1;
            //system.runAs(u){
            opp.stageName='02 - Qualified';
            opp.Buying_Program__c = 'Standard';
            recursive.ispopulateISREmail = true;
            recursive.isCheckForProductPlatformGroup =true;
            recursive.checkOpportunityUpdateValidation = false;
            recursive.isUpdateOpportunity = false;
            system.debug('testclassstartrecursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('testclassstartrecursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);
            update opp;
            update lineItem1;
        }
        Test.stopTest();
    }

    static testMethod void OpportunityUpdateValidationCheck_TestMethod2()
    {
        Test.startTest();

        Profile_Name_Mapping__c p = Profile_Name_Mapping__c.getValues('Profile - 120');
        User u = new User(alias = 'standt', email='standarduser@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Profile_Id__c,timezonesidkey='America/Los_Angeles', username='etmintegddfbkyoutrration@vmware.com.vmw', Division='APAC');
        insert u;       
        try
        {
            system.runAs(u)
            {
                Account act1 = new Account(RecordTypeId = String.ValueOf(recursive.CustomerAccountRecType),Name = 'New Test Account 001',
                Address_1_del__c = 'test',Address_2__c = 'test',City__c = 'SC',Country__c = 'United States',Region__c='North America',State__c = 'CA',Zip_Postal_Code__c = '95051',Account_Status__c = 'Active');
                insert act1;
                
                Contact cont=new Contact(AccountId=act1.Id,Email='asd@asd.com',Department__c='Human Resources',Job_Function__c='CIO',LastName='truework', Primary_Contact__c=true);
                insert cont;
                recursive.checkOpportunityUpdateValidation = false;
                recursive.isUpdateOpportunity = false;
                
                Opportunity opp = new Opportunity();
                opp=new Opportunity(stageName = '02 - Qualified',Forecast_Status__c = 'Upside',accountid = act1.id,
                Additional_Opportunity_Information__c = 'Test test',amount = 1500,Application_Virtualized__c = 'Not Applicable',Primary_Solution__c = 'PaaS',Salesprism_Identifier__c= 'SalesPrism',Opportunity_Products__c='VCLOUD HYBRID SERVICES',RecordTypeId=recursive.VCloudOpportunityRecType,Buying_Program__c = 'Standard',CloseDate = date.today(),Competitor__c = 'None',Description = 'Test',
                ForecastCategoryName = 'Omitted',Name = 'Test Opp 007-2',ownerid=u.id, Opportunity_Source__c='Airwatch');
                insert opp;

                Pricebook2 stdpb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
                // Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true,IsStandard = true);
                // insert pbk1;
                Product2 prd1 = new Product2(Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
                insert prd1;

                PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
                insert pbe1;

                OpportunityLineItem lineItem1 = new OpportunityLineItem();
                lineItem1 =new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=200);
                insert lineItem1;
                
                opp.stageName='06 - Closed Won';
                recursive.ispopulateISREmail = true;
                recursive.isCheckForProductPlatformGroup =true;
                recursive.checkOpportunityUpdateValidation = false;
                recursive.isUpdateOpportunity = false;
                system.debug('testclassstartrecursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('testclassstartrecursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);
                update opp;
                OnOffSwitch__c onOff=OnOffSwitch__c.getall().get('FlatRebateFutureMethodSwitch');
                if(!onOff.Active__c)
                {
                    onOff.Active__c =true;
                    update onOff;
                }
                
                /*System.debug(OnOffSwitch__c.getall().get('FlatRebateFutureMethodSwitch'));
                System.debug(recursive.callFromOpportunityLineItemInsert);
                System.debug(recursive.callFromOpportunityLineItemUpdate);
                System.debug(recursive.callFromFlatRebateAdmin);
                System.debug(recursive.callFromOpportunityAfterUpdate);
                System.debug(recursive.RebateApplied);
                System.debug(recursive.callFromOpportunityLineItemDelete);
                System.debug(recursive.callFromOpportunityLineItemUpdate_future);*/
                
                recursive.callFromOpportunityLineItemInsert = false;
                update lineItem1;
                delete lineItem1;
            }
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You must add a product to this opportunity!') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }   
    static testMethod void OpportunityUpdateValidationCheck_TestMethod3()
    {
        Test.startTest();

        Profile_Name_Mapping__c p = Profile_Name_Mapping__c.getValues('Profile - 120');
        User u = new User(alias = 'standt', email='standarduser@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Profile_Id__c,timezonesidkey='America/Los_Angeles', username='etmintegddfbkyoutrration@vmware.com.vmw', Division='APAC');
        insert u;       
        try
        {
            system.runAs(u)
            {
                Account act1 = new Account(RecordTypeId = String.ValueOf(recursive.CustomerAccountRecType),Name = 'New Test Account 001',
                Address_1_del__c = 'test',Address_2__c = 'test',City__c = 'SC',Country__c = 'United States',Region__c='North America',State__c = 'CA',Zip_Postal_Code__c = '95051',Account_Status__c = 'Active');
                insert act1;
                
                Contact cont=new Contact(AccountId=act1.Id,Email='asd@asd.com',Department__c='Human Resources',Job_Function__c='CIO',LastName='truework', Primary_Contact__c=true);
                insert cont;
                recursive.checkOpportunityUpdateValidation = false;
                recursive.isUpdateOpportunity = false;
                
                Opportunity opp = new Opportunity();
                opp=new Opportunity(stageName = '02 - Qualified',Forecast_Status__c = 'Upside',accountid = act1.id,
                Additional_Opportunity_Information__c = 'Test test',amount = 1500,Application_Virtualized__c = 'Not Applicable',Primary_Solution__c = 'PaaS',Salesprism_Identifier__c= 'SalesPrism',Opportunity_Products__c='VCLOUD HYBRID SERVICES',RecordTypeId=recursive.VCloudOpportunityRecType,Buying_Program__c = 'Standard',CloseDate = date.today(),Competitor__c = 'None',Description = 'Test',
                ForecastCategoryName = 'Omitted',Name = 'Test Opp 007-2',ownerid=u.id, Opportunity_Source__c='Vmware');
                insert opp;

                Pricebook2 stdpb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
                // Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true,IsStandard = true);
                // insert pbk1;
                Product2 prd1 = new Product2(Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
                insert prd1;

                PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
                insert pbe1;

                OpportunityLineItem lineItem1 = new OpportunityLineItem();
                lineItem1 =new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=200);
                //insert lineItem1;
                
                opp.stageName='06 - Closed Won';
                recursive.ispopulateISREmail = true;
                recursive.isCheckForProductPlatformGroup =true;
                recursive.checkOpportunityUpdateValidation = false;
                recursive.isUpdateOpportunity = false;
                system.debug('testclassstartrecursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
system.debug('testclassstartrecursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);
                update opp;
                OnOffSwitch__c onOff=OnOffSwitch__c.getall().get('FlatRebateFutureMethodSwitch');
                if(!onOff.Active__c)
                {
                    onOff.Active__c =true;
                    update onOff;
                }
                
                /*System.debug(OnOffSwitch__c.getall().get('FlatRebateFutureMethodSwitch'));
                System.debug(recursive.callFromOpportunityLineItemInsert);
                System.debug(recursive.callFromOpportunityLineItemUpdate);
                System.debug(recursive.callFromFlatRebateAdmin);
                System.debug(recursive.callFromOpportunityAfterUpdate);
                System.debug(recursive.RebateApplied);
                System.debug(recursive.callFromOpportunityLineItemDelete);
                System.debug(recursive.callFromOpportunityLineItemUpdate_future);*/
                
                recursive.callFromOpportunityLineItemInsert = false;
                update lineItem1;
                delete lineItem1;
            }
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You must add a product to this opportunity!') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }   
}