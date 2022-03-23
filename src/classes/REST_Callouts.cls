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
        System.debug('BODY: ' + request.getBody());
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

    public static HttpRequest prepareGetHospitalsRequest (REST_HospitalDTO hospitalDTO){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setBody(JSON.serialize(hospitalDTO));
        return request;
    }

//    public static String ReturnAccessToken()
//    {
//        String requestBody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+passwordToken;
//        Http http = new Http();
//        HttpRequest request  = new HttpRequest();
//        request.setBody(requestBody);
//        request.setMethod('POST');
//        request.setEndpoint(accessTokenURL);
//        HttpResponse response = http.send(request);
//        DeserializeResponse tokenResponse = (deserializeResponse)JSON.deserialize(response.getBody(), deserializeResponse.class);
//        return tokenResponse.access_token;
//    }
//
//    public class DeserializeResponse
//    {
//        public String id;
//        public String access_token;
//    }
}