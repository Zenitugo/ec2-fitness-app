###################### Export ALB DNS NAME #######################

output "alb_dns_name" {
    value = module.alb.alb_dns_name
}