resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  user_data_base64            = var.user_data != null ? base64encode(var.user_data) : null
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = {
    Name = var.instance_name
  }
}
