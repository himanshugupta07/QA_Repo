public class OpportunityLineItemService {

    public void generateSequence(Map<Id,OpportunityLineItem> opl){
        Set<Id> setOppIds = new Set<Id>();
        for(OpportunityLineItem o: opl.values()){
            setOppIds.add(o.opportunityId);
        }
        Map<Id, OpportunityLineItem> mapOpl = new Map<Id, OpportunityLineItem>([SELECT ID,Order_Sequence__c,OpportunityId
                                                                               	FROM OpportunityLineItem
                                                                               	WHERE OpportunityId IN: setOppIds]);
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT Id, Total_Product_Count__c 
                                                                FROM Opportunity
                                                               	WHERE Id IN: setOppIds]);
        Map<Id, OpportunityLineItem> mapOplUpdate = new Map<Id, OpportunityLineItem>();
        Map<Id, Opportunity> mapOppUpdate = new Map<Id, Opportunity>();
        
        for(OpportunityLineItem o: mapOpl.values()){
            if(o.Order_Sequence__c==null){
                if(mapOpp.get(o.OpportunityId).Total_Product_Count__c==null){
                    mapOpp.get(o.OpportunityId).Total_Product_Count__c = 0;
                }
                o.Order_Sequence__c = formatInt(Integer.valueOf(mapOpp.get(o.OpportunityId).Total_Product_Count__c + 1));
            	mapOpp.get(o.OpportunityId).Total_Product_Count__c = mapOpp.get(o.OpportunityId).Total_Product_Count__c + 1;
                mapOplUpdate.put(o.Id,o);
                mapOppUpdate.put(o.OpportunityId,mapOpp.get(o.OpportunityId));
            }
        }
        update mapOplUpdate.values();
        update mapOppUpdate.values();
    }
    
    public String formatInt(Integer i){
        String tmp = String.valueOf(i);
        switch on tmp.length(){
            when 1{
                tmp = '00' + i;
            } 
            when 2{
                tmp = '0' + i;
            }
        }
        return tmp;
    }
}