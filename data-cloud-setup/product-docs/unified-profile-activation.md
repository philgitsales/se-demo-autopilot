# Unified Individual for Activation Membership | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_unified_profile_activation.htm&type=5

DATA 360
Unified Individual for Activation Membership

To take advantage of identity resolution, use the Unified Individual data model object (DMO) as the Activation Membership. With identity resolution, you combine data from disparate data sources to create one Unified Individual. When selecting Unified Individual as the DMO, the Individual ID attribute is included and not the Unified Individual ID.

Contact Points for a Unified Individual

If you have data from multiple data sources in Data 360, use Unified Individual as the Activation Membership. Selecting Individual instead of Unified Individual as the Activation Membership can result in duplicate entries in your count. When any DMO besides Unified Individual is selected as the Activation Membership, Data 360 includes all contact points associated with the object.

Data 360 activates one row for a Unified Individual. Unified Individual includes different fields depending on which contact point channel you select.

CONTACT POINT FIELD
Email Address
Subscriber key
Contact email address

Phone Number
Subscriber key
Contact phone number
Phone country code

MobilePush
Subscriber key

WhatsApp
Subscriber key

If contact points come from multiple sources, Data 360 selects the contact points you prioritized in source selection. If there are multiple contact points for a single source, the contact point with the highest Einstein engagement score is selected. If the score isn't available or has the same score, the lowest alphanumeric ID is selected.

SEE ALSO
Salesforce Help: Identity Resolution Match Rules