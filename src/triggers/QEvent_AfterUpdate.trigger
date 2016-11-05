/**
*		Update related call when we change the time or the owner of a event
		@actor : David Browaeys
*/
trigger QEvent_AfterUpdate on Event (after update) 
{
	set<id> setCallIds = new set<id>();
	
	for(Event e : trigger.new)
	{	//only if related call is not null
		if(e.Related_Call_ID__c != null && e.Related_Call_ID__c !='')
		{
			setCallIds.add(e.Related_Call_ID__c);
		}
	}
	
	if(!setCallIds.isEmpty())
	{
		//load related call_record
		map<id, Call_Record__c> mapCalls = new map<id, Call_Record__c>([	select	id, Name, Date_Time_of_Call__c, OwnerId
																			from	Call_Record__c
																			where 	id in :setCallIds
																		]);
		// I want to update the calls only if they don't have the same time of their related event.																
		map<id,Call_Record__c> mapCallToUpdate = new map<id,Call_Record__c>();	
																		
		for(Event e : trigger.new)
		{
			Call_Record__c sCall = mapCalls.get(e.Related_Call_ID__c);
			
			boolean bToUpdate = false;
			
			if(sCall != null && e.ActivityDateTime != sCall.Date_Time_of_Call__c)			
			{
				sCall.Date_Time_of_Call__c = e.ActivityDateTime;
				bToUpdate = true;
			}
			
			if(sCall != null && e.OwnerId != sCall.OwnerId)
			{
				sCall.OwnerId = e.OwnerId;
				bToUpdate = true;
			}
			
			if(bToUpdate)			//add only if time or owner is not the same
				mapCallToUpdate.put(sCall.Id,sCall);
		}
		
		if(!mapCallToUpdate.values().IsEmpty()){ update mapCallToUpdate.values(); }
	}
}