public class CaseSummaryRpt{

    public String sUSer {get;set;}
    public String sUserID {get;set;}
    public String sAcctID {get;set;}
    public String SDate {get;set;} 
    public String Status {get;set;} 
   
    public List<User> userlist {get;set;}
    public List<Account> acctlist {get;set;}
    public String selectedregion {get;set;}
    public String sregion {get;set;}
    public String sviewname {get;set;}
    public String susrid {get;set;}
    public String sactid {get;set;}
    public String datee {get;set;}
    
    public Long dt1Long; 
    public DateTime EndDate {get;set;}
    public String ProcedureRecordtype = 'Procedure Scheduler';
    public String SJMRecordtype = 'SJM Standard Event';
    public String sAMorPM = '';
    public String eAMorPM = '';
    public string startminutes = '';
    public string endminutes = '';
    //public string callindate = '';
    
    List<SelectOption> regions = new List<SelectOption>();
       public class CalUser{
        public string UserId {get;set;}
        public string UserIdName {get;set;}
        public boolean isEventAvailable {get;set;}
       }
       
        Map<String,CalUser> listCallUser = new Map<String,CalUser>();
       public class calEventM{
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
        //public boolean IsIndependentUser {get;set;}
        
        public string EvtStartDate {get;set;}
        public string EvtEndDate {get;set;}
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
        
        //public Boolean HasEditAccess{get;set;}
        //public string prmcasediag {get;set;}
 
    }
    
    public List<calEventM> eventsM {get;set;}
   
  
    public CaseSummaryRpt()
    {
        //system.debug('@@listviewstart');
        sregion =  ApexPages.currentPage().getParameters().get('region');
        sactid = ApexPages.currentPage().getParameters().get('acctId');
        susrid = ApexPages.currentPage().getParameters().get('userId');
        datee = ApexPages.currentPage().getParameters().get('Date');
        sviewname = ApexPages.currentPage().getParameters().get('Viewname');
        //system.debug('@@parameters ' + sregion + ' -- ' + sactid + ' -- ' + susrid + ' -- ' + datee);
      
        List<calEventM> listobjcalEvtM = new List<calEventM>();
        eventsM = getCalenderEvents(sregion,susrid,sactid,datee,'No',sviewname);
        
       for(String SUserId : listCallUser.keySet())
       {
           //system.debug('@@@Constructor'+ listCallUser);
           if(listCallUser.get(SUserId ).isEventAvailable == False )
           {
             calEventM myEvent1 = new calEventM();
             myEvent1.SfId = '999999999';
             myEvent1.UserId = listCallUser.get(SUserId ).userId;
             myEvent1.userIdName = listCallUser.get(SUserId ).userIdName ;
             eventsM.add(myEvent1);
            }
       }
        
    }
        
    
     
