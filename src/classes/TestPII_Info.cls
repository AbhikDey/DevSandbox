@isTest
public class TestPII_Info {
    Private static List<String> getTestProfilesList () {
        List<String> profiles = new List<String>();
        profiles.add('CLAG Agent (New)');
        profiles.add('CLAG Manager');
        profiles.add('CLAG Preferencial Client User');
        profiles.add('CLAG System Administrator');
        
        return profiles;
    }
    
    
    private static final String CANDIDATE_SERVICE='CandidateService';
    
    @isTest
    static void TestPutPII_Info(){
        String extId = '1';
        PII_Info piiClass = new PII_Info();
        
        //setup things
        Test.setMock(HttpCalloutMock.class, new PII_InfoServiceMockImpl());
        setupSettings();
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        //create new user
        User u = new User(Alias = 'standt7', Email='standarduser6633@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing8156', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6633@testorg.com',Scheduler_Country_Code__c = 'DE');
        insert u;
        system.assertNotEquals(null, u.Id );    
        Candidate__c myCand = new Candidate__c();
        myCand.External_System_Id__c = '5';
        insert myCand;
        PII_Info.CandidateInfo newCandidate = new PII_Info.CandidateInfo();
        newCandidate.FIRST_NAME = 'TEST';
        newCandidate.LAST_NAME = 'TEST';
        newCandidate.METHOD = 'POST';
        newCandidate.UserID = 'akhanna02@sjm.com';
        newCandidate.Status = 'Success';
        newCandidate.ID = '1';
        newCandidate.EXTERNALSYSTEMNAME = 'Salesforce';
        newCandidate.EXTERNALSYSTEMID = myCand.Id;
        newCandidate.ENTITY_NAME ='Candidate__c';
        newCandidate.GENDER = 'Male';
        newCandidate.DATE_OF_BIRTH = '01/01/2011';
        newCandidate.HOME_PHONE = '1231231233';
        newCandidate.CELL_PHONE = '1231231234';
        newCandidate.ADDRESS_LINE1 = '6300 Bee Caves Rd';
        newCandidate.ADDRESS_LINE2 = 'Suite 200';
        newCandidate.ADDRESS_CITY = 'Austin';
        newCandidate.ADDRESS_STATE_PROVINCE = 'TX';
        newCandidate.ADDRESS_COUNTRY = 'USA';
        newCandidate.CREATED_BY = 'akhanna02@SJM.COM';
        newCandidate.CREATED_DT = string.valueOf(Datetime.now());
        newCandidate.MODIFIED_BY = 'akhanna02@sjm.com';
        newCandidate.MODIFIED_DT = string.valueOf(Datetime.now());
        
        piiClass.UpdateAuditDetails(newCandidate);

        piiClass.updatePII_Info(newCandidate);
        piiClass.createPII_Info(newCandidate);
                
        //Search Request Candidate
        PII_Info.RequestSearchCandidateInfo Reqsearch = new PII_Info.RequestSearchCandidateInfo();
        
        Reqsearch.EXTERNALSYSTEMNAME = 'Salesforce';
        
        Reqsearch.FIRST_NAME = 'TEST';
        Reqsearch.LAST_NAME = 'TEST';
        Reqsearch.ENTITY_NAME ='Candidate__c';
        Reqsearch.METHOD = 'POST';
        
        //  PII_Info.RequestGetCandidateInfo Reqsearch1 = new PII_Info.RequestGetCandidateInfo();
        // PII_Info.getListPII_Info('33','test');
        
        Test.stopTest();
    }
    
    
    
    @isTest 
    static void TestPostPII_Info(){
        String extId = '1';
        PII_Info piiClass = new PII_Info();
        
        //setup things
        Test.setMock(HttpCalloutMock.class, new PII_InfoServiceMockImpl());
        setupSettings();
        
        Test.startTest();
        Candidate__c myCand = new Candidate__c();
        myCand.External_System_Id__c = '4';
        insert myCand;
        PII_Info.CandidateInfo newCandidate = new PII_Info.CandidateInfo();
        newCandidate.FIRST_NAME = 'TEST';
        newCandidate.LAST_NAME = 'TEST';
        newCandidate.METHOD = 'POST';
        
        
        newCandidate.ID = '1';
        newCandidate.EXTERNALSYSTEMNAME = 'Salesforce';
        newCandidate.EXTERNALSYSTEMID = myCand.Id;
        newCandidate.ENTITY_NAME ='Candidate__c';
        newCandidate.GENDER = 'Male';
        newCandidate.DATE_OF_BIRTH = '01/01/2011';
        newCandidate.HOME_PHONE = '1231231233';
        newCandidate.CELL_PHONE = '1231231234';
        newCandidate.ADDRESS_LINE1 = '6300 Bee Caves Rd';
        newCandidate.ADDRESS_LINE2 = 'Suite 200';
        newCandidate.ADDRESS_CITY = 'Austin';
        newCandidate.ADDRESS_STATE_PROVINCE = 'TX';
        newCandidate.ADDRESS_COUNTRY = 'USA';
        newCandidate.CREATED_BY = null;
        newCandidate.CREATED_DT = string.valueOf(Datetime.now());
        newCandidate.MODIFIED_BY = 'akhanna02@sjm.com';
        newCandidate.MODIFIED_DT = string.valueOf(Datetime.now());
        
        piiClass.InsertAuditDetails(newCandidate);
        
        piiClass.createPII_info(newCandidate);
        //test create
        
        //System.assert(canInfo != null);
        //System.assertNotEquals(canInfo == null, canInfo != null);
        Test.stopTest();
    }
    
    @isTest 
    static void TestGetPII_Info(){
        String extId = '1'; //good response
        String extId2 = '2'; //exception response
        String extId3 = '3'; //null response
        
        
        PII_Info piiClass = new PII_Info();
        
        //setup things
        Test.setMock(HttpCalloutMock.class, new PII_InfoServiceMockImpl());
        setupSettings();
        
        Test.startTest();
        PII_Info.CandidateInfo canInfo = null;
        PII_Info.CandidateInfo canInfo2 = null;
        PII_Info.CandidateInfo canInfo3 = null;
        PII_Info.CandidateInfo canInfo4 = null;
        PII_Info.CandidateInfo canInfo5 = null;
        List<PII_Info.CandidateInfo> canInfos = null;
        try{
            //normal happy path
            canInfo = piiClass.getPII_Info(extId);
            System.assert(canInfo != null);
            System.assertNotEquals(canInfo == null, canInfo != null);
            
            //normal happy path as object
            PII_Info.RequestGetCandidateInfo reqInfo = new PII_Info.RequestGetCandidateInfo();
            Candidate__c myCand = new Candidate__c();
            myCand.External_System_Id__c = '10';
            insert myCand;
            reqInfo.EXTERNALSYSTEMID = myCand.Id;
            reqInfo.METHOD = 'GETID';
            canInfo4 = piiClass.getPII_Info(reqInfo);
            //System.assert(canInfo4 != null);
            //System.assertNotEquals(canInfo4 == null, canInfo4 != null);
            
            //null path
            canInfo3 = piiClass.getPII_Info(extId3);
            System.assert(canInfo3 == null);
            
            //Test getPIIInfo for ID
            Candidate__c myCand1 = new Candidate__c();
            myCand1.External_System_Id__c = '11';
            insert myCand1;
            canInfo5 = piiClass.getPII_Info(myCand1.Id);
            //System.assert(canInfo5 != null);
            
            //list
            canInfos = piiClass.getListPII_Info('test', 'test');
            System.assert(canInfos != null);
            
            //exception path -- needs to be at the bottom
            canInfo2 = piiClass.getPII_Info(extId2);
            
        }
        catch(CalloutException ex){
            System.assert(ex != null);
        } 
        
        
        Test.stopTest();
    }
    
    @isTest 
    static void TestGetListViewPII_Info(){
        List<String> extId = new List<String>{'1'}; //good response
        List<String> extId2 = new List<String>{'2'}; //exception response
        List<String> extId3 = new List<String>{'3'}; //null response
        
        
        PII_Info piiClass = new PII_Info();
        
        //setup things
        Test.setMock(HttpCalloutMock.class, new PII_InfoServiceMockImpl());
        setupSettings();
        
        Test.startTest();
        List<PII_Info.CandidateInfo> canInfo1 = null;
        List<PII_Info.CandidateInfo> canInfo2 = null;
        List<PII_Info.CandidateInfo> canInfo3 = null;
        List<PII_Info.CandidateInfo> canInfo4 = null;
        List<PII_Info.CandidateInfo> canInfo5 = null;
        List<PII_Info.CandidateInfo> canInfo6 = null;
        try{
            //normal happy path
            Candidate__c myCand = new Candidate__c();
            myCand.External_System_Id__c = '1';
            insert myCand;
            canInfo1 = piiClass.getListViewPII_Info(new List<ID>{myCand.Id});
            System.assert(canInfo1 != null);
            System.assertNotEquals(canInfo1 == null, canInfo1 != null);
            
            //normal happy path as object
            PII_Info.RequestGetListCandidateInfo reqInfo = new PII_Info.RequestGetListCandidateInfo();
            reqInfo.EXTERNALSYSTEMID = new List<String>{'1'};
            reqInfo.Method = 'GETID';
            reqInfo.EXTERNALSYSTEMNAME = 'Salesforce';
            canInfo4 = piiClass.getListViewPII_Info(reqInfo);
            System.assert(canInfo4 != null);
            System.assertNotEquals(canInfo4 == null, canInfo4 != null);
            
            //null path
            PII_Info.ResponseErrorMessage eMsg = new PII_Info.ResponseErrorMessage();
            eMsg.Status = 'Failure';
            eMsg.Description = 'Validation Error';
   			eMsg.Message = 'The following field is not in the list of valid values: Method,GETIDx';
            canInfo3 = piiClass.getListViewPII_Info(extId3);
            System.assert(canInfo3 == null);                        
            
            //exception path -- needs to be at the bottom
            canInfo2 = piiClass.getListViewPII_Info(extId2);
            
        }
        catch(CalloutException ex){
            System.assert(ex != null);
        } 
        
        
        Test.stopTest();
    }
    
    @isTest 
    static void TestMiscMethods(){
        
        
        Test.StartTest();
        Date outDate = PII_Info.parseDate(string.valueOf(Datetime.now()));
        System.debug('TestPII_Info > outdate > ' + outDate);
        System.assert(outDate != null);
        
        String formattedPh = PII_Info.formatPhone('123 123 1233');
        System.debug('TestPII_Info > formattedPh > ' + formattedPh);
        System.assert(formattedPh != null);
        
        String lreq = '';
        String resJSON = PII_Info.formatListJSON(lreq);
        
        Test.stopTest();
    }
    
    static void setupSettings(){
        SJM_Integrations__c sjmIntegration = new SJM_Integrations__c();
        sjmIntegration.Name = CANDIDATE_SERVICE;
        sjmIntegration.Web_Service_Endpoint__c = 'URL';
        sjmIntegration.Web_Service_Name__c = CANDIDATE_SERVICE;
        sjmIntegration.Web_Service_User__c = 'USERNAME';
        sjmIntegration.Web_Service_Password__c = 'PASSWORD';
        insert sjmIntegration;
    }
}