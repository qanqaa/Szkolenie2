global class REST_RequestService {

    public static List<REST_SyncRequest> insertHospitals(String body) {
        List<REST_SyncRequest> syncRequests = new List<REST_SyncRequest>();
        System.debug('BODY:' + body);
        if (body == null || body == '') {
            syncRequests.add(new REST_SyncRequest(REST_OperationType.READ_RECORD.name(), null, 'Received empty or null request.'));
            return syncRequests;
        }
        List<REST_HospitalDTO> hospitalsDTO = (List<REST_HospitalDTO>) JSON.deserialize(body, List<REST_HospitalDTO>.class);
        System.debug('hospitalsDTO:' + hospitalsDTO);
        List<Hospital__c> hospitals = REST_ObjectMapper.mapToHospitalsFrom2Org(hospitalsDTO);
        System.debug('hospitals:' + hospitals);
        Database.SaveResult[] saveResults = Database.insert(hospitals, false);
        String[] saveResultsMsg = decodeDatabaseSaveResults(saveResults);
        for (Integer i = 0; i < saveResultsMsg.size(); i++) {
            REST_HospitalDTO hospitalDTO = new REST_HospitalDTO(hospitals.get(i));
            syncRequests.add(new REST_SyncRequest(REST_OperationType.INSERT_RECORD.name(), hospitalDTO, String.valueOf(saveResultsMsg.get(i))));
        }
        return syncRequests;
    }

    public static List<REST_HospitalDTO> readHospitalsByParameters(String hospitalName, String hospitalAddress) {
        if(hospitalName == null){
            hospitalName = '';
        }
        if(hospitalAddress == null){
            hospitalAddress = '';
        }
        hospitalName  = hospitalName.replace('%20',' ');
        hospitalAddress = hospitalAddress.replace('%20',' ');
        System.debug(createQuery(hospitalName,hospitalAddress));
        List<Hospital__c> queriedHospitals = Database.query(createQuery(hospitalName,hospitalAddress));
        List<REST_HospitalDTO> queriedHospitalsDTO = new List<REST_HospitalDTO>();
        for (Hospital__c queriedHospital : queriedHospitals) {
            queriedHospitalsDTO.add(new REST_HospitalDTO(queriedHospital));
        }
        return queriedHospitalsDTO;
    }

    public static List<REST_SyncRequest> updateHospitals(String body) {
        List<REST_SyncRequest> syncRequests = new List<REST_SyncRequest>();
        List<Hospital__c> hospitals = new List<Hospital__c>();
        try {
            List<REST_HospitalDTO> hospitalsDTO = (List<REST_HospitalDTO>) JSON.deserialize(body, List<REST_HospitalDTO>.class);
            System.debug(hospitalsDTO);
            //ZAMIENIC ID Z EXTERNAL ID

            List<Id> hospitalsId = new List<Id>();
            for (REST_HospitalDTO hospitalDTO : hospitalsDTO) {
                hospitalsId.add(hospitalDTO.externalId); // LISTA ID Z BIEZACEGO SYSTEMU
            }
            hospitals = getHospitals(hospitalsId);
            if (hospitals.isEmpty()) {
                syncRequests.add(new REST_SyncRequest(REST_OperationType.UPDATE_RECORD.name(), null, 'No records found with specified ID.'));
                return syncRequests;
            }
            Map<Id, REST_HospitalDTO> hospitalsToUpdate = new Map<Id, REST_HospitalDTO>();
            for (REST_HospitalDTO hospitalToUpdate : hospitalsDTO) {
                hospitalsToUpdate.put(hospitalToUpdate.externalId, hospitalToUpdate);
            }
            for (Hospital__c hospital : hospitals) {
                REST_HospitalDTO newHospitalData = hospitalsToUpdate.get(hospital.Id);
                hospital.Name = newHospitalData.name != null ? newHospitalData.name : hospital.Name;
                hospital.Address__c = newHospitalData.address != null ? newHospitalData.address : hospital.Address__c;
            }
            System.debug(hospitals);
            Database.SaveResult[] saveResults = Database.update(hospitals, false);
            String[] saveResultsMsg = decodeDatabaseSaveResults(saveResults);
            for (Integer i = 0; i < saveResultsMsg.size(); i++) {
                REST_HospitalDTO hospitalDTO = new REST_HospitalDTO(hospitals.get(i));
                syncRequests.add(new REST_SyncRequest(REST_OperationType.UPDATE_RECORD.name(), hospitalDTO, String.valueOf(saveResultsMsg.get(i))));
            }
            return syncRequests;
        } catch (Exception e) {
            syncRequests.add(new REST_SyncRequest(REST_OperationType.UPDATE_RECORD.name(), null, e.getMessage()));
            return syncRequests;
        }
    }

    public static List<REST_SyncRequest> deleteHospitals(String body) {
        List<REST_SyncRequest> syncRequests = new List<REST_SyncRequest>();
        System.debug('BODY: ' + body);
        try {
            List<REST_HospitalDTO> hospitalsDTOIds = (List<REST_HospitalDTO>) JSON.deserialize(body, List<REST_HospitalDTO>.class);
            System.debug('hospitalsDTOIds: ' + hospitalsDTOIds);
            List<Id> hospitalsIds = getIds(hospitalsDTOIds);
            System.debug('hospitalsIds: ' + hospitalsIds);
            List<Hospital__c> hospitals = getHospitals(hospitalsIds);
            System.debug('hospitals: ' + hospitals);
            if (hospitals.isEmpty()) {
                syncRequests.add(new REST_SyncRequest(REST_OperationType.DELETE_RECORD.name(), null, 'No records found with specified ID.'));
                return syncRequests;
            }

            Database.DeleteResult[] deleteResults = Database.delete(hospitals, false);
            String[] deleteResultsMsg = decodeDatabaseDeleteResults(deleteResults);

            for (Integer i = 0; i < deleteResultsMsg.size(); i++) {
                REST_HospitalDTO hospitalDTO = new REST_HospitalDTO(hospitals.get(i));
                syncRequests.add(new REST_SyncRequest(REST_OperationType.DELETE_RECORD.name(), hospitalDTO, String.valueOf(deleteResultsMsg.get(i))));
            }
            return syncRequests;
        } catch (Exception e) {
            syncRequests.add(new REST_SyncRequest(REST_OperationType.DELETE_RECORD.name(), null, e.getMessage()));
            return syncRequests;
        }
    }

    public static List<Id> getIds (List<REST_HospitalDTO> hospitalsDTOIds){
        List<Id> hospitalsIds = new List<Id>();
        for(REST_HospitalDTO hospitalDTO : hospitalsDTOIds){
            hospitalsIds.add(hospitalDTO.externalId);
        }
        return hospitalsIds;
    }

    public static List<Hospital__c> getHospitals(List<Id> externalHospitalsIds) {
        List<Hospital__c> hospitals = new List<Hospital__c>();
        hospitals = [SELECT Id, Name, Address__c, ExternalId__c FROM Hospital__c WHERE Id IN :externalHospitalsIds];
        return hospitals;
    }

    public static String[] decodeDatabaseDeleteResults(Database.DeleteResult[] deleteResults) {
        String[] deleteResultsMsg = new String[]{
        };
        for (Database.DeleteResult deleteResult : deleteResults) {
            if (deleteResult.isSuccess()) {
                deleteResultsMsg.add('Success');
            } else {
                String errorMsg = '';
                for (Database.Error error : deleteResult.getErrors()) {
                    errorMsg += error.getStatusCode() + ': ' + error.getMessage();
                    deleteResultsMsg.add(errorMsg);
                }
            }
        }
        return deleteResultsMsg;
    }

    public static String[] decodeDatabaseSaveResults(Database.SaveResult[] saveResults) {
        String[] saveResultsMsg = new String[]{
        };
        for (Database.SaveResult saveResult : saveResults) {
            if (saveResult.isSuccess()) {
                saveResultsMsg.add('Success');
            } else {
                String errorMsg = '';
                for (Database.Error error : saveResult.getErrors()) {
                    errorMsg += error.getStatusCode() + ': ' + error.getMessage();
                    saveResultsMsg.add(errorMsg);
                }
            }
        }
        return saveResultsMsg;
    }

    public static List<Hospital__c> searchHospitals(String query) {
        List<Hospital__c> hospitals = Database.query(query);
        return hospitals;
    }

    public static String createQuery(String hospitalName, String hospitalAddress) {
        String searchQuery = 'SELECT Id, Name, Address__c, ExternalId__c FROM Hospital__c';
        if(string.isNotEmpty(hospitalName) || string.isNotEmpty(hospitalAddress)){
            searchQuery += ' WHERE ';
        }
        if (string.isNotEmpty(hospitalName)) {
            searchQuery += 'Name LIKE \'%' + hospitalName + '%\'';
            System.debug(searchQuery);
            return searchQuery;
        }
        if(string.isNotEmpty(hospitalName) && string.isNotEmpty(hospitalAddress)){
            searchQuery += ' AND ';
        }
        if (string.isNotEmpty(hospitalAddress)) {
            return searchQuery += 'Address__c LIKE \'%' + hospitalAddress + '%\'';
        }else {
            return searchQuery;
        }
    }
}