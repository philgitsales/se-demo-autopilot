# Default and Custom Match Rules | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_match_rules_criteria.htm&type=5

DATA 360
Default and Custom Match Rules

Identity resolution provides out-of-the-box, default match rules for different types of matching. Use custom match rules to resolve use cases that aren’t covered by default rules. Developing balanced, effective sets of match rules across different types of criteria improves consolidation rates for individuals and accounts.

Match Rules for Accounts
Identity resolution provides two preconfigured default match rules based on Account Name combined with other common data. Default match rules allow you to quickly select one of the four common match rule configurations. You can combine default and custom rules in a ruleset to create multiple ways for records to match. To get the best results from account matching, we recommend using match rules that match by account name and geographical location. The specific address data you select impacts the quality and precision of your matches.
Match Rules for Individuals
Identity resolution provides four preconfigured default match rules based on Individual First Name and Individual Last Name combined with other common data. You can combine default and custom rules in a ruleset to create multiple ways for records to match.
Match Rules for Households
You can add only one match rule to a ruleset when configuring household matching in Data 360 identity resolution. Each unified household contains one or more individuals. We recommend matching individuals into households based on either last name and address or on party identifier.