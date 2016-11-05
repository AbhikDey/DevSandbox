/**
 * @DateCreated: 08/30/2016
 * @Author: NS
 * @Jira: I5
 */
global class IS_AutoCreateOpptyJob implements Database.Batchable<SObject>, Schedulable
{
    global String query;
    list<EmailTemplate> lstEmailTemplates = new list<EmailTemplate>();
    RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName = 'SJM_Service_Plan_Sales'];
    public IS_AutoCreateOpptyJob()
    {
    }
    global void execute(System.SchedulableContext sc)
    {
        Database.executeBatch(this, 200 );
    }
    // Start Method
    global  Database.QueryLocator start(Database.BatchableContext BC)
    {
        query = 'Select Id,Account_Number__c,Warranty_End__c,Serial_Lot_Number__c, Oppty_Product_Model__c, Account_Name__r.SJM_ID__c,Account_Name__r.Id,Account_Name__r.Name,Account_Name__r.Service_Contract_Specialist__r.Id,Account_Name__c';
        query += ' from Equipment__c where RecordType.Name = \'SJM Capital\'';
        query += ' AND Warranty_Expired__c = true';
        query += ' AND Serial_Lot_Number__c != null';
        query += ' AND Warranty_End__c != null'; 
        query += ' AND Account_Name__r.SJM_ID__c != null Order by Account_Number__c asc';
      //  System.debug('@@queryresults ' + query) ;
        return Database.getQueryLocator(query);
    }
    // Execute Logic
        global void execute(Database.BatchableContext bc, List<Equipment__c> originalrecords){
            List<String> ModelNames = new List<String>();
            List<Equipment__c> listofEquip = new List<Equipment__c>();
            
            Map<string,PricebookEntry> productMap = new Map<string,PricebookEntry>();
            Map<Id,List<Equipment__c>> AccountMap = new Map<Id,List<Equipment__c>>();
            Map<Id, Equipment__c> equipcustprodMap = new Map<Id, Equipment__c>(originalrecords);       
            for(ID eid : equipcustprodMap.keyset()){
                ModelNames.add(equipcustprodMap.get(eid).Oppty_Product_Model__c);
            }
            try{
            
            if(ModelNames.size() > 0){
              //  System.debug('@@InsideModelNames'+ModelNames) ;
              List<PricebookEntry> pricebookent = [Select Id, ProductCode, UnitPrice, Pricebook2Id, Pricebook2.Name, Product2Id,Product2.ProductCode, Product2.Name from PricebookEntry];
                for(PricebookEntry pb : pricebookent ){
               // system.debug('priceb '+pb.Pricebook2.Name);
                }
               // System.debug('@@pricebookentry'+pricebookent ) ;
                for(PricebookEntry prod : [Select Id, ProductCode, UnitPrice, Pricebook2Id, Pricebook2.Name, Product2Id,Product2.ProductCode, Product2.Name from PricebookEntry Where ProductCode in :ModelNames ]){
                    ProductMap.put(prod.ProductCode, prod);
                }
              //  System.debug('@@ProductMap ' + ProductMap.size()) ;
            }
            for( Equipment__c eq : originalrecords){  
                if (AccountMap.get(eq.Account_Name__r.Id) == null){
                        AccountMap.put(eq.Account_Name__r.Id, new list<Equipment__c>{eq});
                  //  System.debug('@@ifaccountmap ') ;
                    }
                else
                {
                    AccountMap.get(eq.Account_Name__r.Id).add(eq);
                  //  System.debug('@@elseaccountMap' + eq) ;
                } 
            }
            if (AccountMap.size()>0) {
                
                for(id accntid :AccountMap.keySet()){
                    listofEquip = AccountMap.get(accntid);
                    string myDate = Datetime.now().format('yyyyMMdd');
                    opportunity op = new opportunity();
                    op.RecordTypeId = rt.id;
                    op.Name = 'A_'+myDate+'_'+listofEquip[0].Account_Number__c;
                    op.AccountId = accntid;
                    op.StageName = 'Prospecting';
                    op.CloseDate = listofEquip[0].Warranty_End__c;
                    if (listofEquip[0].Account_Name__r.Service_Contract_Specialist__r.Id != null)
                    {op.OwnerId=listofEquip[0].Account_Name__r.Service_Contract_Specialist__r.Id;}
                    else{op.OwnerId='005j000000DvbSQ';}
                    insert op;
                  //  System.debug('@@CreateOppty ' + op);
                    list<OpportunityLineItem> listOpptyItem = new list<OpportunityLineItem>();
                    boolean successEmail = false;
                    boolean failureEmail = false;
                    for(Equipment__c eq : listofEquip){                    
                 //   system.debug('ProductMap'+ProductMap);
                  //  system.debug('Equipmentopp'+eq.Oppty_Product_Model__c);
                        if(eq.Oppty_Product_Model__c != null)
                        {
                            OpportunityLineItem ol = new OpportunityLineItem();
                            ol.OpportunityId = op.Id;
                            ol.Equipment__c = eq.id;
                           if(ProductMap!=null && ProductMap.get(eq.Oppty_Product_Model__c) !=null){
                            ol.PricebookEntryId = ProductMap.get(eq.Oppty_Product_Model__c).id;
                          //  System.debug('@@PricebookEntryId ' + ol.PricebookEntryId) ;
                            ol.TotalPrice = ProductMap.get(eq.Oppty_Product_Model__c).UnitPrice;
                            }
                          //  System.debug('@@TotalPrice ' + ol.TotalPrice) ;
                            ol.Quantity = 1;
                            listOpptyItem.add(ol);
                           successEmail = true;
                        }
                        else
                        {
                            failureEmail = true;
                        }
                    }
                    insert listOpptyItem;
                  //  System.debug('@@CreateOpptylineitem ' + listOpptyItem) ;     
            ID whatID = op.Id; 
            User userid = [select id, Email from User where Id=:op.OwnerId];

			OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where Address = 'servicecontracts@sjm.com'];
    				
            lstEmailTemplates = [select Id,Name,DeveloperName from EmailTemplate where Name in ('ISOpptySuccess','ISOpptyFail')];
            if(successEmail == true){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(owea.size() > 0){
                        mail.setOrgWideEmailAddressId(owea[0].Id);
                    }	
         //   System.debug('SendEmailResultlese' + lstEmailTemplates) ;
            String[] toAddresses = new String[] {userid.Email}; 
            String[] ccAddresses = new String[] {'LFlowers@sjm.com'};
            if(lstEmailTemplates!=null && lstEmailTemplates.size()>0){
            mail.setTemplateId(lstEmailTemplates[1].Id);
            mail.setSaveAsActivity(false);
            mail.setToAddresses(toAddresses);
            mail.setccAddresses(ccAddresses);
            mail.setWhatId(whatID);
            mail.setTargetObjectId(userid.id);
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }    
            }
            if(failureEmail == true){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                    if(owea.size() > 0){
                        mail1.setOrgWideEmailAddressId(owea[0].Id);
                    }	
          //  System.debug('SendEmailResultlese' + lstEmailTemplates) ;
            String[] toAddresses = new String[] {userid.Email}; 
            String[] ccAddresses = new String[] {'LFlowers@sjm.com'};
            if(lstEmailTemplates!=null && lstEmailTemplates.size()>0){
            mail1.setTemplateId(lstEmailTemplates[0].Id);
            mail1.setSaveAsActivity(false);
            mail1.setToAddresses(toAddresses);
            mail1.setccAddresses(ccAddresses);
            mail1.setWhatId(whatID);
            mail1.setTargetObjectId(userid.id);
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
            }    
            }
                  successEmail=false;  
                  failureEmail=false;
            }
            
       }
      }
     catch (System.DmlException e) 
     {
        for (Integer i = 0; i < e.getNumDml(); i++)
         {
            // Process exception here
            System.debug(e.getDmlMessage(i));
         }
    }
    }
    global void finish(Database.BatchableContext BC )
    {
        // Logic to be Executed at finish
        System.debug('Batch job finished...') ;
    }
 
}