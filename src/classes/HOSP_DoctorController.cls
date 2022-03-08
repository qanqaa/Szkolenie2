public class HOSP_DoctorController {

    public Doctor__c doctor { get; set; }
    public String searchQuery { get; set; }
    Public Integer size { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }

    public HOSP_DoctorController() {
        doctor = new Doctor__c();
        size = 5;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5', '5'));
        paginationSizeOptions.add(new SelectOption('10', '10'));
        paginationSizeOptions.add(new SelectOption('20', '20'));
        paginationSizeOptions.add(new SelectOption('50', '50'));
        paginationSizeOptions.add(new SelectOption('100', '100'));
    }

    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                setCon = new ApexPages.StandardSetController(new List<Doctor__c>());
                setCon.setPageSize(size);
            }
            return setCon;
        }
        set;
    }

    public PageReference refreshPageSize() {
        setCon.setPageSize(size);
        return null;
    }

    public List<Doctor__c> getDoctors() {
        return (List<Doctor__c>) setCon.getRecords();
    }

    public void searchDoctors() {
        setCon = new ApexPages.StandardSetController(Database.query(createQuery()));
        setCon.setPageSize(size);

        if (setCon.getRecords().isEmpty()) {
            displayInfoMessage (Label.NoDoctorsFound);
        }
    }

    public String createQuery() {
        searchQuery = 'SELECT Name, First_Name__c, Email__c, Country__c  FROM Doctor__c';
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
            setCon = new ApexPages.StandardSetController(new List<Doctor__c>());
            doctor.Country__c = null;
        } catch (Exception e) {
            displayInfoMessage(e.getMessage());
        }
    }
}