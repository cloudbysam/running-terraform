output "alb_dns_name" {
  value       = module.webserver-cluster.alb-dns-name
  description = "The domain name of the load balancer"
}

output "name_servers_for_namecheap" {
  value       = module.webserver-cluster.route53_name_servers
  description = "Copy these 4 name servers and paste them into custom DNS settings on NameCheap"
}