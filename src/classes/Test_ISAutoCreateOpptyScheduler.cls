//Scheduler test method
@isTest
private class Test_ISAutoCreateOpptyScheduler {
    public static testmethod void test() {
        Test.StartTest();
        // The query used by the batch job.
        IS_AutoCreateOpptyJob testsch = new IS_AutoCreateOpptyJob();
        //String query = 'Select Id,Account_Number__c,Warranty_End__c,Serial_Lot_Number__c, Oppty_Product_Model__c, Account_Name__r.SJM_ID__c,Account_Name__r.Id,Account_Name__r.Name,Account_Name__r.Service_Contract_Specialist__r.Id,Account_Name__c FROM Equipment__c' + 'WHERE Id NOT IN (SELECT Merchandise__c FROM Line_Item__c)';
        String sch = '0 0 23 * * ?';
        system.schedule('Test Status check', sch, testsch);
        Test.StopTest();
    }

}