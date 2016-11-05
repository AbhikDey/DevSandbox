public with sharing class candidateListViewExtension1 {

    private integer counter=0;  //keeps track of the offset
    private integer list_size=Integer.ValueOf(label.ListViewSize); //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public String candStatus {get; set;}    
    
    public string selectedPage{get;set{selectedPage=value;}
    }
    
    public candidateListViewExtension1() {
        total_size = [select count() from Candidate__c]; //set the total size in the constructor
        selectedPage='0';
        
        List<CandidateWrapper> candWrapList = getCandidates();
        if(candWrapList == null || total_size == 0){
            candStatus = 'Failure';
        } else if(candWrapList != null && candWrapList.size() == 0){
            candStatus = 'Failure';
        }
        else {
            candStatus = 'Success';
        }
    }        
    
    
    public PageReference listView() {
        if(candStatus == 'Failure'){
            //return new ApexPages.Action('{!List}').invoke();
            Schema.DescribeSObjectResult result = Candidate__c.SObjectType.getDescribe(); 
            PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
            pageRef.setRedirect(true); 
            return pageRef;
        } else {
            return null;
        }        
    }
    
    public CandidateWrapper[] getCandidates() {
                
        if (selectedPage != '0') counter = list_size*integer.valueOf(selectedPage)-list_size;
        try { //we have to catch query exceptions in case the list is greater than 2000 rows
                
                //Variables Initialization
                List<CandidateWrapper> lstWrapper = new List<CandidateWrapper>();
                PII_info pii = new PII_Info();
                List <PII_info.CandidateInfo> cList = new List <PII_info.CandidateInfo>();
                Map <Id,PII_info.CandidateInfo> cMap = new Map <Id,PII_info.CandidateInfo>();
                List<ID> candList = new List<ID>();
                
                Candidate__c[] lstCandidate = [select Id,Name,Referred_By__c,Referred_By__r.Name,Referred_To__c,Referred_To__r.Name,Stage_Name__c from Candidate__c ORDER BY LastViewedDate DESC NULLS LAST, Name ASC limit :list_size offset :counter];                   
                
                for(Candidate__c cand : lstCandidate)
                {
                    candList.add(cand.ID);
                }
                
                if(candList.size() > 0)
                {
                    cList = pii.getListViewPII_Info(candList);
                }
                
                if(cList!= null && cList.size() > 0)
                {
                    for(PII_info.CandidateInfo pic : cList)
                    {
                        cMap.put(ID.ValueOf(pic.EXTERNALSYSTEMID),pic);
                    }
                } /*else {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, label.PII_ErrorMsg);
                    ApexPages.addMessage(myMsg);                    
                }*/
                
                for(Candidate__c cand : lstCandidate)
                {
                    if(cMap != null && cMap.get(cand.Id) != null)
                    {
                        lstWrapper.add(new CandidateWrapper(cand ,cMap.get(cand.Id).LAST_NAME,cMap.get(cand.Id).FIRST_NAME));
                    } else
                    {
                        lstWrapper.add(new CandidateWrapper(cand ,null,null));
                    }
                }
                
                return lstWrapper;
        
        } catch(Exception e){
            system.debug('@@@error message ' + e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, label.PII_ErrorMsg);            
            ApexPages.addMessage(myMsg);
            total_size = 1;
            counter = 0;
            return null;            
        }
    }    
    
    public Component.Apex.pageBlockButtons getMyCommandButtons() {
        
        //the reRender attribute is a set NOT a string
        Set<string> theSet = new Set<string>();
        theSet.add('myPanel');
        theSet.add('myButtons');
                
        integer totalPages;
        if (math.mod(total_size, list_size) > 0) {
            totalPages = total_size/list_size + 1;
        } else {
            totalPages = (total_size/list_size);
        }
        
        integer currentPage;        
        if (selectedPage == '0') {
            currentPage = counter/list_size + 1;
        } else {
            currentPage = integer.valueOf(selectedPage);
        }
     
        Component.Apex.pageBlockButtons pbButtons = new Component.Apex.pageBlockButtons();        
        pbButtons.location = 'top';
        pbButtons.id = 'myPBButtons';
        
        
        Component.Apex.outputPanel opPanel = new Component.Apex.outputPanel();
        opPanel.id = 'myButtons';
        opPanel.layout = 'block'; 
        opPanel.style = 'text-align:center';
                                
        //the Previous button will alway be displayed
        Component.Apex.commandButton b1 = new Component.Apex.commandButton();
        b1.expressions.action = '{!Previous}';
        b1.title = 'Previous';
        b1.value = 'Previous';
        b1.styleClass = 'slds-button slds-button--neutral';
        b1.expressions.disabled = '{!disablePrevious}';        
        b1.reRender = theSet;

        opPanel.childComponents.add(b1);        
                        
        for (integer i=0;i<totalPages;i++) {
            Component.Apex.commandButton btn = new Component.Apex.commandButton();
            
            if (i+1==1) {
                btn.title = 'First Page';
                btn.value = 'First Page';              
                btn.styleClass = 'slds-button slds-button--neutral';
                btn.rendered = true;                                        
            } else if (i+1==totalPages) {
                btn.title = 'Last Page';
                btn.value = 'Last Page';           
                btn.styleClass = 'slds-button slds-button--neutral';
                btn.rendered = true;                            
            } else {
                btn.title = 'Page ' + string.valueOf(i+1) + ' ';
                btn.value = ' ' + string.valueOf(i+1) + ' ';            
                btn.styleClass = 'slds-button slds-button--neutral';
                btn.rendered = false;             
            }
            
            if (   (i+1 <= 5 && currentPage < 5)
                || (i+1 >= totalPages-4 && currentPage > totalPages-4)
                || (i+1 >= currentPage-2 && i+1 <= currentPage+2))
            {
                btn.rendered = true;
            }
                                     
            if (i+1==currentPage) {
                btn.disabled = true; 
                btn.style = 'color:blue;';
            }  
            
            btn.onclick = 'queryByPage(\''+string.valueOf(i+1)+'\');return false;';
                 
            opPanel.childComponents.add(btn);
            
            if (i+1 == 1 || i+1 == totalPages-1) { //put text after page 1 and before last page
                Component.Apex.outputText text = new Component.Apex.outputText();
                text.value = '...';        
                opPanel.childComponents.add(text);
            } 
             
        }
        
        //the Next button will alway be displayed
        Component.Apex.commandButton b2 = new Component.Apex.commandButton();
        b2.expressions.action = '{!Next}';
        b2.title = 'Next';
        b2.value = 'Next';
        b2.styleClass = 'slds-button slds-button--neutral';
        b2.expressions.disabled = '{!disableNext}';        
        b2.reRender = theSet;
        opPanel.childComponents.add(b2);
                
        //add all buttons as children of the outputPanel                
        pbButtons.childComponents.add(opPanel);  
  
        return pbButtons;

    }    
    
    public PageReference refreshGrid() { //user clicked a page number        
        system.debug('**** ' + selectedPage);
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        selectedPage = '0';
        counter -= list_size;
        return null;
    }

    public PageReference Next() { //user clicked next button
        selectedPage = '0';
        counter += list_size;
        return null;
    }

    public PageReference End() { //user clicked end
        selectedPage = '0';
        counter = total_size - math.mod(total_size, list_size);
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }

    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
            
}