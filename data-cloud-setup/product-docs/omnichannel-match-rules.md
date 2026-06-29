# Define Match Rules for Identity Resolution and Relate Separate Individuals | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_omni_match.htm&type=5

DATA 360
Define Match Rules for Identity Resolution and Relate Separate Individuals

Let’s review the steps for defining match rules for Identity Resolution and relating separate Individuals in Data 360.

Relate your separate Individuals to a Unified Individual using Identity Resolution. This example assumes that you can externally collect FirstName, LastName, EmailAddress, and/or PhoneNumber for each channel SubscriberKey. You then import the external data from three different systems, one for each channel, and map it accordingly. The imported SubscriberKey is linked to the Individual ID in Data 360. Using these match rules, Identity Resolution relates the separate Individuals, representing a person’s various Marketing Cloud Engagement SubscriberKeys, to a single Unified Individual.

NOTE Your company’s data mapping, identity resolution strategy, and rules can differ. Learn more about match rules and Unified Individual Considerations and Best Practices.
In Data 360, go to the Identity Resolution app.
Click New.
Set the Primary Data Model Object to Individual and enter a Ruleset ID.
Click Next.
Enter a ruleset name and the description.
Click Save.
In the Match Rules section, click Configure.
For Match Rule 1, click Configure.
Select Fuzzy Name and Normalized Phone and click Next.
Review the default rules.
Click Add Match Rule.
Select Fuzzy Name and Normalized Email and click Next.
Select Custom Rule and click Next.
Match on Mobile SDK Shared Identifier.
NOTE Customers must implement Mobile SDK to include both Data 360 and MobilePush modules.
Enter a name for the Match Rule and click Next.
Read the overview and click Save.