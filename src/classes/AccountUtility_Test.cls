@isTest
public class AccountUtility_Test
{
   static testmethod void UpdateAccountTest()
   {
   
   RecordType rt = [SELECT Id, Name FROM RecordType WHERE Sobjecttype = 'Case' AND Name= 'Servicemax'];
        Account ac = new Account();
        ac.name = 'Test Account';
        ac.SJM_ID__c= '1000000001';
        insert ac;
        
         Account ac1 = new Account();
        ac1.name = 'Test Account';
        ac1.SJM_ID__c= '1000000011';
        insert ac1;
        
        Group_Members__c sm = new Group_Members__c();
        sm.Group__c= ac.Id;
        sm.Associated_Account__c = ac1.Id; 
        insert sm;
        
        Product2 pr = new Product2();
        pr.name = 'Test Product';
        pr.Productcode='1234567';
        
        pr.USD_Selling_Division__c='AF';
        insert pr;
        
        Contact cont = new Contact();
        cont.FirstName = 'First';
        Cont.LastName = 'last';
        cont.email = 'test@gmail.com';
        cont.AccountId = ac.Id;
        cont.SJM_Id__c = 'HR001';
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.name = 'test';
        opp.AccountId= ac.Id;
        opp.StageName= 'Prospecting';
        opp.CloseDate = system.Today();
        insert opp;
        
       
      // Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
       Id pricebookId = Test.getStandardPricebookId();
        
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
insert pbk1;

Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
insert prd1;

PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID= pricebookId , UnitPrice=50, isActive=true);
insert pbe1;

   
OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4,UnitPrice=100);
insert lineItem1;    
       
       
       
  
       
        Case c = new Case();
        
        c.ContactId = cont.Id;
        c.AccountId = ac.Id;
        c.Opportunity__c = opp.Id;
        c.Pricing_Floor__c= 'Other';
        c.status = 'New';
        c.Origin = 'Email';
        c.Servicemax_SJM_ID__c=ac.SJM_ID__c;
        insert c;
        
        Recordtype rte= [SELECT Id, Name FROM Recordtype WHERE Sobjecttype='Case_Lines__c' AND Name='Capital'];
        Case_Lines__c cl = new Case_Lines__c();
        cl.RecordTypeId=rte.Id;
        cl.Case__c=c.Id;
        cl.product__c=pr.Id;
        cl.Qty__c=1;
        insert cl;
        
         Case c2 = new Case();
        
        c2.ContactId = cont.Id;
        c2.status = 'New';
        c2.Origin = 'Email';
        c2.Account_SJM_Id__c=ac.SJM_ID__c;
        insert c2;
        
         Case c3 = new Case();
        
        
        c3.status = 'New';
        c3.Origin = 'Email';
        c3.Account_SJM_Id__c=cont.SJM_ID__c;
        c.Servicemax_SJM_ID__c=ac.SJM_ID__c;
        insert c3;
        
        
        Contract cnt = new Contract ();
       cnt.AccountId = ac1.Id;
        cnt.Request_Number__c = c.Id;
        cnt.Status= 'Draft';
        cnt.StartDate=system.today();
        cnt.ContractTerm = 12;
        
        insert cnt;
        
       
        
    
             
                   
        }
     }