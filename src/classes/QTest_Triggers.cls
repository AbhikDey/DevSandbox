/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class QTest_Triggers {

    static testMethod void myUnitTest() 
    {
    	map<string, string> mapNameToID = new map<string, string>(); 
    	//Added by Brahma
    	Id phyRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician/Practitioner').getRecordTypeId();
    	
    	for(RecordType sRCT : [select 	id, 
    									SobjectType, 
    									DeveloperName 
    							from 	RecordType 
    							where 	SobjectType in ('Account', 'Call_Record__c', 'Event') 
    							and 	DeveloperName in ('SJM_Customer', 'Prospective', 'Sales_Call', 'ANZ_Standard_Event')])
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
    	sContact.Email = 'test4@gmail.com';
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
    	
    	sCall.Date_Time_of_Call__c = System.today().addDays(1);
    	update sCall;
    	
    	ExecutionPlan__c sEP 	= new ExecutionPlan__c();
 		sEP.Name 				= 'VSI Renal Denervation Q1 2013';
 		sEP.Start_Date__c		= system.today();
 		sEP.Expiry_Date__c		= system.today().addDays(10);
 		sEP.Approved__c			= true;
 		insert sEP;
    	
    	ExecutionPlanActivity__c sEPA 	= new ExecutionPlanActivity__c();
 		sEPA.ExecutionPlan__c 			= sEP.id;
 		sEPA.Type__c 					= 'Presentation to referral group: Clinical Cardiologists';
 		sEPA.Quantity__c 				= 10;
 		insert sEPA;
    	
    	Event sEvent 			= new Event();
    	sEvent.WhatId 			= sEPA.id;
    	sEvent.Related_Call_ID__c = sCall.Id;
    	sEvent.RecordTypeId 	= mapNameToID.get('Event|ANZ_Standard_Event');
    	sEvent.Location 		= 'Sydney';
    	sEvent.Subject 			= 'QTest';
    	sEvent.StartDateTime 	= Datetime.now();
    	sEvent.EndDateTime 		= Datetime.now();
    	sEvent.Type 			= 'Meeting';
    	sEvent.Description 		= 'Test for quattro';
    	insert sEvent;
    	    	
    	Event iEvent = [select id from Event where Related_Call_ID__c = :sCall.Id limit 1];
    	iEvent.ActivityDateTime = System.today().addDays(2);
    	update iEvent;
    	
    	delete sCall;
    	
    	sCall 							= new Call_Record__c();
    	sCall.Contact__c 				= strDoctorContactId;
    	sCall.RecordTypeId 				= mapNameToID.get('Call_Record__c|Sales_Call');
    	sCall.Facility_Practitioner__c 	= oFacility.Id;
    	sCall.Call_Objectives__c 		= 'Blablabla';
    	sCall.Call_Type__c 				= 'Phone';
    	sCall.Location_of_Call__c 		= 'Melbourne';
    	sCall.Call_Status__c 			= 'Planning';
    	sCall.Date_Time_of_Call__c 		= System.today();
    	insert sCall;
    	
    	sCall.Follow_Up_Due_Date_Time__c 	= Datetime.now();
    	sCall.Next_Call_Objective__c 		= 'test';
    	sCall.Customer_Commitment__c 		= 'test';
    	sCall.Customer_Discussion__c 		= 'test';
    	sCall.Call_Status__c 				= 'Completed';
    	update sCall;
    	
    }
    
 	static testMethod void testEventTrigger() 
 	{
 		//Getting RecordTypeId for Event
 		Id evtRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('ANZ Standard Event').getRecordTypeId();
 		
 		ExecutionPlan__c sEP 	= new ExecutionPlan__c();
 		sEP.Name 				= 'VSI Renal Denervation Q1 2013';
 		sEP.Start_Date__c		= system.today();
 		sEP.Expiry_Date__c		= system.today().addDays(10);
 		sEP.Approved__c			= true;
 		insert sEP;
 		
 		ExecutionPlanActivity__c sEPA 	= new ExecutionPlanActivity__c();
 		sEPA.ExecutionPlan__c 			= sEP.id;
 		sEPA.Type__c 					= 'Presentation to referral group: Clinical Cardiologists';
 		sEPA.Quantity__c 				= 10;
 		insert sEPA;
 		
 		Event sEvent 			= new Event();
    	sEvent.WhatId 			= sEPA.id;
    	sEvent.RecordTypeId 	= evtRecordTypeId;
    	sEvent.Location 		= 'Sydney';
    	sEvent.Subject 			= 'QTest';
    	sEvent.StartDateTime 	= Datetime.now();
    	sEvent.EndDateTime 		= Datetime.now();
    	sEvent.Type 			= 'Meeting';
    	sEvent.Description 		= 'Test for quattro';
    	insert sEvent;
 		
 		sEvent.Event_Completed__c = true;
 		update sEvent;
 		
 		delete sEvent;
 		
 		// For Task Trigger
 		Task sTask 		= new Task();
 		sTask.WhatId 	= sEPA.id;
 		insert sTask;
 		
 		sTask.Status = 'Completed';
 		update sTask;
 		
 		delete sTask;
 	}
 	
 	
 	static testMethod void testCallRecordTrigger() 
 	{
 		ExecutionPlan__c sEP 	= new ExecutionPlan__c();
 		sEP.Name 				= 'VSI Renal Denervation Q1 2013';
 		sEP.Start_Date__c		= system.today();
 		sEP.Expiry_Date__c		= system.today().addDays(10);
 		sEP.Approved__c			= true;
 		insert sEP;
 		
 		ExecutionPlanActivity__c sEPA 	= new ExecutionPlanActivity__c();
 		sEPA.ExecutionPlan__c 			= sEP.id;
 		sEPA.Type__c 					= 'Presentation to referral group: Clinical Cardiologists';
 		sEPA.Quantity__c 				= 10;
 		insert sEPA;
 		
 		Call_Record__c sCall 				= new Call_Record__c();
    	sCall.Execution_Plan_Objective__c 	= sEPA.Id;
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
 		// Update Call Record to complete. 
 		sCall.Call_Status__c 				= 'Completed';
 		update sCall;
 		
 		sEP.Approved__c			= false;
 		update sEP;
 		
 		try
 		{
	 		// Delete CallRecord
	 		delete sCall;
 		}
 		catch(Exception e){}
 	}
}