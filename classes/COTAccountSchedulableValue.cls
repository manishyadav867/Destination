/**
* Class Name: COTAccountSchedulableValue
* Author: Accenture
* Date: 10/25/2010
* Description: Class is reponsible to execute the ChannelOverlayTerritoryAccountValue 
* class in scheduled manner.
**/
global class COTAccountSchedulableValue implements Schedulable {

    global void execute(SchedulableContext info) {
        // execute the ChannelOverlayTerritoryAccountValue
       Database.executeBatch(new ChannelOverlayTerritoryAccountValue());
        LimitNotifySwitch__c logAutSwitch =LimitNotifySwitch__c.getOrgDefaults();//Custom setting to turn off  SalesforceLimitNotification
    if(logAutSwitch.Status__c)
    {
        SalesforceLimitNotification.UsageCalc();
    }
    }
}