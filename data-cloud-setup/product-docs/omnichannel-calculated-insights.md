# Create a Calculated Insight to Select the MobilePush SubscriberKey | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_omni_ci.htm&type=5

DATA 360
Create a Calculated Insight to Select the MobilePush SubscriberKey

Data 360 has numerous controls to select and activate a channel contact point. However, for some scenarios, you must create a Calculated Insight to filter or select a specific channel contact point. For example, Data 360 doesn’t support activating the Email, SMS, and MobilePush channels together.

NOTE If your Omni-Channel journey includes Email and SMS but not MobilePush, you can skip this step.

The Calculated Insight output includes the attribute MobilePush Key, which you can add as a direct attribute when you activate the Unified Individual. This action ensures that the activated data extension in Marketing Cloud Engagement has the contact point values for the Email, SMS, and MobilePush channels. Journey Builder can use these contact points to orchestrate Omni-Channel journeys.

NOTE Marketing Cloud Engagement requires a SubscriberKey to execute MobilePush sends.
Using this SQL, Cumulus creates a Calculated Insight that searches all of a Unified Individual’s MobilePush SubscriberKeys and selects the SubscriberKey with the most recent app engagement.

select rk.ssot__Id__c as UnifiedIndividual_Id__c,rk.ssot__PartyId__c as MobilePush_SubscriberKey__c,count(*) as NUMRECORDS FROM ( select UnifiedIndividual__dlm.ssot__Id__c as ssot__Id__c ,ssot__ContactPointApp__dlm.ssot__PartyId__c as ssot__PartyId__c, rank() over (PARTITION by ssot__ContactPointApp__dlm.ssot__PartyId__c order by ssot__DeviceApplicationEngagement__dlm.ssot__EngagementDateTm__c desc) as rank__c FROM UnifiedIndividual__dlm INNER JOIN IndividualIdentityLink__dlm ON UnifiedIndividual__dlm.ssot__Id__c = IndividualIdentityLink__dlm.UnifiedRecordId__c LEFT JOIN ssot__ContactPointApp__dlm ON ssot__ContactPointApp__dlm.ssot__PartyId__c = IndividualIdentityLink__dlm.SourceRecordId__c LEFT JOIN ssot__DeviceApplicationEngagement__dlm ON ssot__DeviceApplicationEngagement__dlm.ssot__IndividualId__c = IndividualIdentityLink__dlm.SourceRecordId__c WHERE IndividualIdentityLink__dlm.ssot__DataSourceId__c = 'YOUR_SFDATASOURCE' ) rk where rk.rank__c = 1 group by rk.ssot__Id__c, rk.ssot__PartyId__c