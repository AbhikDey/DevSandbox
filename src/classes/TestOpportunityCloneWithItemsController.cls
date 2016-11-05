@isTest
private class TestOpportunityCloneWithItemsController {

    
    
    static testMethod void testOPCloneController() {

    RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name = 'SJM Service Plan Sales'];
    Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
    RecordType eqrt = [SELECT id,Name FROM RecordType WHERE SobjectType='Equipment__c' AND Name = 'SJM Capital'];
    RecordType rt1 = [SELECT id,Name FROM RecordType WHERE SobjectType='Event' AND Name = 'SJM Standard Event']; 
    RecordType rt2 = [SELECT id,Name FROM RecordType WHERE SobjectType='Task' AND Name = 'SJM Global Standard Task']; 
       // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.OpptylineitemsClone;
        Test.setCurrentPage(pref);

        Profile p = [SELECT Id FROM Profile WHERE Name='SJM Sales User'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Customer Service - Inside Sales'];
        User u = new User(Alias = 'standt6', Email='standarduser663@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing815', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,userroleid = r.Id,TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser663@testorg.com');
        insert u;
        system.assertNotEquals(null, u.Id );

        System.runAs(new User(Id = UserInfo.getUserId())) {

        // setup account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc .Name = 'St Jude Abott test';
        acc.SJM_ID__c ='100098922';
        acc.Service_Contract_Specialist__c = u.id;
        insert acc;

        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.Email = 'test@sjm.com';
        cont.Accountid= acc.id;
        cont.Personal_Email__c = 'test@sjm.com';
        cont.Office_Phone__c = '1234567899';
        cont.HomePhone = '1234567899';
        insert cont;

        Account acc1 = [Select OwnerID, Owner.ID From Account where ID = :acc.id];

        Product2 produc2 = new Product2();
        produc2.Name = 'testprod';
        produc2.Productcode = 'VM390000';
        produc2.isActive = true;
        insert produc2 ;
        
        Equipment__c eq = new Equipment__c();
        eq.Serial_Lot_Number__c ='123455';
        eq.Account_Name__c = acc.id;
        eq.Warranty_End__c = system.today().addDays(+120);
        system.debug('Datebefore 90' +  eq.Warranty_End__c);
        eq.Serial_Lot_Number__c = '999999';
        eq.Oppty_Product_Model__c = 'VM390000';
        eq.RecordTypeId = eqrt.id;
        insert eq;
        
        Pricebook2 objPB=new Pricebook2();
        objPB.Name='Standard Price Book';
        objPB.IsActive = true;      
        insert objPB;
    
        PricebookEntry przentry = new PricebookEntry();
        przentry.Pricebook2Id =   Test.getStandardPricebookId();
        przentry.Product2Id = produc2.Id;
       
        przentry.CurrencyISOcode='USD';
        przentry.UnitPrice = 1059.5;
        przentry.isActive = true;
        przentry.UseStandardPrice = false;
        insert przentry;


        // create new Oppty record
        Opportunity op = new Opportunity();
        op.Name = 'test ISOppty';
        op.AccountId = acc.id;
        op.OwnerId = acc1.OwnerId;  
        op.RecordTypeId = rt.id;
        op.StageName = 'Prospecting';
        op.CloseDate = Date.today();
        insert op;

        // create a line item
        OpportunityLineItem ol = new OpportunityLineItem();
        ol.OpportunityId = op.Id;
        ol.Equipment__c = eq.id;
        ol.PricebookEntryId = przentry.Id;
        ol.TotalPrice = przentry.UnitPrice;
        ol.Quantity = 1;              
        //ol.UnitPrice = 0.01;
        insert ol;
        
        Opportunity_Contact__c oppcon = new Opportunity_Contact__c();
        oppcon.Contact__c = cont.Id;
        //oppcon.Name = 'oppcon';
        oppcon.Opportunity__c = op.Id;
        insert oppcon;
        
        Task newtask = new Task();
        newtask.WhatId = op.id;
        newtask.Subject = 'Task'; 
        newtask.OwnerId = u.id;
        newtask.status= 'Open';  
        newtask.WhoId = cont.Id;     
        Insert newtask;  
        
        Event newevent = new Event();
        newevent.WhatId = op.id;
        newevent.Subject = 'Event'; 
        newevent.status__c = 'Open';
        newevent.recordTypeId = rt1.id;  
        newevent.OwnerId = u.id;
        newevent.ActivityDate = Date.today();
        newevent.ActivityDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        newevent.StartDateTime = datetime.newInstance(2016, 04, 12, 3, 00, 00);
        newevent.EndDateTime = datetime.newInstance(2016, 04, 13, 3, 00, 00);
        newevent.IsAllDayEvent = false;
        newevent.WhoId = cont.Id; 
            
        Insert newevent;  
        
        // Construct the standard controller
        ApexPages.StandardController con = new ApexPages.StandardController(op);

        // create the controller
        OpportunityCloneWithItemsController ext = new OpportunityCloneWithItemsController(con);

        // Switch to test context
        Test.startTest();

        // call the cloneWithItems method
        PageReference ref = ext.cloneWithItems();
        // create the matching page reference
        PageReference redir = new PageReference('/'+ext.newRecordId+'/e?retURL=%2F'+ext.newRecordId);

        // make sure the user is sent to the correct url
        //System.assertEquals(ref.getUrl(),redir.getUrl());

  
        Opportunity newOP = [select id from Opportunity where id = :ext.newRecordId];
        //System.assertNotEquals(newOP, null);
        // check that the line item was created
        List<OpportunityLineItem> newItems = [Select p.Id From OpportunityLineItem p where OpportunityId = :newOP.id];
        //System.assertEquals(newItems.size(),1);

        // Switch back to runtime context
        Test.stopTest();
      }
    }

}