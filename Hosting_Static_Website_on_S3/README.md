# HOSTING STATIC WEBSITE ON AWS SIMPLE STORAGE SERVICE (S3)

## Architecture Diagram


![architecture](https://user-images.githubusercontent.com/34815693/232652445-d9808091-d468-455d-bd99-d079b526a183.png)


[Click Here ](https://drive.google.com/file/d/1RThadyvBUDHQ9Iq3EfiYAybB2DizmtJi/view?usp=sharing) to have access to he architectural diagram

## Introduction


Hosting a static website on the cloud has become a popular choice for many individuals and businesses today. It offers scalability, flexibility, and cost-effectiveness that traditional hosting options can't match. Amazon Web Services (AWS) provides an excellent platform for hosting static websites through its Simple Storage Service (S3).



*A static website is a website that consists of fixed web pages that are displayed to the user exactly as they were created. These web pages are typically created using HTML, CSS, and other front-end web development technologies. Unlike dynamic websites, which generate content on the fly using server-side scripting languages, static websites have pre-built pages that are stored on a server and sent to the user's web browser upon request.*

**Some Benefits of Using S3 and Route 53 for Hosting the Website**
+ Cost-effective: Amazon S3 and Route 53 are both very cost-effective solutions for hosting static websites. You only pay for the storage and bandwidth that you use, and there are no upfront costs or minimum fees.

+ Scalability: S3 and Route 53 are both highly scalable services, meaning they can easily handle a large volume of traffic and data without any performance issues.

+ Reliability: Both services offer high availability and durability, with multiple backups and redundancies built in to ensure your website is always accessible.

+ Security: S3 and Route 53 both offer robust security features, such as encryption at rest and in transit, access control, and data protection.

+ Easy to use: Setting up and managing a static website on S3 and Route 53 is relatively easy and straightforward, even for non-technical users.

+ Custom domain support: Route 53 makes it easy to map your custom domain name to your S3 bucket, allowing you to use your own branded domain for your static website.



In this project, I will be focusing on how to host a static website on S3 and link it to a domain name [qerbos.com](qerbros.com) purchased from [GoDaddy.com](GoDaddy.com.) Additionally, I will be using Amazon Route 53 to create a hosted zone for our domain name, which will allow us to map our domain name to the S3 bucket hosting our website.

This project will provide you with a step-by-step guide to creating and configuring your S3 bucket, setting up your hosted zone on Route 53, and linking the two together to create a functional website.


## Setting up S3 bucket for hosting the static website
A series of processes were caried out in setting up the S3 for this purpose.
1. Log in to your AWS account and navigate to the S3 console. 
![s3_console](https://user-images.githubusercontent.com/34815693/232654353-78aac826-97f3-49e7-bf2b-67e8d2edefc3.PNG)
2. Click the "Create bucket" button and enter a unique name for your bucket, this case it is qerbros.com since the bucket name must match the domain name. 
![bucket_name](https://user-images.githubusercontent.com/34815693/232652616-c2cab426-277e-4d72-a11f-b80ff42c3db7.PNG)



In creating the bucket, all settings were left to be deafult. The region of choice is US East (N. Virginia) us-east-1 as seen in the image above.
3. Upload the website files into the bucket as seen below

![web_file](https://user-images.githubusercontent.com/34815693/232652644-72a20295-1c73-41b1-8dc5-042294a53b03.PNG)

4. Uder the properties tab, Click on "Static website hosting" and choose "Use this bucket to host a website  after clicking the edit option. 
![static](https://user-images.githubusercontent.com/34815693/232653861-a3310349-7976-4752-9cee-45437a90ca24.PNG)

Under the edit button, I indicated the landing page of my website which is the index.html file. I did not use an error file in this project hence was left blank.
![index](https://user-images.githubusercontent.com/34815693/232652707-afb575e2-8dd2-4137-8552-68d40326e0e9.PNG)
5. Under the permissions menu, public access is enabled for the backet.
![public](https://user-images.githubusercontent.com/34815693/232654039-c6c641dc-e044-476c-a457-83058f8fabf2.PNG)

 A bucket policy was then created. The policy is as witten bellow
 ```
 {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::qerbros.com/*"
        }
    ]
}
```
The object ownership was changed to ACLs enabled


![acl](https://user-images.githubusercontent.com/34815693/232652741-e8c9a3c9-9934-4173-ba4b-c1b8ff612ce6.PNG)



Access Control List was edited to suit the project as indicated below

![Control](https://user-images.githubusercontent.com/34815693/232652819-e54265a6-e043-4bb5-91f3-ba2ec3f1b67e.PNG)



The deafult website acess point is given as *http://qerbros.com.s3-website-us-east-1.amazonaws.com*


## Configuring Route 53 
Amazon Route 53 is a highly scalable and reliable cloud-based Domain Name System (DNS) web service offered by AWS (Amazon Web Services). It provides developers and businesses with a way to route end-users to Internet applications by translating human-readable domain names (such as www.example.com) into the IP addresses (such as 192.0.2.1) that computers use to identify each other on the Internet.

Route 53 is designed to provide a fast and reliable way to route traffic to web applications by leveraging the vast infrastructure of AWS. It can be used to register domain names, create DNS zones, and manage the traffic routing policies for your web applications. It also provides advanced features such as traffic flow management, health checks, and DNS failover, which can help you ensure the availability and reliability of your web applications.

In summary, Amazon Route 53 is a powerful DNS service that can be used to manage your domain names and route traffic to your web applications. It is a key component of the AWS ecosystem and is widely used by developers and businesses to manage their web infrastructure on the cloud.

In this project however, the Domain name was bought from GoDaddy. Route 53 was used to create a hosted Zone for which the name servers for replaced in Godaddy with the ones provided by the Route 53 Hosted Zone.

In configuring the Route 53, follow the steps stipulated below:

1. Log in to your AWS account and navigate to the Route 53 console.
![reoute53](https://user-images.githubusercontent.com/34815693/232652873-5dd5fbf5-231a-4e1f-9729-878d82263ce3.PNG)

2. Click on "Hosted Zones" in the left-hand menu and then click on the "Create Hosted Zone" button.
3. Enter your domain name (qerbros.com) and click "Create Hosted Zone.". Ensure you select public zone since it will be assessible via the internet.

![hosted_zone](https://user-images.githubusercontent.com/34815693/232652910-e1c3826f-6d6f-4061-add6-7424a9f9f7ca.PNG)


4. You will be redirected to the "Record Sets" tab. Click on "Create Record Set."

5. Leave the name field blank, select "A - IPv4 address" for the type, and choose "Yes" for "Alias."
6. In the "Alias Target" field, select your S3 bucket from the dropdown list.
7. Click on "Create" to create the record set.

![arecord](https://user-images.githubusercontent.com/34815693/232652964-898fa79a-7782-42b5-bf82-3f42c4ce7eed.PNG)





8. Go back to your S3 bucket and click on the "Properties" tab.
9. Click on "Static Website Hosting" and copy the Endpoint URL.
```
http://qerbros.com.s3-website-us-east-1.amazonaws.com

```
10. Go back to the Route 53 console, click on "Create Record Set" again, and enter "www" for the name.
11. Select "CNAME - Canonical name" for the type, and leave the "Alias" field as "No."
12. In the "Value" field, paste the Endpoint URL of your S3 bucket (e.g. "my-bucket.s3-website-us-west-2.amazonaws.com"). 
![cname1](https://user-images.githubusercontent.com/34815693/232653043-1d83595a-99a5-428e-b358-dfe9b35a1e1b.PNG)






13. Click on "Create" to create the record set.

![records](https://user-images.githubusercontent.com/34815693/232653085-aa89e25e-2fa4-48bb-afd0-6e5603f501d4.PNG)




The above image containes all the records created for the hosted zone. Te NS (Name Server) record containes the name servers that will be doing the resolution. They are stated below:
```
ns-873.awsdns-45.net.
ns-1383.awsdns-44.org.
ns-1767.awsdns-28.co.uk.
ns-66.awsdns-08.com.
```

Since my domain name was bought on Godaddy, I set these NS values in the GoDaddy NS settings as show below.

![godaddy](https://user-images.githubusercontent.com/34815693/232653167-a96f76ef-22d5-40b8-bfe4-72761f58a2f2.PNG)




## Video Demonstration



https://user-images.githubusercontent.com/34815693/232653245-0b3270ba-3a0e-41ab-9d78-3df0caaf42ad.mp4



## Conclusion
In conclusion, hosting a static website on AWS using S3 and Route 53 is a cost-effective and scalable solution that can provide high availability, reliability, and performance. With S3, you can store and distribute your website content to users around the world with low latency and high throughput. With Route 53, you can manage your domain name system and route traffic to your web applications, providing a seamless user experience.

To optimize your static website hosting experience on AWS, here are some recommendations:

* Enable caching and compression: By enabling caching and compression, you can improve the performance and reduce the cost of hosting your static website on S3. This can be achieved by configuring the appropriate metadata headers on your S3 objects.

* Use CloudFront: CloudFront is a content delivery network (CDN) offered by AWS that can help improve the performance and reduce the latency of your static website by caching your content in edge locations around the world.

* Implement security best practices: When hosting your static website on S3, it's important to implement security best practices to protect your website content and users' data. This includes configuring S3 bucket policies, setting up access control, and enabling SSL/TLS encryption.

* Monitor your website: It's important to monitor your website to ensure that it's always available and performing optimally. This can be achieved by setting up health checks and monitoring tools such as AWS CloudWatch.

By following these recommendations, you can ensure that your static website hosting on AWS is reliable, scalable, and cost-effective.






