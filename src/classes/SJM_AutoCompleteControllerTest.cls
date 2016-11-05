@isTest
private class SJM_AutoCompleteControllerTest {

      // Methods for testing
    static testMethod void autoCompleteCntrollerTest() {
        Contact c = new Contact();
        test.startTest();
       // insert c;
        RecordType rt = new RecordType();
        rt.SobjectType = 'Contact';
        rt.DeveloperName = 'Physician';
        // for the contact id put 003
       String record_id =  SJM_AutoCompleteController.findObjectNameFromRecordIdPrefix('003');
         // for the exception put any character
          String record_id1 =  SJM_AutoCompleteController.findObjectNameFromRecordIdPrefix('a');
        
        SObject []obj = SJM_AutoCompleteController.findSObjects('Contact', '', '003', '001', true, true);
        SObject []obj1 = SJM_AutoCompleteController.findSObjects(null, '', '003', '001', false, false);
        SObject []obj2 = SJM_AutoCompleteController.findSObjects('nu12123', 'asgd3773643?.<,=-`  87*', '003', '001', true, true);
        SObject []obj4 = SJM_AutoCompleteController.findSObjects(null, 'asgd3773643?.<,=-`     87*', '003', '001', false, false);
        test.stopTest();
        
    }

}