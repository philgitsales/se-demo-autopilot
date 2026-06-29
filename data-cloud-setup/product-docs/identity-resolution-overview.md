# About Identity Resolution | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_identity_resolution.htm&type=5

DATA 360
About Identity Resolution

Identity resolution is the processing engine that generates unified profiles from source profile data stored in Data 360. Unified profiles act as a system of reference to unlock our source data. Understand how and when source profiles are processed and what you can do with unified profile output.

The Unified Profile Key Ring

Unified profiles are keys that help you unlock your data, but they aren’t golden records. Unified profiles give you the most complete, accurate, and robust picture of each customer built from all of your source profile data about an individual or account. Identity resolution doesn’t pick winning values or override any existing data while unifying profiles.

Think about each unified profile like a ring of keys. Each ring contains one or many keys that all belong to the same person or business. Each key on the key ring fits into a different lock. In this analogy, your unified profile is a key ring that contains a key to a source record. You can use the keys to unlock a single record or many records in order to use the data contained in the records.

With your unified profile key ring, you can identify all the records that belong to an individual or business, and find the keys that let you access data about them. The unified profile key ring allows you to build a holistic view of your customer without requiring you to merge data into a single “best” record. This system of reference lets you decide which data is most important for any given purpose. It also allows you to select different views of the customer for different use cases.

Review these resources for a deeper dive into the identity resolution key ring analogy.

Medium: Looking Beyond the Golden Record: Unified Profiles in Salesforce Data 360
Salesforce Admin Blog: Rethinking the Golden Record: The Advantages of Data Cloud’s Unified Profile
Trailhead: Get to Know Unified Profiles
Identity Resolution Terminology
Understand what terms like rulesets and unified objects mean when used in the context of identity resolution.
Processing Frequency for Identity Resolution
Identity resolution processes rulesets as frequently as every 60 minutes to 24 hours, depending on the data source. Each data source is processed on its own timeline according to when data is received and how many changes accumulate.
Real-Time Identity Resolution
Real-time identity resolution identifies customers in milliseconds so you can personalize your site or communications during an engagement.
Billing Considerations for Identity Resolution
Use of identity resolution impacts the consumption of credits used for billing in these usage types.
SEE ALSO
Salesforce Help: Identity Resolution Rulesets