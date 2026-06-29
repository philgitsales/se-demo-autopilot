# Model Your Contact Data for Omnichannel Journeys | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_omni_model.htm&type=5

DATA 360
Model Your Contact Data for Omnichannel Journeys

This solution kit is designed for customers who have implemented single-channel contacts in Marketing Cloud Engagement. Customers who have implemented single-channel contacts in Marketing Cloud Engagement must follow this solution kit to execute omnichannel journeys. Determine whether you’ve implemented omnichannel or single-channel Contacts.

Omnichannel Contacts

If your Contacts are already configured as Omni-Channel contacts, congrats! Your Marketing Cloud Engagement SubscriberKeys can natively execute each channel within an Omni-Channel journey. In the context of this solution kit, Omni-Channel contacts have a shared SubscriberKey that you can use across all three channels.

In this scenario, the person John Smith is represented by the single SubscriberKey John.Smith in Marketing Cloud. The SubscriberKey has an associated address stored in Marketing Cloud Engagement for each channel: email, SMS, and MobilePush.

MARKETING CLOUD ENGAGEMENT CONTACT
SYSTEM

SUBSCRIBERKEY: JOHN.SMITH

Email Channel Contact SMS Channel Contact MobilePush Channel Contact
EmailAddress PhoneNumber DeviceID
john.smith@example.com 555-123-1234 bac87c7c-3d40-472f-8dd6-d5cb0bc9f40c

If you’ve implemented Marketing Cloud Engagement in this way, you could use Data 360 to activate a single channel for an Individual without using Identity Resolution and successfully deliver messages to email, SMS, and MobilePush channels. Because the contact is already unified in Marketing Cloud Engagement, the SubscriberKey is shared by all channels. Journey Builder can use the SubscriberKey value John.Smith to look up the default send addresses stored in Marketing Cloud Engagement for each channel and deliver messages to them.

Single-Channel Contacts

Customers commonly implement Marketing Cloud Engagement using single-channel contacts. Each SubscriberKey has an address for one or two channels but not all three channels.

In the context of this solution kit, single-channel contacts have a unique SubscriberKey for each of the three channels.

This example illustrates a series of separate single-channel contacts within Marketing Cloud Engagement. In this scenario, the person John Smith is represented by three different SubscriberKeys in Marketing Cloud Engagement: John.Smith.Email, John.Smith.SMS, and John.Smith.MobilePush. In this case, the SubscriberKeys can’t execute each channel within an Omni-Channel journey.

MARKETING CLOUD ENGAGEMENT CONTACT
SYSTEM
SubscriberKey: John.Smith.Email SubscriberKey: JohnSmith.SMS SubscriberKey: John.Smith.MobilePush
Email Channel Contact SMS Channel Contact MobilePush Channel Contact
EmailAddress PhoneNumber DeviceID
john.smith@example.com 555-123-1234 bac87c7c-3d40-472f-8dd6-d5cb0bc9f40c

For example, because the customer has separate SubscriberKey values for each channel, Journey Builder can use only the SubscriberKey value John.Smith.Email to retrieve and send to the default send address stored in the Marketing Cloud Engagement email channel. In this instance, SubscriberKey John.Smith.Email sends to email john.smith@example.com. However, this same SubscriberKey can’t send to SMS contact 555-123-1234 or MobilePush SubscriberKeybac87c7c-3d40-472f-8dd6-d5cb0bc9f40c.

If you’re using single-channel contacts, follow this solution kit to use Data 360 to build a Unified Individual that represents a single person consisting of separate Individuals with different contact points. You can then use Data 360 to orchestrate an Omni-Channel journey in Marketing Cloud Engagement.

NOTE It’s common for customers to implement Marketing Cloud Engagement so that the person is represented by two different contacts. One contact supports two channels, for example, SubscriberKey John.Smith.1 is used by email and MobilePush. The other contact supports a third channel, for example, SubscriberKey John.Smith.2 is used by SMS. We recommend following this solution kit to learn how to relate these two separate contacts within Data 360.