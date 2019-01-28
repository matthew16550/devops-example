# Name to be used as identifier throughout the stack
STACK_NAME="devops-example"

# Region to deploy in
AWS_REGION="ap-southeast-2"

# Name of profile in ~/.aws/config to use when creating / updating the stack (needs admin access to various services)
AWS_PROFILE_DEPLOY="devops-example"

# Name of profile in ~/.aws/config to use when testing the stack (needs read-only access to various services)
AWS_PROFILE_TEST="devops-example"

# Name of the CloudWatch log group for logging to be sent to
# Does not matter if it exists or not before creating the stack
# Will not be deleted when this stack is destroyed
CLOUDWATCH_LOG_GROUP="devops-example"

# CIDR that is allowed to SSH into EC2 instances on the stacks public subnet
ALLOW_SSH_FROM_CIDR="0.0.0.0/0"  # TODO pick something narrow!

# Name of SSH key pair that already exists in EC2, it will allow SSH into the stacks EC2 instances
SSH_KEY_PAIR_NAME="devops-example"

# Name of AMI to use for ECS instances
ECS_AMI_NAME="amzn-ami-2018.03.k-amazon-ecs-optimized"

# Name of kong image to use (from Docker Hub)
KONG_IMAGE="kong:1.0.1" # TODO 1.0.2 is released but not yet available in ECS
