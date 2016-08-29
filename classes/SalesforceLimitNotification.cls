public class SalesforceLimitNotification
{

    

    //---Inner Class to be used for deserializing

    public class deserializeResponse

    {

        public String id;

        public String access_token;

        public String Name;

        public String Description;

    }

 public static String ReturnAccessToken()

    {
    SFConnectedappinfo__c customsetnrecord = SFConnectedappinfo__c.getInstance('Notify');
    final String clientId = customsetnrecord.Consumer_Key__c;
    final String clientSecret =customsetnrecord.Consumer_Secret__c;
    final String username = customsetnrecord.username__c;
    final String password = customsetnrecord.password__c;

String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm(); 
String url =  salesforceHost + '/services/oauth2/token';
        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;       
system.debug('reqbody#'+reqbody);
        Http h = new Http();

        HttpRequest req = new HttpRequest();

        req.setBody(reqbody);

        req.setMethod('GET');

       req.setEndpoint(url);
       HttpResponse res = h.send(req);
        system.debug('res#'+res);
         

        //---Researched in SFDC books: Method 2 for parsing JSON and extracting a Token value without looping, Uses a class as written above

        deserializeResponse resp1 = (deserializeResponse)JSON.deserialize(res.getbody(), deserializeResponse.class);       

        //System.debug('Access Token = ' + resp1.access_token);

         

        return resp1.access_token;

    }


public static List<DailyApiLimit> getCallLimitRestAPI()
{
//SalesforceLimitNotification salesnote=new SalesforceLimitNotification();
String accessToken = SalesforceLimitNotification.ReturnAccessToken();
String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
String url =  salesforceHost + '/services/data/v36.0/limits/'; 
List<DailyApiLimit> lstDailyApiLimit=new List<DailyApiLimit>();
 
 if(accessToken != null)
{

Http http = new Http(); 
HttpRequest req = new HttpRequest();            
req.setHeader('Authorization','Bearer ' + accessToken);
req.setHeader('Content-type', 'application/json');
req.setHeader('accept','application/json');
req.setMethod('GET');
//req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());          
//req.setBody('');
req.setEndpoint(url);

System.debug('>>'+req); 
HTTPResponse res = http.send(req);
System.debug('>>'+res);
 deserializeResponse resp2 = (deserializeResponse)JSON.deserialize(res.getbody(), deserializeResponse.class);

JSONParser parser = JSON.createParser(res.getBody());
System.debug('>>'+parser);
DailyApiLimit dAPI=new DailyApiLimit();
while (parser.nextToken() != null) 
{
    //if current token is a field name
    system.debug('gettoken'+parser.getCurrentToken());
    if(parser.getCurrentToken()==JSONToken.END_OBJECT)
    {
            System.debug('>>'+dAPI.APIName);
            System.debug('>>'+dAPI.Remaining);
            System.debug('>>'+dAPI.Max);
            

        if(dAPI.APIName!=null && dAPI.Remaining!=null && dAPI.Max!=null)
        lstDailyApiLimit.add(dAPI);
         
        dAPI=new DailyApiLimit();
    }
   
    if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
    {
       
        String fieldName = parser.getText();
        System.debug('fieldName: ' + fieldName);
        
        if(fieldName!='Max' && fieldName!='Remaining')
        {

            dAPI.APIName=parser.getText();

        }
        
        //move to token after the field name
        parser.nextToken(); 
        if(fieldName == 'Max'){
            system.debug('TestMax'+ parser.getText());
            dAPI.Max=Long.valueOf(parser.getText());
        }
        else if(fieldName == 'Remaining'){
     
            dAPI.Remaining=Double.valueOf(parser.getText());
            system.debug('TestRemaining'+ parser.getText());
        }
        
}   


} 

for(DailyApiLimit APIlimit:lstDailyApiLimit)
{

If(APIlimit.Max!=null && APIlimit.Remaining!=null)
{
Decimal PercentUsage=((APIlimit.Max-APIlimit.Remaining)/APIlimit.Max)*100;  
System.debug('>>'+PercentUsage);
System.debug('>>'+PercentUsage.setScale(2));
APIlimit.UsagePercent=PercentUsage.setScale(2);
System.debug('>>'+APIlimit.UsagePercent);
}}
system.debug('lstDailyApiLimit##'+lstDailyApiLimit);
}
return lstDailyApiLimit;
}

@future(callout=true)
public static void UsageCalc()
{
    System.debug('**********************');
List<DailyApiLimit>  lstDailyApiLimit=getCallLimitRestAPI();
Boolean mailFlagHigh=false;Boolean mailFlagLow=false;Boolean mailFlagMedium=false;
string finalmailbody='';
SFLimitNotification__c Userlistvalues1= SFLimitNotification__c.getValues('HighUsagePercent');
integer HighUsagePercent=integer.valueOf(Userlistvalues1.value__c);

SFLimitNotification__c Userlistvalues2= SFLimitNotification__c.getValues('LowUsagePercent');
integer LowUsagePercent=integer.valueOf(Userlistvalues2.value__c);

SFLimitNotification__c Userlistvalues3= SFLimitNotification__c.getValues('MediumUsagePercent');
integer MediumUsagePercent=integer.valueOf(Userlistvalues3.value__c);

string mailbodyHigh='Limit Exceeded more than '+HighUsagePercent+'%'+'</BR>';

string mailbodyLow='Limit Exceeded more than '+LowUsagePercent+'%'+'</BR>';

string mailbodyMedium='Limit Exceeded more than '+MediumUsagePercent+'%'+'</BR>';

for(DailyApiLimit APIlimit:lstDailyApiLimit)
{
If(APIlimit.Max!=null && APIlimit.Remaining!=null)
APIlimit.UsagePercent=((APIlimit.Max-APIlimit.Remaining)/APIlimit.Max)*100;
Decimal test=0;
test=(APIlimit.UsagePercent).setScale(2);
if(test>HighUsagePercent)
{
    System.debug('********one*************');

    mailbodyHigh+='APIName='+APIlimit.APIName+' APILmit='+APIlimit.Max+' APIUsage='+test+ '</BR>';
    mailFlagHigh=true;
}
if(test>LowUsagePercent && test<MediumUsagePercent)
{
    mailbodyLow+='APIName='+APIlimit.APIName+' APILmit='+APIlimit.Max+' APIUsage='+test + '</BR>';
    mailFlagLow=true;
    
}
if(test>MediumUsagePercent && test<HighUsagePercent)
{
    System.debug('********two************');

    mailbodyMedium+='APIName='+APIlimit.APIName+' APILmit='+APIlimit.Max+' APIUsage='+test+ '</BR>';
    mailFlagMedium=true;
    
}

}

if(mailFlagHigh==true)
{
finalmailbody+='<div style="width=200px; border:2px black; background-color:Red; color:white; font-weight:bold;border-radius:15px;">'+mailbodyHigh+'</BR>';

}

if(mailFlagMedium==true)
{
finalmailbody+='<div style="width=200px;border:2px black;background-color:Gold; color:black; font-weight:bold; border-radius:15px;">'+mailbodyMedium+'</BR>';
}

if(mailFlagLow==true)
{
finalmailbody+='<div style="width=200px;border:2px black;background-color:LightBlue; color:black; font-weight:bold; border-radius:15px;">'+mailbodyLow+'</BR>';

}

String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
finalmailbody+='<div style="width=200px;border:2px black;background-color:Beige; color:Black; font-weight:bold; border-radius:15px;">'+'For more Details please visit: '+salesforceHost+'/apex/SalesforceLimitPage'+'</BR>';

 
if(mailFlagHigh==true || mailFlagLow==true || mailFlagMedium==true)
sendLimitEmail(finalmailbody);
system.debug('lstDailyApiLimit##'+lstDailyApiLimit);

    
}

public static void sendLimitEmail(string Body)
{
    System.debug('****entered************');

SFLimitNotification__c Userlistvalues= SFLimitNotification__c.getValues('UserList');
List<user> lstuser=new List<user>();
string userStr=Userlistvalues.value__c;
if(userStr!=null || userStr!='')
{
List<string> userlist=userStr.split(',');
lstuser=[select id,name from user where id in:userlist];
}
List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
for(User usr:lstuser)
{
    System.debug('****users************');
    SFLimitNotification__c sfl=SFLimitNotification__c.getValues('DONT REPLY');
    string mailnote=sfl.value__c;
   OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: mailnote];
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
   if ( owea.size() > 0 ) {
    mail.setOrgWideEmailAddressId(owea.get(0).Id);

}
   mail.setSubject('Salesforce Limit Exceeded');
    mail.setTargetObjectId(usr.Id);
    mail.setSaveAsActivity(false);
    mail.setHtmlBody(Body);
    mails.add(mail);
    System.debug('****usersmail************'+usr.Id);

}
try
{

if(!Test.isRunningTest())
{
Messaging.SendEmailResult[] results=Messaging.sendEmail(mails);
system.debug('result#'+results);
}
}
catch(Exception Ex)
{

}
}

public class DailyApiLimit
{
    public string APIName{get;set;}
    public Decimal Remaining{get;set;}
    public Long Max{get;set;}
    public Decimal UsagePercent{get;set;}
    
    
    
}


}