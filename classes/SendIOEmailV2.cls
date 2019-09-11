//////////////////////////////////////////////////
//EMB Restructure 
//Eleanor Matthewman - 25 July 2016
//New Apex Class that is launched from Process 
//Builder - EMB Booked Sales Processes
//This acts like an email alert except it also 
//includes the IO/Email confirmation
//documents as an attachment to the email
//
//I have included the most common file types for 
//conversion however if other files are to be used, 
//they will need to be added to the conversion section
//for the attachments to open correctly after being sent
//////////////////////////////////////////////////

public class SendIOEmailV2 {
    @InvocableMethod
    public static void SendIOEmail(List<Id> OppIDs){
        //Variable declarations
        List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa;
        Opportunity Opp = [SELECT Id,Order_Type__c FROM Opportunity WHERE Id =: OppIDs[0]];
        Map<Id,Quote> q = new Map<Id,Quote>([SELECT Id FROM Quote WHERE OpportunityId IN : OppIDs AND Status = 'Active I/O']);
        set<Id> x = q.keyset();
        list<Id> y = new List<Id>(x);
        Quote q1 = new quote(Id=y[0],Order_Type2__c = opp.Order_Type__c);
        update q1;
        //QuoteDocument qd1 = createPdf(OppIDs[0],String.valueof(y[0]));
        snd(OppIDs[0],String.valueof(y[0]));
        /*
        List<QuoteDocument> qdoc = [SELECT Id,Name,Document FROM QuoteDocument WHERE QuoteId IN:  q.Keyset() ORDER BY Name DESC Limit 1];
        //Opportunity Opp = new Opportunity(Id = OppIDs[0]);
        for (QuoteDocument cv : qdoc) {
            if (cv != null) {
                efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Name);
                efa.setBody(cv.Document);
                //This section converts the content document into its 
                //matching MIME type to allow it to be opened after sent. 
                //A complete list of MIME types can be found at the link below: 
                //http://www.iana.org/assignments/media-types/media-types.xhtml
                efa.setContentType('application/pdf');
                attList.add(efa);
            }
        } 
        
        // Create a dummy email message object that creates the template for the actual email
        // 
        Opportunity op = [SELECT Id,Is_Position_Approved__c FROM Opportunity WHERE Id =: OppIDs];
        EmailTemplate templateID = new EmailTemplate();
        if(op.Is_Position_Approved__c==TRUE){
            templateID = [SELECT Id 
                          FROM EmailTemplate 
                          WHERE developerName = 'EMB_MediaIO_Sales_Opp_Ready_for_MSG_Processing'];
        }
        else{
            templateID = [SELECT Id 
                          FROM EmailTemplate 
                          WHERE developerName = 'EMB_Media_Sales_Opp_Ready_for_Position_Approval'];
        }
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Media_Accounts').getRecordTypeId();
        Id CntrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Media_Contacts').getRecordTypeId();
        
        Account act = new Account(Name='Dummy Acc',RecordTypeId = AccrecordTypeId);
        act.BillingCity = 'London';
        act.BillingCountry = 'United Kingdom';
        act.BillingPostalCode = 'EP14 4EU';
        act.BillingState = 'London';
        act.BillingStreet = '20 Cabot Sq';
        Contact cnt = new Contact(FirstName = 'Dummy', LastName = 'Contact', Email = 'test@example.com',RecordTypeId = CntrecordTypeId);
        Messaging.SingleEmailMessage dummyMail = new Messaging.SingleEmailMessage();
        dummyMail.setTemplateID(templateID.Id);
        dummyMail.setWhatId(Opp.Id);
        dummymail.setSaveAsActivity(false);
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        insert act;
        cnt.AccountId = act.id;
        insert cnt;
        dummyMail.setTargetObjectID(cnt.Id);
        Messaging.SendEmailResult[] dummyresults = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { dummyMail }); // Dummy email send
        Database.rollback(sp); // Email will not send as it is rolled Back
        //Determine recipients
        List<String> mailToAddresses = new List<String>();
        mailToAddresses.addAll((Label.IO_Email_Addresses).split(';'));
        system.debug('Emails: '+mailToAddresses);
        //Creates the actual email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailToAddresses);
        mail.setSubject(dummyMail.getSubject());
        mail.setPlainTextBody(dummyMail.getPlainTextBody());
        mail.setHTMLBody(dummyMail.getHTMLBody());
        mail.setSaveAsActivity(false);
        //Only add an attachment if there is one
        if (!attList.isEmpty()) {
            mail.setFileAttachments(attList);
        }
        try {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(
                new List<Messaging.Email> { mail }
            );
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 
                'An Error occured while trying to email, ' + e.getMessage()
            ));
        }*/
    }
    
