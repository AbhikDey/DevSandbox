public with sharing class QVFC_CoachingSession 
{
	/*
		Created By 	: 	Nashir
		Date 		:	11-10-2012
		Project		:	
	*/
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// Public Variable

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// Private Variable
	private string	m_strCallRecordId;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// 
	public QVFC_CoachingSession()
	{
		m_strCallRecordId = Apexpages.currentPage().getParameters().get('Id');
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// Page Ref
	public Pagereference init()
	{
		// Load Call_Record__c
		Call_Record__c sCallRecord;
		try
		{
			sCallRecord = [select 	id, 
									Call_Objectives__c,
									Customer_Discussion__c,
									Customer_Commitment__c,
									Next_Call_Objective__c,
									Coaching_Session__c,
									OwnerId
							from 	Call_Record__c
							where	id =:  m_strCallRecordId limit 1]; 
			
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to load Call Record with id ' + m_strCallRecordId));
			return null;
		}
		
		if(sCallRecord.Coaching_Session__c != null)
		{
			ApexPages.pageReference pr = new ApexPages.pageReference('/' + sCallRecord.Coaching_Session__c + '/e?retURL=' + sCallRecord.Coaching_Session__c);
			pr.setRedirect(true);
        	return pr;
		}
		
		// Get 
		Coaching_Session__c sCoachingSession = new Coaching_Session__c();
		try
		{
			
			string RECTID = [Select Id 
        					From 	RecordType 
        					where 	SobjectType = 'Coaching_Session__c' 
        					and 	DeveloperName = 'Post_Call_Coaching_Session' limit 1].id; 
        					
			sCoachingSession.Call_Objectives__c 	= sCallRecord.Call_Objectives__c;
			sCoachingSession.Customer_Discussion__c = sCallRecord.Customer_Discussion__c;
			sCoachingSession.Customer_Commitment__c = sCallRecord.Customer_Commitment__c;
			sCoachingSession.Next_Call_Objective__c = sCallRecord.Next_Call_Objective__c;
			sCoachingSession.Sales_Rep_Name__c		= sCallRecord.OwnerId;
			sCoachingSession.Sales_Coach_Name__c	= userinfo.getUserId();
			sCoachingSession.RecordTypeId			= RECTID;
			sCoachingSession.OwnerId				= sCallRecord.OwnerId;
			insert sCoachingSession;
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to Insert New Coaching Session'));
			return null;
		}
		
		// Update Old CallRecord
		sCallRecord.Coaching_Session__c = sCoachingSession.id;
		update sCallRecord;
		
		ApexPages.pageReference pr = new ApexPages.pageReference('/' + sCoachingSession.id + '/e?retURL=' + sCoachingSession.id);
        pr.setRedirect(true);
        return pr;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// External Function
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// Internal Function
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// Test Class
	static testMethod void myUnitTest() 
    {
    	map<string, string> mapNameToID = new map<string, string>(); 
    	//Added by Brahma
    	Id phyRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician/Practitioner').getRecordTypeId();
    	
    	for(RecordType sRCT : [select 	id, 
    									SobjectType, 
    									DeveloperName 
    							from 	RecordType 
    							where 	SobjectType in ('Account', 'Call_Record__c') 
    							and 	DeveloperName in ('SJM_Customer', 'Prospective', 'Sales_Call')])
    	{
    		mapNameToID.put(sRCT.SobjectType + '|' + sRCT.DeveloperName, sRCT.id);
    	}
    	
    	
        Account oFacility 					= new Account();
    	oFacility.Name	 					= 'Facility Quattro';
    	oFacility.RecordTypeId 				= mapNameToID.get('Account|SJM_Customer');
    	oFacility.BillingState				= 'NSW';
    	oFacility.BillingStreet				= '301/50 Holt Street';
    	oFacility.BillingPostalCode			= '2010';
    	oFacility.BillingCity				= 'Surry Hills';
    	insert oFacility;
    	
    	//Commented by Brahma - ANZ Consolidation
    	//Account oDoctor 					= new Account();
    	//oDoctor.FirstName 					= 'Doctor';
    	//oDoctor.LastName 					= 'Quattro';
    	//oDoctor.Phone						= '04123456789';
    	//oDoctor.RecordTypeId 				= mapNameToID.get('Account|Practitioner');
    	//oDoctor.BillingState				= 'NSW';
    	//oDoctor.BillingStreet				= '301/50 Holt Street';
    	//oDoctor.BillingPostalCode			= '2010';
    	//oDoctor.BillingCity					= 'Surry Hills';
    	//insert oDoctor;
    	
    	Contact sContact = new Contact();
    	sContact.FirstName = 'Doctor';
    	sContact.LastName = 'Quattro';
    	sContact.Phone = '04123456789';
    	sContact.Email = 'test6@gmail.com';
    	sContact.AccountId = oFacility.Id;
    	sContact.RecordTypeId = phyRecTypeId;
    	insert sContact;
    	
    	//Added by Brahma
    	//string strDoctorContactId = [select id, PersonContactId from Account where Id = :oDoctor.Id].PersonContactId;
    	string strDoctorContactId = sContact.Id;
    	
    	Affiliation__c oRelation 				= new Affiliation__c();
    	oRelation.Contact__c 					= strDoctorContactId;
    	oRelation.Account__c 					= oFacility.Id;
    	oRelation.Primary__c			 		= true;
    	insert oRelation;
    	
    	Call_Record__c sCall 				= new Call_Record__c();
    	sCall.Contact__c 					= strDoctorContactId;
    	sCall.RecordTypeId 					= mapNameToID.get('Call_Record__c|Sales_Call');
    	sCall.Facility_Practitioner__c 		= oFacility.Id;
    	sCall.Call_Objectives__c 			= 'Blablabla';
    	sCall.Call_Type__c 					= 'Phone';
    	sCall.Location_of_Call__c 			= 'Melbourne';
    	sCall.Call_Status__c 				= 'Planning';
    	sCall.Date_Time_of_Call__c 			= System.today();
    	sCall.Follow_Up_Due_Date_Time__c 	= Datetime.now();
    	sCall.Next_Call_Objective__c 		= 'test';
    	sCall.Customer_Commitment__c 		= 'test';
    	sCall.Customer_Discussion__c 		= 'test';
    	insert sCall;
    	
    	test.startTest();
    	Pagereference sPage = new Pagereference('/apex/QVFP_CoachingSession');
    	Test.setCurrentPage(sPage);
    	{
	        Apexpages.currentPage().getParameters().put('id', sCall.Id);
	    	QVFC_CoachingSession oController = new QVFC_CoachingSession();
	    	oController.init();
    	}
    	{
			Apexpages.currentPage().getParameters().put('oRelation', sCall.Id);
	    	QVFC_CoachingSession oController = new QVFC_CoachingSession();
	    	oController.init();
    	}
    	test.stopTest();
    	
    	
    }
}