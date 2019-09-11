/**
 * @File Name          : EmbProdOliHandler_Test.cls
 * @Description        : 
 * @Author             : Himanshu Gupta
 * @Group              : 
 * @Last Modified By   : Himanshu Gupta
 * @Last Modified On   : 8/14/2019, 12:56:57 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/5/2019, 12:11:18 PM   Himanshu Gupta     Initial Version
**/
//Test Methods for EmbProdOliHandler
@isTest
public class EmbProdOliHandler_Test {
    
    //Create Test Data
    public static Opportunity createOpp() {
        //Get Record Types
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Media_Accounts').getRecordTypeId();
        Id CntrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Media_Contacts').getRecordTypeId();
        Id OpprecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('EMBOpp').getRecordTypeId();
        Id prrecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('EconProducts').getRecordTypeId();
         
        //Create Account
        Account acc =  new Account();
        acc.Name = 'Test Account'+Integer.valueof((Math.random() * 100));
        acc.RecordTypeId = AccrecordTypeId;
        acc.Client_Type__c = 'Academic';
        acc.Industry = 'Academic';
        acc.BillingStreet = 'Street, Chicago, United States';
        acc.BillingCity = 'Chicago';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = 'TW3455';
        insert acc;
        
        //Create Sales Agent
        Sales_Agent__c sa =  new Sales_Agent__c(Name='Sales Agent', Sales_Agent_Code__c='T0001');
        insert sa;
              
        //Create Product
        Product2 pr = new Product2();
        pr.IsActive = TRUE;
        pr.CanUseRevenueSchedule = TRUE;
        pr.RecordTypeId = prrecordTypeId;
        pr.Name = 'TEST Product';
        pr.ProductGroup__c = 'Media';
        pr.CurrencyIsoCode = 'USD';
        insert pr;
        
        //Adding Product to Standard Price Book
        Pricebook2 stdPb = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update stdPb;
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = pr.id,unitprice=10000.0, isActive=true);
        
        //Adding to EMB PriceBook
        List<Print_IO_Settings__mdt> getstng = [SELECT Quote_Template_Id__c,Email_Addresses__c,PriceBookID__c
                                                FROM Print_IO_Settings__mdt];
        PricebookEntry pbe = new PricebookEntry(pricebook2id = getstng[0].PriceBookID__c, product2id = pr.id,unitprice=10000.0, isActive=true);
        insert pbe;
        
        //Create REF_Product_Rate_Cards__c
        REF_Product_Rate_Cards__c prc = new REF_Product_Rate_Cards__c();
        prc.Rate__c = 10000;
        prc.End_Date__c = system.today();
        prc.Product__c = pr.Id;
       	prc.PriceBookEntryId__c = pbe.Id;
        prc.CurrencyIsoCode = 'USD';
        prc.Ad_Size__c = '1/2 Page Vertical';
        prc.Edition__c = 'AS';
        prc.Publication__c = 'The Economist Newspaper';
        insert prc;
        
