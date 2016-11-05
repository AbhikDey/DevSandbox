trigger UpdateEventID on Procedure__c (after insert, after update) {
    
    ID rectypeid = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('DBS Case').getRecordTypeId();
    List<Event> evt = new List<Event>(); 
    Event evt1 = new Event();  
    if (Trigger.isInsert || Trigger.isUpdate) 
    { 
        for(Procedure__c p : trigger.new)
        {
            //system.debug('@@Recordtypeid  ' + p.RecordTypeId + '  @@original id ' + rectypeid);
           if(p.RecordTypeId == rectypeid && p.Related_Event_ID__c != null)
           {
               evt1.Id = p.Related_Event_ID__c;
               evt1.Procedure__c = p.Id;
               //evt1.Status__c = 'Completed';
               //system.debug('@@evt1.Procedure__c  ' + evt1.Procedure__c + '  @@evt1.Status__c ' + evt1.Status__c + '  @@evt1.Id ' + evt1.Id);
              
               evt.add(evt1);
               //system.debug('@@evt '  + evt);
           } 
        }
    }
        if(evt.size() > 0)
            update evt;
        
}