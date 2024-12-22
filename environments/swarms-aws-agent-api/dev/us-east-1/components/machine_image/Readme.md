# Description: Instructions for managing machine images.
# Author: <Your Name>
# Date: 2024-12-22

machine_image


`tofu apply -destroy -target module.ec2.aws_spot_instance_request.this[0] -auto-approve`

aws ec2 describe-images --owners 099720109477 > images.json
* 
  
tofu state rm "module.ec2.aws_spot_instance_request.this[0]"

# packer build

```
packer init -upgrade ./ubuntu-fastapi.pkr.hcl 
packer fmt ./ubuntu-fastapi.pkr.hcl 
export AWS_DEFAULT_PROFILE=swarms 
packer build ./ubuntu-fastapi.pkr.hcl 
```
