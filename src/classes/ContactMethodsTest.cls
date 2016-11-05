@isTest
Private class ContactMethodsTest{
//Create a contact, create an account
//invoke method to associate
static testmethod void CreateAffiliation()
{
Account Acct = new Account(Name = 'TestAffiliation');
Insert Acct;
Id sAcctId  = Acct.Id;

Contact Con = new Contact(LastName = 'Demo', FirstName = 'Affiliation',AccountId = sAcctId, Email='test1@gmail.com');
Insert Con;
Id sConId = Con.Id;

//Affiliation__c Aff = new Affiliation__c(Account__c = sAcctId, Contact__c = sConId, Role__c = 'Physician' );

//Insert Aff;

Affiliation__c NewAff = [select Account__c,Contact__c,Status__c from Affiliation__c where Account__c=:sAcctId  AND Contact__c = :sConId];

system.assertEquals('Active', NewAff.Status__c);

}
}