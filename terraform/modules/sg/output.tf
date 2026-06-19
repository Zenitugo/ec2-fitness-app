output alb_sg  {
  value       = aws_security_group.alb_sg.id
}


output backend_sg  {
  value       = aws_security_group.backend_sg.id
}

output database_sg  {
  value       = aws_security_group.database_sg.id
}
