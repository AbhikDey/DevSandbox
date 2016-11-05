@Istest
public class Test_Contractviewcontroller{
   static testmethod void ContractsviewTest()
   {
    Account ac = new Account();
        ac.name = 'Test Account';
        ac.SJM_ID__c= '1000000001';
        insert ac;
        
          Case c = new Case();
        
      
        c.AccountId = ac.Id;
       
        c.status = 'New';
        c.Origin = 'Email';
      
        insert c;
       
        Contract cnt = new Contract ();
       cnt.AccountId = ac.Id;
       cnt.Name= 'Test';
       cnt.Request_Type__c= 'Contract';
        cnt.Request_Number__c = c.Id;
        cnt.Status= 'Draft';
        cnt.StartDate=system.today();
        cnt.ContractTerm = 12;
        
        insert cnt;
        
        
           ApexPages.StandardController sc = new ApexPages.StandardController(cnt );
       Contractviewcontroller contr = new Contractviewcontroller(sc);
        
        
        
        
   }
   }