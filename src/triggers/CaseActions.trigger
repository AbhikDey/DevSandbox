trigger CaseActions on Case (before insert, before update, after insert, after update){ 
  if((trigger.IsInsert || trigger.Isupdate) && trigger.Isbefore){
   AccountUtility.UpdateAccountName(Trigger.new);
  
}


 if(trigger.IsInsert  && trigger.Isafter){
   AccountUtility.addproduct(Trigger.new);
   

}
}