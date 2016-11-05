@isTest
public class TaskController_Test{

@isTest
private static void TestTaskDelete(){

// Create a Account
Account a1 = new Account  (
             Name = 'Demo Account');
        insert a1;
        system.assertNotEquals( null, a1.Id );
//Create  a physician

Contact c1 = new Contact(
            firstname = 'phys1',
            lastname = 'phys2',
            AccountId = a1.Id,
            Email='abc@sjm.com');
            insert c1;
            system.assertNotEquals( null, c1.Id );
//Create a Candidate
Candidate__c cd1 = new Candidate__c(
            Referred_By__c = c1.Id,
            Referred_To__c = c1.Id,
            External_System_Id__c = '1');
insert cd1;
system.assertNotEquals( null, cd1.Id );

Task task1 = new Task(
    ActivityDate = Date.today().addDays(7),
    Subject='Candidate Task',
    WhatId = cd1.Id,
    OwnerId = UserInfo.getUserId(),
    Status='In Progress',
    Candidate_Stage__c = 'Education');


insert task1 ;
system.assertNotEquals( null, task1.Id );

System.debug(task1.Id);
//Task createdtask1 = [SELECT Status from Task where ID = 'abc'];
try{
    delete task1;
    System.assert(false);
    }
    
  catch(dmlexception e)
  {
  system.assertNotEquals(e.getMessage(),'System Genereated Tasks Cannot be Deleted. Please contact your system Administrator');
  }

    
    


}
}