@isTest
                        
global class MockHttpResponseGenerate implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      
  

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"jcTZV6qVLzUsMfuQI27CUXbsgAkKkZnK2pGjqt6eQtHbTLdtR4hA7_zR8bPwMTugRoDAIIGmLHjKP76_xf2FCYDPwqWKBcDCKSugHcSfXT0MvcLGdauQi0iyn_e6xtEI58vIl7cKb_GM6X53ouE8NxKtYBgGDimwU8qAS9_FGTc70X2LGm5KJPUKMHWsukOp3uQ-x3qePixLF0GwSBrp4hHPs_hizxTBsKejJqH0ijEnWn7AivipY9UEWHS5iJ1k_UfLpVib83FikG-Uvq5Ejg5WqPxijGTyrrmUWvpS-ODzAWI53pENe9XxPUWhzt1pIYxz9P_ETKVydf0EAVScL7ejwYo3_DldjVRA7QbcxV9I483PdUxF9pA7Og1No9bh_ubQGIBHeOrPrFOhdgKZLMX4_Rn5hkTXqqY4kKKcfcuHQ-DRsBVrgBwwlC0zhsyhzY2sQIGZOjVpMxpNwvk5pjy8zI6pbKYz6BAlLKGUkot0eyVkmgCRM5jwdC9fxxqg","token_type":"bearer","expires_in":86400,"userName":"pritam.shekhawat@hytechpro.com",".issued":"Sun, 28 Jun 2015 11:40:31 GMT",".expires":"Mon, 29 Jun 2015 11:40:31 GMT"}');
        res.setStatusCode(200);

        return res;

    }

}