/**
 * Class: HFMReorderOpportunity
 * VF: HFMReorderOpportunityDetails, HFMReorderOpportunityEdit
 * Test Class: Test_HFMReorderOpportunity
 * Purpose: Provide the "Detail" view & "Edit" functionality for HFM Reorder Opportunity
 * */

public class HFMReorderOpportunity {
	
    private final ApexPages.StandardController controller;
    private final Opportunity oppty;
   	private List<OpportunityLineItemSchedule> scheduleLineItems = new List<OpportunityLineItemSchedule>();
    
    public HFMReorderOpportunity(ApexPages.StandardController stdController){
        oppty = (Opportunity)stdController.getRecord();
        controller = stdController;
    }
    
    public List<OpportunityLineItemSchedule> getScheduleLineItems(){
        if (scheduleLineItems == null || scheduleLineItems.size() == 0){
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
        try {
            system.debug('Update'+scheduleLineItems );
            update scheduleLineItems ;
        } 
        Catch (DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        PageReference pr = controller.save();
        pageReference pv = controller.view();
        return pv;
    }
}