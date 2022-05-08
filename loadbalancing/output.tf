output "lb_tg_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}
output "lb" {
  value = aws_lb.ecs_lb.id
}

output "lb_endpoint"{
  value = aws_lb.ecs_lb.dns_name
}