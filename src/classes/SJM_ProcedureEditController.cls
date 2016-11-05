/******************************************************************************
* Controller for SJM_ProcedureEdit VF page.
*
* @Author: Adeel Ahmad ( Magnet 360 )
* @Date: 11/24/2015
*/
public with sharing class SJM_ProcedureEditController 
{
    // Private variables
    private ApexPages.StandardController stdController;
    private ID procedureId {get; set;}
    
    // Public Variables
    public ID accountId {get; set;}
    public Procedure__c currentProcedure {get; set;} 
    public String procedureDate {get; set;}
    public ID eventId {get; set;}
    public ID contID {get; set;}
    
    /******************************************************************************
    * Get Instance of procedure item settings
    *
    * @Author: Adeel Ahmad ( Magnet 360 )
    * @Date: 11/24/2015
    * @Type Of Variable : Getter , Setter ( Private )
    * @Return : Procedure_Tracker_Settings__c instance
    *******************************************************************************/

    private Procedure_Tracker_Settings__c pSettings {
        get{
            if(pSettings == null){
                pSettings = Procedure_Tracker_Settings__c.getInstance();                
            }
            return pSettings;
        }
        set;
    }
    
    /******************************************************************************
    * Get Map of picklist labels to list of procedure items, If procedure record is 
    * need to edit then query on procedure items against procedure, Then put the \
    * picklist labels to as key in map and proceudre item list
    *
    * @Author: Adeel Ahmad ( Magnet 360 )
    * @Date: 11/24/2015
    * @Type Of Variable : Getter , Setter ( Public )
    * @Return : Map<String, List<Procedure_Item__c>> instance
    *******************************************************************************/ 
    public Map<String, List<Procedure_Item__c>> typeToProcedureItems {
        get {
            Id procedureId = this.stdController.getId();

            if (typeToProcedureItems == null) {
                typeToProcedureItems  = new Map<String, List<Procedure_Item__c>> ();
            }
            
            if (typeToProcedureItems.size() == 0 && procedureId != null) {
                
                for (Procedure_Item__c p : [
                    SELECT  Id, 
                            Name, 
                            Procedure_Item__c, 
                            Manufacturer__c,
                            Procedure__c,
                            Resterilized__c,
                            Location__c,
                            Catheter_Type__c,
                            Number_of_Electrodes__c,
                            Tip_Size__c,
                            Notes__c
                    FROM Procedure_Item__c
                    WHERE Procedure__c = :procedureId
                    ORDER BY Procedure_Item__c
                ]) {
                    
                    List<Procedure_Item__c> procedureItems = typeToProcedureItems.get(p.Procedure_Item__c);
                    if (procedureItems == null) {
                        procedureItems = new List<Procedure_Item__c>();
                        typeToProcedureItems.put(p.Procedure_Item__c, procedureItems);
                    }
                    procedureItems.add(p);
                }
            }

            //Iterating over all procedure item types and create new procedure item for all item types
            //Initally all item types will be listed and there will be one record for each procedure item type
            for (String picklistEntryLabel : procedureItemPicklistLabels )
            {
                //If there is already procedure item record  saved, incase of edit then don;t add it to procedure items list
                if (typeToProcedureItems.get( picklistEntryLabel ) == null){
                    LIST<Procedure_Item__c> pList = new LIST<Procedure_Item__c>();
                    Procedure_Item__c pc = new Procedure_Item__c(Procedure_Item__c = picklistEntryLabel);
                    pList.add(pc);
                    typeToProcedureItems.put( picklistEntryLabel, pList );
                }
            }
            System.debug('AA:typeToProcedureItems' + typeToProcedureItems);
            return typeToProcedureItems;
        }
        set;
    }
    
    /******************************************************************************
    * Get list of Procedure Item Field Picklist values 
    *
    * @Author: Adeel Ahmad ( Magnet 360 )
    * @Date: 11/24/2015
    * @Type Of Variable : Getter , Setter ( Public )
    * @Return : procedureItemPicklistLabels List<String> instance
    *******************************************************************************/
    public List<String> procedureItemPicklistLabels {
        get{
            
            // If List has not populated then..
            if( procedureItemPicklistLabels == null ){
                
                // Initialize list 
                procedureItemPicklistLabels = new List<String>();
                
                // Iterate over described picklist values 
                for( Schema.Picklistentry pe : Procedure_Item__c.Procedure_Item__c.getDescribe().getPicklistValues() ){
                    
                    // add to list
                    if(pe.getLabel() != 'DBS')
                    {
                        procedureItemPicklistLabels.add( pe.getLabel() );
                    }
                }
            }
            
            // return picklist labels list
            return procedureItemPicklistLabels; 
        } 
        set;
    }

    /******************************************************************************
    * Get Map of Required fields from custom settings
    *
    * @Author: Adeel Ahmad ( Magnet 360 )
    * @Date: 11/24/2015
    * @Type Of Variable : Getter , Setter ( Public )
    * @Return : requiredFieldsMap Map<String, String> instance
    *******************************************************************************/
    public Map<String, String> requiredFieldsMap{
        get{
            if(requiredFieldsMap == null){
                requiredFieldsMap = new Map<String, String>();
            }
            Map<String, Schema.SObjectField> allFields = Schema.SObjectType.Procedure__c.fields.getMap() ;
            for( String fsName : allFields.keySet() )
            {
                requiredFieldsMap.put(fsName, '');
            }
            LIST<String> requireFieldsList = pSettings.Require_Fields__c.split(',');
            for(String f : requireFieldsList){
                requiredFieldsMap.put(f.toLowerCase().trim(), 'required');
            }
            System.debug('AA:requiredFieldsMap' + requiredFieldsMap);
            return requiredFieldsMap;
        }
        set;
    }
    
    /******************************************************************************
    * Constructor of SJM_ProcedureEditController
    *
    * @Author: Adeel Ahmad ( Magnet 360 )
    * @Date: 11/24/2015
    * @Return : None Void
    * @Param : ApexPages.StandardController
    *******************************************************************************/
    public SJM_ProcedureEditController( ApexPages.StandardController sc ){
        this.stdController = sc;
        procedureId = ApexPages.currentPage().getParameters().get('id');
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        if(ApexPages.currentPage().getParameters().get('contactId') != '')
        {
           contID = ApexPages.currentPage().getParameters().get('contactId');
           //system.debug('@@ contid ' + contID );
        }
        
        
        String accountFieldId = pSettings.Procedure_Account_Field_Id__c;
        //String contactFieldId = pSettings.Procedure_Contact_Field_Id__c;
        
        if(ApexPages.currentPage().getParameters().get(accountFieldId) != null){
            accountId = ApexPages.currentPage().getParameters().get(accountFieldId);
        }
        //if(ApexPages.currentPage().getParameters().get(contactFieldId) != null){
            //contID = ApexPages.currentPage().getParameters().get(contactFieldId);
        //}
        
        
        procedureDate = null;

        if(currentProcedure != null || procedureId != null){
            currentProcedure = [SELECT  Id, 
                                        Account__c,
                                        Rep__c,
                                        FCE__c,
                                        Procedure__c,
                                        Procedure_Type__c,
                                        Procedure_Physician__c,
                                        Procedure_Date__c,
                                        Physician_Begins_Vascular_Access__c,
                                        Physician_Declares_End_of_Procedure__c,
                                        X_Ray_Hours__c,
                                        X_Ray_Minutes__c,
                                        X_Ray_Time__c,
                                        Dose_Unit_of_Measurement__c,
                                        Dose_1__c,
                                        Dose_2__c, 
                                        Dose_3__c, 
                                        Dose_4__c, 
                                        Dose_5__c, 
                                        Dose_Amount__c
                                FROM Procedure__c WHERE id = :procedureId];
            accountId = currentProcedure.Account__c; 
            if(currentProcedure.Procedure_Physician__c != null)
            {
                contID = currentProcedure.Procedure_Physician__c;
            }
            
            if(currentProcedure.Procedure_Date__c != null){
                procedureDate = currentProcedure.Procedure_Date__c.format();
            }
 
        }
        else
        {
            if(contID != null || contID != '')
            {
               currentProcedure = new Procedure__c(Account__c = accountId, 
                                                Procedure_Physician__c = contID, 
                                                Rep__c = UserInfo.getUserId(), 
                                                Dose_1__c = '0', 
                                                Dose_2__c = '0', 
                                                Dose_3__c = '0', 
                                                Dose_4__c = '0', 
                                                Dose_5__c = '0'
                                                ); 
           }
           else
           {
               currentProcedure = new Procedure__c(Account__c = accountId,  
                                                Rep__c = UserInfo.getUserId(), 
                                                Dose_1__c = '0', 
                                                Dose_2__c = '0', 
                                                Dose_3__c = '0', 
                                                Dose_4__c = '0', 
                                                Dose_5__c = '0'
                                                ); 
           }  
        }
        eventId = ApexPages.currentPage().getParameters().get('eventId');
        
        if(eventId != null){
            procedureDate = [SELECT StartDateTime FROM Event WHERE id =: eventId ].StartDateTime.date().format();
        }
    }

    /******************************************************************************
    * Detemine is VF page in SF1 envirement or other
    *
    * @Author: Adeel Ahmad ( Magnet 360 )
    * @Date: 11/24/2015
    * @Return : Boolean
    * @Param : None
    *******************************************************************************/
    public Boolean getIsS1(){
       String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        
       return String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
              String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
              ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
              (String.isNotBlank(retUrl) && retURL.contains('projectone'));
    }    
}