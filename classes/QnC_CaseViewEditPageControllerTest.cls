@isTest(SeeAllData=true)
Public class QnC_CaseViewEditPageControllerTest
{
  public static case QnCCase,QnCCase1;
  Id currentUserId = Userinfo.getUserId();
  public static List<Case> newCaseList = new List<Case>();
  public static CaseComment caseComment = new CaseComment();
  public static Case_Team_Member__c caseTeam = new Case_Team_Member__c();
  public Static Case ChildCase;
  public static Attachment attach = new Attachment();
  public static user CaseOwner;
  public static user CaseOwner2;
  public static user CaseOwner3;
  
  
    static void setUpData() {
        Profile_Name_Mapping__c pCusObj = CustomSettingUtility.getProfileNameMapping('System Administrator');  
        Id pId = Id.ValueOf(pCusObj.Profile_Id__c);
        CaseOwner = new User (alias = 'GSS223', email='user1@testorg.com',languagelocalekey='en_US', 
                    emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = pId, 
                    timezonesidkey='America/Los_Angeles', username='gssutiluser1@testorg2.com');
        insert CaseOwner;
        
        ID recTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Case_QnC').Record_Type_ID__c);  
        QnCCase= new case (RecordTypeId=recTypeId, Case_Subject__c='Test Case',Case_Description__c='Test Case',
                 Reason='Test',QnC_Issue_Category__c='APJ- Quotas and Commissions', QnC_Issue_Type__c='Others', 
                 Status='New',Priority = '3-Medium', ownerid=CaseOwner.id,Reported_By__c=CaseOwner.id);
                    
        insert QnCCase; 
        
        caseComment= new CaseComment (CommentBody='Test',IsPublished=true, ParentId = QnCCase.id);
        insert caseComment;  
                  
        attach = new Attachment(Body=Blob.valueOf('Test'),Name='Test',ParentId = QnCCase.id);   
        insert attach;
        
        
     }  
     
     static void setUpData2() {
        Profile_Name_Mapping__c pCusObj = CustomSettingUtility.getProfileNameMapping('System Administrator');  
        Id pId = Id.ValueOf(pCusObj.Profile_Id__c);
        CaseOwner = new User (alias = 'GSS223', email='user1@testorg.com',languagelocalekey='en_US', 
                    emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = pId, 
                    timezonesidkey='America/Los_Angeles', username='gssutiluser1@testorg2.com');
        insert CaseOwner;
        
        system.runas(CaseOwner){
            Profile_Name_Mapping__c p2CusObj = CustomSettingUtility.getProfileNameMapping('Hybrid Rep');  
            Id p2Id = Id.ValueOf(p2CusObj.Profile_Id__c);
            CaseOwner2 = new User (alias = 'GSS223', email='user1@testorg.com',languagelocalekey='en_US', 
                        emailencodingkey='UTF-8', lastname='Testing',localesidkey='en_US', profileid = p2Id, 
                        timezonesidkey='America/Los_Angeles', username='gssutiluser2@testorg2.com');
            insert CaseOwner2;
            
             CaseOwner3 = new User (alias = 'GSS22321', email='user12@testorg.com',languagelocalekey='en_US', 
                        emailencodingkey='UTF-8', lastname='Testing1',localesidkey='en_US', profileid = p2Id, 
                        timezonesidkey='America/Los_Angeles', username='gssutiluser22@testorg2.com');
            insert CaseOwner3;
            
            
        
            ID recTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Case_QnC').Record_Type_ID__c);  
        QnCCase= new case (RecordTypeId=recTypeId, Case_Subject__c='Test Case',Case_Description__c='Test Case',
                 Reason='Test',QnC_Issue_Category__c='APJ- Quotas and Commissions', QnC_Issue_Type__c='Others', 
                 Status='New',Priority = '3-Medium',ownerid=CaseOwner.id,Reported_By__c=CaseOwner.id);
                    
        insert QnCCase; 
        QnCCase1= new case (RecordTypeId=recTypeId, Case_Subject__c='Test Case',Case_Description__c='Test Case',
                 Reason='Test',QnC_Issue_Category__c='APJ- Quotas and Commissions', QnC_Issue_Type__c='Others', 
                 Status='New',Priority = '3-Medium',ownerid=CaseOwner2.id,Reported_By__c=CaseOwner2.id,ParentId=QnCCase.id);
                    
        insert QnCCase1;
        
        caseTeam = new Case_Team_Member__c (Case_Access_Level__c='Read/Write',Case__c = QnCCase1.id,Team_Member__c= CaseOwner2.id,
                   Team_Member_Role__c='Sales Operation - Read/Write',CurrencyIsoCode='EUR');
            insert caseTeam;
        
        caseComment= new CaseComment (CommentBody='Test',IsPublished=true, ParentId = QnCCase1.id);
        insert caseComment;  
                  
        attach = new Attachment(Body=Blob.valueOf('Test'),Name='Test',ParentId = QnCCase1.id);   
        insert attach;
        }
     }     
          
     public static testmethod void testSearchForCase1() {
         GSS_UtilityClass.isBeforeInsert_Case=true;
         GSS_UtilityClass.isBeforeUpdate_Case=true;
         GSS_UtilityClass.isAfterInsert_Case=true;
         GSS_UtilityClass.isAfterUpdate_Case=true;
        setUpData();
        
        PageReference pageRef = Page.QnC_CaseViewEditPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',QnCCase.id);  
        
        Test.startTest();
       
        QnC_CaseViewEditPageController caseviewpage = new QnC_CaseViewEditPageController(); 
        ID recTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Case_QnC').Record_Type_ID__c); 
        
        ChildCase= new Case(RecordTypeId= recTypeId, Subject='Child', Description='Child Case for Test1',
                    Reason='Test',QnC_Issue_Category__c='Test', QnC_Issue_Type__c='Test', ParentId=QnCCase.id, 
                    Priority = '3-Medium',Status = 'New',ownerid=CaseOwner.id,Reported_By__c=CaseOwner.id );
        insert ChildCase;
        Test.stopTest(); 
        newCaseList.add(ChildCase);
        caseviewpage.getRelatedCases();  
        caseviewpage.getRelatedCaseComments();
        caseviewpage.getRelatedAttachments();
        caseviewpage.saveCase();
        caseviewpage.escalateCase();
        caseviewpage.getCaseAccessLevel();
        
    
    }
    public static testmethod void testSearchForCase2() {
        GSS_UtilityClass.isBeforeInsert_Case=true;
         GSS_UtilityClass.isBeforeUpdate_Case=true;
         GSS_UtilityClass.isAfterInsert_Case=true;
         GSS_UtilityClass.isAfterUpdate_Case=true;
        setUpData2();
        PageReference pageRef = Page.QnC_CaseViewEditPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',QnCCase1.id);  
        
        system.runas(CaseOwner3){
        Test.startTest();
        QnC_CaseViewEditPageController caseviewpage = new QnC_CaseViewEditPageController(); 
        ID recTypeId = Id.valueOf(Record_Type_Settings__c.getInstance('SFA_Case_QnC').Record_Type_ID__c); 
        
        ChildCase= new Case(RecordTypeId= recTypeId, Subject='Child', Description='Child Case for Test1',
                    Reason='Test',QnC_Issue_Category__c='Test', QnC_Issue_Type__c='Test', ParentId=QnCCase.id, 
                    Priority = '3-Medium',Status = 'New',Reported_By__c=CaseOwner.id );
        insert ChildCase;
        Test.stopTest();
        newCaseList.add(ChildCase);
        //caseviewpage.getRelatedCases();  
        //caseviewpage.getRelatedCaseComments();
        //caseviewpage.getRelatedAttachments();
        caseviewpage.saveCase();
        caseviewpage.escalateCase();
        caseviewpage.getCaseAccessLevel();
         
    }
    }
}