public with sharing class PII_Info {
    private static final String CANDIDATE_SERVICE='CandidateService';
    private static final String CertName=label.SelfSignedCertificate;
    /*  
*  Ship Info Class to hold REST API response data  
*/  
    public class CandidateInfo {
        public string Method{get;set;}
        public string UserID{get;set;}
        public string Status{get;set;}
        public String ID{get;set;}
        public String EXTERNALSYSTEMNAME{get;set;}        
        public String EXTERNALSYSTEMID{get;set;}  
        public String ENTITY_NAME{get;set;}
        public String FIRST_NAME{get;set;}  
        public String LAST_NAME{get;set;}  
        public String GENDER{get;set;}
        public String DATE_OF_BIRTH{get;set;}
        public String HOME_PHONE{get;set;}
        public String CELL_PHONE{get;set;}
        public String ADDRESS_LINE1{get;set;}
        public String ADDRESS_LINE2{get;set;}
        public String ADDRESS_CITY{get;set;}
        public String ADDRESS_STATE_PROVINCE{get;set;}
        public String ADDRESS_COUNTRY{get;set;}
        public String CREATED_BY{get;set;}
        public String CREATED_DT{get;set;}
        public String MODIFIED_BY{get;set;}
        public String MODIFIED_DT{get;set;}  
    }
    
    public class ResponseErrorMessage{
        public string Status{get;set;}
        public string Description{get;set;}
        public String Message{get;set;}
    }
    
    public class RequestGetCandidateInfo{
        public string Method{get;set;}
        public string UserID{get;set;}
        public String ID{get;set;}
        public String EXTERNALSYSTEMNAME{get;set;}
        public String EXTERNALSYSTEMID{get;set;}
    }
    
    public class RequestGetListCandidateInfo{
        public string Method{get;set;}
        public String EXTERNALSYSTEMNAME{get;set;}
        public List<String> EXTERNALSYSTEMID{get;set;}
    }
    
    public class RequestSearchCandidateInfo{
        public string Method{get;set;}
        public String EXTERNALSYSTEMNAME{get;set;}
        public String ENTITY_NAME{get;set;}
        public String FIRST_NAME{get;set;}  
        public String LAST_NAME{get;set;}
    }
    
    public CandidateInfo UpdateAuditDetails(CandidateInfo theCandidateInfo){
        if (string.isEmpty(theCandidateInfo.CREATED_BY)){
            theCandidateInfo.CREATED_BY = Userinfo.getUserName();
        }
        
        theCandidateInfo.EXTERNALSYSTEMNAME = 'Salesforce';
        theCandidateInfo.ENTITY_NAME = 'Candidate__c';
        theCandidateInfo.Method = 'PUT';
        theCandidateInfo.UserID = Userinfo.getUserName();
        
        return theCandidateInfo;
    }
    
    public CandidateInfo InsertAuditDetails(CandidateInfo theCandidateInfo){
        if (string.isEmpty(theCandidateInfo.CREATED_BY)){
            theCandidateInfo.CREATED_BY = Userinfo.getUserName();
        }
        
        theCandidateInfo.EXTERNALSYSTEMNAME = 'Salesforce';
        theCandidateInfo.ENTITY_NAME = 'Candidate__c';
        theCandidateInfo.Method = 'POST';
        theCandidateInfo.UserID = Userinfo.getUserName();
        
        return theCandidateInfo;
    }
    
    @future(callout=true)
    public static void updatePII_Info(string id, string candidateJson){
        string sfObjId = null;
        SJM_Error_Handling__c sjmEH = new SJM_Error_Handling__c();
        String retResponse = null;
        
        try{
            System.debug('*** try' + candidateJson);
            //call webservice
            SJM_Integrations__c sjmIntegration = getServiceCredentials(CANDIDATE_SERVICE);
            if(sjmIntegration == null) throw new UnableToReachSJMException('No SJM integration defined for request: '+ CANDIDATE_SERVICE);
            string endPoint = sjmIntegration.Web_Service_Endpoint__c; //+ '/' + Integer.valueOf(id);
            
            System.debug('*** SJM JSON' + candidateJson);
            System.debug('*** SJM Req EndPoint ' + endPoint);
            
            HttpRequest req = getHttpReqWithAuthHeader(endPoint, 
                                                       sjmIntegration.Web_Service_User__c, 
                                                       sjmIntegration.Web_Service_Password__c,
                                                       'POST');
            
            //Set Certificate for Two-Way SSL Authentication
            req.setClientCertificateName(CertName);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(candidateJson); 
            
            sfObjId = ((CandidateInfo)JSON.deserialize(candidateJson,CandidateInfo.class)).EXTERNALSYSTEMID; 
            System.debug('*** SJM JSON candidate id ' + sfObjId);
            
            Http http = new Http();
            HTTPResponse res= null;
            
            System.debug('*** SJM Req EndPoint  '+ endPoint);                        
            
            res = http.send(req);
            System.debug('*** SJM Res getHeaderKeys  '+ res.getHeaderKeys());
            System.debug('*** SJM Res getHeader(Content-Type)  '+ res.getHeader('Content-Type'));
            System.debug('*** SJM Res getHeader(Connection)  '+ res.getHeader('Connection'));
            System.debug('*** SJM Res getStatus  '+ res.getStatus());
            System.debug('*** SJM Res getStatusCode  '+ res.getStatusCode());
            
            
            if(res.getStatusCode() == 200 && res.getHeader('Content-Type') == 'application/json'){
                String bodyResult;
                System.debug('*** SJM Response body '+ res.getBody());
                bodyResult = resBodyResult(res.getBody());
                System.debug('*** SJM Response bodyResult '+ bodyResult);
                
                if(bodyResult == 'Success')
                {
                    System.debug('*** SJM Response body '+ res.getBody());                                        
                    String str = res.getbody();
                    str = str.replaceAll('\\[', '').replaceAll('\\]','');
                    CandidateInfo candidateFromService = (CandidateInfo)JSON.deserialize(str,CandidateInfo.class); 
                    sfObjId = candidateFromService.EXTERNALSYSTEMID;                    
                    System.debug('*** SJM JSON candidate id ' + sfObjId);
                    retResponse = 'Success';
                } else if(bodyResult == 'Failure')   
                {
                    ResponseErrorMessage errMsg = (ResponseErrorMessage)JSON.deserialize(res.getBody(),ResponseErrorMessage.class);
                    retResponse = errMsg.Status+' | '+errMsg.Description+' | '+errMsg.Message;
                    throw new InvalidServiceResponseException(retResponse+'. Status Code: ' + res.getStatusCode());
                }      
            }
            else
            {
                System.debug('*** SJM else' );
                retResponse = 'Failed to save Candidate Details. Status Code: '+res.getStatusCode();
                throw new InvalidServiceResponseException('Failed to save Candidate Details. Status Code: ' + res.getStatusCode());
            }
            
            System.debug('*** SJM Return Response : '+retResponse);
        } catch(Exception ce){
         	system.debug('@@Exception ' + ce);
            sjmEH.CandidateID__c = sfObjId;
            sjmEH.Error_Number__c =  String.valueOf(ce.getTypeName());
            sjmEH.Error_Description__c = String.valueOf(ce.getMessage());
            sjmEH.Error_Category__c = 'Candidate Integration Error';
            UPSERT sjmEH;
        } 
    }
    
    public void updatePII_Info(PII_Info.CandidateInfo incomingCandidate){
        string candidateJson = JSON.serialize(incomingCandidate);
        PII_Info.updatePII_Info(incomingCandidate.ID, candidateJson);
    }
    
    @future(callout=true)
    public static void createPII_Info(string candidateJson){
        string sfObjId = null;
        SJM_Error_Handling__c sjmEH = new SJM_Error_Handling__c();
        String retResponse = null;
        
        try{
            //call webservice
            SJM_Integrations__c sjmIntegration = getServiceCredentials(CANDIDATE_SERVICE);
            if(sjmIntegration == null) throw new UnableToReachSJMException('No SJM integration defined for request: '+ CANDIDATE_SERVICE);
            string endPoint = sjmIntegration.Web_Service_Endpoint__c;
            
            System.debug('*** SJM JSON' + candidateJson);
            System.debug('*** SJM Req EndPoint ' + endPoint);
            
            HttpRequest req = getHttpReqWithAuthHeader(endPoint, 
                                                       sjmIntegration.Web_Service_User__c, 
                                                       sjmIntegration.Web_Service_Password__c,
                                                       'POST');
            
            //Set Certificate for Two-Way SSL Authentication
            req.setClientCertificateName(CertName);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(candidateJson); 
           
            sfObjId = ((CandidateInfo)JSON.deserialize(candidateJson,CandidateInfo.class)).EXTERNALSYSTEMID; 
            System.debug('*** SJM JSON candidate id ' + sfObjId);
            
            Http http = new Http();
            HTTPResponse res= null;
            
            System.debug('*** SJM Req EndPoint  '+ endPoint);
            
            res = http.send(req);
            System.debug('*** SJM Res getHeaderKeys  '+ res.getHeaderKeys());
            System.debug('*** SJM Res getHeader(Content-Type)  '+ res.getHeader('Content-Type'));
            System.debug('*** SJM Res getHeader(Connection)  '+ res.getHeader('Connection'));
            System.debug('*** SJM Res getStatus  '+ res.getStatus());
            System.debug('*** SJM Res getStatusCode  '+ res.getStatusCode());
                        
             
            if((res.getStatusCode() == 201 || res.getStatusCode() == 200) && res.getHeader('Content-Type') == 'application/json'){ 
                String bodyResult;
                bodyResult = resBodyResult(res.getBody());
                System.debug('*** SJM Response bodyResult '+ bodyResult);
                
                if(bodyResult == 'Success')
                {
                    System.debug('*** SJM Response body '+ res.getBody());                                        
                    String str = res.getbody();
                    str = str.replaceAll('\\[', '').replaceAll('\\]','');
                    CandidateInfo candidateFromService = (CandidateInfo)JSON.deserialize(str,CandidateInfo.class); 
                    sfObjId = candidateFromService.EXTERNALSYSTEMID;
                    
                    List<Candidate__c> sfCandidates = [SELECT ID FROM Candidate__c where ID = :candidateFromService.EXTERNALSYSTEMID LIMIT 1];
                    for(Candidate__c sf : sfCandidates){
                        System.debug('*** SJM Update SObject. ID: '+ sf.Id +'. Remote ID: ' + candidateFromService.ID);
                        sf.External_System_Id__c = String.valueOf(Integer.valueOf(candidateFromService.ID));    
                        update sf;
                    }
                    
                    retResponse = 'Success';
                    
                } else if(bodyResult == 'Failure')
                {
                    ResponseErrorMessage errMsg = (ResponseErrorMessage)JSON.deserialize(res.getBody(),ResponseErrorMessage.class);
                    retResponse = errMsg.Status+' | '+errMsg.Description+' | '+errMsg.Message;
                    throw new InvalidServiceResponseException(retResponse+'. Status Code: ' + res.getStatusCode());
                }
                                
            }
            else{                
                System.debug('*** SJM else' );
                retResponse = 'Failed to save Candidate Details. Status Code: '+res.getStatusCode();
                throw new InvalidServiceResponseException('Failed to save Candidate Details. Status Code: ' + res.getStatusCode());
            }
            System.debug('*** SJM Return Response : '+retResponse);
        }
        catch(CallOutException ce){  
            //KARANAM - Saving candidate error message on errohandling object
            system.debug('@@Exception ' + ce);
            sjmEH.CandidateID__c = sfObjId;
            sjmEH.Error_Number__c =  String.valueOf(ce.getTypeName());
            sjmEH.Error_Description__c = String.valueOf(ce.getMessage());
            sjmEH.Error_Category__c = 'Candidate Integration Error';
            UPSERT sjmEH;           
        }        
        catch(Exception e){  
            //KARANAM - Saving candidate error message on errohandling object
            system.debug('@@Exception ' + e);
            sjmEH.CandidateID__c = sfObjId;
            sjmEH.Error_Number__c =  String.valueOf(e.getTypeName());
            sjmEH.Error_Description__c = String.valueOf(e.getMessage());
            sjmEH.Error_Category__c = 'Candidate Integration Error';
            UPSERT sjmEH;            
        }
    }
    
    public void createPII_info(CandidateInfo newCandidate){
        string candidateJson = JSON.serialize(newCandidate);
        PII_Info.createPII_Info(candidateJson);
    }
    
    public CandidateInfo getPII_Info(string externalID){     
        RequestGetCandidateInfo reqCandidateInfo = new RequestGetCandidateInfo();
        reqCandidateInfo.Method = 'GETID';
        reqCandidateInfo.UserID = Userinfo.getUserName(); //TODO
        reqCandidateInfo.ID = externalID;
        reqCandidateInfo.EXTERNALSYSTEMNAME = 'Salesforce';
        
        return getPII_Info(reqCandidateInfo);
    }
    
    public List<CandidateInfo> getListViewPII_Info(List<ID> candIDs){     
        RequestGetListCandidateInfo reqListCandidateInfo = new RequestGetListCandidateInfo();
        reqListCandidateInfo.Method = 'GETID';
        //reqListCandidateInfo.UserID = Userinfo.getUserName(); //TODO
        reqListCandidateInfo.EXTERNALSYSTEMID = candIDs;
        reqListCandidateInfo.EXTERNALSYSTEMNAME = 'Salesforce';
        
        return getListViewPII_Info(reqListCandidateInfo);
    }
    
    public CandidateInfo getPII_Info(ID candID){     
        RequestGetCandidateInfo reqCandidateInfo = new RequestGetCandidateInfo();
        reqCandidateInfo.Method = 'GETID';
        reqCandidateInfo.UserID = Userinfo.getUserName(); //TODO
        reqCandidateInfo.EXTERNALSYSTEMID = String.valueOf(candID);
        reqCandidateInfo.EXTERNALSYSTEMNAME = 'Salesforce';
        
        return getPII_Info(reqCandidateInfo);
    }
    
    public List<CandidateInfo> getListPII_Info(string fName, string lName){     
        RequestSearchCandidateInfo srchCandidateInfo = new RequestSearchCandidateInfo();
        srchCandidateInfo.Method = 'GETNAME';
        srchCandidateInfo.EXTERNALSYSTEMNAME = 'Salesforce';
        srchCandidateInfo.ENTITY_NAME = 'Candidate__c';
        srchCandidateInfo.FIRST_NAME = fName;
        srchCandidateInfo.LAST_NAME = lName;
        
        return getListPII_Info(srchCandidateInfo);
    }
    
    public CandidateInfo getPII_Info(RequestGetCandidateInfo reqCandidateInfo){  
            string sfObjId = null;
            String retResponse = null;  
             
        try{  
            //call webservice
            SJM_Integrations__c sjmIntegration = getServiceCredentials(CANDIDATE_SERVICE);
            if(sjmIntegration == null) throw new UnableToReachSJMException('No SJM integration defined for request: '+ CANDIDATE_SERVICE);
            string endPoint = sjmIntegration.Web_Service_Endpoint__c; //+ '/' + Integer.valueOf(externalID);
            
            HttpRequest req = getHttpReqWithAuthHeader(endPoint, 
                                                       sjmIntegration.Web_Service_User__c, 
                                                       sjmIntegration.Web_Service_Password__c,
                                                       'POST');
            
            string requestJson = JSON.serialize(reqCandidateInfo);
            
            Http http = new Http();
            HTTPResponse res= null;
            sfObjId = reqCandidateInfo.EXTERNALSYSTEMID;
             
            System.debug('*** SJM Req JSON ' + requestJson);
            System.debug('*** SJM Req EndPoint ' + endPoint);
            
            
            req.setBody(requestJson);
            //req.setHeader('Content-Length',String.valueof(requestJson.length()));
            //Set Certificate for Two-Way SSL Authentication
            req.setClientCertificateName(CertName);
            req.setHeader('Content-Type', 'application/json');
            res = http.send(req);
            System.debug('*** SJM Res getHeaderKeys  '+ res.getHeaderKeys());
            System.debug('*** SJM Res getHeader(Content-Type)  '+ res.getHeader('Content-Type'));
            System.debug('*** SJM Res getHeader(Connection)  '+ res.getHeader('Connection'));
            System.debug('*** SJM Res getStatus  '+ res.getStatus());
            System.debug('*** SJM Res getStatusCode  '+ res.getStatusCode());            
            System.debug('*** SJM Content-Length - ' + String.valueof(requestJson.length()));            
            
            if((res.getStatusCode() == 200 || res.getBody().length() > 0) && res.getHeader('Content-Type') == 'application/json'){ 
                List<CandidateInfo> theStatus = new List<CandidateInfo>();
                String bodyResult;
                System.debug('*** SJM Response body '+ res.getBody());
                bodyResult = resBodyResult(res.getBody());
                System.debug('*** SJM Response bodyResult '+ bodyResult);
                if(bodyResult == 'Success')
                {
                    theStatus = (List<CandidateInfo>)JSON.deserialize(res.getbody(),List<CandidateInfo>.class);  
                    System.debug('*** SJM theStatus ' + theStatus);
                    retResponse = 'Success';
                } else if(bodyResult == 'Failure')
                {
                    ResponseErrorMessage errMsg = (ResponseErrorMessage)JSON.deserialize(res.getBody(),ResponseErrorMessage.class);
                    retResponse = errMsg.Status+' | '+errMsg.Description+' | '+errMsg.Message;
                    throw new InvalidServiceResponseException(retResponse+'. Status Code: ' + res.getStatusCode());
                }
                return (theStatus.size() > 0)? theStatus[0] : null;                
            }
            else{
                System.debug('*** SJM Response body IS NULL');
                retResponse = 'Failed to get Candidate Details. Status Code: '+res.getStatusCode();
                throw new InvalidServiceResponseException('Failed to get Candidate Details. Status Code: ' + res.getStatusCode());
                return null;
            }
        }        
        catch(Exception e){
            system.debug('@@Exception ' + e); 
            //createSJMErrorLog.createErrorRecord(sfObjId,String.valueOf(e.getTypeName()),String.valueOf(e.getMessage()));
            throw e;
        }        
    }      
    
    public List<CandidateInfo> getListPII_Info(RequestSearchCandidateInfo srchCandidateInfo){
        string sfObjId = null;
        String retResponse = null;
        
        try{  
            //call webservice
            SJM_Integrations__c sjmIntegration = getServiceCredentials(CANDIDATE_SERVICE);
            if(sjmIntegration == null) throw new UnableToReachSJMException('No SJM integration defined for request: '+ CANDIDATE_SERVICE);
            string endPoint = sjmIntegration.Web_Service_Endpoint__c; //+ '/' + Integer.valueOf(externalID);
            
            HttpRequest req = getHttpReqWithAuthHeader(endPoint, 
                                                       sjmIntegration.Web_Service_User__c, 
                                                       sjmIntegration.Web_Service_Password__c,
                                                       'POST');
            
            string requestJson = JSON.serialize(srchCandidateInfo);
            
            Http http = new Http();
            HTTPResponse res= null;
            System.debug('*** SJM Req JSON ' + requestJson);
            System.debug('*** SJM Req EndPoint ' + endPoint);
            
            
            req.setBody(requestJson);
            //req.setHeader('Content-Length',String.valueof(requestJson.length()));
            //Set Certificate for Two-Way SSL Authentication
            req.setClientCertificateName(CertName);
            req.setHeader('Content-Type', 'application/json');
            res = http.send(req);
            System.debug('*** SJM Res getHeaderKeys  '+ res.getHeaderKeys());
            System.debug('*** SJM Res getHeader(Content-Type)  '+ res.getHeader('Content-Type'));
            System.debug('*** SJM Res getHeader(Connection)  '+ res.getHeader('Connection'));
            System.debug('*** SJM Res getStatus  '+ res.getStatus());
            System.debug('*** SJM Res getStatusCode  '+ res.getStatusCode());            
            System.debug('*** SJM ' + 'Content-Length - ' + String.valueof(requestJson.length()));   
            
            
            if((res.getStatusCode() == 200 || res.getBody().length() > 0) && res.getHeader('Content-Type') == 'application/json'){ 
                List<CandidateInfo> theStatus = new List<CandidateInfo>();
                String bodyResult;
                System.debug('*** SJM Response body '+ res.getBody());
                bodyResult = resBodyResult(res.getBody());
                System.debug('*** SJM Response bodyResult '+ bodyResult);
                
                if(bodyResult == 'Success')
                {
                    theStatus = (List<CandidateInfo>)JSON.deserialize(res.getbody(),List<CandidateInfo>.class);  
                    System.debug('*** SJM theStatus ' + theStatus);
                    retResponse = 'Success';
                } else if(bodyResult == 'Failure')
                {
                    ResponseErrorMessage errMsg = (ResponseErrorMessage)JSON.deserialize(res.getBody(),ResponseErrorMessage.class);
                    retResponse = errMsg.Status+' | '+errMsg.Description+' | '+errMsg.Message;
                    throw new InvalidServiceResponseException(retResponse+'. Status Code: ' + res.getStatusCode());
                }
                return (theStatus.size() > 0)? theStatus : null;
            }
            else{
                System.debug('*** SJM Response body IS NULL');
                retResponse = 'Failed to get Candidate Details. Status Code: '+res.getStatusCode();
                throw new InvalidServiceResponseException('Failed to get Candidate Details. Status Code: ' + res.getStatusCode());
                return null;
            }
        }
        catch(Exception e){  
            system.debug('@@Exception ' + e);
            //createSJMErrorLog.createErrorRecord(sfObjId,String.valueOf(e.getTypeName()),String.valueOf(e.getMessage()));
            throw e;
        } 
    }
    
    public List<CandidateInfo> getListViewPII_Info(RequestGetListCandidateInfo reqListCandidateInfo){     
        string sfObjId = null;
        String retResponse = null;
        
        try{  
            //call webservice
            SJM_Integrations__c sjmIntegration = getServiceCredentials(CANDIDATE_SERVICE);
            if(sjmIntegration == null) throw new UnableToReachSJMException('No SJM integration defined for request: '+ CANDIDATE_SERVICE);
            string endPoint = sjmIntegration.Web_Service_Endpoint__c; //+ '/' + Integer.valueOf(externalID);
            
            HttpRequest req = getHttpReqWithAuthHeader(endPoint, 
                                                       sjmIntegration.Web_Service_User__c, 
                                                       sjmIntegration.Web_Service_Password__c,
                                                       'POST');
            
            string requestJson = JSON.serialize(reqListCandidateInfo);
            
            Http http = new Http();
            HTTPResponse res= null;
            System.debug('*** SJM Req JSON ' + requestJson);
            System.debug('*** SJM Req EndPoint ' + endPoint);
            string finalRequestJson = formatListJSON(requestJson);
            System.debug('*** SJM Final Req JSON ' + finalRequestJson);
            
            req.setBody(finalRequestJson);
            //req.setHeader('Content-Length',String.valueof(requestJson.length()));
            //Set Certificate for Two-Way SSL Authentication
            req.setClientCertificateName(CertName);
            req.setHeader('Content-Type', 'application/json');
            res = http.send(req);
            System.debug('*** SJM Res getHeaderKeys  '+ res.getHeaderKeys());
            System.debug('*** SJM Res getHeader(Content-Type)  '+ res.getHeader('Content-Type'));
            System.debug('*** SJM Res getHeader(Connection)  '+ res.getHeader('Connection'));
            System.debug('*** SJM Res getStatus  '+ res.getStatus());
            System.debug('*** SJM Res getStatusCode  '+ res.getStatusCode());            
            System.debug('*** SJM ' + 'Content-Length - ' + String.valueof(requestJson.length())); 
            
            
            if((res.getStatusCode() == 200 || res.getBody().length() > 0) && res.getHeader('Content-Type') == 'application/json'){ 
                List<CandidateInfo> theStatus = new List<CandidateInfo>();
                String bodyResult;
                System.debug('*** SJM Response body '+ res.getBody());
                bodyResult = resBodyResult(res.getBody());
                System.debug('*** SJM Response bodyResult '+ bodyResult);
                
                if(bodyResult == 'Success')
                {
                    theStatus = (List<CandidateInfo>)JSON.deserialize(res.getbody(),List<CandidateInfo>.class);  
                    System.debug('*** SJM theStatus ' + theStatus);
                    retResponse = 'Success';
                } else if(bodyResult == 'Failure')
                {
                    ResponseErrorMessage errMsg = (ResponseErrorMessage)JSON.deserialize(res.getBody(),ResponseErrorMessage.class);
                    retResponse = errMsg.Status+' | '+errMsg.Description+' | '+errMsg.Message;
                    throw new InvalidServiceResponseException(retResponse+'. Status Code: ' + res.getStatusCode());
                }
                return (theStatus.size() > 0)? theStatus : null;
            }
            else{
                System.debug('*** SJM Response body IS NULL');
                retResponse = 'Failed to get Candidate Details. Status Code: '+res.getStatusCode();
                throw new InvalidServiceResponseException('Failed to get Candidate Details. Status Code: ' + res.getStatusCode());
                return null;
            }
        }
        catch(Exception e){  
            system.debug('@@Exception ' + e);
            //createSJMErrorLog.createErrorRecord(sfObjId,String.valueOf(e.getTypeName()),String.valueOf(e.getMessage()));
            throw e;
        } 
    }
    
    private static HttpRequest getHttpReqWithAuthHeader(String endpoint, String user, String password, string httpMethod){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(httpMethod);
        Blob headerValue = Blob.valueOf(user + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        //System.debug('*** SJM Username '+ user);
        //req.setHeader('Content-Length',String.valueOf(soapRequest.length()));
        req.setHeader('Content-Type', 'text/json');
        return req;
    }
    
    private static SJM_Integrations__c getServiceCredentials(String serviceName){
        SJM_Integrations__c sjmIntegration = SJM_Integrations__c.getValues(serviceName);
        return sjmIntegration != null ? sjmIntegration : null;
        
    }
    
    public static String formatListJSON(String lreq) {
        if(lreq == null) return '';
        String remSqrBrkts = lreq.replaceAll('\\[', '').replaceAll('\\]','');
        
        //Getting Candidate Key Prefix
        Schema.DescribeSObjectResult r = Candidate__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        String finalReq = remSqrBrkts.replaceAll(',"'+keyPrefix, ',"EXTERNALSYSTEMID":"'+keyPrefix);
        System.debug('*** SJM Request String - ' + finalReq);
        return finalReq;
    }
    
    public static Date parseDate(String inDate) {
        Date dateRes = null;
        /*try {
String candDate = inDate.substring(0,Math.min(10,inDate.length()));
dateRes = Date.parse(candDate);
}
catch (Exception e) {}
if (dateRes == null) {    */    
        try {
            String candDate = inDate.substring(0,10);
            dateRes = Date.valueOf(candDate);
        }
        catch (Exception e) {}
        //}
        
        return dateRes;
    }
    
    public static String formatPhone(String cphone) {
        if(cphone == null) return '';
        String fphone = cphone.replaceAll('\\D','');
        
        if (fphone.length() == 10) {
            fphone = usaFormat(fphone);
            return fphone;
        }
        else {
            return cphone;
        }
        
    }
    
    static String usaFormat(String s) {
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
    }
    
    public static String resBodyResult(String resBody) {
        map<string, Object> untypedMap = new map<string, Object>();
        List<Object> untypedList = new List<Object>();
        System.debug('*** SJM Response body '+ resBody);
        
        if(JSON.deserializeUntyped(resBody) instanceof List<Object>)
        {
            untypedList = (List<Object>)JSON.deserializeUntyped(resBody);
        } else if(JSON.deserializeUntyped(resBody) instanceof map<string, Object>){
            untypedMap = (map<string, Object>)JSON.deserializeUntyped(resBody);
        }
        
        
        System.debug('*** SJM Response body untypedList - '+ untypedList);
        
        for(object o : untypedList)
        {
            System.debug('*** SJM Response body untypedList o - '+ o);  
            untypedMap = (map<string, Object>)o;
            System.debug('*** SJM Response body String sMap - '+ untypedMap); 
            System.debug('*** SJM sMap.get(Status) - '+ untypedMap.get('Status')); 
        }
        return String.ValueOf(untypedMap.get('Status'));   
    }
    
    public class UnableToReachSJMException extends Exception {}
    public class InvalidServiceResponseException extends Exception {}
}