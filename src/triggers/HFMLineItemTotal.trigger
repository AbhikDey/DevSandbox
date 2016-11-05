/**********************************************************************************************
    Author : Sunil
    Description : This trigger updates the Total amount
     on Reorder Line Item using (Revenue * Quantity) from the line item schedule object
**********************************************************************************************/

trigger HFMLineItemTotal on OpportunityLineItem (Before update) {
   
     List<RecordType> recordTypeId = [SELECT ID FROM RecordType where DeveloperName = :'CardioMEMS_Reorder' LIMIT 1];
     
     for(OpportunityLineItem oli : trigger.new)
     {
         List<Opportunity> parentOpty = [SELECT RecordTypeId,Id from Opportunity where Id = : oli.OpportunityId LIMIT 1];
         //Check if the Opportunity type is Re_order
         if(parentOpty[0].RecordTypeId == recordTypeId[0].id)
         {
            
             system.debug('You are upating Reorder...' + oli.OpportunityId  + '..' );
             
             //check if there are any schedule line items
              List<OpportunityLineItemSchedule> scheduleLineItems = [SELECT Id, Quantity, Revenue, ScheduleDate, Type 
                                 FROM OpportunityLineItemSchedule 
                                 WHERE OpportunityLineItemID = : oli.id
                                 AND Type = 'Both'
                                 ORDER BY ScheduleDate
                                ];
                     
             Decimal Total = 0;            
             for(OpportunityLineItemSchedule li :ScheduleLineItems)
             {
                Total  = Total  + (li.Revenue * li.Quantity);
             }
             
             //update total into HFM_Total__c
             oli.HFM_Total__c = Total;
         }
         else
         {
                 system.debug('This is not a reorder...' + oli.OpportunityId + '..' );
         }
         
     }
     
     
   
}