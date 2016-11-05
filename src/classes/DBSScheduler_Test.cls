@isTest
private class DBSScheduler_Test{
     static testMethod void runAsAllProfiles () {
        List<String> profiles = getTestProfilesList();
        for ( String profileName : profiles ) {
            List<Profile> profileRecords = [SELECT Id FROM Profile WHERE Name = :profileName ];
            if ( profileRecords!= null && profileRecords.size() > 0 ) {
                Profile profileRecord = profileRecords[0];
                User profileBasedUser = new User(Alias = profileName.replace(' ','').replace('-','_').left(8), Email = profileName.replace(' ','').replace('-','_') + '@testorg.com', EmailEncodingKey = 'UTF-8', LastName='Testing ' + profileName, LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileRecord.Id, TimeZoneSidKey='America/Los_Angeles', UserName=profileName.replace(' ','').replace('-','_') + '@testorg.com');
                System.runAs(profileBasedUser) {
                    DBSScheduler_Test();
                    DBSScheduler_Test2();
                    DBSScheduler_Test3();
                    DBSScheduler_Test4();
                }
            }
        }
        
    }
    
    static testMethod void DBSScheduler_Test(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt7', Email='standarduser6633@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing8156', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6633@testorg.com',Scheduler_Country_Code__c = 'ALL');
        insert u;
        system.assertNotEquals(null, u.Id );
         
