# Get Started with Ingestion API | Data 360 Ingestion API Reference | Data 360 Integration Guide | Salesforce Developers

> Source: https://developer.salesforce.com/docs/data/data-cloud-int/references/data-cloud-ingestionapi-ref/c360-a-api-get-started.html

Get Started with Ingestion API

Before using Ingestion API in Data 360, complete the prerequisites, set up authentication, and know the limits that apply to bulk ingestion and streaming ingestion.

Setup Ingestion API connector to define the endpoints and payload to ingest data.
Create an Ingestion API data stream to configure ingestion jobs and expose the API for external consumption.
Contact your admin to configure endpoint details.

Set up a connected app to authenticate and request access to Data 360 Ingestion API. The connected app enables standard OAuth protocols for authentication and authorization. Follow the instructions in Salesforce Help Create a Connected App, and configure the app as needed. In your connected app, make sure Enable OAuth Settings and necessary OAuth scopes are selected. The possible scopes are:

Access and manage your Data 360 Ingestion API data (cdp_ingest_api).
Access and manage your data (api).
Perform requests on your behalf at any time (refresh_token, offline_access).

Your orgs must be provisioned with Data Cloud licenses and the users must be assigned to appropriate roles for having full access to objects in the Data Cloud. Refer to User Roles and Permission Sets in Data Cloud before setting up the Connected App.

Acquire a Salesforce Access Token

Send a request for acquiring the Salesforce access token. Here’s how a sample request is going to look like.

Refer to OAuth 2.0 JWT Bearer Flow for Server-to-Server Integration for creating a JWT assertion.

Response Format

This example shows a response from Salesforce.

Exchanging Salesforce Access Token for Data 360 Access Token

Now that you’ve acquired the Salesforce access token, use it to get the Data 360 access token to invoke the Ingestion API.

This example shows a request for Data 360 access token. From the response received while acquiring the Salesforce access token, use the instance_url for POST and use the access_token for the subject_token.

This example shows a sample response.

The instance url in the response is the tenant specific endpoint in the Data 360 ingestion api connector detail page. You can control the JWT “expires_in” time by setting the timeout value for the connected app. See Manage Session Policies for a Connected App.

Item Description
API usage limits After each request, your app must check the response code. The HTTP 429 Too Many Requestsstatus code indicates the app must reduce its request frequency.
Bulk Job Retention Time Any open bulk jobs with the status of Open or Upload Complete that are older than 7 days, are deleted from the ingestion queue.
Maximum Number of Files per Job You can upload one file at a time per bulk job. A job can have a maximum of 100 files.
Maximum Payload size CSV files uploaded via Bulk API have a maximum size of 150 MB.
Number of Requests or Jobs Allowed per Hour 20
Number of Concurrent Requests or Jobs Allowed at One Time 5
Item Description
API usage limits After each request, your app must check the response code. The HTTP 429 Too Many Requests status code indicates the app must reduce its request frequency.
Expected Latency Data is processed asynchronously approximately every 3 minutes.
Maximum Payload Size Per Request JSON data uploaded via Streaming API have a maximum body size of 200 KB per request
Maximum Number of Records that can be Deleted You can delete a maximum of 200 records via Streaming API.
Total Number of Requests per Second Across All Ingestion API Object Endpoints 250 requests

Ingestion API uses eventual consistency. After bulk or streaming data is ingested, allow a minimum of 30 seconds for internal caches to refresh before the data becomes available to query in Data 360.

HTTP Response Code Description
200 OK Request succeeded.
201 Created Indicates that the resource was successfully created.
202 Accepted The request was accepted and the data will be processed asynchronously.
204 No Content Job was successfully deleted.
400 Bad Request Server can’t process the request due to client error. Possible causes are a malformed request syntax or invalid request body.
401 Unauthorized Authentication failed because the JWT is invalid or expired. Refresh the token.
404 Not Found Client error: the requested resource doesn’t exist.
409 Conflict Client error: unable to update the job state given its status.
429 Conflict The user has sent too many requests in a given amount of time. Implement a back-off policy to reduce the number of requests.
500 Internal Server Error Internal server error. Retry the request.
For streaming: Small payloads (up to 200 KB per single request)
For bulk: Large CSVs up to 150 MB

For guidance on overall limitations view Data 360 Limits and Guidelines.

Streaming Ingestion Walkthrough

Use this walkthrough to understand the steps for loading records using streaming ingestion.

Bulk Ingestion Walkthrough

This walkthrough guides you through the steps for loading records using bulk ingestion.

See Also

Data Cloud Developer Guide: Quick Start