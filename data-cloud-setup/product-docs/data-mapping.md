# Data Mapping | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_data_mapping.htm&type=5

DATA 360
Data Mapping

Data ingested by all data streams is written to data lake objects (DLOs). After creating your data streams, you must associate your DLOs to data model objects (DMOs). Only mapped fields and objects with relationships can be used for Segmentation and Activation.

On the Data Stream detail page or after deploying your data streams, click Start Data Mapping.

On the Field mapping canvas, you can see both your DLOs and target DMOs. To map one to another, click the name of a DLO and connect it to the desired DMO. For example, you can map the DLO firstname to the target First Name field using this method.

Data Mapping Requirements in Data 360
Mappings and relationships are set up automatically only for data streams that are deployed through standard data bundles. However, you must ensure that the required mappings and relationships are set up properly for custom data streams.
Data Mapping Best Practices
Proper data mapping in Data 360 is a key component for success. Follow some best practices for data mapping to ensure your data can be used throughout Data 360 for segmentation, insights, and identity resolution.
Data Mapper Views
Select table or visual view when mapping your data in Data 360.
Data Types in Field Mappings
When mapping a data lake object (DLO) to a data model object (DMO), the data types of the DLO and DMO fields must be compatible.
Map Data Model Objects
Data mapping relates Data Lake Object (DLO) fields to Data Model Object (DMO) fields, paving the way for unifying your source data into a single standardized Customer 360 data model.
Automapping
Automapping in Data 360 maps data lake object (DLO) fields to the correct data model object (DMO) fields. When you choose a specific DMO during field mapping, Data 360 calculates and applies the field mappings. You can then make any necessary changes and save the mappings.
Mapping UDLOs to UDMOs
Workloads in Data 360 that consume unstructured data do so through unstructured data model objects (UDMOs). When you create a UDLO, you map it to a UDMO.
Manage Data 360 Objects and Field Mappings
Edit or remove objects and field mappings associated with a data model object (DMO) or data lake object (DLO). Manage mappings and objects to ensure data accuracy and maintain the integrity of your data model.
Delete an Unstructured Data Lake Object
You can delete unstructured data lake objects (UDLOs) at any time.
Remove a Field from a Data 360 Page
A FlexiPage represents the metadata associated with a Lightning page. A Lightning page is a customizable screen made up of regions containing Lightning components. A Lightning page is created only for derived data model objects (DMO) that have unified objects such as UnifiedIndividual and UnifiedAccount. You can remove a field from the Data 360 page to remove field mappings.