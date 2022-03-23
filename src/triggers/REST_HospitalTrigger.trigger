trigger REST_HospitalTrigger on Hospital__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(HOSP_TriggerUtilities.runTrigger){
        new  REST_HospitalTriggerHandler().run();
        System.debug('TRIGGER HANDLER - runTrigger: ' + HOSP_TriggerUtilities.runTrigger);
    }
    System.debug('TRIGGER HANDLER - runTrigger: ' + HOSP_TriggerUtilities.runTrigger);
}