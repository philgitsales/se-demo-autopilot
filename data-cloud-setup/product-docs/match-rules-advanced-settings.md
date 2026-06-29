# Advanced Match Criteria Settings | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_match_rules_advanced_settings.htm&type=5

DATA 360
Advanced Match Criteria Settings

Access match rule modifier settings in Advanced Match Criteria Settings for each match rule.

You can set rules to use case sensitive matching or to match blank values.

Case Sensitive

If Case Sensitive is selected for a match rule, uppercase letters don't match lowercase letters. For example, “Maryanne” and “MaryAnne” are treated as different names in case sensitive matches.

The option Use case sensitive matching to link Individual ID and Fully Qualified Key can be set for an entire ruleset when you create a new ruleset. If selected, identity resolution matches records where both the individual ID and fully qualified key are identical.

Match on Blank

If selected, empty field values are considered matches. Choose this setting thoughtfully to avoid overmatching. For example, selecting Match on Blank for a field that’s frequently empty, such as a middle name, can cause records that are incomplete to be linked into the same unified profile.

When a ruleset iruns in real time, Match on Blank is ignored.

The error “Some source profiles weren’t unified because they matched 50,000 or more other profiles. To reduce the number of matching records, clean your data or refine your match rules.” on a ruleset run can be caused by selecting Match on Blank for fields that are frequently empty.