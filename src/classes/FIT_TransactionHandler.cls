/**
 * Handle class for FIT_TransactionTrigger.trigger
 * @DateCreated: 1/18/2015
 * @Author: Andres Di Geronimo-Stenberg (Magnet360)
 */
public with sharing class FIT_TransactionHandler 
{

    private static Set<ID> sales_order_rt
    {
        get{
            if ( sales_order_rt == null )
            {
                Map< ID, RecordType > sales_order = new Map< ID, RecordType >(
                                                    [ Select Id 
                                                      From RecordType 
                                                      Where ( DeveloperName=: 'Sales_Order' 
                                                              OR DeveloperName=: 'Sales_Order_PO_Pending' )
                                                      AND SobjectType = 'Transactions__c' ]);

                sales_order_rt = sales_order.keySet();
            }
            system.debug('### sales_order_rt : ' + sales_order_rt );
            return sales_order_rt;
        } set;
    } 

    
    private static Set<ID> consignment_rt
    {
        get{
            if ( consignment_rt == null )
            {
                Map< ID, RecordType > consignment_rts = new Map< ID, RecordType >(
                                                    [ Select Id 
                                                      From RecordType 
                                                      Where ( DeveloperName=: 'Consignment_Request')
                                                      AND SobjectType = 'Transactions__c' ]);

                consignment_rt = consignment_rts.keySet();
            }
            system.debug('### consignment_rt : ' + consignment_rt );
            return consignment_rt;
        } set;
    } 

    private static Set<ID> inventory_rt
    {
        get{
            if ( inventory_rt == null )
            {
                Map< ID, RecordType > inventory_rts = new Map< ID, RecordType >(
                                                    [ Select Id 
                                                      From RecordType 
                                                      Where ( DeveloperName=: 'Inventory_Transfer')
                                                      AND SobjectType = 'Transactions__c' ]);

                inventory_rt = inventory_rts.keySet();
            }
            system.debug('### inventory_rt : ' + inventory_rt );
            return inventory_rt;
        } set;
    }
/******************************************************************************
 * onBeforeUpdate
 * @author: Andres Di Geronimo-Stenberg(Magnet 360)
 * @date: 1/18/2016
 * @jira: 
 * @description: Proccess the on Before Update actions
 * @param: List< Transactions__c > a_transactions
 * @param: Map< ID , Transactions__c > a_old_trans
 * @return: None.
 ******************************************************************************/
    public static void onBeforeUpdate( List< Transactions__c > a_transactions , 
                                       Map< ID , Transactions__c > a_old_trans ) 
    {
        system.debug('### START METHOD : onBeforeUpdate');

        List< Transactions__c > l_sales_order_transactions =  new List< Transactions__c >();
        List< Transactions__c > consignment_transactions =  new List< Transactions__c >();
        List< Transactions__c > inventory_transactions =  new List< Transactions__c >();
        for( Transactions__c t : a_transactions )
        {
            if( sales_order_rt.contains( t.RecordTypeID ) &&
                t.Submit__c != a_old_trans.get( t.id ).Submit__c &&
                t.Submit__c )
            {
                List<Transaction_Items__c> listOfitems = [select id from Transaction_Items__c where Transaction_ID__c = :t.id];
                if(!listOfitems.isEmpty()){
                  l_sales_order_transactions.add( t );
                  t.Submit__c = false;
                }else{
                  t.addError('You cannot submit a Transaction if it does not have any Transaction Items');
                }
                
            }else if(consignment_rt.contains(t.RecordTypeId) && 
                     t.Submit__c != a_old_trans.get( t.id ).Submit__c &&
                     t.Submit__c){
                     
                     List<Transaction_Items__c> listOfitems = [select id from Transaction_Items__c where Transaction_ID__c = :t.id];
                     if(!listOfitems.isEmpty()){
                        for(Transaction_Items__c item : listOfitems){
                            item.status__c = 'In Progress';
                        }
                        consignment_transactions.add(t);
                        t.Submit__c = false;
                        t.Status__c ='Send';        
                     }else{
                        //can not submit without items
                        t.addError('You cannot submit a Transaction if it does not have any Transaction Items');
                     }
                    
                         
            }else if(inventory_rt.contains(t.RecordTypeId) && t.Submit__c != a_old_trans.get( t.id ).Submit__c &&
                     t.Submit__c){
                         
                     List<Transaction_Items__c> listOfitems = [select id from Transaction_Items__c where Transaction_ID__c = :t.id];
                     if(!listOfitems.isEmpty()){
                      for(Transaction_Items__c item : listOfitems){
                        item.status__c = 'In Progress';
                      }
                      inventory_transactions.add(t);
                      t.Submit__c = false;
                      t.Status__c ='Send';        
                    }else{
                        //can not submit without items
                        t.addError('You cannot submit a Transaction if it does not have any Transaction Items');
                     }    
            }
        }

        if( l_sales_order_transactions.size() > 0 )
        {
            submitSalesOrder( l_sales_order_transactions );
        }
        
        if( consignment_transactions.size() > 0 )
        {
            submitConsignmentRequest( consignment_transactions );
        }
        
        if( inventory_transactions.size() > 0 )
        {
           submitInventoryTransfers( inventory_transactions);
        }

        system.debug('### END METHOD : onBeforeUpdate');
    }

    
    private static void submitConsignmentRequest( List< Transactions__c > consignment_transactions )
    {
        for(Transactions__c t : consignment_transactions){
          FIT_TransactionsController.sendConsignmentRequest(t.id);
        }
    }
    
     private static void submitInventoryTransfers( List< Transactions__c > inventory_transactions )
    {
        for(Transactions__c t : inventory_transactions){
          FIT_TransactionsController.sendTransferRequest(t.id);
        }
    }

/******************************************************************************
 * submitSalesOrder
 * @author: Andres Di Geronimo-Stenberg(Magnet 360)
 * @date: 1/18/2016
 * @jira: 
 * @description: Handles the transactions with record type Sales_Order, when 
                 the check box Submit_Sales_Order__c is passed as true.
                 Updates the status of the transaction.
 * @param: List< Transactions__c > a_transactions
 * @return: None.
 ******************************************************************************/
    private static void submitSalesOrder( List< Transactions__c > a_transactions )
    {
        system.debug('### START METHOD submitSalesOrder() ');

        Map< Id, Integer > l_trans_id_trans_item = new Map< Id, Integer >();
        Map< Id, Set< ID > > l_trans_id_inventory = new Map< Id, Set< ID > >();
        Set< ID > l_inventory_id = new Set< ID >();

        getItemsAndInventory( l_trans_id_trans_item , 
                              l_trans_id_inventory , 
                              l_inventory_id , 
                              a_transactions);

        Map< ID , Inventory__c > l_inventory = new Map< ID, Inventory__c > (
                                                [ SELECT Id, Quantity__c 
                                                  FROM Inventory__c 
                                                  WHERE ID IN :l_inventory_id ] );

        List< Inventory__c > l_inv_to_update = new  List< Inventory__c >();

        for( Transactions__c trans : a_transactions )
        {
            // When Transaction status equals to InProgress then get all related
            // TransactionItems and update then with decrement of 1 Quantity
            if( trans.Status__c == 'In Progress' ){

                // Check the number of items the transaction has
                if( l_trans_id_trans_item.get( trans.id ) > 0 )
                {
                    //Obtains all the invetories related with the "transactions Item"
                    //related with the "transaction"
                    Set< ID > l_inventory_ids = l_trans_id_inventory.get( trans.id );

                    if( l_inventory_ids.size() > 0 )
                    {
                        for( ID inv_id : l_inventory_ids )
                        {
                            Inventory__c l_inv = l_inventory.get( inv_id );

                            if( l_inv.Quantity__c !=  null ) 
                            {
                                l_inv.Quantity__c = l_inv.Quantity__c - 1;
                                l_inv_to_update.add( l_inv );
                            }
                        }
                    }

                    trans.Status__c = 'PO Pending' ;
                }
            }
            else if ( trans.Status__c == 'PO Pending' )
            {
                trans.Status__c = 'Invoiced' ;
            }
        }

        if( l_inv_to_update.size() > 0 )
        {
            update l_inv_to_update;
        }

        system.debug('### END METHOD submitSalesOrder() ');
    }

/******************************************************************************
 * getItemsAndInventory
 * @author: Andres Di Geronimo-Stenberg(Magnet 360)
 * @date: 1/18/2016
 * @jira: 
 * @description: Obtains the Transaction Items and Inventorie records related 
                 with the a_transactions list passed as parameter
 * @param: Map< Id, Integer > a_trans_id_trans_item
 * @param: Map< Id, Set< ID > > a_trans_id_inventory
 * @param: Set< ID > a_inventory_id
 * @param: List< Transactions__c > a_transactions
 * @return: None.
 ******************************************************************************/
    private static void getItemsAndInventory( Map< Id, Integer > a_trans_id_trans_item,
                                              Map< Id, Set< ID > > a_trans_id_inventory,
                                              Set< ID > a_inventory_id ,
                                              List< Transactions__c > a_transactions )
    {
        system.debug('### START METHOD getItemsAndInventory() ');

        List< Transaction_Items__c > l_trans_items = [ SELECT Id, 
                                                              Inventory__c,
                                                              Transaction_ID__c 
                                                       FROM Transaction_Items__c  
                                                       WHERE Transaction_ID__c = :a_transactions ] ;

        for( Transaction_Items__c ti : l_trans_items )
        {
            Integer l_num_trans = 0;

            if( a_trans_id_trans_item.containsKey( ti.Transaction_ID__c ) )
            {
                l_num_trans = a_trans_id_trans_item.get( ti.Transaction_ID__c );
            }

            l_num_trans++;

            a_trans_id_trans_item.put( ti.Transaction_ID__c , l_num_trans );               


            if( ti.Inventory__c != null )
            {
                a_inventory_id.add( ti.Inventory__c );

                Set< ID > l_aux_set = new  Set< ID >();

                if( a_trans_id_inventory.containsKey( ti.Transaction_ID__c ) )
                {
                    l_aux_set = a_trans_id_inventory.get( ti.Transaction_ID__c );
                }

                l_aux_set.add( ti.Inventory__c );

                a_trans_id_inventory.put( ti.Transaction_ID__c , l_aux_set );               
            }

        }
        system.debug('### END METHOD getItemsAndInventory() ');
    }


}