resource "aws_instance" "this" {
  for_each = var.resources

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = try(var.subnet_ids[each.value.subnet_name], null)
  key_name                    = try(each.value.key_name, null)
  associate_public_ip_address = try(each.value.associate_public_ip_address, false)

  vpc_security_group_ids = try(
    [for sg in each.value.security_groups : var.security_group_ids[sg]],
    []
  )

  dynamic "root_block_device" {
    for_each = try(each.value.root_volume_size, null) != null ? [1] : []
    content {
      volume_size = each.value.root_volume_size
      volume_type = try(each.value.root_volume_type, "gp3")
    }
  }

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
