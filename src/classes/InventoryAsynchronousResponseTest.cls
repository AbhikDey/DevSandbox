@isTest
public class InventoryAsynchronousResponseTest {

    static testMethod void asynchSuccessResponse() {
        InventoryAsynchronousResponse.ListOfSjmInboundResponse sjmResponse = 
          new InventoryAsynchronousResponse.ListOfSjmInboundResponse();  
          sjmResponse.SjmTransactionHeader = new List<InventoryAsynchronousResponse.SjmTransactionHeader>();          
        InventoryAsynchronousResponse.SjmTransactionHeader header = new InventoryAsynchronousResponse.SjmTransactionHeader();
       
        
        //create account
         RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        //get consignment record type
        RecordType  rt = [select id, developername from recordtype where DeveloperName='Consignment_Request' AND SobjectType =:'Transactions__c'];
        System.debug('Record type '+ rt);
        //create transaction with above account and record type.
        Transactions__c t = new Transactions__c(RecordTypeId=rt.id, Account__c=a.ID);
        insert t;
        
        header.TransactionId      = t.ID;
        header.TransactionRowId   = t.ID;
        header.TransactionNumber  = t.ID;
        header.TransactionType    = rt.DeveloperName;
        header.TransactionStatus  = 'True';
        header.TransactionMode    = '';
        header.PONumber           = 'SomeNumber';       
        sjmResponse.SjmTransactionHeader.add(header);
        
        InventoryAsynchronousResponse.Response asyncResponse = InventoryAsynchronousResponse.Submit_Input (sjmResponse);
        System.debug('**** Response '+ asyncResponse);
        
        Transactions__c tAfter = [select id, name, status__c from Transactions__c where id = :t.ID];
        system.assertEquals( 'Received', tAfter.status__c );
    }
    
    static testMethod void asynchFailureResponse() {
        InventoryAsynchronousResponse.ListOfSjmInboundResponse sjmResponse = 
          new InventoryAsynchronousResponse.ListOfSjmInboundResponse();  
          sjmResponse.SjmTransactionHeader = new List<InventoryAsynchronousResponse.SjmTransactionHeader>();          
        InventoryAsynchronousResponse.SjmTransactionHeader header = new InventoryAsynchronousResponse.SjmTransactionHeader();
       
        
        //create account
         RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        //get consignment record type
        RecordType  rt = [select id, developername from recordtype where DeveloperName='Consignment_Request' AND SobjectType =:'Transactions__c' ];
        System.debug('Record type '+ rt);
        //create transaction with above account and record type.
        Transactions__c t = new Transactions__c(RecordTypeId=rt.id, Account__c=a.ID);
        insert t;
        Product_FIM__c p = new Product_FIM__c(name='AC-0050', material_type__c='ZMOD', is_active__c='Y', PH1__c='12190', PH2__c='12190', PH3__c='61219020',
                                             product_description__c='Test product', Product_Key__c='AC-0050', unit_of_measure__c='ED');
        insert p;
        //Add a Transaction Item
        Transaction_Items__c item = new Transaction_Items__c(Transaction_ID__c = t.id, Quantity__c=10, Model_Number__c = p.id, 
        Line_Number__c=Decimal.valueOf('10'), status__c='Pending');
        insert item;
        
        header.TransactionId      = t.ID;
        header.TransactionRowId   = t.ID;
        header.TransactionNumber  = t.ID;
        header.TransactionType    = rt.DeveloperName;
        header.TransactionStatus  = 'False';
        header.TransactionMode    = '';
        header.PONumber           = 'SomeNumber';      
        
        InventoryAsynchronousResponse.SjmTransactionDetailItems detail = new InventoryAsynchronousResponse.SjmTransactionDetailItems();
        detail.LineNumber = '10';
        detail.Status     = 'Failure';
        detail.ErrorNum   = '9990';
        detail.ErrorDesc  = 'No invetory available';
        detail.ErrorSeverity ='E';
        header.ListOfSjmTransactionDetailItems = new List<InventoryAsynchronousResponse.SjmTransactionDetailItems>();
        header.ListOfSjmTransactionDetailItems.add(detail);
        
        sjmResponse.SjmTransactionHeader.add(header);
        
        InventoryAsynchronousResponse.Response asyncResponse = InventoryAsynchronousResponse.Submit_Input (sjmResponse);
        System.debug('**** Response '+ asyncResponse);
        
        Transactions__c tAfter = [select id, name, status__c from Transactions__c where id = :t.ID];
        system.assertEquals( 'Errors', tAfter.status__c );
    }
    
