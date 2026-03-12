public class TicketHandler {
    
    public static void assignAgent(List<Ticket__c> newTickets) {
        
        // Step 1 - Find the agent with the lowest ticket load
        List<Agent__c> agents = [
            SELECT Id, Name, Current_Ticket_Load__c 
            FROM Agent__c 
            WHERE Active__c = true 
            ORDER BY Current_Ticket_Load__c ASC 
            LIMIT 1
        ];
        
        // Step 2 - If an agent exists, assign them to the ticket
        if(agents.size() > 0) {
            Agent__c assignedAgent = agents[0];
            
            for(Ticket__c ticket : newTickets) {
                ticket.Assigned_Agent__c = assignedAgent.Id;
            }
            
            // Step 3 - Increase that agent's ticket load by 1
            assignedAgent.Current_Ticket_Load__c += 1;
            update assignedAgent;
        }
    }
}
