@IsTest

public class Procedure_preventDeletion_test
{
    static testMethod void testDelete()
    {
        Account a1 = new Account  (
                     Name = 'Demo Account');
                insert a1;
                system.assertNotEquals( null, a1.Id );

        RecordType rt = [Select id From RecordType Where SobjectType = :'Contact' AND DeveloperName = :'Physician'];

        Contact c1 = new Contact(
                    firstname = 'phys1',
                    lastname = 'phys2',
                    AccountId = a1.Id,
                    Email='abc@sjm.com',
                    RecordTypeID = rt.id);
                    insert c1;   

        Procedure__c prc = new Procedure__c();
        
        prc.Procedure__c = 'AF';
        prc.Procedure_Type__c = 'Array';
        prc.Account__c = a1.Id;
        prc.Procedure_Physician__c = c1.id;
        insert prc;
        
       /* Procedure__c prcNotDeletable = new Procedure__c();
        prcNotDeletable.Procedure__c = 'AF';
        prcNotDeletable.Procedure_Type__c = 'Array';
        prcNotDeletable.Account__c = '001g000000irTmd';
        prcNotDeletable.Procedure_Physician__c  = c1.id;
        
        insert prcNotDeletable;
        
        Datetime longBack= Datetime.now().addDays(-4);       
        Test.setCreatedDate(prcNotDeletable.Id, longBack)
*/

        delete prc;
      /*  Try
        {
            delete prcNotDeletable;
            system.assert(false); // It should throw an error
        }
        catch(exception e)
        {
            system.assert(true);
        }
        */
        
       
    }
    
    
}