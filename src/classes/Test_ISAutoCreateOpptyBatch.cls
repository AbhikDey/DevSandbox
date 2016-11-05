//Batch test method
@isTest
public class Test_ISAutoCreateOpptyBatch {
    static testmethod void Opptest() {
         
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name = 'SJM Service Plan Sales'];
        Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
        RecordType eqrt = [SELECT id,Name FROM RecordType WHERE SobjectType='Equipment__c' AND Name = 'SJM Capital'];
        
      
        //create new account
        Account acc = new Account();
        acc.RecordTypeId = personAccRecTypeId;
        acc.Name = 'Rouel';
        acc.SJM_ID__c ='100098920';
        insert acc;
        system.assertNotEquals(null, acc.Id );
        
        
        
        
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
        //eq.Warranty_Expired__c = true;
        
        insert eq;
        
        
        Pricebook2 objPB=new Pricebook2();
        objPB.Name='Standard Price Book';
        objPB.IsActive = true;      
        insert objPB;
        
        PricebookEntry przentry = new PricebookEntry();
        przentry.Pricebook2Id =   Test.getStandardPricebookId();
        przentry.Product2Id = produc2.Id;
       
       //przentry.ProductCode = 'VM390000';
       przentry.CurrencyISOcode='USD';
        przentry.UnitPrice = 1059.5;
        przentry.isActive = true;
        przentry.UseStandardPrice = false;
        insert przentry;
        system.debug('przentry.Product2Id'+przentry.Product2Id);
        Opportunity opp = new Opportunity();
        opp.Name = 'test Opp';
        opp.AccountId = acc.id;
        opp.RecordTypeId = rt.id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today();
        insert opp; 
        
       system.debug('przentry.Productcode'+przentry.ProductCode);
             system.debug('przentry.ProductName'+przentry.Product2.Name);
        system.debug('przentry.ProductId'+przentry.Product2Id);
        
        OpportunityLineItem ol = new OpportunityLineItem();
        ol.OpportunityId = opp.Id;
        ol.Equipment__c = eq.id;
        ol.PricebookEntryId = przentry.Id;
        ol.TotalPrice = przentry.UnitPrice;
        ol.Quantity = 1;              
        //ol.UnitPrice = 0.01;
        insert ol;
        
        IS_AutoCreateOpptyJob testbatch = new IS_AutoCreateOpptyJob();
     //  testbatch.query = 'Select Id,Account_Number__c,Warranty_End__c,Serial_Lot_Number__c, Oppty_Product_Model__c, Account_Name__c FROM Equipment__c ';
        

       Database.executeBatch(testbatch , 200);
       
    
       
    //   Database.executeBatch(testbatch);
        
    }
}