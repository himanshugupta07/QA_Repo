@isTest
public class budgetTaskCreator_Test {
	
    static void createTestData(String Mon){
        // Create Account 
        Id AccountRTId = [Select Id from RecordType where DeveloperName = 'Media_Accounts' AND SObjectType = 'Account' limit 1].Id;
        Account acc =  new Account();
        acc.Name = 'Test AccountBB';
        acc.RecordTypeId = AccountRTId;
        acc.Client_Type__c = 'Academic';
        acc.Industry = 'Automotive';
        acc.Type = 'Client';
        acc.Active_Account__c= true;
        acc.BillingStreet = 'Street,London';
        acc.BillingCity = 'Delhi';
        acc.BillingState = 'Delhi';
        acc.BillingCountry = 'India';
        acc.BillingPostalCode ='TN11 9DZ';
        acc.Data_com_Industry__c = 'Automotive';
		acc.New_FY_budgeting_start_in__c = Mon;
        insert acc;
    }
    
    static testmethod void runTest() {
        List<String> Months = New List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
            for(String s: Months){
                createTestData(s);
            }
        test.startTest();
        budgetTaskCreator b = new budgetTaskCreator(); 
        String sch = '0 00 1 3 * ?'; 
        system.schedule('Test', sch, b);         
        test.stopTest();
    }
}