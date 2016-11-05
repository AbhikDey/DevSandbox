/**
* Controller for autoComplete Component
* 
* @Date: 11.16.2015
* @Author: Adeel Ahmad (Magnet 360)
* 
* @Updates:
*/
global with sharing class SJM_AutoCompleteController {
    
    @RemoteAction
    global static SObject[] findSObjects(String obj, String qry, String preFix, String accId, boolean showAllContacts, Boolean showAcctAddress) {
        // more than one field can be passed in the addFields parameter
        // split it into an array for later use
        List<String> fieldList;
        
        //If object name is not provided, get the object name based on prefix
        //If object name is not provided, get the object name based on prefix
        if(obj == '' || obj == null){
            obj = findObjectNameFromRecordIdPrefix(preFix);
        } 

        //Incase of contact, check for record type as well
        String recordType = '';
        String relatedTo = '';
        
        System.debug('*** showAllContacts = ' + showAllContacts);
        System.debug('*** showAcctAddress = ' + showAcctAddress);
        // If Object is contact
        if(obj == 'Contact' && showAllContacts == false){
            System.debug('*** Getting Affiliation__c details' );
            
            Set<ID> contactIds = new Set<ID>();
            // Query on Affiliation__c Records
            for( Affiliation__c a : [select Contact__c from Affiliation__c where Account__c = :accId] ){
                contactIds.add( a.Contact__c );
            }
            
            // get contact record type Id with 'Physician' Devloper name
            ID recTypeId = [Select Id From RecordType  Where SobjectType = 'Contact' and DeveloperName = 'Physician'].Id;
            recordType = ' AND RecordTypeId =: recTypeId ';
            
            // If account Id is not empty
            if(accId != ''){
                relatedTo = ' AND ID in :contactIds ';                
            }
        }
        
       // check to see if the object passed is valid
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        
        // create the filter text
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        String soql;
        //begin building the dynamic soql query
        if(showAcctAddress == true){
            soql = 'select id, Name,BillingStreet,Search_2__c';
            filter = filter + ' or Search_2__c like \'%' + String.escapeSingleQuotes(qry) + '%\'';
            soql += ' from ' + obj + ' WHERE Search_2__c ' + filter;
        }
        else
        {
            soql = 'select id, Name ';
            soql += ' from ' + obj + ' WHERE Name ' + filter;
        }

        // add the object and filter by name to the soql
        //soql += ' from ' + obj + ' WHERE Name ' + filter;
        // add the filter by additional fields to the soql

        if(recordType != ''){
            soql += recordType;
        }

        if(relatedTo != ''){
            soql += relatedTo;
        }
        if(showAcctAddress == true)
        {
            soql += ' order by Search_2__c limit 20';
        }
        else
        {
            soql += ' order by Name limit 20';
        }
        System.debug('AA:Soql ' + soql);
        
        List<sObject> L = new List<sObject>();
        try {
            L = Database.query(soql);
        }
        catch (QueryException e) {
            return null;
        }
        return L;
   }
    
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
}