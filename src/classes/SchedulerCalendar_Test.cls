@isTest
private class SchedulerCalendar_Test{
     static testMethod void runAsAllProfiles () {
        List<String> profiles = getTestProfilesList();
        for ( String profileName : profiles ) {
            List<Profile> profileRecords = [SELECT Id FROM Profile WHERE Name = :profileName ];
            if ( profileRecords!= null && profileRecords.size() > 0 ) {
                Profile profileRecord = profileRecords[0];
                User profileBasedUser = new User(Alias = profileName.replace(' ','').replace('-','_').left(8), Email = profileName.replace(' ','').replace('-','_') + '@testorg.com', EmailEncodingKey = 'UTF-8', LastName='Testing ' + profileName, LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileRecord.Id, TimeZoneSidKey='America/Los_Angeles', UserName=profileName.replace(' ','').replace('-','_') + '@testorg.com');
                System.runAs(profileBasedUser) {
                    SchedulerCalendar_Test();
                    SchedulerCalendar_Test2();
                    SchedulerCalendar_Test3();
                }
            }
        }
        
    }
    
    static testMethod void SchedulerCalendar_Test(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt6', Email='standarduser663@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing815', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser663@testorg.com');
        insert u;
        system.assertNotEquals(null, u.Id );
         
