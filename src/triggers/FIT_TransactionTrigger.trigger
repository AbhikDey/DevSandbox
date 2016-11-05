/**
 * Super Trigger for Transactions__c
 * @DateCreated: 1/18/2015
 * @Author: Andres Di Geronimo-Stenberg (Magnet360)
 */
trigger FIT_TransactionTrigger on Transactions__c ( before update) 
{
    if( Trigger.isUpdate && Trigger.isBefore )
    {
        FIT_TransactionHandler.onBeforeUpdate( Trigger.new , Trigger.oldMap );
    }
}