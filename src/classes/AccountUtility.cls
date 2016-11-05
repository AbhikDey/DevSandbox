public class AccountUtility {
public static void UpdateAccountName(Case[] cases){
//RecordType svmxrt  = [SELECT Id, Name FROM RecordType WHERE Sobjecttype = 'Case' AND Name= 'Servicemax'];
  list<Account> lstAccount = new list<Account>();
    set<string> setofaccIds = new set<string>();
        Map<string, Id> MapIds = new Map<string, Id>();
  
   
        for(Case cs : cases) {
       
            setofaccIds.add(cs.Account_SJM_Id__c);
                setofaccIds.add(cs.Servicemax_SJM_ID__c);
            
            if(cs.Servicemax_SJM_ID__c == null){
               cs.SalesOrg_Account__c = cs.AccountId;
               }
               
        }
        
        lstAccount = [Select Id, SJM_ID__c From Account Where SJM_ID__c IN: setofaccIds];
            if(lstAccount != null && lstAccount.size() > 0) {
                for(Account acc : lstAccount) {
                    MapIds.put(acc.SJM_ID__c, acc.Id);
                    
            }
        }
        
      // Contact[] lstContact= [SELECT Id, SJM_ID__c FROM Contact WHERE SJM_ID__c IN : setofaccIds];
        /* if(lstAccount != null && lstAccount.size() > 0) {
             for(Contact cont : lstContact) {
             MapIds.put(cont.SJM_ID__c, cont.Id);
             
             }
             }*/
             
        
        for(Case cse : cases) {
       // String HRNUMBER='HR';
        if(cse.Account_SJM_Id__c !=null){
         cse.AccountId= MapIds.get(cse.Account_SJM_Id__c);
         
        /*   if(cse.Account_SJM_Id__c.contains(HRNUMBER)){
                cse.ContactId = MapIds.get(cse.Account_SJM_Id__c);
                  }
                   else{
                   cse.AccountId= MapIds.get(cse.Account_SJM_Id__c);
                   }*/
                   }
                
               if(cse.Servicemax_SJM_ID__c != null){
               cse.Servicemax_Account__c = MapIds.get(cse.Servicemax_SJM_ID__c );
              // cse.RecordtypeId = svmxrt.Id;
               cse.AccountId = MapIds.get(cse.Servicemax_SJM_ID__c );
               }
               
            
            
        }
        }



public static void addproduct(Case[] c){
List<OpportunityLineItem> oppitem = new List<OpportunityLineItem>();
List<Case_Lines__c> caseproduct = new List<Case_Lines__c>();

string opp;
string cse;



for(Case cs : c){
  if(cs.opportunity__c != null){
  opp = cs.opportunity__c;
  cse = cs.Id;
}
}

oppitem  = [SELECT Id, Product2Id,Product2.USD_Product_Category__c,Product_Type__c,Product2.USD_Selling_Division__c, Quantity FROM OpportunityLineItem WHERE OpportunityId =: opp];

RecordType rt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Case_Lines__c' AND NAME = 'Capital'];
system.debug('OppId'+opp);
system.debug('Listofoppproditems'+oppitem.size()  );
for(OpportunityLineItem opplineitem : oppitem ){
              
   
              Case_Lines__c aff = new Case_Lines__c();
              aff.RecordtypeId = rt.Id;
              aff.Case__c = cse ;
              aff.Division__c = opplineitem.Product2.USD_Selling_Division__c;
           aff.Product_Category__c =  opplineitem.Product2.USD_Product_Category__c;
              aff.Product__c = opplineitem.Product2Id;
              aff.Qty__c = opplineitem.Quantity;
               aff.Type__c= opplineitem.Product_Type__c;
            
       caseproduct.add(aff);
      
}
system.debug('ListofCaseitems'+caseproduct.size());
insert caseproduct;
}



}