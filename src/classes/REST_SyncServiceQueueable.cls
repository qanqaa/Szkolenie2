public class REST_SyncServiceQueueable implements Queueable {
    public String operationType {get; set;}
    public List<Hospital__c> hospitals { get; set; }
    public List<REST_HospitalDTO> hospitalsDTO { get; set; }

    public REST_SyncServiceQueueable(REST_OperationType operationType, List<Hospital__c> hospitals) {
        this.operationType = operationType.name();
        this.hospitals = hospitals;
        hospitalsDTO = REST_ObjectMapper.mapToHospitalsDTO(hospitals);
    }

    public void execute(QueueableContext context) {
        if (operationType == REST_OperationType.INSERT_RECORD.name()) {

        }
        else if(operationType == REST_OperationType.UPDATE_RECORD.name()){

        }
        else if(operationType == REST_OperationType.DELETE_RECORD.name()){

        }
    }
}