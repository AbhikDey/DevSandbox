public class TaskController {

 public static void handleBeforeDelete( List<Task> Tasks ){
 
 for (Task Tsk : Tasks)      
       {            

             if((!String.isBlank(Tsk.Candidate_Stage__c)) || (!String.isBlank(Tsk.OpportunityStage__c))){
             Tsk.addError('System Genereated Tasks Cannot be Deleted. Please contact your system Administrator');
             }
         }
 
 }




}