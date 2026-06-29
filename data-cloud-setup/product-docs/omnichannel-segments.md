# Create a Segment to Qualify the Correct Unified Individuals | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_omni_segment.htm&type=5

DATA 360
Create a Segment to Qualify the Correct Unified Individuals

Cumulus creates a segment that qualifies the Unified Individuals they want to use for their journey.

Log in to Data 360 and navigate to the Segments tab.
Click New.
To choose which data model object (DMO) to segment the audience on, select Unified Individual.
Name the segment Omnichannel Credit Limit Alert and add a description.
Select a publish schedule of Don’t refresh.
NOTE Refreshes overwrite and reset the required Send Relationship setting on the resulting data extension.
Add a start date and time and an expiration date.
Click Save.
To build the segment, click Edit Rules.
Drag the Credit Limit Met attribute to the interface.
Select an operator of True.
Click Done.
Add additional attributes and save additional criteria as needed.
Click Save.