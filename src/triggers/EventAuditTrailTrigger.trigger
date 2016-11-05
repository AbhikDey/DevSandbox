trigger EventAuditTrailTrigger on Event (after insert, after update) {
    //collection object for all updates
    List<SchedulerAuditTrail__c> updates = new List<SchedulerAuditTrail__c>();
    
   	id procSchRecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Procedure Scheduler').getRecordTypeId();
    
    //loop thru new objects for the trigger
    for(Event e : Trigger.New){
        //System.debug('Dev Name ' + e.recordTypeId);
        
        if (e.recordTypeId == procSchRecordId){
            //figure out if the type is "create" or "update"
            string type = 'Create';
            if (Trigger.oldMap != null && Trigger.oldMap.get(e.id) != null){
                type = 'Update';
            }
                
            SchedulerAuditTrail__c trail = new SchedulerAuditTrail__c(
                ActivityId__c = e.id,
                createBy__c = e.createdById,
                createDate__c = datetime.now(),
                updateType__c = type
            );
                
            updates.add(trail);
        }
    }
    
    //update the database
    if (updates.size() > 0){
        System.debug('Ready to insert:' + updates.size());
    	Database.insert(updates);
    }
    else{
        System.debug('No changes discovered');
    }
}