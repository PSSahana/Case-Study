


output "rds-end-point" {
  value = "${aws_db_instance.db.endpoint}"
}