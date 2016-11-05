public class candidateControllerExtension  
{  
    private Candidate__c myCandidate = new Candidate__c();  
    PII_Info myPII_Info = new PII_Info();  
    PII_Info.CandidateInfo theCandidateInfo_int = new PII_Info.CandidateInfo();
    private ApexPages.StandardController controller {get; set;} 
    public List<SelectOption> statusOptions {get; set;}
    
    public candidateControllerExtension(ApexPages.StandardController controller) {  
        //initialize the standard controller  
        this.controller = controller;  
        this.myCandidate = (Candidate__c)controller.getRecord();
        
        //System.debug('CandidateController: Loaded');
        //Get the Candidate Profile info
        //this.refreshPII_Info();
    }
    
    public void refreshPII_Info()  
    {  
        //System.debug('CandidateController: Refresh called for ID: ' + this.myCandidate.External_System_Id__c);
        //System.debug('CandidateController: Refresh called for External ID: ' + this.myCandidate.ID);
        myPII_Info = new PII_Info();
        
        // This service request will send External System Id
        /*if (!string.isEmpty(this.myCandidate.External_System_Id__c)){
theCandidateInfo_int = myPII_Info.getPII_Info(this.myCandidate.External_System_Id__c);
}*/
        
        // This service request will send Candidate Id
        if (!string.isEmpty(this.myCandidate.ID)){
            theCandidateInfo_int = myPII_Info.getPII_Info(this.myCandidate.ID);
        }
        
    }  
    
    public List<SelectOption> getGenderOptions() {
        //System.debug('*** getStatusOptions');
        List<SelectOption> genOptionList = new List<SelectOption>();
        Set<String> genSet = new Set<String> {'Male','Female','Unknown'};
        
        // Set None option value
        genOptionList.add(new SelectOption('' ,'--None--' ));
        
        for(String s : genSet){
            genOptionList.add(new SelectOption(s , s));
        }
        
        return genOptionList;
    }    
    
    public PageReference Edit(){
        //System.debug('*** SJM Launch Edit: ID: ' + myCandidate.id);
        //System.debug('*** SJM Launch Edit: Last Name: ' + LastName);
        
        PageReference page = new PageReference('/apex/EditCandidateDetails?id=' + myCandidate.id) ;
        return page;
    }
    
    public PageReference SaveRecord(){
        try{
            if(DateOfBirth > Date.today()){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Date Of Birth : Date Entered is greater than Current Date');
                ApexPages.addMessage(myMsg);                
                return null;
            }
            
            if (myCandidate.Id == null || myCandidate.External_System_Id__c == null) {                
                this.createCandidate();                
            }
            else{                
                this.updateCandidate();
            }
            
        }
        catch(DMLException dmle){
            //System.debug('*** SJM Error Save DMl' + dmle.getMessage());   
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, label.PII_ErrorMsg);
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        catch(Exception e){
            //System.debug('*** SJM Error Save ' + e.getMessage());   
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, label.PII_ErrorMsg);
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        
        //PageReference page = new PageReference('/apex/ViewCandidateDetails?id=' + myCandidate.id) ;
        //return page;
        
        return redirectToList(myCandidate.Id);
    }
    
    public PageReference Cancel(){
        if(myCandidate.Id != null){
            return redirectToList(myCandidate.Id);
        } else {
        Schema.DescribeSObjectResult result = Candidate__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        pageRef.setRedirect(true); 
        return pageRef;
        }        
    }
    
    private void updateCandidate(){
        
        //System.debug('*** SJM Update Candidate. ID: ' + myCandidate.id);
        //Update the standard object
        update myCandidate;
        
        //make the webservice call to save the remote object
        //update teh candidate object
        theCandidateInfo_int.EXTERNALSYSTEMID = myCandidate.Id;
        theCandidateInfo_int = myPII_Info.UpdateAuditDetails(theCandidateInfo);
        
        string candidateJson = JSON.serialize(theCandidateInfo);
        //System.debug('@@@*** SJM Update: JSON: ' + theCandidateInfo.ID  +'@@ ' + candidateJson);
        PII_Info.updatePII_Info(theCandidateInfo.ID, candidateJson);
    }
    
    private void createCandidate(){
        //System.debug('*** SJM Create Candidate.');
        upsert myCandidate;
        
        //update the remote object
        theCandidateInfo_int.EXTERNALSYSTEMID = myCandidate.Id;
        theCandidateInfo_int.EXTERNALSYSTEMNAME = 'Salesforce';
        theCandidateInfo_int.ENTITY_NAME = 'Candidate__c';
        
        //make the webservice call to save
        theCandidateInfo_int = myPII_Info.InsertAuditDetails(theCandidateInfo);
        
        string candidateJson = JSON.serialize(theCandidateInfo);
        //System.debug('*** SJM Create: JSON: ' + candidateJson);
        PII_Info.createPII_info(candidateJson);
    }
    
    private PII_Info.CandidateInfo theCandidateInfo {
        get {
          if (this.theCandidateInfo_int == null)
            this.theCandidateInfo_int = new PII_Info.CandidateInfo();
          return this.theCandidateInfo_int;
        }
        set;                
    }
    
    
    private PageReference redirectToList(ID candID) { 
        //Schema.DescribeSObjectResult result = Candidate__c.SObjectType.getDescribe(); 
        //PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        //system.debug('Cand ID - '+candID);
        sleep(2000);
        PageReference pageRef = new PageReference('/' + candID);
        pageRef.setRedirect(true); 
        return pageRef; 
    }
    
    public static void sleep(Long milliSeconds)
    {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }
    
    /* Public properties */    
    public string getErrorMessage(){
        return (this.theCandidateInfo_int == null || this.theCandidateInfo_int.ID == null)? label.PII_ErrorMsg : null;
    }
    
    public String getID()  
    {  
        return theCandidateInfo.ID;  
    }
    
    public String ExternalID
    {  
        get{
            return theCandidateInfo.EXTERNALSYSTEMID;  
        }
        set{
            theCandidateInfo.EXTERNALSYSTEMID = value;
        }
    }
    public String FirstName
    {  
        get {
            return theCandidateInfo.FIRST_NAME;  
        }
        set{
            theCandidateInfo.FIRST_NAME = value;
        }
    }  
    public String LastName
    {  
        get{
            return theCandidateInfo.LAST_NAME;  
        }
        set{
            theCandidateInfo.LAST_NAME = value;
        }
    } 
    
    public String Gender
    {  
        get{
            return theCandidateInfo.GENDER;  
        }
        set{
            theCandidateInfo.GENDER = value;
        }
    }
    
    public string getFormattedDateOfBirth(){
        string output = '';
        if(DateOfBirth != null){
            output = DateOfBirth.format();
        }
        return output;
    }
    
    public Date DateOfBirth  
    {  
        get{
            try{
                if(theCandidateInfo.DATE_OF_BIRTH != null ){
                    //System.debug('*** > DOB > ' + PII_Info.parseDate(theCandidateInfo.DATE_OF_BIRTH));
                    return(PII_Info.parseDate(theCandidateInfo.DATE_OF_BIRTH));
                }
                else
                    return null;
            } catch(Exception e){
                return null;
            }
        }
        set{
            theCandidateInfo.DATE_OF_BIRTH = string.valueOf(value);
        }
    }
    public String HomePhone  
    {  
        get{
            return theCandidateInfo.HOME_PHONE != null ? PII_Info.formatPhone(theCandidateInfo.HOME_PHONE) : null;  
        }
        set{
            theCandidateInfo.HOME_PHONE = value;
        }
    }
    public String CellPhone  
    {  
        get{
            return theCandidateInfo.CELL_PHONE != null ? PII_Info.formatPhone(theCandidateInfo.CELL_PHONE) : null;  
        }
        set{
            theCandidateInfo.CELL_PHONE = value;
        }
    }
    public String AddressLine1
    {  
        get{
            return theCandidateInfo.ADDRESS_LINE1;  
        }
        set{
            theCandidateInfo.ADDRESS_LINE1 = value;  
        }
    }
    public String AddressLine2
    {  
        get{
            return theCandidateInfo.ADDRESS_LINE2;  
        }
        set{
            theCandidateInfo.ADDRESS_LINE2 = value;  
        }
    }
    public String AddressCity
    {  
        get{
            return theCandidateInfo.ADDRESS_CITY;  
        }
        set{
            theCandidateInfo.ADDRESS_CITY = value;
        }
    }
    public String AddressState
    {  
        get{
            return theCandidateInfo.ADDRESS_STATE_PROVINCE;  
        }
        set{
            theCandidateInfo.ADDRESS_STATE_PROVINCE =value;
        }
    }
    public String AddressCountry
    {  
        get{
            return theCandidateInfo.ADDRESS_COUNTRY;  
        }
        set{
            theCandidateInfo.ADDRESS_COUNTRY = value;
        }
    }
    public String getCreatedBy()  
    {  
        return theCandidateInfo.CREATED_BY;  
    }
    public DateTime getCreatedDt()  
    {  
        return Datetime.valueOf(theCandidateInfo.CREATED_DT.replace('T', ' ')); 
    }
    public String getModifiedBy()  
    {  
        return theCandidateInfo.MODIFIED_BY;  
    }
    public DateTime getModifiedDt()  
    {  
        return Datetime.valueOf(theCandidateInfo.MODIFIED_DT.replace('T', ' '));  
    }
    public String getUserId_Name()
    {
        return UserInfo.getName();
    }
    
}