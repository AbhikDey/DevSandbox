@isTest
private class FIT_InventoryFullJobTest
{
	@isTest
	static void runBatch()
	{

        Product_FIM__c l_product = new Product_FIM__c( Name = '11111' , Product_Description__c = 'Description' , Product_Key__c = '11111');
        insert l_product;

        Inventory__c l_inventory = new Inventory__c( Inventory_ID__c = 'invid',
                                                     Status__c = 'Y');
        //A inventorytage is going to be created for this records with status = N
        //Becase there are no inventoryStage with the same InventoryID
        Inventory__c l_inventory2 = new Inventory__c( Inventory_ID__c = 'invid2',
                                                      Status__c = 'Y');

        Inventory__c l_inventory3 = new Inventory__c( Inventory_ID__c = 'invid3',
                                                      Status__c = 'Y');

        //A inventorytage is going to be created for this records with status = N
        //Becase there are no inventoryStage with the same InventoryID
        Inventory__c l_inventory4 = new Inventory__c( Inventory_ID__c = 'invid4',
                                                      Status__c = 'Y');

        Inventory__c l_inventory5 = new Inventory__c( Inventory_ID__c = 'invid5',
                                                      Status__c = 'Y');

        insert new List< Inventory__c > { l_inventory, l_inventory2 ,l_inventory3, l_inventory4,l_inventory5};

        //This invFull is going to be processed because match a material# with 
        //product name, and inventoryID doesn't exists in the InventoryBase
        //and Serial_Number__c != blank
        Inventory_Full__c l_full_1 =  new Inventory_Full__c( Inventory_ID__c = 'newinvid' , 
                                                             Material__c = l_product.Name , 
                                                             Status__c = 'Y' , 
                                                             Serial_Number__c = '0000');


        //This invFull is not going to be processed because match the inventoryID 
        //with an  existing in the InventoryBase inventoryID and Serial_Number__c != blank
        Inventory_Full__c l_full_2 =  new Inventory_Full__c( Inventory_ID__c = 'invid' , 
                                                             Material__c = l_product.Name , 
                                                             Status__c = 'Y', 
                                                             Serial_Number__c = '0000');


        //This invFull is not going to be processed because it doesn't match a 
        //material# with product name,
        Inventory_Full__c l_full_3 =  new Inventory_Full__c( Inventory_ID__c = 'newinvid2' , 
                                                             Material__c = '22222' , 
                                                             Status__c = 'Y', 
                                                             Serial_Number__c = '0000');

        //This invFull is going to be processed because match a material# with 
        //product name, and inventoryID doesn't exists in the InventoryBase
        //and Serial_Number__c == blank
        Inventory_Full__c l_full_4 =  new Inventory_Full__c( Inventory_ID__c = 'newinvid3' , 
                                                             Material__c = l_product.Name , 
                                                             Status__c = 'Y', 
                                                             Serial_Number__c = '');

        //An inventory record with status=Y is going to be created for this entry
        //Becase the inventoryBase records that exists has status=N
        Inventory_Full__c l_full_5 =  new Inventory_Full__c( Inventory_ID__c = 'invid3' , 
                                                             Material__c = l_product.Name , 
                                                             Status__c = 'N', 
                                                             Serial_Number__c = '0000');        

        //Because the l_full_5 creates an inventoryFull, this one is going to be
        //ommited. Duplicated invid3+Status
        Inventory_Full__c l_full_6 =  new Inventory_Full__c( Inventory_ID__c = 'invid3' , 
                                                             Material__c = l_product.Name , 
                                                             Status__c = 'N', 
                                                             Serial_Number__c = '');   

        //Even when the InventoryId+Status match with an InventoryBase record
        //a new InventoryStage is going to be created because the 
        //serial number == null
        Inventory_Full__c l_full_7 =  new Inventory_Full__c( Inventory_ID__c = 'invid5' , 
                                                             Material__c = l_product.Name , 
                                                             Status__c = 'Y', 
                                                             Serial_Number__c = '');   

        insert new List<Inventory_Full__c> { l_full_1 , l_full_2 , l_full_3 , l_full_4 , l_full_5 , l_full_6, l_full_7};

        Test.startTest();
            FIT_InventoryFullJob batchJob = new FIT_InventoryFullJob();
            Database.executeBatch(batchJob);
        Test.stopTest();

        List<Inventory_Stage__c > l_stages = [Select ID, Status__c From Inventory_Stage__c];

        Integer l_status_y = 0;
        Integer l_status_n = 0;
        for( Inventory_Stage__c stage : l_stages )
        {
            if( stage.Status__c == 'Y' )
            {
                l_status_y++;
            }
            else if( stage.Status__c == 'N'  )
            {
                l_status_n++;
            }
        }


        system.assertEquals( l_status_y ,  4 );
        system.assertEquals( l_status_n ,  2 );

	}
}