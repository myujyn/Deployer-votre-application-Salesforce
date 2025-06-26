@isTest
public with sharing class TestHandleContact {

    static final string REQUEST_URI = '/services/apexrest/v1/Contacts/';

    @TestSetup
    static void makeData(){

        Contact testContact = new Contact(
            LastName = 'Goodspeed',
            FirstName = 'Stanley',
            Email = 'stanley.goodspeed@test.com'
        );
        insert testContact;
    }

    @isTest
    static void testCreateNewContact(){

        Contact testNewContact = new Contact(
            LastName = 'Smith',
            FirstName = 'John',
            Email = 'john.smith@test.com'
        );

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testNewContact));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        HandleContact.createContact(testNewContact.LastName, testNewContact.FirstName, testNewContact.Email);
        Test.stopTest();

        System.debug(res.responseBody.toString());
        Map<String, Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.debug((String)responseBody.get('Id'));

        Assert.areEqual(201, res.statusCode);
        Assert.areNotEqual(null, (String)responseBody.get('Id'));
    }

    @isTest
    static void testCreateExistingContact(){

        Contact testExistingContact = new Contact(
            LastName = 'Goodspeed',
            FirstName = 'Stanley',
            Email = 'stanley.goodspeed@test.com'
        );

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testExistingContact));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        HandleContact.createContact(testExistingContact.LastName, testExistingContact.FirstName, testExistingContact.Email);
        Test.stopTest();

        Map<String,Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());

        Assert.areNotEqual(null, (String)responseBody.get('Id'));
        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testCreateContactFailed(){

        // Mocking the request with invalid data
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty('testFail'));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        HandleContact.createContact('failLastName', 'failFirstName', 'failEmail');
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testUpdateContact(){

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'stanley.goodspeed@test.com' LIMIT 1];

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "updated.stanleygoodspeed@test.com"}');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        HandleContact.updateContact();
        Test.stopTest();

        Contact updatedContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'updated.stanleygoodspeed@test.com' LIMIT 1];
        Map<String,Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());

        Assert.areEqual(updatedContact.Id, (String)responseBody.get('Id'));
        Assert.areEqual(200, res.statusCode);
        Assert.areNotEqual('stanley.goodspeed@test.com', updatedContact.Email);
    }

    @isTest
    static void testUpdateContactFailed(){

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'stanley.goodspeed@test.com' LIMIT 1];

        // Mocking the request with invalid data
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "invalidEmail"}');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        HandleContact.updateContact();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testDeleteContact(){

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'stanley.goodspeed@test.com' LIMIT 1];

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        HandleContact.deleteContact();
        Test.stopTest();

        Contact deactivatedContact = [SELECT Id, LastName, FirstName, Email, Active__c FROM Contact WHERE Email = 'stanley.goodspeed@test.com' LIMIT 1];

        Assert.areEqual(false, deactivatedContact.Active__c);
        Assert.areEqual(200, res.statusCode);
    }

    @isTest
    static void testDeleteContactFailed(){

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + 'invalidId';
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        HandleContact.deleteContact();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testDeleteContactNull(){

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + 'invalidId';
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Mocking the response as null
        RestContext.response = null;

        Test.startTest();
        HandleContact.deleteContact();
        Test.stopTest();
    }

}