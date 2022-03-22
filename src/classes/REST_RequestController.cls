@RestResource(urlMapping = '/Hospital__c/*')
global class REST_RequestController {

    @HttpPost
    global static List<REST_SyncRequest> insertHospitals() {
        String body = RestContext.request.requestBody.toString();
        return REST_RequestService.insertHospitals(body);
    }

    @HttpGet
    global static List<REST_SyncRequest> readHospitalsByParameters() {
        String body = RestContext.request.requestBody.toString();
        return REST_RequestService.readHospitalsByParameters(body);
    }

    @HttpPatch
    global static List<REST_SyncRequest> updateHospitals() {
        String body = RestContext.request.requestBody.toString();
        return REST_RequestService.updateHospitals(body);
    }

    @HttpDelete
    global static List<REST_SyncRequest> deleteHospitals() {
        String body = RestContext.request.requestBody.toString();
        return REST_RequestService.deleteHospitals(body);
    }
}