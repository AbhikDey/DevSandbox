@isTest
private class TestContractProductMultipicker {

    static testMethod void myUnitTest() {
        Test.startTest();
        
        Account ac = new Account();
        ac.name = 'Test Account';
        ac.SJM_ID__c= '1000000001';
        insert ac;
        
        
          
        Contract cnt = new Contract ();
        cnt.AccountId = ac.Id;
        cnt.Status= 'Draft';
        cnt.StartDate=system.today();
        cnt.ContractTerm = 12;
        
        insert cnt;
        
      
        
        Product2 objP=new Product2();
        objP.Name='Test product';
        objP.ProductCode='test';
       
        insert objP;
        
        Product2 objP1=new Product2();
        objP1.Name='Test product1';
        objP1.ProductCode='test1';
     
        insert objP1;
      
       
        
     
        
        ContractProductsMultipicker objProd=new ContractProductsMultipicker ();
        RecordType rt =  [SELECT Id, Name FROM RecordType WHERE sobjecttype='Contract_Line_Items__c' AND Name = 'Capital'];
        list<ContractProductsMultipicker.productsWrapper> lst=new list<ContractProductsMultipicker.productsWrapper>();
        objProd.Save();
        lst.add(new ContractProductsMultipicker.productsWrapper(objP,'New',1,true));
        lst.add(new ContractProductsMultipicker.productsWrapper(objP1,'New',1,false));
        objProd.selectAll();
        objProd.Save();
        objProd.strName='';
        objProd.search();
        objProd.strName='Test';
        objProd.search();
        objProd.cancelRecord();
       
        list<ContractProductsMultipicker.productsWrapper> lsttest=new list<ContractProductsMultipicker.productsWrapper>();
       lsttest= objProd.lstProdW;
        for(ContractProductsMultipicker.productsWrapper obj:lsttest){
            obj.isSelect=true;
        }
        objProd.Save();
        list<ContractProductsMultipicker.productsWrapper> lsttest1=new list<ContractProductsMultipicker.productsWrapper>();
       lsttest1= objProd.lstProdW;
        for(ContractProductsMultipicker.productsWrapper obj:lsttest1){
            obj.isSelect=true;
           obj.PrdType=  'New';
            obj.prods= objP;
            obj.qty=2;
        }
      
         objProd.Save();
        
        Test.stopTest();
    }
}