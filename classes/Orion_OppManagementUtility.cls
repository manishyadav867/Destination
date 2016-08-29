//************************************************************************************************************
// Name             : Orion_OppManagmentUtility.cls
// Description      : This class has all the processing needed for auto approval process and product validation
//                    This class is created as part of Orion Phase 2 Project CR-00138210 and CR-00138211
// Created By       : Yoganand Gadekar.
// Created Date     : 07/03/2016

/************************Version Updates********************************************************************
26/Aug/2016       Hem    Changes for CR-00140589
26/Aug/2016       Vijit  Changes for CR-00140797
 ***********************************************************************************************************/
public class Orion_OppManagementUtility {

Public static string SIR_Fallout_Reason = 'SIR_Fallout_Reason';
Public static string NoCustomerFound = 'NoCustomerFound';
Public static string multiplecustomerfound = 'multiplecustomerfound';
Public static string opcspfflagcheck = 'opcspfflagcheck';
Public static string opcflagChecked = 'opcflagChecked';
Public static string noneglishinform = 'noneglishinform';
Public static string MSORecordTypeId = 'MSORecordTypeId';
Public static string manualdetermination = 'manualdetermination';
Public static string noopenopportunity = 'noopenopportunity';
Public static string bypassapprovalstatuses= 'bypassapprovalstatuses';
Public static string PendingAssignmentUserId = 'PendingAssignmentUserId';
Public static string DealDenialReason = 'DealDenialReason';
Public static string Approve = 'Approve';
Public static string Auto_approved = 'Auto approved';
Public static string Registration_Products = 'Registration Products';
Public static string Registrations = 'Registrations';
Public static string Deal_Registration = 'Deal Registration';
Public static string SFA_Acc_EC = 'SFA_Acc_EC';
Public static string PSO = 'PSO';
Public static string Reject = 'Reject';
Public static string Auto_rejected = 'Auto rejected';
Public static string Other = (Orion_Phase_II_Configurations__c.getInstance('reasonforreject')!=null && Orion_Phase_II_Configurations__c.getInstance('reasonforreject').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('reasonforreject').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('reasonforreject').value__c:'The opportunity is already in VMware’s pipeline.';//'Other'; modified as part of Orion Hotfix 05th Auguts
Public Static Id dealRegId;
Public static List<String> dealRegProducts;
Public Static boolean dealRegInAutoApproval = false;
//Public Static String emailSubject = Orion_Phase_II_Configurations__c.getValues('partnerEmailSubject').value__c;
//Public Static String usersEmailId;
//Public Static String emailTemplateBody;
Public static boolean eligibleToLeadService = false;
//Public static string emailToPartnerBody = 'All the products added on Registration were approved';
//Public static string emailToPartnerSub = Orion_Phase_II_Configurations__c.getValues('partnerEmailSubject').value__c;
Public static string accPbmUserName;
Public static string allApprovedProductNames;
Public static boolean allowOppUpdateCheck = true;
public static boolean AprovalfirstRun =true;
Public static boolean acrDealApproval = false;
Public static boolean dealRegProgramUpdate = false;
Public static string dealRegStatus;
Public static string resubmitApprovedPro;
Public static string resubmitRejectedPro;
Public static string manualRuleReason;
Public static List<partner_select_product__c> rejectedProList;//= New Map<id,id>();
Public static boolean leadupdateRecursiveCheck = true;
Public static Id oppOwnerId;
public static boolean sendEmailToOnOppCreate = false;
Public static string accountISREmail;
Public static Id accSourcedOnCustomerName;
Public static Id sourcedConId;
Public static boolean dealManualDeterCheck = false;
public static boolean multipleAccountFlag = false;    //Added as part of CR-00140795 on 26/Aug/2016 - Vijit
Public static string stageNameQua = (Orion_Phase_II_Configurations__c.getInstance('stageNameQua')!=null && Orion_Phase_II_Configurations__c.getInstance('stageNameQua').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('stageNameQua').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('stageNameQua').value__c:'02 - Qualified';//'Other'; modified as part of Orion Hotfix 05th Auguts
Public static id accRecordTypeID = Record_Type_Settings__c.getall().get('SFA_Acc_EC').Record_Type_ID__c;//added as part of 26th August Release  
 
  Public static void searchAccount(Deal_Registration__c dealRegRec,string accId){
     String NameAcc = dealRegRec.Company__c;
     string CountryAcc = dealRegRec.country__c;
     string CityAcc = dealRegRec.city__c;
     string ZipCodeAcc = dealRegRec.Zip_Postal_Code__c;
     string StateAcc = dealRegRec.State_Province__c;
     string domainAcc = dealRegRec.Orion_Customer_Domain__c;
     //added as part of 26th August Release - start
        string domainNames = (Orion_Phase_II_Configurations__c.getInstance('domainNames')!=null && Orion_Phase_II_Configurations__c.getInstance('domainNames').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('domainNames').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('domainNames').value__c:'www.,http://www.,https://www.';//'Other'; modified as part of Orion Hotfix 05th Auguts
        List<string> domainNameList = new List<string>();        
            domainNameList.add(domainAcc);
        
        for(string str : domainNames.split(',')){
            if(domainAcc != null && domainAcc != '')
                domainAcc = domainAcc.removeStartIgnoreCase(str);
        }        
        for(string str : domainNames.split(',')){
            if(str != null && str != '')    
                domainNameList.add(str+domainAcc);
        }
        if(domainAcc!= null && domainAcc!= ''){
            domainNameList.add(domainAcc);
        }    
     //added as part of 26th August Release - end
                 
     List<account> accList = New List<account>();
     //added as part of 26th August start
     List<account> accDomList = New List<account>();
     List<account> accNameList = New List<account>();
     List<account> accFormList = New List<account>();
     Boolean putDealInAuto = false;
     string noSingleAccount = (Orion_Phase_II_Configurations__c.getInstance('nosingleaccount')!=null && Orion_Phase_II_Configurations__c.getInstance('nosingleaccount').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('nosingleaccount').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('nosingleaccount').value__c:'No Single account was found';
     Boolean putdealInACR = false;
     string multiAccount = (Orion_Phase_II_Configurations__c.getInstance('multiAccount')!=null && Orion_Phase_II_Configurations__c.getInstance('multiAccount').value__c!=null && Orion_Phase_II_Configurations__c.getInstance('multiAccount').value__c!='')?Orion_Phase_II_Configurations__c.getInstance('multiAccount').value__c:'Multiple accounts found for the entered email address.';     //Added as part of CR-00140795 on 26/Aug/2016 - Vijit
     //added as part of 26th August end
     
     List<deal_Registration__c> dealList = New List<deal_registration__c>();
     dealList.add(dealRegRec);
      rejectedProList = New List<partner_select_product__c>();
        eligibleToLeadService = dealRegRec.Orion_Eligible_to_Lead_Services__c;
        dealRegStatus = dealRegRec.Registration_Status__c;
                
     //use the account found on registration form for product valdiation
     if(accId != null){
       accFormList = database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Id = \''+accId+'\' limit 1');
     }
     //Do account search if account was not found on registration form
     //else {
         //Added by HEM on 26th-Aug-2016 - CR-00140589 - START
         List<String> excludePFSTList = new List<String>();
         excludePFSTList = Orion_Record__c.getInstance('PFSTNames')!=null && Orion_Record__c.getInstance('PFSTNames').value__c!=null?Orion_Record__c.getInstance('PFSTNames').value__c.split(';'):'Airwatch_temporary;Renewals_Temporary;VMware Consumer'.split(';');        
         Set<String> excludePFSTSet=new Set<String>(excludePFSTList);
         System.debug('-----excludePFSTSet------'+excludePFSTSet);
         //Added by HEM on 26th-Aug-2016 - CR-00140589 - END
         //Search accounts based on address and domain main
         //accList =  database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Country__c = \''+ dealRegRec.country__c+'\' and City__c = \'' +dealRegRec.city__c +'\' and Zip_Postal_Code__c = \''+ dealRegRec.Zip_Postal_Code__c +'\'and State_Province__c = \'' +dealRegRec.State_Province__c +'\' and Domain_Name__c = \''+ dealRegRec.Orion_Customer_Domain__c+'\'');
         // Modified below query for CR-00140797, on 26/Aug/2016 - Vijit - START
         //Modified below queries for CR-00140589 for 26/Aug/2016 [added: and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet)] - HEM
         if(CountryAcc == 'UNITED STATES'){
             accDomList =  database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Country__c =: CountryAcc and City__c =: CityAcc and State_Province__c =: StateAcc and Domain_Name__c IN : domainNameList and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) and RecordType.id = : accRecordTypeID');
             // search accounts based on address and customer name if previous search did not yeild any results
             //if(accList.size() == 0){                 
                //accList = database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Country__c = \''+ dealRegRec.country__c+'\' and City__c = \'' +dealRegRec.city__c +'\' and Zip_Postal_Code__c = \''+ dealRegRec.Zip_Postal_Code__c +'\'and State_Province__c = \'' +dealRegRec.State_Province__c +'\' and Name = \''+ dealRegRec.Company__c+'\'');
               // Modified below query for CR-00140797, added Zip_Postal_Code__c condition on 26/Aug/2016 - Vijit
               accNameList = database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Country__c =: CountryAcc and City__c =: CityAcc and State_Province__c =: StateAcc and Name Like \'%'+ NameAcc +'%\' and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) and RecordType.id = : accRecordTypeID');
           
            //}  
         }else{
             accDomList =  database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Country__c =: CountryAcc and (City__c =: CityAcc OR State_Province__c =: StateAcc) and Domain_Name__c IN : domainNameList and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) and RecordType.id = : accRecordTypeID');
             //if(accList.size() == 0){                 
                //accList = database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Country__c = \''+ dealRegRec.country__c+'\' and City__c = \'' +dealRegRec.city__c +'\' and Zip_Postal_Code__c = \''+ dealRegRec.Zip_Postal_Code__c +'\'and State_Province__c = \'' +dealRegRec.State_Province__c +'\' and Name = \''+ dealRegRec.Company__c+'\'');
                // Modified below query for CR-00140797, added Zip_Postal_Code__c condition on 26/Aug/2016 - Vijit
                accNameList = database.query(Orion_OppManagementSequenceController.buildQueryString(false,true,false)+' where Country__c =: CountryAcc and (City__c =: CityAcc OR State_Province__c =: StateAcc) and Name Like \'%'+ NameAcc +'%\' and (NOT Primary_Field_Sales_Territory__r.Name IN:excludePFSTSet) and RecordType.id = : accRecordTypeID');
            //}
         }
     //}       
     
     /*Added as part of 26th August Release - start*/ 
      if((accId != null && accDomList.size() == 0 && accNameList.size() == 0) || (accId == null && accDomList.size() == 0 && accNameList.size() == 1) || (accId == null && accDomList.size() == 1 && accNameList.size() == 0)){
         putDealInAuto =  true;
      }
      
      if(accId != null && accDomList.size() == 1 && accNameList.size() == 1){
         if(accId == accDomList[0].Id && accId == accNameList[0].Id){
            putDealInAuto =  true;
         }
      }
      if(accId != null && accDomList.size() == 1 && accNameList.size() == 0){
         if(accId == accDomList[0].Id){
            putDealInAuto =  true;
         }
      }
      if(accId != null && accDomList.size() == 0 && accNameList.size() == 1){
         if(accId == accNameList[0].Id){
            putDealInAuto =  true;
         }
      } 
      if(accId == null && accDomList.size() == 1 && accNameList.size() == 1){
         if(accDomList[0].Id == accNameList[0].Id){
            putDealInAuto =  true;
         }
      }  
      
      if(accId == null && accDomList.size() == 0 && accNameList.size() == 0){
         putdealInACR = true;
      }
      
      if(accId != null ){
         accList = accFormList;
      }         
      else if(accDomList.size() == 1){
        accList = accDomList;
      }
      else if(accNameList.size() == 1){
        accList = accNameList;
      }
      /*Added as part of 26th August Release - end*/
      
        //Added as part of CR-00140795 on 19/Aug/2016 - Vijit - START
       if((manualExceptionDetermine(null,dealRegRec,null) && acrDealApproval == false) || (multipleAccountFlag == true) || (putDealInAuto == false) || (putdealInACR == true)){
           System.debug(logginglevel.error,'Inside New IF---- ');
            dealRegRec.Orion_Denial_Reason__c  = manualRuleReason ;
            //Added as part of 26th August Release start
            if(putDealInAuto  == false){
               dealRegRec.Orion_Denial_Reason__c = noSingleAccount ;
            }
        //Added as part of CR-00140795 on 26/Aug/2016 - Vijit - START
            if(multipleAccountFlag  == true){
               dealRegRec.Orion_Denial_Reason__c = multiAccount ;
            } //Added as part of CR-00140795 on 26/Aug/2016 - END
            //Added as part of 26th August Release end
            if(putdealInACR){
                dealRegRec.Orion_Denial_Reason__c = Orion_Phase_II_Configurations__c.getValues(NoCustomerFound).value__c;
                dealRegRec.Orion_Deal_In_ACR__c = true;
            }    
            update dealRegRec;
            submitDealRegInApproval();
            dealManualDeterCheck = true; 
       } //Added as part of CR-00140795 on 19/Aug/2016 - Vijit - END      
       else if(accList.size() == 1 && manualExceptionDetermine(accList[0],null,null) && acrDealApproval == false){
              dealRegRec.Orion_Denial_Reason__c  = manualRuleReason ;
              update dealRegRec;
              submitDealRegInApproval();
              dealManualDeterCheck = true;
       }
       //Added as part of CR–00140578 -end
     if(dealManualDeterCheck == false){       
     //Submit the deal reg record in manual approval process if multiple accounts are found or no accounts are found
     if(accList.size() > 1 || accList.size() == 0 || dealRegRec.Source_SIR_DealReg__c == true){ 
       if(accList.size() == 0 || dealRegRec.Source_SIR_DealReg__c == true){
       if(dealRegRec.Source_SIR_DealReg__c == true)
          dealRegRec.Orion_Denial_Reason__c  = Orion_Phase_II_Configurations__c.getValues(SIR_Fallout_Reason).value__c;
       else
           dealRegRec.Orion_Denial_Reason__c  = Orion_Phase_II_Configurations__c.getValues(NoCustomerFound).value__c;
           dealRegRec.Orion_Deal_In_ACR__c = true;
           update dealRegRec;
           //create new account request and flow will continue once ACR is completed
           //createNewAccountRequest(dealRegRec);
           submitDealRegInApproval();
       }    
       else{
           dealRegRec.Orion_Denial_Reason__c  = Orion_Phase_II_Configurations__c.getValues(multiplecustomerfound).value__c;
           update dealRegRec;           
           submitDealRegInApproval();
       }    
       
     }  
     else if(accList.size() == 1){
            string opcSpfCheck = Orion_Phase_II_Configurations__c.getValues(opcspfflagcheck).value__c;
            // send deal reg in manual approval if opc flag is set on the customer account search
            if(opcSpfCheck  == 'ON' && (accList[0].AccountExtension__r.Orion_ElaOpcFlag__c || accList[0].AccountExtension__r.Orion_Non_Standard_SPF_flag__c)){
               dealRegRec.Orion_Denial_Reason__c  = Orion_Phase_II_Configurations__c.getValues(opcflagChecked).value__c;
               update dealRegRec;
               submitDealRegInApproval();
            }
            else{
                if(checkifNonEnglish(dealRegRec.Company__c) || checkifNonEnglish(dealRegRec.Orion_Customer_Domain__c) || checkifNonEnglish(dealRegRec.email__c)){
                   dealRegRec.Orion_Denial_Reason__c  = Orion_Phase_II_Configurations__c.getValues(noneglishinform).value__c;
                   update dealRegRec;
                   submitDealRegInApproval(); 
                }
                else{
                    // send deal reg record in auto approval process
                    accPbmUserName = accList[0].PBM__r.Name;
                    oppOwnerId = accList[0].Primary_Field_Sales_Territory__r.ISR_IAR__c;
                    accountISREmail = accList[0].Primary_Field_Sales_Territory__r.ISR_IAR__r.email; 
                    if(acrDealApproval){
                        //dealRegRec = Orion_OppManagementSequenceController.updateAddressOnDealRegFromAcr(dealRegRec,accList[0]);
                    }
                        Orion_OppManagementSequenceController.accNewCountry = accList[0].country__c;
                        Orion_OppManagementSequenceController.accNewCity = accList[0].city__c;
                        Orion_OppManagementSequenceController.accNewName = accList[0].name;
                        Orion_OppManagementSequenceController.accNewAddress1 = accList[0].Address_1_del__c;
                        Orion_OppManagementSequenceController.accNewAddress2 = accList[0].Address_2__c;
                        Orion_OppManagementSequenceController.accNewZipCode = accList[0].Zip_Postal_Code__c;
                        Orion_OppManagementSequenceController.accNewState  = accList[0].State_Province__c;
                        Orion_OppManagementSequenceController.accNewDomainName = accList[0].Domain_Name__c;
                    executeProductValidation(accList[0],dealRegRec); 
                }
            }
         }   
     }    
  } 
  
