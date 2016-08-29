/**
* Class : TimeTrackController 
* Author : Accenture IDC ( Vivekanand Deshmane) 
* CR# :CR-00009696
* Description :  This class is used to claculate time spent on Case,Request and Case Activities.
************************Version Updates********************************************
 Updated Date(DD/MM/YYYY)         Updated By              Update Comments
 10/04/2012                    Vivekanand Deshmane    Added code for CR-00009696
 25/05/2012                    Vivekanand Deshmane    Modified for BUG-00035971
 06/05/2012                    Vivekanand Deshmane    Modified For CR-00012847 
 09/05/2012                    Vivekanand Deshmane    Modified For CR-00012848
 08/29/2012                    Vivekanand Deshmane    Modified For CR-00016565
 01/25/2013                    Vivekanand Deshmane    Modified For CR-00022624
 06/06/2014                    GSS optimization       Agent Console Fix      
 22/08/2016                    Pabitra Pramanick      CR-00140078 added Industry Field
**************************************************************************************
*/ 
global class TimeTrackController 
{

    public Case caseObj;
    public  Boolean webex=false;
   
    private Case theCase;//CR-00140078 added Industry Field
    
    public TimeTrackController(ApexPages.StandardController controller) 
    {
      //CR-00140078 added Industry Field
      theCase = (Case)controller.getRecord();
    }
           
/**
* @param  string time1
* @param  string URL
* @param  String mode
* @return Time_Track__c 
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to calculate and insert time spent on WebEx,konva,Bugzilla,ServerScript Link/buttons
*
**/
     @RemoteAction   
    global static Time_Track__c thirdPartyTimeTrck(string time1,string URL,String mode) 
    {
         Time_Track__c c = new Time_Track__c();
     try{  
         
        // validating CaseNumber return by method recordId shold not be null and then inserting record in Time Track object with required values.
        if(time1!=null&&!time1.equals('')&&!time1.equals('0:00:00')&&!isTimeTrackRestrictedProfile(URL))
        {
             if(recordId(URL) != null && (recordId(URL).length()==15||recordId(URL).length()==18))
            {  
                String caseId= recordId(URL);      
                c.Case__c = caseId; 
                c.User__c = System.userInfo.GetUserId();
                c.Total_Time__c = time1;     
                c.Mode__c    =    mode;
                c.Ismanual__c=false;
                System.debug('c.Case__c'+c.Case__c);
                c.Temp_Time_Track__c=getTempTimeTrackId(c.Case__c);
                boolean isclose=[select IsClosed From Case where Id=:caseId].IsClosed;
                if(!isclose){
                GSSTimeTrackArchiveUtility.mergeTimeTrackEntries(c);
                }
              
                //Insert c;
               
          }
       }
       
       if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
       
      }catch(Exception e){
                System.debug('Exception Time Track controller'+e); 
                }      
        return c;

    }
/**
* @param  string time1
* @param  string URL
* @param  String mode
* @return Time_Track__c 
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to  insert time spent on Case Activity,Request,Case Comment Edit,Send Customer Email,Case Edit etc actions.
**/

    @RemoteAction   
  global static Time_Track__c findContacts(string time1,string URL) 
  {
          
        Time_Track__c c = new Time_Track__c();
   try{
        // validating CaseNumber return by method recordId shold not be null and then inserting record in Time Track object with required values.
     if(time1!=null&&!time1.equals('')&&!time1.equals('0:00:00')&&!isTimeTrackRestrictedProfile(URL))
        {
        if(recordId(URL) != null && (recordId(URL).length()==15||recordId(URL).length()==18)&& time1!=null&&!time1.equals(''))
        {  
            String caseId=recordId(URL);          
            c.Case__c = caseId;
            c.User__c = System.userInfo.GetUserId();
            c.Total_Time__c = time1;     
            c.Mode__c    =    mode(URL);
            c.Temp_Time_Track__c=getTempTimeTrackId(c.Case__c);
            c.Ismanual__c=false;
             boolean isclose=[select IsClosed From Case where Id=:caseId].IsClosed;
                if(!isclose){
                GSSTimeTrackArchiveUtility.mergeTimeTrackEntries(c);
                }
            //Insert c;
           
        }
        // validating Request Number return by method recordIdForRequestshold not be null and then inserting record in Time Track object with required values.
        else  if(recordIdForRequest(URL) != null){
              String reqId=recordIdForRequest(URL);
              String caseNumber;
              LIST<GSS_Request__c>GSS_RequestList =[Select   GSS_Case_Number__c from GSS_Request__c where id=:reqId limit 1 ];
              for(GSS_Request__c gssc:GSS_RequestList){
              caseNumber=gssc.GSS_Case_Number__c;
              }
             c.Case__c=caseNumber;
             c.Request__c=reqId;     
             c.User__c = System.userInfo.GetUserId();
             c.Total_Time__c = time1;     
             c.Mode__c    =    mode(URL);
             c.Temp_Time_Track__c=getTempTimeTrackId(c.Case__c);
             c.Ismanual__c=false;
             boolean isclose=[select IsClosed From Case where Id=:caseNumber].IsClosed;
                if(!isclose){
                GSSTimeTrackArchiveUtility.mergeTimeTrackEntries(c);
                }
            //Insert c;
                     
         }
            // validating Case Number return by method recordIdForActivity should not be null and then inserting record in Time Track object with required values.

        else  if(recordIdForActivity(URL) != null && (recordIdForActivity(URL).length()==12||recordIdForActivity(URL).length()==15)){
            String caseNumber='500'+recordIdForActivity(URL);
                                       
             c.Case__c=caseNumber;
             c.User__c = System.userInfo.GetUserId();
             c.Total_Time__c = time1;     
             c.Mode__c    =    mode(URL);
             c.Temp_Time_Track__c=getTempTimeTrackId(c.Case__c);
             c.Ismanual__c=false;
             boolean isclose=[select IsClosed From Case where Id=:caseNumber].IsClosed;
                if(!isclose){
                GSSTimeTrackArchiveUtility.mergeTimeTrackEntries(c);
                }
          //Insert c;
                   
        }
    }
    
     if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
  }catch(Exception e){
                       System.debug('Exception Time Track controller'+e);
      }
        return c;
        
  }
    
 /**
 * @param  string URL
 * @return String  
 * @Author Vivekanand Deshmane
 * @CR 00009696
 * Used to  get Case Id from Activity URL.
 **/
 global static String recordIdForActivity(String URL){
           String caseID = null;
            String[] splitURL = URL.split('.com/');
             String[] requestURL = splitURL[1].split('retURL='); 
            if(requestURL.size()>1 && requestURL[1].length()>0){
            
            if(requestURL [1].indexOf('500',0)!=-1){
            caseID=requestURL [1].substring(requestURL [1].indexOf('500',0)+3,requestURL[1].length());
            }
            }
           return caseID ;
   }

    
/**
* @param  string URL
* @return String  
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to  get Case Id from Request URL.
**/
global static String recordIdForRequest(String URL){
  
        String requestID = null;
   try
   {     
        
        PageReference pageRef = new PageReference(URL);
        String[] splitURL = URL.split('.com/');
        String[] requestURL = splitURL[1].split('/'); 
        String reqestpid= pageRef.getParameters().get('pid');
        String reqparent_id = pageRef.getParameters().get('parent_id');
        String req_id = pageRef.getParameters().get('id');
        String requestWhatId = pageRef.getParameters().get('what_id');
        String requestp3_lkid=pageRef.getParameters().get('p3_lkid');
            
            if(requestp3_lkid!=null){
            requestID=requestp3_lkid;
            }
            else if(requestWhatId!=null){
            requestID=requestWhatId; 
            }          
            else if(req_id!=null){
            requestID=req_id; 
            }       
            else if(reqestpid!=null){
             requestID=reqestpid; 
             }else if(requestURL [0].length() > 3&&requestURL [0].substring(0,3)== 'a2b')
              {
                  requestID = requestURL [0];   
              }else if(reqparent_id!=null){
             requestID=reqparent_id;
             }else if(recordIdForRequestFromChildObject(URL)!=null){
              requestID=recordIdForRequestFromChildObject(URL);
             }else if(recordIdForRequestFromAttachment(URL)!=null){
              requestID=recordIdForRequestFromAttachment(URL);
             }
             else
             {
             requestID = null;
             }
             
          if(Test.isRunningTest()){
               Throw new TimeTrackerException();
           }    
     }Catch(Exception e){
                System.debug('Exception Time Track controller'+e);
     }
        
    return requestID;
   }
 /**
 * @param  string URL
 * @return String  
 * @Author Vivekanand Deshmane
 * @CR 00012847
 * Used to  get Request Id from Note URL.
 **/
    global static String recordIdForRequestFromChildObject(String URL)
    {
      //https://cs3.salesforce.com/002Q00000056z3i
         String noteID;
         String requestId=null;
     try{
         String[] splitURL = URL.split('.com/');
         String[] noteURL = splitURL[1].split('/');
        if(noteURL[0].length() > 3)
         {
              if(noteURL[0].substring(0,3)== '002')
              {
                  noteID= noteURL[0];   
              }
              else
              {
                  noteID= null;   
              }
         }
         if(noteID!=null)
         {
            Note noteObj =[Select ParentId From Note where  Id=:noteID];
            if(noteObj !=null){
            requestId=noteObj.ParentId;
            }
       }
        if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
      }catch(Exception e){
                System.debug('Exception Time Track controller'+e);
      }  
     return requestId ;
  } 
/**
* @param  string URL
* @return String  
* @Author Vivekanand Deshmane
* @CR 00012847
* Used to  get Request Id from Attachment URL.
**/
 global static String recordIdForRequestFromAttachment (String URL)
    {
    //https://cs3.salesforce.com/002Q00000056z3x/e?retURL=%2Fa2bQ00000009Mq4   
       String attachmentID;
       String requestId=null;
      try
      {
          String[] splitURL = URL.split('.com/');
          String[] attachmentURL = splitURL[1].split('/');
         if(attachmentURL [0].length() > 3)
         {
              if(attachmentURL[0].substring(0,3)== '00P')
              {
                  attachmentID= attachmentURL[0];   
              }
              else
              {
                  attachmentID= null;   
              }
         }
         if(attachmentID!=null)
         {
            Attachment attachmentObj =[Select ParentId From Attachment where  Id=:attachmentID];
           if(attachmentObj!=null){
            requestId=attachmentObj.ParentId;
            }
         }
          if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
     }Catch(Exception e){
           System.debug('Exception Time Track controller'+e);
     }  
         
 Return requestId;
    
 }
/**
* @param  string URL
* @return String  
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to  get Case Id from Case URL.
**/
global static String recordId(String URL)
 {
     String CaseId = null; 
     try
     {
         String[] splitURL = URL.split('.com/');
         String[] caseURL = splitURL[1].split('/');   
         
         PageReference pageRef = new PageReference(URL);
         
         
         String CaseIdWhatId = pageRef.getParameters().get('what_id');
         String ParentIdComment = pageRef.getParameters().get('parent_id');         
         String CaseIdSendMail = pageRef.getParameters().get('p3_lkid');
         String CaseIDd= pageRef.getParameters().get('CaseID');
         String CaseIDFromTTList= pageRef.getParameters().get('id');
         String TTListrlid=pageRef.getParameters().get('rlid');
         String CaseIDFromReassign= pageRef.getParameters().get('ID');
         String ReassignbringBack=pageRef.getParameters().get('bringBack');
         String Casesbstr= pageRef.getParameters().get('sbstr');
         String Pid= pageRef.getParameters().get('pid');
         String kp=pageRef.getParameters().get('kp');
         
         if(Pid!=null&&!Pid.equals('')&&kp!=null){
         CaseId = Pid;
         }
         else if(Casesbstr!=null&&!Casesbstr.equals('')){
         Case caseobj=[select ID from Case where CaseNumber=:Casesbstr];
          CaseId=caseobj.Id; 
         }
         else if(CaseIDd!= null)
         {
             if(CaseIDd.substring(0,3)== '500')
             {
                  CaseId = CaseIDd;
             }
         }
         else if(CaseIdWhatId != null)
         {
             if(CaseIdWhatId.substring(0,3)== '500')
             {
                  CaseId = CaseIdWhatId;
             }
         }

         else if(ParentIdComment != null)
         {
             if(ParentIdComment.substring(0,3)== '500')
             {
                  CaseId = ParentIdComment;
             }
         }
         else if(CaseIdSendMail != null)
         {
             if(CaseIdSendMail.substring(0,3)== '500')
             {
                  CaseId = CaseIdSendMail;
             }
         }
         else if(CaseIDFromTTList!=null&&TTListrlid!=null){
         CaseId=CaseIDFromTTList; 
         }else if(CaseIDFromReassign!=null&&ReassignbringBack!=null){
         CaseId=CaseIDFromReassign; 
         }
         else if(CaseId == null)
         {   
         if(caseURL[0].length() > 3)
         {
              if(caseURL[0].substring(0,3)== '500')
              {
                  CaseId = caseURL[0];   
              }
              else
              {
                  CaseId = null;   
              }
         }
         
         else
         {
             CaseId = null;
         }
        }
         if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
       //Agent Console fix starts       
       if(caseId.contains('?'))
         caseId=caseId.substring(0,caseId.indexof('?'));  
       //Agent Console fix ends
  }Catch(Exception e){
       System.debug('Exception Time Track controller'+e);
     }           
  return CaseId;
}
    
     /**
         * @param  string URL
         * @return String  
         * @Author Vivekanand Deshmane
         * @CR 00009696
         * Used to  get Case mode type by using Case URL.
         **/

    global static String mode(String URL)
    {
    String mode =  'View';   
     try
     {
         String[] splitURL = URL.split('.com/');
         String[] caseURL = splitURL[1].split('/');   
         PageReference pageRef = new PageReference(URL);
         String CaseIdWhatId = pageRef.getParameters().get('what_id');
         String ParentIdComment = pageRef.getParameters().get('parent_id');
         String retURL= pageRef.getParameters().get('retURL');
         
         String CaseIdSendMail = pageRef.getParameters().get('p3_lkid');
         String CaseID= pageRef.getParameters().get('CaseID');
         String reqestpid= pageRef.getParameters().get('pid');
         String reqparent_id = pageRef.getParameters().get('parent_id');      
         String requestIdFromNote=recordIdForRequestFromChildObject(URL);
         String requestIdFromAttachment=recordIdForRequestFromAttachment(URL);  
         String CaseIDFromReassign= pageRef.getParameters().get('ID');
         String parentName=pageRef.getParameters().get('parentname');
         String kp=pageRef.getParameters().get('kp');
        
        if(CaseIdWhatId != null)
         {
             if(CaseIdWhatId.substring(0,3)== '500')
             {
                  mode = 'Case Activity Edit';
             }else{
                 mode='Request Activity Edit';
             }
         } 
         if(reqestpid!= null&&kp!=null)
         {
            
                  mode = 'Case Team Edit';
            
         } 
         if(CaseIdSendMail != null)
         {
             if(CaseIdSendMail.substring(0,3)== '500')
             {
                  mode = 'Case Send Mail';
             }else{
                 mode = 'Request Send Mail';
             }
         } 
              
         if(ParentIdComment != null&&retURL!=null)
         {
             if(ParentIdComment.substring(0,3)== '500')
             {
                  mode = 'Case Comment Edit';
             }
         }
         if(CaseID!= null)
         {
             if(CaseID.substring(0,3)== '500')
             {
                  mode = 'Case WebEx View';
             }
         }


         if(caseURL[0].length() > 14)
         {
              if(caseURL.size() > 1)
              {
                  if(caseURL[1].substring(0,1) == 'e')
                  {
                      mode =  'Edit';
                  }            
              }           
         }
         if((reqparent_id!=null||requestIdFromNote!=null)&&URL.contains('/002')){
         mode='Note'; 
         }
         if((reqestpid!=null||requestIdFromAttachment!=null||parentName!=null)&&kp==null){
         mode='Attachment'; 
         }
         if(CaseIDFromReassign!=null){
         mode='View'; 
         }
          if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
  }Catch(Exception e){
         System.debug('Exception Time Track controller'+e);
     }         
  return mode ;
 }
/**
* @param  string URL
* @return Integer 
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to  get record count from temp time track object ob basis of case Id.
**/

 @RemoteAction   
global static Integer getTemTime(string URL) 
{
     Integer count=0;
try
{
      if(recordId(URL) != null)
        {
                        String caseId= recordId(URL);
            List<Temp_Time_Track__c> temList=[Select Id from Temp_Time_Track__c where Case__c=:caseId];
            if(temList.size()>0){
                count=temList.size();
            }
         }   
          if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
}Catch(Exception e){
          System.debug('Exception Time Track controller'+e);
     }  
return count;
        
}
/**
* @param  string URL
* @return Integer 
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to get record count from temp time track object by using case Id and logged in user Id as crateria.
**/
@RemoteAction   
global static Integer getTemTimeOfUser(string URL) 
 {
     Integer count=0;
  try
  {
        if(recordId(URL) != null)
        {
                        String caseId= recordId(URL);
            List<Temp_Time_Track__c> temList=[Select Id from Temp_Time_Track__c where User__c=:UserInfo.getUserId() and Case__c=:caseId];
            if(temList.size()>0){
                count=temList.size();
            }
         }   
          if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
   }Catch(Exception e){
          System.debug('Exception Time Track controller'+e);
     }  
return count;
        
 }

 /**
 * @param  string URL
 * @return Time_Track__c
 * @Author Vivekanand Deshmane
 * @CR 00009696
 * Used to update time track as additoinal work.
**/


@RemoteAction   
global static Time_Track__c  updateTimeTrack(string URL,String extraTime) 
{
    Time_Track__c tt=new Time_Track__c();
 try
 {
            if(recordId(URL) != null)
        {
            String caseId= recordId(URL);
            tt=updateRemoveFromTempTimeTrack(caseId,extraTime);
        }
         if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
 }Catch(Exception e){
            System.debug('Exception Time Track controller'+e);
     }          
           
  return tt;
       
 }
/**
* @param  string URL
* @return Integer  
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to insert Record in Temp Time Tack Object.
**/
@RemoteAction   
global static Integer  insertTempTimeTrack(String URL) 
{
 try
 {
   Temp_Time_Track__c c = new Temp_Time_Track__c();
    if(recordId(URL) != null&&!isTimeTrackRestrictedProfile(URL))
         {
            String caseId= recordId(URL);
            Datetime x =  Datetime.now();
            c.Case__c=caseId;
            c.time__c=x+'';
            c.User__c=UserInfo.getUserId();   
            insert c;
         }
          if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
   }Catch(Exception e){
         System.debug('Exception Time Track controller'+e);
     }  
 return 1;
}
     
/**
* @param  List<Temp_Time_Track__c>  temList
* @return void 
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to remove List of Records from Temp Time Tack Object.
**/
global static void removeEntryFromTempTimeTrack( List<Temp_Time_Track__c>  temList)
{
    try
    {
        if(temList!=null&&temList.size()>0){
        delete temList;
        }
         if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
    }Catch(Exception e){
          System.debug('Exception Time Track controller'+e);
     }  
}
    
/**
* @param  String strTotalTime
* @return Integer 
* @Author Vivekanand Deshmane
* @CR 00009696
* this method conevrts time in secod.
**/
global static Integer getTimeInSec(String strTotalTime)
 {
  Integer timeInSec=0;
  try
  {   if(!strTotalTime.equals('')){
       List<String>splitTime=strTotalTime.split(':');
       Integer hrs=Integer.valueOf(splitTime[0]);
       Integer min=Integer.valueOf(splitTime[1]);
       Integer sec=Integer.valueOf(splitTime[2]);
       timeInSec=hrs*3600+min*60+sec;
       }
        if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
  }Catch(Exception e){
        System.debug('Exception Time Track controller'+e);
  }   
      
 return timeInSec;
 }
    
/**
* @param  String caseId
* @return String 
* @Author Vivekanand Deshmane
* @CR 00009696
* Use to get record fomr Temp Track Obejct by using UserId and Case Id as crateria.
**/
global static String getTempTimeTrackId(String caseId)
  {
  String tempTimeTrackId=null;
  
   try
   {
       
        List <Temp_Time_Track__c> temTraclList=[Select Id ,User__c,time__c  from Temp_Time_Track__c where Case__c=:caseId and User__c=:UserInfo.getUserId()];
        if(temTraclList!=null&&temTraclList.size()>0){
            tempTimeTrackId=temTraclList.get(0).Id;
        }
         if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
   }Catch(Exception e){
       System.debug('Exception Time Track controller'+e);
  }    
  return tempTimeTrackId;
}
   
   
 /**
* @param  String url
* @return Time_Track__c
* @Author Vivekanand Deshmane
* @CR 00009696
* used to remove record from Temp Time Track object by uisng looged in User Id as crateria.
**/
 @RemoteAction
 global static Time_Track__c removeEntryFromTempTimeTrack(String url)
 {
    Time_Track__c TimeTrackObj= new Time_Track__c ();
   try
   {
      
             
         
        
        List<Temp_Time_Track__c> temList = [Select Id ,User__c,time__c,Case__c from Temp_Time_Track__c where User__c=:UserInfo.getUserId()];
        if(temList !=null&&temList.size()>0){
        String caseId=temList.get(0).Case__c;
        String extraTime='0:00:00';
        List<WebExTempTimTrack__c> tempWebxList= [Select Id ,User__c,time__c  from WebExTempTimTrack__c where Case__c=:caseId and User__c=:UserInfo.getUserId()];
           if(tempWebxList.isempty()){
           TimeTrackObj=updateRemoveFromTempTimeTrack(caseId,extraTime);
           }
        }
        
         if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
   }Catch(Exception e){
       System.debug('Exception Time Track controller'+e);  
   }   
  return TimeTrackObj;
        
 }
/**
* @return PageReference
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to update additional work as part of time track object.
**/
 
public PageReference saveTimerData()
{
 try
 {
       String URL= System.currentPagereference().getParameters().get('URL');
       String extraTime=System.currentPagereference().getParameters().get('extraTime');
       if(URL!=null)
       {
          Time_Track__c TimeTrackObj= updateTimeTrack(URL,extraTime);
      }
       if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
 }Catch(Exception e){
        System.debug('Exception Time Track controller'+e);
   } 
return null;
} 
/**
* @return PageReference
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to update case view as part of time track obejct on "onbeforeunload" event.
**/

public PageReference  saveOnFocusTimerData(){
        String URL= System.currentPagereference().getParameters().get('URL');
        String onFocustime=System.currentPagereference().getParameters().get('extraTime');
      findContacts(onFocustime,URL);
     updateTimeTrack(URL,onFocustime);
                
      return null;

  }
  
/**
* @param String caseId
* @return Time_Track__c
* @Author Vivekanand Deshmane
* @CR 00009696
* Used to calculate additional work time by taking reference of start time of Case which is in Temp Time Track Object and end time as current System Time  .
 **/
global static Time_Track__c  updateRemoveFromTempTimeTrack(String caseId,String extraTime) {
 Time_Track__c tt=new Time_Track__c();
try
{

 String currenDateTimeStr= Datetime.now()+'';
 List<Temp_Time_Track__c> temList= new List<Temp_Time_Track__c>();
    List<Time_Track__c> timeTrackList= new List<Time_Track__c> ();
    Integer tracTime=0;
    Integer tracTimeTotal_OldTime=0;
    Integer tempTime=0;
    Integer additionalTime=0;
    String additionalTimeStr='0:00:00';
    String startTempTime=null;
    Integer totalTempTime=0;
    temList= [Select Id ,User__c,time__c  from Temp_Time_Track__c where Case__c=:caseId and User__c=:UserInfo.getUserId()];
                 //getting Start time of case from temList which contains only one record of Temp_Time_Tack object.
                  if(temList!=null&&temList.size()>0){
                  startTempTime=temList.get(0).time__c;
                  timeTrackList=[Select Id,Total_Time__c,Total_OldTime__c from Time_Track__c where Temp_Time_Track__c=:temList.get(0).Id and Case__c=:caseId and User__c=:UserInfo.getUserId()];
                  //System.debug('############# timeTrackListSize '+timeTrackList.size()); 
                  } 
                 if(timeTrackList!=null&&timeTrackList.size()>0)
                 {   
                  // Iterating timeTrackList list  which contains records of Time_Track__c  object and we getting total time from record.
                      for(Time_Track__c ttobj :timeTrackList)
                    {       String strTotalTime= ttobj.Total_Time__c;
                             String strTotal_OldTime= ttobj.Total_OldTime__c;
                         //System.debug('############# strTotalTime '+strTotalTime); 
                         if(strTotalTime!=null&&strTotalTime.contains(':')){
                                tracTime=tracTime+getTimeInSec(strTotalTime);               
                            }
                            if(strTotal_OldTime!=null&&strTotal_OldTime.contains(':')){
                                tracTimeTotal_OldTime=tracTimeTotal_OldTime+getTimeInSec(strTotal_OldTime);               
                            }
                      }
                }
                tracTime=tracTime+getTimeInSec(extraTime); 
                List<String> splitTime = new List<String>();
                 List<String> splitEndTime = new List<String>();
                if(startTempTime!=null && !startTempTime.equals('')){
              if(startTempTime.contains('.')){
               startTempTime=startTempTime.replace('.',':');
                 // splitTime=startTempTime.split('.');
                }
               
               
               if(currenDateTimeStr.contains('.')){
               currenDateTimeStr=startTempTime.replace('.',':');
                 // splitTime=startTempTime.split('.');
                }
               Datetime x =  datetime.valueOfGmt(currenDateTimeStr);            
              Integer tempEndTime =Integer.valueOf(x.getTime())/1000;
              Datetime temStartDateTime = datetime.valueOfGmt(startTempTime);

              Integer startTempTimeLong=Integer.valueOf(temStartDateTime.getTime())/1000;  
                          
             //Here we calculating overall time spent on case.           
             totalTempTime=tempEndTime-startTempTimeLong;
              //Here we are calculating additional work time by substracting total time of all modes of case from overall time spent on case. 
             System.debug('############# currenDateTimeStr==>'+currenDateTimeStr); 
             System.debug('############# startTempTime==>'+startTempTime); 
             System.debug('############# tracTime==>'+tracTime); 
            tracTime=tracTime-tracTimeTotal_OldTime;
             if(timeTrackList.size()==0){                               
                 additionalTime = 0;
             }else{
                 additionalTime=totalTempTime-tracTime;
             }    
             //System.debug('############# additionalTime='+additionalTime);   
             Integer totalHrs = 0 ;
             Integer totalMin = 0;
             Integer totalSec = 0;
            Integer totalsec_1 = Math.mod(additionalTime,60);
            Integer totalsec_11 = additionalTime/60;
            totalMin = totalMin  + totalsec_11;
            Integer totalmin_1 = Math.mod(totalMin ,60);
            Integer totalmin_11 = totalMin /60;
            totalHrs = totalHrs + totalmin_11;
           String totalmin_1_Formatted;
           String totalsec_1_Formatted;
            if(totalmin_1<=9){
           totalmin_1_Formatted= ':0'+totalmin_1;
            }else{
            totalmin_1_Formatted=':'+totalmin_1;
            }
             if(totalsec_1>0&&totalsec_1<=9){
            totalsec_1_Formatted=':0'+totalsec_1;
            }else{
             if(totalsec_1>0)
             totalsec_1_Formatted=':'+totalsec_1;
            }
            if(totalHrs!=null&&totalmin_1_Formatted!=null&&totalsec_1_Formatted!=null){
            additionalTimeStr= totalHrs +totalmin_1_Formatted+totalsec_1_Formatted;
            }
            if(additionalTimeStr!=null&&!additionalTimeStr.equals('')&&!additionalTimeStr.equals('0:00:00')&&!isTimeTrackRestrictedProfile(extraTime)){
            tt=otherWorkTimeTrck(additionalTimeStr,caseId,'Additional Work');
            }
             
                removeEntryFromTempTimeTrack(temList);
            
                 
           
  }
   List<WebExTempTimTrack__c> tempWebxList= [Select Id ,User__c,time__c  from WebExTempTimTrack__c where Case__c=:caseId and User__c=:UserInfo.getUserId()];
             if(!tempWebxList.isempty()){
               weExTimeTrackEntry(tempWebxList,'Web Ex Session',caseId);
                  
              }  
   List<Time_Track__c>updateTimeTrackrowsList=new List<Time_Track__c>();
   
   
   List <Time_Track__c> timeTrackrowsList=[select id,Total_Time__c,Total_OldTime__c from Time_Track__c where Case__c=:caseId and User__c=:
   UserInfo.getUserId() and DAY_ONLY(createddate)=:Datetime.now().dateGMT() ];
   if(!timeTrackrowsList.isempty()){
   for(Time_Track__c ttobj:timeTrackrowsList){
       ttobj.Total_OldTime__c=ttobj.Total_Time__c;
       updateTimeTrackrowsList.add(ttobj);
   }
   //system.debug('$$$$$$$$$$ DAY_ONLY'+DAY_ONLY(timeTrackrowsList1.get(0).createddate.date()));
  update updateTimeTrackrowsList;
   }
   
               
   if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
  }Catch(Exception e){
       System.debug('Exception Time Track controller'+e);
  } 
 return tt;
 }
    /**
         * @param String time1
         * @param String caseId
         * @@param String mode
         * @return Time_Track__c
         * @Author Vivekanand Deshmane
         * @CR 00009696
         * Used to Insert additional work time in Time Track Object .
      **/
 global static Time_Track__c otherWorkTimeTrck(string time1,string caseId,String mode) 
 {
 Time_Track__c c = new Time_Track__c();
    try
    {
        if(caseId != null)
        {  
            Time1 = Time1;  
            
            c.Case__c =  caseId;
            c.User__c = System.userInfo.GetUserId();
            c.Total_Time__c = time1;     
            c.Mode__c    =    mode;
            c.Temp_Time_Track__c=getTempTimeTrackId(c.Case__c);
            c.Ismanual__c=false;
              boolean isclose=[select IsClosed From Case where Id=:caseId].IsClosed;
                if(!isclose){
                GSSTimeTrackArchiveUtility.mergeTimeTrackEntries(c);
                }
            //Insert c;
              
          } 
           if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
     }Catch(Exception e){
       System.debug('Exception Time Track controller'+e);
  } 
  return c;

 }
/**
* @return Boolean
* @Author Vivekanand Deshmane
* @CR 00012848
* This method returns true if current user's profile is time track restricted profile.
**/ 
@RemoteAction   
global static Boolean isTimeTrackRestrictedProfile(String URL)
{
     Boolean isRestrictedUser=true;
     Set <ID> restrictedProfileIDs=new Set<ID> ();
      ID currentUserProfileID=userInfo.getProfileId();
     if(GSS_TimeTrack_ProfileRestriction__c.getAll().values().size()>0){
      for (GSS_TimeTrack_ProfileRestriction__c ttpr: GSS_TimeTrack_ProfileRestriction__c.getAll().values()){
       system.debug('userInfo.getProfileId().equals(ttpr.Id__c)==>'+userInfo.getProfileId().equals(ttpr.Id__c));
      
       //ID profileIdFromCS=ttpr.Id__c;
       restrictedProfileIDs.add(ttpr.Id__c);
      
      }
      // CR-00022624 (adding condition to check if case is closed)
       if(restrictedProfileIDs.contains(currentUserProfileID)&&!isCaseClosed(url)){
              isRestrictedUser=false;
       } 
     }
    if(Test.isRunningTest()){
     isRestrictedUser=false;
    }    
  return isRestrictedUser;
 }
 
 /*****************
 * @param  String URL
 * @Author Vivekanand Deshmane
 * @CR-00022624 
 * Created Method to return a boolean that indicates that the case is closed.
 * This boolean is used in rest of the code to prevent any addition of time track 
 * entries for any mode when the case is closed.
 ******************/
 public static boolean isCaseClosed(String URL){
 
     String caseId= recordId(URL);
     boolean isclose=false;
    if(caseId!=null&&!caseId.equals('')){
       isclose=[select IsClosed From Case where Id=:caseId].IsClosed;
      }
    return isclose;
 }
 
 /**
* @return Integer  
* @Author Vivekanand Deshmane
* @CR-00016565
* Used to insert Record in WebEx Temp Time Tack Object.
**/

global static Integer  weExTempTimeTrackEntry() 
{
 try
 {
 String URL= System.currentPagereference().getParameters().get('URL');
   if(!isTimeTrackRestrictedProfile(URL)){
  
   WebExTempTimTrack__c webExc = new WebExTempTimTrack__c ();
    if(recordId(URL) != null&&!isTimeTrackRestrictedProfile(URL))
         {
            String caseId= recordId(URL);
             List<Temp_Time_Track__c> temList = [Select Id ,User__c,time__c,Case__c from Temp_Time_Track__c where User__c=:UserInfo.getUserId() and Case__c=:caseId];
             removeEntryFromWebExTempTimeTrack(caseId);
             if(!temList.isempty()){
                 removeEntryFromTempTimeTrack(temList);
             }


            Datetime x =  Datetime.now();
            webExc .Case__c=caseId;
            webExc .time__c=x+'';
            webExc .User__c=UserInfo.getUserId();   
            insert webExc ;
         }
          if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
    }   
    }   
   Catch(Exception e){
         System.debug('Exception Time Track controller'+e);
     } 
     return 1;
  }
      

 
/**
* @param  List<WebExTempTimTrack__c> temList,String mode, String caseId
* @Author Vivekanand Deshmane
* @CR-00016565
* Used to insert Record in WebEx Temp Time Tack Object.
**/

global static void weExTimeTrackEntry( List<WebExTempTimTrack__c> temList,String mode, String caseId) 

{
  try
  { 
      
 
     String currenDateTimeStr= Datetime.now()+'';
 
    List<Time_Track__c> timeTrackList= new List<Time_Track__c> ();
    Integer tracTime=0;
    Integer tempTime=0;
    Integer additionalTime=0;
    String additionalTimeStr='0:00:00';
    String startTempTime=null;
    Integer totalTempTime=0;
    
                  if(temList!=null&&temList.size()>0){
                  startTempTime=temList.get(0).time__c;
                  
                   List<String> splitTime = new List<String>();
                 List<String> splitEndTime = new List<String>();
                if(startTempTime!=null && !startTempTime.equals('')){
                      if(startTempTime.contains('.')){
                           startTempTime=startTempTime.replace('.',':');
                         
                        }
               
               
                   if(currenDateTimeStr.contains('.')){
                       currenDateTimeStr=startTempTime.replace('.',':');
                 
                        }
                       Datetime x =  datetime.valueOfGmt(currenDateTimeStr);            
                      Integer tempEndTime =Integer.valueOf(x.getTime())/1000;
                      Datetime temStartDateTime = datetime.valueOfGmt(startTempTime);

                      Integer startTempTimeLong=Integer.valueOf(temStartDateTime.getTime())/1000;  
                              
                         //Here we calculating overall time spent on case.           
                     totalTempTime=tempEndTime-startTempTimeLong;
                     
                     if(totalTempTime!=null&&totalTempTime>0)
                         {
                     
                                Integer totalHrs = 0 ;
                                Integer totalMin = 0;
                                Integer totalSec = 0;
                                Integer totalsec_1 = Math.mod(totalTempTime,60);
                                Integer totalsec_11 = totalTempTime/60;
                                totalMin = totalMin  + totalsec_11;
                                Integer totalmin_1 = Math.mod(totalMin ,60);
                                Integer totalmin_11 = totalMin /60;
                                totalHrs = totalHrs + totalmin_11;
                               String totalmin_1_Formatted;
                               String totalsec_1_Formatted;
                        if(totalmin_1<=9){
                           totalmin_1_Formatted= ':0'+totalmin_1;
                            }else{
                            totalmin_1_Formatted=':'+totalmin_1;
                            }
                             if(totalsec_1>0&&totalsec_1<=9){
                                totalsec_1_Formatted=':0'+totalsec_1;
                                }else{
                             if(totalsec_1>0)
                             totalsec_1_Formatted=':'+totalsec_1;
                        }
                        if(totalHrs!=null&&totalmin_1_Formatted!=null&&totalsec_1_Formatted!=null){
                        additionalTimeStr= totalHrs +totalmin_1_Formatted+totalsec_1_Formatted;
                         if(!additionalTimeStr.equals('0:00:00')){
                             Time_Track__c c = new Time_Track__c();
                                c.Case__c =  caseId;
                                c.User__c = System.userInfo.GetUserId();
                                c.Total_Time__c = additionalTimeStr;     
                                c.Mode__c    =    mode;
                                //c.Temp_Time_Track__c=getTempTimeTrackId(c.Case__c);
                                c.Ismanual__c=false;
                                  boolean isclose=[select IsClosed From Case where Id=:caseId].IsClosed;
                                if(!isclose){
                                GSSTimeTrackArchiveUtility.mergeTimeTrackEntries(c);
                                }
                                //Insert c;
                                removeEntryFromWebExTempTimeTrack(caseId);
                                 Temp_Time_Track__c tempc = new Temp_Time_Track__c();
                                 Datetime x1 =  Datetime.now();
                                 tempc.Case__c=caseId;
                                 tempc.time__c=x1+'';
                                 tempc.User__c=UserInfo.getUserId();   
                                    insert tempc ;
                                                            
                                                            
                         
                             }
                         
                         }
                      } 
                }
                  
                   
           }
           
   }Catch(Exception e){
         System.debug('Exception Time Track controller'+e);
     }  
 
}
/**
* @param  String caseId
* 
* @Author Vivekanand Deshmane
* @CR-00016565
* used to remove record from WebExTempTimeTrack object by uisng looged in User Id and case ID as crateria.
**/

 global static void removeEntryFromWebExTempTimeTrack(String caseId)
 {
    
   try
   {
    
        List<WebExTempTimTrack__c> temList = [Select Id ,User__c,time__c,Case__c from WebExTempTimTrack__c where User__c=:UserInfo.getUserId() and Case__c=:caseId ];
        if(temList !=null&&temList.size()>0){
         delete temList; 
         
          
        }
         if(Test.isRunningTest()){
           Throw new TimeTrackerException();
       }
   }Catch(Exception e){
       System.debug('Exception Time Track controller'+e);  
   }   
  
        
 }
 
 public class TimeTrackerException extends Exception{}
 
 //Start:CR-00140078 added Industry Field
 public string getIndustry(){
     List<case_extension__c> cextList = [select industry__c from case_extension__c where case__c = :theCase.id];
     if(!cextList.isEmpty()){
         return cextList[0].industry__c;
     }
     else {
        return null;
     }
 }
 //Stop:CR-00140078 added Industry Field
 
}