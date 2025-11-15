# 🚀 Production-Grade AWS EKS Infrastructure — Fully Automated with Terraform  

This project is my complete, end-to-end **Kubernetes (EKS) production infrastructure**, automated entirely using **Terraform modules** — architected exactly the way real companies run cloud infra.  
No shortcuts. No copy-paste. Pure hands-on engineering.

---

## 🏗️ What’s Inside (The Real Stuff)
### **🟦 Amazon EKS Cluster**
- Highly available control plane  
- Managed node groups (AutoScaling enabled)  
- kubectl auto-authentication via AWS IAM + OIDC  

### **🌐 VPC Architecture**
- Custom CIDR  
- Public + Private Subnets  
- Internet Gateway  
- NAT Gateway  
- Route tables + associations  
> Designed for secure production workloads.

### **🔐 IAM & Security**
- OIDC provider  
- IRSA for ALB, EFS, Addons  
- Least-privilege IAM roles  
- Security Groups with strict rules  

### **📦 Storage**
- Amazon EFS (HA across AZs)  
- EFS CSI driver (Helm chart)  
- Dynamic PVC provisioning  
- StorageClass → Persistent workloads ready  

### **🌀 Ingress & Load Balancing**
- AWS ALB Ingress Controller  
- L7 routing rules  
- Auto-managed security + target groups  

### **🧰 Supporting Services**
- Bastion Host (Public subnet)  
- SSH access to private nodes  
- Remote backend: S3 + DynamoDB locking  

---




