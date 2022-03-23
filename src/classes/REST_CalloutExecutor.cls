public class REST_CalloutExecutor implements Queueable, Database.AllowsCallouts {
    public String operationType { get; set; }
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
            List<Hospital__c> syncedHospitals = REST_ObjectMapper.mapFromSyncRequestsToHospitals(syncRequests);
            System.debug(syncedHospitals);
            HOSP_TriggerUtilities.runTrigger = false;
            update syncedHospitals;
            List<Hospital__c> hospitalCheck = [
                    SELECT Id, Name, Address__c, ExternalId__c
                    FROM Hospital__c
                    WHERE Name LIKE '%dupa%'
            ];
            System.debug('HOSPITAL CHECK: ' + hospitalCheck);

        } else if (operationType == REST_OperationType.UPDATE_RECORD.name()) {
            Http http = new Http();
            HttpRequest request = REST_Callouts.preparePatchHospitalsRequest(hospitalsDTO);
            HttpResponse response = http.send(request);
            System.debug('UPDATE response: ' + response);
            System.debug('##############RESPONSE BODY UPDATE : ' + response.getBody());
            List<REST_SyncRequest> syncRequests = (List<REST_SyncRequest>) JSON.deserialize(response.getBody(),
                    List<REST_SyncRequest>.class);
            System.debug(syncRequests);

        } else if (operationType == REST_OperationType.DELETE_RECORD.name()) {
            Http http = new Http();
            HttpRequest request = REST_Callouts.prepareDeleteHospitalsRequest(hospitalsDTO);
            HttpResponse response = http.send(request);
            System.debug('DELETE response: ' + response);
            System.debug('##############RESPONSE BODY DELETE : ' + response.getBody());
            List<REST_SyncRequest> syncRequests = (List<REST_SyncRequest>) JSON.deserialize(response.getBody(),
                    List<REST_SyncRequest>.class);
            System.debug(syncRequests);
        } else {
            System.debug('COS SIE POPSULO');
        }
    }
}