trigger QT_CallRecord_AfterDelete on Call_Record__c (after delete) 
{
	// This Trigger add or minus counter on ExecutionPlanActivity__c
	
	map<string, ExecutionPlanActivity__c> mapIdToBespokePlanObjective = new map<string, ExecutionPlanActivity__c>(); 
	
	if(QStaticTracker.m_bCallAfterInsertUpdateDeleteTriggerFired == null)
		QStaticTracker.m_bCallAfterInsertUpdateDeleteTriggerFired = false;
	
	if(QStaticTracker.m_bCallAfterInsertUpdateDeleteTriggerFired)
	{
		return;
	}
	else
	{
		QStaticTracker.m_bCallAfterInsertUpdateDeleteTriggerFired = true;
	}
	
	for(Call_Record__c sCallRecord : trigger.old)
	{
		system.debug('sCallRecord:' + sCallRecord);
		if(sCallRecord.Execution_Plan_Objective__c != null)
		{
			mapIdToBespokePlanObjective.put(sCallRecord.Execution_Plan_Objective__c, null);
		}	
	}
	system.debug('mapIdToBespokePlanObjective:' + mapIdToBespokePlanObjective);
	
	// Load BespokePlanObjective__c
	for(ExecutionPlanActivity__c sBPO : [select 	id, 
													Scheduled__c, 
													Completed__c 
										from 		ExecutionPlanActivity__c 
										where 		id in : mapIdToBespokePlanObjective.keyset()])
	{
		mapIdToBespokePlanObjective.put(sBPO.id, sBPO);
	}
	
	// Lets Update BespokePlanObjective__c
	for(Call_Record__c sCallRecord : trigger.old)
	{
		if(sCallRecord.Execution_Plan_Objective__c != null && mapIdToBespokePlanObjective.containskey(sCallRecord.Execution_Plan_Objective__c))
		{
			// If Already completed then deleted
			if(sCallRecord.Call_Status__c == 'Completed')
			{
				mapIdToBespokePlanObjective.get(sCallRecord.Execution_Plan_Objective__c).Completed__c -= 1;
			}
			else
			{
				mapIdToBespokePlanObjective.get(sCallRecord.Execution_Plan_Objective__c).Scheduled__c -= 1;
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
	
	for(Call_Record__c sCallRecord : trigger.old)
	{
		if(sCallRecord.Execution_Plan_Objective__c != null && mapBPOIdToError.containskey(sCallRecord.Execution_Plan_Objective__c))
		{
			sCallRecord.addError('Error Updating Execution Plan Objectives:' + mapBPOIdToError.get(sCallRecord.Execution_Plan_Objective__c));
		}	
	}
}