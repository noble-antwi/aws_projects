# Ransomware on S3: Simulation and Detection


This project simulates a ransomware attack in an AWS environment, focusing on detection and analysis of unauthorized actions like data exfiltration and deletion. The investigation leverages AWS-native tools such as CloudTrail, Athena, and GuardDuty to identify malicious activity, assess its impact, and provide remediation strategies.

## Why This Project Matters

Cloud storage services like AWS S3 are frequent targets for ransomware attacks. Through this project, I explored:

Simulating real-world ransomware behavior to understand the risks.

Detecting security breaches using AWS-native tools such as CloudTrail, Athena, and GuardDuty.

Strengthening cloud environments by applying best practices in logging, monitoring, and response.

This project deepened my knowledge of incident response in cloud environments, which is critical for my journey as a future Cloud Security Engineer

## Environment Setup

### Provision Resources:

1. Used AWS CloudFormation to create S3 buckets and IAM roles.

2. Enabled logging with the Assisted Log Enabler.

### Prepare Analysis Tools:

1. Set up the AWS Security Analytics Bootstrap for Athena-based queries.

2. Verified setup by running initial queries on CloudTrail logs.

## Investigating Ransomware - Part 1

### Questions - Part 1

#### 1. What is the name of the IAM user that created the bucket and what time was it created?

In answering this question, AWS suggested going trough the listed buckets in order to see any bucket that does not meet the standard naming convention for your environment. Doing that, I was able to see a bucket that has the name starting as `we-stole-ur-data` which is weired and does not meet our naming standard.
![We stole Your Data](<04. Westorele your data.png>)
 This words helped to generate an SQL command that targetted it in Athena in order to obtain API call of `CreateBucket`. The query is

```sql
SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where eventname = 'CreateBucket' and requestparameters like '%we-stole-ur-data-%'
```

![alt text](image-21.png)

This produce a single result and containing the required answer to the question.

**Answer**

1. IAM User that created bucket is `tdir-workshop-rroe-dev`
2. Time of creation is `2025-01-04T23:17:15Z`
 This can be simly put in the form `Date: January 4, 2025
Time: 11:17:15 PM UTC`

##### Other Scenarios

**Scenario 1**

I can use the s3 command below: This command retrieves metadata about all S3 buckets in your AWS account, including their names, creation dates, and regions.

``` bash

aws s3api list-buckets --query "Buckets[?LocationConstraint == 'us-east-1' || LocationConstraint == null].[Name, CreationDate]" --region us-east-1 --output table
```

It lists the names and creation dates of S3 buckets located in us-east-1 or with no region specified (defaulting to us-east-1).

This option can also be used to check for the newly created bucket in the environment.
![s3 query](image-22.png)

**Scenario 2**

This will be to list the bucket created with time specifics using sql query from Athena
To list all newly created buckets in the last 12 hours, you can query the CloudTrail logs for the CreateBucket event and filter by the eventtime field.

```sql
SELECT 
    json_extract_scalar(requestparameters, '$.bucketName') AS bucket_name,
    useridentity.username AS iam_user,
    eventtime AS creation_time
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventname = 'CreateBucket'
  AND from_iso8601_timestamp(eventtime) >= current_timestamp - interval '12' hour
ORDER BY creation_time DESC;

```

![alt text](image-23.png)

The command quickly produced the desired result. I must however state this is contingent on knowing the time the incident happened and can be alterered to meet the desired result.

#### 2. Was the IAM user that created the bucket the same IAM user that uploaded the ransom note?

We cound not asceerttain the result because there was not Server Access Logging Enabled on the bakut hence using the PutObject api call does not
get us any result as illustrated below:

```sql
SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where eventname = 'PutObject' and requestparameters like '%all_your_data_are_belong_to_us.txt%'
```
![alt text](image-24.png)