        //Create Opportunity
        Opportunity o = new Opportunity();
        o.Name = 'TEST Opp'+Integer.valueof((Math.random() * 100));
        o.AccountId =  acc.Id;
        o.Type =  'New';
        o.RecordTypeId = OpprecordTypeId;
        o.Initiative__c ='Automotive' ;
        o.StageName='10% Early discussions';
        o.CloseDate = Date.today();
        o.Probability = 10;
        o.CurrencyIsoCode = 'USD';
        o.Sub__c='NA';
        o.Region__c='US';
        o.EIU_Sales_Agent__c = sa.Id;
        o.Sales_Department__c='Careers';
		o.Initiative__c = 'None';
        o.MediaBudget__c = 100;
        o.PO_Number__c = '1211';
        o.Media_Strategist__c = 'Luc Ganot';
        o.Loss_Detail__c = 'reason';
        o.Loss_Reason__c = 'Price';
        insert o;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = o.Id,
                                                         Product2Id = pr.Id,
                                                          PricebookEntryId = pbe.Id);
        oli.Quantity =1;
        oli.TotalPrice = 1000;
        insert oli;
        
        return o;
    }
    
    public static String getJSON(){
        String json = '[{\"Publication__c\":\"The Economist Newspaper\",\"Issue_Date__c\":\"2019-08-31\",'+
                        '\"Platform__c\":\"Print The Economist\",\"Edition__c\":\"AS\",\"Ad_Size__c\":\"1/2 Page Vertical\",'+
                        '\"currency__c\":\"USD 5997.6\",\"Discount_IO__c\":\"20\",\"Discount\":20,\"UnitPrice\":7497,'+
                        '\"TotalPrice\":5997.6,\"Product2Id\":\"01t14000005nUDrAAM\",\"PricebookEntryId\":\"01u1O00000gzWkKQAU\",'+
            			'\"Position__c\":\"TEXT\",\"Quantity\":1,\"Section__c\":\"TEXT\",\"Classified_Category__c\":\"TEXT\",'+
            			'\"RevSchId__c\":\"00k1700000CfB1hAAF\",\"Print_IO__c\":\"Print_IO\",'+
                        '\"Requested_Gauranted__c\":\"\",\"Color__c\":\"\"},';
        json += '{\"Publication__c\":\"The Economist Newspaper\",\"Issue_Date__c\":\"2019-08-31\",'+
                        '\"Platform__c\":\"Print The Economist\",\"Edition__c\":\"AS\",\"Ad_Size__c\":\"1/2 Page Horizontal\",'+
                        '\"currency__c\":\"USD 5997.6\",\"Discount_IO__c\":\"20\",\"Discount\":20,\"UnitPrice\":7497,'+
                        '\"TotalPrice\":5997.6,\"Product2Id\":\"01t14000005nUDrAAM\",\"PricebookEntryId\":\"01u1O00000gzWkKQAU\",'+
            			'\"Position__c\":\"TEXT\",\"Quantity\":1,\"Section__c\":\"TEXT\",\"Classified_Category__c\":\"TEXT\",'+
            			'\"RevSchId__c\":\"00k1700000CfB1hAAF\",\"Print_IO__c\":\"Print_IO\",'+
                        '\"Requested_Gauranted__c\":\"\",\"Color__c\":\"\"}]';
        return json;
    }
    
    public static String getJSON2(){
        String json = '[{\"Publication__c\":\"The Economist Newspaper\",\"Issue_Date__c\":\"2019-08-21\",'+
                        '\"Platform__c\":\"Print The Economist\",\"Edition__c\":\"AP\",\"Ad_Size__c\":\"1/2 Page Vertical\",'+
                        '\"currency__c\":\"USD 5997.6\",\"Discount_IO__c\":\"20\",\"Discount\":20,\"UnitPrice\":7497,'+
                        '\"TotalPrice\":5997.6,\"Product2Id\":\"01t14000005nUDrAAM\",\"PricebookEntryId\":\"01u1O00000gzWkKQAU\",'+
            			'\"Position__c\":\"TEXT2\",\"Quantity\":1,\"Section__c\":\"TEXT2\",\"Classified_Category__c\":\"TEXT2\",'+
            			'\"RevSchId__c\":\"00k1700000CfB1hAAF\",\"Print_IO__c\":\"Print_IO\",'+
                        '\"Requested_Gauranted__c\":\"2\",\"Color__c\":\"2\"},';
        json += '{\"Publication__c\":\"The Economist Newspaper\",\"Issue_Date__c\":\"2019-10-07\",'+
                        '\"Platform__c\":\"Print The Economist\",\"Edition__c\":\"AP\",\"Ad_Size__c\":\"1/2 Page Horizontal\",'+
                        '\"currency__c\":\"USD 5997.6\",\"Discount_IO__c\":\"30\",\"Discount\":20,\"UnitPrice\":7497,'+
                        '\"TotalPrice\":5997.6,\"Product2Id\":\"01t14000005nUDrAAM\",\"PricebookEntryId\":\"01u1O00000gzWkKQAU\",'+
            			'\"Position__c\":\"TEXT2\",\"Quantity\":1,\"Section__c\":\"TEXT2\",\"Classified_Category__c\":\"TEXT2\",'+
            			'\"RevSchId__c\":\"00k1700000CfB1hAAF\",\"Print_IO__c\":\"Print_IO\",'+
                        '\"Requested_Gauranted__c\":\"2\",\"Color__c\":\"2\"}]';
        return json;
    }
    
    public static String getJSON3(){
        String json = '[{\"Publication__c\":\"The Economist Newspaper\",\"Issue_Date__c\":\"2019-08-25\",'+
                        '\"Platform__c\":\"Display The Economist\",\"Edition__c\":\"AS\",\"Ad_Size__c\":\"1/2 Page\",'+
                        '\"currency__c\":\"USD 5997.6\",\"Discount_IO__c\":\"10\",\"Discount\":10,\"UnitPrice\":7497,'+
                        '\"TotalPrice\":5997.6,\"Product2Id\":\"01t14000005nUDrAAM\",\"PricebookEntryId\":\"01u1O00000gzWkKQAU\",'+
            			'\"Position__c\":\"TEXT\",\"Quantity\":1,\"Section__c\":\"TEXT\",\"Classified_Category__c\":\"TEXT\",'+
            			'\"RevSchId__c\":\"00k1700000CfB1hAAF\",\"Print_IO__c\":\"Print_IO\",'+
                        '\"Requested_Gauranted__c\":\"\",\"Color__c\":\"\"}]';
        return json;
    }
    
    static testMethod void testallMethods1() {
    	Opportunity opp = createOpp();
        EmbProdOliHandler.saveOli(getJSON3(),opp.Id,'USD','Yes','Careers');
        EmbProdOliHandler.createQuote(opp.Id);
        
        EmbProdOliHandler.getPrice(getJSON3(),'USD',opp.Id,'Careers');
        
        EmbProdOliHandler.saveOli(getJSON2(),opp.Id,'USD','Yes','');
        EmbProdOliHandler.createQuote(opp.Id);
    }
    
    static testMethod void testallMethods2() {
        Opportunity opp = createOpp();
        EmbProdOliHandler.saveOli(getJSON3(),opp.Id,'USD','Yes','Careers');
        EmbProdOliHandler.handleRevSchUpdateOli(opp.Id);
        EmbProdOliHandler.createQuote(opp.Id);
        
        List<OpportunityLineItem> oli = EmbProdOliHandler.getOli(opp.Id);
        List<Id> olIds = new List<Id>();
        for(OpportunitylineItem o : oli ){
            olIds.add(o.Id);
        }
        
        if(olIds.size()>1){
        	EmbProdOliHandler.delOli(olIds[0]);
        }   
    }
    
    static testMethod void testallMethods3(){
        Opportunity opp = createOpp();
        EmbProdOliHandler.saveOli(getJSON3(),opp.Id,'USD','Yes','Careers');
        EmbProdOliHandler.saveSchedule(opp.Id);
        List<OpportunityLineItem> oli = EmbProdOliHandler.getOli2(opp.Id);
        System.assert(oli != null);
        
        String delrv = EmbProdOliHandler.delRevSch(oli.get(0).Id,String.valueof(oli.get(0).RevSchId__c));
        system.assert(delrv != null);
    }
    
    static testMethod void testallMethods4(){
        Opportunity opp = createOpp();
        //Add Oli
        EmbProdOliHandler.saveOli(getJSON(),opp.Id,'USD','Yes','');
        EmbProdOliHandler.saveSchedule(opp.Id);
        List<OpportunityLineItem> oli = EmbProdOliHandler.getOli(opp.Id);
        
        string strOli = JSON.serialize(oli);
        List<String> x = strOli.split('},');
        List<String> y = new List<String>();
        string xy;
        integer i = 0;
        for(String a: x){
            if(!a.contains('attributes')){           
                String js1 = a;
                integer len = js1.length();
                if(!js1.startsWith('[{')){
                    js1 =  '[{' + js1;
                }
                
                len = js1.length();
                if(!js1.endsWith('}')){
                    js1 = js1+'}';
                }
                
                len = js1.length();
                
                if(!js1.endsWith(']')){
                    js1 = js1+']';
                }
                y.add(js1);
            }
        }
        xy = y.get(0).removeend(']') + ',' + y.get(1).removestart('[');
        EmbProdOliHandler.handleRevSchUpdates(opp.Id,xy,system.today());
        EmbProdOliHandler.updClosedateCheck(opp.Id);
    }
    static testMethod void testallMethods5() {
    	Opportunity opp = createOpp();
        //Add Oli
        EmbProdOliHandler.saveOli(getJSON(),opp.Id,'USD','Yes','');
        EmbProdOliHandler.saveSchedule(opp.Id);
        
        System.assert( EmbProdOliHandler.getGroupSale(opp.Id) != null );
        
        List<OpportunityLineItem> oli = EmbProdOliHandler.getOli(opp.Id);
        System.assert(oli != null);
        
        String curcy = EmbProdOliHandler.getCurrency(opp.Id);
        System.assert(curcy == 'USD');
        
        boolean hasOli = EmbProdOliHandler.hasOli(opp.Id);
        System.assert(hasOli == TRUE);
        
        String opName = EmbProdOliHandler.getOppName(opp.Id);
        System.assert(opName.contains('TEST'));
        
        OpportunityLineItem oli2 = EmbProdOliHandler.getPrice(getJSON(),'USD',opp.Id,'Careers');
        System.assert(oli2.unitprice != null);
        
        String dateToday = EmbProdOliHandler.getToday(31,'Jan',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Feb',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Mar',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Apr',2019);
        dateToday = EmbProdOliHandler.getToday(31,'May',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Jun',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Jul',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Aug',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Sep',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Oct',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Nov',2019);
        dateToday = EmbProdOliHandler.getToday(31,'Dec',2019);
        
        String pubDates = EmbProdOliHandler.getIssueDates('1843');
        pubDates = EmbProdOliHandler.getIssueDates('1843 Supplement');
        
        date str2Date = EmbProdOliHandler.str2Date('19 Jan 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Feb 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Mar 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Apr 2019');
        str2Date = EmbProdOliHandler.str2Date('19 May 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Jun 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Jul 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Aug 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Sep 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Oct 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Nov 2019');
        str2Date = EmbProdOliHandler.str2Date('19 Dec 2019');
        
        str2Date = EmbProdOliHandler.str2Date('2019-01-19');
        str2Date = EmbProdOliHandler.str2Date('2019-02-19');
        str2Date = EmbProdOliHandler.str2Date('2019-03-19');
        str2Date = EmbProdOliHandler.str2Date('2019-04-19');
        str2Date = EmbProdOliHandler.str2Date('2019-05-19');
        str2Date = EmbProdOliHandler.str2Date('2019-06-19');
        str2Date = EmbProdOliHandler.str2Date('2019-07-19');
        str2Date = EmbProdOliHandler.str2Date('2019-08-19');
        str2Date = EmbProdOliHandler.str2Date('2019-09-19');
        str2Date = EmbProdOliHandler.str2Date('2019-10-19');
        str2Date = EmbProdOliHandler.str2Date('2019-11-19');
        str2Date = EmbProdOliHandler.str2Date('2019-12-19');
        
        str2Date = EmbProdOliHandler.getsfDate(10,'Jan',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Feb',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Mar',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Apr',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'May',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Jun',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Jul',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Aug',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Sep',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Oct',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Nov',2019);
        str2Date = EmbProdOliHandler.getsfDate(10,'Dec',2019);
        
        //EmbProdOliHandler.createQuote(opp.Id);
        oli = EmbProdOliHandler.getAttachments(opp.Id);
        System.assert(oli != null);
        
        EmbProdOliHandler.DataTableResponse dtr = EmbProdOliHandler.getAccRecords('OpportunityLineItem','DataTableFieldSet',opp.Id,'TRUE');
        
        List<Id> olIds = new List<Id>();
        for(OpportunitylineItem o : oli ){
            olIds.add(o.Id);
        }
        
        if(olIds.size()>1){
        	EmbProdOliHandler.delOli(olIds[0]);
        }
    }
}