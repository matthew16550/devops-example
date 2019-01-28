This is a work in progress demo project using [Terraform](https://www.terraform.io/) to create an [Amazon ECS](https://aws.amazon.com/ecs/)
cluster running the following:

 * [Kong API Gateway](https://konghq.com/kong/)
 * [nginx-hello](https://github.com/nginxinc/NGINX-Demos/tree/master/nginx-hello) (A "Hello World" web server)
 
# Prerequisites

* Development and testing was done on macOS.  It probably works ok on Linux too. 
 
* [Docker](https://docs.docker.com/install/) installed locally.

* `SETTINGS.sh` adjusted to your liking.

* An [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) as named in `SETTINGS.sh`.

* AWS credentials for the [Profile(s)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
  named in `SETTINGS.sh`.
  
  e.g. in `~/.aws/credentials`:
  ```
  [devops-example]
  aws_access_key_id=...
  aws_secret_access_key=...
  ```
  
  and in `~/.aws/config`:
  ```
  [profile devops-example]
  region=ap-southeast-2
  ```

# Deploying

1. Run `bin/stack-create.sh` to create everything.
    
1. Run `bin/test.sh` to check the stack is working properly.

# Undeploying

Run `bin/stack-destroy.sh` to destroy everything except for the logs in CloudWatch (which should be destroyed manually).

# Things not yet addressed

* Instance / DB sizing is chosen to suit the AWS Free Tier
* Kong
  * Authentication for Admin API
* Kong Database
  * Enable deletion protection 
  * Backups
  * Storage size
  * At rest encryption
  * SSL connections
  * Proper password
  * Kong gets password via Secrets Manager
* Logging
   * From ECS instance hosts (tasks are already sending to CloudWatch)
* High availability / multi-zone etc
* HTTPS instead of HTTP everywhere
* Network
  * ACLs (much less verbose after https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/173)
  * Is ALB talking via IPv6 
* Testing
  * Network ACLs / Security Groups (haven't figured out how to test whats actually happening)
  * ECS instance exists  
* Static analysis
  * https://github.com/elmundio87/terraform_validate - will do simple stuff, inactive project, wont do modules
  * https://github.com/eerkunt/terraform-compliance - looks active, not sure about modules
* Are health checks pointing at paths that actually indicate health?
* ...