#### 3. Did the IAM user that created the S3 bucket perform any other actions?**
Running any of the sql queries below, we will identity that the usr permfromed other actions which are below:
1. GetCallerIdentity: This API provides information to the caller about the credentials that are currently in use. It is similar to the whoami command found on most Unix-like operating systems
2. ListBuckets: This API lists buckets in the AWS account
3. PutBucketLogging: This API changes the logging status of an S3 bucket
4. CreateBucket: This API creates buckets in the AWS account, and was the API used to create the suspicious bucket named we-stole-ur-data-*
5. PutBucketTagging: This creates a tag set for an S3 bucket

``` sql

SELECT 
    userIdentity.userName AS iam_user, 
    eventTime, 
    eventName, 
    eventSource, 
    awsRegion,
    requestParameters
FROM 
    "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE 
    userIdentity.userName = 'tdir-workshop-rroe-dev'
ORDER BY 
    eventTime DESC;

 ```

 ![Actions Performed](image.png)

 or

 ``` sql
 SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where useridentity.username = 'tdir-workshop-rroe-dev'
 ```



## Investigating Ransomware - Part 2

### Questions - Part 2

 #### 1. The name of the object that was taken was credit-card-data.csv. In which bucket and prefix/folder location was this object stored?

 To determine the bucket and prefix (folder location) where the object credit-card-data.csv was stored, we need to query the GetObject events for this specific object.
The relevant details are usually found in the requestparameters column.

 ``` sql

 SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where requestparameters like '%credit-card-data.csv%'
 ```

#### 2. The name of the object that was taken was credit-card-data.csv. In which bucket and prefix/folder location was this object stored?

```sql
SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where requestparameters like '%credit-card-data.csv%'
```

![buckets](image-2.png)

or with by using the sql query below

``` sql
SELECT 
    json_extract(requestparameters, '$.bucketName') AS bucket_name,
    json_extract(requestparameters, '$.key') AS object_key
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventsource = 's3.amazonaws.com'
  AND eventname IN ('GetObject', 'PutObject', 'DeleteObject')
  AND requestparameters LIKE '%credit-card-data.csv%';

```

![buckets and thier prefix](image-3.png)

Therfore the name of the bucket is *simulation-bucket-03-bmi5x8fo96zawjcq* and its prefix is *backup/customers/payment_information/credit-card-data.csv*

### 3. Did the ransomware group take the object? If so, what was the date and time?

USING THE PREVIOUS QUERY OF

```sql
SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where requestparameters like '%credit-card-data.csv%'
```

The `useragent` column gives you the various commands run in s3 as shown below
![commands for user agent column](image-4.png)  where we have the `s3.cp` and `s3.rm`. The dates and time are also listed in the image below in teh `eventtime` column in UTC time format.
 ![event time and names](image-5.png)
The time for the GetObject API call is 2024-12-28T01:04:58Z.

**ISO 8601 Format:**  
`2024-12-28T01:04:58Z`  

**Human-Readable Format (UTC):**  
**Date:** December 28, 2024  
**Time:** 01:04:58 AM UTC  

*The same time was used to make the `DeleteObject` api call which is removing of object in the bucket.*

**Using Prompt Engineering**

Using prompt engerrring, I was able to ask ChatGPT to assist in crafting a promt that can get the same result. It gave me one that has only the GetObject API call but i twerked it to add the DeleteObject API call as shown below. The question however was asking only for tge GetObject API call as it did not mention Object removal. The first query illustrate only object retrival usingthe GetObject api call

```sql
SELECT 
    useridentity.arn AS user_arn,
    eventtime AS access_time,
    json_extract(requestparameters, '$.bucketName') AS bucket_name,
    json_extract(requestparameters, '$.key') AS object_key,
    sourceipaddress AS source_ip,
    useragent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventsource = 's3.amazonaws.com'
  AND eventname = 'GetObject'
  AND requestparameters LIKE '%credit-card-data.csv%';
```

![alt text](image-6.png)

For the second query, it included the DeleteObject api call

