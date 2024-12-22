# Plan
## Phase 1

0. create standard vpc with a private network to host ec2, 
so we will put the intances in public for now and use security groups to limit access.
1. create minimal ec2 instance in machine_image
terraform  for ubuntu python uvicorn fastapi nginx systemd server with custom code pulled in via git
2. create minimal ec2 ami from instance in machine_image
3. create autoscaling_group of size 1 for image
4. create application load balancer
5. create dns_entry
6. packer ami for ubuntu python uvicorn fastapi nginx systemd server with custom git modules
7. oidc connect from github to aws

# todo 

0. create role for developers to run ssm job
to deploy new service.
1. call from github action.
2. have least privlege
3. allow for calling ssm with information about context
4. route to server
5. retrieve logs
6. provision other services to be used by the agents

0. run_only to only run the server without installing everything
1.  alb sticky sessions :send users back to server via sticky sessions or some id.
2. create cognito user pool for login
4. create work_queue
5. create lambda_workers on queue
6. create resource_launchers to create new resources.
7. use fine grained roles
https://github.com/cloudposse/terraform-aws-ssm-iam-role.git
8. create user home directories for different agent
9. look at  natgw alternatives
that costs money https://aws.amazon.com/vpc/pricing/
10. check in copy of swagger

11. swarms router
12. fluid api
13. agent service discovery
14. setup ticketing interface
15. 
