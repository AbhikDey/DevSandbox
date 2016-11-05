/*
    Author : Sunil Damle
*/
trigger event_AssignedEvent on Event (Before update) { 
    Map<id,Schema.RecordTypeInfo> evntType = Event.sObjectType.getDescribe().getRecordTypeInfosById();
    for(Event newEvent : trigger.new){
        //If event is procedure scheduler
        if(evntType.get(newEvent.recordTypeID).getName().containsIgnoreCase('Procedure Scheduler'))
        {           
            {
                if((Trigger.oldMap.get(newEvent.Id).Assignment_Status__c ) == 'Uncovered')
                {
                    if(newEvent.OwnerId != Trigger.oldMap.get(newEvent.Id).OwnerId)
                    {
                        //Owner is being changed
                        newEvent.Assignment_Status__c = 'Assigned';
                    }
                    
                }
            }
        }    
    }
}