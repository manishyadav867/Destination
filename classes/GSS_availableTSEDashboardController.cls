/**************************************************************************************
* Class Name   : GSS_availableTSEDashboardController
* Description  : Controller for the GSS available TSE Dashboard
* CR Number    : CR-00138493
* Created By   : Sneha Rathi, Accenture
* Created Date : 14-June-2016
************************Version Updates************************************************
 Date(DD/MM/YYYY)         Updated By       CR/Defect Number         Comments
 05-Aug-2013            Pabitra Pramanick  CR-00140411          Color-code TSE who are unavaliable and are not ready to take the Cases
************************Version Updates************************************************/
public class GSS_availableTSEDashboardController
{
    //public Date filterDate{get; set;}
    public case cdate{get;set;}
    public List<TSE_Details> lstApacTSEs{get; private set;}
    public List<TSE_Details> lstEmeaTSEs{get; private set;}
    public List<TSE_Details> lstNasaTSEs{get; private set;}
    private Static String apacRegion = 'APAC';
    private Static String emeaRegion = 'EMEA';
    private Static String nasaRegion = 'NASA';
    private Static String startTime = 'Start Time';
    private Static String endTime = 'End Time';
    
    public GSS_availableTSEDashboardController()
    {  cdate = new Case();
        cdate.Assigned_Function_Case_Escalation__c = Date.Today();
        fetchRegionAvailableTSE();
    }
    
    /*
        Name : fetchRegionAvailableTSE
        Description : Fetches the details for all the TSE who are available on selected date in NASA / APAC & EMEA region
        Params : None
        Returntype : Void
    */
    public void fetchRegionAvailableTSE()
    {
        //Start : CR-00140411:Creating set of event record type.
        Set<ID> eventRTiDSet = new Set<ID>();
        if(Record_Type_Settings__c.getInstance('GSS_EVENT_US') != null){
            eventRTiDSet.add(Record_Type_Settings__c.getInstance('GSS_EVENT_US').Record_Type_ID__c);
        }
        if(Record_Type_Settings__c.getInstance('GSS_EVENT') != null){
            eventRTiDSet.add(Record_Type_Settings__c.getInstance('GSS_EVENT').Record_Type_ID__c);
        }
        System.debug('eventRTiDSet:'+eventRTiDSet);
        //End : CR-00140411:Creating set of event record type.
        
        lstApacTSEs = new List<TSE_Details>();
        lstEmeaTSEs = new List<TSE_Details>();
        lstNasaTSEs = new List<TSE_Details>();
        //Build the start time & end time for selected date
        DateTime eventStartDate = DateTime.newInstanceGMT(cdate.Assigned_Function_Case_Escalation__c.year(), cdate.Assigned_Function_Case_Escalation__c.month(), cdate.Assigned_Function_Case_Escalation__c.day());
        DateTime eventendDate = eventStartDate.addDays(1);
        //fetch all the events starting the selected filter date with duration of 241 minutes and above and have the 'User under shift' flag is checked
        //CR-00140411:Adding filter on event record type.
        List<Event> lstEvent = [Select Owner.Id, Owner.Name, ShowAs, StartDateTime, EndDateTime from Event where recordtypeid in :eventRTiDSet and StartDateTime >= :eventStartDate and StartDateTime < :eventEndDate and DurationInMinutes >= 241 and OwnerId in (Select User__c from GSS_User_Data__c where User_under_Shift__c = true) order by StartDateTime];
        System.debug('lstEvent -- ' + lstEvent);
        //Fetch APAC Region Shift Timings
        DateTime apacStartTime = fetchShiftDateTime(apacRegion, startTime);
        DateTime apacEndTime = fetchShiftDateTime(apacRegion, endTime);
        System.debug('Apac timings ' + apacStartTime  + ' ' + apacEndTime);
        //Fetch EMEA Region Shift Timings
        DateTime emeaStartTime = fetchShiftDateTime(emeaRegion, startTime);
        DateTime emeaEndTime = fetchShiftDateTime(emeaRegion, endTime);
        System.debug('Emea timings ' + emeaStartTime  + ' ' + emeaEndTime);
        //Fetch NASA Region Shift Timings
        DateTime nasaStartTime = fetchShiftDateTime(nasaRegion, startTime);
        DateTime nasaEndTime = (fetchShiftDateTime(nasaRegion, endTime)).addDays(1);
        System.debug('Nasa timings ' + nasaStartTime  + ' ' + nasaEndTime);
        Set<Id> setUsers = new Set<Id>();
        for(Event evnt : lstEvent)
        {
            //fetch the time after 241 minutes of the event
            DateTime evntHalfTime = evnt.StartDateTime.addMinutes(241);
            System.debug('evnt.StartDateTime -- ' + evnt.StartDateTime);
            System.debug('evntHalfTime -- ' + evntHalfTime);
            System.debug('Boolean Operator -1- ' + (evnt.StartDateTime >= emeaStartTime));
            System.debug('Boolean Operator -2- ' + (evntHalfTime <= emeaEndTime));
            //Check if user is already added to any shift 
            if(!setUsers.contains(evnt.Owner.Id))
            {
                if(evnt.StartDateTime >= apacStartTime && evntHalfTime <= apacEndTime)
                {
                    setUsers.add(evnt.Owner.Id);
                    //CR-00140411:Passing one more variable.
                    lstApacTSEs.add(new TSE_Details(evnt.Owner.Id, evnt.Owner.Name, (evnt.ShowAs != 'OutOfOffice')));
                }
                else if(evnt.StartDateTime >= emeaStartTime && evntHalfTime <= emeaEndTime)
                {
                    setUsers.add(evnt.Owner.Id);
                    //CR-00140411:Passing one more variable.
                    lstEmeaTSEs.add(new TSE_Details(evnt.Owner.Id, evnt.Owner.Name, (evnt.ShowAs != 'OutOfOffice')));
                    System.debug('lstEmeaTSEs -- ' + lstEmeaTSEs);
                }
                else if(evnt.StartDateTime >= nasaStartTime && evntHalfTime <= nasaEndTime)
                {
                    setUsers.add(evnt.Owner.Id);
                    //CR-00140411:Passing one more variable.
                    lstNasaTSEs.add(new TSE_Details(evnt.Owner.Id, evnt.Owner.Name, (evnt.ShowAs != 'OutOfOffice')));
                }
            }
        }       
    }
    
