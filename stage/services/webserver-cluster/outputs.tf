output "alb-dns-name" {
  value       = aws_lb.load-balancer.dns_name
  description = "The domain name of the load balancer."
}