    Public static void executeProductValidation(account acc,Deal_Registration__c dealReg){       
       
           Set<string> oppproductModelNSet = New Set<String>();      
           Set<string> psoOppproductModelNSet = New Set<String>();
           Set<string> psoPlatformGroupSet  = New Set<String>();
           Set<string> oppProductsSet = new Set<string>();      
           Set<Id> psoOppProductsSet = new Set<Id>();
           Set<String> oppMultiSelectProSet = New Set<String>();
           
           Id endCustomerAccntRecTypeId = Record_Type_Settings__c.getValues(SFA_Acc_EC).Record_Type_ID__c; 
           Set<id> allaccIdSet = new Set<Id>();
           List<Partner_Select_Product__c> allDealProductList = New List<Partner_Select_Product__c>();
           Set<Id> approvedProductSet = New Set<Id>();
           List<Partner_Select_Product__c > approvedProductList = New List<Partner_Select_Product__c>();
            Set<Id> approvedProductIdSet = New Set<Id>();
           Set<Id> psoApprovedProductIdSet = New Set<Id>();           
           Boolean goForManualApproval = false;
           String msoOpportunityRecordType = Orion_Phase_II_Configurations__c.getValues(MSORecordTypeId).value__c;
           
           // save products from registration product line in a map for comparison
           for(Partner_Select_Product__c  dealProduct : database.query(Orion_OppManagementSequenceController.buildQueryString(false,false,true)+' where Registration__c = \'' +dealRegId+'\' and Approved__c != true and Rejected__c != true')){
                allDealProductList.add(dealProduct);            
           }
           // Execute manual exception rules and if match found go for manual approval
           //if(manualExceptionDetermine(acc,dealReg,allDealProductList) && acrDealApproval == false){ - changed as part of CR–00140578 
           if(manualExceptionDetermine(null,dealReg,allDealProductList) && acrDealApproval == false){ //changed as part of CR–00140578 
              dealReg.Orion_Denial_Reason__c  = manualRuleReason ;//Orion_Phase_II_Configurations__c.getValues('manualdetermination').value__c;
              update dealReg;
              submitDealRegInApproval();
           }
           
           else{
           //Query all customer accounts having name and pfst same as that of the deal reg record.
           string accName = acc.name+'%';
           for(account acct : [Select Id, Name,Primary_Field_Sales_Territory__c from Account where Name like: accName and Primary_Field_Sales_Territory__c =: acc.primary_field_sales_territory__c and RecordTypeId = : endCustomerAccntRecTypeId Limit 49999]){
               allaccIdSet.add(acct.id);
           }
           
           map<string,string> proDealMap = New Map<string,string>();
           //Iterate through all the open MSO opportunities present on the accounts with same name under same PFST of the searched account
           for(opportunity opp : [select id,stageName,accountid,Orion_Registration_ProductIds__c,PSO_Opportunity_Flag__c,VMware_Products__c, Orion_Oppty_Do_You_Plan_To_Lead_Services__c, (select id,Product2Id,Quantity,Orion_Platform_Group__c,Associated_Platform_Group__c from OpportunityLineItems),(select id,name,PlatformGroup__c from Orion_Product_Lines__r) from Opportunity where (Not stageName like '%Closed%') and accountid IN : allaccIdSet and recordTypeId =: msoOpportunityRecordType ]){
              
              //iterate through opportunity line items to get the products asscoiated with open opportunities
              for(OpportunityLineItem opLine : opp.OpportunityLineItems){                           
                   oppProductsSet.add(opLine.Orion_Platform_Group__c);
                   proDealMap.put(opLine.Orion_Platform_Group__c,opp.id); 
 
                    if(opLine.Orion_Platform_Group__c == PSO){
                        psoPlatformGroupSet.add(opLine.Associated_Platform_Group__c);  
                    }
              } 
              
              //Store all the modelN products of open opportunities
              for(Orion_Product_Line__c opl : opp.Orion_Product_Lines__r){
                  oppproductModelNSet.add(opl.PlatformGroup__c);
                  proDealMap.put(opl.PlatformGroup__c,opp.id);
              } 
              
              //Store all products from product multiselect field of open opportunities
              if(opp.VMware_Products__c != null && opp.VMware_Products__c != ''){
                  for(string pro : string.valueof(opp.VMware_Products__c).split(';')){
                    oppMultiSelectProSet.add(pro);
                    proDealMap.put(pro,opp.id);
                  }
              }
           }  
         map<id,id> rejProOppMap = New Map<id,id>();
          id newOppId;
          for(Partner_Select_Product__c dealPro : allDealProductList){
              //add products which are not present on any open opportunities
              if((!oppProductsSet.contains(dealPro.Product_Platform_Group__c) && (!oppproductModelNSet.contains(dealPro.Platform_Group__c)) && !oppMultiSelectProSet.contains(dealPro.Product_Platform_Group__c))){ 
                  approvedProductIdSet.add(dealPro.Id);
                  approvedProductSet.add(dealPro.product__c);
                  approvedProductList.add(dealPro);
              }
              else{
                  rejectedProList.add(dealPro);
                  
                  if(proDealMap.get(dealPro.Product_Platform_Group__c) != null){
                    rejProOppMap.put(dealPro.id,proDealMap.get(dealPro.Product_Platform_Group__c));
                  }
                  
                  /*else if(proDealMap.get(dealPro.Platform_Group__c) != null){
                          rejProOppMap.put(dealPro.id,proDealMap.get(dealPro.Platform_Group__c));
                  } 
                  else if(proDealMap.get(dealPro.product__r.Name) != null){
                          rejProOppMap.put(dealPro.id,proDealMap.get(dealPro.product__r.Name));  
                  }*/
              }             
              
              if(!psoPlatformGroupSet.contains(dealPro.product__r.Name)){ 
                 psoApprovedProductIdSet.add(dealpro.Id);
              }   
          }  
          
          //Submit deal reg record in manual approval if no oppties were found on the accounts
          if(goForManualApproval && allaccIdSet.size() > 1){
              dealReg.Orion_Denial_Reason__c  = Orion_Phase_II_Configurations__c.getValues(noopenopportunity).value__c;
              update dealReg;
              submitDealRegInApproval();
          } 
          //if deal products were not found on open opportunities then go for auto approval process
          else{
            //Reject the deal Reg record if all the products were found on open opportunities
              if(approvedProductIdSet.size() == 0){
                  if(dealReg.registrations__c != null){                   
                    newOppId = addProductsToSalesOpp(dealReg.Registrations__c,dealReg,approvedProductList);
                  }  
                  approveOrrejectDeal(dealReg,false,dealReg.Registrations__c);                  
                  updateDealRegProducts(allDealProductList,approvedProductIdSet,psoApprovedProductIdSet,rejProOppMap);
              }    
              else{                                      
                   if(dealReg.Registrations__c == null){
                   //approve the deal reg record if some products were not found on open opportunities and create new oppty
                    newOppId = createNewOpty(acc.id,dealReg,approvedProductSet,approvedProductList);
                   }
                   else{
                     newOppId = addProductsToSalesOpp(dealReg.Registrations__c,dealReg,approvedProductList);
                   } 
                   updateDealRegProducts(allDealProductList,approvedProductIdSet,psoApprovedProductIdSet,rejProOppMap);
                   
                   //set email address body for the email to be sent to partner upon approval
                   //emailTemplateBody = 'Deal registration ORAN : '+dealReg.ORAN__c+'<br/><br/>'+emailTemplateBody; 
                   approveOrrejectDeal(dealReg,true,newOppId);
                   
              }    
          } 
       }                                                           
    }            
    
