public class DispatcherOpportunityViewController {

    public DispatcherOpportunityViewController(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public PageReference getRedir() {

        Opportunity c = [Select id, recordtypeid From Opportunity Where Id = :ApexPages.currentPage().getParameters().get('id')];


        PageReference newPage;
        
        //check for CardioMEMS_Reorder record type Id
      // Id reOrderTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' and DeveloperName = 'CardioMEMS_Reorder'];
       List<RecordType> recordTypeId = [SELECT ID FROM RecordType where DeveloperName = :'CardioMEMS_Reorder' LIMIT 1];
       system.debug('Record Type Id is...'+recordTypeId[0].id);
       
        if (c.recordtypeid == recordTypeId[0].id) {
                //View page for ReOrder goes here --012P00000004kQlIAI
            newPage = Page.HFMReorderOpportunityDetails;
        } else {
            newPage = new PageReference('/' + c.id);
            newPage.getParameters().put('nooverride', '1');
        }

        newPage.getParameters().put('id', c.id);
        return newPage.setRedirect(true);

    }

    private final ApexPages.StandardController controller;

}