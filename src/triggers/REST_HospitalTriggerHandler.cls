public with sharing class REST_HospitalTriggerHandler extends HOSP_TriggerHandler{
private List<Hospital__c> newList;
private List<Hospital__c> oldList;
private Map<Id, Hospital__c> newMap;
private Map<Id, Hospital__c> oldMap;

public REST_HospitalTriggerHandler() {
this.oldList = (List<Hospital__c>) Trigger.Old;
this.newList = (List<Hospital__c>) Trigger.New;
this.oldMap = (Map<Id, Hospital__c>) Trigger.oldMap;
this.newMap = (Map<Id, Hospital__c>) Trigger.newMap;
}

protected override void afterInsert() {
System.enqueueJob(new REST_CalloutExecutor(REST_OperationType.INSERT_RECORD.name(), this.newList));
}

protected override void afterUpdate() {
System.enqueueJob(new REST_CalloutExecutor(REST_OperationType.UPDATE_RECORD.name(), this.newList));
}

protected override void afterDelete() {
System.enqueueJob(new REST_CalloutExecutor(REST_OperationType.DELETE_RECORD.name(), this.oldList));
}
}