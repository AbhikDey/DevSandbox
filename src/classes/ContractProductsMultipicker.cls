public without sharing class ContractProductsMultipicker {
    
    public list<productsWrapper> lstProdW{get;set;}
    public string ContractId{get;set;}
    public Decimal qty {get;set;} 
     public string strName{set;get;}
     public Boolean isAllSelect{set;get;}
      public String cseline2{get;set;}
       public  List<Contract_Line_Items__c> cntrctline{get;set;}
        public Boolean refreshPage {get; set;}
    public ContractProductsMultipicker ()
    {
                   RecordType rtpe = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Contract_Line_Items__c' AND Name = 'Capital'];
        ContractId=ApexPages.currentPage().getParameters().get('id');
        lstProdW=new list<productsWrapper>();
        
         refreshPage=false;
      cntrctline= [SELECT Contract__c,Recordtype.Id, Product_Type__c, Product__r.Name,Product__r.ProductCode, Qty__c FROM  Contract_Line_Items__c WHERE Contract__c=:ContractId AND Recordtype.Id=:rtpe.Id  ];
     
        for(Product2 Prod:[select id, Name, ProductCode,USD_Selling_Division__c,USD_Product_Category__c from Product2 order by Name LIMIT 10])
        {
           
             lstProdW.add(new productsWrapper(Prod,cseline2,qty,false));
        }    
    }
    
   

    

    public PageReference Save() {
        map<string,PricebookEntry> mapPrEntry=new map<string,PricebookEntry>();
        for(PricebookEntry pe:[select id, Product2Id ,Pricebook2Id,UnitPrice from PricebookEntry ])
        {
            mapPrEntry.put(pe.Product2Id,pe);
        }

       list<Contract_Line_Items__c > lstOppItems=new list<Contract_Line_Items__c >();
        
        for(productsWrapper wr : lstProdW)
        {
        RecordType rt =   [SELECT Id, Name FROM RecordType WHERE sobjecttype='Contract_Line_Items__c' AND Name = 'Capital'];
          if(wr.isSelect || wr.qty>0){
                if(wr.qty!=null && wr.qty>0 )
                {   
       
                    Contract_Line_Items__c  cslineItem=new Contract_Line_Items__c ();
                    cslineItem.recordtypeid= rt.Id;
                    cslineItem.Contract__c=ContractId;
                     cslineItem.Product_Type__c=wr.PrdType;
                    cslineItem.Division__c= wr.prods.USD_Selling_Division__c;
                   cslineItem.Product__c=wr.prods.Id;
                  cslineItem.Product_Category__c=wr.prods.USD_Product_Category__c;
                    cslineItem.Qty__c= wr.qty;
                     system.debug(' qty is >>>>'+qty);
                    lstOppItems.add(cslineItem);
                    
                }
                else
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Quantity is mandatory');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
        }

       
         
        if(lstOppItems.isempty()){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast one product');
                    ApexPages.addMessage(myMsg);
                    return null;
        }

        Database.insert(lstOppItems);
       // Pagereference pf=new Pagereference('/apex/caselineitems?id='+caseId);
       refreshPage=true;
         
        return null;
    }
    public void search(){
    
       if(strName!=null && strName!=''){
       string strsearch  = '%'+ strName +'%'; 
         lstProdW=new list<productsWrapper>();
        for(Product2 Prod:[select id, Name, ProductCode,USD_Selling_Division__c,USD_Product_Category__c from Product2 where NAME LIKE: strsearch  OR ProductCode LIKE: strsearch  OR USD_Selling_Division__c LIKE: strsearch  OR USD_Product_Category__c LIKE: strsearch  ]){
            
             lstProdW.add(new productsWrapper(Prod,cseline2,qty,false));
        }
      }else{
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter product name');
                ApexPages.addMessage(myMsg);
               
      }
    }
    public PageReference selectAll(){
    list<productsWrapper> temp= new list<productsWrapper>();
    temp=lstProdW;
    lstProdW=new list<productsWrapper>();
    for(productsWrapper obj:temp){
        obj.isSelect=true;
        lstProdW.add(obj);
    }
    system.debug('isAllSelect=='+isAllSelect);
    return null;
    }
    public class productsWrapper{
        public Decimal qty{get;set;}
        public String PrdType{get;set;}
        public product2 prods{get;set;}
        public boolean isSelect{get;set;}
        public productsWrapper(product2 prods,String PrdType,Decimal qty, Boolean isSelect){
         this.prods=prods;
         this.PrdType=PrdType;
         this.isSelect=isSelect;
         this.qty = qty;
        }
        
    }
       public pageReference cancelRecord(){
    
        PageReference pageRef = new PageReference('/'+ContractId);
        pageRef.setredirect(true);
        
        return pageRef;
    
    }
}