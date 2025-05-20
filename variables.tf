# 변수 정의
variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = string
  default     = "eyjo-ec2-rsa-pem"  # 실제 키 페어 이름으로 대체하세요
}

variable "key_name_ed25519" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = string
  default     = "eyjo-ec2-ed25519-pem"  # 실제 키 페어 이름으로 대체하세요
}


variable "latest_ami_al2_ssm_parameter" {
  description = "(DO NOT CHANGE)"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


/*
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu*24.04*" "Name=architecture,Values=x86_64" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table
*/
