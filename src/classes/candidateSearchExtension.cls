public class candidateSearchExtension  
{    
    PII_Info myPII_Info;
    List<PII_Info.CandidateInfo> theCandidateInfoList_int;
    private ApexPages.StandardController controller {get; set;} 
    private static Integer MIN_SEARCH_FIELD_SIZE = 1;
    
    /* Public properties */
    public string SearchFirstName{get;set;}
    public string SearchLastName{get;set;}
    public boolean IsSearchListAvailable{get;set;}
    public Map<String,String> CandNameMap{get;set;}
    
    public candidateSearchExtension(ApexPages.StandardController controller) {  
        //initialize the standard controller  
        this.controller = controller;
    }        
    
    public void SearchForCandidates(){
        System.debug('*** SJM Launch Search: First Name: ' + SearchFirstName);
        System.debug('*** SJM Launch Search: Last Name: ' + SearchLastName);
        myPII_Info = new PII_Info();
        try{
            if (string.isBlank(SearchFirstName.trim()) || string.isBlank(SearchLastName.trim()) ||
                SearchFirstName.length() < MIN_SEARCH_FIELD_SIZE || SearchLastName.length() < MIN_SEARCH_FIELD_SIZE){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ' First and Last fields are required to be at least ' + MIN_SEARCH_FIELD_SIZE +' long');
                    ApexPages.addMessage(myMsg);
                    
                    this.IsSearchListAvailable = false;
                }
            else{
                this.IsSearchListAvailable = true;            
                theCandidateInfoList_int = myPII_Info.getListPII_Info(SearchFirstName,SearchLastName);             
            }
        }catch(Exception e){
            System.debug('*** SJM Search Retreive ' + e.getMessage());                   
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, label.PII_ErrorMsg);
            ApexPages.addMessage(myMsg);                
        }
    }
            
    public List<PII_Info.CandidateInfo> theCandidateInfoList {
                
        get{
            //variable declaration
            List<PII_Info.CandidateInfo> theCandidateAccessList = new List<PII_Info.CandidateInfo>();
            Map<Id,PII_Info.CandidateInfo> candMap = new Map<Id,PII_Info.CandidateInfo>();
            List<UserRecordAccess> usrAccessList = new List<UserRecordAccess>();
            Set<Id> candSet = new Set<Id>();
            Set<Id> candNameSet = new Set<Id>();
            CandNameMap = new Map<String,String>();
            
            if (this.theCandidateInfoList_int == null){
                this.theCandidateInfoList_int = new List<PII_Info.CandidateInfo>();
            }
            
            if(this.theCandidateInfoList_int.size() > 0){
                for(PII_Info.CandidateInfo ci : this.theCandidateInfoList_int){
                    candMap.put(Id.valueOf(ci.EXTERNALSYSTEMID), ci);
                    
                    //Check if it is 18char
                    if(ci.EXTERNALSYSTEMID.length() == 18)
                    candSet.add(Id.valueOf(ci.EXTERNALSYSTEMID));
                }
            }
            
            //Check if the user has access to the candidate records
            if(candSet.size() > 0){
                usrAccessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId IN :candSet];
            }
            
            if(usrAccessList.size() > 0){
                for(UserRecordAccess ua : usrAccessList){
                    if(ua.HasReadAccess){
                        theCandidateAccessList.add(candMap.get(ua.RecordId));
                        candNameSet.add(ua.RecordId);
                    }
                }
            }
            
            if(candNameSet.size() > 0){
                for(Candidate__c c : [Select Id,Name from Candidate__c where Id in :candNameSet]){
                    CandNameMap.put(c.Id,c.Name);
                }
            }
            
            return theCandidateAccessList;
        }
    }
            
}