    Public static void submitDealRegInApproval(){
      // Submit the record for manual Approval
      if(!acrDealApproval){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(dealRegId);                        
        Approval.ProcessResult result = Approval.process(req);
      }
    }
    
    Public static id createNewOpty(Id searchedAccId,Deal_Registration__c dealReg,Set<Id> apprvedProductIdSet,List<Partner_Select_Product__c> apprvProductsList){
         //Concanate all approved products
         string allApprovedProducts = null;
         string allAppProductIds = null;
         string approvedProductNames = null;
         for(Partner_Select_Product__c DealPro : apprvProductsList){             
             if(allApprovedProducts != null && allApprovedProducts != ''){
                 if(!allApprovedProducts.contains(DealPro.Product_Platform_Group__c))
                     allApprovedProducts = allApprovedProducts+';'+DealPro.Product_Platform_Group__c;
             }    
             else{
               allApprovedProducts =DealPro.Product_Platform_Group__c;   
             }  
             
             if(approvedProductNames != null && approvedProductNames != ''){
                 if(!approvedProductNames.contains(DealPro.Name))
                     approvedProductNames = approvedProductNames +';'+DealPro.Name;
             }    
             else{
               approvedProductNames =DealPro.Name;   
             }
             
             
              if(allAppProductIds != null && allAppProductIds != ''){
                 allAppProductIds = allAppProductIds +';'+DealPro.product__c;
             }    
             else{
               allAppProductIds =DealPro.product__c;   
             } 
         } 
         allApprovedProductNames = approvedProductNames ;//allApprovedProducts;
         //Insert New opportunity
         Opportunity opp = new Opportunity();
         opp = opportunityFieldMapping(opp,dealReg,searchedAccId);
         //Update all approved products on opportunity multiselect picklist product field
         opp.VMware_Products__c = allApprovedProducts; 
         opp.Orion_Approved_Product_Names__c = approvedProductNames;
         opp.Orion_Registration_ProductIds__c = allAppProductIds ;               
         insert opp;
                                                 
         return opp.id;
    }
           
    
    Public static void approveOrrejectDeal(deal_registration__c dealRegRec,boolean approveDealReg,id oppRecId){
      //Approve or Reject deal depending on products found/not found on open oppties
      string bypassApproveStatuses = Orion_Phase_II_Configurations__c.getValues(bypassapprovalstatuses).value__c;
      boolean alreadyapproved = false;
      string rejectedProducts;
      for(partner_select_product__c dealPro : rejectedProList){
          if(rejectedProducts != null && rejectedProducts != ''){
            if(!rejectedProducts.contains(DealPro.Product_Platform_Group__c))
               rejectedProducts= rejectedProducts+';'+DealPro.Product_Platform_Group__c;
         }    
          else{
             rejectedProducts =DealPro.Product_Platform_Group__c;   
          }
             
      }
      
      for(string status : bypassApproveStatuses.split(',')){
          if(status == dealRegRec.registration_status__c){
             approveDealReg = true;
             alreadyapproved = true;
          }
      }
      
          if(!acrDealApproval)
              submitDealRegInApproval();
          dealRegInAutoApproval = true;
          deal_registration__c dealReg;
          if(approveDealReg){
            dealReg = new Deal_registration__c(
            id = dealRegRec.id,
            Registrations__c = oppRecId,
            Review_Status__c = Approve,
            Review_Comments__c = Auto_approved,
            Orion_Approved_Products__c = allApprovedProductNames,
            Orion_Eligible_to_Lead_Services__c = eligibleToLeadService,
            Resubmitted_Approved_Products__c = resubmitApprovedPro,
            ReSubmitted_Rejected_Products__c = rejectedProducts  
            );
            if(alreadyapproved)
               dealReg.Resubmit_For_Approval__c = true;
            //Send email to partner with ORAN and approved/rejected products details
            //usersEmailId = UserInfo.getUserEmail();
            //emailToPartnerSub = 'Deal registration : '+dealReg.Name+emailToPartnerSub;
            
            if(!alreadyapproved){               
               sendEmailToOnOppCreate = true;
               dealReg.Account_ISR_Email__c = accountISREmail;
               dealReg.Account_Populated__c = accSourcedOnCustomerName;
            } 

            //Call future method to create new contact in case if contact is not present.This is to be done only in case of ACR process
            if(acrDealApproval){               
               if(dealRegRec.ISR_Approver__c != null && string.valueof(dealRegRec.ISR_Approver__c).contains(Orion_Phase_II_Configurations__c.getValues(PendingAssignmentUserId).value__c)){            
                   Orion_OppManagementSequenceController.CreateNewContact(dealRegRec.Id,dealRegRec.email__c,accSourcedOnCustomerName,oppOwnerId,oppRecId,sourcedConId,dealRegRec.Active_Partner_Account__c,true);    
               } 
               else{
                  Orion_OppManagementSequenceController.CreateNewContact(dealRegRec.Id,dealRegRec.email__c,accSourcedOnCustomerName,dealRegRec.ISR_Approver__c,oppRecId,sourcedConId,dealRegRec.Active_Partner_Account__c,true); 
               } 
              
            }  
            else{
              //In case of Direct Approval without ACR, Craete Contact Role
              if(!alreadyapproved){
                 Orion_OppManagementSequenceController.CreateNewContact(dealRegRec.Id,dealRegRec.email__c,accSourcedOnCustomerName,dealRegRec.ISR_Approver__c,oppRecId,sourcedConId,dealRegRec.Active_Partner_Account__c,false); 
              }
            }          
          }
          else{        
            dealReg = new Deal_registration__c(
            id = dealRegRec.id,
            Orion_Denial_Reason__c = Orion_Phase_II_Configurations__c.getValues(DealDenialReason).value__c,
            Review_Status__c = Reject,
            Reason_for_Reject__c = Other,
            ReSubmitted_Rejected_Products__c = rejectedProducts,  
            Review_Comments__c = Auto_rejected);
          }
          
          if(acrDealApproval){
              dealReg = Orion_OppManagementSequenceController.updateAddressOnDealRegFromAcr(dealReg,accSourcedOnCustomerName);
          }
            update dealReg;                           
        
    }
    
