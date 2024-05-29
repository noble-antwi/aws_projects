# THREE TIER ARCHITECTURE IMPLEMENTATION ON AWS

The three-tier architecture is a widely adopted software design pattern that divides applications into three distinct layers: the presentation layer, the business logic layer, and the data storage layer. This segmentation facilitates better organization and scalability, particularly in client-server environments like web applications. Each tier performs specific functions and can be managed independently, contrasting with the older monolithic approach where all components were integrated into a single entity.

When it comes to implementing such architectures in the cloud, Amazon Web Services (AWS) stands out as a leading provider offering a plethora of cloud computing services. Some key AWS services essential for building a robust three-tier cloud infrastructure include Elastic Compute Cloud (EC2), Auto Scaling Group, Virtual Private Cloud (VPC), Elastic Load Balancer (ELB), Security Groups, and the Internet Gateway. By leveraging these services, developers can design systems that are highly available and fault-tolerant, ensuring uninterrupted performance even in the face of failures.

In practical terms, utilizing AWS services enables developers to deploy scalable virtual servers (EC2) that automatically adjust to fluctuating demands (Auto Scaling Group). They can also create isolated network environments (VPC) with controlled access and traffic routing (Security Groups, Internet Gateway) while distributing incoming traffic across multiple instances for better performance and reliability (ELB). This approach reflects a paradigm shift towards more resilient and adaptable cloud-based architectures, aligning with modern application development practices.

![Architecture](media/001Three-Tier-Architecture.drawio.png)

Architectrual Diagram can be found at 
https://drive.google.com/file/d/12wnWdic_07iAOk1HJWzQ00iMLe-AVaQk/view?usp=sharing

Our goal is to address several key aspects in designing our application infrastructure:

1. Scalability: Each tier of our architecture should be capable of scaling horizontally to accommodate varying levels of traffic and requests. This can be achieved by dynamically adjusting the number of EC2 instances in each tier and load balancing across them. For example, we can add more instances to handle increased demand and scale down during periods of lower traffic automatically.
2. Fault Tolerance: We design our infrastructure to withstand unexpected changes in traffic and faults. This involves implementing redundancy measures, such as maintaining extra EC2 instances to handle increased load without compromising performance. By distributing the workload across multiple instances, we mitigate the impact of failures and ensure uninterrupted service.
3. Security: Our infrastructure prioritizes security by minimizing exposure to external threats. We establish private communication channels within the application, using private IPs and subnet configurations. The presentation tier remains isolated in a private subnet accessible only through an application load balancer, while backend and database tiers are similarly protected from internet access. Additionally, we implement security measures like Bastion hosts for remote SSH access and NAT gateways for internet connectivity within private subnets. AWS security groups further enhance our defenses by restricting access to authorized entities only.
4. High Availability: Unlike traditional data centers that are susceptible to regional disasters, we leverage AWS's multiple availability zones to ensure high availability. By distributing our application across different geographical locations, we minimize the risk of downtime due to localized events like earthquakes or power outages
5. Modularity: We aim to break down our application into separate, manageable components, allowing teams to focus on specific tiers independently. This modular approach ensures agility in making changes and enables quick recovery from unexpected issues by isolating and addressing faulty parts.
In summary, our approach focuses on achieving a well-structured, scalable, highly available, fault-tolerant, and secure infrastructure tailored to meet the demands of modern application environments.

Now that we have gotten introduced to the task at hand, we proceed to execute it.
NB:
Original Project Source as an AWS Workshop that can be found using the link 
https://catalog.us-east-1.prod.workshops.aws/workshops/85cd2bb2-7f79-4e96-bdee-8078e469752a/en-US/introduction
## Project Setup

The setup phase of this workshop involves downloading code from Github, uploading it to an S3 bucket for accessibility by instances, and creating an AWS Identity and Access Management (IAM) EC2 role. This role facilitates secure connections to instances using AWS Systems Manager Session Manager, eliminating the need for SSH key pairs.
This was started by cloning the orinal project from AWS on Github in order to access the project file as can be seen below:
![Cone Projectss](media/002_CloningOriginalProjectFromAWS.png)

### Creating S3 Bucket
I created a buket by name *three-tier-web-application-bucket* which will serve as a place holder for all the application codes and other important file. In the creation process, all the default were maintained in order to achieve maximum security. The bucket was created in the US East (N. Virginia) us-east-1 region.
![Creating of Bucket](<media/003_Creating of Bucket.png>)

### IAM EC2 Instance Role Creation
Role Created name is *three-tier-webapp-EC2-SSM-S3* which has two permissions attached namely
1. AmazonSSMManagedInstanceCore
2. AmazonS3ReadOnlyAccess

The tust relationship created is
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```
![IAMRoel](media/004_CreatingIAMRole.png)


### Networking and Security
In this section we will be building out the VPC networking components as well as security groups that will add a layer of protection around our EC2 instances, Aurora databases, and Elastic Load Balancers.

#### VPC Creation

Under this section, i selected VPC only and name it *three_tier_webapp_vpc* iwth CIDR of 10.0.0.0/16
![alt text](media/005_VPCOnly.png) 

#### Creation of Subnets
In this activity as depicted by the Architectural Diagram
![Subnet Creation](media/006_CreationOfSubnets.png)

#### Adding an Internet Gateway
Though some subnets are named as Public, they are in actual not yet made public to recieve traffic from the internet. This can only be achieved by attaching an Internet Gateway module and configuring the Routes