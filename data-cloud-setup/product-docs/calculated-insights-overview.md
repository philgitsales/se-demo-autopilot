# Enhance Data with Insights | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_insights.htm&type=5

DATA 360
Enhance Data with Insights

With insight features, you can define and calculate multidimensional metrics from your entire digital state stored in Data 360.

NOTE

As of October 14, 2025, Data Cloud has been rebranded to Data 360. During this transition, you may see references to Data Cloud in our application and documentation. While the name is new, the functionality and content remains unchanged.

Your metrics can include customer lifetime value (LTV), most viewed categories, and customer satisfaction score (CSAT), or any other metrics.

After creating your insights, put them into effect for your streaming insights with data actions.

Calculated Insights

Use a calculated insight to define and calculate multidimensional metrics on your entire digital state in Data 360. You can create metrics at the profile, segment, and population levels. For example, you can evaluate performance at the channel level or use product metrics to understand purchasing and browsing behavior.

Marketers can use metrics, dimensions, and filters to define segment criteria and personalization attributes for activation. Data analysts can also visualize the insights in CRM Analytics to understand data patterns.

Calculated insights can help you understand each stage of the customer journey by analyzing various metrics. Here are some benefits.

Build metrics on large-scale data in Data 360 by using analytical functions for in-depth analysis. For example, rank customers by spend or engagement scores.

Calculate custom metrics with logic, mathematics, statistics, time series functions, and complex workflows.

Automatically recompute calculated insights when the base data changes. The calculated insight automatically adds the incremental data changes.

Access the Visual Insights Builder for point and click insight creation. The SQL-based insights authoring experience provides data engineers with appropriate tools for their role and experience.

Turn insights into actions as they’re integrated into segmentation and activation.

Streaming Insights

Get insights more quickly by creating metrics on streaming data. Streaming insights are aggregation queries based on real-time engagement data for a rolling time window. Insights process the data from streaming data sources, such as Web SDK and Mobile SDK. Use a streaming insight to build time series aggregation, in near real time, that you can use to drive orchestration or data actions in Data 360.

Note: Segment and activation don't support streaming insights.

You can use streaming insights and data actions to support different use cases. Review these examples to discover ways to apply the functionality.

Service and support: A customer visited a troubleshooting page before calling support. Having this information helps support skip unnecessary troubleshooting steps that the customer has attempted.
Intelligent routing: When used with Service Cloud, send a notification to PagerDuty if a customer escalates a case.
Customer feedback: Intercept near real time customer reviews and drive satisfaction improvement actions, such as creating a case.
Account engagement: Intercept inactive accounts for customer engagement signals in near real time to drive re-engagement.
Points balances: Update the point balance in Salesforce CRM based on order transaction and social share.
Log scanning: Filter streaming device log data based on error codes to find the most frequent errors and determine if the device needs servicing.
Lead scoring: Perform lead scoring based on near real-time user actions, such as a customer requesting a product feature in a forum.
Real-Time Insights

Use real-time insights to build more complex personalization logic for your website. With real-time insights, you can track cumulative website activity to see if the user’s activity meets defined thresholds.

For example, use a customer’s active browsing behavior to:

Calculate which products the customer is most interested in and deliver personalized recommendations.
Calculate the value of items in a customer’s cart to see if they qualify for a discount.
Get a count of the number of times the customer has clicked a product to track product category preferences.

You can create real-time insights with a real-time data graph and related data model objects (DMOs). Data 360 calculates and stores insights in the data graph. You can use real-time insights with segmentation and activation as part of a real-time data graph.

How Are Calculated, Streaming, and Real-Time Insights Different?
CALCULATED INSIGHTS STREAMING INSIGHTS REAL-TIME INSIGHTS
How is data processed? High volume data processing and metrics generation. Continuous stream processing as Data 360 receives data. Time windows as little as 1 minute. In real-time, with results in milliseconds.
How is data collected? Collected in batches as sets of records and processed as unit. Work on events as they’re updated via streaming data from Web SDK and Mobile SDK. Data 360 processes insights for every event that updates in the real-time data graph.
How can you use this data in Data 360? Perform complex calculations usually needing large historic data. Handle micro batches of a few records. Calculates an insight from a single record to drive personalization logic using aggregate metrics.
Example Use Case Customer rank by spending. Click stream analysis, ecommerce, transactions. Personalized ecommerce experience with recommendations based on which products the user is viewing.
Billing Considerations for Insights
Use of insights impacts the consumption of credits used for billing in these usage types.
Authoring Methods for Insights
Design and implement insights using visual building tools or direct SQL syntax to meet specific analytical requirements. Authors can transform raw data by joining, aggregating, or filtering datasets through node-based workflows and streaming functions. With these methods you can clone existing logic, save drafts, and apply complex SQL operators to generate real-time or calculated metrics. You gain the flexibility to build sophisticated data models from scratch or use pre-configured packages for faster deployment.
Authoring Considerations for Insights
With strategic planning your Data 360 insights deliver accurate, high-performance data visualizations for your business users. You can optimize your data processing with complex joins, relative time-windows, and advanced metric layering.
Managing Insights
Manage calculated insights to drive data-informed decisions with precision. Configure history tracking to monitor long-term metric trends and maintain data integrity. You can schedule automated processing, manually trigger updates, and validate results to ensure your team accesses accurate analytics. Efficiently organize your insight using the list view to edit or delete records as your business needs evolve.