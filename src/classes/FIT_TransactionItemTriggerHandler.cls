public with sharing class FIT_TransactionItemTriggerHandler {
    
    private Static String PENDING = 'Pending';
    private Static String SUCCESS = 'Success';
    private Static String SEND = 'Send';
    private Static String ERRORS = 'Errors';
    private Static String RECEIVED = 'Received';
    private Static String CONSIGNMENT_REQUEST = 'Consignment_Request';
    private Static String INVENTORY_TRANSFER = 'Inventory_Transfer';
    private Static String PO_PENDING = 'PO Pending';
    private Static String INVOICED = 'Invoiced';
    private Static String SALES_ORDER = 'Sales_Order';
    private Static String ERROR_MSG  = 'This Transaction Item cannot be deleted based on its Status.';


    private Static List< String> sales_order_rt_name = new List<String >{ 'Sales_Order',
                                                                          'Sales_Order_Invoiced',
                                                                          'Sales_Order_PO_Pending'}; 

    private Static List< String> invnt_transfer_rt_name = new List<String >{ 'Inventory_Transfer',
                                                                             'Inventory_Transfer_Read_Only'}; 

    private Static List< String> consignment_request_rt_name = new List<String >{ 'Consignment_Request',
                                                                                  'Consignment_Request_Read_Only'};                                                                              

    private static Set<ID> invnt_transfer_rt{
        get{
            if (invnt_transfer_rt==null)
            {
                Map< ID, RecordType > l_recordTypes = new Map< ID, RecordType >(
                                                        [ Select Id 
                                                          From RecordType 
                                                          Where SobjectType=: 'Transactions__c' 
                                                          AND DeveloperName IN: invnt_transfer_rt_name]);
                invnt_transfer_rt = l_recordTypes.keySet();
            }
            return invnt_transfer_rt;
        } set;
    }

    private static Set<ID> sales_order_rt{
        get{
            if (sales_order_rt==null)
            {
                Map< ID, RecordType > l_recordTypes = new Map< ID, RecordType >(
                                                        [ Select Id 
                                                          From RecordType 
                                                          Where SobjectType=: 'Transactions__c' 
                                                          AND DeveloperName IN: sales_order_rt_name]);
                sales_order_rt = l_recordTypes.keySet();
            }
            return sales_order_rt;
        } set;
    }

    private static Set<ID> consignment_request_rt{
        get{
            if (consignment_request_rt==null)
            {
                Map< ID, RecordType > l_recordTypes = new Map< ID, RecordType >(
                                                        [ Select Id 
                                                          From RecordType 
                                                          Where SobjectType=: 'Transactions__c' 
                                                          AND DeveloperName IN: consignment_request_rt_name]);
                consignment_request_rt = l_recordTypes.keySet();
            }
            return consignment_request_rt;
        } set;
    }    


/******************************************************************************
 * checkDuplicatedInventory
 * @author: Andres Di Geronimo-Stenberg (Magnet 360)
 * @date: 1/22/2016
 * @jira: 
 * @description: For each TransactionItem  associated with a transaction,
                 the Inventory must be different, and the Stock_Partner_Number__c
                 must be the same.
 * @param: List< Transaction_Items__c > a_transaction_items
 * @return: None.
 ******************************************************************************/
    public static void checkInventory( List< Transaction_Items__c > a_items )
    {
        System.debug( '### START METHOD : checkInventory()');
        System.debug( '### PARAM: a_items : ' + a_items );

        Set< Id > l_transaction_id_set = new Set< Id >();
        Set< Id > l_inventory_id_set = new Set< Id >();

        for( Transaction_Items__c ti : a_items )
        {
            l_transaction_id_set.add( ti.Transaction_ID__c );
            l_inventory_id_set.add( ti.Inventory__c );
        }

        Set< ID > l_record_type_id = new Set<ID>();
        l_record_type_id.addAll( invnt_transfer_rt );
        l_record_type_id.addAll( sales_order_rt );

        Map< ID , Transactions__c > l_transactions = getTransactionWithItems( l_transaction_id_set ,l_record_type_id);
        system.debug( '*** l_transactions : ' + l_transactions.values() );

        //The inventories related with the Transaction Items passed as parameters
        Map< ID ,Inventory__c > l_inventories = new Map< ID ,Inventory__c > ([ Select Id,
                                                                                     Stock_Partner_Number__c
                                                                              From Inventory__c
                                                                              Where ID IN: l_inventory_id_set ]);

        for( Transaction_Items__c ti : a_items )
        {
            if( l_transactions.containsKey( ti.Transaction_ID__c) )
            {
                for( Transaction_Items__c ti_child : l_transactions.get( ti.Transaction_ID__c).Transaction_Items__r )
                {
                    // Inventory should be unique in each TransactionItem
                    if( ti_child.Inventory__c == ti.Inventory__c )
                    {
                        ti.addError( 'You cannot select a duplicate inventory record for this transaction' );
                        break;
                    }

                    //All the transactionItem should have the same Inventory.Stock_Partner_Number__c
                    //Only for Inventory_Transfer Transactions 
                    if( invnt_transfer_rt.contains( l_transactions.get( ti.Transaction_ID__c).RecordTypeID ) &&
                        ti_child.Inventory__r != null && 
                        l_inventories.containsKey(ti.Inventory__c) &&
                        ti_child.Inventory__r.Stock_Partner_Number__c  != l_inventories.get(ti.Inventory__c).Stock_Partner_Number__c )
                    {
                        ti.addError( 'You cannot add inventory records to the same transaction from multiple locations.' );
                        break;                        
                    }
                }
            }
        }
        System.debug( '### END METHOD : checkInventory()');
    }

/******************************************************************************
 * getTransactionWithItems
 * @author: Andres Di Geronimo-Stenberg (Magnet 360)
 * @date: 1/22/2016
 * @jira: 
 * @description: Obtains Transactions and the transactionITems base on the 
                 Set of TransactionIDs passed as parameter, for the 
                 sales_order_rt and invnt_transfer_rt record types
 * @param: Set< Id > a_transaction_id_set
 * @return: Map< ID , Transactions__c >
 ******************************************************************************/
    private static Map< ID , Transactions__c > getTransactionWithItems( Set< Id > a_transaction_id_set , Set< ID > a_record_type_id)
    {
        System.debug( '### START METHOD : getTransactionWithItems()');
        System.debug( '### PARAM a_transaction_id_set : ' + a_transaction_id_set );

        Map< ID , Transactions__c > l_transactions = new Map< ID , Transactions__c >(
                                                      [ Select ID, 
                                                               RecordTypeID,
                                                               Items__c,
                                                               ( Select ID,
                                                                        Inventory__c,
                                                                        Inventory__r.Stock_Partner_Number__c,
                                                                        Model__c,
                                                                        Serial__c,
                                                                        Status__c,
                                                                        Model_Number__r.Name
                                                                 From Transaction_Items__r 
                                                                 ORDER BY Serial__c,Model__c DESC )
                                                        From Transactions__c
                                                        Where Id IN :a_transaction_id_set 
                                                        AND RecordTypeID IN: a_record_type_id ] );

        System.debug( '### RETURN l_transactions : ' + l_transactions);
        System.debug( '### END METHOD : getTransactionWithItems()');
        return l_transactions;        
    }

    public static void setPrice( List<Transaction_Items__c> items ){

    	Map<String, WrapperClass> modelToPriceMap = new Map<String, WrapperClass>();
    	Set<Id> inventoryIds = new Set<Id>();
    	Map<Id,String> inventoryToModelMap = new map<Id,String>();
    	Map<String, Id> productNameToIdMap = new Map<String,Id>();
    	Map<Id, String> transactionAccountMap = new Map<Id, String>();
    	Set<Id> transactionIds = new Set<Id>(); 

    	// Get inventory Ids
    	for( Transaction_Items__c it : items )
    	{
    		if( it.Inventory__c != null ) inventoryIds.add(it.Inventory__c);
    		transactionIds.add(it.Transaction_ID__c);
    	}

    	if( inventoryIds.size() == 0 || inventoryIds == null ) return ; 

    	// Get Account ID of Transction
    	for( Transactions__c tr : [SELECT Id, Account__r.SJM_ID__c FROM Transactions__c WHERE ID IN :transactionIds 
                                   AND (recordType.DeveloperName != :INVENTORY_TRANSFER AND recordType.DeveloperName != :CONSIGNMENT_REQUEST) ])
    	{
    		transactionAccountMap.put(tr.Id, tr.Account__r.SJM_ID__c );
    	}
    	System.debug('UAC: transactionAccountMap ' + transactionAccountMap ) ;

    	// Now get Model numbers (string) from Inventory
    	for( Inventory__c inv : [SELECT Id, Model_Number__c FROM Inventory__c WHERE ID IN :inventoryIds ] )
    	{
    		inventoryToModelMap.put(inv.Id, inv.Model_Number__c);	
    	}
    	System.debug('UAC: inventoryToModelMap ' + inventoryToModelMap ) ;

    	// Now get ModelNumber Ids as per string model numbers 
    	for( Product_FIM__c prod : [ SELECT Id, Name FROM Product_FIM__c WHERE NAME IN :inventoryToModelMap.values() ])
    	{
    		//modelToPriceMap.put(prod.Id, new WrapperClass('List', 0.00)) ;
    		productNameToIdMap.put(prod.Name, prod.Id);
    	}
    	System.debug('UAC: productNameToIdMap ' + productNameToIdMap ) ;

    	if( productNameToIdMap.size() ==0 || productNameToIdMap == null ) return ;


    	// Get Customer price information as per models
		for(Customer_Pricing__c cp : [  SELECT Id, List_Price__c, Contract_Price__c, Group_Price__c, Model_Number__c, Account__r.SJM_ID__c
										FROM Customer_Pricing__c 
										WHERE Model_Number__c IN :productNameToIdMap.values() AND Name IN :transactionAccountMap.values() ] ) 
		{
			System.debug('UAC: cp ' + cp );
		    WrapperClass mt = modelToPriceMap.get(cp.Model_Number__c + '' + cp.Account__r.SJM_ID__c );
		    if( mt== null ) 
		    {
		    	mt = new WrapperClass('List', 0.00) ;
		    	modelToPriceMap.put(cp.Model_Number__c + '' + cp.Account__r.SJM_ID__c , mt ) ; 
		    }
		    
		    if( ( mt.price == 0 && mt.price < cp.List_Price__c ) || (cp.List_Price__c > 0 && mt.price > cp.List_Price__c) ) {
		        mt.price = cp.List_Price__c;
		        mt.priceType = 'List';
		        System.debug('UAC: mt ' + mt ) ;
		    }
		    
		    if( (mt.price == 0 && mt.price < cp.Contract_Price__c) || (cp.Contract_Price__c > 0 && mt.price > cp.Contract_Price__c) ) {
		        mt.price = cp.Contract_Price__c;
		        mt.priceType = 'Contract';
		        System.debug('UAC: mt ' + mt ) ;
		    }

		    if( (mt.price == 0 && mt.price < cp.Group_Price__c) || (cp.Group_Price__c > 0  &&  mt.price > cp.Group_Price__c) ) {
		        mt.price = cp.Group_Price__c;
		        mt.priceType = 'Group';
		        System.debug('UAC: mt ' + mt ) ;
		    }
		}
		System.debug('UAC: modelToPriceMap ' + modelToPriceMap );

		// Populate lowest price and type
		for( Transaction_Items__c it : items )
		{
			if( it.Inventory__c != null && !transactionAccountMap.isEmpty())
			{	
				WrapperClass mt = modelToPriceMap.get(productNameToIdMap.get(inventoryToModelMap.get(it.Inventory__c)) + '' + transactionAccountMap.get(it.Transaction_ID__c)) ;
				System.debug('UAC: mt ' + mt );
				if( mt != null && mt.price > 0  )
				{
					it.Price__c = mt.price ; 
					it.Price_Type__c =  mt.priceType ;
				}
			}
		}
    }


/******************************************************************************
 * beforeDelete
 * @author: Andres Di Geronimo-Stenberg (Magnet 360)
 * @date: 1/13/2016
 * @jira: 
 * @description: Checks the status of the Transaction and Transaction Item
                 before remove a Transaction item.
 * @param: List< Transaction_Items__c > a_transaction_items
 * @return: None.
 ******************************************************************************/
    public static void beforeDelete( List< Transaction_Items__c > a_transaction_items )
    {
        System.debug(' START METHOD : beforeDelete() ' );

        Set< ID > l_transaction_id = new Set< ID >();

        for( Transaction_Items__c ti : a_transaction_items )
        {
            l_transaction_id.add( ti.Transaction_ID__c );
        }

        Map< ID, Transactions__c > l_transactions = new Map< ID, Transactions__c > ([ Select Id,
                                                                                             recordType.DeveloperName,
                                                                                             Status__c
                                                                                       From Transactions__c
                                                                                       Where ID IN: l_transaction_id ]);

        for( Transaction_Items__c ti : a_transaction_items )
        {
            Transactions__c l_tran = l_transactions.get( ti.Transaction_ID__c );
            system.debug( ' ti.Status__c : ' + ti.Status__c);
            system.debug( ' l_tran.Status__c : ' + l_tran.Status__c);
            system.debug( ' l_tran.recordType.DeveloperName : ' +  l_tran.recordType.DeveloperName);

            if( ( ti.Status__c == PENDING || ti.Status__c == SUCCESS ) &&
                ( l_tran.Status__c == SEND || l_tran.Status__c == RECEIVED || l_tran.Status__c == ERRORS) && 
                ( l_tran.recordType.DeveloperName.contains(CONSIGNMENT_REQUEST) || 
                  l_tran.recordType.DeveloperName.contains(INVENTORY_TRANSFER) ) )
            {
                system.debug('*** ERROR 1');
                ti.addError(ERROR_MSG);
            }
            else if( ( l_tran.Status__c == PO_PENDING || l_tran.Status__c == INVOICED) &&
                      l_tran.recordType.DeveloperName.contains(SALES_ORDER)  )
            {
                system.debug('*** ERROR 2 ');
                ti.addError(ERROR_MSG);
            }
        }

        System.debug(' END METHOD : beforeDelete() ' );
    }

/******************************************************************************
 * setItemsInTransaction
 * @author: Andres Di Geronimo-Stenberg (Magnet 360)
 * @date: 1/27/2016
 * @jira: SFIT-317
 * @description: The "Items" field on the Transaction record is populated upon 
                 a Transaction Item trigger. I will contain a concatenation of
                 Model | Serial | Status. Only for RT invnt_transfer and
                 consignment_request
 * @param: List< Transaction_Items__c > a_transaction_items
 * @return: None.
 ******************************************************************************/
    public static void setItemsInTransaction( List< Transaction_Items__c > a_transaction_items )
    {
        System.debug(' START METHOD : setItemsInTransaction() ' );
        System.debug(' PARAM : a_transaction_items ' + a_transaction_items);

        Set< ID > l_transaction_id_set = new Set< ID >();

        for( Transaction_Items__c ti : a_transaction_items )
        {
            l_transaction_id_set.add( ti.Transaction_ID__c );
        }

        Set< ID > l_record_type_id = new Set<ID>();        
        l_record_type_id.addAll( invnt_transfer_rt );
        l_record_type_id.addAll( consignment_request_rt );

        Map< ID , Transactions__c > l_transactions = getTransactionWithItems( l_transaction_id_set , l_record_type_id);

        for( Transactions__c t : l_transactions.values() )
        {
            t.Items__c = '';

            if( t.Transaction_Items__r != null && t.Transaction_Items__r.size() > 0 )
            {
                for( Transaction_Items__c ti : t.Transaction_Items__r )
                {
                    if( invnt_transfer_rt.contains( t.RecordTypeID ) )
                    {
                        t.Items__c = t.Items__c + 
                                     ti.Model__c + ' | ' + 
                                     ti.Serial__c + ' | ' + 
                                     ti.Status__c + '\n' ;
                    }
                    else
                    {
                        t.Items__c = t.Items__c + 
                                     ti.Model_Number__r.Name + ' | ' + 
                                     ti.Status__c + '\n' ;
                    }
                }
            }
        }

        if( l_transactions.size() > 0 )
        {
            update l_transactions.values();
        }
        System.debug(' END METHOD : setItemsInTransaction() ' );
    }

    // Wrapper Class 
	public class WrapperClass
	{
		public String priceType ;
		public Decimal price ;
		public WrapperClass( String type, Decimal price )
		{
			this.priceType = type ; 
			this.price = price ; 
		}
	}

    
}