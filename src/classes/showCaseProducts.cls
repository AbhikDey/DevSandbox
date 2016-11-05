public without sharing class showCaseProducts {
    
    public list<productsWrapper> lstProdW{get;set;}
    public string caseId{get;set;}
    public Decimal qty {get;set;} 
     public string strName{set;get;}
     public Boolean isAllSelect{set;get;}
      public String cseline2{get;set;}
       public  List<Case_Lines__c> cseline{get;set;}
        public Boolean refreshPage {get; set;}
    public showCaseProducts ()
    {
                   RecordType rtpe = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Case_Lines__c' AND Name = 'Capital'];
        caseId=ApexPages.currentPage().getParameters().get('id');
        lstProdW=new list<productsWrapper>();
        
         refreshPage=false;
      cseline= [SELECT Case__c,Recordtype.Id, Type__c, Product__r.Name,Product_Code__c, Qty__c FROM  Case_Lines__c WHERE Case__c=:caseId AND Recordtype.Id=:rtpe.Id  ];
     
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

       list<Case_Lines__c> lstOppItems=new list<Case_Lines__c>();
        
        for(productsWrapper wr : lstProdW)
        {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Case_Lines__c' AND Name = 'Capital'];
          if(wr.isSelect || wr.qty>0){
                if(wr.qty!=null && wr.qty>0 )
                {   
       
                    Case_Lines__c cslineItem=new Case_Lines__c();
                    cslineItem.recordtypeid= rt.Id;
                    cslineItem.Case__c=caseId;
                     cslineItem.Type__c=wr.cslne;
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
        public String cslne{get;set;}
        public product2 prods{get;set;}
        public boolean isSelect{get;set;}
        public productsWrapper(product2 prods,String cslne,Decimal qty, Boolean isSelect){
         this.prods=prods;
         this.cslne=cslne;
         this.isSelect=isSelect;
         this.qty = qty;
        }
        
    }
       public pageReference cancelRecord(){
    
        PageReference pageRef = new PageReference('/'+caseId);
        pageRef.setredirect(true);
        
        return pageRef;
    
    }
}