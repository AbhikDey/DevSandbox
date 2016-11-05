public with sharing class SchedulerProfile {

      public Boolean result = false;
      public String Prset;
      public String DEPerSet = 'Opportunity_Management_DBS_OUS';
      
      List<Id> listpersetass = new List<Id>();
      List<String> liststring =  new List<String>();
    
    PageReference pageRef;

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
                 //system.debug('@@ if ' + procedureId);
                 pageRef = new PageReference('/apex/DBSSchedular');
                 //pageRef.getParameters().put('id',procedureId );
         }
         else
         {
                 pageRef = new PageReference('/apex/FullCalendar');
          
         }
          pageRef.setRedirect(true);
          return pageRef; 

   }
}