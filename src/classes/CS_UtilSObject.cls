public class CS_UtilSObject {

    public static void getAllFieldDescribe() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        Set<String> typeSet = new Set<String>();
        Set<String> soapTypeSet = new Set<String>();  
        
        for (Schema.SObjectType sot : gd.values()) {
            Map<String, Schema.SObjectField> objectFields_map = getFieldDescribe(sot.getDescribe());
            
            if (fieldDescribeCache.size() > 99) break;
            
            system.debug('------');
            system.debug(sot.getDescribe().getName());
            for (Schema.SObjectField sof : objectFields_map.values()) {
                system.debug(sof.getDescribe().getName() + ':' + sof.getDescribe().getLabel()
                     + ':' + sof.getDescribe().getType() + ':' + sof.getDescribe().getSOAPType());
                soapTypeSet.add(sof.getDescribe().getSOAPType().name());
                typeSet.add(sof.getDescribe().getType().name());
            }
            system.debug('------');
            
        }
        
        system.debug('--- Used type list ---');
        for(String s : typeSet) {
            system.debug(s);
        }
        system.debug('------');
        
        system.debug('--- Used soap type list ---');
        for(String s : soapTypeSet) {
            system.debug(s);
        }
        system.debug('------');
    }
    
    public static Map<String, Map<String, Schema.SObjectField>> fieldDescribeCache = 
                new Map<String, Map<String, Schema.SObjectField>>();
                
    public static Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    
    public static Map<String, Schema.SObjectField> getFieldDescribe(Schema.DescribeSObjectResult sdo) {
        if (!fieldDescribeCache.containsKey(sdo.getName())) {
            fieldDescribeCache.put(sdo.getName(), sdo.fields.getMap());
        }
        return fieldDescribeCache.get(sdo.getName());
    }
    
    public static Map<String, Schema.SObjectField> getFieldDescribeByApiName(String obj) {
        
        if (!fieldDescribeCache.containsKey(obj)) {
            Schema.SObjectType leadSchema = schemaMap.get(obj);
            fieldDescribeCache.put(obj, leadSchema.getDescribe().fields.getMap());
        }
        return fieldDescribeCache.get(obj);
    }
    
    public static String buildQueryFields(Schema.DescribeSObjectResult sdo) {
        
        Map<String, Schema.SObjectField> objectFields_map = getFieldDescribe(sdo);
        //Added by Abhijeet
        system.debug('Add fields:' +  objectFields_map);
        String queryFields = '';
        Boolean firstFlag = true;
        for (string c : objectFields_map.keySet()) {
            if (!firstFlag) {
                queryFields = queryFields + ', ';
            }
            queryFields = queryFields + c;
            firstFlag = false;
        }
        return queryFields;
    }
    
    public static String buildQueryFieldsByComma(String fieldStr) {
        List<String> scriptIds = fieldStr.split(',');
        
        String queryFields = '';
        Boolean firstFlag = true;
        for (string c : scriptIds) {
            if (!firstFlag) {
                queryFields = queryFields + ', ';
            }
            queryFields = queryFields + '\'' + c + '\'';
            firstFlag = false;
        }
        return queryFields;
    }
    
    public static String appendQueryFields(String fieldStr, String newFieldStr) {
        if (fieldStr != '') {
            fieldStr = fieldStr + ',';
        }
        fieldStr = fieldStr + '\'' + newFieldStr + '\'';
        
        return fieldStr;
    }
    
    public static String buildQueryFields(Schema.DescribeSObjectResult sdo, String tableName) {
        Map<String, Schema.SObjectField> objectFields_map = getFieldDescribe(sdo);
        String queryFields = '';
        Boolean firstFlag = true;
        for (string c : objectFields_map.keySet()) {
            if (!firstFlag) {
                queryFields = queryFields + ', ';
            }
            queryFields = queryFields + tableName + '.' + c;
            firstFlag = false;
        }
        return queryFields;
    }
    
    public static String buildQuery(Schema.DescribeSObjectResult sdo) {
        String queryFields = buildQueryFields(sdo);
        queryFields = 'SELECT ' + queryFields + ' FROM ' + sdo.getName() + ' ';
        return queryFields;
    }
        
    public static String buildQuery(Schema.DescribeSObjectResult sdo, String extraColumns) {
        String queryFields = buildQueryFields(sdo);
        queryFields = 'SELECT ' + queryFields + ',' + extraColumns + ' FROM ' + sdo.getName() + ' ';
        return queryFields;
    }
        
    public List<SelectOption> getPicklistSelectOption(Schema.DescribeFieldResult F) {
        List<SelectOption> options = new List<SelectOption>();
        
        List<Schema.PicklistEntry> Ple = F.getPicklistValues();
        for(Schema.PicklistEntry p : ple){
            options.add(new SelectOption(p.getLabel(), p.getLabel()));
        }
        return options;
    }
    
}