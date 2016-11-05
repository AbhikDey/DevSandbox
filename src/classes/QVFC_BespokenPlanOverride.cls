public with sharing class QVFC_BespokenPlanOverride 
{
    public          boolean         mp_bNoSTplan            {get; set;}
    public          boolean         mp_bPlanExists          {get; set;}
    public          string          mp_strTemplateId        {get; set;}
    
    private         string          m_strAccountId;
    private         ExecutionPlan__c  m_standardPlan;
    private         ExecutionPlan__c  m_BeSpokenPlan;
    private         Account         m_oAccount;
    
    //private         map<string, Contact> m_ContactPerIds;
    //private         map<string, string> m_Relationshiptype  = new map<string,string>();
    //private         map<string, string> m_Relationshiprole  = new map<string,string>();
    //private           map<string, string> m_DexusContact      = new map<string,string>();
    //private         map<string, list<string>> m_mapContactIdliContactId = new map<string, list<string>>();
    
    // Store Bespoke Plan
    private	map<string, ExecutionPlan__c>	mapIdToBespokePlan = new map<string, ExecutionPlan__c>();
     
    
    public QVFC_BespokenPlanOverride(Apexpages.standardcontroller SC)
    {
        this.m_strAccountId = Apexpages.currentPage().getParameters().get('acctid');
    }
    
    public void Init()
    {
       
       	for(ExecutionPlan__c sBespokePlan : [select  	SystemModstamp, Start_Date__c, 
                            							Remaining_Activities__c, OwnerId, Name, IsDeleted, Id, Expiry_Date__c, 
                            							Active__c, Active_Flag__c, Desired_Outcome__c
                    							from    ExecutionPlan__c 
                    							where   Active__c = 'ACTIVE' 
                    							and     Account__c = null
                    							and     Start_Date__c <= :System.today()
                    							and     Expiry_Date__c >= :System.today()])
		{
			mapIdToBespokePlan.put(sBespokePlan.id, sBespokePlan);	
		}
                    
        m_oAccount          = [select Id, Name from Account where Id = :m_strAccountId];

        mp_strTemplateId = '';
    }
    
    public Pagereference Use()
    {
        mp_strTemplateId = Apexpages.currentPage().getParameters().get('template');
        if(GenerateBespokenPlan())
        {
            return new Pagereference('/'+m_BeSpokenPlan.Id+'/e?retURL=%2F'+m_BeSpokenPlan.Id + '&CF00NN0000000KbZT=' + userinfo.getName());
        }
        return null;
    }
    
    public list<ExecutionPlan__c> GetBespokenPlanTemplates()
    {
        /*
        return [    select  SystemModstamp, Start_Date__c, 
                            Remaining_Activities__c, OwnerId, Name, IsDeleted, Id, Expiry_Date__c, 
                            Active__c, Active_Flag__c
                    from    ExecutionPlan__c 
                    where   Active__c = 'ACTIVE' 
                    and     Account__c = null
                    and     Start_Date__c <= :System.today()
                    and     Expiry_Date__c >= :System.today()];
		*/
		
		return mapIdToBespokePlan.values();
    }
    
    
    private  boolean GenerateBespokenPlan()
    {
        list<ExecutionPlanActivity__c> liBespokePlanObjectives = new list<ExecutionPlanActivity__c>(), listandardObjectives;
        
        //list<Bespoke_Plan_Key_Contacts__c> liBespokePlanKeyContacts = new list<Bespoke_Plan_Key_Contacts__c>(), listandardContacts;
        try
        {
           m_standardPlan = mapIdToBespokePlan.get(mp_strTemplateId);
                         
			system.debug('m_standardPlan:' + m_standardPlan);	                         
                                 
           mp_bNoSTplan = false;
        }
        catch(Exception e )
        {
            mp_bNoSTplan = true;
            QUtils.Debug('No active standard execution plan.');
            QUtils.AddError('There is no active standard execution plan.');
            return false;
        }
            
        try
        {                               //load Objective to be clone
            listandardObjectives = [    select 	Type__c,  
            									Remaining__c, 
            									Quantity__c, 
            									Name, 
            									Completed__c,
            									Campaign__c,
            									ExecutionPlan__c 
            							From 	ExecutionPlanActivity__c 
                                        where 	ExecutionPlan__c = :m_standardPlan.id ];
        }
        catch(Exception e )
        {
            QUtils.addError('Load Bespoke Plan Error : '+e.getMessage());
        }
   
        try
        {
        	// Get RecordType of Bespoke_Plan
        	string RECTID = [Select Id 
        					From 	RecordType 
        					where 	SobjectType = 'ExecutionPlan__c' 
        					and 	DeveloperName = 'Bespoke_Plan' limit 1].id; 
        	
            mp_bPlanExists 				= false;
            m_BeSpokenPlan 				= m_standardPlan.clone(false,true);
            m_BeSpokenPlan.Name 		= m_BeSpokenPlan.Name + '-' + m_oAccount.Name;
            m_BeSpokenPlan.Account__c 	= m_strAccountId;
            m_BeSpokenPlan.RecordTypeId	= RECTID;
            insert m_BeSpokenPlan;
            
            for(ExecutionPlanActivity__c oObj: listandardObjectives)                 //clone bespoke plan objectives
            {
                ExecutionPlanActivity__c o = oObj.clone(false,true);
                o.ExecutionPlan__c = m_BeSpokenPlan.Id;
                liBespokePlanObjectives.add(o);
            }
            
            insert liBespokePlanObjectives;
            
        }
        catch(Exception e )
        {
            QUtils.addError('Clone Error : '+e.getMessage());
        }
        return true;
    }
    
    public Pagereference ContinueToRecord()  
    {
        return new Pagereference('/'+m_BeSpokenPlan.Id);
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////// Test Class
    public static testmethod void myUnitTest()
    {
        Account BusinessAccount     = new Account();
        BusinessAccount.Name        = 'Test 1000';
        insert BusinessAccount;
        
        Account sAccount1            = new Account();
        sAccount1.Name               = 'Account Test 1000';
        insert sAccount1;
        
        ExecutionPlan__c bplan 	= new ExecutionPlan__c();
        //bplan.Account__c 		= BusinessAccount.Id;
        bplan.Approved__c 		= true;
        bplan.Start_Date__c 	= system.today().addDays(-10);
        bplan.Expiry_Date__c  	= system.today().addDays(10);
        bplan.Name 				= 'test';
        insert bplan;
        
        ExecutionPlanActivity__c sEPA 	= new ExecutionPlanActivity__c();
 		sEPA.ExecutionPlan__c 			= bplan.id;
 		sEPA.Type__c 					= 'Presentation to referral group: Clinical Cardiologists';
 		sEPA.Quantity__c 				= 10;
 		insert sEPA;
        
        test.StartTest();
        
        Pagereference sPage = new Pagereference('/apex/QVFP_BespokenPlanOverride?acctid='+BusinessAccount.Id);
        Test.setCurrentPage(sPage);
        Apexpages.currentPage().getParameters().put('template', bplan.Id);
        Apexpages.currentPage().getParameters().put('acctid', BusinessAccount.Id);
        
        QVFC_BespokenPlanOverride oController = new QVFC_BespokenPlanOverride(null);
        oController.Init();
        oController.Use();
        oController.GetBespokenPlanTemplates();
        oController.ContinueToRecord();
        
        test.StopTest();
    }
    
    public static testmethod void myErrorTest()
    {
        Account BusinessAccount     = new Account();
        BusinessAccount.Name        = 'Test 1000';
        insert BusinessAccount;
        
        Pagereference sPage = new Pagereference('/apex/QVFP_BespokenPlanOverride?acctid='+BusinessAccount.Id);
        Test.setCurrentPage(sPage);
        Apexpages.currentPage().getParameters().put('template', BusinessAccount.Id);
        Apexpages.currentPage().getParameters().put('acctid', BusinessAccount.Id);
        
        QVFC_BespokenPlanOverride oController = new QVFC_BespokenPlanOverride(null);
        oController.Init();
        try
        {
	        oController.Use();
        }
        catch(Exception e){}
        
    }
        
}