@Istest
public class Test_HFMReorderOpportunity {
    
    private static Opportunity oppty = null;
    
    @isTest 
    static void TestGetScheduleLineItems(){
        
        setupTest();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(oppty);
        HFMReorderOpportunity controller = new HFMReorderOpportunity(sc);
        
        List<OpportunityLineItemSchedule> items = controller.getScheduleLineItems();
        System.debug('Item Size: ' + items.size());
        System.assert(items != null );
        System.assert(items.size() > 0);
        
        ApexPages.StandardController scNew = new ApexPages.standardController(oppty);
        HFMReorderOpportunityNew controllerNew = new HFMReorderOpportunityNew(scNew);
        
        List<OpportunityLineItemSchedule> lineTempItems = controllerNew.getTempScheduleLineItems();
        System.assert(lineTempItems != null);
        
        List<OpportunityLineItemSchedule> lineItems = controllerNew.getScheduleLineItems();
        System.assert(lineItems != null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void TestNewReorder(){
        setupTest();
        
        Test.startTest();
        //Details & Edit Controller
        ApexPages.StandardController sc = new ApexPages.standardController(oppty);
        HFMReorderOpportunity controller = new HFMReorderOpportunity(sc);
        PageReference rc = controller.newReorder();
        
        System.assert(rc != null);      
        
        //New Controller
        ApexPages.StandardController scNew = new ApexPages.standardController(oppty);
        HFMReorderOpportunityNew controllerNew = new HFMReorderOpportunityNew(scNew);
        PageReference rcNew = controllerNew.newReorder();
        
        System.assert(rcNew != null); 
        
        Test.stopTest();
    }
    
    @isTest 
    static void TestEditScheduleLintItems(){
        setupTest();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(oppty);
        HFMReorderOpportunity controller = new HFMReorderOpportunity(sc);
        
        List<OpportunityLineItemSchedule> items = controller.getScheduleLineItems();
        System.assert(items != null );
        System.assert(items.size() > 0);
        
        System.assert(items[0].Quantity == 100);
        
        //Update the quantity & Save
        items[0].Quantity = 102;
        controller.SaveLineItemChanges();
        
        //Re-get things
        items = controller.getScheduleLineItems();
        System.assert(items != null );
        System.assert(items.size() > 0);
        System.assert(items[0].Quantity == 102);
        
        //update the quantity to break the save
        try{
            items.add(new OpportunityLineItemSchedule());
            controller.SaveLineItemChanges();
        }
        catch(DmlException e){System.debug('Testing DML Exception');}
        
        Test.stopTest();
    }
    
    @isTest
    static void TestGetItems(){
        setupTestForNew();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(oppty);
        HFMReorderOpportunityNew controller = new HFMReorderOpportunityNew(sc);
        
        List<SelectOption> productList = controller.getItems();
        System.assert(productList != null);
        
        Test.stopTest();
    }
    
    @isTest
    static void TestNewControllerMisc(){
        setupTestForNew();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(oppty);
        HFMReorderOpportunityNew controller = new HFMReorderOpportunityNew(sc);
        controller.setProductForOpty('Test');
        System.assert(controller.getProductForOpty() == 'Test');
        
        controller.setAccountId('Test');
        System.assert(controller.getAccountId() == 'Test');
        Test.StopTest();
    }
    
    /*
    @isTest
    
    static void TestSaveLineItemChanges() {
        setupTest();
        
        
        ApexPages.StandardController sc = new ApexPages.standardController(oppty);
        HFMReorderOpportunityNew controller = new HFMReorderOpportunityNew(sc);
        
        controller.ProductForOpty = 'CM1000: CardioMEMS™ Patient Electronics System (GSM)';
        controller.getTempScheduleLineItems();        
        
        Test.startTest();
        PageReference pg = controller.SaveLineItemChanges();
        System.assert(pg != null);
        
        
        try{
            controller.TempScheduleLineItems = null;
            controller.TempScheduleLineItems = new List<OpportunityLineItemSchedule>();
            controller.TempScheduleLineItems.add(new OpportunityLineItemSchedule(type='Both', 
                                                      // OpportunityLineItemId = opptyLineItem.Id,
                                                      //ScheduleDate = date.today() ,
                                                      //Quantity = 0,
                                                      Revenue = 22000
                                                     ));
            
            controller.SaveLineItemChanges();
        }
        catch(DmlException e){
            
        }
        
        
        Test.stopTest(); 
    }
    
    */
    
    
    private static void setupTestForNew(){
        ID opptyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SJM HFM Re-order Opportunity').getRecordTypeId();
        
        oppty = new Opportunity(Name = 'Test Opportunity',
                                RecordTypeId = opptyRecordType,
                                StageName = 'Final Negotitations',
                                CloseDate = Date.today());
        upsert oppty;
        
    }
    
    private static void setupTest(){
        setupTestForNew();        
        
        //Pricebook2 pb2 = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        //upsert pb2;
        
        Product2 prd = new Product2(Name = 'CM1000', 
                                    ProductCode = 'CM1000',
                                    CurrencyIsoCode = 'USD', 
                                    CanUseQuantitySchedule = true,
                                    CanUseRevenueSchedule=true);
        upsert prd;
        
        //pb2 = [select id from Pricebook2 where IsStandard = true limit 1];
        //Pricebook2 standardPB = Test.getStandardPricebookId();
        //Pricebook2 customPB = [select id from Pricebook2 where isStandard=true];
        
        PriceBookEntry pbe = new PriceBookEntry(CurrencyISOCode = 'USD',
                                                IsActive = true,
                                                Product2id = prd.Id,
                                                PriceBook2Id = Test.getStandardPricebookId(),
                                                //PriceBook2Id = customPB.id,
                                                UnitPrice = 1
                                                //,UseStandardPrice = false
                                               );
        upsert pbe;
        
        List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id FROM PriceBookEntry WHERE PriceBook2.isStandard=true LIMIT 1];
        System.debug('Test PriceBookList: ' + priceBookList);
        
        OpportunityLineItem opptyLineItem = new OpportunityLineItem( OpportunityId = oppty.Id,
                                                                    Quantity = 1,
                                                                    TotalPrice = 1,
                                                                    PricebookEntryId = pbe.id);
        upsert opptyLineItem;
        
        OpportunityLineItemSchedule opptyLineItemSchedule = new OpportunityLineItemSchedule(type='Both', 
                                                                                            OpportunityLineItemId = opptyLineItem.Id,
                                                                                            ScheduleDate = Date.today(),
                                                                                            Quantity = 100,
                                                                                            Revenue = 1000
                                                                                           );
        upsert opptyLineItemSchedule;
    }
}