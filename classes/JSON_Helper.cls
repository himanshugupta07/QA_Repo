public class JSON_Helper {

	public String Position {get;set;} 
    public String Id {get;set;} 
	public String Issue_Date {get;set;} 
	public String Requested_Gauranted {get;set;} 
	public Integer Quantity {get;set;} 
	public String Section {get;set;} 
	public String Ad_Size {get;set;} 
	public String Publication {get;set;} 
	public Decimal UnitPrice {get;set;} 
	public String Edition {get;set;} 
	public String Platform {get;set;} 
	public String Classified_Category {get;set;} 
	public String Color {get;set;} 
	public String Product2Id {get;set;} 
    public String PricebookEntryId {get;set;} 
    public String OpportunityId {get;set;}
    public Decimal discount {get;set;}
    public String discount2 {get;set;}
    public String curncy {get;set;}
    public String RevSchId {get;set;}
    public String TotalPrice {get;set;} 
    public String Print_IO {get;set;}
    public String Combined_Audience {get;set;}
        
	public JSON_Helper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'Position__c') {
						Position = parser.getText();
					} else if (text == 'Issue_Date__c') {
						Issue_Date = parser.getText();
					} else if (text == 'Requested_Gauranted__c') {
						Requested_Gauranted = parser.getText();
					} else if (text == 'Quantity') {
						Quantity = parser.getIntegerValue();
					} else if (text == 'Section__c') {
						Section = parser.getText();
					} else if (text == 'Ad_Size__c') {
						Ad_Size = parser.getText();
					} else if (text == 'Publication__c') {
						Publication = parser.getText();
					} else if (text == 'UnitPrice') {
						UnitPrice = parser.getDecimalValue();
					} else if (text == 'Edition__c') {
						Edition = parser.getText();
					} else if (text == 'Platform__c') {
						Platform = parser.getText();
					} else if (text == 'Classified_Category__c') {
						Classified_Category = parser.getText();
					} else if (text == 'Color__c') {
						Color = parser.getText();
					} else if ((text == 'Id') && (parser.getText()!=null)){ 
						Id = parser.getText();
					} else if (text == 'Product2Id') {
						Product2Id = parser.getText();
					} else if (text == 'PricebookEntryId') {
						PricebookEntryId = parser.getText();
					} else if (text == 'OpportunityId') {
						OpportunityId = parser.getText();
					} else if (text == 'Discount') {
                        String handover = parser.getText();
						discount = decimal.valueOf(handover);
					} else if (text == 'currency__c') {
						curncy = parser.getText();
					} else if (text == 'Discount_IO__c') {
						discount2 = parser.getText();
					} else if (text == 'RevSchId__c') {
						RevSchId = parser.getText();
					} else if (text == 'TotalPrice') {
						TotalPrice = parser.getText();
					} else if (text == 'Print_IO__c') {
						Print_IO = parser.getText();
					} else if (text == 'Combined_Audience__c') {
						Combined_Audience = parser.getText();
					}
                    else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser); 
					}
				}
			}
		}
	}
	
	
	public static JSON_Helper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new JSON_Helper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
}