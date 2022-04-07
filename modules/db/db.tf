provider "aws" {
  region = "${var.region}"
}


resource "aws_db_instance" "db" {
  identifier = "${var.identifier}"
  final_snapshot_identifier = "${var.final-snapshot-identifier}"
  allocated_storage = "${var.rds-allocated-storage}"
  storage_type = "${var.storage-type}"
  engine = "${var.rds-engine}"
  engine_version = "${var.engine-version}"
  instance_class = "${var.db-instance-class}"
  backup_retention_period = "${var.backup-retension-period}"
  backup_window = "${var.backup-window}"
  publicly_accessible = "${var.publicly-accessible}"
  username = "${var.rds-username}"
  password = "${var.rds-password}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  db_subnet_group_name = "${aws_db_subnet_group.rds_instance_subnets.name}"
  skip_final_snapshot = "${var.skip-final-snapshot}"
  multi_az = "${var.multi-az}"
  storage_encrypted = "${var.storage-encrypted}"
  deletion_protection = "${var.deletion-protection}"

}


resource "aws_db_subnet_group" "rds_instance_subnets" {
  name = "${var.rds_private_subnets_groups_name}"
  description = "${var.rds_private_subnets_groups_description}"
  subnet_ids = ["${var.aws_db_subnet_group_private_subnets}"][0]
  tags = {
    Name = "${var.name-aws-db-subnet-group}"
  }
}