    public List<calEventM> getCalenderEvents(string Region,string sUserID,string sAcctID,String SDate,String Status, String Viewname) {
    
        //system.debug('@@method');
        String[] Regresult = Region.split(',\\s*');
        String[] Usrresult = sUserID.split(',\\s*');
        String[] Acctresult = sAcctID.split(',\\s*');
        Map<ID,User> users = new Map<ID,User>();
        //system.debug('@@listview1  ' + Region + ' -- ' + sUserID + ' -- ' + sAcctID + ' -- ' + SDate);
        
        DateTime StartDate;
        
        Integer sIntDate;
        Integer sIntMonth;
        Integer sIntYear;
        
        Integer eIntDate;
        
        Integer Seconds;
        Integer minutes;
        Integer hrs;
        Decimal disminutes;
        Decimal disseconds;
        Integer seconds1;
        
        Integer s_offset_hrs;
        Integer s_offset_mins;
        Integer s_offset_seconds;

        
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
        
        
        String[] mySDateOnly = SDate.split(' ');
        String[] strSDate = mySDateOnly[0].split('-');
        sIntDate = integer.valueOf(strSDate[2]);
        //system.debug('@@ Date ' + sIntDate);
        sIntMonth = integer.valueOf(strSDate[1]);
        //system.debug('@@ Month ' + sIntMonth);
        sIntYear = integer.valueOf(strSDate[0]);
        //system.debug('@@ Year ' + sIntYear);
        if(Viewname != 'timelineDay')
        {
            eIntDate = sIntDate+6;
        }
        else
        {
          eIntDate = sIntDate;  
        }
        Date stdt = Date.newInstance(sIntYear,sIntMonth,sIntDate);
        Date edt = Date.newInstance(sIntYear,sIntMonth,eIntDate);
        
        Date startOfWeek;
        Date weekSDate;
        Date weekEDate;
        dt1Long = DateTime.now().getTime();
        
        try{ 
                if(Viewname != 'timelineDay')
                {        
                     startOfWeek = stdt.toStartOfWeek();            
                     weekSDate = startOfWeek.addDays(1);
                     weekEDate = startOfWeek.addDays(6);
                     StartDate = DateTime.newInstance(weekSDate.year(),weekSDate.month(),weekSDate.day(),s_offset_hrs,s_offset_mins,s_offset_seconds);
                     EndDate = StartDate.addDays(6).addDays(1).addSeconds(-1);
                    system.Debug('@@Duration  :'+ StartDate + ' EndDate ' + EndDate );
                }
                else
                {
                    //StartDate = DateTime.newInstance(weekSDate.year(),weekSDate.month(),weekSDate.day(),s_offset_hrs,s_offset_mins,s_offset_seconds);
                    //EndDate = StartDate.addDays(0).addDays(1).addSeconds(-1);
                    StartDate = DateTime.newInstance(stdt.year(),stdt.month(),stdt.day(),s_offset_hrs,s_offset_mins,s_offset_seconds);
                    EndDate = StartDate.addDays(0).addDays(1).addSeconds(-1);
                    system.Debug('@@else  :'+ StartDate + ' EndDate ' + EndDate );
                }
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        
        string usid;
        string IndeUsrId;
        eventsM = new list<calEventM>();
        userlist = new List<User>();
        acctlist = new List<Account>();
        list<User> uncovereduser = new List<User>();
        list<User> independentuser = new List<User>();
       
        uncovereduser = [SELECT Id FROM User where IsActive = true and name like '%UnCovered%' limit 1];
        
        if(uncovereduser.size() > 0){
            usid = String.valueOf(uncovereduser[0].id); 
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
                    userlist = [SELECT id FROM user where Region__c = : Regresult and isactive = true order by name ];
                    userlist.addAll(uncovereduser); 
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
       system.debug('@@userlist  ' + userlist);
        Set<Id> actid = new Set<Id>();
        Set<Id> conid = new Set<Id>();
        Set<Id> usrid = new Set<Id>();
        Set<Id> rid = new Set<Id>();
        List<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' and (Name = :ProcedureRecordtype)];
        List<RecordType> rtstd = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' and (Name = :SJMRecordtype)];
        //system.debug('@@rtstd ' + rtstd);
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
                              RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c,SortByUncovered__c
                              FROM Event
                              WHERE OwnerId != null and OwnerId = : userlist 
                              and Accountid = :acctlist 
                              and (StartDateTime != null or EndDateTime != null) 
                              and RecordTypeId = :rid 
                              and StartDateTime >= :StartDate 
                              and EndDateTime <= :EndDate 
                              and Status__c!= 'Cancelled' order by SortByUncovered__c desc
                              LIMIT 50000]);
                              
                 objEventPTO = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,
                                 AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c,SortByUncovered__c 
                                 from Event 
                                 where OwnerId != null and OwnerId = : userlist 
                                 and (StartDateTime != null or EndDateTime != null) 
                                 and RecordTypeId = :rtstd and StartDateTime >= :StartDate 
                                 and EndDateTime <= :EndDate and Status__c!= 'Cancelled' order by SortByUncovered__c desc 
                                 limit 50000]);     
                 system.Debug('@@objEventPTOAcctId :'+ objEventPTO);       
            }
            
            objEvent.addAll(objEventPTO);
                    
        }
        else
        {
            if(Status == 'No')  
            {                   
                objEvent = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,AccountId,RecordTypeId,
                              WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c from Event 
                              where OwnerId != null and OwnerId = : userlist 
                              and AccountId = : acctlist and AccountId != null 
                              and (StartDateTime != null or EndDateTime != null) and RecordTypeId = :rid and StartDateTime >= :StartDate and EndDateTime <= :EndDate 
                              and Status__c!= 'Cancelled' order by SortByUncovered__c desc limit 50000]); 
                              
                objEventPTO = ( [SELECT IsAllDayEvent, Assignment_Status__c,StartDateTime,EndDateTime,Id,Subject,OwnerId,
                                 AccountId,RecordTypeId,WhoId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Comments__c,Call_in_Date__c 
                                 from Event 
                                 where OwnerId != null and OwnerId = : userlist 
                                 and (StartDateTime != null or EndDateTime != null) 
                                 and RecordTypeId = :rtstd and StartDateTime >= :StartDate 
                                 and EndDateTime <= :EndDate and Status__c!= 'Cancelled' limit 50000]); 
                                 
                system.Debug('@@objEventPTO :'+ objEventPTO);                
            }
            
            objEvent.addAll(objEventPTO);
        }                       
                              
       
       List<id> accountIds = new List<id>();
        for(Event objEvtItem : objEvent){
            if (objEvtItem.AccountId != null || objEvtItem.AccountId != '')
            {
                accountIds.add(objEvtItem.AccountId);
            }
        }
        
        if(objEvent.size()>0)
        {
            try{
                for(event ent:objEvent)
                {
                    actid.add(ent.AccountId);
                    conid.add(ent.WhoId);
                    usrid.add(ent.OwnerId);
                }
                Map<ID,Account> accounts = new Map<ID,Account>([SELECT Id,name FROM Account where Id =:actid]);
                Map<ID,Contact> contacts = new Map<ID,Contact>([SELECT Id,name FROM Contact where Id =:conid]);
                users = new Map<ID,User>([SELECT Id,name FROM User where Id =:userlist ]);
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
                    
                    if(myEvent.StartHour < 12)
                    {
                        sAMorPM = 'AM';
                    }
                    else
                    {
                        if(myEvent.StartHour > 12)
                        {
                          myEvent.StartHour = (myEvent.StartHour - 12);  
                        }
                         sAMorPM = 'PM';   
                    }                  

                    if(evnt.Call_in_Date__c != null)
                    {
                        myEvent.CallInDate = (evnt.Call_in_Date__c).format();
                        
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
                   
                      if(myEvent.EndHour > 12)
                        {
                          myEvent.EndHour = (myEvent.EndHour - 12);  
                          eAMorPM = 'PM';
                        }
                      else
                        {
                            eAMorPM = 'AM';
                        }
                        
                    
                    if(myEvent.StartMinute > 0)
                    {
                       startminutes = String.valueOf(myEvent.StartMinute);
                       if(myEvent.EndMinute > 0)
                       {
                           endminutes =  String.valueOf(myEvent.EndMinute);
                           myEvent.EvtStartDate = myEvent.StartMonth + '/' +  myEvent.StartDay + '/' + myEvent.StartYear + ' ' + myEvent.StartHour + ':' + startminutes + ' ' + sAMorPM + ' to ' + myEvent.EndHour + ':' + endminutes + ' ' + eAMorPM;
                       }
                       else
                       {
                           myEvent.EvtStartDate = myEvent.StartMonth + '/' +  myEvent.StartDay + '/' + myEvent.StartYear + ' ' + myEvent.StartHour + ':' + startminutes + ' ' + sAMorPM +' to ' + myEvent.EndHour + ' ' + eAMorPM;
                       }
                    }
                    
                    else
                    {
                        myEvent.EvtStartDate = myEvent.StartMonth + '/' +  myEvent.StartDay + '/' + myEvent.StartYear + ' ' + myEvent.StartHour + ' ' + sAMorPM + ' to ' + myEvent.EndHour + ' ' + eAMorPM;
                    }
                    
                     if(evnt.Subject != null){
                        myEvent.title = 'Title: ' + evnt.Subject;
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
                        myEvent.ContIdName = 'Dr: ' + contacts.get(evnt.WhoId).name;
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
                                   
                    if(evnt.Comments__c != '' && evnt.Comments__c != null)
                    {
                        myEvent.Description = 'Notes: ' + evnt.Comments__c;
                    }
                    else
                    {
                        myEvent.Description = '';
                    }
                    
                    myEvent.SfId = evnt.Id;
                    
                    if(evnt.OwnerId != null){
                        myEvent.UserId = evnt.OwnerId ;
                        myEvent.UserIdName = users.get(evnt.OwnerId).name;
                    }
                    else
                    {
                        myEvent.UserId = '';
                    }
                    
                    
                    if(evnt.RecordTypeId != null){
                        myEvent.RcrdTypeName = rtMap.get(evnt.RecordTypeId).getName(); 
                        //if(myEvent.RcrdTypeName == 'SJM Standard Event')
                        //{
                             //if(evnt.Subject != null)
                             //{
                                //myEvent.title = evnt.Subject;
                             //}
                             //else
                             //{
                                //myEvent.title = '';
                             //}
                        //}
                    }
                    else
                    {
                        myEvent.RcrdTypeName = '';
                    }
                    
                    
                    //myEvent.prmcasediag = myEvent.PrmCasWillUse + ' - ' + myEvent.PrmDiagonosis;
                    //myEvent.prmcasediag = myEvent.PrmDiagonosis;
                    //system.debug('@@myEvent  ' + myEvent);
                    
                    
                    if(listCallUser.isEmpty() || !(listCallUser.containsKey(myEvent.UserId))){
                        CalUser objCallUser = new  CalUser();
                        objCallUser.UserId = myEvent.UserId;
                        objCallUser.UserIdName = myEvent.UserIdName;
                        objCallUser.isEventAvailable = True;
                        listCallUser.put( myEvent.UserId,objCallUser);
                    }
                    eventsM.add(myEvent);
                    system.debug('@@calllEventM  ' + eventsM);
                }
                 
                for(User objUser1 : userlist)
                {             
                 if(!(listCallUser.containsKey(objUser1.id)))
                 {               
                    CalUser objCallUser1 = new  CalUser();
                    objCallUser1.UserId = objUser1.id;
                    objCallUser1.UserIdName = users.get(objUser1.id).name;
                    objCallUser1.isEventAvailable = False;
                    listCallUser.put( objUser1.id,objCallUser1);
                 }
        
                }

            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
        } 
      
        return eventsM;
        
    }  
}