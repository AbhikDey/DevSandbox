public class candidateViewExtension  
{  
    private Candidate__c myCandidate = new Candidate__c();  
    PII_Info myPII_Info = new PII_Info();  
    PII_Info.CandidateInfo theCandidateInfo_int = new PII_Info.CandidateInfo();
    private ApexPages.StandardController controller {get; set;} 
    public string statusCheck;
    
    public candidateViewExtension(ApexPages.StandardController controller) {  
        //initialize the standard controller  
        this.controller = controller;  
        this.myCandidate = (Candidate__c)controller.getRecord();
        
        System.debug('CandidateController: Loaded');
        //Get the Candidate Profile info
        //this.refreshPII_Info();
    }
    
    public void refreshPII_Info()  
    {  
        System.debug('CandidateController: Refresh called for ID: ' + this.myCandidate.External_System_Id__c);
        System.debug('CandidateController: Refresh called for External ID: ' + this.myCandidate.ID);
        myPII_Info = new PII_Info();
        //string sfObjId = null;
        //SJM_Error_Handling__c sjmEH = new SJM_Error_Handling__c();
        // This service request will send External System Id
        /*if (!string.isEmpty(this.myCandidate.External_System_Id__c)){
            theCandidateInfo_int = myPII_Info.getPII_Info(this.myCandidate.External_System_Id__c);
        }*/
        
        // This service request will send Candidate Id
        //sfObjId = this.myCandidate.ID;
        try{
            if (!string.isEmpty(this.myCandidate.ID)){
                theCandidateInfo_int = myPII_Info.getPII_Info(this.myCandidate.ID);
                statusCheck = 'Success';
                system.debug('@@@candidate message ' + theCandidateInfo_int);
            }
        } catch(Exception e){
            //System.debug('*** SJM GET Retreive ' + e.getMessage());  
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, label.PII_ErrorMsg);
            system.debug('@@@error message ' + myMsg);
            ApexPages.addMessage(myMsg);     
            statusCheck = 'Failure';
        }                
    }  
    
    private PII_Info.CandidateInfo theCandidateInfo {
        get{
            if (this.theCandidateInfo_int == null){
                this.theCandidateInfo_int = new PII_Info.CandidateInfo();
            }
            return this.theCandidateInfo_int;
        }
    }
    
    /* Public properties */
    public string getErrorMessage(){
    	return ((this.theCandidateInfo_int == null && statusCheck == 'Success') || (this.theCandidateInfo_int.ID == null && statusCheck == 'Success'))? label.PII_SaveMsg : null;
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
    public Date DateOfBirth  
    {  
        get{
            //return theCandidateInfo.DATE_OF_BIRTH != null ? Date.parse(theCandidateInfo.DATE_OF_BIRTH.replace(':', ' ')) : null;
           
          try{
          if(theCandidateInfo.DATE_OF_BIRTH != null )
            return(PII_Info.parseDate(theCandidateInfo.DATE_OF_BIRTH));
          else
            return null;
          } catch(Exception e){
              return null;
          }    
        }
        set{
            
            theCandidateInfo.DATE_OF_BIRTH = String.valueOf(value);
            
        }
    }
    public String HomePhone  
    {  
        get{
            return(PII_Info.formatPhone(theCandidateInfo.HOME_PHONE));  
        }
        set{
            theCandidateInfo.HOME_PHONE = value;
        }
    }
    public String CellPhone  
    {  
        get{
            return(PII_Info.formatPhone(theCandidateInfo.CELL_PHONE));  
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
        return Datetime.valueOf(theCandidateInfo.CREATED_DT); 
    }
    public String getModifiedBy()  
    {  
        return theCandidateInfo.MODIFIED_BY;  
    }
    public DateTime getModifiedDt()  
    {  
        return Datetime.valueOf(theCandidateInfo.MODIFIED_DT);  
    }

}