output "alb_dns_name" {
  value = aws_lb.test-spot-lb.dns_name
  description = "The domain name name of the application load balancer"
}