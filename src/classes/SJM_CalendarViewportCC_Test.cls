@isTest 
private class SJM_CalendarViewportCC_Test{
    static testMethod void runAsAllProfiles () {
        List<String> profiles = getTestProfilesList();
        
        for ( String profileName : profiles ) {
            List<Profile> profileRecords = [SELECT Id FROM Profile WHERE Name = :profileName ];
            if ( profileRecords!= null && profileRecords.size() > 0 ) {
                Profile profileRecord = profileRecords[0];
                User profileBasedUser = new User(Alias = profileName.replace(' ','').replace('-','_').left(8), Email = profileName.replace(' ','').replace('-','_') + '@testorg.com', EmailEncodingKey = 'UTF-8', LastName='Testing ' + profileName, LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileRecord.Id, TimeZoneSidKey='America/Los_Angeles', UserName=profileName.replace(' ','').replace('-','_') + '@testorg.com');
                
                System.runAs(profileBasedUser) {
                    SJM_CalendarViewportCC_Test();
                }
            }
        }
    }

  static testMethod void SJM_CalendarViewportCC_Test(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    
    Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
         acc.Name = 'Rouel';
        insert acc;
        
    Event eventEle = new Event();
        eventEle.WhatId = acc.id;
        eventEle.ActivityDate = Date.today();
        eventEle.Description = 'Test Event';
        eventEle.Subject = 'Test Subject';
        eventEle.ActivityDateTime = datetime.newInstance(2014, 02, 16, 3, 00, 00);
        eventEle.StartDateTime = datetime.newInstance(2014, 02, 16, 3, 00, 00);
        eventEle.EndDateTime = datetime.newInstance(2014, 02, 16, 4, 00, 00);
        

        insert eventEle;
        
        PageReference page = new PageReference('/apex/TestCalendar');
        Test.setCurrentPage(page);
        
        ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
        SJM_CalendarViewportCC latamCalendarViewObj = new SJM_CalendarViewportCC(sc);
        latamCalendarViewObj.selectedCountry2 = 'Test';
 
        String[] calDayTransStringArray = SJM_CalendarViewportCC.calendarDayTranslations(true);
        SJM_CalendarViewportCC.calendarDayTranslations(false);
        System.debug('calDayTransStringArraycalDayTransStringArray'+calDayTransStringArray);
        
        String[] calMonthTransStringArray = SJM_CalendarViewportCC.calendarMonthTranslations (true);
        SJM_CalendarViewportCC.calendarMonthTranslations (false);
        System.debug('calMonthTransStringArraycalMonthTransStringArray'+calMonthTransStringArray);
        
        SJM_CalendarViewportCC.getCalendarUsers();
        SJM_CalendarViewportCC.getCalendarSQLStatement2('2014-02-16 3:00:00','2014-02-16 3:00:00');
        SJM_CalendarViewportCC.getCalendarEvents2('2014-02-16 3:00:00','2014-02-16 3:00:00');
        SJM_CalendarViewportCC.getCalendarEvents3('2014-02-16 3:00:00','2014-02-16 3:00:00','true','SSP1','123456789','123456789');
        SJM_CalendarViewportCC.getCalendarEvents3('2014-02-16 3:00:00','2014-02-16 4:00:00','false','SSP1','123456789','123456789');
        SJM_CalendarViewportCC.getCalendarCountSQLStatement3('2014-02-16 3:00:00','2014-02-16 4:00:00','true');
        SJM_CalendarViewportCC.getCalendarCountSQLStatement3('2014-02-16 3:00:00','2014-02-16 4:00:00','false');
        SJM_CalendarViewportCC.getCalendarModifiedCountSQLStatement4('2014-02-16 3:00:00','2014-02-16 4:00:00','2014-02-16 4:11:00','true');
        SJM_CalendarViewportCC.getCalendarModifiedCountSQLStatement4('2014-02-16 3:00:00','2014-02-16 4:12:00','2014-02-16 4:11:00','false');
        SJM_CalendarViewportCC.getCalendarEventsCount4('2014-02-16 3:00:00','2014-02-16 4:12:00','2014-02-16 4:11:00','true');
        SJM_CalendarViewportCC.getCalendarEventsCount4('2014-02-16 3:00:00','2014-02-16 4:12:00','2014-02-16 4:11:00','false');
        SJM_CalendarViewportCC.getCalendarSQLStatement();        
        SJM_CalendarViewportCC.getUsersList('SSP1');
        SJM_CalendarViewportCC.getAcctsList('SSP1');
        SJM_CalendarViewportCC.getCalendarEvents();
    }
    static testMethod void getUserRegions_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        SJM_CalendarViewportCC  myPageTestCalenda = new SJM_CalendarViewportCC(sc);
        List<SelectOption> testoptions1=myPageTestCalenda.getUserRegions();        
    }
    static testMethod void getProperties_Test(){
        SJM_CalendarViewportCC.calendarEvent ce = new SJM_CalendarViewportCC.calendarEvent();
        ce.Id = 1;
        ce.StartYear = 2000;
        ce.StartMonth = 2001;
        ce.StartDay = 2002;
        ce.StartHour = 2003;
        ce.StartMinute = 2004;
        ce.StartSecond = 2004;
        ce.EndYear = 2005;
        ce.EndMonth = 2006;
        ce.EndDay = 2007;
        ce.EndHour = 2008;
        ce.EndMinute = 2009;
        ce.EndSecond = 2010;

        ce.Title = 'Test1';
        ce.SfId = 'Test2';
        ce.AcctIdName = 'Test3';
        ce.ContIdName = 'Test33';
        ce.PrmCasWillUse = 'Test4';
        ce.PrmDiagonosis = 'Test5';
        ce.EventStatus = 'Assigned';
        ce.UserId = 'Test6';
        ce.UserIdName = 'Test7';
        //ce.EventRecord = 'Test8';
        ce.RcrdTypeName = 'SJM Standard Event';
        ce.UserIdColor = '#99999';
        SJM_CalendarViewportCC.Acctdetails ce1 = new SJM_CalendarViewportCC.Acctdetails();
        ce1.AcctId = 'Test9';
        ce1.AcctIdName = 'Test10';
        SJM_CalendarViewportCC.Contdetails ce2 = new SJM_CalendarViewportCC.Contdetails();
        ce2.ContId = 'Test11';
        ce2.ContIdName = 'Test12';
    }
    public static List<String> getTestProfilesList () {
        List<String> profiles = new List<String>();
        profiles.add('CLAG Agent (New)');
        profiles.add('CLAG Manager');
        profiles.add('CLAG Preferencial Client User');
        profiles.add('CLAG System Administrator');
        
        return profiles;
    }
        
}