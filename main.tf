module "rds-mysql-app1" {
  source = "./modules/db"

  region = "ap-southeast-1"
  identifier = "db-app1"
  final-snapshot-identifier = "db-final-snap-shot"
  rds-allocated-storage = "5"
  storage-type = "gp2"
  rds-engine = "mysql"
  engine-version = "5.7.17"
  db-instance-class = "db.t2.micro"
  backup-retension-period = "0"
  backup-window = "04:00-06:00"
  publicly-accessible = "false"
  rds-username = "demo"
  rds-password = "admin123"
  skip-final-snapshot = "true"
  multi-az = "true"
  storage-encrypted = "false"
  deletion-protection = "false"

  vpc_security_group_ids = module.rds-sg.aws-security-group-rds
  rds_private_subnets_groups_name = "govtech-rds-private-subnets-group"
  rds_private_subnets_groups_description = "Allowed Only Private Subnets for Govtech-RDS-MYSQL"
  aws_db_subnet_group_private_subnets = module.vpc.private-subnet-ids
  name-aws-db-subnet-group = "Govtech-rds-subnets-groups"
}

module "ec2-app-v1" {
  source = "./modules/EC2"
  region = "ap-southeast-1"
  key-name = "test"
  ami-id = "ami-0801a1e12f4a9ccc0"
  instance-type = "t2.micro"
  number-of-ec2-instances-required = "3"
  public-key-file-name = "${file("./modules/EC2/test.pub")}"

  associate-public-ip-address = "true"

  vpc-security-group-ids = "${module.Govtech-ec2-sg.ec2-sg-security-group}"
  ec2-subnets-ids = ["${module.vpc.public-subnet-ids}"][0]

  #ec2-subnets-ids = ["${module.Govtech-vpc.private-subnet-ids}"]
  
  user-data = "${file("./modules/EC2/nginx.sh")}"


}

module "rds-sg" {
  source = "./modules/rds-sg"

  region = "eu-west-1"
  aws-security-group-name = "db_sec_grp"
  vpc-id = "${module.vpc.vpc-id}"
  aws-security-group-tag-name = "govtech-sg-rds"
  
  #RULE-1-INBOUND-RULES
  rule-1-from-port= 3306
  rule-1-protocol = "tcp"
  rule-1-to-port = 3306
  rule-1-cidr_blocks = "192.168.0.0/16"

  #RULE-2-INBOUND-RULES
  rule-2-from-port= 1433
  rule-2-protocol = "tcp"
  rule-2-to-port = 1433
  rule-2-cidr_blocks = "192.168.0.0/16"

  #RULE-1-OUTBOUND-RULES
  outbound-rule-1-from-port = 0
  outbound-rule-1-protocol = "-1"
  outbound-rule-1-to-port = 0
  outbound-rule-1-cidr_blocks = "0.0.0.0/0"

}

module "vpc" {
  source = "./modules/vpc"
  ###VPC###
  instance-tenancy = "default"
  enable-dns-support = "true"
  enable-dns-hostnames = "true"
  vpc-name = "Govtech-vpc"
  vpc-location = "Sinagpore"
  region = "ap-southeast-1"
  internet-gateway-name = "Govtech-igw"
  map_public_ip_on_launch = "true"
  public-subnets-name = "public-subnets"
  public-subnets-location = "Singapore"
  public-subnet-routes-name = "public-subnet-routes"
  private-subnets-location-name = "Singapore"
  private-subnet-name = "private-subnets"
  total-nat-gateway-required = "1"
  eip-for-nat-gateway-name = "eip-nat-gateway"
  nat-gateway-name = "nat-gateway"
  private-route-cidr = "0.0.0.0/0"
  private-route-name = "private-route"
  vpc-cidr = "10.11.0.0/16"
  azs = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  vpc-public-subnet-cidr = ["10.11.1.0/24","10.11.2.0/24","10.11.3.0/24"]
  vpc-private-subnet-cidr = ["10.11.4.0/24","10.11.5.0/24","10.11.6.0/24"]
}


module "alb" {
  source = "./modules/alb"

  region = "us-east-1"
  alb-name = "Govtech-alb"
  internal = "false"
  alb-sg = "${module.Govtech-ec2-sg.ec2-sg-security-group}"
  alb-subnets = ["${module.vpc.public-subnet-ids}"][0]
  alb-tag = "Govtech-alb"
  

  #Target Groups

