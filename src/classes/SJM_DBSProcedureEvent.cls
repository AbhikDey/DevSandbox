global class SJM_DBSProcedureEvent {
    public SJM_DBSProcedureEvent(ApexPages.StandardController controller) {

    }
    
    @RemoteAction
    public static id getRecordId(){
        //make soql quesy here
        List<RecordType> recordTypeId = [SELECT ID FROM RecordType where DeveloperName = 'DBS_Case' LIMIT 1];
        return recordTypeId[0].id;
    }
    
}