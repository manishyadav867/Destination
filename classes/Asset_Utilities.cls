//***************************************************************************************
// Name             : Asset_Utilities.cls
// Description      : Utility class to form the batch query and to get field describes
// Created By       : Accenture
// Created Date     : 06/15/2012

// ************************Version Updates***********************************************
// 
// ***************************************************************************************

public with sharing class Asset_Utilities {
    
    // *********************************************************************************
    // Name       :   getObjectKeyMap
    // Description:   Method to create a map of object field definition
    //
    // Parameters :   String object name 
    // Returns    :   Map of String & SchemaSObjectField
    // ***********************************************************************************
    public static Map<String, Schema.SObjectField> getObjectKeyMap(String objName)
    {   
        Map<String, Schema.SObjectField> objectKeyMap = new Map<String, Schema.SObjectField>();
        
        if(objName.equalsIgnoreCase('Case')){
          objectKeyMap = Schema.SObjectType.Case.fields.getMap();
        } 
        if(objName.equalsIgnoreCase('Contact')){
           objectKeyMap = Schema.SObjectType.Contact.fields.getMap();
        }
        //CGS related changes - starts
        if(objName.equalsIgnoreCase('Case_SLA__c')){
           objectKeyMap = Schema.SObjectType.Case_SLA__c.fields.getMap();
        }
        //CGS related changes - ends
        if(objName.equalsIgnoreCase('Lead')){
           objectKeyMap = Schema.SObjectType.Lead.fields.getMap();
        }
        if(objName.equalsIgnoreCase('Account')){
           objectKeyMap = Schema.SObjectType.Account.fields.getMap();
        }
        if(objName.equalsIgnoreCase('VMW_Team_Resource__c')){
           objectKeyMap = Schema.SObjectType.VMW_Team_Resource__c.fields.getMap();
        }
        if(objName.equalsIgnoreCase('Opportunity')){
           objectKeyMap = Schema.SObjectType.Opportunity.fields.getMap();
        }
        if(objName.equalsIgnoreCase('Deal_Registration__c')){
           objectKeyMap = Schema.SObjectType.Deal_Registration__c.fields.getMap();
        }        
        return objectKeyMap;
    }
    
    // *********************************************************************************
    // Name       :   getObjEmailFields
    // Description:   Method to get the all email fields from  object
    //
    // Parameters :   String object name  
    // Returns    :   List of String
    // ***********************************************************************************
    public static List<String> getObjEmailFields(String objName)
    {   
        List<String> objEmailFieldList = new List<String>();
                      
        Map<String, Schema.SObjectField> objectFieldMap = getObjectKeyMap(objName);                             

        for(String fapiKey: objectFieldMap.keySet()){   
            Schema.DescribeFieldResult F = objectFieldMap.get(fapiKey).getDescribe();                          
                        
            if(String.ValueOf(F.getType())=='Email'){
                objEmailFieldList.add(String.ValueOf(objectFieldMap.get(fapiKey)));       
            }
        }
        return objEmailFieldList;           
    }
    
    // *********************************************************************************
    // Name       :   getSobjectQuery
    // Description:   Method to form the quesry for various objects for email masking
    //
    // Parameters :   String object name  
    // Returns    :   String
    // ***********************************************************************************          
    public static String getSobjectQuery(String objName)
    {
        List<String> objectEmailFieldList = getObjEmailFields(objName);
              
        String QUERY_TO_UPDATE = 'Select Id,';
        for(Integer i=0;i<objectEmailFieldList.size();i++)
        {
            if(i!=0)
            {              
                QUERY_TO_UPDATE+=','+objectEmailFieldList.get(i);
            }
           else
            {
               QUERY_TO_UPDATE+=objectEmailFieldList.get(i);
            }              
        }
        if(objName.equalsIgnoreCase('Lead')){
            
            QUERY_TO_UPDATE+=' From '+ objName+' where IsConverted = false';
        }
        else{
            QUERY_TO_UPDATE+=' From '+ objName;
        }     
        return QUERY_TO_UPDATE;
    }
}