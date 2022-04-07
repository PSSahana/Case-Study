
output "aws-security-group-rds" {
  value = "${aws_security_group.db_sec_grp.id}"
}