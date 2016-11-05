trigger TaskActions on Task (before delete) {

TaskController.handleBeforeDelete( Trigger.old);

}