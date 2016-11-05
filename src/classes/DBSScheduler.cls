global class DBSScheduler{
    
    global static String sUSerlocale {get;set;}
    global static String sUSer {get;set;} 
    global static list<calEventM> eventsM {get;set;}
    global static List<User> userlist {get;set;}
    global static List<Account> acctlist {get;set;}
    global static String dtFormat = 'EEE, d MMM yyyy HH:mm:ss';
    global static Long dt1Long; 
    
    global static final String SJMRecordtype = 'SJM Standard Event';
    global static final String CalView = 'timelineDay';
    global static final String ProcedureRecordtype = 'DBS Procedure Scheduler';
    global static final String ProcedureRecordtypeDevname = 'DBS_Procedure_Scheduler';
    global static final String DEPerSet = 'Opportunity_Management_DBS_OUS';
    
    global static String countries = '';
    
    global static String getCountries() {
        
        //check if the user has only one country
        User usr = [SELECT Scheduler_Country_Code__c from user where id = :UserInfo.getUserId()];            
        List<string> contryCod = String.valueOf(usr.Scheduler_Country_Code__c).split('\\;'); 
        
        if(countries == '')
        {
            if(contryCod.size() > 1)
            {       
                countries = 'ALL';
            }
        }
        else{
            system.debug('Initial countries was not black' + countries );
        }
        return countries;
        
    }
    
    @RemoteAction
    global static void setCountries(String countries1) {           
        DBSScheduler.countries = countries1;           
    }
    
    
    public List<SelectOption> getItems() { 
        system.debug('Used Id ' + UserInfo.getUserId() );
        List<SelectOption> options = new List<SelectOption>();
        User usr = [SELECT Scheduler_Country_Code__c from user where id = :UserInfo.getUserId()];   
        
        if(usr != null && ((String.valueOf(usr.Scheduler_Country_Code__c)) != null && (String.valueOf(usr.Scheduler_Country_Code__c))!= ''))       
        {
            List<string> contryCod = String.valueOf(usr.Scheduler_Country_Code__c).split('\\;');            
           if(contryCod.size() >1 ) 
           {
               options.add(new SelectOption('ALL','ALL'));
    
                for(string s:contryCod)
                {
                    options.add(new SelectOption(s,s));
                }   
            } 
            else
            {
              for(string s:contryCod)
                {
                    options.add(new SelectOption(s,s));
                } 
            }     
        }
        
        return options;
    }
     
    global PageReference refreshPanel() {
        
        getUsersList();
        system.debug('Referesh the list....');
        return null;
    }
     
    public DBSScheduler()
    {
        sUSerlocale =  UserInfo.getLocale();
    }
    
    
    //The below preperties are used show event related information on calendar  
    global class calEventM{
        public Integer Id {get;set;}
        public String title {get;set;}               
        public string SfId {get;set;}
        public string UserId {get;set;}
        public string UserIdName {get;set;}
        public String url {get;set;}
        public string AcctIdName {get;set;}
        public string AcctbillCity {get;set;}
        public string Acctsearch {get;set;}
        public string ContIdName {get;set;}
        public string RcrdTypeName {get;set;}
        public string PrmCasWillUse {get;set;}
        public string PrmDiagonosis {get;set;}
        public string AssignmentStatus {get;set;}
        public string EvtStatus {get;set;}
        public string ResourceId {get;set;}
        
        public boolean IsAllDayEvent {get;set;}
        public boolean IsUncoveredUser {get;set;}
        
        public Decimal StartYear {get;set;}
        public Decimal StartMonth {get;set;}
        public Decimal StartDay {get;set;}
        public Decimal StartHour {get;set;}
        public Decimal StartMinute {get;set;}
        public Decimal StartSecond {get;set;}
        
        public Decimal EndYear {get;set;}
        public Decimal EndMonth {get;set;}
        public Decimal EndDay {get;set;}
        public Decimal EndHour {get;set;}
        public Decimal EndMinute {get;set;}
        public Decimal EndSecond {get;set;}
        
    }
    
    @RemoteAction
    global static id getRecordId(){
        //make soql quesy here
        List<RecordType> recordTypeId = [SELECT ID FROM RecordType where DeveloperName = :ProcedureRecordtypeDevname LIMIT 1];
        return recordTypeId[0].id;
    }
    
    @RemoteAction
    global static list<calEventM> getCalenderEvents(string sUserID,string sAcctID, String pclick, String nclick, String SDate, String Status, String ViewName, String CountryName) {
        
        User userobj = new User();
        userobj = [SELECT id, Scheduler_Country_Code__c from user where id = :UserInfo.getUserId() LIMIT 1];
        
        List<string> countryCode = new List<string>();
        string[] countrylist;
        if(CountryName == '' || CountryName == null){CountryName  = countries;}
        
        if(CountryName == 'ALL')
        {
            countrylist =  String.valueOf(userobj.Scheduler_Country_Code__c).split('\\;');
            for(string contryName : countrylist )
            {
               countryCode.add(contryName );
            }
          
        }   
        else
        {
          countryCode.add(CountryName );
        }    

        String[] Usrresult = sUserID.split(',\\s*');
        String[] Acctresult = sAcctID.split(',\\s*');
        
        DateTime StartDate;
        DateTime EndDate;
        
        Integer sIntDate;
        Integer sIntMonth;
        Integer sIntYear;
        
        Integer eIntDate;
        Integer eIntMonth;
        Integer eIntYear;
        
        Integer Seconds;
        Integer minutes;
        Integer hrs;
        Decimal disminutes;
        Decimal disseconds;
        Integer seconds1;
        Integer s_offset_hrs;
        Integer s_offset_mins;
        Integer s_offset_seconds;
        
        DateTime now = DateTime.now();
        Long offset = DateTime.newInstance(now.date(), now.time()).getTime() - DateTime.newInstance(now.dateGmt(), now.timeGmt()).getTime();
        
        Seconds = Integer.valueOf(offset/(1000));
        hrs = Integer.valueOf(Math.Floor(Seconds/(60*60)));
        disminutes = math.mod(Seconds,3600);
        minutes =  Integer.valueOf(Math.floor(disminutes/(60)));
        disseconds = math.mod(Integer.valueOf(disminutes),60);
        seconds1 = Integer.valueOf(math.ceil(disseconds));
        
        
        s_offset_hrs = hrs;
        s_offset_mins =  minutes;
        s_offset_seconds = seconds1;
         
        String[] mySDateOnly = SDate.split(' ');
        String[] strSDate = mySDateOnly[0].split('-');
        sIntDate = integer.valueOf(strSDate[2]);
        sIntMonth = integer.valueOf(strSDate[1]);
        sIntYear = integer.valueOf(strSDate[0]);
        
        
        if(ViewName != CalView)
        {
            eIntDate = sIntDate+6;
        }
        else
        {
            eIntDate = sIntDate;  
        }
        Date stdt = Date.newInstance(sIntYear,sIntMonth,sIntDate);
        Date edt = Date.newInstance(sIntYear,sIntMonth,eIntDate);
        Integer duration = stdt.daysBetween(edt);
        Date startOfWeek;
        Date weekSDate;
        Date weekEDate;
        dt1Long = DateTime.now().getTime();
       
        try{
            if(pclick == 'false' && nclick == 'false'){
               if(ViewName != CalView)
                {
                     startOfWeek = stdt.toStartOfWeek();            
                     weekSDate = startOfWeek.addDays(0);
                     weekEDate = startOfWeek.addDays(6);
                     StartDate = DateTime.newInstance(weekSDate.year(),weekSDate.month(),weekSDate.day(),s_offset_hrs,s_offset_mins,s_offset_seconds);
                     EndDate = StartDate.addDays(6).addDays(1).addSeconds(-1);
                     //system.Debug('@@Duration > 6 StartDate :'+ StartDate + ' EndDate ' + EndDate );
                 }
                 else
                 {
                     StartDate = DateTime.newInstance(stdt.year(),stdt.month(),stdt.day(),s_offset_hrs,s_offset_mins,s_offset_seconds);
                     EndDate = StartDate.addDays(0).addDays(1).addSeconds(-1);
                     //system.Debug('@@Day > 1 StartDate :'+ StartDate + ' EndDate ' + EndDate );
                 }   
            }
            
            if(pclick == 'true' || nclick == 'true'){
                StartDate = DateTime.newInstance(sIntYear,sIntMonth,sIntDate,s_offset_hrs,s_offset_mins,s_offset_seconds);
                EndDate = DateTime.newInstance(sIntYear,sIntMonth,eIntDate,s_offset_hrs,s_offset_mins,s_offset_seconds);
                EndDate = EndDate.addDays(1).addSeconds(-1);
                //system.Debug('StartDate :'+ StartDate + ' EndDate ' + EndDate);
            }
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        finally{
            Long dt2Long = DateTime.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            //system.debug('Calendar Prev and Next click took ' + milliseconds + '  Milli seconds to complete');
        }
        
        string usid;
        string IndeUsrId;
        eventsM = new list<calEventM>();
        userlist = new List<User>();
        acctlist = new List<Account>();
        list<User> uncovereduser = new List<User>();
        
        uncovereduser = [SELECT Id FROM User where IsActive = true and name like '%UnCovered%' limit 1];
        if(uncovereduser.size() > 0){
            usid = String.valueOf(uncovereduser[0].id); 
        }
        
        try{
            if(sUserID != '')
            {
                userlist = [SELECT id, name FROM user where Id = :Usrresult and isactive = true and Scheduler_Country_Code__c != null order by name];
                //system.debug('@@userlist if  ' + userlist);
            }
            else
            { 
                List<User> objUserList =new List<User>( [SELECT Id,Name,Scheduler_Country_Code__c FROM User where Scheduler_Country_Code__c != null and IsActive = true order by name Limit 150]);
                for(user objuser : objUserList )
                {
                   for (string countryNme : countryCode)
                   {
                    if( String.valueOf(objuser.Scheduler_Country_Code__c).indexOf(countryNme ) != -1)
                    {
                       userlist.add(objuser);
                    }
                
                    }               
                }
                userlist.addAll(uncovereduser); 
            }
            
        } 
        catch(Exception e){
            system.debug(e.getMessage());
        } 
        finally{
            Long dt2Long = DateTime.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            system.debug('Default search filters loading took ' + milliseconds + '  Milli seconds to complete');
        }  
        
        Set<Id> actid = new Set<Id>();
        Set<Id> conid = new Set<Id>();
        Set<Id> rid = new Set<Id>();
        
        List<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' and (Name = :ProcedureRecordtype)];
        
        List<RecordType> rtstd = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' and (Name = :SJMRecordtype)];
        for(RecordType r : rt)
        {
            rid.add(r.id); 
        }
        
        List<Event> objEvent = new List<Event>();
        List<Event> objEventPTO = new List<Event>();
        
        if(sAcctID != '')
        {
            if(sUserID != '')
            {
                if(Status == 'No')
                {
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and Accountid = :Acctresult and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                }
                else
                {
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and Accountid = :Acctresult and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c = 'Cancelled' limit 50000]);
                }    
            }  
            
            else
            {
                if(Status == 'No')
                {
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and Accountid = :Acctresult and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                }
                else
                {
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and Accountid = :Acctresult and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c = 'Cancelled' limit 50000]);
                }   
            }       
        }
        else
        {
            if(sUserID != '')
            {
                if(Status == 'No')  
                {
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and AccountId != null and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                    objEventPTO = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rtstd and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                }
                else
                {    
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and AccountId != null and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c = 'Cancelled' limit 50000]);
                }
            }
            else
            {
                if(Status == 'No')  
                {                   
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and AccountId != null and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                    objEventPTO = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rtstd and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                }
                else
                {    
                    objEvent = ( [SELECT IsAllDayEvent, Status__c,Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c from Event where OwnerId != null and OwnerId = : userlist and AccountId != null and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c = 'Cancelled' limit 50000]);
                }
            }
            objEvent.addAll(objEventPTO);
        }
        
        
        if(objEvent.size()>0){
            try{
                for(event ent:objEvent)
                {
                    actid.add(ent.AccountId);
                    conid.add(ent.WhoId);
                }
                Map<ID,Account> accounts = new Map<ID,Account>([SELECT Id,name,BillingCity,Search_2__c FROM Account where Id =:actid]);
                Map<ID,Contact> contacts = new Map<ID,Contact>([SELECT Id,name FROM Contact where Id =:conid]);
                Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Event.getRecordTypeInfosById();
                
                for(Event evnt: objEvent)
                {
                    DateTime startDT = evnt.StartDateTime;
                    DateTime endDT = evnt.EndDateTime;
                    calEventM myEvent = new calEventM();
                    
                    if (evnt.StartDateTime != null) {
                        myEvent.StartYear = evnt.StartDateTime.year();
                        myEvent.StartMonth = evnt.StartDateTime.month()-1;
                        myEvent.StartDay = evnt.StartDateTime.day();
                        myEvent.StartHour = evnt.StartDateTime.hour();
                        myEvent.StartMinute = evnt.StartDateTime.minute();
                        myEvent.StartSecond = evnt.StartDateTime.second();
                    }        
                    
                    if (evnt.EndDateTime != null) {
                        myEvent.EndYear = evnt.EndDateTime.year();
                        myEvent.EndMonth = evnt.EndDateTime.month()-1;
                        myEvent.EndDay = evnt.EndDateTime.day();
                        myEvent.EndHour = evnt.EndDateTime.hour();
                        myEvent.EndMinute = evnt.EndDateTime.minute();
                        myEvent.EndSecond = evnt.EndDateTime.second();
                    }
                    if(evnt.IsAllDayEvent == true)
                    {
                        myEvent.StartDay = evnt.StartDateTime.day()+1;
                        myEvent.EndDay = evnt.EndDateTime.day()+1;
                        myEvent.StartHour = 8;
                        myEvent.EndHour = 17;
                    } 
                    
                    if(evnt.Subject != null){
                        myEvent.title = evnt.Subject;
                    }
                    else
                    {
                        myEvent.title = '';
                    }
                    
                    if(evnt.AccountId != null){
                        myEvent.AcctIdName = accounts.get(evnt.AccountId ).name;
                        myEvent.AcctbillCity = accounts.get(evnt.AccountId ).BillingCity;
                        myEvent.Acctsearch = accounts.get(evnt.AccountId ).Search_2__c;
                    }
                    else
                    {
                        myEvent.AcctIdName = '';
                    } 
                    
                    if(evnt.WhoId != null){
                        myEvent.ContIdName = contacts.get(evnt.WhoId).name;
                    }
                    else
                    {
                        myEvent.ContIdName = '';
                    }              
                    
                    myEvent.SfId = evnt.Id;
                    
                    if(evnt.OwnerId != null){
                        myEvent.UserId = evnt.OwnerId ;
                    }
                    else
                    {
                        myEvent.UserId = '';
                    }
                    
                    
                    if(evnt.Assignment_Status__c != null){
                        myEvent.ResourceId =  evnt.Assignment_Status__c + myEvent.UserId;
                    }
                    else
                    {
                        myEvent.ResourceId = 'Uncovered' + myEvent.UserId;                       
                    }
                    
                    if(evnt.Assignment_Status__c != null){
                        myEvent.AssignmentStatus= evnt.Assignment_Status__c;
                    }
                    else
                    {
                        myEvent.AssignmentStatus= 'Uncovered';
                    }
                    
                    if(evnt.Status__c != null){
                        myEvent.EvtStatus = evnt.Status__c;
                    }
                    
                    if(evnt.RecordTypeId != null){
                        myEvent.RcrdTypeName = rtMap.get(evnt.RecordTypeId).getName(); 
                    }
                    else
                    {
                        myEvent.RcrdTypeName = '';
                    }
                    
                    if(evnt.OwnerId == usid && evnt.Assignment_Status__c != '' )
                    {
                        myEvent.IsUncoveredUser = true;
                    }
                    else
                    {
                        myEvent.IsUncoveredUser = false;
                    }
                    
                    myEvent.url = 'javascript:sforce.one.navigateToSObject("' + evnt.Id + '","edit")';
                    eventsM.add(myEvent);                   
                }
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            finally{
                Long dt2Long = DateTime.now().getTime();
                Long milliseconds = dt2Long - dt1Long;
                system.debug('Method getcalendarevents took ' + milliseconds + '  Milli seconds to complete');
            }
            
        } 
        
        if((sUserID == '') ){
            calEventM myEvent1 = new calEventM();
            myEvent1.SfId = '0';
            myEvent1.UserId = usid;
            myEvent1.AssignmentStatus = 'Uncovered';
            myEvent1.EvtStatus = 'Open';
            myEvent1.IsUncoveredUser = true;
            eventsM.add(myEvent1);
        }
        
        return eventsM ;
        
    }
    
    
    public List<SelectOption> getUsersList() {
        
        List<SelectOption> objUsers= new List<SelectOption>();
        List<User> selectUsers = new List<User>();
        List<Id> listAssigneId = new List<Id>();
        List<Id> listpersetass = new List<Id>();
        List<Id> listperset = new List<Id>();
        List<Id> listperAssid = new List<Id>();
        List<Id> listuser = new List<Id>();
        List<String> liststring =  new List<String>();
        sUSer  = UserInfo.getUserId();
        dt1Long = DateTime.now().getTime();
        User usr = new User();
        Boolean IsUserAvailable = false;
        Boolean result = false;
        Boolean result1 = false;
        String Prset;
        try{
            
            usr = [SELECT Scheduler_Country_Code__c from user where id = :UserInfo.getUserId()];
            if(countries == '' || countries == null)
            {
                countries =  String.valueOf(usr.Scheduler_Country_Code__c);                 
            }
            
             List<string> countryCodes = new List<string>();
             string[] countrylist;
              
      if(countries =='ALL' )
      {
        countrylist =  String.valueOf(usr.Scheduler_Country_Code__c).split('\\;');
        for(string contryName : countrylist )
        {
          countryCodes.add(contryName );
        }       
      }
      else
      {
         countryCodes.add(countries);      
      }  

            for(PermissionSetAssignment prnames :[SELECT Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()])
            {  
                listpersetass.add(prnames.PermissionSetId);
            }
            
            for(PermissionSet p : [SELECT Id,Name from PermissionSet where id = : listpersetass])
            {
                liststring.add(p.name); 
            }
            
            Prset = String.valueof(liststring);
            
            String[] arrprset = Prset.split('\\,');
            for(String check : arrprset)
            {
                if(check.contains(DEPerSet))
                {
                    result1 = true;
                }
            }
            
            List<user> objUserList = new List<user>();
            
            if(result1 == true)
            { 
                for(PermissionSet p3 : [SELECT Id,Name FROM PermissionSet where name = :DEPerSet])
                {                            
                    listperset.add(p3.Id);                            
                }
                
                for(PermissionSetAssignment psas : [SELECT Id,AssigneeId from PermissionSetAssignment where PermissionSetId = : listperset])
                {                           
                    listperAssid.add(psas.AssigneeId);
                }
                
              
               objUserList = [SELECT Id,Name,Scheduler_Country_Code__c FROM User where Scheduler_Country_Code__c != null and Id = : listperAssid limit 150];
               //system.debug('@@objUserList ' + objUserList); 
                
                for(user objuser : objUserList )
                {              
                 //system.debug('@@objuser  ' + objuser.Id);
                 for (string countryName : countryCodes)
                 {
                    if( String.valueOf(objuser.Scheduler_Country_Code__c).indexOf(countryName ) != -1)
                    {
                       listuser.add(objuser.Id);
                    }
                  }
                }  
            }
            else
            {           
               objUserList = [SELECT Id,Name,Scheduler_Country_Code__c FROM User where Scheduler_Country_Code__c != null limit 150];
                system.debug('@@objUserList1 ' + objUserList); 
                for(user objuser : objUserList)
                {
                   for (string countryName : countryCodes)
                   {
                     if( String.valueOf(objuser.Scheduler_Country_Code__c).indexOf(countryName ) != -1)
                     {
                         listuser.add(objuser.Id);
                     }
                   }
                } 
            }
            
            selectUsers = [SELECT Id,Name FROM User where Id = :listuser and IsActive = true order by name Limit 150];
            
            if(selectUsers.size() > 0)
            {
                objUsers.add(new SelectOption('' ,'--All Assignees--' ));
                
                for(User oUser :selectUsers )
                {
                    if (sUSer  == oUser.Id)
                    {
                        //IsUserAvailable = true;
                    }
                    objUsers.add(new SelectOption(oUser.Id , oUser.Name));
                }
            } 
            
            if( !IsUserAvailable )
            {
                sUSer   = '';
            }
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
        finally{
            Long dt2Long = DateTime.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            system.debug('SUNILD...Method getUser took ' + milliseconds + '  Milli seconds to complete');
        }
        
        return objUsers;     
    }   
}