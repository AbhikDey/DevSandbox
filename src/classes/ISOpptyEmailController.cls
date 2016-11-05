public class ISOpptyEmailController {
  
  public Id opptyId {get;set;}
  //wrapper class start
  public class aTableRow {
    
    public Opportunity opt { get; set; }
    public OpportunityLineItem ol { get; set; }
    public Equipment__c equ { get; set; }
    public aTableRow(Equipment__c a, OpportunityLineItem b, Opportunity c) {
      equ = a;
      ol = b;
      opt = c;
    }
  }
  //end of wrapper class
  //CONSTRUCTOR
  public List<aTableRow> gettableRows() {
    list<aTableRow> tblrow = new List<aTableRow>();
   // List<Id> eqIds = new List<Id>();
    for(Opportunity op:[select AccountId, CloseDate, Name from Opportunity where id=:opptyId]) {
    for(Equipment__c eq:[select Account_Name__r.SJM_ID__c,Account_Name__r.Name,Serial_Lot_Number__c,Installed_Product_Name__c,Sale_Type__c,Oppty_Product_Model__c,Warranty_End__c,List_Price__c,Account_Name__c from Equipment__c where Account_Name__c=:op.AccountId and Warranty_End__c=:op.CloseDate]){
        tblrow.add(new aTableRow(eq,null,op));
        system.debug('@@tablerow:' + tblrow);
        }
    }
    //SUCCESS
       for(OpportunityLineItem opli:[select Equipment__c,Equipment__r.Account_Name__r.SJM_ID__c,Equipment__r.Account_Name__r.Name,Equipment__r.Serial_Lot_Number__c,Equipment__r.Installed_Product_Name__c,Equipment__r.Sale_Type__c,Equipment__r.Oppty_Product_Model__c,Equipment__r.Warranty_End__c,Equipment__r.Account_Name__c,TotalPrice from OpportunityLineItem where OpportunityId=:opptyId]){
        for(aTableRow t:tblrow){
        if(opli.Equipment__c == t.equ.Id){
        t.ol = opli;
            system.debug('@@Opptyline:' + opli);
        }
        }
        }
            return tblrow;
        }
        }