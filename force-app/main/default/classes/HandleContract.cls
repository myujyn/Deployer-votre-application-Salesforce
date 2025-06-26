@RestResource(urlMapping='/v1/Contracts/*')
global with sharing class HandleContract {

    // Utility method to create a RestResponse object
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
     * @description Http POST request to create a contract
     * @param accountId Id of the account associated with the contract
     * @param status Status of the contract
     * @param startDate Start date of the contract
     * @param contractTerm Term of the contract in months
     */
    @HttpPost
    global static void createContract(String accountId, String status, Date startDate, Integer contractTerm){

        RestResponse response = prepareResponse();

        try{
            // Validate input parameters
            if (String.isBlank(accountId) || String.isBlank(status) || startDate == null || contractTerm == null){
                throw new IllegalArgumentException('Missing required fields');
            }

            // Create new Contract and insert into database
            Contract newContract = New Contract(
                AccountId = accountId,
                Status = status,
                StartDate = startDate,
                ContractTerm = contractTerm
            );
            insert newContract;

            // Prepare response body for successful creation
            Map<String,String> responseValuesMap = new Map<String,String>{
                'Id' => newContract.Id,
                'Message' => 'Contract successfully created'
            };

            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 201;

        } catch (Exception e){
            // Handle exceptions and return an appropriate message
            System.debug('ERROR ON CREATE: ' + e.getMessage());

            // Prepare response body for error on creation
            Map<String,String> responseValuesMap = new Map<String,String>{
                'Message' => 'Contract not created, bad request'
            };
            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 400;
        }
    }

    /**
     * @description Http PATCH request to update a contract
     */
    @HttpPatch
    global static void updateContract(){

        RestResponse response = prepareResponse();

        try{
            // Retrieve the Contract from the URI
            RestRequest request = RestContext.request;
            String contractId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
            Contract contract =[SELECT Id FROM Contract WHERE Id =:contractId];

            // Deserialize request body and update Contract fields
            Map<String,Object> requestBodyMap = (Map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());

            for(String field : requestBodyMap.keySet()){
                contract.put(field, requestBodyMap.get(field));
            }
            update contract;

            // Prepare response body for sucessful update
            Map<String,String> responseValuesMap = new Map<String,String>{
                'Id' => contract.Id,
                'Message' => 'Contract successfully updated'
            };

            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 200;

        } catch (Exception e){
            // Handle exceptions and return an appropriate error message
            System.debug('ERROR ON UPDATE: ' + e.getMessage());

            // Prepare response body for error on update
            Map<String,String> responseValuesMap = new Map<String,String>{
                'Message' => 'Contract not updated, bad request'
            };
            response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            response.statusCode = 400;
        }
    }
}