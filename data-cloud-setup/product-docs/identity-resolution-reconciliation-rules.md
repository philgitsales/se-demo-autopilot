# Identity Resolution Reconciliation Rules | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_reconciliation_rules.htm&type=5

DATA 360
Identity Resolution Reconciliation Rules

A reconciliation rule specifies how to select a single value to save to a unified field that can’t have multiple values, such as an individual’s name, during the identity resolution process. Reconciliation rules are set at the object level and can be overridden by field-specific reconciliation rules. The reconciliation process doesn’t delete or change any source profile data, update your connected source systems, or tell you which source data to use when working with your customers.

NOTE Reconciliation rules don’t apply to contact points such as email or phone number. All contact points remain part of a unified profile, so all contact points are available when creating activations for segments on unified profile. Use the source priority order in activations to make sure you deliver a contact point from the desired source to your activation target.

The reconciliation process determines only what information is shown in the unified profile. It isn’t intended to determine a “best” value for a field across all applications. Reconciled values are shorthand used to summarize and label a customer 360 profile.

Unified link objects connect your unified profile to all source data so that you can choose which view of the customer to use. Use your unified profiles to guide you to the best source data to use in your use case.

Reconciliation Rule Settings

Select a reconciliation rule for a field based on the type of data that field holds and your organization’s preferences.

RECONCILIATION RULE DEFINITION
Last Updated

This rule specifies that the value from the most recently updated record must be selected for inclusion in the unified profile.

The Last Updated record is determined by the Last Modified Date field on your primary data model object. This reconciliation rule is available only when the Last Modified Date field is mapped from the data stream.

If matching records have the same last updated date and time, a value is selected alphabetically.

Most Frequent

This rule specifies that the most frequently occurring value must be selected for inclusion in the unified profile.

If Ignore Empty Values is selected, the identity resolution process doesn’t select null values, even if null is the most frequently occurring value for the field.

If values occur at identical rates of frequency, the last updated value is selected.

Source Priority

This rule sorts your data lake objects in order of most to least preferred for inclusion in the unified profile.

To stabilize ID values, use the Source Priority reconciliation rule on ID fields.

If Ignore Empty Values is selected, the identity resolution process selects the highest-priority non-null value.

If records from the same source are matched, individual fields within the record are reconciled according to field-level reconciliation rules. If the field-level reconciliation rule is also source priority, the last updated value is selected.

EXAMPLE Suppose a unified profile is created with data from multiple sources that contain different data about a customer’s first name. For example, the First Name field is Samantha in the first source and Sam in the second source.

If the active reconciliation rule for the field is Last Updated and the second source was modified most recently, the value from the second source is selected for the unified profile's First Name. The reconciled value, Sam, is used in segmentation and activation.

However, if the active reconciliation rule for the field is Source Priority and the first data source is prioritized above the second data source, the reconciled value is Samantha.

Set a Default Reconciliation Rule
Set a default reconciliation rule for each object in your identity resolution ruleset. The default reconciliation rule tells the identity resolution process how to select values for all fields in an object.
Override an Object’s Default Reconciliation Rule
Override an object’s default reconciliation behavior by applying a reconciliation rule to a specific field.
Reconciliation Rule Warnings
Reconciliation rule warnings help you identify fields to change or review. You can ignore a reconciliation rule warning. Identity resolution processes run even with these warnings.
SEE ALSO
Salesforce Help: Reconciliation Rule Warnings
Salesforce Help: Set a Default Reconciliation Rule
Salesforce Help: Override an Object’s Default Reconciliation Rule