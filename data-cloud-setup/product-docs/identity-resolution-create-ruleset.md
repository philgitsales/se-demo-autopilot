# Create Identity Resolution Rulesets | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_identity_resolution_ruleset_create.htm&type=5

DATA 360
Create Identity Resolution Rulesets

Get started with identity resolution by setting up a ruleset to unify accounts, individuals, leads, or households. The primary data model object for your ruleset determines which records are unified. Match and reconciliation rules you add to your ruleset after creating it guide how records are matched.

REQUIRED EDITIONS
Available in: All Editions supported by Data 360. See Data 360 edition availability.
PERMISSION SETS NEEDED
To create identity resolution rulesets:

Permission set:

Data Cloud Architect
On the Identity Resolutions tab, click New.
Select a data space.
Select the primary data model object that your ruleset will be based on.
If you don’t see any objects available, make sure your data is modeled properly and that you haven’t reached the maximum number of rulesets.
Household unification is available only after you run a ruleset based on Individuals.
Add an optional ruleset ID of up to four text characters.
Optionally, add a ruleset ID of up to four text characters. The ruleset ID can’t be changed and becomes part of the data model object names and API names. If you have two rulesets for an object, at least one must have a ruleset ID.
TIP Use test as a ruleset ID. After using the test ruleset to test different combinations of match and reconciliation rules, delete the ruleset. If you delete a ruleset and want to use the same ruleset ID again later, you could encounter an error. Wait for Data 360 to finish deleting the ruleset with your desired ruleset ID and try again.
Click Next.
Name your ruleset and add an optional description.
If your ruleset will unify individuals, you can opt to link all individuals who share the same individual ID and key qualifier.
If you’re creating a ruleset to unify households, select the Individual ruleset whose output will be used as the source data for the households.
Make a note of the data model object and API names created by the ruleset.
Click Save.

Add match rules and reconciliation rules to your ruleset.

NOTE Rulesets are scheduled to run at least one time per day after publication. To prevent unnecessary credit consumption, we recommend disabling Run jobs automatically while you're configuring a ruleset. Use the Run Now button to run a ruleset during configuration.

The consolidation rate on the ruleset's identity resolution summary details the results of the last successfully completed run. Compare the consolidation rates of two rulesets to determine which better meets your needs. To reduce usage costs, we recommend keeping only one active ruleset.

Filter Source Records out of Identity Resolution
Control which source records enter the identity resolution processing pipeline by defining filter conditions on your ruleset's primary data model object. Filters act as a preprocessing gate, so records that match your exclusion conditions never enter the unification pipeline. Using filters helps keep unified profiles clean and reduces credit consumption.
Delete an Identity Resolution Ruleset
Deleting a ruleset permanently removes all unified customer data, eliminates dependencies on data model objects, stops all processing of the ruleset, and deletes the history of previous runs. In some cases, it’s better to update the match or reconciliation rules instead of deleting the ruleset.
SEE ALSO
Salesforce Help: Configure Identity Resolution Match Rules