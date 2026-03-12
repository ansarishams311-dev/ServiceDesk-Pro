trigger TicketTrigger on Ticket__c (before insert, after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        TicketHandler.assignAgent(Trigger.new);
    }
}
