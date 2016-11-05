@isTest
private class FIT_InventoryStageJobTest 
{
    public static testMethod void stageJob()
    {
        Account ac = new Account( Name = 'Test Account', SJM_ID__c= '10000369');
        insert ac;

        Product_FIM__c prod = new Product_FIM__c( Name = '1233' , Product_Key__c = '1233' );
        insert prod ;

        Double randomValue = Math.random();

        // Insert User
        Profile p = [SELECT Id FROM Profile WHERE name='System Administrator']; 
        User u = new User(  Alias = 'standt', Email='standarduser@testorg.com', Emailencodingkey='UTF-8', Username='test_user1'+ randomValue +'@company.com',
                            Lastname='Testing123', Languagelocalekey='en_US', Localesidkey='en_US', Profileid = p.Id, 
                            Timezonesidkey='America/Los_Angeles', Business_Partner__c = '3000055' );
        insert u;

    	// Insert Inventory Stage records
    	Inventory_Stage__c stage1 = new Inventory_Stage__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '10000369', Status__c = 'Y', Material__c = '1233' ) ;
        Inventory_Stage__c stage2 = new Inventory_Stage__c( Inventory_ID__c = '13', Stock_Partner_Number__c = '3000055', Status__c = 'Y', Material__c = '1233' ) ;
        Inventory_Stage__c stage3 = new Inventory_Stage__c( Inventory_ID__c = '16', Stock_Partner_Number__c = '3000055', Status__c = 'Y', Material__c = '1233' ) ;
        Inventory_Stage__c stage32 = new Inventory_Stage__c( Inventory_ID__c = '16', Stock_Partner_Number__c = '3000055', Status__c = 'N', Material__c = '1233' ) ;
    	Inventory_Stage__c stage4 = new Inventory_Stage__c( Inventory_ID__c = '14', Stock_Partner_Number__c = '3000055', Status__c = 'N', Material__c = '1233') ;
        Inventory_Stage__c stage5 = new Inventory_Stage__c( Inventory_ID__c = '15', Stock_Partner_Number__c = '325', Status__c = 'N', Material__c = '1233') ;

        Inventory_Stage__c stage6 = new Inventory_Stage__c( Inventory_ID__c = '17', Stock_Partner_Number__c = '3000055', Status__c = 'N', Material__c = '1233') ;
        Inventory_Stage__c stage7 = new Inventory_Stage__c( Inventory_ID__c = '17', Stock_Partner_Number__c = '3000055', Status__c = 'Y', Material__c = '1233') ;
        Inventory_Stage__c stage8 = new Inventory_Stage__c( Inventory_ID__c = '19', Stock_Partner_Number__c = '3000054', Status__c = 'Y', Material__c = '55' ) ;
        Inventory_Stage__c stage9 = new Inventory_Stage__c( Inventory_ID__c = '20', Stock_Partner_Number__c = '3000055', Status__c = 'Y', Material__c = '55' ) ;
    	insert new List<Inventory_Stage__c>{ stage1, stage2, stage3, stage4, stage5, stage6, stage7 , stage32 , stage8, stage9}; 

        Inventory_Stage__c stage31 = new Inventory_Stage__c( Inventory_ID__c = '16', Stock_Partner_Number__c = '3000055', Status__c = 'Y', Material__c = '1233' ) ;

        
        
        insert new List<Inventory_Stage__c>{ stage31 }; 


    	// Insert Inventory records
        Inventory__c inv1 = new Inventory__c( Inventory_ID__c = '12', Stock_Partner_Number__c = '5',  Status__c = 'Y' ) ;
    	Inventory__c inv2 = new Inventory__c( Inventory_ID__c = '14', Stock_Partner_Number__c = '5', Status__c = 'N' ) ;
    	insert new List<Inventory__c>{ inv1, inv2 }; 

    	// Run batch job
    	Test.startTest() ;
        FIT_InventoryStageJob batchJob = new FIT_InventoryStageJob();
        Database.executeBatch(batchJob, 200 );
        Test.stopTest() ;

        List< Inventory_Stage__c > l_stage = [ Select Id,
                                                     Error__c, 
                                                     Processed__c, 
                                                     Inventory_ID__c,
                                                     Status__c
                                              From Inventory_Stage__c ];

        System.assertEquals( l_stage.size() ,  11 );                                      

        for(Inventory_Stage__c is : l_stage )
        {
            if( is.Inventory_ID__c == '17')
            {
                System.assertEquals( is.Error__c , 'Duplicate Inventory ID records found' );
                System.assertEquals( is.Processed__c , TRUE );                
            }
            else if( is.Inventory_ID__c == '15')
            {
                System.assertEquals( is.Error__c , 'Matching Inventory ID could not be found' );
            }
            else if( ( is.Inventory_ID__c == '16' || is.Inventory_ID__c == '15') && is.Status__c =='N' )
            {
                System.assertEquals( is.Error__c , 'Matching Inventory ID could not be found' );
            }
            else if( is.id == stage3.id ) // stage3.id == The first InventStage.Inventory_ID__c ==16
            {
                system.assertEquals( is.Processed__c , true );
                System.assertEquals( is.Error__c , 'Duplicate Inventory ID records found' );
            }
            else if( is.Inventory_ID__c == '19' )
            {
                System.assertEquals( is.Error__c , 'Matching Consignment Location could not be found'+' | ' +'Matching Product could not be found' );
                System.assertEquals( is.Processed__c , TRUE ); 
            }
            
            else if( is.Inventory_ID__c == '20' )
            {
                System.assertEquals( is.Error__c , 'Matching Product could not be found' );
                System.assertEquals( is.Processed__c , TRUE ); 
            }

        }

        List< Inventory__c > l_invetory = [ Select id,
                                                   Inventory_ID__c, 
                                                   Account__c,
                                                   User__c,
                                                   Product_Number__c
                                            From Inventory__c ];

        for( Inventory__c i: l_invetory )
        {
            if( i.Inventory_ID__c == '12')
            {
                System.assert( i.Account__c == ac.id );
                system.assert( i.Product_Number__c == prod.id );
            }
            else if ( i.Inventory_ID__c == '13')
            {
                System.assert( i.User__c == u.id );
            }
            else if( i.Inventory_ID__c == '14' )
            {
                //Inventory with Inventory_ID__c == 14 must being deleted 
                system.assert(false);
            }
        }


        List<Inventory_Log__c> log = [Select  Date_Time__c , 
                                              Deleted__c , 
                                              In_Error__c , 
                                              Inserted__c, 
                                              Processed__c, 
                                              Updated__c 
                                     From Inventory_Log__c ];

        System.assertEquals( log.size() , 1 );
        //Delete InventoryShare with Inventory_ID__c = '14'
        System.assertEquals( log[0].Deleted__c , 1 );
        //Trying to delete Inventory_ID__c = '16' and 15. 
        //There is a InventoryShare with status == N
        //2 inventories with  Inventory_ID__c = '17' and one extra Y with  Inventory_ID__c = '16'
        //For Inventory_ID__c = '19', none user with Business_Partner__c = 3000055 is found
        //For Inventory_ID__c = '20', Product is not found
        System.assertEquals( log[0].In_Error__c , 7 ); 
        //Inserted InventoryShare with Inventory_ID__c = '13' and 16
        System.assertEquals( log[0].Inserted__c , 2 );
        //Inserted InventoryShare with Inventory_ID__c = '12'
        System.assertEquals( log[0].Updated__c , 1 );

        System.assertEquals( log[0].Processed__c , 11 );




    }
}