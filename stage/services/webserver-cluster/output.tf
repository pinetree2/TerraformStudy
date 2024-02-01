# output "alb_dns_name" {
#   value = aws_lb.example.dns_name
#   description = "The domain name of the load balancer"
# }

output "alb_dns_name" {
 value = module.webserver_cluster.alb_dns_name
 description = "The domain name of the load balancer"
}

output "asg_name" {
 value = module.webserver_cluster.asg_name
 description = "The name of the Auto Scaling Group"
}