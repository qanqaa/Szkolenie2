global class REST_HospitalDTO {

    public String hospitalId;
    public String name;
    public String address;

    global REST_HospitalDTO(Hospital__c hospital) {
        this.hospitalId = hospital.Id;
        this.name = hospital.Name;
        this.address = hospital.Address__c;
    }
}