```sql
SELECT 
    useridentity.arn AS user_arn,
    eventtime AS event_time,
    json_extract(requestparameters, '$.bucketName') AS bucket_name,
    json_extract(requestparameters, '$.key') AS object_key,
    eventname,
    sourceipaddress AS source_ip,
    useragent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventsource = 's3.amazonaws.com'
  AND eventname IN ('GetObject', 'DeleteObject')
  AND requestparameters LIKE '%credit-card-data.csv%';
```

![getdeleted api calls](image-7.png)

#### 4. Was the credit-card-data.csv object deleted?

From the  previous queries it has been determined that, the command `s3.rm` was used by the bad actor which indicates a data removal activity. The api in question here will be `DeleteObject` api. This can also be confirmed by using the ChatGPT prompt below

```sql
SELECT 
    useridentity.arn AS user_arn,
    eventtime AS event_time,
    json_extract(requestparameters, '$.bucketName') AS bucket_name,
    json_extract(requestparameters, '$.key') AS object_key,
    eventname,
    sourceipaddress AS source_ip,
    useragent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventsource = 's3.amazonaws.com'
  AND eventname = 'DeleteObject'
  AND requestparameters LIKE '%credit-card-data.csv%';
```

![Delete Object](image-8.png)

#### 4. What IP address and user agent did the ransomware group use to perform the unauthorized activity?

The ip address used for the unauthorised activity can easily be learned from previous command which includes the `sourceipaddress` field. The identified IP address used for the activities is `54.227.117.56`. The useragent used is `aws-cli/2.22.18 md/awscrt#0.23.4 ua/2.0 os/linux#6.1.119-129.201.amzn2023.x86_64 md/arch#x86_64 lang/python#3.12.6 md/pyimpl#CPython exec-env/CloudShell cfg/retry-mode#standard md/installer#exe md/distrib#amzn.2023 md/prompt#off md/command#s3.cp`. This was also obtained from previous commands but also can be obtained using the Prompt generated below:

```sql
SELECT 
    useridentity.arn AS user_arn,
    eventtime AS event_time,
    json_extract(requestparameters, '$.bucketName') AS bucket_name,
    json_extract(requestparameters, '$.key') AS object_key,
    eventname,
    sourceipaddress AS source_ip,
    useragent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventsource = 's3.amazonaws.com'
  AND eventname IN ('GetObject', 'DeleteObject')
  AND requestparameters LIKE '%credit-card-data.csv%';
```

   ![sourceip and user agent](image-9.png)

#### 5. What is the name of the IAM user that took the object?

The also can be obtained from previous commands. The identified IAM user is `tdir-workshop-jstiles-dev
![IAMuser identification](image-10.png)
`

#### 5. Was the IAM user used to take any other objects?

To obtain the above, we find out the GetObject API calls made by the user by running the sql query below.

```sql
SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where eventname = 'GetObject' and useridentity.username = 'tdir-workshop-jstiles-dev'
```

![Result](image-11.png)

The above command generated 451 results.

ChatGPT prompt also gave a similar one but added the DeleteObject API call.

```sql
SELECT 
    useridentity.userName AS iam_user,
    eventtime AS event_time,
    json_extract(requestparameters, '$.bucketName') AS bucket_name,
    json_extract(requestparameters, '$.key') AS object_key,
    eventname,
    sourceipaddress AS source_ip,
    useragent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventsource = 's3.amazonaws.com'
  AND useridentity.userName = 'tdir-workshop-jstiles-dev'  -- Use the identified IAM user
  AND eventname IN ('GetObject', 'DeleteObject');

```

#### 6. What other activities were performed with this IAM user?

This can be obtained by running a search on the user to see all the eventnames as was performed by the user.

```sql
/* SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where eventname = 'GetObject' and useridentity.username = 'tdir-workshop-jstiles-dev'*/

SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where useridentity.username = 'tdir-workshop-jstiles-dev'
```

This can also be done by using a ChatGPT prompt which gives the query below

```sql
SELECT 
    useridentity.userName AS iam_user,
    eventtime AS event_time,
    eventname AS action,
    eventsource AS service,
    sourceipaddress AS source_ip,
    useragent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE useridentity.userName = 'tdir-workshop-jstiles-dev'  -- IAM user
ORDER BY eventtime DESC;

```

