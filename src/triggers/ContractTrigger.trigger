trigger ContractTrigger on Contract (after Insert, before insert) {

if(trigger.IsInsert && trigger.Isafter){
 ContractUtility.Contractlineitems(Trigger.new);
}
if(trigger.IsInsert && trigger.Isbefore){
 ContractUtility.Cont(Trigger.new);
}




}