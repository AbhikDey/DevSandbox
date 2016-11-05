Trigger Send_Email_Record_AssignedTo_Create on Event (after insert) {
    
   
        
    Set<Id> ownerIds = new Set<Id>();
    Set<Id> WhatIds = new Set<Id>();

    //Getting Record Types
    Map<ID,Schema.RecordTypeInfo> rt_Map = Event.sObjectType.getDescribe().getRecordTypeInfosById();

   
    for(Event evt: Trigger.New){
    
        
        ownerIds.add(evt.ownerId);
        WhatIds.add(evt.WhatId);
        
    }
    
    
    List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
    Map<Id,User> userMap = new Map<Id,User>([select Name, Email, Opt_In_for_Procedure_Scheduler_Emails__c from User where Id in :ownerIds]);
    Map<Id,Account> accMap = new Map<Id,Account>([select Id, Name from Account where Id in :WhatIds]);
    for(Event evt : Trigger.New)
    {
        if(userMap.containskey(evt.ownerId) && rt_map.get(evt.recordTypeID).getName().containsIgnoreCase('Procedure Scheduler') && userMap.get(evt.OwnerId).Opt_In_for_Procedure_Scheduler_Emails__c){
        User theUser = userMap.get(evt.ownerId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {theUser.Email};
        mail.setToAddresses(toAddresses);    // Set the TO addresses
        mail.setSubject('A Scheduled Procedure has been assigned to you');    


        String template = 'Hello {0}, \nA Scheduled Procedure has been assigned to you. Here are the details - \n\n';
        template+= 'Subject: {1}\n';
        template+= 'Scheduled Start: {2}\n';
        template+= 'Account: {4}\n';
        template+= 'For all procedure details, please click here: {3}' + evt.Id ;
        String duedate = '';
        if (evt.StartDateTime==null)
            duedate = '';
        else
            duedate = evt.StartDateTime.format();
        List<String> args = new List<String>();
        args.add(theUser.Name);
        args.add(evt.Subject);
        args.add(duedate);        
        args.add(evt.Event_URL__c);
        if(accMap.get(evt.WhatId) != null)         
        args.add(accMap.get(evt.WhatId).Name);


        String formattedHtml = String.format(template, args);

        mail.setPlainTextBody(formattedHtml);
        lstEmail.add(mail);
      
            Messaging.SendEmail(lstEmail);
    }
    }
    
    }