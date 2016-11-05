public class Contractviewcontroller{

 string recId;
 

    public list<Contract> contr{get;set;}
    
    public Contractviewcontroller(ApexPages.StandardController controller) 
    {
       
        recId = controller.getRecord().Id;
      
       
           contr = [SELECT Id, ContractNumber, Name,Request_Type__c,Contract_Link__c, AccountId, StartDate, EndDate,Status FROM Contract WHERE AccountId =: recId ORDER BY StartDate DESC ];
          
    }
}