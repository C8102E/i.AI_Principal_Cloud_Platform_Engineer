# Terraform AWS Infrastructure

Terraform code that will take the components of a python ETL pipeline and deploy it to AWS services.

## Prerequisites

- AWS Account
- Terraform installed
- AWS CLI installed and configured

- ## Infrastructure Diagram
```mermaid
graph TD;
    EventBridge[EventBridge<br>weather_trigger] -->|Triggers| LambdaRetrieve[Lambda<br>weather_retrieve]
    LambdaRetrieve -->|Stores data in| S3Landing[S3 Bucket<br>weather_landing]
    S3Landing -->|Notification on Object Creation| LambdaETL[Lambda<br>weather_etl]
    LambdaETL -->|Processes and stores transformed data in| S3Transformed[S3 Bucket<br>weather_transformed]
    IAMRole[IAM Role<br>iam_for_lambda] -->|Assumed by| LambdaRetrieve
    IAMRole -->|Assumed by| LambdaETL

    classDef aws fill:#f9f,stroke:#333,stroke-width:4px;
    class EventBridge,LambdaRetrieve,LambdaETL,S3Landing,S3Transformed,IAMRole aws;
```
- ## Infrastructure Diagram
### Structuring the Files
The files are organised based on their purpose and content:

**main.tf:** This file acts as the entry point of the Terraform module. It includes the provider configuration and any resource that doesn't fit neatly into other categories. It's the module should be initiated from with provider specifics.
**variables.tf:** This file declares variables that will be used across multiple resources or modules. Declaring variables here allows for easier customisation of the Terraform configurations without hardcoding values into the resource configurations.
**locals.tf:** This file defines local values that are meant to be reused within the module. Locals can help avoid repetition and make the configuration more readable.
**iam.tf, lambda.tf, eventbridge.tf, s3_buckets.tf:** These files contain resources related to their namesakes. Splitting resources into separate files by their functionality or service type helps keep the configuration organised.