    static testMethod void asynchPartialResponse() {
        InventoryAsynchronousResponse.ListOfSjmInboundResponse sjmResponse = 
          new InventoryAsynchronousResponse.ListOfSjmInboundResponse();  
          sjmResponse.SjmTransactionHeader = new List<InventoryAsynchronousResponse.SjmTransactionHeader>();          
        InventoryAsynchronousResponse.SjmTransactionHeader header = new InventoryAsynchronousResponse.SjmTransactionHeader();
       
        
        //create account
         RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        //get consignment record type
        RecordType  rt = [select id, developername from recordtype where DeveloperName='Consignment_Request' AND SobjectType =:'Transactions__c'];
        System.debug('Record type '+ rt);
        //create transaction with above account and record type.
        Transactions__c t = new Transactions__c(RecordTypeId=rt.id, Account__c=a.ID);
        insert t;
        
        header.TransactionId      = t.ID;
        header.TransactionRowId   = t.ID;
        header.TransactionNumber  = t.ID;
        header.TransactionType    = rt.DeveloperName;
        header.TransactionStatus  = 'Partial';
        header.TransactionMode    = '';
        header.PONumber           = 'SomeNumber';      
        
        InventoryAsynchronousResponse.SjmTransactionDetailItems detailFailed = new InventoryAsynchronousResponse.SjmTransactionDetailItems();
        detailFailed.LineNumber = '10';
        detailFailed.Status     = 'False';
        detailFailed.ErrorNum   = '9990';
        detailFailed.ErrorDesc  = 'No invetory available';
        detailFailed.ErrorSeverity ='E';
        
       
         InventoryAsynchronousResponse.SjmTransactionDetailItems detailSuccess = new InventoryAsynchronousResponse.SjmTransactionDetailItems();
        detailSuccess.LineNumber = '20';
        detailSuccess.Status     = 'True';
        detailSuccess.ErrorNum   = '9990';
        detailSuccess.ErrorDesc  = 'No invetory available';
        detailSuccess.ErrorSeverity ='I';
        
        
        header.ListOfSjmTransactionDetailItems = new List<InventoryAsynchronousResponse.SjmTransactionDetailItems>();
        header.ListOfSjmTransactionDetailItems.add(detailFailed);
        header.ListOfSjmTransactionDetailItems.add(detailSuccess);
        
        sjmResponse.SjmTransactionHeader.add(header);
        
        InventoryAsynchronousResponse.Response asyncResponse = InventoryAsynchronousResponse.Submit_Input (sjmResponse);
        System.debug('**** Response '+ asyncResponse);
        
        Transactions__c tAfter = [select id, name, status__c from Transactions__c where id = :t.ID];
        system.assertEquals( 'Partial', tAfter.status__c );
    }
    
