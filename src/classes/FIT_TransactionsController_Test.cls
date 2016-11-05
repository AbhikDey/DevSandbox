@isTest
private class FIT_TransactionsController_Test {
    @isTest
    private static void processConsignment(){
        insert new SJM_Integrations__c(Web_Service_User__c='some_user', Web_Service_Endpoint__c='some_endpoint', name='InventoryConsignment',
                                       Web_Service_Password__c='some_password', Web_Service_Name__c ='InventoryConsignment');
                                              
        RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        Transactions__c t = new Transactions__c(Account__c=a.Id, Status__c = 'In Progress');
        insert t;
       // ID id = 'a0fg0000002b8hG';
       // Product_FIM__c i = [select id, name from Product_FIM__c where id = :id];
        
        Product_FIM__c p = new Product_FIM__c(name='AC-0050', material_type__c='ZMOD', is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                             product_description__c='Test product', Product_Key__c='AC-0050', unit_of_measure__c='ED');
        insert p;
        Transaction_Items__c item = new Transaction_Items__c(Transaction_ID__c = t.id, Quantity__c=10, Model_Number__c = p.id);
        insert item;
        Test.startTest();
            t.Submit__c = true;
            update t;
            Transactions__c tt = [select id, name, status__c from Transactions__c where id = : t.Id];
            System.assertEquals('Send', tt.Status__c);
          
        Test.stopTest();
          Transaction_Log__c log = [select id, name, Transaction_ID__c from Transaction_Log__c where Transaction_ID__c = : tt.id];
          System.assertNotEquals(null, log);
    }
    
    
    
    
    @isTest
    private static void processConsignment_Negative(){
      //  insert new SJM_Integrations__c(Web_Service_User__c='some_user', Web_Service_Endpoint__c='some_endpoint', name='InventoryConsignment',
      //                                 Web_Service_Password__c='some_password', Web_Service_Name__c ='InventoryConsignment');
                                              
        RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        Transactions__c t = new Transactions__c(Account__c=a.Id, Status__c = 'In Progress');
        insert t;
        
        Product_FIM__c p = new Product_FIM__c(name='AC-0050', material_type__c='ZMOD', is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                             product_description__c='Test product', Product_Key__c='AC-0050', unit_of_measure__c='ED');
        insert p;
        Transaction_Items__c item = new Transaction_Items__c(Transaction_ID__c = t.id, Quantity__c=10, Model_Number__c = p.id);
        insert item;
        Test.startTest();
            t.Submit__c = true;
            update t;
            Transactions__c tt = [select id, name, status__c from Transactions__c where id = : t.Id];
            System.assertEquals('Send', tt.Status__c);
          
        Test.stopTest();
          Transaction_Log__c log = [select id, name, Transaction_ID__c, Description__c, Error_Description__c,type__c 
                                    from Transaction_Log__c where Transaction_ID__c = : tt.id];
          System.debug('*** Transaction log INFO ' +log);
          System.assertNotEquals(null, log);
          List<Transaction_Items__c> listOfitems = [select id, status__c from Transaction_Items__c where Transaction_ID__c = :tt.id];
          System.assertNotEquals(null, listOfitems);
          System.assertEquals('Pending', listOfitems.get(0).status__c);
          Transactions__c ttt = [select id, name, status__c from Transactions__c where id = : t.Id];
          System.assertEquals('Errors', ttt.Status__c);
    }

