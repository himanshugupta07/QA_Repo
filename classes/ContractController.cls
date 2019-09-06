//////////////////////////////////////////////////
//Case 00005653 - Duc Lam - 14 March 2012
//Upload Content from opportunity button
//Updated code to include link to Account on Opportunity
//Eleanor updated this controller to include EMB email processing with EMB Type is integrated 
//Duc - Updated query to include EMB record type
//////////////////////////////////////////////////
public class ContractController {

    public ContentVersion myProposal {get;set;}
    public opportunity prop1{get;set;}
    public opportunity Opp1;
    public opportunity prop2;

//instatiate controller
    public ContractController(ApexPages.StandardController controller){
        prop1 = (opportunity)controller.getRecord();
        prop1 = [select Id, Name, AccountId, EIU_Sales_Agent__c, Sales_Department__c, CloseDate from Opportunity where Id = :prop1.Id];
        prop2 = (opportunity)controller.getRecord();
        prop2 = [select AccountId from opportunity where Id = :prop2.Id];   
 
        Opp1 =  [select Name, Sales_Department__c, Opportunity_Type__c, Record_Type_Name__c from opportunity where Id = :prop1.Id];
        
        if (prop1.CloseDate<system.today()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Close Date for the Opportunity is in the past and must be updated before completing the upload.'));         
        }
        
        myProposal = new ContentVersion();
    }

//code for upload button
    public PageReference upload(){
        system.debug('INSIDE UPLOAD');
        if (prop1.CloseDate<system.today()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Close Date for the Opportunity is in the past and must be updated before completing the upload.'));
            return null;            
        }
        if (myProposal.PathOnClient != null){
            List<Content_Library_IDs__c> LibraryID = [select Library_ID__c from Content_Library_IDs__c where Name = 'Contract Library'];
            myProposal.FirstPublishLocationID = LibraryID.get(0).Library_ID__c;
        //code for picking up default user.    
            List<Default_Owner__c> UserId = [select User_Id__c from Default_Owner__c where Region__c = 'US'];
            myProposal.OwnerId = UserId.get(0).User_Id__c;
            myProposal.Opportunity__c = prop1.Id;
            myProposal.TagCsv = Opp1.Sales_Department__c;
            myProposal.Account__c = prop2.AccountId;
            myProposal.Description = Opp1.Sales_Department__c;
            myProposal.RecordTypeId='01230000000xVYXAA2';
            
            //If it is an integrated opportunity then an email needs to be sent
            if (Opp1.Opportunity_Type__c == 'Integrated' && Opp1.Record_Type_Name__c != 'EIUOpp') {
                // Create a dummy email message object that creates the template for the actual email
                EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE developerName = 'EMB_Integrated_Contract_Alert'];
                Contact cnt = [SELECT Id, Email from Contact where Name = 'Eleanor Matthewman' LIMIT 1];
                Messaging.SingleEmailMessage dummyMail = new Messaging.SingleEmailMessage();
                dummyMail.setTargetObjectId(cnt.Id);
                dummyMail.setTemplateId(templateId.Id);
                dummyMail.setWhatId(prop2.Id);
                // Send the emails in a transaction, then roll it back
                Savepoint sp = Database.setSavepoint();
                Messaging.SendEmailResult[] dummyresults = Messaging.sendEmail(
                    new Messaging.SingleEmailMessage[] { dummyMail }); // Dummy email send
                Database.rollback(sp); // Email will not send as it is rolled Back
                
                // Create email attachment
                Blob b = myProposal.versiondata;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(myProposal.PathOnClient);
                efa.setBody(b);
                
                // Create the actual email message object
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(getEmailAddresses());
                mail.setSubject(dummyMail.getSubject());
                mail.setPlainTextBody(dummyMail.getPlainTextBody());
                mail.setHTMLBody(dummyMail.getHTMLBody());
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                // Pass this email message to the built-in sendEmail method of the Messaging class
                Messaging.SendEmailResult[] results = Messaging.sendEmail(
                    new Messaging.SingleEmailMessage[] { mail });
                system.debug('results'+results);
            }
            prop1.Is_Contract_Loaded__c = TRUE;
            
            insert myProposal;
            update prop1;
            return new PageReference('/'+ prop1.Id);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No file has been selected for upload'));
            return null;
        }
    }

//code for cancel button
    public PageReference cancel(){
        return new PageReference('/' + prop1.Id);
    }
    
//code for getting email addresses to send to
    private List<String> getEmailAddresses() {
                List<String> idList = new List<String>();
                List<String> mailToAddresses = new List<String>();
        
                mailToAddresses.addAll((Label.Contract_Email_Addresses).split(';'));
 
                return mailToAddresses;
    }
    
//code necessary for test class (TestContractFileUpload)
    public void setmyProposal(ContentVersion PropContent){
        myProposal = PropContent;
    }
}