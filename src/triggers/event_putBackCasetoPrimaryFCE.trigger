/*
    Author : Sunil Damle
*/
trigger event_putBackCasetoPrimaryFCE on Event (Before update) {

Map<ID,Schema.RecordTypeInfo> recordTypeMap = Event.sObjectType.getDescribe().getRecordTypeInfosById();
Map<Id,Account> accMap = new Map<Id,Account>();
List<Id> WhatIds = new List<Id>();

for(Event evt:Trigger.new){
    WhatIds.add(evt.WhatId);
}

	//Move SOQL query outside of the for statement.
	if(WhatIds.Size() > 0)
	{    
	    accMap = new Map<Id, Account>([select Id, USD_AF_Region__c from Account WHERE Id=:WhatIds]);
	}

    for(Event prEvent : trigger.new)
    {
        //get the Record Type ID Map
        
        if(prEvent.Assignment_Status__c == 'Uncovered')
        {                              
               if(Trigger.oldMap.get(prEvent.Id).Assignment_Status__c == 'Assigned')
               {
                  
                try {
                    String i = accMap.get(prEvent.WhatId).USD_AF_Region__c;
                }
                catch (System.NullPointerException e) {
                    return;
                }
              

                  
                   if(recordTypeMap.get(prEvent.recordTypeID).getName().containsIgnoreCase('Procedure Scheduler') && accMap.get(prEvent.WhatId).USD_AF_Region__c != NULL && accMap.get(prEvent.WhatId).USD_AF_Region__c.trim() != ''){
                        List<Regional_Admins__c> ra = [select Id, Name, Primary_FCE_REP__c, Primary_FCE_REP__r.IsActive, Backup1__c, Backup1__r.IsActive, Backup2__c, Backup2__r.IsActive, Backup3__c, Backup3__r.IsActive from Regional_Admins__c WHERE Name = :accMap.get(prEvent.WhatId).USD_AF_Region__c]; 
                      
                       if(ra.size() > 0 && ra[0].Primary_FCE_REP__r.IsActive == true){    
                            prEvent.OwnerId = ra[0].Primary_FCE_REP__c; 
                        } else if(ra.size() > 0 && ra[0].Backup1__r.IsActive == true){
                            prEvent.OwnerId = ra[0].Backup1__c; 
                        } else if(ra.size() > 0 && ra[0].Backup2__r.IsActive == true){
                            prEvent.OwnerId = ra[0].Backup2__c;
                        } else if(ra.size() > 0 && ra[0].Backup3__r.IsActive == true){
                            prEvent.OwnerId = ra[0].Backup3__c;
                        }                    
                    }
                }
              
                   
              else{
                   // system.debug('Previous status wasnt assigned');
                   return;
               }
            }                                               
        }//end of for(prEvent) loop    
}