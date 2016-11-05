@isTest
private class cloneRedirectExtension_Test {

static testMethod void runAsAllProfiles () {
        List<String> profiles = getTestProfilesList();
        for ( String profileName : profiles ) {
            List<Profile> profileRecords = [SELECT Id FROM Profile WHERE Name = :profileName ];
            if ( profileRecords!= null && profileRecords.size() > 0 ) {
                Profile profileRecord = profileRecords[0];
                User profileBasedUser = new User(Alias = profileName.replace(' ','').replace('-','_').left(8), Email = profileName.replace(' ','').replace('-','_') + '@testorg.com', EmailEncodingKey = 'UTF-8', LastName='Testing ' + profileName, LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileRecord.Id, TimeZoneSidKey='America/Los_Angeles', UserName=profileName.replace(' ','').replace('-','_') + '@testorg.com');
                System.runAs(profileBasedUser) {
                    testevtCloneController();
                }
            }
        }
        
    }
    

static testMethod void testevtCloneController() {
    // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.cloneRedirect;
        Test.setCurrentPage(pref);
        
   Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];     
         //create new user
        User u = new User(Alias = 'standt7', Email='standarduser6633@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing8155', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6633@testorg.com');
        insert u;
        system.assertNotEquals(null, u.Id );
        
        
        //get SJM Standard Event 
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'Procedure Scheduler']; 
        
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Rouel1';
        acc.USD_AF_Region__c='SSP1';
        
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        //create new contact
        contact con = new contact();
        con.AccountID= acc.id;
        con.firstname = 'testfname11';
        con.LastName = 'testLname11';
        con.Email = 'test11@test.com';
        con.Personal_Email__c = 'test21@test.com';
        con.Office_Phone__c = '112345789';
        con.HomePhone = '11211212';
        con.MobilePhone = '115665';
        insert con;    
        system.assertNotEquals(null, con.Id );
        
        
         // setup a ship to event
        Event shipTo = new Event();
        shipTo.WhatId = acc.id; 
        shipTo.ActivityDate = Date.today();
        shipTo.RecordTypeId = rt.id;
        shipTo.Subject = 'Clone Record';
        shipTo.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        shipTo.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        shipTo.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        shipTo.OwnerId = u.id;
        shipTo.WhoId = con.id;
        shipTo.Status__c = 'Open';
        insert shipTo;
        
        // Construct the standard controller
        ApexPages.StandardController con1 = new ApexPages.StandardController(shipTo);
        
        // create the controller
        cloneRedirectExtension ext = new cloneRedirectExtension(con1);

        // Switch to test context
        Test.startTest();
        // call the cloneWithItems method
        PageReference ref = ext.whereTo();
        // create the matching page reference
        PageReference redir = new PageReference('/'+ext.newRecordId);

        // make sure the user is sent to the correct url
        System.assertEquals(ref.getUrl(),redir.getUrl());
        
        // check that the new po was created successfully
        Event newevt = [select id from Event where id = :ext.newRecordId];
        System.assertNotEquals(newevt, null);
        
        // Switch back to runtime context
        Test.stopTest();
        
   }  
   
   
    public static List<String> getTestProfilesList () {
        List<String> profiles = new List<String>();
        profiles.add('CLAG Agent (New)');
        profiles.add('CLAG Manager');
        profiles.add('CLAG Preferencial Client User');
        profiles.add('CLAG System Administrator');
        
        return profiles;
    } 
    
    
    static testMethod void testevtCloneControllerelse() {
    // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.cloneRedirect;
        Test.setCurrentPage(pref);
        
   Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p1 = [SELECT Id FROM Profile WHERE Name='Standard User'];     
         //create new user
        User u1 = new User(Alias = 'standt8', Email='standarduser666@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing8156', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p1.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser666@testorg.com');
        insert u1;
        system.assertNotEquals(null, u1.Id );
        
        
        //get SJM Standard Event 
        RecordType rt1 = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'Procedure Scheduler']; 
        
        //create new account
        Account acc1 = new Account();
        acc1.RecordTypeId = personAccRecTypeId;
        acc1.Name = 'Rouel2';
        acc1.USD_AF_Region__c='SSP1';
        
        insert acc1;
        system.assertNotEquals(null, acc1.Id );
        
        //create new contact
        contact con1 = new contact();
        con1.AccountID= acc1.id;
        con1.firstname = 'testfname112';
        con1.LastName = 'testLname112';
        con1.Email = 'test12@test.com';
        con1.Personal_Email__c = 'test23@test.com';
        con1.Office_Phone__c = '1122345789';
        con1.HomePhone = '112211212';
        con1.MobilePhone = '1125665';
        insert con1;    
        system.assertNotEquals(null, con1.Id );
        
        
         // setup a ship to event
        Event shipTo1 = new Event();
        shipTo1.WhatId = acc1.id; 
        shipTo1.ActivityDate = Date.today();
        shipTo1.RecordTypeId = rt1.id;
        shipTo1.Subject = '';
        shipTo1.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        shipTo1.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        shipTo1.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        shipTo1.OwnerId = u1.id;
        //shipTo1.WhoId = con1.id;
        shipTo1.Status__c = 'Open';
        insert shipTo1;
        
        // Construct the standard controller
        ApexPages.StandardController con2 = new ApexPages.StandardController(shipTo1);
        
        // create the controller
        cloneRedirectExtension ext = new cloneRedirectExtension(con2);
        try{
        // Switch to test context
        Test.startTest();
        // call the cloneWithItems method
        PageReference ref1 = ext.whereTo();
        // create the matching page reference
        PageReference redir1 = new PageReference('/'+ext.newRecordId);

        // make sure the user is sent to the correct url
        System.assertEquals(ref1.getUrl(),redir1.getUrl());
        
        // check that the new po was created successfully
        Event newevt1 = [select id from Event where id = :ext.newRecordId];
        System.assertNotEquals(newevt1, null);
        
        // Switch back to runtime context
        Test.stopTest();
        }
        catch (DMLException e)
        {
            //System.assert(e.getMessage());
        }
   }    
}