        //get SJM Standard Event 
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'SJM Standard Event']; 
        
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Rouel';
        acc.USD_AF_Region__c='SSP1';
        
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        //create new contact
        contact con = new contact();
        con.AccountID= acc.id;
        con.firstname = 'testfname';
        con.LastName = 'testLname';
        con.Email = 'test@test.com';
        con.Personal_Email__c = 'test1@test.com';
        con.Office_Phone__c = '12345789';
        con.HomePhone = '1211212';
        con.MobilePhone = '15665';
        insert con;    
        system.assertNotEquals(null, con.Id );
        
        //create new event
        Event eventEle = new Event();
        eventEle.WhatId = acc.id; 
        eventEle.ActivityDate = Date.today();
        eventEle.Description = 'Test Event';
        eventEle.Subject = 'Test Subject';
        //eventEle.ActivityDateTime = Date.today();
        //eventEle.StartDateTime = Date.today();
        //eventEle.EndDateTime = Date.today();
        eventEle.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        eventEle.IsAllDayEvent = false;
        eventEle.OwnerId = u.id;
        eventEle.WhoId = con.id;
        eventEle.recordTypeId = rt.id;
        eventEle.Status__c = 'Open';  
        insert eventEle;
        system.debug('@insert' + eventEle);
        system.debug('@record' + eventEle.recordTypeId);
        system.debug('@status' + eventEle.Status__c);
        system.assertNotEquals(null, eventEle.Id);        
        
        ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
        SchedulerCalendar.sRegion  = 'Test';
        SchedulerCalendar.EndDate = datetime.newInstance(2016, 04, 17, 3, 00, 00);
        //getCalenderEvents(string Region,string sUserID,string sAcctID, String pclick, String nclick, String SDate, String Status, String ViewName)
        SchedulerCalendar.getCalenderEvents('SSP1',u.id,acc.id,'false','false','2016-04-10','No', 'Week');
        SchedulerCalendar.getUsersList('SSP1');
        SchedulerCalendar.getAcctsList('SSP1');
    }
    
    static testMethod void SchedulerCalendar_Test2(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt6', Email='standarduser663@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing815', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser663@testorg.com');
        insert u;
        system.assertNotEquals(null, u.Id );
         
        //get SJM Standard Event 
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'SJM Standard Event']; 
        
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Rouel';
        acc.USD_AF_Region__c='SSP1';
        
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        //create new contact
        contact con = new contact();
        con.AccountID= acc.id;
        con.firstname = 'testfname';
        con.LastName = 'testLname';
        con.Email = 'test@test.com';
        con.Personal_Email__c = 'test1@test.com';
        con.Office_Phone__c = '12345789';
        con.HomePhone = '1211212';
        con.MobilePhone = '15665';
        insert con;    
        system.assertNotEquals(null, con.Id );
        
        //create new event
        Event eventEle = new Event();
        eventEle.WhatId = acc.id; 
        eventEle.ActivityDate = Date.today();
        eventEle.Description = 'Test Event';
        eventEle.Subject = 'Test Subject';
        eventEle.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        eventEle.IsAllDayEvent = false;
        eventEle.OwnerId = u.id;
        eventEle.WhoId = con.id;
        eventEle.recordTypeId = rt.id;
        eventEle.Status__c = 'Open';  
        insert eventEle;
       
        system.assertNotEquals(null, eventEle.Id);        
        
        ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
        SchedulerCalendar.sRegion  = 'Test';
        SchedulerCalendar.EndDate = datetime.newInstance(2016, 04, 17, 3, 00, 00);
        //getCalenderEvents(string Region,string sUserID,string sAcctID, String pclick, String nclick, String SDate, String Status, String ViewName)
        SchedulerCalendar.getCalenderEvents('SSP1','','','true','true','2016-04-10','No', '');
        SchedulerCalendar.getUsersList('SSP1');
        SchedulerCalendar.getAcctsList('SSP1');
    }
    
    static testMethod void SchedulerCalendar_Test3(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt6', Email='standarduser663@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing815', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser663@testorg.com');
        insert u;
        system.assertNotEquals(null, u.Id );
         
        //get SJM Standard Event 
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'SJM Standard Event']; 
        
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Rouel';
        acc.USD_AF_Region__c='SSP1';
        
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        //create new contact
        contact con = new contact();
        con.AccountID= acc.id;
        con.firstname = 'testfname';
        con.LastName = 'testLname';
        con.Email = 'test@test.com';
        con.Personal_Email__c = 'test1@test.com';
        con.Office_Phone__c = '12345789';
        con.HomePhone = '1211212';
        con.MobilePhone = '15665';
        insert con;    
        system.assertNotEquals(null, con.Id );
        
        //create new event
        Event eventEle = new Event();
        eventEle.WhatId = acc.id; 
        eventEle.ActivityDate = Date.today();
        eventEle.Description = 'Test Event';
        eventEle.Subject = 'Test Subject';
        //eventEle.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.StartDateTime = Date.today();
        eventEle.EndDateTime = Date.today();
        eventEle.IsAllDayEvent = true;
        eventEle.OwnerId = u.id;
        eventEle.WhoId = con.id;
        eventEle.recordTypeId = rt.id;
        eventEle.Status__c = 'Open';  
        insert eventEle;
       
        system.assertNotEquals(null, eventEle.Id);        
        
        ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
        SchedulerCalendar.sRegion  = 'Test';
        SchedulerCalendar.EndDate = Date.today();
        //getCalenderEvents(string Region,string sUserID,string sAcctID, String pclick, String nclick, String SDate, String Status, String ViewName)
        SchedulerCalendar.getCalenderEvents('SSP1','',acc.id,'true','true','2016-04-10','yes', '');
        SchedulerCalendar.getUsersList('SSP1');
        SchedulerCalendar.getAcctsList('SSP1');
    }
    
    static testMethod void getProperties_Test(){
        SchedulerCalendar.calEventM ce = new SchedulerCalendar.calEventM();
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
        ce.AssignmentStatus = 'Assigned';
        ce.UserId = 'Test6';
        ce.UserIdName = 'Test7';
        ce.RcrdTypeName = 'SJM Standard Event';
        ce.ResourceId = 'TestResId';
        ce.IsAllDayEvent = false;
        ce.IsUncoveredUser = false;
        ce.url = 'test.salesforce.com';
        //ce.EndDate = DateTime.now();
    }
    
    public static List<String> getTestProfilesList () {
        List<String> profiles = new List<String>();
        profiles.add('CLAG Agent (New)');
        profiles.add('CLAG Manager');
        profiles.add('CLAG Preferencial Client User');
        profiles.add('CLAG System Administrator');
        
        return profiles;
    }
    
     static testMethod void getUserRegions_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt7', Email='standarduser513@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'test',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser513@testorg.com');
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        SchedulerCalendar  myPageTestCalenda = new SchedulerCalendar();
        List<SelectOption> testoptions1=myPageTestCalenda.getUserRegions();        
    }
    
    static testMethod void getAccountList_Test() {
        SchedulerCalendar.AccountList AccountLists = new SchedulerCalendar.AccountList();
        AccountLists.id = '123';
        AccountLists.name = 'testName';        
    }
}