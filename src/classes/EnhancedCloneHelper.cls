/**
* @description Helper class to clone parent and its children sObjects
*/
global without sharing class EnhancedCloneHelper {
       
    /**
    * @description Clone parent and its children
    * @param id of the parent sObject
    * @return String Serialized result
    */
    webservice static String clone (String sObjectId) {
        
        List<Case> parentSObjects;
        Case parent;
        CloneModel cloneModelResult = new CloneModel();
        
        // Parent query
        String query = String.format(
            'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'',
            new String[] {
                String.join(
                    new List<String>(
                        Case.SObjectType.getDescribe().fields.getMap().keySet()
                    ),
                    ','
                ),
                String.valueOf(Case.SObjectType),
                sObjectId
           }
        );

        try {
            
            // Query and gets results
            parentSObjects = Database.query(query);         
            
            // Clone the original object. Here you can change anything without affecting the original sObject
            parent = parentSObjects[0].clone(false, true, false, false);
            parent.Subject= parent.Subject+ ' CLONED';
            if(parent.RFP_Due_Date__c !=null){
            parent.ParentId = sObjectId;
            }
            parent.Complete_Info_Date__c=null;
            parent.Date_Quoted__c   =null;
            parent.Date_Received__c =null;
            parent.RFP_Due_Date__c=null;
            parent.Date_Received__c=System.TODAY();
            
            parent.Status='New';
            parent.OwnerId= UserInfo.getUserId();
            parent.Opportunity__c =null;
            if( parent.Requester_Name__c ==null){
            parent.Requester_Name__c= parent.SuppliedName;
            }
           
            parent.SuppliedCompany='';
             parent.SuppliedPhone='';
            
          parent.SuppliedName = '';
         parent.SuppliedEmail= '';
            Database.insert(parent);
       
        } catch (DmlException error) {
            cloneModelResult.message = 'An error occurred while cloning the object.' + error.getMessage();
            return JSON.serialize(cloneModelResult);        
        }
        
        // Children query  
        query = String.format(
            'SELECT {0} FROM {1} WHERE Case__c= \'\'{2}\'\'',
            new String[] {
                String.join(
                    new List<String>(
                        Case_Lines__c.SObjectType.getDescribe().fields.getMap().keySet()
                    ),
                    ','
                ),
                String.valueOf(Case_Lines__c.SObjectType),
                sObjectId
           }
        );
        
        List<Case_Lines__c> children = new List<Case_Lines__c>();
        
        
            
            // Query and clone the children. Here you can change anything without affecting the original sObject
            for (Case_Lines__c child:(List<Case_Lines__c>)Database.query(query)) {
                children.add(child.clone(false,true,false,false));
            }
            
            // If there isn't any children ends the process and return success
            if (children.isEmpty()) {
                cloneModelResult.isSuccess = true;
                cloneModelResult.message = 'Object successfully cloned!';                
                cloneModelResult.url = getUrlRedirect(parent.Id);
                return JSON.serialize(cloneModelResult);
            }
            
            // Set the parent's Id
            for (Case_Lines__c child : children) {
                child.Case__c= parent.Id;
            }
        
            Database.insert(children);
    
            
      
        
        // Return success at the end of the process
        cloneModelResult.isSuccess = true;
        cloneModelResult.message = 'Case and its Products successfully cloned!';
        cloneModelResult.url = getUrlRedirect(parent.Id);
        
        return JSON.serialize(cloneModelResult);

    }

    private static String getUrlRedirect(String sObjectId){
        PageReference page = new PageReference('/'+ sObjectId);
        return page.getUrl();
    }
    
    global class CloneModel {
        Boolean isSuccess;
        String message;
        String url;
    }
}