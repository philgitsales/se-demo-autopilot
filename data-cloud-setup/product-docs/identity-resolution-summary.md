# Identity Resolution Ruleset Processing Results | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_resolution_summary.htm&type=5

DATA 360
Identity Resolution Ruleset Processing Results

Summary statistics are available after a ruleset job runs for the first time. Results of the most recent run are shown in the Resolution Summary. Results from previous days are listed in the processing history table. If the ruleset was processed more than one time per day, the results in the processing history table reflect the last run completed during the day.

TERM DEFINITION
Ruleset Name The name given to the ruleset.
Ruleset Status

Indicates the ruleset’s status.

New—The ruleset was created, but no match or reconciliation rules have been added. The ruleset job hasn’t run yet.
Publishing—Ruleset publication is in progress. Data from the last publish is available until publishing is complete. Reload the page to see the updated status.
Published—The ruleset was published. Changes to the ruleset are used the next time that the ruleset job runs.
Deleting—Ruleset deletion is in progress.
Delete Failed—The ruleset deletion failed. Contact Salesforce Customer Support for help.
Error—The ruleset has a problem. Contact Salesforce Customer Support for help.

Last Job Status

Indicates the status of the most recent ruleset job.

Blank (no status)—The ruleset was created, but no match or reconciliation rules have been added.
Scheduled—The ruleset job is ready and waiting to start running.
In Progress—The ruleset job is running. Unified profiles from the last successful publish are available until the job is completed.
Succeeded—The ruleset job ran successfully.
Succeeded with Warnings—The job was completed but one or more errors resulted in some records being skipped or filtered out during matching. See Troubleshoot Identity Resolution Ruleset Processing Errors for help with understanding and resolving errors.
Skipped—The ruleset job was skipped because there were no changes to data streams, to records in the source data model object, or to the ruleset's configuration.
Error—There was a problem running the ruleset job. Contact Salesforce Customer Support for help.
Failed—The ruleset job failed. Contact Salesforce Customer Support for help.

Source Profiles The count of profiles in the source data model objects.
Total Unified Profiles Number of unified customer profile records that the ruleset job created.
Consolidation Rate

The amount by which source profiles were combined to produce unified profiles, calculated as 1 - (number of unified individuals / number of source individuals).

For example, if you ingest 100 source records and create 80 unified profiles, your consolidation rate is 20%.

To increase the consolidation rate, try adding more match rules. To reduce the consolidation rate, try removing some match rules.

Known Unified Profiles The number of unified profiles made up of at least one known source profile.
Anonymous Unified Profiles The number of unified profiles made up of only anonymous source profiles.