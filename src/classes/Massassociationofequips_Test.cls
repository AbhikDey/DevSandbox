@isTest(SeeAllData=true) 
public class Massassociationofequips_Test
{

   static testmethod void Labequips()
   {
   Recordtype rt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Account' AND Name = 'SJM Customer'];
        Account ac = new Account();
        ac.name = 'Test Account';
        ac.recordtypeid = rt.Id;
        ac.SJM_ID__c= '1000001';
        insert ac;
        
        
        Lab__c lb = new Lab__c();
        lb.Lab_Name__c ='Test';
        lb.Account_Name__c= ac.Id;
        insert lb;
        
        Recordtype eqrt = [SELECT Id, Name FROM RecordType WHERE sobjecttype='Equipment__c' AND Name = 'SJM Capital'];

         Equipment__c eq = new Equipment__c();
        eq.Account_Name__c = ac.Id;
        eq.Product_Category__c='X-Ray System';
        eq.System_Manufacturer__c='None';
        eq.Version_Type__c='EnSite Classic';
        eq.Warranty_Status__c='Under Warranty';
        eq.recordtypeId=eqrt.Id;
        insert eq;
        
         ApexPages.StandardController sc = new ApexPages.StandardController(lb);
       MassAssociateController casereport = new MassAssociateController  (sc);
        casereport.getData();
        
        casereport.saveRecord();
        
       
        casereport.cancelRecord();
        
        
        
      }
        
        }