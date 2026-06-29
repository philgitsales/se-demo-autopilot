# Data Mapping Requirements in Data 360 | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_required_data_mappings.htm&type=5

DATA 360
Data Mapping Requirements in Data 360

Mappings and relationships are set up automatically only for data streams that are deployed through standard data bundles. However, you must ensure that the required mappings and relationships are set up properly for custom data streams.

When you’re mapping a data model object (DMO) in the Profile or Other category, you must map the primary key field. You can save the data mapping only after mapping the primary key.
When you’re mapping a DMO in the Engagement category, you must map the primary key field and the Event dateTime field. You can save the mapping only after mapping both fields.
To use identity resolution, segmentation, and activation, map the required fields and relationships for the party area data. You can use the Entity Relationships Diagram (ERD) for Party area to plan the mapping. You must also map the Individual object and either a Contact Point or the Party Identification object must be mapped in data streams.
The reference to the Individual object in other objects within the data model is done through the Party attribute. Think of it as a foreign key relationship that links to an Individual.Id attribute. In the Party entity relationship diagram, you can see that each Contact Point <channel> object alongside Party Identification has that reference. While in some cases it can be confusing, when it comes to attributes, Party = Individual.Id.
Map at least one Contact Point <channel> attribute to enable unification and activation processes to work.

A Contact Point <channel> object contains details about an individual, such as an email address or phone number. Without the contact point, activation isn’t feasible because there isn’t a contact detail through which to engage with customers.

The Party Identification object represents sets of third-party identifiers for an individual, such as a loyalty card number or a driver license number that can associate numerous customer records together. For the same Party Identification Type and Identification Name values, Data 360 matches records with the same Identification Number.
To activate digital identifiers to JSON-based external activation platforms that use the activation toolkit, map the Contact Point Digital Id object. This mapping is mandatory when the activation platform relies on specific digital identifiers such as UID2 or RampID. If your activation only targets email or phone-based destinations (using Contact Point Email or Contact Point Phone), this mapping is optional. For more information, see Ingest and Model Digital Identifiers for JSON-based External Activation Targets.
OBJECT FIELDS RELATIONSHIP
Individual ID None
Contact Point Email
ContactPointId
PartyId
EmailAddress
ContactPointEmail (PartyId) (many) to Individual (Id) (one)
Contact Point Phone
ContactPointId (key)
PartyId
TelephoneNumber
Country
FormattedE164PhoneNumber
ContactPointPhone (PartyId) (many) to Individual (Id) (one)
Contact Point Address
ContactPointId (key)
PartyId
StreetID
CityID (City Name)
StateName (State Province Name)
CountryID (Country Name)
ContactPointAddress (PartyId) (many) to Individual (Id) (one)
Contact Point Social
ContactPointId (key)
PartyId
SocialHandleId
ContactPointSocial (PartyId) (many) to Individual (Id) (one)
Contact Point OTT Service
Contact Point OTT Service Id
PartyId
Country
Username
ContactPointOTTService (PartyId) (many) to Individual (Id) (one)
Contact Point Digital Id
ContactPointDigitalId (key)
IndividualId
DigitalIdType
DigitalIdValueText
ContactPointDigitalId (IndividualId) (many) to Individual (Id) (one)
SEE ALSO
Salesforce Help: Category
External: Party Overview Entity Relationship Diagram