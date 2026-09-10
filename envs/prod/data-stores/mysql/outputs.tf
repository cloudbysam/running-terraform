output "address" {
  value       = module.mysql_database.address
  description = "connect to the database at this endpoint."
}

output "port" {
  value       = module.mysql_database.port
  description = "The port the database is listening on."
}