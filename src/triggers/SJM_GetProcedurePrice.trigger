trigger SJM_GetProcedurePrice on Procedure__c (before insert, before update) {
    
    /******************/    
    map<Id,String> UniqueIdsMap = new map<Id,String>();
    map<Id,Procedure__c> P_Map = new map<Id,Procedure__c>();
    map<String,Price_List__c> PL_Map = new map<String,Price_List__c>();
    list<Price_List__c> PList = new list<Price_List__c>();
    set<id> setEventIds = new set<id>();
     ID rectypeid = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('DBS Case').getRecordTypeId();
     system.debug('@@DBSRecordtype' + rectypeid);
    for(Procedure__c p : trigger.new)
    {
        if(p.RecordTypeId != rectypeid){
        system.debug('@@Recordtypeid  ' + p.RecordTypeId);
            UniqueIdsMap.put(p.Id,p.Procedure_Type__c.toLowerCase());
            P_Map.put(p.Id,p);
            p.SJM_Procedure_Price__c = 0;
            //system.debug(' P UniqueIdsMap - '+p.Procedure_Type__c);
            //system.debug(' p.SJM_Procedure_Price__c - '+p.SJM_Procedure_Price__c);
            //Get Events for the procedure created
            if(p.Procedure_Date__c != null && p.Related_Event_ID__c != null){
                setEventIds.add(p.Related_Event_ID__c);
            }
        }
    }
    
    if(UniqueIdsMap.size() > 0)
    {
        PList = [Select Id, UniqueID__c, New_Device_Price__c, Resterilized_Device_Price__c from Price_List__c Where UniqueID__c in :UniqueIdsMap.values() and Active__c=true];
    }
    
    if(PList.size() > 0)
    {
        //Clear PL_Map
        PL_Map.clear();
        for(Price_List__c pl : PList){
        PL_Map.put(pl.UniqueID__c.toLowerCase(),pl);
        //system.debug('PL UniqueIdsMap - '+pl.UniqueID__c);
        }
    }
    //system.debug('P_Map size - '+P_Map.size());
    //system.debug('PList size - '+PList.size());
    //system.debug('PL_Map size - '+PL_Map.size());
    
    for(String s : PL_Map.keyset()){
        //system.debug('Key - '+s);
        //system.debug('PL Map - '+PL_Map.get(s));
        for(String v : UniqueIdsMap.values()){
            if(s == v){
                system.debug('Key Matched');
            } else {
                system.debug('Key Not Matched');
            }
        }
    }
    
    
    for(Procedure__c p : trigger.new)
    {  
    if(p.RecordTypeId != rectypeid){         
     if(PList.size() > 0 && PL_Map.size() > 0)
     {
        String s = UniqueIdsMap.get(p.Id);
        //system.debug('UniqueID - '+UniqueIdsMap.get(p.Id));
        //system.debug('PL Map - '+PL_Map.get(s));
        //system.debug('New Device - '+PL_Map.get(s).New_Device_Price__c);
        //system.debug(' p.SJM_Procedure_Price__c - '+p.SJM_Procedure_Price__c);            
        try{
            p.SJM_Procedure_Price__c = PL_Map.get(s).New_Device_Price__c;
        } catch (System.NullPointerException e) {
            p.SJM_Procedure_Price__c = 0;
        }
        //system.debug(' p.SJM_Procedure_Price__c - '+p.SJM_Procedure_Price__c);
     } else {
        p.SJM_Procedure_Price__c = 0;
     } 
     }    
    }
    
    //Update Scheduler Events to Confirmed after procedure is created
    if(!setEventIds.isEmpty())
    {
        List<Event> EvtUpdate = new List<Event>();
        map<id, Event> mapEvents = new map<id, Event>([ select Id, Status__c from Event where Status__c = 'Open' and id in :setEventIds]);      
        
        for(Id key : mapEvents.keyset()){
            Event e = mapEvents.get(key);
            
            if(e != null)
            {
                e.Status__c = 'Confirmed';
                EvtUpdate.add(e);
            }
        }
        
        if(!EvtUpdate.IsEmpty()){update EvtUpdate;}
    }
    
}