trigger QEvent_BeforeInsert on Event (before insert, before update) 
{
    Id evtRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('ANZ Standard Event').getRecordTypeId();
    
    if(QStaticTracker.m_bEventInsertTriggerFired == null)
        QStaticTracker.m_bEventInsertTriggerFired = false;
    
    if(QStaticTracker.m_bEventInsertTriggerFired)
    {
        return;
    }
    
    if(QStaticTracker.m_bEventUpdateTriggerFired == null)
        QStaticTracker.m_bEventUpdateTriggerFired = false;
    
    if(QStaticTracker.m_bEventUpdateTriggerFired)
    {
        return;
    }
    
    map<string,set<string>> mapAccountPerPersonAccountIds = new map<string,set<string>>();
    set<string> setPersonAccountIds = new set<string>();
    for(Event newEvent : trigger.new)
    {
        if(trigger.isUpdate && newEvent.Related_Call_ID__c != null && newEvent.Related_Call_ID__c != '' && 
                (newEvent.WhoId != trigger.oldMap.get(newEvent.Id).WhoId || newEvent.WhatId != trigger.oldMap.get(newEvent.Id).WhatId) )
        {
            newEvent.addError('You are not allowed to update the practitoner or the facility of an event related to a call. Please create a new call.');
            continue;
        }
        else if(newEvent.WhatId != null && String.valueOf(newEvent.WhatId).startsWith('001') && 
            newEvent.WhoId != null && String.valueOf(newEvent.WhoId).startsWith('003') )  
        {
            setPersonAccountIds.add(newEvent.WhoId);
        }
    }
    
    //Commented by Brahma for Consolidation
    //for(Relationship_360__c r360 : [select id, Account__c, Doctor__c from Relationship_360__c where Doctor__c in :setPersonAccountIds])
    for(Affiliation__c r360 : [select id, Account__c, Contact__c from Affiliation__c where Contact__c in :setPersonAccountIds])
    {
        if(mapAccountPerPersonAccountIds.get(r360.Contact__c) == null)
        {
            mapAccountPerPersonAccountIds.put(r360.Contact__c, new set<string>());
        }
        mapAccountPerPersonAccountIds.get(r360.Contact__c).add(r360.Account__c);
    }
    if(trigger.isInsert)
    {
        for(Event newEvent : trigger.new)
        {
            if(newEvent.WhatId != null && String.valueOf(newEvent.WhatId).startsWith('001') && 
                newEvent.WhoId != null && String.valueOf(newEvent.WhoId).startsWith('003')  && newEvent.RecordTypeId == evtRecordTypeId)  
            {
                if( mapAccountPerPersonAccountIds.containskey(newEvent.WhoId) && 
                    !mapAccountPerPersonAccountIds.get(newEvent.WhoId).contains(newEvent.WhatId))
                {
                    newEvent.addError('You must select a "Facility" related to the "Practitioner."');
                }
            }
        }
    }
}