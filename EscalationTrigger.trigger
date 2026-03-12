trigger EscalationTrigger on Ticket__c (before update) {
    if(Trigger.isUpdate && Trigger.isAfter) {
        for(Ticket__c ticket : Trigger.new) {
            Ticket__c oldTicket = Trigger.oldMap.get(ticket.Id);
            
            if(ticket.SLA_Breach__c == true && 
               oldTicket.SLA_Breach__c == false) {
                EscalationHandler.escalateTicket(
                    new List<Ticket__c>{ticket}
                );
            }
        }
    }
}
