@IsTest
public class JSONhelper_Test {

	static testMethod void testParse() {
        String json = '[{\"Id\":\"00k1700000CfB1hAAF\",\"OpportunityId\":\"0061700000Js1qTAAR\",'+
                        '\"Publication__c\":\"The Economist Newspaper\",\"Issue_Date__c\":\"2019-08-31\",'+
                        '\"Platform__c\":\"Print The Economist\",\"Edition__c\":\"AS\",\"Ad_Size__c\":\"1/2 Page Vertical\",'+
                        '\"currency__c\":\"GBP 5997.6\",\"Discount_IO__c\":\"20\",\"Discount\":20,\"UnitPrice\":7497,'+
                        '\"TotalPrice\":5997.6,\"Product2Id\":\"01t14000005nUDrAAM\",\"PricebookEntryId\":\"01u1O00000gzWkKQAU\",'+
            			'\"Position__c\":\"TEXT\",\"Quantity\":1,\"Section__c\":\"TEXT\",\"Classified_Category__c\":\"TEXT\",'+
            			'\"RevSchId__c\":\"00k1700000CfB1hAAF\",\"Print_IO__c\":\"Print_IO\",'+
                        '\"Requested_Gauranted__c\":\"\",\"Color__c\":\"\"}]';
		//List<JSON_Helper> r = JSON_Helper.parse(json);
		JSON_Helper r = new JSON_Helper(System.JSON.createParser(json));
        System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON_Helper objJSON2Apex = new JSON_Helper(System.JSON.createParser(json));
		System.assert(objJSON2Apex != null);
		System.assert(objJSON2Apex.Id == null);
		System.assert(objJSON2Apex.OpportunityId == null);
		System.assert(objJSON2Apex.Publication == null);
		System.assert(objJSON2Apex.Issue_Date == null);
		System.assert(objJSON2Apex.Platform == null);
		System.assert(objJSON2Apex.Edition == null);
		System.assert(objJSON2Apex.Ad_Size == null);
		System.assert(objJSON2Apex.curncy == null);
		System.assert(objJSON2Apex.discount2 == null);
		System.assert(objJSON2Apex.Discount == null);
		System.assert(objJSON2Apex.UnitPrice == null);
		System.assert(objJSON2Apex.TotalPrice == null);
		System.assert(objJSON2Apex.Product2Id == null);
		System.assert(objJSON2Apex.PricebookEntryId == null);
		System.assert(objJSON2Apex.Requested_Gauranted == null);
		System.assert(objJSON2Apex.Color == null);
	}
}