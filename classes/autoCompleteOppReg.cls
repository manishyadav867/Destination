// ******************************************************************************************************
// Name             : autoCompleteOppReg.cls
// Description      : Controller class for autoCompleteAccount and autoCompleteOppReg VF Components against CR-00138214
// Created By       : Vijit Vijay[Accenture]
// Created Date     : 17/03/2016
// *******************************************************************************************************
//Modification Log :
//* Developer                   Date                   Description
//* ----------                  -----                  ------------------------
//* Vijit                   10 Aug 2016            Changes for CR-00140707
//* Hem                     24 Aug 2016            Changes for CR-00140589
//************************************************************************************************************/
global class autoCompleteOppReg{
    public static String BLANK= '';
    public static String None= '--None--';
    public static String dblUnderscore= '__';
    public static String Underscore = '_';
    /*        
     @Description : This method is used for auto suggestion based on email entered.
     @Return : Contact List
     @Param : String
    */
    public static List<contact> searchkeywords(string searchText) {
        String searchTextDefault = searchText.trim();
        ID conRecordTypeID = Record_Type_Settings__c.getall().get('SFA_Con_Cust').Record_Type_ID__c;
        List<contact>lstContact=new List<contact>();

        searchTextDefault=searchTextDefault.replaceAll( '\\s+', ' ');        
        //Modified below query for CR-00140707 - START
        lstContact=[Select Email, Lastname, FirstName, Country__c, Job_Function__c, Department__c, Phone, Account.Name, Account.id, Account.EA_Number__c, Address_1__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Code__c, State__c from Contact where Email LIKE:searchTextDefault and RecordType.id = :conRecordTypeID and Active_Status__c = 'Active' and (NOT Contact.Account.Name Like '%Test%') and (NOT Contact.Account.Name Like '%Default Consumer Account%') and (NOT Contact.Account.Name Like '%VMware%') limit 10];      
        return lstContact;
    }

    /*        
     @Description : This method is used for auto suggestion based on email entered.
     @Return : Contact List
     @Param : String
    */
    
    @RemoteAction
    global static SObject[] findSObjects(string obj,string qry, string addFields, string profilename) 
    {
        
        List<sObject> L = new List<sObject>();
        try 
        {
            L = searchkeywords(qry);//Database.query(soql);
        }
        catch (QueryException e) 
        {
            return null;
        }
        return L;
   }
   
    /*        
     @Description : This method is used for auto suggestion based on Country.
     @Return : Account List
     @Param : String
    */
   public static List<Account> searchkeywordsAccount(string searchText,string accountCountry,string accountState) {
        //Set<String> queryPFSTSet = new Set<String>();
        //queryPFSTSet = getPFSTSet();
        //Added by HEM on 26th-Aug-2016 - CR-00140589 - START
        List<String> excludePFSTList = new List<String>();
        excludePFSTList = Orion_Record__c.getInstance('PFSTNames')!=null && Orion_Record__c.getInstance('PFSTNames').value__c!=null?Orion_Record__c.getInstance('PFSTNames').value__c.split(';'):'Airwatch_temporary;Renewals_Temporary;VMware Consumer'.split(';');        
        Set<String> excludePFSTSet=new Set<String>(excludePFSTList);
        //System.debug('---searchkeywordsAccount----excludePFSTSet------'+excludePFSTSet);
        //Added by HEM on 26th-Aug-2016 - CR-00140589 - END
        
        String searchTextDefault = searchText.trim();        
        List<Account>lstAccount=new List<Account>();            
           searchTextDefault=searchTextDefault.replaceAll( '\\s+', ' ');
           String[] strs = searchTextDefault.split(',');           
           
        ID ECAcctRecordTypeID = Record_Type_Settings__c.getall().get('SFA_Acc_EC').Record_Type_ID__c;        
        
        if(strs.size() == 1){
            
            if(accountState != null && accountState !=BLANK && accountState != None && accountState != dblUnderscore && accountState != Underscore){                        
                
                String searchTextDefault1 = strs[0];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault1 + '%' and country__c=:accountCountry and State_Province__c=:accountState and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];
                return lstAccount;
            }else{              
                String searchTextDefault1 = strs[0];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault1 + '%' and country__c=:accountCountry and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];               
                return lstAccount;
            }
        }else if(strs.size() == 2){
            if(accountState != null && accountState !=BLANK && accountState != None && accountState != dblUnderscore && accountState != Underscore){
                String searchTextDefault2 = strs[0];
                String address = strs[1];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault2 + '%' and country__c=:accountCountry and State_Province__c=:accountState and Address_1_del__c LIKE:address + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];               
                return lstAccount;              
            }else{
                String searchTextDefault2 = strs[0];
                String address = strs[1];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault2 + '%' and country__c=:accountCountry and Address_1_del__c LIKE:address + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];                
                return lstAccount;
            }
        }else if(strs.size() == 3){
            if(accountState != null && accountState !=BLANK && accountState != None && accountState != dblUnderscore && accountState != Underscore){
                String searchTextDefault3 = strs[0];
                String address = strs[1];
                String city = strs[2];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault3 + '%' and country__c=:accountCountry and State_Province__c=:accountState and Address_1_del__c LIKE:address + '%' and City__c LIKE:city + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];            
                return lstAccount;              
            }else{
                String searchTextDefault3 = strs[0];
                String address = strs[1];
                String city = strs[2];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault3 + '%' and country__c=:accountCountry and Address_1_del__c LIKE:address + '%' and City__c LIKE:city + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];                
                return lstAccount;
            }
        }else if(strs.size() == 4){
            if(accountState != null && accountState !=BLANK && accountState != None && accountState != dblUnderscore && accountState != Underscore){               
                String searchTextDefault4 = strs[0];
                String address = strs[1];
                String city = strs[2];
                String state = strs[3];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault4 + '%' and country__c=:accountCountry and State_Province__c=:accountState and Address_1_del__c LIKE:address + '%' and City__c LIKE:city + '%' and State_Province__c LIKE:state + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];                
                return lstAccount;              
            }else{
                String searchTextDefault4 = strs[0];
                String address = strs[1];
                String city = strs[2];
                String state = strs[3];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault4 + '%' and country__c=:accountCountry and Address_1_del__c LIKE:address + '%' and City__c LIKE:city + '%' and State_Province__c LIKE:state + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];                
                return lstAccount;
            }   
        }else if(strs.size() == 5){
            if(accountState != null && accountState !=BLANK && accountState != None && accountState != dblUnderscore && accountState != Underscore){
                String searchTextDefault5 = strs[0];
                String address = strs[1];
                String city = strs[2];
                String state = strs[3];
                String country = strs[4];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault5 + '%' and country__c LIKE:country + '%' and State_Province__c=:accountState and Address_1_del__c LIKE:address + '%' and City__c LIKE:city + '%' and State_Province__c LIKE:state + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];                
                return lstAccount;              
            }else{
                String searchTextDefault5 = strs[0];
                String address = strs[1];
                String city = strs[2];
                String state = strs[3];
                String country = strs[4];
                lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where name LIKE:searchTextDefault5 + '%' and country__c LIKE:country + '%' and Address_1_del__c LIKE:address + '%' and City__c LIKE:city + '%' and State_Province__c LIKE:state + '%' and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];                
                return lstAccount;
            }   
        }
        return lstAccount;
    }
    
    /*        
     @Description : This method is used for auto suggestion based on Country.
     @Return : Account List
     @Param : String
    */
   @RemoteAction
    global static SObject[] findSObjectsAccount(string obj,string qry, string addFields, string addFieldsState, string profilename) 
    {

        List<sObject> L = new List<sObject>();
        try 
        {
            L = searchkeywordsAccount(qry,addFields,addFieldsState);//Database.query(soql);
        }
        catch (QueryException e) 
        {
            return null;
        }
        return L;
    }
    
    /*        
     @Description : This method is used for auto suggestion based on Domain.
     @Return : Account List
     @Param : String
    */
    public static List<Account> searchkeywordsDomain(string searchText,string accountCountry) {
        //Added by HEM on 26th-Aug-2016 - CR-00140589 - START
        List<String> excludePFSTList = new List<String>();
        excludePFSTList = Orion_Record__c.getInstance('PFSTNames')!=null && Orion_Record__c.getInstance('PFSTNames').value__c!=null?Orion_Record__c.getInstance('PFSTNames').value__c.split(';'):'Airwatch_temporary;Renewals_Temporary;VMware Consumer'.split(';');        
        Set<String> excludePFSTSet=new Set<String>(excludePFSTList);
        //System.debug('---searchkeywordsDomain----excludePFSTSet------'+excludePFSTSet);
        //Added by HEM on 26th-Aug-2016 - CR-00140589 - END
        String searchTextDefault = searchText.trim();
        List<Account>lstAccount=new List<Account>();       
           searchTextDefault=searchTextDefault.replaceAll( '\\s+', ' ');
           
        ID ECAcctRecordTypeID = Record_Type_Settings__c.getall().get('SFA_Acc_EC').Record_Type_ID__c;                
             
       lstAccount=[Select id, Name, Address_1_del__c, Address_2__c, Address_3__c, Address_4__c, City__c, Zip_Postal_Code__c, Country__c, State_Province__c, Domain_Name__c from Account where Domain_Name__c LIKE:'%' + searchTextDefault + '%' and country__c=:accountCountry and RecordType.id = :ECAcctRecordTypeID and (NOT Account.Name Like '%Test%') and (NOT Account.Name Like '%Default Consumer Account%') and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) limit 5];       

        return lstAccount;
    }
    /*        
     @Description : This method is used for auto suggestion based on Domain.
     @Return : Account List
     @Param : String
    */
   @RemoteAction
    global static SObject[] findSObjectsDomain(string obj,string qry, string addFields, string profilename) 
    {
        List<sObject> L = new List<sObject>();
        try 
        {
            L = searchkeywordsDomain(qry,addFields);//Database.query(soql);
        }
        catch (QueryException e) 
        {
            return null;
        }
        return L;
   }
}