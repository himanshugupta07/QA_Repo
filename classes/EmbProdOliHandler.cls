/*
**************************************************************
Print I/O Implementation to Salesforce
Project Number : 930
Project Name : SP FY2018 - EMB IO Automation
Project ID: a0A1O00001C8Ooz
Developer : Himanshu Gupta
Current Version : V1
Created on : 25/09/2018
**************************************************************
Class Details:
Contains all the Apex Methods used in the IO Components.
**************************************************************
*/
global without sharing class EmbProdOliHandler {
    Global Static Id OppId; 
    
    //Fetching OpportunityLineItem as LineItemSchedule for RevenueDate Editing.
    @AuraEnabled
    public static List<OpportunityLineItem> getOli2(String oppId){
        
        Map<Id,OpportunityLineItemSchedule> oppOlis = new Map<Id,OpportunityLineItemSchedule>([SELECT Id,OpportunityLineItemId,
                                                                                               Revenue,ScheduleDate,
                                                                                               Type,CurrencyIsoCode, 
                                                                                               OpportunityLineItem.Product_Name__c, 
                                                                                               OpportunityLineItem.Edition__c,
                                                                                               OpportunityLineItem.Issue_Date__c, 
                                                                                               OpportunityLineItem.Ad_Size__c,
                                                                                               OpportunityLineItem.Print_IO__c,
                                                                                               OpportunityLineItem.currency__c,
                                                                                               OpportunityLineItem.Publication__c,
                                                                                               OpportunityLineItem.Platform__c,
                                                                                               OpportunityLineItem.TotalPrice
                                                                                               FROM OpportunityLineItemSchedule
                                                                                               WHERE OpportunityLineItem.OpportunityId=:oppId
                                                                                               AND OpportunityLineItem.Discount != 100
        																	]);
        List<OpportunityLineItem> oppOli = new List<OpportunityLineItem>();
        OpportunityLineItem oli = new OpportunityLineItem();
        system.debug('size'+oppOlis.size());
        for(OpportunityLineItemSchedule oliSch: oppOlis.values()){
            if(oliSch.OpportunityLineItem.Print_IO__c==TRUE){
                oli = new OpportunityLineItem(Id = oliSch.OpportunityLineItemId,
                                             Publication__c =  oliSch.OpportunityLineItem.Publication__c,
                                             Platform__c = oliSch.OpportunityLineItem.Platform__c,
                                             Edition__c = oliSch.OpportunityLineItem.Edition__c,
                                             Issue_Date__c = oliSch.ScheduleDate,
                                             Ad_Size__c = oliSch.OpportunityLineItem.Ad_Size__c,
                                             currency__c = oliSch.OpportunityLineItem.currency__c,
                                             Print_IO__c = oliSch.OpportunityLineItem.Print_IO__c,
                                             TotalPrice = oliSch.OpportunityLineItem.TotalPrice,
                                             RevSchId__c=oliSch.Id);
            }
            else{
                oli = new OpportunityLineItem(Id = oliSch.OpportunityLineItemId,
                                              Name__c = oliSch.OpportunityLineItem.Product_Name__c,
                                              Issue_Date__c = oliSch.ScheduleDate,
                                              currency__c = oliSch.CurrencyIsoCode + ' ' +String.valueof(oliSch.Revenue.setScale(2)),
                                              RevSchId__c=oliSch.Id,
                                              TotalPrice = oliSch.OpportunityLineItem.TotalPrice);
            }
            oppOli.add(oli);
        }
        return oppOli;
    }
    
    //Fetching Opportunity Line Item for IO Tool and RelatedListView
    @AuraEnabled
    global static List<OpportunityLineItem> getOli(String oppId){
        
        Map<Id,OpportunityLineItem> oppOli = new Map<Id,OpportunityLineItem>([SELECT  Id,OpportunityId,Publication__c,Issue_Date__c,Platform__c,Section__c,
                                                                              Edition__c,Classified_Category__c,Ad_Size__c,Requested_Gauranted__c,
                                                                              Position__c,Color__c,currency__c,Discount_IO__c,Combined_Audience__c,
                                                                              Discount,UnitPrice,TotalPrice,Product2Id, PricebookEntryId
                                                                              FROM OpportunityLineItem
                                                                              WHERE OpportunityId=: oppId AND Print_IO__c=TRUE]);
        system.debug('oli'+oppOli);
        
        return oppOli.values();
    }
    
    //Checking if Opportunity has OpportunityLineItem
    @AuraEnabled
    global static String getCurrency(String oppId){
        Opportunity opp = [SELECT  Id,CurrencyIsoCode
                           FROM Opportunity
                           WHERE Id=: oppId];
        return opp.CurrencyIsoCode;
    }
    
    @AuraEnabled
    global static String getGroupSale(String oppId){
        String s;
        Opportunity opp = [SELECT  Id,Group_Sale__c,Sales_Department__c 
                           FROM Opportunity
                           WHERE Id=: oppId];
        s = opp.Group_Sale__c + ',' + opp.Sales_Department__c;
        return s;
    }
    @AuraEnabled
    global static date getCloseDate(String oppId){
        Opportunity opp = [SELECT  closedate 
                           FROM Opportunity
                           WHERE Id=: oppId];
        return opp.closedate;
    }
    //Checking if Opportunity has OpportunityLineItem
    @AuraEnabled
    global static boolean hasOli(String oppId){
        boolean oliStatus=TRUE;
        List<OpportunityLineItem> oppOli = [SELECT  Id
                                            FROM OpportunityLineItem
                                            WHERE OpportunityId=: oppId 
                                            AND Print_IO__c=TRUE];
        if(oppOli.isEmpty()){
            oliStatus = FALSE;
        }
        return oliStatus;
    }
    
    //Handling Revenue Schedule Updates
    @AuraEnabled
    global static void handleRevSchUpdates(String oppId,String oli,date closeDate){
        //Handling JSON String to Fetch Individual Line Items from it
        system.debug(oli);
        List<String> js = oli.split('},');
        system.debug(js);
        OpportunityLineItem opli;
        OpportunityLineItemSchedule olis;
        Decimal Uprice;
        Map<Id,OpportunityLineItem> olifix = new Map<Id,OpportunityLineItem>();
        List<OpportunityLineItemSchedule> olisUp = new List<OpportunityLineItemSchedule>();
        //Ensuring split a Valid JSON String
        if(oli != '[]'){
        for(integer i=0;i<js.size();i++){
            
            String js1 = js.get(i);
            integer len = js1.length();
            
            if(js1.right(len-1)!='}'){
                js1 = js1+'}]';
            }
            
            len = js1.length();
            
            if(js1.right(len-1)!=']'){
                js1 = js1+']';
            }
            //Calling JSON_Helper to get the values
            JSON_Helper objJSON2Apex = new JSON_Helper(System.JSON.createParser(js1));
            //Posting Values Back to OpportunityLineItem
            opli = new OpportunityLineItem(Id = objJSON2Apex.Id);
            olis = new OpportunityLineItemSchedule(Id = objJSON2Apex.RevSchId);
            
            //Removing Currency Code from the Amount
            String tempStr = objJSON2Apex.curncy;
            List<string> amt;
            if(tempStr.contains(' ')){
                amt = ((objJSON2Apex.curncy).split(' '));
               	Uprice = decimal.valueOf(amt[1]);
            }
            else{
                if(tempStr.isNumeric()){
                   Uprice = decimal.valueOf(tempStr);
                }
                else
                    Uprice = 0.00;
            }
            opli.Issue_Date__c = str2Date(objJSON2Apex.Issue_Date);
            opli.RevSchId__c = objJSON2Apex.RevSchId;
			
            olis.ScheduleDate = opli.Issue_Date__c;
            olis.Revenue = Uprice;
            
                if(olis.Id == null){
                    olis.OpportunityLineItemId = objJSON2Apex.Id;
                    olis.Type = 'Revenue';
                }
            
            if(objJSON2Apex.Print_IO!=null){
            	opli.Print_IO__c = boolean.valueOf(objJSON2Apex.Print_IO);
                olifix.put(opli.Id,opli);
            }
            system.debug('opli'+opli);
            system.debug('olis'+olis);
            
            olisUp.add(olis);
        }
        }
        Opportunity op = new Opportunity(Id = OppId);
        op.CloseDate = closeDate;
        op.Close_Date_Updated_from_Component__c = TRUE;
        update op;        

        system.debug('olisUp'+olisUp);
        if(olisUp.size()>0){
            try{
                Database.UpsertResult[] results = Database.upsert(olisUp);
            }catch (DmlException e){
                throw new AuraHandledException('Unable to Save Records!!\n'+e.getMessage());
            }
            createQuote(oppId);
        }
           
    }
    @AuraEnabled
    global static void updClosedateCheck(Id oppId){
        Opportunity op = new Opportunity(Id = oppId);
        op.Close_Date_Updated_from_Component__c = FALSE;
        update op; 
    }
    
    @AuraEnabled
    global static void handleRevSchUpdateOli(String oppId){
        List<OpportunityLineItem> oppli = getOli2(oppId);
        Map<Id,OpportunityLineItem> oliUp = new Map<Id,OpportunityLineItem>();
        
        for(OpportunityLineItem o: oppli){
            if(!(o.Print_IO__c)){
                o.Issue_Date__c = null;
            }
            oliUp.put(o.Id, o);
        }
        try{
            database.upsert(oliUp.values());
        }
        catch (DmlException e){
            throw new AuraHandledException('Unable to Save Records!!\n'+e.getMessage());
        }
    }
    
    
    //Delete OpportunityLineItem
    @AuraEnabled
    global static Boolean delOli(String oliId){
        
        List<QuotelineItem> ql = new List<QuotelineItem>();
        if(oliId!=null){
        	OpportunityLineItem opl = New OpportunityLineItem(Id=oliId);
            ql = [SELECT Id FROM QuotelineItem WHERE OpportunityLineItemId =: opl.Id];
        	delete opl;
        }
        
        Boolean t = TRUE;
        
        if(ql.size()>0){
            t = FALSE;
            Database.DeleteResult[] DR_Dels = Database.delete(ql);
            for(Database.DeleteResult dr : DR_Dels) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                    t = TRUE;
                }
            }
        }
        return t;
    }
    
    //Delete RevenueScheduel
    @AuraEnabled
    global static String delRevSch(String oliId,String RevSchId){
        
        List<OpportunityLineItemSchedule> olis = [SELECT Id 
                                                  FROM OpportunityLineItemSchedule 
                                                  WHERE OpportunityLineItemId =: oliId];
        
        String t = 'TRUE';
        if( (RevSchId != null) && (olis.size() > 1) ){
            OpportunityLineItemSchedule rvsch = New OpportunityLineItemSchedule(Id=RevSchId);
            
            t = 'FALSE';
            Database.DeleteResult DR_Dels = Database.delete(rvsch);
            if (DR_Dels.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + DR_Dels.getId());
                t = 'TRUE';
            }
        }
        else{
            t = 'LAST';
        }
        return t;
    }
    
    //Fetch Opportunity Name for Toast
    @AuraEnabled
    global static String getOppName(String oppId){
        system.debug('oppId'+oppId);
        Opportunity opp = [SELECT Name FROM opportunity WHERE id=:oppId limit 1];
        String Oppname = opp.name;
        system.debug(Oppname+oppId);
        return Oppname;
    }
    //Save Line Item
    @AuraEnabled
    global static boolean delSchedule(String OppId){
        List<OpportunityLineItemSchedule> clnSch = [SELECT Id 
                                                    FROM OpportunityLineItemSchedule
                                                    WHERE OpportunityLineItem.OpportunityId =: OppId
                                                    AND OpportunityLineItem.Print_IO__c = TRUE];
        system.debug('clnSch '+clnSch);
        Boolean b = FALSE;
        if(clnSch.size()>0){
            Database.DeleteResult[] DR_Dels = Database.delete(clnSch, false);
            for(Database.DeleteResult dr : DR_Dels) {
                b = FALSE;
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted OpportunityLineItemSchedule with ID: ' + dr.getId());
                    b = TRUE;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('OpportunityLineItemSchedule fields that affected this error: ' + err.getFields());
                        throw new AuraHandledException('Darn it! Something went wrong!! Unable to save your changes '+err.getMessage());
                    }
                }
            } 
        }
        else{
            b = TRUE;
        }
        return b;
    }
    //Save Line Item
    @AuraEnabled
    global static void saveOli(String oli,String OppId,string ISOcurncy,String GroupSale,String SalesDept){
		
        //Check if Opportunity is Locked
        if( Approval.isLocked(OppId) ){
            throw new AuraHandledException('Opportunity is currently Locked for editing.\nPlease contact Approver!');
        }
        
        List<OpportunityLineItem> delOlis = New List<OpportunityLineItem>();
        system.debug('delSchedule Status '+ delSchedule(OppId));      
        List<OpportunityLineItem> oli2 = new List<OpportunityLineItem>();
        OpportunityLineItem opli = new OpportunityLineItem();
        Boolean full_discount=FALSE;
        Decimal Uprice;
        //Handling JSON String to Fetch Individual Line Items from it
        List<String> js = oli.split('},');
        //Ensuring split a Valid JSON String
        for(integer i=0;i<js.size();i++){
            opli = new OpportunityLineItem();
            String js1 = js.get(i);
            integer len = js1.length();
            
            if(js1.right(len-1)!='}'){
                js1 = js1+'}]';
            }
            
            len = js1.length();
            
            if(js1.right(len-1)!=']'){
                js1 = js1+']';
            }
            //Calling JSON_Helper to get the values
            system.debug('JSON: '+js1);
            JSON_Helper objJSON2Apex = new JSON_Helper(System.JSON.createParser(js1));
            //Fetching List Prices, ProductIDs and PricebookEntryIDs.
            REF_Product_Rate_Cards__c up = new REF_Product_Rate_Cards__c();
            
            //Removing Currency Code from the Amount
            String tempStr = objJSON2Apex.curncy;
            List<string> amt;
            if(tempStr.contains(' ')){
                amt = ((objJSON2Apex.curncy).split(' '));
               	Uprice = decimal.valueOf(amt[1]);
            }
            else{
                if(tempStr.isNumeric()){
                   Uprice = decimal.valueOf(tempStr);
                }
                else
                    Uprice = 0.00;
            }
            
            system.debug('ISOcurncy '+ISOcurncy+objJSON2Apex.Ad_Size+objJSON2Apex.Edition);
            opli.Ad_Size__c = objJSON2Apex.Ad_Size;
            if((opli.Ad_Size__c!=null)&&(opli.Ad_Size__c!='Production Charge')){
                system.debug('NOT NULL '+ISOcurncy+objJSON2Apex.Ad_Size+objJSON2Apex.Publication+objJSON2Apex.Edition);
                List<REF_Product_Rate_Cards__c> x = new List<REF_Product_Rate_Cards__c>();
                if( (SalesDept != null) && (SalesDept == 'Careers') ){
                    x = [SELECT Rate__c,Product__c,PriceBookEntryId__c,Ad_Size__c
                         FROM REF_Product_Rate_Cards__c 
                         WHERE End_Date__c >= TODAY 
                         AND CurrencyIsoCode =: ISOcurncy
                         AND Ad_Size__c =: objJSON2Apex.Ad_Size
                         AND Edition__c =: objJSON2Apex.Edition
                         AND Publication__c =: objJSON2Apex.Publication
                         AND Type__c = 'Careers'
                         Limit 1];
                }
                else{
                    x = [SELECT Rate__c,Product__c,PriceBookEntryId__c,Ad_Size__c
                         FROM REF_Product_Rate_Cards__c 
                         WHERE End_Date__c >= TODAY 
                         AND CurrencyIsoCode =: ISOcurncy
                         AND Ad_Size__c =: objJSON2Apex.Ad_Size
                         AND Edition__c =: objJSON2Apex.Edition
                         AND Publication__c =: objJSON2Apex.Publication
                         AND Type__c != 'Careers'
                         Limit 1];
                }
                if(x.size()>0){
                    up = x[0];
                    if(x[0].Rate__c == 0){
                        up.Rate__c = Uprice;
                    }
                }
                else{
                    x = [SELECT Rate__c,Product__c,PriceBookEntryId__c,Ad_Size__c
                                                         FROM REF_Product_Rate_Cards__c 
                                                         WHERE End_Date__c >= TODAY 
                                                         AND CurrencyIsoCode =: ISOcurncy
                                                         AND Publication__c =: objJSON2Apex.Publication
                                                         Limit 1];
                    up = x[0];
                    up.Rate__c = Uprice;
                    up.Ad_Size__c = objJSON2Apex.Ad_Size;
                }
            }
            else{
                up = [SELECT Rate__c,Product__c,PriceBookEntryId__c,Ad_Size__c
                      FROM REF_Product_Rate_Cards__c 
                      WHERE End_Date__c >= TODAY 
                      AND CurrencyIsoCode =: ISOcurncy
                      AND Ad_Size__c =: objJSON2Apex.Ad_Size
                      AND Publication__c =: objJSON2Apex.Publication
                      Limit 1];
            }
            system.debug('up '+up.rate__c);
            opli = new OpportunityLineItem(Id = objJSON2Apex.Id,
                							OpportunityId = OppId,
                                           Product2Id = up.Product__c,
                                           PricebookEntryId = up.PriceBookEntryId__c);
 
            //Posting Values to OpportunityLineItem from JSON String
            opli.Position__c = objJSON2Apex.Position;
            opli.Issue_Date__c = str2Date(objJSON2Apex.Issue_Date);
            opli.Requested_Gauranted__c = objJSON2Apex.Requested_Gauranted;
            opli.Quantity = 1;
            opli.Section__c = objJSON2Apex.Section;
            opli.Ad_Size__c = up.Ad_Size__c;
            opli.Publication__c = objJSON2Apex.Publication;
            opli.Edition__c = objJSON2Apex.Edition;
            opli.Platform__c = objJSON2Apex.Platform; 
            opli.Classified_Category__c = objJSON2Apex.Classified_Category;
            opli.Color__c = objJSON2Apex.Color;
            opli.Discount_IO__c = objJSON2Apex.discount2;
            opli.Discount = decimal.valueOf(objJSON2Apex.discount2);
            opli.currency__c = objJSON2Apex.curncy;
            opli.Print_IO__c = true;
            opli.Combined_Audience__c = objJSON2Apex.Combined_Audience;
			system.debug('Combined_Audience__c'+objJSON2Apex.Combined_Audience);
            opli.UnitPrice = up.Rate__c;
            if(((opli.Discount==0)||(opli.Discount==null))&&(opli.UnitPrice!=0)){
                opli.Discount = (((opli.UnitPrice - Uprice)/opli.UnitPrice)*100);
                opli.Discount = (opli.Discount).setScale(2);
                opli.Discount_IO__c = String.valueOf((opli.Discount).setScale(2));
                opli.currency__c = String.valueof(ISOcurncy) + ' ' + String.valueOf(((opli.UnitPrice)*((100-opli.Discount)/100)).setScale(2));
                system.debug('opli.currency__c'+opli.currency__c);
                if((opli.Discount > 100)||(opli.Discount < 0)){
                    opli.Discount = 0;
                    opli.Discount_IO__c =String.valueof(0.00);
                    opli.UnitPrice = Uprice;
                    opli.currency__c = String.valueof(ISOcurncy) + ' ' + String.valueOf(opli.UnitPrice);
                }
            }
            else{
                opli.currency__c = String.valueof(ISOcurncy) + ' ' + String.valueOf(((opli.UnitPrice)*((100-opli.Discount)/100)).setScale(2));
            }
            if(((opli.UnitPrice==0)||(opli.UnitPrice==null))&&(Uprice>0)){
               opli.UnitPrice =  Uprice;
               opli.currency__c = String.valueof(ISOcurncy) + ' ' + String.valueOf(Uprice);
            }
            system.debug('opli'+opli);
            oli2.add(opli);
            if(((opli.Discount==100)||(opli.UnitPrice==0.00))&&(opli.Issue_Date__c!=null)&&(full_discount!=TRUE)){
                System.debug('FULL DISCOUNT!!'+opli.Issue_Date__c);
                full_discount = TRUE;
            }
        }      
        
        List<Print_IO_Settings__mdt> getstng = [SELECT Quote_Template_Id__c,Email_Addresses__c,PriceBookID__c
                                                FROM Print_IO_Settings__mdt];
        Opportunity op = [SELECT Id,Is_Re_Opened__c,StageName,closedate  FROM Opportunity WHERE Id =: OppId];
        op.IO_Opportunity__c = TRUE;
        op.Full_Discount_w_Guaranteed_Date__c = full_discount;
        op.Pricebook2Id = getstng[0].PriceBookID__c;
        op.Group_Sale__c = GroupSale;
        
        if(op.Is_Re_Opened__c==TRUE){
            op.Order_Type__c = 'Amendment';
            if(op.StageName =='50% Planned'){
                op.Is_Position_Approved__c = FALSE;
            }
            else{
                throw new AuraHandledException('Please Update the Opportunity Stage to 50% to Edit Products!!');
            }
        }
        else{
        	op.Order_Type__c = 'New'; 
        }
		
        if(op.CloseDate<System.today()){
            op.CloseDate = System.today();
        }
        try{
            upsert op;
        }catch (DmlException e){
            throw new AuraHandledException('Unable to Save Records!!\n'+e.getMessage());
        }
  		
        try{
            Database.UpsertResult[] results = Database.upsert(oli2);
            //Verifying Results
            for(Database.UpsertResult ur: results) {
                system.debug('results '+ur);
                if(!(ur.isSuccess())) {
                    throw new AuraHandledException('Unable to Save Records!!');
                }
            }
        }catch (DmlException e){
            throw new AuraHandledException('Unable to Save Records!!\n'+e.getMessage());
        }
    }
    
    //Saving Revenue Schedule Called from HandleSave method in Editor Controller, Once SaveOli is successfully finished.
    @AuraEnabled
    global static void saveSchedule(String oppid){
    	OpportunityLineItemSchedule olisch;
        List<OpportunityLineItemSchedule> olischlst = new List<OpportunityLineItemSchedule>();
        set<Id> ods = new set<Id>();
        List<OpportunityLineItem> crtolisch = [SELECT Id,TotalPrice,Issue_Date__c,Discount_IO__c,Opportunity.closedate,Discount
                                               FROM OpportunityLineItem
                                               WHERE opportunityId=:OppId 
                                               AND Print_IO__c=TRUE 
                                               AND Discount!=100];
        for(OpportunityLineItem noli: crtolisch){
            if((noli.TotalPrice!=null)||(noli.Discount_IO__c!='100')||(noli.TotalPrice!=0)||(noli.Discount!=100)){
                olisch = New OpportunityLineItemSchedule(OpportunityLineItemId=noli.Id);
                ods.add(noli.Id);
                olisch.Revenue = noli.TotalPrice;
                if(noli.Issue_Date__c!=null){
                	olisch.ScheduleDate = noli.Issue_Date__c;
                }
                else{
                    olisch.ScheduleDate = noli.Opportunity.closedate;
                }
                olisch.Type = 'Revenue';
                olischlst.add(olisch);
            }
        }
        
        system.debug('olischlst'+olischlst);
        
        List<OpportunityLineItemSchedule> olischlst2 = [SELECT ID FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId=: ods];
        if(olischlst2.size()>0){
            system.debug('OLIS'+olischlst2);
            Database.DeleteResult[] drList = Database.delete(olischlst2, false);
        }
        
        //Insert OpportunityLineItemSchedule
        if(olischlst.size()>0){
            system.debug(olischlst.size());
            Database.SaveResult[] res = Database.insert(olischlst);
            system.debug('OLI: '+crtolisch.size()+' olisch: '+res.size());
        }
        
        //Add Quote
        createQuote(OppId);
        
    }
    
    //Fetching Prices from Product Rate Card
    @AuraEnabled
    global static OpportunityLineItem getPrice(String oli, String ISOcurncy, String OppId, String SalesDept){
        
        String srchQuery;
        OpportunityLineItem opli = new OpportunityLineItem();
        
        //Handling JS to fetch Line Item
        String js = oli, s1 = '}',s2 = '[',s3=']';
        if(!(js.contains('}]"]'))){
            js = js+'}]"]';
        }
        if(js.charAt(0)!=s2.charAt(0)){
            js = '[' + js;
        }
        if(js.charAt(js.length()-1)!=s3.charAt(0)){
            js = js+'[';
        }
        //Calling JSON_Helper to get the values
        JSON_Helper objJSON2Apex = new JSON_Helper(System.JSON.createParser(js));
        //Posting Values Back to OpportunityLineItem
        opli = new OpportunityLineItem();
        opli.Position__c = objJSON2Apex.Position;
        opli.Discount = objJSON2Apex.discount;
        opli.Discount_IO__c = objJSON2Apex.discount2;
        opli.Issue_Date__c = str2Date(objJSON2Apex.Issue_Date);
        opli.Requested_Gauranted__c = objJSON2Apex.Requested_Gauranted;
        opli.Quantity = objJSON2Apex.Quantity;
        opli.Section__c = objJSON2Apex.Section;
        opli.Ad_Size__c = objJSON2Apex.Ad_Size;
        opli.Publication__c = objJSON2Apex.Publication;
        opli.UnitPrice = objJSON2Apex.UnitPrice;
        opli.Edition__c = objJSON2Apex.Edition;
        opli.Platform__c = objJSON2Apex.Platform;
        opli.Classified_Category__c = objJSON2Apex.Classified_Category;
        opli.Color__c = objJSON2Apex.Color;
        opli.Combined_Audience__c = objJSON2Apex.Combined_Audience;
        
        if((objJSON2Apex.Id!=null) && (objJSON2Apex.Id!='BLANK')){
            opli.Id = objJSON2Apex.Id;
        }
        
        //Fetching PriceBook
        List<Print_IO_Settings__mdt> getstng = [SELECT Quote_Template_Id__c,
                                                Email_Addresses__c,PriceBookID__c
                                                FROM Print_IO_Settings__mdt];
        List<Opportunity> op = [SELECT Pricebook2Id FROM Opportunity WHERE id=: OppId];
        system.debug('op'+op+' '+OppId);
        //String prcebkId = op.get(0).Pricebook2Id;
        String prcebkId = getstng.get(0).PriceBookID__c;
        //Query Generator
        srchQuery = 'SELECT Ad_Size__c,Edition__c,Id,Name,Publication__c,Product__c,PriceBookEntryId__c,Price_Book_ID__c,Rate__c,CurrencyIsoCode'
            + ' FROM REF_Product_Rate_Cards__c WHERE End_Date__c >= TODAY';
        //Adding AdSize
        if(ISOcurncy!=null){
            srchQuery += ' AND CurrencyIsoCode =\''+ ISOcurncy + '\'';
        }
        if(opli.Ad_Size__c!=null){
            //srchQuery += ' AND Product2.Ad_Size__c =\''+ opli.Ad_Size__c +'\'';
            srchQuery += ' AND Ad_Size__c =\''+ opli.Ad_Size__c +'\'';
        }
        if(opli.Edition__c!=null){
            //srchQuery += ' AND Product2.Edition__c =\''+ opli.Edition__c +'\'';
            if((opli.Ad_Size__c!=null)&&(opli.Ad_Size__c!='Production Charge')){
            srchQuery += ' AND Edition__c =\''+ opli.Edition__c +'\'';
            }
        }
        if(opli.Publication__c!=null){
            //srchQuery += ' AND Product2.Publication__c =\''+ opli.Publication__c + '\'';
            srchQuery += ' AND Publication__c =\''+ opli.Publication__c + '\'';
        }
        
        if((SalesDept!=null) && (SalesDept == 'Careers')){
           srchQuery += ' AND Type__c =\''+ SalesDept + '\''; 
        }
        else{
           srchQuery += ' AND Type__c !=\''+ 'Careers' + '\'';  
        }
        
        srchQuery += ' Limit 1';
        system.debug('srchQuery'+srchQuery);
        List<REF_Product_Rate_Cards__c> prodval = database.query(srchQuery);
        system.debug(prodval);
        //Posting Prices back Oli
        OpportunityLineItem opli2;
        if(prodval.size()>0){
            for(REF_Product_Rate_Cards__c pr: prodval){
                opli2 = new OpportunityLineItem(UnitPrice=pr.Rate__c,Product2Id=pr.Product__c,PricebookEntryId=pr.PriceBookEntryId__c);
                opli2.Position__c  =  opli.Position__c;
                opli2.Issue_Date__c  =  opli.Issue_Date__c;
                opli2.Requested_Gauranted__c  =  opli.Requested_Gauranted__c;
                opli2.Quantity  =  opli.Quantity;
                opli2.Section__c  =  opli.Section__c;
                opli2.Ad_Size__c  =  opli.Ad_Size__c;
                opli2.Publication__c  =  opli.Publication__c;
                opli2.Discount = opli.Discount;
                opli2.Discount_IO__c = opli.Discount_IO__c;
                opli2.Edition__c  =  opli.Edition__c;
                opli2.Platform__c  =  opli.Platform__c;
                opli2.Classified_Category__c  =  opli.Classified_Category__c;
                opli2.Color__c  =  opli.Color__c;
                opli2.currency__c = pr.CurrencyIsoCode+' '+opli2.UnitPrice;
                opli2.Combined_Audience__c = opli.Combined_Audience__c;
                if(opli.Id!=null){
                    opli2.Id  =  opli.Id;
                }
                //Sending Data back to the Component            
                opli = opli2;
                
            }
        }
        else{
            srchQuery = 'SELECT Ad_Size__c,Edition__c,Id,Name,Publication__c,Product__c,PriceBookEntryId__c,Price_Book_ID__c,Rate__c,CurrencyIsoCode'
            + ' FROM REF_Product_Rate_Cards__c WHERE End_Date__c >= TODAY';
            srchQuery += ' AND CurrencyIsoCode =\''+ ISOcurncy + '\'';
            srchQuery += ' AND Publication__c =\''+ opli.Publication__c + '\'';
            srchQuery += ' Limit 1';
            prodval = database.query(srchQuery);
            
            if(prodval.size()>0){
               	opli2 = new OpportunityLineItem(UnitPrice=0,
                                                Product2Id=prodval[0].Product__c,
                                                PricebookEntryId=prodval[0].PriceBookEntryId__c);
            	
                opli2.Position__c  =  opli.Position__c;
                opli2.Issue_Date__c  =  opli.Issue_Date__c;
                opli2.Requested_Gauranted__c  =  opli.Requested_Gauranted__c;
                opli2.Quantity  =  opli.Quantity;
                opli2.Section__c  =  opli.Section__c;
                opli2.Ad_Size__c  =  opli.Ad_Size__c;
                opli2.Publication__c  =  opli.Publication__c;
                opli2.Discount = opli.Discount;
                opli2.Discount_IO__c = opli.Discount_IO__c;
                opli2.Edition__c  =  opli.Edition__c;
                opli2.Platform__c  =  opli.Platform__c;
                opli2.Classified_Category__c  =  opli.Classified_Category__c;
                opli2.Color__c  =  opli.Color__c;
                opli2.currency__c = prodval[0].CurrencyIsoCode+' '+opli2.UnitPrice;
                opli2.Combined_Audience__c = opli.Combined_Audience__c;
                if(opli.Id!=null){
                    opli2.Id  =  opli.Id;
                }
                opli = opli2;
            }
            else{
                throw new AuraHandledException('This is not a valid currency for Publication.\n Please update Opportunity Currency!');
            }
                                    
        }
        return opli;
    }
    
    //Getting Today
    @AuraEnabled
    global static String getToday(Integer Day, String Month, Integer Year){
        Integer intMnth;
        System.debug(Day+Month+Year);
        if(Month=='Jan')
            intMnth=1;
        if(Month=='Feb')
            intMnth=2;
        if(Month=='Mar')
            intMnth=3;
        if(Month=='Apr')
            intMnth=4;
        if(Month=='May')
            intMnth=5;
        if(Month=='Jun')
            intMnth=6;
        if(Month=='Jul')
            intMnth=7;
        if(Month=='Aug')
            intMnth=8;
        if(Month=='Sep')
            intMnth=9;
        if(Month=='Oct')
            intMnth=10;
        if(Month=='Nov')
            intMnth=11;
        if(Month=='Dec')
            intMnth=12;
        
        String myDate;
        Date clcdt = date.newInstance(Integer.valueOf(Year), intMnth, Integer.valueOf(Day));
        Datetime dt = DateTime.newInstance(clcdt.toStartOfMonth(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek= dt.format('EEE');
        String monthName= dt.format('MMM');
        
        myDate = dayOfWeek+','+date.daysInMonth(clcdt.year(), clcdt.month())+','+monthName+','+clcdt.day()+','+clcdt.year();
        return myDate;
    }
    
    //Get SF Date
    @AuraEnabled
    global static date getsfDate(Integer Day, String Month, Integer Year){
        Integer intMnth;
        System.debug(Day+Month+Year);
        if(Month=='Jan')
            intMnth=1;
        if(Month=='Feb')
            intMnth=2;
        if(Month=='Mar')
            intMnth=3;
        if(Month=='Apr')
            intMnth=4;
        if(Month=='May')
            intMnth=5;
        if(Month=='Jun')
            intMnth=6;
        if(Month=='Jul')
            intMnth=7;
        if(Month=='Aug')
            intMnth=8;
        if(Month=='Sep')
            intMnth=9;
        if(Month=='Oct')
            intMnth=10;
        if(Month=='Nov')
            intMnth=11;
        if(Month=='Dec')
            intMnth=12;
        
        Date clcdt = date.newInstance(Integer.valueOf(Year), intMnth, Integer.valueOf(Day));
        return clcdt;
    }
    
    //Get Issue Dates from MetaData
    @AuraEnabled
    global static String getIssueDates(String pub){
        if(pub == '1843 Supplement')
            pub = '1843';
        list<IO_IssueDates__mdt> isdt = [SELECT Issue_Date__c,Publication__c,Active__c FROM IO_IssueDates__mdt WHERE Active__c=TRUE AND Publication__c=:pub ORDER BY Issue_Date__c DESC];
        String s='';
        for(IO_IssueDates__mdt i : isdt){
            datetime dt = DateTime.newInstance(i.Issue_Date__c,Time.newInstance(0, 0, 0, 0));
            String dayOfWeek= dt.format('dd MMM yyyy');
            
            s = dayOfWeek+','+s;
        }
        return s;
    }
    
    //Date String to Date
    global static date str2Date(String JSONdate){
        String[] strDate;
        Date d;
        if(JSONdate!=null){
            if(JSONdate.contains(' ')){
                strDate = JSONdate.split(' ');
                if(strDate.size()==3){
                    Integer myIntDate = integer.valueOf(strDate[0]);
                    Integer myIntMonth;
                    if(strDate[1]!=null){
                        switch on strDate[1]{
                            when  'Jan' { 
                                myIntMonth=1;
                            }
                            when  'Feb' { 
                                myIntMonth=2;
                            }
                            when  'Mar' { 
                                myIntMonth=3;
                            }
                            when  'Apr' { 
                                myIntMonth=4;
                            }                
                            when  'May' { 
                                myIntMonth=5;
                            }  
                            when  'Jun' { 
                                myIntMonth=6;
                            }
                            when  'Jul' { 
                                myIntMonth=7;
                            }                
                            when  'Aug' { 
                                myIntMonth=8;
                            } 
                            when  'Sep' { 
                                myIntMonth=9;
                            }  
                            when  'Oct' { 
                                myIntMonth=10;
                            }
                            when  'Nov' { 
                                myIntMonth=11;
                            }                
                            when  'Dec' { 
                                myIntMonth=12;
                            } 
                        }
                    }
                    Integer myIntYear = integer.valueOf(strDate[2]);
                    d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                }
                else{
                    d = null;
                }
            }
            if(JSONdate.contains('-')){
                strDate = JSONdate.split('-');
                if((strDate[0]!=null)){
                    Integer myIntDate = integer.valueOf(strDate[2]);
                    Integer myIntMonth = integer.valueOf(strDate[1]);
                    Integer myIntYear = integer.valueOf(strDate[0]);
                    d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                }
            }
        }
        system.debug('objJSON2Apex.Issue_Date: '+JSONdate+' '+d);
        return d;
    }
    
    //Create Quote called from SaveOli, once Revenue Schedules are updated Successfully.
    global static void createQuote(String oppid){
        system.debug('oppid'+oppid);
        List<opportunity> op = [SELECT 	Name,
                                Pricebook2Id,
                                Order_Type__c,
                                account.billingStreet,
                                account.billingCity,
                                account.billingState,
                                account.billingCountry
                                from 
                                Opportunity WHERE id=:oppid];
        List<Quote> q1 = [SELECT Id,Name from Quote WHERE OpportunityId=:oppid AND Status='Active I/O'];
        Integer version=1;
        for(Quote q2: q1){
            //q2.Primary_Quote__c=FALSE;
            //q2.Status='Inactive I/O';
            version++;
        }
        String qname = op.get(0).Name+' v'+version;
        Quote q = new quote();
        if(q1.size()>0){
                q.Id=q1[0].Id;
        }
        else{
        q = new Quote(name=qname,
                            OpportunityId=oppid,
                            Pricebook2Id=op.get(0).Pricebook2Id,
                            Primary_Quote__c=TRUE,
                            Order_Type2__c = op.get(0).Order_Type__c,
                            Status='Active I/O',
                            billingStreet = op.get(0).account.billingStreet,
                            billingCity = op.get(0).account.billingCity,
                            billingState = op.get(0).account.billingState,
                            billingCountry = op.get(0).account.billingCountry);
        //q1.add(q);
        //upsert q1;
        insert q;
        }
        
        createQli(oppid,q.Id); //Creating Quote Line Item
    }
    
    //Creating Quote Line Item
    global static void createQli(String oppid,string Qid){
        List<OpportunityLineItem> oppOli = [SELECT  Id,OpportunityId,Publication__c,Issue_Date__c,Platform__c,Section__c,
                                            Edition__c,Classified_Category__c,Ad_Size__c,Requested_Gauranted__c,Print__c,
                                            Size__c,Position__c,Color__c,currency__c,Discount,UnitPrice,TotalPrice,Combined_Audience__c,
                                            Product2Id, PricebookEntryId, isdeleted
                                            FROM OpportunityLineItem 
                                            WHERE OpportunityId=:oppid AND Print_IO__c=TRUE];
        
        List<QuoteLineItem> oldQliLst = [SELECT OpportunityLineItemId,Id,Ad_Size__c,Classified_Category__c,Color__c,Description,RowNum__c,
                                   Discount,Edition__c,Issue_Date__c,Platform__c,Position__c,Print__c,Product2Id,Publication__c,Combined_Audience__c,
                                   Requested_Gauranted__c,Section__c,Size__c,TotalPrice,UnitPrice,QuoteId,LastModifiedDate,Row_Number__c,IsDeleted
                                   FROM QuoteLineItem 
                                   WHERE (QuoteId =: Qid) OR (QuoteId =: Qid AND IsDeleted = TRUE)
                                   ORDER BY LastModifiedDate DESC ALL ROWS];
        
        Map<Id,QuoteLineItem> oldQli = new Map<Id,QuoteLineItem>();
        String recChanges = '', deleted = '', added = '';
        
        deleted = '';
        for(QuoteLineItem ql: oldQliLst){
            oldQli.put(ql.OpportunityLineItemId, ql);
            if(ql.isDeleted){
                deleted += 'Row Id : ' + ql.RowNum__c;
                if(ql.Publication__c!=null){
                    deleted += ' | Publication: ' + ql.Publication__c;
                }
                if(ql.Ad_Size__c!=null){
                    deleted += ' | ' + 'Ad Size: ' + ql.Ad_Size__c ;
                }
                if(ql.Issue_Date__c!=null){
                    deleted += ' | Issue Date: ' + String.valueof(ql.Issue_Date__c.format()) + '\n';
                }
            }
        }
        
        system.debug('MAP: '+oldQli.keyset());
        integer count=0;
        String cmpr='';
        added = '';
        for(OpportunityLineItem ol: oppOli){
            cmpr='';
            count=0;
            if((!(ol.IsDeleted)) && (!(oldQli.containsKey(ol.Id))) && (oldQli.size() > 0)){
                if(ol.Publication__c!=null){
                    added += ' Publication: ' + ol.Publication__c;
                }
                if(ol.Ad_Size__c!=null){
                    added += ' | ' + 'Ad Size: ' + ol.Ad_Size__c ;
                }
                if(ol.Issue_Date__c!=null){
                    added += ' | Issue Date: ' + String.valueof(ol.Issue_Date__c.format()) + '\n';
                }
            }
            if(oldQli.containsKey(ol.Id)){
                if(ol.Ad_Size__c!=oldQli.get(ol.Id).Ad_Size__c){
                    cmpr += 'Field: Ad_Size | Old Value: ' + oldQli.get(ol.Id).Ad_Size__c + ' | New Value: ' + ol.Ad_Size__c + '\n';
                    count =1 ;
                }
                if(ol.Classified_Category__c!=oldQli.get(ol.Id).Classified_Category__c){
                    cmpr += 'Field: Classified_Category | Old Value: ' + oldQli.get(ol.Id).Classified_Category__c 
                        + ' | New Value: ' + ol.Classified_Category__c + '\n';
                    count =1 ;
                }
                if(ol.Color__c!=oldQli.get(ol.Id).Color__c){
                    cmpr += 'Field: Color | Old Value: ' + oldQli.get(ol.Id).Color__c +
                        ' | New Value: ' + ol.Color__c + '\n';
                    count =1 ;
                }
                if(ol.Discount!=oldQli.get(ol.Id).Discount){
                    cmpr += 'Field: Discount | Old Value: ' + oldQli.get(ol.Id).Discount + 
                        ' | New Value: ' + ol.Discount + '\n';
                    count =1 ;
                }
                if(ol.Edition__c!=oldQli.get(ol.Id).Edition__c){
                    cmpr += 'Field: Edition | Old Value: ' + oldQli.get(ol.Id).Edition__c + 
                        ' | New Value: ' + ol.Edition__c + '\n';
                    count =1 ;
                }
                if(ol.Issue_Date__c!=oldQli.get(ol.Id).Issue_Date__c){
                    cmpr += 'Field: Issue Date | Old Value: ' + oldQli.get(ol.Id).Issue_Date__c + 
                        ' | New Value: ' + ol.Issue_Date__c + '\n';
                    count =1 ;
                }
                if(ol.Platform__c!=oldQli.get(ol.Id).Platform__c){
                    cmpr += 'Field: Platform | Old Value: ' + oldQli.get(ol.Id).Platform__c + 
                        ' | New Value: ' + ol.Platform__c + '\n';
                    count =1 ;
                }
                if(ol.Position__c!=oldQli.get(ol.Id).Position__c){
                    cmpr += 'Field: Position | Old Value: ' + oldQli.get(ol.Id).Position__c + 
                        ' | New Value: ' + ol.Position__c + '\n';
                    count =1 ;
                }
                if(ol.Print__c!=oldQli.get(ol.Id).Print__c){
                    cmpr += 'Field: Print | Old Value: ' + oldQli.get(ol.Id).Print__c + 
                        ' | New Value: ' + ol.Print__c + '\n';
                    count =1 ;
                }
                if(ol.Publication__c!=oldQli.get(ol.Id).Publication__c){
                    cmpr += 'Field: Publication | Old Value: ' + oldQli.get(ol.Id).Publication__c + 
                        ' | New Value: ' + ol.Publication__c + '\n';                    
                    count =1 ;
                }
                if(ol.Requested_Gauranted__c!=oldQli.get(ol.Id).Requested_Gauranted__c){
                    cmpr += 'Field: Requested Gauranted | Old Value: ' + oldQli.get(ol.Id).Requested_Gauranted__c + 
                        ' | New Value: ' + ol.Requested_Gauranted__c + '\n';
                    count =1 ;
                }
                if(ol.Section__c!=oldQli.get(ol.Id).Section__c){
                    cmpr += 'Field: Section | Old Value: ' + oldQli.get(ol.Id).Section__c + 
                        ' | New Value: ' + ol.Section__c + '\n';
                    count =1 ;
                }
                if(ol.Size__c!=oldQli.get(ol.Id).Size__c){
                    cmpr += 'Field: Size | Old Value: ' + oldQli.get(ol.Id).Size__c + 
                        ' | New Value: ' + ol.Size__c + '\n';
                    count =1 ;
                }
                if(ol.TotalPrice!=oldQli.get(ol.Id).TotalPrice){
                    cmpr += 'Field: TotalPrice | Old Value: ' + oldQli.get(ol.Id).TotalPrice + 
                        ' | New Value: ' + ol.TotalPrice + '\n';
                    count =1 ;
                }
                if(ol.UnitPrice!=oldQli.get(ol.Id).UnitPrice){
                    cmpr += 'Field: UnitPrice | Old Value: ' + oldQli.get(ol.Id).UnitPrice + 
                        ' | New Value: ' + ol.UnitPrice + '\n';
                    count =1 ;
                }
                if(ol.Combined_Audience__c !=oldQli.get(ol.Id).Combined_Audience__c ){
                    cmpr += 'Field: Combined Audience | Old Value: ' + oldQli.get(ol.Id).Combined_Audience__c  + 
                        ' | New Value: ' + ol.Combined_Audience__c  + '\n';
                    count =1 ;
                }
                if(count == 1){
                    cmpr = cmpr.removeEndIgnoreCase(','); 
                    cmpr = cmpr.removeEnd(',');
                    cmpr = cmpr.replace('null', 'Blank');
                    recChanges += '\nFollowing Information has changed at Row Id : ' + oldQli.get(ol.Id).RowNum__c  + '\n';
                    recChanges += cmpr;
                }
            }
        }
        
        if(added != ''){
            recChanges += '\nFollowing Rows were Added : \n';
            recChanges += added;
        }
        
        if(deleted != ''){
            recChanges += '\nFollowing Rows were Deleted : \n';
            recChanges += deleted;
        }
        
        recChanges = recChanges.removeEndIgnoreCase(',');
        recChanges = recChanges.remove('null');
        system.debug('count '+count);
        system.debug('recChanges end '+recChanges);
        quote q = new Quote(Id=Qid,Description=recChanges);
        upsert q;
        
        List<QuoteLineItem> qli = new List<QuoteLineItem>();
        QuoteLineItem ql = new QuoteLineItem();
        integer i=0;
        for(OpportunityLineItem o: oppOli){
            i = i + 1;
            if(oldQli.containsKey(o.Id)){
                ql = new QuoteLineItem(Id=oldQli.get(o.Id).Id);
            }else{
                ql = new QuoteLineItem();
                ql.PricebookEntryId = o.PricebookEntryId;
                ql.Product2Id = o.Product2Id;
                ql.Quantity = 1;
                ql.QuoteId = Qid;
                ql.OpportunityLineItemId = o.id;
            }
            ql.Quantity = 1;
            ql.UnitPrice = o.UnitPrice;
            ql.Discount = o.Discount;
            ql.Position__c = o.Position__c;
            ql.Issue_Date__c = o.Issue_Date__c;
            ql.Requested_Gauranted__c = o.Requested_Gauranted__c;
            ql.Section__c = o.Section__c;
            ql.Ad_Size__c = o.Ad_Size__c;
            ql.Publication__c = o.Publication__c;
            ql.Edition__c = o.Edition__c;
            ql.Platform__c = o.Platform__c;
            ql.Classified_Category__c = o.Classified_Category__c;
            ql.Color__c = o.Color__c;
            ql.Row_Number__c = i;
            ql.Combined_Audience__c = o.Combined_Audience__c;
            qli.add(ql);
        }
        upsert qli;
        
        createPdf(oppid,Qid);
    }
    
    //Creating PDF at a future time as results are not available in the same transaction.
    @future(callout=true)
    global static void createPdf(String oppid,string Qid){
        
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
        Blob b;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = pg.getContentAsPDF() ;
        }
        quotedoc.Document = b;
        quotedoc.QuoteId = QuoteID ;
        
        insert quotedoc;
    }
    
    @AuraEnabled
    public static List <OpportunityLineItem> getAttachments(Id oppId) {
        system.debug(oppId);
        List<OpportunityLineItem> oli = [SELECT Id,Product_Name__c,Ad_Size__c, Publication__c,UnitPrice,TotalPrice  
                                         FROM OpportunityLineItem 
                                         WHERE OpportunityId =: oppId];
        system.debug(oli);
        return oli;
    }
    
    //Fetching Records for Related List
    @AuraEnabled
    public static DataTableResponse getAccRecords(String strObjectName, String strFieldSetName,String OppId, String editable){                
        
        //Get the fields from FieldSet
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);
        
        //To hold the table hearders 
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        
        //Field to be queried - fetched from fieldset
        List<String> lstFieldsToQuery = new List<String>();
        
        //The final wrapper response to return to component
        DataTableResponse response = new DataTableResponse();
        
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            if(dataType == 'datetime'){
                dataType = 'date';
            }
            //Create a wrapper instance and store label, fieldname and type.
            DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                String.valueOf(eachFieldSetMember.getType()).toLowerCase(),
                                                                OppId,editable);
            system.debug('datacolumns '+datacolumns);
            lstDataColumns.add(datacolumns);
            lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
        }
        
        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(! lstDataColumns.isEmpty()){            
            response.lstDataTableColumns = lstDataColumns;
            String query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') + ' FROM ' + strObjectName + ' WHERE OpportunityId = \'' + oppId + '\'';
            if(editable=='TRUE'){
                query = query + ' AND HasRevenueSchedule = TRUE';
            }
            System.debug('query'+query);
            response.lstDataTableData = Database.query(query);
            system.debug('response.lstDataTableData'+response.lstDataTableData);
        }
        
        return response;
    }
    
    //Wrapper class to hold Columns with headers
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean editable {get;set;}
        @AuraEnabled
        public getCurrencyISO typeAttributes {get;set;}
        @AuraEnabled
        public SetAlignment cellAttributes  {get;set;}
        
        
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String type, String OppId, String editable){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.cellAttributes = new SetAlignment();
            if(type=='currency'){
                this.typeAttributes = new GetCurrencyISO(OppId);
            }
            if((fieldName=='Issue_Date__c') && (editable=='TRUE')){
                this.editable = TRUE;
                this.label = 'Revenue Schedule Date';
            }
            if(fieldName=='Issue_Date__c'){
                this.type= 'date-local';
            }
        }
    }
	//Setting ISO for Datatable
    public class GetCurrencyISO{
        @AuraEnabled
        public String currencyCode {get;set;}
        @AuraEnabled
        public String currencyDisplayAs {get;set;}
        
        public getCurrencyISO(String OppId){
            this.currencyCode=[SELECT CurrencyIsoCode FROM Opportunity WHERE Id =: OppId ].CurrencyIsoCode;
            this.currencyDisplayAs='code';
        }
    }
    //Setting alignment for Datatable
    public class SetAlignment{
        @AuraEnabled
        public String alignment {get;set;}
        
        public SetAlignment(){
            alignment = 'left';
        }
    }
    
    //Wrapper calss to hold response - This response is used in the lightning:datatable component
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}                
        
        public DataTableResponse(){
            lstDataTableColumns = new List<DataTableColumns>();
            lstDataTableData = new List<sObject>();
        }
    }
}