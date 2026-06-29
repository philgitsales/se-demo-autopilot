# Identity Resolution Match Rules | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_match_rules.htm&type=5

DATA 360
Identity Resolution Match Rules

Match rules tell Data 360 which profiles to unify during the identity resolution process. Each match rule contains one or more criteria. Profiles are matched when all criteria within a match rule are satisfied.

Create multiple match rules to widen matching options. A unified profile is created if any single match rule is activated.

Match rules can be created only on certain objects. Available objects vary depending on whether you’re matching individuals or accounts. Ensure these objects are properly mapped to make them available for identity resolution.

When matching accounts—Account, Contact Point Address, Contact Point Phone, Contact Point Email, Party Identification
When matching individuals—Individual, Contact Point Address, Contact Point App, Contact Point Email, Contact Point Phone, Contact Point Social, Party Identification

Use criteria to determine how strict each match rule is. Consider adding more criteria if accuracy is your top priority. You’re more likely to create unique unified profiles with more criteria in your match rules. If increased consolidation is a priority, reduce the number of criteria to allow profiles to more easily be matched.

Identity Resolution Match Rule Terminology
Understand the roles that match rules, match criteria, and match methods play in identity resolution rulesets. Adding, adjusting, and removing match rules, match criteria, and match methods can change the consolidation rate of the overall ruleset.
Configure Identity Resolution Match Rules
Specify how identity resolution identifies matching records in Data 360.
Identity Resolution Match Methods
Match rule methods determine how source data is transformed for comparison during matching. Changing the match method on a field typically changes the consolidation rate based on that field.
Advanced Match Criteria Settings
Access match rule modifier settings in Advanced Match Criteria Settings for each match rule.
Default and Custom Match Rules
Identity resolution provides out-of-the-box, default match rules for different types of matching. Use custom match rules to resolve use cases that aren’t covered by default rules. Developing balanced, effective sets of match rules across different types of criteria improves consolidation rates for individuals and accounts.
SEE ALSO
Salesforce Help: Data Mapping Requirements
Salesforce Help: Select Unified Individual for Activation Membership
Salesforce Help: Customer 360 Data Model: Individual and Contact Points