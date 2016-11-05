@isTest
public class SJM_DBSProcedureEvent_Test {
	static testMethod void SJM_DBSProcedureEvent_Test(){
        //get DBS_CASE 
        
        Test.startTest();
        RecordType rt = [SELECT id FROM RecordType WHERE DeveloperName = 'DBS_Case'];     
        SJM_DBSProcedureEvent controller = new SJM_DBSProcedureEvent(null);
        
        id fromController = SJM_DBSProcedureEvent.getRecordId();
        
        system.assertEquals(fromController, rt.Id );
        
        Test.stopTest();
    }
}