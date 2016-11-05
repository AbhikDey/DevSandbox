public with sharing class DBSProfile {

// Private variables
    public ApexPages.StandardController stdController;
    public ID procedureId {get; set;}
    
      public Boolean result = false;
      public String Prset;
      public String DEPerSet = 'Opportunity_Management_DBS_OUS';
      
      List<Id> listpersetass = new List<Id>();
      List<String> liststring =  new List<String>();
    
    // Public Variables
    public ID accountId {get; set;}
    PageReference pageRef;

    public DBSProfile(ApexPages.StandardController controller) { 
        this.stdController = controller;
        procedureId = ApexPages.currentPage().getParameters().get('id');
        //system.debug('@@ procedureId  ' + procedureId);
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        //system.debug('@@ accountId' + accountId);
        
    }

    public PageReference Redirect(){
    
        for(PermissionSetAssignment prnames :[SELECT Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()])
        {  
           listpersetass.add(prnames.PermissionSetId);
        }

        for(PermissionSet p : [SELECT Id,Name from PermissionSet where id = : listpersetass])
        {
           liststring.add(p.name); 
        }

        Prset = String.valueof(liststring);
                      
        String[] arrprset = Prset.split('\\,');
        
        for(String check : arrprset)
        {
           if(check.contains(DEPerSet))
             {
               result = true;
             }
        }
    
        if(result == true)
          { 
             if(procedureId != null){
                 //system.debug('@@ if ' + procedureId);
                 pageRef = new PageReference('/apex/SJM_DBSProcedureTracker?Id='+procedureId);
                 pageRef.getParameters().put('id',procedureId );
             } 
             else
             {
                 //system.debug('@@ else ' + accountId);
                 pageRef = new PageReference('/apex/SJM_DBSProcedureTracker?accountId='+accountId);
                 pageRef.getParameters().put('accountId',accountId );
             }           
            
             //pageRef.setRedirect(true);
             //return pageRef; 
          }
    
        else
         {
            if(procedureId != null){
                 pageRef = new PageReference('/apex/SJM_ProcedureEdit?Id='+procedureId);
                 pageRef.getParameters().put('id',procedureId );
             } 
             else
             {
                 pageRef = new PageReference('/apex/SJM_ProcedureEdit?accountId='+accountId);
                 pageRef.getParameters().put('accountId',accountId );
             }
         } 
         
          pageRef.setRedirect(true);
          return pageRef; 

   }
 

}