/**
 * @DateCreated: 
 * @Author: (Magnet360)
 * @Jira: SFIT-142
 * @Updated: 2/2/2015 | ADG-S
 */
global class FIT_InventoryFullJob implements Database.Batchable<SObject>
{
    String query ; 
    public FIT_InventoryFullJob() 
    {
    }

    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        query = 'SELECT Id, Name, Model_Number__c, Serial_Number__c, Batch_Lot_Number__c, Material__c, Inventory_ID__c, '+
                'Stock_Partner_Number__c, Use_By_Date__c, Quantity__c, Status__c, Receipt_Date__c '+
                'FROM Inventory_Full__c';

        return Database.getQueryLocator(query);
    }
  
    // Execute Logic
    global void execute( Database.BatchableContext BC, List<Inventory_Full__c> invFullList )
    {  
        Map<String, Product_FIM__c> productMap = new Map<String,Product_FIM__c>(); 
        Map<String, Inventory_Stage__c> inventoryStageMap = new Map<String, Inventory_Stage__c>(); 
        Map<String, Inventory_Full__c> inventoryFullMap = new Map<String, Inventory_Full__c>();
        Map<String, Inventory__c> inventoryMap = new Map<String, Inventory__c>();
        List<Inventory_Full__c> excludedList = new List<Inventory_Full__c>();
        Set<String> materialNumbers = new Set<String>() ;
        
        // Itterate over stage rows and get StockPartnerNumber and Materials
        for( Inventory_Full__c s : invFullList )
        {
            if( s.Material__c != null )
            {
                materialNumbers.add(s.Material__c) ;
            } 
        }

        // Get Products 
        for( Product_FIM__c p : [ SELECT Id, Product_Key__c FROM Product_FIM__c WHERE Product_Key__c IN :materialNumbers ])
        {
            productMap.put(p.Product_Key__c, p ) ;
        }

        // Exculde records which dont have products 
        for( Inventory_Full__c inv : invFullList )
        {
            if( inv.Material__c != null && productMap.containsKey(inv.Material__c))
            {
                inventoryFullMap.put( inv.Inventory_ID__c, inv );
            } 
        }
        System.debug('UAC: excludedList ' + excludedList ) ;

        // Get all records from Inventory object that match the Inventory_id
        for( Inventory__c inv : [   SELECT Inventory_ID__c, 
                                           Status__c
                                    FROM Inventory__c WHERE Inventory_ID__c IN :inventoryFullMap.keySet()  ] )
        {
            inventoryMap.put(inv.Inventory_ID__c + '-' + inv.Status__c , inv);
        }

        
        // Itterate over InventoryFull records and check basesd on Serial number 
        for( Inventory_Full__c s : inventoryFullMap.values() )
        {
            //If the Serial # field is not blank and the record within the Inventory 
            //Full table does not exist within the Inventory table, the record 
            //should be written to the Inventory Stage table with a Status value of "Y".
            if( s.Serial_Number__c != null && !inventoryMap.containsKey(s.Inventory_ID__c + '-' + s.Status__c ) )
            {
                system.debug('### Y :' + s.Inventory_ID__c + '-' + s.Status__c); 
                Inventory_Stage__c inv = new Inventory_Stage__c(Inventory_ID__c = s.Inventory_ID__c, Model_Number__c = s.Model_Number__c, Full__c = true, Processed__c = false,
                                                                Quantity__c = s.Quantity__c, Serial_Number__c = s.Serial_Number__c, Status__c = 'Y',
                                                                Batch_Lot_Number__c = s.Batch_Lot_Number__c, Stock_Partner_Number__c = s.Stock_Partner_Number__c, 
                                                                Use_By_Date__c = s.Use_By_Date__c, Receipt_Date__c = s.Receipt_Date__c, Material__c = s.Material__c) ;
                inventoryStageMap.put(s.Inventory_ID__c + '-' + s.Status__c , inv);
            }

            //If the Serial # field is blank, the record should be written to 
            //the Inventory Stage table with a Status value of "Y".
            if( s.Serial_Number__c == null )
            {
                system.debug('### Y2 :' + s.Inventory_ID__c + '-' + s.Status__c); 

                Inventory_Stage__c inv = new Inventory_Stage__c(Inventory_ID__c = s.Inventory_ID__c, Model_Number__c = s.Model_Number__c, Full__c = true, Processed__c = false,
                                                                Quantity__c = s.Quantity__c, Serial_Number__c = s.Serial_Number__c, Status__c = 'Y',
                                                                Batch_Lot_Number__c = s.Batch_Lot_Number__c, Stock_Partner_Number__c = s.Stock_Partner_Number__c, 
                                                                Use_By_Date__c = s.Use_By_Date__c, Receipt_Date__c = s.Receipt_Date__c, Material__c = s.Material__c) ;
                inventoryStageMap.put(s.Inventory_ID__c + '-' + s.Status__c , inv);
            }
        }

        system.debug('#### inventoryStageMap.size ' + inventoryStageMap.size() );

        upsertInvetoryStage( inventoryStageMap.values() );
    }  

 
    global void finish(Database.BatchableContext BC )
    {

        // When finished then run batch job to check inv base
        FIT_InventoryBaseJob batchJob = new FIT_InventoryBaseJob();
        Database.executeBatch(batchJob, 200 );

        // Logic to be Executed at finish
        System.debug('Batch job finished...') ;
    }


/******************************************************************************
 * upsertInvetoryStage
 * @author: Andres Di Geronimo-Stenberg (Magnet 360)
 * @date: 2/4/2016
 * @jira: Insert or Update the InventoryStage records
 * @description: 
 * @param: List< Inventory_Stage__c > a_inventory_stage_records
 * @return: None.
 ******************************************************************************/
    public static void upsertInvetoryStage( List< Inventory_Stage__c > a_inventory_stage_records )
    {
        List<Database.UpsertResult> results = Database.upsert( a_inventory_stage_records , Inventory_Stage__c.Inventory_ID__c, false );
        Integer counter = 0;
        String errors;
        Integer recordsInserted, recordsUpdated, recordsDeleted, recordsErrors, recrodsExcluded, totalStageRecords ;
        recordsInserted = recordsUpdated = recordsDeleted = recordsErrors = totalStageRecords = recrodsExcluded = 0 ; 

        // Itterate over results
        for(Database.UpsertResult res : results)
        {
            // When error occurred during upsert
            if(!res.isSuccess() )
            {
                System.debug(System.LoggingLevel.ERROR, 'UAC: upsertable Stages Failed: ' + a_inventory_stage_records[counter] );
                errors = 'Inserting Inventory Records ';
                for(Database.Error er : res.geterrors())
                {
                    errors += er.getMessage();
                }
                errors += '\n';
                System.debug('UAC: error ' + errors) ;
                recordsErrors++ ;
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
                System.debug(System.LoggingLevel.ERROR, 'UAC: record prcoessed '+ res.getId() );
            }
            counter++;
        }        
    }

}