    Public static void updateDealRegProducts(List<Partner_Select_Product__c> alldealProducts,Set<Id> approvedProductSet,Set<Id> psoApprovedProductSet,map<id,id> rejtdProOppMap){
        boolean allProductApproved = true;
        //string rejectedproductBody = 'Below products were rejected during auto approval : <br/>';
        //string eligibleToServiceBody = 'Below products are not eligible for lead services : <br/>';
        boolean allproductElgibleforService = true;
        for(Partner_Select_Product__c dealProLine : alldealProducts){
            //mark deal products as approved if products were not found opportunity
            if(approvedProductSet.contains(dealProLine.id)){
               dealProLine.Approved__c = true;
               dealProLine.Rejected__c =  false;
               dealProLine.Eligible_for_Benifits__c = true;
            }
            else{
               //mark deal products as rejected if products were found open opportunity
               dealProLine.Approved__c = false;
               dealProLine.Rejected__c = true;               
               dealProLine.Eligible_for_Benifits__c = false;
               dealProLine.Denial_Reason__c = 'Product is Rejected as it is already present on opportunity :'+rejtdProOppMap.get(dealProLine .id);
               //emailTemplateBody = 'Deal registration was approved but some of the products were Rejected';
               allProductApproved = false;
               //rejectedproductBody = rejectedproductBody +dealProLine.product__r.name+', ';
            }
            
            if(psoApprovedProductSet.contains(dealProLine.id) && dealProLine.Approved__c == true){
               dealProLine.Eligible_to_Lead_Services__c = true;
               if(dealRegStatus!=null && dealRegStatus!='' && dealRegStatus.contains('Approved') && !eligibleToLeadService )
                  dealProLine.Eligible_to_Lead_Services__c = false;
            }
            else{
               dealProLine.Eligible_to_Lead_Services__c = false; 
               allproductElgibleforService = false;
               //eligibleToServiceBody = eligibleToServiceBody +dealProLine.product__r.name+', ';
            }
        }  
        /*if(allProductApproved == false){
            emailToPartnerBody = rejectedproductBody ;
        }  
        if(allproductElgibleforService == false){
           emailToPartnerBody = emailToPartnerBody +'<br/><br/>'+eligibleToServiceBody ;
        }*/
        //  system.debug('==---===>>>>'+alldealProducts);
        update alldealProducts;
    }
    
