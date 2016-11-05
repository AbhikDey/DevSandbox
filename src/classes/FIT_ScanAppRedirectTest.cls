@isTest
private class FIT_ScanAppRedirectTest
{
    @isTest
    static void TestScanAppRedirect()
    {
        // Create Accout
        RecordType  customerRecordType = [SELECT Id, Developername FROM Recordtype WHERE DeveloperName='SJM_Customer'];

        Account ac = new Account(Name='Test', recordTypeId = customerRecordType.Id );
        insert ac;

        RecordType  Inventory_Transfer = [ Select Id 
                                    From RecordType 
                                    Where DeveloperName=: 'Inventory_Transfer' 
                                    AND SobjectType = 'Transactions__c' limit 1];

        // Create Transaction
        Transactions__c trans = new Transactions__c(Account__c=ac.Id, Status__c = 'In Progress', recordTypeId = Inventory_Transfer.id);
        insert trans ;

        Inventory__c l_inventory = new Inventory__c();
        
        l_inventory.Serial_Number__c = '7517399'; 
        insert l_inventory;


        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.ScanAppRedirect')); 
            System.currentPageReference().getParameters().put('Id', trans.id);
            System.currentPageReference().getParameters().put('scanValue', ']c1010541473450361717151231217517399');


            FIT_ScanAppRedirectController l_controller = new FIT_ScanAppRedirectController();
            l_controller.redirect();

            List<FIT_DeepLinkDummy__c> l_item = [ Select id from FIT_DeepLinkDummy__c Where FIT_Inventory__c =:l_inventory.id];
            system.assertEquals( l_item.size() , 1 );
        Test.stopTest();
    }
}