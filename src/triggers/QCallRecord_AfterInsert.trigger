/**
*       Insert event when we insert a call
        @actor : David Browaeys
*/
trigger QCallRecord_AfterInsert on Call_Record__c (after insert, before update) 
{
    if(QStaticTracker.m_bCallUpdateTriggerFired == null)
        QStaticTracker.m_bCallUpdateTriggerFired = false;
    if(QStaticTracker.m_bCallUpdateTriggerFired)
        return ;
        
    /******************/    
    set<id> setAccountIds = new set<id>();
    set<id> setContactIds = new set<id>();
    map<string,Event> theseEvents = new map<string,Event>();
    set<id> theCalls = new set<id>();
    map<string,Call_Record__c> mapNextCallToInsert = new map<string,Call_Record__c>();
    map<string, set<string>> mapFacilityPerPractitioner = new map<string, set<string>>();
    // Update Execute Plan Counter
    map<string, ExecutionPlanActivity__c> mapIdToBespokePlanObjective = new map<string, ExecutionPlanActivity__c>();
    
    for(Call_Record__c c : trigger.new)
    {
        if(c.Facility_Practitioner__c != null)
        {
            setAccountIds.add(c.Facility_Practitioner__c);
            theCalls.add(c.Id);
        }
        if(c.Contact__c != null)
        {
            setContactIds.add(c.Contact__c);
        }
        
        if( c.Execution_Plan_Objective__c != null && 
            (
                trigger.isInsert || 
                (trigger.isUpdate && c.Call_Status__c == 'Completed')
            )
        )
        {
            system.debug('************');
            
            mapIdToBespokePlanObjective.put(c.Execution_Plan_Objective__c, null);
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Load ExecutionPlanActivity__c
    for(ExecutionPlanActivity__c sBPO : [select     id, 
                                                    Scheduled__c, 
                                                    Completed__c 
                                        from        ExecutionPlanActivity__c 
                                        where       id in : mapIdToBespokePlanObjective.keyset()])
    {
        mapIdToBespokePlanObjective.put(sBPO.id, sBPO);
    }
    
    for(Call_Record__c sCallRecord : trigger.new)
    {
        system.debug('mapIdToBespokePlanObjective.get(sCallRecord.Execution_Plan_Objective__c):' + mapIdToBespokePlanObjective.get(sCallRecord.Execution_Plan_Objective__c));
        
        if(sCallRecord.Execution_Plan_Objective__c != null && mapIdToBespokePlanObjective.containskey(sCallRecord.Execution_Plan_Objective__c))
        {
            if(trigger.isInsert)
            {
                mapIdToBespokePlanObjective.get(sCallRecord.Execution_Plan_Objective__c).Scheduled__c += 1;
            }
            else if(trigger.isUpdate)
            {
                mapIdToBespokePlanObjective.get(sCallRecord.Execution_Plan_Objective__c).Scheduled__c -= 1;
                mapIdToBespokePlanObjective.get(sCallRecord.Execution_Plan_Objective__c).Completed__c += 1;
            }
        }
    }
    
    // Move Map value to List, So we can track error. If any on update. 
    list<ExecutionPlanActivity__c>  liBespokePlanObjective  = mapIdToBespokePlanObjective.values();
    map<string, string>             mapBPOIdToError         = new map<string, string>(); 
    
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
    
    for(Call_Record__c sCallRecord : trigger.new)
    {
        if(sCallRecord.Execution_Plan_Objective__c != null && mapBPOIdToError.containskey(sCallRecord.Execution_Plan_Objective__c))
        {
            sCallRecord.addError('Error Updating Execution Plan Objectives:' + mapBPOIdToError.get(sCallRecord.Execution_Plan_Objective__c));
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    map<id, Account > mapAccountDetails= new map<id,Account>([  select  id, Name, RecordType.DeveloperName 
                                                                from    Account 
                                                                where   id in :setAccountIds
                                                            ]);
                                                            
    //Added by Brahma
    Id phyRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician/Practitioner').getRecordTypeId();
    map<id, Contact > mapContactDetails = new map<id, Contact>();
    //Commented by Brahma for Consolidation
    //for(Contact c : [select id, Name, AccountId, Account.IsPersonAccount from Contact where   id in :setContactIds])
    for(Contact c : [select id, Name, AccountId, RecordTypeId from Contact where   id in :setContactIds])
    {
        mapContactDetails.put(c.Id, c); 
        //Commented by Brahma for Consolidation
        //if(!c.Account.isPersonAccount)
        if(c.RecordTypeId != phyRecTypeId)
        {
            mapFacilityPerPractitioner.put(c.Id, new set<string>{c.AccountId});
        }
    }
                                                                    
    for(Affiliation__c r360 : [select id, Contact__c, Account__c from Affiliation__c where Contact__c in :setContactIds])
    {
        if(mapFacilityPerPractitioner.get(r360.Contact__c) == null)
        {
            mapFacilityPerPractitioner.put(r360.Contact__c, new set<string>());
        }
        mapFacilityPerPractitioner.get(r360.Contact__c).add(r360.Account__c);
    }
    
    QStaticTracker.m_bEventInsertTriggerFired = true;
    for(Call_Record__c thisCallsheet : trigger.new)
    {
        if(thisCallsheet.Facility_Practitioner__c != null && 
            mapAccountDetails.get(thisCallsheet.Facility_Practitioner__c) != null && 
            thisCallsheet.Contact__c != null)
        {
            
            if(mapAccountDetails.get(thisCallsheet.Facility_Practitioner__c).RecordType.DeveloperName != 'SJM_Customer'
                && mapAccountDetails.get(thisCallsheet.Facility_Practitioner__c).RecordType.DeveloperName != 'Prospective'
                && mapAccountDetails.get(thisCallsheet.Facility_Practitioner__c).RecordType.DeveloperName != 'Private_Practice'
                && mapAccountDetails.get(thisCallsheet.Facility_Practitioner__c).RecordType.DeveloperName != 'Purchasing_Group')
            {
                thisCallsheet.addError('The Facility field must only be populated with a SJM Customer, Prospective, Private Practice or Purchasing Group');
                continue;
            }
            
            if(trigger.IsUpdate && thisCallsheet.Contact__c != trigger.oldMap.get(thisCallsheet.Id).Contact__c)
            {
                thisCallsheet.addError('You are not allowed to update the Practitioner. Please create a new call.');
                continue;
            }
            
            if( thisCallsheet.Facility_Practitioner__c == null ||
                mapFacilityPerPractitioner.get(thisCallsheet.Contact__c) == null ||
                !mapFacilityPerPractitioner.get(thisCallsheet.Contact__c).contains(thisCallsheet.Facility_Practitioner__c) )
            {
                thisCallsheet.addError('You must select a "Facility" related to the "Practitioner."');
                continue;
            }
        
            if(trigger.IsInsert)
            {
                Event thisEvent = new Event();
                if(thisCallsheet.Contact__c != null)
                {
                    thisEvent.WhoId = thisCallsheet.Contact__c;
                }
                
                thisEvent.WhatId = thisCallsheet.Facility_Practitioner__c;
                if(thisCallsheet.Contact__c != null)
                    thisEvent.Subject = 'Call with ' + mapContactDetails.get(thisCallsheet.Contact__c).Name;
                else
                    thisEvent.Subject = 'Call with ' + mapAccountDetails.get(thisCallsheet.Facility_Practitioner__c).Name;
                thisEvent.DurationInMinutes = 30;
                thisEvent.ActivityDateTime = thisCallsheet.Date_Time_of_Call__c;
                thisEvent.Related_Call_ID__c = thisCallsheet.Id;
                thisEvent.Location = thisCallsheet.Location_of_Call__c;
                theseEvents.put(thisCallsheet.Id,thisEvent); 
                
                if(thisCallsheet.Follow_Up_Due_Date_Time__c != null)
                {
                    Call_Record__c sNextCall                = new Call_Record__c();
                    sNextCall.RecordTypeId                  = thisCallsheet.RecordTypeId;
                    sNextCall.Call_Objectives__c            = thisCallsheet.Next_Call_Objective__c;
                    sNextCall.Date_Time_of_Call__c          = thisCallsheet.Follow_Up_Due_Date_Time__c;
                    sNextCall.Contact__c                    = thisCallsheet.Contact__c;
                    sNextCall.Facility_Practitioner__c      = thisCallsheet.Facility_Practitioner__c;
                    sNextCall.Division__c                   = thisCallsheet.Division__c;
                    sNextCall.Call_Status__c                = 'Planning';
                    
                    mapNextCallToInsert.put(thisCallsheet.Id, sNextCall);   
                }
            }
            
        }
    }
    try
    {
        if(!theseEvents.isEmpty()){insert theseEvents.values();}
        QStaticTracker.m_bEventInsertTriggerFired = false;
        
        if(!mapNextCallToInsert.IsEmpty()) insert mapNextCallToInsert.values();
        
    }catch(Exception  e)
    {
        System.debug(''+e.getMessage());
    }
    
    if(trigger.isInsert)
    {
        //////////////////associate call with its next call
        QStaticTracker.m_bCallUpdateTriggerFired = true;    //lock call update trigger
        list<Call_Record__c> liCallToUpdate = new list<Call_Record__c>();
        list<Event> liEventToUpdate = new list<Event>();
        for(Call_Record__c c : trigger.new)
        {   
            Call_Record__c sCall = new Call_Record__c(Id=c.Id);
            boolean bUpdate = false;
            if(theseEvents.get(c.id) != null)
            {
                sCall.Related_Event_ID__c = theseEvents.get(c.id).Id;
                bUpdate = true;
            }
            if(mapNextCallToInsert.get(c.Id) != null)
            {
                sCall.Next_Call_Record_ID__c = mapNextCallToInsert.get(sCall.Id).Id;
                bUpdate = true;
            }           
            System.debug('>>>>>>>>>>>>>>>>>>>>>>'+sCall);
            if(bUpdate) liCallToUpdate.add(sCall);
        }
        
        if(!liCallToUpdate.IsEmpty()){ update liCallToUpdate;}
        
        QStaticTracker.m_bCallUpdateTriggerFired = false;   //unlock call update trigger
    }
}