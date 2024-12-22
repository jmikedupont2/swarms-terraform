# terraform-template

Terraform project template for deploying infrastructure across multiple environments and regions, following best practices with modular structure and automated syntax checks (GitHub Actions)

## Getting Started

To get started with this Terraform project, follow these steps:

### Prerequisites

- Ensure you have [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
- Install [AWS CLI](https://aws.amazon.com/cli/) and configure it with your credentials.
- Make sure you have access to the necessary AWS resources and permissions.

### Setup

1. **Clone the Repository**

   Clone this repository to your local machine using the following command:

   ```bash
   git clone <repository-url>
   cd terraform-template
   ```

2. **Initialize Terraform**

   Navigate to the environment directory you wish to deploy and initialize Terraform:

   ```bash
   cd environments/swarms-aws-agent-api/dev/us-east-1
   terraform init
   ```

3. **Plan and Apply**

   Review the changes Terraform will make to your infrastructure:

   ```bash
   terraform plan
   ```

   If everything looks good, apply the changes:

   ```bash
   terraform apply
   ```

4. **Verify Deployment**

   After deployment, verify that the resources are created successfully in your AWS account.

### Additional Resources

- Refer to the [Terraform Documentation](https://www.terraform.io/docs/index.html) for more details on using Terraform.
- Check the [AWS Documentation](https://docs.aws.amazon.com/) for information on AWS services.

## Directory Structure Overview

The following is an overview of the directory structure of this Terraform project:

```
terraform-template/                   # Root directory of the Terraform template repository
├── README.md                         # Project documentation and overview
├── environments                      # Contains environment-specific configurations
│   ├── swarms-aws-agent-api          # Example service with various setups
│   │   ├── dev                       # Development environment configuration
│   │   │   └── us-east-1             # Region-specific configuration
│   ├── swarms-deploy                 # Deployment configurations
├── modules                           # Directory containing reusable Terraform modules
│   ├── aws                           # AWS-specific modules
│   ├── github                        # GitHub-related modules
├── accounts                          # Account-specific configurations
│   ├── mdupont                       # User-specific configurations
│   ├── swarms                        # Swarm-specific configurations
├── actions                           # Automation scripts and actions
├── logs                              # Logging scripts and configurations
```

This structure is designed to facilitate modular, maintainable, and scalable infrastructure as code using Terraform.

## Detailed File Structure

### Readmes
- `./README.md`
- `./accounts/swarms/Readme.md`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/Readme.md`
- `./environments/swarms-aws-agent-api/dev/us-east-1/Readme.md`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/Readme.md`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/autoscaling_group/Readme.md`

### Main API Component
- `./environments/swarms-aws-agent-api/dev/us-east-1/main.tf`

### Auto Scaling Group
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/autoscaling_group/main.tf`

### Launch Template
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/launch_template/main.tf`

### Load Balancer
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/main.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/route53/main.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/https/main.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/target_group/main.tf`

### Roles and Security
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/roles/main.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/security/main.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/vpc/main.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/keypairs/main.tf`

### Example Another App
- `./environments/swarms-deploy/dev/us-east-1/components/launch_template/main.tf`
- `./environments/swarms-deploy/dev/us-east-1/components/autoscaling_group/main.tf`
- `./environments/swarms-deploy/dev/us-east-1/main.tf`
- `./environments/swarms-deploy/main.tf`

### Setup SSM Access
- `./modules/aws/ssm/setup/main.tf`
- `./modules/aws/ssm/observability/jobs/main.tf`
- `./modules/aws/ssm/observability/install.sh`
- `./modules/aws/ssm/observability/main.tf`
- `./modules/github/actions/aws/policy/main.json`

### Stage 1 Producing AMI
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/Readme.md`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/variables.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/ubuntu-fastapi.pkr.hcl`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/versions.tf`
- `./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/main.tf`

### Call from GitHub
- `./accounts/swarms/github/main.tf`
- `./environments/call-swarms/deploy.yaml`
- `./environments/call-swarms/main.tf`
- `./.github/workflows/call-swarms.yml`
- `./.github/workflows/terraform-validate.yml`
- `./.github/workflows/terraform-security-check.yml`
- `./actions/call_swarms.sh`

### Observability
- `./logs/logs/202412211604.log`
- `./logs/getlogs.sh`

This detailed file structure provides a comprehensive view of the project's components and their respective locations within the repository.


```
help me create a c4/semantic web/mermaid plantuml deployment  diagram 
for a self service cognito enabled, smart agent server hosting, 
with many different deployment options ranging from t2-small to any larger size.
using terraform, aws, ec2, alb,diagram
accounts/swarms 
		-> environments/swarms-aws-agent-api/dev/us-east-1
		   godaddy -> ns api.swarms.ai ->
		   route53 -> cname ->application load balancer 
		   -> autoscaling group -> launch template -> ami 
	   AMI : components/machine_image/ubuntu-fastapi.pkr.hcl

	   swarms -> ec2, user data
    	  github clone branch run api/install.sh, swarms user, app/boot.sh as swarms user (virtual env)
	      instance profile (our server, customer server) ->
		  todo :read access to specific ssm secrets -> openai key
		   servers tagged as user X can access secrets tagged Y.
		   outgoing ip address : (can talk to other servers) (allow certain ip ranges)
		  , nginx, systemd (isolate user process, write access to home), uvicorn -> swarms 4 processes fast api.
	   
	   githubactions -> oidc connection -> aws -> ssm document -> update your part of the server.
	   githubactions -> oidc connection -> aws -> ssm document -> terraform -> create new clusters 

shared hosted aws account :
   profiles for each customer, 
	tags for customer resources
    which api calls they can use
    tags for cost tracking 
	custom vpc, subsets network resources.
	
	on servers, the agents will have own aws role/profiles (like lamda)
    either each customer/agent gets own unix user, homedir, storage, email , backup.
    containerization, k8s, docker.
```

# diagram1

```plantuml
@startuml

!define RECTANGLE class

RECTANGLE "Self-Service Cognito-Enabled Smart Agent Server" {
  (User)
}

rectangle "Accounts/Swarm" {
  usecase "Create Environments" as U1
  usecase "Deploy EC2 Instances" as U2
  usecase "Manage Load Balancer" as U3
  usecase "Configure Auto-Scaling" as U4
  usecase "Provision AMI" as U5
  usecase "Access SSM Secrets" as U6
  usecase "Update Server Configuration" as U7
  usecase "Track Customer API Calls" as U8
  usecase "Provision Shared Resources" as U9
}

User --> U1 : "Creates / Manages"
User --> U2 : "Deploys Instances"
User --> U3 : "Configures Load Balancer"
User --> U4 : "Sets Auto-Scaling Parameters"
User --> U5 : "Uses AMI for Deployment"
User --> U6 : "Requests Secrets for Access"
User --> U7 : "Updates Configuration"
User --> U8 : "Monitors API Usage"
User --> U9 : "Shares Resources among Customers"

U1 --> "Route53" : "Configures CNAME"
U2 --> "EC2" : "Launches Instances"
U3 --> "ALB" : "Routes Traffic"
U4 --> "AutoScaling Group" : "Manages Scalability"
U5 --> "AMI" : "Provides Machine Image"
U7 --> "GitHub Actions" : "Automates Deploy"
U6 --> "Instance Profile" : "Manages Permissions"
U8 --> "Tags" : "Tracks Costs"

note right of U5 : Component: \ncomponents/machine_image/ubuntu-fastapi.pkr.hcl
note right of U8 : Custom VPC \n\n Customer Profiles

@enduml
```
![1000019322](https://github.com/user-attachments/assets/7f2c8f90-8222-4344-a007-59ea518b0f00)
https://www.planttext.com/?text=RPJVRzem4CVVyrVSUDeUA1gK_dgOccQeGu8AaRAdIfCnbs0riPalRbTD-zztjfCre3q6V_pr-NE7RwaHjd5rbOYgCg-r-gLqcIGVTbWeZR2UPO_fm_rY1h8IH4do_iCWnweOvcXVb4J8JAbLOuOpBROLxY2lEHRI4dK3da4xWDy9mCSDeVsK_4aIYx8HkgmG1gcKnkc6Hlchi7K47Q4Kn8kPHT4WpFIBiaRN74W340IRpttgAnugymQpR0nppNVI4bjitCUMGeiIOM743kv4vJ4RiSdHcKONgdGM8NLygLoAYhL4yBmFhgnvKQICXdGvZ-lJ_ZhV38aWpvTiGLhiQh_eGvl3pjymQeBkRD5mRAGl-_IZ5V8PCaUDgHbFLtF8k7TjyDN_gyltmd9NraZ6sNzghdqVV4DWEFp2Gk6cqqqmWkYA1ZrYx8cecdgUUyGaP7JwwCHq3pptOCv2ZXJ3IbXHOuFsA7NgOVuahnaAOo4MuQUXprruReq_7H87jyO37nlHPoz3Pb1F9z9xr9MdbiRFjgKWUqDifOzSXvjumVGk64Hj-3fTc_ZaXFrwVh0shi7fP71YAdj8bpFE7KUA9paG2-6qtEEnxabaqiLTO48Y0Kz6KIZ9w-VjEfljnDvRumw1RliAVaLiLQMQDzuoRRVuCRvfHsV7r5B8lNy9vdMyzcNaxbNppMrPgnT6OOi_hGusOtCOleXmLpfmQg4gF2fZXRPMH24cOTzXnwCeOsYOTjyVRYWxr8R_A5QL-mPC4USYC_N1Q1w46tZIilkWKHqB_w5yuIEtvGV63Gl1bHpKsU7PdkrbTPhdknrR1jzN6USzwVT_MbiyFuAtg7VyPFu5

### Explanation:
- This diagram represents the primary use cases associated with your smart agent server project.
- Each use case such as creating environments, deploying EC2 instances, and accessing SSM secrets represents functionalities your system supports.
- Annotations explain the components (like AMI) and setups (like custom VPC) tied to specific activities. 


```plantuml
@startuml

!define RECTANGLE(x) rectangle x as x
!define DIAMOND(x) diamond x as x

package "Accounts/Swarm" {
    RECTANGLE(swarms-aws-agent-api) {
        package "Environments" {
            RECTANGLE(dev) {
                RECTANGLE(us_east_1) {
                    RECTANGLE(Godaddy)
                    RECTANGLE(Route53)
                    RECTANGLE(ALB) as alb
                    RECTANGLE(AutoScalingGroup) as asg
                    RECTANGLE(LaunchTemplate) as lt
                    RECTANGLE(AMI) as ami
                }
            }
        }
    }
    Godaddy -> Route53: ns api.swarms.ai
    Route53 -> alb: CNAME
    alb -> asg
    asg -> lt
    lt -> ami: "components/machine_image/ubuntu-fastapi.pkr.hcl"

    package "EC2 Instance" {
        RECTANGLE(EC2) {
            RECTANGLE(UserData)
            RECTANGLE(InstanceProfile)
            RECTANGLE(Nginx)
            RECTANGLE(Systemd)
            RECTANGLE(Uvicorn)
            RECTANGLE(FastAPI)

            EC2 -> UserData: github clone branch run
            EC2 -> InstanceProfile: read access to SSM secrets
            EC2 -> Nginx: isolates user process
            EC2 -> Systemd: manage services
            EC2 -> Uvicorn: "4 instances of FastAPI"
        }
    }

    UserData -> EC2: "run api/install.sh"
    InstanceProfile -> EC2: "access tagged secrets"
    Nginx -> Systemd: "manage processes"
}

package "GitHub Actions" {
    RECTANGLE(OIDC) {
        RECTANGLE(SSM_Document)
        RECTANGLE(Terraform)
    }
    OIDC -> AWS
    AWS -> SSM_Document: "update server"
    OIDC -> AWS: "create new clusters"
    AWS -> Terraform
}

package "Shared Hosted AWS Account" {
    RECTANGLE(Profiles) {
        RECTANGLE(Tags)
        RECTANGLE(VPC)
    }
    Profiles -> Tags: "customer resources"
    Profiles -> VPC: "subnet resources"
    Profiles -> EC2: "instance roles"
}

@enduml


Here's an updated PlantUML deployment diagram reflecting your architecture with key components:

```plantuml
@startuml

!define RECTANGLE(x) rectangle x as x
!define DIAMOND(x) diamond x as x

package "Accounts/Swarm" {
    RECTANGLE(swarms-aws-agent-api) {
        package "Environments" {
            RECTANGLE(dev) {
                RECTANGLE(us_east_1) {
                    RECTANGLE(Godaddy)
                    RECTANGLE(Route53)
                    RECTANGLE(ALB) as alb
                    RECTANGLE(AutoScalingGroup) as asg
                    RECTANGLE(LaunchTemplate) as lt
                    RECTANGLE(AMI) as ami
                }
            }
        }
    }
    Godaddy -> Route53: ns api.swarms.ai
    Route53 -> alb: CNAME
    alb -> asg
    asg -> lt
    lt -> ami: "components/machine_image/ubuntu-fastapi.pkr.hcl"

    package "EC2 Instance" {
        RECTANGLE(EC2) {
            RECTANGLE(UserData)
            RECTANGLE(InstanceProfile)
            RECTANGLE(Nginx)
            RECTANGLE(Systemd)
            RECTANGLE(Uvicorn)
            RECTANGLE(FastAPI)

            EC2 -> UserData: github clone branch run
            EC2 -> InstanceProfile: read access to SSM secrets
            EC2 -> Nginx: isolates user process
            EC2 -> Systemd: manage services
            EC2 -> Uvicorn: "4 instances of FastAPI"
        }
    }

    UserData -> EC2: "run api/install.sh"
    InstanceProfile -> EC2: "access tagged secrets"
    Nginx -> Systemd: "manage processes"
}

package "GitHub Actions" {
    RECTANGLE(OIDC) {
        RECTANGLE(SSM_Document)
        RECTANGLE(Terraform)
    }
    OIDC -> AWS
    AWS -> SSM_Document: "update server"
    OIDC -> AWS: "create new clusters"
    AWS -> Terraform
}

package "Shared Hosted AWS Account" {
    RECTANGLE(Profiles) {
        RECTANGLE(Tags)
        RECTANGLE(VPC)
    }
    Profiles -> Tags: "customer resources"
    Profiles -> VPC: "subnet resources"
    Profiles -> EC2: "instance roles"
}

@enduml
```


It seems there was some confusion. Here’s a refined version of the complete PlantUML deployment diagram for your smart agent server setup:

```plantuml
@startuml

!define RECTANGLE(x) rectangle x as x
!define DIAMOND(x) diamond x as x

package "Accounts/Swarms" {
    RECTANGLE("swarms-aws-agent-api") {
        package "Environments" {
            RECTANGLE("dev") {
                RECTANGLE("us-east-1") {
                    RECTANGLE(Godaddy)
                    RECTANGLE(Route53)
                    RECTANGLE(ALB) as alb
                    RECTANGLE("AutoScalingGroup") as asg
                    RECTANGLE("LaunchTemplate") as lt
                    RECTANGLE("AMI") as ami
                }
            }
        }
    }
    Godaddy -> Route53: ns api.swarms.ai
    Route53 -> alb: CNAME
    alb -> asg
    asg -> lt
    lt -> ami: "components/machine_image/ubuntu-fastapi.pkr.hcl"

    package "EC2 Instance" {
        RECTANGLE("EC2") {
            RECTANGLE("UserData") as userdata
            RECTANGLE("InstanceProfile") as ip
            RECTANGLE("Nginx") as nginx
            RECTANGLE("Systemd") as systemd
            RECTANGLE("Uvicorn") as uvicorn
            RECTANGLE("FastAPI") as fastapi

            EC2 -> userdata: "github clone branch run api/install.sh"
            EC2 -> ip: "read access to SSM secrets"
            EC2 -> nginx: "isolates user process"
            EC2 -> systemd: "manages services"
            EC2 -> uvicorn: "4 instances of FastAPI"
        }
    }

    userdata -> EC2: "execute boot.sh"
    ip -> EC2: "access tagged secrets"
    nginx -> systemd: "manage processes"
}

package "GitHub Actions" {
    RECTANGLE("OIDC") {
        RECTANGLE("AWS")
        RECTANGLE("SSM Document")
        RECTANGLE("Terraform")
    }
    OIDC -> AWS
    AWS -> SSM Document: "update server"
    OIDC -> AWS: "create new clusters"
}

package "Shared Hosted AWS Account" {
    RECTANGLE("Profiles") {
        RECTANGLE("Tags")
        RECTANGLE("VPC")
    }
    Profiles -> Tags: "customer resources"
    Profiles -> VPC: "subnet resources"
    Profiles -> EC2: "instance roles"
}

note right of ami: "Designed for\nFastAPI deployments"
@enduml
```

### Key Components:
1. **Accounts/Swarms**: Represents the main framework for your smart agent server.
2. **Environments**: Contains different environments such as `dev` in `us-east-1`.
3. **EC2 Instance**: Details the EC2 setup, including user data and necessary components (Nginx, Systemd, Uvicorn).
4. **GitHub Actions**: Integrates CI/CD using OIDC, SSM, and Terraform.
5. **Shared Hosted AWS Account**: Manages profiles, tags, and VPC configurations for customer resources.

You can copy this code into a PlantUML tool to visualize the deployment diagram.
### Explanation:
- **Packages and Rectangles**: The diagram encapsulates components like Route 53, ALB, and Auto Scaling Group within a structured format.
- **Interactions**: Arrows show the relationships and interactions among components, such as the CNAME setup with Route 53 and the EC2 instances launching user data scripts.
- **GitHub Actions**: Represents automation activities and connections to AWS services.
- **Shared AWS Account**: Displays customer management and tagging for resources.

This structure captures your specifications for the deployment of a self-service Cognito-enabled smart agent server using Terraform and AWS components effectively. Adjust as necessary for your specific documentation needs!```

### Explanation:
- The main structure includes the accounts, environments, EC2 instances, GitHub Actions, and shared AWS resources.
- The individual components and their interactions are represented using rectangles for entities and arrows for relationships.
- Customize further by adding details and refining the relationships based on your specific needs.```

To manage a shared hosted AWS account for multiple customers with the requirements you've laid out, you can consider the following architecture:

### AWS Account Structure:
1. **Profiles**: Utilize IAM roles and users for each customer. Create separate profiles in the AWS CLI for easy access.
   
2. **Resource Tagging**: Implement a consistent tagging strategy for all resources (e.g., `CustomerName`, `Project`, `Environment`, `CostCenter`) to facilitate cost management and resource identification.
   
3. **API Call Restrictions**: Use IAM policies to specify which API calls each customer's role can perform based on their needs.

4. **Cost Tracking**: Leverage AWS Cost Explorer and AWS Budgets, filtering by tags to track costs per customer.

5. **Networking**: Set up custom VPCs for customers if isolation is required. Use subnets and security groups to segment resources.

### Server and Agent Management:
1. **AWS Roles for Agents**: Each agent (server) should have an IAM role assigned that grants necessary permissions. If using Lambda, this can be done via execution roles.

2. **Unix User Management**: Depending on your requirements:
   - One option is to create a Unix user for each customer/agent.
   - Assign unique home directories, storage solutions (e.g., EBS, S3), and ensure proper permissions.
   
3. **Containerization**: Use Docker and Kubernetes (EKS) to manage applications. This allows for easier resource allocation and isolation between different customers.

4. **Email & Backup**: Consider using Amazon SES for email needs and AWS Backup/CloudFormation for automated backups of customer data.

### Best Practices:
- **Security**: Regularly audit IAM roles and policies for least privilege access.
- **Monitoring**: Use CloudWatch for logging and monitoring resource utilization.
- **Cost Management**: Use AWS Cost Allocation Reports to analyze customer costs effectively.

This architecture ensures streamlined operations, cost tracking, and enhanced security across customer resources in a shared AWS account.    



### Repo Structure Overview

- **Root Directory**: The main container of your Terraform project (`terraform-template/`).
  
- **README.md**: Provides an overview and documentation for the project, helping users understand its purpose and how to use it.

- **Environments**: Contains specific configurations for different environments (e.g., development, staging).
  - **swarms-aws-agent-api**: An example service with various setups.
    - **dev/us-east-1**: The development environment tailored for the US East (N. Virginia) region.

- **Modules**: Encapsulates reusable Terraform code to ensure DRY (Don't Repeat Yourself) principles.
  - **swarms**: A collection of Terraform modules related to the swarm infrastructure.

### Components Explained

- **DNS Management**:
  - Using GoDaddy for domain management and AWS Route 53 for DNS routing (e.g., `api.swarms.ai`).

- **Application Layer**:
  - Includes an Application Load Balancer directing traffic to an Auto Scaling Group, which manages instances defined by a launch template.

- **Instance Management**:
  - AMIs (Amazon Machine Images) created using Packer (e.g., `ubuntu-fastapi.pkr.hcl`).

- **Settings for EC2 Instances**:
  - User data scripts to set up necessary configurations, such as cloning from GitHub and running scripts as the `swarms` user to set up the FastAPI application.

- **Access Management**:
  - IAM roles and instance profiles are created to manage permissions. SSM (AWS Systems Manager) secrets are tagged, allowing specific servers to access configurations, like OpenAI keys.

- **Networking**:
  - Outbound traffic settings defined to control which IP ranges can communicate with the infrastructure.

- **Application Deployment**:
  - Utilizes Nginx and Systemd to manage FastAPI processes, ensuring multiple instances run smoothly.

### CI/CD with GitHub Actions
- Implements OIDC connections to AWS for secure deployments and updates using GitHub Actions.
- SSM documents are utilized for executing specific management tasks, like creating new clusters and updating configurations seamlessly.

This structure facilitates a modular, maintainable, and automated approach to infrastructure as code using Terraform, alongside solid CI/CD practices.



It seems you might want to continue with a task or scenario related to the previous content but haven't specified what you'd like next. If you need more details or a specific aspect of the Terraform setup, architecture diagram, or other inquiries, please let me know, and I'll be glad to assist!
