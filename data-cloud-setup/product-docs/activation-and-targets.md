# Activation and Activation Targets | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_activation.htm&type=5

DATA 360
Activation and Activation Targets

Activation is the process that publishes a segment to your activation platforms, allowing you to take action on that data. An activation target is used to store authentication and authorization information for a given activation platform, like Marketing Cloud Engagement or Meta.

Once you have created a target, you can publish your segments with contact points and additional attributes to that activation target. This enables you to power personalized marketing campaigns, create effective ad campaigns, and deliver consistent customer experiences.

Activation Targets in Data 360
Depending on your use case, data can be activated to various targets, from file storage, external activation, or to other data model objects (DMOs) in Data 360. Once you know where you want to act on the segmented data from Data 360, create activation targets for each platform.
Activation for Data 360 Segments
Activation is the process that publishes a segment to activation platforms in Data 360. Before you activate your segments, it's important to review some activation concepts.
Activation for Data 360 Data Model Objects
Use data from various sources to build complete customer profiles by activating a data model object (DMO). This feature presents data in a readily actionable format and facilitates personalized customer experiences. Data 360 offers two methods for DMO activation: streaming and batch, with each designed for different use cases and destinations.
Standardize Activations by Using Activation Templates
Use activation templates to define and save reusable activation configurations. These configurations include settings for contact point selection, source priority, filters, enrichment data, and membership filtering. Use these templates to create activations with consistent, predefined settings across all supported activation platforms.
Create an API Activation in Data 360
API activation expands where and how you can initiate activations. API activation gives you the flexibility to use a Data 360 activation from Flow by using an API call.
Advertise with Data 360
Use Data 360 to implement advertising strategies with first-party data. Establish a reliable source of truth in Data 360, and connect with external advertising platforms to deliver highly targeted, personalized experiences across every channel.
Capping Communications for B2C Engagements
Set caps on communications with B2C customers, leads, or prospects to ensure compliance with regulatory requirements, enhance the customer experience, and avoid message fatigue. Optimize your campaign spend budgets across lines of business by applying department-level thresholds. Stay compliant with regulatory requirements by avoiding unsolicited, unregulated communications to targeted entities.
Publish History of Your Activation
In Data Cloud, view the activation history to see when and how segments were published. For segments published to a Marketing Cloud Engagement activation target, additional columns appear in the activation history to provide more details. View the same publish history details in a segment record.
Activation Type and Target Compatibility
Summary of activation types, publish schedules, and supported activation targets.
Activation Refresh Types
When creating an activation, choose from two refresh types: full or incremental. A full refresh updates all records in the segment during activation. An incremental refresh publishes only the added, updated, and deleted records since the last successful refresh.
Troubleshoot Activation Errors
Get tips for solving common activation errors in Data 360.