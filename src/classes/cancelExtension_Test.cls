@isTest
private class cancelExtension_Test {

    static testMethod void runAsAllProfiles () {
        List<String> profiles = getTestProfilesList();
        for ( String profileName : profiles ) {
            List<Profile> profileRecords = [SELECT Id FROM Profile WHERE Name = :profileName ];
            if ( profileRecords!= null && profileRecords.size() > 0 ) {
                Profile profileRecord = profileRecords[0];
                User profileBasedUser = new User(Alias = profileName.replace(' ','').replace('-','_').left(8), Email = profileName.replace(' ','').replace('-','_') + '@testorg.com', EmailEncodingKey = 'UTF-8', LastName='Testing ' + profileName, LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileRecord.Id, TimeZoneSidKey='America/Los_Angeles', UserName=profileName.replace(' ','').replace('-','_') + '@testorg.com');
                System.runAs(profileBasedUser) {
                    testevtCancelController();
                }
            }
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
    
    
    static testMethod void testevtCancelController() {
    // setup a reference to the page the controller is expecting with the parameters
        //PageReference pref = Page.cloneRedirect;
        //Test.setCurrentPage(pref);
        
   Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];     
         //create new user
        User u = new User(Alias = 'standt9', Email='standarduser66333@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing81556', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser66333@testorg.com');
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
        shipTo.Subject = 'Cancel Record';
        shipTo.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        shipTo.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        shipTo.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        shipTo.OwnerId = u.id;
        shipTo.WhoId = con.id;
        shipTo.Status__c = 'Open';
        insert shipTo;
        //shipTo.Status__c = 'Cancelled';
        //update shipTo;
        //Event shipToupdate = new Event();
        
        // Construct the standard controller
        ApexPages.StandardController con1 = new ApexPages.StandardController(shipTo);
        
        // create the controller
        cancelExtension ext = new cancelExtension(con1);

        // Switch to test context
        Test.startTest();
        // call the cloneWithItems method
        PageReference ref = ext.setCancel();
        // create the matching page reference
        PageReference redir = new PageReference('/'+ext.newRecordId);

        // make sure the user is sent to the correct url
        System.assertEquals(ref.getUrl(),redir.getUrl());
        
        // check that the new po was created successfully
        Event newevt = [select id, Status__c from Event where id = :shipTo.Id];
        newevt.Status__c = 'Cancelled';
        update newevt;
        PageReference redir1 = new PageReference('/'+newevt.Id);
        //System.assertNotEquals(newevt, null);
        
        // Switch back to runtime context
        Test.stopTest();
        
   }
    
}