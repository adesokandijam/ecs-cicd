output "public_subnet" {
  value = aws_subnet.public_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.ecs-vpc.id
}
output "lb_sg"{
    value = aws_security_group.lb.id
}

output "task_sg" {
  value = aws_security_group.hello_world_task.id
}