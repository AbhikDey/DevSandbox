global class CandidateWrapper
{
    public String lastName {get;set;}
    public String firstName {get;set;}
    public Candidate__c cand {get;set;}
    
    public CandidateWrapper(Candidate__c cand,String lastName,String firstName)
    {
        this.cand= cand;
        this.lastName= lastName;
        this.firstName= firstName;
    }
}