@isTest
public class TestCandidateExtension {

    private static final String CANDIDATE_SERVICE='CandidateService';

    @isTest static void TestcandidateControllerExtension(){
        //setup things
        Test.setMock(HttpCalloutMock.class, new PII_InfoServiceMockImpl());
        setupSettings();
        
        Test.startTest();
         Candidate__c cand = new Candidate__c();
         Date SD = Date.today();
         
         Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
         //create new account
         Account acc = new Account();
         acc.RecordTypeId = personAccRecTypeId;
         acc.Name = 'Rouel';
         acc.USD_AF_Region__c='SSP1';
         insert acc;
         
         //create new contact
         contact con = new contact();
         con.AccountID = acc.id;
         con.firstname = 'testfname';
         con.LastName = 'testLname';
         con.Email = 'test@test.com';
         con.Personal_Email__c = 'test1@test.com';
         con.Office_Phone__c = '12345789';
         con.HomePhone = '1211212';
         con.MobilePhone = '15665';
         insert con;    
         
         //create new user
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
         User u = new User(Alias = 'standt7', Email='standarduser6633@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing8156', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6633@testorg.com',Scheduler_Country_Code__c = 'DE');
         insert u;
         
         PageReference pageNewRef = Page.CreateNewCandidate;
         Test.setCurrentPage(pageNewRef);
         ApexPages.StandardController sc = new ApexPages.standardController(cand);
         candidateControllerExtension newCand = new candidateControllerExtension(sc);
         cand.Stage_Name__c = 'Identify';
         cand.Source__c = 'Referred by patient';
         cand.Referred_By__c = con.Id;
         cand.Referred_To__c = con.Id;
         cand.Schedule_Date__c = SD.addDays(20);
         cand.Case_Id__c = 'Ztx1234';
         cand.Procedure_Covered_By__c = u.Id;
         cand.Other_Authorization_Options__c = 'Auth by PTA complete';
         cand.Account__c = acc.id;
         cand.Comments__c = 'Test Insert - 1';
         newCand.FirstName = 'Test';
         newCand.LastName = 'Insert1';
         newCand.DateOfBirth = SD.addDays(-2000);
         newCand.Gender = 'Male';
         newCand.AddressLine1 = '6300 Bee Caves Rd';
         newCand.AddressLine2 = 'Suite 200';
         newCand.AddressCity = 'Austin';
         newCand.AddressState = 'TX';
         newCand.AddressCountry = 'USA';
         cand.Email__c = 'Test_Insert1@test.com';
         newCand.CellPhone = '1234567891';
         newCand.HomePhone = '1234567891';
         newCand.ExternalID = '1';
         
         //Get Gender Options
         newCand.getGenderOptions();          
         
         //Save Cand Record
         newCand.SaveRecord();  
         
         //Check if DOB greater than today
         newCand.DateOfBirth = SD.addDays(2);
         newCand.SaveRecord();
         
         //Cancel
         newCand.Cancel();
        
         // Cancel to show standard List View
         Candidate__c cand1 = new Candidate__c();
         ApexPages.StandardController sc1 = new ApexPages.standardController(cand1);
         candidateControllerExtension newCand1 = new candidateControllerExtension(sc1);
         newCand1.Cancel();        
         
         //Edit
         newCand.Edit();
         newCand.DateOfBirth = SD.addDays(-1000);
         newCand.SaveRecord();         
         
         //Get Candidate Profile info
         String fname = newCand.FirstName;
         String lname = newCand.LastName;
         Date dob = newCand.DateOfBirth;
         String gen = newCand.Gender;
         String add1 = newCand.AddressLine1;
         String add2 = newCand.AddressLine2;
         String city = newCand.AddressCity;
         String state = newCand.AddressState;
         String country = newCand.AddressCountry;
         String cphone = newCand.CellPhone;
         String hphone = newCand.HomePhone;
         String cBy = newCand.getCreatedBy();
         //DateTime cDt = newCand.getCreatedDt();
         String mBy = newCand.getModifiedBy();
         //DateTime mDt = newCand.getModifiedDt();
         String uName = newCand.getUserId_Name();
         String fDob = newCand.getFormattedDateOfBirth();
         String cid = newCand.getID();
         String errMsg = newCand.getErrorMessage();
         String eid= newCand.ExternalID;   
        
         //Getting Candidate details
         //newCand.refreshPII_Info();
         
         //Search Candidate
         List<PII_Info.CandidateInfo> theCandList1 = null;
         Candidate__c cand2 = new Candidate__c();
          
         PageReference searchPage1 = Page.SearchCandidate;
         Test.setCurrentPage(searchPage1);
         ApexPages.StandardController sc3 = new ApexPages.standardController(cand2);
         candidateSearchExtension searchCand1 = new candidateSearchExtension(sc3);
         System.debug('TestcandidateSearchExtension 1');
          //Searching
         searchCand1.SearchFirstName='Test';
         searchCand1.SearchLastName='Insert';
         searchCand1.SearchForCandidates();
         theCandList1=searchCand1.theCandidateInfoList;
         System.debug('TestcandidateSearchExtension 2');
        
        //Candidate ListView
         List<PII_Info.CandidateInfo> theCandListView = null;
         Candidate__c cand3 = new Candidate__c();
          
         PageReference listViewPage = Page.CandidateListView1;
         Test.setCurrentPage(listViewPage);        
         candidateListViewExtension1 listViewCand = new candidateListViewExtension1();   
         List<CandidateWrapper> testWrap = new List<CandidateWrapper>();
         testWrap.add(new CandidateWrapper(cand,'Insert','Test'));
        
        Test.stopTest();
    }
        
    @isTest static void TestcandidateViewExtension(){
                 
         Candidate__c cand1 = new Candidate__c();
         Date SD = Date.today();
         
         Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SJM Customer').getRecordTypeId();
         //create new account
         Account acc1 = new Account();
         acc1.RecordTypeId = personAccRecTypeId;
         acc1.Name = 'Roue2';
         acc1.USD_AF_Region__c='SSP1';
         insert acc1;
         
         //create new contact
         contact con1 = new contact();
         con1.AccountID = acc1.id;
         con1.firstname = 'testfname';
         con1.LastName = 'testLname1';
         con1.Email = 'test1@test.com';
         con1.Personal_Email__c = 'test2@test.com';
         con1.Office_Phone__c = '12345789';
         con1.HomePhone = '1211212';
         con1.MobilePhone = '15665';
         insert con1;    
         
         //create new user
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
         User u1 = new User(Alias = 'standt7', Email='standarduser6633@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing8157', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Region__c = 'SSP1',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6634@testorg.com',Scheduler_Country_Code__c = 'DE');
         insert u1;
         
         
         cand1.Stage_Name__c = 'Identify';
         cand1.Source__c = 'Referred by patient';
         cand1.Referred_By__c = con1.Id;
         cand1.Referred_To__c = con1.Id;
         cand1.Schedule_Date__c = SD.addDays(20);
         cand1.Case_Id__c = 'Ztx1235';
         cand1.Procedure_Covered_By__c = u1.Id;
         cand1.Other_Authorization_Options__c = 'Auth by PTA complete';
         cand1.Account__c = acc1.id;
         cand1.Comments__c = 'Test Insert - 2';
         cand1.Email__c = 'Test_Insert2@test.com';
         
         //Insert
         insert cand1;
         
        String extId = cand1.Id;
        PII_Info piiClass = new PII_Info();
        
        //setup things
        Test.setMock(HttpCalloutMock.class, new PII_InfoServiceMockImpl());
        setupSettings();
        
        Test.startTest();
        PII_Info.CandidateInfo newCandidate = new PII_Info.CandidateInfo();
        newCandidate.FIRST_NAME = 'Test';
        newCandidate.LAST_NAME = 'Insert1';
        newCandidate.METHOD = 'POST';
        
        
        newCandidate.ID = '1';
        newCandidate.EXTERNALSYSTEMNAME = 'Salesforce';
        newCandidate.EXTERNALSYSTEMID = extId;
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
        newCandidate.MODIFIED_BY = null;
        newCandidate.MODIFIED_DT = string.valueOf(Datetime.now());
        
        //Creating Candidate Profile
        piiClass.InsertAuditDetails(newCandidate);        
        piiClass.createPII_info(newCandidate);
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(cand1);
        candidateViewExtension readCand = new candidateViewExtension(sc1);
        readCand.refreshPII_Info();
        
         //Set Candidate Profile info
         readCand.FirstName = 'Test';
         readCand.LastName = 'Insert1';
         readCand.DateOfBirth = SD.addDays(-2000);
         readCand.Gender = 'Male';
         readCand.AddressLine1 = '6300 Bee Caves Rd';
         readCand.AddressLine2 = 'Suite 200';
         readCand.AddressCity = 'Austin';
         readCand.AddressState = 'TX';
         readCand.AddressCountry = 'USA';
         readCand.CellPhone = '1234567891';
         readCand.HomePhone = '1234567891';
         readCand.ExternalID = cand1.Id;
         
         //Save Candidate Record
         update cand1;
         
         //Get Candidate Profile info
         String fname = readCand.FirstName;
         String lname = readCand.LastName;
         Date dob = readCand.DateOfBirth;
         String gen = readCand.Gender;
         String add1 = readCand.AddressLine1;
         String add2 = readCand.AddressLine2;
         String city = readCand.AddressCity;
         String state = readCand.AddressState;
         String country = readCand.AddressCountry;
         String cphone = readCand.CellPhone;
         String hphone = readCand.HomePhone;
         String cBy = readCand.getCreatedBy();
         String mBy = readCand.getModifiedBy();
         String cid = readCand.getID();
         String errMsg = readCand.getErrorMessage();
         String eid= readCand.ExternalID;
         
         PageReference searchPage = Page.SearchCandidate;
         Test.setCurrentPage(searchPage);
         ApexPages.currentPage().getParameters().put('SearchFirstName', 'Test');
         ApexPages.currentPage().getParameters().put('SearchLastName', 'Insert');
         ApexPages.StandardController sc2 = new ApexPages.standardController(cand1);
         candidateSearchExtension searchCand = new candidateSearchExtension(sc2);
         
         //Check for Error
         searchCand.SearchFirstName=' ';
         searchCand.SearchLastName=' ';
         searchCand.SearchForCandidates();
         
         //Searching
         searchCand.SearchFirstName='Test';
         searchCand.SearchLastName='Insert';
         searchCand.SearchForCandidates();
         
         //calling Cand Info List
         List<PII_Info.CandidateInfo> theCandList;
         theCandList = searchCand.theCandidateInfoList;
          
         //Candidate ListView
         List<PII_Info.CandidateInfo> theCandListView = null;
         Candidate__c cand3 = new Candidate__c();
          
         PageReference listViewPage = Page.CandidateListView1;
         Test.setCurrentPage(listViewPage);        
         candidateListViewExtension1 listViewCand = new candidateListViewExtension1();
         listViewCand.getCandidates();    
         listViewCand.getDisableNext();
         listViewCand.getDisablePrevious();
         listViewCand.getTotal_size();
         listViewCand.Next();
         listViewCand.Next();
         listViewCand.Previous();  
         listViewCand.End();    
         listViewCand.getMyCommandButtons();
         listViewCand.SelectedPage='10';
         listViewCand.total_size=50;
         listViewCand.refreshGrid();        
         listViewCand.getMyCommandButtons(); 
         listViewCand.getPageNumber();
         listViewCand.getTotalPages();
         listViewCand.listView();
        
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