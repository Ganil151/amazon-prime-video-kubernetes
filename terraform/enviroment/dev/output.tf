output "vpc_id" {
  value = module.vpc.vpc_id
}

output "app_server_public_ip" {
  value = module.App-Server.public_ip
}

output "app_server_instance_id" {
  value = module.App-Server.instance_id
}

output "sonarqube_server_public_ip" {
  value = module.sonarQube-server.public_ip
}

output "sonarqube_server_instance_id" {
  value = module.sonarQube-server.instance_id
}

output "worker_server_public_ip" {
  value = module.worker-server.public_ip
}

output "worker_server_instance_id" {
  value = module.worker-server.instance_id
}

output "private_key_path" {
  value = module.keys.private_key_path
}
