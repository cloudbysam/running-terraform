output "address" {
  value       = aws_db_instance.database.address
  description = "connect to the database at this endpoint."
}

output "port" {
  value       = aws_db_instance.database.port
  description = "The port the database is listening on."
}