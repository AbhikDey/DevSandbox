/**
 * @DateCreated: 
 * @Author: Andres Di Geronimo-Stenberg(Magnet360)
 * @Description: If a record within the Inventory table does not exist within 
 *               the Inventory Full table, the record should be written to the 
 *               Inventory Stage table with a Status value of "N".
 */
global class FIT_InventoryBaseJob implements Database.Batchable<sObject> {
	
	String query;
	
	global FIT_InventoryBaseJob() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		query = 'SELECT Id, Name, Model_Number__c, Serial_Number__c, '+
				'Batch_Lot_Number__c, Inventory_ID__c, '+
                'Stock_Partner_Number__c, Use_By_Date__c, Quantity__c, '+
                'Status__c, Receipt_Date__c, Part_Number__c '+
                'FROM Inventory__c WHERE Inventory_ID__c != null ';

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Inventory__c> l_inventory ) 
   	{
   		Set< String > l_inventory_id = new Set< String >();

		for( Inventory__c inv : l_inventory )
		{
			l_inventory_id.add( inv.Inventory_ID__c );
		}

		Set< String > l_inv_full_set = new Set< String >();

		//Get the Inventory Full records that match the Inventory_ID__c of the
		//Inventory records
        for( Inventory_Full__c inv_full : [ SELECT Inventory_ID__c, 
														Status__c
                                                 FROM Inventory_Full__c
                                                 Where Inventory_ID__c IN: l_inventory_id ] )
        {
        	l_inv_full_set.add( inv_full.Inventory_ID__c);
        }

        Map<String, Inventory_Stage__c> inventoryStageMap = new Map<String, Inventory_Stage__c>(); 

		for( Inventory__c s : l_inventory )
		{
	        //If a record within the Inventory table does not exist within 
	        //the Inventory Full table, the record should be written to the 
	        //Inventory Stage table with a Status value of "N"
			if( !l_inv_full_set.contains( s.Inventory_ID__c) )
			{
	            Inventory_Stage__c inv = new Inventory_Stage__c(Inventory_ID__c = s.Inventory_ID__c, Model_Number__c = s.Model_Number__c, Full__c = true,Processed__c = false,
	                                                            Quantity__c = s.Quantity__c, Serial_Number__c = s.Serial_Number__c, Status__c = 'N',
	                                                            Batch_Lot_Number__c = s.Batch_Lot_Number__c, Stock_Partner_Number__c = s.Stock_Partner_Number__c, 
	                                                            Use_By_Date__c = s.Use_By_Date__c, Receipt_Date__c = s.Receipt_Date__c, Material__c = s.Part_Number__c) ;

	            inventoryStageMap.put(s.Inventory_ID__c + '-' + s.Status__c , inv);
			}
		}

		if( inventoryStageMap.size() > 0 )
		{
			FIT_InventoryFullJob.upsertInvetoryStage( inventoryStageMap.values() );
		}

	}
	
	global void finish(Database.BatchableContext BC) 
	{
        //if( !Test.isRunningTest() )
        //{
            // When finished then run batch job for Stage processing
       /*     FIT_InventoryStageJob batchJob = new FIT_InventoryStageJob();
            batchJob.execute(null);*/

        // When finished then run batch job to check inv base
        FIT_InventoryStageJob batchJob = new FIT_InventoryStageJob();
        Database.executeBatch(batchJob, 200 );
            
        //}		
	}
	
}