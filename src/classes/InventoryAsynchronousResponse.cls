global  with sharing class InventoryAsynchronousResponse {
webService static Response Submit_Input (ListOfSjmInboundResponse ListOfSjmInboundResponse) {
        
          String responseMessage = '';
          String responseStatus  ='SUCCESS';
          ID id = null;
          String tempId = null;
          List<SJMResponse> responseList = new List<SJMResponse>();
          SJMResponse sjmResponse = null;
          String NoTransactionFoundEmail='DG-BF-IT-GIT-CRM-Solutions@sjm.com';
       try{
          
          //This should always be one transaction per call
          SjmTransactionHeader transHeader = ListOfSjmInboundResponse.SjmTransactionHeader.get(0);
          System.debug('transaction id/name '+ transHeader.TransactionRowId);
          tempId = transHeader.TransactionRowId;
          id = transHeader.TransactionRowId;
          List<Transactions__c> transactions = [select id, name, status__c from Transactions__c where id =:id];
          System.debug('size '+ transactions.size());
          if(transactions.size() == 1){
               Transactions__c tt = transactions.get(0); 
              if(!String.IsEmpty(transHeader.TransactionId)){ tt.SAP_Order__c = transHeader.TransactionId;}
               System.debug('******   '+tt);
               System.debug('******   Transaction error check');
               Map<Decimal, SjmTransactionDetailItems>  successItems = new Map<Decimal, SjmTransactionDetailItems>();
               List<SjmTransactionDetailItems> transactionLevelErrors = new List<SjmTransactionDetailItems>();
               Map<Decimal, List<SjmTransactionDetailItems>> itemLevelErrors = new Map<Decimal, List<SjmTransactionDetailItems>>();
              if(transHeader.ListOfSjmTransactionDetailItems != null && !transHeader.ListOfSjmTransactionDetailItems.isEmpty()){
                   for(SjmTransactionDetailItems detailItem : transHeader.ListOfSjmTransactionDetailItems){
                           if(detailItem.LineNumber == '0'){
                              transactionLevelErrors.add(detailItem);
                           }else{
                               //get item based on key and append new record.
                               if(itemLevelErrors.get(Decimal.valueOf(detailItem.LineNumber)) == null){
                                   itemLevelErrors.put(Decimal.valueOf(detailItem.LineNumber), new List<SjmTransactionDetailItems>());
                               }
                               itemLevelErrors.get(Decimal.valueOf(detailItem.LineNumber)).add(detailItem);
                           }
                   }
              }
              
              
               System.debug('******   Transaction Item error check');
            if('True'.equalsIgnoreCase(transHeader.TransactionStatus)){
                   tt.Status__c = 'Received';
                   tt.SAP_Order__c = transHeader.TransactionId;                      
                   update tt;
                   //insertTransactionLog('Transaction Successfully Processed by SAP', tt.ID);
                    insert new Transaction_Log__c(Log_Date__c=date.today(), Description__c='Transaction Successfully Processed by SAP', Transaction_ID__c=id);
                    List<Transaction_Items__c> itemList = [select id, status__c from Transaction_Items__c where  Transaction_ID__c =:tt.id];
                    for(Transaction_Items__c tItem : itemList){
                        if(tItem.Status__c =='Pending')  {
                          tItem.Status__c='Success';
                        }
                    }
                    update itemList;
                  
              }else if('Partial'.equalsIgnoreCase(transHeader.TransactionStatus)){
                  System.debug('Partial response');
                  // insertTransactionLog('Transaction Partially Processed by SAP', tt.ID);
                   processTransactionLevelErrors(transactionLevelErrors, id);
                   updateItemStatus(itemLevelErrors, id, false);
                   updateTransToError('Partial', tt);
              }else{
                 
                 System.debug('False response there are errors in response ');
                 processTransactionLevelErrors(transactionLevelErrors, id);
                 updateItemStatus(itemLevelErrors, id, false);
                 updateTransToError('Errors', tt);
                
                  
            }
         }else{
              setExceptionalCaseSingleEmail(tempId, NoTransactionFoundEmail);
              responseMessage='Transaction id '+ tempId + ' was not found.';
              responseStatus='FAILURE';
        }        
          
         sjmResponse = new SJMResponse(id, responseStatus, responseMessage);
       }catch(Exception e){
              responseStatus='FAILURE';
              responseMessage=e.getMessage();
            if(id != null){
               insertTransactionLog(e.getMessage(), id); 
            }else{
                //case when ID is not formatted correctly
                sjmResponse = new SJMResponse(tempId, responseStatus, responseMessage);
                setExceptionalCaseSingleEmail(tempId, NoTransactionFoundEmail);
            }
       }
    
      responseList.add(SJMResponse);
      return new Response(responseList) ;
    
    }
    
   
    private static void setExceptionalCaseSingleEmail(String recId, String recipient){
        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
        singleMail.setSubject('Error Processing Acknowledgement');   
        String[] toAddresses = new String[]{recipient};
            singleMail.setToAddresses(toAddresses);
        //If transaction id is not found or is invalid we will not be able to use a template.
        // singleMail.setTargetObjectId(id);
        singleMail.setPlainTextBody('The following error has occurred while attempting to process the Acknowledgement for the following transaction: '+recId+'.\n\n' +
                                    'Error Description: Transaction ID could not be found within Salesforce.');

                //add mail
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        emails.add(singleMail);
        Messaging.sendEmail(emails);
    }
    
     private static void updateTransToError(String status, Transactions__c tt){
         tt.Status__c = status;
         update tt;
    }
    
    private static void insertTransactionLog(String description, ID id){
         insert new Transaction_Log__c(Log_Date__c=date.today(), Error_Description__c=description, Transaction_ID__c=id);
    }
    
    
    private static void processTransactionLevelErrors(List<SjmTransactionDetailItems> errorItems, Id transactionId){
         List<Transaction_Log__c> logs = new List<Transaction_Log__c>();
         if(!errorItems.isEmpty()){
             for(SjmTransactionDetailItems sjmItem : errorItems){
                   logs.add(new Transaction_Log__c(Error_Number__c=sjmItem.ErrorNum,
                                                   Error_Description__c=sjmItem.ErrorDesc,
                                                   Error_Severity__c=sjmItem.ErrorSeverity,
                                                   Transaction_ID__c=transactionId,
                                                   type__c='SAP Error',
                                                   Log_Date__c=date.today(),
                                                   Description__c='Transaction Failed to Process by SAP'));
             }
         }
        
        if(!logs.isEmpty()){
            insert logs;
        }
    }
    
    
    
    private static void updateItemStatus(Map<Decimal, List<SjmTransactionDetailItems>> errorItems, Id transactionId, Boolean updateAllToError){
        List<Transaction_Items__c> itemsToUpdate = new List<Transaction_Items__c>();
        List<Transaction_Log__c> logs = new List<Transaction_Log__c>();
        System.debug('updateItemsToError size ' + errorItems.size() + ' keys: '+ errorItems.keySet() + ' transactionId ' + transactionId);
        List<Transaction_Items__c> errItems = new List<Transaction_Items__c>();
        if(!errorItems.isEmpty() && !updateAllToError){
            //Need to retrieve all of the Transactions, then check those that are in error by using the line number, 
            //then update all of the remaining items to success?
            errItems = [select id, Line_Number__c, Error_Number__c , Error_Description__c, Status__c, Error_Severity__c 
                                                   from Transaction_Items__c where Transaction_ID__c = :transactionId AND status__c='Pending'];
                                                  // and line_number__c in :errorItems.keySet()];
                                                  // 
            System.debug('All transaction items  size ' + errItems.size() +' ' + errItems);            
            
            for(Transaction_Items__c i : errItems){
                 System.debug('Item to update ' + i); 
                if(errorItems.containsKey(i.Line_Number__c)){
                  List<SjmTransactionDetailItems> sjmItems = errorItems.get(i.Line_Number__c);
                  System.debug('sjmItems size ' + sjmItems.size()  +'  i.Line_Number__c '+ i.Line_Number__c);
                    if(sjmItems != null && !sjmItems.isEmpty()){
                         for(SjmTransactionDetailItems sjmItem : sjmItems) {
                            logs.add(new Transaction_Log__c(Error_Number__c=sjmItem.ErrorNum,
                                                                           Error_Description__c=sjmItem.ErrorDesc,
                                                                           Error_Severity__c=sjmItem.ErrorSeverity,
                                                                           Transaction_ID__c=transactionId,
                                                                           Transaction_Item_ID__c=i.id,
                                                                           type__c='SAP Error',
                                                                           Log_Date__c=date.today(),
                                                                           Description__c='Transaction Failed to Process by SAP'));
                            
                            i.status__c = 'Failure';
                            i.Error_Description__c = sjmItem.ErrorDesc;
                            i.Error_Severity__c = sjmItem.ErrorSeverity;
                            i.Error_Number__c   = sjmItem.ErrorNum; 
                            itemsToUpdate.add(i);   
                        }
                    }
                }else{
                  i.status__c = 'Success';
                  itemsToUpdate.add(i); 
                }
            }   
            
        }
        if(!itemsToUpdate.isEmpty()){
           update itemsToUpdate;
        }
        if(!logs.isEmpty()){
            insert logs;
        }
        
        
    }
    
   


    /**
     * These object are user for the Salesforce Inbound Ack call from SJM
     * ListOfSjmInboundResponse, SjmTransactionHeader, SjmTransactionDetailItems
     */
    global class ListOfSjmInboundResponse{
        webservice List<SjmTransactionHeader> SjmTransactionHeader {get;set;}
    }
    //note trasaction is a reserved word
   global class SjmTransactionHeader{
        //Ties to the SAP order number rerturned by SAP
        webService  string TransactionId {get;set;}
        webService  string TransactionRowId {get;set;}
        webService  string TransactionNumber {get;set;}
        webService  string TransactionType {get;set;}
        webService  string TransactionStatus {get;set;}
        //webService  string SAPRefId {get;set;}
        webService  string TransactionMode {get;set;}
        webService  string PONumber {get;set;}
       
       //added errors at the transaction level
       //webService List<SjmTransactionError> ListOfSjmTransactionErrors {get; set;}
       webService List<SjmTransactionDetailItems> ListOfSjmTransactionDetailItems {get; set;}
    }
    
   global class SjmTransactionDetailItems{
        webService  String LineNumber {set;get;}
        webService  String Status {set;get;}
        webService  String ErrorNum {set;get;}
        webService  String ErrorDesc {set;get;}
        webService  String ErrorSeverity {set;get;}
    }
    
    /**
     * Objects used for response from this websevice
     * SJMResponse, SJMResponseDetailItem
     */
    global class Response{
        webservice List<SJMResponse> SJMResponse {set;get;}
        public Response(List<SJMResponse> SJMResponse){
            this.SJMResponse = SJMResponse;
        }
    }

    global class SJMResponse{
        webService  String status {set;get;}
        webService  String message {set;get;}
        webService  String transactionId {set;get;}
        
        public SJMResponse(String transactionId, String status, String message){
            this.transactionId = transactionId;
            this.status = status;
            this.message = message;
        }
    }
}