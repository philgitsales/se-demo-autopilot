# Identity Resolution Rulesets | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_identity_resolution_ruleset.htm&type=5

DATA 360
Identity Resolution Rulesets

Rulesets contain match and reconciliation rules that tell the customer data platform how to link multiple sources of data into a unified profile. Unified profile information is stored in data model objects created by the ruleset.

Create Identity Resolution Rulesets
Get started with identity resolution by setting up a ruleset to unify accounts, individuals, leads, or households. The primary data model object for your ruleset determines which records are unified. Match and reconciliation rules you add to your ruleset after creating it guide how records are matched.
Identity Resolution Match Rules
Match rules tell Data 360 which profiles to unify during the identity resolution process. Each match rule contains one or more criteria. Profiles are matched when all criteria within a match rule are satisfied.
Identity Resolution Reconciliation Rules
A reconciliation rule specifies how to select a single value to save to a unified field that can’t have multiple values, such as an individual’s name, during the identity resolution process. Reconciliation rules are set at the object level and can be overridden by field-specific reconciliation rules. The reconciliation process doesn’t delete or change any source profile data, update your connected source systems, or tell you which source data to use when working with your customers.
Scheduled and Real-Time Matching in Identity Resolution
Identity resolution can perform two types of ruleset runs: scheduled or real-time. They differ in how and when the two types of ruleset runs are performed, and how they interact with other features.
Identity Resolution Ruleset Processing Results
Summary statistics are available after a ruleset job runs for the first time. Results of the most recent run are shown in the Resolution Summary. Results from previous days are listed in the processing history table. If the ruleset was processed more than one time per day, the results in the processing history table reflect the last run completed during the day.
SEE ALSO
Salesforce Help: Identity Resolution Terminology