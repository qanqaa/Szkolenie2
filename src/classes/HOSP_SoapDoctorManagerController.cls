public with sharing class HOSP_SoapDoctorManagerController {

    public Doctor__c doctor { get; set; }
    public String searchQuery { get; set; }
    public Integer size { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }
    public String FileBodyString { get; set; }
    public List<Doctor__c> allDoctors { get; set; }
    private final String recordDelimiter = ',';
    private final String lineDelimiter = '\n';
    public List<Doctor__c> doctors { get; set; }
    public boolean displayPopup {get;set;}
    public Id doctorIdToDelete {get; set;}

    public HOSP_SoapDoctorManagerController(){
        this.doctor = new Doctor__c();
    }

    public void searchDoctors() {
        HOSP_SOAPCommunicator communicator = new HOSP_SOAPCommunicator();
        try{
            this.allDoctors = communicator.searchDoctors(createQuery());
            System.debug(allDoctors);
        }
        catch(Exception e){
            displayInfoMessage (Label.NoDoctorsFound);
        }
    }

    public void deleteDoctor(){
        HOSP_SOAPCommunicator communicator = new HOSP_SOAPCommunicator();
        System.debug(doctorIdToDelete);
        communicator.deleteDoctor(doctorIdToDelete);
        searchDoctors();
    }

    public List<Doctor__c> getDoctors() {
        return allDoctors;
    }

    public String createQuery() {
        searchQuery = 'SELECT Id, Name, First_Name__c, Email__c, Country__c, Specialty__c, Licence_Number__c, Phone__c FROM Doctor__c';
        if (string.isNotBlank(doctor.Country__c)) {
            searchQuery += ' WHERE Country__c LIKE \'%' + doctor.Country__c + '%\'';
            if (string.isNotBlank(doctor.First_Name__c)) {
                return searchQuery += ' AND First_Name__c LIKE \'%' + doctor.First_Name__c + '%\'';
            }
            if (string.isNotBlank(doctor.Name)) {
                return searchQuery += ' AND Name LIKE \'%' + doctor.Name + '%\'';
            }
            if (string.isNotBlank(doctor.Email__c)) {
                return searchQuery += ' AND Email__c LIKE \'%' + doctor.Email__c + '%\'';
            }
            return searchQuery;
        } else {
            return null;
        }
    }

    public void displayInfoMessage(String message) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message));
    }

    public void clearResults() {
        try {
            allDoctors.clear();
            doctor.clear();
            doctor.Country__c = null;
        } catch (Exception e) {
            displayInfoMessage(e.getMessage());
        }
    }

    public void closePopup()
    {
        displayPopup = false;
    }
    public void showPopup()
    {
        displayPopup = true;
    }

}