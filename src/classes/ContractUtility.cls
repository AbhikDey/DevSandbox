public class ContractUtility {

public static void Contractlineitems(Contract [] cont){

List<Case_Lines__c> cseitem = new List<Case_Lines__c>();

List<Contract_Line_Items__c> contprod = new List<Contract_Line_Items__c>();


string cse;
string cnt;

for(Contract cs : cont){

 
  cnt= cs.Id;
  if(cs.Request_Number__c!= null){
  

  cse = cs.Request_Number__c;
 
  
}
}



cseitem  = [SELECT Id,Recordtype.Name,Division__c,Type__c, Product_Category__c, Product__c, Qty__c FROM Case_Lines__c WHERE Case__c=: cse   ];

 RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Contract_Line_Items__c' AND Name = 'Capital'];
 RecordType rt1 = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Contract_Line_Items__c' AND Name = 'Implants & Disposables'];
 RecordType rt2 = [SELECT Id, Name FROM RecordType WHERE SObjecttype = 'Contract_Line_Items__c' AND Name = 'Capital Alternative Program'];









for(Case_Lines__c cselineitem : cseitem ){

      
     if(cseitem.size() >0  ){
     
        Contract_Line_Items__c aff = new Contract_Line_Items__c();
        if(cselineitem.Recordtype.Name == 'Capital'){
              aff.RecordtypeId=rt.Id;
              }
             if(cselineitem.Recordtype.Name == 'Implants & Disposables'){
                aff.RecordtypeId=rt1.Id;
              }
                  if(cselineitem.Recordtype.Name == 'Capital Alternative Program'){
                      aff.RecordtypeId=rt2.Id;
                  }
            aff.Contract__c = cnt ;
            aff.Product_Type__c= cselineitem.Type__c ;
           aff.Product__c = cselineitem.Product__c ;
            aff.Product_Category__c= cselineitem.Product_Category__c;
             aff.Division__c= cselineitem.Division__c;
             aff.Qty__c = cselineitem.Qty__c;
              contprod.add(aff);
                 
                 
     
}

}
insert contprod;

}



public static void Cont(Contract [] contr){

Set<Id> cntitem = new Set<Id>();
List<Case> cse = new List<Case>();


string cset;


for(Contract cs : contr){
  if(cs.Request_Number__c!= null){
cntitem.add(cs.Request_Number__c);
 cset = cs.AccountId;

}

cse = [SELECT Id, AccountId FROM Case WHERE Id IN: cntitem ];


for(Case cselineitem : cse ){
              
       cset = cselineitem.AccountId;
          
      
   
}

for(Contract csri : contr){
 if(csri.Request_Number__c!= null){
 csri.AccountId = cset ;
  
}
}

}

}




 


}