    /*
        Name : fetchShiftDateTime
        Description : Builds the regions start and end time based on the custom setting data
        Params : @String, @String
        Return type : Void
    */
    public DateTime fetchShiftDateTime(String region, String tm)
    {
        GSS_Region_Shift_Timings__c shiftDetails = GSS_Region_Shift_Timings__c.getInstance(region);
        DateTime shiftTime;
        if(tm == startTime)
        {
            List<String> startTimeData = shiftDetails.Start_Time__c.split(':');
            shiftTime = DateTime.newInstanceGmt(cdate.Assigned_Function_Case_Escalation__c.year(), cdate.Assigned_Function_Case_Escalation__c.month(), cdate.Assigned_Function_Case_Escalation__c.day(), Integer.valueOf(startTimeData[0]), Integer.valueOf(startTimeData[1]), 00);
        }
        else if(tm == endTime)
        {
            List<String> endTimeData = shiftDetails.End_Time__c.split(':');
            shiftTime = DateTime.newInstanceGmt(cdate.Assigned_Function_Case_Escalation__c.year(), cdate.Assigned_Function_Case_Escalation__c.month(), cdate.Assigned_Function_Case_Escalation__c.day(), Integer.valueOf(endTimeData[0]), Integer.valueOf(endTimeData[1]), 00);
        }
        return shiftTime;
    }
    
    //Wrapper class to hold the TSE data
    class TSE_Details
    {
        public Id userId{get; private set;}
        public String userName{get; private set;}
        //CR-00140411:Added below member variable
        public boolean available{get; private set;}
        
        public TSE_Details(Id usrId, String usrNm, boolean usrAvl)
        {
            userId = usrId;
            userName = usrNm;
            //CR-00140411:Initializing the variable.
            available = usrAvl;
        }
    }
}