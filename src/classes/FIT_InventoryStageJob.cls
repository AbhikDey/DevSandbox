/**
 * @DateCreated: 
 * @Author: (Magnet360)
 * @Jira: SFIT-140
 * @Updated: 1/18/2015 | ADG-S
 */
global class FIT_InventoryStageJob implements Database.Batchable<SObject>, Schedulable
{
    String query;

    public FIT_InventoryStageJob() 
    {
    }

    global void execute(System.SchedulableContext sc)
    {
        Database.executeBatch(this, 200 );
    }

    // Start Method
    global  Database.QueryLocator start(Database.BatchableContext BC)
    {
        // Get data from Inventory Stage 
        query = 'SELECT Id, Name, Model_Number__c, Serial_Number__c, Batch_Lot_Number__c, Material__c, Inventory_ID__c, '+
        		'Stock_Partner_Number__c, Use_By_Date__c, Quantity__c, Status__c, Receipt_Date__c '+
        		'FROM Inventory_Stage__c '+
                'WHERE Processed__c = FALSE '+
                'ORDER BY Inventory_ID__c , LastModifiedDate ASC ';

        return Database.getQueryLocator(query);

    }
  
   	// Execute Logic
	global void execute( Database.BatchableContext BC, List<Inventory_Stage__c> invStageList )
	{  // Level-1 

        String errors;
        Integer recordsInserted, recordsUpdated, recordsDeleted, recordsErrors, totalStageRecords ;
		Map<String, Inventory__c> inventoryMap = new Map<String, Inventory__c>(); 
        Map<String, Account> accountMap = new Map<String,Account>();
        Map<String, User> usersMap = new Map<String,User>();
        Map<String, Product_FIM__c> productMap = new Map<String,Product_FIM__c>(); 
        Map<String, Inventory_Stage__c> invStageMapToProcess = new Map<String, Inventory_Stage__c>();
        Map<String, Integer> invStageYStatusMap = new Map<String, Integer>();
        Map<String, Integer> invStageNStatusMap = new Map<String, Integer>();
        Map<Id, Inventory_Stage__c> invStageMapOriginal = new Map<Id, Inventory_Stage__c>();
        List<Inventory__c> toDelete = new List<Inventory__c>(); 
        List<Inventory__c> upsertableInventories = new List<Inventory__c>();
        List<Inventory_Stage__c> upsertableStages = new List<Inventory_Stage__c>();
        List<Inventory_Stage__c> upsertableStageswitoutInventory = new List<Inventory_Stage__c>();
        List<Inventory_Stage__c> toDeletedStages = new List<Inventory_Stage__c>();
        Set<String> invIdStatus = new Set<String>();
        Set<String> stockPartners = new Set<String>() ;
        Set<String> businessPartners = new Set<String>() ;
        Set<String> materialNumbers = new Set<String>() ;
        Set<String> invIdsToProcess = new Set<String>();

        // Initialize variables 
        recordsInserted = recordsUpdated = recordsDeleted = recordsErrors = totalStageRecords = 0 ;  

        Set< String > l_inventory_id =  new Set< String >();

        // Itterate over stage rows and fill a map
        for( Inventory_Stage__c s : invStageList )
        {
            totalStageRecords++ ;
            invStageMapOriginal.put(s.Id, s); 
            l_inventory_id.add( s.Inventory_ID__c );
        }

        // Get Aggregate result and seprate record for processing
        List<AggregateResult> aggegateResults = [   SELECT Inventory_ID__c, 
                                                           Status__c, 
                                                           Count(Name)TotalRecords 
                                                    FROM Inventory_Stage__c
                                                    WHERE Processed__c = FALSE 
                                                    AND Inventory_ID__c IN : l_inventory_id
                                                    GROUP BY Inventory_ID__c, Status__c ] ;
        for( AggregateResult r : aggegateResults )
        {
            String invId = (String)r.get('Inventory_Id__c') ;
            String status = (String) r.get('Status__c');
            Integer records = (Integer)r.get('TotalRecords') == null ? 0 : (Integer)r.get('TotalRecords') ;
            if( status == 'Y' ) invStageYStatusMap.put(invId + '-' + status, records ) ;
            if( status == 'N' ) invStageNStatusMap.put(invId + '-' + status, records ) ;
        }

        // Remove item from Main List which not contain InventoryID 
        List< Inventory_Stage__c > l_inventory_to_update = new List< Inventory_Stage__c >();

        for( Inventory_Stage__c s : invStageList )
        {
            //If the Inventory ID grouping  includes a group of record with a Status 
            //value of "Y" and the same number of record with a Status value of "N", exclude 
            //these records from processing
            system.debug( '*** s.Inventory_ID__c : ' + s.Inventory_ID__c);
            system.debug( '*** Y : ' + invStageYStatusMap.get(s.Inventory_ID__c+'-Y'));
            system.debug( '*** N : ' + invStageNStatusMap.get(s.Inventory_ID__c+'-N'));
            if ( ( invStageYStatusMap.get(s.Inventory_ID__c+'-Y') == 1 && invStageNStatusMap.get(s.Inventory_ID__c+'-N') == 1 ) ||
                 ( invStageYStatusMap.get(s.Inventory_ID__c+'-Y') == 2 && invStageNStatusMap.get(s.Inventory_ID__c+'-N') == 2 ) ||
                 ( invStageYStatusMap.get(s.Inventory_ID__c+'-Y') == 4 && invStageNStatusMap.get(s.Inventory_ID__c+'-N') == 4 ) ||
                 ( invStageYStatusMap.get(s.Inventory_ID__c+'-Y') == 6 && invStageNStatusMap.get(s.Inventory_ID__c+'-N') == 6 ) )
            {
                s.Error__c = 'Duplicate Inventory ID records found';
                s.Processed__c = True ;
                l_inventory_to_update.add( s );
                recordsErrors++ ;
            }
            else
            {
                if( invStageMapToProcess.containsKey( s.Inventory_ID__c + '-' + s.Status__c ) )
                {
                    Inventory_Stage__c l_inv_sta = invStageMapToProcess.get( s.Inventory_ID__c + '-' + s.Status__c );
                    l_inv_sta.Error__c = 'Duplicate Inventory ID records found';
                    l_inv_sta.Processed__c = True ;
                    l_inventory_to_update.add( l_inv_sta );
                    recordsErrors++ ;
                }
                invStageMapToProcess.put(s.Inventory_ID__c + '-' + s.Status__c, s ) ;
            }  
        }
        if( l_inventory_to_update.size() > 0 ) update l_inventory_to_update ; 

        system.debug( '*** invStageMapToProcess : ' + invStageMapToProcess );

        // Itterate over Stage rows on which will process and fill a map
        for( Inventory_Stage__c s : invStageMapToProcess.values() )
        {
            if( String.isNotBlank( s.Stock_Partner_Number__c ) && 
                s.Stock_Partner_Number__c.startsWith('1000') ) 
            {
                stockPartners.add(s.Stock_Partner_Number__c) ;
            }
            if( String.isNotBlank( s.Stock_Partner_Number__c ) && 
                s.Stock_Partner_Number__c.startsWith('3000') )
            {
                businessPartners.add(s.Stock_Partner_Number__c) ;
            } 
            if( s.Material__c != null ) 
            {
                materialNumbers.add(s.Material__c) ;
            }
        }

        // Get Accounts and populate into Map 
        for( Account ac : [SELECT Id, Name, SJM_ID__c FROM Account where SJM_ID__c IN :stockPartners ] )
        {
            accountMap.put(ac.SJM_ID__c, ac );
        }
        
        // Get User and put into Map 
        for( User u : [ SELECT Id, Name, Business_Partner__c FROM User WHERE Business_Partner__c IN :businessPartners ] )
        {
            usersMap.put(u.Business_Partner__c , u );
        }

        // Get Products 
        for( Product_FIM__c p : [ SELECT Id, Name, Product_Key__c FROM Product_FIM__c WHERE Product_Key__c IN :materialNumbers ])
        {
            productMap.put(p.Product_Key__c, p ) ;
        }

		// Get all records from Inventory object and put into map
		for( Inventory__c inv : [SELECT Id, 
                                        Name, 
                                        Model_Number__c, 
                                        Serial_Number__c, 
                                        Batch_Lot_Number__c, 
                                        Inventory_ID__c, 
                                        Account__c, 
                                        User__c,
										Stock_Partner_Number__c, 
                                        Use_By_Date__c, 
                                        Quantity__c, 
                                        Status__c, 
                                        Receipt_Date__c, 
                                        Product_Number__c,
                                        Part_Number__c
								 FROM Inventory__c 
                                 WHERE Inventory_ID__c != null 
                                 AND Inventory_ID__c IN : l_inventory_id ] )
		{
			inventoryMap.put(inv.Inventory_ID__c, inv);
            //System.debug('UAC: selectedInventory ' + inv);
		}


        // Itterate over stage rows and change map values as per stage records
        for( Inventory_Stage__c s : invStageMapToProcess.values() )
        {   // Level-2 

            // When Status on InventoryStage Y
            if( s.Status__c == 'Y' ) 
            {  
                Boolean l_insert_inventory = false;

                s.Processed__c = true ;
                // Create new Inventory record for Insert/Update
                Inventory__c inv = new Inventory__c( Inventory_ID__c = s.Inventory_ID__c, 
                                                     Model_Number__c = s.Model_Number__c, 
                                                     Quantity__c = s.Quantity__c, 
                                                     Serial_Number__c = s.Serial_Number__c, 
                                                     Batch_Lot_Number__c = s.Batch_Lot_Number__c, 
                                                     Stock_Partner_Number__c = s.Stock_Partner_Number__c, 
                                                     Use_By_Date__c = s.Use_By_Date__c, 
                                                     Status__c = s.Status__c,  
                                                     Receipt_Date__c = s.Receipt_Date__c,
                                                     Part_Number__c = s.Material__c) ;
                
                // The Stock_Partner_Number__c could start with 1000 or 3000
                // If found, set l_insert_inventory = true
                if( String.isNotBlank( s.Stock_Partner_Number__c ) && 
                    s.Stock_Partner_Number__c.startsWith('1000') && 
                    accountMap.containsKey(s.Stock_Partner_Number__c) )    
                {
                    inv.Account__c = accountMap.get(s.Stock_Partner_Number__c).Id ;
                    s.Error__c = '' ;
                    l_insert_inventory = true;
                }
                else
                {
                    s.Error__c = 'Matching Consignment Location could not be found' ;
                }

                if( String.isNotBlank( s.Stock_Partner_Number__c ) && 
                    s.Stock_Partner_Number__c.startsWith('3000') && 
                    usersMap.containsKey(s.Stock_Partner_Number__c)  )   
                {
                        inv.User__c = usersMap.get(s.Stock_Partner_Number__c).Id ;
                        s.Error__c = '' ;
                        l_insert_inventory = true;
                }
                //If l_insert_inventory = true, then the Stock_Partner_Number__c starting with 1000 
                //so no need to set an error
                else if( !l_insert_inventory ) 
                {
                    s.Error__c = 'Matching Consignment Location could not be found' ;
                }
                
                // When Product found as per Stage Material then get ProductId otherwise fill Error__c field on Stage
                if( productMap.containsKey(s.Material__c) )    
                {
                    //Check if the user or account were set before
                    if( l_insert_inventory )
                    {
                        inv.Product_Number__c = productMap.get(s.Material__c).Id ;
                        s.Error__c = '' ;
                    }
                }
                else
                {
                    if( s.Error__c != '' )
                    {
                        s.Error__c = s.Error__c +' | ';
                    }
                    s.Error__c = s.Error__c + 'Matching Product could not be found' ;
                    l_insert_inventory = false;
                }

                if( l_insert_inventory )
                {
                    upsertableInventories.add(inv);
                    upsertableStages.add(s);
                }
                else
                {
                    upsertableStageswitoutInventory.add(s); 
                    recordsErrors++ ;                   
                }

            }
            // When Status on InventoryStage N then try to find related Inventory record, if found then delete otherwise fill Error__c field on stage
            else if( s.Status__c == 'N' && inventoryMap.containsKey(s.Inventory_ID__c) ) 
            {
                toDelete.add(new Inventory__c( Id = inventoryMap.get(s.Inventory_ID__c).Id )) ;
                inventoryMap.remove(s.Inventory_ID__c);
                recordsDeleted++ ;
                s.Processed__c = true ;
                toDeletedStages.add(s);
            }
            else
            {
                s.Error__c  = 'Matching Inventory ID could not be found' ;
                recordsErrors++ ;
                s.Processed__c = true ;
                toDeletedStages.add(s);
            }

        }   // Level-2 

        // Upsert Inventory Records & Get result of upserted Inventory rows
        List<Database.UpsertResult> results = Database.upsert( upsertableInventories , Inventory__c.Inventory_ID__c, false );
        Integer counter = 0;
        
        // Itterate over results
        for(Database.UpsertResult res : results)
        {
            // When error occurred during upsert
            if(!res.isSuccess() )
            {
                System.debug(System.LoggingLevel.ERROR, 'UAC: upsertable Failed: ' + upsertableInventories[counter] );
                errors = 'Inserting Inventory Records ';
                for(Database.Error er : res.geterrors())
                {
                    errors += er.getMessage();
                }
                errors += '\n';
                System.debug('UAC: error ' + errors) ;
                recordsErrors++ ;
                upsertableStages[counter].Error__c = errors ;
            }
            else
            {   
                // Check whether records is inserted or updated 
                if( res.isCreated() )
                {
                    recordsInserted++ ;
                }
                else
                {
                    recordsUpdated++ ;
                }
                //System.debug(System.LoggingLevel.ERROR, 'UAC: record prcoessed '+ res.getId() );
            }
            counter++;
        }

        for( Inventory__c inv : toDelete ) System.debug('UAC: delete' + inv ) ;

        // Delete inventory record which deletable
        if( toDelete.size() > 0 ) delete toDelete ; 

        List<Inventory_Stage__c> updatable = new List<Inventory_Stage__c>();
        updatable = upsertableStages ;
        updatable.addAll(upsertableStageswitoutInventory) ;
        updatable.addAll(toDeletedStages) ;

        if( updatable.size() > 0 ) update updatable ;

        // Create a Inventory Log record
        Inventory_Log__c log = new Inventory_Log__c(    Date_Time__c = Datetime.now(), 
                                                        Deleted__c = recordsDeleted, 
                                                        In_Error__c = recordsErrors, 
                                                        Inserted__c = recordsInserted, 
                                                        Processed__c = totalStageRecords, 
                                                        Updated__c = recordsUpdated  );
        insert log ;
        
	}  // Level-1

 
    global void finish(Database.BatchableContext BC )
    {
        // Logic to be Executed at finish
        System.debug('Batch job finished...') ;
    }

}