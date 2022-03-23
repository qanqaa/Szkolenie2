global class REST_RequestService {

    public static List<REST_SyncRequest> insertHospitals(String body) {
        List<REST_SyncRequest> syncRequests = new List<REST_SyncRequest>();
        if (body == null || body == '') {
            syncRequests.add(new REST_SyncRequest(REST_OperationType.READ_RECORD.name(), null, 'Received empty or null request.'));
            return syncRequests;
        }
        List<REST_HospitalDTO> hospitalsDTO = (List<REST_HospitalDTO>) JSON.deserialize(body, List<REST_HospitalDTO>.class);
        List<Hospital__c> hospitals = REST_ObjectMapper.mapToHospitals(hospitalsDTO);

        Database.SaveResult[] saveResults = Database.insert(hospitals, false);
        String[] saveResultsMsg = decodeDatabaseSaveResults(saveResults);

        for (Integer i = 0; i < saveResultsMsg.size(); i++) {
            REST_HospitalDTO hospitalDTO = new REST_HospitalDTO(hospitals.get(i));
            syncRequests.add(new REST_SyncRequest(REST_OperationType.INSERT_RECORD.name(), hospitalDTO, String.valueOf(saveResultsMsg.get(i))));
        }
        return syncRequests;
    }

    public static List<REST_SyncRequest> readHospitalsByParameters(String body) {
        List<REST_SyncRequest> syncRequests = new List<REST_SyncRequest>();
        if (body == null || body == '') {
            syncRequests.add(new REST_SyncRequest(REST_OperationType.READ_RECORD.name(), null, 'Received empty or null request.'));
            return syncRequests;
        }
        REST_HospitalDTO hospitalParameters = (REST_HospitalDTO) JSON.deserialize(body, REST_HospitalDTO.class);
        List<Hospital__c> hospitals = searchHospitals(createQuery(hospitalParameters));
        if (hospitals.isEmpty()) {
            syncRequests.add(new REST_SyncRequest(REST_OperationType.READ_RECORD.name(), null, 'No records found with specified criteria.'));
            return syncRequests;
        }
        for (Hospital__c hospital : hospitals) {
            REST_HospitalDTO hospitalDTO = new REST_HospitalDTO(hospital);
            syncRequests.add(new REST_SyncRequest(REST_OperationType.READ_RECORD.name(), hospitalDTO, 'Success'));
        }
        return syncRequests;
    }

    public static List<REST_SyncRequest> updateHospitals(String body) {
        List<REST_SyncRequest> syncRequests = new List<REST_SyncRequest>();
        List<Hospital__c> hospitals = new List<Hospital__c>();
        try {
            List<REST_HospitalDTO> hospitalsDTO = (List<REST_HospitalDTO>) JSON.deserialize(body, List<REST_HospitalDTO>.class);
            List<Id> hospitalsId = new List<Id>();
            for (REST_HospitalDTO hospitalDTO : hospitalsDTO) {
                hospitalsId.add(hospitalDTO.hospitalId);
            }
            hospitals = getHospitals(hospitalsId);
            if (hospitals.isEmpty()) {
                syncRequests.add(new REST_SyncRequest(REST_OperationType.UPDATE_RECORD.name(), null, 'No records found with specified ID.'));
                return syncRequests;
            }
            Map<Id, REST_HospitalDTO> hospitalsToUpdate = new Map<Id, REST_HospitalDTO>();
            for (REST_HospitalDTO hospitalToUpdate : hospitalsDTO) {
                hospitalsToUpdate.put(hospitalToUpdate.hospitalId, hospitalToUpdate);
            }
            for (Hospital__c hospital : hospitals) {
                REST_HospitalDTO newHospitalData = hospitalsToUpdate.get(hospital.Id);
                hospital.Name = newHospitalData.name != null ? newHospitalData.name : hospital.Name;
                hospital.Address__c = newHospitalData.address != null ? newHospitalData.address : hospital.Address__c;
            }
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
        try {
            List<REST_HospitalDTO> hospitalsDTOIds = (List<REST_HospitalDTO>) JSON.deserialize(body, List<REST_HospitalDTO>.class);

            List<Id> hospitalsIds = getIds(hospitalsDTOIds);
            List<Hospital__c> hospitals = getHospitals(hospitalsIds);
            if (hospitals.isEmpty()) {
                syncRequests.add(new REST_SyncRequest(REST_OperationType.UPDATE_RECORD.name(), null, 'No records found with specified ID.'));
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
            hospitalsIds.add(hospitalDTO.hospitalId);
        }
        return hospitalsIds;
    }

    public static List<Hospital__c> getHospitals(List<Id> externalHospitalsIds) {
        List<Hospital__c> hospitals = new List<Hospital__c>();
        hospitals = [SELECT Id, Name, Address__c FROM Hospital__c WHERE Id IN :externalHospitalsIds];
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

    public static String createQuery(REST_HospitalDTO hospitalParameters) {
        String searchQuery = 'SELECT Id, Name, Address__c, ExternalId__c FROM Hospital__c';
        if (string.isNotBlank(hospitalParameters.name)) {
            searchQuery += ' WHERE Name LIKE \'%' + hospitalParameters.name + '%\'';
            if (string.isNotBlank(hospitalParameters.address)) {
                return searchQuery += ' AND Address__c LIKE \'%' + hospitalParameters.address + '%\'';
            }
            System.debug(searchQuery);
            return searchQuery;
        } else {
            return null;
        }
    }
}