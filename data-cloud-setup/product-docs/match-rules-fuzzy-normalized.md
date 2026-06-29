# Identity Resolution Match Methods | Salesforce Help

> Source: https://help.salesforce.com/s/articleView?id=data.c360_a_match_rules_criteria_fuzzy_normalized.htm&type=5

DATA 360
Identity Resolution Match Methods

Match rule methods determine how source data is transformed for comparison during matching. Changing the match method on a field typically changes the consolidation rate based on that field.

WARNING Data is transformed for matching purposes when the Fuzzy and Exact Normalized match methods are selected. However, reformatted data is not stored in unified profiles. The format of the value stored in a unified profile is based on source data and determined by reconciliation rules.

Match methods describe the precision with which data is matched during identity resolution. The anticipated consolidation rate is lower when precision matching is required. Selecting a less precise match method typically raises the consolidation rate, but can result in undesirable matches.

Up to five match methods are available for use in creating criteria for custom match rules. The match methods available for each object and field vary. Fuzzy match methods aren’t available for fields from the Account object.

Exact
Exact Normalized
Fuzzy - High Precision
Fuzzy - Medium Precision
Fuzzy - Low Precision

You can refine custom match criteria further by allowing matches to be made between blank fields.

TIP To determine the most effective match method for your data, configure multiple rulesets with different criteria. Compare consolidation rates and decide which match method works best for your unified profiles.
Exact Match Method

The Exact match method is available for all objects and fields. If this match method is used, values match regardless of case.

EXAMPLE

Because exact match is case-insensitive, these four source data values are an exact match:

Maryanne
maryanne
MARYANNE
MaryAnne
Exact Normalized Match Method

The Exact Normalized match method is available for specific fields for the Contact Point Email, Phone, and Address objects.

When this match method is selected, source data is transformed to address issues like trailing spaces, inconsistent formatting, special characters, and more.

OBJECT FIELDS WITH EXACT NORMALIZED MATCH METHOD SUPPORT NORMALIZATION PROCESS
Individual
First Name

Standardizes capitalization so that matches are case-insensitive

Contact Point Email
Email Address

Standardizes capitalization so that matches are case-insensitive
Removes white space from the beginning and end of an email address
Removes non-alphanumeric characters like quotes (“”) and brackets (<>) from email address
For email addresses with the gmail.com domain, removes both period (.) and plus (+) characters from email address

Contact Point Phone
Formatted E164 Phone Number

Removes white spaces from phone number
Removes non-alphanumeric-characters like asterisk (*) and parentheses (()) from phone number
Validates phone number with Google's common Java, C++ and JavaScript library for parsing, formatting, and validating international phone numbers
Uses the country code or name for normalization if it’s available or identifiable based on contact point phone or address records.
If a country code is provided and mapped to the phone country code field (ssot__CountryCode__c) in the Contact Point Phone DMO, the country code is used for normalization.
If the country code isn't available, and if the country name is provided and mapped to the country name field (ssot__CountryId__c) in the Contact Point Phone DMO, the country name is used for normalization.
If a country code or name isn't identifiable from data in the Contact Point Phone DMO, and Contact Point Address DMO exists with a valid mapping to country name, the country name in Contact Point Address DMO is used for normalization.
If a country code or name isn't available, the phone number is normalized without it.

For data sources with phone number country codes, map the Phone Country Code field.

Contact Point Address
Address Line 1
Address Line 2
Address Line 3
State Province
Country

Standardized based on country-specific rules for addresses
EXAMPLE

These source data values are an exact normalized match:

Contact Point Email Object
SOURCE VALUES EXACT NORMALIZED EMAIL ADDRESS FIELD VALUE

<MichelleNoris@gmail.com>
"MichelleNoris"@gmail.com
michellenoris@gmail.com
michellenoris@gmail.com
EXAMPLE

These source data values are an exact normalized match:

Contact Point Phone Object
SOURCE VALUES EXACT NORMALIZED FORMATTED E164 PHONE NUMBER FIELD VALUE

+1 (650) 277-9500
+1 650 277-9500
1 (650) 277-9500
+16502779500
EXAMPLE

These source data values are an exact normalized match:

Contact Point Address Object
SOURCE VALUES EXACT NORMALIZED ADDRESS LINE 1 AND ADDRESS LINE 2 FIELD VALUES EXACT NORMALIZED STATE PROVINCE AND COUNTRY FIELD VALUES

Source 1

Address Line 1: 220 Laurier Avenue West
Address Line 2: Suite 1000
State Province: ON
Country: CA

Source 2

Address Line 1: 220 Laurier Ave W
Address Line 2: Ste 1000
State Province: Ontario
Country: Canada
220 Laurier Ave W Ste 1000 Ontario Canada

Source 1

Address Line 1: 56 Abascal
Address Line 2: Calle de José
State Province: Madrid
Country: ES

Source 2

Address Line 1: Abascal 56
Address Line 2: Calle de José
State Province: Madrid
Country: Spain
Calle De José Abascal 56 Madrid Spain
TIP Exact normalized matches generally lead to higher consolidation rates than exact matches. To determine the most effective match method for your data, configure multiple rulesets. Compare the consolidation rate of each ruleset and decide which works best for our data.
Fuzzy Match Methods

The Fuzzy match methods are available for most fields.

If any of these match methods are used, matches are based on an Artificial Intelligence (AI) model trained with data from over 150 countries, 3 billion English words, and 20 million names. The AI model is built with the Bidirectional Encoder Representations from Transformers (BERT) Language Model to match common misspellings, diacritical marks, synonyms, and more. The AI model has a 0.7 confidence threshold.

To allow more control over the granularity of matching, three levels of precision are available: high, medium, and low precision.

Fuzzy Matching Precision Levels
PRECISION LEVEL DESCRIPTION MATCHING VALUES
Low Precision Matches values with loose similarities.
Lisa, Liza
Cathi, Cathy
Lucia, Luc

Medium Precision Matches values with the same initials, gender variants, shuffled names, and similar subnames.
S., Sharon
A.M., Anthony Michael
Cathi, Cathie
Lilian, Liliana
Gabriel, Gabrielle
José Andrés, Pepe
Joey James, James Joseph

High Precision Matches values across nicknames, punctuation, international abbreviations, international alphabet characters, and cross-cultural spellings.
Beatriz, Beatrice
William, Bill
Mary-Jo, MaryJo
Håkon, Hakon
Catherine, Katherine
TIP Fuzzy matches generally lead to higher consolidation rates than exact matches. To determine the most effective match method for your data, configure multiple rulesets with different criteria. Compare consolidation rates and decide which match method works best for your unified profiles.
SEE ALSO
Salesforce Help: Advanced Match Criteria Settings