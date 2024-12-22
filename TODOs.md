# TODOs and FIXMEs

This document lists all the TODO and FIXME comments found in the project files.

## TODOs

- **General Improvements:**
  - Ensure all Terraform modules are using the latest stable versions.
  - Review and update all IAM policies to follow the principle of least privilege.
  - Add more detailed comments and documentation for complex Terraform configurations.

- **environments/swarms-aws-agent-api/dev/us-east-1/main.tf:**
  - FIXME: Move key_name default value to a settings file or variable.
  - TODO: Move hardcoded AMI IDs to variables or data sources for better maintainability.
  - TODO: Consider using a variable for the instance type to allow flexibility in deployments.

- **modules/aws/ssm/observability/main.tf:**
  - TODO: Add error handling for SSM document executions.
  - TODO: Review and optimize CloudWatch log retention policies.

- **environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/main.tf:**
  - TODO: Implement health checks for the ALB target groups.
  - TODO: Add SSL/TLS configuration for secure communication.

- **environments/swarms-aws-agent-api/dev/us-east-1/components/security/main.tf:**
  - TODO: Review security group rules for potential over-permissiveness.
  - TODO: Implement security group rules for specific IP ranges if applicable.

- **environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/main.tf:**
  - TODO: Automate the AMI creation process using CI/CD pipelines.
  - TODO: Validate the user data script for potential improvements.

- **environments/swarms-deploy/dev/us-east-1/main.tf:**
  - TODO: Ensure all resources are tagged for cost tracking and management.
  - TODO: Review the use of spot instances for cost optimization.

## Documentation

- TODO: Update all README files with the latest setup instructions and architecture diagrams.
- TODO: Add a section in the documentation for troubleshooting common issues.

## Testing and Validation

- TODO: Implement automated tests for Terraform configurations using tools like Terratest.
- TODO: Validate the infrastructure setup in a staging environment before production deployment.

## FIXMEs

- **environments/swarms-aws-agent-api/dev/us-east-1/main.tf:**
  - FIXME: move to settings
