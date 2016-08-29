// ************************Version Updates********************************************
//
// Updated Date     Updated By       Update Comments 
// 2/21/2012        Shweta Tiwari    Added Error handling code in catch block for CR-00008898
// ************************************************************************************
@isTest
private class COTASV_CPAM_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        COTAccountSchedulableValue cotAccSVal = new COTAccountSchedulableValue();
        ChannelPlanAlertMail channelPAM = new ChannelPlanAlertMail();
        SchedulableContext info ;
        
        try{
        		cotAccSVal.execute(info);
        		channelPAM.execute(info);
        }
        catch(Exception e){
            //Added Error handling code in catch block for CR-00008898
            CreateApexErrorLog.insertHandledExceptions(e, null, null, null, 'ApexClass', 'Account', 'COTASV_CPAM_Test');
            // End of code for CR-00008898                           
        }
                
    }
}