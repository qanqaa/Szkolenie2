public class REST_CalloutExecutor implements Queueable, Database.AllowsCallouts{
    public String operationType {get; set;}
    public List<Hospital__c> hospitals { get; set; }
    public Hospital__c hospital { get; set; }
    public List<REST_HospitalDTO> hospitalsDTO { get; set; }
    public REST_HospitalDTO hospitalDTO { get; set; }

    public REST_CalloutExecutor(String operationType, List<Hospital__c> hospitals) {
        this.operationType = operationType;
        this.hospitals = hospitals;
        hospitalsDTO = REST_ObjectMapper.mapToHospitalsDTO(hospitals);
        System.debug('hospitalsDTO' + hospitalsDTO);
        System.debug('operationType ' + operationType);
    }

    public void execute(QueueableContext context) {
        if (operationType == REST_OperationType.INSERT_RECORD.name()) {
            Http http = new Http();
            HttpRequest request = REST_Callouts.preparePostHospitalsRequest(hospitalsDTO);
            HttpResponse response = http.send(request);
            System.debug('response: ' + response);
            System.debug('##############RESPONSE BODY: ' + response.getBody());
            List<REST_SyncRequest> syncRequests = (List<REST_SyncRequest>) JSON.deserialize(response.getBody(),
                    List<REST_SyncRequest>.class);
            System.debug(syncRequests);

            //UPDATE REKORDU: PRZYPISANIE OTRZYMANEGO ID JAKO EXTERNAL ID
            if(syncRequests.size() > 1){
                List<Hospital__c> syncedHospitals =  REST_ObjectMapper.mapFromSyncRequestsToHospitals(syncRequests);
                System.debug(syncedHospitals);
                update syncedHospitals;
                List<Hospital__c> hospitalCheck = [
                        SELECT Id, Name, Address__c, ExternalId__c
                        FROM Hospital__c
                        WHERE Name LIKE '%dupa%'
                ];
                System.debug('HOSPITAL CHECK: ' + hospitalCheck);
            }
        }
        else if(operationType == REST_OperationType.UPDATE_RECORD.name()){
            Http http = new Http();
            HttpRequest request = REST_Callouts.preparePatchHospitalsRequest(hospitalsDTO);
            HttpResponse response = http.send(request);
            List<REST_SyncRequest> syncRequests = (List<REST_SyncRequest>) JSON.deserialize(response.getBody(),
                    List<REST_SyncRequest>.class);
        }
        else if(operationType == REST_OperationType.DELETE_RECORD.name()){
            Http http = new Http();
            HttpRequest request = REST_Callouts.prepareGetHospitalsRequest(hospitalDTO);
            HttpResponse response = http.send(request);
            List<REST_SyncRequest> syncRequests = (List<REST_SyncRequest>) JSON.deserialize(response.getBody(),
                    List<REST_SyncRequest>.class);
        }
        else{
            System.debug('COS SIE POPSULO');
        }
    }
}