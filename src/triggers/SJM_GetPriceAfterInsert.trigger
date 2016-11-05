trigger SJM_GetPriceAfterInsert on Procedure_Item__c (before insert, before update) {
    
    /******************/    
    map<Id,String> UniqueIdsMap = new map<Id,String>();
    map<Id,Procedure_Item__c> PI_Map = new map<Id,Procedure_Item__c>();
    map<String,Price_List__c> PL_Map = new map<String,Price_List__c>();
    list<Price_List__c> PList = new list<Price_List__c>();
    
    for(Procedure_Item__c pi : trigger.new)
    {
        UniqueIdsMap.put(pi.Id,pi.UniqueID__c.toLowerCase());
        PI_Map.put(pi.Id,pi);
        //system.debug(' PI UniqueIdsMap - '+pi.UniqueID__c);
    }
    
    if(UniqueIdsMap.size() > 0)
    {
        //PList = [Select Id, UniqueID__c, New_Device_Price__c, Resterilized_Device_Price__c from Price_List__c Where UniqueID__c in :UniqueIdsMap.values() and Active__c=true];
        PList = [Select Id, UniqueID__c, New_Device_Price__c, Resterilized_Device_Price__c from Price_List__c Where Active__c=true];
    }
    
    if(PList.size() > 0)
    {
        //Clear PL_Map
        PL_Map.clear();
        for(Price_List__c pl : PList){
        PL_Map.put(pl.UniqueID__c.toLowerCase(),pl);
        //system.debug('PL UniqueIdsMap - '+pl.UniqueID__c);
        }
    }
    //system.debug('PI_Map size - '+PI_Map.size());
    //system.debug('PList size - '+PList.size());
    //system.debug('PL_Map size - '+PL_Map.size());
    
    /*
    for(String s : PL_Map.keyset()){
        //system.debug('Key - '+s);
        //system.debug('PL Map - '+PL_Map.get(s));
        for(String v : UniqueIdsMap.values()){
            if(s == v){
                system.debug('Key Matched');
            } else {
                system.debug('Key Not Matched');
            }
        }
    }
    */
    
    for(Procedure_Item__c pi : trigger.new)
    {           
         if(PL_Map.containsKey(pi.UniqueID__c.toLowerCase()))
		 {
            String s = UniqueIdsMap.get(pi.Id);
            system.debug('UniqueID - '+UniqueIdsMap.get(pi.Id));
            //system.debug('PL Map - '+PL_Map.get(s));
            //system.debug('Resterilized - '+PL_Map.get(s).Resterilized_Device_Price__c);
            //system.debug('New Device - '+PL_Map.get(s).New_Device_Price__c); 
            try{           
	            if(PI_Map.get(pi.Id).Resterilized__c == 'Yes'){
	                pi.Unit_Price__c=PL_Map.get(s).Resterilized_Device_Price__c;
	            } else if(PI_Map.get(pi.Id).Resterilized__c == 'No'){
	                pi.Unit_Price__c=PL_Map.get(s).New_Device_Price__c;
	            } else
	            {
	                pi.Unit_Price__c=PL_Map.get(s).New_Device_Price__c;
	            }
            } catch (System.NullPointerException e) {
            	pi.Unit_Price__c = 0;
            }
            
        } else {
        	pi.Unit_Price__c = 0;
        }
    }
    
    //Clear Maps
    UniqueIdsMap.clear();
    PI_Map.clear();
    PL_Map.clear();    

}