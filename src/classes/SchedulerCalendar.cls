global class SchedulerCalendar{
    
    global static String sRegion {get;set;} 
    global static list<calEventM> eventsM {get;set;}
    global static DateTime EndDate {get;set;}
    global static List<User> userlist {get;set;}
    global static List<Account> acctlist {get;set;}
    global static String dtFormat = 'EEE, d MMM yyyy HH:mm:ss';
    global static Long dt1Long; 
    
    global static final String SJMRecordtype = 'SJM Standard Event';
    global static final String CalView = 'timelineDay';
    global static final String ProcedureRecordtype = 'Procedure Scheduler';
    global static final String ProcedureRecordtypeDevname = 'Procedure_Scheduler';
    
    //Based on selection of Region get the Assignee list
    global class userList{
        public String id {get;set;}        
        public String name {get;private set;}
        
    }
    
    //Based on selection of Region get the Hospital list    
    global class AccountList{
        public String id {get;set;}        
        public String name {get;set;}
    }    
    
    //The below preperties are used show event related information on calendar  
    global class calEventM{
        public Integer Id {get;set;}
        public String title {get;set;}               
        public string SfId {get;set;}
        public string UserId {get;set;}
        public string UserIdName {get;set;}
        public String url {get;set;}
        public Id AcctId{get;set;}
        public string AcctIdName {get;set;}
        public string ContIdName {get;set;}
        public string RcrdTypeName {get;set;}
        public string PrmCasWillUse {get;set;}
        public string PrmDiagonosis {get;set;}
        public string AssignmentStatus {get;set;}
        public string ResourceId {get;set;}
        /*Add Call-in Date and Notes field*/
        public string Description {get;set;}
        public string CallInDate {get; set;}
        /*End : Add Call-in Date and Notes field*/
        public boolean IsAllDayEvent {get;set;}
        public boolean IsUncoveredUser {get;set;}
        public boolean IsIndependentUser {get;set;}
        
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
        
        public Boolean HasEditAccess{get;set;}
    }
    
    @RemoteAction
    global static id getRecordId(){
        //make soql quesy here
        List<RecordType> recordTypeId = [SELECT ID FROM RecordType where DeveloperName = :ProcedureRecordtypeDevname LIMIT 1];
        return recordTypeId[0].id;
    }
    
    @RemoteAction
    global static list<calEventM> getCalenderEvents(string Region,string sUserID,string sAcctID, String pclick, String nclick, String SDate, String Status, String ViewName) {
        String[] Regresult = Region.split(',\\s*');
        String[] Usrresult = sUserID.split(',\\s*');
        String[] Acctresult = sAcctID.split(',\\s*');
        
        DateTime StartDate;
        
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
        
        //Integer e_offset_hrs;
        //Integer e_offset_mins;
        //Integer e_offset_seconds;
        
        Map<Id, Boolean> accessDetails = new Map<Id, Boolean>();
        
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
        
        /*if(hrs >= 0)
        {
            e_offset_hrs = hrs;
        }
        else{
            e_offset_hrs = (hrs + 23);
        }
        e_offset_mins = 59;
        e_offset_seconds = 59;*/
        
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
            if(pclick == 'false' && nclick == 'false')
            {
                if(ViewName != CalView)
                {
                     startOfWeek = stdt.toStartOfWeek();            
                     weekSDate = startOfWeek.addDays(1);
                     weekEDate = startOfWeek.addDays(6);
                     StartDate = DateTime.newInstance(weekSDate.year(),weekSDate.month(),weekSDate.day(),s_offset_hrs,s_offset_mins,s_offset_seconds);
                     EndDate = StartDate.addDays(6).addDays(1).addSeconds(-1);
                     system.Debug('@@Duration > 6 StartDate :'+ StartDate + ' EndDate ' + EndDate );
                 }
                 else
                 {
                     StartDate = DateTime.newInstance(stdt.year(),stdt.month(),stdt.day(),s_offset_hrs,s_offset_mins,s_offset_seconds);
                     EndDate = StartDate.addDays(0).addDays(1).addSeconds(-1);
                     system.Debug('@@Day > 1 StartDate :'+ StartDate + ' EndDate ' + EndDate );
                 }
            }
            
            if(pclick == 'true' || nclick == 'true')
            {
                StartDate = DateTime.newInstance(sIntYear,sIntMonth,sIntDate,s_offset_hrs,s_offset_mins,s_offset_seconds);
                EndDate = DateTime.newInstance(sIntYear,sIntMonth,eIntDate,s_offset_hrs,s_offset_mins,s_offset_seconds);
                EndDate = EndDate.addDays(1).addSeconds(-1);
                system.Debug('@@StartDate :'+ StartDate + ' EndDate ' + EndDate);
            }
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        finally{
            Long dt2Long = DateTime.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            system.debug('Calendar Prev and Next click took ' + milliseconds + '  Milli seconds to complete');
        }
        
        string usid;
        string IndeUsrId;
        eventsM = new list<calEventM>();
        userlist = new List<User>();
        acctlist = new List<Account>();
        list<User> uncovereduser = new List<User>();
        list<User> independentuser = new List<User>();
        
        uncovereduser = [SELECT Id FROM User where IsActive = true and name like '%UnCovered%' limit 1];
        independentuser = [SELECT Id FROM User where IsActive = true and name like '%Independent%' limit 1];
        if(uncovereduser.size() > 0){
            usid = String.valueOf(uncovereduser[0].id); 
        }
        if(independentuser.size() > 0){
            IndeUsrId = String.valueOf(independentuser[0].id); 
        }
        try{
            if (Region != '') 
            {
                acctlist = [SELECT id FROM account where USD_AF_Region__c = : Regresult and USD_AF_Region__c != null order by name];
                if(sUserID != ''){
                    userlist = [SELECT id FROM user where Region__c = : Regresult and id = : Usrresult and isactive =  true order by name];
                }
                else
                { 
                    userlist = [SELECT id FROM user where Region__c = : Regresult and isactive = true order by name];
                    userlist.addAll(uncovereduser); 
                    userlist.addAll(independentuser);
                }
                
                if(sAcctID != '')
                {
                    acctlist = [SELECT Id FROM account where USD_AF_Region__c = :Regresult and Id = :Acctresult and USD_AF_Region__c != null order by name];
                }
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
            if(Status == 'No')
            {
                objEvent = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,
                              RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c
                              FROM Event
                              WHERE OwnerId != null and OwnerId = : userlist 
                              and Accountid = :acctlist 
                              and (StartDateTime != null or EndDateTime != null) 
                              and RecordTypeId = :rid 
                              and StartDateTime >= :StartDate 
                              and EndDateTime <= :EndDate 
                              and Status__c!= 'Cancelled' 
                              LIMIT 50000]);
            }
            else
            {
                objEvent = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,
                              RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c 
                              FROM Event 
                              WHERE OwnerId != null and OwnerId = : userlist and Accountid = :acctlist and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c = 'Cancelled' limit 50000]);
            }         
        }
        else
        {
            if(Status == 'No')  
            {                   
                
                objEvent = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c from Event where OwnerId != null and OwnerId = : userlist and AccountId = : acctlist and AccountId != null and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                objEventPTO = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c from Event where OwnerId != null and OwnerId = : userlist and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rtstd and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]);
                
                system.Debug('@@objEventPTO :'+ objEventPTO );
                
            }
            else
            {
                objEvent = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c from Event where OwnerId != null and OwnerId = : userlist and AccountId = : acctlist and AccountId != null and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate and Status__c = 'Cancelled' limit 50000]);
            }
            
            objEvent.addAll(objEventPTO);
        }
        
        //get list of account ids
        List<id> accountIds = new List<id>();
        for(Event objEvtItem : objEvent){
            if (objEvtItem.AccountId != null || objEvtItem.AccountId != '')
            {
                accountIds.add(objEvtItem.AccountId);
            }
        }
        System.debug('*** Account ID= ' + accountIds);
        
        //call UserRecordAccess
        List<UserRecordAccess> temp = [SELECT RecordId, HasReadAccess FROM UserRecordAccess
                                       WHERE UserId = :UserInfo.getUserId()
                                       AND RecordId IN :accountIds];
        for(UserRecordAccess t : temp){
            accessDetails.put(t.RecordId, t.HasReadAccess);
        }
        System.debug('*** Access List = ' + accessDetails);  
        
        if(objEvent.size()>0){
            try{
                for(event ent:objEvent)
                {
                    actid.add(ent.AccountId);
                    conid.add(ent.WhoId);
                }
                Map<ID,Account> accounts = new Map<ID,Account>([SELECT Id,name FROM Account where Id =:actid]);
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
                    
                    if(evnt.Call_in_Date__c != null)
                    {
                        myEvent.CallInDate = (evnt.Call_in_Date__c).format();
                        // system.debug('Call In Date Is' + myEvent.CallInDate);
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
                        myEvent.AcctId = evnt.AccountId;
                        myEvent.AcctIdName = accounts.get(evnt.AccountId).name;
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
                    
                    if(evnt.Primary_Case_Will_Use__c != null){
                        myEvent.PrmCasWillUse = evnt.Primary_Case_Will_Use__c;
                    }
                    else
                    {
                        myEvent.PrmCasWillUse = '';
                    }
                    
                    if(evnt.Primary_Diagnosis__c != null){
                        myEvent.PrmDiagonosis = evnt.Primary_Diagnosis__c;
                    }
                    else
                    {
                        myEvent.PrmDiagonosis = '';
                    }                
                    if(evnt.Comments__c != '' )
                    {
                        system.debug('Custom Log' + evnt.Comments__c);
                        myEvent.Description = evnt.Comments__c;
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
                    if(evnt.OwnerId == IndeUsrId && evnt.Assignment_Status__c != '' )
                    {
                        myEvent.IsIndependentUser = true;
                    }
                    else
                    {
                        myEvent.IsIndependentUser = false;
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
        if((sUserID == '' && Region != '') || (sRegion != null)){
            calEventM myEvent1 = new calEventM();
            myEvent1.SfId = '0';
            myEvent1.UserId = usid;
            myEvent1.AssignmentStatus = 'Uncovered';
            myEvent1.IsUncoveredUser = true;
            eventsM.add(myEvent1);
        }
        if((sUserID == '' && Region != '') || (sRegion != null)){
            calEventM myEvent2 = new calEventM();
            myEvent2.SfId = '1';
            myEvent2.UserId = IndeUsrId;
            myEvent2.AssignmentStatus = 'Independent';
            myEvent2.IsIndependentUser = true;
            eventsM.add(myEvent2);
        }
        
        //go thru list of events and update access details
        List<CalEventM> updatedList = new List<CalEventM>();
        System.debug('*** Orig List = ' + eventsM);
        for(calEventM evtM : eventsM){
            if (accessDetails.containsKey(evtM.AcctId))
                evtM.HasEditAccess = accessDetails.get(evtM.AcctId);
            else
                evtM.HasEditAccess = true;
            
            updatedList.add(evtM);
        }
        System.debug('*** Updated List = ' + updatedList);
        return updatedList ;
        
    }
    
    public List<SelectOption> getUserRegions() {
        List<SelectOption> regions = new List<SelectOption>();
        ID usrID = UserInfo.getUserId();
        dt1Long = DateTime.now().getTime();
        String usrArea;
        String usrRegion;
        String Region;
        AggregateResult[] results;
        
        if(usrID != null){
            user u = new user();
            u = [Select Id, Region__c, Area__c from user where Id=:usrID];
            usrArea = u.Area__c;
            usrRegion = u.Region__c;
        }
        
        try{
            if(usrArea != null && usrRegion != null)
            {
                results  = [SELECT Region__c, COUNT(ID) FROM user Where IsActive=true and Area__c != null and Region__c != null and Area__c=:usrArea group by Region__c order by Region__c];
            }
            else
            {
                results  = [SELECT Region__c, COUNT(ID) FROM user Where IsActive=true and Region__c != null group by Region__c order by Region__c];
            }
            
            
            for (AggregateResult ar : results) {
                Region = (String) ar.get('Region__c');
                regions.add(new SelectOption(Region, Region));   
            }
            
            //Default to User Region
            if(usrRegion != null)
            {
                sRegion = usrRegion;
            }
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
        finally{
            Long dt2Long = DateTime.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            system.debug('Method getUserRegions took ' + milliseconds + '  Milli seconds to complete');
        }
        return regions;
        
    }
    
    
    @RemoteAction
    global static List<userList> getUsersList(String Region) 
    {
        String[] Regresult = Region.split(',\\s*');
        List<userList> objUsers= new List<userList>();
        List<User> selectUsers = new List<User>();
        dt1Long = DateTime.now().getTime();
        try
        {
            selectUsers = [SELECT id,name FROM user where Region__c = :Regresult and IsActive = true and Region__c != null order by name];
            if(selectUsers.size() > 0)
            {
                for(User oUser :selectUsers )
                {
                    userList objUser = new userList ();
                    objUser.id = oUser.id;
                    objUser.name = oUser.name;
                    objUsers.add(objUser);
                }
            } 
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
        finally{
            Long dt2Long = DateTime.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            system.debug('Method getUsersList took ' + milliseconds + '  Milli seconds to complete');          
        }
        return objUsers;
    }
    
    
    @RemoteAction
    global static List<AccountList> getAcctsList(String Region) {
        String[] Regresult = Region.split(',\\s*');
        List<Account> acct = new List<Account>();
        List<AccountList> objAccounts = new List<AccountList>();
        dt1Long = DateTime.now().getTime();
        try
        {
            acct = [SELECT id,name FROM account where USD_AF_Region__c = :Regresult and USD_AF_Region__c != null and name != null order by name];
            
            for(Account oAcct :acct)
            {
                AccountList objAcc = new AccountList();
                objAcc.id = oAcct.id;
                objAcc.name = oAcct.name;
                objAccounts.add(objAcc); 
            }
        }
        catch(exception e)
        {
            system.debug(e.getMessage());
        } 
        finally{
            Long dt2Long = DateTime.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            system.debug('Method getAcctsList took ' + milliseconds + '  Milli seconds to complete');
        }
        
        return objAccounts;
    }
    
}