global class PII_InfoServiceMockImpl implements  HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
        string method = 'GETID';
        string method1 = 'GETID';

        System.debug('PII_InfoServiceMockImpl > req.getBody() = ' + req.getbody());
        PII_Info.RequestGetCandidateInfo reqCandidateInfo = (PII_Info.RequestGetCandidateInfo)JSON.deserialize(req.getbody(),PII_Info.RequestGetCandidateInfo.class);
        method = reqCandidateInfo.METHOD;
        System.debug('PII_InfoServiceMockImpl > Method = ' + method);
        
        PII_Info.RequestGetListCandidateInfo reqListCandidateInfo = (PII_Info.RequestGetListCandidateInfo)JSON.deserialize(req.getbody(),PII_Info.RequestGetListCandidateInfo.class);
        method1 = reqListCandidateInfo.METHOD;
        System.debug('PII_InfoServiceMockImpl > Method1 = ' + method1);
        
        if (method == 'GETID'){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if (reqCandidateInfo.ID == '3'){
                res.setStatusCode(404);
            }
            else if (reqCandidateInfo.ID == '2'){
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
                throw e;
            }
            else{
                res.setBody('[{"Method":"GETID","Status":"Success","FIRST_NAME":"TEST USER FIRST", "LAST_NAME":"TEST USER LAST"}]');
                res.setStatusCode(200);
            }
            
            return res;
        }
        
        if (method1 == 'GETID'){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if (reqListCandidateInfo.EXTERNALSYSTEMID[0] == '3'){
                res.setStatusCode(200);
                res.setBody('{"Status":"Failure","Description":"Validation Error","Message":"The following field is not in the list of valid values: Method,GETIDx"}');

            }
            else if (reqListCandidateInfo.EXTERNALSYSTEMID[0] == '2'){
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
                throw e;
            }
            else{
                res.setBody('[{"Method":"GETID","Status":"Success","FIRST_NAME":"TEST USER FIRST", "LAST_NAME":"TEST USER LAST"}]');
                res.setStatusCode(200);
            }
            
            return res;
        } 
        
        if (method == 'POST'){
            HttpResponse res = new HttpResponse();
            PII_Info.CandidateInfo canInfo = new PII_Info.CandidateInfo();
            canInfo.FIRST_NAME = 'Test';
            canInfo.LAST_NAME = 'TEST';
            canInfo.ID = '10';
            canInfo.DATE_OF_BIRTH = '01/01/2001';
            canInfo.Status = 'Success';
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(Json.serialize(canInfo));
            res.setStatusCode(201);
            return res;
        } 
        
        if (method == 'PUT'){
            HttpResponse res = new HttpResponse();
            PII_Info.CandidateInfo canInfo = new PII_Info.CandidateInfo();
            canInfo.FIRST_NAME = 'Test';
            canInfo.LAST_NAME = 'TEST';
            canInfo.ID = '10';
            canInfo.DATE_OF_BIRTH = '01/01/2001';
            canInfo.Status = 'Success';
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(Json.serialize(canInfo));
            res.setStatusCode(200);
            return res;
        } 
        
        if (method == 'GETNAME'){
            HttpResponse res = new HttpResponse();
            
            List<PII_Info.CandidateInfo> canInfos = new List<PII_Info.CandidateInfo>();
            
            candidateSearchExtension srchCandidateInfo = 
                (candidateSearchExtension)JSON.deserialize(req.getbody(),candidateSearchExtension.class);
			System.debug('PII_InfoMockImpl > srchCandidateInfo :' + srchCandidateInfo);
            if (srchCandidateInfo.SearchFirstName == ' ' && srchCandidateInfo.SearchLastName == ' '){
                
            }
            else{
            PII_Info.CandidateInfo canInfo1 = new PII_Info.CandidateInfo();
            canInfo1.FIRST_NAME = 'Test';
            canInfo1.LAST_NAME = 'Test';
            canInfo1.ID = '10';
            canInfo1.DATE_OF_BIRTH = '01/01/2001';
            canInfo1.Status = 'Success';
            canInfo1.EXTERNALSYSTEMID = 'a0FP0000003jsCWAAH';
            canInfos.add(canInfo1);
            
            PII_Info.CandidateInfo canInfo2 = new PII_Info.CandidateInfo();
            canInfo2.FIRST_NAME = 'Test';
            canInfo2.LAST_NAME = 'Test';
            canInfo2.ID = '11';
            canInfo2.DATE_OF_BIRTH = '01/01/2002';
            canInfo2.Status = 'Success';
            canInfo2.EXTERNALSYSTEMID = 'a0FP0000003jsCWAAH';
            canInfos.add(canInfo2);
            }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(Json.serialize(canInfos));
            res.setStatusCode(200);
            return res;
        } else return null;
    }
}