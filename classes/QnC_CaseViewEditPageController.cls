/****-------------------------------------------------
// Name         : QnC_CaseViewEditPageController
// Author       : Accenture [Dilip]
// Created Date : May-04, 2013
// Description  : Controller for visualforce page "QnC_CaseViewEditPage" to provide the case_requester sharing on the case with below functions:
//                  1. Case View/Edit Access
//                  2. Permission to view/create Case Comments
//                  3. Permission to view related cases 
// Modified By  : Avaneesh Singh
// Modified Date: 12 july 2013
// Purpose      : Parent Case need to be accessible by the user as he is getting insufficient privilege  
// ************************Version Updates********************************************
// Date         Developer               Description
// -----------------------------------------------------------------------------------
// 16 Aug 2016  Veera           CR-00140228: Case Escalation Logic
// ************************************************************************************

-------------------------------------------------***/
public without sharing class QnC_CaseViewEditPageController {
    public Case caseRec {get;set;}
    public Case caseParentRec {get;set;}
    
    public String caseParentAccess {get;set;}
    public Boolean isCurrUserOwner {get;set;}
    public static Id QuotaAndCommissionsCaseRT = recursive.QuotaAndCommissionCaseRT;
    
    Id currentUserId = Userinfo.getUserId();
    User currUser;
    Id CaserecId;
    Id caseParentRecId;    // Modified By  : Avaneesh Singh 12 july 2013
    // Default constructor
    Public boolean CaseEscalated {get;set;} // Added for CR-00140228 - to render Escalate button
    Public boolean displayPopUp {get;set;}  // Added for CR-00140228 - to render popup window
    public QnC_CaseViewEditPageController() {
        currUser = [select Id, Profile.Name from User where Id=:currentUserId ]; 
        String caseId = ApexPages.currentPage().getParameters().get('id');
        
        if(caseId != null && caseId != '') {
            caseRec = getCaseDetails(caseId);
            CaserecId=caseRec.Id;
            CaseEscalated =caseRec.isEscalated;
            
         // Modified By  : Avaneesh Singh 12 july 2013
            caseParentRecId=caseRec.ParentId;
            if(caseParentRecId !=null ){
             caseParentRec=getCaseParentDetails(caseParentRecId);
            }// end of Modification
            
            isCurrUserOwner = false;
           
            Set<Id> queueMemebers = QnC_CaseSharingCalculations.getGroupMembersIds(new Set<Id>{caseRec.OwnerId});
            
            if(currentUserId == caseRec.OwnerId || queueMemebers.contains(currentUserId)) {
                isCurrUserOwner = true;
            }
        }
        
    }
    
    /* Method to get the list of all the related child cases */
    public Case[] getRelatedCases() {
        String SOQL_QUERY = 'Select Id, CaseNumber, isEscalated, Case_Subject__c, Case_Description__c, Priority, CreatedDate, LastModifiedDate, Status, OwnerId';
        SOQL_QUERY += ' from Case ';
        SOQL_QUERY += ' where ParentId=\''+caseRec.Id+'\'';
        /*
        if(currUser.Profile.Name != 'System Administrator') {
            SOQL_QUERY += ' and (Reported_By__c=\''+ Userinfo.getUserId() +'\' OR OwnerId=\''+ Userinfo.getUserId() +'\')';
        }
        */
        return (Case[]) Database.query(SOQL_QUERY);
    }
    
    /* method to get case comments */
    public CaseComment[] getRelatedCaseComments() {
        return [select Id, ParentId, CommentBody, IsPublished, CreatedById, CreatedBy.Name, CreatedDate from CaseComment where ParentId= :caseRec.Id order by CreatedDate desc];
    }
    
    /* method to get case team members */
    public Case_Team_Member__c[] getCaseTeamMembers() {
        return [select Id, Name, Case_Access_Level__c, Team_Member__c, Team_Member_Role__c from Case_Team_Member__c where Case__c = :caseRec.Id];
    }
    
    /* method to get case attachments */
    public Attachment[] getRelatedAttachments() {
        return [select Id, Name, Body, BodyLength, CreatedById, CreatedDate, LastModifiedDate from Attachment where ParentId = :caseRec.Id order by CreatedDate desc];
    }
    
    /* Method to save the changes for fields edited by the user */
    public Pagereference saveCase() {
        try {
            // update the case and return to the view page
           if( caseRec.Status.startsWith('Closed') && (caseRec.QnC_Issue_Category__c==null || caseRec.Root_Cause_Category__c==null  || caseRec.Case_Resolution__c==null || caseRec.QnC_Issue_Type__c==null)){
               Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, System.Label.QnCValidationErrMsg));
                return null;
           }else{
                update caseRec;
                PageReference ReturnPage = new PageReference('/apex/QnC_CaseViewEditPage?id='+CaserecId+'&isView=1');
                 ReturnPage.setRedirect(true);
                return ReturnPage;    
            }
        }
        // In case of exception add an error message to the page the redirect user to the same page where he is currently
        catch(exception ex) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    /* Method to get the detail of the case in context */
    public Case getCaseDetails(String caseRecId) {
        String[] caseFields = new String[]{};
        
 // "assigned_to_hr__c","assigned_to_payroll__c","assigned_to_it__c","assigned_to_ops_lead__c","assigned_to_bookings__c" fields are deleted as a part of CR-00107691        
        
        Case[] cases = [SELECT Id, OwnerId, RecordTypeId, CaseNumber, Reported_By__c, Status, Support_Group__c, Sub_Status__c, CreatedDate, Priority, ClosedDate,
            Reason, QnC_Issue_Category__c, Related_Cases_Closed__c, QnC_Issue_Type__c, Related_Cases_Open__c, QnC_Issue_Sub_Type__c, Origin,
            ParentId, GSS_Support_Customer_Region__c, Parent_Case_Status__c, Sub_Region__c, Duplicate_Of_Case__c, Originating_Dept__c, 
            Assigned_to_Commissions_on__c,  Assigned_to_Bookings_on__c,  Assigned_to_HR_on__c, Assigned_to_Commissions__c,
            Assigned_to_IT_on__c,  Assigned_to_Ops_Lead_on__c,  Assigned_to_Payroll_on__c, Impacted_Sales_Employee__c,
            Response_from_Bookings_on__c, Response_from_Commissions_on__c, Response_from_IT_on__c, Response_from_Ops_Lead_on__c, Response_from_Payroll_on__c, Response_from_HR_on__c,
            IsEscalated, Escalated_By__c, Escalation_Reason__c, Escalated_On__c, Assigned_Function__c, Assigned_Function_Case_Escalation__c, Assigned_Function_Case_Resolution__c,
            Case_Subject__c, Case_Description__c, Root_Cause__c, Case_Resolution__c, Root_Cause_Category__c, Resolution_Reasons__c, Root_Cause_Reason__c,
            Re_Opened_Date__c, Count_Email__c, Re_Opened_Count__c, Case_Age_Days__c, First_Response_Date__c, Case_Age_Bucket__c, First_Response_Time_Hours__c, 
            SuppliedName, SuppliedCompany, SuppliedEmail, SuppliedPhone, Change_Request__c, Change_Submitted_Date__c, Change_Approval_Status__c, Change_Submitted_By__c,
            Change_Approved_On__c, Change_Project__c, Change_Status__c, Change_Release__c, Change_Sub_Status__c, Change_Release_Date__c, Change_Owner_Group__c,
            Change_Deployment_Date__c, CreatedById, LastModifiedById,Case_Age_QnC_Days__c
            FROM Case WHERE Id=:caseRecId ] ;
        
        return cases.size()>0 ? cases[0]:null;
    }
    
     /* Method to get the detail of the case in context // Modified By  : Avaneesh Singh 12 july 2013*/
    public Case getCaseParentDetails(String caseParentRecId) {
 
  // "assigned_to_hr__c","assigned_to_payroll__c","assigned_to_it__c","assigned_to_ops_lead__c","assigned_to_bookings__c" fields are deleted as a part of CR-00107691       
        
        Case caseObj = [SELECT Id, OwnerId, RecordTypeId, CaseNumber, Reported_By__c, Status, Support_Group__c, Sub_Status__c, CreatedDate, Priority, ClosedDate,
            Reason, QnC_Issue_Category__c, Related_Cases_Closed__c, QnC_Issue_Type__c, Related_Cases_Open__c, QnC_Issue_Sub_Type__c, Origin,
            ParentId, GSS_Support_Customer_Region__c, Parent_Case_Status__c, Sub_Region__c, Duplicate_Of_Case__c, Originating_Dept__c, 
            Assigned_to_Commissions_on__c,  Assigned_to_Bookings_on__c,  Assigned_to_HR_on__c, Assigned_to_Commissions__c,
            Assigned_to_IT_on__c,  Assigned_to_Ops_Lead_on__c,  Assigned_to_Payroll_on__c, Impacted_Sales_Employee__c,
            Response_from_Bookings_on__c, Response_from_Commissions_on__c, Response_from_IT_on__c, Response_from_Ops_Lead_on__c, Response_from_Payroll_on__c, Response_from_HR_on__c,
            IsEscalated, Escalated_By__c, Escalation_Reason__c, Escalated_On__c, Assigned_Function__c, Assigned_Function_Case_Escalation__c, Assigned_Function_Case_Resolution__c,
            Case_Subject__c, Case_Description__c, Root_Cause__c, Case_Resolution__c, Root_Cause_Category__c, Resolution_Reasons__c, Root_Cause_Reason__c,
            Re_Opened_Date__c, Count_Email__c, Re_Opened_Count__c, Case_Age_Days__c, First_Response_Date__c, Case_Age_Bucket__c, First_Response_Time_Hours__c, 
            SuppliedName, SuppliedCompany, SuppliedEmail, SuppliedPhone, Change_Request__c, Change_Submitted_Date__c, Change_Approval_Status__c, Change_Submitted_By__c,
            Change_Approved_On__c, Change_Project__c, Change_Status__c, Change_Release__c, Change_Sub_Status__c, Change_Release_Date__c, Change_Owner_Group__c,
            Change_Deployment_Date__c, CreatedById, LastModifiedById,Case_Age_QnC_Days__c
            FROM Case WHERE Id=:caseParentRecId ] ;
         if(caseObj !=null ){
          caseParentAccess =CaseAprentAccessLevel(caseObj.id ) ;

         }
         
        return caseObj !=null ? caseObj :null;
    }
    
    /* Method to set the case access level of the logged in user */
    public String getCaseAccessLevel() {
        // set the default access as None
        String caseAccessLevelStr = 'None';
        
        // check if the user is Sys-Admin or Case-Requester or Case-Owner
        // If yes assign Edit access on the case
        if(currUser.Profile.Name == 'System Administrator' || currentUserId == caseRec.OwnerId || currentUserId == caseRec.Reported_By__c) {
            caseAccessLevelStr = 'Edit';
        }
        // else check if the user is a case team member
        else {
            for(Case_Team_Member__c ctm : [select Id, Team_Member__c, Case_Access_Level__c, Team_Member_Role__c from Case_Team_Member__c where Case__c=:caseRec.Id ]) {
                if(currentUserId == ctm.Team_Member__c) {
                    if(ctm.Case_Access_Level__c == 'Read/Write') {
                        caseAccessLevelStr = 'Edit';
                        break;
                    }
                    else if(ctm.Case_Access_Level__c == 'Read Only') {
                        caseAccessLevelStr = 'Read';
                    }
                }
            }
        }
        
        
        
        // return the appropriate case access level
        return caseAccessLevelStr;
    } 
    
     
    /* Method to set the case access level of the logged in user */
    public String CaseAprentAccessLevel(Id CaseparentId) {
        // set the default access as None
        String caseAccessLevelStr = 'None';
        
        // check if the user is Sys-Admin or Case-Requester or Case-Owner
        // If yes assign Edit access on the case
        if(currUser.Profile.Name == 'System Administrator' || currentUserId == caseRec.OwnerId || currentUserId == caseRec.Reported_By__c) {
            caseAccessLevelStr = 'Edit';
        }
        // else check if the user is a case team member
        else {
            for(Case_Team_Member__c ctm : [select Id, Team_Member__c, Case_Access_Level__c, Team_Member_Role__c from Case_Team_Member__c where Case__c=:CaseparentId]) {
                if(currentUserId == ctm.Team_Member__c) {
                    if(ctm.Case_Access_Level__c == 'Read/Write') {
                        caseAccessLevelStr = 'Edit';
                        break;
                    }
                    else if(ctm.Case_Access_Level__c == 'Read Only') {
                        caseAccessLevelStr = 'Read';
                    }
                }
            }
        }
        
        
        
        // return the appropriate case access level
        return caseAccessLevelStr ;
    } 
    
    // Added by: Veera  - CR-00140228 - Meathod to Implement Case Escalation Logic --Start
    //Below methods are invoked when user clicks "Escalate" - Case will be escalated only if it is not having any child cases.
     public Pagereference escalateCase() {
        try { 
                Integer childcasecnt = getRelatedCases().size();
                If(childcasecnt>0)
                {
                    displayPopUp=true;
                }else 
                {
                    caserec.Isescalated=true;
                    update caseRec;
                    PageReference ReturnPage = new PageReference('/apex/QnC_CaseViewEditPage?id='+CaserecId+'&isView=1');
                    ReturnPage.setRedirect(true);
                    return ReturnPage;  
                }
            }
        // In case of exception add an error message to the page the redirect user to the same page where he is currently
        catch(exception ex) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    // Added by: Veera  - CR-00140228 - Meathod to Implement Case Escalation Logic --End
    
}