public with sharing class QVFC_CallRecordRelatedList 
{
	/*
		Created By 	: 	Nashir
		Date 		:	02-10-2012
		Project		:	
	*/
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// Public Variable
	public 	list<Call_Record__c>	mp_liCallRecord 		{get; set;}
	public	boolean					mp_bSeeAllList			{get; set;}
	public 	string					mp_strObjectId			{get; set;}
	public 	string					mp_strAllListView		{get; set;}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// Private Variable
	private Coaching_Session__c		m_sCoachingSession;
	private map<string, string>		m_mapCallIdToCoachingObjectives;
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// 
	public QVFC_CallRecordRelatedList(Apexpages.Standardcontroller SC)
	{
		mp_bSeeAllList = Apexpages.currentPage().getParameters().get('list') != null ;
		
		if(!mp_bSeeAllList)	
		{
			mp_strObjectId = SC.getId();
		}
		else 
		{
			mp_strObjectId = Apexpages.currentPage().getParameters().get('RecordID');
		}
		
		system.debug('mp_strObjectId:' + mp_strObjectId);
		
		mp_liCallRecord 				= new list<Call_Record__c>();
		m_mapCallIdToCoachingObjectives	= new map<string, string>();
	}
	
	
	public void Init()
	{
		integer iTotalMax 	= 5;
		integer iTotal 		= 0;
		
		// Load Coaching Session
		try
		{
			m_sCoachingSession = [select 	id, 
											Sales_Rep_Name__c, 
											Coaching_Day_Date__c 
									from 	Coaching_Session__c 
									where 	id =:mp_strObjectId limit 1];
			
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to load Coaching Session with Id = ' + mp_strObjectId));
            return;	
		}
		
		// Count Total
		AggregateResult[] groupedResultsTask = [select 	count(id) Total
												from 	Call_Record__c
												where 	Ownerid =: m_sCoachingSession.Sales_Rep_Name__c 
												and 	Date_Time_of_Call__c >=: GetStartDateTime(m_sCoachingSession.Coaching_Day_Date__c) 
												and 	Date_Time_of_Call__c <=: GetEndDateTime(m_sCoachingSession.Coaching_Day_Date__c)];
												
		iTotal = integer.ValueOf(groupedResultsTask[0].get('Total'));
		
		if(iTotal > 5)
		{
			mp_strAllListView = 'Show All (' + iTotal + ') »';
		}
		
		
		if(mp_bSeeAllList)
		{
			iTotalMax 	= iTotal;
		}
		
		// Load Call Record
		for(Call_Record__c sCallRecord : [select 	id,
													Name,
													Facility_Practitioner__c, 
													Contact__c,
													Case_Type__c,
													Call_Objectives__c,
													Coaching_Objectives__c
											from 	Call_Record__c
											where 	Ownerid =: m_sCoachingSession.Sales_Rep_Name__c 
											and 	Date_Time_of_Call__c >=: GetStartDateTime(m_sCoachingSession.Coaching_Day_Date__c) 
											and 	Date_Time_of_Call__c <=: GetEndDateTime(m_sCoachingSession.Coaching_Day_Date__c)
											limit 	: iTotalMax])
		{
			mp_liCallRecord.add(sCallRecord);
			m_mapCallIdToCoachingObjectives.put(sCallRecord.id, sCallRecord.Coaching_Objectives__c);
		}
		
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// 
	
	public Pagereference actionUpdate()
	{
		list<Call_Record__c> liUpdate = new list<Call_Record__c>(); 
		
		// Check any change on Coaching_Objectives__c
		for(Call_Record__c sCallRecord : mp_liCallRecord)
		{
			if(sCallRecord.Coaching_Objectives__c != m_mapCallIdToCoachingObjectives.get(sCallRecord.id))
			{
				// Record need to update
				liUpdate.add(sCallRecord);
			}
		}
		
		if(!liUpdate.isempty())
		{
			update liUpdate;
		}
		
	 	return null;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///// 
	private datetime GetStartDateTime(date dtDate)
	{
		datetime dt = datetime.newInstance(dtDate, time.newInstance(0,0,0,0));
		return dt;
	}
	
	private datetime GetEndDateTime(date dtDate)
	{
		datetime dt = datetime.newInstance(dtDate, time.newInstance(23,59,59,0));
		return dt;
	}
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////// Test Class
    public static testmethod void myUnitTest()
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
    	oFacility.RecordTypeId 				= mapNameToID.get('Account|SJM_Customer');//[select Id from RecordType where DeveloperName = 'Facility'].Id;
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
    	//oDoctor.RecordTypeId 				= mapNameToID.get('Account|Practitioner'); //[select Id from RecordType where DeveloperName = 'Practitioner'].Id;
    	//oDoctor.BillingState				= 'NSW';
    	//oDoctor.BillingStreet				= '301/50 Holt Street';
    	//oDoctor.BillingPostalCode			= '2010';
    	//oDoctor.BillingCity					= 'Surry Hills';
    	//insert oDoctor;
    	
    	Contact sContact = new Contact();
    	sContact.FirstName = 'Doctor';
    	sContact.LastName = 'Quattro';
    	sContact.Phone = '04123456789';
    	sContact.Email = 'test5@gmail.com';
    	sContact.AccountId = oFacility.Id;
    	sContact.RecordTypeId = phyRecTypeId;
    	insert sContact;
    	
    	
    	//Added by Brahma
    	//string strDoctorContactId = [select id, PersonContactId from Account where Id = :oDoctor.Id].PersonContactId;
    	string strDoctorContactId = sContact.Id;
    	
    	Affiliation__c oRelation 			= new Affiliation__c();
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
    	sCall.Date_Time_of_Call__c 			= system.today();
    	sCall.Follow_Up_Due_Date_Time__c 	= Datetime.now();
    	sCall.Next_Call_Objective__c 		= 'test';
    	sCall.Customer_Commitment__c 		= 'test';
    	sCall.Customer_Discussion__c 		= 'test';
    	sCall.Coaching_Objectives__c		= 'test';
    	insert sCall;
    	
    	Coaching_Session__c sCS 	= new Coaching_Session__c();
    	sCS.Sales_Rep_Name__c		= userinfo.getUserId();
    	sCS.Coaching_Day_Date__c	= system.today();
    	insert sCS;
    	
    	
		test.StartTest();
        
        Pagereference sPage = new Pagereference('/apex/QVFP_CallRecordRelatedList');
        Test.setCurrentPage(sPage);
        
        QVFC_CallRecordRelatedList oController = new QVFC_CallRecordRelatedList(new Apexpages.Standardcontroller(sCS));
        oController.Init();
        system.debug('List:' + oController.mp_liCallRecord);
        if(oController.mp_liCallRecord.size() > 0){
	        oController.mp_liCallRecord[0].Coaching_Objectives__c = 'test10';
	        oController.actionUpdate();
        }
    }
}