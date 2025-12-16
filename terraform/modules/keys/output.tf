output "key_name" {
  value       = aws_key_pair.kp.key_name
  description = "Name of the SSH key pair"
}

output "private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the private key file"
}