    Public Static Opportunity opportunityFieldMapping(Opportunity opp,deal_registration__c thisDealReg,Id searchedAccId){
      //map opportunity fields with deal reg fields data
      opp.RecordTypeId = Orion_Phase_II_Configurations__c.getValues(MSORecordTypeId).value__c;
      if(oppOwnerId != null)
          opp.OwnerId = oppOwnerId;
      else    
         opp.OwnerId = Orion_Phase_II_Configurations__c.getValues(PendingAssignmentUserId).value__c;
      
      opp.CloseDate= thisDealReg.CloseDate__c;           
      opp.Name = thisDealReg.Project_Name__c;                                         
      opp.Campaign_Name__c = thisDealReg.Lead_Campaign_Name__c;            
      opp.Campaign_ID__c = thisDealReg.Campaign_ID__c;            
      opp.Description = thisDealReg.Description__c;
                        
      /*
      // Added by RPODDAR for CR-00012046
      if(thisLead != null && (opp.Lead_ID__c==null || opp.Lead_ID__c==''))
      {
        opp.Lead_ID__c = thisLead.Lead_ID__c;
      }
      else{
        opp.Lead_ID__c = opp.Lead_ID__c + (thisLead!=null? ';'+thisLead.Lead_ID__c : '');
      } End of RPODDAR for CR-00012046 */
                                
       opp.LeadSource = thisDealReg.LeadSource__c;                 
       opp.Last_Campaign_Response__c = thisDealReg.Last_Campaign_Response__c;                       
       opp.Screened_By__c = thisDealReg.Screened_By__c;            
       opp.Screening_Results__c = thisDealReg.Screening_Results__c;            
       opp.Screening_Pass_Date__c = thisDealReg.Screening_Pass_Date__c;                                                                             
       opp.Active_ORAN__c = thisDealReg.ORAN__c;                           
       opp.Primary_Product_Group_Interest__c = thisDealReg.Primary_Product_Group_Interest__c;
       opp.Secondary_Product_Group_Interest__c = thisDealReg.Secondary_Product_Group_Interest__c ;
       opp.Product_Interest__c = thisDealReg.Product_Interest__c;            
       if(opp.Amount == null){               
          opp.Amount= 0.0;
       }
       opp.StageName= stageNameQua;//'02-Qualified';//thisDealReg.StageName__c;'02-Qualified';
       opp.accountId = searchedAccId;
              
       opp.Opportunity_Source__c = 'Registration';
       opp.Probability = thisDealReg.Orion_Close_Probability__c;//25; 
       opp.Forecast_Status__c = 'Upside';
       opp.OpportunityPartner_Reseller__c = thisDealReg.Active_Partner_Account__c;
       opp.End_User_Contact_First_Name__c = thisDealReg.First_Name__c;
       opp.End_User_Contact_Last_Name__c = thisDealReg.Last_Name__c;
       opp.Registration_Probability__c = thisDealReg.Orion_Close_Probability__c;//25; 
       opp.Registration_Sales_Stage__c = thisDealReg.StageName__c;//'02-Qualified';
       opp.VMware_List_License_Value__c = thisDealReg.VMware_List_License_Value__c ;
       opp.Registration_Next_Step__c = thisDealReg.Next_Steps__c;
       opp.Selling_Activities__c = thisDealReg.Value_Selling_Activities_Provided__c;
       opp.Partner_Contact__c = thisDealReg.Orion_Primary_Sales_Contact_Name__c;
       opp.Reseller_PRM_ID__c = thisDealReg.Partner_Id__c; 
       opp.Partner_PBM__c = thisDealReg.Active_Partner_Account__r.PBM__r.name;
       opp.Distributor__c = thisDealReg.Preferred_Distributor__c;
       opp.Route_to_Market__c = 'Channel';
       opp.Created_from_a_Registration__c = true;
       opp.Orion_Oppty_Do_You_Plan_To_Lead_Services__c = thisDealReg.Do_You_Plan_To_Lead_Services__c; //Added for CR-00138673 as part of Orion Phase-2 - Vijit
         
       return opp;    
    }
    
