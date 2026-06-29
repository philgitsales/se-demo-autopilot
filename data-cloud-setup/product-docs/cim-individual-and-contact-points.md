# Customer 360 Data Model: Individual and Contact Points | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_cloud_information_model_individual_and_contact_points.htm&type=5

DATA 360
Customer 360 Data Model: Individual and Contact Points

When using the Customer 360 Data Model, Data 360 prepares a list of Salesforce-published objects, fields, metadata, and relationships to ensure consistency across applications and business processes. Individual and contact point objects are important concepts for successful and complete data streams.

OBJECT TYPE WHAT IT IS EXAMPLE
Individual Represent the person you are, or will be, dealing with using the system FirstName, LastName, BirthDate, BirthPlace
Contact Point Email Email address for an individual info@northerntrailoutfitters.com
Contact Point Phone Phone number for an individual +1555123456
Contact Point Address Mailing address for an individual 123 Main St., Big City, CA12345, USA
Contact Point App Software Application for an individual and optionally on a specific device John Doe has Strava App on device iPhone123
Contact Point OTT Service The “over-the-top” technology that delivers a messaging/streaming service account of an individual through internet-connected devices WhatsApp, Line, Netflix
Contact Point Social Social handle for an individual Twitter: @trustednews
Contact Point Digital Id A digital identifier of an individual such as Google Ad ID (GAID), Mobile Ad ID (MAID), Apple Identifier for Advertisers (IDFA), etc.
Party Identification Set of ways to identify an individual Drivers license number, customer ID
TelephoneNumber The display name, as defined by the customer. Include this object in places where customers view the number like Profile API and Profile Views.
FormattedE164PhoneNumber The E164 formatted phone number. Use in backend systems as the standardized value for processing.
Country The country code US, CA, IT, NZ, AU
PhoneCountryCode The country dialing code +1, +91
Individual ID

Imported data customer identifiers must be mapped to the Individual ID field to drive identity resolution behavior and to receive accurate data when creating data segments.

The Individual ID object is important to ensuring successful data in Data 360. When importing any customer information, it’s mapped to this object and remains consistent throughout the entire product.