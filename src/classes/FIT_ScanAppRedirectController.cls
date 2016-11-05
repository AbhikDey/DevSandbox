/**
 * Controller for the page ScanAppRedirect.page
 * @DateCreated: 1/20/2016
 * @Author: Andres Di Geronimo-Stenberg (Magnet360)
 */
global without sharing class FIT_ScanAppRedirectController 
{
    public String scanValue {get; set;}
    public String transactionId {get; set;}

/******************************************************************************
 * FIT_ScanAppRedirectController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 1/20/16
 * @jira: 
 * @description: Constructor. Gets the parameters passsed on the url
 * @param: None
 * @return: None.
 ******************************************************************************/
    public FIT_ScanAppRedirectController( ) 
    {
        System.debug('### STAR METHOD : FIT_ScanAppRedirectController()' );

        scanValue = ApexPages.currentPage().getParameters().get('scanValue');

        System.debug('*** scanValue : ' + scanValue.length() );

        transactionId = ApexPages.currentPage().getParameters().get('Id');

        //Below are two sample GTIN barcodes, one for a 7-digit serial number 
        //and one for a 9-digit serial number. Pull in all digits after the last 
        //parenthesis.
        //(01)05414734503617(17)151231(21)7513909
        //(01)05414734502443(17)151231(21)CGE010079
        
        if (EncodingUtil.urlDecode(scanValue, 'UTF-8').length() == 36) {
        	scanValue = scanValue.right(7);
    	} else if (EncodingUtil.urlDecode(scanValue, 'UTF-8').length() == 37) {
    		scanValue = scanValue.right(8);
		} else if (EncodingUtil.urlDecode(scanValue, 'UTF-8').length() == 38) {
			scanValue = scanValue.right(9);
		}
        
        //scanValue = scanValue.substringAfterLast(')');

        System.debug('*** scanValue : ' + scanValue );
        System.debug('*** transactionId : ' + transactionId );

        System.debug('### STOP METHOD : FIT_ScanAppRedirectController()' );
    }
 
/******************************************************************************
 * redirect
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 1/20/16
 * @jira: 
 * @description: Obtains the Inventory related with the code passed as url-parameter
                 and creates a new TransactionItem related with the transactionId
                 passed as url-parameter
 * @param: None.
 * @return: PageReference.
 ******************************************************************************/    
    public PageReference redirect() 
    {
        System.debug('### STAR METHOD : redirect()' );
        System.debug('UAC: scanValue in redirect  ' + scanValue ) ;

        List<Inventory__c> inventory = [ SELECT Id 
                                         FROM Inventory__c 
                                         WHERE Serial_Number__c = :scanValue ] ;

        /*if( inventory.size() > 0 )
        {
            System.debug('UAC: product ' + inventory[0].Id ); 

            Transaction_Items__c item = new Transaction_Items__c();
            item.Transaction_ID__c = transactionId; 
            item.Received__c = True; 
            item.Inventory__c = inventory[0].Id; 
            item.Quantity__c = 1 ;
            insert item ;

            System.debug('UAC: after inert ' + item ); 
        }*/

        FIT_DeepLinkDummy__c newScan = new FIT_DeepLinkDummy__c(
        	FIT_Transaction__c = transactionId,
        	FIT_Serial_Value__c = scanValue,
        	FIT_Serial_Found__c = (inventory.size() > 0 ? true : false),
        	FIT_Inventory__c = (inventory.size() > 0 ? inventory[0].Id : null)
        );

        insert newScan;

        PageReference pageRef = new PageReference('salesforce1://sObject/' + newScan.Id + '/view');
        pageRef.setRedirect(true);

        System.debug('### STOP METHOD : redirect()' );
        return pageRef ;
    }

}