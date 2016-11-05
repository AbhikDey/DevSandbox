@isTest
public class SJM_DBSProcedureTracker_Test {

  static testMethod void sjmdbsproceduretrackerTest() {
        
        Account a1 = new Account  (
                     Name = 'Demo Account');
                insert a1;
                system.assertNotEquals( null, a1.Id );

        RecordType rt = [Select id From RecordType Where SobjectType='Contact' AND DeveloperName='Physician'];

        Contact c1 = new Contact(
                    firstname = 'phys1',
                    lastname = 'phys2',
                    AccountId = a1.Id,
                    Email='abc@sjm.com',
                    RecordTypeID = rt.id);
                    insert c1;   


        Procedure__c procedure= new Procedure__c();
        Procedure__c procedure1= new Procedure__c();
        procedure.Procedure_Date__c = Date.today();
        //procedure.Procedure_Type__c = 'NavX';
        procedure.Account__c = a1.Id;
        procedure.Procedure_Physician__c = c1.id;
        insert procedure;
        
        Procedure_Tracker_Settings__c ptSetting = new Procedure_Tracker_Settings__c();
        ptSetting.Require_Fields__c = 'Name';
        ptSetting.Procedure_Account_Field_Id__c = 'CF00Ng0000001UPye_lkid';
        insert ptSetting;
        
        Account acc = new Account();
        acc.Name = 'testing';
        insert acc;
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        
        ApexPages.currentPage().getParameters().put(ptSetting.Procedure_Account_Field_Id__c,acc.Id);
        Procedure_Item__c procedureItem = new Procedure_Item__c();
        procedureItem.Procedure__c = Procedure.id;
        procedureItem.Procedure_Item__c = 'DBS';
        
        insert procedureItem;
        
        ApexPages.currentPage().getParameters().put('id',procedure.id);
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController( procedure );
        
        SJM_DBSProcedureTracker sjmdbsproceduretracker = new SJM_DBSProcedureTracker(sc);
        //Map<String, List<Procedure_Item__c>> pITest = procedureEditController.typeToProcedureItems;
        
        Boolean s1test = sjmdbsproceduretracker.getIsS1();
        ApexPages.currentPage().getParameters().put('id',null);
        sc = new ApexPages.StandardController( procedure1 );
        sjmdbsproceduretracker = new SJM_DBSProcedureTracker(sc);
        Map<String, String> rfMaptest = sjmdbsproceduretracker.requiredFieldsMap;        
        test.stopTest();
    }
    
     static testMethod void getAcctContact_Test(){
        /*Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt67', Email='standarduser51@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'test',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser51@testorg.com');
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        SJM_DBSProcedureTracker  myPageTestCalenda = new SJM_DBSProcedureTracker(sc);
        List<SelectOption> testoptions1 = myPageTestCalenda.getcontacts(); */
        
                Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt67', Email='standarduser51@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'test',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser51@testorg.com');
        insert u;
        
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        Contact contact = new Contact( FirstName = 'Test', LastName = 'User', AccountId = acct.Id,  Personal_Email__c = 'test@sjm.com',
            Office_Phone__c = '1234567899', HomePhone = '1234567899');
        insert contact;
        
        RecordType rt1 = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND DeveloperName = 'DBS_Procedure_Scheduler'];
        
        Event eventEle = new Event();
        eventEle.WhatId = acct.id; 
        eventEle.ActivityDate = Date.today();
        eventEle.Description = 'Test Event';
        eventEle.Subject = 'Test Subject';
        //eventEle.ActivityDateTime = datetime.newInstance(2016, 10, 12, 3, 00, 00);
        //eventEle.StartDateTime = datetime.newInstance(2016, 10, 12, 3, 00, 00);
        //eventEle.EndDateTime = datetime.newInstance(2016, 10, 13, 3, 00, 00);
        eventEle.ActivityDateTime = system.now().adddays(-9);
        eventEle.StartDateTime = system.now().adddays(-9);
        eventEle.EndDateTime = system.now().adddays(1);
        eventEle.IsAllDayEvent = false;
        eventEle.OwnerId = u.id;
        eventEle.WhoId = contact.id;
        eventEle.recordTypeId = rt1.id;
        eventEle.Status__c = 'open';  
        insert eventEle; 
        
        Procedure__c procedure= new Procedure__c();
        procedure.Procedure_Date__c = Date.today();
        procedure.Account__c = acct.Id;
        procedure.Procedure_Physician__c = contact.id;
        insert procedure;
        
        Affiliation__c af = new Affiliation__c();
        af.Account__c = acct.id;
        af.Contact__c = contact.id;
        insert af;
        
        Date predate = Date.Today().addDays(-10);
        
        Affiliation__c cont = [SELECT Account__c,Contact_Name__c,Contact__c,Id,Name,Role__c FROM Affiliation__c WHERE Account__c = : procedure.Account__c limit 1];  
        Event evt = [SELECT StartDateTime FROM Event WHERE id =: eventEle.id limit 1];
        
        Event e = [SELECT Id,StartDateTime,Subject,OwnerId,Owner.Name,Status__c from Event where WhatId = :procedure.Account__c and RecordTypeId =: rt1.id and Status__c!= 'Cancelled' and DAY_ONLY(StartDateTime) <= TODAY and DAY_ONLY(StartDateTime) >= :predate limit 1];
        system.debug('@@eeee' + e);
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        SJM_DBSProcedureTracker  myPageTestCalenda = new SJM_DBSProcedureTracker(sc);
        //List<SelectOption> testoptions1 = myPageTestCalenda.getcontacts();
        List<SelectOption> testoptions2 = myPageTestCalenda.getevents();        
    }

}