    public static QuoteDocument createPdf(String oppid,string Qid){
        
        List<Print_IO_Settings__mdt> getstng = [SELECT Quote_Template_Id__c,
                                                Email_Addresses__c
                                                FROM Print_IO_Settings__mdt];
        String QuoteID = String.valueOf(Qid).substring(0, 15);
        String templateID = getstng.get(0).Quote_Template_Id__c;
        String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?id=';
        quoteUrl +=QuoteID;
        quoteUrl +='&summlid=';
        quoteUrl +=templateID ;
        system.debug(quoteUrl);
        PageReference pg = new PageReference(quoteUrl) ;
        QuoteDocument quotedoc = new QuoteDocument(); 
        Blob b = pg.getContentAsPDF() ;
        quotedoc.Document = b;
        quotedoc.QuoteId = QuoteID ;
        
        insert quotedoc;
        return quotedoc;
    }
    @future(callout=true)
    public static void snd(String oppid,string Qid ){
        QuoteDocument qd1 = createPdf(oppid,Qid);
        List<QuoteDocument> qdoc = [SELECT Id,Name,Document FROM QuoteDocument WHERE Id =: qd1.Id ];
        List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa;
        for (QuoteDocument cv : qdoc) {
            if (cv != null) {
                efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Name);
                efa.setBody(cv.Document);
                //This section converts the content document into its 
                //matching MIME type to allow it to be opened after sent. 
                //A complete list of MIME types can be found at the link below: 
                //http://www.iana.org/assignments/media-types/media-types.xhtml
                efa.setContentType('application/pdf');
                attList.add(efa);
            }
        } 
        List<ContentVersion> CVs = [SELECT Id, Title, VersionData, FileType FROM ContentVersion WHERE IOOpportunity__r.Id  =:oppid];
        for (ContentVersion cv : CVs) {
            if (cv != null) {
                efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Title);
                efa.setBody(cv.VersionData);
                    //This section converts the content document into its 
                    //matching MIME type to allow it to be opened after sent. 
                    //A complete list of MIME types can be found at the link below: 
                    //http://www.iana.org/assignments/media-types/media-types.xhtml
                efa.setContentType(cv.FileType == 'WORD' ? 'application/msword' :
                                   cv.FileType == 'WORD_X' ? 'application/msword' :
                                   cv.FileType == 'PDF' ? 'application/pdf' :
                                   cv.FileType == 'EXCEL' ? 'application/vnd.ms-excel' :
                                   cv.FileType == 'EXCEL_M' ? 'application/vnd.ms-excel.sheet.macroenabled.12' :
                                   cv.FileType == 'EXCEL_X' ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' :
                                   cv.FileType == 'POWER_POINT' ? 'application/vnd.ms-powerpoint' :
                                   cv.FileType == 'POWER_POINT_M' ? 'application/vnd.ms-powerpoint.presentation.macroenabled.12' :
                                   cv.FileType == 'POWER_POINT' ? 'application/vnd.ms-powerpoint' :
                                   cv.FileType == 'csv' ? 'text/csv' :
                                   '');
                attList.add(efa);
            }
        } 
        // Create a dummy email message object that creates the template for the actual email
        // 
        Opportunity op = [SELECT Id,Is_Position_Approved__c FROM Opportunity WHERE Id =: oppid];
        EmailTemplate templateID = new EmailTemplate();
        if(op.Is_Position_Approved__c==TRUE){
            templateID = [SELECT Id 
                          FROM EmailTemplate 
                          WHERE developerName = 'EMB_MediaIO_Sales_Opp_Ready_for_MSG_Processing'];
        }
        else{
            templateID = [SELECT Id 
                          FROM EmailTemplate 
                          WHERE developerName = 'EMB_Media_Sales_Opp_Ready_for_Position_Approval'];
        }
        
        Contact cnt = [SELECT ID FROM Contact limit 1];
        Messaging.SingleEmailMessage dummyMail = new Messaging.SingleEmailMessage();
        dummyMail.setTemplateID(templateID.Id);
        dummyMail.setWhatId(Op.Id);
        dummymail.setSaveAsActivity(false);
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        dummyMail.setTargetObjectID(cnt.Id);
        Messaging.SendEmailResult[] dummyresults = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { dummyMail }); // Dummy email send
        Database.rollback(sp); // Email will not send as it is rolled Back
        //Determine recipients
        List<String> mailToAddresses = new List<String>();
        mailToAddresses.addAll((Label.IO_Email_Addresses).split(';'));
        system.debug('Emails: '+mailToAddresses);
        //Creates the actual email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailToAddresses);
        mail.setSubject(dummyMail.getSubject());
        mail.setPlainTextBody(dummyMail.getPlainTextBody());
        mail.setHTMLBody(dummyMail.getHTMLBody());
        mail.setSaveAsActivity(false);
        //Only add an attachment if there is one
        if (!attList.isEmpty()) {
            mail.setFileAttachments(attList);
        }
        try {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(
                new List<Messaging.Email> { mail }
            );
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 
                'An Error occured while trying to email, ' + e.getMessage()
            ));
        }
    }
}