    @isTest
    private static void processConsignment_NoItems(){
       insert new SJM_Integrations__c(Web_Service_User__c='some_user', Web_Service_Endpoint__c='some_endpoint', name='InventoryConsignment',
                                      Web_Service_Password__c='some_password', Web_Service_Name__c ='InventoryConsignment');
        RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        Transactions__c t = new Transactions__c(Account__c=a.Id, Status__c = 'In Progress');
        insert t;
        Product_FIM__c p = new Product_FIM__c(name='AC-0050', material_type__c='ZMOD', is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                             product_description__c='Test product', Product_Key__c='AC-0050', unit_of_measure__c='ED');
        insert p;
        //don't add items
        Test.startTest();
          try{
            t.Submit__c = true;
            update t;
            Transactions__c tt = [select id, name, status__c from Transactions__c where id = : t.Id];
            System.assertEquals('Pending', tt.Status__c);
          }catch(Exception e){
            System.debug('Message '+ e.getMessage());
            System.assert(e.getMessage().contains('You cannot submit a Transaction if it does not have any Transaction Items'));
          }
        Test.stopTest();
      }
        
    
    @isTest
    private static void processTransferRequest(){
        insert new SJM_Integrations__c(Web_Service_User__c='some_user', Web_Service_Endpoint__c='some_endpoint', name='InventoryTransfer',
                                       Web_Service_Password__c='some_password', Web_Service_Name__c ='InventoryTransfer');
                                              
        RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        
        RecordType  transferRecordType = [select id, developername from recordtype where DeveloperName='Inventory_Transfer' and SObjectType = 'Transactions__c'];
        
        Transactions__c t = new Transactions__c(Account__c=a.Id, Status__c = 'In Progress', RecordTypeId=transferRecordType.id);
        insert t;
        
        Product_FIM__c p = new Product_FIM__c(name='AC-0050', material_type__c='ZMOD', is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                             product_description__c='Test product', Product_Key__c='AC-0050', unit_of_measure__c='ED');
        insert p;
        Transaction_Items__c item = new Transaction_Items__c(Transaction_ID__c = t.id, Quantity__c=10, Model_Number__c = p.id);
        insert item;
        Test.startTest();
            t.Submit__c = true;
            update t;
            Transactions__c tt = [select id, name, status__c from Transactions__c where id = : t.Id];
            System.assertEquals('Send', tt.Status__c);
        Test.stopTest();
         Transaction_Log__c log = [select id, name, Transaction_ID__c from Transaction_Log__c where Transaction_ID__c = : tt.id];
         System.assertNotEquals(null, log);
         
    }
    
    
    @isTest
    private static void processTransferRequest_Negative(){
        RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        RecordType  transferRecordType = [select id, developername from recordtype where DeveloperName='Inventory_Transfer' and SObjectType = 'Transactions__c'];
        
        Transactions__c t = new Transactions__c(Account__c=a.Id, Status__c = 'In Progress', RecordTypeId=transferRecordType.id);
        insert t;
        
        Product_FIM__c p = new Product_FIM__c(name='AC-0050', material_type__c='ZMOD', is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                             product_description__c='Test product', Product_Key__c='AC-0050', unit_of_measure__c='ED');
        insert p;
        Transaction_Items__c item = new Transaction_Items__c(Transaction_ID__c = t.id, Quantity__c=10, Model_Number__c = p.id);
        insert item;
        Test.startTest();
            t.Submit__c = true;
            update t;
            Transactions__c tt = [select id, name, status__c from Transactions__c where id = : t.Id];
            System.assertEquals('Send', tt.Status__c);
        Test.stopTest();
         Transaction_Log__c log = [select id, name, Transaction_ID__c from Transaction_Log__c where Transaction_ID__c = : tt.id];
         System.assertNotEquals(null, log);
         Transactions__c ttt = [select id, name, status__c from Transactions__c where id = : t.Id];
         System.assertEquals('Errors', ttt.Status__c);
    }
    
    @isTest
    private static void processTransferRequest_NoItems(){
        insert new SJM_Integrations__c(Web_Service_User__c='some_user', Web_Service_Endpoint__c='some_endpoint', name='InventoryTransfer',
                                       Web_Service_Password__c='some_password', Web_Service_Name__c ='InventoryTransfer');
                                              
        RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        
        RecordType  transferRecordType = [select id, developername from recordtype where DeveloperName='Inventory_Transfer' and SObjectType = 'Transactions__c'];
        
        Transactions__c t = new Transactions__c(Account__c=a.Id, Status__c = 'In Progress', RecordTypeId=transferRecordType.id);
        insert t;
        
        Product_FIM__c p = new Product_FIM__c(name='AC-0050', material_type__c='ZMOD', is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                             product_description__c='Test product', Product_Key__c='AC-0050', unit_of_measure__c='ED');
        insert p;
        //don't add items
        Test.startTest();
          try{
            t.Submit__c = true;
            update t;
            Transactions__c tt = [select id, name, status__c from Transactions__c where id = : t.Id];
            System.assertEquals('Pending', tt.Status__c);
          }catch(Exception e){
            System.debug('Message '+ e.getMessage());
            System.assert(e.getMessage().contains('You cannot submit a Transaction if it does not have any Transaction Items'));
          }
        Test.stopTest();
      }
    
      
    @isTest
    private static void processOkResponse(){
        String okResponse ='<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'+
            '<SOAP:Header/>'+
            '<SOAP:Body xmlns:urn="urn:partner.soap.sforce.com">'+
            '<ns0:DummyResponse xmlns:ns0="urn:partner.soap.sforce.com">'+
            '<ns0:Text>OK</ns0:Text>'+
            '</ns0:DummyResponse>'+
            '</SOAP:Body>'+
            '</SOAP:Envelope>';
        String okValue = FIT_TransactionsController.processResponse(okResponse, '');
        System.assertEquals('OK', okValue); 
    
    }
    public static testMethod void submitTrans(){
        
        // Create Accout
        RecordType  customerRecordType = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='SJM_Customer'];
        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, Status__c = 'In Progress');
        insert trans ;
        
        // Create Product
        Product_FIM__c prod = new Product_FIM__c(  Name='AC-0050', Material_type__c='ZMOD', Is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                                    Product_description__c='Test product', Product_Key__c='AC-0050', Unit_of_measure__c='ED', Serialized__c = true);
        insert prod;

        Inventory__c inv = new Inventory__c( Account__c = ac.Id, Quantity__c = 4 ) ;
        insert inv ; 

        // Create Transaction items
        Transaction_Items__c item = new Transaction_Items__c(Transaction_ID__c = trans.Id, Quantity__c=10, Model_Number__c = prod.Id, Inventory__c = inv.Id );
        insert item;

        // Declare controller and call its method two times 
        FIT_TransactionsController controller = new FIT_TransactionsController( new ApexPages.StandardController(trans) );
        PageReference pr ;
        pr = controller.submitOrder() ;
        pr = controller.submitOrder() ;

        // For Pic2Shop call back method 
        controller.transactionId = trans.Id ;
        controller.scanValue = 'AC-0050';

        ApexPages.currentPage().getParameters().put('scanValue', 'AC-0050');
        FIT_TransactionsController cont = new FIT_TransactionsController() ; // just for constructor code
    }
}