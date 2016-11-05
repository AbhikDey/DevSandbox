trigger FIT_TransactionItem on Transaction_Items__c( before insert, 
                                                     before delete,
                                                     after insert,
                                                     after update,
                                                     after delete, 
                                                     after undelete )
{

    if( Trigger.isBefore && Trigger.isInsert )
    {
        FIT_TransactionItemTriggerHandler.checkInventory( Trigger.new );
        FIT_TransactionItemTriggerHandler.setPrice(Trigger.new);
    }
    else if( Trigger.isBefore && Trigger.isDelete )
    {
        FIT_TransactionItemTriggerHandler.beforeDelete( Trigger.old );
    }
    else if( Trigger.isAfter && Trigger.isInsert )
    {
        FIT_TransactionItemTriggerHandler.setItemsInTransaction( Trigger.new );
    }
    else if( Trigger.isAfter && Trigger.isUpdate )
    {
        FIT_TransactionItemTriggerHandler.setItemsInTransaction( Trigger.new );
    }
    else if( Trigger.isAfter && Trigger.isDelete )
    {
        FIT_TransactionItemTriggerHandler.setItemsInTransaction( Trigger.old );
    }
    else if( Trigger.isAfter && Trigger.isUndelete )
    {
        FIT_TransactionItemTriggerHandler.setItemsInTransaction( Trigger.old );
    }
}