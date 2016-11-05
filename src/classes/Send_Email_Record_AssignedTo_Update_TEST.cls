@isTest
private class Send_Email_Record_AssignedTo_Update_TEST {
	@isTest
    //Create an account
    public static void accountTieTogetherTest(){
    	Id SJMCustomerRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
        Account a = new Account();
        a.Name = 'Test Account1234567';
        a.USD_AF_Region__c = 'SSP2';
        a.RecordTypeId = SJMCustomerRecordTypeId;
        a.Status__c = 'Active';
        insert a;
        
        
        
        Profile p = [SELECT Id FROM Profile WHERE name='SJM Force.com User'];
    
     	Double randomValue1 = Math.random();
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', Emailencodingkey='UTF-8', Username='test_user1'+ randomValue1 +'@company.com',
                            Lastname='davis', Languagelocalekey='en_US', Localesidkey='en_US', Profileid = p.Id, 
                            Timezonesidkey='America/Chicago', Business_Partner__c = '3000058', IsActive=true, Opt_In_for_Procedure_Scheduler_Emails__c = true);
        insert u1;
        
        Double randomValue2 = Math.random();
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', Emailencodingkey='UTF-8', Username='test_user1'+ randomValue2 +'@company.com',
                            Lastname='damle', Languagelocalekey='en_US', Localesidkey='en_US', Profileid = p.Id, 
                            Timezonesidkey='America/Chicago', Business_Partner__c = '3000052', IsActive=true, Opt_In_for_Procedure_Scheduler_Emails__c = true);
        insert u2; 
        
        String duedate = '';
        Id EventRecordTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByName().get('Procedure Scheduler').getRecordTypeId();
        Event e = new Event();
        e.RecordTypeId = EventRecordTypeId;
        e.OwnerId = u1.Id;      	
        e.WhatId = a.Id;
        e.Subject = 'Test Procedure';
        e.StartDateTime = datetime.newInstance(2016, 02, 26, 09, 30, 0);
        e.EndDateTime = datetime.newInstance(2016, 02, 26, 10, 30, 0);        
        insert e;
       
        e.OwnerId =u2.Id;	     
        update e;
        
        }
}