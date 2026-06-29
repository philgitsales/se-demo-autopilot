public class DataCloudSync {
    @future(callout=true)
    public static void syncContactProfile() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v66.0/ssot/data-streams/ContactProfile/actions/run');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{}');

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Sync response: ' + res.getStatusCode() + ' ' + res.getBody());
    }
}
