# Configure Identity Resolution Match Rules | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_match_rules_configure.htm&type=5

DATA 360
Configure Identity Resolution Match Rules

Specify how identity resolution identifies matching records in Data 360.

REQUIRED EDITIONS
Available in: All Editions supported by Data 360. See Data 360 edition availability.
PERMISSION SETS NEEDED
To configure match rules

Permission set:

Data Cloud Architect

To create or edit match rules:

Go to the record homepage of your identity resolution ruleset.
In Match Rules, click Configure or Edit.
Click Add Match Rule.
Select a default match rule or click Custom Rule to create your own. To create a match rule based on party identifier or an external identity link, create a custom rule.
Click Next.
Edit, add, or delete criteria for your match rule. To create a match rule based on party identifier, select the Party Identification data model object and the Identification Number field. To create a match rule based on an external identity link, select the Identity Match data model object and the Identity Match Type field.
TIP Matching on a single contact point isn’t recommended to avoid over grouping, except for unique external identifiers like a party identifier. Matching on single data point, such as phone number or email alone, could mix household members with a shared contact point into a single unified profile. By adding more match criteria, like name or email, you’re less likely to mix household members into a single unified profile.
NOTE Each ruleset must have at least one match rule. You can't delete the last match rule from a ruleset. To stop a ruleset from running, delete it.
To set up cross-object matching, case sensitive matching, or allow blank values to match, click Configure to access the advanced criteria settings. For cross-object matching, the object you want to match to must be modeled properly.
Name your match rule with 80 characters or less.
Click Save.

After saving the ruleset, optionally add filter conditions to control which source records enter the matching process.

To filter records, open the Filters section of the ruleset and define conditions using fields from the primary data model object.

Configure Real-Time Matching in Data 360
You can configure any ruleset for real-time matching after its first ruleset run is completed by creating a real-time data graph based on the ruleset’s output unified profile data model object.