![allevent](image-12.png)
To list the unique events performed by your IAM user `tdir-workshop-jstiles-dev` and count the number of occurrences of each event, I use the `GROUP BY` and `COUNT` clauses in `SQL`. This query will give you a breakdown of how many times each action was performed by your user.

```sql
SELECT 
    eventname AS action,
    COUNT(*) AS event_count
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE useridentity.userName = 'tdir-workshop-jstiles-dev'  -- IAM user
GROUP BY eventname
ORDER BY event_count DESC;
```

| action           | event_count |
|------------------|-------------|
| GetObject        | 451         |
| DeleteObject     | 76          |
| ListObjects      | 9           |
| ListBuckets      | 3           |
| GetCallerIdentity| 2           |
| DeleteAccessKey  | 1           |
| HeadObject       | 1           |
| CreateAccessKey  | 1           |
| ListAccessKeys   | 1           |

![Counting](image-13.png)

## Investigating Ransomware - Part 3

### Question - Part 3

#### 1. Were any buckets deleted? If so, which ones?

To check if any buckets were deleted by the IAM user tdir-workshop-jstiles-dev, you can query the CloudTrail logs for DeleteBucket events. This will show you the names of any buckets that were deleted and the corresponding details.

I first used the GenAI to obtian a query of

```sql
SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventname = 'DeleteBucket';

```

The query gave me no output which indicated that there was no buket deleted.
![No Bucekt Deleted](image-14.png)

I then cross check with what was provided in the exercise by running the query

```sql
SELECT eventtime,eventname,requestparameters FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where eventname = 'DeleteBucket'
```

Which also produced no output indicating that, there was absoulutely no bucket deleted in the account.

#### 2. Were objects taken from any buckets?

To check if any objects were taken (accessed or downloaded) from any buckets in your account, you can query for `GetObject` events, which are triggered when objects are retrieved from S3 buckets.

`Note: This only works for S3 buckets that are configured to log data events to CloudTrail.`

Here’s the query to list all GetObject events, showing which objects were accessed and from which buckets:

```sql
SELECT 
    eventtime AS event_time,
    json_extract(requestparameters, '$.bucketName') AS bucket_name,
    json_extract(requestparameters, '$.key') AS object_key,
    eventname AS action,
    sourceipaddress AS source_ip,
    useragent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventname = 'GetObject'
ORDER BY event_time DESC;
```

The query was a obtained as a result of prompt engineering from AI platform. The result indicates that, there are several data exfiltration that occured
![GetObjects](image-15.png)

### How many bytes were deleted from this bucket? How many bytes were transferred out?

![alt text](image-16.png)
![alt text](image-17.png)

## Investigating Ransomware - Part 4

### Questions - Part 4 

#### It seems as if Server Access Logging was disabled. What was the name of the IAM user that disabled Server Access Logging?

This can be detemrined by using the Guarduty Findings page which. Yhe finsing type identified is `Stealth:S3/ServerAccessLoggingDisabled` which classified as low. The IAM user name identified to have executed this task is the `tdir-workshop-rroe-dev`
![server Access loggin Disbaled](image-18.png)
The above was instruction from the AWS workshop, however, making use of GENAI and Prompt Engineering, i was able to obtain an sql query that was able to fetch the same informaiton. The query is below:

```sql
SELECT 
    useridentity.username AS iam_user,
    eventtime AS action_time,
    eventname AS action,
    CAST(json_extract(requestparameters, '$.bucketName') AS VARCHAR) AS bucket_name,
    json_extract(requestparameters, '$.loggingEnabled') AS logging_status
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE eventname = 'PutBucketLogging'
ORDER BY eventtime DESC;

```

The API call that is responsbile for modifying the server access logging configuration on S3 is `PutBucketLogging` events and hence that was what was targetted in the where clause for the eventname column.

![PutBuketLoggings](image-19.png)

### What time was it disabled?

