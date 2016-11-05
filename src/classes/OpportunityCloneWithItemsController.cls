public class OpportunityCloneWithItemsController {

    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
     // add the instance for the variables being passed by id on the url
    private Opportunity op {get;set;}
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}
    // initialize the controller
    public OpportunityCloneWithItemsController(ApexPages.StandardController controller) {
        //initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        op = (Opportunity)controller.getRecord();
    }
    // method called from the VF's action attribute to clone the op
    public PageReference cloneWithItems() {
         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         Opportunity newOP;
         try 
         {
                 //copy the Opportunity - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
                 op = [select ID, RecordTypeId, AccountId, CloseDate, Name, StageName,Status__c,PriorityIS__c,Description,OwnerId  from Opportunity where id = :op.id];
                 newOP = op.clone(false);
             	 newOP.StageName = 'Prospecting';
             	 newOP.Name = newOP.Name+' (Clone)';
                 if(newOP != null)
                 insert newOP;
                 // set the id of the new op created for testing
                 newRecordId = newOP.id;
                 // copy over the PRODUCTS - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
                 List<OpportunityLineItem> oppr = new List<OpportunityLineItem>();
                 for (OpportunityLineItem ol : [Select p.Id, p.Equipment__c, p.OpportunityId, p.Quantity,p.UnitPrice,p.PriceBookEntryId,p.Product2Id From OpportunityLineItem p where OpportunityId = :op.id]) {
                     OpportunityLineItem newOL = ol.clone(false);
                     newOL.OpportunityId = newOP.id;
                     oppr.add(newOL);
                 }
                 if(oppr.size()>0)
                 insert oppr;
             //copy over the STAKEHOLDERS - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
             List<Opportunity_Contact__c> opsh = new List<Opportunity_Contact__c>();
             for (Opportunity_Contact__c os : [SELECT Contact__c,Id,RecordTypeId,Level_Of_Advocacy__c,Level_Of_Influence__c,Mode__c,Name,Opportunity__c,Role__c,Stakeholder_Interests__c,Stakeholder_Name__c FROM Opportunity_Contact__c where Opportunity__c = :op.id]) {
                  Opportunity_Contact__c newOSH = os.clone(false);
                  newOSH.Opportunity__c = newOP.id;
                  opsh.add(newOSH);
             }
             if(opsh.size()>0)
             insert opsh;
             //copy over the TASKS
             List<Task> optsk = new List<Task>();
             for (Task ot : [SELECT AccountId,ActivityDate,Description,Id,OwnerId,Owner_Name__c,RecordTypeId,Status,Subject,TaskSubtype,WhatId,WhoId,Priority,CallDisposition,CallDurationInSeconds,Caller_Name__c,Caller_Phone__c,CallObject,CallType,Call_in_Date__c FROM Task where WhatId = :op.id]) {
                  Task newtask = ot.clone(false);
                  newtask.WhatId = newOP.id;
                  optsk.add(newtask);
             }
             if(optsk.size()>0)
             insert optsk;
             
              //copy over the EVENTS
             List<Event> opev = new List<Event>();
             for (Event oe : [SELECT AccountId,ActivityDate,Description,Id,OwnerId,Owner_Name__c,RecordTypeId,Status__c,Subject,WhatId,WhoId,EndDateTime,StartDateTime,Location,IsAllDayEvent FROM Event where WhatId = :op.id]) {
                  Event newevent = oe.clone(false);
                  newevent.WhatId = newOP.id;
                  opev.add(newevent);
             }
             if(opev.size()>0)
             insert opev;

             //copy over the NOTES
          /*   Map<Id,List<ContentNote>> noteMap = new Map<Id,List<ContentNote>>();
             List<ContentNote> Cnote = new list<ContentNote>();
             List<Id> docIds = new List<Id>();
             List<ContentDocumentLink> Cdoc = new list<ContentDocumentLink>();
             Map<Id,Id> docEntyMap = new Map<Id,Id>();
             Map<Id,Id> ContMap = new Map<Id,Id>();
             Map<Id,ContentDocumentLink> newdocMap = new Map<Id,ContentDocumentLink>();
				
              for(ContentDocumentLink links : [SELECT Id,LinkedEntityId,ContentDocumentId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityID = :op.id]){
                  docIds.add(links.ContentDocumentId);
                  newdocMap.put(links.Id, links);
                  docEntyMap.put(links.ContentDocumentId,links.LinkedEntityId);
                  
                   
                  List<ContentNote> notes = noteMap.get(links.LinkedEntityId);
                     if(notes == null){
                         notes = new List<ContentNote>();
                         ContentNote c1 = new ContentNote();
                         c1.LinkedEntityID = links.LinkedEntityId;
                         c1.
                         notes.add(links.ContentDocumentId);
                         noteMap.put(links.LinkedEntityID, notes);
                     }
                     else{
                         notes.add(links.ContentDocumentId);
                     } 
                 }
             	if(docIds.size() > 0){
                 for(ContentNote cn : [SELECT Id, Content, Title from ContentNote where Id in :docIds])
                     {
                       	ContentNote c1 = new ContentNote();
                         system.debug('@@connote ' + cn);
                         c1 = cn.clone(false);
                         system.debug('@@afterclone ' + c1);
                        //c1.Title = 'test1';
                      //  Blob k = EncodingUtil.base64Decode(c1.Content);
						//String body = c1.Content;
						//c1.Content = Blob.valueOf(body.escapeHTML4());
						 c1.Content = k;
                         insert c1;
                         system.debug('@@afterinsert ' + c1);
                        // ContMap.put(cn.id, c1.Id);
                     }
             }*/
           /*  if(newdocMap.size() > 0){
                 for(Id docId: newdocMap.keySet()){
                     ContentDocumentLink cd1 = new ContentDocumentLink();
                     cd1 = newdocMap.get(docId).clone(false);
                     cd1.LinkedEntityId = newOP.id;
                     cd1.ContentDocumentId = ContMap.get(newdocMap.get(docId).ContentDocumentId);
                     Cdoc.add(cd1);
                 }
             	
             }
             if(Cdoc.size()>0)
             insert Cdoc;*/
        /*     
             for(ContentNote cn : noteMap.get(op.Id)){
                 ContentNote cnn = cn.clone(false);
                  cnn.LinkedEntityID = newOP.id;
                  Cnote.add(cnn);
             }
             if(Cnote.size()>0)
             insert Cnote;*/
      //do something with your note records
                 }
		 catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
       // return new PageReference('/'+newOP.id+'/e?retURL=%2F'+newOP.id);
       return new PageReference('/'+newOP.id);
    }  
}