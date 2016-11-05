@isTest
public class EnhancedCloneTest
{
   static testmethod void EnhancedcloneTest()
   {
   
    Account ac = new Account();
        ac.name = 'Test Account';
        ac.SJM_ID__c= '1000000001';
        insert ac;
        
         Case c2 = new Case();
        
        c2.AccountId=ac.Id;
        c2.status = 'New';
        c2.Origin = 'Email';
      
        insert c2;
       
       Case_Lines__c clin = new Case_Lines__c();
       clin.Case__c = c2.Id;
       clin.Division__c = 'AF';
       clin.Type__c= 'New';
           insert clin;
           
           
 EnhancedCloneHelper.clone(C2.Id);
        
        }
        }