@isTest
private class SJM_ProcedureControllerTest {
    // Methods for testing
    static testMethod void procedureControllerTest() {
        
        Account a1 = new Account  (
                     Name = 'Demo Account');
                insert a1;
                system.assertNotEquals( null, a1.Id );

        RecordType rt = [Select id From RecordType Where SobjectType='Contact' AND DeveloperName='Physician'];

        Contact c1 = new Contact(
                    firstname = 'phys1',
                    lastname = 'phys2',
                    AccountId = a1.Id,
                    Email='abc@sjm.com',
                    RecordTypeID = rt.id);
                    insert c1;   


        Procedure__c procedure= new Procedure__c();
        Procedure__c procedure1= new Procedure__c();
        procedure.Procedure_Date__c = Date.today();
        procedure.Procedure_Type__c = 'NavX';
        procedure.Account__c = a1.Id;
        procedure.Procedure_Physician__c = c1.id;
        insert procedure;
        
        Procedure_Tracker_Settings__c ptSetting = new Procedure_Tracker_Settings__c();
        ptSetting.Require_Fields__c = 'Name';
        ptSetting.Procedure_Account_Field_Id__c = 'CF00Ng0000001UPye_lkid';
        insert ptSetting;
        
        Account acc = new Account();
        acc.Name = 'testing';
        insert acc;
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        
        ApexPages.currentPage().getParameters().put(ptSetting.Procedure_Account_Field_Id__c,acc.Id);
        Procedure_Item__c procedureItem = new Procedure_Item__c();
        procedureItem.Procedure__c = Procedure.id;
        procedureItem.Procedure_Item__c = 'Transseptal Needle';
        
        insert procedureItem;
        
        ApexPages.currentPage().getParameters().put('id',procedure.id);
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController( procedure );
        
        SJM_ProcedureEditController procedureEditController = new SJM_ProcedureEditController(sc);
        Map<String, List<Procedure_Item__c>> pITest = procedureEditController.typeToProcedureItems;
        
        Boolean s1test = procedureEditController.getIsS1();
        ApexPages.currentPage().getParameters().put('id',null);
        sc = new ApexPages.StandardController( procedure1 );
        procedureEditController = new SJM_ProcedureEditController(sc);
		Map<String, String> rfMaptest = procedureEditController.requiredFieldsMap;        
        test.stopTest();
    }
}