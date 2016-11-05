trigger QT_Task_AfterInsertUpdateDelete on Task (after delete, after insert, after update) 
{
	map<string, ExecutionPlanActivity__c> mapIdToBespokePlanObjective = new map<string, ExecutionPlanActivity__c>(); 
	// Get Prefix for BespokePlanObjective__c
	string strBPOPrefix = ExecutionPlanActivity__c.getsObjectType().getDescribe().getKeyPrefix();
	
	if(trigger.isDelete)
	{
		for(Task sTask : trigger.old)
		{
			if(sTask.WhatId != null && string.valueOf(sTask.WhatId).startsWith(strBPOPrefix))
			{
				mapIdToBespokePlanObjective.put(sTask.WhatId, null);
			}	
		}
	}
	else
	{
		for(Task sTask : trigger.new)
		{
			if(sTask.WhatId != null && string.valueOf(sTask.WhatId).startsWith(strBPOPrefix))
			{
				if(	trigger.isInsert || 
					(trigger.isUpdate && sTask.Status == 'Completed')
				)
				{
					mapIdToBespokePlanObjective.put(sTask.WhatId, null);
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
		for(Task sTask : trigger.old)
		{
			if(sTask.WhatId != null && mapIdToBespokePlanObjective.containskey(sTask.WhatId))
			{
				// If Already completed then deleted
				if(sTask.Status == 'Completed')
				{
					mapIdToBespokePlanObjective.get(sTask.WhatId).Completed__c -= 1;
				}
				else
				{
					mapIdToBespokePlanObjective.get(sTask.WhatId).Scheduled__c -= 1;
				}
			}
		}
	}
	else
	{
		for(Task sTask : trigger.new)
		{
			if(sTask.WhatId != null && mapIdToBespokePlanObjective.containskey(sTask.WhatId))
			{
				if(trigger.isInsert)
				{
					mapIdToBespokePlanObjective.get(sTask.WhatId).Scheduled__c += 1;
				}
				else if(trigger.isUpdate)
				{
					mapIdToBespokePlanObjective.get(sTask.WhatId).Scheduled__c -= 1;
					mapIdToBespokePlanObjective.get(sTask.WhatId).Completed__c += 1;
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
		for(Task sTask : trigger.old)
		{
			if(sTask.WhatId != null && mapBPOIdToError.containskey(sTask.WhatId))
			{
				sTask.addError('Error Updating Execution Plan Objectives:' + mapBPOIdToError.get(sTask.WhatId));
			}
		}
	}
	else
	{
		for(Task sTask : trigger.new)
		{
			if(sTask.WhatId != null && mapBPOIdToError.containskey(sTask.WhatId))
			{
				sTask.addError('Error Updating Execution Plan Objectives:' + mapBPOIdToError.get(sTask.WhatId));
			}
		}
	}
}