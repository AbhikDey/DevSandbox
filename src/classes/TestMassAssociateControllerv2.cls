@isTest
private class TestMassAssociateControllerv2  {

    static testMethod void myUnitTest() 
    {
        Test.startTest();
        
        Account ac = new Account();
        ac.name = 'Test Account';
       ac.SJM_ID__c= '1000000001';
        insert ac;
        
        Opportunity opp = new Opportunity();
        opp.name = 'test';
        opp.AccountId= ac.Id;
        opp.StageName= 'Prospecting';
        opp.CloseDate = system.Today();
        insert opp;
        
        
        Case objCase=new Case();
        objCase.Subject='Test Subject';
        objCase.Description='Test Description';
        insert objCase;
        
        Case_Lines__c objLine=new Case_Lines__c();
        objLine.Case__c=objCase.Id;
        ApexPages.currentPage().getParameters().put('id',objCase.Id);
        
        Product2 objP=new Product2();
        objP.Name='Test product';
        objP.ProductCode='test';
       
        insert objP;
        
        Product2 objP1=new Product2();
        objP1.Name='Test product1';
        objP1.ProductCode='test1';
       
        insert objP1;
        
        Pricebook2 objPB=new Pricebook2();
        objPB.Name='Test';
        objPB.IsActive = true;      
        insert objPB;
        
        //PriceBook2 pb2 = [select Id from Pricebook2 where IsStandard=true];
        
        PricebookEntry objPE=new PricebookEntry();
        objPE.Product2Id=objP.Id;
        objPE.Pricebook2Id=Test.getStandardPricebookId();
        objPE.UnitPrice=500;
        objPE.IsActive = true;
        objPE.UseStandardPrice = false;
        insert objPE;
        
       
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        MassAssociateControllerv2 objProd = new MassAssociateControllerv2(sc);
        //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Case_Lines__c' AND Name = 'Capital'];
        list<MassAssociateControllerv2.checkbox> lst=new list<MassAssociateControllerv2.checkbox>();
        lst.add(new MassAssociateControllerv2.checkbox(true,'New',1,objP));
        lst.add(new MassAssociateControllerv2.checkbox(false, 'New',1,objP1 ));
        objProd.saveRecord();
        objProd.strsearch='';
        //objProd.search();
        objProd.strsearch='Test';
         objProd.strname='%Test%';
        objProd.searchbtn();
        objProd.cancelRecord();
        MassAssociateControllerv2 teste= new MassAssociateControllerv2(sc);
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
        teste.strname='';
        teste.searchbtn();
        teste.cancelRecord();
        list<MassAssociateControllerv2.checkbox> lsttest=new list<MassAssociateControllerv2.checkbox>();
        lsttest= teste.binddata();
        for(MassAssociateControllerv2.checkbox obj:lsttest){
            obj.s=true;
        }
        teste.saveRecord();
        list<MassAssociateControllerv2.checkbox> lsttest1=new list<MassAssociateControllerv2.checkbox>();
        lsttest1= teste.binddata();
        for(MassAssociateControllerv2.checkbox obj:lsttest1){
            obj.s=true;
           obj.prdtype=  'New';
            obj.qty=1;
        }
        teste.saveRecord();
        Test.stopTest();
    }
}