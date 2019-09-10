trigger OpportunityLineItemTrigger on OpportunityLineItem ( before insert, before update, before delete,
                                    after insert, after update, after delete ){
	switch on Trigger.OperationType  {
        when AFTER_INSERT {
			OpportunityLineItemService sr = new OpportunityLineItemService();
            sr.generateSequence(Trigger.newMap);
        }
    }
}