public class MassAccountAssociation {
    string recId;
    /*public String getsaveRecord() {
        system.debug('this is test method');
        return null;
    }*/
    public String DealId {get;set;}
      public string strsearch{get;set;}
      public string strsear{get;set;}
   public string  searchmem{get;set;}
      //public DATE Startdate {get;set;}
       public DATE Enddate {get;set;}
       public Date Startdate { get { return Date.today(); }}
    public list<Account> equip{get;set;}
    public List<Group_Members__c> ListAccounts{get;set;} 
      public List<Group_Members__c> Deals{get;set;} 
    public List<checkbox> cb{get;set;}
    public Boolean refreshPage {get; set;}
   
    public MassAccountAssociation(ApexPages.StandardController controller) {
  
        recId = controller.getRecord().Id;
           // Startdate = null;
            Enddate=null;
       refreshPage=false;
         ListAccounts= [SELECT Id, Associated_Account__c,Associated_Account__r.Name ,Start_date__c, End_date__c, SJM_ID__c FROM Group_Members__c WHERE Group__c =: recId ORDER BY Start_date__c DESC  ];
        cb=getData();
           
    }

    
    public List<checkbox> getData(){
        Account recName=[SELECT Id, Name,Billingcity,BillingState, SJM_ID__c FROM Account WHERE Id =:recId AND (BillingCountry='US' OR BillingCountry='CA' OR BillingCountry='')];  
        
        equip = [SELECT Name, SJM_ID__c,Billingcity,BillingState,Type FROM Account WHERE SJM_ID__c!= null AND BillingCountry !=null ORDER BY SJM_ID__c LIMIT 7 ];
          
        cb = new List<checkbox>();
        
        for(Account pe: equip) {
            cb.add(new checkbox(false,Startdate,Enddate, pe));
        }
        
        return cb;
    }
    
        
     public pagereference searchbtn()
    {
        if(strsear != null && strsear != '')
        {
            string strnam = '%'+strsear+'%';
            //  Opportunity recName=[SELECT AccountId, Account.Name FROm Opportunity WHERE Id =:recId];  
            equip = new List<Account>();
            equip = [SELECT Id, Name, SJM_ID__c,Billingcity,BillingState,Type FROM Account WHERE (Name LIKE : strnam OR SJM_ID__c  LIKE :strnam OR Type LIKE : strnam) AND (BillingCountry='US' OR BillingCountry='CA' OR BillingCountry='') AND (Type !='IDN' AND Type !='GPO' AND Type !='Group') LIMIT 25 ];
            cb = new List<checkbox>();
            for(Account pe: equip) {
                cb.add(new checkbox(false,Startdate ,Enddate, pe));
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter any Account name');
            ApexPages.addMessage(myMsg);
            return null;
        }
        strsear=null;
        return null;
    }
    
     public pagereference searchmem()
    {
        if(strsearch != null && strsearch != '')
        {
            string strname = '%'+strsearch+'%';
            //  Opportunity recName=[SELECT AccountId, Account.Name FROm Opportunity WHERE Id =:recId];  
            ListAccounts= new List<Group_Members__c >();
           ListAccounts= [SELECT Id, Associated_Account__c,Associated_Account__r.Name ,Start_date__c, End_date__c, SJM_ID__c FROM Group_Members__c WHERE Group__c =: recId AND  (Associated_Account__r.Name LIKE : strname  OR  SJM_ID__c LIKE : strname) ];
           
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter any Account name');
            ApexPages.addMessage(myMsg);
            return null;
        }
        strsearch=null;
        return null;
    }
    
    public class checkbox{
    
        public Boolean s{get;set;}
        public Date Startdate {get;set;}
        public Date Enddate {get;set;}
        public Account t {get;set;}
    
        public checkbox(Boolean s,Date Startdate ,Date Enddate, Account t){        
            this.s=s;
            this.Startdate = Startdate;
            this.Enddate = Enddate;
            this.t=t;
        }
    }
    
    public void deleteDeal(){
       deals = [SELECT Id, Associated_Account__c,Associated_Account__r.Name ,Start_date__c, End_date__c, SJM_ID__c FROM Group_Members__c WHERE id =: dealId];
      if(deals.size() > 0 || deals[0].Id != ''){
      delete deals;
      }
       refreshPage=true;
  
   }
         
     public pageReference saveRecord(){  
     
        PageReference pageRef = new PageReference('/'+recId);
        pageRef.setredirect(true);

              
        List<Account> acts = new List<Account>();
        system.debug('cb======='+cb);
        system.debug('recId===='+recId);
             List<Group_Members__c > grpmems = new   List<Group_Members__c >();
        for(checkbox wapper:cb ){
            system.debug('wapper.s======='+wapper.s);
            // check this record is selected or not
            if(wapper.s == true){
          Group_Members__c grpmem = new Group_Members__c ();
           grpmem.Group__c = recId;
           grpmem.Account_Type__c =wapper.t.Type ;
           grpmem.Associated_Account__c= wapper.t.Id;
           grpmem.Start_date__c = wapper.Startdate;
           grpmem.End_date__c = wapper.Enddate;
           
           grpmems.add(grpmem); 
            }
                  
        }
   

       
        
         update ListAccounts;  
     
        
  Database.insert(grpmems) ;
         refreshPage=true;
        return null;
     }
    
    
    public pageReference cancelRecord(){
    
        PageReference pageRef = new PageReference('/'+recId);
        pageRef.setredirect(true);
        
        return pageRef;
    
    }
    
     
    
   }