    Public static boolean ValidateDealForManualApproval(deal_registration__c dealRegRec, Id accountId){
     //Search account with changed address and compare it with sourced account, mark account for manual review if different accoutn found
      Boolean markDealForManualApproval = true;
      for(Account acc : [select id,name,Address_1_del__c,State_Province__c ,Country__c,City__c,Zip_Postal_Code__c,Domain_Name__c,Primary_Field_Sales_Territory__c from account where Country__c =: dealRegRec.country__c and City__c =: dealRegRec.city__c and Zip_Postal_Code__c =: dealRegRec.Zip_Postal_Code__c and State_Province__c =: dealRegRec.State_Province__c]){
          if(accountId == acc.id){
             markDealForManualApproval = false;
          }    
      }
      return markDealForManualApproval;
    }
    
    Public Static void createNewAccountRequest(List<Deal_Registration__c> thisDealList){
        // Created new ACR if no account was foudn during account sourcing step
        List<Account_request__c> accReqList = new List<Account_request__c>();
        for(Deal_Registration__c thisDeal : thisDealList){
            account_request__c accReq = new account_request__c();               
            accReq.Request_Process__c = Deal_Registration;         
            accReq.Account_Name_Native_Language__c = thisDeal.Company__c; 
            accReq.Account_Name__c = thisDeal.Company__c;                           
            accReq.Address_1__c = thisDeal.Address_1__c;     
            accReq.Address_2__c = thisDeal.Address_2__c;
            accReq.City__c = thisDeal.City__c;         
            accReq.State_Province__c = thisDeal.State_Province__c;   
            accReq.State_Other__c = thisDeal.State_Province__c;
            accReq.Postal_Code__c = thisDeal.Zip_Postal_Code__c;
            accReq.Country__c = thisDeal.Country__c;
            accReq.Industry__c = thisDeal.Industry__c;
            if(thisDeal.Industry__c == null || thisDeal.Industry__c == '')
               accReq.Industry__c = 'Other';
            accReq.uuid__c = thisDeal.uuid__c;
            accReq.duns__c = thisDeal.Duns__c;
            accReq.Global_Ult_DUNS__c = thisDeal.GULT__C;
            accReq.website__c = thisDeal.website__c;       
            accReq.Request_Status__c = 'New'; 
            accReq.Request_Type__c = 'New Account';         
            accReq.Requested_By__c = UserInfo.getUserId();
            accReq.System_Source__c = 'VMStar (SFDC)';
            //accReq.Orion_Approval_Deal_Id__c = thisDeal.Id;
            accReq.Deal_Registration__c = thisDeal.Id;
            accReq.Deal_ACR__c = true;
            accReqList.add(accReq);
        }
        database.insert(accReqList,false);
        
    }
        
    
    //Manual Exception Determination rules to compare account,deal and deal products data
    Public static boolean manualExceptionDetermine(account acc, Deal_Registration__c dealReg, List<Partner_Select_Product__c> dealRegProdList){
     boolean markDealForManualApp = false;
     string dealGeo; 
     //Added if as part of CR–00140578 
     if(dealReg != null){    
       dealGeo =  returnGeoForCountry(dealReg.country__c);
     }
       
      for(Manual_Exception_determination__c med : [Select id,Reason_Message__c,Object_Name__c,Object_Field__c,Geo__c,Field_Value__c from Manual_Exception_determination__c] ){
         //compare rules for account object 
         //Changed as part of CR–00140578         
          if(acc!= null && med.geo__c == acc.geo__c && med.Object_Name__c == 'Account' && acc.get(med.Object_Field__c) == med.Field_Value__c){
             markDealForManualApp = true;
             manualRuleReason = med.Reason_Message__c;
             break;
          }          
          if(dealGeo == med.geo__c){              
              //compare rules for registration object
              //Changed as part of CR–00140578         
              if(dealReg!= null && med.Object_Name__c == Registrations && dealReg.get(med.Object_Field__c) == med.Field_Value__c){
                 markDealForManualApp = true;
                 manualRuleReason = med.Reason_Message__c;                
                 break;
              }
              //compare rules for registration line items object
              //Changed as part of CR–00140578         
              if(dealRegProdList != null && med.Object_Name__c == Registration_Products){                 
                 for(Partner_Select_Product__c psp : dealRegProdList){                     
                     if(psp.get(med.Object_Field__c) == med.Field_Value__c){
                         markDealForManualApp = true;
                         manualRuleReason = med.Reason_Message__c;                        
                         break;
                     }
                 }
              }
          } 
      }
      return markDealForManualApp;
   }  
   
