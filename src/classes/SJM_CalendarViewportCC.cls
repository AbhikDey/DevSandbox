global class SJM_CalendarViewportCC{
    
    //global List<Event> MyEvents {get;set;}
    global String selectedCountry2{get;set;}
   
    global class userList{
        public String id {get;set;}        
        public String name {get;private set;}
        }
        
    global class AccountList{
        public String id {get;set;}        
        public String name {get;private set;}
    }         
        
    global class calendarEvent {
        public Integer Id {get;set;}
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

        public string Title {get;set;}
        public string SfId {get;set;}
        public string AcctIdName {get;set;}
        public string ContIdName {get;set;}
        public string RcrdTypeName {get;set;}
        public string PrmCasWillUse {get;set;}
        public string PrmDiagonosis {get;set;}
        public string EventStatus {get;set;}
        public string UserId {get;set;}
        public string UserIdName {get;set;}
        public string UserIdColor {get;set;}

        public Event EventRecord {get;set;}
       
    }
    
    global class DateParts {
        //public Decimal Year {get;set;}
        //public Decimal Month {get;set;}
        //public Decimal Day {get;set;}
        //public Decimal Hour {get;set;}
        //public Decimal Minute {get;set;}
        //public Decimal Second {get;set;}
    }
    
    global class CalendarUser {
        public String UserId {get;set;}
        public String UserIdName {get;set;}
        public String ManagerId {get;set;}
        public String ManagerIdName {get;set;}
    }
    
    global class Acctdetails {
        public String AcctId {get;set;}
        public String AcctIdName {get;set;}
        
    }
    
     global class Contdetails {
        public String ContId {get;set;}
        public String ContIdName {get;set;}
        
    }
    
    //public Map<string,DateParts> StartDatesParts {get;set;}
    //public Map<string,DateParts> EndDatesParts {get;set;}
    public String[] calendarDayNamesShort {get;set;}
    public String[] calendarDayNamesLong {get;set;}
    public String[] calendarMonthNamesShort {get;set;}
    public String[] calendarMonthNamesLong {get;set;}
    public String[] calendarColors {get;set;}
    public String[] calendarLightColors {get;set;}
    public String defaultRecordTypeId {get;set;}
    
    public static String[] getTranslatedJsStringArrayValues (String valuesCommaSeparatedList ) {
        String[] valuesArray = valuesCommaSeparatedList.split(',');
        for ( Integer index = 0; index < valuesArray.size(); index++  ) {
            valuesArray[index] = '\'' + valuesArray[index] + '\'';
        }
        return valuesArray;
    }
    
    public SJM_CalendarViewportCC(ApexPages.StandardController stdController) {
        calendarDayNamesShort = getTranslatedJsStringArrayValues(Label.CalendarDayNamesShort);
        calendarDayNamesLong = getTranslatedJsStringArrayValues(Label.CalendarDayNamesLong);
        calendarMonthNamesShort = getTranslatedJsStringArrayValues(Label.CalendarMonthNamesShort);
        calendarMonthNamesLong = getTranslatedJsStringArrayValues(Label.CalendarMonthNamesLong);
        calendarColors = getTranslatedJsStringArrayValues(Label.CalendarColors);
        calendarLightColors = getTranslatedJsStringArrayValues(Label.CalendarLightColors);
        
        for (Schema.RecordTypeInfo rtInfo : Event.SObjectType.getDescribe().getRecordTypeInfos()) {
          if (rtInfo.isDefaultRecordTypeMapping()) {
            this.defaultRecordTypeId = rtInfo.getRecordTypeId();
          }
        }        
    }

      /*public List<SelectOption> getUserRegions() {
      List<SelectOption> regions = new List<SelectOption>();  
      ID usrID = UserInfo.getUserId();
      String usrArea;
      String usrRegion;
      
      if(usrID != null){
        user u = new user();
        u = [Select Id, Region__c, Area__c from user where Id=:usrID];
        usrArea = u.Area__c;
        usrRegion = u.Region__c;
      }
      
      AggregateResult[] results  = [SELECT Region__c, COUNT(ID) FROM user Where IsActive=true and Area__c != null and Region__c != null and Area__c=:usrArea group by Region__c order by Region__c];
      String Region;
      //regions.add(new SelectOption( 'Unassigned','Unassigned'));
      
      for (AggregateResult ar : results) {
          Region = (String) ar.get('Region__c');
             regions.add(new SelectOption(Region, Region));   
      }
 
        //Default to User Region
        selectedCountry2 = usrRegion;
        return regions;
        
    }*/
    
    public List<SelectOption> getUserRegions() {
      List<SelectOption> regions = new List<SelectOption>();
      List<Regional_Admins__c> regadmin = new List<Regional_Admins__c>();  
      ID usrID = UserInfo.getUserId();
      
      String usrArea;
      String usrRegion;
      AggregateResult[] results;
      
      if(usrID != null){
        user u = new user();
        u = [Select Id, Region__c, Area__c from user where Id=:usrID];
        usrArea = u.Area__c;
        usrRegion = u.Region__c;
      }
      
      if(usrArea != null && usrRegion != null)
      {
          results  = [SELECT Region__c, COUNT(ID) FROM user Where IsActive=true and Area__c != null and Region__c != null and Area__c=:usrArea group by Region__c order by Region__c];
      }
      else
      {
          results  = [SELECT Region__c, COUNT(ID) FROM user Where IsActive=true and Region__c != null group by Region__c order by Region__c];
      }
      String Region;
      
      for (AggregateResult ar : results) {
              Region = (String) ar.get('Region__c');
             regions.add(new SelectOption(Region, Region));   
      }
 
        //Default to User Region
        if(usrRegion != null)
        {
            selectedCountry2 = usrRegion;
        }
        return regions;
        
    }
     
   
   @RemoteAction
    global static List<userList> getUsersList(String Region) {
    
     String[] Regresult = Region.split(',\\s*');
     
     List<userList> objUsers= new List<userList>();
     List<User> selectUsers = new List<User>();
     
     /*if( Region != ''){
      selectUsers = [SELECT id,name FROM user where  Region__c = :Region and IsActive = true order by name];
     }
     else
     {
      selectUsers = [SELECT id,name FROM user where Profile.Name = 'SJM Customer Service' and IsActive = true order by name];
     }*/
     
      selectUsers = [SELECT id,name FROM user where  Region__c = :Regresult and IsActive = true and Region__c != null order by name];

        for(User oUser :selectUsers )
        {
           userList objUser = new userList ();
           objUser.id = oUser.id;
           objUser.name = oUser.name;
           objUsers.add(objUser);
        }
        
        return objUsers;
    }
    
    @RemoteAction
    global static List<AccountList> getAcctsList(String Region) {
     String[] Regresult = Region.split(',\\s*');
     List<Account> acct = new List<Account>();
     List<AccountList> objAccounts = new List<AccountList>();
     
      acct = [SELECT id,name FROM account where USD_AF_Region__c = :Regresult and USD_AF_Region__c != null and name != null order by name];
     
        for(Account oAcct :acct)
        {
           AccountList objAcc = new AccountList();
           objAcc.id = oAcct.id;
           objAcc.name = oAcct.name;
           objAccounts.add(objAcc); 
        }
         
        return objAccounts;
    }


    @RemoteAction
    global static String[] calendarDayTranslations (Boolean isAbbreviated) {
        String[] translatedValues;
    
        if ( isAbbreviated ) {
            translatedValues = getTranslatedJsStringArrayValues(Label.CalendarDayNamesShort);
        } 
        else {
            translatedValues = getTranslatedJsStringArrayValues(Label.CalendarDayNamesLong);
        }
    
        return translatedValues;
    }

    @RemoteAction
    global static String[] calendarMonthTranslations (Boolean isAbbreviated) {
        String[] translatedValues;
    
        if ( isAbbreviated ) {
            translatedValues = getTranslatedJsStringArrayValues(Label.CalendarMonthNamesShort);
        } 
        else {
            translatedValues = getTranslatedJsStringArrayValues(Label.CalendarMonthNamesLong);
        }
    
        return translatedValues;
    }

    public static Map<String,CalendarUser> getCalendarUsers() {
        Map<String,CalendarUser> calendarUsers = new Map<String,CalendarUser>();
        Set<Id> ownerIds = new Set<Id>();

        String eventsSQL = 'SELECT id, OwnerId FROM Event Where StartDateTime >= LAST_N_DAYS:30 limit 50000';
        List<Event> events = Database.query(eventsSQL);
        for (Event e : events ) {
            ownerIds.add(e.OwnerId);
        }

        String usersSQL = CS_UtilSObject.buildQuery(Schema.SObjectType.User) + ' WHERE Id IN :ownerIds ORDER BY Name ';
        List<User> users = Database.query(usersSQL);
        for (User u : users) {
            CalendarUser cu = new CalendarUser();
            cu.UserId = u.id;
            cu.UserIdName = u.name;
            cu.ManagerId = u.id;
            cu.ManagerIdName = u.name;
            calendarUsers.put(u.id,cu);
        }
        
        return calendarUsers;
    }
    
    
    public static Map<String,Acctdetails> getCalendarAccts() {
        Map<String,Acctdetails> calendarAccts = new Map<String,Acctdetails>();
        
        Set<Id> acctIds = new Set<Id>();

        String eventsSQL = 'SELECT id, AccountId FROM Event where AccountId != null and StartDateTime >= LAST_N_DAYS:30 limit 50000';
        List<Event> events = Database.query(eventsSQL);
        for (Event e : events ) {
            acctIds.add(e.AccountId);
        }

        String acctSQL = CS_UtilSObject.buildQuery(Schema.SObjectType.Account) + ' WHERE Id IN :acctIds ORDER BY Name ';
        List<Account> accts = Database.query(acctSQL);
        
        for (Account act : accts) {
            Acctdetails acctdetail = new Acctdetails();
            acctdetail.AcctId = act.id;
            acctdetail.AcctIdName = act.name;
           
            calendarAccts.put(act.id,acctdetail);
            
        }
        
       return calendarAccts; 
    }
    
    
    public static Map<String,Contdetails> getCalendarContact() {
        Map<String,Contdetails> calendarCont = new Map<String,Contdetails>();
        
        Set<Id> contIds = new Set<Id>();

        String eventsSQL = 'SELECT id, WhoId FROM Event where WhoId != null and StartDateTime >= LAST_N_DAYS:30 limit 50000';
        List<Event> events = Database.query(eventsSQL);
        for (Event e : events ) {
            contIds.add(e.WhoId);
        }
        
        String contSQL = CS_UtilSObject.buildQuery(Schema.SObjectType.Contact) + ' WHERE Id IN :contIds';
        List<Contact> conts = Database.query(contSQL);
        
        for (Contact contacts : conts) {
            Contdetails contdetail = new Contdetails();
            contdetail.ContId = contacts.id;
            contdetail.ContIdName = contacts.name;
           
            calendarCont.put(contacts.id,contdetail);
        }
        
       return calendarCont; 
    }

    @RemoteAction
    global static List<calendarEvent> getCalendarEvents3(String fromDateString, String toDateString, String currentUserOnly ,String Region,String sUserID, String sAcctId ) {
        
        String[] Regresult = Region.split(',\\s*');
        String[] Acctresult = sAcctId.split(',\\s*');
        String[] Usrresult = sUserID.split(',\\s*');
        
        List<calendarEvent> calendarEventsList = new List<calendarEvent>();
        Map<String,CalendarUser> users = getCalendarUsers();
        Map<String,Acctdetails> accts = getCalendarAccts();
        Map<String,Contdetails> conts = getCalendarContact();
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Event.getRecordTypeInfosById();
        
        String eventsSQL = getCalendarSQLStatement3 (fromDateString, toDateString, currentUserOnly);
        String currentUserId = UserInfo.getUserID();
        List<User> userlist = new List<User>();
        List<Account> acctlist = new List<Account>();
        
         /*if (Region  != 'Unassigned') 
         {
             if(sUserID != '')
             {
                 userlist = [SELECT id FROM user where Region__c = :Region and id = :sUserID and IsActive = true order by name];
             }
             else
             { 
                  userlist = [SELECT id FROM user where Region__c = :Region and IsActive = true order by name];
             }
         }
         else
         {
          
             if(sUserID != '')
               {
                  userlist = [SELECT id FROM user where Profile.Name = 'SJM Customer Service' and id = :sUserID and IsActive = true order by name];
               }
             else
             { 
               userlist = [SELECT id FROM user where Profile.Name = 'SJM Customer Service' and IsActive = true order by name];
             }
         }
       
        List<Event> eventsList = Database.query(eventsSQL + ' and OwnerId = : userlist');*/
        if(Region != '')
         {
             if(sAcctId != '')
             {
                 acctlist = [SELECT Id FROM account where USD_AF_Region__c = :Regresult and Id = :Acctresult and USD_AF_Region__c != null order by name];
             }
             else
             { 
                  //acctlist = [SELECT Id FROM account where USD_AF_Region__c = :Regresult and USD_AF_Region__c != null order by name];
             }
             if(sUserID != '')
             {
                 userlist = [SELECT Id FROM user where Region__c = :Regresult and Id = :sUserID and IsActive = true order by name];
             }
             else
             { 
                  userlist = [SELECT Id FROM user where Region__c = :Regresult and IsActive = true order by name];
             }
          }  
          
        //List<Event> eventsList = Database.query(eventsSQL + ' and AccountId = : acctlist and OwnerId = : userlist'); 
        List<Event> eventsList = new List<Event>();
            if(sAcctId != '')
            {
                eventsList = Database.query(eventsSQL + ' and AccountId = : acctlist and OwnerId = : userlist');
            }
            else
            {
                eventsList = Database.query(eventsSQL + ' and OwnerId = : userlist');
            }

        Integer eventIndex = 1;
        for( Event e : eventsList ) {
            calendarEvent ce = new calendarEvent();
            ce.id = eventIndex;

            if ( e.StartDateTime != null) {
                ce.StartYear = e.StartDateTime.year();
                ce.StartMonth = e.StartDateTime.month()-1;
                ce.StartDay = e.StartDateTime.day();
                ce.StartHour = e.StartDateTime.hour();
                ce.StartMinute = e.StartDateTime.minute();
                ce.StartSecond = e.StartDateTime.second();
            }        
            
            if ( e.EndDateTime != null) {
                ce.EndYear = e.EndDateTime.year();
                ce.EndMonth = e.EndDateTime.month()-1;
                ce.EndDay = e.EndDateTime.day();
                ce.EndHour = e.EndDateTime.hour();
                ce.EndMinute = e.EndDateTime.minute();
                ce.EndSecond = e.EndDateTime.second();
            }
                    
            ce.Title = e.Subject;
            ce.SfId = e.Id;
            ce.UserId = e.OwnerId;
            ce.UserIdName = users.get(e.OwnerId).UserIdName;
            //ce.AcctIdName = accts.get(e.AccountId).AcctIdName;
            
             if(e.IsAllDayEvent == true)
            {
              ce.StartHour = 7;
              ce.EndHour = 16;  
            }
            
            if(e.AccountId != null ){
            ce.AcctIdName = accts.get(e.AccountId).AcctIdName;
            }
            else{
            ce.AcctIdName = '';
            
            }
            
            if(e.WhoId != null ){
                ce.ContIdName = conts.get(e.WhoId).ContIdName;
                
            }
            else
            {
                ce.ContIdName = '';
            }
            
            ce.RcrdTypeName = rtMap.get(e.RecordTypeId).getName();
            ce.PrmCasWillUse = e.Primary_Case_Will_Use__c;
            ce.PrmDiagonosis = e.Primary_Diagnosis__c;
            ce.EventStatus = e.Assignment_Status__c;
            ce.EventRecord = e;
            
            calendarEventsList.add(ce);
            eventIndex++;
        }             
        
        return calendarEventsList;
    }

    @RemoteAction
    global static Integer getCalendarEventsCount4(String fromDateString, String toDateString, String lastModifiedDateString, String currentUserOnly) {
        String eventsSQL = getCalendarCountSQLStatement3 (fromDateString, toDateString, currentUserOnly);
        String currentUserId = UserInfo.getUserID();
        Integer count = Database.countQuery(eventsSQL);
        if (count == null) {
            count = 0;
        }
        
        Integer lastModifiedCount = 0;
        try {
            eventsSQL = getCalendarModifiedCountSQLStatement4 (fromDateString, toDateString, lastModifiedDateString, currentUserOnly);
            currentUserId = UserInfo.getUserID();
            lastModifiedCount = Database.countQuery(eventsSQL);
            if (lastModifiedCount == null) {
                lastModifiedCount = 0;
            }
        }
        catch(Exception ex) {
        }
        
        return count+lastModifiedCount;
    }

    @RemoteAction
    global static List<calendarEvent> getCalendarEvents2(String fromDateString, String toDateString) {
        String currentUserOnly = 'true';
        return getCalendarEvents3( fromDateString, toDateString, currentUserOnly,'','','') ;
    }

    @RemoteAction
    global static List<calendarEvent> getCalendarEvents() {
        Datetime fromDate = Date.today().toStartofWeek();
        Datetime toDate = fromDate + 7;
        String currentUserOnly = 'true';
        return getCalendarEvents3( fromDate.format('yyyy-MM-dd HH:mm:ss'), toDate.format('yyyy-MM-dd HH:mm:ss'), currentUserOnly,'','','') ;
    }

    @RemoteAction
    global static string getCalendarCountSQLStatement3 (String fromDateString, String toDateString, String currentUserOnly) {
        DateTime fromDate = datetime.valueOf(fromDateString);
        DateTime toDate = datetime.valueOf(toDateString);

        String whereClause = 'id != null ';
        if (fromDate != null) {
            whereClause = whereClause + 'AND StartDateTime > ' + fromDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'') + ' ';
        }
        if (toDate!= null) {
            whereClause = whereClause + 'AND StartDateTime < ' + (toDate+1).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'') + ' ';
        }
        if (currentUserOnly == 'true') {
            whereClause = whereClause + 'AND OwnerId = :currentUserId ';
        }

        String eventsSQL = 'SELECT COUNT() FROM Event WHERE ' + whereClause;
        
        return eventsSQL;
    }

    @RemoteAction
    global static string getCalendarModifiedCountSQLStatement4 (String fromDateString, String toDateString, String lastModifiedDateString, String currentUserOnly) {
        DateTime fromDate = datetime.valueOf(fromDateString);
        DateTime toDate = datetime.valueOf(toDateString);
        DateTime lastModifiedDate = datetime.valueOf(lastModifiedDateString);

        String whereClause = 'id != null ';
        if (fromDate != null) {
            whereClause = whereClause + 'AND StartDateTime > ' + fromDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'') + ' ';
        }
        if (toDate!= null) {
            whereClause = whereClause + 'AND StartDateTime < ' + (toDate+1).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'') + ' ';
        }
        if (lastModifiedDate!= null) {
            whereClause = whereClause + 'AND LastModifiedDate > ' + (lastModifiedDate).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'') + ' ';
        }
        if (currentUserOnly == 'true') {
            whereClause = whereClause + 'AND OwnerId = :currentUserId ';
        }

        String eventsSQL = 'SELECT COUNT() FROM Event WHERE ' + whereClause;
        
        return eventsSQL;
    }

    @RemoteAction
    global static string getCalendarSQLStatement3 (String fromDateString, String toDateString, String currentUserOnly) {
        DateTime fromDate = datetime.valueOf(fromDateString);
        DateTime toDate = datetime.valueOf(toDateString);

        String whereClause = 'id != null ';
        if (fromDate != null) {
            whereClause = whereClause + 'AND StartDateTime > ' + fromDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'') + ' ';
        }
        if (toDate!= null) {
            whereClause = whereClause + 'AND StartDateTime < ' + (toDate+1).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'') + ' ';
        }
        if (currentUserOnly == 'true') {
            whereClause = whereClause + 'AND OwnerId = :currentUserId ';
        }
        
        
        String eventsSQL = CS_UtilSObject.buildQuery(Schema.SObjectType.Event) + ' WHERE ' + whereClause;
        
        return eventsSQL;
    }

    @RemoteAction
    global static string getCalendarSQLStatement2 (String fromDateString, String toDateString) {
        String currentUserOnly = 'true';
        String currentUserId = UserInfo.getUserID();
        
        return getCalendarSQLStatement3 (fromDateString, toDateString, currentUserOnly).replace(':currentUserId','\'' + currentUserId + '\'');
   }

    @RemoteAction
    global static string getCalendarSQLStatement () {
        Date startOfWeek = Date.Today().toStartofWeek();
        Datetime fromDate = datetime.newInstance(startOfWeek.year(), startOfWeek.month(),startOfWeek.day());
        Datetime toDate = fromDate + 7;
        String currentUserOnly = 'true';
        String currentUserId = UserInfo.getUserID();
        
        return getCalendarSQLStatement3 (fromDate.format('yyyy-MM-dd HH:mm:ss'), toDate.format('yyyy-MM-dd HH:mm:ss'), currentUserOnly).replace(':currentUserId','\'' + currentUserId + '\'');
   }
   
   
   
}