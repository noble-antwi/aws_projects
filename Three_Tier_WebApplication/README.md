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

#### Adding Internet Gateway

Internet Gateway created was calle *ThreeTierWebApp_IGW* which was the only Internet Gatway created in addition to the Default Gateway
![IGW](media/007_InternetGatewayAddedNotAttached.png)

The IGW however is currently not associated with any subnet since it is not attached to any VPC and then aattachedment to subnets, hence none of the subnet is currenlty public, ie.e receiving internrt traffic.

![VPCAttachment](media/008_VPCAttachement.png)

#### NAT Gateway Creation

In order for the instances in the app layer private subnet and DB layer Private subnet to be able to access the internet they will need to go through a NAT Gateway. For high availability, we will deploy one NAT gateway in each of your public. In order for the NAT Gatways to have a static IP, I will also create an Elastic IP in the process

![FirstNATGW](media/010_FirstNATGW.png)

The two Gateways are added Successfully with two Elastic IPs (Public Static IPs)

![ElasticIP](media/012_TwoNGWCreatedSuccesfully.png)

#### Routing Configuration
At this stage, I want to create route table in order to directs traffic in my Infratructure to the right resource. A default route table is already created during the creation of the VPC which aids in establishing Private routing between resources in the Network. This route does not see Public Traffic.

Default Routes can be seen below with its details 
![Routes](media/013_Routes.png)

#### Adding of Public Routes

As depicted in the video below,  a public Route Table was created by name ThreTierWebApp_Public_RT with the configuation details below.

The routes were updates to direct all oubic traffic to the Internet Gatway and the subnet that are associated with this routes are 
1. ThreeTierWebapp_PublicWeb-AZ2(b)
2. ThreeTierWebapp_PublicWeb-AZ1(a)
![PublicROutes](media/016_PublicROutes.png)

#### Adding of Private Routes

Adding Private Routes will ensure tehe APp Tier does not communicate with the internet Directly but rather through  NAT Gateway. As depicted in the video, Two private routes were created which are 
1. ThreeTierWebApp_PrivateApp_AZ1(a)_RT : This routes traffic to Instances in the availabeility Zone A. The subent associated to this route is ThreeTierWebapp_PrivateApp-AZ1(a) with the routes configured below

![alt text](media/017_PrivateAZ1_RT.png)

2. ThreeTierWebApp_PrivateApp_AZ2(b)_RT : Routes Traffic in Availability Zone B. The subnet assocciated to this route is ThreeTierWebapp_PrivateApp-AZ2(b)

![private AZ2](media/018_PrivateAZ2.png)

NB: Routes are not added for the DB subnet because the DB is managed Directly by AWS

### Security Groups

Security groups will tighten the rules around which traffic will be allowed to our Elastic Load Balancers and EC2 instances.
The first security group you’ll create is for the public, internet facing load balancer. After typing a name and description, add an inbound rule to allow HTTP type traffic for your IP.

In following security best practices, the security groups are going to be in the from or a daisy chain.

The first security group you’ll create is for the public, internet facing load balancer. After typing a name and description, add an inbound rule to allow HTTP type traffic for your IP.

The second security group you’ll create is for the public instances in the web tier. After typing a name and description, add an inbound rule that allows HTTP type traffic from your internet facing load balancer security group you created in the previous step. This will allow traffic from your public facing load balancer to hit your instances. Then, add an additional rule that will allow HTTP type traffic for your IP. This will allow you to access your instance when we test.

The third security group will be for our internal load balancer. Create this new security group and add an inbound rule that allows HTTP type traffic from your public instance security group. This will allow traffic from your web tier instances to hit your internal load balancer.

The fourth security group we’ll configure is for our private instances. After typing a name and description, add an inbound rule that will allow TCP type traffic on port 4000 from the internal load balancer security group you created in the previous step. This is the port our app tier application is running on and allows our internal load balancer to forward traffic on this port to our private instances. You should also add another route for port 4000 that allows your IP for testing.

The fifth security group we’ll configure protects our private database instances. For this security group, add an inbound rule that will allow traffic from the private instance security group to the MYSQL/Aurora port (3306).

![SecurityGroups](media/019_SecurityGroups.png)

Detailed Explanation can be find the Video below

# My Video

Here is a video embedded directly in the Markdown file:

<iframe src="https://drive.google.com/file/d/1V11c90i-I1qoUKswBaqd0ZmHFr6zm6Qh/preview" width="640" height="480" allow="autoplay"></iframe>




## Database Deployment

In the RDS Dashboard, the first thing to be done is the creation of the DB subnet group.

![DB Subnet](media/021_DBSubnet.png)

#### Database Deployment
I created the DB with the following details
Database Creations Details

I picked Standard Create and then selected Aurora (MySQL Compatible Version). For the Templates, i went with Dev/Test since this is going to be a Test and not a production workload.
I named the DB Cluster Identifier as ThreeTiierWebApp-Cluster2
For the credentials
Master User is antwinob with Password been 0242.ann
Encryption is een managed by aws/secretesmanager 

In the configuration option, I selected Aurora Standard. IN teh DB instance Class, I selected Memory Optimised Class specifically db.r5.xlarge with 4vCPUs and 32GB RAM, and a Netork of 4750 Mbps
For Multi-AZ deployment, in order to achieve high availability and establish fault tolereance, we went for Multi AZ Deployment.

Under the connectivity option, The ThreeTierWebApp VPC was selected after which the DB Subent group gets populated.The option to access it Publicly has also been turn to No. The secueiry grouo for the DB Tier was selected.

All other options were left in theri default state.
