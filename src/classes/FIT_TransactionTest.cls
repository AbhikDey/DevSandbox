@isTest
private class FIT_TransactionTest
{
    public static testMethod void submitTrans(){
        
        // Create Accout
        RecordType  customerRecordType = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='SJM_Customer'];
        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        RecordType  sales_order = [ Select Id 
                                    From RecordType 
                                    Where DeveloperName=: 'Sales_Order' 
                                    AND SobjectType = 'Transactions__c' limit 1];

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, Status__c = 'In Progress', recordTypeId = sales_order.id);
        insert trans ;

        System.assertEquals( trans.Status__c , 'In Progress');
        
        // Create Product
        Product_FIM__c prod = new Product_FIM__c(  Name='AC-0050', Material_type__c='ZMOD', Is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                                    Product_description__c='Test product', Product_Key__c='AC-0050', Unit_of_measure__c='ED', Serialized__c = true);
        insert prod;

        Inventory__c inv = new Inventory__c( Account__c = ac.Id, Quantity__c = 4 ) ;
        insert inv ; 

        // Create Transaction items
        Transaction_Items__c item = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Model_Number__c = prod.Id, Inventory__c = inv.Id );
        insert item;

        Test.startTest();

            trans.Submit__c = true;
            update trans;

            Transactions__c l_updated = [ Select Id, 
                                                 Status__c, 
                                                 Submit__c 
                                          From Transactions__c 
                                          Where Id = :trans.id];

            System.assertEquals( l_updated.Status__c , 'PO Pending');
            System.assertEquals( l_updated.Submit__c , false);

            l_updated.Submit__c = true;
            update l_updated;      

            l_updated = [ Select Id, 
                                 Status__c, 
                                 Submit__c 
                          From Transactions__c 
                          Where Id = :trans.id];


            System.assertEquals( l_updated.Status__c , 'Invoiced');      

        Test.stopTest();

    }
    
    public static testMethod void submitTrans_NoItems(){
        
        // Create Accout
        RecordType  customerRecordType = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='SJM_Customer'];
        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        RecordType  sales_order = [ Select Id 
                                    From RecordType 
                                    Where DeveloperName=: 'Sales_Order' 
                                    AND SobjectType = 'Transactions__c' limit 1];

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, Status__c = 'In Progress', recordTypeId = sales_order.id);
        insert trans ;

        System.assertEquals( trans.Status__c , 'In Progress');
        
        // Create Product
        Product_FIM__c prod = new Product_FIM__c(  Name='AC-0050', Material_type__c='ZMOD', Is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                                    Product_description__c='Test product', Product_Key__c='AC-0050', Unit_of_measure__c='ED', Serialized__c = true);
        insert prod;

        Inventory__c inv = new Inventory__c( Account__c = ac.Id, Quantity__c = 4 ) ;
        insert inv ; 

        // NO Transaction items

        Test.startTest();
         try{
            trans.Submit__c = true;
            update trans;

            Transactions__c l_updated = [ Select Id, 
                                                 Status__c, 
                                                 Submit__c 
                                          From Transactions__c 
                                          Where Id = :trans.id];

            System.assertEquals( l_updated.Status__c , 'In Progress');//status should not have been updated to Invoiced due to missing items
            System.assertEquals( l_updated.Submit__c , false);
         }catch(Exception e){
          	System.debug('Message '+ e.getMessage());
          	System.assert(e.getMessage().contains('You cannot submit a Transaction if it does not have any Transaction Items'));
          }
        Test.stopTest();

    }
}