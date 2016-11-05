@isTest
public class Test_EventProcedure{

    static testmethod void testOne() {
     Account acct = new Account( Name = 'Test Account' );
     insert acct;
     
      Contact contact = new Contact( FirstName = 'Test', LastName = 'User', AccountId = acct.Id,  Personal_Email__c = 'test@sjm.com',
        Office_Phone__c = '1234567899', HomePhone = '1234567899');
      insert contact;
 
      Profile p = [SELECT Id FROM Profile WHERE Name='SJM Sales User'];
       
        User u = new User(Alias = 'standt61', Email='standarduser6631@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing815', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser663@testorg.com');
        insert u;
 
        RecordType rt1 = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'SJM Standard Event'];
        RecordType rt2 = [SELECT id,Name FROM RecordType WHERE SobjectType='Procedure__c' AND Name = 'DBS Case']; 
         
        Event eventEle = new Event();
        eventEle.WhatId = acct.id; 
        eventEle.ActivityDate = Date.today();
        eventEle.Description = 'Test Event';
        eventEle.Subject = 'Test Subject';
        eventEle.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        eventEle.IsAllDayEvent = false;
        eventEle.OwnerId = u.id;
        eventEle.WhoId = contact.id;
        eventEle.recordTypeId = rt1.id;
        eventEle.Status__c = 'completed';  
        insert eventEle; 
          
        Procedure__c procedure = new Procedure__c();
        procedure.Procedure_Date__c = Date.today();
        procedure.Account__c = acct.Id;
        procedure.Procedure_Physician__c = contact.id;
        procedure.recordTypeId = rt2.id;
        procedure.Related_Event_ID__c = eventEle.id;
        insert procedure;
        
        Event eventEle1 = new Event();
        eventEle1.WhatId = acct.id; 
        eventEle1.ActivityDate = Date.today();
        eventEle1.Description = 'Test Event';
        eventEle1.Subject = 'Test Subject';
        eventEle1.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle1.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        eventEle1.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        eventEle1.IsAllDayEvent = false;
        eventEle1.OwnerId = u.id;
        eventEle1.WhoId = contact.id;
        eventEle1.Procedure__c = procedure.id;
        eventEle1.recordTypeId = rt1.id;
        eventEle1.Status__c = 'completed';  
        insert eventEle1; 
        
        Test.startTest();
        update eventEle1;
        Test.stopTest();
        
    } 
         
}