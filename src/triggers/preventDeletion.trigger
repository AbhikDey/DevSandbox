trigger preventDeletion on Procedure__c (before delete){
    for(Procedure__c prc:Trigger.old){    
      if(prc.RecordTypeId == '012j0000000ubvnAAA'){
		Long difference = System.Now().getTime() - prc.CreatedDate.getTime();
		long hr = difference/(1000*60*60);    
		if(hr < 24 )
		 {
		 	return;
		 }
		 else
		 {
		 	prc.addError('You can\'t delete this record, after 24 hrs of its creation!');
		 }
      }
    }
}