output "instance_id" {

  value = aws_instance.ollama_server.id

}

output "public_ip" {

  value = aws_instance.ollama_server.public_ip

}