  tg-name = "Govtech-tg"
  port = "80"
  protocol = "HTTP"
  vpc-id = "${module.vpc.vpc-id}"
  no-of-frontend-attachments = "${module.ec2-app-v1.aws-instance}"[0]
}

module "auto-scaling" {
  source = "./modules/asg"

  region = "ap-southeast-1"

  #SSH Keys Genration
  key-name = "test"
  public-key-file-name = "${file("./modules/asg/test.pub")}"

  #Launch Configuration

  launch-configuration-name = "test-lc"
  image-id = "ami-0801a1e12f4a9ccc0"
  instance-type = "t2.micro"
  launch-configuration-security-groups = "${module.Govtech-ec2-sg.ec2-sg-security-group}"
  launch-configuration-public-key-name = "test"

  #Auto-Scaling

  autoscaling-group-name = "test-asg"
  max-size = "4"
  min-size = "1"
  health-check-grace-period = "300"
  desired-capacity = "2"
  force-delete = "true"
  #A list of subnet IDs to launch resources in
  vpc-zone-identifier = "${module.vpc.public-subnet-ids}"
  
  tag-key = "Name"
  tag-value = "testing"

  #Auto-Scaling Policy-Scale-up
  auto-scaling-policy-name-scale-up = "cpu-policy-scale-up"
  adjustment-type-scale-up = "ChangeInCapacity"
  scaling-adjustment-scale-up = "1"
  cooldown-scale-up = "300"
  policy-type-scale-up = "SimpleScaling"

  #Auto-Scaling Policy Cloud-Watch Alarm-Scale-Up
  alarm-name-scale-up = "cpu-alarm-scale-up"
  comparison-operator-scale-up = "GreaterThanOrEqualToThreshold"
  evaluation-periods-scale-up = "2"
  metric-name-scale-up = "CPUUtilization"
  namespace-scale-up = "AWS/EC2"
  period-scale-up = "120"
  statistic-scale-up = "Average"
  threshold-scale-up = "70"

  #Auto-Scaling Policy-Scale-down
  auto-scaling-policy-name-scale-down = "cpu-policy-scale-down"
  adjustment-type-scale-down = "ChangeInCapacity"
  scaling-adjustment-scale-down = "-1"
  cooldown-scale-down = "300"
  policy-type-scale-down = "SimpleScaling"

  #Auto-Scaling Policy Cloud-Watch Alarm-Scale-down
  alarm-name-scale-down = "cpu-alarm-scale-down"
  comparison-operator-scale-down = "LessThanOrEqualToThreshold"
  evaluation-periods-scale-down = "2"
  metric-name-scale-down = "CPUUtilization"
  namespace-scale-down = "AWS/EC2"
  period-scale-down = "120"
  statistic-scale-down = "Average"
  threshold-scale-down = "50"

}

module "Govtech-ec2-sg" {
  source = "./modules/ec2_sg"
  region = "eu-west-2"
  vpc-id = module.vpc.vpc-id
  ec2-sg-name = "ec2-sg"

  ###SECURITY INBOUND GROUP RULES###
  #RULE-1-INBOUND-RULES
  rule-1-from-port= 80
  rule-1-protocol = "tcp"
  rule-1-to-port = 80
  rule-1-cidr_blocks = "0.0.0.0/0"

  #RULE-2-INBOUND-RULES

  rule-2-from-port = 443
  rule-2-protocol = "tcp"
  rule-2-to-port = 443
  rule-2-cidr_blocks = "0.0.0.0/0"

  #RULE-3-INBOUND-RULES
  rule-3-from-port = 22
  rule-3-protocol = "tcp"
  rule-3-to-port = 22
  rule-3-cidr_blocks = "119.153.149.158/32"


  #RULE-4-INBOUND-RULES
  rule-4-from-port = 10000
  rule-4-protocol =  "tcp"
  rule-4-to-port =   10000
  rule-4-cidr_blocks = "192.168.0.0/16"

  #RULE-5-INBOUND-RULES
  rule-5-from-port = 11000
  rule-5-protocol = "tcp"
  rule-5-to-port = 11000
  rule-5-cidr_blocks = "192.168.1.0/24"

  ###SECURITY GROUP OUTBOUND RULES###
  #RULE-1-OUTBOUND-RULES
  outbound-rule-1-from-port = 0
  outbound-rule-1-protocol = "-1"
  outbound-rule-1-to-port = 0
  outbound-rule-1-cidr_blocks = "0.0.0.0/0"

  #NOTE: ONLY ALL PORTS WILL BE "" & CIDR BLOCK WILL IN COMMAS ""
}