        //get SJM Standard Event DBS Procedure Scheduler  SJM Standard Event
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'DBS Procedure Scheduler']; 
        
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
        System.runAs(u){
            ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
            DBSScheduler.getCalenderEvents(u.id,acc.id,'false','false','2016-04-10','No','','GB');
            DBSScheduler.getCountries();
            DBSScheduler.setCountries('DE');
            DBSScheduler.getRecordId();
        }
    }
    
    static testMethod void DBSScheduler_Test2(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt8', Email='standarduser66338@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing81568', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP2',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser66338@testorg.com',Scheduler_Country_Code__c = 'DE;GB');
        insert u;
        system.assertNotEquals(null, u.Id );
         
        //get SJM Standard Event 
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'DBS Procedure Scheduler']; 
        
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Roue2';
        acc.USD_AF_Region__c='SSP2';
        
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        //create new contact
        contact con = new contact();
        con.AccountID = acc.id;
        con.firstname = 'testfname1';
        con.LastName = 'testLname1';
        con.Email = 'test1@test.com';
        con.Personal_Email__c = 'test2@test.com';
        con.Office_Phone__c = '12345789';
        con.HomePhone = '1211212';
        con.MobilePhone = '15665';
        insert con;    
        system.assertNotEquals(null, con.Id );
        
        //create new event
        Event eventEle = new Event();
        eventEle.OwnerId = u.id;
        eventEle.WhoId = con.id;
        eventEle.WhatId = acc.id; 
        eventEle.ActivityDate = Date.today();
        eventEle.Description = 'Test Event';
        eventEle.Subject = 'Test Subject';
        eventEle.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        eventEle.IsAllDayEvent = false;
        eventEle.recordTypeId = rt.id;
        eventEle.Status__c = 'Cancelled';  
        
        insert eventEle;

        System.runAs(u){
        ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
        DBSScheduler.getCalenderEvents(u.id,'','true','true','2016-04-10','No','','');
        //DBSScheduler.getAssigneList(eventEle.id,'karanam',eventEle.StartDateTime,eventEle.EndDateTime);
        DBSScheduler.getCountries();
        DBSScheduler.setCountries('DE');
        DBSScheduler.getRecordId();
        
        }
    }
    
    static testMethod void getProperties_Test(){
        DBSScheduler.calEventM ce = new DBSScheduler.calEventM();
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
        ce.SfId = '123456789';
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
        ce.EvtStatus = 'Open';
        ce.url = 'test.salesforce.com';
        
        
    }
    
    static testMethod void DBSScheduler_Test3(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt9', Email='standarduser66339@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing81569', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP3',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser66339@testorg.com',Scheduler_Country_Code__c = 'DE');
        insert u;
        system.assertNotEquals(null, u.Id );
         
        //get SJM Standard Event 
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'DBS Procedure Scheduler']; 
        
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Roue3';
        acc.USD_AF_Region__c='SSP3';
        
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        //create new contact
        contact con = new contact();
        con.AccountID= acc.id;
        con.firstname = 'testfname12';
        con.LastName = 'testLname12';
        con.Email = 'test@test.com';
        con.Personal_Email__c = 'test12@test.com';
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
        eventEle.StartDateTime = Date.today();
        eventEle.EndDateTime = Date.today();
        eventEle.IsAllDayEvent = false;
        eventEle.OwnerId = u.id;
        eventEle.WhoId = con.id;
        eventEle.recordTypeId = rt.id;
        eventEle.Status__c = 'Cancelled';  
        //eventEle.Assignment_Status__c = 'Uncovered';
        insert eventEle;

        System.runAs(u){
        ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
        DBSScheduler.getCalenderEvents('',acc.id,'false','false','2016-04-10','No','','');
        DBSScheduler.getCountries();
        DBSScheduler.setCountries('GB');
        }
        
    }
    
    static testMethod void DBSScheduler_Test4(){
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt91', Email='standarduser36339@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing81569', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP3',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser36339@testorg.com',Scheduler_Country_Code__c = 'DE');
        insert u;
        system.assertNotEquals(null, u.Id );
         
        //get SJM Standard Event 
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'SJM Standard Event']; 
        
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Roue3';
        acc.USD_AF_Region__c='SSP3';
        
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        //create new contact
        contact con = new contact();
        con.AccountID= acc.id;
        con.firstname = 'testfname112';
        con.LastName = 'testLname112';
        con.Email = 'test1@test.com';
        con.Personal_Email__c = 'test112@test.com';
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
        eventEle.StartDateTime = Date.today();
        eventEle.EndDateTime = Date.today();
        eventEle.IsAllDayEvent = true;
        eventEle.OwnerId = u.id;
        eventEle.WhoId = con.id;
        eventEle.recordTypeId = rt.id;
        eventEle.Status__c = 'Cancelled';  
       
        insert eventEle;

        System.runAs(u){
        ApexPages.StandardController sc = new ApexPages.standardController(eventEle);
        DBSScheduler.getCalenderEvents('','','false','false','2016-04-10','No','','');
        DBSScheduler.getCountries();
        DBSScheduler.setCountries('GB');
        }
        
    }

    public static List<String> getTestProfilesList () {
        List<String> profiles = new List<String>();
        profiles.add('CLAG Agent (New)');
        profiles.add('CLAG Manager');
        profiles.add('CLAG Preferencial Client User');
        profiles.add('CLAG System Administrator');
        
        return profiles;
    }
    
     static testMethod void getUsersList_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt9', Email='standarduser5133@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'test',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5133@testorg.com',Scheduler_Country_Code__c = 'DE');
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        DBSScheduler myPageTestCalenda = new DBSScheduler();
        List<SelectOption> testoptions1=myPageTestCalenda.getUsersList();        
    } 
    
    static testMethod void getItems_Test(){
    
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt99', Email='standarduser51333@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing12', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'test',Scheduler_Country_Code__c = 'DE',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser51333@testorg.com');
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        DBSScheduler myPageTestCalenda1 = new DBSScheduler();
        List<SelectOption> testoptions2 = myPageTestCalenda1.getItems();   
    }
    
    
    
     /* static testMethod void Assignelist_Test() {
        DBSScheduler.Assignelist AssigneeLists = new DBSScheduler.Assignelist();
        AssigneeLists.eid = '123';
        AssigneeLists.assignename = 'testName';  
        AssigneeLists.evtstarttime = '';
        AssigneeLists.evtendtime = '';     
    }*/
    
    /*static testMethod void getCountries_Test(){
         User usr = [SELECT Scheduler_Country_Code__c from user where id = :UserInfo.getUserId()];
         List<string> contryCod = String.valueOf(usr.Scheduler_Country_Code__c).split('\\;') ;       
     }*/
}