@isTest
private class TestMassAccountsAssociation  {

    static testMethod void myUnitTest() 
    {
        Test.startTest();
        RecordType rt= [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND Name = 'Account Group'];
        RecordType rt1= [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND Name = 'SJM Customer'];
        
        Account ac = new Account();
        ac.RecordtypeId= rt.Id;
        ac.name = 'Test Account Group';
       ac.SJM_ID__c= '1000000090';
        insert ac;
        
         Account ac1 = new Account();
        ac1.RecordtypeId= rt1.Id;
        ac1.name = 'Test Account';
       ac1.SJM_ID__c= '1000000091';
        insert ac1;
        
       Group_Members__c gm = new Group_Members__c();
       
         gm.Group__c = ac.Id;
         gm.Associated_Account__c= ac1.Id;
         insert gm;
         
       
        ApexPages.StandardController sc = new ApexPages.standardController(ac);
        MassAccountAssociation MA = new MassAccountAssociation(sc);
        //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Case_Lines__c' AND Name = 'Capital'];
        list<MassAccountAssociation.checkbox> lst=new list<MassAccountAssociation.checkbox>();
        lst.add(new MassAccountAssociation.checkbox(TRUE,SYSTEM.TODAY(),SYSTEM.TODAY(),ac));
        lst.add(new MassAccountAssociation.checkbox(false ,SYSTEM.TODAY(),SYSTEM.TODAY(),ac ));
        MA.saveRecord();
        MA.strsearch='';
        //objProd.search();
        MA.strsearch='Test';
        // MA.strname ='%Test%';
        MA.searchbtn();
        MA.cancelRecord();
        MassAccountAssociation teste= new MassAccountAssociation (sc);
        //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Case_Lines__c' AND Name = 'Capital'];
       /* list<MassAssociateControllerv2.checkbox> lsttest=new list<MassAssociateControllerv2.checkbox>();
        teste.saveRecord();
        lsttest.add(new MassAssociateControllerv2.checkbox(true,1,objP));
        lsttest.add(new MassAssociateControllerv2.checkbox(false,1,objP));
        
        for(MassAssociateControllerv2.checkbox wapper: lsttest){
            PricebookEntry objPE1 = [ SELECT Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry  WHERE Product2Id =: wapper.t.Id];  
       
            if(wapper.s ==true){
                if(wapper.qty!=null && wapper.qty!=0){
                    OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.Id, PriceBookEntryID=objPE1.id, quantity=wapper.qty, TotalPrice=500);
                    insert lineItem1;  
                } 
            }
        } */
    
          
       
        teste.saveRecord();
        teste.strsearch='';
        teste.strsearch='';
        teste.refreshPage=True;
        //teste.strname='';
        teste.searchbtn();
        teste.cancelRecord();
        list<MassAccountAssociation.checkbox> lsttest=new list<MassAccountAssociation.checkbox>();
        lsttest= teste.getData();
        for(MassAccountAssociation.checkbox obj:lsttest){
            obj.s=true;
        }
        teste.saveRecord();
        list<MassAccountAssociation.checkbox> lsttest1=new list<MassAccountAssociation.checkbox>();
        lsttest1= teste.getData();
        for(MassAccountAssociation.checkbox obj:lsttest1){
            obj.s=true;
            obj.Startdate=System.TODAY();
            obj.Enddate=System.TODAY();
        }
        teste.saveRecord();
        Test.stopTest();
    }
}