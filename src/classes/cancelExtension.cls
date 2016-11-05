public class cancelExtension {

    Id recordId;
    public ID newRecordId {get;set;}

    public cancelExtension(ApexPages.StandardController controller) {
        recordId = controller.getRecord().Id;
    }
    
    public PageReference setCancel(){
    
        Event e = [select Id, Status__c from Event where Id = :recordId limit 1];
        
        e.Status__c = 'Cancelled';
        
        update e;
        newRecordId = e.Id;
        return new PageReference('/' + e.Id);
         
    }
    
}