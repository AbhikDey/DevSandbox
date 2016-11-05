trigger OpportunityActions on Opportunity (before insert, before update, after insert, after update) {
    
    if( trigger.isBefore ) {
        
        if( trigger.isInsert ) {
            OpportunityController.handleBeforeInsert( trigger.new );
        }
        if ( trigger.isUpdate) {
            OpportunityController.handleBeforeInsert( trigger.new );
        }
        
    } else if( trigger.isAfter ) {
        // Do nothing for now.
    }

}