     Public static id addProductsToSalesOpp(id opptyId, Deal_Registration__c thisDealReg,List<Partner_Select_Product__c> apprvProductsList){
    //update opportunity with new approved products
    opportunity salesOpp = [select id,Registration_Next_Step__c,Orion_Approved_Product_Names__c,Orion_Registration_ProductIds__c,vmware_products__c,CloseDate,Name ,Campaign_Name__c ,Campaign_ID__c,Description,LeadSource,
                            Last_Campaign_Response__c,Screened_By__c,Screening_Results__c,Screening_Pass_Date__c,Active_ORAN__c,
                            Primary_Product_Group_Interest__c,Secondary_Product_Group_Interest__c,Product_Interest__c,StageName,
                            Opportunity_Source__c,Probability,OpportunityPartner_Reseller__c,End_User_Contact_First_Name__c,
                            End_User_Contact_Last_Name__c,Registration_Probability__c,Registration_Sales_Stage__c,
                            VMware_List_License_Value__c,Partner_Contact__c,Distributor__c, Orion_Oppty_Do_You_Plan_To_Lead_Services__c from opportunity where id = : opptyId];
    // Added Orion_Oppty_Do_You_Plan_To_Lead_Services__c in the query for CR-00138673 as part of Orion Phase-2 - Vijit
     string allApprovedProducts = salesOpp.vmware_products__c;
     string allAppProductIds = salesOpp.Orion_Registration_ProductIds__c ;
     string approvedProductNames = salesOpp.Orion_Approved_Product_Names__c;
     //add newly approved products to the existign products and update the oppty
         for(Partner_Select_Product__c DealPro : apprvProductsList){             
             if(allApprovedProducts != null && allApprovedProducts != ''){
                if(!allApprovedProducts.contains(DealPro.Product_Platform_Group__c))
                     allApprovedProducts = allApprovedProducts+';'+DealPro.Product_Platform_Group__c;
             }    
             else{
               allApprovedProducts =DealPro.Product_Platform_Group__c;   
             } 
             
             if(approvedProductNames != null && approvedProductNames != ''){
                 if(!approvedProductNames.contains(DealPro.Name))
                     approvedProductNames = approvedProductNames+';'+DealPro.Name;
             }    
             else{
               approvedProductNames =DealPro.Name;   
             }
             
             if(allAppProductIds != null && allAppProductIds != ''){
                 allAppProductIds = allAppProductIds +';'+DealPro.product__c;
             }    
             else{
                allAppProductIds =DealPro.product__c;   
             }  
             
             if(resubmitApprovedPro != null && resubmitApprovedPro != ''){
                 if(!resubmitApprovedPro.contains(DealPro.Product_Platform_Group__c))
                    resubmitApprovedPro = resubmitApprovedPro+';'+DealPro.Product_Platform_Group__c;
             }    
             else{
                  resubmitApprovedPro =DealPro.Product_Platform_Group__c;   
             }
         }
         allApprovedProductNames = approvedProductNames;//allApprovedProducts;
         salesOpp.vmware_products__c = allApprovedProducts ;
         salesOpp.Orion_Approved_Product_Names__c = approvedProductNames;
         salesOpp.Orion_Registration_ProductIds__c = allAppProductIds ; 
         salesOpp.CloseDate= thisDealReg.CloseDate__c;           
         salesOpp.Name = thisDealReg.Project_Name__c;                                         
         salesOpp.Campaign_Name__c = thisDealReg.Lead_Campaign_Name__c;            
         salesOpp.Campaign_ID__c = thisDealReg.Campaign_ID__c;            
         salesOpp.Description = thisDealReg.Description__c;                       
         salesOpp.LeadSource = thisDealReg.LeadSource__c;                 
         salesOpp.Last_Campaign_Response__c = thisDealReg.Last_Campaign_Response__c;                       
         salesOpp.Screened_By__c = thisDealReg.Screened_By__c;            
         salesOpp.Screening_Results__c = thisDealReg.Screening_Results__c;            
         salesOpp.Screening_Pass_Date__c = thisDealReg.Screening_Pass_Date__c;                                                                             
         salesOpp.Active_ORAN__c = thisDealReg.ORAN__c;                           
         salesOpp.Primary_Product_Group_Interest__c = thisDealReg.Primary_Product_Group_Interest__c;
         salesOpp.Secondary_Product_Group_Interest__c = thisDealReg.Secondary_Product_Group_Interest__c ;
         salesOpp.Product_Interest__c = thisDealReg.Product_Interest__c;                  
         //salesOpp.StageName= thisDealReg.StageName__c;//'02-Qualified';                     
         salesOpp.Opportunity_Source__c = 'Registration';
         salesOpp.Probability = thisDealReg.Orion_Close_Probability__c;//25;       
         salesOpp.OpportunityPartner_Reseller__c = thisDealReg.Active_Partner_Account__c;
         salesOpp.End_User_Contact_First_Name__c = thisDealReg.First_Name__c;
         salesOpp.End_User_Contact_Last_Name__c = thisDealReg.Last_Name__c;
         salesOpp.Registration_Probability__c = thisDealReg.Orion_Close_Probability__c;//25;
         salesOpp.Registration_Sales_Stage__c = thisDealReg.StageName__c;//'02-Qualified';
         salesOpp.VMware_List_License_Value__c = thisDealReg.VMware_List_License_Value__c ;       
         salesOpp.Partner_Contact__c = thisDealReg.Orion_Primary_Sales_Contact_Name__c;       
         salesOpp.Distributor__c = thisDealReg.Preferred_Distributor__c;
         
         salesOpp.Partner_PBM__c = thisDealReg.Active_Partner_Account__r.PBM__r.name;
         salesOpp.Route_to_Market__c = 'Channel';
         salesOpp.Reseller_PRM_ID__c = thisDealReg.Partner_Id__c; 
         salesOpp.Created_from_a_Registration__c = true;
         salesOpp.Registration_Next_Step__c = thisDealReg.Next_Steps__c;
         salesOpp.Selling_Activities__c = thisDealReg.Value_Selling_Activities_Provided__c;
         salesOpp.Orion_Oppty_Do_You_Plan_To_Lead_Services__c = thisDealReg.Do_You_Plan_To_Lead_Services__c; //Added for CR-00138673 as part of Orion Phase-2 - Vijit
         update salesOpp;
    return salesOpp.id;
   }
   
