global class budgetTaskCreator implements Database.Batchable<sObject>,Schedulable{
	
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	String query = 'SELECT Id,New_FY_budgeting_start_in__c,OwnerId,Name FROM Account WHERE New_FY_budgeting_start_in__c!=null';
        Database.QueryLocator d = Database.getQueryLocator(query); 
        return d;
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Integer crMon = system.today().month();
        Integer accMon;
        List<Task> nwTsk = new List<Task>();
        
        for(Account a : scope){
            switch on a.New_FY_budgeting_start_in__c {
                when 'January' {
                    accMon = 1;
                }
                when 'February' {
                    accMon = 2;
                }
                when 'March' {
                    accMon = 3;
                }
                when 'April' {
                    accMon = 4;
                }
                when 'May' {
                    accMon = 5;
                }
                when 'June' {
                    accMon = 6;
                }
                when 'July' {
                    accMon = 7;
                }
                when 'August' {
                    accMon = 8;
                }
                when 'September' {
                    accMon = 9;
                }
                when 'October' {
                    accMon = 10;
                }
                when 'November' {
                    accMon = 11;
                }
                when 'December' {
                    accMon = 12;
                }
                when else {
                    accMon = 20;
                }
            }
            accMon = accMon - 1;
            If(accMon == 0){
                accMon = 12;
            }
            if((accMon == crMon) && (accMon > 0) && (accMon <= 12)){
            	Task tmpTsk = new Task();
                tmpTsk.OwnerId = a.OwnerId;
                tmpTsk.ActivityDate = system.today();
                tmpTsk.WhatId = a.Id;
                tmpTsk.Subject = a.Name + ' is due for New FY Budgeting Next Month';
                tmpTsk.Status = 'Not Started';
                tmpTsk.Priority = 'High';
                tmpTsk.Type = 'Meeting';
                tmpTsk.Description = 'This Account is due for New FY Budgeting Next Month. Please Contact them!';
                tmpTsk.IsReminderSet = TRUE;
                tmpTsk.ReminderDateTime = System.now();
                nwTsk.add(tmpTsk);
        	}
        }
        Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
        dmlOptions.EmailHeader.TriggerUserEmail = TRUE; 
        if(nwTsk.size()>0){
            Database.Insert(nwTsk,dmlOptions);
        }       
    }
    
    global void finish(Database.BatchableContext BC){
    }
}