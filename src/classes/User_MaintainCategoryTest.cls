@isTest
public class User_MaintainCategoryTest
{

  @isTest(SeeAllData=true)
  static void runBatch()
  {
  
  
  Profile p = [SELECT Id FROM Profile WHERE Name='SJM Sales User'];
  
  User u = new User(Alias = 'sales', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='testpermissionsetuser@testorg.com',IsActive=true);
        insert u;
        system.assertNotEquals( null, u.Id );
   
   List<PermissionSet > ps = [SELECT Id FROM PermissionSet WHERE Label in 
   ('Opportunity Management - Capital Sales')];
   //,'Opportunity Management - DBS','SJM FIT Users - All Licenses',
   //'SJM Tracker Users - All Licenses','SJM DSA User – All Licenses')];
        
   //PermissionSet ps = 
  
  //system.debug('permset-'+ ps.Id);
   // Assign the above inserted user for the above Permission Set.
   for(PermissionSet psalist : ps )
   {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = psalist .Id;
        insert psa;
        system.assertNotEquals( null, psa.Id );
    
    }
        
    Test.startTest();
        User_MaintainCategory usrMain = new User_MaintainCategory();
        usrMain.soql='SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Label FROM PermissionSetAssignment WHERE Assignee.IsActive = true and PermissionSet.isOwnedByProfile = false' + ' and AssigneeId=\'' + u.Id + '\'' + ' LIMIT 200';
        ID batchprocessid = Database.executeBatch(usrMain);
    Test.stopTest(); 
    
    
  
    list<User> Users = [Select Id,User_Category__c from User where Id=:u.Id];
   
    
    system.debug('Users-' + Users[0].id);
    system.debug('UserCategory-' + Users[0].User_Category__c);
    
    system.assertEquals(Users[0].User_Category__c, 'OppMan-Capital' );
    
     
    
        
  }







}