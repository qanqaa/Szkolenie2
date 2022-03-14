public with sharing class HOSP_SoapEditDoctorController {
    ApexPages.StandardController controller { get; set; }
    Doctor__c doctor {get; set;}

    public HOSP_SoapEditDoctorController(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public PageReference saveNew(){
        SObject recentDoctor = controller.getRecord();
        upsert recentDoctor;
        return new PageReference('/' + ('' + recentDoctor.get('Id')).subString(0, 3) + '/e?');
    }

    public PageReference saveDoctor(){
        SObject recentDoctor = controller.getRecord();
        Doctor__c doctor = (Doctor__c)recentDoctor;
        HOSP_SOAPCommunicator communicator = new HOSP_SOAPCommunicator();
        communicator.addNewDoctor(doctor);
        return null;
    }
}