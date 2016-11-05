public without sharing class MassAssociateControllerv2 
{
    string recId;
    public List<checkbox> cb{get;set;}
    public Integer qty {get;set;} 
    public string strsearch{get;set;}
    public String prdType{get;set;}
    public string strname{get;set;}
    public Boolean refreshPage {get; set;}
    // public List<OpportunityLineItem> contRecords{get;set;}
    public List<OpportunityLineItem> oppline{get;set;}
    /*public String getsaveRecord() {
        system.debug('this is test method');
        return null;
    }*/
    public list<Product2> equip{get;set;}
    public MassAssociateControllerv2(ApexPages.StandardController controller) 
    {
        recId = controller.getRecord().Id;
        String pd;
        qty= null;
        refreshPage=false;
        cb=binddata();
           
    }
    
    
    
    
    public List<checkbox> binddata()
    {
        // Opportunity recName=[SELECT AccountId, Account.Name FROm Opportunity WHERE Id =:recId];  
        equip = [SELECT Id, Name,Productcode, USD_Product_Category__c, USD_Selling_Division__c FROM Product2  LIMIT 10  ];
        
        List<Contract> cnt = [SELECT Id FROM CONTRACT  LIMIT 10  ];
        cb = new List<checkbox>();
        for(Product2    pe: equip) 
        {
            cb.add(new checkbox(false,prdType,qty, pe));
        }
        oppline= [SELECT Name,ProductCode,Product_Type__c, Product2.Name, OpportunityId, Quantity FROM  OpportunityLineItem WHERE OpportunityId =:recId];
        return cb;
    }
    public pagereference searchbtn()
    {
        if(strsearch != null && strsearch != '')
        {
            string strname = '%'+strsearch+'%';
            //  Opportunity recName=[SELECT AccountId, Account.Name FROm Opportunity WHERE Id =:recId];  
            equip = new List<Product2 >();
            equip = [SELECT Id, Name,Productcode,USD_Product_Category__c, USD_Selling_Division__c FROM Product2 WHERE Name LIKE : strname OR USD_Selling_Division__c LIKE : strname OR USD_Product_Category__c LIKE : strname ];
            cb = new List<checkbox>();
            for(Product2    pe: equip) {
                cb.add(new checkbox(false,prdType,qty,pe));
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter any Product name');
            ApexPages.addMessage(myMsg);
            return null;
        }
        strsearch=null;
        return null;
    }
    public class checkbox{
    
        public Boolean s{get;set;}
        public Integer qty{get;set;}
        Public String prdType{get;set;}
        public Product2    t {get;set;}
            public checkbox(Boolean s,String prdtype, Integer qty, Product2   t){        
            this.s=s;
            this.prdtype = prdtype;
            this.qty=qty;
            this.t=t;
        }
    }
    
    // set the value to false in the constructor 
    public pageReference saveRecord()
    {  
        map<string,PricebookEntry> mapPrEntry=new map<string,PricebookEntry>();
        for(PricebookEntry pe:[select id, Product2Id ,Pricebook2Id,UnitPrice from PricebookEntry WHERE IsActive=TRUE AND currencyisocode='USD' ])
        {
            mapPrEntry.put(pe.Product2Id,pe);
        }
        list<OpportunityLineItem> lstOppItems=new list<OpportunityLineItem>();
        PageReference pageRef = new PageReference('/'+recId);
        pageRef.setredirect(true);
        string strproduct='';
        List<Opportunity > lstEqu = new  List<Opportunity >();
        system.debug('cb======='+cb);
        system.debug('recId===='+recId);
        for(checkbox wapper:cb )
        {
            string test = wapper.t.Id;
            system.debug('Id======='+test);
            // check this record is selected or not
            if(wapper.s == true){
                if(wapper.qty!=null && wapper.qty!=0){
                    OpportunityLineItem oppItem=new OpportunityLineItem();
                    oppItem.OpportunityId=recId;
                    if(mapPrEntry!=null && mapPrEntry.get(test)!=null){
                        oppItem.PricebookEntryId=mapPrEntry.get(test).Id;
                        oppItem.Product_Type__c = wapper.prdtype;
                        oppItem.UnitPrice= mapPrEntry.get(test).UnitPrice;
                    }
                    oppItem.Quantity=wapper.qty;
                   
                    lstOppItems.add(oppItem);
                    system.debug('recId===='+oppItem.UnitPrice);
                    system.debug('cb======='+oppItem.PricebookEntryId);
       
                }else
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Quantiy is mandatory');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
             
            }
        }
        if(lstOppItems.isempty())
        {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast one product');
                    ApexPages.addMessage(myMsg);
                    return null;
        }else{
            try{
                Database.insert(lstOppItems);
            }catch(Exception e) {
                system.debug('e.getMessage()==='+e);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
            // Pagereference pf=new Pagereference('/apex/opportunityassociation?scontrolCaching=1&id='+recId);
            refreshPage=true;
            //  contRecords= [SELECT Name,ProductCode,Product2.Name, OpportunityId, Quantity FROM  OpportunityLineItem WHERE OpportunityId =:recId];
            return null;
    }
    
    public pageReference cancelRecord(){
    
        PageReference pageRef = new PageReference('/'+recId);
        pageRef.setredirect(true);
        return pageRef;
    
    }
    
     
}