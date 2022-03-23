public with sharing class REST_HospitalSearcherController {
    public Hospital__c hospital { get; set; }
    public String searchQuery { get; set; }
    public Integer size { get; set; }
    public List<Hospital__c> hospitals { get; set; }
    public List<REST_HospitalTableWrapper> hospitalsTableWrapper { get; set; }
    public Hospital__c newHospital { get; set; }
    public Hospital__c updateHospital { get; set; }
    public Hospital__c deleteHospital { get; set; }
    public String hospitalToUpdate { get; set; }
    public String hospitalToDelete { get; set; }
    public Boolean shouldCloseAddHospitalModal {get; set;}
    public Boolean shouldCloseUpdateHospitalModal {get; set;}
    public REST_HospitalDTO hospitalDTO { get; set; }

    public REST_HospitalSearcherController() {
        this.hospital = new Hospital__c();
        this.newHospital = new Hospital__c();
        this.updateHospital = new Hospital__c();
        this.deleteHospital = new Hospital__c();
        this.shouldCloseAddHospitalModal = false;
        this.shouldCloseUpdateHospitalModal = false;
    }

    public void saveHospital() {
        Hospital__c hospitalToSave = new Hospital__c(
                Name = newHospital.Name,
                Address__c = newHospital.Address__c
        );
        Database.SaveResult saveResult = Database.insert(hospitalToSave);
        if(saveResult.isSuccess()){
            shouldCloseAddHospitalModal = true;
        }
        else{
            for(Database.Error err : saveResult.getErrors()) {
                displayInfoMessage(err.getStatusCode() + ': ' + err.getMessage());
            }
        }
    }

    public void searchHospitals() {
        try {
            List<Hospital__c> hospitalsFromOrg = Database.query(createQuery());
            HttpRequest req = new HttpRequest();
            String query= createQuery();
            System.debug(query);
            req.setEndpoint('callout:IIORG/apexrest/Hospital__c?name='+ hospital.Name +'&address='+hospital.Address__c);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse resp = http.send(req);
            system.debug('Body:'+resp.getBody());

            List<REST_HospitalDTO> hospitalsDTOFrom2ndOrg = (List<REST_HospitalDTO>) JSON.deserialize(resp.getBody(),
                    List<REST_HospitalDTO>.class);
            System.debug('hospitalsDTOFrom2ndOrg: ' + hospitalsDTOFrom2ndOrg);
            List<Hospital__c> hospitalsFrom2ndOrg = new List<Hospital__c>();
            for (REST_HospitalDTO hospitalDTOFrom2ndOrg : hospitalsDTOFrom2ndOrg) {
                Hospital__c hospitalFrom2ndOrg = new Hospital__c(
                        Id = hospitalDTOFrom2ndOrg.externalId,
                        Name = hospitalDTOFrom2ndOrg.name,
                        Address__c = hospitalDTOFrom2ndOrg.address,
                        ExternalId__c = hospitalDTOFrom2ndOrg.hospitalId);
                hospitalsFrom2ndOrg.add(hospitalFrom2ndOrg);

            }
            System.debug('hospitalsFrom2ndOrg: ' + hospitalsFrom2ndOrg);

            List<Hospital__c> finalHospitals = new List<Hospital__c>();
            finalHospitals.addAll(hospitalsFromOrg);
            System.debug('FINAL HOSPITALS: ' + finalHospitals);

            for (Hospital__c hospitalFrom2ndOrg : hospitalsFrom2ndOrg) {
                finalHospitals.contains(hospitalFrom2ndOrg);
                if(!finalHospitals.contains(hospitalFrom2ndOrg)){
                    finalHospitals.add(hospitalFrom2ndOrg);
                }
                else{
                    System.debug('ZAWIERA WIEC NIE DODAJE DO LISTY');
                }
            }

            hospitals = finalHospitals;

            //WRAP BY MIEC CHECKBOXY
            hospitalsTableWrapper = new List<REST_HospitalTableWrapper>();
            for(Hospital__c finalHospital : finalHospitals){
                REST_HospitalTableWrapper hospitalTableWrapper = new REST_HospitalTableWrapper(finalHospital);
                System.debug(hospitalTableWrapper);
                hospitalsTableWrapper.add(hospitalTableWrapper);
            }
            System.debug('>>>>>>>>>>>' + hospitalsTableWrapper);


//            List<Hospital__c> hospitals = (List<Hospital__c>) JSON.deserialize(resp.getBody(),
//                    List<Hospital__c>.class);
//            System.debug(hospitals);

//            HttpRequest req = new HttpRequest();
//            String query= createQuery();
//            System.debug(query);
//            req.setEndpoint('callout:IIORG/data/v54.0/query?q='+ query);
//            req.setMethod('GET');
//            Http http = new Http();
//            HTTPResponse resp = http.send(req);
//            system.debug('Body:'+resp.getBody());
//            List<Hospital__c> hospitals = (List<Hospital__c>) JSON.deserialize(resp.getBody(),
//                    List<Hospital__c>.class);
//            System.debug(hospitals);
        } catch (Exception e) {
            clearResults();
            //displayInfoMessage(Label.NoHospitalsFound);
        }


    }

    public void readHospitalRecord() {
        shouldCloseUpdateHospitalModal = false;
        for (Hospital__c hospitalFromList : hospitals) {
            if (hospitalFromList.Id == hospitalToUpdate) {
                updateHospital = hospitalFromList;
            }
        }
    }

    public void updateHospitals() {
        Database.SaveResult saveResult = Database.update(updateHospital);
        if(saveResult.isSuccess()){
            shouldCloseUpdateHospitalModal = true;
        }
        else{
            for(Database.Error err : saveResult.getErrors()) {
                displayInfoMessage(err.getStatusCode() + ': ' + err.getMessage());
            }
        }
    }

    public void deleteHospital() {
        for (Hospital__c hospitalFromList : hospitals) {
            if (hospitalFromList.Id == hospitalToDelete) {
                deleteHospital = hospitalFromList;
            }
        }
        Database.DeleteResult deleteResult = Database.delete(deleteHospital);
    }

    public String createQuery() {
        searchQuery = 'SELECT Id, Name, Address__c, ExternalId__c FROM Hospital__c';
        if (string.isNotBlank(hospital.Name)) {
            searchQuery += ' WHERE Name LIKE \'%' + hospital.Name + '%\'';
            if (string.isNotBlank(hospital.Address__c)) {
                return searchQuery += ' AND Address__c LIKE \'%' + hospital.Address__c + '%\'';
            }
            System.debug(searchQuery);
            return searchQuery;
        } else {
            return null;
        }
    }

//    public String createQuery() {
//        searchQuery = 'SELECT+Id,+Name,+Address__c,+ExternalId__c+FROM+Hospital__c';
//        if (string.isNotBlank(hospital.Name)) {
//            searchQuery += '+WHERE+Name+LIKE+\'%25' + hospital.Name + '%25\'';
//            if (string.isNotBlank(hospital.Address__c)) {
//                return searchQuery += '+AND+Address__c+LIKE+\'%25' + hospital.Address__c + '%25\'';
//            }
//            System.debug(searchQuery);
//            return searchQuery;
//        } else {
//            return null;
//        }
//    }

    public void displayInfoMessage(String message) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message));
    }

    public void clearResults() {
        try {
            if(hospital != null){
                hospital.clear();
            }
            if(hospitalsTableWrapper != null){
                hospitalsTableWrapper.clear();
                hospitalsTableWrapper = null;
            }
        } catch (Exception e) {
            displayInfoMessage(e.getMessage());
        }
    }

    public void clearHospital() {
        try {
            newHospital.clear();
            shouldCloseAddHospitalModal = false;
        } catch (Exception e) {
            displayInfoMessage(e.getMessage());
        }
    }

}

