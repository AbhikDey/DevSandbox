public with sharing class QVFC_CallRecordOverride 
{       //CUSTOM URL TO NEW CALL PAGE
    public PageReference redirect()
    {   
        String strAccountId                 = Apexpages.currentPage().getParameters().get('accountid');
        String strContactId                 = Apexpages.currentPage().getParameters().get('contactid');
        String strEventId                   = Apexpages.currentPage().getParameters().get('id');
        string strCallType                  = Apexpages.currentPage().getParameters().get('CallType');
        string strPGPT                      = Apexpages.currentPage().getParameters().get('Product_Group_Proced_Therapy__c');
        string strCampaign                  = Apexpages.currentPage().getParameters().get('Campaign__c');

        //ADDED DSTEAD 1MAY15
        string strProduct                   = Apexpages.currentPage().getParameters().get('Product__c');
        //-------------------
        
        string strExecutionPlanObjective    = Apexpages.currentPage().getParameters().get('ExecutionPlanObjective');
        string strDivision                  = Apexpages.currentPage().getParameters().get('Division__c');
        
        system.debug('strDivision:::' + strDivision);
        system.debug('strCallType:' + strCallType + ' strExecutionPlanObjective:' + strExecutionPlanObjective);
        
        Account sAcct; Contact sDoctor;
        Event sEvt;
        try
        {
            if(strContactId != null && strContactId != '')
                sDoctor     = [select FirstName, LastName from Contact where Id =:strContactId];                
        }
        catch(Exception e ){}
        
        try
        {
            if(strAccountId != null && strAccountId != '')
                sAcct       = [select Name from Account where Id =:strAccountId];
        }
        catch(Exception e ){}
        
        try
        {
            if(strEventId != null && strEventId != '')
                sEvt        = [select Id, ActivityDate, ActivityDateTime from Event where Id =:strEventId];
        }
        catch(Exception e ){}
        
        String doctor               = QCustomField.getId('Call_Record__c', 'Contact__c');
        String facilityPractitioner = QCustomField.getId('Call_Record__c', 'Facility_Practitioner__c');
        String datetimeofcall       = QCustomField.getId('Call_Record__c', 'Date_Time_of_Call__c');
        string CallType             = QCustomField.getId('Call_Record__c', 'Call_Type__c');
        string PGPT                 = QCustomField.getId('Call_Record__c', 'Product_Group_Proced_Therapy__c');
        string strCampaignFID       = QCustomField.getId('Call_Record__c', 'Campaign__c');

        //ADDED DSTEAD 1MAY15       
        string strProductFID        = QCustomField.getId('Call_Record__c', 'Product__c');
        //-------------------

        string Division             = QCustomField.getId('Call_Record__c', 'Division__c');
        String forwardURL           = '/' + Call_Record__c.getsObjectType().getDescribe().getKeyPrefix() + '/e?mode=new';
        
        system.debug('facilityPractitioner:' + facilityPractitioner + ' datetimeofcall:' + datetimeofcall + ' CallType:' + CallType);
        system.debug('Division:::' + Division);
        
        if(Apexpages.currentPage().getParameters().get('RecordType') != null)
        {
            forwardURL+='&RecordType='+Apexpages.currentPage().getParameters().get('RecordType');
        }
        if(sDoctor != null)
        {
            forwardURL += '&CF' + doctor + '_lkid=' + strContactId + '&CF' + doctor + '=' + sDoctor.FirstName+'+'+sDoctor.LastName;
        }
        if(sAcct != null)
        {
            forwardURL += '&CF' + facilityPractitioner + '_lkid=' + strAccountId + '&CF' + facilityPractitioner + '=' + sAcct.Name;
        }
        if(sEvt != null)
        {
            forwardURL += '&'+ datetimeofcall + '=' + Encodingutil.urlEncode(sEvt.ActivityDateTime.format('dd/MM/yyyy hh:mm a'), 'UTF-8');
        }
        
        if(strCallType != null && strCallType != '')
        {
            forwardURL += '&' + CallType + '=' + strCallType;
        }
        
        if(strPGPT != null && strPGPT != '')
        {
            forwardURL += '&' + PGPT + '=' + strPGPT;
        }
        
        if(strCampaign != null && strCampaign != '')
        {
            forwardURL += '&' + strCampaignFID + '=' + Encodingutil.urlEncode(strCampaign, 'UTF-8');
        }
        
        //ADDED DSTEAD 1MAY15        
        if(strProduct != null && strProduct != '')
        {
            forwardURL += '&' + strProductFID + '=' + Encodingutil.urlEncode(strProduct, 'UTF-8');
        }
        //-------------------
           
        if(strDivision != null && strDivision != '')
        {
            forwardURL += '&' + Division + '=' + Encodingutil.urlEncode(strDivision, 'UTF-8');
        }
        
        if(strExecutionPlanObjective != null && strExecutionPlanObjective != '')
        {
            forwardURL += '&CF' + QCustomField.getId('Call_Record__c', 'Execution_Plan_Objective__c') + '=' + strExecutionPlanObjective;
        }
        
        system.debug('forwardURL:' + forwardURL);
        
        //forwardURL = EncodingUtil.urlEncode(forwardURL, 'UTF-8');
        
        //system.debug('After Encode forwardURL:' + forwardURL);
        
        return new PageReference(forwardURL);
        //return new PageReference(EncodingUtil.urlEncode(forwardURL, 'UTF-8'));
    }
}