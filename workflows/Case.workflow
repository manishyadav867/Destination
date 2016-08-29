<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>QnC_Update_Case_Type</fullName>
        <field>QnC_Case_Type__c</field>
        <formula>IF(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_APJ_Commissions_Id__c,15),&quot;APJ&quot;, 
(IF(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_AMER_Commissions_Id__c,15),&quot;AMER&quot;, 
(IF(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_EMEA_Commissions_Id__c,15),&quot;EMEA&quot;,
(IF(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Amer_Sales_Ops__c,15),&quot;Amer-Comp&quot;,
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Corporate_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;APJ&quot;),&quot;Corporate-APJ&quot;,
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Corporate_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;AMER&quot;),&quot;Corporate-AMER&quot;, 
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Corporate_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;EMEA&quot;),&quot;Corporate-EMEA&quot;,
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Corporate_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;GlobalOps&quot;),&quot;Corporate-Salesops&quot;, 
(IF(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Corporate_Commissions_Id__c,15),&quot;Corporate&quot;,
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Geo_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;APJ&quot;),&quot;Geo-Corporate-APJ&quot;,
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Geo_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;AMER&quot;),&quot;Geo-Corporate-AMER&quot;,
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Geo_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;EMEA&quot;),&quot;Geo-Corporate-EMEA&quot;, 
(IF(AND(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Geo_Commissions_Id__c,15),Parent.QnC_Case_Type__c=&quot;GlobalOps&quot;),&quot;Geo-Corporate-Salesops&quot;, 
(IF(OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Geo_Sales_Commission__c,15),&quot;GlobalOps&quot;,&quot;Geo-Corporate&quot;)))))))))))))))))))))))))))</formula>
        <name>QnC - Update Case Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>QnC - AMER case Escalation Notification</fullName>
        <actions>
            <name>QnC_AMER_case_Escalation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  $User.IsDataMigrationUser__c =false, 
RecordTypeId = LEFT($Setup.QnC_Case_Properties__c.QnC_Case_Record_Type_Id__c,15),  
ISCHANGED(IsEscalated), IsEscalated, 
OR(QnC_Case_Type__c =&quot;Corporate-AMER&quot;,
AND(ISPickval(GSS_Support_Customer_Region__c,&apos;AMER&apos;), 
QnC_Case_Type__c =&quot;Corporate-Salesops&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QnC - Case Assignment Notification to new Owner%2FQueue Corporate</fullName>
        <actions>
            <name>QnC_Case_Assignment_Notification_to_New_Owner_Queue_corporate</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>($User.IsDataMigrationUser__c =false) &amp;&amp; 
(AND( RecordTypeId ==   LEFT( $Setup.QnC_Case_Properties__c.QnC_Case_Record_Type_Id__c, 15), 
OR(QnC_Case_Type__c =&quot;Corporate&quot;,
QnC_Case_Type__c =&quot;Corporate-Salesops&quot;,
QnC_Case_Type__c =&quot;Corporate-APJ&quot;,
QnC_Case_Type__c =&quot;Corporate-AMER&quot;,
QnC_Case_Type__c =&quot;Corporate-EMEA&quot;) ,
OR( AND( ISNEW() ,  NOT(ISBLANK(OwnerId) )),  ISCHANGED(OwnerId)  ),  BEGINS(OwnerId, &quot;005&quot;) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QnC - Case Closure Notification to Requestor Corp</fullName>
        <actions>
            <name>QnC_Case_Closure_Notification_email_Requestor_Corp</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>($User.IsDataMigrationUser__c =false) 
&amp;&amp; (AND(RecordTypeId == LEFT($Setup.QnC_Case_Properties__c.QnC_Case_Record_Type_Id__c, 15),
ISCHANGED( IsClosed ) ,
IsClosed ,
OR(QnC_Case_Type__c =&quot;Corporate&quot;,
QnC_Case_Type__c =&quot;Corporate-Salesops&quot;,
QnC_Case_Type__c =&quot;Corporate-APJ&quot;,
QnC_Case_Type__c =&quot;Corporate-AMER&quot;,
QnC_Case_Type__c =&quot;Corporate-EMEA&quot;
)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QnC - Case Escalation Notification Corp</fullName>
        <actions>
            <name>GSS_Service_Reason_Renewals_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>QnC_Case_Escalation_Notification_to_Requester_Corp</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( $User.IsDataMigrationUser__c =false,
RecordTypeId = LEFT($Setup.QnC_Case_Properties__c.QnC_Case_Record_Type_Id__c,15),
ISCHANGED(IsEscalated),
IsEscalated,  
QnC_Case_Type__c =&quot;Corporate&quot;, 
BEGINS(OwnerId,&quot;005&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QnC - Case Re-open Notification to Owner Corp</fullName>
        <actions>
            <name>QnC_Case_Status_Re_open_Notification_Owner_Corp</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>QnC_Case_Status_Re_open_Notification_Requester_Corp</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>($User.IsDataMigrationUser__c =false) &amp;&amp; 
(AND(  RecordTypeId == LEFT($Setup.QnC_Case_Properties__c.QnC_Case_Record_Type_Id__c, 15),
AND(ISCHANGED(Status),isPickval(Status,&quot;Re-opened&quot;)), 
OR(QnC_Case_Type__c =&quot;Corporate&quot;,
QnC_Case_Type__c =&quot;Corporate-Salesops&quot;,
QnC_Case_Type__c =&quot;Corporate-APJ&quot;,
QnC_Case_Type__c =&quot;Corporate-AMER&quot;,
QnC_Case_Type__c =&quot;Corporate-EMEA&quot;
) , BEGINS(OwnerId,&quot;005&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QnC - EMEA%2FAPJ case Escalation Notification</fullName>
        <actions>
            <name>QnC_AMEA_APJ_case_Escalation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND($User.IsDataMigrationUser__c =false,
RecordTypeId = LEFT($Setup.QnC_Case_Properties__c.QnC_Case_Record_Type_Id__c,15),
ISCHANGED(IsEscalated), IsEscalated, 
AND(OR(isPickval(GSS_Support_Customer_Region__c,&apos;APAC&apos;) ,
isPickval(GSS_Support_Customer_Region__c,&apos;EMEA&apos;)),
QnC_Case_Type__c =&quot;Corporate-Salesops&quot;),
OR(QnC_Case_Type__c =&quot;Corporate-EMEA&quot;,
QnC_Case_Type__c =&quot;Corporate-APJ&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QnC - Update Case Type</fullName>
        <actions>
            <name>QnC_Update_Case_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  $User.IsDataMigrationUser__c =false,  RecordTypeId = LEFT($Setup.QnC_Case_Properties__c.QnC_Case_Record_Type_Id__c,15),  OR(ISNEW(), ISCHANGED( OwnerId )),  OR(  OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_APJ_Commissions_Id__c,15 ),  OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_AMER_Commissions_Id__c,15 ), OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Amer_Sales_Ops__c,15 ),  OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_EMEA_Commissions_Id__c,15 ), OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Geo_Commissions_Id__c,15 ),  OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Corporate_Commissions_Id__c,15),  OwnerId = LEFT( $Setup.QnC_Case_Properties__c.Queue_Geo_Sales_Commission__c,15 )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
