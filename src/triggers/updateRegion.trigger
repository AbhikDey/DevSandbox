trigger updateRegion on Event(after insert) {
   for(Event evt:Trigger.new){
    String region = evt.AccountREgion__c; 
    String eventTypeId = evt.RecordTypeId;
    if(eventTypeId == '012g00000008pnAAAQ')
    {
      
  //  EventRelation er = new EventRelation(EventId = evt.id, RelationId = '023g0000002X8Ka', Status = 'Accepted', isParent = false, isWhat=false,isInvitee = true);
  //  insert er;
    
    //Sunil Damle :005j000000CCnDiAAL
    // EventRelation erSD = new EventRelation(EventId = evt.id, RelationId = '023g0000002XNou', Status = 'New', isParent = false, isWhat=false, isInvitee = false);
   // insert erSD;
    
   // EventRelation userEr = new EventRelation(EventId = evt.id, RelationId = '005j000000CDBXXAA5', Status = 'Accepted', isParent = false, isWhat=false,isInvitee = true);
   // insert userEr;
    }
    
    }
}