@isTest
private class TestshowCaseProducts {

    static testMethod void myUnitTest() {
        Test.startTest();
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
        
        showCaseProducts objProd=new showCaseProducts();
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Case_Lines__c' AND Name = 'Capital'];
        list<showCaseProducts.productsWrapper> lst=new list<showCaseProducts.productsWrapper>();
        objProd.Save();
        lst.add(new showCaseProducts.productsWrapper(objP,'New',1,true));
        lst.add(new showCaseProducts.productsWrapper(objP1,'New',1,false));
        objProd.selectAll();
        objProd.Save();
        objProd.strName='';
        objProd.search();
        objProd.strName='Test';
        objProd.search();
        objProd.cancelRecord();
       
        list<showCaseProducts.productsWrapper> lsttest=new list<showCaseProducts.productsWrapper>();
       lsttest= objProd.lstProdW;
        for(showCaseProducts.productsWrapper obj:lsttest){
            obj.isSelect=true;
        }
        objProd.Save();
        list<showCaseProducts.productsWrapper> lsttest1=new list<showCaseProducts.productsWrapper>();
       lsttest1= objProd.lstProdW;
        for(showCaseProducts.productsWrapper obj:lsttest1){
            obj.isSelect=true;
           obj.cslne=  'New';
            obj.prods= objP;
            obj.qty=2;
        }
      
         objProd.Save();
        
        Test.stopTest();
    }
}