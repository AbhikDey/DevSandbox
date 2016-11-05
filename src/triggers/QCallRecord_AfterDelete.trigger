/**
*		Delete related events when we delete a call
		@actor : David Browaeys
*/
trigger QCallRecord_AfterDelete on Call_Record__c (after delete) 
{
	set<string> setEventIds = new set<string>();
	for(Call_Record__c c : trigger.old)
	{
		setEventIds.add(c.Related_Event_ID__c);
	}
	
	if(!setEventIds.IsEmpty())
	{
		list<Event> liEvents = [select id from Event where id in :setEventIds];
		
		delete liEvents;
	} 
}