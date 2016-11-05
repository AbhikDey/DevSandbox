public class SFCalloutUtil_AC {

    public static HttpRequest getHttpRequest(String endpoint, String reqType){
        HttpRequest req = new HttpRequest();                
        LoginResult result = SFCalloutUtil_AC.getLoginInfo();
        req.setEndpoint(result.instance_url + endpoint);
        system.debug('sessionId = '+result.access_token);
        req.setHeader('Authorization','OAuth '+result.access_token);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod(reqType);
        return req;
        
    }
    
   //This method is get salesforce user session id/access token
    public static LoginResult getLoginInfo(){
        Http h = new Http();
        HttpResponse res = new Httpresponse();
        HttpRequest req = new HttpRequest();
        Access_Settings__c testSetting = Access_Settings__c.getInstance('TEST');
        String endpoint = testSetting.Endpoint__C +'/services/oauth2/token?grant_type=password&client_id='
                          +testSetting.Consumer_Key__c+'&client_secret='+testSetting.Consumer_Secret__c
                          +'&username='+testSetting.Username__c+'&password='+testSetting.password__c;
        req.setEndpoint(endpoint);
        //req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        res = h.send(req); 
        system.debug('response = '+res.getBody());
        LoginResult resultWrapper = (LoginResult)JSON.deserialize(res.getBody(), LoginResult.class); 
        return resultWrapper;
        
    }
    
     public class LoginResult{
       public String access_token;
       public String instance_url;
       public String id;
       public String token_type;
       public String issued_at;
       public String signature; 
    }    
    
    //sample rest api call to salesforce
    public static void photocall(String fromID, String toID ){
                
        HttpRequest req = new HttpRequest();                
        LoginResult login = SFCalloutUtil_AC.getLoginInfo();
                                    
        String fromUserId = fromID;
        String toUserId = toID;
        
        
        req.setEndpoint(login.instance_url+'/services/data/v34.0/chatter/users/'+fromUserId+'/photo');
        req.setHeader('Authorization','OAuth '+login.access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        http h = new http();
        HttpResponse res = h.send(req);                        
        system.debug('response = '+res.getBody());
        
        Map<String,Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        String fullEmailPhotoUrl = (String)responseMap.get('fullEmailPhotoUrl');
        system.debug('fullEmailPhotoUrl = '+fullEmailPhotoUrl);
        
        
        HttpRequest req1 = new HttpRequest();
        req1.setEndPoint(fullEmailPhotoUrl);
        req1.setMethod('GET');
        HttpResponse res1 = new Http().send(req1);
        system.debug('res1 body = '+res1.getBody());
        Blob b = res1.getBodyAsBlob();
        ConnectApi.ChatterUsers.setPhoto(null, toUserId, 
             new ConnectApi.BinaryInput(b, res1.getHeader('Content-Type'),'userImage.jpg'));
                
    }
    
    //Commented By Brahma  
    /*  
    public static void massphotocall(){
                
        HttpRequest req = new HttpRequest();                
        LoginResult login = SFCalloutUtil_AC.getLoginInfo();
        
        List<User> usrList = [Select Id, ANZ_ID__c From User Where ANZ_ID__c != null];
        Map<Id,User> usrMap = New Map<Id,User>(usrList);
        
         
        for(String key:usrMap.keySet()){ 
            System.debug('ID - '+key);
            System.debug('ANZ ID - '+usrMap.get(key).ANZ_ID__c);
        }
        
        
        for(String key:usrMap.keySet()){
                    
            Id fromUserId = usrMap.get(key).ANZ_ID__c;
            Id toUserId = key;
            
            
            req.setEndpoint(login.instance_url+'/services/data/v34.0/chatter/users/'+fromUserId+'/photo');
            req.setHeader('Authorization','OAuth '+login.access_token);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('GET');
            http h = new http();
            HttpResponse res = h.send(req);                        
            system.debug('response = '+res.getBody());
            
            Map<String,Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            String fullEmailPhotoUrl = (String)responseMap.get('fullEmailPhotoUrl');
            system.debug('fullEmailPhotoUrl = '+fullEmailPhotoUrl);
            
            
            HttpRequest req1 = new HttpRequest();
            req1.setEndPoint(fullEmailPhotoUrl);
            req1.setMethod('GET');
            HttpResponse res1 = new Http().send(req1);
            system.debug('res1 body = '+res1.getBody());
            Blob b = res1.getBodyAsBlob();
            ConnectApi.ChatterUsers.setPhoto(null, toUserId, 
                 new ConnectApi.BinaryInput(b, res1.getHeader('Content-Type'),'userImage.jpg'));
            
            //Re-Initialize
            //fromUserId = null;
            //toUserId = null;
            //fullEmailPhotoUrl = null;
        }
        
        /*
        for (ConnectApi.BatchResult eachResult : ConnectApi.ChatterUsers.getUserBatch(null, new List<Id> { fromUserId })) {
             ConnectApi.User eachUser = (ConnectApi.User)eachResult.getResult();
             ConnectApi.Photo p = ConnectApi.ChatterUsers.getPhoto(null, fromUserId);
             Http h = new Http();
             HttpRequest req = new HttpRequest();
             req.setEndPoint(p.fullEmailPhotoUrl);
             req.setMethod('GET');
             HttpResponse res = new Http().send(req);
             Blob b = res.getBodyAsBlob();
             ConnectApi.ChatterUsers.setPhoto(null, toUserId, 
                 new ConnectApi.BinaryInput(b, res.getHeader('Content-Type'),'user3.jpg'));
        }*/
        
        
    //}*/

}