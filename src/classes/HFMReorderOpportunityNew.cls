/* Class: HFMReorderOpportunityNew
* VF: HFMReorderOpportunityDetails, HFMReorderOpportunityEdit
* Test Class: Test_HFMReorderOpportunity
* Purpose: Provide the "Detail" view & "Edit" functionality for HFM Reorder Opportunity
* */

public class HFMReorderOpportunityNew {
    
    private final ApexPages.StandardController controller;
    private static Opportunity opptyReOrder = null;
    public Opportunity oppty;
    private List<OpportunityLineItemSchedule> scheduleLineItems = new List<OpportunityLineItemSchedule>();
    
    //stores temporary line item data
    public List<OpportunityLineItemSchedule> tempScheduleLineItems = new List<OpportunityLineItemSchedule>();
    public string ProductForOpty {get;set;}
    public string AccountId {get;set;}
    
    public String getProductForOpty () {
        return productForOpty;
    }
    
    public void setProductForOpty (string optyPR) {
        this.productForOpty = optyPR;
    }
    
    public String getAccountId  () {
        return AccountId ;
    }
    
    public void setAccountId  (string acct) {
        this.AccountId = acct;
    }
    
    public HFMReorderOpportunityNew(ApexPages.StandardController stdController){
        
        oppty = (Opportunity)stdController.getRecord();
        if(oppty== null)
        {
            //PageReference redirectSuccess = new ApexPages.StandardController(reOrder_c).view();
            // return (redirectSuccess);            
        }
        controller = stdController;
        
        string accid = ApexPages.currentPage().getParameters().get('accountid');
        
        AccountId = accid;
        
        System.debug('Account ID: ' + AccountId);
        
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        /* options.add(new SelectOption('CM2000: CardioMEMS™ PA Sensor and Delivery System','CM2000: CardioMEMS™ PA Sensor and Delivery System'));
options.add(new SelectOption('CM1000','CM1000: CardioMEMS™ Patient Electronics System (GSM)'));
options.add(new SelectOption('CM1010','CM1010: CardioMEMS™ Patient Electronics System (Land Line)'));*/
        // List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            Opportunity.HFMReorderProduct__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
        
    }
    
    
    
     public List<OpportunityLineItemSchedule> getTempScheduleLineItems(){
        if ((TempScheduleLineItems== null || TempScheduleLineItems.size() == 0) && oppty != null){
            //create 12 dummy records with Date = last day of the month;
            //Quantity 0 and price = list price
            
            Integer[] myInts = new Integer[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12};
            OpportunityLineItemSchedule v1 = null;
            Integer numberOfDays = 31;
            Date ScheduleDateindex ;
            Date lastDayOfMonth;
            
            for (Integer i : myInts) {
            
                numberOfDays = Date.daysInMonth( System.Today().year(), i);
                lastDayOfMonth = Date.newInstance(System.Today().year(), i, numberOfDays);
                
                ScheduleDateindex = Date.newInstance(2016, i, 31);
            
                v1 =  new OpportunityLineItemSchedule(type='Both', 
                                           /* OpportunityLineItemId = opptyLineItem.Id,*/
                                            ScheduleDate = lastDayOfMonth ,
                                            Quantity = 0,
                                            Revenue = 22000
                                           );
                tempScheduleLineItems.add(v1); 
               
            }
            
          
            
            
        }
        
        return tempScheduleLineItems;
    }
    
    
    public List<OpportunityLineItemSchedule> getScheduleLineItems(){
        if ((scheduleLineItems == null || scheduleLineItems.size() == 0) && oppty != null){
            //get data from DB;
            List<OpportunityLineItem> opptyLineItemIds = [SELECT ID FROM OpportunityLineItem where OpportunityId = :oppty.Id];
            
            scheduleLineItems = [SELECT Id, Quantity, Revenue, ScheduleDate, Type 
                                 FROM OpportunityLineItemSchedule 
                                 WHERE OpportunityLineItemID in :opptyLineItemIds
                                 AND Type = 'Both'
                                 ORDER BY ScheduleDate
                                ];
        }
        
        return scheduleLineItems;
    }
    
    public PageReference newReorder() {
        PageReference newPage = new PageReference('/apex/HFMReorderOpportunityNew');
        newPage.setRedirect(true);
        return newPage;
    }
    
     public PageReference SaveLineItemChanges() {
    
     
     
               pageReference pv = new PageReference('/apex/hfmreorderopportunitydetails') ;
               Date lastDayOfYear = Date.newInstance(System.Today().year(), 12, 31);
               ID opptyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SJM HFM Re-order Opportunity').getRecordTypeId();
               Date closeDate =  Date.newInstance(2016, 12, 31);
               
                try {
                    
               
            opptyReOrder = new Opportunity(Name = 'Test Opportunity',
                            RecordTypeId = opptyRecordType,
                            AccountId = AccountId,
                            StageName = 'Final Negotitations',
                            HFMReorderProduct__c = ProductForOpty,
                            CloseDate = lastDayOfYear );
             upsert opptyReOrder;
        
            if(opptyReOrder != null)
            {
                PageReference pr = controller.save();
            
                //1. Get selected Model
                Integer ProductCodeIndex = ProductForOpty.indexOf(':');
                system.debug('character found at '+ ProductCodeIndex);
                String Model = ProductForOpty.left(ProductCodeIndex);
                system.debug('Selected Model is '+ Model );
                
                //2. 
                Product2 selectProduct  = [SELECT Id FROM Product2 where ProductCode =: Model];
                system.debug('selected Product Id is ' + selectProduct.Id);
                List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id FROM PriceBookEntry WHERE Product2Id =: selectProduct.Id AND PriceBook2.isStandard=true LIMIT 1];
                
                OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=opptyReOrder.Id, PricebookEntryId=priceBookList[0].Id, UnitPrice=22000, Quantity = decimal.valueof('12'));                               
                insert oli;
                
                system.debug('Size....' + tempScheduleLineItems .size());
                system.debug('Size....' + tempScheduleLineItems .size());
                
                //3. Create schedule line items
                Integer i = 0;
                while (i < tempScheduleLineItems .size())
                {
                    tempScheduleLineItems.get(i).OpportunityLineItemId  = oli.id;
                    i++;
                    
                }
                
                insert tempScheduleLineItems;

                 pv.getParameters().put('Id', opptyReOrder.Id);
                 pv.setRedirect(true);
               
                    
            }
            
     
        } 
        Catch (DMLException e) {
            pv = null;
            ApexPages.addMessages(e);
            return null;
        }
        
        
        return pv;
    }
}