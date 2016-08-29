@isTest(SeeALLdata= true)
public class ScheduleLead_Campaign_MappingBatchTest{
    public static String CRON_EXP =  '0 0 23 * * ?'; 

    static testmethod void ScheduleLead_Campaign_MappingBatchTest1(){
        
        
        User objUser = createUser('Phillip','Taylor','vmware@example.com','stand');
       
        Lead ld =  createlead();
        list<Record_Source_Restriction__c> Custlist = Record_Source_Restriction__c.getall().values();
        
        if(Custlist!=null ){
        for(Record_Source_Restriction__c RSR : Custlist){
            RSR .Inactive__c=False;
            }
            update Custlist;
        }
        else{
            Record_Source_Restriction__c sc=new Record_Source_Restriction__c();
            sc.name='ScheduleLead_Campaign_MappingBatch';
            sc.Inactive__c=True;
            insert sc;
        }
        Campaign objCampaign1 = createCampaign('TestCam','Management','MKTG External List');
        Campaign objCampaign2 = createCampaign('TestCam2','Mobile','MKTG Print Ad');
       
            CampaignMember objCampaignMember1 = createCampaignMember(objCampaign1.Id, ld.Id,'Attended',objUser.Id);
        
        
            Test.startTest();           
         
            Lead_Campaign_MappingBatch lcm =new Lead_Campaign_MappingBatch();
            Database.executeBatch(lcm,200);
            Test.stopTest();
            
            
        
        
        //System.assert(true);
    }
    static testmethod void ScheduleLead_Campaign_MappingBatchTest2(){
    User objUser = createUser('Phillip','Taylor','vmware@example.com','stand');
       
        Lead ld =  createlead();
        
        Campaign objCampaign1 = createCampaign('TestCam','Management','MKTG External List');
        Campaign objCampaign2 = createCampaign('TestCam2','Mobile','MKTG Print Ad');
       
            CampaignMember objCampaignMember1 = createCampaignMember(objCampaign1.Id, ld.Id,'Attended',objUser.Id);
        
        
            Test.startTest();
            
            ScheduleLead_Campaign_MappingBatch objSchedule = new ScheduleLead_Campaign_MappingBatch();
            
           System.schedule('ScheduleLead_Campaign_MappingBatch test', CRON_EXP , objSchedule);
           ScheduleLead_Campaign_MappingBatch objSchedule1 = new ScheduleLead_Campaign_MappingBatch();
           System.schedule('ScheduleLead_Campaign_MappingBatch test1', CRON_EXP , objSchedule1 );
           System.schedule('ScheduleLead_Campaign_MappingBatch test2', CRON_EXP , objSchedule1 );                   
    
    }
    static Campaign createCampaign(String Name,String SolutionFocus,String Type){
        Campaign objCampaign = new Campaign(Solution_Focus__c=SolutionFocus,Name=Name,Type=Type);
        insert objCampaign;
        return objCampaign;
    }
    static CampaignMember createCampaignMember(Id Campaign_ID,Id Lead_ID,String Status,String LeadScreeningOwner){
        System.debug('prining---'+Campaign_ID);
         System.debug('prining--Lead_ID-'+Lead_ID);
          System.debug('prining--Status-'+Status);
           System.debug('prining--LeadScreeningOwner-'+LeadScreeningOwner);
        CampaignMember objCampaignMember = new CampaignMember(CampaignId = Campaign_ID,LeadId=Lead_ID,Status=Status,Lead_Screening_Owner__c=LeadScreeningOwner);
        insert objCampaignMember;
        return objCampaignMember;
    }
    static User createUser(String firstName,String lastName, String email,String alias){
        
        Profile profile1 = [SELECT ID FROM PROFILE WHERE NAME = 'LDR Manager' LIMIT 1];
        User objUser = new User(languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', emailencodingkey='UTF-8');
        objUser.FirstName = firstName;
        objUser.LastName = lastName;
        objUser.Alias = alias; 
        objUser.Email = email;
        objUser.profileid = profile1.Id;
        objUser.Username =String.valueOf(System.now().getTime())+'@vmware.com' ;
        objUser.FederationIdentifier = String.valueOf(System.now().getTime());
        objUser.Division='Testing';
        insert objUser;       
        return objUser;
    
    }
    
    Static Lead createlead(){
        Id LeadRecordTypeId = schema.SObjectType.Lead.getRecordTypeInfosByName().get('VMware Lead Record Type').getRecordTypeId();
        /*Record_Type_Settings__c rt1= new Record_Type_Settings__c (name = 'Lead_XSUS',Record_Type_ID__c ='012c000000052FrAAI');
        Insert rt1;
        LeadManagerPublicGroup__c leadmanagerPublic = new LeadManagerPublicGroup__c(name = 'Lead Manager Public Group ID',Update_Owner_Fields__c = true);
        Insert leadmanagerPublic ;
        DNBI_Properties__c DNBI = new DNBI_Properties__c(name = 'Integration_Batch_Size', DNB_Value__c = '50');
        Insert DNBI;
        ETM_Do_Not_Delete_Territory_Values__c ETM = new ETM_Do_Not_Delete_Territory_Values__c(name = 'test',Target_Objects__c ='Lead');
        Insert ETM;
        OnOffSwitch__c onoff = new OnOffSwitch__c(name = 'EloquaIntegration',Active__c = true);
        Insert onoff;
        ByPassTriggerForDataMigration__c migration = new ByPassTriggerForDataMigration__c();
        migration.name = 'CampaignBeforeInsertBeforeUpdate';
        migration.DeactivateComponents__c = false;
        migration.Trigger_Name__c= 'Campaign';
        migration.Object_Name__c = 'CampaignBeforeInsertBeforeUpdate';
        migration.User_Name__c= 'Data Conversion';
        Insert migration ;*/
        
        String userid= [select id,name from User where name ='Eloqua Integration'].id;
        
         //User objUsertest = createUser('test','Integration','etmintegration@vmware.com.vmw','stand');
         User objUsertest = createUser('test','Integration','eloqua@vmware.com.vmw','stand');
         
          Lead leadtest = new Lead();
         System.runas(objUsertest ){
             //Lead leadtest = new Lead();
        leadtest.Company = 'Test';
        leadtest.LastName = 'Lead1';
        leadtest.PFST_Match_Reason__c = 'DUNS reason1';
        leadtest.Status = 'test';
        leadtest.Geo__c = 'EMEA';
        leadtest.uuid__c = '123456';
        leadtest.country__c ='INDIA';
        leadtest.City__c = 'Kolkata';
        leadtest.Postal_Code__c = '743318';
        leadtest.state_province__c = 'West Bengal';
        leadtest.email = 'pabitra.pramanick@accenture.com';
        leadtest.duns__c = 'Test';
        leadtest.Industry = 'Education';
        leadtest.Primary_Product_Group_Interest__c = 'Services';
        leadtest.Status = '0 New Response';
        leadtest.Screening_Results__c='Pre-Qualified';
        leadtest.PFST_Match_Reason__c = 'test reason2';
        leadtest.LDR__c = userid;
        leadtest.recordtypeid = LeadRecordTypeId ;
        try{
            Insert leadtest;
         }Catch(Exception ex){
             System.debug('Printing-- exception--'+ex.getmessage());
         }
        
       
         }
         return leadtest;
    }
    
}