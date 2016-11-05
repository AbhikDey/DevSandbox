public with sharing class SJM_DBSProcedureTracker {
    // Private variables
    private static string RECORD_TYPE = 'DBS Case';
    private ApexPages.StandardController stdController;
    private ID procedureId {get; set;}
    
    // Public Variables
    public ID accountId {get; set;}
    //public ID contactId {get; set;}
    public ID dbsrectypeid {get; set;}
    public Procedure__c currentProcedure {get; set;} 
    public Procedure_Item__c currentProcedureItems {get; set;} 
    public String procedureDate {get; set;}
    public ID eventId {get; set;}
    
    
    private Procedure_Tracker_Settings__c pSettings {
        get{
            if(pSettings == null){
                pSettings = Procedure_Tracker_Settings__c.getInstance();                
            }
            return pSettings;
        }
        set;
    }
    
    public Map<String, String> requiredFieldsMap{
        get{
            if(requiredFieldsMap == null){
                requiredFieldsMap = new Map<String, String>();
            }
            Map<String, Schema.SObjectField> allFields = Schema.SObjectType.Procedure__c.fields.getMap() ;
            for( String fsName : allFields.keySet() )
            {
                requiredFieldsMap.put(fsName, '');
            }
            LIST<String> requireFieldsList = pSettings.Require_Fields__c.split(',');
            for(String f : requireFieldsList){
                requiredFieldsMap.put(f.toLowerCase().trim(), 'required');
            }
            //System.debug('AA:requiredFieldsMap' + requiredFieldsMap);
            return requiredFieldsMap;
        }
        set;
    }
    
    public SJM_DBSProcedureTracker( ApexPages.StandardController sc )
    {
        
        this.stdController = sc;
        procedureId = ApexPages.currentPage().getParameters().get('id');
        //system.debug('@@ procedureId' + procedureId);
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        //system.debug('@@ accountId' + accountId);
        dbsrectypeid = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get(RECORD_TYPE).getRecordTypeId();
        String accountFieldId = pSettings.Procedure_Account_Field_Id__c;
        if(ApexPages.currentPage().getParameters().get(accountFieldId) != null){
            accountId = ApexPages.currentPage().getParameters().get(accountFieldId);
        }
        
        procedureDate = null;
        if(currentProcedure != null || procedureId != null){
            currentProcedure = [SELECT  Id, 
                                Account__c,
                                Rep__c,
                                Procedure_Physician__c,
                                Procedure_Date__c,
                                DBS_Implant_Duration_Time__c,
                                DBS_Travel_Time__c,
                                DBS_Wait_Time__c,
                                DBSG_Intervention_Type__c,
                                DBSG_Indication__c,
                                DBSG_Activity_Type__c,
                                DBSG_Follow_up_Type__c,
                                DBS_Account_Search__c,
                                DBSG_Target_Area__c,
                                DBSG_Target_Area_2__c
                                FROM Procedure__c WHERE id = :procedureId];
            accountId = currentProcedure.Account__c;
            //contactId = currentProcedure.Procedure_Physician__c;
            currentProcedureItems = [SELECT  Id, 
                                    Name, 
                                    Procedure_Item__c,
                                    Procedure__c,
                                    DBSGImplanted_Generator__c,
                                    DBSGPocket_Adapter__c
                                    FROM Procedure_Item__c
                                    WHERE Procedure__c = :procedureId];
            
            if(currentProcedure.Procedure_Date__c != null){
                procedureDate = currentProcedure.Procedure_Date__c.format();
            }
            //system.debug('@@@@@@ accountId' + accountId);
        }else{
            //system.debug('@@@@@@ test');
            currentProcedure = new Procedure__c(Account__c = accountId, 
                                                Rep__c = UserInfo.getUserId() 
                                               );   
        }
        
        eventId = ApexPages.currentPage().getParameters().get('eventId');
        if(eventId != null){
            procedureDate = [SELECT StartDateTime FROM Event WHERE id =: eventId ].StartDateTime.date().format();
            
        } 
        
    }
    
   /*public List<selectOption> getcontacts() {
       //system.debug('@@accountId ' + currentProcedure.Account__c);
       
        List<selectOption> options = new List<selectOption>();
         for (Affiliation__c cont : [SELECT Account__c,Contact_Name__c,Contact__c,Id,Name,Role__c FROM Affiliation__c WHERE Account__c = :currentProcedure.Account__c and contact__r.Recordtype.name = 'Physician/Practitioner']) 
         { 
             if(cont != null)
             {
                 options.add(new selectOption(cont.Contact__c, cont.Contact_Name__c)); 
             }
         }
         
         return options;
    }*/
    
    
    public List<selectOption> getevents() {
    string s;
    List<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' and (DeveloperName = 'DBS_Procedure_Scheduler')];
    Set<Id> rid = new Set<Id>();
    for(RecordType r : rt)
        {
            rid.add(r.id); 
        }
      
       Date predate = Date.Today().addDays(-90);

        List<selectOption> evtoptions = new List<selectOption>();
         for (Event evt : [SELECT Id,StartDateTime,Subject,OwnerId,Owner.Name,Activity_Type__c,Status__c,AccountId from Event WHERE WhatId = :currentProcedure.Account__c and RecordTypeId =: rid and Status__c!= 'Cancelled' and DAY_ONLY(StartDateTime) <= TODAY and DAY_ONLY(StartDateTime) >=:predate limit 140]) 
         { 
             system.debug('@@evtlist ' + evt);
             if(evt != null)
            {
                 if(evt.Subject != null ){   
                    s = string.valueOf(evt.Owner.Name + ' - ' + evt.StartDateTime.format() + ' - ' + evt.Activity_Type__c + ' - ' + evt.Subject);
                  }
                  else
                  {
                      s = string.valueOf(evt.Owner.Name + ' - ' + evt.StartDateTime.format() + ' - ' + evt.Activity_Type__c);
                  }
                 
                 evtoptions.add(new selectOption(evt.Id, s)); 
                 s = '';
             }
         }
        
         return evtoptions;
    }
    
    
    public Boolean getIsS1(){
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        
        return String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
            ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
            (String.isNotBlank(retUrl) && retURL.contains('projectone'));
    }    
}