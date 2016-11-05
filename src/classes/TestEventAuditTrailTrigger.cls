@isTest
public class TestEventAuditTrailTrigger {
	@isTest static void TestEventAuditTrailTrigger() {
        id recordTypeID = [SELECT id from RecordType where developername = 'Procedure_Scheduler'].id;
        System.debug('Test - RecordTypeID: ' + recordTypeID);
        
        
        Account fakeAccount = new Account(Name='Fake Account');
        insert fakeAccount;
         
        Event evt = new Event(
            recordTypeId = recordTypeID,
            WhatId = fakeAccount.id,
            StartDateTime = datetime.now(),
            EndDateTime = datetime.now().addDays(1),
            subject = 'Test Event'
        );
        
        //test create
        Test.startTest();
        insert evt;
        System.debug('Test - RecordTypeID2: ' + evt.recordTypeID);
        integer changes = Database.CountQuery('SELECT COUNT() FROM SchedulerAuditTrail__c where updateType__c = \'Create\'');
        System.debug('Changes Count: ' + changes);
      	System.assert(changes > 0);
        

        //test update
        evt.Subject = 'New Test Event'; //changes
        
        update evt;
        integer changes2 = Database.CountQuery('SELECT COUNT() FROM SchedulerAuditTrail__c where updateType__c = \'Update\'');
        System.debug('Changes2 Count: ' + changes2);
      	System.assert(changes2 > 0);
        Test.stopTest();                                      
    }
}