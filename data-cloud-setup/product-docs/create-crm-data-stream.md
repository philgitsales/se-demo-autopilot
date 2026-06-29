# Create a Salesforce CRM Data Stream | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_create_crm_data_stream.htm&type=5

DATA 360
Create a Salesforce CRM Data Stream

Create a data stream to begin the flow of data from a Salesforce CRM data source to Data 360 for processing and unification.

REQUIRED EDITIONS
Available in: All Editions supported by Data 360. See Data 360 edition availability.
USER PERMISSIONS NEEDED
To create a data stream

Permission set:

Data 360 Architect

Considerations

If the objects selected for the data stream support change events, Data 360 adds the selections to a Change Data Capture standard channel named DataCloudEntities. Make sure that you don't modify the selections for this standard channel in Metadata API or Tooling API. Updating the channel selections using the API can result in unexpected synchronizations of Salesforce objects that weren't intended by the Data 360 administrator. For more information, see Change Data Capture.
The Event object fields: Attendees, Email, and Phone aren’t supported because the value for these fields is retrieved from other objects.
You can't ingest metadata from CRM when creating a CRM data stream.
To process the data stream using the streaming process, the object must be included in the list of objects that support change events. See StandardObjectNameChangeEvent. Additionally, there are several scenarios in which streaming isn’t available and the processing mode changes to batch, as listed in CRM Connector Streaming
Data 360 runs a query to verify that your data is accurate before starting the extraction process. If the validation process takes over 2 minutes, it stops automatically. The status updates to Failed, and Data 360 retries the validation.
When creating a data stream, you can select multiple objects. For each selected object, a separate data stream is created. This feature is supported during deployment and redeployment, allowing you to add new source and formula fields, or to reconfigure data spaces. Multiple object deployment applies to the interface and does not affect other methods of CRM datastream creation, such as through the Connect API.
In Data 360, go to the Data Streams tab and click New.
Select the Salesforce CRM data source and click Next.
To create your data stream, select a Salesforce org.
If you have only one Salesforce org connected to Data 360, it’s selected by default.
Select the View Objects tab.
Select up to 30 Salesforce objects to include in the data stream and click Next.
Select an object category from the dropdown menu: Profile, Engagement, or Other. Refer to Category to see considerations for each category.
You can change the name of the DLO label, API name, and data stream name, or accept the default names.
The data stream name defaults to the object label and the alias that’s provided when setting up the connection to a Salesforce CRM org.
Don’t change the API name of the CRM object after creation. Changes to the API name can cause data sync issues or prevent the data stream from ingesting or updating records properly.
Review the objects and fields to include in the data stream and deselect the fields that aren't required.
By default, all fields for an object are selected. To allow the stream to be ingested in a faster streaming mode, exclude batch ingested fields. For periodic batch mode processing, leave them in. To learn more, see CRM connector streaming considerations.
(Optional) Click New Formula Field and add these fields.
Field Label—the display name for a data stream field.
Field API Name—the programmatic reference for a data stream field.
Formula Return Type—the data type corresponding to the new field. The options are number, text, and date.
Transformation Formula— the calculation can include input from other fields in the same row or across rows.
Click Next.
Select a Data Space.
To determine which records in the DLO are available on the associated data space, you can click Set Filter, then Add Filter.
The filter doesn't prevent the ingestion of records from the connected data source or filter out records before they're ingested into Data 360. See Understanding Data Space Filters on Data Streams.
The refresh schedule is set by default. For more information, see Data Stream Schedule in Data 360.
Click Deploy.

You've now created a Salesforce CRM data stream. If you disable a field in the future, redeploy the stream to enable the field again. To create more data streams, repeat these steps.

Disable or Re-enable a Salesforce CRM Connector Data Stream Field
Disable a field in a Salesforce CRM connector data stream to stop new data ingestion, clear existing data for that field, and remove it. If the field is required again later for a standard or custom data lake object (DLO), you can enable it. You can’t assign the name of a disabled field to a new field.
Store or Remove Deleted CRM Connector Data Stream Records
Store soft deleted data stream records that have been in the Salesforce Recycle Bin for up to 15 days. To store deleted data stream records, create a Deleted Record data lake object (DLO). You can use this DLO to view your stored records and use them in Data 360. For example, you can use the Deleted Record DLO to store deleted contacts outside of your Recycle Bin. You can only store deleted records of structured data streams.
SEE ALSO
Salesforce Help: Disable or Re-enable a Salesforce CRM Connector Data Stream Field
Salesforce Help: CRM Connector Streaming Considerations
Salesforce Help: Enable Object and Field Permissions to Access Salesforce CRM in Data 360
Salesforce Help: Unsupported Objects and Object Types in CRM Data Streams
Salesforce Help: Manage Big Objects
Salesforce Help: Data Stream Schedule in Data 360
Salesforce Help: Set Up a Salesforce Connection in Data 360