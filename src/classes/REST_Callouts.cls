public with sharing class REST_Callouts {

    private static final String endpoint = 'callout:IIORG/apexrest/Hospital__c';
    private static final String accessTokenURL = 'https://login.salesforce.com/services/oauth2/token';
    private static String accessToken {get; set;}

    public static HttpRequest preparePostHospitalsRequest (List<REST_HospitalDTO> hospitalsDTO){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(JSON.serialize(hospitalsDTO));
        return request;
    }

    public static HttpRequest preparePatchHospitalsRequest (List<REST_HospitalDTO> hospitalsDTO){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod('PATCH');
        request.setBody(JSON.serialize(hospitalsDTO));
        return request;
    }

    public static HttpRequest prepareDeleteHospitalsRequest (List<REST_HospitalDTO> hospitalsDTO){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod('DELETE');
        request.setBody(JSON.serialize(hospitalsDTO));
        return request;
    }
}