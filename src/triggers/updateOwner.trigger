trigger updateOwner on Event (before insert) {

//Getting Record Types
Map<ID,Schema.RecordTypeInfo> rt_Map = Event.sObjectType.getDescribe().getRecordTypeInfosById();
//Map<ID,Event> EvtMap = new Map<ID,Event>();
List<Regional_Admins__c> raList = new List<Regional_Admins__c>();
Map<String,Regional_Admins__c> raMap = new Map<String,Regional_Admins__c>();
//Creating List for WhatIds
List<Id> WhatIds = new List<Id>();
Set<String> regionSet = new Set<String>();
Map<Id,String> regionMap = new Map<Id,String>();


Map<Id,Account> accMap = new Map<Id,Account>();

for(Event evt:Trigger.new){
    WhatIds.add(evt.WhatId);
    //EvtMap.put(evt.Id,evt);
}

if(WhatIds.Size() > 0)    
    accMap = new Map<Id, Account>([select Id, USD_AF_Region__c from Account WHERE Id=:WhatIds]);
        
for(Account a : accMap.values()){
	regionSet.add(a.USD_AF_Region__c);
	regionMap.put(a.Id,a.USD_AF_Region__c);
}

//Query Regional Admin Table
if(regionSet.size() > 0){
	raList = [select Id, Name, Primary_FCE_REP__c, Primary_FCE_REP__r.IsActive, Backup1__c, Backup1__r.IsActive, Backup2__c, Backup2__r.IsActive, Backup3__c, Backup3__r.IsActive from Regional_Admins__c WHERE Name = :regionSet];	
}

//Populating Regional Admin Map
if(raList.size() > 0){
	for(Regional_Admins__c ra : raList){
		raMap.put(ra.Name,ra);
	}	
}

//Get Profile Name 
List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];

for(Event evt:Trigger.new){    

    try {
        String i = accMap.get(evt.WhatId).USD_AF_Region__c;
        }
    catch (System.NullPointerException e) {
        return;
        }
    
    if(rt_map.get(evt.recordTypeID).getName().containsIgnoreCase('Procedure Scheduler') && !String.valueOf(evt.WhatId).startsWith('001')){
        evt.adderror('For this event you must select \"Account\" from the \'Related To\' list');
        return;
    }
    
    if(rt_map.get(evt.recordTypeID).getName().containsIgnoreCase('Procedure Scheduler') && accMap.get(evt.WhatId).USD_AF_Region__c != NULL && accMap.get(evt.WhatId).USD_AF_Region__c.trim() != ''){
        
        //Check if CS assigned this event manually to a Rep
        String userProfile = PROFILE[0].Name;
    
        if(evt.OwnerId != userinfo.getUserId() && (userProfile.containsIgnoreCase('SJM Customer Service') || userProfile.containsIgnoreCase('System Administrator')))
        {
            evt.Assignment_Status__c = 'Assigned';
            return;

        }
        else
        {
		  try {
	         if(raMap.size() > 0 && raMap.get(regionMap.get(evt.WhatId)).Primary_FCE_REP__r.IsActive == true){    
	            evt.OwnerId = raMap.get(regionMap.get(evt.WhatId)).Primary_FCE_REP__c; 
	        } else if(raMap.size() > 0 && raMap.get(regionMap.get(evt.WhatId)).Backup1__r.IsActive == true){
	            evt.OwnerId = raMap.get(regionMap.get(evt.WhatId)).Backup1__c; 
	        } else if(raMap.size() > 0 && raMap.get(regionMap.get(evt.WhatId)).Backup2__r.IsActive == true){
	            evt.OwnerId = raMap.get(regionMap.get(evt.WhatId)).Backup2__c;
	        } else if(raMap.size() > 0 && raMap.get(regionMap.get(evt.WhatId)).Backup3__r.IsActive == true){
	            evt.OwnerId = raMap.get(regionMap.get(evt.WhatId)).Backup3__c;
	        } 
		  } catch (System.NullPointerException e) {
		  	
		  }
        }
        
    }
    
}
}