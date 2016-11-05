@isTest
private class SchedulerProfile_Test{

    static testMethod void runAsAllProfiles () {
        List<String> profiles = getTestProfilesList();
        for ( String profileName : profiles ) {
            List<Profile> profileRecords = [SELECT Id FROM Profile WHERE Name = :profileName ];
            if ( profileRecords!= null && profileRecords.size() > 0 ) {
                Profile profileRecord = profileRecords[0];
                User profileBasedUser = new User(Alias = profileName.replace(' ','').replace('-','_').left(8), Email = profileName.replace(' ','').replace('-','_') + '@testorg.com', EmailEncodingKey = 'UTF-8', LastName='Testing ' + profileName, LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileRecord.Id, TimeZoneSidKey='America/Los_Angeles', UserName=profileName.replace(' ','').replace('-','_') + '@testorg.com');
                System.runAs(profileBasedUser) {
                    redirect1_Test();
                }
            }
        }
        
    }


    static testMethod void redirect1_Test(){
    
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
        //create new user
        User u = new User(Alias = 'standt5', Email='standarduser6333@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing9157', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6333@testorg.com');
        insert u;
        system.assertNotEquals(null, u.Id );
        
        test.startTest();
           PageReference pageRef = Page.FullCalendar;
           Account acc = new Account(Name='Abcd');
           insert acc;

           Test.setCurrentPage(pageRef);
           pageRef.getParameters().put('accountId',u.id);
           //ApexPages.StandardController sc = new ApexPages.standardController(u); 
           SchedulerProfile controller = new SchedulerProfile();
           System.assertNotEquals(null,controller.Redirect());
           test.stopTest(); 
         
    }


    public static List<String> getTestProfilesList () {
        List<String> profiles = new List<String>();
        profiles.add('CLAG Agent (New)');
        profiles.add('CLAG Manager');
        profiles.add('CLAG Preferencial Client User');
        profiles.add('CLAG System Administrator');
        
        return profiles;
    }

}