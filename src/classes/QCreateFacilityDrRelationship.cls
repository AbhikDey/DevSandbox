public with sharing class QCreateFacilityDrRelationship 
{
	public	list<Affiliation__c>				liRelations					{get; set;}
	public	string								mp_strTitle					{get; set;}
	public	boolean								mp_bToCall					{get; set;}
	public	boolean								mp_bNoRecord				{get; set;}
	
	public 	boolean                             mp_bSelectRT        		{get; set;}	
	public	boolean								mp_bIsSystemAdmin 			{get; set;}
	public  boolean								mp_bIsAF_CRM				{get; set;}
	public	boolean								mp_bBPO						{get; set;}	
	public 	list<SelectOption>                  mp_liCallRecordType 		{get; set;}
    public 	list<RecordType>                    mp_liCallDescript   		{get; set;}
    public 	list<ExecutionPlanActivity__c>		mp_liExecutionPlanActivity 	{get; set;}
    public 	string                              mp_strRTid          		{get; set;}
    	
	public	string								mp_strAcctId				{get; set;}			
	public	string								mp_strConId			 		{get; set;}
    public	string								mp_strDivision				{get; set;}
    
	public 	string								m_strDoctor;
	public	string								m_strAccountId;
	public	string								m_strRetURL;
	public	string								m_redirectTo;
	public	boolean								m_IsPersonAccount;
	public 	boolean								m_DisplayCallTypeField		{get; set;}
	
	public	Call_Record__c						sCallRecord					{get; set;}
	
	private string								m_strPersonalAccountId;
	private map<string, string>					m_mapRecIDToName;
	
	//Added by Brahma
    Id phyRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician/Practitioner').getRecordTypeId();
	
	public QCreateFacilityDrRelationship()
	{
		try
		{
			mp_bIsSystemAdmin = [select id from Profile where Name = 'System Administrator' limit 1].Id == UserInfo.getProfileId();
			mp_bIsAF_CRM = false;
			if(!mp_bIsSystemAdmin)
			{
				mp_bIsAF_CRM = true;
				set<string> setProfiles = new set<string>();
				for(Profile p : [select id from Profile where Name = 'SJM AF - CRM User' or Name = 'SJM AFCRM User'])
				{
					setProfiles.add(p.Id);
				}
				mp_bIsSystemAdmin = setProfiles.contains(UserInfo.getProfileId());
			}
		}
		catch(Exception e )
		{
			mp_bIsSystemAdmin = false;
		}
		
		//m_strAccountId		= 	Apexpages.currentPage().getParameters().get('contactId');
		m_strDoctor			= 	Apexpages.currentPage().getParameters().get('contactId');
		m_redirectTo		= 	Apexpages.currentPage().getParameters().get('redirectTo');
		
		mp_bToCall = (m_redirectTo != null && m_redirectTo == 'call');	//we want to redirect to a new call edit page ?
		
		
		m_strRetURL = '/'+m_strDoctor;
		
		if(mp_bToCall)			//define title of the page
			mp_strTitle = 'Select Account / Contact Affiliation';
		else
			mp_strTitle = 'Primary Relationship Management';	
			
		mp_bSelectRT 		= false;   
		mp_bBPO				= false;
		m_mapRecIDToName	= new map<string, string>();
	}
	
	public Pagereference Init()
	{
		sCallRecord = new Call_Record__c();
		m_DisplayCallTypeField	= false;
		
		
		if(m_strDoctor == null)
		{
			QUtils.AddError('Page not found. Try again or contact an admin.');
			return null;
		}
		//if(m_strAccountId.startsWith('003'))
		//{
			//m_strDoctor = m_strAccountId;
			m_strAccountId = [select id, AccountId from Contact where Id = :m_strDoctor].AccountId;
			//m_strDoctor = [select id, AccountId from Contact where Id = :m_strDoctor].AccountId;
			//m_strAccountId = m_strAccountId;
			//m_IsPersonAccount = false;
			//mp_bNoRecord = true;
			system.debug('m_strAccountId - '+m_strAccountId);
			system.debug('m_strDoctor - '+m_strDoctor);
			m_IsPersonAccount = true;	
			
			if(m_strAccountId == null)
			return UseForSystemAdmin();
		/*}
		else
		{
			//Changes by Brahma - ANZ Consolidation
			//m_strDoctor = [select id, PersonContactId from Account where Id = :m_strAccountId].PersonContactId;	//contact is a PersonAccount --> Doctor
			system.debug('m_strAccountId - '+m_strAccountId);
			system.debug('phyRecTypeId - '+phyRecTypeId);
			m_strDoctor = [select Id, AccountId from Contact where AccountId = :m_strAccountId and RecordTypeId = :phyRecTypeId][0].Id;
			m_strPersonalAccountId = m_strAccountId;
			m_IsPersonAccount = true;			
		}*/
		
		FilterOption();
		
		return null;
	}
	
	public Pagereference CreateNewFacilityDrRelationship()
	{
		//Commented by Brahma
		//Account sDoctor;		//redirect to facility/dr relationship edit page
		Contact sDoctor;		//redirect to facility/dr relationship edit page
		try
		{
			if(m_strDoctor != null && m_strDoctor != '')		//get the name of the Doctor for URL paramaters
				sDoctor 	= [select Name from Contact where Id =:m_strDoctor];				
		}
		catch(Exception e ){}
		
		//Commented by Brahma
		//String doctor = QCustomField.getId('Relationship_360__c', 'Doctor__c');		//get field ID for the URL parameters
		String doctor = QCustomField.getId('Affiliation__c', 'Contact__c');		//get field ID for the URL parameters
		
		//String forwardURL = '/' + Relationship_360__c.getsObjectType().getDescribe().getKeyPrefix() + '/e?mode=new';	//get prefix of the object 
		String forwardURL = '/' + Affiliation__c.getsObjectType().getDescribe().getKeyPrefix() + '/e?mode=new';	//get prefix of the object
		
		if(sDoctor != null)		//only if doctor is not null
		{
			forwardURL += '&CF' + doctor + '_lkid=' + m_strDoctor + '&CF' + doctor + '=' + sDoctor.Name;
		}
		
		return new PageReference(forwardURL);	
	}
	
	private void FilterOption()
	{
		try
		{	//load Relation360
			mp_bNoRecord = false;
			
			liRelations = [select Id, Name, Account__c, Primary__c, Role__c, Contact__c From Affiliation__c where Contact__c = :m_strDoctor];
			
			if(liRelations == null || liRelations.IsEmpty())
			{//boom no relation
				mp_bNoRecord = true;
			}
		}
		catch(Exception  e)
		{	//boom no relation
			mp_bNoRecord = true;
		}
	}
	
	public Pagereference UseForSystemAdmin()
	{
		GetRecordTypeForUser();
        mp_bSelectRT = true;
		return null;
	}
	
	public Pagereference UseCallTypeField()
	{
		mp_bSelectRT			= false;
		m_DisplayCallTypeField 	= true;
		
		// Get User Profile
		try
		{
			Profile sProfile = [Select Name from Profile where id =: userinfo.getProfileId()]; 
			// Get Division Name
			list<string> liDivision = ((string)sProfile.Name).split(' ');
			
			if(liDivision.size() == 3)
			{
				schema.DescribeFieldResult schemaDescribeResults 	= Call_Record__c.Division__c.getDescribe();
            	list <Schema.PicklistEntry> liPickListValues 		= schemaDescribeResults.getPickListValues();
            
				for(Schema.Picklistentry sType : liPickListValues)
				{
					if(liDivision[1].contains(sType.getValue()))
					{
						sCallRecord.Division__c = sType.getValue();
						mp_strDivision			= sType.getValue();
					}
				}
			}
			
		}
		catch(Exception e)
		{
			
		}
		
		sCallRecord.Call_Type__c = m_mapRecIDToName.get(mp_strRTid);
		
		return null;
	}
	
	public Pagereference UserUse()
	{
		m_DisplayCallTypeField = false;
		
		GetRecordTypeForUser();
		
		mp_bSelectRT = true;
		return null;
	}
	
	public Pagereference DisplayExecutionPlan()
	{
		m_DisplayCallTypeField 		= false;
		mp_bSelectRT				= false;
		Pagereference 				pageRef;
		
		system.debug('m_strAccountId:' + m_strAccountId + ' mp_strAcctId:' + mp_strAcctId );
		
		mp_liExecutionPlanActivity 	= new list<ExecutionPlanActivity__c>();
		
		if(sCallRecord.Call_Type__c != null && sCallRecord.Call_Type__c != '')
		{
			string strQuery = 	' select 	Id, ExecutionPlan__r.Name, Name, Type__c, Description__c, Quantity__c from 	ExecutionPlanActivity__c' +   
								' where (ExecutionPlan__r.Account__c =: m_strAccountId or ExecutionPlan__r.Account__c =: mp_strAcctId) ' + 
								' and 	Type__c =\'' +  sCallRecord.Call_Type__c + '\'';

			if(sCallRecord.Campaign__c != null)
			{
				strQuery += ' and Campaign__c =\'' + sCallRecord.Campaign__c + '\'';
			}
			
			system.debug('strQuery:' + strQuery);
			
			for(ExecutionPlanActivity__c sBPO : database.query(strQuery))
			{
				mp_liExecutionPlanActivity.add(sBPO);
			}
		}
		
		if(mp_liExecutionPlanActivity.size() == 0)
		{
			pageRef = new Pagereference(GeneratePageLocation());
			pageRef.setRedirect(true);
		}
		else
		{
			mp_bBPO = true;
		}
		
		return pageRef;
	}
	
	private string GeneratePageLocation()
	{
		string strPageLocation;
		string BPOName = Apexpages.currentPage().getParameters().get('bporelalionid');
		
		if(mp_bNoRecord)	//no relation --> redirect to the call edit page without facility
		{
			strPageLocation = '/apex/QVFP_CallRecordOverride?accountId='+m_strAccountId+'&contactid='+m_strDoctor;
		}
		else	//redirect to the call edit page
		{
			strPageLocation = '/apex/QVFP_CallRecordOverride?accountId='+mp_strAcctId+'&contactid='+mp_strConId;
		}
		
		if(mp_strRTid != null && mp_strRTid != '')
		{
			strPageLocation += '&RecordType=' + mp_strRTid;
		}
		
		if(sCallRecord.Call_Type__c != null && sCallRecord.Call_Type__c != '')
		{
			strPageLocation += '&CallType=' + sCallRecord.Call_Type__c;
		}
		
		if(sCallRecord.Product_Group_Proced_Therapy__c != null && sCallRecord.Product_Group_Proced_Therapy__c != '')
		{
			strPageLocation += '&Product_Group_Proced_Therapy__c=' + sCallRecord.Product_Group_Proced_Therapy__c;
		}
		
		if(sCallRecord.Division__c != null && sCallRecord.Division__c != '')
		{
			strPageLocation += '&Division__c=' + sCallRecord.Division__c;
		}
		
		if(sCallRecord.Campaign__c != null && sCallRecord.Campaign__c != '')
		{
			strPageLocation += '&Campaign__c=' + sCallRecord.Campaign__c;
		}
		
		if(BPOName != null && BPOName != '')
		{
			strPageLocation += '&ExecutionPlanObjective=' + BPOName;
		}
		
		system.debug('PageRef:::' + strPageLocation + ':::Division:::' + sCallRecord.Division__c);
		
		return strPageLocation;
	}
	
	public Pagereference Use()
	{	
		system.debug('########################>'+mp_strAcctId+'--'+mp_strConId+'-'+mp_strRTid + '-sCallRecord.Call_Type__c:' + sCallRecord.Call_Type__c);
		
		string strPageLocation;
		
		Pagereference pageRef;
		pageRef = new Pagereference(GeneratePageLocation());
		pageRef.setRedirect(true);
		
		return pageRef;
	}
	
	public Pagereference Save()
	{		//change the primary relationship
		string strPrimaryId = Apexpages.currentPage().getParameters().get('relalionid');
		try
		{
			for(Affiliation__c r : liRelations)
			{
				r.Primary__c = (r.Id == strPrimaryId);
			}
			upsert liRelations;
		}
		catch(Exception e )
		{
			System.debug(e.getMessage());
		}
		return null;
	}
	
	public Pagereference Back()
	{	//back to the Doctor
		Pagereference pageRef = new Pagereference(m_strRetURL);
		pageRef.setRedirect(true);
		return pageRef;
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////
	/// Private Method
	
	private void GetRecordTypeForUser()
	{
		mp_liCallRecordType = new list<SelectOption>();
        mp_liCallDescript =  new list<RecordType>();
		
		list<string> liRecordTypeId = new list<string>();
		
		Schema.DescribeSObjectResult d = Schema.SObjectType.Call_Record__c;
		Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
		
		for(Schema.RecordTypeInfo sRecordTypeInfo : rtMapById.values())
		{
			if(sRecordTypeInfo.isAvailable())
			{
				liRecordTypeId.add(sRecordTypeInfo.getRecordTypeId());
			}
		}
		
		// Get RecordType Desc
		for(RecordType rt : [select id, Name, DeveloperName, Description from RecordType where id in : liRecordTypeId order by Name])
        {
			mp_liCallRecordType.add(new SelectOption(rt.Id, rt.Name));
			mp_liCallDescript.add(rt);
			m_mapRecIDToName.put(rt.Id, rt.Name);
        }
		
	}
	
	public static testmethod void myUnitTest()
	{
		//Added by Brahma
    	Id phyRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician/Practitioner').getRecordTypeId();
		
		Account oFacility 					= new Account();
    	oFacility.Name	 					= 'Facility Quattro';
    	oFacility.RecordTypeId 				= [select Id from RecordType where DeveloperName = 'SJM_Customer'].Id;
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
    	//oDoctor.RecordTypeId 				= [select Id from RecordType where DeveloperName = 'Practitioner'].Id;
    	//oDoctor.BillingState				= 'NSW';
    	//oDoctor.BillingStreet				= '301/50 Holt Street';
    	//oDoctor.BillingPostalCode			= '2010';
    	//oDoctor.BillingCity					= 'Surry Hills';
    	//insert oDoctor;
    	
    	Contact sContact = new Contact();
    	sContact.FirstName = 'David';
    	sContact.LastName = 'Test';
    	sContact.Phone = '0456789123';
    	sContact.Email = 'test3@gmail.com';
    	sContact.AccountId = oFacility.Id;
    	sContact.RecordTypeId = phyRecTypeId;
    	insert sContact;
    	
    	//Added by Brahma
    	//string strDoctorContactId = [select id, PersonContactId from Account where Id = :oDoctor.Id].PersonContactId;
    	string strDoctorContactId = sContact.Id;
    	
    	Affiliation__c oRelation	 			= new Affiliation__c();
    	oRelation.Contact__c 					= strDoctorContactId;
    	oRelation.Account__c 					= oFacility.Id;
    	oRelation.Primary__c			 		= true;
    	insert oRelation;
    	
    	//TEST Error
    	{
	    	QCreateFacilityDrRelationship oCOntroller = new QCreateFacilityDrRelationship();
	    	oController.Init();
    	}
    	
    	//Test Select Facility
    	{
    		Pagereference pageRef = new Pagereference('/apex/QVFP_CreateFacilityDrRelationship');
    		pageRef.getParameters().put('contactId',sContact.Id);
    		
    		Test.setCurrentPage(pageRef);
    		
    		QCreateFacilityDrRelationship oCOntroller = new QCreateFacilityDrRelationship();
	    	oCOntroller.Init();
	    	pageRef.getParameters().put('relalionid',oRelation.Id);
	    	oCOntroller.Save();
	    	oCOntroller.Back();
    	}
    	
    	//Test New Call
    	{
    		Pagereference pageRef = new Pagereference('/apex/QVFP_CreateFacilityDrRelationship');
    		pageRef.getParameters().put('contactId',sContact.Id);
    		pageRef.getParameters().put('redirectTo','call');
    		
    		Test.setCurrentPage(pageRef);
    		
    		QCreateFacilityDrRelationship oCOntroller = new QCreateFacilityDrRelationship();
	    	oCOntroller.Init();
	    	pageRef.getParameters().put('acctid',oFacility.Id);
	    	pageRef.getParameters().put('conid',strDoctorContactId);
	    	oCOntroller.Use();
	    	
	    	pageRef = new Pagereference('/apex/QVFP_CallRecordOverride');
	    	pageRef.getParameters().put('accountid',oFacility.Id);
	    	pageRef.getParameters().put('contactid',strDoctorContactId);
	    	
	    	Test.setCurrentPage(pageRef);
	    	
	    	QVFC_CallRecordOverride oRedirect = new QVFC_CallRecordOverride();
	    	oRedirect.redirect();
    	}
    	
    	//Test without facility
    	{
    		Pagereference pageRef = new Pagereference('/apex/QVFP_CreateFacilityDrRelationship');
    		pageRef.getParameters().put('contactId',sContact.Id);
    		pageRef.getParameters().put('redirectTo','call');
    		
    		delete oRelation;
    		
    		Test.setCurrentPage(pageRef);
  
    		QCreateFacilityDrRelationship oCOntroller = new QCreateFacilityDrRelationship();
	    	oCOntroller.Init();
	    	oCOntroller.CreateNewFacilityDrRelationship();
	    	oCOntroller.Use();
    	}
    	
    	//Test Contact without relationship
    	{
    		Pagereference pageRef = new Pagereference('/apex/QVFP_CreateFacilityDrRelationship');
    		pageRef.getParameters().put('contactId',sContact.Id);
    		pageRef.getParameters().put('redirectTo','call');
    		Test.setCurrentPage(pageRef);
  
    		QCreateFacilityDrRelationship oCOntroller = new QCreateFacilityDrRelationship();
	    	oCOntroller.Init();
	    	oCOntroller.Use();
    	}
    	
    	
    	//Test Contact without relationship
    	{
    		Pagereference pageRef = new Pagereference('/apex/QVFP_CreateFacilityDrRelationship');
    		pageRef.getParameters().put('contactId',sContact.Id);
    		pageRef.getParameters().put('redirectTo','call');
    		Test.setCurrentPage(pageRef);
  
    		QCreateFacilityDrRelationship oCOntroller = new QCreateFacilityDrRelationship();
	    	oCOntroller.Init();
	    	oCOntroller.UserUse();
	    	oCOntroller.mp_strRTid = oCOntroller.mp_liCallRecordType[0].getValue();
	    	oCOntroller.UseCallTypeField();
	    	oCOntroller.DisplayExecutionPlan();
    	}
	}
}