# 🔐 AWS Organizations SCP Demo – Restricting S3 Access

This project demonstrates how to use **AWS Service Control Policies (SCPs)** within **AWS Organizations** to enforce access restrictions across multiple AWS accounts.

The implementation showcases a practical example of applying an SCP that **denies access to S3 services** while maintaining full access to all other services — all managed at the **Organizational Unit (OU)** level.

---

## 📌 Project Highlights

- Structured AWS accounts under a centralized **Organization**.
- Created two Organizational Units: `PROD` and `DEV`.
- Moved accounts into their respective OUs.
- Created a custom SCP: **Allow All Except S3**
- Applied the SCP to the `PROD OU`.
- Validated the policy by testing denied access to S3 in the Production account.

---

## 📖 Full Implementation Guide

For a detailed, step-by-step breakdown with screenshots and JSON policy code:

👉 **Read the full guide on Medium:**  
[Using Service Control Policies (SCPs) to Restrict AWS Account Access – A Hands-On Guide](https://medium.com/@noble-antwi/using-service-control-policies-scps-to-restrict-aws-account-access-a-hands-on-guide-f818be31c88f)

---

## 🎯 Key Learnings

- SCPs are not IAM policies but act as **permission guardrails**.
- They apply **across accounts or OUs**, allowing centralized control.
- Deny statements in SCPs always override Allow, making them perfect for critical service restrictions.
- Ideal for enforcing **least privilege** and **compliance boundaries** in large cloud environments.

---

## 🛠️ Technologies Used

- AWS Organizations  
- AWS Identity & Access Management (IAM)  
- Amazon S3  
- SCP JSON policy

---

## 📬 Feedback or Questions?

Feel free to connect with me on [LinkedIn](https://www.linkedin.com/in/noble-antwi/) or drop a comment under the Medium post. I'm always open to discussing cloud security, IAM best practices, or AWS architecture in general.