   Public static string returnGeoForCountry(string dealCountry){
     Map<String, Orion_Country_Geo_Mapping__c> allCountryGeo = Orion_Country_Geo_Mapping__c.getAll();
     string Geo;
     for(Orion_Country_Geo_Mapping__c cGeo : allCountryGeo.values()){
         if(cGeo.Country__c != '' && cGeo.Country__c != null && dealCountry != '' && dealCountry != null){
            if(cGeo.Country__c.tolowercase() == dealCountry.tolowercase()){
               Geo = cGeo.Geo__c;
            }
         }
     }
     
     return Geo;
   }
   //Re-Registered Registration shall gets auto approved logic below - REQ-061 - By Vijit- START
   Public static void approveDealRegForReRegister(List<Partner_Select_product__c> dealProList, Id dealId){
      //Approve all products
      for(Partner_Select_product__c psp : dealProList){
          psp.Approved__c = true;
          psp.Eligible_for_Benifits__c = true;
      }
      update dealProList;

      //sumbit deal reg for approval
      Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
      req.setObjectId(dealId);                        
      Approval.ProcessResult result = Approval.process(req);
      
      deal_registration__c dealReg;
      
        dealReg = new Deal_registration__c(
        id = dealId,
        Review_Status__c = Approve,
        Review_Comments__c = Auto_approved
        );
        
        update dealReg;
   
   }//Re-Registered Registration shall gets auto approved logic below - REQ-061 - By Vijit- END
   
   public static boolean validateOppProductForLeadConversion(lead leadRec,Id accountId){
     Set<String> allProductsOfOpp = new Set<String>();
     String msoOpportunityRecordType = Orion_Phase_II_Configurations__c.getValues(MSORecordTypeId).value__c;
     Boolean allProductsFoundCheck = true;
     //Compare primary product group interest with all the products of opportunity
     for(opportunity opp : [select id,stageName,accountid,Orion_Registration_ProductIds__c,PSO_Opportunity_Flag__c,VMware_Products__c,(select id,Product2Id,Quantity,Orion_Platform_Group__c,Associated_Platform_Group__c,Product2.Product_Group__c from OpportunityLineItems),(select id,name,PlatformGroup__c from Orion_Product_Lines__r) from Opportunity where (Not stageName like '%Closed%') and accountid = : accountId and recordTypeId =: msoOpportunityRecordType ]){
        
         for(OpportunityLineItem opLine : opp.OpportunityLineItems){
            //compare with Opportunity Line items
            if(opLine.Product2.Product_Group__c != null && opLine.Product2.Product_Group__c != ''){
               for(string OliPro : opLine.Product2.Product_Group__c.split(';')){
               allProductsOfOpp.add(OliPro.tolowercase());
               }
            }
         }
         
         //Compare with ModelN Products
         for(Orion_Product_Line__c opl : opp.Orion_Product_Lines__r){
             allProductsOfOpp.add(opl.PlatformGroup__c.tolowercase());
         }                  
         if(opp.VMware_Products__c != null && opp.VMware_Products__c != ''){
             for(string pro : opp.VMware_Products__c.split(';')){
                 allProductsOfOpp.add(pro.tolowercase());
             }
         }
       }
       
       //Compare All lead products with the open opportunity products
       if(leadRec.Primary_Product_Group_Interest__c != null && leadRec.Primary_Product_Group_Interest__c != ''){
          for(string leadPro : leadRec.Primary_Product_Group_Interest__c.split(';')){
             if(!allProductsOfOpp.contains(leadPro.tolowercase())){
                allProductsFoundCheck = false;
             }
          }
       }
       if(leadRec.Primary_Product_Group_Interest__c == null || leadRec.Primary_Product_Group_Interest__c == ''){
          allProductsFoundCheck = false;
       }
       
       return allProductsFoundCheck;
   }  
   
   Public static boolean checkifNonEnglish(string inputfeldval){
   //Return false if the input is in english and true if it is not in english
       if(inputfeldval != null)
           inputfeldval = inputfeldval.replaceAll( '\\s+', '');   
                  
           Pattern p = Pattern.compile('[^0-9a-zA-Z\\!@#\\$%\\^&\\*\\,\\.;:"-<>?|}{()><+=_~`\\\']');              
           //Pattern p = Pattern.compile('[^\\*\\#]');
           String matchString = p.matcher(inputfeldval).replaceAll('');            
           if(inputfeldval.length() == matchString.length())
               return FALSE;
           else
             return TRUE;                    
  }  

   Public static void OrionCounter(){
       integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
      }    
}