# Identity Resolution Terminology | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_identity_resolution_terms.htm&type=5

DATA 360
Identity Resolution Terminology

Understand what terms like rulesets and unified objects mean when used in the context of identity resolution.

Rulesets
Identity resolution rulesets contain match and reconciliation rules that specify how to link multiple sources of data into a unified profile. Match rules specify how to compare field values to identify matching records. Reconciliation rules specify how to select values from among multiple data sources to use as summary data in the unified profile.

To learn about match rules, see Identity Resolution Match Rule Terminology.

To learn about reconciliation rules, see Identity Resolution Reconciliation Rules.

Ruleset Job
The ruleset job processes source profiles according to how your source data is mapped and the match, and reconciliation rules you configure. The job runs at least one time a day for each ruleset, unless it detects no changes in source data or ruleset configuration. If nothing has changed, the ruleset job is skipped.
Unified Profile Objects
Identity resolution links source profiles info unified profiles that can be used in processes such as segmentation and activation, calculated insights, reporting, and more. Unification is determined based on the data mappings you create and on match and reconciliation rules specified in the ruleset.

When a ruleset is based on the Individual DMO, information such as first name and last name from multiple data sources is consolidated into unified individual objects. When a ruleset is based on the Account DMO, information such as business name, location, and type is consolidated into unified account objects. Each unified profile object contains summary information about the profile selected using reconciliation rules and IDs that point to source data, allowing you to decide which is the best data source for a given use case.

Unified Contact Point Objects
An individual or account can have multiple valid contact points that must be preserved for each unified individual or unified account. For example, an individual can have both a home phone number and a mobile phone number. Data 360 creates unified contact point objects to aggregate contact points from different data sources, based on mappings and rules in each ruleset. Unified contact point objects retain all unique contact points for a unified profile.

During reconciliation, only the attributes that describe contact points are reconciled if there’s a conflict between sources. For example, if a phone number is listed as personal number in some sources, and a business number in other sources, reconciliation rules determine if the phone number is listed as personal or business.

Unified Link Objects
Unified link objects serve as the link between the source data and unified objects. Unified link objects allow you to view source data of each unified profile and are required for creating calculated insights for unified profiles.
Unified Link Objects and Relationships to Unified Objects
Identity resolution creates the following link tables as a bridge between source objects and unified profile objects.
SEE ALSO
Salesforce Help: Identity Resolution Match Rule Terminology
Salesforce Help: Identity Resolution Reconciliation Rules