output "alb-dns-name" {
  value       = aws_lb.load-balancer.dns_name
  description = "The domain name of the load balancer."
}

output "asg_name" {
  value       = aws_autoscaling_group.auto-scale.name
  description = "The name of the autoscaling group"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the security group attached to the load balancer."
}

output "ec2_security_group_id" {
  value       = aws_security_group.network.id
  description = "The ID of the security group attached to the ec2 launch template."
}

output "route53_name_servers" {
  value       = aws_route53_zone.primary[*].name_servers
  description = "The 4 AWS Name Servers to copy and paste into NameCheap"
}

output "alb_zone_id" {
  value       = aws_lb.load-balancer.zone_id
  description = "The internal canonical hosted zone ID of the Application Load Balancer"
}

# output "cloudfront_dns_name" {
#   value       = aws_cloudfront_distribution.cdn.domain_name
#   description = "The global domain name assigned to your CloudFront distribution"
# }