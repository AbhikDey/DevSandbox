public class ContactMethods {

    public static void AssociateContacts(Contact[] Contacts){
    
    list<Affiliation__c> AfftoCreate = new list<Affiliation__c>();
    
    for(Contact Cons : Contacts){
    
    string sAccountId = Cons.AccountId;
    string sConId = Cons.Id;
    if(sAccountId != null)
    {
        
        string sSOQL = 'Select count() from Affiliation__c where Account__c = :sAccountId and Contact__c = :sConId';
        
        
        //integer count = 0;
        
        integer count = Database.countQuery(sSOQL);
        
        if(count == 0){
        AfftoCreate.add(new Affiliation__c(
        Account__c=Cons.AccountId,
        Contact__c=Cons.Id,
        Primary__c = True
         
        ) );
        }
        
    }//if
    
    
    }//for
    
    if(AfftoCreate != null && AfftoCreate.size() > 0){ 
    insert AfftoCreate;
    }//if
    
    }//AssociateContacts


}