// TODO I've no idea how secure this bastion is!
module "bastion" {
  source  = "github.com/philips-software/terraform-aws-bastion"
  version = "1.1.0"

  aws_region     = "${var.region}"
  enable_bastion = "true"
  environment    = "${var.stack_name}"
  key_name       = "${var.ssh_key_pair_name}"
  project        = "not-used"
  subnet_id      = "${element(module.vpc.public_subnets, 0)}"
  vpc_id         = "${module.vpc.vpc_id}"

  tags = {
    Stack = "${var.stack_name}"
  }
}
