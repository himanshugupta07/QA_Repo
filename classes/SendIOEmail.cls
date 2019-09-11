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

public class SendIOEmail {
    @InvocableMethod
    public static void SendIOEmail(List<Id> OppIDs){
	//Variable declarations
        List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
  		Messaging.EmailFileAttachment efa;
        List<ContentVersion> CVs = [SELECT Id, Title, VersionData, FileType FROM ContentVersion WHERE IOOpportunity__r.Id in :OppIDs];
        List<Opportunity> Opps = [Select Id from Opportunity where ID in :OppIDs]; 
        Opportunity Opp = Opps[0];
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
                                   '');
                attList.add(efa);
            }
        } 
		// Create a dummy email message object that creates the template for the actual email
			EmailTemplate templateID = [SELECT Id FROM EmailTemplate WHERE developerName = 'EMB_Media_Sales_Opp_Ready_for_MSG_Processing'];
            Contact cnt = [SELECT id, Email from Contact where Name = 'Eleanor Matthewman' LIMIT 1];
			Messaging.SingleEmailMessage dummyMail = new Messaging.SingleEmailMessage();
        	dummyMail.setTargetObjectID(cnt.Id);
			dummyMail.setTemplateID(templateID.Id);
            dummyMail.setWhatId(Opp.Id);
        	dummymail.setSaveAsActivity(false);
        // Send the emails in a transaction, then roll it back
			Savepoint sp = Database.setSavepoint();
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