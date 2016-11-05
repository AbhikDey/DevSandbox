global class User_MaintainCategory implements Database.Batchable<SObject>,Schedulable {
    global String soql;
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
    //string sId = '005j000000CPDsT';
    if(!test.IsRunningTest())
    soql = 'SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Label  FROM PermissionSetAssignment WHERE Assignee.IsActive = true and PermissionSet.isOwnedByProfile = false';
    /*
    if(test.IsRunningTest()==true) {

           //soql = soql + ' and Assignee.UserName like \'testpermissionsetuser%\' limit 200';
            
            soql = soql + ' and Assignee.UserName like \'testpermissionsetuser%\'';
            
            //soql = 'SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Label  FROM PermissionSetAssignment WHERE Assignee.UserName like \'testpermissionsetuser%\'';

        }*/
    system.debug('soql-' + soql);
    //String soql = 'SELECT Id FROM User WHERE Id = :sId AND isActive = true ORDER BY Name DESC';
    return Database.getQueryLocator(soql);
    
    }//Database.QueryLocator start

global void execute(SchedulableContext sc) {
  User_MaintainCategory umc = new User_MaintainCategory();
  database.executebatch(umc);
}



global void execute(Database.BatchableContext BC, List<PermissionSetAssignment> ActiveuserPermissionslist) {

    Set<Id> UserIds = new Set<Id>();
    Map<Id, List<String>> PermMap = new Map<Id, List<String>>();
    List<User> userList = new List<User>();
    List<User> userUpdate = new List<User>();
    List<UserCategorySettings__c> ucrList = UserCategorySettings__c.getall().values();    
    system.debug('ucrList-' + ucrList);
    //Loop thru the List to get UserIds & PermissionMap
    for( PermissionSetAssignment psa : ActiveuserPermissionslist)
    {
        UserIds.add(psa.AssigneeId);
        
        If(PermMap.containsKey(psa.AssigneeId)){
            PermMap.get(psa.AssigneeId).add(psa.PermissionSet.Label);
        } else {
            List<String> s = new List<String>();
            s.add(psa.PermissionSet.Label);
            PermMap.put(psa.AssigneeId,s);
        }
        
    }
    system.debug('UserIds-' + UserIds);
    //To get User List
    userList = [SELECT Id, User_Category__c FROM User WHERE IsActive=true and Id in :UserIds];
    Map<Id, User> userMap = new Map<Id, User>(userList);
    
    for(Id uid : PermMap.keySet()){
        for(String p : PermMap.get(uid)){
            
          for(UserCategorySettings__c ucr : ucrList){
            //Check permissionset in Custom Settings
            if(p == ucr.PermissionSetLabel__c){
                if(userMap.get(uid).User_Category__c == null){
                    userMap.get(uid).User_Category__c = ucr.Category__c;
                } else if(userMap.get(uid).User_Category__c != null && !userMap.get(uid).User_Category__c.contains(ucr.Category__c)){
                    userMap.get(uid).User_Category__c = userMap.get(uid).User_Category__c + '; ' +ucr.Category__c;
                }
            }
            
            
          }
        }
    }
    
    for(User u : userMap.values()){
        if(u.User_Category__c != null){
            userUpdate.add(u);
            system.debug('User_Category__c - '+u.User_Category__c);
        }       
    }
    
    //Update Users
    if(userUpdate.size() > 0){      
        update userUpdate;
    }
        

}//void execute

global void finish(Database.BatchableContext info) {
        //do nothing...
    }

}//batchUserFunctionType