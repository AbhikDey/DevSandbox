/**
*		Udate event when we update a call
		@actor : David Browaeys
*/
trigger QCallRecord_AfterUpdate on Call_Record__c (after update) 
{
	if(QStaticTracker.m_bCallUpdateTriggerFired == null)
		QStaticTracker.m_bCallUpdateTriggerFired = false;
	
	if(QStaticTracker.m_bCallUpdateTriggerFired)
	{
		return;
	}	
	
	set<id> setEventIds 	= 		new set<id>();
	map<string,Call_Record__c> mapNextCallToInsert = new map<string,Call_Record__c>();
	
	for(Call_Record__c c : trigger.new)
	{
		if(c.Date_Time_of_Call__c != trigger.oldMap.get(c.Id).Date_Time_of_Call__c)
		{
			if(c.Related_Event_ID__c != null)
			{
				setEventIds.add(c.Related_Event_ID__c);
			}
		}
		if(c.Follow_Up_Due_Date_Time__c != null && trigger.oldMap.get(c.Id).Follow_Up_Due_Date_Time__c == null)
		{
			Call_Record__c sNextCall 				= new Call_Record__c();
			sNextCall.RecordTypeId					= c.RecordTypeId;
			sNextCall.Call_Objectives__c		 	= c.Next_Call_Objective__c;
			sNextCall.Date_Time_of_Call__c 			= c.Follow_Up_Due_Date_Time__c;
			sNextCall.Contact__c					= c.Contact__c;
			sNextCall.Facility_Practitioner__c 		= c.Facility_Practitioner__c;
			sNextCall.Division__c					= c.Division__c;
			sNextCall.Call_Status__c				= 'Planning';
			
			mapNextCallToInsert.put(c.Id, sNextCall);	
		}
	}
	
	if(!mapNextCallToInsert.values().IsEmpty()) insert mapNextCallToInsert.values();
	
	if(!setEventIds.isEmpty())
	{
		//boolean to check if updated
		boolean bToUpdate = false;
		
		map<id, Event> mapEvents = new map<id, Event>([	select	Id, ActivityDateTime
														from	Event
														where	id in :setEventIds]);												
		
		for(Call_Record__c c : trigger.new)
		{
			if(c.Date_Time_of_Call__c != trigger.oldMap.get(c.Id).Date_Time_of_Call__c)
			{
				Event e = mapEvents.get(c.Related_Event_ID__c);
				
				if(e != null)
				{
					e.ActivityDateTime = c.Date_Time_of_Call__c;
					mapEvents.put(e.Id,e);
					bToUpdate = true;
				}
			}
		}
		
		if(!mapEvents.values().IsEmpty() && bToUpdate){update mapEvents.values();}
	}
	
	QStaticTracker.m_bCallUpdateTriggerFired = true;	//lock call update trigger
		
	list<Call_Record__c> liCallToUpdate = new list<Call_Record__c>();
	list<Event> liEventToUpdate = new list<Event>();
	for(Call_Record__c c : trigger.new)
	{	
		Call_Record__c sCall = new Call_Record__c(Id=c.Id);
		
		if(mapNextCallToInsert.get(c.Id) != null)
		{
			sCall.Next_Call_Record_ID__c = mapNextCallToInsert.get(sCall.Id).Id;
		}
		
		liCallToUpdate.add(sCall);
	}
	
	if(!liCallToUpdate.IsEmpty()){ update liCallToUpdate;}
	
	QStaticTracker.m_bCallUpdateTriggerFired = false;	//unlock call update trigger
}