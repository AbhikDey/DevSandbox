public class MassAssociateController {
    string recId;
    /*public String getsaveRecord() {
        system.debug('this is test method');
        return null;
    }*/
    
    public list<Equipment__c> equip{get;set;}
    public List<checkbox> cb{get;set;}

    public MassAssociateController(ApexPages.StandardController controller) {
        recId = controller.getRecord().Id;
       
        cb=getData();
           
    }
    
    public List<checkbox> getData(){
        Lab__c recName=[SELECT Account_Name__c FROm Lab__c WHERE Id =:recId];  
        
        equip = [SELECT Name, Account_Name__c,Account_Name__r.Name, RecordTypeId, LastModifiedById, LastModifiedDate, Product_Category__c, System_Manufacturer__c, Version_Type__c, Warranty_Status__c FROM Equipment__c WHERE Account_Name__c=:recName.Account_Name__c AND Account_Name__c != NULL AND Lab__c =null  ];
        
        cb = new List<checkbox>();
        
        for(Equipment__c pe: equip) {
            cb.add(new checkbox(false,pe));
        }
        
        return cb;
    }
    
    public class checkbox{
    
        public Boolean s{get;set;}
        public Equipment__c t {get;set;}
    
        public checkbox(Boolean s,Equipment__c t){        
            this.s=s;
            this.t=t;
        }
    }
         
     public pageReference saveRecord(){  
     
        PageReference pageRef = new PageReference('/'+recId);
        pageRef.setredirect(true);

              
        List<Equipment__c> lstEqu = new  List<Equipment__c>();
        system.debug('cb======='+cb);
        system.debug('recId===='+recId);
        
        for(checkbox wapper:cb ){
            system.debug('wapper.s======='+wapper.s);
            // check this record is selected or not
            if(wapper.s == true){
                lstEqu.add(wapper.t);// selected records are add to list        
            }
        }

        for(Equipment__c obj:lstEqu){
        
            obj.Lab__c= recId;
           
        }
        
        update lstEqu;
        return pageRef;
     }
    
    public pageReference cancelRecord(){
    
        PageReference pageRef = new PageReference('/'+recId);
        pageRef.setredirect(true);
        
        return pageRef;
    
    }
    
     
    
   }