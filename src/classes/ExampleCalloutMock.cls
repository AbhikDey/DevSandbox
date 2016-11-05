@isTest
global class ExampleCalloutMock implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
  //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
  //System.assertEquals('GET', req.getMethod());

    HttpResponse res = new HttpResponse();
    //res.setStatus('OK');
    //res.setStatusCode(200);
    //res.setBody('GREAT SCOTT');
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{"foo":"bar"}');
    res.setStatusCode(200);
    return res;
    
  }
}