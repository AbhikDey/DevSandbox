@isTest
public class OpportunityController_Test {
    
    @isTest
    private static void testProductSync() {
        
        // Create a record type map.
        Map<String,Id> recordTypesMap = new Map<String,Id>();
        for( RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity'] ) {
            recordTypesMap.put( rt.Name, rt.Id );
        }
        
        // Create Account.
        Account a1 = new Account    (
                                        Name = 'a1'
                                    );
        
        insert a1;
        system.assertNotEquals( null, a1.Id );
        
        // Create Account Products.
        Product_Account__c paCM = new Product_Account__c    (
                                                                Account_Id__c = a1.Id,
                                                                Product_Line__c = 'CARDIOMEMS'
                                                            );
        
        Product_Account__c paIL = new Product_Account__c    (
                                                                Account_Id__c = a1.Id,
                                                                Product_Line__c = 'AF'
                                                            );
        
        insert new List<Product_Account__c> { paCM, paIL };
        system.assertNotEquals( null, paCM.Id );
        system.assertNotEquals( null, paIL.Id );
        
        // Create Opportunities.
        Opportunity oppCM = new Opportunity (
                                                AccountId = a1.Id,
                                                CloseDate = Date.today(),
                                                Name = 'oppCM',
                                                RecordTypeId = recordTypesMap.get( 'SJM HFM New Opportunity' ),
                                                StageName = 'Prospecting'
                                            );
        
        Opportunity oppIL = new Opportunity (
                                                AccountId = a1.Id,
                                                CloseDate = Date.today(),
                                                Name = 'oppIL',
                                                RecordTypeId = recordTypesMap.get( 'Integrated Lab' ),
                                                StageName = 'Prospecting'
                                            );
        
        insert new List<Opportunity> { oppCM, oppIL };
        system.assertNotEquals( null, oppCM.Id );
        system.assertNotEquals( null, oppIL.Id );
        
        //Update
        Opportunity UpdateOpp = [SELECT Id, Name FROM Opportunity WHERE Id = :oppCM.Id];
        UpdateOpp.Name = 'UpdateCM';
        update UpdateOpp;
        //
        
        //Check pricing record
        
        List<Pricebook2> stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
        
        if(!stdPBL.isEmpty()){
             system.assertNotEquals( oppCM.PriceBook2Id, stdPBL[0].id );
             system.assertNotEquals( oppIL.PriceBook2Id, stdPBL[0].id );
            //for(Opportunity o: opps )
            //o.PriceBook2Id = stdPBL[0].id;
          }
        
        
        //
        // Query for the Opportunities' updated info.
        List<Opportunity> updatedOpps = [
                                            SELECT  Id,
                                                    Product_Account__c,
                                                    RecordType.Name
                                            FROM    Opportunity
                                            WHERE   Id IN ( :oppCM.Id, :oppIL.Id )
                                        ];
        
        // Iterate over the updated Opportunities.
        for( Opportunity opp : updatedOpps ) {
            
            // If Opportunity is CardioMEMS.
            if( 'CardioMEMS'.equals( opp.RecordType.Name ) ) {
                system.assertEquals( paCM.Id, opp.Product_Account__c );
            }
            // If Opportunity is Integrated Lab.
            else if( 'Integrated Lab'.equals( opp.RecordType.Name ) ) {
                system.assertEquals( paIL.Id, opp.Product_Account__c );
            }
            
        }
        
    }

}