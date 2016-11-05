public class OpportunityController {
    
    private static Set<String> ilProducts = new Set<String> { '' };
    private static Set<String> cmProducts = new Set<String> { '' };
    
    public static void handleBeforeInsert( List<Opportunity> opps ) {
    
        //Update Pricebook 
        List<Pricebook2> stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
        
        if(!stdPBL.isEmpty()){
            for(Opportunity o: opps )
            o.PriceBook2Id = stdPBL[0].id;
          }
        
        //End PriceBookUpdate
        // Iterate over the Opportunities and identify the Accounts.
        Set<Id> accountIds = new Set<Id>();
        for( Opportunity opp : opps ) {
            accountIds.add( opp.AccountId );
        }
        
        // Put the Opportunity Record Types into a map.
        Map<String,Id> oppRecordTypesMap = new Map<String,Id>();
        for( RecordType rt : [
                                SELECT  Id,
                                        Name
                                FROM    RecordType
                                WHERE   SObjectType = 'Opportunity'
                            ] ) {
            oppRecordTypesMap.put( rt.Name, rt.Id );
        }
        
        // Query for the Account Products and put them into a map.
        Map<Id,Map<Id,Id>> accountProductsMap = new Map<Id,Map<Id,Id>>();
        for( Account account : [
                                    SELECT  Id,
                                    (
                                        SELECT  Id,
                                                Product_Line__c
                                        FROM    Product_Accounts__r
                                        WHERE   Product_Line__c IN ( 'AF', 'CARDIOMEMS' )
                                        ORDER BY    CreatedDate DESC
                                    )
                                    FROM    Account
                                    WHERE   Id IN :accountIds
                            ] ) {
            
            // If there are products related to the Account.
            if( account.Product_Accounts__r != null && account.Product_Accounts__r.size() > 0 ) {
                
                // Initialize the products map.
                Map<Id,Id> productsMap = new Map<Id,Id>();
                
                // Add the products map to the parent map.
                accountProductsMap.put( account.Id, productsMap );
                
                // Iterate over the products.
                for( Product_Account__c product : account.Product_Accounts__r ) {
                    
                    // If the product line is CardioMems.
                    if( 'CARDIOMEMS'.equals( product.Product_Line__c ) && productsMap.get( oppRecordTypesMap.get( 'CardioMEMS' ) ) == null ) {
                        productsMap.put( oppRecordTypesMap.get( 'CardioMEMS' ), product.Id );
                    }
                    // If the product line is Integrated Labs.
                    else if( 'AF'.equals( product.Product_Line__c ) && productsMap.get( oppRecordTypesMap.get( 'Integrated Lab' ) ) == null  ) {
                        productsMap.put( oppRecordTypesMap.get( 'Integrated Lab' ), product.Id );
                    }
                    
                }
                
            }
            
        }
        
        // Iterate over the Opportunities.
        for( Opportunity opp : opps ) {
            
            // Grab the Account Products map.
            Map<Id,Id> productsMap = accountProductsMap.get( opp.AccountId );
            
            // Skip the record if there aren't any mapped values.
            if( productsMap == null || productsMap.size() == 0 ) continue;
            
            // Grab the id of the appropriate product.
            Id productId = productsMap.get( opp.RecordTypeId );
            
            // If product id was found.
            if( productId != null ) {
                
                // Set the Opportunity's Product Account value.
                opp.Product_Account__c = productId;
                
            }
            
        }
        
    }

}