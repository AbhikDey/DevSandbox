global with sharing class FIT_TransactionsController { 

    private ApexPages.StandardController standardController;
    private static List<Transaction_Items__c> toUpdate;
    private static final String INV_CONSIGNMENT='InventoryConsignment';
    private static final String INV_TRANSFER='InventoryTransfer';
    private static final String DEFAULT_PRIMARY_PLANT = '1017';
    public String scanValue {get; set;}
    public String transactionId {get; set;}
    public Boolean itemCreated {get; set; }
    
    public FIT_TransactionsController( ) 
    {
        scanValue = ApexPages.currentPage().getParameters().get('scanValue');
        if( scanValue == 'code') scanValue = ApexPages.currentPage().getParameters().get('ean');
        transactionId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('UAC: scanValue ' + scanValue + ' transactionId ' + transactionId ) ;
        if( scanValue.length() > 7 )
        {
            scanValue = scanValue.right(7);
        }
        itemCreated = false; 
    }

    public FIT_TransactionsController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        if( !Test.isRunningTest() ) standardController.addFields( new List<String>{'Status__c'});
    }
 
    public PageReference sendConsignmentRequest(){
        Transactions__c trans = (Transactions__c) standardController.getRecord();   
        sendConsignmentRequest(trans.id);
        PageReference pr = new ApexPages.StandardController(trans).view();
        pr.setRedirect(true);
        return pr;
    }
    
     public PageReference sendInventoryTransfer(){
        Transactions__c trans = (Transactions__c) standardController.getRecord();   
        sendTransferRequest(trans.id);
        PageReference pr = new ApexPages.StandardController(trans).view();
        pr.setRedirect(true);
        return pr;
    }
    
    
    @future(callout=true)
    public static void sendConsignmentRequest(String id)
    {
        
        Transactions__c t = [select id, status__c, User__r.FirstName, OwnerId,
                             PO_Number__c, Shipping_Priority__c, Account__c, Account__r.SJM_ID__c, User__r.Business_Partner__c, 
                             Ship_To_Address__r.Account__r.SJM_ID__c, Ship_To_Address__r.User__r.Business_Partner__c
                             from Transactions__c where id = :id];
        toUpdate = new List<Transaction_Items__c>();   
       
        try{
             SJM_Integrations__c sjmIntegration = getServiceCredentials(INV_CONSIGNMENT);
             if(sjmIntegration == null) throw new UnableToReachSJMException('No SJM integration defined for request: '+ INV_CONSIGNMENT);
             String request  = buildConsignmentSoapMessage(t);
        
             HttpRequest req =getHttpReqWithAuthHeader(sjmIntegration.Web_Service_Endpoint__c, sjmIntegration.Web_Service_User__c, 
                                                       sjmIntegration.Web_Service_Password__c, request);
             Http http = new Http();
             req.setBody(request);
             HTTPResponse res= null;
             System.debug('*** SJM Req body  '+ req.getBody());
             if(!Test.isRunningTest()){
                res = http.send(req);
             }else{
                res = new HTTPResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
             }
             System.debug('*** SJM Response  '+ res);
             if(res.getStatusCode() == 200){ 
                 System.debug('*** SJM Response body '+ res.getBody());
                  if(Test.isRunningTest() || 'OK'.equalsIgnoreCase(processResponse(res.getBody(), INV_CONSIGNMENT))){
                      //System.debug('SJM service response: '+ sResponse);
                      t.Status__c = 'Send';
                      insert new Transaction_Log__c(Log_Date__c= date.today(), Transaction_ID__c=t.id,  Description__c='Transaction Sent to SAP'); 
                      if(!toUpdate.isEmpty()){
                       update toUpdate;      
                      }
                  }else{
                     System.debug('Response did not return a status of OK '+ res.getBody());
                     throw new UnableToReachSJMException('Response was not OK ');  
                  }
             }else{
                System.debug('Response code '+ +res.getStatusCode());
                throw new UnableToReachSJMException('Http response code: ' +res.getStatusCode());
             }  
        }catch(Exception e){
            system.debug('Error sending Consignment request'+ e.getMessage());
            t.Status__c = 'Errors';
            String errorMessage = e.getMessage().length() < 200 ? e.getMessage() : e.getMessage().substring(0, 200);
            insert new Transaction_Log__c(Log_Date__c= date.today(), Transaction_ID__c=t.id,  Error_Description__c=errorMessage,
                                          Description__c='Error sending Consignment request',
                                          type__c='Data Power Error');
            List<Transaction_Items__c> listOfitems = [select id, status__c from Transaction_Items__c where Transaction_ID__c = :t.id];
            if(!listOfitems.isEmpty()){
                for(Transaction_Items__c item : listOfitems){
                    item.status__c = 'Pending';
                }        
            }    
            update listOfitems;
        }
         upsert t;
    }
    
    @future(callout=true)
    public static void sendTransferRequest(String id){
         Transactions__c t = [select id, status__c, User__r.FirstName, 
                             PO_Number__c, Shipping_Priority__c, Account__c, Account__r.SJM_ID__c, User__r.Business_Partner__c, Ship_To_Address__r.Account__r.SJM_ID__c
                             from Transactions__c where id = :id];
        toUpdate = new List<Transaction_Items__c>();   
       
        try{
             SJM_Integrations__c sjmIntegration = getServiceCredentials(INV_TRANSFER);
             if(sjmIntegration == null) throw new UnableToReachSJMException('No SJM integration defined for request: '+ INV_TRANSFER);
             String request = buildInventoryTransferSoapMessage(t);
             HttpRequest req =getHttpReqWithAuthHeader(sjmIntegration.Web_Service_Endpoint__c, sjmIntegration.Web_Service_User__c, 
                                                       sjmIntegration.Web_Service_Password__c, request);
             Http http = new Http();
             req.setBody(request);
             HTTPResponse res= null;
             System.debug('*** SJM Req body  '+ req.getBody());
             if(!Test.isRunningTest()){
                res = http.send(req);
             }else{
                res = new HTTPResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
             }
             System.debug('*** SJM Response  '+ res.getBody());
             if(res.getStatusCode() == 200){ 
                 System.debug('*** SJM Response body '+ res.getBody());
                  if(Test.isRunningTest() || 'OK'.equalsIgnoreCase(processResponse(res.getBody(), INV_TRANSFER))){
                      t.Status__c = 'Send';
                      insert new Transaction_Log__c(Log_Date__c= date.today(), Transaction_ID__c=t.id,  Description__c='Transaction Sent to SAP'); 
                      if(!toUpdate.isEmpty()){
                       update toUpdate;      
                      }
                     
                  }else{
                       System.debug('Response did not return a status of OK '+ res.getBody());
                       throw new UnableToReachSJMException('Response was not OK ');  
                  }
             }else{
                System.debug('Response code '+ +res.getStatusCode());
                throw new UnableToReachSJMException('Response code: ' +res.getStatusCode());
             }           
            
        }catch(Exception e){
            system.debug('Error sending Inventory Transfer request'+ e.getMessage());
            t.Status__c = 'Errors';
            String errorMessage = e.getMessage().length() < 200 ? e.getMessage() : e.getMessage().substring(0, 200);
            insert new Transaction_Log__c(Log_Date__c= date.today(), Transaction_ID__c=t.id,  Error_Description__c=errorMessage,
                                          Description__c='Error sending Inventory Transfer request',
                                          type__c='Data Power Error');            
        }
         upsert t;

    }
    
    private static HttpRequest getHttpReqWithAuthHeader(String endpoint, String user, String password, String soapRequest){
         HttpRequest req = new HttpRequest();
         req.setEndpoint(endpoint);
         req.setMethod('POST');
         Blob headerValue = Blob.valueOf(user + ':' + password);
         String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
         req.setHeader('Authorization', authorizationHeader);
         req.setHeader('Content-Length',String.valueOf(soapRequest.length()));
         req.setHeader('Content-Type', 'text/xml');
        return req;
    }
    @TestVisible
    private static String processResponse(String soapResponse, String responseType){
        Dom.Document doc = new Dom.Document();
        doc.load(soapResponse);
        Dom.XMLNode Envelope = doc.getRootElement();
        System.debug('Envolpe: '+ Envelope);
        //body
        Dom.XMLNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/'); 
        system.debug('Response body' + body);
        //DummyResponse 
        Dom.XMLNode dummyResponse = body.getChildElement('DummyResponse', 'urn:partner.soap.sforce.com'); 
        system.debug('Response DummyResponse' + dummyResponse);
        //child element or response code
        Dom.XMLNode serviceResponseCode = dummyResponse.getChildElement('Text', 'urn:partner.soap.sforce.com'); 
        //system.debug('Response value of Text' + serviceResponseCode); 
        system.debug(' service response code ' + serviceResponseCode.getText());
        return serviceResponseCode.getText();
    }
   
    
    private static SJM_Integrations__c getServiceCredentials(String serviceName){
        SJM_Integrations__c sjmIntegration = SJM_Integrations__c.getValues(serviceName);
        return sjmIntegration != null ? sjmIntegration : null;
        
    }
        
    private static String buildConsignmentSoapMessage(Transactions__c t){
        User owningUser = [select Business_Partner__c from User where id = :t.OwnerId];
        String TransactionType      ='Consignment Inventory Orders';
        String TransactionRowId     = t.id;
        TransactionRowId            = TransactionRowId.length() > 15 ? TransactionRowId.substring(0, 15): TransactionRowId;
        String OrderNumber          = t.PO_Number__c != null ? t.PO_Number__c : t.id; 
        String SJMSoldToFacilityNum = t.Account__c != null && t.Account__r.SJM_ID__c != null ? t.Account__r.SJM_ID__c : t.User__r.Business_Partner__c; 
        String SJMShipToFacilityNum = t.Ship_To_Address__r.Account__r.SJM_ID__c != null ? t.Ship_To_Address__r.Account__r.SJM_ID__c  : t.Ship_To_Address__r.User__r.Business_Partner__c; 
        String SJMBenefitingRepUId  = owningUser.Business_Partner__c != null ? owningUser.Business_Partner__c : ''; //
        String PrimaryPlant         = DEFAULT_PRIMARY_PLANT;
        String SJMPONum             = t.PO_Number__c != null ? t.PO_Number__c : t.id;
        String ShipInstructions     = '';
        //NEPPAS01:JIRA|SR-808| fix the shipping priority values 98,96
        String DeliveryPriority     = t.Shipping_Priority__c =='FedEx Second Day' ?  '24' :  t.Shipping_Priority__c =='FedEx Standard Overnight' ? '21' : '25';
        
        String message = '<soapenv:Envelope  xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com">'+
                            '<soapenv:Header></soapenv:Header>'+
                            '<soapenv:Body>'+
                            '<urn:USD_CONSIGN_FILLUP_REQ xmlns:urn="urn:partner.soap.sforce.com">'+
                                 '<urn:ListOfSjmConsignmentInventory-Orders>'+
                                    '<urn:SjmConsignmentInventoryOrderEntry-Orders>'+
                                       '<urn:TransactionType>Consignment Inventory Orders</urn:TransactionType>'+
                                       '<urn:TransactionRowId>'+TransactionRowId+'</urn:TransactionRowId>'+
                                       '<urn:OrderNumber>'+OrderNumber+'</urn:OrderNumber>'+
                                       '<urn:SJMSoldToFacilityNum>'+SJMSoldToFacilityNum+'</urn:SJMSoldToFacilityNum>'+
                                       '<urn:SJMShipToFacilityNum>'+SJMShipToFacilityNum+'</urn:SJMShipToFacilityNum>'+
                                       '<urn:SJMBenefitingRepUId>'+SJMBenefitingRepUId+'</urn:SJMBenefitingRepUId>'+
                                       '<urn:PrimaryPlant>'+PrimaryPlant+'</urn:PrimaryPlant>'+
                                       '<urn:SJMPONum>'+SJMPONum+'</urn:SJMPONum>'+
                                       '<urn:ShipInstructions>'+ShipInstructions+'</urn:ShipInstructions>'+
                                       '<urn:DeliveryPriority>'+DeliveryPriority+'</urn:DeliveryPriority>'+
                                       '<urn:ListOfOrderEntry-LineItems>';
                                        Integer lineNum = 10;
                                        
                                        List<Transaction_Items__c> transactionItemsId = [select id, name, model_number__c, quantity__c,Inventory__r.Model_Number__c, Line_Number__c 
                                                                          from Transaction_Items__c where Transaction_ID__c =:t.ID];
                                        List<ID> ids = new List<ID>();
                                        for(Transaction_Items__c ti : transactionItemsId ){
                                            ids.add(ti.Model_Number__c);
                                        }
                                        Map<Id, Product_FIM__c> inventoryModelNumToProductMap = new Map<Id, Product_FIM__c>();
                                        List<Product_FIM__c> prouductsFIMList = [select name from Product_FIM__c where id IN :ids];
                                        for(Product_FIM__c p: prouductsFIMList){
                                            inventoryModelNumToProductMap.put(p.id, p);
                                        }
                                       
                                        
                                       // for(Transaction_Items__c tItem :  [select id, name, model_number__c, quantity__c,Inventory__r.Model_Number__c, Line_Number__c 
                                       //                                 from Transaction_Items__c where Transaction_ID__c =:t.ID]){
                                       //   Product_FIM__c productName = [select name from Product_FIM__c where id = :tItem.model_number__c];
                                          
                                       for(Transaction_Items__c tItem :  transactionItemsId){
                                          Product_FIM__c productName = inventoryModelNumToProductMap.get(tItem.model_number__c);
                                          String LineNumber        = String.valueOf(lineNum);
                                          String SJMModelNumber    = productName.Name; 
                                          String QuantityRequested = String.valueOf(tItem.Quantity__c);
                                          //String SJMSpiffableFlag  = tItem.Request_Short_Dated_Product__c ? 'Y' : 'N';
                                          tItem.status__c = 'Pending';
                                          tItem.Line_Number__c =  lineNum;
                                          lineNum = lineNum + 10; //10, 20, 30. etc.                                            
                                          toUpdate.add(tItem);
                                          message = message+'<urn:OrderEntry-LineItems>'+
                                             '<urn:LineNumber>'+LineNumber+'</urn:LineNumber>'+
                                             '<urn:SJMModelNumber>'+SJMModelNumber+'</urn:SJMModelNumber>'+
                                             '<urn:QuantityRequested>'+QuantityRequested+'</urn:QuantityRequested>'+
                                             //'<urn:SJMSpiffableFlag>'+SJMSpiffableFlag+'</urn:SJMSpiffableFlag>'+
                                          '</urn:OrderEntry-LineItems>';
                                         }
                                        message = message +
                                       '</urn:ListOfOrderEntry-LineItems>'+
                                    '</urn:SjmConsignmentInventoryOrderEntry-Orders>'+
                                 '</urn:ListOfSjmConsignmentInventory-Orders>'+
                              '</urn:USD_CONSIGN_FILLUP_REQ>'+
                            '</soapenv:Body>'+
                            '</soapenv:Envelope>';
        return message;
    }
  
     private static String buildInventoryTransferSoapMessage(Transactions__c t){   
         Boolean headerExists = false;
         String TransactionType         ='Stock Transfer';
         String TransactionRowId        = t.id;
         TransactionRowId               = TransactionRowId.length() > 15 ? TransactionRowId.substring(0, 15): TransactionRowId;
         String TransactionNumber       = t.id;
         String DestinationInvLocation  = t.User__r.Business_Partner__c;
         String SourceInvLocation='';
         
         List<Transaction_Items__c> transactionItesmList = [select id, name, model_number__c, quantity__c, Line_Number__c, Inventory__r.Model_Number__c,
                                                            Inventory__r.Part_Number__c, Inventory__r.Serial_Number__c, Inventory__r.Batch_Lot_Number__c, Inventory__r.Stock_Partner_Number__c
                                                            from Transaction_Items__c where Transaction_ID__c =:t.ID];
          String soapMessage=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com">'+
           '<soapenv:Header/>'+
           '<soapenv:Body>'+
              '<urn:USD_INV_TRANS_REQ xmlns:urn="urn:partner.soap.sforce.com">'+
                 '<urn:ListOfSjmInventoryTransfer>'+
                    '<urn:SjmInventoryTransfer>'+
                      
                       '<urn:TransactionType>'+TransactionType+'</urn:TransactionType>'+
                       '<urn:TransactionRowId>'+TransactionRowId+'</urn:TransactionRowId>'+
                       '<urn:TransactionNumber>'+TransactionNumber+'</urn:TransactionNumber>'+
                       '<urn:SourceInvLocation>'+transactionItesmList.get(0).Inventory__r.Stock_Partner_Number__c+'</urn:SourceInvLocation>'+ 
                       '<urn:DestinationInvLocation>'+DestinationInvLocation+'</urn:DestinationInvLocation>'+
                       '<urn:ListOfSjmInventoryItem>';
                         Integer lineNum = 10;
                         
                        for(Transaction_Items__c tItem : transactionItesmList){
                         
                             system.debug('Transaction item details: '+ tItem);
                            // Product_FIM__c productName = [select name from Product_FIM__c where id = :tItem.model_number__c];
                            // system.debug('Product Name: '+ productName); 
                             String LineNumber    = String.valueOf(lineNum);
                             String ModelNumber   = tItem.Inventory__r.Model_Number__c != null ? tItem.Inventory__r.Model_Number__c : ''; //tItem.Model_Number__c; //productName.name;
                             String PartNumber    = tItem.Inventory__r.Part_Number__c  != null ? tItem.Inventory__r.Part_Number__c : '';
                             String SerialNumber  = tItem.Inventory__r.Serial_Number__c != null ? tItem.Inventory__r.Serial_Number__c : '';
                             String LotNumber     = tItem.Inventory__r.Batch_Lot_Number__c != null ? tItem.Inventory__r.Batch_Lot_Number__c : '';
                             String Quantity      = String.valueOf(tItem.Quantity__c);
                             tItem.Line_Number__c = lineNum;
                             lineNum = lineNum + 10;
                             SourceInvLocation  = tItem.Inventory__r.Stock_Partner_Number__c != null ? tItem.Inventory__r.Stock_Partner_Number__c : '';
                             tItem.status__c = 'Pending';
                             toUpdate.add(tItem);
                              soapMessage = soapMessage +
                               '<urn:SjmInventoryItem>'+
                                 '<urn:LineNumber>'+LineNumber+'</urn:LineNumber>'+
                                 '<urn:ModelNumber>'+ModelNumber+'</urn:ModelNumber>'+
                                 '<urn:PartNumber>'+PartNumber+'</urn:PartNumber>'+
                                 '<urn:SerialNumber>'+SerialNumber+'</urn:SerialNumber>'+
                                 '<urn:LotNumber>'+LotNumber+'</urn:LotNumber>'+
                                 '<urn:Quantity>'+Quantity+'</urn:Quantity>'+     
                             '</urn:SjmInventoryItem>';
                         }
                          soapMessage = soapMessage +
                       '</urn:ListOfSjmInventoryItem>'+       
                    '</urn:SjmInventoryTransfer>'+
                 '</urn:ListOfSjmInventoryTransfer>'+
             '</urn:USD_INV_TRANS_REQ>'+
           '</soapenv:Body>'+
        '</soapenv:Envelope>';
         return soapMessage;
     }
    
     
     // Method to Control Submit button functionality on Transaction object
    public PageReference submitOrder(){
        system.debug('### START METHOD submitOrder() ');

        // Get transaction record
        Transactions__c trans = (Transactions__c) standardController.getRecord();
        
        // Create a page reference to redirect after processing 
        PageReference pr = new ApexPages.StandardController(trans).view();
        pr.setRedirect(true);
        
        // When Transaction status equals to InProgress then get all related TransactionItems and update then with decrement of 1 Quantity
        if( trans.Status__c == 'In Progress' ){

            // Get transaction items
            List<Transaction_Items__c> items = [ SELECT Id, Inventory__c FROM Transaction_Items__c  WHERE Transaction_ID__c = :trans.Id ] ;
            Set<Id> inventoryIds = new Set<Id>(); 

            // When Transaction item found then decrement by 1 and update 
            if( items.size() > 0 ){
                
                for( Transaction_Items__c it : items ){
                    if( it.Inventory__c != null ) inventoryIds.add(it.Inventory__c);
                }

                List<Inventory__c> inventoryList = [SELECT Id, Quantity__c FROM Inventory__c WHERE ID IN :inventoryIds ] ;
                if( inventoryList.size() > 0 ){
                    for( Inventory__c inv : inventoryList ){
                        if( inv.Quantity__c !=  null ) inv.Quantity__c = inv.Quantity__c-1;
                    }
                    update inventoryList ; 
                }
                trans.Status__c = 'PO Pending' ;
            }
        }
        else if ( trans.Status__c == 'PO Pending' ){
            trans.Status__c = 'Invoiced' ;
        }

        // Update Transaction record 
        update trans ; 

        // Redirect to transaction record 
        return pr ;
        //return null;

    }

    
    public class UnableToReachSJMException extends Exception {}
}