    static testMethod void transactionLevelErrorResponse() {
        InventoryAsynchronousResponse.ListOfSjmInboundResponse sjmResponse = 
          new InventoryAsynchronousResponse.ListOfSjmInboundResponse();  
          sjmResponse.SjmTransactionHeader = new List<InventoryAsynchronousResponse.SjmTransactionHeader>();          
        InventoryAsynchronousResponse.SjmTransactionHeader header = new InventoryAsynchronousResponse.SjmTransactionHeader();
       
        
        //create account
         RecordType  customerRecordType = [select id, developername from recordtype where DeveloperName='SJM_Customer'];
        Account a = new Account(Name='Beverly Hospital', recordTypeId=customerRecordType.id);
        insert a;
        //get consignment record type
        RecordType  rt = [select id, developername from recordtype where DeveloperName='Consignment_Request' AND SobjectType =:'Transactions__c'];
        System.debug('Record type '+ rt);
        //create transaction with above account and record type.
        Transactions__c t = new Transactions__c(RecordTypeId=rt.id, Account__c=a.ID);
        insert t;
        
        header.TransactionId      = t.ID;
        header.TransactionRowId   = t.ID;
        header.TransactionNumber  = t.ID;
        header.TransactionType    = rt.DeveloperName;
        header.TransactionStatus  = 'False';
        header.TransactionMode    = '';
        header.PONumber           = 'SomeNumber';      
        
        InventoryAsynchronousResponse.SjmTransactionDetailItems detailFailed = new InventoryAsynchronousResponse.SjmTransactionDetailItems();
        detailFailed.LineNumber = '0';
        detailFailed.Status     = 'False';
        detailFailed.ErrorNum   = '9990';
        detailFailed.ErrorDesc  = 'No invetory available';
        detailFailed.ErrorSeverity ='E';
        
        header.ListOfSjmTransactionDetailItems = new List<InventoryAsynchronousResponse.SjmTransactionDetailItems>();
        header.ListOfSjmTransactionDetailItems.add(detailFailed);
        sjmResponse.SjmTransactionHeader.add(header);
        
        InventoryAsynchronousResponse.Response asyncResponse = InventoryAsynchronousResponse.Submit_Input (sjmResponse);
        System.debug('**** Response '+ asyncResponse);
        
        Transactions__c tAfter = [select id, name, status__c from Transactions__c where id = :t.ID];
        system.assertEquals( 'Errors', tAfter.status__c );
    }
    
     static testMethod void asynchTransactionIdNoFound() {
        InventoryAsynchronousResponse.ListOfSjmInboundResponse sjmResponse = 
          new InventoryAsynchronousResponse.ListOfSjmInboundResponse();  
          sjmResponse.SjmTransactionHeader = new List<InventoryAsynchronousResponse.SjmTransactionHeader>();          
        InventoryAsynchronousResponse.SjmTransactionHeader header = new InventoryAsynchronousResponse.SjmTransactionHeader();
        ID id = 'a0ig00000033AqJ';//an ID not in the system
        header.TransactionId      = id;
        header.TransactionRowId   = id;
        header.TransactionNumber  = id;
        header.TransactionType    = 'Consignment_Request';
        header.TransactionStatus  = 'True';
        header.TransactionMode    = '';
        header.PONumber           = 'SomeNumber';      
        sjmResponse.SjmTransactionHeader.add(header);
        InventoryAsynchronousResponse.Response asyncResponse = InventoryAsynchronousResponse.Submit_Input (sjmResponse);
        system.assertEquals( 'FAILURE', asyncResponse.SJMResponse.get(0).status );
    }
    
    static testMethod void asynchTransactionIdInvalidFormat() {
        InventoryAsynchronousResponse.ListOfSjmInboundResponse sjmResponse = 
          new InventoryAsynchronousResponse.ListOfSjmInboundResponse();  
          sjmResponse.SjmTransactionHeader = new List<InventoryAsynchronousResponse.SjmTransactionHeader>();          
        InventoryAsynchronousResponse.SjmTransactionHeader header = new InventoryAsynchronousResponse.SjmTransactionHeader();
        String id = 'invalid_transaction_id';//an invalid format
        header.TransactionId      = id;
        header.TransactionRowId   = id;
        header.TransactionNumber  = id;
        header.TransactionType    = 'Consignment_Request';
        header.TransactionStatus  = 'True';
        header.TransactionMode    = '';
        header.PONumber           = 'SomeNumber';      
        sjmResponse.SjmTransactionHeader.add(header);
        InventoryAsynchronousResponse.Response asyncResponse = InventoryAsynchronousResponse.Submit_Input (sjmResponse);
        system.assertEquals( 'FAILURE', asyncResponse.SJMResponse.get(0).status );
    }
}