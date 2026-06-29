# Data Streams in Data 360 | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_data_streams.htm&type=5

DATA 360
Data Streams in Data 360

Data streams are the connections and associated data ingested into Data 360.

Navigate, edit, and review data stream schedules in this help section. Review the Data Sources in Data 360 section to know about data streams supported in Data 360 and the steps to create the data streams.

Billing Considerations for Data Ingestion
Ingesting data from external soures impacts the consumption of credits used for billing for orgs operating Data 360 under a Data Cloud license. Ingestion from internal sources doesn't consume credits.
Data Streams Tab Navigation
On the Data 360 Data Streams tab, you can view all existing data streams, including the data streams you own. You can also create a data stream.
Data Stream Schedule in Data 360
Data streams can operate on different refresh schedules. Learn more about how and when these data streams update.
Data Stream Settings and Refresh Modes
With data streams, you can schedule or run jobs to ingest data from a source system. These jobs pull data from the source system into the connected data stream. The method and frequency options for data ingestion depends on the type of connector. Use the data stream settings to create or change the execution parameters of a data stream.
Data Lake Object Naming Standards
Use these naming guidelines for data lake objects.
Record Modified Field
The record modified field is set when defining the source object during setup in Data 360.
Create a Data Stream from a Data Kit
When you create a data stream from a data kit in your target org, the data model objects are available automatically. When adding a data model to a data kit, a custom data model is added as is. If you’re adding a standard data model, only the custom mappings and custom fields are packaged.
Update Database Configuration for Zero Copy Data Streams
When deploying a data kit that contains zero copy data streams, you can update the target database, schema, or table after deployment to match your target environment.
Create an Unstructured Data Lake Object from a Data Kit
After you have deployed your data kit in Data 360, you can create an unstructured data lake object (UDLO). All fields are automatically mapped.
Disable a Data Stream Field
If a field is no longer required in a data stream, you can disable it. Disabling a field removes it from the data stream, and no new data is ingested. You can’t assign the name of a disabled field to a new field.
Delete a Data Stream
You can delete a data stream in Data 360 if the connection is no longer needed.
Edit a Data Stream
You can edit a data stream in Data 360 for the Amazon S3, GCS, Azure, Marketing Cloud Engagement, and SFTP connectors. Changing the name of a data stream doesn’t change the name of the DLO that the data stream uses.
Delete Ingested Records in Data 360
You can delete data ingested into Data 360. Your data stream must have an upsert refresh mode. The deletion process depends on the type of connector that you’re using.
Supported File Formats in Data 360
Data 360 supports various files and compression formats for your data stream sources.
Data Stream and Data Lake Object Refresh History
Data 360 provides record-level statistics of the data ingested by data streams and records processed into a data lake object (DLO).
Monitoring Data Stream Problem Records
Records that can’t be ingested into Data 360 due to data quality issues are logged as problem records and stored in a problem record data lake object (DLO). Problem records are created when data is ingested through: all structured ingest connectors, Web and Mobile App connectors, and Ingestion APIs.
Using an Existing Data Lake Object to Create a Data Stream
You can use an existing data lake object (DLO) when creating an S3, Google Cloud Storage, or SFTP data stream. The data stream that initially created the DLO defines the characteristics, such as the primary key, event date time, and record modified field. You can convey how the new data stream’s fields conform to the existing DLO fields.
Ingest Data by Uploading a File
Create a data stream by bringing in data from a local CSV file into Data 360.
Troubleshoot Data Stream Errors
Data streams can encounter various issues when importing data into Data 360. Use this troubleshooting section to identify and resolve common data streaming errors.