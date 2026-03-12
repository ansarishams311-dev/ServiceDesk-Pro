public class EscalationHandler {
    
    public static void escalateTicket(List<Ticket__c> tickets) {
        
        // Step 1 - Find the senior agent with lowest load
        List<Agent__c> seniorAgents = [
            SELECT Id, Name, Current_Ticket_Load__c
            FROM Agent__c
            WHERE Active__c = true
            ORDER BY Current_Ticket_Load__c ASC
            LIMIT 1
        ];
        
        // Step 2 - Prepare list of tickets to update
        List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();
        
        for(Ticket__c ticket : tickets) {
            
            // Step 3 - Change priority to Critical
            ticket.Priority__c = 'Critical';
            
            // Step 4 - Change status to Escalated
            ticket.Status__c = 'Escalated';
            
            // Step 5 - Assign senior agent if exists
            if(seniorAgents.size() > 0) {
                ticket.Assigned_Agent__c = seniorAgents[0].Id;
            }
            
            ticketsToUpdate.add(ticket);
        }
        
        // Step 6 - Save all ticket updates
        if(ticketsToUpdate.size() > 0) {
            update ticketsToUpdate;
        }
        
        // Step 7 - Send email alert to manager
        sendEscalationEmail(tickets);
    }
    
    private static void sendEscalationEmail(List<Ticket__c> tickets) {
        
        List<Messaging.SingleEmailMessage> emails = 
            new List<Messaging.SingleEmailMessage>();
        
        for(Ticket__c ticket : tickets) {
            Messaging.SingleEmailMessage email = 
                new Messaging.SingleEmailMessage();
            
            email.setToAddresses(
                new List<String>{'manager@company.com'}
            );
            email.setSubject(
                'URGENT - Ticket Escalated: ' + ticket.Name
            );
            email.setPlainTextBody(
                'The following ticket has breached SLA and been escalated:\n\n' +
                'Ticket: ' + ticket.Name + '\n' +
                'Subject: ' + ticket.Subject__c + '\n' +
                'Priority: Critical\n' +
                'Status: Escalated\n\n' +
                'Please review immediately.'
            );
            
            emails.add(email);
        }
        
        if(emails.size() > 0) {
            Messaging.sendEmail(emails);
        }
    }
}
