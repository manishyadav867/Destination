/************************************************************************************************************
    Apex ClassName - OpportunityUpdateValidationCheck
    Version - 1.0 
    Created Date - 05 May 2011
    Function - 
    Modification Log :
    -----------------------                                   
    * Developer                   Date                   Description
    * ----------                  -----                  ------------------------
    * Sneha Jain                11 May,2011             Class for executing the Validation Rule on Opportunity update[CR-4875]
    * Sneha Jain                17 May,2011             Modifying the class to put a check if the last product is deleted from the oppty
    * Alka                      07 June,2013              Modified for SDP Phase2.0 
    * Alka                     18-Jun-2013              Modified for SDP Phase2.0 CR-00044847
    * Accenture                4-Sept-2013                Modified for GSM Project
    *Avaneesh Singh             24-Oct-2013              CR-00042298 PLM 2.1
    *Swati Anshu                03-June-2015            Modified for CR-00128495- Close Oppty with no products by Sys Admin, Delegated Admin and ETM Ops Support
    * BHUMIKA UDANI             09-JULY-2015            BUG-00124870 - BY PASS PRODUCT VALIDATION FOR AW OPPORTUNITIES
    *Sandip                     05-August-2015          CR-00132447 - By pass Update opportunity validation during insertion 
    *safiya                     01-feb-2016             CR-00136849 -RE: Follow Up from 10/28 NSX NM Meeting(By pass validation)
    *Manish                     01-Aug-2016             BUG-00150133
    *Manish                     22-Aug-2016             Added for CR-00140850 
    ************************************************************************************************************/


    public class OpportunityUpdateValidationCheck {

        //Added flag to check if this class is executed before
        public static Boolean isExecuted = false;
        public static void checkValidationRule() {

            OpportunityUpdateCheck__c customOppty = OpportunityUpdateCheck__c.getInstance('OpportunityUpdateValidation');

            if (OpportunityUpdateValidationCheck.isExecuted) {
                //  return;
            }

            OpportunityUpdateValidationCheck.isExecuted = true;

            //Added by Jaypal for CR-00025413 Dated 5 Dec 2012    
            if (!recursive.allowBackendProcess) {
                // Added for CR-00128495- Close Oppty with no products by Sys Admin, Delegated Admin and ETM Ops Support- Start
                string profileId = userinfo.getProfileId();
                List < CloseOpptybyProfile__c > closedOpptyProfile = CloseOpptybyProfile__c.getall().values();
                Set < string > ProfileNamesBypass = new Set < string > ();
                for (CloseOpptybyProfile__c prfl: closedOpptyProfile) {
                    ProfileNamesBypass.add(prfl.Profile_Id__c);
                    system.debug('Inside Profile namebypass' + ProfileNamesBypass);
                }
                // Added for CR-00128495- Close Oppty with no products by Sys Admin, Delegated Admin and ETM Ops Support- End           

                
                if (customOppty.executeValidation__c == true) {
                    for (Opportunity oppty: (List < Opportunity > ) Trigger.New) {
                        
                        Opportunity Oldoppty = (Opportunity) trigger.oldMap.get(oppty.Id);
                        string salesprizmValue = oppty.Salesprism_Identifier__c;
                        // Modifying the class to put a check if the last product is deleted from the oppty : Accenture(Sneha) : CR-4875
                        if (!oppty.HasOpportunityLineItem && OpportunityLineItemManagement.isLineItemDelete) {
                            oppty.addError('You cannot delete the last product for the opportunity. To delete this product you must add another product first.');
                        }

                        boolean salesPrismCheck = false;
                        if ((Oldoppty.Buying_Program__c == null && oppty.Buying_Program__c != null) || (Oldoppty.Primary_Solution__c == null && oppty.Primary_Solution__c != null) && (oppty.Salesprism_Identifier__c != null && oppty.Salesprism_Identifier__c.containsIgnoreCase('SalesPrism'))) {
                            salesPrismCheck = true;
                        }
                        //Added Datacenter_Region__c to if condition for SDP Phase 2.0
                        //CR-00042298 Batch_PLM2DealRegLeadConversion.isPLMDealRegLeadConversion flag used to by pass below validation.
                         //Added for CR-00128495- Close Oppty with no products by Sys Admin, Delegated Admin and ETM Ops Support- Swati -- Start
                        //START - BUG-00124870 – 25.06.2015 – BHUMIKA UDANI - BY PASS PRODUCT VALIDATION FOR AW OPPORTUNITIES
                        // Added this condition in if clause && (!recursive.checkOpportunityUpdateValidation) for CR-00132447 
                        //Added condition for NSX user to by pass the validation while edidting NSX use case field-CR-00136849  
                        system.debug('oppty.RecordTypeId == recursive.VCloudOpportunityRecType'+oppty.RecordTypeId);
                        system.debug('oppty.HasOpportunityLineItem'+oppty.HasOpportunityLineItem);
                        system.debug('recursive.isUpdateOpportunity'+recursive.isUpdateOpportunity);
                        system.debug('OpportunityLineItemManagement.isLineItemDelete'+OpportunityLineItemManagement.isLineItemDelete);
                        system.debug('salesPrismCheck'+salesPrismCheck);
                        system.debug('Batch_PLM2DealRegLeadConversion.isPLMDealRegLeadConversion'+Batch_PLM2DealRegLeadConversion.isPLMDealRegLeadConversion);
                        system.debug('oppty.Opportunity_Source__c'+oppty.Opportunity_Source__c);

                        system.debug('AWStaticValues__c.getInstance(Source).Value__c'+AWStaticValues__c.getInstance('Source').Value__c);
                        system.debug('recursive.checkOpportunityUpdateValidation'+recursive.checkOpportunityUpdateValidation);
                        if (((!((oppty.NSX_Use_Case__c!= null && oppty.NSX_Use_Case__c != Oldoppty.NSX_Use_Case__c)) && oppty.RecordTypeId == recursive.ManagedSalesOpportunityRecType && !(ProfileNamesBypass.contains(profileId.substring(0, 15)))) || oppty.RecordTypeId == recursive.VCloudOpportunityRecType) 
                            && oppty.HasOpportunityLineItem == false && recursive.isUpdateOpportunity == false && OpportunityLineItemManagement.isLineItemDelete == false 
                            &&  !salesPrismCheck && !Batch_PLM2DealRegLeadConversion.isPLMDealRegLeadConversion && (string.isBlank(oppty.Opportunity_Source__c) || !(oppty.Opportunity_Source__c.equals(AWStaticValues__c.getInstance('Source').Value__c))) && (!recursive.checkOpportunityUpdateValidation)){
                        //Added for CR-00128495- Close Oppty with no products by Sys Admin, Delegated Admin and ETM Ops Support- Swati  -- End
                        //END - BUG-00124870 – 25.06.2015 – BHUMIKA UDANI - BY PASS PRODUCT VALIDATION FOR AW OPPORTUNITIES
                            if (!((oppty.Service_Type__c != null && oppty.Service_Type__c != Oldoppty.Service_Type__c) || (oppty.Monthly_commitment__c != null && oppty.Monthly_commitment__c != Oldoppty.Monthly_commitment__c) || (oppty.Opportunity_Type_picklist__c != null && oppty.Opportunity_Type_picklist__c != Oldoppty.Opportunity_Type_picklist__c) || (oppty.Duration_Months__c != null && oppty.Duration_Months__c != Oldoppty.Duration_Months__c) || (oppty.Subscription_Payment_type__c != null && oppty.Subscription_Payment_type__c != Oldoppty.Subscription_Payment_type__c) || (oppty.Data_load_service__c != null && oppty.Data_load_service__c != Oldoppty.Data_load_service__c) || (oppty.Datacenter_Region__c != null && oppty.Datacenter_Region__c != Oldoppty.Datacenter_Region__c) || GSM_BussinessIssueUpdatePrompterType.skipProdValidation // Changes made for GSM project
                            ||(oppty.TotalOppBI__c != null && oppty.TotalOppBI__c != Oldoppty.TotalOppBI__c) // Changes made for GSM project
                         //Start - Manish :: L2O Airforce Lead Conversion By pass   
                            || (oppty.Lead_ID__c != null) 
                            || (oppty.AW_Country__c != null && oppty.AW_Country__c != Oldoppty.AW_Country__c) 
                            || (oppty.AW_3rd_Party_Emails__c != null && oppty.AW_3rd_Party_Emails__c != Oldoppty.AW_3rd_Party_Emails__c) 
                            || (oppty.AW_Industry__c != null && oppty.AW_Industry__c != Oldoppty.AW_Industry__c) 
                            || (oppty.AW_Lead_Source__c != null && oppty.AW_Lead_Source__c != Oldoppty.AW_Lead_Source__c) 
                            || (oppty.AW_Notes_Comments__c != null && oppty.AW_Notes_Comments__c != Oldoppty.AW_Notes_Comments__c) 
                            || (oppty.AW_Representative_Email__c != null && oppty.AW_Representative_Email__c != Oldoppty.AW_Representative_Email__c) 
                            || (oppty.AW_Partner_Representative__c != null && oppty.AW_Partner_Representative__c != Oldoppty.AW_Partner_Representative__c) 
                            || (oppty.AW_Region__c != null && oppty.AW_Region__c != Oldoppty.AW_Region__c) 
                            || (oppty.AW_Registered__c != null && oppty.AW_Registered__c != Oldoppty.AW_Registered__c) 
                            || (oppty.AW_To_3rd_Party__c != null && oppty.AW_To_3rd_Party__c != Oldoppty.AW_To_3rd_Party__c) 
                            || (oppty.AW_Type__c != null && oppty.AW_Type__c != Oldoppty.AW_Type__c) 
                            || (oppty.Solution_of_interest__c != null && oppty.Solution_of_interest__c != Oldoppty.Solution_of_interest__c)
                        // Start - Manish :: Added for CR-00140850
                            || (oppty.Lead_Source_Most_Recent__c != null && oppty.Lead_Source_Most_Recent__c != Oldoppty.Lead_Source_Most_Recent__c)
                        // END - Manish :: Added for CR-00140850    
                        //END - Manish :: L2O Airforce Lead Conversion By pass   
                            ) ) {
                                oppty.addError('You must add a product to this opportunity!');
                            }
                        } 
                        //Added for SDP Phase2.0 - Start

                        Boolean vCHSProductFlag = false;
                        List < String > productList = new List < String > ();
                        if (oppty.HasOpportunityLineItem == true && oppty.Opportunity_Products__c != null) {
                            productList = (oppty.Opportunity_Products__c).split(';');
                            for (String prod: productList) {
                                if (prod.equalsIgnoreCase(System.Label.VCIS_Product)) {
                                    vCHSProductFlag = true;
                                    System.debug('***vCHSProductFlag***' + vCHSProductFlag);
                                    break;
                                }
                            }
                        }
                        //Added Datacenter_Region__c to if condition for SDP CR-00044847
                        if (vCHSProductFlag == true && (oppty.RecordTypeId == recursive.ManagedSalesOpportunityRecType || oppty.RecordTypeId == recursive.VCloudOpportunityRecType) && ((oppty.Service_Type__c == null && oppty.Service_Type__c != Oldoppty.Service_Type__c) || (oppty.Monthly_commitment__c == null && oppty.Monthly_commitment__c != Oldoppty.Monthly_commitment__c) || (oppty.Opportunity_Type_picklist__c == null && oppty.Opportunity_Type_picklist__c != Oldoppty.Opportunity_Type_picklist__c) || (oppty.Duration_Months__c == null && oppty.Duration_Months__c != Oldoppty.Duration_Months__c) || (oppty.Subscription_Payment_type__c == null && oppty.Subscription_Payment_type__c != Oldoppty.Subscription_Payment_type__c) || (oppty.Data_load_service__c == null && oppty.Data_load_service__c != Oldoppty.Data_load_service__c) || oppty.Datacenter_Region__c == null && oppty.Datacenter_Region__c != Oldoppty.Datacenter_Region__c) ) {
                            oppty.addError(System.Label.VCIS_Product_ErrorMessage);
                            productList.clear();
                        }
                        //Added for SDP Phase2.0 - End
                    }
                }
            }
            //Changes end for CR-00025413
        }
    }