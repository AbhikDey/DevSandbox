@isTest
private class FIT_TransactionItemTriggerHandlerTest {
    
    private static RecordType customerRecordType
    {
        get{
            if ( customerRecordType==null )
            {
                customerRecordType = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='SJM_Customer'];
            }
            return customerRecordType;
        } set;
    }  

    private static RecordType inventory_transfer_rt
    {
        get{
            if ( inventory_transfer_rt==null )
            {
                inventory_transfer_rt = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='Inventory_Transfer' AND SobjectType = 'Transactions__c'];
            }
            return inventory_transfer_rt;
        } set;
    }

    private static RecordType sales_order_rt
    {
        get{
            if ( sales_order_rt==null )
            {
                sales_order_rt = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='Sales_Order' AND SobjectType = 'Transactions__c'];
            }
            return sales_order_rt;
        } set;
    }    

    
    public static testMethod void checkPrice()
    {

        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id, SJM_ID__c = 'test1' );
        insert ac;

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, Status__c = 'In Progress', RecordTypeId = sales_order_rt.id);
        insert trans ;
        
        // Create Product
        Product_FIM__c prod = new Product_FIM__c(  Name='AC-0050', Material_type__c='ZMOD', Is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                                    Product_description__c='Test product', Product_Key__c='AC-0050', Unit_of_measure__c='ED');
        insert prod;

        Customer_Pricing__c cp1 = new Customer_Pricing__c(  Name = 'test1',  Contract_Price__c = 5 , List_Price__c = 6  , Group_Price__c= 7 , 
                                                            Model_Number__c = prod.Id, Account__c = ac.Id ) ;
        insert cp1 ; 

        Inventory__c inv1 = new Inventory__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '5',  Status__c = 'Y' , Model_Number__c = 'AC-0050') ;
        Inventory__c inv2 = new Inventory__c( Inventory_ID__c = '13', Stock_Partner_Number__c = '5',  Status__c = 'Y' , Model_Number__c =  'AC-0050') ;
        Inventory__c inv3 = new Inventory__c( Inventory_ID__c = '14', Stock_Partner_Number__c = '5',  Status__c = 'Y' , Model_Number__c = 'AC-0050') ;
        insert new List<Inventory__c>{inv1,inv2,inv3};        

        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Model_Number__c = prod.Id, Inventory__c = inv1.id);
        insert item1 ;

        // Set List price as Lowest and insert Item 
        cp1.List_Price__c = 4 ;
        update cp1 ;
        Transaction_Items__c item2 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Model_Number__c = prod.Id , Inventory__c = inv2.id);
        insert item2 ;

        // Set Group price as Lowest and insert Item 
        cp1.Group_Price__c = 3 ; 
        update cp1 ; 
        Transaction_Items__c item3 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Model_Number__c = prod.Id, Inventory__c = inv3.id);
        insert item3 ;

    }

    public static testMethod void deleteConsignment_Request()
    {

        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        RecordType  consignment_request_rt = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='Consignment_Request' AND SobjectType = 'Transactions__c'];

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, RecordtypeID = consignment_request_rt.id , Status__c='Send');
        insert trans ;
        
        // Create Product
        Product_FIM__c prod = new Product_FIM__c(  Name='AC-0050', Material_type__c='ZMOD', Is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                                    Product_description__c='Test product', Product_Key__c='AC-0050', Unit_of_measure__c='ED');
        insert prod;

        Customer_Pricing__c cp1 = new Customer_Pricing__c(  Name = 'test1',  Contract_Price__c = 5 , List_Price__c = 6  , Group_Price__c= 7 , 
                                                            Model_Number__c = prod.Id, Account__c = ac.Id ) ;
        insert cp1 ; 

        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Model_Number__c = prod.Id, Status__c = 'Pending');
        insert item1 ;

        Test.startTest();
        try{
            delete item1;
        }
        catch( exception e )
        {
            system.assert(true);
        }
        
        Test.stopTest();
    }


    public static testMethod void deleteSales_Order()
    {

        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        RecordType  consignment_request_rt = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='Sales_Order' AND SobjectType = 'Transactions__c'];

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, RecordtypeID = consignment_request_rt.id , Status__c='Invoiced');
        insert trans ;
        
        // Create Product
        Product_FIM__c prod = new Product_FIM__c(  Name='AC-0050', Material_type__c='ZMOD', Is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                                    Product_description__c='Test product', Product_Key__c='AC-0050', Unit_of_measure__c='ED');
        insert prod;

        Customer_Pricing__c cp1 = new Customer_Pricing__c(  Name = 'test1',  Contract_Price__c = 5 , List_Price__c = 6  , Group_Price__c= 7 , 
                                                            Model_Number__c = prod.Id, Account__c = ac.Id ) ;
        insert cp1 ; 

        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Model_Number__c = prod.Id);
        insert item1 ;

        Test.startTest();
        try{
            delete item1;
        }
        catch( exception e )
        {
            system.assert(true);
        }
        
        Test.stopTest();
    }

    public static testMethod void checkDuplicatedInventory()
    {

        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, RecordtypeID = inventory_transfer_rt.id );
        insert trans ;
        
        Inventory__c inv1 = new Inventory__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '5',  Status__c = 'Y' ) ;
        insert inv1;

        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv1.id);
        insert item1 ;

        Transaction_Items__c item2 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv1.id);

        Test.startTest();
        try
        {
            insert item2;
            system.assert(false); //It should not pass this line, because a duplicated inventory record was selected
        }
        catch( exception e )
        {
            system.assert(e.getmessage().contains('You cannot select a duplicate inventory record for this transaction'));
        }
        
        Test.stopTest();
    }

    public static testMethod void checkInventorySockPartnerNumber()
    {
        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, RecordtypeID = inventory_transfer_rt.id );
        insert trans ;
        
        Inventory__c inv1 = new Inventory__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '52',  Status__c = 'Y' ) ;
        Inventory__c inv2 = new Inventory__c( Inventory_ID__c = '13', Stock_Partner_Number__c = '51',  Status__c = 'Y' ) ;
        insert new List<Inventory__c>{ inv1 , inv2 };
        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv1.id);
        insert item1 ;

        Transaction_Items__c item2 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv2.id);

        Test.startTest();
        try
        {
            insert item2;
            system.assert(false); //It should not pass this line, because Transaction.inventory.Stock_Partner_Number__c are different
        }
        catch( exception e )
        {
            system.debug('***** ' +e.getmessage() );
            system.assert(e.getmessage().contains('You cannot add inventory records to the same transaction from multiple locations.'));
        }
        
        Test.stopTest();
    }


    public static testMethod void checkInsertTransactionItemSuccesfull()
    {

        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, RecordtypeID = inventory_transfer_rt.id );
        insert trans ;
        
        Inventory__c inv1 = new Inventory__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '52',  Status__c = 'Y' ) ;
        Inventory__c inv2 = new Inventory__c( Inventory_ID__c = '13', Stock_Partner_Number__c = '52',  Status__c = 'Y' ) ;
        insert new List<Inventory__c>{ inv1 , inv2 };
        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv1.id);
        insert item1 ;

        Transaction_Items__c item2 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv2.id);

        Test.startTest();

        insert item2;
        system.assert( item2.id != null ); 

        Test.stopTest();
    }

    public static testMethod void setItemsInTransactionTest()
    {
        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, RecordtypeID = inventory_transfer_rt.id );
        insert trans ;
        
        Inventory__c inv1 = new Inventory__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '52',  Status__c = 'Y' ) ;
        insert new List<Inventory__c>{ inv1  };
        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv1.id);
        

        Test.startTest();
            insert item1 ;
        Test.stopTest();


        Transaction_Items__c l_item_inserted = [ Select Model__c,
                                                        Serial__c,
                                                        Status__c
                                                 From Transaction_Items__c
                                                 Where ID = : item1.id ];

        Transactions__c l_trans_inserted = [ Select Items__c
                                             From Transactions__c
                                             Where ID = :trans.id ];

        String items = '';
        items = items + l_item_inserted.Model__c + ' | ' + l_item_inserted.Serial__c + ' | ' + l_item_inserted.Status__c  ;                                     

        system.assertEquals( l_trans_inserted.Items__c , items );
    }
    
    
    public static testMethod void checkDeleteUndeleteTransactionItemSuccesfull()
    {

        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, RecordtypeID = inventory_transfer_rt.id );
        insert trans ;
        
        Inventory__c inv1 = new Inventory__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '52',  Status__c = 'Y' ) ;
        Inventory__c inv2 = new Inventory__c( Inventory_ID__c = '13', Stock_Partner_Number__c = '52',  Status__c = 'Y' ) ;
        insert new List<Inventory__c>{ inv1 , inv2 };
        // Create Transaction items
        Transaction_Items__c item1 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv1.id);
        insert item1 ;

        Transaction_Items__c item2 = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Inventory__c = inv2.id);

        Test.startTest();

        insert item2;
        system.assert( item2.id != null );

        delete item2;


        Test.stopTest();
    }    





}