From the earlier query and Guard Duty finding, we can deteremin that the time the action was taken to diable the access logging for the busket was:
Date: December 28, 2024
Time: 01:05:55 AM UT

### What was the API call that was made to disable Server Access Logging?

From the earlier section, it was detemrin that the API call that disbales the server access logging on S3 is `PutBucketLoggings` which can also be seen in Gaurduty under the action menu as shown below:
![api call](image-20.png)

### Bonus Question: The customer has made you aware of another top-secret, highly confidential file: company-secrets.doc. Was this object deleted? Was it taken?

To determine if the object **`company-secrets.doc`** was deleted or taken, we need to search for specific API actions related to this object in the CloudTrail logs:

1. **Was it deleted?**
   - Look for the `DeleteObject` API call where the object key matches `company-secrets.doc`.

2. **Was it taken?**
   - Look for the `GetObject` API call where the object key matches `company-secrets.doc`.

---

### **SQL Query: Was `company-secrets.doc` Deleted or Taken?**

```sql
SELECT 
    eventname AS action,
    eventtime AS timestamp,
    CAST(json_extract(requestparameters, '$.bucketName') AS VARCHAR) AS bucket_name,
    CAST(json_extract(requestparameters, '$.key') AS VARCHAR) AS object_key,
    useridentity.username AS iam_user,
    sourceipaddress AS source_ip,
    useragent AS user_agent
FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail"
WHERE CAST(json_extract(requestparameters, '$.key') AS VARCHAR) = 'company-secrets.doc'
  AND eventname IN ('DeleteObject', 'GetObject')
ORDER BY eventtime DESC;
```

---

### **Explanation**

1. **`CAST(json_extract(requestparameters, '$.key') AS VARCHAR) = 'company-secrets.doc'`**:
   - Filters the query to focus only on the object `company-secrets.doc`.

2. **`eventname IN ('DeleteObject', 'GetObject')`**:
   - Looks for API actions where the object was either deleted (`DeleteObject`) or accessed (`GetObject`).

3. **`CAST(json_extract(requestparameters, '$.bucketName') AS VARCHAR)`**:
   - Extracts the name of the bucket where the object resides.

4. **`useridentity.username`, `sourceipaddress`, `useragent`**:
   - Captures the IAM user, IP address, and user agent for forensic purposes.

5. **`ORDER BY eventtime DESC`**:
   - Lists the events in reverse chronological order for easy analysis.

The result proved that none of the actions were taken on the object.

NB: the other option will be to use the sql command below:

```sql

SELECT * FROM "irworkshopgluedatabase"."irworkshopgluetablecloudtrail" where requestparameters like '%company-secrets.doc%'
```

This will fetch any request that containe the word company-secrets.doc. This however did also not fetch any result which corroborated the earlier finding.

## **Video Walkthrough**
For a detailed walkthrough of this project, check out the [YouTube playlist](https://www.youtube.com/playlist?list=YOUR_PLAYLIST_ID). The videos cover every aspect of the simulation, investigation, and insights gained.

---

## **Key Learnings**
1. **Incident Response**:
   - Mastered the use of AWS tools like Athena and GuardDuty for forensic investigations.
2. **Log Analysis**:
   - Learned to craft detailed SQL queries to extract insights from CloudTrail logs.
3. **Threat Detection**:
   - Tracked malicious activities, including IP addresses, user agents, and compromised IAM roles.

---

## **Tools and Services Used**
- **Amazon S3**: Target environment for the simulated attack.
- **CloudFormation**: Automated lab environment setup.
- **Amazon Athena**: SQL-based log analysis.
- **GuardDuty**: Detected disabling of server access logging.
- **CloudWatch**: Monitored data deletion and exfiltration.



## **Acknowledgment**

This project was inspired by the AWS workshop **Ransomware on S3: Simulation and Detection**. Special thanks to AWS for providing detailed guidance and tools to simulate real-world security events.

For more information, visit the [AWS CIRT resources](https://catalog.workshops.aws/aws-cirt-ransomware-simulation-and-detection/en-US).