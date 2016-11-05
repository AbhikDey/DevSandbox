trigger ContactActions on Contact (after insert, after update) {
    if(Trigger.isinsert || Trigger.isupdate){
        if(Trigger.isAfter){
        
        ContactMethods.AssociateContacts(Trigger.new);
        }
    }
}