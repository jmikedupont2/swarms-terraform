machine_image


`tofu apply -destroy -target module.ec2.aws_spot_instance_request.this[0] -auto-approve`

aws ec2 describe-images --owners 099720109477 > images.json
* 
  
tofu state rm "module.ec2.aws_spot_instance_request.this[0]"
