@isTest
private class TestSFCalloutUtil_AC{

static testMethod void createUser(){

    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    User u = new User(Alias = 'standt', Email='standarduser285623@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser18569@testorg.com');
            
       insert u;
       
       Access_Settings__c CusSetting = new Access_Settings__c();
       CusSetting.Consumer_Key__c = 'Test1';
       CusSetting.Consumer_Secret__c = 'Test2';
       CusSetting.Endpoint__c = 'http://api.salesforce.com/foo/bar';
       CusSetting.password__c = 'Test4';
       CusSetting.Username__c = 'Test5';
       CusSetting.Name = 'TEST';
       insert CusSetting;
       
       String endpoint = 'https://ap1.salesforce.com/'; 
       String reqType = 'POST';
       //String fullEmailPhotoUrl = 'testpass';
       
       SFCalloutUtil_AC.LoginResult logrslt = new SFCalloutUtil_AC.LoginResult();  
       logrslt.access_token = 'Test6'; 
       logrslt.instance_url = 'Test7'; 
       logrslt.id = '1234'; 
       logrslt.token_type = 'Test9'; 
       logrslt.issued_at = 'Test10'; 
       logrslt.signature = 'Test11';
       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());  
        HttpRequest req = SFCalloutUtil_AC.getHttpRequest(endpoint,reqType);
        //SFCalloutUtil_AC.photocall(endpoint,reqType);
        Test.stopTest();       
    }        
}