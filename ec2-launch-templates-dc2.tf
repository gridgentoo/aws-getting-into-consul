# Consul Server Launch Template DC2
resource "aws_launch_template" "consul_server_dc2" {
  name_prefix            = "${var.main_project_tag}-server-lt-dc2-"
  image_id               = var.use_latest_ami ? data.aws_ssm_parameter.ubuntu_1804_ami_id.value : var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.consul_server_dc2.id]

  # uses the same as DC1
  iam_instance_profile {
    name = aws_iam_instance_profile.consul_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${var.main_project_tag}-server-dc2" },
      { "Project" = var.main_project_tag }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { "Name" = "${var.main_project_tag}-server-volume-dc2" },
      { "Project" = var.main_project_tag }
    )
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-server-lt-dc2" },
    { "Project" = var.main_project_tag }
  )

  user_data = base64encode(templatefile("${path.module}/scripts/server-dc2.sh", {
    PROJECT_TAG   = "Project"
    PROJECT_VALUE = var.main_project_tag
    BOOTSTRAP_NUMBER = var.server_min_count_dc2
    GOSSIP_KEY = random_id.gossip_key.b64_std
    CA_PUBLIC_KEY = tls_self_signed_cert.ca_cert.cert_pem
    SERVER_PUBLIC_KEY = tls_locally_signed_cert.server_dc2_signed_cert.cert_pem
    SERVER_PRIVATE_KEY = tls_private_key.server_dc2_key.private_key_pem
    BOOTSTRAP_TOKEN    = random_uuid.consul_bootstrap_token.result # defined in ec2-launch-templates.tf
  }))
}

# Consul Client API DC2 Launch Template
resource "aws_launch_template" "consul_client_api_dc2" {
  name_prefix            = "${var.main_project_tag}-api-lt-dc2-"
  image_id               = var.use_latest_ami ? data.aws_ssm_parameter.ubuntu_1804_ami_id.value : var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.consul_client_dc2.id]

  # Same as Dc1
  iam_instance_profile {
    name = aws_iam_instance_profile.consul_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${var.main_project_tag}-api-dc2" },
      { "Project" = var.main_project_tag }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { "Name" = "${var.main_project_tag}-api-volume-dc2" },
      { "Project" = var.main_project_tag }
    )
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-api-lt-dc2" },
    { "Project" = var.main_project_tag }
  )

  user_data = base64encode(templatefile("${path.module}/scripts/client-api-dc2.sh", {
    PROJECT_TAG   = "Project"
    PROJECT_VALUE = var.main_project_tag
    GOSSIP_KEY = random_id.gossip_key.b64_std
    CA_PUBLIC_KEY = tls_self_signed_cert.ca_cert.cert_pem
    CLIENT_PUBLIC_KEY = tls_locally_signed_cert.client_api_dc2_signed_cert.cert_pem
    CLIENT_PRIVATE_KEY = tls_private_key.client_api_dc2_key.private_key_pem
  }))
}