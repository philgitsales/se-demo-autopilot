# Create Segments in Data 360 | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_segments.htm&type=5

DATA 360
Create Segments in Data 360

Use segmentation in Data 360 to break down your data into useful segments to understand, target, and analyze your customers. After you create a segment, you can publish it to an activation target.

NOTE

As of October 14, 2025, Data Cloud has been rebranded to Data 360. During this transition, you may see references to Data Cloud in our application and documentation. While the name is new, the functionality and content remains unchanged.

You can create segments on objects from your data model, and then publish them on a chosen schedule or as needed. Whether basic or complex, segments are crucial in using Data 360. Learn about building segments with the attribute library, extending segments with calculated insights, and filtering your segment data.

Limitations with Composite Keys:

The Segment Canvas relies on predefined relationships to join data. Because these relationships currently support only a single field, Data 360 can't automatically join data using all fields in a composite key. This can lead to inaccurate population counts or segments that randomly select only one field for the join.
Composite keys function correctly only when users write manual queries where every field in the composite key is explicitly defined in the join logic.
To ensure consistent and accurate results in segmentation, use data model objects (DMOs) with a single, unique primary key.
Create a Standard Segment in Data 360
Create a standard segment based on a data model object and then publish the segment to activation targets.
Create a Real-Time Segment
Create a real-time segment that completes on demand in milliseconds. To make the segment available in your real-time data graph, add the Segment ID and Timestamp fields from the segment membership DMO object to the real-time data graph. You can’t use a real-time segment with exclusion criteria and nested batch segments. You also can't use segment counts and manual publish with a real-time segment.
Create a Waterfall Segment
If you’re running a campaign with multiple offers, use a waterfall segment to process a list of existing segments in a priority order. The primary goal is to ensure that an individual who qualifies for more than one segment is placed only into the highest-priority segment they match. This creates a series of mutually exclusive audiences, which is ideal for campaigns where you want to send customers only one, most-relevant offer.
Create a Dynamic Segment
Create a dynamic segment based on a Data Model Object (DMO) and run segment queries without persisting data in Segment Membership DMOs. Define attribute filters with placeholders that accept dynamic values at execution time.
Create a Segment from a Data Kit
Instead of creating a segment from scratch in Data 360, use a predefined segment from a data kit. You can edit and fine-tune the segment.
Segment Canvas
Use the segment canvas in Data 360 to select direct and related attributes to narrow down a created segment to your target audience.
Troubleshoot Segment Errors
Get tips for solving the most common segment errors in Data 360.
Segmentation Filter Examples
Review examples of filters for various types of segmentation use cases. Use these examples as a starting point for your segments, which you can tailor by adding more filters to fit your campaigns.
Einstein Segments in Data 360
Create segments with Einstein Segment Creation generative AI. Enter a high-level description of your segment and receive a suggested segment and all its attributes. Easily draft another segment by changing the description, or edit the segment’s attributes to make adjustments. After you’re satisfied with your segment, publish and activate it.
Billing Considerations for Segmentation
Segmentation uses Data 360 for processing and publishing segment data. Use of segmentation impacts the consumption of credits in these usage types.