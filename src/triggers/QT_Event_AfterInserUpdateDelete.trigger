trigger QT_Event_AfterInserUpdateDelete on Event (after delete, after insert, after update) 
{
	map<string, ExecutionPlanActivity__c> mapIdToBespokePlanObjective = new map<string, ExecutionPlanActivity__c>(); 
	// Get Prefix for BespokePlanObjective__c
	string strBPOPrefix = ExecutionPlanActivity__c.getsObjectType().getDescribe().getKeyPrefix();
	
	if(trigger.isDelete)
	{
		for(Event sEvent : trigger.old)
		{
			if(sEvent.WhatId != null && string.valueOf(sEvent.WhatId).startsWith(strBPOPrefix))
			{
				mapIdToBespokePlanObjective.put(sEvent.WhatId, null);
			}	
		}
	}
	else
	{
		for(Event sEvent : trigger.new)
		{
			if(sEvent.WhatId != null && string.valueOf(sEvent.WhatId).startsWith(strBPOPrefix))
			{
				if(	trigger.isInsert || 
					(trigger.isUpdate && sEvent.Event_Completed__c == true)
				)
				{
					mapIdToBespokePlanObjective.put(sEvent.WhatId, null);
				}
			}
		}	
	}
	
	// Load BespokePlanObjective__c
	for(ExecutionPlanActivity__c sBPO : [select 	id, 
												Scheduled__c, 
												Completed__c 
										from 	ExecutionPlanActivity__c 
										where 	id in : mapIdToBespokePlanObjective.keyset()])
	{
		mapIdToBespokePlanObjective.put(sBPO.id, sBPO);
	}
	
	// Lets Update BespokePlanObjective__c
	if(trigger.isDelete)
	{
		for(Event sEvent : trigger.old)
		{
			if(sEvent.WhatId != null && mapIdToBespokePlanObjective.containskey(sEvent.WhatId))
			{
				// If Already completed then deleted
				if(sEvent.Event_Completed__c == true)
				{
					mapIdToBespokePlanObjective.get(sEvent.WhatId).Completed__c -= 1;
				}
				else
				{
					mapIdToBespokePlanObjective.get(sEvent.WhatId).Scheduled__c -= 1;
				}
			}
		}
	}
	else
	{
		for(Event sEvent : trigger.new)
		{
			if(sEvent.WhatId != null && mapIdToBespokePlanObjective.containskey(sEvent.WhatId))
			{
				if(trigger.isInsert)
				{
					mapIdToBespokePlanObjective.get(sEvent.WhatId).Scheduled__c += 1;
				}
				else if(trigger.isUpdate)
				{
					mapIdToBespokePlanObjective.get(sEvent.WhatId).Scheduled__c -= 1;
					mapIdToBespokePlanObjective.get(sEvent.WhatId).Completed__c += 1;
				}
			}
		}
	}
	
	// Move Map value to List, So we can track error. If any on update. 
	list<ExecutionPlanActivity__c> 	liBespokePlanObjective 	= mapIdToBespokePlanObjective.values();
	map<string, string>				mapBPOIdToError			= new map<string, string>(); 
	
	database.Saveresult[] arrSR = database.update(liBespokePlanObjective, false);
	
	for(integer i = 0 ; i < arrSR.size(); i++ )
    {
        if(!arrSR[i].isSuccess())
        {
        	string strError = '';
            for(Database.Error sError : arrSR[i].getErrors())
            {
                strError += sError.getMessage() + ' ';
            }
            
            system.debug('arrSR[i].getId():' + arrSR[i].getId() + ' strError:' + strError);
            
            mapBPOIdToError.put(liBespokePlanObjective[i].id, strError);
        }
    }
	
	if(trigger.isDelete)
	{
		for(Event sEvent : trigger.old)
		{
			if(sEvent.WhatId != null && mapBPOIdToError.containskey(sEvent.WhatId))
			{
				sEvent.addError('Error Updating Execution Plan Objectives:' + mapBPOIdToError.get(sEvent.WhatId));
			}
		}
	}
	else
	{
		for(Event sEvent : trigger.new)
		{
			if(sEvent.WhatId != null && mapBPOIdToError.containskey(sEvent.WhatId))
			{
				sEvent.addError('Error Updating Execution Plan Objectives:' + mapBPOIdToError.get(sEvent.WhatId));
			}
		}
	}
}