trigger QT_CoachingSession on Coaching_Session__c (before insert, before update) 
{
	for (Coaching_Session__c cs : Trigger.new)
	{
		if(cs.Sales_Rep_Name__c != null)
		{
			cs.OwnerId = cs.Sales_Rep_Name__c;
		}
	}
}