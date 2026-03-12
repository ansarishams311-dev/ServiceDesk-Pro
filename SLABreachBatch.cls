global class SLABreachBatch implements Database.Batchable<sObject> {
    
    // Step 1 - Start method - decides WHAT records to process
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Subject__c, 
                   Priority__c, Status__c,
                   SLA_Breach__c, Ticket_Opened_At__c,
                   SLA_Policy__r.Resolution_Time_Hours__c
            FROM Ticket__c
            WHERE Status__c NOT IN ('Resolved', 'Closed')
            AND SLA_Breach__c = false
        ]);
    }
    
    // Step 2 - Execute method - processes each batch of records
    global void execute(Database.BatchableContext bc, 
                        List<Ticket__c> tickets) {
        
        List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();
        DateTime now = DateTime.now();
        
        for(Ticket__c ticket : tickets) {
            
            if(ticket.Ticket_Opened_At__c != null && 
               ticket.SLA_Policy__r.Resolution_Time_Hours__c != null) {
                
                // Calculate hours since ticket was opened
                Long milliseconds = now.getTime() - 
                    ticket.Ticket_Opened_At__c.getTime();
                Integer hoursOpen = (Integer)(milliseconds / 
                    (1000 * 60 * 60));
                
                // Check if resolution time exceeded
                if(hoursOpen > ticket.SLA_Policy__r
                   .Resolution_Time_Hours__c) {
                    ticket.SLA_Breach__c = true;
                    ticketsToUpdate.add(ticket);
                }
            }
        }
        
        if(ticketsToUpdate.size() > 0) {
            update ticketsToUpdate;
        }
    }
    
    // Step 3 - Finish method - runs after ALL batches complete
    global void finish(Database.BatchableContext bc) {
        System.debug('SLA Breach Batch Job Completed Successfully!');
    }
}
