@RestResource(urlMapping='/v1/Contacts/*')
global with sharing class HandleContact {

    // Utility method to prepare a RestResponse object
    private static RestResponse prepareResponse(){
        RestResponse response = RestContext.response;
        if (response == null){
            response = new RestResponse();
            RestContext.response = response;
        }
        response.addHeader('Content-Type', 'application/json');
        return response;
    }

    /**
     * @description Http POST request to create a contact
     * @param lastName Last name of the contact
     * @param firstName First name of the contact
     * @param email Email of the contact
     */
    @HttpPost
    global static void createContact(String lastName, String firstName, String email) {

        RestResponse response = prepareResponse();

        try {
            // Check if a contact with the provided email already exists
            List<Contact> contactList = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

            // If a contact with the email exists, return a message
            if (contactList.size() > 0){
                Contact contact = contactList[0];

                Map<String, String> responseValuesMap = new Map<String, String>{
                    'Id' => contact.Id,
                    'Message' => 'Contact already exists, email must be unique'
                };

                response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
                response.statusCode = 400;

            // If no contact with the email exists, create a new contact
            }else{
                Contact contact = new Contact (
                    LastName = lastName,
                    FirstName = firstName,
                    Email = email
                );
                insert contact;

                // Prepare response body for successful creation
                Map<String, String> responseValuesMap = new Map<String, String>{
                    'Id' => contact.Id,
                    'Message' => 'Contact succesfully created'
                };

                response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
                response.statusCode = 201;
            }
        } catch(Exception e) {
            // Handle exceptions and return an appropriate message
            System.debug('ERROR ON CREATE: ' + e.getMessage());
            
            // Prepare response body for error on creation
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact not created, bad request'
            };
            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 400;
        }
    }

    /**
     * @description Http PATCH request to update a contact
     */
    @HttpPatch
    global static void updateContact() {

        RestResponse response = prepareResponse();

        try {
            // Retrieve the Contact from the URI
            RestRequest request = RestContext.request;
            String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            Contact contact = [SELECT Id, Email FROM Contact WHERE Id = :contactId];
            
            // Deserialize request body and update Contact fields
            Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.toString());
            
            for(String field : requestBodyMap.keySet()) {
                contact.put(field, requestBodyMap.get(field));
            }
            update contact;

            // Prepare response body for sucessful update
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Id' => contact.Id,
                'Message' => 'Contact succesfully updated'
            };

            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 200;
            
        } catch(Exception e) {
            // Handle exceptions and return an appropriate error message
            System.debug('ERROR ON UPDATE: ' + e.getMessage());

            // Prepare response body for error on update
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact not updated, bad request'
            };
            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 400;
        }
    }

    /**
     * @description Http DELETE request to deactivate a contact
     */
    @HttpDelete
    global static void deleteContact(){

        RestResponse response = prepareResponse();

        try {
            // Retrieve the Contact from the URI
            RestRequest request = RestContext.request;
            String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);

            // Deactivate the Contact
            Contact contact = [SELECT Id, Active__c FROM Contact WHERE Id = :contactId];
            contact.Active__c = false;
            update contact;

            // Prepare response body for sucessful deactivation
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact '+ contact.Id +' successfully deactivated'
            };
            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 200;

        } catch(Exception e) {
            // Handle exceptions and return an appropriate error message            
            System.debug('ERROR ON DELETE: ' + e.getMessage());

            // Prepare response body for error on deactivation
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact not deactivated, bad request'
            };
            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 400;
        }
    }
}