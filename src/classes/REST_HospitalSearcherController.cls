public with sharing class REST_HospitalSearcherController {
    public Hospital__c hospital { get; set; }
    public String searchQuery { get; set; }
    public Integer size { get; set; }
    public List<Hospital__c> hospitals { get; set; }
    public String hospitalIdToDelete { get; set; }
    public Hospital__c newHospital { get; set; }
    public Hospital__c updateHospital { get; set; }
    public String hospitalToUpdate { get; set; }
    public Boolean shouldCloseAddHospitalModal {get; set;}
    public Boolean shouldCloseUpdateHospitalModal {get; set;}
    public REST_HospitalDTO hospitalDTO { get; set; }

    public REST_HospitalSearcherController() {
        this.hospital = new Hospital__c();
        this.newHospital = new Hospital__c();
        this.updateHospital = new Hospital__c();
        this.shouldCloseAddHospitalModal = false;
        this.shouldCloseUpdateHospitalModal = false;
    }

    public void saveHospital() {
    }

    public void searchHospitals() {
        try {
            Http http = new Http();
            hospitalDTO = new REST_HospitalDTO(hospital);
            HttpRequest request = REST_Callouts.prepareGetHospitalsRequest(hospitalDTO);
            System.debug(request.getBody());
            HttpResponse response = http.send(request);
            System.debug(response);
            List<REST_SyncRequest> syncRequests = (List<REST_SyncRequest>) JSON.deserialize(response.getBody(),
                    List<REST_SyncRequest>.class);
        } catch (Exception e) {
            clearResults();
            //displayInfoMessage(Label.NoHospitalsFound);
        }


    }

    public void readHospitalRecord() {
        shouldCloseUpdateHospitalModal = false;
        for (Hospital__c hospitalFromList : hospitals) {
            if (hospitalFromList.ExternalId__c == hospitalToUpdate) {
                updateHospital = hospitalFromList;
            }
        }
    }

    public void updateHospitals() {
    }

    public void deleteHospital() {
    }


    public void displayInfoMessage(String message) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message));
    }

    public void clearResults() {
        try {
            if(hospital != null){
                hospital.clear();
            }
            if(hospitals != null){
                hospitals.clear();
                hospitals = null;
            }
        } catch (Exception e) {
            displayInfoMessage(e.getMessage());
        }
    }

    public void clearHospital() {
        try {
            shouldCloseAddHospitalModal = false;
            newHospital.clear();
        } catch (Exception e) {
            displayInfoMessage(e.getMessage());
        }
    }
}