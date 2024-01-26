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

