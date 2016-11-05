public class cloneRedirectExtension {
    
    private ApexPages.StandardController controller {get; set;}
    private Event evt {get;set;}
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}

    public cloneRedirectExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        evt = (Event)controller.getRecord();
    }
    
    public PageReference whereTo(){
        
        // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
        Event newEvt;
        
        try {
              //ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
             //evt = [select Id, RecordTypeId, Subject,StartDateTime, EndDateTime, OwnerId, WhatId from Event where id = :evt.id];
             evt = [SELECT RecordTypeId, Subject,Assignment_Status__c,Caller_Name__c,Caller_Phone__c,Call_in_Date__c,Comments__c,EndDateTime,
                OwnerId,Primary_Case_Will_Use__c,Primary_Diagnosis__c,Secondary_Case_Will_Use__c,Secondary_Diagnosis__c,
                StartDateTime,WhatId,WhoId FROM Event where id = :evt.id];
             
             if(evt.Subject != null)
             {
                evt.Subject = 'Clone Record ' + evt.Subject;
             }
             else
             {
                evt.Subject = 'Clone Record ';
             }
             newEvt = evt.clone(false);
             
             insert newEvt;  
             
             // set the id of the new po created for testing
               newRecordId = newEvt.id;         

         } catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
         
       return new PageReference('/'+newEvt.id);   
    }
}