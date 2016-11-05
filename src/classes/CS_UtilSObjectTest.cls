@isTest
public class CS_UtilSObjectTest{
    static testMethod void testCS_UtilSObject(){
        Schema.DescribeSObjectResult objDef = Account.sObjectType.getDescribe();
        CS_UtilSObject.getAllFieldDescribe();
        CS_UtilSObject.getFieldDescribeByApiName('Account') ;
        CS_UtilSObject.buildQueryFieldsByComma('query');
        CS_UtilSObject.appendQueryFields('query1,query3','query2,query4');
        CS_UtilSObject.buildQueryFields(objDef,'query');
        CS_UtilSObject.buildQuery(objDef);
        CS_UtilSObject.buildQuery(objDef,'query');        
    }
}